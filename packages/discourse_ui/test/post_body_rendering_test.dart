import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/utils/cooked_content.dart';
import 'package:discourse_ui/utils/html_colors.dart';
import 'package:discourse_ui/utils/initials.dart';
import 'package:discourse_ui/views/widgets/forum_icon_widget.dart';
import 'package:discourse_ui/views/widgets/rich_text_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:discourse_ui/views/widgets/brand_image.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// How post bodies render, one test per defect the 2026-09-23 thread
/// rendering audit found on real forums (921 forums, 292k posts, app vs
/// web). The HTML is the shape Discourse cooks for each construct, written
/// out by hand rather than copied from anyone's post.
const _forum = 'https://forum.example.com';

/// The thread page's body width on a 393dp-wide phone (16dp padding a side).
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

/// Renders [cooked] the way PostListItem does: through CookedContent, then
/// RichTextContent, at the thread's column width.
Future<void> _render(WidgetTester tester, String cooked, {ThemeData? theme}) async {
  final html = CookedContent.parse(cooked, forumBaseUrl: _forum).html;
  await tester.pumpWidget(MaterialApp(
    theme: theme ?? AppTheme.lightTheme,
    home: Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            key: _bodyKey,
            width: _column,
            child: RichTextContent(siteContext: _ctx, content: html),
          ),
        ),
      ),
    ),
  ));
  await tester.pump();
}

/// Everything the post painted as text, in paint order.
String _renderedText(WidgetTester tester) {
  final sb = StringBuffer();
  void walk(RenderObject r) {
    if (r is RenderParagraph) sb.write('${r.text.toPlainText()} ');
    r.visitChildren(walk);
  }

  walk(tester.renderObject(find.byKey(_bodyKey)));
  return sb.toString();
}

/// The colour a run of text was painted with.
Color? _colourOf(WidgetTester tester, String text) {
  Color? found;
  void visitSpan(InlineSpan span, TextStyle? inherited) {
    final style = inherited?.merge(span.style) ?? span.style;
    if (span is TextSpan) {
      if ((span.text ?? '').contains(text)) found ??= style?.color;
      span.children?.forEach((c) => visitSpan(c, style));
    }
  }

  void walk(RenderObject r) {
    if (r is RenderParagraph) visitSpan(r.text, null);
    r.visitChildren(walk);
  }

  walk(tester.renderObject(find.byKey(_bodyKey)));
  return found;
}

double _bodyHeight(WidgetTester tester) => tester.getSize(find.byKey(_bodyKey)).height;

