import 'dart:async';
import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/chat_unread.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/chat/chat_browse_channels_page.dart';
import 'package:discourse_ui/views/chat/chat_channel_list_page.dart';
import 'package:discourse_ui/views/chat/widgets/chat_channel_avatar.dart';
import 'package:discourse_ui/views/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// The chat list, rebuilt on Discourse's mobile chat: avatars, the last
/// message and its time, badges, Starred, live updates, browsing and
/// closing a DM.
const _site = 'https://chat.example';

SiteContext _ctx() => SiteContext(
      siteType: 'chat-test',
      site: Site(
        id: null,
        name: 'Chat',
        url: _site,
        description: '',
        endpoint: null,
        baseUrl: _site,
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'chat-test',
      ),
    )..setLoginData(FCLoginResult(
        result: true,
        resultText: '',
        user: FCUser(id: '2', username: 'alice')));

Map<String, dynamic> _user(int id, String username, {String? name}) => {
      'id': id,
      'username': username,
      if (name != null) 'name': name,
      'avatar_template': '/user_avatar/chat.example/$username/{size}/1_2.png',
    };

String _today(int hour) =>
    DateTime.now().copyWith(hour: hour, minute: 0).toUtc().toIso8601String();

Map<String, dynamic> _channel(int id, String title,
        {bool starred = false,
        bool muted = false,
        String? excerpt,
        String? emoji}) =>
    {
      'id': id,
      'title': title,
      'chatable_type': 'Category',
      'chatable': {'color': '0088CC'},
      if (emoji != null) 'emoji': emoji,
      'memberships_count': 12,
      'current_user_membership': {
        'starred': starred,
        'muted': muted,
        'following': true
      },
      if (excerpt != null)
        'last_message': {
          'id': id * 10,
          'excerpt': excerpt,
          'created_at': _today(9)
        },
    };

Map<String, dynamic> _dm(int id, String title, List<Map<String, dynamic>> users,
        {String? excerpt, bool group = false}) =>
    {
      'id': id,
      'title': title,
      'chatable_type': 'DirectMessage',
      'chatable': {'group': group, 'users': users},
      'current_user_membership': {'following': true},
      if (excerpt != null)
        'last_message': {
          'id': id * 10,
          'excerpt': excerpt,
          'created_at': _today(10)
        },
    };

