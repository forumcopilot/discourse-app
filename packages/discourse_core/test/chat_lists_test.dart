import 'dart:async';
import 'dart:convert';

import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// The chat list as Discourse's mobile chat draws it: who is in a DM and
/// their avatars, a channel's emoji and colour, the last message, the
/// reader's settings; browsing, joining, leaving, closing a DM; and the
/// list kept current live.
void main() {
  const site = 'https://chat.example';
  setUp(DiscourseChatChannelDetails.clear);

  test("an empty channel has no last message, though Discourse sends one timed now", () {
    final d = DiscourseChatChannelDetails.fromChannelJson('https://x.example', {
      'id': 1,
      'title': 'General',
      'chatable_type': 'Category',
      // Chat::NullMessage, serialized.
      'last_message': {'id': null, 'message': null, 'created_at': DateTime.now().toUtc().toIso8601String()},
    });
    expect(d.lastMessageAt, isNull);
    expect(d.lastMessageId, isNull);
    expect(d.lastMessageExcerpt, isNull);
  });

  Map<String, dynamic> dm({required int id, required List<Map<String, dynamic>> users, bool group = false}) => {
        'id': id,
        'title': users.map((u) => u['username']).join(', '),
        'chatable_type': 'DirectMessage',
        'chatable': {'group': group, 'users': users},
        'memberships_count': users.length + 1,
        'current_user_membership': {'starred': false, 'muted': false, 'notification_level': 'always'},
        'last_message': {'id': 40, 'excerpt': 'see you at 3', 'created_at': '2026-10-01T10:42:00Z'},
        'meta': {
          'message_bus_last_ids': {'new_messages': 17}
        },
      };

  Map<String, dynamic> user(int id, String username, {String? name}) => {
        'id': id,
        'username': username,
        if (name != null) 'name': name,
        'avatar_template': '/user_avatar/chat.example/$username/{size}/1_2.png',
      };

  group('channel details', () {
    test('a DM keeps the other person and their avatar', () {
      final d = DiscourseChatChannelDetails.fromChannelJson(
          site, dm(id: 5, users: [user(7, 'samr', name: 'Sam Rivera')]));
      expect(d.isDirectMessage, isTrue);
      expect(d.isGroup, isFalse);
      expect(d.members.single.displayName, 'Sam Rivera');
      expect(d.members.single.avatarUrl, 'https://chat.example/user_avatar/chat.example/samr/96/1_2.png');
      expect(d.lastMessageExcerpt, 'see you at 3');
      expect(d.lastMessageAt, DateTime.utc(2026, 10, 1, 10, 42));
      expect(d.newMessagesBusId, 17);
    });

    test('a group chat is one by its flag or by its size', () {
      expect(DiscourseChatChannelDetails.fromChannelJson(site, dm(id: 6, users: [user(1, 'a')], group: true)).isGroup,
          isTrue, reason: 'a named group chat with one other person');
      expect(DiscourseChatChannelDetails.fromChannelJson(site, dm(id: 6, users: [user(1, 'a'), user(2, 'b')])).isGroup,
          isTrue);
    });

    test("a channel keeps its emoji, its category's colour and the reader's settings", () {
      final d = DiscourseChatChannelDetails.fromChannelJson(site, {
        'id': 1,
        'title': 'support',
        'chatable_type': 'Category',
        'chatable': {'id': 3, 'color': '0088CC'},
        'emoji': 'hammer_and_wrench',
        'memberships_count': 42,
        'threading_enabled': true,
        'current_user_membership': {'starred': true, 'muted': true, 'notification_level': 'never'},
        'meta': {'can_flag': true, 'can_moderate': false},
      });
      expect(d.isDirectMessage, isFalse);
      expect(d.color, '0088CC');
      expect(d.emoji, 'hammer_and_wrench');
      expect(d.membershipsCount, 42);
      expect(d.starred, isTrue);
      expect(d.muted, isTrue);
      expect(d.notificationLevel, 'never');
      expect(d.threadingEnabled, isTrue);
      expect(d.canFlag, isTrue);
    });

    test('every channel the proxy reads is recorded', () async {
      final proxy = _Recording(site)
        ..responses['/chat/api/me/channels'] = {
          'public_channels': [],
          'direct_message_channels': [dm(id: 5, users: [user(7, 'samr')])],
        };
      await proxy.getMyChannelsAsync();
      expect(DiscourseChatChannelDetails.of(site, 5)?.members.single.username, 'samr');
    });
  });

  group('requests', () {
    test('browse, join, leave, close a DM, star, notifications', () async {
      final proxy = _Recording(site)
        ..responses['/chat/api/channels'] = {
          'channels': [
            {'id': 9, 'title': 'off-topic', 'chatable_type': 'Category', 'meta': {'can_join_chat_channel': true}},
          ],
        };
      final browsed = await proxy.browseChannelsAsync(filter: 'off', status: 'open');
      expect(browsed.channels.single.canJoin, isTrue);
      expect(proxy.queries.last, {'filter': 'off', 'status': 'open', 'offset': 0, 'limit': 25});

      DiscourseChatChannelDetails.store(site, const DiscourseChatChannelDetails(channelId: 9));
      await proxy.joinChannelAsync(9);
      await proxy.leaveChannelAsync(9);
      await proxy.closeDirectMessageAsync(5);
      await proxy.setChannelStarredAsync(9, true);
      await proxy.updateChannelNotificationsAsync(9, muted: true, level: 'never');
      expect(proxy.calls, [
        'GET /chat/api/channels',
        'POST /chat/api/channels/9/memberships/me',
        'DELETE /chat/api/channels/9/memberships/me',
        'DELETE /chat/api/channels/5/memberships/me/follows',
        'PUT /chat/api/channels/9/memberships/me {"starred":true}',
        'PUT /chat/api/channels/9/notifications-settings/me {"notifications_settings":{"muted":true,"notification_level":"never"}}',
      ]);
      final d = DiscourseChatChannelDetails.of(site, 9)!;
      expect(d.starred, isTrue);
      expect(d.muted, isTrue);
      expect(d.notificationLevel, 'never');
    });
  });

  group('live list', () {
    late _HeldPolls server;
    late DiscourseMessageBus bus;
    late List<DiscourseChatListEvent> events;
    late void Function()? stop;

    setUp(() async {
      server = _HeldPolls();
      final ctx = _context(site)
        ..setLoginData(FCLoginResult(result: true, resultText: '', user: FCUser(id: '2', username: 'alice')));
      bus = DiscourseMessageBus(ctx, client: server, minInterval: Duration.zero);
      events = [];
      DiscourseChatChannelDetails.store(site, DiscourseChatChannelDetails.fromChannelJson(site, dm(id: 5, users: [user(7, 'samr')])));
      stop = _Recording(site, bus: bus, context: ctx).watchChannelList([5], events.add);
    });

    tearDown(() {
      stop?.call();
      bus.close();
    });

    test('subscribes from where the list was read', () async {
      await server.nextPoll;
      expect(server.polls.single['/chat/5/new-messages'], 17);
      expect(server.polls.single.keys, containsAll(['/chat/user-tracking-state/2', '/chat/new-channel']));
    });

    test("someone's message updates the excerpt and is reported", () async {
      await server.nextPoll;
      server.answer([
        {
          'channel': '/chat/5/new-messages',
          'message_id': 18,
          'data': {
            'type': 'channel',
            'channel_id': 5,
            'message': {'id': 41, 'excerpt': 'on my way', 'created_at': '2026-10-01T11:00:00Z', 'user': {'id': 7}},
          },
        },
        {
          'channel': '/chat/user-tracking-state/2',
          'message_id': 3,
          'data': {'channel_id': 5, 'unread_count': 1, 'mention_count': 0},
        },
      ]);
      await server.nextPoll;
      final message = events.whereType<DiscourseChatListNewMessage>().single;
      expect(message.fromReader, isFalse);
      expect(DiscourseChatChannelDetails.of(site, 5)!.lastMessageExcerpt, 'on my way');
      final tracking = events.whereType<DiscourseChatListTracking>().single;
      expect(tracking.unreadCount, 1);
    });

    test("the reader's own message is theirs", () async {
      await server.nextPoll;
      server.answer([
        {
          'channel': '/chat/5/new-messages',
          'message_id': 18,
          'data': {
            'type': 'channel',
            'message': {'id': 42, 'excerpt': 'ok', 'created_at': '2026-10-01T11:01:00Z', 'user': {'id': 2}},
          },
        },
      ]);
      await server.nextPoll;
      expect(events.whereType<DiscourseChatListNewMessage>().single.fromReader, isTrue);
    });
  });

  test('Browse channels has an Archived tab only where channels are archived', () {
    addTearDown(DiscourseChatSettings.clear);
    DiscourseChatSettings.storeFromClientSettings(site, {});
    expect(DiscourseChatSettings.forSite(site).archivingAllowed, isFalse);
    DiscourseChatSettings.storeFromClientSettings(site, {'chat_allow_archiving_channels': true});
    expect(DiscourseChatSettings.forSite(site).archivingAllowed, isTrue);
  });
}

