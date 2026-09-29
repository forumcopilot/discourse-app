import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/listitems/topic_list_item.dart';
import 'package:discourse_ui/views/widgets/user_avatar.dart';
import 'package:discourse_ui/views/widgets/suggested_topics_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// The section under a topic's last post: Discourse's suggested topics and
/// its related ones, as the topic lists' own rows.
void main() {
  const forum = 'https://forum.example';
  final ctx = SiteContext(
    siteType: 'more-test',
    site: Site(
      id: null,
      name: 'Test',
      url: forum,
      description: '',
      endpoint: null,
      baseUrl: forum,
      logoUrl: null,
      backgroundUrl: null,
      siteType: 'more-test',
    ),
  );

  Map<String, dynamic> listed(int id) => {
        'id': id,
        'title': 'Topic $id',
        'posts_count': 3,
        'category_id': 4,
        'created_at': '2026-09-20T10:00:00Z',
        'last_posted_at': '2026-09-28T10:00:00Z',
        'posters': [
          {
            'extras': 'latest single',
            'user': {'id': 14, 'username': 'demo2', 'avatar_template': ''},
          },
        ],
      };

  setUp(() {
    DiscourseMoreTopics.clear();
    SiteProxyFactory.register('more-test', _Factory());
    SiteProxyService.initialize(ctx);
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: SuggestedTopicsCard(siteContext: ctx, topicId: '26'),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('both lists: a Related | Suggested choice over list rows',
      (tester) async {
    DiscourseMoreTopics.storeFrom(forum, '26', {
      'suggested_topics': [listed(31), listed(32)],
      'related_topics': [listed(41)],
    });
    await pump(tester);

    expect(find.widgetWithText(ChoiceChip, 'Related Topics'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Suggested Topics'), findsOneWidget);
    expect(find.byType(TopicListItem), findsOneWidget, reason: 'related first');
    expect(find.text('Topic 41'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Suggested Topics'));
    await tester.pumpAndSettle();
    expect(find.byType(TopicListItem), findsNWidgets(2));
    expect(find.text('Topic 31'), findsOneWidget);
  });

  testWidgets('one list: its heading, and a way on to the latest topics',
      (tester) async {
    DiscourseMoreTopics.storeFrom(forum, '26', {
      'suggested_topics': [listed(31)],
    });
    await pump(tester);

    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.text('Suggested Topics'), findsOneWidget);
    expect(find.text('Topic 31'), findsOneWidget);
    expect(tester.widget<UserAvatar>(find.byType(UserAvatar)).username, 'demo2',
        reason: 'the poster, not a placeholder glyph');
    expect(find.textContaining('demo2', findRichText: true), findsWidgets);
    expect(find.widgetWithText(OutlinedButton, 'Latest topics'), findsOneWidget);
  });

  testWidgets('nothing to suggest draws nothing', (tester) async {
    DiscourseMoreTopics.storeFrom(forum, '26', {'suggested_topics': []});
    await pump(tester);
    expect(tester.getSize(find.byType(SuggestedTopicsCard)).height, 0);
  });
}

class _Topics extends DiscourseTopicProxy {
  _Topics(super.context);
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      path == '/categories.json'
          ? {
              'category_list': {
                'categories': [
                  {'id': 4, 'name': 'General'},
                ],
              },
            }
          : const {};
}

class _Factory implements SiteProxyFactory {
  @override
  IFCTopicProxy createTopicProxy(SiteContext context) => _Topics(context);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
