/// Measurement harness for [DiscourseClient]'s request-reduction layer.
///
/// Runs the REAL client (real Dio stack, real sockets) against an in-process
/// HTTP server that counts every request it receives, so cache behavior is
/// verified by observed request counts rather than by reading the code.
///
/// A/B procedure (from packages/discourse_core):
///
///   flutter test test/discourse_client_measurement_test.dart          # working tree
///   git stash push -- lib/src/network/discourse_client.dart
///   flutter test test/discourse_client_measurement_test.dart          # HEAD
///   git stash pop
///
/// Every test prints a `[measure]` line with the observed server-side count,
/// so the two runs can be compared quantitatively. Assertions encode the
/// intended (post-change) behavior; failures on the HEAD run are the
/// "before" measurement.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:discourse_core/src/network/discourse_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Loopback HTTP server that records every request it serves.
class CountingServer {
  final HttpServer _server;
  final List<ServedRequest> requests = [];

  /// Route table: exact path → responder. Falls back to 200 `{}`.
  final Map<String, FutureOr<void> Function(HttpRequest)> routes = {};

  CountingServer._(this._server) {
    _server.listen((req) async {
      requests.add(ServedRequest(
        method: req.method,
        path: req.uri.path,
        query: req.uri.query,
        at: DateTime.now(),
      ));
      final handler = routes[req.uri.path];
      if (handler != null) {
        await handler(req);
      } else {
        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType.json;
        req.response.write('{"ok":true,"path":"${req.uri.path}"}');
      }
      await req.response.close();
    });
  }

  static Future<CountingServer> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    return CountingServer._(server);
  }

  String get baseUrl => 'http://127.0.0.1:${_server.port}';

  int count({String? method, required String path}) => requests
      .where((r) => r.path == path && (method == null || r.method == method))
      .length;

  Future<void> close() => _server.close(force: true);
}

class ServedRequest {
  final String method;
  final String path;
  final String query;
  final DateTime at;
  ServedRequest({
    required this.method,
    required this.path,
    required this.query,
    required this.at,
  });

  @override
  String toString() =>
      '$method $path${query.isEmpty ? '' : '?$query'} @${at.toIso8601String()}';
}

SiteContext contextFor(CountingServer server) {
  final site = Site(
    id: null,
    name: 'Measurement forum',
    url: server.baseUrl,
    description: 'in-process counting server',
    endpoint: null,
    baseUrl: server.baseUrl,
    logoUrl: null,
    backgroundUrl: null,
    siteType: 'discourse',
  );
  return SiteContext(siteType: 'discourse', site: site);
}

void measure(String label, CountingServer server,
    {String? method, required String path}) {
  final n = server.count(method: method, path: path);
  // ignore: avoid_print
  print('[measure] $label: server saw $n × ${method ?? 'ANY'} $path');
}

