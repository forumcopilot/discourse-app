import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities;
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/theme/forum_brand_style.dart';
import 'package:discourse_ui/utils/cooked_content.dart';
import 'package:discourse_ui/utils/html_colors.dart';
import 'package:discourse_ui/views/widgets/category_badge.dart';
import 'package:discourse_ui/views/widgets/rich_text_content.dart';
import 'package:discourse_ui/views/widgets/topic_taxonomy_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// A category looks the same wherever it is named: a mark in its own
/// colour (split with its parent's for a subcategory, or its emoji) and its
/// name — on topic rows, the topic page, search, pickers and hashtags. The
/// app used to draw most of these in its own blue, and named some
/// categories with no colour at all.
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

void main() {
  setUp(() {
    DiscourseSiteCapabilities.reset();
    DiscourseSiteCapabilities.store(_forum, {
      'top_menu_items': ['latest'],
      'uncategorized_category_id': 1,
      'categories': [
        {'id': 1, 'name': 'Uncategorized', 'color': '0088CC', 'text_color': 'FFFFFF'},
        {'id': 5, 'name': 'Tech', 'color': '0E76A8', 'text_color': 'FFFFFF', 'style_type': 'square'},
        {'id': 6, 'name': 'Arduino', 'color': 'E45735', 'parent_category_id': 5},
        {'id': 4, 'name': 'General', 'color': '25AAE2', 'style_type': 'emoji', 'emoji': 'blue_book'},
        {'id': 9, 'name': 'Night', 'color': '111111'},
        {
          'id': 18,
          'name': 'Product Announcements',
          'color': 'FCBD01',
          'uploaded_logo': {'url': '//cdn.example/rocket.png'},
          'uploaded_logo_dark': {'url': '/uploads/rocket-dark.png'},
          'uploaded_background': {'url': '//cdn.example/bg.jpg'},
        },
      ],
    });
  });

  Future<void> pump(WidgetTester tester, Widget child, {ThemeData? theme}) =>
      tester.pumpWidget(MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        home: Scaffold(body: Center(child: child)),
      ));

  BoxDecoration markOf(WidgetTester tester) => tester
      .widget<Container>(find.descendant(
          of: find.byType(CategoryMark), matching: find.byType(Container)))
      .decoration! as BoxDecoration;

  testWidgets('the badge is the category colour and name from /site.json',
      (tester) async {
    // The topic row knows only the id; the name comes from the forum.
    await pump(tester, CategoryBadge(siteContext: _ctx, categoryId: '5'));
    expect(find.text('Tech'), findsOneWidget);
    expect(markOf(tester).color, const Color(0xFF0E76A8));
  });

  testWidgets("a subcategory's mark is half its parent's colour",
      (tester) async {
    await pump(tester, CategoryBadge(siteContext: _ctx, categoryId: '6'));
    final gradient = markOf(tester).gradient! as LinearGradient;
    expect(gradient.colors.first, const Color(0xFF0E76A8));
    expect(gradient.colors.last, const Color(0xFFE45735));
  });

  testWidgets('an emoji-styled category shows its emoji', (tester) async {
    await pump(tester, CategoryBadge(siteContext: _ctx, categoryId: '4'));
    expect(find.text('📘'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
  });

  testWidgets('Uncategorized wears no badge, as on the web', (tester) async {
    await pump(tester, CategoryBadge(siteContext: _ctx, categoryId: '1'));
    expect(find.text('Uncategorized'), findsNothing);
  });

  testWidgets('before the categories are known, the name still shows',
      (tester) async {
    await pump(tester,
        CategoryBadge(siteContext: _ctx, categoryId: '77', fallbackName: 'Later'));
    expect(find.text('Later'), findsOneWidget);
  });

  testWidgets('a near-black category still shows on a dark page',
      (tester) async {
    await pump(tester, CategoryBadge(siteContext: _ctx, categoryId: '9'),
        theme: AppTheme.darkTheme);
    final surface = AppTheme.darkTheme.colorScheme.surface;
    expect(contrastRatio(markOf(tester).color!, surface),
        greaterThanOrEqualTo(1.8));
  });

  test('a category opened from a badge or link keeps its colours', () {
    final forum = categoryForum(_ctx, '6');
    expect(forum.name, 'Arduino');
    expect(forum.color, 'E45735');
    expect(forum.parentId, '5');
  });

  test('a category header is the forum card in the category colour', () {
    final light = ForumBrandStyle.forColor(const Color(0xFF25AAE2),
        preferredText: Colors.white, brightness: Brightness.light);
    // Its own hue; the lightness may move a step so the text reads (white
    // on this blue is 2.6:1, so the text turns black).
    expect(HSLColor.fromColor(light.base).hue,
        closeTo(HSLColor.fromColor(const Color(0xFF25AAE2)).hue, 1));
    final dark = ForumBrandStyle.forColor(const Color(0xFF25AAE2),
        preferredText: Colors.white, brightness: Brightness.dark);
    expect(dark.isDark, isTrue, reason: 'deepened on a dark screen');
    for (final s in [light, dark]) {
      for (final c in s.colors) {
        expect(contrastRatio(s.foreground, c), greaterThanOrEqualTo(4.5));
      }
    }
  });

  group('TopicTaxonomyChips', () {
    testWidgets('one row for list and page: badge, tags, then "+N"',
        (tester) async {
      await pump(
          tester,
          TopicTaxonomyChips(
            siteContext: _ctx,
            categoryId: '5',
            tags: const ['a', 'b', 'c'],
            maxTags: 2,
          ));
      expect(find.byType(CategoryBadge), findsOneWidget);
      expect(find.byType(TagChip), findsNWidgets(2));
      expect(find.text('+1'), findsOneWidget);
    });

    testWidgets('an uncategorized topic with no tags draws nothing at all',
        (tester) async {
      await pump(
          tester,
          TopicTaxonomyChips(
            siteContext: _ctx,
            categoryId: '1',
            padding: const EdgeInsets.all(24),
          ));
      expect(find.byType(Padding), findsNothing,
          reason: 'no empty padded row under the title');
    });
  });

  testWidgets("a category hashtag in a post carries the category's mark",
      (tester) async {
    const cooked = '<p>See <a class="hashtag-cooked" href="/c/tech/5" '
        'data-type="category" data-slug="tech" data-id="5">'
        '<span class="hashtag-icon-placeholder"></span><span>Tech</span></a></p>';
    final html = CookedContent.parse(cooked, forumBaseUrl: _forum).html;
    await pump(
        tester,
        SizedBox(
          width: 360,
          child: RichTextContent(siteContext: _ctx, content: html),
        ));
    await tester.pump();
    expect(find.byType(CategoryMark), findsOneWidget);
    expect(markOf(tester).color, const Color(0xFF0E76A8));
  });

  // The category page picks its uploads for the page's mode; the list
  // payload's FCForum carries only the light logo.
  test("a category's logo and background follow light and dark", () {
    final forum = FCForum(id: '18', name: 'Product Announcements');
    expect(categoryLogoUrl(_ctx, forum, dark: false), 'https://cdn.example/rocket.png');
    expect(categoryLogoUrl(_ctx, forum, dark: true),
        '$_forum/uploads/rocket-dark.png');
    // No dark background uploaded: the one background serves both.
    expect(categoryBackgroundUrl(_ctx, forum, dark: true), 'https://cdn.example/bg.jpg');
    // A category /site.json does not know keeps what the list gave it.
    final other = FCForum(id: '404', name: 'X', logoUrl: 'https://l.example/x.png');
    expect(categoryLogoUrl(_ctx, other, dark: true), 'https://l.example/x.png');
  });

  test("floating buttons are the forum's accent", () {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      expect(theme.floatingActionButtonTheme.backgroundColor,
          theme.colorScheme.primary);
      expect(theme.floatingActionButtonTheme.foregroundColor,
          theme.colorScheme.onPrimary);
    }
  });
}

