import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The User API Key must survive a process restart and clear completely on
/// sign-out. These run against the plugins' mock channels, so they prove
/// the Dart contract (which keys go where, migration, tolerance of a lost
/// key), not the platform stores themselves.
///
/// Background: the audit recorded the Pixel silently signing out mid-way
/// through a session, cause unknown. Whatever the platform did, the Dart
/// layer used to make it worse — a secure-storage read that threw took the
/// whole launch down with it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const url = 'https://forum.example';
  Site site() => Site(
        id: null,
        name: 'Example',
        url: url,
        description: 'persistence test site',
        endpoint: null,
        baseUrl: url,
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'discourse',
      );
  SiteContext freshContext() => SiteContext(siteType: 'discourse', site: site());
  String prefix() => 'discourse:${site().pluginUrl}';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('credentials written by one context are readable by a fresh one',
      () async {
    await freshContext().setUserApiCredentials(
      userApiKey: 'k-secret',
      userApiClientId: 'client-1',
      pushEnabled: true,
    );

    final restored = freshContext();
    expect(restored.hasUserApiKey, isFalse, reason: 'not loaded yet');
    await restored.loadUserApiCredentials();

    expect(restored.hasUserApiKey, isTrue);
    expect(restored.userApiKey, 'k-secret');
    expect(restored.userApiClientId, 'client-1');
    expect(restored.userApiPushEnabled, isTrue);
    expect(restored.userApiAuthHeaders(), {
      'User-Api-Key': 'k-secret',
      'User-Api-Client-Id': 'client-1',
    });
  });

  test('the key itself never lands in plain SharedPreferences', () async {
    await freshContext().setUserApiCredentials(
      userApiKey: 'k-secret',
      userApiClientId: 'client-1',
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('${prefix()}_user_api_key'), isNull);
    expect(prefs.getString('${prefix()}_user_api_client_id'), 'client-1');
    expect(
      await const FlutterSecureStorage().read(key: '${prefix()}_user_api_key'),
      'k-secret',
    );
  });

  test('a plaintext key from an older build is migrated on read', () async {
    SharedPreferences.setMockInitialValues({
      '${prefix()}_user_api_key': 'legacy-key',
      '${prefix()}_user_api_client_id': 'client-old',
    });

    final ctx = freshContext();
    await ctx.loadUserApiCredentials();
    expect(ctx.hasUserApiKey, isTrue);
    expect(ctx.userApiKey, 'legacy-key');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('${prefix()}_user_api_key'), isNull,
        reason: 'plaintext copy removed');

    // And it now comes from secure storage, not the removed pref.
    final again = freshContext();
    await again.loadUserApiCredentials();
    expect(again.userApiKey, 'legacy-key');
  });

  test('a lost key starts the app signed out, not crashed', () async {
    // Client id survived, secret did not: what a cloud-restored install or
    // a Keystore reset looks like from Dart.
    SharedPreferences.setMockInitialValues({
      '${prefix()}_user_api_client_id': 'client-1',
      '${prefix()}_login_snapshot': '{"user":{"id":1}}',
    });

    final ctx = freshContext();
    await expectLater(ctx.loadUserApiCredentials(), completes);
    expect(ctx.hasUserApiKey, isFalse);
    expect(ctx.userApiAuthHeaders(), isEmpty,
        reason: 'no half-credential must ever reach a request');
  });

  test('sign-out clears every trace, including the login snapshot',
      () async {
    final ctx = freshContext();
    await ctx.setUserApiCredentials(
      userApiKey: 'k-secret',
      userApiClientId: 'client-1',
    );
    await ctx.saveLoginSnapshot('{"user":{"id":1}}');

    await ctx.clearUserApiCredentials();
    expect(ctx.hasUserApiKey, isFalse);

    final restored = freshContext();
    await restored.loadUserApiCredentials();
    expect(restored.hasUserApiKey, isFalse);
    expect(restored.userApiClientId, isNull);
    expect(await restored.readLoginSnapshot(), isNull);
    expect(
      await const FlutterSecureStorage().read(key: '${prefix()}_user_api_key'),
      isNull,
    );
  });
}
