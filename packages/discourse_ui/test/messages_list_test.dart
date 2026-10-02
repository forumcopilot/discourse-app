import 'dart:convert';

import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/private_messaging/tabs/private_message_list_tab.dart';
import 'package:discourse_ui/views/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// The messages page as Discourse's: New and Unread with their counts, a
/// group's inbox with its own filters, who is in each message, swipe to
/// archive, and messages arriving announced over the list.
const _site = 'https://pm.example';

SiteContext _ctx() => SiteContext(
      siteType: 'pm-test',
      site: Site(
        id: null,
        name: 'PM',
        url: _site,
        description: '',
        endpoint: null,
        baseUrl: _site,
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'pm-test',
      ),
    )..setLoginData(FCLoginResult(result: true, resultText: '', user: FCUser(id: '2', username: 'alice')));

Map<String, dynamic> _topic(int id, String title, List<int> posters, {int minutesAgo = 0}) => {
      'id': id,
      'title': title,
      'posts_count': 2,
      'last_posted_at': DateTime.now().subtract(Duration(minutes: minutesAgo)).toUtc().toIso8601String(),
      'archetype': 'private_message',
      'posters': [
        for (var i = 0; i < posters.length; i++)
          {'user_id': posters[i], 'extras': i == posters.length - 1 ? 'latest' : ''},
      ],
    };

const _users = [
  {'id': 2, 'username': 'alice', 'avatar_template': '/a/alice/{size}.png'},
  {'id': 7, 'username': 'samr', 'avatar_template': '/a/samr/{size}.png'},
  {'id': 8, 'username': 'kim', 'avatar_template': '/a/kim/{size}.png'},
];

void main() {
  late _Messages pm;

  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    DiscourseMessageTracking.clear();
    pm = _Messages(_ctx());
    SiteProxyFactory.register('pm-test', _Factory(pm));
    SiteProxyService.initialize(_ctx());
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: PrivateMessageListTab(siteContext: _ctx(), isActive: true)),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('New and Unread carry their counts', (tester) async {
    pm.tracking = [
      {'topic_id': 1, 'last_read_post_number': null, 'highest_post_number': 1, 'group_ids': []},
      {'topic_id': 2, 'last_read_post_number': 1, 'highest_post_number': 3, 'notification_level': 3, 'group_ids': []},
      {'topic_id': 3, 'last_read_post_number': 1, 'highest_post_number': 2, 'notification_level': 2, 'group_ids': []},
    ];
    await pump(tester);
    expect(find.text('Unread (2)'), findsOneWidget);
    expect(find.text('New (1)'), findsOneWidget);
    expect(find.byType(PopupMenuButton<String>), findsNothing, reason: 'no group inboxes, no inbox menu');
  });

  testWidgets("a group's inbox, picked from the menu, has its own filters and counts", (tester) async {
    pm.groups = [
      {'id': 41, 'name': 'team', 'full_name': 'The Team', 'has_messages': true},
    ];
    pm.tracking = [
      {'topic_id': 5, 'last_read_post_number': null, 'highest_post_number': 1, 'group_ids': [41]},
    ];
    await pump(tester);
    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('New'), findsOneWidget, reason: "the group's message is not in the personal count");
    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget, reason: 'the group has one waiting');
    await tester.tap(find.text('team').last);
    await tester.pumpAndSettle();
    expect(find.text('Sent'), findsNothing);
    expect(find.text('New (1)'), findsOneWidget);
    await tester.tap(find.text('New (1)'));
    await tester.pumpAndSettle();
    expect(pm.paths, contains('/topics/private-messages-group/alice/team/new.json'));
  });

  testWidgets('a row shows who else is in it; a group message two of them', (tester) async {
    pm.inbox = [
      _topic(10, 'Lunch?', [2, 7]),
      _topic(11, 'Offsite', [2, 7, 8], minutesAgo: 5),
    ];
    await pump(tester);
    final names = tester.widgetList<UserAvatar>(find.byType(UserAvatar)).map((a) => a.username).toList();
    expect(names, ['samr', 'samr', 'kim'], reason: 'never the reader; the latest poster in front');
  });

  testWidgets('a swipe archives, and Undo moves it back', (tester) async {
    pm.inbox = [_topic(10, 'Lunch?', [2, 7])];
    await pump(tester);
    await tester.drag(find.text('Lunch?'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Lunch?'), findsNothing);
    expect(pm.calls, ['PUT /t/10/archive-message.json']);
    expect(find.text('Message archived'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(pm.calls.last, 'PUT /t/10/move-to-inbox.json');
    expect(find.text('Lunch?'), findsOneWidget);
  });

  testWidgets('a message arriving is announced over the list, and a tap shows it', (tester) async {
    pm.inbox = [_topic(10, 'Lunch?', [2, 7])];
    await pump(tester);
    pm.onIncoming!({
      'topic_id': 12,
      'message_type': 'new_topic',
      'payload': {'group_ids': [], 'created_by_user_id': 7},
    }, 'new_topic');
    await tester.pump();
    expect(find.text('See 1 new or updated topic'), findsOneWidget);
    pm.inbox = [_topic(12, 'Hello', [7]), ...pm.inbox];
    await tester.tap(find.text('See 1 new or updated topic'));
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);
    expect(find.textContaining('new or updated'), findsNothing);
  });
}

class _Messages extends DiscoursePrivateConversationProxy {
  _Messages(super.context);

  List<Map<String, dynamic>> inbox = const [];
  List<Map<String, dynamic>> groups = const [];
  List<Map<String, dynamic>> tracking = const [];
  final List<String> paths = [];
  final List<String> calls = [];
  void Function(Map<String, dynamic> message, String type)? onIncoming;

  @override
  Future<Map<String, dynamic>> apiGet(String path, {Map<String, dynamic>? query}) async {
    paths.add(path);
    if (path == '/u/alice.json') {
      return {
        'user': {'username': 'alice', 'groups': groups},
      };
    }
    if (path == '/u/alice/private-message-topic-tracking-state.json') return {'_value': tracking};
    if (path == '/topics/private-messages/alice.json') {
      return {
        'users': _users,
        'topic_list': {'topics': inbox},
      };
    }
    return const {
      'topic_list': {'topics': []},
    };
  }

  @override
  Future<Map<String, dynamic>> apiPut(String path, {Map<String, dynamic>? query, Object? body}) async {
    calls.add('PUT $path${body == null || (body is Map && body.isEmpty) ? '' : ' ${jsonEncode(body)}'}');
    return const {};
  }

  @override
  void Function()? watchMessageTracking(
      List<int> groupIds, void Function(Map<String, dynamic> message, String type) onIncoming) {
    this.onIncoming = onIncoming;
    return () {};
  }
}

class _Factory implements SiteProxyFactory {
  _Factory(this.pm);
  final _Messages pm;

  @override
  IFCPrivateConversationProxy createPrivateConversationProxy(SiteContext context) => pm;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
