import 'dart:async';

import 'package:discourse_core/discourse_core.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/drafts_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

void main() {
  late _Drafts drafts;
  late SiteContext site;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
            (_) async => null);
    drafts = _Drafts();
    site = SiteContext(
        siteType: 'draft-list-test',
        site: const Site(
          name: 'Test',
          url: 'https://drafts.example',
          baseUrl: 'https://drafts.example',
          description: '',
          siteType: 'draft-list-test',
        ));
    await site.setUserApiCredentials(
        userApiKey: 'first', userApiClientId: 'first');
    SiteProxyFactory.register('draft-list-test', _Factory(drafts));
    SiteProxyService.initialize(site);
  });

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: DraftsListPage(siteContext: site),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> discard(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Discard').first);
    await tester.pumpAndSettle();
  }

  Future<void> expireUndo(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  }

  Future<void> loadMore(WidgetTester tester,
      {String label = 'Load more'}) async {
    await tester.scrollUntilVisible(find.text(label), 500, maxScrolls: 40);
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  Future<void> refresh(WidgetTester tester) => tester
      .widget<RefreshIndicator>(find.byType(RefreshIndicator))
      .onRefresh();

  Future<void> switchAccount() => site.setUserApiCredentials(
      userApiKey: 'second', userApiClientId: 'second');

  void expectStaleScreen() {
    expect(find.text('Draft 0'), findsNothing);
    expect(find.text('Your sign-in changed. Reopen this screen to continue.'),
        findsOneWidget);
  }

  for (final action in ['timeout', 'undo', 'refresh', 'discard', 'resume']) {
    testWidgets('$action after account change cannot reuse old drafts',
        (tester) async {
      await open(tester);
      if (action == 'timeout' || action == 'undo') await discard(tester);
      await switchAccount();
      switch (action) {
        case 'timeout':
          await expireUndo(tester);
        case 'undo':
          await tester.tap(find.text('Undo'));
          await tester.pumpAndSettle();
        case 'refresh':
          await refresh(tester);
          await tester.pumpAndSettle();
        case 'discard':
          await discard(tester);
          await expireUndo(tester);
        case 'resume':
          await tester.tap(find.text('Draft 0'));
          await tester.pumpAndSettle();
      }
      expect(drafts.deleted, isEmpty);
      expect(drafts.pages, [0]);
      expectStaleScreen();
    });
  }

  for (final success in [true, false]) {
    testWidgets('late refresh $success cannot show the old account drafts',
        (tester) async {
      await open(tester);
      final gate = Completer<FCDraftListResult>();
      drafts.nextResult = gate;
      final pending = refresh(tester);
      await switchAccount();
      gate.complete(FCDraftListResult(
          result: success,
          total: 1,
          items: [_draft(0)],
          resultText: 'Old error'));
      await pending;
      await tester.pumpAndSettle();
      expectStaleScreen();
      expect(find.text('Old error'), findsNothing);
    });
    testWidgets('late delete $success cannot reload or restore old drafts',
        (tester) async {
      await open(tester);
      final gate = Completer<FCDeleteDraftResult>();
      drafts.deleteGate = gate;
      await discard(tester);
      await expireUndo(tester);
      expect(drafts.deleted, ['new_topic_0']);
      await switchAccount();
      gate.complete(
          FCDeleteDraftResult(result: success, resultText: 'Old error'));
      await tester.pumpAndSettle();
      expect(drafts.pages, [0]);
      expectStaleScreen();
      expect(find.text('Old error'), findsNothing);
    });
  }

  for (final changeAccount in [false, true]) {
    testWidgets(
        'pending delete after page disposal, account changed: $changeAccount',
        (tester) async {
      // Keep the messenger alive while removing only the page.
      final showDrafts = ValueNotifier(true);
      addTearDown(showDrafts.dispose);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ValueListenableBuilder<bool>(
          valueListenable: showDrafts,
          builder: (_, visible, __) => visible
              ? DraftsListPage(siteContext: site)
              : const Scaffold(body: Text('Away')),
        ),
      ));
      await tester.pumpAndSettle();
      await discard(tester);
      showDrafts.value = false;
      await tester.pump();
      if (changeAccount) await switchAccount();
      await expireUndo(tester);
      expect(drafts.deleted, changeAccount ? isEmpty : ['new_topic_0']);
      expect(drafts.pages, [0]);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'a delete that fails after the reader left the page still says so',
      (tester) async {
    final showDrafts = ValueNotifier(true);
    addTearDown(showDrafts.dispose);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ValueListenableBuilder<bool>(
        valueListenable: showDrafts,
        builder: (_, visible, __) => visible
            ? DraftsListPage(siteContext: site)
            : const Scaffold(body: Text('Away')),
      ),
    ));
    await tester.pumpAndSettle();
    drafts.deleteError = 'Delete unavailable';
    await discard(tester);
    showDrafts.value = false;
    await tester.pump();
    await expireUndo(tester);
    expect(drafts.deleted, ['new_topic_0']);
    expect(
        find.text(
            "Draft not discarded. It's still in Drafts. Delete unavailable"),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'older drafts load beyond the first 50 and stop after a short page',
      (tester) async {
    drafts.items = List.generate(55, _draft);
    await open(tester);
    await loadMore(tester);
    expect(drafts.pages, [0, 1]);
    await tester.scrollUntilVisible(find.text('Draft 54'), 500);
    expect(find.text('Draft 54'), findsOneWidget);
    expect(find.text('Load more'), findsNothing);
  });

  testWidgets(
      'failed next page retries the same offset without losing loaded drafts',
      (tester) async {
    drafts.items = List.generate(51, _draft);
    drafts.errors[1] = 'Next page unavailable';
    await open(tester);
    await loadMore(tester);
    expect(find.text('Next page unavailable'), findsOneWidget);
    drafts.errors.clear();
    await loadMore(tester, label: 'Retry');
    expect(drafts.pages, [0, 1, 1]);
    await tester.scrollUntilVisible(find.text('Draft 50'), 500);
    expect(find.text('Draft 50'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Draft 0'), -500, maxScrolls: 40);
    expect(find.text('Draft 0'), findsOneWidget);
  });

  testWidgets('refresh failure retains visible drafts and offers retry',
      (tester) async {
    await open(tester);
    drafts.errors[0] = 'Refresh unavailable';
    await refresh(tester);
    await tester.pumpAndSettle();
    expect(find.text('Draft 0'), findsOneWidget);
    expect(find.text('Refresh unavailable'), findsOneWidget);
    drafts.errors.clear();
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Refresh unavailable'), findsNothing);
    expect(find.text('Draft 0'), findsOneWidget);
  });

  testWidgets('refresh errors are visible above a long retained list',
      (tester) async {
    drafts.items = List.generate(50, _draft);
    await open(tester);
    drafts.errors[0] = 'Refresh unavailable';
    await refresh(tester);
    await tester.pumpAndSettle();
    expect(find.text('Draft 0'), findsOneWidget);
    expect(find.text('Refresh unavailable'), findsOneWidget);
    expect(find.text('Retry').hitTestable(), findsOneWidget);
  });

  testWidgets(
      'delayed discard keeps the original forum proxy after switching forums',
      (tester) async {
    await open(tester);
    await discard(tester);
    final other = _Drafts();
    SiteProxyFactory.register('draft-list-test', _Factory(other));
    SiteProxyService.initialize(SiteContext(
        siteType: 'draft-list-test',
        site: const Site(
          name: 'Other',
          url: 'https://other.example',
          baseUrl: 'https://other.example',
          description: '',
          siteType: 'draft-list-test',
        )));
    await expireUndo(tester);
    expect(drafts.deleted, ['new_topic_0']);
    expect(other.deleted, isEmpty);
    expect(other.pages, isEmpty);
  });

  for (final throwsError in [false, true]) {
    testWidgets(
        'discard ${throwsError ? "exception" : "refusal"} restores the draft and shows the reason',
        (tester) async {
      drafts.deleteError = 'Delete unavailable';
      drafts.throwDelete = throwsError;
      await open(tester);
      await discard(tester);
      await expireUndo(tester);
      expect(find.text('Draft 0'), findsOneWidget);
      expect(find.text('Delete unavailable'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'refresh while Undo is available keeps pending deletion hidden and Undo restores it once',
      (tester) async {
    await open(tester);
    await discard(tester);
    await refresh(tester);
    await tester.pumpAndSettle();
    expect(find.text('Draft 0'), findsNothing);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Draft 0'), findsOneWidget);
    expect(drafts.deleted, isEmpty);
  });

  testWidgets('a late refresh cannot replace a newer response', (tester) async {
    await open(tester);
    final old = Completer<FCDraftListResult>();
    drafts.nextResult = old;
    final first = refresh(tester);
    drafts.items = [_draft(9)];
    await refresh(tester);
    old.complete(FCDraftListResult(result: true, total: 1, items: [_draft(0)]));
    await first;
    await tester.pumpAndSettle();
    expect(find.text('Draft 9'), findsOneWidget);
    expect(find.text('Draft 0'), findsNothing);
  });

  testWidgets(
      'successful delete resets pagination so shifted offsets do not skip a draft',
      (tester) async {
    drafts.items = List.generate(55, _draft);
    await open(tester);
    await discard(tester);
    await expireUndo(tester);
    expect(drafts.pages, [0, 0]);
    await loadMore(tester);
    expect(drafts.pages, [0, 0, 1]);
    await tester.scrollUntilVisible(find.text('Draft 54'), 500);
    expect(find.text('Draft 54'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Draft 50'), -500);
    expect(find.text('Draft 50'), findsOneWidget);
  });
}

FCDraft _draft(int i) => FCDraft(
    draftKey: 'new_topic_$i',
    sequence: 3,
    data: {'title': 'Draft $i', 'reply': 'Body $i'});

class _Drafts implements IFCDraftProxy {
  List<FCDraft> items = [_draft(0)];
  final pages = <int>[];
  final errors = <int, String>{};
  final deleted = <String>[];
  String? deleteError;
  bool throwDelete = false;
  Completer<FCDraftListResult>? nextResult;
  Completer<FCDeleteDraftResult>? deleteGate;

  @override
  Future<FCDraftListResult> getMyDraftsAsync({int page = 0}) async {
    pages.add(page);
    final held = nextResult;
    nextResult = null;
    if (held != null) return held.future;
    final error = errors[page];
    final result = items.skip(page * 50).take(50).toList();
    return FCDraftListResult(
        result: error == null,
        resultText: error,
        total: result.length,
        items: error == null ? result : []);
  }

  @override
  Future<FCDeleteDraftResult> deleteDraftAsync(String key,
      {int sequence = 0}) async {
    deleted.add(key);
    if (deleteGate != null) return deleteGate!.future;
    if (throwDelete) throw Exception(deleteError);
    if (deleteError == null) items.removeWhere((d) => d.draftKey == key);
    return FCDeleteDraftResult(
        result: deleteError == null, resultText: deleteError);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Factory implements SiteProxyFactory {
  _Factory(this.drafts);
  final _Drafts drafts;
  @override
  IFCDraftProxy createDraftProxy(SiteContext context) => drafts;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
