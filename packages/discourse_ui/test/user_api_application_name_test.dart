import 'package:discourse_ui/config/app_forum_config.dart';
import 'package:flutter_test/flutter_test.dart';

/// The name Discourse shows on its grant page is the only thing telling the
/// user which app is asking for access to their account, so it has to be
/// the app they installed — not the template's placeholder.
void main() {
  tearDown(() => AppForumConfig.setUserApiApplicationName(null));

  test('falls back to the compile-time default', () {
    expect(AppForumConfig.userApiApplicationName,
        AppForumConfig.defaultUserApiApplicationName);
  });

  test('a host app names itself', () {
    AppForumConfig.setUserApiApplicationName('A Better Discourse App (ABDA)');
    expect(AppForumConfig.userApiApplicationName,
        'A Better Discourse App (ABDA)');
  });

  test('whitespace is trimmed rather than sent as-is', () {
    AppForumConfig.setUserApiApplicationName('  ABDA  ');
    expect(AppForumConfig.userApiApplicationName, 'ABDA');
  });

  test('null or blank restores the default', () {
    AppForumConfig.setUserApiApplicationName('ABDA');
    AppForumConfig.setUserApiApplicationName('   ');
    expect(AppForumConfig.userApiApplicationName,
        AppForumConfig.defaultUserApiApplicationName);
    AppForumConfig.setUserApiApplicationName('ABDA');
    AppForumConfig.setUserApiApplicationName(null);
    expect(AppForumConfig.userApiApplicationName,
        AppForumConfig.defaultUserApiApplicationName);
  });
}
