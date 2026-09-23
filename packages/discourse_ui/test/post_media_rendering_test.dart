import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/utils/cooked_content.dart';
import 'package:discourse_ui/views/widgets/embed_cards.dart';
import 'package:discourse_ui/views/widgets/post_content_callbacks.dart';
import 'package:discourse_ui/views/widgets/rich_text_content.dart';
import 'package:discourse_ui/views/widgets/twitter_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Content the September 2026 thread-rendering audit found missing from
/// posts: tables, videos, audio, embeds and tweets. As in
/// post_body_rendering_test.dart, the HTML is the shape Discourse cooks for
/// each construct, written out by hand.
const _forum = 'https://forum.example.com';

/// The thread page's body width on a 393dp-wide phone.
const double _column = 361;

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

final _bodyKey = GlobalKey();

/// URLs the post asked to open, in order.
final _opened = <String>[];

Future<void> _render(WidgetTester tester, String cooked, {ThemeData? theme}) async {
  _opened.clear();
  final html = CookedContent.parse(cooked, forumBaseUrl: _forum).html;
  await tester.pumpWidget(MaterialApp(
    theme: theme ?? AppTheme.lightTheme,
    home: Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            key: _bodyKey,
            width: _column,
            child: RichTextContent(
              siteContext: _ctx,
              content: html,
              callbacks: PostContentCallbacks(onUrlTap: _opened.add),
            ),
          ),
        ),
      ),
    ),
  ));
  await tester.pump();
}

String _renderedText(WidgetTester tester) {
  final sb = StringBuffer();
  void walk(RenderObject r) {
    if (r is RenderParagraph) sb.write('${r.text.toPlainText()} ');
    r.visitChildren(walk);
  }

  walk(tester.renderObject(find.byKey(_bodyKey)));
  return sb.toString();
}

Rect _rectOfText(WidgetTester tester, String text) =>
    tester.getRect(find.byWidgetPredicate((w) =>
        w is RichText && w.text.toPlainText().trim() == text));

const _mdTable = '''
<p>Before the table.</p>
<div class="md-table">
<table>
<thead>
<tr>
<th>Setting</th>
<th style="text-align:right">Default</th>
<th>Notes</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>max_width</code></td>
<td style="text-align:right">690</td>
<td>Wider uploads are scaled down to this, keeping their proportions, and the original stays one tap away.</td>
</tr>
<tr>
<td>docs</td>
<td style="text-align:right">1</td>
<td>See <a href="https://example.org/docs">the guide</a></td>
</tr>
</tbody>
</table>
</div>
<p>After the table.</p>''';

