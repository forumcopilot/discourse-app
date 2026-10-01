import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/theme/design_tokens.dart';
import 'package:discourse_ui/utils/emoji_shortcodes.dart';
import 'package:discourse_ui/views/widgets/cooked_inline_text.dart';
import 'package:discourse_ui/views/widgets/thread_poll_card.dart';
import 'package:discourse_ui/views/widgets/thread_poll_mini_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// A Discourse poll's options (and title) are cooked HTML, not text: the
/// options of the "What Should We Prioritize Next?" poll on
/// forum.ewelink.cc/t/209155 showed their `<img class="emoji">` markup
/// verbatim. They read as post text does now.
const _forum = 'https://forum.example.com';

/// Option 1 of that poll, exactly as /t/209155.json serves it.
const _doorLock =
    'Door Lock <img src="https://emoji.discourse-cdn.com/apple/red_apple.png?v=15" title=":red_apple:" class="emoji" alt=":red_apple:" loading="lazy" width="20" height="20">'
    '<img src="https://emoji.discourse-cdn.com/apple/house.png?v=15" title=":house:" class="emoji" alt=":house:" loading="lazy" width="20" height="20">'
    '<img src="https://emoji.discourse-cdn.com/apple/speaking_head.png?v=15" title=":speaking_head:" class="emoji" alt=":speaking_head:" loading="lazy" width="20" height="20">'
    '<img src="https://emoji.discourse-cdn.com/apple/star.png?v=15" title=":star:" class="emoji" alt=":star:" loading="lazy" width="20" height="20">';

const _pump =
    'Pump <img src="https://emoji.discourse-cdn.com/apple/star.png?v=15" title=":star:" class="emoji" alt=":star:" loading="lazy" width="20" height="20">';

String _e(String name) => discourseEmojiChar(name)!;

final _doorLockText = 'Door Lock ${_e('red_apple')}${_e('house')}${_e('speaking_head')}${_e('star')}';

final _ctx = SiteContext(
  siteType: 'discourse',
  site: Site(
    id: null,
    name: 'Example',
    url: _forum,
    description: '',
    logoUrl: null,
    backgroundUrl: null,
    endpoint: null,
    baseUrl: _forum,
    siteType: 'discourse',
    language: null,
  ),
);

FCPoll _poll({bool voted = false, String title = ''}) => FCPoll(
      pollId: 'poll',
      topicId: '209155',
      postId: '1',
      question: title,
      responses: [
        FCPollResponse(id: 'a', text: _doorLock, voteCount: voted ? 14 : null, viewerVotedFor: voted),
        FCPollResponse(id: 'b', text: _pump, voteCount: voted ? 2 : null),
      ],
      voterCount: voted ? 30 : null,
      maxVotes: 20,
      canVote: !voted,
      hasVoted: voted,
      canViewResults: voted,
      viewResultsUnvoted: false,
    );

