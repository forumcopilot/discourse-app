import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Edit profile as an overview: each row shows what is set, opens an
/// editor for just that, and the change saves when it is made. What the
/// forum does not allow is left out or locked.
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

  Map<String, dynamic> aliceJson({bool canChangeBio = true}) => {
        'id': 2,
        'username': 'alice',
        'name': 'Alice Nguyen',
        'can_edit_name': true,
        'can_change_bio': canChangeBio,
        'bio_raw': 'Designer in **Saigon**',
        'bio_cooked': '<p>Designer in <strong>Saigon</strong></p>',
        'location': 'Saigon',
        'website': 'https://alice.design/',
        'title': 'Community lead',
        'has_title_badges': true,
        'flair_group_id': 41,
        'groups': [
          {
            'id': 41,
            'name': 'designers',
            'full_name': 'Designers',
            'title': 'Community lead',
            'flair_url': 'paintbrush',
            'flair_bg_color': '7B4FC9',
          },
        ],
        'user_fields': {'1': 'she/her'},
        'user_option': {'timezone': 'Asia/Ho_Chi_Minh'},
        'featured_topic': {'id': 42, 'title': 'Meetup guide'},
      };

  const fields = [
    DiscourseUserFieldDef(id: 1, name: 'Pronouns', showOnProfile: true),
    DiscourseUserFieldDef(
      id: 2,
      name: 'Favourite tool',
      type: DiscourseUserFieldType.dropdown,
      requiredForAll: true,
      options: ['Figma', 'Sketch'],
    ),
  ];

  Future<_FakeProfile> pump(WidgetTester tester,
      {bool canChangeBio = true,
      DiscourseProfileSettings settings = const DiscourseProfileSettings()}) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    final proxy = _FakeProfile(ctx, aliceJson(canChangeBio: canChangeBio),
        settings: settings, fields: fields);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: EditProfilePage(
        siteContext: ctx,
        userInfo: FCUserInfoResult(result: true, id: '2', username: 'alice'),
        proxy: proxy,
      ),
    ));
    await tester.pumpAndSettle();
    return proxy;
  }

  testWidgets('rows show what is set, grouped, and only what the forum allows',
      (tester) async {
    await pump(tester);

    for (final heading in [
      'Name and about',
      'Next to your name',
      'On your profile',
      'Privacy and time',
    ]) {
      expect(find.text(heading), findsOneWidget, reason: heading);
    }
    expect(find.text('@alice'), findsOneWidget);
    expect(find.text('Alice Nguyen'), findsOneWidget);
    expect(find.text('Designer in Saigon'), findsOneWidget,
        reason: 'the cooked bio as text, not its Markdown');
    expect(find.text('alice.design'), findsOneWidget);
    expect(find.text('Community lead'), findsOneWidget);
    expect(find.text('Designers'), findsOneWidget);
    expect(find.text('Meetup guide'), findsOneWidget);
    expect(find.text('Favourite tool needs an answer'), findsOneWidget,
        reason: 'a required question left unanswered is called out');
    expect(find.textContaining('Asia/Ho_Chi_Minh'), findsOneWidget);
    expect(find.text('Hide my public profile'), findsOneWidget);
    expect(find.text('Primary group'), findsNothing,
        reason: 'user_selected_primary_groups is off by default');
    expect(find.text('Birthday'), findsNothing,
        reason: 'cakeday birthdays are off by default');
    expect(find.text('Save'), findsNothing, reason: 'no page-wide Save');
  });

  testWidgets("fields the forum's sign-in owns are locked and say why",
      (tester) async {
    final proxy = await pump(tester, canChangeBio: false);
    await tester.tap(find.text('About me'));
    await tester.pumpAndSettle();
    expect(find.text('This forum manages it through its own sign-in. Change it there.'),
        findsOneWidget);
    expect(proxy.updates, isEmpty);
  });

  testWidgets('a title is saved when picked, and Undo puts it back',
      (tester) async {
    final proxy = await pump(tester);
    await tester.tap(find.text('Title'));
    await tester.pumpAndSettle();
    expect(find.text('Badge · earned Jan 2026'), findsOneWidget);
    await tester.tap(find.text('Leader'));
    await tester.pumpAndSettle();

    expect(proxy.updates.last, {'title': 'Leader'});
    expect(find.text('Title changed to Leader'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(proxy.updates.last, {'title': 'Community lead'});
  });

  testWidgets('a one-line text saves from its dialog', (tester) async {
    final proxy = await pump(tester);
    await tester.tap(find.text('Location'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Hanoi');
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();
    expect(proxy.updates.last, {'location': 'Hanoi'});
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets("the forum's questions do not save without a required answer",
      (tester) async {
    final proxy = await pump(tester);
    await tester.tap(find.text('More about you'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('This forum asks everyone to answer'), findsOneWidget);
    expect(proxy.fieldUpdates, isEmpty);

    await tester.tap(find.text('Favourite tool *'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Figma').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(proxy.fieldUpdates.single, {2: 'Figma'},
        reason: 'only what changed is sent');
  });
}

class _FakeProfile extends DiscourseProfileProxy {
  _FakeProfile(super.context, this.json,
      {required this.settings, required this.fields});

  Map<String, dynamic> json;
  final DiscourseProfileSettings settings;
  final List<DiscourseUserFieldDef> fields;
  final List<Map<String, dynamic>> updates = [];
  final List<Map<int, Object?>> fieldUpdates = [];

  DiscourseEditableProfile get _current =>
      DiscourseEditableProfile.fromUserJson(json, siteUrl: siteContext.site.url);

  @override
  Future<({DiscourseProfileSettings settings, List<DiscourseUserFieldDef> fields})>
      forumRules() async => (settings: settings, fields: fields);

  @override
  Future<DiscourseEditableProfile> loadMine() async => _current;

  @override
  Future<DiscourseEditableProfile> update(Map<String, dynamic> fields) async {
    updates.add(fields);
    json = {...json, ...fields};
    return _current;
  }

  @override
  Future<DiscourseEditableProfile> updateUserFields(
      Map<int, Object?> values) async {
    fieldUpdates.add(values);
    json = {
      ...json,
      'user_fields': {
        ...(json['user_fields'] as Map),
        for (final e in values.entries) '${e.key}': e.value,
      },
    };
    return _current;
  }

  @override
  Future<List<DiscourseTitleOption>> titleOptions(
          DiscourseEditableProfile profile) async =>
      [
        const DiscourseTitleOption(
            title: 'Community lead', groupName: 'Designers'),
        DiscourseTitleOption(
            title: 'Leader',
            badgeName: 'Leader',
            grantedAt: DateTime.utc(2026, 1, 5)),
      ];
}
