import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// A ranked-choice poll as the poll plugin serializes it: every voter has a
/// vote row on every option (Abstain is rank 0), so each option's `votes`
/// is the voter count, and the result is `ranked_choice_outcome`.
Map<String, dynamic> rankedPoll({Map<String, dynamic>? outcome}) => {
      'name': 'poll',
      'type': 'ranked_choice',
      'status': 'open',
      'results': 'always',
      'voters': 2,
      'options': [
        {'id': 'tea', 'html': 'Tea', 'votes': 2},
        {'id': 'coffee', 'html': 'Coffee', 'votes': 2},
        {'id': 'water', 'html': 'Water', 'votes': 2},
      ],
      'ranked_choice_outcome': outcome,
    };

const _winner = {
  'tied': false,
  'tied_candidates': null,
  'winner': true,
  'winning_candidate': {'digest': 'coffee', 'html': 'Coffee'},
  'round_activity': [
    {
      'round': 1,
      'majority': {'digest': 'coffee', 'html': 'Coffee'},
      'eliminated': null
    }
  ],
};

class RankedPollProxy extends DiscoursePostProxy {
  RankedPollProxy()
      : super(SiteContext(
            siteType: 'discourse',
            site: Site(
                id: null,
                name: 'Test',
                url: 'https://one.example',
                description: '',
                endpoint: null,
                baseUrl: 'https://one.example',
                logoUrl: null,
                backgroundUrl: null,
                siteType: 'discourse')));

  final writes = <Map<String, dynamic>>[];
  Map<String, dynamic> nextGet = {};

  Future<FCPoll> loadPoll({
    Map<String, dynamic> poll = const {},
    List<Object?>? ballot,
  }) async {
    nextGet = {
      'id': 11,
      'post_stream': {
        'posts': [
          {
            'id': 101,
            'post_number': 1,
            'post_type': 1,
            'username': 'a',
            'cooked': '',
            'polls': [poll.isEmpty ? rankedPoll() : poll],
            if (ballot != null) 'polls_votes': {'poll': ballot},
          },
        ]
      },
    };
    return (await getThreadAsync('11', 1, 20, true)).posts.single.polls.single;
  }

  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      nextGet;

  @override
  Future<Map<String, dynamic>> apiPut(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    expect(path, '/polls/vote');
    final data = Map<String, dynamic>.from(body! as Map);
    writes.add(data);
    // The server echoes the ballot it stored, ranks as the form sent them.
    return {
      'poll': rankedPoll(outcome: _winner),
      'vote': (data['options'] as Map).values.toList(),
    };
  }
}

void main() {
  test('the viewer\'s ranked ballot is a vote, Abstain is not a choice',
      () async {
    final proxy = RankedPollProxy();
    final poll = await proxy.loadPoll(
      poll: rankedPoll(outcome: _winner),
      ballot: [
        {'digest': 'tea', 'rank': 2},
        {'digest': 'coffee', 'rank': 1},
        {'digest': 'water', 'rank': 0},
      ],
    );
    expect(poll.hasVoted, isTrue);
    expect(poll.canVote, isFalse);
    expect(poll.responses.map((r) => r.viewerVotedFor), [true, true, false]);
    final extras = DiscoursePollExtras.of(poll)!;
    expect(extras.isRankedChoice, isTrue);
    expect(extras.viewerRanks, {'tea': 2, 'coffee': 1, 'water': 0});
    expect(extras.outcome?.tied, isFalse);
    expect(extras.outcome?.winnerId, 'coffee');
  });

  test('a tie names the tied options; no votes yet, no outcome', () async {
    final proxy = RankedPollProxy();
    final tied = await proxy.loadPoll(
        poll: rankedPoll(outcome: {
      'tied': true,
      'tied_candidates': [
        {'digest': 'tea', 'html': 'Tea'},
        {'digest': 'water', 'html': 'Water'},
      ],
      'winner': null,
      'winning_candidate': null,
      'round_activity': [],
    }));
    expect(DiscoursePollExtras.of(tied)!.outcome?.tiedIds, ['tea', 'water']);
    final fresh = await proxy.loadPoll();
    expect(fresh.hasVoted, isFalse);
    expect(fresh.canVote, isTrue);
    expect(DiscoursePollExtras.of(fresh)!.outcome, isNull);
  });

  test('a ranked ballot ranks every option, as the web sends it', () async {
    final proxy = RankedPollProxy();
    final poll = await proxy.loadPoll();
    final updated = await proxy.voteRankedChoicePollAsync(
        '11', {'coffee': 1, 'tea': 2},
        poll: poll);
    expect(proxy.writes.single, {
      'post_id': 101,
      'poll_name': 'poll',
      'options': {
        '0': {'digest': 'tea', 'rank': '2'},
        '1': {'digest': 'coffee', 'rank': '1'},
        '2': {'digest': 'water', 'rank': '0'},
      },
    });
    expect(updated?.hasVoted, isTrue);
    expect(updated?.postId, '101');
    expect(DiscoursePollExtras.of(updated!)!.viewerRanks,
        {'tea': 2, 'coffee': 1, 'water': 0});
    expect(DiscoursePollExtras.of(updated)!.outcome?.winnerId, 'coffee');
  });

  test('a ballot the server would refuse is not sent', () async {
    final proxy = RankedPollProxy();
    final poll = await proxy.loadPoll();
    for (final ranks in <Map<String, int>>[
      {},
      {'tea': 0, 'coffee': 0},
      {'tea': 1, 'coffee': 1},
      {'tea': 4},
      {'tea': -1},
      {'juice': 1},
    ]) {
      expect(await proxy.voteRankedChoicePollAsync('11', ranks, poll: poll),
          isNull,
          reason: '$ranks');
    }
    expect(await proxy.voteRankedChoicePollAsync('22', {'tea': 1}, poll: poll),
        isNull,
        reason: 'another topic');
    expect(proxy.writes, isEmpty);
  });

  test('a ranked-choice poll takes no plain choice, a plain poll no ranks',
      () async {
    final proxy = RankedPollProxy();
    final ranked = await proxy.loadPoll();
    expect(await proxy.votePollAsync('11', ['tea'], poll: ranked), isNull);
    final regular = await proxy.loadPoll(
        poll: {...rankedPoll(), 'type': 'regular'});
    expect(DiscoursePollExtras.of(regular)!.isRankedChoice, isFalse);
    expect(
        await proxy.voteRankedChoicePollAsync('11', {'tea': 1}, poll: regular),
        isNull);
    expect(proxy.writes, isEmpty);
  });
}
