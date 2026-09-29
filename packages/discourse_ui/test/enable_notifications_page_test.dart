import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities;
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/notification_permission.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/enable_notifications_page.dart';
import 'package:discourse_ui/views/widgets/forum_icon_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// The page that asks for notifications: a preview of what arrives under the
/// forum's icon, the two steps the button takes, and the button itself.
const _forum = 'https://community.example.com';

SiteContext _context() => SiteContext(
      siteType: 'discourse',
      site: Site(
        id: null,
        name: 'ABDA Community',
        url: _forum,
        description: '',
        logoUrl: null,
        backgroundUrl: null,
        endpoint: null,
        baseUrl: _forum,
        siteType: 'discourse',
        language: null,
      ),
    );

Widget _app({Brightness brightness = Brightness.light, double textScale = 1}) =>
    MaterialApp(
      theme: AppTheme.themeFor(brightness, null),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: EnableNotificationsPage(siteContext: _context()),
    );

void main() {
  setUp(() {
    DiscourseSiteCapabilities.reset();
    // Not asked yet, on every machine the tests run on.
    NotificationPermission.debugStatus =
        NotificationPermissionState.notDetermined;
  });
  tearDown(() => NotificationPermission.debugStatus = null);

  testWidgets('previews notifications under the forum and names both steps',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pump();

    expect(find.text('Never miss a reply on ABDA Community'), findsOneWidget);
    // Two sample notifications, each under the forum's own icon.
    expect(find.byType(ForumIconTile), findsNWidgets(2));
    expect(find.text('ABDA Community · now'), findsOneWidget);
    expect(find.text('Allow notifications on this phone'), findsOneWidget);
    expect(find.text('Approve on ABDA Community'), findsOneWidget);
    expect(find.textContaining('Read-only'), findsOneWidget);
    // The button says what it does, and appears with the title.
    expect(find.widgetWithText(FilledButton, 'Turn on notifications'),
        findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Not now'), findsOneWidget);
    // The owner footnote is gone: a user cannot act on it.
    expect(find.textContaining('owner'), findsNothing);
  });

  testWidgets(
      'when the phone already allows notifications, the first step '
      'says so', (tester) async {
    NotificationPermission.debugStatus = NotificationPermissionState.granted;
    await tester.pumpWidget(_app());
    await tester.pump();

    expect(
        find.text('Notifications are allowed on this phone'), findsOneWidget);
    expect(find.text('Allow notifications on this phone'), findsNothing);
    expect(find.text('Approve on ABDA Community'), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    testWidgets(
        'a small phone at 200% text scrolls rather than overflows '
        '(${brightness.name})', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(brightness: brightness, textScale: 2));
      await tester.pump();

      expect(tester.takeException(), isNull);
      // The buttons stay pinned below the scrolling explanation.
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  }
}
