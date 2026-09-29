import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/utils/markdown_preview.dart';
import 'package:discourse_ui/views/my_posts_page.dart';
import 'package:discourse_ui/views/widgets/activity_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// My posts: the signed-in reader's own activity, as web's sidebar link
/// opens it, instead of their whole profile.
void main() {
  group('markdown preview', () {
    test('keeps the words, drops the syntax', () {
      expect(
        markdownPreviewText(
            '[quote="bob, post:3"]\nold words\n[/quote]\n**Bold** idea: see '
            '[the docs](https://x.example) ![shot|690x388](upload://a.png)\n'
            '> quoted line\n- item one'),
        'Bold idea: see the docs [image] item one',
      );
    });

    test('snake_case and a lone star survive', () {
      expect(markdownPreviewText('my_var * 2 is _fine_'), 'my_var * 2 is fine');
    });
  });

  group('page', () {
    late _Users users;
    late _Topics topics;
    late _Drafts drafts;
    final ctx = SiteContext(
      siteType: 'myposts-test',
      site: Site(
        id: null,
        name: 'Test',
        url: 'https://forum.example',
        description: '',
        endpoint: null,
        baseUrl: 'https://forum.example',
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'myposts-test',
      ),
    )..setLoginData(FCLoginResult(
        result: true,
        resultText: '',
        user: FCUser(id: '2', username: 'tung'),
      ));

    Map<String, dynamic> action(int postNumber, DateTime at) => {
          'action_type': postNumber == 1 ? 4 : 5,
          'post_id': 900 + postNumber,
          'topic_id': 70 + postNumber,
          'title': 'Topic $postNumber',
          'post_number': postNumber,
          'username': 'tung',
          'excerpt': 'My words $postNumber',
          'created_at': at.toUtc().toIso8601String(),
        };

    setUp(() {
      users = _Users(ctx);
      topics = _Topics(ctx);
      drafts = _Drafts();
      SiteProxyFactory.register('myposts-test', _Factory(users, topics, drafts));
      SiteProxyService.initialize(ctx);
    });

    Future<void> pump(WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MyPostsPage(siteContext: ctx),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('All is topics and replies, grouped by time', (tester) async {
      final now = DateTime.now();
      users.actions = [
        action(12, now),
        action(1, now.subtract(const Duration(days: 30))),
      ];
      await pump(tester);

      expect(users.filters.first, '4,5', reason: "web's All stream");
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Earlier'), findsOneWidget);
      final kinds = tester
          .widgetList<ActivityRow>(find.byType(ActivityRow))
          .map((r) => r.kind)
          .toList();
      expect(kinds, ['Replied', 'Started a topic']);
      expect(find.text('My words 12'), findsOneWidget, reason: 'quoted');
    });

    testWidgets('Topics come from the topic list, with their counts',
        (tester) async {
      await pump(tester);
      await tester.tap(find.text('Topics'));
      await tester.pumpAndSettle();

      expect(topics.paths.single, '/topics/created-by/tung.json');
      final row = tester.widget<ActivityRow>(find.byType(ActivityRow));
      expect(row.replyCount, 6);
      expect(row.viewCount, 40);
      expect(row.tags, ['mobile']);
    });

    testWidgets('drafts waiting and pending posts announce themselves',
        (tester) async {
      drafts.count = 2;
      users.pending = [
        {
          'id': 5,
          'raw_text': 'Please **approve** me',
          'title': 'First post',
          'topic_id': 90,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        },
      ];
      await pump(tester);

      expect(find.text('2 drafts waiting'), findsOneWidget);
      expect(find.text('Pending (1)'), findsOneWidget);
      await tester.tap(find.text('Pending (1)'));
      await tester.pumpAndSettle();
      final row = tester.widget<ActivityRow>(find.byType(ActivityRow));
      expect(row.kind, 'Awaiting approval');
      expect(row.excerpt, 'Please approve me');
    });

    testWidgets('no pending posts, no Pending filter', (tester) async {
      await pump(tester);
      expect(find.textContaining('Pending'), findsNothing);
      expect(find.textContaining('drafts waiting'), findsNothing);
    });
  });
}

class _Users extends DiscourseUserProxy {
  _Users(super.context);
  List<Map<String, dynamic>> actions = const [];
  List<Map<String, dynamic>> pending = const [];
  final filters = <String>[];

  @override
  Future<Map<String, dynamic>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    if (path == '/user_actions.json') {
      filters.add(query?['filter']?.toString() ?? '');
      return {'user_actions': actions};
    }
    if (path == '/posts/tung/pending.json') return {'pending_posts': pending};
    return const {};
  }
}

class _Topics extends DiscourseTopicProxy {
  _Topics(super.context);
  final paths = <String>[];

  @override
  Future<Map<String, dynamic>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    if (path == '/categories.json') return {'category_list': {'categories': []}};
    paths.add(path);
    return {
      'users': [
        {'id': 2, 'username': 'tung', 'avatar_template': ''},
      ],
      'topic_list': {
        'topics': [
          {
            'id': 31,
            'title': 'My topic',
            'posts_count': 7,
            'views': 40,
            'like_count': 3,
            'tags': ['mobile'],
            'created_at': '2026-09-20T10:00:00Z',
            'posters': [
              {'user_id': 2, 'extras': 'latest single'},
            ],
          },
        ],
      },
    };
  }
}

class _Drafts implements IFCDraftProxy {
  int count = 0;

  @override
  Future<FCDraftListResult> getMyDraftsAsync({int page = 0}) async =>
      FCDraftListResult(
        result: true,
        total: count,
        items: [
          for (var i = 0; i < count; i++)
            FCDraft(draftKey: 'topic_$i', sequence: 0, data: const {}),
        ],
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Factory implements SiteProxyFactory {
  _Factory(this.users, this.topics, this.drafts);
  final _Users users;
  final _Topics topics;
  final _Drafts drafts;

  @override
  IFCUserProxy createUserProxy(SiteContext context) => users;

  @override
  IFCTopicProxy createTopicProxy(SiteContext context) => topics;

  @override
  IFCDraftProxy createDraftProxy(SiteContext context) => drafts;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