class _Recording extends DiscourseChatProxy {
  _Recording(String url, {this.bus, SiteContext? context}) : super(context ?? _context(url));

  final DiscourseMessageBus? bus;
  final Map<String, Map<String, dynamic>> responses = {};
  final List<String> calls = [];
  final List<Map<String, dynamic>?> queries = [];

  @override
  Future<Map<String, dynamic>> apiGet(String path, {Map<String, dynamic>? query}) async {
    calls.add('GET $path');
    queries.add(query);
    return responses[path] ?? const {};
  }

  @override
  Future<Map<String, dynamic>> apiPost(String path, {Map<String, dynamic>? query, Object? body}) async {
    calls.add('POST $path${body == null ? '' : ' ${jsonEncode(body)}'}');
    return const {};
  }

  @override
  Future<Map<String, dynamic>> apiPut(String path, {Map<String, dynamic>? query, Object? body}) async {
    calls.add('PUT $path${body == null ? '' : ' ${jsonEncode(body)}'}');
    return const {};
  }

  @override
  Future<Map<String, dynamic>> apiDelete(String path, {Map<String, dynamic>? query, Object? body}) async {
    calls.add('DELETE $path');
    return const {};
  }

  @override
  void Function()? watchChannelList(List<int> channelIds, void Function(DiscourseChatListEvent event) onEvent) {
    // Route through the test bus instead of the shared one.
    return watchChannelListOn(bus!, channelIds, onEvent);
  }
}

class _HeldPolls extends DiscourseClient {
  final List<Map<String, dynamic>> polls = [];
  final List<Completer<FCCallResult>> _held = [];
  Completer<void> _arrived = Completer<void>();

  Future<void> get nextPoll async {
    await _arrived.future.timeout(const Duration(seconds: 2));
    _arrived = Completer<void>();
  }

  void answer(List<Object> messages) =>
      _held.removeAt(0).complete(FCCallResult(statusCode: 200, body: jsonEncode(messages)));

  @override
  Future<FCCallResult> post(SiteContext context, String path,
      {Map<String, dynamic>? query, Object? body, Map<String, String>? extraHeaders}) {
    polls.add((jsonDecode(body as String) as Map).cast<String, dynamic>());
    final c = Completer<FCCallResult>();
    _held.add(c);
    if (!_arrived.isCompleted) _arrived.complete();
    return c.future;
  }
}

SiteContext _context(String url) => SiteContext(
      siteType: 'discourse',
      site: Site(
        id: null,
        name: 'Test',
        url: url,
        description: '',
        endpoint: null,
        baseUrl: url,
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'discourse',
      ),
    );
