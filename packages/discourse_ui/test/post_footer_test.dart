import 'package:discourse_ui/controllers/post_controller.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/listitems/post_list_item.dart';
import 'package:discourse_ui/views/listitems/post_list_item_social.dart';
import 'package:discourse_ui/views/widgets/post_action_button.dart';
import 'package:discourse_ui/views/widgets/reaction_glyph.dart';
import 'package:discourse_ui/views/widgets/remote_circle_avatar.dart';
import 'package:discourse_ui/views/widgets/topic_stats_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post_reaction.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';

/// The footer of a post and the summary that closes the opening post,
/// laid out as Discourse web lays them out.
Widget _app(Widget child, {double textScale = 1, double width = 390}) =>
    MaterialApp(
      theme: AppTheme.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 800),
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    );

FCPost _post({
  bool canLike = true,
  bool isSolution = false,
  bool canAcceptAnswer = false,
}) =>
    FCPost(
      id: '11',
      title: '',
      content: '<p>hi</p>',
      topicId: '7',
      postNumber: 4,
      authorId: '1',
      authorName: 'bob',
      timestamp: DateTime(2026, 9, 28),
      canLike: canLike,
      isSolution: isSolution,
      canAcceptAnswer: canAcceptAnswer,
    );

SiteContext _signedIn() => SiteContext(
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
    )..setLoginData(FCLoginResult(
        result: true,
        resultText: '',
        user: FCUser(id: '2', username: 'alice'),
      ));

final _reactions = [FCPostReaction(id: 'heart', count: 2)];

Color? _iconColor(WidgetTester tester, IconData icon) =>
    tester.widget<Icon>(find.byIcon(icon)).color;

