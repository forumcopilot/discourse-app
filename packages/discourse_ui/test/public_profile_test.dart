import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/widgets/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Someone's profile, as web's user page shows it: who they are, how to
/// reach them, their numbers, then Activity / Summary / Badges.
void main() {
  const forum = 'https://forum.example';
  final ctx = SiteContext(
    siteType: 'public-test',
    site: Site(
      id: null,
      name: 'Test',
      url: forum,
      description: '',
      endpoint: null,
      baseUrl: forum,
      logoUrl: null,
      backgroundUrl: null,
      siteType: 'public-test',
    ),
  )..setLoginData(FCLoginResult(
      result: true,
      resultText: '',
      user: FCUser(id: '2', username: 'tung'),
    ));

  FCUserInfoResult alice() => FCUserInfoResult(
        result: true,
        id: '7',
        username: 'alice',
        displayText: 'Alice Nguyen',
        acceptsPM: true,
        canChatUser: true,
        location: 'Saigon',
        website: 'https://www.alice.dev/',
        registrationTime: DateTime(2024, 3, 5),
        lastSeenAt: DateTime.now().subtract(const Duration(hours: 2)),
        trustLevel: 3,
        userGroups: const ['meetup-hosts'],
      );

  setUp(() {
    DiscourseUserProfileExtras.clear();
    DiscourseUserProfileExtras.store(
      forum,
      'alice',
      DiscourseUserProfileExtras(
        title: 'Community lead',
        statusDescription: 'On holiday until Monday',
        statusEndsAt: DateTime.now().add(const Duration(days: 2)),
        featuredTopicId: 42,
        featuredTopicTitle: 'Meetup venue ideas',
        bioText: 'Flutter dev, Discourse fan.',
      ),
    );
    SiteProxyFactory.register('public-test', _Factory());
    SiteProxyService.initialize(ctx);
  });

  Future<void> pump(WidgetTester tester, {bool self = false}) async {
    tester.view.physicalSize = const Size(1080, 2600);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ProfileView(siteContext: ctx, userInfo: alice(), isSelf: self),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('who they are, how to reach them, their numbers', (tester) async {
    await pump(tester);

    expect(find.text('Alice Nguyen'), findsOneWidget);
    expect(find.text('@alice · Community lead'), findsOneWidget);
    expect(find.text('On holiday until Monday'), findsOneWidget);
    expect(find.text('Flutter dev, Discourse fan.'), findsOneWidget);
    expect(find.text('Saigon'), findsOneWidget);
    expect(find.text('alice.dev'), findsOneWidget);
    expect(find.textContaining('Joined Mar 2024'), findsOneWidget,
        reason: 'one line, where the info card had three rows');
    expect(find.text('Message'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Edit profile'), findsNothing);
    expect(find.text('1,200'), findsOneWidget, reason: 'posts, from the summary');
    for (final tab in ['Activity', 'Summary', 'Badges']) {
      expect(find.text(tab), findsOneWidget, reason: tab);
    }
  });

  testWidgets('Summary: featured topic, top categories, details',
      (tester) async {
    await pump(tester);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();

    expect(find.text('Featured topic'), findsOneWidget);
    expect(find.text('Meetup venue ideas'), findsOneWidget);
    expect(find.text('Top categories'), findsOneWidget);
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Trust level 3'), findsOneWidget);
    expect(find.text('meetup-hosts'), findsOneWidget);
  });

  testWidgets('your own public profile offers Edit profile instead',
      (tester) async {
    await pump(tester, self: true);
    expect(find.text('Edit profile'), findsOneWidget);
    expect(find.text('Message'), findsNothing);
  });
}

class _Users extends DiscourseUserProxy {
  _Users(super.context);

  @override
  Future<Map<String, dynamic>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    if (path == '/u/alice/summary.json') {
      return {
        'user_summary': {
          'post_count': 1200,
          'likes_received': 3400,
          'days_visited': 210,
          'solved_count': 41,
          'can_see_summary_stats': true,
          'top_categories': [
            {'id': 4, 'name': 'General', 'topic_count': 2, 'post_count': 9},
          ],
        },
      };
    }
    if (path == '/user_actions.json') return {'user_actions': []};
    return const {};
  }
}

class _Factory implements SiteProxyFactory {
  @override
  IFCUserProxy createUserProxy(SiteContext context) => _Users(context);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
