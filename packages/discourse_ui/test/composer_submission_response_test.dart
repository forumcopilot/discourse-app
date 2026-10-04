import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/new_topic_page.dart';
import 'package:discourse_ui/views/post_page.dart';
import 'package:discourse_ui/views/private_messaging/conversation/pages/new_conversation_page.dart';
import 'package:discourse_ui/views/reply_page.dart';
import 'package:discourse_ui/views/widgets/message_compose_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

const unconfirmed =
    "We couldn't confirm that this was sent. Your text has been kept. Check the forum before trying again.";

void main() {
  late SiteContext site;
  late _Drafts drafts;
  late _Responses responses;
  late GlobalKey<NavigatorState> navigator;
  String? createdTopic;

  setUp(() {
    drafts = _Drafts();
    responses = _Responses();
    navigator = GlobalKey<NavigatorState>();
    createdTopic = null;
    site = SiteContext(
        siteType: 'submission-test',
        site: const Site(
          name: 'Test',
          url: 'https://submission.example',
          baseUrl: 'https://submission.example',
          description: '',
          siteType: 'submission-test',
        ))
      ..setLoginData(FCLoginResult(
          result: true,
          resultText: '',
          user: FCUser(id: '2', username: 'writer', canModerate: true)));
    SiteProxyFactory.register('submission-test', _Factory(drafts, responses));
    SiteProxyService.initialize(site);
  });

  MessageComposePage composer(WidgetTester tester) =>
      tester.widget<MessageComposePage>(find.byType(MessageComposePage));

  Future<void> open(WidgetTester tester, String kind) async {
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigator,
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: Text('Home')),
    ));
    final Widget page = switch (kind) {
      'topic' => NewTopicPage(
          siteContext: site,
          forumId: '4',
          forumName: 'General',
          onTopicCreated: (id, _) => createdTopic = id),
      'message' =>
        NewConversationPage(siteContext: site, initialRecipient: 'alice'),
      _ => ReplyPage(
          siteContext: site, threadId: '42', topicTitle: 'Existing topic'),
    };
    navigator.currentState!.push(MaterialPageRoute<void>(builder: (_) => page));
    await tester.pumpAndSettle();
    if (kind == 'whisper') {
      composer(tester).onWhisperChanged!(true);
      await tester.pump();
    }
    composer(tester).titleController!.text = 'A useful title';
    composer(tester).contentController!.text = 'Writing to preserve';
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  for (final kind in ['topic', 'reply', 'whisper', 'message']) {
    for (final id in [null, '', 0, 'not-an-id']) {
      testWidgets('$kind preserves writing after an unconfirmed ID: $id',
          (tester) async {
        responses.data = {
          if (id != null) 'id': id,
          if (id != null) 'topic_id': id
        };
        await open(tester, kind);
        await expectLater(
            composer(tester).onSubmit('A useful title', 'Writing to preserve'),
            throwsA(predicate((e) => e.toString().contains(unconfirmed))));
        expect(responses.calls, 1);
        expect(drafts.deletes, 0);
        expect(createdTopic, isNull);
        expect(composer(tester).contentController!.text, 'Writing to preserve');
        await composer(tester).onSaveDraft!();
        expect(drafts.saves.last['reply'], 'Writing to preserve');
        await close(tester);
      });
    }

    testWidgets('$kind accepts a confirmed ID and clears its draft',
        (tester) async {
      responses.data = {'id': 101, 'topic_id': 42};
      await open(tester, kind);
      expect(
          await composer(tester)
              .onSubmit('A useful title', 'Writing to preserve'),
          isTrue);
      expect(responses.calls, 1);
      expect(responses.path, '/posts.json');
      expect(responses.body!['raw'], 'Writing to preserve');
      if (kind == 'topic') {
        expect(responses.body!['category'], 4);
        expect(responses.body!['title'], 'A useful title');
        expect(responses.body!['archetype'], 'regular');
      } else if (kind == 'message') {
        expect(responses.body!['target_recipients'], 'alice');
        expect(responses.body!['archetype'], 'private_message');
      } else {
        expect(responses.body!['topic_id'], 42);
        expect(responses.body!['whisper'], kind == 'whisper' ? 'true' : null);
      }
      expect(drafts.deletes, 1);
      if (kind == 'topic') expect(createdTopic, '42');
      if (kind == 'topic' || kind == 'message') {
        expect(composer(tester).pageAfterSubmit!(), isA<PostPage>());
      } else {
        expect(composer(tester).onSuccess!(true), '101');
      }
      await close(tester);
      expect(drafts.saves, isEmpty);
    });
  }

  for (final kind in ['topic', 'reply', 'whisper']) {
    testWidgets('$kind queued for approval is accepted without a published ID',
        (tester) async {
      responses.data = {
        'action': 'enqueued',
        'pending_post': {'id': 9},
        'pending_count': 1
      };
      await open(tester, kind);
      final sending =
          composer(tester).onSubmit('A useful title', 'Writing to preserve');
      await tester.pumpAndSettle();
      expect(find.text('Post Needs Approval'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(await sending, isTrue);
      expect(drafts.deletes, 1);
      expect(createdTopic, isNull);
      if (kind == 'topic') {
        expect(composer(tester).pageAfterSubmit!(), isNull);
      } else {
        expect(composer(tester).onSuccess!(true), isNull);
      }
      await close(tester);
    });
  }

  testWidgets('Send shows an uncertainty notice and leaves the editor open',
      (tester) async {
    await open(tester, 'reply');
    await tester.tap(find.widgetWithText(FilledButton, 'Reply'));
    await tester.pumpAndSettle();
    expect(find.byType(MessageComposePage), findsOneWidget);
    expect(find.text(unconfirmed), findsOneWidget);
    expect(responses.calls, 1, reason: 'do not automatically resubmit');
    expect(drafts.deletes, 0);
    await close(tester);
  });
}

class _Responses {
  Map<String, dynamic> data = {};
  int calls = 0;
  String? path;
  Map<String, dynamic>? body;
  Future<Map<String, dynamic>> post(String path, Object? body) async {
    calls++;
    this.path = path;
    this.body = body as Map<String, dynamic>;
    return data;
  }
}

class _Topics extends DiscourseTopicProxy {
  _Topics(super.context, this.responses);
  final _Responses responses;
  @override
  Future<Map<String, dynamic>> apiPost(String path,
          {Map<String, dynamic>? query, Object? body}) =>
      responses.post(path, body);
}

class _Posts extends DiscoursePostProxy {
  _Posts(super.context, this.responses);
  final _Responses responses;
  @override
  Future<Map<String, dynamic>> apiPost(String path,
          {Map<String, dynamic>? query, Object? body}) =>
      responses.post(path, body);
}

class _Conversations extends DiscoursePrivateConversationProxy {
  _Conversations(super.context, this.responses);
  final _Responses responses;
  @override
  Future<Map<String, dynamic>> apiPost(String path,
          {Map<String, dynamic>? query, Object? body}) =>
      responses.post(path, body);
}

class _Drafts implements IFCDraftProxy {
  int deletes = 0;
  final saves = <Map<String, dynamic>>[];
  @override
  Future<FCLoadDraftResult> loadDraftAsync(String key) async =>
      FCLoadDraftResult(result: true);
  @override
  Future<FCSaveDraftResult> saveDraftAsync(
      {required String draftKey,
      required Map<String, dynamic> data,
      int sequence = 0}) async {
    saves.add(data);
    return FCSaveDraftResult(result: true, sequence: sequence + 1);
  }

  @override
  Future<FCDeleteDraftResult> deleteDraftAsync(String key,
      {int sequence = 0}) async {
    deletes++;
    return FCDeleteDraftResult(result: true);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Factory implements SiteProxyFactory {
  _Factory(this.drafts, this.responses);
  final _Drafts drafts;
  final _Responses responses;
  @override
  IFCDraftProxy createDraftProxy(SiteContext context) => drafts;
  @override
  IFCTopicProxy createTopicProxy(SiteContext context) =>
      _Topics(context, responses);
  @override
  IFCPostProxy createPostProxy(SiteContext context) =>
      _Posts(context, responses);
  @override
  IFCPrivateConversationProxy createPrivateConversationProxy(
          SiteContext context) =>
      _Conversations(context, responses);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
