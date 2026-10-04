import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'discourse_client_measurement_test.dart' show CountingServer, contextFor;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // This contract test needs loopback sockets, not the widget-test HTTP stub.
  HttpOverrides.global = null;
  late CountingServer forum;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    DiscourseUploadMetadata.reset();
    forum = await CountingServer.start();
  });
  tearDown(() => forum.close());

  for (final type in ['post', 'pm', 'chat']) {
    test('$type multipart fields, subfolder, credentials and response mapping',
        () async {
      final context = contextFor(forum);
      context.site = context.site.copyWith(
          url: '${forum.baseUrl}/Forum', baseUrl: '${forum.baseUrl}/Forum');
      await context.setUserApiCredentials(
          userApiKey: 'upload-test-key', userApiClientId: 'upload-test-client');
      String? body;
      String? contentType;
      String? apiKey;
      String? clientId;
      forum.routes['/Forum/uploads.json'] = (request) async {
        body = await utf8.decoder.bind(request).join();
        contentType = request.headers.contentType?.mimeType;
        apiKey = request.headers.value('User-Api-Key');
        clientId = request.headers.value('User-Api-Client-Id');
        request.response.write(jsonEncode({
          'id': 12,
          'short_url': 'upload://contract.png',
          'url': '${forum.baseUrl}/uploads/contract.png',
          'original_filename': 'server-name.png',
          'filesize': 3,
          'width': 1200,
          'height': 800,
          'thumbnail_width': 600,
          'thumbnail_height': 400,
        }));
      };
      final result = await DiscourseAttachmentProxy(context)
          .uploadAttachmentAsync(type, '42', 'ignored-group', 'picked.png',
              Uint8List.fromList([65, 66, 67]));
      expect(forum.requests.single.method, 'POST');
      expect(contentType, 'multipart/form-data');
      expect(apiKey, 'upload-test-key');
      expect(clientId, 'upload-test-client');
      expect(
          body,
          contains(
              'name="upload_type"\r\n\r\n${type == 'chat' ? 'chat-composer' : 'composer'}\r\n'));
      if (type == 'pm') {
        expect(body, contains('name="for_private_message"\r\n\r\ntrue\r\n'));
      } else {
        expect(body, isNot(contains('name="for_private_message"')));
      }
      expect(body, contains('name="file"; filename="picked.png"'));
      expect(body, contains('ABC'));
      expect(result.result, isTrue);
      expect(result.attachmentId, '12');
      expect(result.groupId, 'upload://contract.png');
      expect(result.url, '${forum.baseUrl}/uploads/contract.png');
      expect(result.fileName, 'server-name.png');
      expect(result.fileSize, 3);
      expect(discourseUploadMarkdown(result.groupId!),
          '![server-name|600x400](upload://contract.png)');
    });
  }

  test('a rejected upload keeps the server reason and has no attachment',
      () async {
    forum.routes['/uploads.json'] = (request) async {
      await request.drain<void>();
      request.response.statusCode = 422;
      request.response.write('{"errors":["File is too large"]}');
    };
    final result = await DiscourseAttachmentProxy(contextFor(forum))
        .uploadAttachmentAsync(
            'pm', '42', '', 'file.txt', Uint8List.fromList([65]));
    expect(result.result, isFalse);
    expect(result.resultText, contains('File is too large'));
    expect(result.attachmentId, isNull);
    expect(result.groupId, isNull);
  });
}
