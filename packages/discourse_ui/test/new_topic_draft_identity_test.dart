import 'dart:async';

import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/new_topic_page.dart';
import 'package:discourse_ui/views/widgets/message_compose_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

void main() {
  late _Drafts drafts;
  late _Topics topics;
  late SiteContext site;
  const template = 'Describe the problem and steps to reproduce.';

  setUp(() {
    drafts = _Drafts();
    topics = _Topics();
    site = SiteContext(
        siteType: 'topic-identity-test',
        site: const Site(
            name: 'Test',
            url: 'https://identity.example',
            baseUrl: 'https://identity.example',
            description: '',
            siteType: 'topic-identity-test'));
    SiteProxyFactory.register('topic-identity-test', _Factory(drafts, topics));
    SiteProxyService.initialize(site);
    DiscourseSiteCapabilities.store(site.site.pluginUrl, {
      'top_menu_items': ['latest'],
      'categories': [
        {'id': 4, 'name': 'General'},
        {'id': 9, 'name': 'Bugs', 'topic_template': template},
      ],
    });
  });

  Future<void> open(WidgetTester tester,
      {String category = '4', String? key}) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: key == null
          ? NewTopicPage(
              siteContext: site, forumId: category, forumName: 'Category')
          : NewTopicPage(
              siteContext: site,
              forumId: category,
              forumName: 'Category',
              draftKey: key),
    ));
    await tester.pumpAndSettle();
  }

  MessageComposePage composer(WidgetTester tester) =>
      tester.widget<MessageComposePage>(find.byType(MessageComposePage));

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  testWidgets('new topic does not restore or overwrite the legacy global draft',
      (tester) async {
    drafts.data['new_topic'] = {
      'title': 'Old title',
      'reply': 'Old body',
      'categoryId': 9
    };
    await open(tester);
    expect(composer(tester).contentController!.text, isEmpty);
    expect(composer(tester).titleController!.text, isEmpty);
    composer(tester).titleController!.text = 'New title';
    composer(tester).contentController!.text = 'New body';
    await composer(tester).onSaveDraft!();
    final key = drafts.loads.single;
    expect(key, startsWith('new_topic_'));
    expect(drafts.data[key]!['categoryId'], 4);
    expect(drafts.data['new_topic']!['reply'], 'Old body');
    await close(tester);
  });

  for (final secondCategory in ['4', '9']) {
    testWidgets(
        'separate composers keep both drafts in category $secondCategory',
        (tester) async {
      await open(tester);
      composer(tester).titleController!.text = 'First title';
      composer(tester).contentController!.text = 'First body';
      await composer(tester).onSaveDraft!();
      final firstKey = drafts.loads.single;
      await close(tester);
      await open(tester, category: secondCategory);
      composer(tester).titleController!.text = 'Second title';
      composer(tester).contentController!.text = 'Second body';
      await composer(tester).onSaveDraft!();
      final secondKey = drafts.loads.last;
      expect(secondKey, isNot(firstKey));
      expect(drafts.data[firstKey]!['reply'], 'First body');
      expect(drafts.data[firstKey]!['categoryId'], 4);
      expect(drafts.data[secondKey]!['reply'], 'Second body');
      expect(drafts.data[secondKey]!['categoryId'], int.parse(secondCategory));
      await expectLater(
          composer(tester).onSubmit('Second title', 'Second body'),
          throwsA(isA<Exception>()));
      expect(topics.category, secondCategory);
      await close(tester);
    });
  }

  for (final key in ['new_topic', 'new_topic_123']) {
    testWidgets(
        'resuming $key preserves a deliberately empty body without a template',
        (tester) async {
      drafts.data[key] = {'title': 'Saved title', 'reply': '', 'categoryId': 9};
      await open(tester, category: '9', key: key);
      expect(drafts.loads, [key]);
      expect(composer(tester).contentController!.text, isEmpty);
      expect(composer(tester).titleController!.text, 'Saved title');
      expect(composer(tester).hasChanges!(), isFalse);
      composer(tester).titleController!.text = 'Updated title';
      await composer(tester).onSaveDraft!();
      expect(drafts.data[key]!['reply'], '');
      expect(drafts.data[key]!['categoryId'], 9);
      await close(tester);
    });
  }

  testWidgets(
      'fresh template is immediate and clearing it survives a delayed draft read',
      (tester) async {
    drafts.gate = Completer<void>();
    await open(tester, category: '9');
    expect(composer(tester).contentController!.text, template);
    composer(tester).contentController!.clear();
    composer(tester).titleController!.text = 'Title only';
    drafts.gate!.complete();
    await tester.pumpAndSettle();
    expect(composer(tester).contentController!.text, isEmpty);
    await composer(tester).onSaveDraft!();
    expect(drafts.data.values.single['reply'], '');
    await close(tester);
  });

  testWidgets(
      'template is available after a failed draft read and retry preserves edits',
      (tester) async {
    drafts.failLoad = true;
    await open(tester, category: '9');
    expect(composer(tester).contentController!.text, template);
    composer(tester).contentController!.text = 'Actual bug report';
    drafts.failLoad = false;
    await composer(tester).onSaveDraft!();
    expect(drafts.data.values.single['reply'], 'Actual bug report');
    await close(tester);
  });
}

class _Drafts implements IFCDraftProxy {
  final data = <String, Map<String, dynamic>>{};
  final loads = <String>[];
  Completer<void>? gate;
  bool failLoad = false;
  @override
  Future<FCLoadDraftResult> loadDraftAsync(String key) async {
    loads.add(key);
    await gate?.future;
    if (failLoad) {
      return FCLoadDraftResult(result: false, resultText: 'Read failed');
    }
    return FCLoadDraftResult(
        result: true,
        draft: data[key] == null
            ? null
            : FCDraft(draftKey: key, sequence: 5, data: data[key]!));
  }

  @override
  Future<FCSaveDraftResult> saveDraftAsync(
      {required String draftKey,
      required Map<String, dynamic> data,
      int sequence = 0}) async {
    this.data[draftKey] = Map.of(data);
    return FCSaveDraftResult(result: true, sequence: sequence + 1);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Topics implements IFCTopicProxy {
  String? category;
  @override
  Future<FCNewTopicResult> newTopic(
      String forumId, String subject, String textBody,
      {String? prefixId,
      List<String>? attachmentIds,
      String? groupId,
      List<String>? tags}) async {
    category = forumId;
    return FCNewTopicResult(
        result: false, resultText: 'Test refusal', topicId: '');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Factory implements SiteProxyFactory {
  _Factory(this.drafts, this.topics);
  final _Drafts drafts;
  final _Topics topics;
  @override
  IFCDraftProxy createDraftProxy(SiteContext context) => drafts;
  @override
  IFCTopicProxy createTopicProxy(SiteContext context) => topics;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
