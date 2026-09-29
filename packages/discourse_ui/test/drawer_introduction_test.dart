import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/widgets/drawer_introduction.dart';
import 'package:discourse_ui/views/widgets/site_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In a host app the forum's left edge is Back, so its drawer opens from ☰
/// only. It shows itself once, the first time a forum is opened, with a line
/// on how to open it again.
void main() {
  final navigatorKey = GlobalKey<NavigatorState>();
  final forumKey = GlobalKey<ScaffoldState>();
  var introduced = 0;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    introduced = 0;
  });

  Future<bool> seen() async =>
      (await SharedPreferences.getInstance())
          .getBool(DrawerIntroduction.prefsKey) ??
      false;

  Future<void> start(WidgetTester tester) => tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(body: Text('Forum list')),
      ));

  Future<void> openForum(WidgetTester tester, {bool enabled = true}) async {
    navigatorKey.currentState!.push(MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        key: forumKey,
        appBar: AppBar(title: const Text('Forum')),
        drawer: const Drawer(child: Text('Map')),
        body: DrawerIntroduction(
          enabled: enabled,
          onIntroduce: () => introduced++,
          child: const Center(child: Text('Topics')),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> closeForum(WidgetTester tester) async {
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
    await tester.pumpAndSettle();
  }

  /// The pause after the forum has slid in, then the drawer's own slide.
  Future<void> wait(WidgetTester tester) async {
    await tester.pump(DrawerIntroduction.delay);
    await tester.pumpAndSettle();
  }

  bool drawerOpen() => forumKey.currentState?.isDrawerOpen ?? false;

  testWidgets('the first forum opens its drawer once, after a moment',
      (tester) async {
    await start(tester);
    await openForum(tester);
    expect(drawerOpen(), isFalse, reason: 'the forum shows first');

    await wait(tester);
    expect(drawerOpen(), isTrue);
    expect(introduced, 1);
    expect(await seen(), isTrue);

    await closeForum(tester);
    await openForum(tester);
    await wait(tester);
    expect(drawerOpen(), isFalse, reason: 'once per install');
    expect(introduced, 1);
  });

  testWidgets('not in the single-forum app, whose edge opens the drawer',
      (tester) async {
    await start(tester);
    await openForum(tester, enabled: false);
    await wait(tester);
    expect(drawerOpen(), isFalse);
    expect(await seen(), isFalse);
  });

  testWidgets('a reader already touching the screen is not interrupted',
      (tester) async {
    await start(tester);
    await openForum(tester);
    await tester.tap(find.text('Topics'));
    await wait(tester);
    expect(drawerOpen(), isFalse);
    expect(await seen(), isFalse, reason: 'it tries again next time');

    await closeForum(tester);
    await openForum(tester);
    await wait(tester);
    expect(drawerOpen(), isTrue);
  });

  testWidgets('not over a page opened on top of the forum', (tester) async {
    await start(tester);
    await openForum(tester);
    navigatorKey.currentState!.push(MaterialPageRoute<void>(
      builder: (_) => const Scaffold(body: Text('A topic')),
    ));
    await tester.pumpAndSettle();
    await wait(tester);
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    expect(drawerOpen(), isFalse);
    expect(await seen(), isFalse);
  });

  testWidgets('a reader who opened the drawer themselves has found it',
      (tester) async {
    await DrawerIntroduction.markSeen();
    await start(tester);
    await openForum(tester);
    await wait(tester);
    expect(drawerOpen(), isFalse);
    expect(introduced, 0);
  });

  group('the drawer', () {
    SiteContext forum() => SiteContext(
          siteType: 'intro-test',
          site: Site(
            id: null,
            name: 'Test Forum',
            url: 'https://forum.example',
            description: '',
            endpoint: null,
            baseUrl: 'https://forum.example',
            logoUrl: null,
            backgroundUrl: null,
            siteType: 'intro-test',
          ),
        );

    Future<void> pump(WidgetTester tester, {required bool introduction}) async {
      tester.view.physicalSize = const Size(1080, 2600);
      tester.view.devicePixelRatio = 2.6;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SiteDrawer(siteContext: forum(), introduction: introduction),
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('says what it holds and how to open it again, that one time',
        (tester) async {
      await pump(tester, introduction: true);
      expect(find.textContaining('are all in this menu'), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget,
          reason: 'the ☰ it names, so the button is recognised');

      await pump(tester, introduction: false);
      expect(find.textContaining('are all in this menu'), findsNothing);
    });
  });
}
