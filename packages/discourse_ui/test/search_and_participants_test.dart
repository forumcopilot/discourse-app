import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/private_messaging/message_participants_sheet.dart';
import 'package:discourse_ui/views/search_page.dart';
import 'package:discourse_ui/views/listitems/topic_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A post found by search shows its topic's state, as the topic rows do;
/// and taking someone off a message says so when it fails.
const _site = 'https://search.example';

SiteContext _ctx() => SiteContext(
      siteType: 'sp-test',
      configDataOutput: FCConfigResult(),
      site: Site(
        id: null,
        name: 'Test',
        url: _site,
        description: '',
        endpoint: null,
        baseUrl: _site,
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'sp-test',
      ),
    )..setLoginData(FCLoginResult(
        result: true, resultText: '', user: FCUser(id: '2', username: 'alice')));

final _searchJson = {
  'posts': [
    {'id': 501, 'topic_id': 27, 'post_number': 1, 'username': 'bob', 'blurb': 'Leaving it up but locking it', 'created_at': '2026-05-10T13:15:00Z'},
    {'id': 502, 'topic_id': 77, 'post_number': 4, 'username': 'carol', 'blurb': 'This fixed it for me', 'created_at': '2026-05-11T13:15:00Z'},
  ],
  'topics': [
    {'id': 27, 'title': 'Old thread — closed for historical reference', 'closed': true, 'category_id': 3, 'posts_count': 3},
    {'id': 77, 'title': 'Upload fails on Android', 'has_accepted_answer': true, 'category_id': 3, 'posts_count': 6},
  ],
  'grouped_search_result': {'more_posts': false},
};

void main() {
  late _Proxies proxies;
  setUp(() {
    // The search history the page saves each query to.
    SharedPreferences.setMockInitialValues({});
    proxies = _Proxies(_ctx());
    SiteProxyFactory.register('sp-test', _Factory(proxies));
    SiteProxyService.initialize(_ctx());
  });

  testWidgets("a post found by search shows its topic's Closed and Solved",
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SearchPage(siteContext: _ctx(), initialQuery: 'locking'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Leaving it up but locking it', findRichText: true), findsWidgets);
    // On the post's own row, which said nothing of its topic before.
    Finder rowOf(String text) => find.ancestor(
        of: find.text(text, findRichText: true), matching: find.byType(TopicListItem));
    expect(
        find.descendant(
            of: rowOf('Leaving it up but locking it'), matching: find.text('Closed')),
        findsOneWidget);
    expect(
        find.descendant(
            of: rowOf('This fixed it for me'), matching: find.text('Solved')),
        findsOneWidget);
  });

  testWidgets('a removal that fails says so, not "Error inviting user"',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => MessageParticipantsSheet.show(
              context,
              [
                FCParticipant(userId: '2', username: 'alice'),
                FCParticipant(userId: '3', username: 'bob'),
              ],
              _ctx(),
              conversationId: '9',
              canRemove: true,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.person_remove_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
    await tester.pumpAndSettle();
    expect(proxies.removed, ['bob']);
    expect(find.text("Couldn't remove bob from this message."), findsOneWidget);
    expect(find.textContaining('inviting'), findsNothing);
  });
}

class _Proxies {
  _Proxies(SiteContext ctx)
      : search = _Search(ctx),
        conversations = _Conversations(ctx);
  final _Search search;
  final _Conversations conversations;
  List<String> get removed => conversations.removed;
}

class _Search extends DiscourseSearchProxy {
  _Search(super.context);
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      path.startsWith('/search') ? _searchJson : const {};
}

class _Conversations extends DiscoursePrivateConversationProxy {
  _Conversations(super.context);
  final removed = <String>[];
  @override
  Future<FCLeaveConversationResult> removeParticipantAsync(
      String conversationId, String username) async {
    removed.add(username);
    return FCLeaveConversationResult(result: false, resultText: '');
  }
}

class _Factory implements SiteProxyFactory {
  _Factory(this.proxies);
  final _Proxies proxies;

  @override
  IFCSearchProxy createSearchProxy(SiteContext context) => proxies.search;

  @override
  IFCPrivateConversationProxy createPrivateConversationProxy(SiteContext context) =>
      proxies.conversations;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
