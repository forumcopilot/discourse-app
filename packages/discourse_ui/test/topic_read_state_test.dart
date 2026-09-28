import 'package:discourse_core/discourse_core.dart' show DiscourseTopicTracking;
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/views/listitems/topic_list_item.dart';
import 'package:discourse_ui/views/widgets/dismiss_topics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Read and unread in the topic list (review, 2026-09-28). On the device,
/// alice's Latest showed all 30 rows grey — 19 of them never opened — and a
/// row went grey the moment it was tapped, before anything was read.
void main() {
  const url = 'https://read-state.example';
  late SiteContext ctx;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    DiscourseTopicTracking.clearAll();
    ctx = SiteContext(
      siteType: 'discourse',
      site: Site(
        id: null,
        name: 'Example',
        url: url,
        description: 'read state test',
        endpoint: null,
        baseUrl: url,
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'discourse',
      ),
    );
    ctx.setLoginData(FCLoginResult(
      result: true,
      resultText: '',
      user: FCUser(id: '2', username: 'alice'),
    ));
  });

  FCTopic topic(String id) => FCTopic(
        id: id,
        title: 'Topic $id',
        forumId: '4',
        forumName: '',
        authorId: '1',
        authorName: 'bob',
        timestamp: DateTime(2026, 9, 1),
      );

  void record(String id,
          {int? lastRead, int highest = 5, int? level, bool unseen = false}) =>
      DiscourseTopicTracking.forSite(ctx).recordTopicJson({
        'id': int.parse(id),
        'highest_post_number': highest,
        if (lastRead != null) 'last_read_post_number': lastRead,
        if (level != null) 'notification_level': level,
        'unseen': unseen,
      });

  Future<void> pumpRows(WidgetTester tester, List<String> ids) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ListView(children: [
          for (final id in ids)
            TopicListItem(
                siteContext: ctx, topic: topic(id), onTap: () {}),
        ]),
      ),
    ));
    await tester.pump();
  }

  Color? titleColor(WidgetTester tester, String id) =>
      tester.widget<Text>(find.text('Topic $id')).style?.color;

  testWidgets('only a topic read to the end steps back', (tester) async {
    record('1', lastRead: 5, level: 1); // read
    record('2'); // never opened, older than the new window
    record('3', lastRead: 2, level: 1); // new replies, not tracked
    await pumpRows(tester, ['1', '2', '3']);
    final scheme = Theme.of(tester.element(find.text('Topic 1'))).colorScheme;
    expect(titleColor(tester, '1'), scheme.onSurfaceVariant);
    expect(titleColor(tester, '2'), scheme.onSurface);
    expect(titleColor(tester, '3'), scheme.onSurface);
    expect(find.byType(Badge), findsNothing);
  });

  testWidgets('new and unread are badged and say so', (tester) async {
    final semantics = tester.ensureSemantics();
    record('1', unseen: true, highest: 1);
    record('2', lastRead: 4, highest: 7, level: 2);
    await pumpRows(tester, ['1', '2']);
    // Merged into each row's own label, as the row reads as one item.
    expect(find.bySemanticsLabel(RegExp(r'Topic 1\nNew topic')),
        findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'Topic 2\n3 unread replies')),
        findsOneWidget);
    semantics.dispose();
  });

  testWidgets('tapping does not mark it read; reading does', (tester) async {
    record('1', unseen: true, highest: 2);
    await pumpRows(tester, ['1']);
    await tester.tap(find.text('Topic 1'));
    await tester.pump();
    expect(find.byType(Badge), findsOneWidget,
        reason: 'backing straight out used to leave it looking read');

    DiscourseTopicTracking.forSite(ctx).recordRead('1', 2);
    await tester.pump();
    await tester.pump();
    expect(find.byType(Badge), findsNothing);
    final scheme = Theme.of(tester.element(find.text('Topic 1'))).colorScheme;
    expect(titleColor(tester, '1'), scheme.onSurfaceVariant);
  });

  testWidgets('a guest sees nothing claimed read', (tester) async {
    ctx.setLoginData(null);
    await pumpRows(tester, ['1']);
    final scheme = Theme.of(tester.element(find.text('Topic 1'))).colorScheme;
    expect(titleColor(tester, '1'), scheme.onSurface);
  });

  testWidgets('dismissing unread offers to stop tracking, and asks first',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: DismissTopicsBar(siteContext: ctx, kind: DismissKind.unread),
      ),
    ));
    await tester.tap(find.text('Dismiss unread'));
    await tester.pumpAndSettle();
    expect(find.text('Dismiss all unread?'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('dismissing new has no tracking choice', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: DismissTopicsBar(siteContext: ctx, kind: DismissKind.newTopics),
      ),
    ));
    await tester.tap(find.text('Dismiss new'));
    await tester.pumpAndSettle();
    expect(find.text('Dismiss new topics?'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNothing);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });
}
