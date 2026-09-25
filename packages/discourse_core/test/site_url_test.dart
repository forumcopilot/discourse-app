import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_core/src/util/site_url.dart';
import 'package:flutter_test/flutter_test.dart';

/// Discourse hands out absolute, site-relative and — for uploads on S3 or a
/// CDN, i.e. every forum Discourse hosts — protocol-relative URLs. The last
/// used to be glued onto the forum's address as a path, so Asana's category
/// logo became https://forum.asana.com//cdck-file-uploads… (a 404) and the
/// app drew an initial where the web shows the logo.
void main() {
  const asanaLogo = '//cdck-file-uploads-us1.s3.dualstack.us-west-2.amazonaws.com'
      '/asana/original/4X/2/5/b/25b853b27f16157184c53262c5be92f95b1c8a47.png';

  test('protocol-relative takes the forum scheme', () {
    expect(absoluteSiteUrl('https://forum.asana.com', asanaLogo),
        'https:$asanaLogo');
    expect(absoluteSiteUrl('http://127.0.0.1:4200', '//cdn.example/a.png'),
        'http://cdn.example/a.png');
  });

  test('site-relative joins the forum address; absolute is kept', () {
    expect(absoluteSiteUrl('https://f.example', '/user_avatar/f/a/120/1.png'),
        'https://f.example/user_avatar/f/a/120/1.png');
    expect(absoluteSiteUrl('https://f.example', 'https://cdn.example/a.png'),
        'https://cdn.example/a.png');
    expect(absoluteSiteUrl('https://f.example', ''), '');
  });

  test('category uploads resolve, with dark variants when uploaded', () {
    DiscourseSiteCapabilities.store('https://forum.asana.com', {
      'top_menu_items': ['latest'],
      'categories': [
        {
          'id': 18,
          'name': 'Product Announcements',
          'color': 'FCBD01',
          'uploaded_logo': {'url': asanaLogo, 'width': 98, 'height': 98},
          'uploaded_logo_dark': null,
          'uploaded_background': {'url': '/uploads/default/original/bg.jpg'},
          'uploaded_background_dark': {'url': '//cdn.example/bg-dark.jpg'},
        },
      ],
    });
    final style = DiscourseSiteCapabilities.forSite('https://forum.asana.com')
        .categoryStyleFor('18')!;
    expect(style.logoFor(dark: false), 'https:$asanaLogo');
    // No dark logo uploaded: the one logo serves both.
    expect(style.logoFor(dark: true), 'https:$asanaLogo');
    expect(style.backgroundFor(dark: false),
        'https://forum.asana.com/uploads/default/original/bg.jpg');
    expect(style.backgroundFor(dark: true), 'https://cdn.example/bg-dark.jpg');
  });
}
