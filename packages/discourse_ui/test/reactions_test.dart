import 'dart:async';

import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/controllers/post_controller.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/utils/post_reactions.dart';
import 'package:discourse_ui/views/listitems/post_list_item.dart';
import 'package:discourse_ui/views/widgets/reaction_glyph.dart';
import 'package:discourse_ui/views/widgets/reaction_picker_sheet.dart';
import 'package:discourse_ui/views/widgets/reaction_users_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post_reaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reacting to a post and seeing who reacted, after the reactions review:
/// the heart stays, shows your reaction and likes on a tap; the summary
/// opens who reacted, per emoji, you first; the picker shows counts and
/// says when a reaction can no longer change.
const _forum = 'https://react.example';

SiteContext _ctx({bool signedIn = true}) {
  final ctx = SiteContext(
    siteType: 'react-test',
    site: Site(
      id: null,
      name: 'Test',
      url: _forum,
      description: '',
      endpoint: null,
      baseUrl: _forum,
      logoUrl: null,
      backgroundUrl: null,
      siteType: 'react-test',
    ),
  );
  if (signedIn) {
    ctx.setLoginData(FCLoginResult(
      result: true,
      resultText: '',
      user: FCUser(id: '2', username: 'alice'),
    ));
  }
  return ctx;
}

