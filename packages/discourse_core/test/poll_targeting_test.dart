import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

Map<String, dynamic> pollJson(String name) => {
      'name': name,
      'type': 'regular',
      'status': 'open',
      'results': 'always',
      'options': [
        {'id': 'yes-digest', 'html': 'Yes'},
        {'id': 'no-digest', 'html': 'No'},
      ],
    };

class RecordingPollProxy extends DiscoursePostProxy {
  RecordingPollProxy(String url)
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
                siteType: 'discourse')));

  final writes = <Map<String, dynamic>>[];
  final reads = <String>[];
  Map<String, dynamic> nextGet = {};

  Future<FCPoll> loadPoll(String topic, int post,
      {String name = 'poll'}) async {
    nextGet = {
      'id': int.parse(topic),
      'post_stream': {
        'posts': [
          {
            'id': post,
            'post_number': 1,
            'post_type': 1,
            'username': 'a',
            'cooked': '',
            'polls': [pollJson(name)]
          },
        ]
      },
    };
    return (await getThreadAsync(topic, 1, 20, true)).posts.single.polls.single;
  }

  @override
  Future<Map<String, dynamic>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    reads.add(path);
    return nextGet;
  }

  @override
  Future<Map<String, dynamic>> apiPut(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    expect(path, '/polls/vote');
    final data = Map<String, dynamic>.from(body! as Map);
    writes.add(data);
    return {
      'poll': pollJson(data['poll_name'] as String),
      'vote': data['options']
    };
  }
}

void main() {
  test('identical options in another topic cannot redirect a vote', () async {
    final proxy = RecordingPollProxy('https://one.example');
    final target = await proxy.loadPoll('11', 101);
    await proxy.loadPoll('22', 202);
    final updated =
        await proxy.votePollAsync('11', ['yes-digest'], poll: target);
    expect(proxy.writes.single['post_id'], 101);
    expect(updated?.topicId, '11');
    expect(updated?.postId, '101');
  });
  test(
      'identical topic ids and options on another forum do not change the target',
      () async {
    final one = RecordingPollProxy('https://one.example/forum');
    final two = RecordingPollProxy('https://one.example/other');
    final target = await one.loadPoll('11', 101);
    await two.loadPoll('11', 202);
    await one.votePollAsync('11', ['yes-digest'], poll: target);
    expect(one.writes.single['post_id'], 101);
    expect(two.writes, isEmpty);
  });

  test('same name and options on different posts keep the displayed post',
      () async {
    final proxy = RecordingPollProxy('https://one.example');
    final target = await proxy.loadPoll('11', 101);
    await proxy.loadPoll('11', 202);
    await proxy.votePollAsync('11', ['yes-digest'], poll: target);
    expect(proxy.writes.single['post_id'], 101);
  });

  test(
      'named polls on the same post keep their explicit name and all selections',
      () async {
    final proxy = RecordingPollProxy('https://one.example');
    final target = await proxy.loadPoll('11', 101, name: 'first');
    await proxy.loadPoll('11', 101, name: 'second');
    final result = await proxy.votePollAsync('11', ['yes-digest', 'no-digest'],
        poll: target);
    expect(proxy.writes.single, {
      'post_id': 101,
      'poll_name': 'first',
      'options': ['yes-digest', 'no-digest'],
    });
    expect(result?.pollId, 'first');
    expect(result?.responses.every((r) => r.viewerVotedFor), isTrue);
  });

  test('poll identity survives more than the old cache capacity', () async {
    final proxy = RecordingPollProxy('https://one.example');
    final target = await proxy.loadPoll('11', 101, name: 'reply');
    for (var i = 0; i < 205; i++) {
      await proxy.loadPoll('${100 + i}', 1000 + i);
    }
    proxy.reads.clear();
    await proxy.votePollAsync('11', ['yes-digest'], poll: target);
    expect(proxy.writes.single['post_id'], 101);
    expect(proxy.writes.single['poll_name'], 'reply');
    expect(proxy.reads, isEmpty);
  });

  test('old calls without poll identity never guess a first post', () async {
    final proxy = RecordingPollProxy('https://one.example');
    await proxy.loadPoll('11', 101);
    proxy.reads.clear();
    expect(await proxy.votePollAsync('11', ['yes-digest']), isNull);
    expect(proxy.writes, isEmpty);
    expect(proxy.reads, isEmpty);
  });

  test('invalid identity or foreign option ids send no request', () async {
    final proxy = RecordingPollProxy('https://one.example');
    final target = await proxy.loadPoll('11', 101);
    expect(
        await proxy.votePollAsync('22', ['yes-digest'], poll: target), isNull);
    expect(await proxy.votePollAsync('11', ['unknown'], poll: target), isNull);
    expect(await proxy.votePollAsync('11', [], poll: target), isNull);
    for (final id in [null, '', 'invalid', '0', '-1']) {
      target.postId = id;
      expect(await proxy.votePollAsync('11', ['yes-digest'], poll: target),
          isNull);
    }
    expect(proxy.writes, isEmpty);
  });
}
