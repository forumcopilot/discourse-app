import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/profile/profile_common.dart';
import 'package:discourse_ui/views/profile/user_card_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// The user card: a quick look at someone over the page being read, from
/// `/u/{username}/card.json`.
void main() {
  const forum = 'https://forum.example';
  final ctx = SiteContext(
    siteType: 'discourse',
    site: Site(
      id: null,
      name: 'Test',
      url: forum,
      description: '',
      endpoint: null,
      baseUrl: forum,
      logoUrl: null,
      backgroundUrl: null,
      siteType: 'discourse',
    ),
  )..setLoginData(FCLoginResult(
      result: true,
      resultText: '',
      user: FCUser(id: '2', username: 'alice'),
    ));

  Future<void> pump(WidgetTester tester, DiscourseUserCard card,
      {int? topicId}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: UserCardSheet(
          siteContext: ctx,
          username: card.username,
          topicId: topicId,
          proxy: _Cards(ctx, card),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets("someone's card: who they are, badges, and ways to reach them",
      (tester) async {
    await pump(
      tester,
      DiscourseUserCard(
        id: 3,
        username: 'bob',
        name: 'Bob Tran',
        title: 'Meetup host',
        flairName: 'hosts',
        flairUrl: 'users',
        flairBgColor: 'C8581A',
        status: const DiscourseUserStatus(
            description: 'In a meeting', emoji: 'calendar'),
        location: 'Saigon',
        fields: const [(name: 'Pronouns', value: 'he/him')],
        badges: const [
          DiscourseFeaturedBadge(id: 7, name: 'Great Topic', badgeTypeId: 1),
        ],
        topicPostCount: 12,
        canSendPrivateMessage: true,
        canChat: true,
        canMute: true,
      ),
      topicId: 98,
    );
    expect(find.text('Bob Tran'), findsOneWidget);
    expect(find.text('@bob · Meetup host'), findsOneWidget);
    expect(find.text('In a meeting'), findsOneWidget);
    expect(find.text('Saigon'), findsOneWidget);
    expect(find.text('Pronouns: he/him'), findsOneWidget);
    expect(find.text('Great Topic'), findsOneWidget);
    expect(find.byType(UserFlairBadge), findsOneWidget);
    expect(find.text("Show only Bob Tran's 12 posts in this topic"),
        findsOneWidget);
    expect(find.text('Message'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.byTooltip('More options'), findsOneWidget);
  });

  testWidgets('no topic, no "only their posts"', (tester) async {
    await pump(tester,
        const DiscourseUserCard(id: 3, username: 'bob', topicPostCount: 4));
    expect(find.textContaining('in this topic'), findsNothing);
    expect(find.text('Message'), findsNothing,
        reason: 'the server says whether they accept messages');
  });

  testWidgets('a private profile: who they are, and Message', (tester) async {
    await pump(
      tester,
      const DiscourseUserCard(
        id: 4,
        username: 'chris',
        profileHidden: true,
        primaryGroupName: 'beta',
        topicPostCount: 3,
        canSendPrivateMessage: true,
      ),
      topicId: 98,
    );
    expect(find.text('chris keeps their profile private.'), findsOneWidget);
    expect(find.text('Member of beta'), findsOneWidget);
    expect(find.text("Show only chris's 3 posts in this topic"), findsOneWidget);
    expect(find.text('Message'), findsOneWidget);
    expect(find.text('Profile'), findsNothing);
  });

  testWidgets('your own card offers Edit profile', (tester) async {
    await pump(
      tester,
      const DiscourseUserCard(
          id: 2, username: 'alice', name: 'Alice Nguyen', topicPostCount: 4),
      topicId: 98,
    );
    expect(find.textContaining('(you)', findRichText: true), findsOneWidget);
    expect(find.text('Show only your 4 posts in this topic'), findsOneWidget);
    expect(find.text('Edit profile'), findsOneWidget);
    expect(find.text('View profile'), findsOneWidget);
    expect(find.text('Message'), findsNothing);
    expect(find.byTooltip('More options'), findsNothing);
  });
}

class _Cards extends DiscourseProfileProxy {
  _Cards(super.context, this.card);
  final DiscourseUserCard card;

  @override
  Future<DiscourseUserCard> loadCard(String username, {int? topicId}) async =>
      card;
}
