import 'package:discourse_ui/config/app_forum_config.dart';
import 'package:discourse_ui/services/notification_installation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The installation is how the notifications backend knows this phone; its
/// credentials and report body are a contract with abda-push
/// (InstallationService there), so they are pinned here.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    NotificationInstallation.resetForTesting();
  });
  tearDown(() => AppForumConfig.setNotificationsApiBaseUrl(null));

  test('credentials are generated once, in the shape the backend accepts',
      () async {
    final first = await NotificationInstallation.credentials();
    // Backend: ^Bearer\s+([A-Za-z0-9_-]{16,64}):([A-Za-z0-9_-]{32,128})$
    expect(first.id, matches(RegExp(r'^[a-f0-9]{32}$')));
    expect(first.secret, matches(RegExp(r'^[A-Za-z0-9_-]{32,128}$')));
    expect(await NotificationInstallation.authorization(),
        'Bearer ${first.id}:${first.secret}');

    NotificationInstallation.resetForTesting();
    final again = await NotificationInstallation.credentials();
    expect(again.id, first.id, reason: 'kept across launches');
    expect(again.secret, first.secret);
  });

  test('a fresh install gets different credentials', () async {
    final a = await NotificationInstallation.credentials();
    SharedPreferences.setMockInitialValues({});
    NotificationInstallation.resetForTesting();
    final b = await NotificationInstallation.credentials();
    expect(b.id, isNot(a.id));
    expect(b.secret, isNot(a.secret));
  });

  test('report body leaves out an unknown token rather than erasing one', () {
    final body = NotificationInstallation.reportBody(
      devicePlatform: 'android',
      notificationsPermitted: false,
    );
    expect(body, {'device_platform': 'android', 'notifications_permitted': false});

    final full = NotificationInstallation.reportBody(
      deviceToken: 'fcm',
      devicePlatform: 'ios',
      notificationsPermitted: true,
      appVersion: '1.0.39+8',
      locale: 'en-US',
    );
    expect(full, {
      'device_token': 'fcm',
      'device_platform': 'ios',
      'notifications_permitted': true,
      'app_version': '1.0.39+8',
      'locale': 'en-US',
    });
  });

  test('nothing is reported before the phone has made a grant', () async {
    AppForumConfig.setNotificationsApiBaseUrl('https://x.example/api');
    expect(await NotificationInstallation.isRegistered(), isFalse);
    expect(await NotificationInstallation.report(token: 'fcm'), isFalse);
  });
}
