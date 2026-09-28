import 'package:discourse_core/discourse_core.dart'
    show
        DiscourseCategoryStyle,
        DiscourseSiteCapabilities,
        DiscourseSiteContextExtension;
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/theme/forum_identity.dart';
import 'package:discourse_ui/utils/discourse_icons.dart';
import 'package:discourse_ui/views/listitems/category_card.dart';
import 'package:discourse_ui/views/tabs/topic_list_tab.dart' show HomeView;
import 'package:discourse_ui/views/widgets/brand_image.dart';
import 'package:discourse_ui/views/widgets/category_tile_mark.dart';
import 'package:discourse_ui/views/widgets/forum_masthead.dart';
import 'package:discourse_ui/views/widgets/site_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// The forum home redesign: the forum's own header, its views taken from
/// its own navigation bar, categories as they are set up on the forum, and
/// the drawer as the forum's map.
const _forum = 'https://py.example.com';

SiteContext _context({String description = ''}) => SiteContext(
      siteType: 'discourse',
      site: Site(
        id: null,
        name: 'Discussions on Python.org',
        url: _forum,
        description: description,
        logoUrl: null,
        backgroundUrl: null,
        endpoint: null,
        baseUrl: _forum,
        siteType: 'discourse',
        language: null,
      ),
    );

