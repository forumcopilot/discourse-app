import 'package:discourse_ui/config/app_forum_config.dart';
import 'package:discourse_ui/services/discourse_login_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The name reaches Discourse's grant page, not just the config getter.
///
/// Discourse prints `application_name` on `/user-api-key/new` — it is the
/// only thing telling the user which app is asking for their account — and
/// stores it on the `UserApiKeyClient` row, so it is what they see later
/// under Preferences → Security → Apps. A host app sets it at startup;
/// this walks the real path from there to the URL the webview opens.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const url = 'https://forum.example';
  DiscourseLoginService service() => DiscourseLoginService(SiteContext(
        siteType: 'discourse',
        site: Site(
          id: null,
          name: 'Example',
          url: url,
          description: 'application name test',
          endpoint: null,
          baseUrl: url,
          logoUrl: null,
          backgroundUrl: null,
          siteType: 'discourse',
        ),
      ));

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });
  tearDown(() => AppForumConfig.setUserApiApplicationName(null));

  test('the login grant is asked for under the host app\'s name', () async {
    AppForumConfig.setUserApiApplicationName('A Better Discourse App (ABDA)');
    final request = await service().beginLogin();
    expect(Uri.parse(request.url).queryParameters['application_name'],
        'A Better Discourse App (ABDA)');
  });

  test('so is the separate notifications grant', () async {
    // Two grant pages, two chances to show the user a name they do not
    // recognise; both read the same setting.
    AppForumConfig.setUserApiApplicationName('A Better Discourse App (ABDA)');
    final request = await service().beginNotificationsGrant();
    expect(Uri.parse(request.url).queryParameters['application_name'],
        'A Better Discourse App (ABDA)');
  });

  test('an unconfigured build still names itself something', () async {
    final request = await service().beginLogin();
    expect(Uri.parse(request.url).queryParameters['application_name'],
        AppForumConfig.defaultUserApiApplicationName);
  });
}
