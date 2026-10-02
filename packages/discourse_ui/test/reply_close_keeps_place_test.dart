import 'package:discourse_ui/controllers/post_controller.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/models/thread_view_data.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/widgets/post_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Closing a reply composer without posting leaves the topic where the
/// reader was. It used to reload the topic, which put them back at the top
/// of the loaded page: closing came back as "no result", and that was read
/// as a reply posted without an id.
SiteContext _ctx() => SiteContext(
      siteType: 'rq-test',
      site: Site(
        id: null,
        name: 'Test',
        url: 'https://forum.example',
        description: '',
        endpoint: null,
        baseUrl: 'https://forum.example',
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'rq-test',
      ),
    );

void main() {
  late _Posts posts;
  late PostActionsHandler handler;
  late List<String?> refreshes;

  setUp(() {
    posts = _Posts();
    SiteProxyFactory.register('rq-test', _Factory(posts, _Drafts()));
    SiteProxyService.initialize(_ctx());
    final controller = PostController();
    controller.threadDataOutput.value = ThreadViewData(
      topic: FCTopic(
        id: '7',
        title: 'Welcome',
        forumId: '3',
        forumName: '',
        authorId: '1',
        authorName: 'bob',
        timestamp: DateTime(2026, 10, 1),
        canReply: true,
      ),
      posts: const [],
      currentStartNum: 0,
      position: 1,
    );
    handler = PostActionsHandler(controller, _ctx());
    refreshes = [];
  });

  void onRefresh([String? scrollToPostId]) => refreshes.add(scrollToPostId);

  Future<void> open(WidgetTester tester, {required bool quote}) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => quote
                ? handler.handleQuote(
                    context, '11', 'bob', 'Hi', '7', 'Welcome', onRefresh)
                : handler.handleReply(context, '11', '7', 'Welcome', onRefresh),
            child: const Text('Topic'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Topic'));
    await tester.pumpAndSettle();
  }

  Future<void> closeAndDiscard(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Topic'), findsOneWidget);
  }

  testWidgets('Reply with Quote, then Discard: the topic is not reloaded',
      (tester) async {
    await open(tester, quote: true);
    expect(find.textContaining('[quote="bob, post:1, topic:7"]'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'Half a thought');
    await tester.pump();
    await closeAndDiscard(tester);
    expect(refreshes, isEmpty);
    expect(posts.replies, isEmpty);
  });

  testWidgets('Reply, then Discard: the topic is not reloaded', (tester) async {
    await open(tester, quote: false);
    await tester.enterText(find.byType(TextField).last, 'Half a thought');
    await tester.pump();
    await closeAndDiscard(tester);
    expect(refreshes, isEmpty);
  });

  testWidgets('Reply closed with nothing written: the topic is not reloaded',
      (tester) async {
    await open(tester, quote: false);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Topic'), findsOneWidget);
    expect(refreshes, isEmpty);
  });

  testWidgets('a quote reply that posts scrolls to the new post',
      (tester) async {
    await open(tester, quote: true);
    await tester.tap(find.widgetWithText(FilledButton, 'Reply'));
    await tester.pumpAndSettle();
    expect(posts.replies, hasLength(1));
    expect(refreshes, ['99']);
  });

  testWidgets('a reply that posts without an id still refreshes the topic',
      (tester) async {
    posts.newPostId = null;
    await open(tester, quote: false);
    await tester.enterText(find.byType(TextField).last, 'A reply');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Reply'));
    await tester.pumpAndSettle();
    expect(posts.replies, ['A reply']);
    expect(refreshes, [null]);
  });
}

class _Posts implements IFCPostProxy {
  final replies = <String>[];
  String? newPostId = '99';

  @override
  Future<FCQuotePostResult> getQuotePostAsync(String postId) async =>
      FCQuotePostResult(
          result: true,
          quoteContent: '[quote="bob, post:1, topic:7"]\nHi\n[/quote]\n\n');

  @override
  Future<FCReplyPostResult> replyPostAsync(
      String forumId,
      String topicId,
      String subject,
      String textBody,
      List<String>? attachmentIds,
      String? groupId,
      bool returnHtml) async {
    replies.add(textBody);
    return FCReplyPostResult(result: true, postId: newPostId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Drafts implements IFCDraftProxy {
  @override
  Future<FCLoadDraftResult> loadDraftAsync(String draftKey) async =>
      FCLoadDraftResult(result: true);

  @override
  Future<FCSaveDraftResult> saveDraftAsync({
    required String draftKey,
    required Map<String, dynamic> data,
    int sequence = 0,
  }) async =>
      FCSaveDraftResult(result: true, sequence: sequence + 1);

  @override
  Future<FCDeleteDraftResult> deleteDraftAsync(String draftKey,
          {int sequence = 0}) async =>
      FCDeleteDraftResult(result: true);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Factory implements SiteProxyFactory {
  _Factory(this.posts, this.drafts);
  final _Posts posts;
  final _Drafts drafts;

  @override
  IFCPostProxy createPostProxy(SiteContext context) => posts;

  @override
  IFCDraftProxy createDraftProxy(SiteContext context) => drafts;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
