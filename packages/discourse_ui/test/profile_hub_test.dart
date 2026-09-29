import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/settings_page.dart';
import 'package:discourse_ui/views/tabs/profile_tab.dart';
import 'package:discourse_ui/views/widgets/site_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// The Profile tab as the reader's account on the forum, and the drawer
/// back to being the forum's map.
void main() {
  SiteContext context({bool signedIn = true}) {
    final ctx = SiteContext(
      siteType: 'hub-test',
      site: Site(
        id: null,
        name: 'Test Forum',
        url: 'https://forum.example',
        description: '',
        endpoint: null,
        baseUrl: 'https://forum.example',
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'hub-test',
      ),
    );
    if (signedIn) {
      ctx.setLoginData(FCLoginResult(
        result: true,
        resultText: '',
        user: FCUser(id: '2', username: 'tung'),
      ));
    }
    return ctx;
  }

  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1080, 2600);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ));
    await tester.pumpAndSettle();
  }

  group('Profile tab', () {
    testWidgets('a guest is invited in', (tester) async {
      final ctx = context(signedIn: false);
      SiteProxyFactory.register('hub-test', _Factory(ctx));
      SiteProxyService.initialize(ctx);
      await pump(tester, ProfileTab(siteContext: ctx, isActive: true));

      expect(find.text('Join Test Forum'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Create account'), findsOneWidget);
      expect(find.text('About this forum'), findsOneWidget);
      expect(find.text('Sign out'), findsNothing);
    });

    testWidgets('signed in: who you are, your numbers, your stuff, settings',
        (tester) async {
      final ctx = context();
      SiteProxyFactory.register('hub-test', _Factory(ctx));
      SiteProxyService.initialize(ctx);
      await pump(tester, ProfileTab(siteContext: ctx, isActive: true));

      expect(find.text('Tung Nguyen'), findsOneWidget);
      expect(find.textContaining('@tung'), findsOneWidget);
      expect(find.text('View profile'), findsOneWidget);
      expect(find.text('Edit profile'), findsOneWidget);
      // Numbers over their labels; solutions only with discourse-solved.
      expect(find.text('26'), findsOneWidget,
          reason: "post_count already counts the topics' opening posts");
      expect(find.text('posts'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('solved'), findsOneWidget,
          reason: 'solutions only where discourse-solved reports them');
      for (final row in ['My posts', 'Drafts', 'Bookmarks', 'Badges', 'Invites',
          'Notification settings', 'Account and privacy', 'Sign out']) {
        expect(find.text(row), findsOneWidget, reason: row);
      }
      // Drafts and bookmarks carry their counts.
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('Account and privacy repeats nothing the tab already has',
        (tester) async {
      final ctx = context();
      await pump(tester, ForumSettingsPage(siteContext: ctx));

      expect(find.text('Account and privacy'), findsOneWidget);
      for (final row in ['Account', 'Change email', 'Change password',
          'Privacy', 'Ignored users', 'Manage account on web']) {
        expect(find.text(row), findsOneWidget, reason: row);
      }
      expect(find.text('Delete account'), findsWidgets);
      // Notification settings and Terms / Privacy Policy are on the tab.
      for (final gone in ['Notifications', 'Notification settings',
          'Terms of Service', 'Privacy Policy']) {
        expect(find.text(gone), findsNothing, reason: gone);
      }
    });
  });

  group('drawer', () {
    testWidgets("your own things live on the Profile tab now", (tester) async {
      final ctx = context();
      await pump(tester, SiteDrawer(siteContext: ctx, homeIsCurrent: true));

      expect(find.text('My posts'), findsOneWidget);
      for (final gone in ['Bookmarks', 'Drafts', 'Invites', 'Notification settings']) {
        expect(find.text(gone), findsNothing, reason: gone);
      }
      expect(find.textContaining('Go to your profile'), findsOneWidget);
      // The less used places fold under More.
      expect(find.text('Users'), findsNothing);
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.text('Users'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
    });

    testWidgets('a guest sees the places unfolded and the ways in',
        (tester) async {
      final ctx = context(signedIn: false);
      await pump(tester, SiteDrawer(siteContext: ctx, homeIsCurrent: true));

      expect(find.text('More'), findsNothing);
      expect(find.text('Users'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Create account'), findsOneWidget);
    });

    testWidgets("the guest's buttons stack rather than wrap a label",
        (tester) async {
      final ctx = context(signedIn: false);
      Widget drawer(double scale) => Builder(
            builder: (c) => MediaQuery(
              data: MediaQuery.of(c)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: SiteDrawer(siteContext: ctx, homeIsCurrent: true),
            ),
          );
      final signIn = find.widgetWithText(FilledButton, 'Sign in');
      final create = find.widgetWithText(OutlinedButton, 'Create account');

      // The test font draws every glyph a full em wide, so "Create
      // account" is twice its width in Roboto: a small size fits beside
      // Sign in, full size does not.
      await pump(tester, drawer(0.4));
      expect(tester.getTopLeft(create).dy, tester.getTopLeft(signIn).dy,
          reason: 'side by side while both labels fit');

      await pump(tester, drawer(1));
      expect(tester.getTopLeft(create).dy,
          greaterThan(tester.getBottomLeft(signIn).dy),
          reason: 'one above the other at a large text size');
      final label = tester.renderObject<RenderParagraph>(
          find.descendant(of: create, matching: find.byType(RichText)));
      expect(label.didExceedMaxLines, isFalse);
      expect(tester.getSize(create).width,
          greaterThan(tester.getSize(find.byType(Drawer)).width / 2),
          reason: 'full width when stacked');
    });
  });
}

class _Users extends DiscourseUserProxy {
  _Users(super.context);

  @override
  Future<Map<String, dynamic>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    if (path == '/u/tung.json') {
      return {
        'user': {
          'id': 2,
          'username': 'tung',
          'name': 'Tung Nguyen',
          'avatar_template': '',
          'trust_level': 2,
          'badge_count': 14,
          'post_count': 26,
        },
      };
    }
    if (path == '/u/tung/summary.json') {
      return {
        'user_summary': {
          'likes_received': 12,
          'days_visited': 30,
          'post_count': 26,
          'topic_count': 15,
          'bookmark_count': 3,
          'solved_count': 1,
          'can_see_summary_stats': true,
        },
      };
    }
    return const {};
  }

  @override
  Future<DiscourseDoNotDisturbResult> getDoNotDisturbStatusAsync() async =>
      DiscourseDoNotDisturbResult(result: true);
}

class _Drafts implements IFCDraftProxy {
  @override
  Future<FCDraftListResult> getMyDraftsAsync({int page = 0}) async =>
      FCDraftListResult(result: true, total: 2, items: [
        FCDraft(draftKey: 'topic_1', sequence: 0, data: const {}),
        FCDraft(draftKey: 'topic_2', sequence: 0, data: const {}),
      ]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Factory implements SiteProxyFactory {
  _Factory(this.ctx);
  final SiteContext ctx;

  @override
  IFCUserProxy createUserProxy(SiteContext context) => _Users(context);

  @override
  IFCDraftProxy createDraftProxy(SiteContext context) => _Drafts();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