Widget _app(Widget child, {Brightness brightness = Brightness.light}) =>
    MaterialApp(
      theme: AppTheme.themeFor(brightness, null),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

void main() {
  setUp(DiscourseSiteCapabilities.reset);

  group('Home views follow the forum\'s own navigation bar', () {
    test('its order, homepage first; New and Unread need a session', () {
      const python = ['categories', 'latest', 'new', 'unread', 'top'];
      expect(
        HomeView.viewsFor(menu: python, signedIn: true, offersHot: true),
        [
          HomeView.categories,
          HomeView.latest,
          HomeView.newTopics,
          HomeView.unread,
          HomeView.top,
        ],
      );
      expect(
        HomeView.viewsFor(menu: python, signedIn: false, offersHot: true),
        [HomeView.categories, HomeView.latest, HomeView.top],
      );
    });

    test(
        'views the app does not draw are skipped; Latest and Categories '
        'are always there', () {
      // Asana: categories|latest|bookmarks|unread|new.
      expect(
        HomeView.viewsFor(
            menu: const ['hot', 'bookmarks', 'unread'],
            signedIn: true,
            offersHot: false),
        [HomeView.latest, HomeView.unread, HomeView.categories],
      );
    });

    test('an unknown menu gets Discourse\'s defaults', () {
      expect(
        HomeView.viewsFor(menu: const [], signedIn: true, offersHot: true),
        [
          HomeView.latest,
          HomeView.hot,
          HomeView.newTopics,
          HomeView.unread,
          HomeView.top,
          HomeView.categories,
        ],
      );
    });
  });

  group('the forum\'s header', () {
    void storeForum({String? lightHeader, bool darkLogo = false}) {
      DiscourseSiteCapabilities.store(_forum, {
        'top_menu_items': ['latest'],
        if (lightHeader != null)
          'default_light_color_scheme': {
            'colors': [
              {'name': 'header_background', 'hex': lightHeader},
              {'name': 'header_primary', 'hex': 'ffffff'},
            ],
          },
      });
      DiscourseSiteCapabilities.storeLogos(
        _forum,
        logoUrl: '$_forum/logo.png',
        logoDarkUrl: darkLogo ? '$_forum/logo-dark.png' : null,
        smallLogoUrl: '$_forum/icon.png',
      );
    }

    Future<ForumIdentity> identity(WidgetTester tester, Brightness b) async {
      late ForumIdentity out;
      await tester.pumpWidget(_app(
        Builder(builder: (context) {
          out = ForumIdentity.of(context, _context().site);
          return const SizedBox();
        }),
        brightness: b,
      ));
      return out;
    }

    testWidgets('light mode: the wordmark on the header it was drawn for',
        (tester) async {
      storeForum();
      final id = await identity(tester, Brightness.light);
      expect(id.wordmark, '$_forum/logo.png');
      expect(id.icon, '$_forum/icon.png');
    });

    testWidgets(
        'dark mode with no dark logo: the icon and name, no plated '
        'wordmark', (tester) async {
      storeForum();
      final id = await identity(tester, Brightness.dark);
      expect(id.wordmark, isNull);
    });

    testWidgets('dark mode with a dark logo uses it', (tester) async {
      storeForum(darkLogo: true);
      final id = await identity(tester, Brightness.dark);
      expect(id.wordmark, '$_forum/logo-dark.png');
    });

    testWidgets(
        'a forum whose own header is dark keeps its wordmark in dark '
        'mode', (tester) async {
      storeForum(lightHeader: '333333');
      final id = await identity(tester, Brightness.dark);
      expect(id.wordmark, '$_forum/logo.png');
    });

    testWidgets(
        'open, it offers search named after the forum and its '
        'stats; collapsed, a search button', (tester) async {
      await tester.pumpWidget(_app(Scaffold(
        drawer: const Drawer(),
        body: CustomScrollView(slivers: [
          ForumMasthead(
            siteContext: _context(description: 'All about Python.'),
            onSearch: () {},
            boardStats: FCBoardStatResult(
              result: true,
              resultText: '',
              totalMembers: 56836,
              activeMembers: 1869,
              totalThreads: 18477,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => SizedBox(height: 80, child: Text('row $i')),
              childCount: 40,
            ),
          ),
        ]),
      )));
      await tester.pump();
      expect(find.text('Search Discussions on Python.org'), findsOneWidget);
      expect(find.text('All about Python.'), findsOneWidget);
      expect(find.textContaining('1.87K active this month'), findsOneWidget);
      expect(find.textContaining('56.8K members'), findsOneWidget);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();
      final button = find.widgetWithIcon(IconButton, Icons.search);
      expect(button, findsOneWidget);
      final opacity = tester.widget<AnimatedOpacity>(find
          .ancestor(of: button, matching: find.byType(AnimatedOpacity))
          .first);
      expect(opacity.opacity, 1);
    });
  });

  group('category marks are what the forum set', () {
    Future<void> pump(WidgetTester tester, DiscourseCategoryStyle style) =>
        tester.pumpWidget(_app(Scaffold(
          body: Center(child: CategoryTileMark(style: style, size: 40)),
        )));

    testWidgets('an uploaded logo', (tester) async {
      await pump(
          tester,
          const DiscourseCategoryStyle(
              id: 1, name: 'Ideas', logoUrl: '$_forum/thumb.png'));
      expect(find.byType(BrandImage), findsOneWidget);
      expect(tester.getSize(find.byType(CategoryTileMark)), const Size(40, 40));
    });

    testWidgets('an icon', (tester) async {
      await pump(
          tester,
          const DiscourseCategoryStyle(
              id: 2,
              name: 'Bug',
              colorHex: 'd1c000',
              styleType: 'icon',
              icon: 'bug'));
      expect(find.byIcon(Icons.bug_report_outlined), findsOneWidget);
    });

    testWidgets('an emoji', (tester) async {
      await pump(
          tester,
          const DiscourseCategoryStyle(
              id: 3,
              name: 'General',
              colorHex: '25AAE2',
              styleType: 'emoji',
              emoji: 'blue_book'));
      expect(find.text('📘'), findsOneWidget);
    });

    testWidgets('a colour, as a plain square with no letter', (tester) async {
      await pump(
          tester,
          const DiscourseCategoryStyle(
              id: 4, name: 'Python Help', colorHex: 'FAC731'));
      expect(find.byType(Text), findsNothing);
      expect(find.byType(Icon), findsNothing);
    });

    test('Discourse\'s icon names map to Material icons', () {
      expect(
          materialIconForDiscourseIcon('circle-question'), Icons.help_outline);
      expect(materialIconForDiscourseIcon('far-circle-question'),
          Icons.help_outline);
      expect(materialIconForDiscourseIcon('square-full'), isNull);
      expect(materialIconForDiscourseIcon('no-such-icon'), isNull);
    });
  });

  testWidgets(
      'a boxes group keeps its own cards; the next top-level '
      'category stands outside it', (tester) async {
    DiscourseSiteCapabilities.store(_forum, {
      'top_menu_items': ['latest'],
      'categories': [
        {
          'id': 12,
          'name': 'Packaging',
          'color': '3572A5',
          'subcategory_list_style': 'boxes'
        },
        {'id': 40, 'name': 'Standards', 'parent_category_id': 12},
        {'id': 17, 'name': 'Typing'},
      ],
    });
    final ctx = _context();
    final packaging = FCForum(id: '12', name: 'Packaging', childForums: [
      FCForum(id: '40', name: 'Standards', parentId: '12'),
    ]);
    await tester.pumpWidget(_app(Scaffold(
      body: ListView(children: [
        CategoryGroup(siteContext: ctx, forum: packaging),
        CategoryCard(
            siteContext: ctx, forum: FCForum(id: '17', name: 'Typing')),
      ]),
    )));
    final group = find.byType(CategoryGroup);
    expect(find.descendant(of: group, matching: find.text('Packaging')),
        findsOneWidget);
    expect(find.descendant(of: group, matching: find.text('Standards')),
        findsOneWidget);
    expect(find.descendant(of: group, matching: find.text('Typing')),
        findsNothing);
    // Indented under the heading, so Typing's full-width card reads apart.
    expect(
        tester
            .getTopLeft(find
                .ancestor(
                    of: find.text('Standards'), matching: find.byType(Material))
                .first)
            .dx,
        greaterThan(tester
            .getTopLeft(find
                .ancestor(
                    of: find.text('Typing'), matching: find.byType(Material))
                .first)
            .dx));
  });

  group('the drawer lists the reader\'s own categories and tags', () {
    void storeCategories() {
      DiscourseSiteCapabilities.store(_forum, {
        'top_menu_items': ['latest'],
        'uncategorized_category_id': 1,
        'navigation_menu_site_top_tags': [
          {'name': 'help'},
          {'name': 'typing'},
        ],
        'categories': [
          {'id': 1, 'name': 'Uncategorized', 'position': 0},
          {'id': 7, 'name': 'Python Help', 'position': 2},
          {'id': 6, 'name': 'Ideas', 'position': 1},
          {'id': 70, 'name': 'Sub', 'parent_category_id': 7, 'position': 3},
        ],
      });
    }

    test('without a sidebar: the top-level categories in the forum\'s order',
        () {
      storeCategories();
      final ctx = _context();
      expect(SiteDrawer.categoryIdsFor(ctx), [6, 7]);
      expect(SiteDrawer.tagsFor(ctx), ['help', 'typing']);
    });

    test('the forum\'s defaults for new members come next', () {
      storeCategories();
      DiscourseSiteCapabilities.storeClientSettings(_forum, {
        'default_navigation_menu_categories': '7|70|99',
        'default_navigation_menu_tags': 'release',
      });
      final ctx = _context();
      expect(SiteDrawer.categoryIdsFor(ctx), [7, 70]);
      expect(SiteDrawer.tagsFor(ctx), ['release']);
    });

    test('the reader\'s own sidebar wins', () {
      storeCategories();
      final ctx = _context()..setSidebar(categoryIds: [70, 1], tags: ['mine']);
      addTearDown(() => ctx.setSidebar());
      expect(SiteDrawer.categoryIdsFor(ctx), [70]);
      expect(SiteDrawer.tagsFor(ctx), ['mine']);
    });
  });
}
