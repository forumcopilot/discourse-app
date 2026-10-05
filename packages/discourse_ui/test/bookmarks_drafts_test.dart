import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/bookmarks_page.dart';
import 'package:discourse_ui/views/drafts_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Bookmarks and Drafts in the topic page's style: what each is, where it
/// leads, the words quoted, and removal with Undo.
void main() {
  const forum = 'https://forum.example';
  final ctx = SiteContext(
    siteType: 'bd-test',
    site: Site(
      id: null,
      name: 'Test',
      url: forum,
      description: '',
      endpoint: null,
      baseUrl: forum,
      logoUrl: null,
      backgroundUrl: null,
      siteType: 'bd-test',
    ),
  )..setLoginData(FCLoginResult(
      result: true,
      resultText: '',
      user: FCUser(id: '2', username: 'tung'),
    ));

  late _Bookmarks bookmarks;
  late _Drafts drafts;

  setUp(() {
    bookmarks = _Bookmarks(ctx);
    drafts = _Drafts();
    SiteProxyFactory.register('bd-test', _Factory(bookmarks, drafts));
    SiteProxyService.initialize(ctx);
  });

  Future<void> pump(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(1080, 2800);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: page,
    ));
    await tester.pumpAndSettle();
  }

  group('bookmarks', () {
    testWidgets('label, reminders in words, pinned first, the saved words',
        (tester) async {
      await pump(tester, BookmarksPage(siteContext: ctx));

      expect(find.text('Pinned'), findsWidgets, reason: 'heading and chip');
      expect(find.text('Check before release'), findsOneWidget,
          reason: "the bookmark's name, never shown before");
      expect(find.textContaining('Tomorrow, '), findsOneWidget);
      expect(find.textContaining('Due · '), findsOneWidget);
      expect(find.textContaining('Whole topic · saved'), findsOneWidget);
      expect(find.text('Push should arrive when swiped away'), findsOneWidget);
      expect(find.text('roadmap'), findsOneWidget, reason: 'its tags');

      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();
      expect(find.text('Whole topic idea'), findsNothing);
      expect(find.text('Roadmap'), findsOneWidget);
    });

    testWidgets('search asks the server', (tester) async {
      await pump(tester, BookmarksPage(siteContext: ctx));
      await tester.enterText(find.byType(TextField), 'release');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(bookmarks.queries.last, 'release');
    });

    testWidgets('swipe removes, Undo brings it back, else it is deleted',
        (tester) async {
      await pump(tester, BookmarksPage(siteContext: ctx));
      await tester.drag(find.text('Roadmap'), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(find.text('Roadmap'), findsNothing);
      expect(find.text('Bookmark removed'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('Roadmap'), findsOneWidget);
      expect(bookmarks.deleted, isEmpty);

      await tester.drag(find.text('Roadmap'), const Offset(-600, 0));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
      expect(bookmarks.deleted, ['/bookmarks/1.json'],
          reason: 'the snackbar times out; since Flutter 3.38 one with an '
              'action would otherwise stay up and the delete never run');
    });
  });

  group('drafts', () {
    testWidgets('what kind, where it goes, the words without their Markdown',
        (tester) async {
      await pump(tester, DraftsListPage(siteContext: ctx));

      expect(find.textContaining('Reply · '), findsOneWidget);
      expect(find.textContaining('New topic · '), findsOneWidget);
      expect(find.textContaining('Message to alice, bob · '), findsOneWidget);
      expect(find.text('Untitled topic'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Earlier'), findsOneWidget);
      expect(find.text('Bold idea'), findsOneWidget, reason: 'no ** marks');
      expect(find.text('[image] crash'), findsOneWidget);
      expect(find.text('design'), findsOneWidget, reason: "the new topic's tags");
    });

    testWidgets('web draft tag objects show their names', (tester) async {
      drafts.tags = [{'id': 3, 'name': 'design'}];
      await pump(tester, DraftsListPage(siteContext: ctx));
      expect(find.text('design'), findsOneWidget);
      expect(find.textContaining('{id:'), findsNothing);
    });

    testWidgets('discard with Undo, no dialog', (tester) async {
      await pump(tester, DraftsListPage(siteContext: ctx));
      await tester.tap(find.byTooltip('Discard').first);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Draft discarded'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Reply · '), findsOneWidget);
      expect(drafts.deleted, isEmpty);

      await tester.tap(find.byTooltip('Discard').first);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
      expect(drafts.deleted, ['topic_77']);
    });
  });
}

class _Bookmarks extends DiscourseBookmarkProxy {
  _Bookmarks(super.context);
  final queries = <String?>[];
  final deleted = <String>[];

  @override
  Future<Map<String, dynamic>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    queries.add(query?['q']?.toString());
    final now = DateTime.now();
    return {
      'user_bookmark_list': {
        'bookmarks': [
          {
            'id': 1,
            'title': 'Roadmap',
            'excerpt': 'Push should arrive when swiped away',
            'name': 'Check before release',
            'pinned': true,
            'bookmarkable_type': 'Post',
            'bookmarkable_id': 501,
            'topic_id': 34,
            'linked_post_number': 12,
            'category_id': 4,
            'tags': ['roadmap'],
            'reminder_at': DateTime(now.year, now.month, now.day + 1, 8)
                .toUtc()
                .toIso8601String(),
            'created_at': now.subtract(const Duration(days: 3)).toIso8601String(),
            'user': {'username': 'bob', 'avatar_template': ''},
          },
          {
            'id': 2,
            'title': 'Naming widgets',
            'bookmarkable_type': 'Post',
            'bookmarkable_id': 502,
            'topic_id': 31,
            'linked_post_number': 4,
            'reminder_at':
                now.subtract(const Duration(hours: 3)).toUtc().toIso8601String(),
            'user': {'username': 'alice', 'avatar_template': ''},
          },
          {
            'id': 3,
            'title': 'Whole topic idea',
            'bookmarkable_type': 'Topic',
            'bookmarkable_id': 33,
            'topic_id': 33,
            'created_at':
                now.subtract(const Duration(days: 30)).toIso8601String(),
          },
        ],
      },
    };
  }

  @override
  Future<Map<String, dynamic>> apiDelete(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    deleted.add(path);
    return const {};
  }
}

