import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// What the app's forum navigation is built from: the forum's own menu and
/// default sidebar (`/site/settings.json`), its top tags and category
/// details (`/site.json`), and each category's week (`/categories.json`).
void main() {
  setUp(DiscourseSiteCapabilities.reset);

  test('top menu and default sidebar come from the client settings', () {
    DiscourseSiteCapabilities.storeClientSettings('https://py.example', {
      'top_menu': 'categories|Latest|new| unread |top',
      'default_navigation_menu_categories': '6|18|x',
      'default_navigation_menu_tags': 'official|release-notes',
    });
    final caps = DiscourseSiteCapabilities.forSite('https://py.example');
    expect(caps.topMenu, ['categories', 'latest', 'new', 'unread', 'top']);
    expect(caps.defaultSidebarCategoryIds, [6, 18]);
    expect(caps.defaultSidebarTags, ['official', 'release-notes']);
  });

  test('missing settings leave the menu empty rather than guessing', () {
    DiscourseSiteCapabilities.storeClientSettings('https://old.example', {});
    final caps = DiscourseSiteCapabilities.forSite('https://old.example');
    expect(caps.topMenu, isEmpty);
    expect(caps.defaultSidebarCategoryIds, isEmpty);
  });

  test('top tags, and a category\'s description, counts and layout', () {
    DiscourseSiteCapabilities.store('https://asana.example', {
      'top_menu_items': ['latest', 'categories'],
      'navigation_menu_site_top_tags': [
        {'id': 1, 'name': 'help'},
        'typing',
      ],
      'categories': [
        {
          'id': 5,
          'name': 'Asana Community',
          'color': '4573D2',
          'description_text': 'Teams&#39; home',
          'topic_count': 14,
          'post_count': 90,
          'subcategory_list_style': 'boxes',
        },
        {'id': 6, 'name': 'Ask the Community', 'parent_category_id': 5},
      ],
    });
    final caps = DiscourseSiteCapabilities.forSite('https://asana.example');
    expect(caps.topTags, ['help', 'typing']);
    final parent = caps.categoryStyleFor('5')!;
    expect(parent.description, "Teams' home");
    expect(parent.topicCount, 14);
    expect(parent.subcategoriesAsBoxes, isTrue);
    final child = caps.categoryStyleFor('6')!;
    expect(child.description, isNull);
    expect(child.subcategoriesAsBoxes, isFalse);
  });

  test('topics this week, subcategory lists included', () {
    DiscourseSiteCapabilities.storeCategoryActivity('https://py.example', [
      {
        'id': 7,
        'topics_week': 15,
        'subcategory_list': [
          {'id': 70, 'topics_week': 2},
        ],
      },
      {'id': 8},
    ]);
    final caps = DiscourseSiteCapabilities.forSite('https://py.example');
    expect(caps.topicsThisWeek[7], 15);
    expect(caps.topicsThisWeek[70], 2);
    expect(caps.topicsThisWeek.containsKey(8), isFalse);
  });
}
