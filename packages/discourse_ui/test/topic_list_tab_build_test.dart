import 'dart:async';

import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/views/tabs/topic_list_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:get/get.dart';

/// Home's lists are built under the tab, and report back to it as they
/// load: none of that may mark the tab dirty while it is being built.
void main() {
  const forum = 'https://forum.example';
  final ctx = SiteContext(
    siteType: 'topic-list-tab-test',
    site: Site(
      id: null,
      name: 'Test',
      url: forum,
      description: '',
      endpoint: null,
      baseUrl: forum,
      logoUrl: null,
      backgroundUrl: null,
      siteType: 'topic-list-tab-test',
    ),
  );

  // Made in each test body, not in setUp: a Completer from outside the
  // test's fake-async zone completes where pump() never flushes.
  late Completer<FCForumDataResult> categories;

  setUp(() {
    SiteProxyFactory.register(
        'topic-list-tab-test', _Factory(() => categories.future));
    SiteProxyService.initialize(ctx);
  });

  tearDown(Get.reset);

  Widget app({HomeView? initialView}) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TopicListTab(
            siteContext: ctx,
            isActive: true,
            showMasthead: false,
            initialView: initialView,
          ),
        ),
      );

  testWidgets('mounting the tab (its lists start loading) builds cleanly',
      (tester) async {
    categories = Completer();
    await tester.pumpWidget(app());
    expect(tester.takeException(), isNull);

    // The categories arrive and the tab redraws from them.
    categories.complete(FCForumDataResult(result: true, resultText: ''));
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('opened on Categories, the view shows once they load',
      (tester) async {
    categories = Completer();
    await tester.pumpWidget(app(initialView: HomeView.categories));
    expect(tester.takeException(), isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    categories.complete(FCForumDataResult(result: true, resultText: ''));
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}

class _Factory implements SiteProxyFactory {
  _Factory(this.categories);

  final Future<FCForumDataResult> Function() categories;

  @override
  IFCForumProxy createForumProxy(SiteContext context) => _Forums(categories);

  @override
  IFCTopicProxy createTopicProxy(SiteContext context) => _Topics();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Forums implements IFCForumProxy {
  _Forums(this.categories);

  final Future<FCForumDataResult> Function() categories;

  @override
  Future<FCForumDataResult> getForumAsync(
          bool returnDescription, String forumId, bool forceRefresh) =>
      categories();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Topics implements IFCTopicProxy {
  @override
  Future<FCLatestTopicResult> getLatestTopicAsync(int startNum, int lastNum,
          {String? searchId, List<String>? filters}) async =>
      FCLatestTopicResult(
          result: true, resultText: '', totalLatestNum: 0, topics: []);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
