import 'dart:async';

import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/new_topic_page.dart';
import 'package:discourse_ui/views/private_messaging/conversation/pages/new_conversation_page.dart';
import 'package:discourse_ui/views/widgets/message_compose_page.dart';
import 'package:discourse_ui/views/widgets/tag_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

void main() {
  late _Drafts drafts;
  late _Topics topics;
  late SiteContext site;

  setUp(() {
    drafts = _Drafts();
    topics = _Topics();
    site = SiteContext(
        siteType: 'tag-draft-test',
        site: const Site(
            name: 'Test',
            url: 'https://draft.example',
            baseUrl: 'https://draft.example',
            description: '',
            siteType: 'tag-draft-test'));
    SiteProxyFactory.register('tag-draft-test', _Factory(drafts, topics));
    SiteProxyService.initialize(site);
    DiscourseSiteCapabilities.store(site.site.pluginUrl, {
      'top_menu_items': ['latest'],
      'can_tag_topics': true,
      'can_create_tag': true
    });
  });

  Future<void> open(WidgetTester tester, {Widget? page}) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: page ??
          NewTopicPage(
              siteContext: site,
              forumId: '4',
              forumName: 'General',
              draftKey: 'new_topic_1'),
    ));
    await tester.pumpAndSettle();
  }

  MessageComposePage composer(WidgetTester tester) =>
      tester.widget<MessageComposePage>(find.byType(MessageComposePage));

  for (final tags in <List<Object>>[
    ['design', 'mobile'],
    [
      {'id': 9, 'name': 'design'},
      {'name': 'mobile'}
    ],
  ]) {
    testWidgets('restores and submits saved tags: $tags', (tester) async {
      drafts.data = {
        'reply': 'Draft body',
        'title': 'Draft title',
        'tags': tags
      };
      await open(tester);
      expect(find.widgetWithText(InputChip, 'design'), findsOneWidget);
      expect(find.widgetWithText(InputChip, 'mobile'), findsOneWidget);
      expect(composer(tester).hasChanges!(), isFalse);
      await expectLater(composer(tester).onSubmit('Draft title', 'Draft body'),
          throwsA(isA<Exception>()));
      expect(topics.tags, ['design', 'mobile']);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  }

  testWidgets('retrying a failed draft read restores tags before saving',
      (tester) async {
    drafts.loadError = 'Cannot load draft';
    drafts.data = {
      'reply': 'Server body',
      'title': 'Server title',
      'tags': ['design']
    };
    await open(tester);
    composer(tester).contentController!.text = 'New writing';
    drafts.loadError = null;
    await composer(tester).onSaveDraft!();
    await tester.pumpAndSettle();
    expect(drafts.saves.single['tags'], [
      {'name': 'design'}
    ]);
    expect(drafts.saves.single['reply'], 'New writing');
    expect(find.widgetWithText(InputChip, 'design'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('restoring message recipients does not clear early text changes',
      (tester) async {
    drafts.loadGate = Completer<void>();
    drafts.data = {
      'reply': 'Server body',
      'title': 'Server title',
      'recipients': 'alice'
    };
    await open(tester,
        page: NewConversationPage(
            siteContext: site, draftKey: 'new_private_message_1'));
    composer(tester).contentController!.text = 'New writing';
    drafts.loadGate!.complete();
    await tester.pumpAndSettle();
    expect(composer(tester).hasChanges!(), isTrue);
    await composer(tester).onSaveDraft!();
    expect(drafts.saves.single['recipients'], 'alice');
    expect(drafts.saves.single['reply'], 'New writing');
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('tag-only edits autosave, including removal of the last tag',
      (tester) async {
    drafts.data = {
      'reply': 'Draft body',
      'title': 'Draft title',
      'tags': ['design']
    };
    await open(tester);
    tester
        .widget<TagInputField>(find.byType(TagInputField))
        .onChanged!(['mobile']);
    await tester.pump(const Duration(seconds: 2));
    expect(drafts.saves.last['tags'], [
      {'name': 'mobile'}
    ]);
    expect(drafts.saves.last['categoryId'], 4);
    expect(composer(tester).hasChanges!(), isTrue);
    tester.widget<TagInputField>(find.byType(TagInputField)).onChanged!([]);
    await tester.pump(const Duration(seconds: 2));
    expect(drafts.saves.last['tags'], isEmpty);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('late restore keeps tags already changed by the writer',
      (tester) async {
    drafts.loadGate = Completer<void>();
    drafts.data = {
      'reply': 'Draft body',
      'title': 'Draft title',
      'tags': ['old']
    };
    await open(tester);
    tester
        .widget<TagInputField>(find.byType(TagInputField))
        .onChanged!(['new']);
    drafts.loadGate!.complete();
    await tester.pumpAndSettle();
    await composer(tester).onSaveDraft!();
    expect(drafts.saves.last['tags'], [
      {'name': 'new'}
    ]);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets(
      'late restore updates chips without clearing uncommitted tag input',
      (tester) async {
    drafts.loadGate = Completer<void>();
    drafts.data = {
      'reply': 'Draft body',
      'title': 'Draft title',
      'tags': ['design']
    };
    await open(tester);
    final field = find.descendant(
        of: find.byType(TagInputField), matching: find.byType(TextField));
    await tester.enterText(field, 'mob');
    drafts.loadGate!.complete();
    await tester.pumpAndSettle();
    expect(find.widgetWithText(InputChip, 'design'), findsOneWidget);
    expect(tester.widget<TextField>(field).controller!.text, 'mob');
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}

class _Drafts implements IFCDraftProxy {
  Map<String, dynamic> data = {};
  Completer<void>? loadGate;
  String? loadError;
  final saves = <Map<String, dynamic>>[];
  @override
  Future<FCLoadDraftResult> loadDraftAsync(String key) async {
    await loadGate?.future;
    if (loadError != null) {
      return FCLoadDraftResult(result: false, resultText: loadError);
    }
    return FCLoadDraftResult(
        result: true, draft: FCDraft(draftKey: key, sequence: 5, data: data));
  }

  @override
  Future<FCSaveDraftResult> saveDraftAsync(
      {required String draftKey,
      required Map<String, dynamic> data,
      int sequence = 0}) async {
    saves.add(data);
    return FCSaveDraftResult(result: true, sequence: sequence + 1);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Topics implements IFCTopicProxy {
  List<String>? tags;
  @override
  Future<FCNewTopicResult> newTopic(
      String forumId, String subject, String textBody,
      {String? prefixId,
      List<String>? attachmentIds,
      String? groupId,
      List<String>? tags}) async {
    this.tags = tags;
    return FCNewTopicResult(
        result: false, resultText: 'Test refusal', topicId: '');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Tags implements IFCTagProxy {
  @override
  Future<FCTagSearchResult> searchTagsAsync(String query,
          {int limit = 10}) async =>
      FCTagSearchResult(result: true, names: []);
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
  IFCTagProxy createTagProxy(SiteContext context) => _Tags();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