void main() {
  late CountingServer server;
  late SiteContext ctx;
  final client = DiscourseClient();

  setUp(() async {
    server = await CountingServer.start();
    ctx = contextFor(server);
    // Statics persist across tests in one VM; each test also gets a unique
    // port so stale TTL entries can never match, but clear anyway.
    DiscourseClient.invalidateReadCache();
  });

  tearDown(() async {
    await server.close();
  });

  group('canonical query cache key', () {
    test('null query and empty-map query share one cache entry', () async {
      await client.get(ctx, '/about.json');
      await client.get(ctx, '/about.json', query: <String, dynamic>{});
      measure('null-vs-empty', server, method: 'GET', path: '/about.json');
      expect(server.count(method: 'GET', path: '/about.json'), 1,
          reason: 'the {null, {}} spellings of "no query" must share a key');
    });

    test('key order does not fork the cache key', () async {
      await client.get(ctx, '/categories.json',
          query: {'include_subcategories': 'true', 'page': '0'});
      await client.get(ctx, '/categories.json',
          query: {'page': '0', 'include_subcategories': 'true'});
      measure('key-order', server, method: 'GET', path: '/categories.json');
      expect(server.count(method: 'GET', path: '/categories.json'), 1,
          reason: 'same params in a different order must share a key');
    });

    test('different query values stay distinct (no false sharing)', () async {
      await client.get(ctx, '/latest.json', query: {'page': '1'});
      await client.get(ctx, '/latest.json', query: {'page': '2'});
      measure('distinct-values', server, method: 'GET', path: '/latest.json');
      expect(server.count(method: 'GET', path: '/latest.json'), 2,
          reason: 'page=1 and page=2 are different requests');
    });

    test('value containing &/= must not collide with a two-param query',
        () async {
      // These are DIFFERENT requests on the wire (Dio percent-encodes the
      // value), so they must not share a cache key. An unencoded join makes
      // both produce `q=1&safe=2`.
      await client.get(ctx, '/search.json', query: {'q': '1&safe=2'});
      await client.get(ctx, '/search.json', query: {'q': '1', 'safe': '2'});
      measure('ambiguous-value', server, method: 'GET', path: '/search.json');
      expect(server.count(method: 'GET', path: '/search.json'), 2,
          reason: 'a value containing "&"/"=" must not alias another query');
    });

    test('concurrent identical GETs coalesce across spellings', () async {
      server.routes['/site/basic-info.json'] = (req) async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType.json;
        req.response.write('{"ok":true}');
      };
      await Future.wait([
        client.get(ctx, '/site/basic-info.json'),
        client.get(ctx, '/site/basic-info.json', query: <String, dynamic>{}),
      ]);
      measure('coalesce', server,
          method: 'GET', path: '/site/basic-info.json');
      expect(server.count(method: 'GET', path: '/site/basic-info.json'), 1,
          reason: 'two in-flight identical GETs must share one socket call');
    });
  });

  group('inert writes', () {
    test('the /topics/timings beacon does not drop the read cache', () async {
      await client.get(ctx, '/t/46.json');
      await client.post(ctx, '/topics/timings',
          body: {'topic_id': 46, 'topic_time': 1000});
      await client.get(ctx, '/t/46.json');
      measure('timings-beacon GET', server, method: 'GET', path: '/t/46.json');
      measure('timings-beacon POST', server,
          method: 'POST', path: '/topics/timings');
      expect(server.count(method: 'POST', path: '/topics/timings'), 1,
          reason: 'the beacon itself must still reach the server');
      expect(server.count(method: 'GET', path: '/t/46.json'), 1,
          reason: 'read-tracking must not invalidate cached reads');
    });

    test('a real write still drops the read cache', () async {
      await client.get(ctx, '/t/46.json');
      await client.post(ctx, '/posts', body: {'raw': 'hello', 'topic_id': 46});
      await client.get(ctx, '/t/46.json');
      measure('real-write GET', server, method: 'GET', path: '/t/46.json');
      expect(server.count(method: 'GET', path: '/t/46.json'), 2,
          reason: 'a reply must invalidate the cached topic');
    });
  });

  group('per-path TTL', () {
    test('/about.json outlives the default 3s TTL', () async {
      await client.get(ctx, '/about.json');
      await Future<void>.delayed(const Duration(milliseconds: 3500));
      await client.get(ctx, '/about.json');
      measure('about-ttl', server, method: 'GET', path: '/about.json');
      expect(server.count(method: 'GET', path: '/about.json'), 1,
          reason: 'forum configuration should survive a screen transition');
    });

    test('default-TTL paths still expire after ~3s', () async {
      await client.get(ctx, '/t/46.json');
      await Future<void>.delayed(const Duration(milliseconds: 3500));
      await client.get(ctx, '/t/46.json');
      measure('default-ttl', server, method: 'GET', path: '/t/46.json');
      expect(server.count(method: 'GET', path: '/t/46.json'), 2,
          reason: 'topic content must go stale quickly');
    });
  });

  group('rate limiting (run last: sets the shared hold)', () {
    test('one automatic retry honoring Retry-After', () async {
      var hits = 0;
      server.routes['/retry.json'] = (req) {
        hits++;
        if (hits == 1) {
          req.response.statusCode = 429;
          req.response.headers.set('Retry-After', '1');
          req.response.headers.contentType = ContentType.text;
          req.response.write('Slow down!');
        } else {
          req.response.statusCode = 200;
          req.response.headers.contentType = ContentType.json;
          req.response.write('{"ok":true}');
        }
      };
      final sw = Stopwatch()..start();
      final result = await client.get(ctx, '/retry.json');
      sw.stop();
      measure('retry-after', server, method: 'GET', path: '/retry.json');
      // ignore: avoid_print
      print('[measure] retry-after: resolved ${result.statusCode} '
          'in ${sw.elapsedMilliseconds}ms');
      expect(result.statusCode, 200,
          reason: 'a single 429 with a short Retry-After should self-heal');
      expect(server.count(method: 'GET', path: '/retry.json'), 2);
      expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(900),
          reason: 'the retry must actually wait the advertised second');
    });

    test('an action-scoped 429 does NOT hold other requests', () async {
      // What Discourse sends for PostAction.limit_action! — 4 likes/minute on
      // one post. Note the Retry-After IS present; only the error-code header
      // is missing, because the limiter carries no error_code.
      server.routes['/post_actions.json'] = (req) {
        req.response.statusCode = 429;
        req.response.headers.set('Retry-After', '30');
        req.response.headers.contentType = ContentType.json;
        req.response.write(jsonEncode({
          'errors': ['You’ve performed this action too many times.'],
          'error_type': 'rate_limit',
          'extras': {'wait_seconds': 30},
        }));
      };
      final liked = await client.post(ctx, '/post_actions.json',
          body: {'id': 1, 'post_action_type_id': 2});
      expect(liked.statusCode, 429);

      final sw = Stopwatch()..start();
      await client.get(ctx, '/t/46.json');
      sw.stop();
      // ignore: avoid_print
      print('[measure] action-scoped: unrelated GET delayed '
          '${sw.elapsedMilliseconds}ms');
      expect(sw.elapsedMilliseconds, lessThan(1000),
          reason: 'a per-post like limit must not freeze reads app-wide');
      expect(server.count(method: 'GET', path: '/t/46.json'), 1);
    });

    test('a 429 holds subsequent requests to OTHER paths', () async {
      // A GLOBAL limit — what the per-IP middleware and the per-User-API-Key
      // limiter send. The error-code header is what marks it as governing
      // every request, and is the reason this one may stall the client.
      server.routes['/limited.json'] = (req) {
        req.response.statusCode = 429;
        req.response.headers.set('Retry-After', '2');
        req.response.headers
            .set('Discourse-Rate-Limit-Error-Code', 'user_api_key_limiter_60_secs');
        req.response.headers.contentType = ContentType.text;
        req.response.write('Slow down!');
      };
      final limited = await client.get(ctx, '/limited.json');
      expect(limited.statusCode, 429,
          reason: 'both attempts 429 → surfaced to the caller');

      final sw = Stopwatch()..start();
      await client.get(ctx, '/unrelated.json');
      sw.stop();
      measure('shared-hold', server, method: 'GET', path: '/unrelated.json');
      // ignore: avoid_print
      print('[measure] shared-hold: unrelated GET delayed '
          '${sw.elapsedMilliseconds}ms');
      expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(1200),
          reason: 'the cooldown is per API key, so it must gate every path');
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}
