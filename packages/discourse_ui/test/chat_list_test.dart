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

Map<String, dynamic> _threads(String title) => {
      'threads': [
        {'id': 5, 'channel_id': 1, 'title': title},
      ],
    };

void main() {
  late _Chat chat;
  var emojiListFetches = 0;

  setUp(() {
    DiscourseChatChannelDetails.clear();
    DiscourseChatSettings.clear();
    DiscourseCustomEmoji.clear();
    DiscourseEmojiSet.clear();
    emojiListFetches = 0;
    DiscourseCustomEmoji.fetchOverride = (_) async {
      emojiListFetches++;
      return <String, dynamic>{};
    };
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
    // Discourse's words: no invented "Joined channels" / "Available
    // channels" headings; the channels to join sit under "Browse channels".
    expect(find.text('Joined channels'), findsNothing);
    expect(find.text('Available channels'), findsNothing);
    expect(find.text('Browse channels'), findsOneWidget);
    expect(ChatUnread.of(_ctx()).value,
        const ChatUnreadState(urgent: 1, any: true));
  });

  testWidgets(
      "channel emoji: the forum's artwork without /emojis.json, and no "
      'shortcode read before the name', (tester) async {
    final semantics = tester.ensureSemantics();
    DiscourseEmojiSet.set(_site, 'twitter');
    chat.list = {
      'public_channels': [_channel(2, 'support', emoji: 'computer')],
      'direct_message_channels': [],
    };
    await pump(tester);
    expect(emojiListFetches, 0,
        reason: 'a standard emoji has a known address in the set');
    final image = tester.widget<Image>(find.descendant(
        of: find.byType(ChatChannelAvatar), matching: find.byType(Image)));
    expect(((image.image as ResizeImage).imageProvider as NetworkImage).url,
        '$_site/images/emoji/twitter/computer.png?v=15');
    expect(find.bySemanticsLabel(RegExp(':computer:|💻')), findsNothing);
    expect(find.bySemanticsLabel(RegExp('support')), findsWidgets);
    semantics.dispose();
  });

  testWidgets('live: a new message moves its excerpt and badge without a refresh',
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
    expect(find.text('Browse channels'), findsOneWidget);
    expect(find.text('Anything goes'), findsOneWidget);
    expect(find.text('30 members'), findsOneWidget);
    await tester.tap(find.text('Join'));
    await tester.pumpAndSettle();
    expect(chat.calls, contains('POST /chat/api/channels/9/memberships/me'));
    expect(find.text('Join'), findsNothing);
    expect(find.text('off-topic'), findsOneWidget);
    expect(tester.getTopLeft(find.text('off-topic')).dy,
        lessThan(tester.getTopLeft(find.text('Browse channels')).dy));
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
    // As the web's card: no button where there is nothing to do; a tap
    // opens the channel.
    expect(find.text('View'), findsNothing);
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
        greaterThan(tester.getTopLeft(find.text('Browse channels')).dy));
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
    // A page of channels the reader has all joined reads the next at once,
    // rather than leaving only Load more.
    expect(chat.browseOffsets, [0, 25]);
    expect(find.text('No channels found'), findsNothing);
    expect(find.text('Next page channel'), findsOneWidget);
    expect(find.text('Load more'), findsNothing);
  });

  testWidgets('reading on alone stops after a few pages', (tester) async {
    chat.list = {
      'public_channels': [_channel(1, 'general')],
      'direct_message_channels': []
    };
    chat.browseAll = [
      for (var id = 1; id <= 200; id++) _channel(id, 'followed $id')
    ];
    await pump(tester);
    expect(chat.browseOffsets, [0, 25, 50, 75]);
    await tester.ensureVisible(find.text('Load more'));
      await tester.pumpAndSettle();
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(chat.browseOffsets, [0, 25, 50, 75, 100, 125, 150, 175]);
  });

  group('discovery keeps the pages the reader loaded', () {
    Map<String, dynamic> joinable(int id) => {
          'id': id,
          'title': 'open $id',
          'chatable_type': 'Category',
          'meta': {'can_join_chat_channel': true},
        };

    Future<void> loadTwoPages(WidgetTester tester) async {
      chat.list = {
        'public_channels': [_channel(100, 'general')],
        'direct_message_channels': [
          _dm(5, 'samr', [_user(7, 'samr')])
        ],
      };
      chat.browseAll = [for (var id = 1; id <= 26; id++) joinable(id)];
      await pump(tester);
      await tester.ensureVisible(find.text('Load more'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Load more'));
      await tester.pumpAndSettle();
      expect(chat.browseOffsets, [0, 25]);
      expect(find.text('open 26'), findsOneWidget);
    }

    testWidgets('when the list is read again (back from a channel, a change)',
        (tester) async {
      await loadTwoPages(tester);
      final listReads =
          chat.calls.where((c) => c == 'GET /chat/api/me/channels').length;
      chat.onEvent!(const DiscourseChatListChanged());
      await tester.pumpAndSettle();
      expect(chat.calls.where((c) => c == 'GET /chat/api/me/channels'),
          hasLength(listReads + 1));
      expect(chat.browseOffsets, [0, 25],
          reason: 'no second request for the channels to join');
      expect(find.text('open 26'), findsOneWidget);
    });

    testWidgets('after a join', (tester) async {
      await loadTwoPages(tester);
      // Mid-screen, clear of the floating button.
      Scrollable.ensureVisible(
          tester.element(find.byKey(const ValueKey('available-channel-3'))),
          alignment: 0.5);
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(
          of: find.byKey(const ValueKey('available-channel-3')),
          matching: find.text('Join')));
      await tester.pumpAndSettle();
      expect(chat.calls, contains('POST /chat/api/channels/3/memberships/me'));
      expect(chat.browseOffsets, [0, 25]);
      expect(find.byKey(const ValueKey('available-channel-3')), findsNothing,
          reason: 'joined: in the list above now');
      expect(find.text('open 26'), findsOneWidget);
    });

    testWidgets('a pull to refresh reads them all again in one request',
        (tester) async {
      await loadTwoPages(tester);
      await tester.widget<RefreshIndicator>(find.byType(RefreshIndicator))
          .onRefresh();
      await tester.pumpAndSettle();
      expect(chat.browseQueries, hasLength(3));
      expect(chat.browseQueries.last, containsPair('offset', 0));
      expect(chat.browseQueries.last, containsPair('limit', 26));
      expect(find.text('open 26'), findsOneWidget);
    });

    testWidgets('across DMs and back', (tester) async {
      await loadTwoPages(tester);
      await tester.dragUntilVisible(
          find.text('DMs'), find.byType(ListView), const Offset(0, 300));
      await tester.pumpAndSettle();
      await showDms(tester);
      await tester.tap(find.text('Channels'));
      await tester.pumpAndSettle();
      expect(chat.browseOffsets, [0, 25]);
      await tester.dragUntilVisible(
          find.text('open 26'), find.byType(ListView), const Offset(0, -300));
      expect(find.text('open 26'), findsOneWidget);
    });

    testWidgets('a channel left elsewhere is offered again', (tester) async {
      await loadTwoPages(tester);
      chat.list = {
        'public_channels': [],
        'direct_message_channels': chat.list['direct_message_channels'],
      };
      chat.browseAll = [
        {
          ..._channel(100, 'general'),
          'current_user_membership': {'following': false},
          'meta': {'can_join_chat_channel': true},
        },
        ...?chat.browseAll,
      ];
      chat.onEvent!(const DiscourseChatListChanged());
      await tester.pumpAndSettle();
      expect(chat.browseQueries.last, containsPair('offset', 0));
      expect(find.byKey(const ValueKey('available-channel-100')),
          findsOneWidget);
    });

    testWidgets('another account starts over', (tester) async {
      final reader = _ctx();
      chat.list = {
        'public_channels': [_channel(100, 'general')],
        'direct_message_channels': [],
      };
      chat.browseAll = [for (var id = 1; id <= 26; id++) joinable(id)];
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChatChannelListPage(siteContext: reader),
      ));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Load more'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Load more'));
      await tester.pumpAndSettle();
      reader.setLoginData(null);
      await tester.pump();
      reader.setLoginData(FCLoginResult(
          result: true, resultText: '', user: FCUser(id: '3', username: 'bob')));
      await tester.pumpAndSettle();
      expect(chat.browseOffsets, [0, 25, 0]);
      expect(find.text('open 26'), findsNothing);
    });
  });

  testWidgets('Retry after a failed refresh reads the pages again',
      (tester) async {
    chat.list = {
      'public_channels': [_channel(100, 'general')],
      'direct_message_channels': [],
    };
    chat.browseAll = [
      for (var id = 1; id <= 26; id++)
        {
          'id': id,
          'title': 'open $id',
          'meta': {'can_join_chat_channel': true},
        }
    ];
    await pump(tester);
    await tester.ensureVisible(find.text('Load more'));
      await tester.pumpAndSettle();
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    chat.failDiscovery = true;
    await tester.widget<RefreshIndicator>(find.byType(RefreshIndicator))
        .onRefresh();
    await tester.pumpAndSettle();
    expect(find.text('Discovery unavailable'), findsOneWidget);
    expect(find.text('open 26'), findsOneWidget,
        reason: 'what was shown stays while the refresh failed');
    chat.failDiscovery = false;
    await tester.ensureVisible(find.text('Retry'));
      await tester.pumpAndSettle();
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(chat.browseQueries.last, containsPair('offset', 0),
        reason: 'not appended after the pages already shown');
    expect(find.text('Discovery unavailable'), findsNothing);
    expect(find.text('open 26'), findsOneWidget);
  });

  test("a channel's status is translated in every language", () {
    final en = lookupAppLocalizations(const Locale('en'));
    for (final locale in AppLocalizations.supportedLocales) {
      if (locale.languageCode == 'en') continue;
      final l10n = lookupAppLocalizations(locale);
      for (final (word, english) in [
        (l10n.chatChannelStatusReadOnly, en.chatChannelStatusReadOnly),
        (l10n.chatChannelStatusClosed, en.chatChannelStatusClosed),
        (l10n.chatChannelStatusArchived, en.chatChannelStatusArchived),
      ]) {
        expect(word, isNot(english), reason: '$locale');
      }
    }
  });

  testWidgets("every channel joined: the web's empty Browse channels line",
      (tester) async {
    chat.list = {
      'public_channels': [_channel(1, 'general')],
      'direct_message_channels': [],
    };
    chat.browse = {
      'channels': [_channel(1, 'general')]
    };
    await pump(tester);
    expect(find.text('No channels found'), findsOneWidget);
    expect(find.text('You have joined all available channels.'), findsNothing);
  });

  testWidgets('a channel with no members shows no count, as on the web',
      (tester) async {
    chat.list = {'public_channels': [], 'direct_message_channels': []};
    chat.browse = {
      'channels': [
        {
          'id': 9,
          'title': 'brand new',
          'memberships_count': 0,
          'meta': {'can_join_chat_channel': true},
        },
      ],
    };
    await pump(tester);
    expect(find.text('brand new'), findsOneWidget);
    expect(find.text('0 members'), findsNothing);
  });

  group('joining, as the web allows it', () {
    testWidgets('only an open channel is offered to join', (tester) async {
      chat.list = {'public_channels': [], 'direct_message_channels': []};
      chat.browse = {
        'channels': [
          {
            'id': 9,
            'title': 'announcements',
            'status': 'read_only',
            'meta': {'can_join_chat_channel': true},
          },
          {
            'id': 10,
            'title': 'lounge',
            'meta': {'can_join_chat_channel': true},
          },
        ],
      };
      await pump(tester);
      expect(
          find.descendant(
              of: find.byKey(const ValueKey('available-channel-9')),
              matching: find.text('Join')),
          findsNothing,
          reason: 'a read-only channel would vanish from both lists');
      expect(find.text('Read Only'), findsOneWidget,
          reason: "Discourse's status word, not the composer's hint");
      expect(find.textContaining('cannot send new messages'), findsNothing);
      expect(
          find.descendant(
              of: find.byKey(const ValueKey('available-channel-10')),
              matching: find.text('Join')),
          findsOneWidget);
    });

    testWidgets('discovery asks for open channels', (tester) async {
      chat.list = {'public_channels': [], 'direct_message_channels': []};
      await pump(tester);
      expect(chat.browseQueries.single, containsPair('status', 'open'));
    });
  });

  group('Browse channels', () {
    Future<void> openBrowse(WidgetTester tester) async {
      await tester.ensureVisible(find.text('Browse channels'));
      await tester.tap(find.text('Browse channels'));
      await tester.pumpAndSettle();
      expect(find.byType(ChatBrowseChannelsPage), findsOneWidget);
    }

    setUp(() {
      chat.list = {
        'public_channels': [_channel(1, 'general')],
        'direct_message_channels': [],
      };
    });

    testWidgets("opens from the chat list, on the web's Open tab",
        (tester) async {
      chat.browseAll = [
        {..._channel(1, 'general')},
        {
          'id': 2,
          'title': 'planning',
          'meta': {'can_join_chat_channel': true}
        },
        {
          'id': 3,
          'title': 'old news',
          'status': 'closed',
          'meta': {'can_join_chat_channel': true}
        },
      ];
      await pump(tester);
      await openBrowse(tester);
      final chips = tester
          .widgetList<ChoiceChip>(find.byType(ChoiceChip))
          .map((c) => ((c.label as Text).data, c.selected))
          .toList();
      expect(chips, [('All', false), ('Open', true), ('Closed', false)],
          reason: 'Archived only where the forum archives channels');
      expect(chat.browseQueries.last, containsPair('status', 'open'));
      expect(find.text('old news'), findsNothing);
      expect(find.widgetWithText(OutlinedButton, 'Leave'), findsOneWidget,
          reason: 'general is followed');
      expect(find.widgetWithText(FilledButton, 'Join'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'plan');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(chat.browseQueries.last, containsPair('filter', 'plan'));
      expect(find.text('planning'), findsOneWidget);
      expect(find.text('general'), findsNothing);
    });

    testWidgets('an Archived tab where the forum archives channels',
        (tester) async {
      DiscourseChatSettings.set(
          _site, const DiscourseChatSettings(archivingAllowed: true));
      chat.browseAll = [];
      await pump(tester);
      await openBrowse(tester);
      expect(find.widgetWithText(ChoiceChip, 'Archived'), findsOneWidget);
    });

    testWidgets('a followed channel closed since can be found and left',
        (tester) async {
      chat.browseAll = [
        {
          'id': 4,
          'title': 'old project',
          'status': 'closed',
          'current_user_membership': {'following': true},
          'meta': {'can_join_chat_channel': true},
        },
      ];
      await pump(tester);
      await openBrowse(tester);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Closed'));
      await tester.pumpAndSettle();
      expect(chat.browseQueries.last, containsPair('status', 'closed'));
      expect(find.text('old project'), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Leave'));
      await tester.pumpAndSettle();
      expect(chat.calls, contains('DELETE /chat/api/channels/4/memberships/me'));
    });

    testWidgets('reads the next page at the end of the list', (tester) async {
      chat.browseAll = [
        for (var id = 10; id < 40; id++)
          {
            'id': id,
            'title': 'channel $id',
            'meta': {'can_join_chat_channel': true}
          }
      ];
      await pump(tester);
      await openBrowse(tester);
      await tester.dragUntilVisible(find.text('channel 39'),
          find.byType(ListView).last, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(chat.browseQueries.last, containsPair('offset', 25));
      expect(find.text('channel 39'), findsOneWidget);
    });
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

  group("My Threads belong to the account that loaded them", () {
    late SiteContext reader;

    Future<void> openThreads(WidgetTester tester) async {
      DiscourseChatSettings.set(
          _site, const DiscourseChatSettings(threadsEnabled: true));
      chat.list = {
        'public_channels': [_channel(1, 'general')],
        'direct_message_channels': []
      };
      reader = _ctx();
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChatChannelListPage(siteContext: reader),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('My Threads'));
      await tester.pump();
    }

    Future<void> switchAccount(WidgetTester tester) async {
      reader.setLoginData(null);
      await tester.pump();
      reader.setLoginData(FCLoginResult(
          result: true,
          resultText: '',
          user: FCUser(id: '3', username: 'bob')));
      // Not pumpAndSettle: a spinner turns while the threads are asked for.
      for (var i = 0; i < 5; i++) {
        await tester.pump();
      }
    }

    testWidgets('signing in as someone else clears the last list',
        (tester) async {
      await openThreads(tester);
      chat.threadRequests.single.complete(_threads('Alice thread'));
      await tester.pumpAndSettle();
      expect(find.text('Alice thread'), findsOneWidget);
      await switchAccount(tester);
      expect(chat.threadRequests, hasLength(2),
          reason: "the new account's threads are asked for");
      expect(find.text('Alice thread'), findsNothing);
      chat.threadRequests.last.complete(_threads('Bob thread'));
      await tester.pumpAndSettle();
      expect(find.text('Bob thread'), findsOneWidget);
    });

    testWidgets("a late answer for the last account is dropped",
        (tester) async {
      await openThreads(tester);
      await switchAccount(tester);
      chat.threadRequests.last.complete(_threads('Bob thread'));
      await tester.pumpAndSettle();
      chat.threadRequests.first.complete(_threads('Alice thread'));
      await tester.pumpAndSettle();
      expect(find.text('Bob thread'), findsOneWidget);
      expect(find.text('Alice thread'), findsNothing);
    });

    testWidgets('resetting the tab drops the loaded threads', (tester) async {
      await openThreads(tester);
      chat.threadRequests.single.complete(_threads('Alice thread'));
      await tester.pumpAndSettle();
      tester
          .state<ChatChannelListPageState>(find.byType(ChatChannelListPage))
          .resetTab();
      await tester.pump();
      expect(find.text('Alice thread'), findsNothing);
      chat.threadRequests.last.complete(_threads('Alice thread, again'));
      await tester.pumpAndSettle();
      expect(find.text('Alice thread, again'), findsOneWidget);
    });
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

  /// When set, the forum's channels: each request gets its offset/limit
  /// slice, as the server answers.
  List<Map<String, dynamic>>? browseAll;
  final List<int> browseOffsets = [];
  final List<Map<String, dynamic>> browseQueries = [];
  final List<Completer<Map<String, dynamic>>> threadRequests = [];
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
    if (path == '/chat/api/me/threads') {
      final request = Completer<Map<String, dynamic>>();
      threadRequests.add(request);
      return request.future;
    }
    if (path == '/chat/api/channels') {
      final offset = query?['offset'] as int? ?? 0;
      browseOffsets.add(offset);
      browseQueries.add({...?query});
      final all = browseAll;
      if (all != null) {
        final limit = query?['limit'] as int? ?? 25;
        final status = query?['status'];
        final filter = (query?['filter'] as String? ?? '').toLowerCase();
        return {
          'channels': all
              .where((c) => status == null || (c['status'] ?? 'open') == status)
              .where((c) =>
                  filter.isEmpty ||
                  (c['title'] as String).toLowerCase().contains(filter))
              .skip(offset)
              .take(limit)
              .toList()
        };
      }
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
      final row = [...?browseAll, ...?(browse['channels'] as List?)]
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
