import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/utils/cooked_content.dart';
import 'package:discourse_ui/views/widgets/onebox_card.dart';
import 'package:discourse_ui/views/widgets/post_content_callbacks.dart';
import 'package:discourse_ui/views/widgets/rich_text_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Link previews (`aside.onebox`), drawn as the web's card. The HTML is the
/// shape Discourse's onebox templates cook, written out by hand.
const _forum = 'https://forum.example.com';

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
final _opened = <String>[];

Future<void> _render(WidgetTester tester, String cooked, {ThemeData? theme}) async {
  _opened.clear();
  final html = CookedContent.parse(cooked, forumBaseUrl: _forum).html;
  await tester.pumpWidget(MaterialApp(
    theme: theme ?? AppTheme.lightTheme,
    home: Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          key: _bodyKey,
          width: 361,
          child: RichTextContent(
            siteContext: _ctx,
            content: html,
            callbacks: PostContentCallbacks(onUrlTap: _opened.add),
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

Size _imageSize(WidgetTester tester, String urlPart) => tester.getSize(find.byWidgetPredicate(
    (w) => w is Image && w.image is NetworkImage && (w.image as NetworkImage).url.contains(urlPart)));

const _generic = '''
<aside class="onebox allowlistedgeneric" data-onebox-src="https://docs.example.org/guide/">
  <header class="source">
    <img src="https://docs.example.org/favicon.png" class="site-icon" width="180" height="180">
    <a href="https://docs.example.org/guide/" target="_blank">Example Docs</a>
  </header>
  <article class="onebox-body">
    <div class="aspect-image" style="--aspect-ratio:690/345;"><img src="https://docs.example.org/social.png" class="thumbnail" width="690" height="345"></div>
    <h3><a href="https://docs.example.org/guide/" target="_blank">The complete guide</a></h3>
    <p>Everything about the thing, in one place.</p>
    <p><strong></strong></p>
  </article>
  <div class="onebox-metadata"></div>
  <div style="clear: both"></div>
</aside>''';

void main() {
  testWidgets('a link preview is a card: small site icon, title, excerpt, small thumbnail',
      (tester) async {
    await _render(tester, _generic);
    expect(find.byType(OneboxCard), findsOneWidget);
    final text = _renderedText(tester);
    expect(text, contains('Example Docs'));
    expect(text, contains('The complete guide'));
    expect(text, contains('Everything about the thing'));

    // The favicon stays a favicon; the thumbnail stays beside the text.
    expect(_imageSize(tester, 'favicon.png').width, lessThanOrEqualTo(16));
    final thumb = _imageSize(tester, 'social.png');
    expect(thumb.width, lessThanOrEqualTo(110));
    final titleRect = tester.getRect(find.text('The complete guide'));
    final thumbRect = tester.getRect(find.byWidgetPredicate((w) =>
        w is Image && w.image is NetworkImage && (w.image as NetworkImage).url.contains('social.png')));
    expect(titleRect.left, greaterThan(thumbRect.right), reason: 'title beside the thumbnail');

    // The title is the link colour, not an underlined link.
    final title = tester.widget<Text>(find.text('The complete guide'));
    expect(title.style?.color, AppTheme.lightTheme.colorScheme.primary);

    await tester.tap(find.text('The complete guide'));
    expect(_opened, ['https://docs.example.org/guide/']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a thumbnail that no longer loads leaves no empty box', (tester) async {
    await _render(tester, _generic);
    // The test HTTP client fails every image request, like a dead image URL.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.pump();
    final card = tester.getRect(find.byType(OneboxCard));
    final title = tester.getRect(find.text('The complete guide'));
    expect(title.left - card.left, lessThan(40), reason: 'the text takes the whole width');
  });

  testWidgets('a GitHub issue: issue icon, title, when and who in local time, short excerpt',
      (tester) async {
    await _render(tester, '''
<aside class="onebox githubissue" data-onebox-src="https://github.com/org/repo/issues/847">
  <header class="source"><a href="https://github.com/org/repo/issues/847">github.com/org/repo</a></header>
  <article class="onebox-body">
    <div class="github-row">
      <div class="github-icon-container" title="Issue"><svg width="60" height="60"></svg></div>
      <div class="github-info-container">
        <h4><a href="https://github.com/org/repo/issues/847">Add support for version 9</a></h4>
        <div class="github-info">
          <div class="date">opened <span class="discourse-local-date" data-format="ll" data-date="2025-04-15" data-time="14:20:37" data-timezone="UTC">02:20PM - 15 Apr 25 UTC</span></div>
          <div class="user"><a href="https://github.com/someone"><img src="https://forum.example.com/uploads/a.jpeg" class="onebox-avatar-inline" width="20" height="20"> someone</a></div>
        </div>
      </div>
    </div>
    <div class="github-row">
      <p class="github-body-container">The first line.<span class="show-more-container"><a href="" class="show-more">…</a></span><span class="excerpt hidden">The whole rest of the issue body.</span></p>
    </div>
  </article>
</aside>''');
    expect(find.byIcon(Icons.adjust), findsOneWidget);
    final text = _renderedText(tester);
    expect(text, contains('Add support for version 9'));
    expect(text, contains('opened'));
    expect(text, contains('someone'));
    expect(text, isNot(contains('02:20PM - 15 Apr 25 UTC')));
    expect(text, isNot(contains('The whole rest of the issue body.')));
    expect(_imageSize(tester, 'a.jpeg').width, lessThanOrEqualTo(20), reason: 'inline avatar stays inline');
  });

  testWidgets('a GitHub file shows its path and code', (tester) async {
    await _render(tester, '''
<aside class="onebox githubblob" data-onebox-src="https://github.com/org/repo/blob/main/app.yml">
  <header class="source"><a href="https://github.com/org/repo/blob/main/app.yml">github.com/org/repo</a></header>
  <article class="onebox-body">
    <h4><a href="https://github.com/org/repo/blob/main/app.yml">app.yml</a></h4>
    <div class="git-blob-info"><a href="https://github.com/org/repo/blob/main/app.yml"><code>main</code></a></div>
    <pre><code class="lang-yml">name: build
on: push
</code></pre>
    This file has been truncated. <a href="https://github.com/org/repo/blob/main/app.yml">show original</a>
  </article>
</aside>''');
    final text = _renderedText(tester);
    expect(text, contains('app.yml'));
    expect(text, contains('name: build'));
    expect(text, contains('show original'));
  });

  testWidgets('a PDF: a PDF tile, the file name readable, its size', (tester) async {
    await _render(tester, '''
<aside class="onebox pdf" data-onebox-src="https://example.org/Annual%20Report%202025.pdf">
  <header class="source"><a href="https://example.org/Annual%20Report%202025.pdf">example.org</a></header>
  <article class="onebox-body">
    <a href="https://example.org/Annual%20Report%202025.pdf"><span class="pdf-onebox-logo"></span></a>
    <h3><a href="https://example.org/Annual%20Report%202025.pdf">Annual%20Report%202025.pdf</a></h3>
    <p class="filesize">815.76 KB</p>
  </article>
</aside>''');
    expect(find.text('PDF'), findsOneWidget);
    expect(find.text('Annual Report 2025.pdf'), findsOneWidget);
    expect(_renderedText(tester), contains('815.76 KB'));
  });

  testWidgets('a tweet: avatar, name and handle, text, date with counts', (tester) async {
    await _render(tester, '''
<aside class="onebox twitterstatus" data-onebox-src="https://x.com/discourse/status/1">
  <header class="source"><a href="https://x.com/discourse/status/1">x.com</a></header>
  <article class="onebox-body">
    <img src="https://pbs.twimg.com/profile_images/1/a_400x400.jpg" class="thumbnail onebox-avatar" width="400" height="400">
    <h4><a href="https://x.com/discourse/status/1">Discourse</a></h4>
    <div class="twitter-screen-name"><a href="https://x.com/discourse/status/1">@discourse</a></div>
    <div class="tweet"><span class="tweet-description">Version 3.4 is out.</span></div>
    <div class="date">
      <a href="https://x.com/discourse/status/1" class="timestamp">9:52 PM - 15 Aug 2024</a>
      <span class="like"><svg viewBox="0 0 512 512"><path d="M0"></path></svg> 47K</span>
      <span class="retweet"><svg viewBox="0 0 640 512"><path d="M0"></path></svg> 17K</span>
    </div>
  </article>
</aside>''');
    final text = _renderedText(tester);
    expect(text, contains('Discourse'));
    expect(text, contains('@discourse'));
    expect(text, contains('Version 3.4 is out.'));
    expect(text, contains('9:52 PM - 15 Aug 2024'));
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.text('47K'), findsOneWidget);
    expect(_imageSize(tester, 'a_400x400').width, 40);
  });

  testWidgets('cards follow the dark theme', (tester) async {
    await _render(tester, _generic, theme: AppTheme.darkTheme);
    final title = tester.widget<Text>(find.text('The complete guide'));
    expect(title.style?.color, AppTheme.darkTheme.colorScheme.primary);
    expect(tester.takeException(), isNull);
  });
}
