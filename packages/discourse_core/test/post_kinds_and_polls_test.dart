import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// What a thread's posts carry beyond their body: every poll in each post
/// (not only the first post's first), the action a small-action post
/// records, and the moderator/hidden flags the web styles.
void main() {
  late _RecordingPostProxy proxy;

  setUp(() => proxy = _RecordingPostProxy());

  Map<String, dynamic> poll(String name, List<String> optionIds) => {
        'name': name,
        'type': 'regular',
        'status': 'open',
        'results': 'always',
        'voters': 3,
        'options': [
          for (final id in optionIds) {'id': id, 'html': 'Option $id', 'votes': 1},
        ],
      };

  Map<String, dynamic> thread() => {
        'id': 7,
        'title': 'A thread',
        'posts_count': 4,
        'details': <String, dynamic>{},
        'post_stream': {
          'posts': [
            {
              'id': 101, 'post_number': 1, 'post_type': 1, 'username': 'a',
              'cooked': '<div class="poll" data-poll-name="poll"></div>',
              'polls': [poll('poll', ['a1', 'a2'])],
            },
            {
              'id': 102, 'post_number': 2, 'post_type': 3, 'username': 'mod',
              'cooked': '', 'action_code': 'closed.enabled',
            },
            {
              'id': 103, 'post_number': 3, 'post_type': 3, 'username': 'mod',
              'cooked': '', 'action_code': 'invited_user', 'action_code_who': 'sam',
            },
            {
              'id': 104, 'post_number': 4, 'post_type': 2, 'username': 'mod',
              'cooked': '<p>Please keep it civil.</p>', 'hidden': true,
              'polls': [poll('first', ['b1', 'b2']), poll('second', ['c1', 'c2'])],
              'polls_votes': {'second': ['c2']},
            },
          ],
        },
      };

  test('every poll of every post is on the post, with the viewer\'s votes', () async {
    proxy.nextGet = thread();
    final r = await proxy.getThreadAsync('7', 1, 20, true);
    expect(r.resultText, '');
    final posts = r.posts;

    expect(posts[0].polls.map((p) => p.pollId), ['poll']);
    expect(posts[3].polls.map((p) => p.pollId), ['first', 'second']);
    expect(posts[3].polls.every((p) => p.postId == '104'), isTrue);
    expect(posts[3].polls[1].hasVoted, isTrue);
    expect(posts[3].polls[1].responses[1].viewerVotedFor, isTrue);
    expect(posts[1].polls, isEmpty);
  });

  test('small actions carry their code; moderator and hidden posts are flagged', () async {
    proxy.nextGet = thread();
    final posts = (await proxy.getThreadAsync('7', 1, 20, true)).posts;

    expect(posts[0].actionCode, isNull);
    expect(posts[1].actionCode, 'closed.enabled');
    expect(posts[2].actionCode, 'invited_user');
    expect(posts[2].actionCodeWho, 'sam');
    expect(posts[3].actionCode, isNull, reason: 'only post_type 3 records an action');
    expect(posts[3].isModeratorAction, isTrue);
    expect(posts[3].isHidden, isTrue);
    expect(posts[0].isModeratorAction, isFalse);
  });

  test('a vote in a reply\'s second poll goes to that post and poll', () async {
    proxy.nextGet = thread();
    await proxy.getThreadAsync('7', 1, 20, true);
    // A busy thread: many more polls parsed after this one.
    for (var i = 0; i < 40; i++) {
      proxy.nextGet = {
        'post_stream': {
          'posts': [
            {'id': 900 + i, 'post_number': 1, 'post_type': 1, 'username': 'x', 'cooked': '',
             'polls': [poll('poll', ['z$i'])]},
          ],
        },
      };
      await proxy.getThreadAsync('${100 + i}', 1, 20, true);
    }

    proxy.nextPut = {'poll': poll('second', ['c1', 'c2']), 'vote': ['c1']};
    final updated = await proxy.votePollAsync('7', ['c1']);

    expect(proxy.puts.single, 'PUT /polls/vote {post_id: 104, poll_name: second, options: [c1]}');
    expect(updated?.pollId, 'second');
    expect(updated?.postId, '104');
  });
}

class _RecordingPostProxy extends DiscoursePostProxy {
  _RecordingPostProxy() : super(_context());

  Map<String, dynamic> nextGet = const {};
  Map<String, dynamic> nextPut = const {};
  final List<String> puts = [];

  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      nextGet;

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
