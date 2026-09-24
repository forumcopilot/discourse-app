import 'dart:async';

import 'package:discourse_core/discourse_core.dart' show DiscourseApiException;
import 'package:discourse_ui/controllers/post_controller.dart' show ThreadLoadException;
import 'package:discourse_ui/core/errors/error_handler.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/utils/cooked_content.dart';
import 'package:discourse_ui/utils/error_message.dart';
import 'package:discourse_ui/utils/html_colors.dart';
import 'package:discourse_ui/views/widgets/code_block.dart';
import 'package:discourse_ui/views/widgets/post_body_extensions.dart';
import 'package:discourse_ui/views/widgets/post_content_callbacks.dart';
import 'package:discourse_ui/views/widgets/rich_text_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/a11y-dark.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:get/get.dart';

/// Batch 6 of the thread-rendering audit: how a post reads. The HTML is the
/// shape Discourse cooks, written out by hand.
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
final _mentions = <String>[];
final _images = <String>[];

Future<void> _render(WidgetTester tester, String html, {ThemeData? theme}) async {
  _mentions.clear();
  _images.clear();
  await tester.pumpWidget(MaterialApp(
    theme: theme ?? AppTheme.lightTheme,
    home: Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          key: _bodyKey,
          width: 361,
          child: RichTextContent(
            siteContext: _ctx,
            content: CookedContent.parse(html, forumBaseUrl: _forum).html,
            callbacks: PostContentCallbacks(
              onMentionTap: _mentions.add,
              onImageTap: (url, _, __) => _images.add(url),
            ),
          ),
        ),
      ),
    ),
  ));
  await tester.pump();
}

TextStyle? _styleOf(WidgetTester tester, String text) {
  TextStyle? found;
  void visit(InlineSpan span, TextStyle? inherited) {
    final style = inherited?.merge(span.style) ?? span.style;
    if (span is TextSpan) {
      if ((span.text ?? '').contains(text)) found ??= style;
      for (final c in span.children ?? const <InlineSpan>[]) {
        visit(c, style);
      }
    }
  }

  for (final p in tester.renderObjectList<RenderParagraph>(find.descendant(
      of: find.byKey(_bodyKey), matching: find.byType(RichText)))) {
    visit(p.text, null);
  }
  return found;
}

