import 'dart:convert';

import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/chat_unread.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/chat/chat_channel_list_page.dart';
import 'package:discourse_ui/views/chat/chat_channel_view.dart';
import 'package:discourse_ui/views/chat/chat_search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// A conversation's header and settings, threads, My Threads, and chat
/// search, as Discourse's chat has them.
const _site = 'https://chat.example';

SiteContext _ctx() => SiteContext(
      siteType: 'thr-test',
      site: Site(
        id: null,
        name: 'Chat',
        url: _site,
        description: '',
        endpoint: null,
        baseUrl: _site,
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'thr-test',
      ),
    )..setLoginData(FCLoginResult(result: true, resultText: '', user: FCUser(id: '2', username: 'alice')));

Map<String, dynamic> _user(int id, String username) => {'id': id, 'username': username};

Map<String, dynamic> _msg(int id, int userId, String username, String text, {int? threadId, Map<String, dynamic>? thread}) => {
      'id': id,
      'chat_channel_id': 1,
      'message': text,
      'cooked': '<p>$text</p>',
      'created_at': DateTime.now().subtract(Duration(minutes: 60 - id)).toUtc().toIso8601String(),
      'user': _user(userId, username),
      if (threadId != null) 'thread_id': threadId,
      if (thread != null) 'thread': thread,
    };

Map<String, dynamic> _general({bool starred = false}) => {
      'id': 1,
      'title': 'general',
      'slug': 'general',
      'chatable_type': 'Category',
      'chatable': {'color': '0088CC'},
      'threading_enabled': true,
      'memberships_count': 12,
      'current_user_membership': {'starred': starred, 'muted': false, 'notification_level': 'mention', 'following': true},
      'meta': {'can_delete_self': true},
    };

