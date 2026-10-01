import 'dart:math' as math;

import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/controllers/post_controller.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/l10n/generated/app_localizations_en.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/appbars/posts_page_app_bar.dart';
import 'package:discourse_ui/views/listitems/post_list_item.dart';
import 'package:discourse_ui/views/widgets/notification_level_sheet.dart';
import 'package:discourse_ui/views/widgets/topic_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post.dart';

/// A topic's status shown the way Discourse web shows it: icons before the
/// title, and a footer under the last post with the reader's Pinned /
/// Unpinned choice and notification level, each with Discourse's reason;
/// not the XenForo-era banners ("This topic is pinned to the top of the
/// forum", "You are subscribed to this topic") that sat over the posts.
const _site = 'https://forum.example';

SiteContext _ctx({bool signedIn = true}) {
  final ctx = SiteContext(
    siteType: 'ts-test',
    site: Site(
      id: null,
      name: 'Test',
      url: _site,
      description: '',
      endpoint: null,
      baseUrl: _site,
      logoUrl: null,
      backgroundUrl: null,
      siteType: 'ts-test',
    ),
  );
  if (signedIn) {
    ctx.setLoginData(FCLoginResult(
        result: true, resultText: '', user: FCUser(id: '2', username: 'alice')));
  }
  return ctx;
}

DiscourseTopicStatus _status(Map<String, dynamic> t) {
  final s = DiscourseTopicStatus.fromTopicView(t);
  DiscourseTopicStatus.store(_site, '7', s);
  return s;
}

