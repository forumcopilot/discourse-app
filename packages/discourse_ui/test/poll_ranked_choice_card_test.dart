import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/views/widgets/thread_poll_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

const _forum = 'https://forum.example';

final _ctx = SiteContext(
    siteType: 'discourse',
    site: Site(
        id: null,
        name: 'Test',
        url: _forum,
        description: '',
        endpoint: null,
        baseUrl: _forum,
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'discourse'));

/// A ranked-choice poll as the poll plugin serializes it: each option's
/// `votes` is the voter count (every voter ranks every option, Abstain
/// included), and the result is `ranked_choice_outcome`.
Map<String, dynamic> _rankedPoll({bool voted = false}) => {
      'name': 'poll',
      'type': 'ranked_choice',
      'status': 'open',
      'results': 'always',
      'voters': voted ? 1 : 0,
      'options': [
        {'id': 'tea', 'html': 'Tea', 'votes': voted ? 1 : 0},
        {'id': 'coffee', 'html': 'Coffee', 'votes': voted ? 1 : 0},
        {'id': 'water', 'html': 'Water', 'votes': voted ? 1 : 0},
      ],
      'ranked_choice_outcome': voted
          ? {
              'tied': false,
              'winner': true,
              'winning_candidate': {'digest': 'coffee', 'html': 'Coffee'},
              'round_activity': [
                {'round': 1}
              ],
            }
          : null,
    };

class _Posts extends DiscoursePostProxy {
  _Posts() : super(_ctx);
  final writes = <Map<String, dynamic>>[];

  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      {
        'id': 11,
        'post_stream': {
          'posts': [
            {
              'id': 101,
              'post_number': 1,
              'post_type': 1,
              'username': 'a',
              'cooked': '',
              'polls': [_rankedPoll()],
            },
          ]
        },
      };

  @override
  Future<Map<String, dynamic>> apiPut(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    final data = Map<String, dynamic>.from(body! as Map);
    writes.add(data);
    return {
      'poll': _rankedPoll(voted: true),
      'vote': (data['options'] as Map).values.toList(),
    };
  }
}

class _Factory implements SiteProxyFactory {
  _Factory(this.posts);
  final _Posts posts;
  @override
  IFCPostProxy createPostProxy(SiteContext context) => posts;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(FCPoll poll, void Function(FCPoll) onVote) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ThreadPollCard(
          topicId: '11',
          siteContext: _ctx,
          poll: poll,
          onVoteSuccess: onVote,
        ),
      ),
    );

/// The rank badge an option carries, by its screen-reader label.
Finder _badge(String label) => find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.label == label,
    description: 'rank badge "$label"');

void main() {
  testWidgets(
      'a ranked-choice poll is voted by ranking, and shows the winner',
      (tester) async {
    final posts = _Posts();
    SiteProxyService.initialize(_ctx);
    SiteProxyFactory.register('discourse', _Factory(posts));
    late FCPoll poll;
    await tester.runAsync(() async {
      poll = (await posts.getThreadAsync('11', 1, 20, true))
          .posts
          .single
          .polls
          .single;
    });
    FCPoll? updated;
    await tester.pumpWidget(_app(poll, (p) => updated = p));

    expect(
        find.text('Tap the options in order of preference. '
            'Unranked options count as Abstain.'),
        findsOneWidget);
    expect(_badge('Abstain'), findsNWidgets(3));

    // Water, then Coffee, then Tea; Water taken back: Coffee moves up to 1.
    for (final option in ['Water', 'Coffee', 'Tea', 'Water']) {
      await tester.tap(find.text(option, findRichText: true));
      await tester.pump();
    }
    expect(_badge('Rank 1'), findsOneWidget);
    expect(_badge('Rank 2'), findsOneWidget);
    expect(_badge('Abstain'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Vote'));
    await tester.pumpAndSettle();
    expect(posts.writes.single, {
      'post_id': 101,
      'poll_name': 'poll',
      'options': {
        '0': {'digest': 'tea', 'rank': '2'},
        '1': {'digest': 'coffee', 'rank': '1'},
        '2': {'digest': 'water', 'rank': '0'},
      },
    });
    expect(updated?.hasVoted, isTrue);

    // After the vote: the viewer's ranks, the winner, and no bars (every
    // option's count is the voter count, 100%).
    await tester.pumpWidget(_app(updated!, (_) {}));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Vote'), findsNothing);
    expect(_badge('Rank 1'), findsOneWidget);
    expect(find.text('Winner'), findsOneWidget);
    expect(
        tester.getRect(find.text('Winner')).center.dy,
        moreOrLessEquals(
            tester.getRect(find.text('Coffee', findRichText: true)).center.dy,
            epsilon: 12));
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.textContaining('%'), findsNothing);
    expect(find.text('Remove vote'), findsOneWidget);
  });
}
