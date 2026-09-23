import 'package:discourse_core/discourse_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
    DiscourseSiteContextExtension.keyReadRetryDelays = const [
      Duration.zero,
      Duration.zero,
    ];
  });

  tearDown(() {
    DiscourseSiteContextExtension.debugSecureStorageOverride = null;
    debugDefaultTargetPlatformOverride = null;
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

  // A refused read (the Keychain around a lock-state change) is not an empty
  // store. Verified on an iPhone 17 on 2026-09-22: a notification tapped on
  // the lock screen opened the forum signed out, while the key was intact —
  // a cold start signed back in.
  group('a refused key read', () {
    test('is retried, and a later success loads the key', () async {
      await freshContext().setUserApiCredentials(
        userApiKey: 'k-secret',
        userApiClientId: 'client-1',
      );
      final flaky = _RefusingStorage(refusals: 2);
      DiscourseSiteContextExtension.debugSecureStorageOverride = flaky;

      final ctx = freshContext();
      await ctx.loadUserApiCredentials();
      expect(flaky.reads, 3);
      expect(ctx.userApiKey, 'k-secret');
      expect(ctx.hasUserApiKey, isTrue);
    });

    test('does not drop a key this context already holds', () async {
      // Site init loads the key, then restorePersistedSession loads it again;
      // the second read being refused must not sign the user out.
      final ctx = freshContext();
      await ctx.setUserApiCredentials(
        userApiKey: 'k-secret',
        userApiClientId: 'client-1',
      );
      await ctx.loadUserApiCredentials();
      expect(ctx.hasUserApiKey, isTrue);

      DiscourseSiteContextExtension.debugSecureStorageOverride =
          _RefusingStorage(refusals: 99);
      await ctx.loadUserApiCredentials();
      expect(ctx.userApiKey, 'k-secret');
      expect(ctx.hasUserApiKey, isTrue);
    });

    test('with nothing loaded starts signed out but leaves the key stored',
        () async {
      await freshContext().setUserApiCredentials(
        userApiKey: 'k-secret',
        userApiClientId: 'client-1',
      );
      DiscourseSiteContextExtension.debugSecureStorageOverride =
          _RefusingStorage(refusals: 99);

      final ctx = freshContext();
      await expectLater(ctx.loadUserApiCredentials(), completes);
      expect(ctx.hasUserApiKey, isFalse);
      expect(ctx.userApiAuthHeaders(), isEmpty);

      // The store was never touched, so the next launch signs back in.
      DiscourseSiteContextExtension.debugSecureStorageOverride = null;
      final next = freshContext();
      await next.loadUserApiCredentials();
      expect(next.userApiKey, 'k-secret');
    });
  });

  group('iOS Keychain class move', () {
    test('an entry from an older build is rewritten once, then left alone',
        () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      // What an older build left: key in the Keychain, no class marker.
      FlutterSecureStorage.setMockInitialValues(
          {'${prefix()}_user_api_key': 'k-old'});
      SharedPreferences.setMockInitialValues(
          {'${prefix()}_user_api_client_id': 'client-1'});
      final counting = _RefusingStorage(refusals: 0);
      DiscourseSiteContextExtension.debugSecureStorageOverride = counting;

      await freshContext().loadUserApiCredentials();
      expect(counting.writes, 1, reason: 'moved under the new class');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('${prefix()}_user_api_key_ios_class'),
          'first_unlock');

      final again = freshContext();
      await again.loadUserApiCredentials();
      expect(counting.writes, 1, reason: 'already moved');
      expect(again.userApiKey, 'k-old');
    });

    test('sign-out forgets the marker with the key', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final ctx = freshContext();
      await ctx.setUserApiCredentials(
        userApiKey: 'k-secret',
        userApiClientId: 'client-1',
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('${prefix()}_user_api_key_ios_class'),
          'first_unlock');

      await ctx.clearUserApiCredentials();
      expect(prefs.getString('${prefix()}_user_api_key_ios_class'), isNull);
      expect(
        await const FlutterSecureStorage()
            .read(key: '${prefix()}_user_api_key'),
        isNull,
      );
    });
  });
}

/// Refuses the first [refusals] reads the way iOS does while the Keychain is
/// locked, then defers to the plugin's mock store. Counts reads and writes.
class _RefusingStorage extends FlutterSecureStorage {
  _RefusingStorage({required this.refusals});

  int refusals;
  int reads = 0;
  int writes = 0;

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    reads++;
    if (refusals > 0) {
      refusals--;
      throw PlatformException(
        code: 'Unexpected security result code',
        message: 'Code: -25308, Message: User interaction is not allowed.',
      );
    }
    return const FlutterSecureStorage().read(key: key);
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) {
    writes++;
    return const FlutterSecureStorage().write(key: key, value: value);
  }
}
