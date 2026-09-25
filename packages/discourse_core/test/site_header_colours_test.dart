import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// Header colours ride on `/site.json`'s default colour schemes. A forum on
/// the stock scheme sends none; a themed forum sends `{name, hex}` pairs,
/// sometimes 3-digit. The header must get a usable value or null, never
/// something it has to sanitize itself.
void main() {
  test('themed forum: light and dark header colours are captured', () {
    DiscourseSiteCapabilities.store('https://a.example', {
      'top_menu_items': ['latest'],
      'default_light_color_scheme': {
        'colors': [
          {'name': 'header_background', 'hex': 'fff'},
          {'name': 'header_primary', 'hex': '#333333'},
          {'name': 'primary', 'hex': '222222'},
        ],
      },
      'default_dark_color_scheme': {
        'colors': [
          {'name': 'header_background', 'hex': '0d1117'},
          {'name': 'header_primary', 'hex': 'not-a-colour'},
        ],
      },
    });
    final caps = DiscourseSiteCapabilities.forSite('https://a.example');
    expect(caps.headerBackgroundFor(dark: false), 'ffffff');
    expect(caps.headerPrimaryFor(dark: false), '333333');
    expect(caps.headerBackgroundFor(dark: true), '0d1117');
    // Malformed dark value falls back to the light one.
    expect(caps.headerPrimaryFor(dark: true), '333333');
  });

  test('stock forum: no scheme means no colours', () {
    DiscourseSiteCapabilities.store('https://b.example', {
      'top_menu_items': ['latest'],
      'default_light_color_scheme': null,
      'default_dark_color_scheme': {'name': 'Dark'},
    });
    final caps = DiscourseSiteCapabilities.forSite('https://b.example');
    expect(caps.headerBackgroundFor(dark: false), isNull);
    expect(caps.headerBackgroundFor(dark: true), isNull);
  });

  // The app themes itself from these, so it needs every colour, not just
  // the header's, and must tell "stock Light" and "no dark mode" apart.
  test('full schemes are kept; a missing scheme is null', () {
    DiscourseSiteCapabilities.store('https://c.example', {
      'top_menu_items': ['latest'],
      'default_light_color_scheme': {
        'colors': [
          {'name': 'primary', 'hex': '222'},
          {'name': 'secondary', 'hex': 'fafafa'},
          {'name': 'tertiary', 'hex': '#0a7c86'},
          {'name': 'love', 'hex': 'nope'},
        ],
      },
      'default_dark_color_scheme': null,
    });
    final caps = DiscourseSiteCapabilities.forSite('https://c.example');
    expect(caps.lightScheme, {
      'primary': '222222',
      'secondary': 'fafafa',
      'tertiary': '0a7c86',
    });
    expect(caps.darkScheme, isNull);

    DiscourseSiteCapabilities.store('https://d.example', {
      'top_menu_items': ['latest'],
      'default_light_color_scheme': null,
    });
    expect(DiscourseSiteCapabilities.forSite('https://d.example').lightScheme,
        isNull);
  });

  test('category styles: colours, parent, emoji; uncategorized known', () {
    DiscourseSiteCapabilities.store('https://e.example', {
      'top_menu_items': ['latest'],
      'uncategorized_category_id': 1,
      'categories': [
        {'id': 1, 'name': 'Uncategorized', 'color': '0088CC'},
        {'id': 4, 'name': 'General', 'color': '25AAE2', 'text_color': 'FFFFFF',
         'style_type': 'emoji', 'emoji': 'blue_book'},
        {'id': 6, 'name': 'Arduino', 'color': 'E45735', 'parent_category_id': 4},
      ],
    });
    final caps = DiscourseSiteCapabilities.forSite('https://e.example');
    final general = caps.categoryStyleFor('4')!;
    expect(general.name, 'General');
    expect(general.colorHex, '25AAE2');
    expect(general.styleType, 'emoji');
    expect(general.emoji, 'blue_book');
    // Older forums send no style_type: a square.
    expect(caps.categoryStyleFor('6')!.styleType, 'square');
    expect(caps.categoryStyleFor('6')!.parentId, 4);
    expect(caps.categoryStyleFor('99'), isNull);
    expect(caps.isUncategorized('1'), isTrue);
    expect(caps.isUncategorized('4'), isFalse);
  });
}