Widget _app(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

FCPost _opening() => FCPost(
      id: '11',
      title: '',
      content: '<p>hi</p>',
      topicId: '7',
      postNumber: 1,
      authorId: '1',
      authorName: 'bob',
      timestamp: DateTime(2026, 9, 28),
    );

final _en = AppLocalizationsEn();

void main() {
  setUp(DiscourseTopicStatus.clear);

  group('before the title', () {
    Future<void> pumpTitle(WidgetTester tester) async {
      await tester.pumpWidget(_app(PostListItem(
        siteContext: _ctx(),
        post: _opening(),
        threadId: '7',
        topicTitle: 'Welcome to the forum',
        postController: PostController(),
      )));
      await tester.pump();
    }

    testWidgets('a closed, pinned topic: a lock, then a thumbtack, no banners',
        (tester) async {
      _status({'closed': true, 'pinned': true});
      await pumpTitle(tester);
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.byIcon(Icons.push_pin), findsOneWidget);
      expect(find.textContaining('Welcome to the forum', findRichText: true),
          findsOneWidget);
      expect(find.textContaining('pinned to the top of the forum'), findsNothing);
      expect(find.textContaining('subscribed'), findsNothing);

      // A tap says what the icon means, in Discourse's words.
      await tester.tap(find.byIcon(Icons.lock));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(_en.topicStatusClosedHelp), findsOneWidget);
      expect(_en.topicStatusClosedHelp,
          'This topic is closed; it no longer accepts new replies');
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('a pin the reader cleared shows the thumbtack upside down',
        (tester) async {
      _status({'pinned': false, 'unpinned': true});
      await pumpTitle(tester);
      final pin = find.byIcon(Icons.push_pin_outlined);
      expect(pin, findsOneWidget);
      final turn = tester.widget<Transform>(
          find.ancestor(of: pin, matching: find.byType(Transform)).first);
      expect(turn.transform.getRotation().entry(0, 0), closeTo(math.cos(math.pi), 1e-9));
    });

    testWidgets('unlisted and deleted have their icons; an ordinary topic none',
        (tester) async {
      _status({'visible': false, 'deleted_at': '2026-09-30T00:00:00Z'});
      await pumpTitle(tester);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);

      _status({});
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off), findsNothing);
      expect(find.byIcon(Icons.lock), findsNothing);
      expect(find.byIcon(Icons.push_pin), findsNothing);
    });
  });

  group('the footer', () {
    testWidgets("the reader's pin and notification level, each with its reason",
        (tester) async {
      final s = _status({
        'pinned': true,
        'details': {'notification_level': 3, 'notifications_reason_id': 1},
      });
      await tester.pumpWidget(_app(TopicFooter(siteContext: _ctx(), topicId: '7', status: s)));
      expect(find.text('Pinned'), findsOneWidget);
      expect(find.text('This topic is pinned for you; it will display at the top of its category'),
          findsOneWidget);
      expect(find.text('Watching'), findsOneWidget);
      expect(find.text('You will receive notifications because you created this topic.'),
          findsOneWidget);
    });

    testWidgets('Unpinned takes the topic out of the top for this reader alone',
        (tester) async {
      final topics = _Topics(_ctx());
      SiteProxyFactory.register('ts-test', _Factory(topics));
      SiteProxyFactory.initialize(_ctx());
      _status({'pinned': true});
      await tester.pumpWidget(_app(TopicStatusBuilder(
        siteContext: _ctx(),
        topicId: '7',
        builder: (context, s) =>
            TopicFooter(siteContext: _ctx(), topicId: '7', status: s!),
      )));
      await tester.tap(find.byKey(const ValueKey('topic-footer-pinned')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pinned-option-unpinned')));
      await tester.pumpAndSettle();
      expect(topics.puts, ['/t/7/clear-pin']);
      expect(find.text('Unpinned'), findsOneWidget);
      expect(find.text('This topic is unpinned for you; it will display in regular order'),
          findsOneWidget);
    });

    testWidgets('no pin choice on a deleted topic, nothing at all for a guest',
        (tester) async {
      final deleted = _status({'pinned': true, 'deleted_at': '2026-09-30T00:00:00Z'});
      await tester.pumpWidget(
          _app(TopicFooter(siteContext: _ctx(), topicId: '7', status: deleted)));
      expect(find.byKey(const ValueKey('topic-footer-pinned')), findsNothing);
      expect(find.byKey(const ValueKey('topic-footer-notifications')), findsOneWidget);

      final pinned = _status({'pinned': true});
      await tester.pumpWidget(_app(
          TopicFooter(siteContext: _ctx(signedIn: false), topicId: '7', status: pinned)));
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('the topic timer and slow mode, as web words them',
        (tester) async {
      final now = DateTime.utc(2026, 10, 1, 12);
      final s = _status({
        'slow_mode_seconds': 3600,
        'topic_timer': {
          'status_type': 'close',
          'execute_at': now.add(const Duration(days: 3)).toIso8601String(),
        },
      });
      await tester.pumpWidget(_app(TopicFooter(
          siteContext: _ctx(signedIn: false), topicId: '7', status: s, now: now)));
      expect(find.text('This topic will automatically close in 3 days.'), findsOneWidget);
      expect(find.text('Please wait 1 hour between your posts in this topic.'), findsOneWidget);
    });
  });

  group('topic timer notice', () {
    final now = DateTime.utc(2026, 10, 1, 12);
    String? notice(Map<String, dynamic> timer, {bool closed = false}) =>
        topicTimerNotice(
          _en,
          DiscourseTopicStatus.fromTopicView({'closed': closed, 'topic_timer': timer}),
          now: now,
          categoryName: 'announcements',
        );
    String at(Duration d) => now.add(d).toIso8601String();

    test('times to come, in minutes, hours or days', () {
      expect(notice({'status_type': 'open', 'execute_at': at(const Duration(minutes: 20))}, closed: true),
          'This topic will automatically open in 20 minutes.');
      expect(notice({'status_type': 'bump', 'execute_at': at(const Duration(hours: 5))}),
          'This topic will be automatically bumped in 5 hours.');
      expect(notice({'status_type': 'publish_to_category', 'execute_at': at(const Duration(days: 1))}),
          'This topic will be published to #announcements in 1 day.');
    });

    test('a timer counted from the last reply gives its length', () {
      expect(
          notice({
            'status_type': 'close',
            'execute_at': at(const Duration(days: 2)),
            'based_on_last_post': true,
            'duration_minutes': 2880,
          }),
          'This topic will close 2 days after the last reply.');
    });

    test('nothing once it has run, or when the topic is already that way', () {
      expect(notice({'status_type': 'close', 'execute_at': at(const Duration(hours: -1))}), isNull);
      expect(notice({'status_type': 'close', 'execute_at': at(const Duration(hours: 1))}, closed: true),
          isNull);
      expect(notice({'status_type': 'open', 'execute_at': at(const Duration(hours: 1))}), isNull);
    });
  });

  test('the reason picks Discourse’s sentence by level and cause', () {
    expect(notificationReasonText(_en, 3, 6),
        'You will receive notifications because you are watching this category.');
    expect(notificationReasonText(_en, 2, 4),
        'You will see a count of new replies because you posted a reply to this topic.');
    expect(notificationReasonText(_en, 2, null),
        'You will see a count of new replies because you read this topic.');
    expect(notificationReasonText(_en, 1, 2),
        'You will be notified if someone mentions your @name or replies to you.');
    expect(notificationReasonText(_en, 0, 7),
        'You are ignoring all notifications in this category.');
  });

  group('the ⋮ menu', () {
    Future<List<String>> menu(WidgetTester tester, DiscourseTopicStatus? s,
        {PostsPageMessageMenu? message}) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: PostsPageAppBar(
            siteContext: _ctx(),
            title: 't',
            topicStatus: s,
            message: message,
            onNotifications: () {},
          ),
        ),
      ));
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();
      return [
        for (final i in tester.widgetList<PopupMenuItem<String>>(
            find.byType(PopupMenuItem<String>)))
          tester
              .widgetList<Text>(find.descendant(
                  of: find.byWidget(i), matching: find.byType(Text)))
              .first
              .data!,
      ];
    }

    const staff = {
      'can_close_topic': true,
      'can_pin_unpin_topic': true,
      'can_archive_topic': true,
      'can_toggle_topic_visibility': true,
      'can_edit': true,
      'can_delete': true,
    };

    testWidgets("staff get web's topic actions, in Discourse's words",
        (tester) async {
      final items = await menu(tester, DiscourseTopicStatus.fromTopicView({'details': staff}));
      expect(items, containsAll(['Close Topic', 'Pin Topic', 'Archive Topic', 'Unlist Topic', 'Delete Topic']));
      expect(items, isNot(contains('Lock')));
      expect(items, isNot(contains('Stick')));
    });

    testWidgets('each one reads the way back once applied', (tester) async {
      final items = await menu(
          tester,
          DiscourseTopicStatus.fromTopicView({
            'closed': true,
            'unpinned': true,
            'archived': true,
            'visible': false,
            'details': staff,
          }));
      expect(items, containsAll(['Open Topic', 'Un-Pin Topic', 'Unarchive Topic', 'List Topic']));
    });

    testWidgets('a deleted topic offers Un-Delete, not Delete', (tester) async {
      final items = await menu(
          tester,
          DiscourseTopicStatus.fromTopicView({
            'deleted_at': '2026-09-30T00:00:00Z',
            'details': {...staff, 'can_recover': true},
          }));
      expect(items, contains('Un-Delete Topic'));
      expect(items, isNot(contains('Delete Topic')));
    });

    testWidgets('readers get none of them', (tester) async {
      final items = await menu(tester, DiscourseTopicStatus.fromTopicView({}));
      expect(items, ['Refresh', 'Notifications']);
    });

    testWidgets("nor does a message, whose menu has its own", (tester) async {
      final items = await menu(
        tester,
        DiscourseTopicStatus.fromTopicView({'archetype': 'private_message', 'details': staff}),
        message: PostsPageMessageMenu(
          participantCount: 2,
          onParticipants: () {},
          isArchived: false,
          onArchive: () {},
          onMarkUnread: () {},
        ),
      );
      expect(items, contains('Archive'));
      expect(items, isNot(contains('Close Topic')));
      expect(items, isNot(contains('Delete Topic')));
    });
  });

  testWidgets('a message’s levels are described as a message’s', (tester) async {
    await tester.pumpWidget(_app(NotificationLevelSheet(
      target: NotificationLevelTarget.message,
      onLevelChanged: (_) async => true,
    )));
    expect(
        find.text('You will be notified of every new reply in this message, '
            'and a count of new replies will be shown.'),
        findsOneWidget);
    expect(find.text('Watching First Post'), findsNothing);
  });
}

class _Topics extends DiscourseTopicProxy {
  _Topics(super.context);
  final puts = <String>[];
  @override
  Future<Map<String, dynamic>> apiPut(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    puts.add(path);
    return const {'success': 'OK'};
  }
}

class _Factory implements SiteProxyFactory {
  _Factory(this.topics);
  final _Topics topics;

  @override
  IFCTopicProxy createTopicProxy(SiteContext context) => topics;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
