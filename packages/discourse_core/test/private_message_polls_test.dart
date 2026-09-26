import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Polls in private messages. A Discourse message is a topic and each message
/// is a post carrying its own `polls` array, but the message model had no
/// field for them, so a poll in a message was drawn as nothing.
void main() {
  Map<String, dynamic> poll(String name, List<String> optionIds) => {
        'name': name,
        'type': 'regular',
        'status': 'open',
        'results': 'always',
        'voters': 2,
        'options': [
          for (final id in optionIds)
            {'id': id, 'html': 'Option $id', 'votes': 1},
        ],
      };

  Map<String, dynamic> message() => {
        'id': 55,
        'title': 'Where shall we meet?',
        'slug': 'where-shall-we-meet',
        'archetype': 'private_message',
        'details': <String, dynamic>{},
        'post_stream': {
          'posts': [
            {
              'id': 501, 'topic_id': 55, 'post_number': 1, 'post_type': 1,
              'username': 'bob',
              'cooked': '<div class="poll" data-poll-name="place"></div>',
              'polls': [poll('place', ['p1', 'p2'])],
              'polls_votes': {'place': ['p2']},
            },
            {
              'id': 502, 'topic_id': 55, 'post_number': 2, 'post_type': 1,
              'username': 'carol', 'cooked': '<p>Either works.</p>',
            },
          ],
        },
      };

  test('a message carries its polls, with the viewer\'s vote', () async {
    final proxy = _ConversationProxy()..nextGet = message();
    final result = await proxy.getConversationAsync('55', 0, 20, true);

    final first = result.messages.first;
    expect(first.polls.map((p) => p.pollId), ['place']);
    expect(first.polls.single.postId, '501');
    expect(first.polls.single.topicId, '55');
    expect(first.polls.single.hasVoted, isTrue);
    expect(first.polls.single.responses[1].viewerVotedFor, isTrue);
    expect(result.messages[1].polls, isEmpty);
  });

  test('a vote in a message\'s poll goes to that message\'s post', () async {
    final conversations = _ConversationProxy()..nextGet = message();
    await conversations.getConversationAsync('55', 0, 20, true);

    final posts = _PostProxy()
      ..nextPut = {'poll': poll('place', ['p1', 'p2']), 'vote': ['p1']};
    final updated = await posts.votePollAsync('55', ['p1']);

    expect(posts.puts.single,
        'PUT /polls/vote {post_id: 501, poll_name: place, options: [p1]}');
    expect(updated?.postId, '501');
  });
}

class _ConversationProxy extends DiscoursePrivateConversationProxy {
  _ConversationProxy() : super(_context());

  Map<String, dynamic> nextGet = const {};

  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      nextGet;
}

class _PostProxy extends DiscoursePostProxy {
  _PostProxy() : super(_context());

  Map<String, dynamic> nextPut = const {};
  final List<String> puts = [];

  @override
  Future<Map<String, dynamic>> apiPut(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    puts.add('PUT $path $body');
    return nextPut;
  }
}

SiteContext _context() => SiteContext(
      siteType: 'discourse',
      site: Site(
        id: null,
        name: 'Test',
        url: 'https://forum.example',
        description: '',
        endpoint: null,
        baseUrl: 'https://forum.example',
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'discourse',
      ),
    );
