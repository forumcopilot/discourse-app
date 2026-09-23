import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:discourse_core/discourse_core.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:test/test.dart';

/// `getConfig` gates entering a forum, so its four reads go out together.
///
/// Answers from an in-process [HttpServer], for the same reason as
/// chat_probe_measurement_test.dart: `package:test`, not `flutter_test`,
/// whose HTTP mock fails every request.
void main() {
  late HttpServer server;

  const configPaths = {
    '/about.json',
    '/chat/api/me/channels',
    '/site.json',
    '/site/settings.json',
  };

  SiteContext contextFor(String url) => SiteContext(
        siteType: 'discourse',
        site: Site(
          name: 'Parallel',
          url: url,
          baseUrl: url,
          description: '',
          siteType: 'discourse',
        ),
      );

  void answer(HttpRequest req, {Map<String, String> headers = const {}}) {
    final res = req.response..headers.contentType = ContentType.json;
    headers.forEach(res.headers.set);
    switch (req.uri.path) {
      case '/about.json':
        res.write(jsonEncode({
          'about': {'version': '3.4.0'}
        }));
        break;
      case '/site.json':
        res.write(jsonEncode({
          'top_menu_items': ['latest']
        }));
        break;
      case '/site/settings.json':
        res.write(jsonEncode({'min_search_term_length': 2}));
        break;
      default:
        res.statusCode = 403;
        res.write(jsonEncode({'errors': ['not permitted']}));
    }
  }

  setUp(() {
    HttpOverrides.global = null;
    DiscourseClient.invalidateReadCache();
    DiscourseSiteContextExtension.resetChatProbeCache();
    DiscourseSiteCapabilities.reset();
  });

  tearDown(() async {
    await server.close(force: true);
  });

  test('the four config reads are in flight at the same time', () async {
    var inFlight = 0;
    var peak = 0;
    final allArrived = Completer<void>();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      inFlight++;
      peak = max(peak, inFlight);
      if (inFlight == configPaths.length && !allArrived.isCompleted) {
        allArrived.complete();
      }
      // Hold each response until all four are waiting — or give up, so a
      // serial getConfig fails the assertion below instead of hanging.
      await allArrived.future
          .timeout(const Duration(seconds: 2), onTimeout: () {});
      answer(req);
      await req.response.close();
      inFlight--;
    });
    final url = 'http://${server.address.address}:${server.port}';

    final result = await DiscourseConfigProxy(contextFor(url))
        .getConfig(url, forceRefresh: true);

    expect(peak, configPaths.length);
    // Each read still lands where it belongs.
    expect(result.version, '3.4.0');
    expect(result.minSearchLength, 2);
    expect(DiscourseSiteCapabilities.isResolved(url), isTrue);
  });

  test('read-only mode is read off /about.json, not whichever reply came last',
      () async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      if (req.uri.path == '/about.json') {
        answer(req, headers: {'Discourse-Readonly': 'true'});
      } else {
        // Every other read answers after /about.json has.
        await Future<void>.delayed(const Duration(milliseconds: 100));
        answer(req);
      }
      await req.response.close();
    });
    final url = 'http://${server.address.address}:${server.port}';

    final result = await DiscourseConfigProxy(contextFor(url))
        .getConfig(url, forceRefresh: true);

    expect(result.isOpen, isFalse);
  });

  test('a forum that does not answer fails getConfig instead of opening empty',
      () async {
    // Bound then closed: connections are refused, as when offline.
    final dead = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final deadUrl = 'http://${dead.address.address}:${dead.port}';
    await dead.close(force: true);

    await expectLater(
      DiscourseConfigProxy(contextFor(deadUrl))
          .getConfig(deadUrl, forceRefresh: true),
      throwsA(isA<DiscourseApiException>()
          .having((e) => e.statusCode, 'statusCode', 0)),
    );

    // tearDown closes `server`.
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  });

  test('a forum that answers /about.json with an error still opens', () async {
    // A login-required forum refuses anonymous /about.json; it is up.
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      if (req.uri.path == '/about.json') {
        req.response
          ..statusCode = 403
          ..write(jsonEncode({'errors': ['not permitted']}));
      } else {
        answer(req);
      }
      await req.response.close();
    });
    final url = 'http://${server.address.address}:${server.port}';

    final result = await DiscourseConfigProxy(contextFor(url))
        .getConfig(url, forceRefresh: true);

    expect(result.version, 'discourse');
    expect(result.isOpen, isTrue);
  });
}
