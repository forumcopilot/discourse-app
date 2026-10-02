import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/views/widgets/thread_poll_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

SiteContext contextFor(String url) => SiteContext(
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
        siteType: 'discourse'));

class RecordingPosts extends DiscoursePostProxy {
  RecordingPosts(super.context);
  final writes = <Map<String, dynamic>>[];

  @override
  Future<Map<String, dynamic>> apiPut(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    writes.add(Map<String, dynamic>.from(body! as Map));
    return {
      'poll': {
        'name': 'second',
        'options': [
          {'id': 'yes', 'html': 'Yes'}
        ]
      },
      'vote': ['yes']
    };
  }
}

class PollFactory implements SiteProxyFactory {
  PollFactory(this.posts);
  final RecordingPosts posts;
  @override
  IFCPostProxy createPostProxy(SiteContext context) => posts;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final otherForum in [false, true]) {
    testWidgets(
        otherForum
            ? 'a stale forum card sends no vote to the active forum'
            : 'the vote button sends the displayed post and named poll',
        (tester) async {
      final context = contextFor('https://forum.example/one');
      final posts = RecordingPosts(
          otherForum ? contextFor('https://forum.example/two') : context);
      SiteProxyService.initialize(posts.siteContext);
      SiteProxyFactory.register('discourse', PollFactory(posts));
      FCPoll? updated;
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
            body: ThreadPollCard(
          topicId: '11',
          siteContext: context,
          poll: FCPoll(
              pollId: 'second',
              topicId: '11',
              postId: '202',
              question: 'Choose',
              canVote: true,
              responses: [FCPollResponse(id: 'yes', text: 'Yes')]),
          onVoteSuccess: (poll) => updated = poll,
        )),
      ));
      await tester.tap(find.text('Yes', findRichText: true));
      await tester.pump();
      await tester.tap(find.text('Vote'));
      await tester.pumpAndSettle();
      if (otherForum) {
        expect(posts.writes, isEmpty);
        expect(updated, isNull);
      } else {
        expect(posts.writes.single, {
          'post_id': 202,
          'poll_name': 'second',
          'options': ['yes'],
        });
        expect(updated?.postId, '202');
        expect(updated?.pollId, 'second');
      }
    });
  }
}
