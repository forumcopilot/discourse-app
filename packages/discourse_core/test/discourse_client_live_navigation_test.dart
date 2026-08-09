/// Live navigation measurement against a real Discourse forum.
///
/// The in-process harness (`discourse_client_measurement_test.dart`) proves the
/// caching mechanisms in isolation. This one answers a different question: does
/// the app's REAL navigation pattern actually trigger them? A cold launch does
/// not — its whole bootstrap fits inside the 3s default TTL — so the scenario
/// that matters is a screen transition, where the old 3s TTL expired and the
/// per-path TTL does not.
///
/// Anonymous on purpose: the User API Key handshake needs an interactive
/// webview grant, so an automated run is always a guest. Note what that rules
/// out — `/topics/timings` is login-gated in DiscourseTopicProxy, so the
/// inert-write path CANNOT be exercised here.
///
/// Hits the network. Run explicitly:
///   flutter test test/discourse_client_live_navigation_test.dart
@Tags(['live'])
library;

import 'package:discourse_core/src/network/discourse_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

const String kForumUrl = 'https://try.discourse.org';

SiteContext liveContext() {
  final site = Site(
    id: null,
    name: 'Live forum',
    url: kForumUrl,
    description: 'live navigation measurement',
    endpoint: null,
    baseUrl: kForumUrl,
    logoUrl: null,
    backgroundUrl: null,
    siteType: 'discourse',
  );
  return SiteContext(siteType: 'discourse', site: site);
}

/// Captures the client's own `🌐 [HTTP ...]` debug lines.
class RequestLog {
  final List<String> lines = [];
  DebugPrintCallback? _saved;

  void start() {
    _saved = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null && message.contains('🌐')) lines.add(message);
    };
  }

  void stop() {
    if (_saved != null) debugPrint = _saved!;
  }

  int get sends => lines.where((l) => l.contains('[HTTP #')).length;
  int get hits => lines.where((l) => l.contains('cache-hit')).length;
  int get coalesced => lines.where((l) => l.contains('coalesced')).length;

  int sendsOf(String pathFragment) => lines
      .where((l) => l.contains('[HTTP #') && l.contains(pathFragment))
      .length;

  void dump(String label) {
    // ignore: avoid_print
    print('[measure] --- $label ---');
    for (final l in lines) {
      // ignore: avoid_print
      print('[measure]   $l');
    }
    // ignore: avoid_print
    print('[measure] $label totals: sends=$sends hits=$hits '
        'coalesced=$coalesced');
  }
}

void main() {
  final client = DiscourseClient();

  test('home → topic → back home: the return home should not refetch config',
      () async {
    DiscourseClient.invalidateReadCache();
    final ctx = liveContext();

    // Discover a real topic id first, outside the measured window.
    final latest = await client.get(ctx, '/latest.json');
    if (latest.statusCode != 200) {
      markTestSkipped('forum unreachable (HTTP ${latest.statusCode})');
      return;
    }
    final match =
        RegExp(r'"id":(\d+),"title"').firstMatch(latest.body);
    final topicId = match?.group(1);
    expect(topicId, isNotNull, reason: 'need a real topic to open');

    DiscourseClient.invalidateReadCache();
    final log = RequestLog()..start();
    try {
      // Home: forums tab + topics tab.
      await client
          .get(ctx, '/categories.json', query: {'include_subcategories': 'true'});
      await client.get(ctx, '/latest.json');

      // Open a topic and "read" it for 4s — longer than the 3s default TTL,
      // well inside the 5-minute categories TTL. This is the gap a real
      // screen transition creates.
      await client.get(ctx, '/t/$topicId.json');
      await Future<void>.delayed(const Duration(seconds: 4));

      // Back to home: both tabs reload.
      await client
          .get(ctx, '/categories.json', query: {'include_subcategories': 'true'});
      await client.get(ctx, '/latest.json');
    } finally {
      log.stop();
    }

    log.dump('home → topic → back home');

    expect(log.sendsOf('/categories.json'), 1,
        reason: 'category tree should survive the trip into a topic');
    expect(log.sendsOf('/latest.json'), 2,
        reason: 'the feed is deliberately near-live and must refetch');
  }, timeout: const Timeout(Duration(seconds: 60)));
}