void main() {
  late _Chat chat;

  setUp(() {
    DiscourseChatChannelDetails.clear();
    DiscourseChatSettings.clear();
    DiscourseCustomEmoji.clear();
    DiscourseCustomEmoji.fetchOverride = (_) async => <String, dynamic>{};
    ChatUnread.clear();
    chat = _Chat(_ctx());
    SiteProxyFactory.register('chat-test', _Factory(chat));
    SiteProxyService.initialize(_ctx());
  });

  tearDown(() => DiscourseCustomEmoji.fetchOverride = null);

  Future<void> pump(WidgetTester tester,
      {double textScale = 1, bool dark = false}) async {
    await tester.pumpWidget(MaterialApp(
      theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChatChannelListPage(siteContext: _ctx()),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> showDms(WidgetTester tester) async {
    await tester.tap(find.text('DMs'));
    await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    for (final size in [const Size(393, 851), const Size(851, 393)]) {
      testWidgets(
          'chat navigation and discovery at large text ($size, dark=$dark)',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        DiscourseChatSettings.set(
            _site, const DiscourseChatSettings(threadsEnabled: true));
        chat.browse = {
          'channels': [
            {
              'id': 9,
              'title': 'Community planning',
              'description': 'Ideas for our next community event',
              'chatable_type': 'Category',
              'memberships_count': 30,
              'meta': {'can_join_chat_channel': true},
            },
          ],
        };
        await pump(tester, textScale: 2, dark: dark);
        expect(tester.takeException(), isNull);
        for (final label in ['Channels', 'DMs', 'My Threads']) {
          final paragraph =
              tester.renderObject<RenderParagraph>(find.text(label));
          expect(paragraph.didExceedMaxLines, isFalse,
              reason: 'navigation labels must remain readable: $label');
        }
        await tester.ensureVisible(find.text('DMs'));
        await tester.tap(find.text('DMs'));
        await tester.pumpAndSettle();
        expect(find.text('You have not joined any direct messages yet!'), findsOneWidget);
        await tester.ensureVisible(find.text('Channels'));
        await tester.tap(find.text('Channels'));
        await tester.pumpAndSettle();
        final tile = find.byKey(const ValueKey('available-channel-9'));
        await tester.ensureVisible(tile);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final title = tester
            .renderObject<RenderParagraph>(find.text('Community planning'));
        expect(title.didExceedMaxLines, isFalse,
            reason:
                'a short channel name must remain readable with large text');
        await tester.ensureVisible(find.text('Join'));
        await tester.tap(find.text('Join'));
        await tester.pumpAndSettle();
        expect(
            chat.calls, contains('POST /chat/api/channels/9/memberships/me'));
      });
    }
  }

  testWidgets("a DM shows the person's avatar, the last message and its time",
      (tester) async {
    chat.list = {
      'public_channels': [_channel(1, 'general')],
      'direct_message_channels': [
        _dm(5, 'samr', [_user(7, 'samr', name: 'Sam Rivera')],
            excerpt: 'see you at 3'),
        _dm(6, 'priya, jonas', [_user(8, 'priya'), _user(9, 'jonas')],
            excerpt: 'notes are up', group: true),
      ],
      'tracking': {
        'channel_tracking': {
          '5': {'unread_count': 2, 'mention_count': 0},
        },
      },
    };
    await pump(tester);
    await showDms(tester);
    final avatars =
        tester.widgetList<UserAvatar>(find.byType(UserAvatar)).toList();
    expect(
        avatars.map((a) => a.username), containsAll(['samr', 'priya', 'jonas']),
        reason: 'a group chat shows two of its people');
    expect(avatars.firstWhere((a) => a.username == 'samr').iconUrl,
        'https://chat.example/user_avatar/chat.example/samr/96/1_2.png');
    expect(find.text('see you at 3'), findsOneWidget);
    expect(find.text('notes are up'), findsOneWidget);
    expect(find.text('2'), findsOneWidget,
        reason: 'unread DMs count as a number');
    // Unread first.
    expect(tester.getTopLeft(find.text('samr')).dy,
        lessThan(tester.getTopLeft(find.text('priya, jonas')).dy));
    expect(ChatUnread.of(_ctx()).value,
        const ChatUnreadState(urgent: 2, any: true));
  });

  testWidgets(
      'channels: starred first, a mention as a number, unread as a dot, muted dimmed',
      (tester) async {
    chat.list = {
      'public_channels': [
        _channel(1, 'general', excerpt: 'release is out'),
        _channel(2, 'support',
            starred: true,
            excerpt: 'try clearing the cache',
            emoji: 'hammer_and_wrench'),
        _channel(3, 'off-topic', muted: true),
      ],
      'direct_message_channels': [],
      'tracking': {
        'channel_tracking': {
          '1': {'unread_count': 4, 'mention_count': 1},
          '2': {'unread_count': 1, 'mention_count': 0},
          '3': {'unread_count': 9, 'mention_count': 0},
        },
      },
    };
    await pump(tester);
    expect(find.text('Starred'), findsOneWidget);
    expect(tester.getTopLeft(find.text('support')).dy,
        lessThan(tester.getTopLeft(find.text('general')).dy));
    expect(find.text('1'), findsOneWidget, reason: "general's mention");
    expect(find.text('9'), findsNothing, reason: 'muted: no badge');
    expect(
        find.ancestor(
            of: find.text('off-topic'), matching: find.byType(Opacity)),
        findsOneWidget);
    expect(find.byType(ChatChannelAvatar), findsNWidgets(3));
    expect(find.text('Joined channels'), findsOneWidget);
    expect(find.text('Available channels'), findsOneWidget);
    expect(ChatUnread.of(_ctx()).value,
        const ChatUnreadState(urgent: 1, any: true));
  });

  testWidgets(
      'live: a new message moves its excerpt and badge without a refresh',
      (tester) async {
    chat.list = {
      'public_channels': [],
      'direct_message_channels': [
        _dm(5, 'samr', [_user(7, 'samr')], excerpt: 'hello')
      ],
    };
    await pump(tester);
    await showDms(tester);
    expect(chat.watched, [5]);
    DiscourseChatChannelDetails.update(
        _site, 5, (d) => d.copyWith(lastMessageExcerpt: 'on my way'));
    chat.onEvent!(const DiscourseChatListNewMessage(
        channelId: 5, fromReader: false, threadReply: false));
    chat.onEvent!(const DiscourseChatListTracking(
        channelId: 5, unreadCount: 1, mentionCount: 0));
    await tester.pump();
    expect(find.text('on my way'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(ChatUnread.of(_ctx()).value.urgent, 1);
  });

  testWidgets('no joined channels: discover and join directly on the main page',
      (tester) async {
    chat.list = {'public_channels': [], 'direct_message_channels': []};
    chat.browse = {
      'channels': [
        {
          'id': 9,
          'title': 'off-topic',
          'description': 'Anything goes',
          'chatable_type': 'Category',
          'memberships_count': 30,
          'meta': {'can_join_chat_channel': true},
        },
      ],
    };
    await pump(tester);
    expect(find.byType(ChatBrowseChannelsPage), findsNothing);
    expect(find.text('Available channels'), findsOneWidget);
    expect(find.text('Anything goes'), findsOneWidget);
    expect(find.text('30 members'), findsOneWidget);
    await tester.tap(find.text('Join'));
    await tester.pumpAndSettle();
    expect(chat.calls, contains('POST /chat/api/channels/9/memberships/me'));
    expect(find.text('Join'), findsNothing);
    expect(find.text('off-topic'), findsOneWidget);
    expect(tester.getTopLeft(find.text('off-topic')).dy,
        lessThan(tester.getTopLeft(find.text('Available channels')).dy));
  });

  testWidgets('discovery excludes joined channels and private conversations',
      (tester) async {
    chat.list = {
      'public_channels': [_channel(1, 'general')],
      'direct_message_channels': []
    };
    chat.browse = {
      'channels': [
        _channel(1, 'general'),
        {
          'id': 9,
          'title': 'Members-only planning',
          'chatable_type': 'Category',
          'meta': {'can_join_chat_channel': true}
        },
        {
          'id': 10,
          'title': 'Archived notes',
          'chatable_type': 'Category',
          'status': 'archived',
          'meta': {'can_join_chat_channel': false}
        },
        _dm(11, 'private conversation', [_user(7, 'samr')]),
      ]
    };
    await pump(tester);
    expect(find.text('general'), findsOneWidget);
    expect(find.text('Members-only planning'), findsOneWidget);
    expect(find.text('private conversation'), findsNothing);
    expect(find.text('Join'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);
    expect(find.text('Archived'), findsOneWidget);
  });

  testWidgets(
      'discovery errors leave joined channels usable and can be retried',
      (tester) async {
    chat.list = {
      'public_channels': [_channel(1, 'general')],
      'direct_message_channels': []
    };
    chat.failDiscovery = true;
    await pump(tester);
    expect(find.text('general'), findsOneWidget);
    expect(find.text('Discovery unavailable'), findsOneWidget);
    chat.failDiscovery = false;
    chat.browse = {
      'channels': [
        {
          'id': 9,
          'title': 'New channel',
          'meta': {'can_join_chat_channel': true}
        }
      ]
    };
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('New channel'), findsOneWidget);
    expect(find.text('Discovery unavailable'), findsNothing);
  });

  testWidgets('failed joins keep the channel in discovery', (tester) async {
    chat.list = {'public_channels': [], 'direct_message_channels': []};
    chat.browse = {
      'channels': [
        {
          'id': 9,
          'title': 'New channel',
          'meta': {'can_join_chat_channel': true}
        }
      ]
    };
    chat.failJoin = true;
    await pump(tester);
    await tester.tap(find.text('Join'));
    await tester.pump();
    expect(find.text('Join denied'), findsOneWidget);
    expect(tester.getTopLeft(find.text('New channel')).dy,
        greaterThan(tester.getTopLeft(find.text('Available channels')).dy));
    expect(find.text('Join'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets(
      'pagination advances past followed channels without false empty state',
      (tester) async {
    chat.list = {
      'public_channels': [_channel(1, 'general')],
      'direct_message_channels': []
    };
    chat.browsePages = {
      0: {
        'channels': [
          for (var id = 1; id <= 25; id++) _channel(id, 'followed $id')
        ]
      },
      25: {
        'channels': [
          {
            'id': 26,
            'title': 'Next page channel',
            'meta': {'can_join_chat_channel': true}
          }
        ]
      },
    };
    await pump(tester);
    expect(find.text('You have joined all available channels.'), findsNothing);
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(chat.browseOffsets, [0, 25]);
    expect(find.text('Next page channel'), findsOneWidget);
    expect(find.text('Load more'), findsNothing);
  });

  testWidgets('logging out discards an in-flight channel response',
      (tester) async {
    final reader = _ctx();
    chat.pendingList = Completer<Map<String, dynamic>>();
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChatChannelListPage(siteContext: reader),
    ));
    await tester.pump();
    reader.setLoginData(null);
    await tester.pump();
    chat.pendingList!.complete({
      'public_channels': [_channel(1, 'Old account channel')]
    });
    await tester.pumpAndSettle();
    expect(find.text('Sign in to use chat'), findsOneWidget);
    expect(find.text('Old account channel'), findsNothing);
    expect(chat.watched, isNull);
  });

  testWidgets('a swipe closes a DM', (tester) async {
    chat.list = {
      'public_channels': [_channel(1, 'general')],
      'direct_message_channels': [
        _dm(5, 'samr', [_user(7, 'samr')], excerpt: 'hi')
      ],
    };
    await pump(tester);
    await showDms(tester);
    await tester.drag(find.text('samr'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(chat.calls,
        contains('DELETE /chat/api/channels/5/memberships/me/follows'));
    expect(find.text('samr'), findsNothing);
  });

  testWidgets('the button says New message', (tester) async {
    chat.list = {
      'public_channels': [_channel(1, 'general')],
      'direct_message_channels': []
    };
    await pump(tester);
    expect(find.text('New message'), findsOneWidget);
  });
}

class _Chat extends DiscourseChatProxy {
  _Chat(super.context);

  Completer<Map<String, dynamic>>? pendingList;
  bool failDiscovery = false;
  bool failJoin = false;
  @override
  Future<FCChatChannelListResult> browseChannelsAsync(
      {String filter = "",
      String? status,
      int offset = 0,
      int limit = 25}) async {
    if (failDiscovery) {
      return FCChatChannelListResult(
          result: false, resultText: "Discovery unavailable");
    }
    return super.browseChannelsAsync(
        filter: filter, status: status, offset: offset, limit: limit);
  }

  @override
  Future<FCChatActionResult> joinChannelAsync(int id) async {
    if (failJoin) {
      return FCChatActionResult(result: false, resultText: "Join denied");
    }
    return super.joinChannelAsync(id);
  }

  Map<String, dynamic> list = const {};
  Map<String, dynamic> browse = const {};
  Map<int, Map<String, dynamic>> browsePages = {};
  final List<int> browseOffsets = [];
  final List<String> calls = [];
  List<int>? watched;
  void Function(DiscourseChatListEvent)? onEvent;

  @override
  Future<Map<String, dynamic>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    calls.add('GET $path');
    if (path == '/chat/api/me/channels') {
      return pendingList?.future ?? Future.value(list);
    }
    if (path == '/chat/api/channels') {
      final offset = query?['offset'] as int? ?? 0;
      browseOffsets.add(offset);
      return browsePages[offset] ?? browse;
    }
    return const {};
  }

  @override
  Future<Map<String, dynamic>> apiPost(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    calls.add('POST $path');
    if (path.contains('/memberships/me')) {
      final id = int.parse(path.split('/')[4]);
      final row = (browse['channels'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere((c) => c['id'] == id);
      row['current_user_membership'] = {'following': true};
      list = {
        ...list,
        'public_channels': [...(list['public_channels'] as List? ?? []), row]
      };
    }
    return const {};
  }

  @override
  Future<Map<String, dynamic>> apiDelete(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    calls.add('DELETE $path');
    return const {};
  }

  @override
  void Function()? watchChannelList(
      List<int> channelIds, void Function(DiscourseChatListEvent) onEvent) {
    watched = channelIds;
    this.onEvent = onEvent;
    return () {};
  }
}

class _Factory implements SiteProxyFactory {
  _Factory(this.chat);
  final _Chat chat;

  @override
  IFCChatProxy createChatProxy(SiteContext context) => chat;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
