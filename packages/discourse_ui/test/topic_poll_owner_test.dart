import 'package:discourse_ui/controllers/post_controller.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/listitems/post_list_item.dart';
import 'package:discourse_ui/views/widgets/thread_poll_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post.dart';

/// A topic poll is drawn in the opening post only when it is that post's:
/// most polls are named "poll", so a reply's must not stand in for it.
FCPoll _poll(String postId, String option) => FCPoll(
      pollId: 'poll',
      topicId: '7',
      postId: postId,
      question: '',
      responses: [FCPollResponse(id: option, text: option)],
      maxVotes: 1,
      canVote: true,
    );

SiteContext _site() => SiteContext(
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

void main() {
  setUp(() => SiteProxyService.initialize(_site()));

  Future<FCPoll> drawn(WidgetTester tester, {required FCPoll topicPoll}) async {
    final post = FCPost(
      id: '101',
      title: '',
      content: '<div class="poll" data-poll-name="poll">'
          '<div class="poll-container"><ul><li>Mine</li></ul></div></div>',
      topicId: '7',
      postNumber: 1,
      authorId: '1',
      authorName: 'bob',
      timestamp: DateTime(2026, 10, 4),
    )..polls = [_poll('101', 'Mine')];
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: PostListItem(
            siteContext: _site(),
            post: post,
            threadId: '7',
            topicTitle: 't',
            postController: PostController(),
            poll: topicPoll,
            onVoteSuccess: (_) {},
          ),
        ),
      ),
    ));
    await tester.pump();
    return tester.widget<ThreadPollCard>(find.byType(ThreadPollCard)).poll;
  }

  testWidgets("a reply's same-named poll does not replace post 1's",
      (tester) async {
    final poll = await drawn(tester, topicPoll: _poll('125', 'Theirs'));
    expect(poll.postId, '101');
    expect(poll.responses.single.text, 'Mine');
  });

  testWidgets("post 1's own topic poll is the live one", (tester) async {
    final poll = await drawn(tester, topicPoll: _poll('101', 'Live'));
    expect(poll.responses.single.text, 'Live',
        reason: 'the thread copy is kept current by the mini poll bar');
  });
}
