import 'dart:async';
import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/config/app_forum_config.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/notification_key_service.dart';
import 'package:discourse_ui/views/settings/do_not_disturb_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_account_switch_test.dart' show account;

void main() {
  late SiteContext site;
  late SharedPreferences prefs;
  late _Users users;
  final calls = <Map<String, dynamic>>[];
  final until = DateTime.utc(2099, 1, 1);
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
            (_) async => null);
    AppForumConfig.setNotificationsApiBaseUrl('https://relay.example/api');
    site = account();
    await site.setUserApiCredentials(
        userApiKey: 'first', userApiClientId: 'first');
    prefs = await SharedPreferences.getInstance();
    final prefix = site.discourseStoragePrefix;
    await prefs.setBool('${prefix}_notifications_key_granted', true);
    await prefs.setBool('${prefix}_notifications_key_install_bound', true);
    await prefs.setString(
        '${prefix}_notifications_client_suffix', 'first-grant');
    await prefs.setString('${prefix}_notifications_dnd_reported', 'off');
    users = _Users(site);
    calls.clear();
    NotificationKeyService.requestOverride = (_, __, body) async {
      calls.add(body);
      return {'ok': true};
    };
  });
  tearDown(() {
    NotificationKeyService.requestOverride = null;
    AppForumConfig.setNotificationsApiBaseUrl(null);
  });
  Future<void> open(WidgetTester tester,
      {Size size = const Size(800, 1400), double textScale = 1}) async {
    users.writeGate = Completer<DiscourseDoNotDisturbResult>();
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!),
      home: Scaffold(body: DoNotDisturbTile(siteContext: site, users: users)),
    ));
  }

  Future<void> switchAccount() async {
    await site.setUserApiCredentials(
        userApiKey: 'second', userApiClientId: 'second');
    site.setLoginData(FCLoginResult(
        result: true,
        resultText: '',
        user: FCUser(id: '8', username: 'user8')));
    await prefs.setString(
        '${site.discourseStoragePrefix}_notifications_client_suffix',
        'second-grant');
    await prefs.setString(
        '${site.discourseStoragePrefix}_notifications_dnd_reported',
        'replacement-state');
  }

  testWidgets('picker can rebuild after its profile tile leaves the viewport',
      (tester) async {
    final visible = ValueNotifier(true);
    addTearDown(visible.dispose);
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
          body: ValueListenableBuilder<bool>(
        valueListenable: visible,
        builder: (_, shown, __) => shown
            ? DoNotDisturbTile(siteContext: site, users: users)
            : const SizedBox.shrink(),
      )),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Do not disturb'));
    await tester.pumpAndSettle();
    // A lazy profile list can dispose its tile when text scaling shifts
    // the visible rows, while the modal route stays open above that list.
    visible.value = false;
    await tester.pumpAndSettle();
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    tester.view.physicalSize = const Size(640, 360);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Until tomorrow'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Until tomorrow'));
    await tester.pumpAndSettle();
    expect(find.text('Until tomorrow'), findsNothing);
    expect(users.enters, 0);
    expect(calls, isEmpty);
  });

  for (final textScale in [1.0, 2.0]) {
    testWidgets(
        'short screen at text scale $textScale can select the last duration',
        (tester) async {
      await open(tester, size: const Size(640, 360), textScale: textScale);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Do not disturb'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Until tomorrow'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Until tomorrow'));
      await tester.pumpAndSettle();
      expect(users.lastDuration, 'tomorrow');
      users.writeGate
          .complete(DiscourseDoNotDisturbResult(result: true, endsAt: until));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  for (final operation in ['load', 'enter', 'leave']) {
    testWidgets(
        '$operation response after account switch does not report old DND to the new grant',
        (tester) async {
      if (operation == 'load') {
        users.loadGate = Completer<DiscourseDoNotDisturbResult>();
      }
      if (operation == 'leave') {
        users.initial =
            DiscourseDoNotDisturbResult(result: true, endsAt: until);
        await prefs.setString(
            '${site.discourseStoragePrefix}_notifications_dnd_reported',
            until.toIso8601String());
      }
      await open(tester);
      await tester.pumpAndSettle();
      if (operation == 'enter') {
        await tester.tap(find.text('Do not disturb'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('30 minutes'));
        await tester.pumpAndSettle();
        expect(users.enters, 1);
      } else if (operation == 'leave') {
        await tester.tap(find.text('Turn off'));
        await tester.pump();
        expect(users.leaves, 1);
      }
      expect(calls, isEmpty);
      await switchAccount();
      final result = DiscourseDoNotDisturbResult(
          result: true, endsAt: operation == 'leave' ? null : until);
      (operation == 'load' ? users.loadGate! : users.writeGate)
          .complete(result);
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
      expect(
          prefs.getString(
              '${site.discourseStoragePrefix}_notifications_dnd_reported'),
          'replacement-state');
      expect(find.text('Your sign-in changed. Reopen this screen to continue.'),
          findsOneWidget);
    });
  }
  testWidgets(
      'switching accounts while the duration picker is open sends no DND request',
      (tester) async {
    await open(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Do not disturb'));
    await tester.pumpAndSettle();
    await switchAccount();
    await tester.tap(find.text('30 minutes'));
    await tester.pumpAndSettle();
    expect(users.enters, 0);
    expect(calls, isEmpty);
    expect(find.text('Your sign-in changed. Reopen this screen to continue.'),
        findsOneWidget);
  });
}

class _Users extends DiscourseUserProxy {
  _Users(super.context);
  DiscourseDoNotDisturbResult initial =
      DiscourseDoNotDisturbResult(result: true);
  Completer<DiscourseDoNotDisturbResult>? loadGate;
  late Completer<DiscourseDoNotDisturbResult> writeGate;
  int enters = 0;
  String? lastDuration;
  int leaves = 0;
  @override
  Future<DiscourseDoNotDisturbResult> getDoNotDisturbStatusAsync() async =>
      loadGate?.future ?? initial;
  @override
  Future<DiscourseDoNotDisturbResult> enterDoNotDisturbAsync(String duration) {
    enters++;
    lastDuration = duration;
    return writeGate.future;
  }

  @override
  Future<DiscourseDoNotDisturbResult> leaveDoNotDisturbAsync() {
    leaves++;
    return writeGate.future;
  }
}
