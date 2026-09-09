import 'package:discourse_ui/views/widgets/brand_image.dart';
import 'package:flutter_test/flutter_test.dart';

/// The decoder is picked from the URL's path, so query strings and case
/// must not confuse it: Discourse serves uploads with cache-busting
/// parameters and admins upload `Logo.SVG` as readily as `logo.svg`.
void main() {
  test('detects an SVG by path extension', () {
    expect(BrandImage.isSvg('https://f.example/uploads/logo.svg'), isTrue);
    expect(BrandImage.isSvg('https://f.example/uploads/Logo.SVG'), isTrue);
    expect(BrandImage.isSvg('https://f.example/uploads/logo.svg?v=3'), isTrue);
  });

  test('anything else is treated as raster', () {
    expect(BrandImage.isSvg('https://f.example/uploads/logo.png'), isFalse);
    expect(BrandImage.isSvg('https://f.example/svg/logo.png?x=.svg'), isFalse);
    expect(BrandImage.isSvg(''), isFalse);
  });
}