Widget _app(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

/// Every paragraph's text, in order.
List<String> _paragraphs(WidgetTester tester) => [
      for (final p in tester.renderObjectList<RenderParagraph>(find.byType(RichText)))
        p.text.toPlainText(),
    ];

/// The span carrying [text] in [CookedInlineText]'s paragraph.
TextSpan _spanOf(WidgetTester tester, String text) {
  final root = tester.widget<RichText>(find.descendant(of: find.byType(CookedInlineText), matching: find.byType(RichText))).text;
  TextSpan? hit;
  root.visitChildren((span) {
    if (span is TextSpan && span.text?.trim() == text) hit = span;
    return hit == null;
  });
  return hit!;
}

void main() {
  setUp(() => SiteProxyService.initialize(_ctx));

  group('CookedInlineText', () {
    testWidgets('the eWeLink option reads as its words and emoji', (tester) async {
      await tester.pumpWidget(_app(const CookedInlineText(_doorLock)));
      final text = _paragraphs(tester).single;
      expect(text, _doorLockText);
      expect(text, startsWith('Door Lock 🍎🏠'));
      expect(text, isNot(contains('<')));
    });

    testWidgets('inline markup keeps its look; entities are decoded', (tester) async {
      await tester.pumpWidget(_app(const CookedInlineText(
        '<strong>Bold</strong> and <em>soft</em>, <code>x = 1</code>\n  &amp; '
        '<a href="/t/topic/9">a link</a><br>next <s>old</s>',
      )));
      expect(_paragraphs(tester).single, 'Bold and soft, x = 1 & a link\nnext old');
      expect(_spanOf(tester, 'Bold').style?.fontWeight, FontWeight.bold);
      expect(_spanOf(tester, 'soft').style?.fontStyle, FontStyle.italic);
      expect(_spanOf(tester, 'x = 1').style?.fontFamily, 'monospace');
      expect(_spanOf(tester, 'old').style?.decoration, TextDecoration.lineThrough);
      final link = _spanOf(tester, 'a link');
      expect(link.style?.color, AppTheme.lightTheme.colorScheme.primary);
      // Not asked to open links: no tap of its own.
      expect(link.recognizer, isNull);
    });

    testWidgets('links tap through when asked', (tester) async {
      await tester.pumpWidget(_app(CookedInlineText(
        'See <a href="/t/topic/9">the topic</a>',
        siteContext: _ctx,
        openLinks: true,
      )));
      expect(_spanOf(tester, 'the topic').recognizer, isNotNull);
    });

    testWidgets("a forum's own emoji is its picture, from the forum", (tester) async {
      await tester.pumpWidget(_app(CookedInlineText(
        'Ours <img src="/uploads/default/original/1X/abc.png" title=":our_logo:" class="emoji emoji-custom" alt=":our_logo:">',
        siteContext: _ctx,
      )));
      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as NetworkImage).url, '$_forum/uploads/default/original/1X/abc.png');
      expect(image.semanticLabel, ':our_logo:');
    });

    testWidgets('a picture reads as its description', (tester) async {
      await tester.pumpWidget(_app(const CookedInlineText(
        'Logo A <img src="https://forum.example.com/uploads/a.png" alt="red logo" width="690" height="388">',
      )));
      expect(_paragraphs(tester).single, 'Logo A red logo');
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('plain text is drawn as it is', (tester) async {
      await tester.pumpWidget(_app(const CookedInlineText('Yes, 10:30 works')));
      expect(_paragraphs(tester).single, 'Yes, 10:30 works');
    });
  });

  group('ThreadPollCard', () {
    Future<void> pumpCard(WidgetTester tester, FCPoll poll) async {
      await tester.pumpWidget(_app(ThreadPollCard(
        poll: poll,
        topicId: '209155',
        siteContext: _ctx,
        onVoteSuccess: (_) {},
      )));
    }

    testWidgets('options to choose from show no markup', (tester) async {
      await pumpCard(tester, _poll());
      final text = _paragraphs(tester);
      expect(text, contains(_doorLockText));
      expect(text, contains('Pump ${_e('star')}'));
      expect(text.join(' '), isNot(contains('emoji.discourse-cdn.com')));
      // The row, label included, still chooses the option.
      await tester.tap(find.text(_doorLockText, findRichText: true));
      await tester.pump();
      expect(find.byIcon(Icons.check_box), findsOneWidget);
    });

    testWidgets('results show the same labels, the viewer\'s choice a weight up', (tester) async {
      await pumpCard(tester, _poll(voted: true));
      final text = _paragraphs(tester);
      expect(text, contains(_doorLockText));
      expect(text, contains('47%'));
      expect(text.join(' '), isNot(contains('<img')));
      FontWeight? weightOf(int option) => tester
          .widget<RichText>(find.descendant(
            of: find.byType(CookedInlineText).at(option),
            matching: find.byType(RichText),
          ))
          .text
          .style
          ?.fontWeight;
      expect(weightOf(0), DesignTokens.fontWeightMedium);
      expect(weightOf(1), isNot(DesignTokens.fontWeightMedium));
    });

    testWidgets('a cooked title reads as text', (tester) async {
      await pumpCard(tester, _poll(title: 'What next? <img class="emoji" alt=":star:" src="https://emoji.discourse-cdn.com/apple/star.png">'));
      expect(_paragraphs(tester), contains('What next? ${_e('star')}'));
    });
  });

  testWidgets('the mini poll bar reads a cooked title as text', (tester) async {
    await tester.pumpWidget(_app(ThreadPollMiniCard(
      poll: _poll(title: '<strong>Prioritize</strong> <img class="emoji" alt=":house:" src="https://emoji.discourse-cdn.com/apple/house.png">'),
      siteContext: _ctx,
      onTap: () {},
    )));
    expect(_paragraphs(tester), contains('Prioritize ${_e('house')}'));
  });

  test('an emoji image\'s alt names its character', () {
    expect(discourseEmojiForAlt(':red_apple:'), '🍎');
    expect(discourseEmojiForAlt(' :star: '), '⭐');
    expect(discourseEmojiForAlt(':wave:t3:'), discourseEmojiChar('wave', tone: '3'));
    expect(discourseEmojiForAlt(':our_logo:'), isNull);
    expect(discourseEmojiForAlt('red apple'), isNull);
  });
}
