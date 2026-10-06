import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_notifications/discourse_notifications.dart';
import 'package:discourse_ui/config/app_forum_config.dart';
import 'package:discourse_ui/services/account_notifications.dart';
import 'package:discourse_ui/services/discourse_login_service.dart';
import 'package:discourse_ui/services/notification_installation.dart';
import 'package:discourse_ui/services/notification_key_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_account_switch_test.dart' show account;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    DiscourseNotifications.ready = false;
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(DiscourseNotifications.channel, (call) async {
      calls.add(call);
      return null;
    });
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    DiscourseNotifications.ready = false;
  });
  test('upgrade seeds all forum identities using the core storage contract',
      () async {
    final first = account();
    final second = account(id: '4', url: 'https://forum.example/Other');
    await first.saveLoginSnapshot(first.loginDataOutput!.toJson());
    await second.saveLoginSnapshot(second.loginDataOutput!.toJson());
    await AccountNotifications.initialize(onTap: (_) {});
    expect(calls.first.method, 'configure');
    expect(calls.first.arguments['accounts'],
        {first.site.url: '7', second.site.url: '4'});
    expect(DiscourseNotifications.ready, isTrue);
  });
  test('retirement clears local ownership even without a backend', () async {
    await DiscourseLoginService(account()).retireNotificationsGrant();
    expect(calls.first.method, 'setAccount');
    expect(calls.first.arguments,
        {'forum': 'https://forum.example/sub', 'userId': null});
  });
  test('stale session cannot republish a departed account', () async {
    final context = account();
    final session = context.configurationSession;
    final clearing = context.clearUserApiCredentials();
    await AccountNotifications.activate(context, session);
    expect(calls, isEmpty);
    try {
      await clearing;
    } catch (_) {}
  });
  test('logout invalidation precedes awaits and rejects late activation', () async {
    final context = account();
    final session = context.configurationSession;
    final retirement = AccountNotifications.retire(context);
    await AccountNotifications.activate(context, session);
    await retirement;
    expect(calls.map((c) => c.arguments['userId']), [null]);
    await AccountNotifications.activate(context, session, newGrant: true);
    expect(calls.last.arguments['userId'], '7');
  });
  test('a native failure never breaks sign-in or sign-out', () async {
    // A forum address the native side could not read used to throw out of
    // finishLogin (half-applied) and handleLogout (no way to sign out).
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(DiscourseNotifications.channel, (call) async {
      calls.add(call);
      throw PlatformException(code: 'notification_error', message: 'Invalid forum');
    });
    final context = account();
    await AccountNotifications.activate(
        context, context.configurationSession, newGrant: true);
    await AccountNotifications.retire(context);
    await DiscourseLoginService(context).retireNotificationsGrant();
    expect(calls.map((c) => c.method), everyElement('setAccount'));
  });

  group('with the notifications backend', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
              (_) async => null);
      AppForumConfig.setNotificationsApiBaseUrl('https://relay.example/api');
      NotificationKeyService.requestOverride = (_, __, ___) async => null;
    });
    tearDown(() {
      NotificationKeyService.requestOverride = null;
      AppForumConfig.setNotificationsApiBaseUrl(null);
    });

    test('a grant finishing during sign-out cannot restore the account',
        () async {
      final context = account();
      final login = DiscourseLoginService(context);
      final grant = await login.beginNotificationsGrant();
      final session = context.configurationSession;
      calls.clear();
      final signingOut = login.retireNotificationsGrant();
      // The grant lands while sign-out is queueing the relay revoke; the
      // page passes what it started with, as enable_notifications_page does.
      await Future<void>.delayed(Duration.zero);
      final granting = login.markNotificationsGranted(
          installBound: true,
          expectedSession: session,
          expectedClientId: grant.clientId);
      await Future.wait([signingOut, granting.catchError((_) => false)]);
      final accounts = calls
          .where((c) => c.method == 'setAccount')
          .map((c) => c.arguments['userId'])
          .toList();
      expect(accounts.last, isNull,
          reason: 'signed out: this forum shows no one\'s notifications');
    });

    test('no key on launch retires a grant left behind', () async {
      // A restore from backup brings preferences back, not the key.
      final context = account(id: null);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
          '${context.discourseStoragePrefix}_notifications_key_granted', true);
      expect(await DiscourseLoginService(context).restorePersistedSession(),
          isFalse);
      expect(prefs.getBool(
              '${context.discourseStoragePrefix}_notifications_key_granted'),
          isNull);
      expect(
          prefs.getKeys().where((k) => k.startsWith('notifications_pending_revoke:')),
          hasLength(1));
      expect(calls.last.arguments, {'forum': context.site.url, 'userId': null});
    });
  });

  test('guarded rejection never falls back to unguarded display', () async {
    expect(
        await AccountNotifications.handle(
            {'delivery_mode': 'account_guarded_v1', 'recipient_user_id': '1'}),
        isTrue);
    expect(calls.single.method, 'show');
    expect(await AccountNotifications.handle({'type': 'legacy'}), isFalse);
  });
  test('only ready Android hosts advertise guarded delivery', () {
    Map<String, dynamic> body(String platform, bool ready) =>
        NotificationInstallation.reportBody(
          devicePlatform: platform,
          notificationsPermitted: true,
          guardedAndroidDelivery: ready,
        );
    expect(
        body('android', true)['notification_delivery'], 'account_guarded_v1');
    expect(
        body('android', false).containsKey('notification_delivery'), isFalse);
    expect(body('ios', true).containsKey('notification_delivery'), isFalse);
  });
}
