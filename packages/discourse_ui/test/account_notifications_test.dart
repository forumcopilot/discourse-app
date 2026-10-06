import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_notifications/discourse_notifications.dart';
import 'package:discourse_ui/services/account_notifications.dart';
import 'package:discourse_ui/services/discourse_login_service.dart';
import 'package:discourse_ui/services/notification_installation.dart';
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
