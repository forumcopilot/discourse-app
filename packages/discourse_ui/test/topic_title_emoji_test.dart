import 'package:discourse_ui/controllers/post_controller.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/listitems/notification_list_item.dart';
import 'package:discourse_ui/views/listitems/post_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// A topic's title comes off the API as plain text with Discourse emoji
/// shortcodes still in it (`fancy_title` even turns a typed 🎙️ back into
/// `:studio_microphone:`). The topic list and the app bar already swapped
/// them for the glyph; the big title above the first post did not, so
/// meta.discourse.org/t/411337 read "… bundled with Discourse
/// :studio_microphone:" on the topic page itself.
const _site = 'https://forum.example';
const _title =
    'Voice: Discord-style voice and video rooms, now bundled with Discourse '
    ':studio_microphone:';
const _shown =
    'Voice: Discord-style voice and video rooms, now bundled with Discourse '
    '\u{1F399}\u{FE0F}';

SiteContext _ctx() => SiteContext(
      siteType: 'tte-test',
      site: Site(
        id: null,
        name: 'Test',
        url: _site,
        description: '',
        endpoint: null,
        baseUrl: _site,
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'tte-test',
      ),
    );

Widget _app(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  testWidgets('the title above the first post shows the emoji, not its code',
      (tester) async {
    await tester.pumpWidget(_app(PostListItem(
      siteContext: _ctx(),
      post: FCPost(
        id: '11',
        title: '',
        content: '<p>hi</p>',
        topicId: '411337',
        postNumber: 1,
        authorId: '1',
        authorName: 'bob',
        timestamp: DateTime(2026, 10, 1),
      ),
      threadId: '411337',
      topicTitle: _title,
      postController: PostController(),
    )));
    await tester.pump();

    expect(find.textContaining(_shown, findRichText: true), findsOneWidget);
    expect(find.textContaining(':studio_microphone:', findRichText: true),
        findsNothing);
  });

  testWidgets('so does a notification about that topic', (tester) async {
    await tester.pumpWidget(_app(NotificationListItem(
      topic: FCTopic(
        id: '411337',
        title: _title,
        forumId: '',
        forumName: '',
        authorId: '1',
        authorName: 'bob',
        timestamp: DateTime(2026, 10, 1),
      ),
      onTap: () {},
    )));
    await tester.pump();

    expect(find.text(_shown), findsOneWidget);
    expect(find.textContaining(':studio_microphone:'), findsNothing);
  });
}