Widget _app(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

FCPostReaction _r(String id, int count, {bool mine = false, bool canUndo = true}) =>
    FCPostReaction(id: id, count: count, viewerReacted: mine, canUndo: mine && canUndo);

String _summary(List<FCPostReaction> list) =>
    list.map((r) => '${r.id}:${r.count}${r.viewerReacted ? '*' : ''}').join(' ');

void main() {
  late _Posts posts;

  setUp(() {
    DiscourseValidReactions.clear();
    DiscourseCustomEmoji.clear();
    SharedPreferences.setMockInitialValues({});
    posts = _Posts(_ctx());
    SiteProxyFactory.register('react-test', _Factory(posts));
    SiteProxyService.initialize(_ctx());
    DiscourseValidReactions.store(_forum, ['heart', 'rocket', 'eyes', 'clap']);
  });

  group('the change drawn before the server answers', () {
    test('a like on a post nobody reacted to', () {
      expect(_summary(toggledReactions([], 'heart')), 'heart:1*');
    });

    test('a like among others', () {
      expect(_summary(toggledReactions([_r('heart', 2), _r('rocket', 1)], 'heart')),
          'heart:3* rocket:1');
    });

    test('another emoji replaces yours, and order follows the counts', () {
      final next = toggledReactions(
          [_r('heart', 2), _r('rocket', 1, mine: true), _r('eyes', 1)], 'eyes');
      expect(_summary(next), 'eyes:2* heart:2');
    });

    test('yours again removes it', () {
      expect(_summary(toggledReactions([_r('heart', 1, mine: true), _r('clap', 1)], 'heart')),
          'clap:1');
    });
  });

  group('picker', () {
    Future<String?> open(WidgetTester tester, List<FCPostReaction> reactions,
        {bool locked = false}) async {
      String? chosen = 'not closed';
      await tester.pumpWidget(_app(Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            chosen = await ReactionPickerSheet.show(
              context: context,
              siteContext: _ctx(),
              reactions: reactions,
              locked: locked,
            );
          },
          child: const Text('open'),
        ),
      )));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return chosen;
    }

    testWidgets("opens on this forum's set at once, with counts and yours marked",
        (tester) async {
      await open(tester, [_r('heart', 2), _r('rocket', 1, mine: true)]);
      expect(find.byType(CircularProgressIndicator), findsNothing,
          reason: 'the set is known from the topic');
      expect(find.byType(ReactionGlyph), findsNWidgets(4));
      expect(find.text('2'), findsOneWidget, reason: 'hearts on this post');
      expect(find.text('Tap your reaction again to remove it.'), findsOneWidget);
      // Every row is centred in the sheet, not only the last: the grid was
      // as wide as its widest row and sat against the left edge.
      final sheet = tester.getRect(find.byType(ReactionPickerSheet));
      final tiles = find.byType(ReactionGlyph);
      final left = tester.getCenter(tiles.first).dx - sheet.left;
      final right = sheet.right - tester.getCenter(tiles.at(3)).dx;
      expect((left - right).abs(), lessThan(2));
    });

    testWidgets('hands back the choice', (tester) async {
      String? chosen;
      await tester.pumpWidget(_app(Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            chosen = await ReactionPickerSheet.show(
                context: context, siteContext: _ctx(), reactions: const []);
          },
          child: const Text('open'),
        ),
      )));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(ReactionGlyph.unicodeFor('eyes')!));
      await tester.pumpAndSettle();
      expect(chosen, 'eyes');
    });

    testWidgets('after the change window, says so and offers nothing',
        (tester) async {
      await open(tester, [_r('rocket', 1, mine: true, canUndo: false)], locked: true);
      expect(find.text('You can no longer change your reaction to this post.'),
          findsOneWidget);
      await tester.tap(find.text(ReactionGlyph.unicodeFor('eyes')!));
      await tester.pumpAndSettle();
      expect(find.byType(ReactionPickerSheet), findsOneWidget, reason: 'still open');
    });
  });

  group('who reacted', () {
    Future<void> open(WidgetTester tester, {VoidCallback? onReact}) async {
      await tester.pumpWidget(_app(Builder(
        builder: (context) => TextButton(
          onPressed: () => ReactionUsersSheet.show(
            context: context,
            siteContext: _ctx(),
            postId: '42',
            reactions: [_r('heart', 2), _r('rocket', 1, mine: true)],
            onReact: onReact,
          ),
          child: const Text('open'),
        ),
      )));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('you first, then everyone by name, with a chip per emoji',
        (tester) async {
      posts.users = const [
        DiscourseReactionUser(userId: '9', username: 'samr', name: 'Sam Rivera', reaction: 'heart'),
        DiscourseReactionUser(userId: '2', username: 'alice', reaction: 'rocket'),
        DiscourseReactionUser(userId: '8', username: 'jonas', reaction: 'heart'),
      ];
      await open(tester);
      expect(find.text('3 reactions'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('You'), findsOneWidget);
      expect(find.text('alice'), findsOneWidget, reason: 'listed once, as you');
      expect(tester.getTopLeft(find.text('alice')).dy,
          lessThan(tester.getTopLeft(find.text('Sam Rivera')).dy));
      expect(find.text('@samr'), findsOneWidget);
      expect(find.text('jonas'), findsOneWidget, reason: 'no name: the username');

      await tester.tap(find.widgetWithText(ChoiceChip, '2'));
      await tester.pumpAndSettle();
      expect(posts.userQueries.last, 'heart');
      expect(find.text('You'), findsNothing, reason: 'you reacted with a rocket');
    });

    testWidgets('the button opens the picker, for a reader who may react',
        (tester) async {
      posts.users = const [];
      var picked = 0;
      await open(tester, onReact: () => picked++);
      await tester.tap(find.text('Change your reaction'));
      await tester.pumpAndSettle();
      expect(picked, 1);
      expect(find.byType(ReactionUsersSheet), findsNothing);
    });

    testWidgets('no button for a reader who may not', (tester) async {
      posts.users = const [];
      await open(tester);
      expect(find.text('Change your reaction'), findsNothing);
      expect(find.text('React'), findsNothing);
    });
  });

  testWidgets("a forum's own emoji is its picture, once the list arrives",
      (tester) async {
    final arrived = Completer<Object?>();
    DiscourseCustomEmoji.fetchOverride = (_) => arrived.future;
    addTearDown(() => DiscourseCustomEmoji.fetchOverride = null);
    await tester.pumpWidget(_app(ReactionGlyph(reactionId: 'discourse', size: 20, siteContext: _ctx())));
    expect(find.byIcon(Icons.emoji_emotions_outlined), findsOneWidget,
        reason: 'not a heart: it read as a like');
    expect(find.byIcon(Icons.favorite), findsNothing);
    arrived.complete({
      'default': [
        {'name': 'discourse', 'url': '//cdn.example/discourse.png'},
      ],
    });
    await tester.pump();
    await tester.pump();
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as ResizeImage).imageProvider, isA<NetworkImage>());
    expect(((image.image as ResizeImage).imageProvider as NetworkImage).url,
        'https://cdn.example/discourse.png');
  });

  group('on a post', () {
    FCPost post({List<FCPostReaction> reactions = const [], bool canLike = true}) => FCPost(
          id: '42',
          title: '',
          content: '<p>hi</p>',
          topicId: '7',
          postNumber: 3,
          authorId: '1',
          authorName: 'bob',
          timestamp: DateTime(2026, 10, 1),
          canLike: canLike,
          reactions: reactions,
        );

    Future<void> pump(WidgetTester tester, FCPost p) async {
      await tester.pumpWidget(_app(SingleChildScrollView(
        child: PostListItem(
          siteContext: _ctx(),
          post: p,
          threadId: '7',
          topicTitle: 't',
          postController: PostController(),
        ),
      )));
      await tester.pump();
    }

    testWidgets('a tap likes at once; the answer replaces the guess',
        (tester) async {
      final answer = Completer<FCToggleReactionResult>();
      posts.nextToggle = answer.future;
      await pump(tester, post(reactions: [_r('rocket', 2)]));
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();
      expect(posts.toggles, ['42 heart viewerReacted=false']);
      expect(find.byIcon(Icons.favorite), findsOneWidget, reason: 'drawn before the answer');
      expect(find.text('3'), findsOneWidget);
      answer.complete(FCToggleReactionResult(
          result: true, reactions: [_r('rocket', 2), _r('heart', 2, mine: true)]));
      await tester.pumpAndSettle();
      expect(find.text('4'), findsOneWidget, reason: "the server's count wins");
      expect(find.text('Tip: long-press the heart for more reactions.'), findsOneWidget,
          reason: 'once, after the first like');
    });

    testWidgets('a refusal puts it back and says why', (tester) async {
      posts.nextToggle = Future.value(
          FCToggleReactionResult(result: false, resultText: 'You cannot like this'));
      await pump(tester, post());
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
      expect(find.text('You cannot like this'), findsOneWidget);
    });

    testWidgets('a tap on your like removes it, telling the proxy you had',
        (tester) async {
      posts.nextToggle = Future.value(FCToggleReactionResult(result: true, reactions: const []));
      await pump(tester, post(canLike: false, reactions: [_r('heart', 1, mine: true)]));
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();
      expect(posts.toggles, ['42 heart viewerReacted=true']);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget,
          reason: 'may react again, though can_act was off');
    });

    testWidgets('past the change window a tap explains and sends nothing',
        (tester) async {
      await pump(tester, post(canLike: false, reactions: [_r('heart', 1, mine: true, canUndo: false)]));
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();
      expect(posts.toggles, isEmpty);
      expect(find.text('You can no longer change your reaction to this post.'), findsOneWidget);
    });

    testWidgets('a hold opens the picker, and the choice is sent', (tester) async {
      posts.nextToggle = Future.value(
          FCToggleReactionResult(result: true, reactions: [_r('rocket', 1, mine: true)]));
      await pump(tester, post());
      await tester.longPress(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();
      expect(find.byType(ReactionPickerSheet), findsOneWidget);
      await tester.tap(find.text(ReactionGlyph.unicodeFor('rocket')!));
      await tester.pumpAndSettle();
      expect(posts.toggles, ['42 rocket viewerReacted=false']);
      expect(find.byIcon(Icons.favorite_border), findsNothing,
          reason: 'your rocket is the button now');
    });

    testWidgets("someone else's reaction arrives while you read", (tester) async {
      await pump(tester, post(reactions: [_r('heart', 1)]));
      DiscourseLiveReactions.publish(DiscourseReactionUpdate(
          siteUrl: _forum, postId: '42', reactions: [_r('heart', 1), _r('clap', 1)]));
      // Delivered on a microtask, then drawn on the next frame.
      await tester.pump();
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
      DiscourseLiveReactions.publish(DiscourseReactionUpdate(
          siteUrl: 'https://other.example', postId: '42', reactions: [_r('heart', 9)]));
      await tester.pump();
      expect(find.text('9'), findsNothing, reason: 'another forum\'s post 42');
    });
  });
}

class _Posts extends DiscoursePostProxy {
  _Posts(super.context);

  List<DiscourseReactionUser> users = const [];
  final List<String?> userQueries = [];
  Future<FCToggleReactionResult>? nextToggle;
  final List<String> toggles = [];

  @override
  Future<DiscourseReactionUsersResult> getReactionUsersAsync(String postId,
      {String? reactionId, int page = 0, int limit = 30}) async {
    userQueries.add(reactionId);
    final rows = reactionId == null ? users : users.where((u) => u.reaction == reactionId).toList();
    return DiscourseReactionUsersResult(result: true, users: rows, total: rows.length);
  }

  @override
  Future<FCToggleReactionResult> toggleReactionAsync(String postId, String reactionId,
      {bool? viewerReacted}) {
    toggles.add('$postId $reactionId viewerReacted=$viewerReacted');
    return nextToggle ?? Future.value(FCToggleReactionResult(result: false));
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