void main() {
  group('tables', () {
    testWidgets('every cell is shown, in rows and columns', (tester) async {
      await _render(tester, _mdTable);
      final text = _renderedText(tester);
      for (final cell in ['Setting', 'Default', 'Notes', 'max_width', '690', 'docs', 'the guide']) {
        expect(text, contains(cell), reason: 'cell "$cell" must be rendered');
      }
      expect(text, contains('Before the table.'));
      expect(text, contains('After the table.'));

      // A row reads left to right; the next row is below it.
      final setting = _rectOfText(tester, 'Setting');
      final notes = _rectOfText(tester, 'Notes');
      final docs = _rectOfText(tester, 'docs');
      expect(notes.left, greaterThan(setting.right));
      expect((notes.center.dy - setting.center.dy).abs(), lessThan(4));
      expect(docs.top, greaterThan(setting.bottom));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a long cell wraps inside the post width instead of scrolling',
        (tester) async {
      // Short words: the test font draws every glyph as a square, so a
      // long word would legitimately need more than the column.
      await _render(tester, '''
<div class="md-table"><table>
<thead><tr><th>Key</th><th>Say</th></tr></thead>
<tbody><tr><td>a</td><td>one two six ten and the cat sat on a mat by the red box</td></tr></tbody>
</table></div>''');
      final body = tester.getRect(find.byKey(_bodyKey));
      final long = tester.getRect(find.byWidgetPredicate((w) =>
          w is RichText && w.text.toPlainText().startsWith('one two')));
      expect(long.right, lessThanOrEqualTo(body.right + 0.5));
      expect(long.height, greaterThan(40), reason: 'the sentence wraps');
      final scroll = tester.state<ScrollableState>(find.descendant(
          of: find.byKey(_bodyKey), matching: find.byType(Scrollable)));
      expect(scroll.position.maxScrollExtent, 0, reason: 'nothing to scroll');
    });

    testWidgets('cell alignment from style="text-align:right" is kept', (tester) async {
      await _render(tester, _mdTable);
      final text = tester.widget<RichText>(find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().trim() == '690'));
      expect(text.textAlign, TextAlign.right);
    });

    testWidgets('a table too wide for the post scrolls sideways', (tester) async {
      final cells = List.generate(9, (i) => '<td>column_${i}_value_long</td>').join();
      final heads = List.generate(9, (i) => '<th>Heading $i</th>').join();
      await _render(tester,
          '<div class="md-table"><table><thead><tr>$heads</tr></thead><tbody><tr>$cells</tr></tbody></table></div>');
      final scroll = find.descendant(
          of: find.byKey(_bodyKey), matching: find.byType(SingleChildScrollView));
      expect(scroll, findsOneWidget);
      final position = tester.state<ScrollableState>(find.descendant(
              of: scroll, matching: find.byType(Scrollable)))
          .position;
      expect(position.maxScrollExtent, greaterThan(0));
      expect(_renderedText(tester), contains('column_8_value_long'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('colspan and rowspan place cells like a browser', (tester) async {
      await _render(tester, '''
<table>
<tr><th colspan="2">Both</th><th>Third</th></tr>
<tr><td rowspan="2">Tall</td><td>b1</td><td>c1</td></tr>
<tr><td>b2</td><td>c2</td></tr>
</table>''');
      final tall = _rectOfText(tester, 'Tall');
      final b1 = _rectOfText(tester, 'b1');
      final b2 = _rectOfText(tester, 'b2');
      final c2 = _rectOfText(tester, 'c2');
      // b2 sits under b1 (column 2), not under Tall.
      expect((b2.left - b1.left).abs(), lessThan(1));
      expect(b2.left, greaterThan(tall.right));
      expect(c2.left, greaterThan(b2.right));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a table inside a table cell renders', (tester) async {
      await _render(tester, '''
<table><tr><td>outer</td><td><table><tr><td>inner</td></tr></table></td></tr></table>''');
      final text = _renderedText(tester);
      expect(text, contains('outer'));
      expect(text, contains('inner'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in the dark theme with theme-coloured rules', (tester) async {
      await _render(tester, _mdTable, theme: AppTheme.darkTheme);
      expect(_renderedText(tester), contains('the guide'));
      expect(tester.takeException(), isNull);
    });
  });

  group('videos', () {
    const lazyYouTube = """
<p>Before the video.</p>
<div class="youtube-onebox lazy-video-container" data-video-id="aqz-KE-bpKQ" data-video-title="Big Buck Bunny 60fps 4K" data-video-start-time="42" data-video-list-id="" data-provider-name="youtube">
  <a href="https://www.youtube.com/watch?v=aqz-KE-bpKQ&amp;t=42" target="_blank" class="video-thumbnail" rel="noopener">
    <img class="youtube-thumbnail" src="/uploads/default/original/1X/thumb.jpeg" title="Big Buck Bunny 60fps 4K" width="690" height="388">
  </a>
</div>
<p>After the video.</p>""";

    testWidgets('a YouTube embed is a preview in place: thumbnail, title, play',
        (tester) async {
      await _render(tester, lazyYouTube);
      expect(find.byType(EmbedPreviewCard), findsOneWidget);
      expect(find.text('Big Buck Bunny 60fps 4K'), findsOneWidget);

      // Between the paragraphs, as on the web — not appended below the post.
      final card = tester.getRect(find.byType(EmbedPreviewCard));
      expect(card.top, greaterThan(_rectOfText(tester, 'Before the video.').bottom));
      expect(card.bottom, lessThan(_rectOfText(tester, 'After the video.').top));
      // 16:9 across the post.
      expect(card.width, closeTo(_column, 1));

      await tester.tap(find.byType(EmbedPreviewCard));
      expect(_opened, ['https://www.youtube.com/watch?v=aqz-KE-bpKQ&t=42']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Vimeo and TikTok lazy videos open their own page', (tester) async {
      await _render(tester, """
<div class="vimeo-onebox lazy-video-container" data-video-id="76979871?h=8272103f6e&amp;app_id=122963" data-video-title="The New Vimeo Player" data-provider-name="vimeo">
  <a href="https://vimeo.com/76979871/8272103f6e" target="_blank"><img class="vimeo-thumbnail" src="https://forum.example.com/uploads/vimeo.jpeg" width="690" height="388"></a>
</div>
<div class="tiktok-onebox lazy-video-container" data-video-id="7000000000000000000" data-video-title="A dance" data-provider-name="tiktok">
  <a href="https://www.tiktok.com/@someone/video/7000000000000000000" target="_blank"><img class="tiktok-thumbnail" src="https://forum.example.com/uploads/tiktok.jpeg" width="332" height="745"></a>
</div>""");
      expect(find.byType(EmbedPreviewCard), findsNWidgets(2));
      expect(find.text('The New Vimeo Player'), findsOneWidget);
      await tester.tap(find.text('The New Vimeo Player'));
      await tester.tap(find.text('A dance'));
      expect(_opened, [
        'https://vimeo.com/76979871/8272103f6e',
        'https://www.tiktok.com/@someone/video/7000000000000000000',
      ]);
      // TikTok is tall, but kept to a sensible height.
      final tiktok = tester.getRect(find.byType(EmbedPreviewCard).last);
      expect(tiktok.height, greaterThan(tiktok.width));
      expect(tiktok.height, lessThanOrEqualTo(480 + 16 + 1));
    });

    testWidgets('a bare YouTube player iframe becomes a preview; its hidden twin does not show',
        (tester) async {
      await _render(tester, """
<p><img class="youtube-thumbnail onebox" style="display: none;" src="https://img.youtube.com/vi/aqz-KE-bpKQ/maxresdefault.jpg" width="690" height="388">
<iframe src="https://www.youtube.com/embed/aqz-KE-bpKQ?feature=oembed&amp;wmode=opaque" width="480" height="360" frameborder="0" allowfullscreen="" class="youtube-onebox"></iframe></p>""");
      expect(find.byType(EmbedPreviewCard), findsOneWidget);
      final images = tester.widgetList<Image>(find.byType(Image)).map((i) => i.image.toString());
      expect(images.where((i) => i.contains('maxresdefault')), isEmpty);
      await tester.tap(find.byType(EmbedPreviewCard));
      expect(_opened, ['https://www.youtube.com/watch?v=aqz-KE-bpKQ']);
    });

    testWidgets('a video link the forum did not embed still gets a preview', (tester) async {
      await _render(tester,
          '<p><a href="https://youtu.be/aqz-KE-bpKQ" class="onebox" target="_blank">https://youtu.be/aqz-KE-bpKQ</a></p>');
      expect(find.byType(EmbedPreviewCard), findsOneWidget);
    });

    testWidgets('an uploaded video shows its poster and plays in the app', (tester) async {
      await _render(tester, """
<p></p><div class="video-placeholder-container" data-video-src="/uploads/default/original/3X/clip.mp4" data-thumbnail-src="https://forum.example.com/uploads/default/original/3X/clip.jpeg" data-video-base62-sha1="abc.mp4">
  </div><p></p>
<video width="640" height="360" controls><source src="https://forum.example.com/uploads/default/original/3X/other.mp4"></video>""");
      final cards = tester.widgetList<PostVideoCard>(find.byType(PostVideoCard)).toList();
      expect(cards, hasLength(2));
      expect(cards.first.src, 'https://forum.example.com/uploads/default/original/3X/clip.mp4');
      expect(cards.first.poster, 'https://forum.example.com/uploads/default/original/3X/clip.jpeg');
      expect(cards.last.src, 'https://forum.example.com/uploads/default/original/3X/other.mp4');
      expect(cards.last.aspectRatio, closeTo(640 / 360, 0.001));
    });

    testWidgets('an audio upload gets a player in place', (tester) async {
      await _render(tester, """
<p><audio preload="metadata" controls="">
    <source src="https://forum.example.com/uploads/default/original/1X/jingle.mp3">
    <a href="https://forum.example.com/uploads/default/original/1X/jingle.mp3">https://forum.example.com/uploads/default/original/1X/jingle.mp3</a>
  </audio> A jingle for the contest.</p>""");
      expect(find.byType(PostAudioPlayer), findsOneWidget);
      expect(tester.widget<PostAudioPlayer>(find.byType(PostAudioPlayer)).src,
          'https://forum.example.com/uploads/default/original/1X/jingle.mp3');
      expect(_renderedText(tester), contains('A jingle for the contest.'));
      expect(tester.takeException(), isNull);
    });
  });

  group('other embeds', () {
    testWidgets('a Spotify player is a row naming the track and the site', (tester) async {
      await _render(tester,
          '<p><iframe src="https://open.spotify.com/embed/track/4uLU6hMCjMI75M1A2tKUQC" title="Spotify Embed: Never Gonna Give You Up" width="100%" height="152"></iframe></p>');
      expect(find.byType(EmbedPreviewCard), findsOneWidget);
      expect(find.text('Never Gonna Give You Up'), findsOneWidget);
      expect(find.text('Spotify'), findsOneWidget);
      await tester.tap(find.byType(EmbedPreviewCard));
      expect(_opened, ['https://open.spotify.com/track/4uLU6hMCjMI75M1A2tKUQC']);
    });

    testWidgets('a Reddit embed opens the post, an unknown site shows its host',
        (tester) async {
      await _render(tester, """
<iframe class="reddit-onebox" src="https://embed.reddit.com/r/flutterdev/comments/abc123/some_title/?embed=true" width="640" height="500"></iframe>
<p><iframe src="https://www.example-widgets.net/widget/7" width="100%" height="300"></iframe></p>""");
      expect(find.text('r/flutterdev'), findsOneWidget);
      expect(find.text('Reddit'), findsOneWidget);
      expect(find.text('example-widgets.net'), findsNWidgets(2), reason: 'name and address');
      await tester.tap(find.text('Reddit'));
      expect(_opened, ['https://www.reddit.com/r/flutterdev/comments/abc123/some_title/']);
    });

    testWidgets('a tweet onebox keeps its text; its avatar stays small', (tester) async {
      await _render(tester, """
<aside class="onebox twitterstatus" data-onebox-src="https://x.com/discourse/status/1">
  <header class="source"><a href="https://x.com/discourse/status/1" target="_blank">x.com</a></header>
  <article class="onebox-body">
    <img src="https://pbs.twimg.com/profile_images/1/a_400x400.jpg" class="thumbnail onebox-avatar" width="400" height="400">
    <h4><a href="https://x.com/discourse/status/1" target="_blank">Discourse</a></h4>
    <div class="tweet"><span class="tweet-description">Version 3.4 is out.</span></div>
  </article>
</aside>""");
      expect(_renderedText(tester), contains('Version 3.4 is out.'));
      final avatar = tester.getSize(find.byWidgetPredicate((w) =>
          w is Image && w.image.toString().contains('a_400x400')));
      expect(avatar.width, lessThanOrEqualTo(48));
    });

    testWidgets('a tweet link the forum did not embed gets the tweet card', (tester) async {
      await _render(tester,
          '<p><a href="https://x.com/discourse/status/1234567890" class="onebox" target="_blank">https://x.com/discourse/status/1234567890</a></p>');
      expect(find.byType(TwitterCard), findsOneWidget);
    });

    testWidgets('embeds render in the dark theme', (tester) async {
      await _render(tester, """
<div class="youtube-onebox lazy-video-container" data-video-id="aqz-KE-bpKQ" data-video-title="Dark" data-provider-name="youtube"><a href="https://www.youtube.com/watch?v=aqz-KE-bpKQ"><img class="youtube-thumbnail" src="https://forum.example.com/t.jpg"></a></div>
<iframe src="https://w.soundcloud.com/player/?url=https%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F1" width="100%" height="166"></iframe>
<p><audio controls><source src="https://forum.example.com/a.mp3"></audio></p>""", theme: AppTheme.darkTheme);
      expect(find.byType(EmbedPreviewCard), findsNWidgets(2));
      expect(find.byType(PostAudioPlayer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
