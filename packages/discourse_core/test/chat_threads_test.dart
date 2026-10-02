import 'dart:convert';

import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Threads and chat search: starting a thread, a thread's replies, the
/// summary under its original message (and its live updates), My Threads,
/// and search results.
void main() {
  const site = 'https://chat.example';
  setUp(DiscourseChatMessageExtras.clear);

  Map<String, dynamic> message(int id, {int? threadId, Map<String, dynamic>? thread}) => {
        'id': id,
        'chat_channel_id': 1,
        'message': 'm$id',
        'cooked': '<p>m$id</p>',
        'created_at': '2026-10-01T10:00:00Z',
        'user': {'id': 7, 'username': 'samr'},
        if (threadId != null) 'thread_id': threadId,
        if (thread != null) 'thread': thread,
      };

  test("a thread's summary is read from its original message", () {
    final p = _Recording(site);
    p.chatEventFrom({
      'type': 'sent',
      'chat_message': message(10, threadId: 5, thread: {
        'id': 5,
        'title': 'Saturday',
        'preview': {
          'reply_count': 3,
          'participant_count': 2,
          'participant_users': [
            {'id': 7, 'username': 'samr', 'avatar_template': '/a/{size}.png'},
          ],
          'last_reply_created_at': '2026-10-01T11:00:00Z',
          'last_reply_excerpt': 'see you there',
          'last_reply_user': {'id': 8, 'username': 'kim'},
        },
      }),
    });
    final t = DiscourseChatMessageExtras.of(site, 10)!.thread!;
    expect((t.threadId, t.title, t.replyCount, t.participantCount), (5, 'Saturday', 3, 2));
    expect(t.participants.single.username, 'samr');
    expect(t.lastReplyUser?.username, 'kim');
    expect(t.lastReplyExcerpt, 'see you there');
  });

  test('a new reply updates the summary live, and an edit keeps it', () {
    final p = _Recording(site);
    p.chatEventFrom({'type': 'sent', 'chat_message': message(10, threadId: 5, thread: {'id': 5, 'preview': {'reply_count': 1}})});
    final event = p.chatEventFrom({
      'type': 'update_thread_original_message',
      'original_message_id': 10,
      'thread_id': 5,
      'preview': {'reply_count': 2, 'last_reply_excerpt': 'two'},
    });
    expect(event, isA<DiscourseChatThreadUpdated>().having((e) => e.originalMessageId, 'id', 10));
    expect(DiscourseChatMessageExtras.of(site, 10)!.thread!.replyCount, 2);
    // A live edit's payload has no summary.
    p.chatEventFrom({'type': 'edit', 'chat_message': message(10, threadId: 5)});
    expect(DiscourseChatMessageExtras.of(site, 10)!.thread!.replyCount, 2);
  });

  test("starting a thread on a message, and reading the thread's replies", () async {
    final p = _Recording(site)..postResponse = {'id': 5, 'channel_id': 1, 'title': null};
    final t = await p.createThreadAsync(1, 10);
    expect(t?.threadId, 5);
    expect(p.calls, ['POST /chat/api/channels/1/threads {"original_message_id":10}']);
    expect(DiscourseChatMessageExtras.of(site, 10)?.thread?.threadId, 5);

    p.getResponses['/chat/api/channels/1/threads/5/messages'] = {
      'messages': [message(10, threadId: 5), message(11, threadId: 5)],
    };
    final page = await p.getThreadMessagesAsync(1, 5);
    expect(page.messages.map((m) => m.id), [10, 11]);
    expect(p.queries['/chat/api/channels/1/threads/5/messages'], {'page_size': 50, 'fetch_from_last_message': true});
    await p.getThreadMessagesAsync(1, 5, targetMessageId: 10, direction: 'past');
    expect(p.queries['/chat/api/channels/1/threads/5/messages'],
        {'page_size': 50, 'target_message_id': 10, 'direction': 'past'});
  });

  test("My Threads: each with its channel and the reader's unread count", () async {
    final p = _Recording(site)
      ..getResponses['/chat/api/me/threads'] = {
        'threads': [
          {
            'id': 5,
            'channel_id': 1,
            'channel': {'id': 1, 'title': 'general'},
            'title': '',
            'original_message': message(10, threadId: 5),
            'preview': {'reply_count': 4, 'last_reply_created_at': '2026-10-01T11:00:00Z'},
          },
        ],
        'tracking': {
          'thread_tracking': {
            '5': {'unread_count': 2, 'mention_count': 0},
          },
        },
      };
    final r = await p.getMyThreadsAsync();
    final t = r.threads.single;
    expect((t.threadId, t.channelId, t.channelTitle, t.title, t.replyCount, t.unreadCount), (5, 1, 'general', null, 4, 2));
    expect(t.originalMessage?.id, 10);
  });

  test('search: messages with their channel, a page at a time', () async {
    final p = _Recording(site)
      ..getResponses['/chat/api/search'] = {
        'messages': [
          {...message(10), 'channel': {'id': 1, 'title': 'general', 'chatable_type': 'Category'}},
        ],
        'meta': {'has_more': true},
      };
    final r = await p.searchChatAsync('saturday', channelId: 1, offset: 20);
    expect(r.messages.single.channelTitle, 'general');
    expect(r.hasMore, isTrue);
    expect(p.queries['/chat/api/search'], {'query': 'saturday', 'channel_id': 1, 'offset': 20, 'limit': 20});
  });
}

class _Recording extends DiscourseChatProxy {
  _Recording(String url)
      : super(SiteContext(
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
        ));

  final List<String> calls = [];
  final Map<String, Map<String, dynamic>> getResponses = {};
  final Map<String, Map<String, dynamic>?> queries = {};
  Map<String, dynamic> postResponse = const {};

  @override
  Future<Map<String, dynamic>> apiGet(String path, {Map<String, dynamic>? query}) async {
    queries[path] = query;
    return getResponses[path] ?? const {};
  }

  @override
  Future<Map<String, dynamic>> apiPost(String path, {Map<String, dynamic>? query, Object? body}) async {
    calls.add('POST $path${body == null ? '' : ' ${jsonEncode(body)}'}');
    return postResponse;
  }
}
