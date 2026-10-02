import 'dart:convert';

import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// What a chat message carries beyond the shared entity (what it replies
/// to, its thread, the reader's bookmark and flag, its pin), and sending a
/// reply.
void main() {
  const site = 'https://chat.example';
  setUp(DiscourseChatMessageExtras.clear);

  test('a message read from the server keeps its reply, thread and marks', () {
    final e = DiscourseChatMessageExtras.fromMessageJson(site, {
      'id': 21,
      'in_reply_to': {
        'id': 20,
        'excerpt': 'Can someone check the German?',
        'user': {'id': 7, 'username': 'samr', 'avatar_template': '/a/{size}.png'},
      },
      'thread': {
        'id': 5,
        'title': 'Translations',
        'reply_count': 3,
        'preview': {
          'reply_count': 3,
          'participant_count': 2,
          'participant_users': [
            {'id': 7, 'username': 'samr'},
            {'id': 8, 'username': 'priya'},
          ],
          'last_reply_created_at': '2026-10-01T09:40:00Z',
          'last_reply_excerpt': 'done',
          'last_reply_user': {'id': 8, 'username': 'priya'},
        },
      },
      'bookmark': {'id': 99},
      'pinned': true,
      'available_flags': ['spam'],
      'user': {'id': 8, 'username': 'priya', 'title': 'Translator'},
    });
    expect(e.replyTo?.messageId, 20);
    expect(e.replyTo?.user?.username, 'samr');
    expect(e.thread?.threadId, 5);
    expect(e.thread?.replyCount, 3);
    expect(e.thread?.participants.map((u) => u.username), ['samr', 'priya']);
    expect(e.thread?.lastReplyUser?.username, 'priya');
    expect(e.bookmarkId, 99);
    expect(e.pinned, isTrue);
    expect(e.canFlag, isTrue);
    expect(e.authorTitle, 'Translator');
  });

  test('a reply is sent with what it answers, and shows it at once', () async {
    final proxy = _Sending(site);
    final original = FCChatMessage(
      id: 20,
      channelId: 1,
      message: 'Can someone check the German?',
      cooked: '',
      authorId: 7,
      authorUsername: 'samr',
      createdAt: DateTime.utc(2026, 10, 1),
    );
    final result = await proxy.sendMessageAsync(1, 'On it <b>now</b>', inReplyTo: original);
    expect(proxy.bodies.single, {'message': 'On it <b>now</b>', 'in_reply_to_id': 20});
    expect(result.message?.cooked, '<p>On it &lt;b&gt;now&lt;&#47;b&gt;</p>',
        reason: 'escaped until the server renders it; it showed the raw text');
    expect(DiscourseChatMessageExtras.of(site, 21)?.replyTo?.user?.username, 'samr');
  });
}

class _Sending extends DiscourseChatProxy {
  _Sending(String url)
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

  final List<Object?> bodies = [];

  @override
  Future<Map<String, dynamic>> apiPost(String path, {Map<String, dynamic>? query, Object? body}) async {
    bodies.add(jsonDecode(jsonEncode(body)));
    return {'message_id': 21};
  }
}
