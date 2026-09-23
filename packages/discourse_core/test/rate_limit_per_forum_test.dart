import 'dart:io';

import 'package:discourse_core/src/network/discourse_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// A 429 from one forum must not hold requests to another.
///
/// DiscourseClient kept a single app-wide "rate limited until", right for a
/// one-forum app but in ABDA a cooldown on forum A stalled every request to
/// forum B. It is now kept per forum origin.
class _Forum {
  _Forum._(this._server);
  final HttpServer _server;
  var rateLimitNext = false;

  static Future<_Forum> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final forum = _Forum._(server);
    server.listen((req) async {
      if (forum.rateLimitNext) {
        forum.rateLimitNext = false;
        // A global limit, as Discourse's per-IP middleware sends it.
        req.response.statusCode = 429;
        req.response.headers.set('Retry-After', '2');
        req.response.headers.set('Discourse-Rate-Limit-Error-Code', 'ip_10_secs_limit');
        req.response.write('Slow down');
      } else {
        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType.json;
        req.response.write('{"ok":true}');
      }
      await req.response.close();
    });
    return forum;
  }

  String get baseUrl => 'http://${_server.address.host}:${_server.port}';

  SiteContext get context => SiteContext(
        siteType: 'discourse',
        site: Site(
          id: null,
          name: baseUrl,
          url: baseUrl,
          description: '',
          endpoint: null,
          baseUrl: baseUrl,
          logoUrl: null,
          backgroundUrl: null,
          siteType: 'discourse',
        ),
      );

  Future<void> close() => _server.close(force: true);
}

void main() {
  late _Forum a;
  late _Forum b;
  final client = DiscourseClient();

  setUp(() async {
    a = await _Forum.start();
    b = await _Forum.start();
    DiscourseClient.invalidateReadCache();
  });

  tearDown(() async {
    await a.close();
    await b.close();
  });

  test('a rate limit on one forum does not hold another', () async {
    a.rateLimitNext = true;
    // Forum A answers 429 (Retry-After: 2); the client holds A and retries.
    final retried = client.get(a.context, '/latest.json');
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final sw = Stopwatch()..start();
    final fromB = await client.get(b.context, '/latest.json');
    expect(fromB.statusCode, 200);
    expect(sw.elapsed, lessThan(const Duration(milliseconds: 800)),
        reason: 'forum B must not wait out forum A\'s cooldown');

    expect((await retried).statusCode, 200);
  });

  test('the rate-limited forum itself still waits', () async {
    a.rateLimitNext = true;
    final retried = client.get(a.context, '/latest.json');
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final sw = Stopwatch()..start();
    final again = await client.get(a.context, '/categories.json');
    expect(again.statusCode, 200);
    expect(sw.elapsed, greaterThan(const Duration(milliseconds: 1200)),
        reason: 'forum A asked for a 2 s pause');

    await retried;
  });
}
