import 'dart:io';

import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'discourse_client_measurement_test.dart' show CountingServer, contextFor;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;
  late CountingServer forum;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    forum = await CountingServer.start();
  });
  tearDown(() => forum.close());

  for (final method in ['GET', 'POST', 'PUT', 'DELETE']) {
    test(
        '$method does not acquire replacement credentials during initialization',
        () async {
      final context = contextFor(forum);
      await context.setUserApiCredentials(
          userApiKey: 'first-key', userApiClientId: 'first-client');
      final client = DiscourseClient();
      final Future<FCCallResult> pending = switch (method) {
        'GET' => client.get(context, '/session-test.json'),
        'POST' => client.post(context, '/session-test.json',
            body: {'raw': 'old account text'}),
        'PUT' => client.put(context, '/session-test.json',
            body: {'raw': 'old account text'}),
        _ => client.delete(context, '/session-test.json'),
      };
      await context.setUserApiCredentials(
          userApiKey: 'second-key', userApiClientId: 'second-client');
      final result = await pending;
      expect(result.statusCode, 0,
          reason: 'local cancellation, no HTTP response');
      expect(forum.requests, isEmpty);
    });
  }
  test('unchanged credentials allow initialization and request dispatch',
      () async {
    final context = contextFor(forum);
    await context.setUserApiCredentials(
        userApiKey: 'first-key', userApiClientId: 'first-client');
    String? key;
    forum.routes['/session-test.json'] = (request) async {
      key = request.headers.value('User-Api-Key');
      await request.drain<void>();
      request.response.write('{}');
    };
    final pending = DiscourseClient()
        .post(context, '/session-test.json', body: {'raw': 'text'});
    await context.setUserApiCredentials(
        userApiKey: 'first-key', userApiClientId: 'first-client');
    expect((await pending).statusCode, 200);
    expect(key, 'first-key');
    expect(forum.requests, hasLength(1));
  });
}
