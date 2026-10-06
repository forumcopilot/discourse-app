import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/config/app_forum_config.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/views/settings/do_not_disturb_tile.dart';
import 'package:discourse_ui/views/settings/notification_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notification settings say where each setting applies: push on this
/// device, or the reader's account on the forum everywhere. Stopping push
/// says what it deletes before it does, and Do Not Disturb lives on the
/// Profile tab alone, where it follows the status sheet.
void main() {
  SiteContext context() {
    final ctx = SiteContext(
      siteType: 'scope-test',
      site: Site(
        id: null,
        name: 'Test Forum',
        url: 'https://forum.example',
        description: '',
        endpoint: null,
        baseUrl: 'https://forum.example',
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'scope-test',
      ),
    );
    ctx.setLoginData(FCLoginResult(
      result: true,
      resultText: '',
      user: FCUser(id: '2', username: 'tung'),
    ));
    return ctx;
  }

  Future<void> pump(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(1080, 6400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ));
    await tester.pumpAndSettle();
  }

  tearDown(() => AppForumConfig.setNotificationsApiBaseUrl(null));

  group('Stop push confirmation', () {
    Future<bool?> open(WidgetTester tester, String button) async {
      bool? answer;
      await pump(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => answer =
                  await confirmStopPush(context, forumName: 'Test Forum'),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Stop push from Test Forum on this device?'),
          findsOneWidget);
      expect(
          find.text('Only this device stops. Your other devices keep theirs.'),
          findsOneWidget);
      expect(
          find.text('Your notifications still show in the app and on the web, '
              "and the forum's emails don't change."),
          findsOneWidget);
      expect(
          find.text('The permission you gave on Test Forum is deleted. To turn '
              "push back on, you'll approve it there again."),
          findsOneWidget);
      expect(find.textContaining('Do not disturb on your profile'),
          findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, button));
      await tester.pumpAndSettle();
      return answer;
    }

    testWidgets('Cancel keeps push', (tester) async {
      expect(await open(tester, 'Cancel'), isFalse);
    });

    testWidgets('Stop push goes ahead', (tester) async {
      expect(await open(tester, 'Stop push'), isTrue);
    });
  });

  group('Notification settings page', () {
    late _Account account;
    Future<SiteContext> setUp({required bool granted}) async {
      final ctx = context();
      final prefix = ctx.discourseStoragePrefix;
      SharedPreferences.setMockInitialValues({
        if (granted) '${prefix}_notifications_key_granted': true,
        if (granted) '${prefix}_notifications_key_install_bound': true,
      });
      AppForumConfig.setNotificationsApiBaseUrl('https://push.example/api');
      account = _Account();
      SiteProxyFactory.register('scope-test', _Factory(account));
      SiteProxyService.initialize(ctx);
      return ctx;
    }

    for (final scale in [1.0, 2.0]) {
      testWidgets(
          'email picker remains selectable in landscape at ${scale}x text',
          (tester) async {
        final ctx = await setUp(granted: false);
        await pump(tester, NotificationSettingsPage(siteContext: ctx));
        await tester.tap(find.text('Email when away'));
        await tester.pumpAndSettle();

        // Rotate and enlarge text while the sheet is already open, as on device.
        tester.view.physicalSize = const Size(640, 360);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        final lastOption = find.descendant(
            of: find.byType(BottomSheet), matching: find.text('Never'));
        await tester.ensureVisible(lastOption);
        await tester.pumpAndSettle();
        await tester.tap(lastOption);
        await tester.pumpAndSettle();
        expect(find.byType(BottomSheet), findsNothing);
        expect(account.saved.single.emailLevel, 2);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('push on: this device, then the account everywhere',
        (tester) async {
      final ctx = await setUp(granted: true);
      await pump(tester, NotificationSettingsPage(siteContext: ctx));

      expect(find.text('On this device'), findsOneWidget);
      expect(
          find.text('Push from Test Forum to this device only. Your other '
              "devices and the web aren't affected."),
          findsOneWidget);
      expect(find.text('Push notifications'), findsOneWidget);
      expect(
          find.text(
              'On: new notifications from Test Forum are pushed to this device.'),
          findsOneWidget);
      for (final kind in _kinds) {
        expect(find.widgetWithText(SwitchListTile, kind), findsOneWidget,
            reason: 'the per-type switches are the everyday control');
      }
      expect(find.text('Stop push on this device'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Turn off'), findsNothing);

      expect(find.text('Your Test Forum account'), findsOneWidget);
      expect(
          find.text('These apply everywhere: on the web, by email and on all '
              'your devices.'),
          findsOneWidget);
      expect(find.text('Email when away'), findsOneWidget);
      expect(find.text('Notify when liked'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Stop push on this device')).dy,
          lessThan(tester.getTopLeft(find.text('Your Test Forum account')).dy),
          reason: 'device settings first, account settings after');

      expect(find.text('Do not disturb'), findsNothing,
          reason: 'it lives on the Profile tab');
    });

    testWidgets('stopping asks first; Cancel leaves push on', (tester) async {
      final ctx = await setUp(granted: true);
      await pump(tester, NotificationSettingsPage(siteContext: ctx));

      await tester.tap(find.text('Stop push on this device'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(
          find.text(
              'On: new notifications from Test Forum are pushed to this device.'),
          findsOneWidget);
    });

    testWidgets('push off: says turning on means approving on the forum',
        (tester) async {
      final ctx = await setUp(granted: false);
      await pump(tester, NotificationSettingsPage(siteContext: ctx));

      expect(
          find.text('Off on this device. To turn it on, you approve it once '
              'on Test Forum.'),
          findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Turn on'), findsOneWidget);
      expect(find.text('Stop push on this device'), findsNothing);
      for (final kind in _kinds) {
        expect(find.text(kind), findsNothing);
      }
    });
  });

  testWidgets(
      'the Profile tab row re-reads Do Not Disturb when it changes '
      'elsewhere', (tester) async {
    final ctx = context();
    final users = _Users(ctx);
    await pump(
      tester,
      Scaffold(body: DoNotDisturbTile(siteContext: ctx, users: users)),
    );
    expect(find.textContaining('On until'), findsNothing);

    // The status sheet's "Pause notifications" turned it on.
    users.next = DiscourseDoNotDisturbResult(
      result: true,
      endsAt: DateTime.now().toUtc().add(const Duration(hours: 2)),
    );
    DoNotDisturbTile.notifyChanged();
    await tester.pumpAndSettle();
    expect(find.textContaining('On until'), findsOneWidget);
  });
}

const _kinds = [
  'Messages and chat',
  'Replies and mentions',
  'Likes and reactions',
  'Everything else',
];

class _Users extends DiscourseUserProxy {
  _Users(super.context);

  DiscourseDoNotDisturbResult next = DiscourseDoNotDisturbResult(result: true);

  @override
  Future<DiscourseDoNotDisturbResult> getDoNotDisturbStatusAsync() async =>
      next;
}

class _Account implements IFCAccountProxy {
  final saved = <FCNotificationPrefs>[];

  @override
  Future<FCNotificationPrefsResult> updateNotificationPrefsAsync(
      FCNotificationPrefs prefs) async {
    saved.add(prefs);
    return FCNotificationPrefsResult(result: true, prefs: prefs);
  }

  @override
  Future<FCNotificationPrefsResult> getNotificationPrefsAsync() async =>
      FCNotificationPrefsResult(result: true, prefs: FCNotificationPrefs());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Factory implements SiteProxyFactory {
  final _Account account;
  _Factory(this.account);
  @override
  IFCAccountProxy createAccountProxy(SiteContext context) => account;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
