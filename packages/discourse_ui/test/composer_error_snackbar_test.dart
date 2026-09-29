import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/utils/app_navigation.dart';
import 'package:discourse_ui/utils/snackbar_helper.dart';
import 'package:discourse_ui/views/widgets/message_compose_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/domain/site.dart';

/// When the forum refuses a new topic ("Title is too short (minimum is 15
/// characters)"), its reason shows, goes away on its own, and a second
/// refusal replaces the first. The error snackbar used to carry a "Dismiss"
/// action, which since Flutter 3.38 pins a snackbar until tapped: the first
/// reason never left, and each later one queued unseen behind it.
void main() {
  const titleTooShort = 'Title is too short (minimum is 15 characters)';
  const bodyTooShort = 'Body is too short (minimum is 20 characters)';

  Future<void> open(
    WidgetTester tester,
    Future<bool> Function(String, String) onSubmit,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigatorKey,
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: Text('Topics')),
    ));
    navigatorKey.currentState!.push<Object?>(FormPageRoute(
      builder: (_) => MessageComposePage(
        siteContext: _site(),
        title: 'New Topic',
        submitLabel: 'Create Topic',
        showTitleField: true,
        autoFocusContent: false,
        onSubmit: onSubmit,
      ),
    ));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Hi');
    await tester.enterText(find.byType(TextField).last, 'Short');
    await tester.pump();
  }

  Future<void> send(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Create Topic'));
    await tester.pumpAndSettle();
  }

  testWidgets('the forum\'s reason shows, then goes away by itself',
      (tester) async {
    await open(tester, (_, __) async => throw Exception(titleTooShort));
    await send(tester);

    expect(find.text(titleTooShort), findsOneWidget);
    expect(find.text('Exception: $titleTooShort'), findsNothing);
    expect(find.text('Dismiss'), findsNothing,
        reason: 'an action would pin the snackbar');

    await tester.pump(SnackbarHelper.readingTime(titleTooShort));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Hi'), findsOneWidget, reason: 'the composer stays');
  });

  testWidgets('a second refusal replaces the first at once', (tester) async {
    final reasons = [titleTooShort, bodyTooShort];
    await open(tester, (_, __) async => throw Exception(reasons.removeAt(0)));

    await send(tester);
    expect(find.text(titleTooShort), findsOneWidget);

    await send(tester);
    expect(find.text(bodyTooShort), findsOneWidget);
    expect(find.text(titleTooShort), findsNothing);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('the close button takes it down early', (tester) async {
    await open(tester, (_, __) async => throw Exception(titleTooShort));
    await send(tester);

    await tester.tap(find.descendant(
        of: find.byType(SnackBar), matching: find.byIcon(Icons.close)));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('a missing title says so once, however often Send is tapped',
      (tester) async {
    await open(tester, (_, __) async => true);
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump();

    await send(tester);
    await send(tester);
    await send(tester);
    expect(find.byType(SnackBar), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing,
        reason: 'no copies queued behind it');
  });

  test('a longer reason stays up longer, within 4–10 s', () {
    expect(SnackbarHelper.readingTime('Saved'), const Duration(seconds: 4));
    final both = '$titleTooShort; $bodyTooShort';
    expect(SnackbarHelper.readingTime(both),
        greaterThan(SnackbarHelper.readingTime(titleTooShort)));
    expect(SnackbarHelper.readingTime('x' * 500), const Duration(seconds: 10));
  });
}

SiteContext _site() => SiteContext(
      siteType: 'discourse',
      site: Site(
        id: null,
        name: 'Test',
        url: 'https://forum.example',
        description: '',
        endpoint: null,
        baseUrl: 'https://forum.example',
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'discourse',
      ),
    );
