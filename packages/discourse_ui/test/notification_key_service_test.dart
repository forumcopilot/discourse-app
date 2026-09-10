import 'package:discourse_ui/config/app_forum_config.dart';
import 'package:discourse_ui/services/notification_key_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// The bodies are the contract with the notifications backend; a backend is
/// written against them, so they are pinned here.
void main() {
  tearDown(() => AppForumConfig.setNotificationsApiBaseUrl(null));

  group('with no backend configured', () {
    test('every call is a no-op that reports failure without a request',
        () async {
      expect(AppForumConfig.isNotificationsGrantEnabled, isFalse);
      expect(
        await NotificationKeyService.register(
          siteUrl: 'https://forum.example',
          clientId: 'abc:notify',
          userApiKey: 'k',
        ),
        isFalse,
      );
      expect(
        await NotificationKeyService.updateDevice(
          siteUrl: 'https://forum.example',
          clientId: 'abc:notify',
          deviceToken: 'fcm',
        ),
        isFalse,
      );
      expect(
        await NotificationKeyService.revoke(
          siteUrl: 'https://forum.example',
          clientId: 'abc:notify',
        ),
        isFalse,
      );
    });
  });

  group('request bodies', () {
    test(
        'name the forum by URL, normalized, and carry an id only when there is one',
        () {
      final withoutId = NotificationKeyService.registerBody(
        siteUrl: 'https://forum.example/ ',
        clientId: 'abc:notify',
        userApiKey: 'k',
      );
      expect(withoutId['site_url'], 'https://forum.example');
      expect(withoutId.containsKey('site_id'), isFalse);
      expect(withoutId['client_id'], 'abc:notify');
      expect(withoutId['user_api_key'], 'k');

      final withId = NotificationKeyService.registerBody(
        siteUrl: 'https://forum.example',
        siteId: 42,
        clientId: 'abc:notify',
        userApiKey: 'k',
      );
      expect(withId['site_id'], 42);
    });

    test('optional identity and device fields are omitted, never sent null',
        () {
      final bare = NotificationKeyService.registerBody(
        siteUrl: 'https://forum.example',
        clientId: 'c',
        userApiKey: 'k',
        discourseUsername: '',
        deviceToken: '',
      );
      expect(bare.keys,
          unorderedEquals(['site_url', 'client_id', 'user_api_key']));

      final full = NotificationKeyService.registerBody(
        siteUrl: 'https://forum.example',
        clientId: 'c',
        userApiKey: 'k',
        discourseUserId: 7,
        discourseUsername: 'jane',
        deviceToken: 'fcm',
        devicePlatform: 'ios',
      );
      expect(full['discourse_user_id'], 7);
      expect(full['discourse_username'], 'jane');
      expect(full['device_token'], 'fcm');
      expect(full['device_platform'], 'ios');
    });

    test('device body', () {
      final body = NotificationKeyService.deviceBody(
        siteUrl: 'https://forum.example//',
        siteId: 3,
        clientId: 'c',
        deviceToken: 'fcm',
        devicePlatform: 'android',
      );
      expect(body, {
        'site_url': 'https://forum.example',
        'site_id': 3,
        'client_id': 'c',
        'device_token': 'fcm',
        'device_platform': 'android',
      });
    });

    test('revoke body identifies the grant without the key', () {
      final body = NotificationKeyService.revokeBody(
        siteUrl: 'https://forum.example',
        clientId: 'c',
      );
      expect(body, {'site_url': 'https://forum.example', 'client_id': 'c'});
      expect(body.containsKey('user_api_key'), isFalse);
    });
  });
}
