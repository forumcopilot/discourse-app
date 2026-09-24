import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-written category link (`/c/hardware/arduino`) carries no id; the
/// app finds it among the categories `/site.json` already gave it.
void main() {
  const forum = 'https://slugs.example';
  setUpAll(() => DiscourseSiteCapabilities.store(forum, {
        'top_menu_items': ['latest'],
        'categories': [
          {'id': 1, 'slug': 'hardware', 'name': 'Hardware', 'parent_category_id': null},
          {'id': 2, 'slug': 'arduino', 'name': 'Arduino', 'parent_category_id': 1},
          {'id': 3, 'slug': 'software', 'name': 'Software', 'parent_category_id': null},
          {'id': 4, 'slug': 'arduino', 'name': 'Arduino IDE', 'parent_category_id': 3},
        ],
      }));

  DiscourseSiteCapabilities caps() => DiscourseSiteCapabilities.forSite(forum);

  test('a top-level slug', () {
    expect(caps().categoryIdForSlugs(['hardware']), 1);
    expect(caps().categoryIdForSlugs(['Hardware']), 1);
  });

  test('a subcategory by its path, when two parents share a slug', () {
    expect(caps().categoryIdForSlugs(['hardware', 'arduino']), 2);
    expect(caps().categoryIdForSlugs(['software', 'arduino']), 4);
  });

  test('a subcategory without its parent matches the slug alone', () {
    expect(caps().categoryIdForSlugs(['arduino']), 2);
  });

  test('an id in place of a slug', () {
    expect(caps().categoryIdForSlugs(['3']), 3);
  });

  test('no such category', () {
    expect(caps().categoryIdForSlugs(['nope']), isNull);
    expect(caps().categoryIdForSlugs([]), isNull);
    expect(DiscourseSiteCapabilities.forSite('https://unknown.example')
        .categoryIdForSlugs(['hardware']), isNull);
  });
}
