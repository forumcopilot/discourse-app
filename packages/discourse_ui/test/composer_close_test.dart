import 'dart:async';

import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/utils/app_navigation.dart';
import 'package:discourse_ui/views/widgets/message_compose_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/domain/site.dart';

/// A composer is a full-screen form: it closes with ✕, asks before throwing
/// away what was written (Discourse's own question), cannot be closed while
/// it sends, and becomes the new topic once it has sent one. It used to
/// close with ← on any Back, without a word.
void main() {
  final navigatorKey = GlobalKey<NavigatorState>();

  Future<Future<Object?>> open(
    WidgetTester tester, {
    Future<bool> Function(String, String)? onSubmit,
    Future<void> Function()? onSaveDraft,
    Future<void> Function()? onDiscard,
    bool isEdit = false,
    Widget? Function()? pageAfterSubmit,
  }) async {
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigatorKey,
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: Text('Topic')),
    ));
    final closed = navigatorKey.currentState!.push<Object?>(FormPageRoute(
      builder: (_) => MessageComposePage(
        siteContext: _site(),
        title: 'Reply',
        submitLabel: 'Send',
        autoFocusContent: false,
        initialContent: isEdit ? 'The post' : null,
        isEdit: isEdit,
        onSubmit: onSubmit ?? (_, __) async => true,
        onSaveDraft: onSaveDraft,
        onDiscard: onDiscard,
        pageAfterSubmit: pageAfterSubmit,
      ),
    ));
    await tester.pumpAndSettle();
    return closed;
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField).last, text);
    await tester.pump();
  }

  testWidgets('✕ closes a composer with nothing written, without asking',
      (tester) async {
    await open(tester);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Topic'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('with writing, Back asks; Cancel keeps writing', (tester) async {
    var discarded = false;
    await open(tester, onDiscard: () async => discarded = true);
    await type(tester, 'Half a thought');

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Do you want to discard your post?'), findsOneWidget);
    expect(find.text('Save draft'), findsNothing); // no draft to keep it in
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Half a thought'), findsOneWidget);
    expect(discarded, isFalse);
  });

  testWidgets('Discard throws the writing away and closes', (tester) async {
    var discarded = false;
    await open(tester, onDiscard: () async => discarded = true);
    await type(tester, 'Half a thought');
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(discarded, isTrue);
    expect(find.text('Topic'), findsOneWidget);
  });

  testWidgets('Save draft keeps it and closes', (tester) async {
    var saved = false;
    await open(tester, onSaveDraft: () async => saved = true);
    await type(tester, 'For later');
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save draft'));
    await tester.pumpAndSettle();
    expect(saved, isTrue);
    expect(find.text('Topic'), findsOneWidget);
  });

  testWidgets('failed Save draft keeps writing visible and allows retry',
      (tester) async {
    var attempts = 0;
    await open(tester, onSaveDraft: () async {
      if (++attempts == 1) throw Exception('Draft limit reached');
    });
    await type(tester, 'Do not lose this');
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save draft'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Do not lose this'), findsOneWidget);
    expect(find.text('Draft limit reached'), findsOneWidget);
    await tester.tap(find.descendant(
        of: find.byType(AppBar), matching: find.byTooltip('Close')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save draft'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text('Topic'), findsOneWidget);
  });

  testWidgets('Back cannot start another close while a draft is saving',
      (tester) async {
    final saving = Completer<void>();
    await open(tester, onSaveDraft: () => saving.future);
    await type(tester, 'For later');
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save draft'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    final dialogs = find.byType(AlertDialog).evaluate().length;
    saving.complete();
    await tester.pumpAndSettle();
    expect(dialogs, 0);
    expect(find.text('Topic'), findsOneWidget);
  });

  testWidgets('an edit asks about "your changes"', (tester) async {
    await open(tester, isEdit: true);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing,
        reason: 'nothing changed yet');

    await open(tester, isEdit: true);
    await type(tester, 'The post, edited');
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Do you want to discard your changes?'), findsOneWidget);
    expect(find.text('Discard changes'), findsOneWidget);
  });

  testWidgets('while it sends, Back does nothing', (tester) async {
    final sending = Completer<bool>();
    await open(tester, onSubmit: (_, __) => sending.future);
    await type(tester, 'Sending this');
    await tester.tap(find.widgetWithText(FilledButton, 'Send'));
    await tester.pump();

    await tester.binding.handlePopRoute();
    // The spinner turns until the send answers: no settling meanwhile.
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Sending this'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    sending.complete(true);
    await tester.pumpAndSettle();
    expect(find.text('Topic'), findsOneWidget);
  });

  testWidgets('once sent, the new topic takes the composer\'s place',
      (tester) async {
    final closed = await open(tester,
        pageAfterSubmit: () => const Scaffold(body: Text('The new topic')));
    await type(tester, 'A new topic');
    await tester.tap(find.widgetWithText(FilledButton, 'Send'));
    await tester.pumpAndSettle();
    expect(find.text('The new topic'), findsOneWidget);
    expect(await closed, true);

    // Back goes to where the composer was opened from.
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.text('Topic'), findsOneWidget);
    expect(find.text('A new topic'), findsNothing);
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
