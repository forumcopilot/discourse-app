import 'package:discourse_ui/config/app_forum_config.dart';
import 'package:flutter_test/flutter_test.dart';

/// The push relay URL has to be settable at runtime because `discourse_ui` is
/// shared: the open-source single-forum template ships it empty, while the
/// multi-tenant ForumCopilot app points every embedded Discourse site at its
/// hosted relay. These assert that one call flips the whole derived chain —
/// `isPushBackendEnabled`, the registered `push_url`, and the `push` scope in
/// the User API Key handshake.
void main() {
  tearDown(() => AppForumConfig.setPushApiBaseUrl(null));

  test('push is off by default, as the OSS template expects', () {
    expect(AppForumConfig.defaultPushApiBaseUrl, isEmpty);
    expect(AppForumConfig.pushApiBaseUrl, isEmpty);
    expect(AppForumConfig.isPushBackendEnabled, isFalse);
    expect(AppForumConfig.discoursePushUrl, isNull);
    expect(AppForumConfig.userApiEffectiveScopes, isNot(contains('push')));
  });

  test('setting the override enables the entire chain', () {
    AppForumConfig.setPushApiBaseUrl('https://push.forumcopilot.com/api');

    expect(AppForumConfig.isPushBackendEnabled, isTrue);
    // The relay path contract Discourse will POST to.
    expect(AppForumConfig.discoursePushUrl,
        'https://push.forumcopilot.com/api/discourse/push');
    // Without this scope Discourse never calls push_url at all.
    expect(AppForumConfig.userApiEffectiveScopes, contains('push'));
  });

  test('a trailing slash does not produce a double slash in push_url', () {
    // Discourse substring-matches push_url against allowed_user_api_push_urls,
    // so a stray slash would silently fail the allowlist check.
    AppForumConfig.setPushApiBaseUrl('https://push.forumcopilot.com/api/');
    expect(AppForumConfig.discoursePushUrl,
        'https://push.forumcopilot.com/api/discourse/push');
  });

  test('whitespace is trimmed rather than enabling push with a bad URL', () {
    AppForumConfig.setPushApiBaseUrl('   ');
    expect(AppForumConfig.isPushBackendEnabled, isFalse);
    expect(AppForumConfig.discoursePushUrl, isNull);
  });

  test('clearing the override falls back to the compile-time default', () {
    AppForumConfig.setPushApiBaseUrl('https://push.forumcopilot.com/api');
    expect(AppForumConfig.isPushBackendEnabled, isTrue);

    AppForumConfig.setPushApiBaseUrl(null);
    expect(AppForumConfig.pushApiBaseUrl, AppForumConfig.defaultPushApiBaseUrl);
    expect(AppForumConfig.isPushBackendEnabled, isFalse);
  });
}
