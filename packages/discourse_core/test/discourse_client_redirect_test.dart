import 'dart:io';
import 'dart:typed_data';

import 'package:discourse_core/src/network/discourse_client.dart';
import 'package:discourse_core/src/proxy/attachment_proxy.dart';
import 'package:flutter_test/flutter_test.dart';

import 'discourse_client_measurement_test.dart' show CountingServer, contextFor;

// Real sockets matter here: a fake adapter does not reproduce dart:io's
// automatic forwarding of custom headers. These are deliberately dummy keys.
const _credentials = {
  'User-Api-Key': 'redirect-test-key',
  'User-Api-Client-Id': 'redirect-test-client',
};

void main() {
  final client = DiscourseClient();
  late CountingServer forum;
  late CountingServer otherOrigin;

  setUp(() async {
    forum = await CountingServer.start();
    otherOrigin = await CountingServer.start();
    DiscourseClient.invalidateReadCache();
  });

  tearDown(() async {
    await forum.close();
    await otherOrigin.close();
  });

  void redirect(String path, int status, String location) {
    forum.routes[path] = (request) {
      request.response.statusCode = status;
      request.response.headers.set(HttpHeaders.locationHeader, location);
    };
  }

  for (final status in [301, 302, 303, 307, 308]) {
    test('$status never forwards API credentials to a different port',
        () async {
      final receivedKeys = <String?>[];
      otherOrigin.routes['/capture'] = (request) {
        receivedKeys.add(request.headers.value('User-Api-Key'));
        request.response.write('{}');
      };
      redirect('/start.json', status, '${otherOrigin.baseUrl}/capture');

      final result = await client.get(contextFor(forum), '/start.json',
          extraHeaders: _credentials);

      expect(receivedKeys, isEmpty,
          reason: 'the redirect destination must receive no request at all');
      expect(result.statusCode, status);
      expect(result.body, contains('redirect'));
    });

    test('$status follows a relative same-origin read with credentials',
        () async {
      final receivedKeys = <String?>[];
      final receivedClients = <String?>[];
      redirect('/forum/start.json', status, 'next.json?fresh=1');
      forum.routes['/forum/next.json'] = (request) {
        receivedKeys.add(request.headers.value('User-Api-Key'));
        receivedClients.add(request.headers.value('User-Api-Client-Id'));
        request.response.write('{"ok":true}');
      };

      final result = await client.get(contextFor(forum), '/forum/start.json',
          query: {'original': 'only-on-first-hop'}, extraHeaders: _credentials);

      expect(result.statusCode, 200);
      expect(receivedKeys, ['redirect-test-key']);
      expect(receivedClients, ['redirect-test-client']);
      expect(forum.requests.last.query, 'fresh=1',
          reason: 'do not append the original query to the Location URL');
    });
  }

  test('checks every hop of a same-origin then cross-origin redirect',
      () async {
    redirect('/start.json', 302, '/second.json');
    redirect('/second.json', 302, '${otherOrigin.baseUrl}/capture');

    final result = await client.get(contextFor(forum), '/start.json',
        extraHeaders: _credentials);

    expect(result.statusCode, 302);
    expect(forum.requests.map((r) => r.path), ['/start.json', '/second.json']);
    expect(otherOrigin.requests, isEmpty);
  });

  test('bounds same-origin redirect loops', () async {
    redirect('/loop.json', 302, '/loop.json');

    final result = await client.get(contextFor(forum), '/loop.json',
        extraHeaders: _credentials);

    expect(result.statusCode, 302);
    expect(forum.requests.length, 6); // Initial request plus five redirects.
  });

  test('upload redirects do not become requests to another origin', () async {
    redirect('/uploads.json', 303, '${otherOrigin.baseUrl}/capture');

    final result = await DiscourseAttachmentProxy(contextFor(forum))
        .uploadAttachmentAsync(
            'post', '', '', 'test.txt', Uint8List.fromList([65]));

    expect(otherOrigin.requests, isEmpty);
    expect(result.result, isFalse);
    expect(result.resultText, contains('303'));
  });

  for (final method in ['POST', 'PUT', 'DELETE']) {
    for (final status in [303, 307]) {
      test('$method $status does not replay a write on the same origin',
          () async {
        redirect('/write.json', status, '/capture');
        final context = contextFor(forum);
        final send = switch (method) {
          'POST' => client.post,
          'PUT' => client.put,
          _ => client.delete,
        };

        final result = await send(context, '/write.json',
            body: {'raw': 'private draft'}, extraHeaders: _credentials);

        expect(result.statusCode, status);
        expect(forum.requests.map((r) => r.path), ['/write.json']);
      });
    }
  }

  test('missing and malformed locations remain actionable failures', () async {
    forum.routes['/missing.json'] =
        (request) => request.response.statusCode = 302;
    redirect('/malformed.json', 302, 'http://[invalid');
    for (final path in ['/missing.json', '/malformed.json']) {
      final result = await client.get(contextFor(forum), path);
      expect(result.statusCode, 302);
      expect(result.body, contains('redirect'));
    }
  });
}
