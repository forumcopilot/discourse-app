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
}