void main() {
  testWidgets('post text is 16 with 1.5 line spacing; links are colour, not underline',
      (tester) async {
    await _render(tester, '<p>Read <a href="https://example.org">the docs</a> first.</p>');
    final text = _styleOf(tester, 'Read');
    expect(text?.fontSize, 16);
    expect(text?.height, 1.5);
    final link = _styleOf(tester, 'the docs');
    expect(link?.decoration, anyOf(isNull, TextDecoration.none));
    expect(link?.color, AppTheme.lightTheme.colorScheme.primary);
  });

  testWidgets('a mention is a pill; tapping opens the profile', (tester) async {
    await _render(tester, '<p>Thanks <a class="mention" href="/u/sam">@sam</a>!</p>');
    final pill = find.ancestor(of: find.text('@sam'), matching: find.byType(Container));
    final box = tester.widget<Container>(pill.first).decoration as BoxDecoration;
    expect(box.borderRadius, isNotNull);
    expect(box.color, AppTheme.lightTheme.colorScheme.surfaceContainerHighest);
    await tester.tap(find.text('@sam'));
    expect(_mentions, ['sam']);
  });

  testWidgets('a post of nothing but emoji shows it large', (tester) async {
    await _render(tester,
        '<p><img src="/images/emoji/twitter/tada.png" title=":tada:" class="emoji only-emoji" alt=":tada:" width="20" height="20"></p>');
    final emoji = tester.widget<Text>(find.text('🎉'));
    expect(emoji.style?.fontSize, 28);
  });

  testWidgets('<details> is ▶ summary, contents on tap; `open` starts open', (tester) async {
    await _render(tester, '<details><summary>Spoiler-free notes</summary><p>Hidden body</p></details>');
    expect(find.byType(DetailsBlock), findsOneWidget);
    expect(find.text('▶'), findsOneWidget);
    expect(find.textContaining('Hidden body', findRichText: true), findsNothing);
    await tester.tap(find.textContaining('Spoiler-free notes', findRichText: true));
    await tester.pump();
    expect(find.text('▼'), findsOneWidget);
    expect(find.textContaining('Hidden body', findRichText: true), findsOneWidget);

    await _render(tester, '<details open=""><summary>Open one</summary><p>Visible body</p></details>');
    expect(find.textContaining('Visible body', findRichText: true), findsOneWidget);
  });

  testWidgets('an image grid is two columns; a tile opens the full-size image', (tester) async {
    String tile(int i) =>
        '<div class="lightbox-wrapper"><a class="lightbox" href="/uploads/full$i.jpg">'
        '<img src="/uploads/small$i.jpg" width="690" height="460"></a></div>';
    await _render(tester, '<div class="d-image-grid">${tile(1)}${tile(2)}${tile(3)}</div>');
    expect(find.byType(ImageGrid), findsOneWidget);
    Rect r(int i) => tester.getRect(find.byWidgetPredicate((w) =>
        w is Image && w.image is NetworkImage && (w.image as NetworkImage).url.endsWith('small$i.jpg')));
    expect(r(2).left, greaterThan(r(1).right), reason: 'second picture in the second column');
    expect(r(3).top, greaterThan(r(1).bottom), reason: 'third under the first');
    await tester.tap(find.byWidgetPredicate((w) =>
        w is Image && w.image is NetworkImage && (w.image as NetworkImage).url.endsWith('small2.jpg')));
    expect(_images, ['$_forum/uploads/full2.jpg']);
  });

  testWidgets('code is coloured by its language and can be copied', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String?;
      return null;
    });
    await _render(tester,
        '<pre><code class="lang-python">def greet(name):\n    return f"hi {name}"\n</code></pre>');
    expect(find.byType(CodeBlock), findsOneWidget);
    final keyword = _styleOf(tester, 'def');
    final plain = _styleOf(tester, 'greet');
    expect(keyword?.color, isNot(plain?.color), reason: 'the keyword is coloured');

    await tester.tap(find.byIcon(Icons.copy_rounded));
    await tester.pump();
    expect(copied, 'def greet(name):\n    return f"hi {name}"');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });

  test('every code colour reads at 4.5:1 on the block, in both themes', () {
    for (final (palette, scheme) in [
      (a11yLightTheme, AppTheme.lightTheme.colorScheme),
      (a11yDarkTheme, AppTheme.darkTheme.colorScheme),
    ]) {
      final bg = scheme.surfaceContainerHighest;
      final theme = CodeBlock.readableTheme(palette, bg);
      for (final e in theme.entries) {
        final c = e.value.color;
        if (c == null) continue;
        expect(contrastRatio(c, bg), greaterThanOrEqualTo(4.5), reason: '${e.key} on $bg');
      }
    }
  });

  test('plain text and unknown languages are left plain', () {
    expect(CodeBlock.highlightSpans('x = 1', 'plaintext', const {}), hasLength(1));
    expect(CodeBlock.highlightSpans('x = 1', 'not-a-language', const {}), hasLength(1));
    expect(CodeBlock.highlightSpans('x = 1', null, const {}), hasLength(1));
  });

  testWidgets('a followed link shows its click count', (tester) async {
    final html = CookedContent.withLinkClicks(
      '<p>See <a href="https://example.org/guide/">the guide</a> and <a class="mention" href="/u/sam">@sam</a>.</p>',
      {'https://example.org/guide': 1234, '/u/sam': 5},
      forumBaseUrl: _forum,
    );
    expect(html, contains('<span class="link-clicks">1.2k</span>'));
    expect('span class="link-clicks"'.allMatches(html), hasLength(1), reason: 'none on mentions');
    await _render(tester, html);
    expect(find.text('1.2k'), findsOneWidget);
  });

  test('click counts in the web\'s short form', () {
    expect(CookedContent.formatClickCount(253), '253');
    expect(CookedContent.formatClickCount(1000), '1k');
    expect(CookedContent.formatClickCount(1234), '1.2k');
    expect(CookedContent.formatClickCount(12345), '12k');
    expect(CookedContent.formatClickCount(1234567), '1.2M');
  });

  testWidgets('errors say what happened, in the reader\'s language', (tester) async {
    late String paywall, firewall, down, forums;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(builder: (context) {
        paywall = describeError(
            const DiscourseApiException(statusCode: 402, method: 'GET', path: '/t/1.json', body: 'Payment Required'),
            context: context);
        firewall = describeError(
            const DiscourseApiException(
                statusCode: 403, method: 'GET', path: '/latest.json', body: '<html><title>Just a moment...</title></html>'),
            context: context);
        // A failed load's result text, as the thread page receives it.
        down = describeError(Exception("The forum isn't responding right now. Please try again later."),
            context: context);
        forums = describeError(Exception('Title seems unclear'), context: context);
        return const SizedBox();
      }),
    ));
    await tester.pumpAndSettle();
    expect(paywall, 'Dies ist nur für zahlende Mitglieder des Forums verfügbar.');
    expect(firewall, contains('Firewall'));
    expect(down, 'Das Forum antwortet gerade nicht. Bitte versuchen Sie es später erneut.');
    expect(forums, 'Title seems unclear', reason: "the forum's own words stay");
  });

  testWidgets('the new pieces follow the dark theme', (tester) async {
    await _render(
      tester,
      '<p><a class="mention" href="/u/sam">@sam</a></p><details><summary>More</summary><p>x</p></details>'
      '<pre><code class="lang-js">const a = 1;</code></pre>',
      theme: AppTheme.darkTheme,
    );
    final pill = find.ancestor(of: find.text('@sam'), matching: find.byType(Container));
    final box = tester.widget<Container>(pill.first).decoration as BoxDecoration;
    expect(box.color, AppTheme.darkTheme.colorScheme.surfaceContainerHighest);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the error dialog for a paywalled topic says so, not "an unexpected error"',
      (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: SizedBox()),
    ));
    await tester.pumpAndSettle();
    // What the thread page throws when /t/{id}.json answers 402.
    unawaited(ErrorHandler.handleError(
      const ThreadLoadException("This is only for the forum's paying members."),
      null,
    ));
    await tester.pumpAndSettle();
    expect(find.text('Dies ist nur für zahlende Mitglieder des Forums verfügbar.'), findsOneWidget);
    expect(find.textContaining('unexpected'), findsNothing);
    expect(find.text('Fehler'), findsOneWidget, reason: 'the title is localized too');
    Get.back();
    await tester.pumpAndSettle();
  });
}
