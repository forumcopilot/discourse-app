import 'dart:convert';
import 'dart:io';

import 'package:discourse_core/discourse_core.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:test/test.dart';

/// Offline request-volume measurement.
///
/// Answers from an in-process [HttpServer] instead of a real forum, so the
/// counts below are assertions rather than anecdotes read off a `flutter run`
/// log. No network access and no `test/config.json` required.
///
/// Uses `package:test` rather than `package:flutter_test` on purpose: the
/// flutter_test binding installs an HTTP mock that fails every request with
/// 400, which would make these numbers meaningless (and, as it happens,
/// would make the chat probe below record a false "installed").
///
/// What is being measured: the chat-plugin route probe in
/// [DiscourseConfigProxy.getConfig]. For a signed-out visitor
/// `/chat/api/me/channels` answers 403, and [DiscourseClient] deliberately
/// caches only 2xx — so before the probe was memoized, every caller of
/// getConfig spent a request on a route the guest provably cannot use.
void main() {
  late HttpServer server;
  late Map<String, int> hits;

  /// Serves the three endpoints `getConfig` touches. `/chat/api/me/channels`
  /// answers [chatStatus] — 403 is what try.discourse.org gives a guest.
  Future<String> startServer({required int chatStatus}) async {
    hits = <String, int>{};
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((HttpRequest req) async {
      final path = req.uri.path;
      hits[path] = (hits[path] ?? 0) + 1;
      final res = req.response..headers.contentType = ContentType.json;
      switch (path) {
        case '/about.json':
          res.statusCode = 200;
          res.write(jsonEncode({
            'about': {'version': '3.4.0.beta1'}
          }));
          break;
        case '/site/settings.json':
          res.statusCode = 200;
          res.write(jsonEncode({'min_search_term_length': 3}));
          break;
        case '/chat/api/me/channels':
          res.statusCode = chatStatus;
          res.write(jsonEncode(chatStatus == 200
              ? {'public_channels': [], 'direct_message_channels': []}
              : {
                  'errors': ['You are not permitted to view that resource.']
                }));
          break;
        default:
          res.statusCode = 404;
          res.write(jsonEncode({
            'errors': ['not found']
          }));
      }
      await res.close();
    });
    return 'http://${server.address.address}:${server.port}';
  }

  SiteContext contextFor(String url) => SiteContext(
        siteType: 'discourse',
        site: Site(
          name: 'Measurement',
          url: url,
          baseUrl: url,
          description: '',
          siteType: 'discourse',
        ),
      );

  setUp(() {
    // flutter_test may have installed a 400-returning HTTP mock.
    HttpOverrides.global = null;
    // Both caches are process-lifetime state that outlives a single test.
    DiscourseClient.invalidateReadCache();
    DiscourseSiteContextExtension.resetChatProbeCache();
  });

  tearDown(() async {
    await server.close(force: true);
  });

  test('a signed-out cold launch probes the chat route once, not per getConfig',
      () async {
    final url = await startServer(chatStatus: 403);
    final context = contextFor(url);
    final proxy = DiscourseConfigProxy(context);

    // The bootstrap calls getConfig three times in ~600ms:
    // SiteInitializationService, SiteController._performSiteInitialization,
    // and SiteHomePage's post-frame "is the site still up?" verification.
    for (var i = 0; i < 3; i++) {
      await proxy.getConfig(url, forceRefresh: true);
    }

    // Control: /about.json answers 200, so the existing read cache already
    // collapses it. This isolates the probe as the thing that escaped.
    expect(hits['/about.json'], 1, reason: '2xx reads are already cached');

    // Was 3 before this change — one 403 per getConfig caller.
    expect(hits['/chat/api/me/channels'], 1,
        reason: 'the 403 route must not be re-probed by every getConfig');

    // And the answer is still right: 403 means the route exists.
    expect(context.chatEnabled, isTrue);
  });

  test('a 404 chat route is also remembered, and reports chat as absent',
      () async {
    final url = await startServer(chatStatus: 404);
    final context = contextFor(url);
    final proxy = DiscourseConfigProxy(context);

    for (var i = 0; i < 3; i++) {
      await proxy.getConfig(url, forceRefresh: true);
    }

    // `false` has to be a remembered answer, not "not yet asked" — otherwise
    // a forum without chat re-probes its 404 on every getConfig forever.
    expect(hits['/chat/api/me/channels'], 1);
    expect(context.chatEnabled, isFalse);
    expect(context.chatProbeResolved, isTrue);
  });

  test('the answer is shared across the SiteContexts a launch builds',
      () async {
    final url = await startServer(chatStatus: 403);

    // SiteController rebuilds a context from disk while
    // SiteInitializationService holds its own; both call getConfig. An
    // instance-scoped memo would let each of them probe again.
    for (var i = 0; i < 3; i++) {
      await DiscourseConfigProxy(contextFor(url))
          .getConfig(url, forceRefresh: true);
    }

    expect(hits['/chat/api/me/channels'], 1);
    expect(contextFor(url).chatEnabled, isTrue);
  });

  test('a rate-limited probe is not remembered, so a 429 cannot pin the answer',
      () async {
    final url = await startServer(chatStatus: 429);
    final context = contextFor(url);

    await DiscourseConfigProxy(context).getConfig(url, forceRefresh: true);

    // 429 is the server declining to answer, not an answer. Memoizing it
    // would let one burst launch decide the nav layout for the whole
    // process — the opposite of what the rate-limit work is for.
    expect(context.chatProbeResolved, isFalse);
    expect(context.chatEnabled, isFalse);
  });

  test('a transport failure is not remembered, so the probe can recover',
      () async {
    // Bind then immediately close: connections are refused, which the client
    // maps to statusCode 0 — no signal either way about the plugin.
    final dead = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final deadUrl = 'http://${dead.address.address}:${dead.port}';
    await dead.close(force: true);

    final deadContext = contextFor(deadUrl);
    await DiscourseConfigProxy(deadContext).getConfig(deadUrl, forceRefresh: true);

    // Nothing was learned, so nothing is recorded: a later getConfig, once
    // the network is back, must be free to ask again rather than serve a
    // guess for the lifetime of the process.
    expect(deadContext.chatProbeResolved, isFalse);

    // tearDown closes `server`, so give it something live to close.
    await startServer(chatStatus: 403);
  });
}
