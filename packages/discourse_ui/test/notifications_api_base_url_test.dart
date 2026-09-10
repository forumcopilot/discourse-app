import 'package:discourse_ui/config/app_forum_config.dart';
import 'package:flutter_test/flutter_test.dart';

/// The notifications grant is off unless a backend is configured: a fork that
/// sets nothing must never ask its users to hand a forum key to a server the
/// fork's author does not run.
void main() {
  tearDown(() {
    AppForumConfig.setNotificationsApiBaseUrl(null);
    AppForumConfig.setPushApiBaseUrl(null);
  });

  test('off by default, as the OSS template expects', () {
    expect(AppForumConfig.defaultNotificationsApiBaseUrl, isEmpty);
    expect(AppForumConfig.notificationsApiBaseUrl, isEmpty);
    expect(AppForumConfig.isNotificationsGrantEnabled, isFalse);
  });

  test('a host app turns it on with its own backend', () {
    AppForumConfig.setNotificationsApiBaseUrl(
        'https://betterdiscourse.app/api');
    expect(AppForumConfig.isNotificationsGrantEnabled, isTrue);
    expect(AppForumConfig.notificationsApiBaseUrl,
        'https://betterdiscourse.app/api');
  });

  test('whitespace is trimmed rather than enabling the flow with a bad URL',
      () {
    AppForumConfig.setNotificationsApiBaseUrl('   ');
    expect(AppForumConfig.isNotificationsGrantEnabled, isFalse);
    AppForumConfig.setNotificationsApiBaseUrl('  https://x.example/api  ');
    expect(AppForumConfig.notificationsApiBaseUrl, 'https://x.example/api');
  });

  test('null restores the compile-time default', () {
    AppForumConfig.setNotificationsApiBaseUrl('https://x.example/api');
    AppForumConfig.setNotificationsApiBaseUrl(null);
    expect(AppForumConfig.notificationsApiBaseUrl,
        AppForumConfig.defaultNotificationsApiBaseUrl);
    expect(AppForumConfig.isNotificationsGrantEnabled, isFalse);
  });

  test('is independent of the push relay: it never adds the push scope', () {
    AppForumConfig.setNotificationsApiBaseUrl('https://x.example/api');
    expect(AppForumConfig.isPushBackendEnabled, isFalse);
    expect(AppForumConfig.discoursePushUrl, isNull);
    expect(AppForumConfig.userApiEffectiveScopes, isNot(contains('push')));
  });
}