void main() {
  group('action buttons', () {
    testWidgets('read as live controls, and Reply reads strongest',
        (tester) async {
      await tester.pumpWidget(_app(const Row(children: [
        PostActionButton(icon: Icons.bookmark_border, semanticLabel: 'b'),
        PostActionButton(
            icon: Icons.reply_rounded, semanticLabel: 'r', emphasized: true),
      ])));
      final scheme = AppTheme.darkTheme.colorScheme;
      expect(_iconColor(tester, Icons.bookmark_border), scheme.onSurfaceVariant,
          reason: 'was faded to 50%, a hair above the disabled 38%');
      expect(_iconColor(tester, Icons.reply_rounded), scheme.onSurface);
    });

    testWidgets('grow with the text size, up to a cap', (tester) async {
      Future<double> sizeAt(double scale) async {
        await tester.pumpWidget(_app(
            const PostActionButton(
                icon: Icons.bookmark_border, semanticLabel: 'b'),
            textScale: scale));
        return tester.widget<Icon>(find.byIcon(Icons.bookmark_border)).size!;
      }

      expect(await sizeAt(1), 24);
      expect(await sizeAt(1.2), closeTo(28.8, 0.01));
      expect(await sizeAt(2), closeTo(24 * PostActionButton.maxIconScale, 0.01));
    });
  });

  group('action row', () {
    Widget row({
      required FCPost post,
      bool loggedIn = true,
      List<FCPostReaction> reactions = const [],
      bool hasMore = true,
      VoidCallback? onReact,
      VoidCallback? onMore,
      VoidCallback? onShowReactors,
      Widget? leading,
      Widget? trailing,
    }) =>
        _app(PostListItemSocial(
          post: post,
          isLoggedIn: loggedIn,
          reactions: reactions,
          hasMoreReactions: hasMore,
          onReact: onReact,
          onMoreReactions: onMore,
          onShowReactors: onShowReactors,
          onBookmark: () {},
          leading: leading,
          trailing: trailing,
        ));

    testWidgets('the replies disclosure leads, Reply ends the row',
        (tester) async {
      await tester.pumpWidget(row(
        post: _post(),
        leading: const Text('1 reply'),
        trailing: const PostActionButton(
            icon: Icons.reply_rounded, semanticLabel: 'Reply'),
      ));
      final leading = tester.getTopLeft(find.text('1 reply'));
      final heart = tester.getCenter(find.byIcon(Icons.favorite_border));
      final bookmark = tester.getCenter(find.byIcon(Icons.bookmark_border));
      final reply = tester.getCenter(find.byIcon(Icons.reply_rounded));
      expect(leading.dx, 0);
      expect(heart.dx, lessThan(bookmark.dx));
      expect(bookmark.dx, lessThan(reply.dx));
      expect(reply.dx, greaterThan(390 - 48),
          reason: 'right-aligned, as web packs its post menu');
    });

    testWidgets('once others reacted, the heart stays beside the count',
        (tester) async {
      // Defect: the heart was replaced by the count as soon as anyone
      // reacted, so the way to react disappeared.
      var reacts = 0, lists = 0;
      await tester.pumpWidget(row(
        post: _post(),
        reactions: _reactions,
        onReact: () => reacts++,
        onShowReactors: () => lists++,
      ));
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(tester.getCenter(find.text('2')).dx,
          lessThan(tester.getCenter(find.byIcon(Icons.favorite_border)).dx),
          reason: 'the summary sits just before the button, as on web');
      await tester.tap(find.text('2'));
      expect(lists, 1, reason: 'a tap on the count lists who reacted');
      await tester.tap(find.byIcon(Icons.favorite_border));
      expect(reacts, 1);
    });

    testWidgets('with only likes the summary is the bare number',
        (tester) async {
      await tester.pumpWidget(row(post: _post(), reactions: _reactions));
      expect(find.byType(ReactionGlyph), findsNothing);
    });

    testWidgets('mixed reactions show the three most used and everyone',
        (tester) async {
      await tester.pumpWidget(row(post: _post(), reactions: [
        FCPostReaction(id: 'heart', count: 5),
        FCPostReaction(id: 'rocket', count: 3),
        FCPostReaction(id: 'eyes', count: 1),
        FCPostReaction(id: 'clap', count: 1),
      ]));
      expect(find.byType(ReactionGlyph), findsNWidgets(3));
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets("your like is a filled heart; a tap is the caller's to undo",
        (tester) async {
      final semantics = tester.ensureSemantics();
      var reacts = 0;
      // Discourse leaves `can_act` off once you have acted.
      await tester.pumpWidget(row(
        post: _post(canLike: false),
        reactions: [
          FCPostReaction(id: 'heart', count: 3, viewerReacted: true, canUndo: true),
        ],
        onReact: () => reacts++,
      ));
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
      expect(find.bySemanticsLabel('You liked this. Tap to remove your like.'),
          findsOneWidget);
      await tester.tap(find.byIcon(Icons.favorite));
      expect(reacts, 1);
      semantics.dispose();
    });

    testWidgets('your other reaction is the button, not a colour',
        (tester) async {
      // Defect: the only sign was the count turning blue.
      final semantics = tester.ensureSemantics();
      var reacts = 0;
      await tester.pumpWidget(row(
        post: _post(canLike: false),
        reactions: [
          FCPostReaction(id: 'heart', count: 2),
          FCPostReaction(id: 'rocket', count: 1, viewerReacted: true, canUndo: true),
        ],
        onReact: () => reacts++,
      ));
      expect(find.byIcon(Icons.favorite_border), findsNothing);
      final button = find.bySemanticsLabel('Your reaction: rocket. Tap to remove it.');
      expect(button, findsOneWidget);
      await tester.tap(button);
      expect(reacts, 1);
      semantics.dispose();
    });

    testWidgets('past the change window it dims, and a hold opens nothing',
        (tester) async {
      final semantics = tester.ensureSemantics();
      var reacts = 0, more = 0;
      await tester.pumpWidget(row(
        post: _post(canLike: false),
        reactions: [
          FCPostReaction(id: 'rocket', count: 1, viewerReacted: true, canUndo: false),
        ],
        onReact: () => reacts++,
        onMore: () => more++,
      ));
      final button = find.bySemanticsLabel(
          'Your reaction: rocket. It can no longer be changed.');
      expect(button, findsOneWidget);
      expect(
          find.ancestor(of: find.byType(ReactionGlyph).last, matching: find.byType(Opacity)),
          findsOneWidget);
      await tester.longPress(button);
      expect(more, 0, reason: 'no picker to change what cannot change');
      expect(reacts, 1, reason: 'a hold explains, as a tap does');
      await tester.tap(button);
      expect(reacts, 2, reason: 'the tap explains, through the caller');
      semantics.dispose();
    });

    testWidgets('a hold opens the picker only where there is one',
        (tester) async {
      var more = 0;
      await tester.pumpWidget(row(post: _post(), onMore: () => more++));
      await tester.longPress(find.byIcon(Icons.favorite_border));
      expect(more, 1);
      await tester.pumpWidget(row(post: _post(), hasMore: false, onMore: () => more++));
      await tester.longPress(find.byIcon(Icons.favorite_border));
      expect(more, 1, reason: 'a forum with nothing but the like');
    });

    testWidgets("your own post's reactions show, and a tap lists who",
        (tester) async {
      var reacts = 0, lists = 0;
      // Discourse leaves `can_act` off the author's own post.
      await tester.pumpWidget(row(
        post: _post(canLike: false),
        reactions: _reactions,
        onReact: () => reacts++,
        onShowReactors: () => lists++,
      ));
      expect(find.text('2'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing,
          reason: 'no reacting to your own post');
      await tester.tap(find.text('2'));
      expect(lists, 1);
      expect(reacts, 0);
    });

    testWidgets('a guest sees the reactions too', (tester) async {
      await tester.pumpWidget(
          row(post: _post(), loggedIn: false, reactions: _reactions));
      expect(find.text('2'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border), findsNothing);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('nothing to show leaves no empty 48dp row', (tester) async {
      await tester.pumpWidget(row(post: _post(), loggedIn: false));
      expect(tester.getSize(find.byType(PostListItemSocial)).height,
          lessThan(kMinInteractiveDimension));
    });
  });

  group('topic summary', () {
    FCTopic topic({
      int views = 42,
      int likes = 1,
      int users = 3,
      List<String> faces = const ['', '', ''],
    }) =>
        FCTopic(
          id: '7',
          title: 't',
          forumId: '1',
          forumName: 'f',
          authorId: '1',
          authorName: 'a',
          timestamp: DateTime(2026, 9, 28),
          viewCount: views,
          likeCount: likes,
          participantCount: users,
          participantIconUrls: faces,
        );

    testWidgets('each number sits over its label', (tester) async {
      await tester.pumpWidget(_app(TopicStatsBar(topic: topic())));
      for (final (n, label) in [('42', 'views'), ('1', 'like'), ('3', 'users')]) {
        expect(tester.getCenter(find.text(n)).dy,
            lessThan(tester.getCenter(find.text(label)).dy));
        expect(tester.getCenter(find.text(n)).dx,
            closeTo(tester.getCenter(find.text(label)).dx, 0.5));
      }
      expect(find.byType(RemoteCircleAvatar), findsNWidgets(3));
      expect(find.bySemanticsLabel('42 views'), findsOneWidget);
    });

    testWidgets('faces once two people have taken part', (tester) async {
      await tester.pumpWidget(_app(TopicStatsBar(topic: topic(faces: ['']))));
      expect(find.byType(RemoteCircleAvatar), findsNothing);
    });

    testWidgets('nothing to report renders nothing', (tester) async {
      await tester.pumpWidget(_app(TopicStatsBar(
          topic: topic(views: 0, likes: 0, users: 0, faces: const []))));
      expect(tester.getSize(find.byType(TopicStatsBar)).height, 0);
    });

    testWidgets('a narrow phone at large text drops faces, never overflows',
        (tester) async {
      await tester.pumpWidget(_app(
        TopicStatsBar(
            topic: topic(
                views: 12345, likes: 678, users: 90, faces: List.filled(5, ''))),
        width: 320,
        textScale: 2,
      ));
      expect(tester.takeException(), isNull);
      expect(find.byType(RemoteCircleAvatar).evaluate().length, lessThan(5));
    });
  });

  group('solution', () {
    Future<void> pumpPost(WidgetTester tester, FCPost post) async {
      await tester.pumpWidget(_app(SingleChildScrollView(
        child: PostListItem(
          siteContext: _signedIn(),
          post: post,
          threadId: '7',
          topicTitle: 't',
          postController: PostController(),
        ),
      )));
      await tester.pump();
    }

    Future<List<String>> menu(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();
      return tester
          .widgetList<PopupMenuItem<String>>(find.byType(PopupMenuItem<String>))
          .map((i) => i.value!)
          .toList();
    }

    testWidgets("the solved post's label is not a button in the row",
        (tester) async {
      // alice may not accept: `can_accept_answer` false on the solution.
      await pumpPost(tester, _post(isSolution: true));
      expect(find.text('Solution'), findsOneWidget,
          reason: 'the label above the body says it is the solution');
      expect(find.byIcon(Icons.check_circle_outline), findsNothing);
      expect(find.byIcon(Icons.check_circle), findsOneWidget,
          reason: "only the label's own glyph");
      expect(await menu(tester),
          isNot(anyOf(contains('accept_answer'), contains('unaccept_answer'))));
    });

    testWidgets('marking is in the menu, for readers who may accept',
        (tester) async {
      await pumpPost(tester, _post(canAcceptAnswer: true));
      expect(find.byIcon(Icons.check_circle_outline), findsNothing,
          reason: 'no longer in the action row');
      expect(await menu(tester), contains('accept_answer'));
      expect(find.text('Mark as solution'), findsOneWidget);
    });

    testWidgets('and so is unmarking', (tester) async {
      await pumpPost(tester, _post(canAcceptAnswer: true, isSolution: true));
      expect(await menu(tester), contains('unaccept_answer'));
      expect(find.text('Unmark as solution'), findsOneWidget);
    });
  });
}