class _Drafts implements IFCDraftProxy {
  List<Object> tags = ['design'];
  final deleted = <String>[];

  @override
  Future<FCDraftListResult> getMyDraftsAsync({int page = 0}) async {
    final now = DateTime.now();
    return FCDraftListResult(result: true, total: 3, items: [
      FCDraft(
        draftKey: 'topic_77',
        sequence: 1,
        title: 'E2E topic with tags',
        topicId: 77,
        updatedAt: now.subtract(const Duration(minutes: 12)),
        data: const {'reply': '**Bold** idea'},
      ),
      FCDraft(
        draftKey: 'new_private_message_1',
        sequence: 0,
        updatedAt: now.subtract(const Duration(minutes: 40)),
        data: const {
          'title': 'Meetup plans',
          'recipients': 'alice,bob',
          'reply': 'Saturday works',
        },
      ),
      FCDraft(
        draftKey: 'new_topic_1700000000',
        sequence: 0,
        categoryId: 4,
        updatedAt: now.subtract(const Duration(days: 14)),
        data: {
          'title': '',
          'reply': '![shot|690x388](upload://a.png) crash',
          'tags': tags,
        },
      ),
    ]);
  }

  @override
  Future<FCDeleteDraftResult> deleteDraftAsync(String draftKey,
      {int sequence = 0}) async {
    deleted.add(draftKey);
    return FCDeleteDraftResult(result: true);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Factory implements SiteProxyFactory {
  _Factory(this.bookmarks, this.drafts);
  final _Bookmarks bookmarks;
  final _Drafts drafts;

  @override
  IFCBookmarkProxy createBookmarkProxy(SiteContext context) => bookmarks;

  @override
  IFCDraftProxy createDraftProxy(SiteContext context) => drafts;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