void main() {
  late _Chat chat;

  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    DiscourseChatChannelDetails.clear();
    DiscourseChatMessageExtras.clear();
    DiscourseChatDrafts.clear();
    DiscourseChatSettings.clear();
    ChatUnread.clear();
    chat = _Chat(_ctx());
    SiteProxyFactory.register('thr-test', _Factory(chat));
    SiteProxyService.initialize(_ctx());
  });

  tearDown(Get.reset);

  Future<void> pumpHome(WidgetTester tester, Widget Function() page) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page())),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> openChannel(WidgetTester tester) =>
      pumpHome(tester, () => ChatChannelScreen(siteContext: _ctx(), channelId: 1, initialTitle: '#general'));

  /// A phone-tall screen, so a settings page fits without scrolling.
  void tall(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets("the header: the channel's name and members, and its settings", (tester) async {
    tall(tester);
    chat.messages = [_msg(10, 7, 'samr', 'hello')];
    await openChannel(tester);
    expect(find.text('#general'), findsOneWidget);
    expect(find.text('12 members'), findsOneWidget);

    await tester.tap(find.byTooltip('Channel settings'));
    await tester.pumpAndSettle();
    expect(find.text('Channel settings'), findsOneWidget);
    expect(find.text('Only for mentions'), findsOneWidget);
    expect(find.text('Sam Rivera'), findsOneWidget, reason: 'the members are listed');
    expect(find.text('Add Member'), findsNothing, reason: 'only group chats add people here');

    await tester.tap(find.text('Star channel'));
    await tester.pumpAndSettle();
    expect(chat.calls, contains('PUT /chat/api/channels/1/memberships/me {"starred":true}'));

    await tester.tap(find.text('Only for mentions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('For all activity'));
    await tester.pumpAndSettle();
    expect(chat.calls.last,
        'PUT /chat/api/channels/1/notifications-settings/me {"notifications_settings":{"notification_level":"always"}}');
    expect(find.text('For all activity'), findsOneWidget);

    await tester.tap(find.text('Leave channel'));
    await tester.pumpAndSettle();
    expect(chat.calls.last, 'DELETE /chat/api/channels/1/memberships/me');
    expect(find.text('open'), findsOneWidget, reason: 'leaving closes the conversation too');
  });

  testWidgets("a channel not joined yet: Join, and nothing to set or leave", (tester) async {
    tall(tester);
    chat.channel = {
      ..._general(),
      'current_user_membership': null,
      'meta': {'can_join_chat_channel': true},
    };
    chat.messages = [_msg(10, 7, 'samr', 'hello')];
    await openChannel(tester);
    await tester.tap(find.byTooltip('Channel settings'));
    await tester.pumpAndSettle();
    expect(find.text('Star channel'), findsNothing);
    expect(find.text('Leave channel'), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Join'));
    await tester.pumpAndSettle();
    expect(chat.calls, contains('POST /chat/api/channels/1/memberships/me'));
    expect(find.text('Star channel'), findsOneWidget);
    expect(find.text('Leave channel'), findsOneWidget);
  });

  testWidgets('a group chat adds people from its settings', (tester) async {
    tall(tester);
    chat.channel = {
      'id': 1,
      'title': 'priya, jonas',
      'chatable_type': 'DirectMessage',
      'chatable': {
        'group': true,
        'users': [_user(8, 'priya'), _user(9, 'jonas')],
      },
      'current_user_membership': {'following': true},
      'meta': {'can_remove_members': true},
    };
    chat.messages = [_msg(10, 8, 'priya', 'hi all')];
    await openChannel(tester);
    expect(find.text('Chat in group'), findsOneWidget);
    await tester.tap(find.byTooltip('Channel settings'));
    await tester.pumpAndSettle();
    expect(find.text('Add Member'), findsOneWidget);
    expect(find.byTooltip('Remove'), findsNWidgets(2), reason: 'everyone but the reader');
    expect(find.text('Chat in group'), findsNothing, reason: 'the conversation is under the settings');
    await tester.tap(find.text('Leave'));
    await tester.pumpAndSettle();
    expect(find.textContaining('re-invited'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(chat.calls.where((c) => c.startsWith('DELETE')), isEmpty);
  });

  testWidgets('a thread shows under its message, opens on a tap, and replies go in it', (tester) async {
    chat.messages = [
      _msg(10, 7, 'samr', 'Dinner on Saturday?', threadId: 5, thread: {
        'id': 5,
        'preview': {
          'reply_count': 3,
          'participant_count': 2,
          'participant_users': [_user(7, 'samr'), _user(8, 'kim')],
          'last_reply_created_at': DateTime.now().toUtc().toIso8601String(),
          'last_reply_excerpt': 'count me in',
          'last_reply_user': _user(8, 'kim'),
        },
      }),
    ];
    chat.threadMessages = [
      _msg(10, 7, 'samr', 'Dinner on Saturday?', threadId: 5),
      _msg(11, 8, 'kim', 'count me in', threadId: 5),
    ];
    await openChannel(tester);
    expect(find.text('3 replies'), findsOneWidget);
    expect(find.textContaining('kim: count me in', findRichText: true), findsOneWidget);

    await tester.tap(find.text('3 replies'));
    await tester.pumpAndSettle();
    expect(find.text('Thread'), findsOneWidget);
    expect(find.text('#general'), findsOneWidget, reason: 'the channel under the title');
    expect(find.text('count me in'), findsOneWidget);
    expect(find.text('Chat in thread'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'me too');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();
    expect(chat.sent.single, {'message': 'me too', 'thread_id': 5});
  });

  testWidgets('Reply in a channel with threads starts a thread, as the web does', (tester) async {
    chat.messages = [_msg(10, 7, 'samr', 'Anyone for lunch?')];
    await openChannel(tester);
    await tester.longPress(find.text('Anyone for lunch?'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Reply'));
    await tester.pumpAndSettle();
    expect(chat.calls, contains('POST /chat/api/channels/1/threads {"original_message_id":10}'));
    expect(find.text('Chat in thread'), findsOneWidget);
    expect(find.text('Replying to samr'), findsNothing);
  });

  testWidgets("My Threads lists the reader's threads", (tester) async {
    DiscourseChatSettings.set(_site, const DiscourseChatSettings(threadsEnabled: true));
    chat.list = {
      'public_channels': [_general()],
      'direct_message_channels': [],
    };
    chat.myThreads = {
      'threads': [
        {
          'id': 5,
          'channel_id': 1,
          'channel': {'id': 1, 'title': 'general'},
          'original_message': _msg(10, 7, 'samr', 'Dinner on Saturday?', threadId: 5),
          'preview': {'reply_count': 3, 'last_reply_excerpt': 'count me in', 'last_reply_user': _user(8, 'kim')},
        },
      ],
      'tracking': {
        'thread_tracking': {
          '5': {'unread_count': 1},
        },
      },
    };
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChatChannelListPage(siteContext: _ctx()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Threads'));
    await tester.pumpAndSettle();
    expect(find.text('Dinner on Saturday?'), findsOneWidget);
    expect(find.text('#general · 3 replies'), findsOneWidget);
    expect(find.text('1'), findsOneWidget, reason: 'unread replies');
  });

  testWidgets('search finds a message and opens its conversation there', (tester) async {
    chat.messages = [_msg(10, 7, 'samr', 'Dinner on Saturday?')];
    chat.search = {
      'messages': [
        {..._msg(10, 7, 'samr', 'Dinner on Saturday?'), 'channel': _general()},
      ],
    };
    await pumpHome(tester, () => ChatSearchPage(siteContext: _ctx()));
    await tester.enterText(find.byType(TextField), 'saturday');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('#general'), findsOneWidget);
    await tester.tap(find.text('Dinner on Saturday?'));
    await tester.pumpAndSettle();
    expect(find.byType(ChatChannelScreen), findsOneWidget);
    expect(chat.queries['/chat/api/channels/1/messages']?['target_message_id'], '10');
    // The message's highlight fades.
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('no results says so', (tester) async {
    await pumpHome(tester, () => ChatSearchPage(siteContext: _ctx(), channelId: 1, channelTitle: '#general'));
    await tester.enterText(find.byType(TextField), 'zebra');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('No results found'), findsOneWidget);
    expect(chat.queries['/chat/api/search']?['channel_id'], 1);
  });
}

class _Chat extends DiscourseChatProxy {
  _Chat(super.context);

  Map<String, dynamic>? channel;
  List<Map<String, dynamic>> messages = const [];
  List<Map<String, dynamic>> threadMessages = const [];
  Map<String, dynamic> list = const {};
  Map<String, dynamic> myThreads = const {};
  Map<String, dynamic> search = const {};
  final List<Map<String, dynamic>> sent = [];
  final List<String> calls = [];
  final Map<String, Map<String, dynamic>?> queries = {};

  String _b(Object? body) => body == null ? '' : ' ${jsonEncode(body)}';

  @override
  Future<Map<String, dynamic>> apiGet(String path, {Map<String, dynamic>? query}) async {
    queries[path] = query;
    switch (path) {
      case '/chat/api/channels/1':
        return {'channel': channel ?? _general()};
      case '/chat/api/channels/1/messages':
        return {'messages': messages.reversed.toList()};
      case '/chat/api/channels/1/threads/5':
      case '/chat/api/channels/1/threads/6':
        return {
          'thread': {'id': int.parse(path.split('/').last), 'channel_id': 1},
        };
      case '/chat/api/channels/1/threads/5/messages':
        return {'messages': threadMessages};
      case '/chat/api/channels/1/memberships':
        final dm = channel?['chatable_type'] == 'DirectMessage';
        return {
          'memberships': dm
              ? [
                  {'user': _user(2, 'alice')},
                  {'user': _user(8, 'priya')},
                  {'user': _user(9, 'jonas')},
                ]
              : [
                  {'user': _user(2, 'alice')},
                  {
                    'user': {..._user(7, 'samr'), 'name': 'Sam Rivera'},
                  },
                ],
          'meta': {'total_rows': dm ? 3 : 12},
        };
      case '/chat/api/me/channels':
        return list;
      case '/chat/api/me/threads':
        return myThreads;
      case '/chat/api/search':
        return search;
    }
    return const {};
  }

  @override
  Future<Map<String, dynamic>> apiPost(String path, {Map<String, dynamic>? query, Object? body}) async {
    calls.add('POST $path${_b(body)}');
    if (path == '/chat/1') {
      sent.add(Map<String, dynamic>.from(jsonDecode(jsonEncode(body)) as Map));
      return {'message_id': 99};
    }
    if (path == '/chat/api/channels/1/threads') return {'id': 6, 'channel_id': 1};
    return const {};
  }

  @override
  Future<Map<String, dynamic>> apiPut(String path, {Map<String, dynamic>? query, Object? body}) async {
    calls.add('PUT $path${_b(body)}');
    return const {};
  }

  @override
  Future<Map<String, dynamic>> apiDelete(String path, {Map<String, dynamic>? query, Object? body}) async {
    calls.add('DELETE $path${_b(body)}');
    return const {};
  }

  @override
  Future<FCChatActionResult> markChannelReadAsync(int channelId, {int? messageId}) async =>
      FCChatActionResult(result: true);

  @override
  Future<FCChatActionResult> markThreadReadAsync(int channelId, int threadId, {required int messageId}) async =>
      FCChatActionResult(result: true);

  @override
  void Function()? watchChannel(int channelId, void Function(DiscourseChatEvent event) onEvent) => () {};

  @override
  void Function()? watchThread(int channelId, int threadId, void Function(DiscourseChatEvent event) onEvent,
          {int lastId = -1}) =>
      () {};

  @override
  void Function()? watchChannelList(List<int> channelIds, void Function(DiscourseChatListEvent) onEvent) => () {};

  @override
  void Function() watchTyping(int channelId, void Function(List<DiscourseChatUser> typing) onChange, {int? threadId}) =>
      () {};

  @override
  Future<void> setTypingAsync(int channelId, {required bool typing, int? threadId}) async {}

  @override
  Future<FCChatActionResult> saveChatDraftAsync(int channelId, String text, {int? threadId}) async =>
      FCChatActionResult(result: true);
}

class _Factory implements SiteProxyFactory {
  _Factory(this.chat);
  final _Chat chat;

  @override
  IFCChatProxy createChatProxy(SiteContext context) => chat;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