void main() {
  group('images', () {
    testWidgets('an upload wider than the column keeps its proportions', (tester) async {
      // A 1672×941 upload, cooked at 690×388. With both attributes passed
      // to Image.network the width was clamped to 361 but the height stayed
      // 388: a blank band above and below the picture.
      await _render(tester, '''
<div class="lightbox-wrapper"><a class="lightbox" href="/uploads/default/original/1X/a.png">
<img src="/uploads/default/optimized/1X/a_2_690x388.png" width="690" height="388">
<div class="meta"><span class="filename">image</span><span class="informations">1672×941 318 KB</span></div>
</a></div>''');

      final box = tester.getSize(find.byType(AspectRatio));
      expect(box.width, _column);
      expect(box.height, closeTo(_column * 388 / 690, 0.5));
    });

    testWidgets('the lightbox caption web hides is not printed', (tester) async {
      await _render(tester, '''
<p>Before</p>
<div class="lightbox-wrapper"><a class="lightbox" href="/uploads/o.png">
<img src="/uploads/r.png" width="690" height="388">
<div class="meta"><span class="filename">image</span><span class="informations">1672×941 318 KB</span></div>
</a></div>''');

      expect(_renderedText(tester), isNot(contains('1672×941')));
      expect(_renderedText(tester), contains('Before'));
    });

    testWidgets('an SVG goes to the SVG renderer, not Image.network', (tester) async {
      await _render(tester,
          '<p><img src="https://cdn.example.com/original/2X/f/diagram.svg" width="690" height="345"></p>');

      expect(find.byType(BrandImage), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      // ...and keeps its proportions like any other upload.
      expect(tester.getSize(find.byType(AspectRatio)).height, closeTo(_column / 2, 0.5));
    });
  });

  testWidgets('<hr> is a thin divider, not a black box with a tall gap', (tester) async {
    await _render(tester, '<p>One</p><hr><p>Two</p>');

    expect(find.byType(Divider), findsOneWidget);
    // Two lines of text and a rule. Before: well over 300dp.
    expect(_bodyHeight(tester), lessThan(110));
  });

  testWidgets('a quote draws one bar and one background, not two', (tester) async {
    await _render(tester, '''
<aside class="quote no-group" data-username="bob" data-post="3" data-topic="42">
<div class="title"><div class="quote-controls"></div>bob:</div>
<blockquote><p>The status page still says it is operational.</p></blockquote>
</aside>
<p>Reply text.</p>''');

    final bars = find.byWidgetPredicate((w) {
      if (w is! Container || w.decoration is! BoxDecoration) return false;
      final border = (w.decoration as BoxDecoration).border;
      return border is Border && border.left.width == 3;
    });
    expect(bars, findsOneWidget);
  });

  testWidgets('.hidden content stays hidden (GitHub onebox body)', (tester) async {
    await _render(tester, '''
<aside class="onebox githubissue" data-onebox-src="https://github.com/o/r/issues/1">
<article class="onebox-body"><div class="github-row">
<p class="github-body-container">Short excerpt<span class="show-more-container"><a href="" class="show-more">…</a></span><span class="excerpt hidden">THE WHOLE ISSUE BODY</span></p>
</div></article></aside>''');

    final text = _renderedText(tester);
    expect(text, contains('Short excerpt'));
    expect(text, isNot(contains('THE WHOLE ISSUE BODY')));
  });

  testWidgets('checklist items show whether they are checked', (tester) async {
    await _render(tester, '''
<ul>
<li><span class="chcklst-box checked fa fa-square-check-o fa-fw"></span> java</li>
<li><span class="chcklst-box fa fa-square-o fa-fw"></span> kotlin</li>
</ul>''');

    expect(find.byIcon(Icons.check_box), findsOneWidget);
    expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
  });

  group('author colours', () {
    testWidgets('an invalid colour no longer takes the post down', (tester) async {
      // community.robotime.com: `<font color="#PG985740">` threw a
      // FormatException inside flutter_html and replaced the whole post
      // with an error box.
      await _render(tester,
          '<p>We will <font color="#PG985740"><font size="4">select 20 winners</font></font>.</p>');

      expect(tester.takeException(), isNull);
      expect(_renderedText(tester), contains('select 20 winners'));
    });

    testWidgets('named colours flutter_html did not know are drawn', (tester) async {
      await _render(tester, '<p><font color="LimeGreen">green text</font></p>');

      expect(_colourOf(tester, 'green text'), isNotNull);
    });

    testWidgets('black text becomes readable in the dark theme', (tester) async {
      final dark = AppTheme.darkTheme;
      await _render(tester, '<p><font color="black">dark text</font></p>', theme: dark);

      final colour = _colourOf(tester, 'dark text')!;
      expect(contrastRatio(colour, dark.colorScheme.surface), greaterThanOrEqualTo(4.5));
    });

    testWidgets('and stays black in the light theme', (tester) async {
      await _render(tester, '<p><font color="black">dark text</font></p>');

      expect(_colourOf(tester, 'dark text'), const Color(0xFF000000));
    });

    testWidgets('a pale colour darkens on the light theme, keeping its hue', (tester) async {
      final light = AppTheme.lightTheme;
      await _render(tester, '<p><font color="#43C6DB">cyan text</font></p>', theme: light);

      final colour = _colourOf(tester, 'cyan text')!;
      expect(contrastRatio(colour, light.colorScheme.surface), greaterThanOrEqualTo(4.5));
      expect(HSLColor.fromColor(colour).hue,
          closeTo(HSLColor.fromColor(const Color(0xFF43C6DB)).hue, 1));
    });
  });

  testWidgets('if flutter_html still fails, the post shows as plain text', (tester) async {
    // setupErrorHandling() installs this in the app. The binding checks the
    // builder is restored before tear-down runs, hence try/finally.
    final restore = installPostBodyErrorFallback();
    try {
      // Bypass CookedContent's sanitising to make flutter_html throw.
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PostBodyFallback(
              html: '<p>Readable fallback text</p>',
              child: Html(data: '<p><font color="#zz0000">x</font></p>'),
            ),
          ),
        ),
      ));

      expect(tester.takeException(), isA<FormatException>());
      expect(find.text('Readable fallback text'), findsOneWidget);
    } finally {
      restore();
    }
  });

  group('initials', () {
    test('take the first character, not half an emoji', () {
      expect(initialOf('🎓 Docs'), '🎓');
      expect(initialOf('👩‍💻 Dev'), '👩‍💻');
      expect(initialOf('alice'), 'A');
      expect(initialOf('  '), '?');
      expect(initialOf('', fallback: 'F'), 'F');
    });

    testWidgets('a category named with an emoji gets its icon', (tester) async {
      // AnkiHub's categories are "🎓 Docs", "🙋 Support", …: the letter
      // fallback threw "string is not well-formed UTF-16".
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: ForumListItemIconWidget(forumName: '🎓 Docs')),
      ));

      expect(tester.takeException(), isNull);
      expect(find.text('🎓'), findsOneWidget);
    });
  });
}
