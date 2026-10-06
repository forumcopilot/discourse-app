import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/services/fc_http_overrides.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'discourse_client_measurement_test.dart' show CountingServer, contextFor;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CountingServer server;
  final client = DiscourseClient();
  Completer<void>? hold;
  Completer<void>? started;

  setUp(() async {
    HttpOverrides.global = null;
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    DiscourseClient.invalidateReadCache();
    hold = null;
    started = null;
    server = await CountingServer.start();
    server.routes['/notifications.json'] = (request) async {
      final owner = request.headers.value('user-api-key') ??
          request.headers.value('cookie') ??
          'guest';
      final gate = hold;
      hold = null;
      started?.complete();
      started = null;
      if (gate != null) await gate.future;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({'owner': owner}));
    };
  });
  tearDown(() => server.close());

  test('same-forum accounts cannot reuse completed responses', () async {
    final a = contextFor(server);
    final b = contextFor(server);
    await a.setUserApiCredentials(
        userApiKey: 'dummy-a', userApiClientId: 'client');
    await b.setUserApiCredentials(
        userApiKey: 'dummy-b', userApiClientId: 'client');
    final first = await client.get(a, '/notifications.json');
    final second = await client.get(b, '/notifications.json');
    expect(second.body, isNot(first.body));
    expect(server.count(path: '/notifications.json'), 2);
  });

  test('login, replacement, logout and re-login each fetch anew', () async {
    final context = contextFor(server);
    await client.get(context, '/notifications.json');
    for (final key in ['dummy-a', 'dummy-b']) {
      await context.setUserApiCredentials(
          userApiKey: key, userApiClientId: 'client');
      expect((await client.get(context, '/notifications.json')).body,
          contains(key));
    }
    await context.clearUserApiCredentials();
    expect((await client.get(context, '/notifications.json')).body,
        contains('guest'));
    await context.setUserApiCredentials(
        userApiKey: 'dummy-a', userApiClientId: 'client');
    await client.get(context, '/notifications.json');
    expect(server.count(path: '/notifications.json'), 5);
  });

  test('new account cannot join old pending request or late cache', () async {
    final context = contextFor(server);
    await context.setUserApiCredentials(
        userApiKey: 'dummy-a', userApiClientId: 'client');
    final gate = hold = Completer<void>();
    final arrival = started = Completer<void>();
    final old = client.get(context, '/notifications.json');
    await arrival.future;
    await context.setUserApiCredentials(
        userApiKey: 'dummy-b', userApiClientId: 'client');
    final current = client.get(context, '/notifications.json');
    gate.complete();
    expect((await old).body, contains('dummy-a'));
    expect((await current).body, contains('dummy-b'));
    expect((await client.get(context, '/notifications.json')).body,
        contains('dummy-b'));
    expect(server.count(path: '/notifications.json'), 2);
  });

  test('unchanged restored credentials preserve caching and coalescing',
      () async {
    final context = contextFor(server);
    await context.setUserApiCredentials(
        userApiKey: 'dummy-a', userApiClientId: 'client');
    await Future.wait(
        List.generate(3, (_) => client.get(context, '/notifications.json')));
    await context.loadUserApiCredentials();
    await client.get(context, '/notifications.json');
    expect(server.count(path: '/notifications.json'), 1);
  });

  group('per forum, not per SiteContext', () {
    // A multi-forum host (ABDA) builds a new SiteContext every time a forum
    // is reopened; the reader is the same, and so are the forum's answers.
    test('the same sign-in in a new SiteContext reuses cached reads',
        () async {
      final first = contextFor(server);
      await first.setUserApiCredentials(
          userApiKey: 'dummy-a', userApiClientId: 'client');
      await client.get(first, '/categories.json');

      final reopened = contextFor(server);
      await reopened.loadUserApiCredentials();
      await client.get(reopened, '/categories.json');

      expect(server.count(path: '/categories.json'), 1);
    });

    test('changed credentials are not served the previous ones\' reads',
        () async {
      final first = contextFor(server);
      await first.setUserApiCredentials(
          userApiKey: 'dummy-a', userApiClientId: 'client');
      await client.get(first, '/notifications.json');

      // Another account, in a new context.
      final other = contextFor(server);
      await other.setUserApiCredentials(
          userApiKey: 'dummy-b', userApiClientId: 'client');
      expect((await client.get(other, '/notifications.json')).body,
          contains('dummy-b'));

      // Signed out and back in with the first account's key.
      await other.clearUserApiCredentials();
      final back = contextFor(server);
      await back.setUserApiCredentials(
          userApiKey: 'dummy-a', userApiClientId: 'client');
      expect((await client.get(back, '/notifications.json')).body,
          contains('dummy-a'));

      expect(server.count(path: '/notifications.json'), 3);
    });

    test('another forum does not share the reads', () async {
      final second = await CountingServer.start();
      addTearDown(second.close);
      for (final forum in [server, second]) {
        final context = contextFor(forum);
        await context.setUserApiCredentials(
            userApiKey: 'dummy-a', userApiClientId: 'client');
        await client.get(context, '/categories.json');
      }
      expect(server.count(path: '/categories.json'), 1);
      expect(second.count(path: '/categories.json'), 1);
    });

    test('a change of sign-in drops that forum\'s reads, and only those',
        () async {
      final second = await CountingServer.start();
      addTearDown(second.close);
      final context = contextFor(server);
      await context.setUserApiCredentials(
          userApiKey: 'dummy-a', userApiClientId: 'client');
      await client.get(context, '/categories.json');
      await client.get(context, '/about.json');
      await client.get(contextFor(second), '/categories.json');
      expect(DiscourseClient.debugCachedReads(server.baseUrl), 2);

      await contextFor(server).loadUserApiCredentials();
      expect(DiscourseClient.debugCachedReads(server.baseUrl), 2,
          reason: 'the same sign-in in another context keeps them');

      await context.clearUserApiCredentials();
      expect(DiscourseClient.debugCachedReads(server.baseUrl), 0);
      expect(DiscourseClient.debugCachedReads(second.baseUrl), 1);

      await context.setUserApiCredentials(
          userApiKey: 'dummy-b', userApiClientId: 'client');
      await client.get(context, '/categories.json');
      expect(DiscourseClient.debugCachedReads(server.baseUrl), 1);
    });
  });

  test('effective header overrides partition cached and pending requests',
      () async {
    final context = contextFor(server);
    final responses = await Future.wait([
      for (final key in ['dummy-a', 'dummy-b'])
        client.get(context, '/notifications.json',
            extraHeaders: {'User-Api-Key': key}),
    ]);
    expect(responses[0].body, contains('dummy-a'));
    expect(responses[1].body, contains('dummy-b'));
    await client.get(context, '/notifications.json',
        extraHeaders: {'User-Api-Key': 'dummy-b'});
    expect(server.count(path: '/notifications.json'), 2);
  });

  test('changed cookie session cannot reuse anonymous response', () async {
    final context = contextFor(server);
    await client.get(context, '/notifications.json');
    await FCDioClient.instance.cookieJar!.saveFromResponse(
        Uri.parse(server.baseUrl), [Cookie('_forum_session', 'dummy-cookie')]);
    expect((await client.get(context, '/notifications.json')).body,
        contains('dummy-cookie'));
    expect(server.count(path: '/notifications.json'), 2);
    await FCDioClient.instance.cookieJar!.deleteAll();
  });
}
