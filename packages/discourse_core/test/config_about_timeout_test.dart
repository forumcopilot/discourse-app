import 'dart:async';
import 'dart:convert';

import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// A forum whose `/about.json` hangs still opens.
///
/// forum.cfx.re (2026-09-23) answered `/site.json` and `/site/settings.json`
/// in ~0.3 s while `/about.json` never answered, and that one optional read
/// ran getConfig into the UI's 10 s timeout: "Failed to connect".
void main() {
  const budget = Duration(milliseconds: 200);
  var forums = 0;

  setUp(() {
    DiscourseClient.invalidateReadCache();
    DiscourseSiteContextExtension.resetChatProbeCache();
    DiscourseSiteCapabilities.reset();
    // Each test gets its own forum: a hung /about.json is remembered per
    // forum for as long as the request is outstanding.
    forums++;
  });

  String forumUrl() => 'https://hung-about-$forums.example';

  test('config is built from /site.json and /site/settings.json', () async {
    final client = _AboutNeverAnswers();
    final url = forumUrl();
    final watch = Stopwatch()..start();

    final result = await DiscourseConfigProxy(_context(url),
            client: client, aboutTimeout: budget)
        .getConfig(url, forceRefresh: true);

    watch.stop();
    // Well inside the UI's 10 s getConfig timeout.
    expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
    // What /about.json alone would have said falls back to its default…
    expect(result.version, 'discourse');
    expect(result.systemVersion, 'discourse');
    expect(result.isOpen, isTrue);
    // …and everything the other reads provide is there.
    expect(result.minSearchLength, 2);
    expect(DiscourseSiteCapabilities.isResolved(url), isTrue);
  });

  test('read-only mode comes from /site/settings.json instead', () async {
    final client = _AboutNeverAnswers(settingsHeaders: {
      'Discourse-Readonly': 'true',
    });
    final url = forumUrl();

    final result = await DiscourseConfigProxy(_context(url),
            client: client, aboutTimeout: budget)
        .getConfig(url, forceRefresh: true);

    expect(result.isOpen, isFalse);
  });

  test('later loads do not wait again on the same hung request', () async {
    final client = _AboutNeverAnswers();
    final url = forumUrl();
    DiscourseConfigProxy proxy() => DiscourseConfigProxy(_context(url),
        client: client, aboutTimeout: const Duration(seconds: 5));

    // First load pays the budget once (shortened here so the test is fast).
    await DiscourseConfigProxy(_context(url),
            client: client, aboutTimeout: budget)
        .getConfig(url, forceRefresh: true);
    expect(client.aboutRequests, 1);

    // A cold launch's second and third getConfig: skipped, not re-awaited.
    // With a 5 s budget, waiting on it would time this test out.
    await proxy().getConfig(url, forceRefresh: true);
    await proxy().getConfig(url, forceRefresh: true);
    expect(client.aboutRequests, 1);

    // Once the hung request settles, the next load asks again.
    client.answerAbout();
    await pumpEventQueue();
    final result = await proxy().getConfig(url, forceRefresh: true);
    expect(client.aboutRequests, 2);
    expect(result.version, '3.4.0');
  });

  test('a forum that answers nothing still fails instead of opening empty',
      () async {
    // /about.json hangs and every other read gets no response at all: the
    // hang must not stand in for "the forum is up".
    final client = _AboutNeverAnswers(othersUnreachable: true);
    final url = forumUrl();

    await expectLater(
      DiscourseConfigProxy(_context(url), client: client, aboutTimeout: budget)
          .getConfig(url, forceRefresh: true),
      throwsA(isA<DiscourseApiException>()
          .having((e) => e.statusCode, 'statusCode', 0)),
    );
  });
}

/// `/about.json` never completes until [answerAbout]; the other config reads
/// answer at once.
class _AboutNeverAnswers extends DiscourseClient {
  _AboutNeverAnswers({
    this.settingsHeaders = const {},
    this.othersUnreachable = false,
  });

  final Map<String, String> settingsHeaders;
  final bool othersUnreachable;
  int aboutRequests = 0;
  final Completer<FCCallResult> _about = Completer<FCCallResult>();

  void answerAbout() => _about.complete(FCCallResult(
        statusCode: 200,
        body: jsonEncode({
          'about': {'version': '3.4.0'}
        }),
      ));

  @override
  Future<FCCallResult> get(
    SiteContext context,
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? extraHeaders,
  }) async {
    if (path == '/about.json') {
      aboutRequests++;
      // Once answered, later requests get the same answer.
      return _about.future;
    }
    if (othersUnreachable) {
      return FCCallResult(
          statusCode: 0, body: jsonEncode({'error': 'Connection refused'}));
    }
    switch (path) {
      case '/site.json':
        return FCCallResult(
          statusCode: 200,
          body: jsonEncode({
            'top_menu_items': ['latest']
          }),
        );
      case '/site/settings.json':
        return FCCallResult(
          statusCode: 200,
          body: jsonEncode({'min_search_term_length': 2}),
          headers: {...settingsHeaders},
        );
      default:
        // /chat/api/me/channels: no chat plugin.
        return FCCallResult(
            statusCode: 404, body: jsonEncode({'errors': ['not found']}));
    }
  }
}

SiteContext _context(String url) => SiteContext(
      siteType: 'discourse',
      site: Site(
        name: 'Hung about',
        url: url,
        baseUrl: url,
        description: '',
        siteType: 'discourse',
      ),
    );
