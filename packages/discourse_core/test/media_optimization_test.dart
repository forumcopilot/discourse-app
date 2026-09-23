import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// The forum's photo settings, read the way Discourse's composer reads them
/// (media-optimization-worker.js, media-optimization-bundle.js).
void main() {
  test('defaults are Discourse\'s', () {
    final o = DiscourseMediaOptimization.fromClientSettings(const {});
    expect(o.enabled, isTrue);
    expect(o.enabledOnIos, isTrue);
    expect(o.bytesThreshold, 524288);
    expect(o.resizeThreshold, 1920);
    expect(o.widthTarget, 1920);
    expect(o.quality, 70);
  });

  test('encode quality 0 means the forum\'s image_quality', () {
    final o = DiscourseMediaOptimization.fromClientSettings(const {
      'composer_media_optimization_image_enabled': false,
      'composer_ios_media_optimisation_image_enabled': false,
      'composer_media_optimization_image_bytes_optimization_threshold': 1000,
      'composer_media_optimization_image_resize_dimensions_threshold': 1600,
      'composer_media_optimization_image_resize_width_target': 1200,
      'composer_media_optimization_image_encode_quality': 0,
      'image_quality': 90,
    });
    expect(o.enabled, isFalse);
    expect(o.enabledOnIos, isFalse);
    expect(o.bytesThreshold, 1000);
    expect(o.resizeThreshold, 1600);
    expect(o.widthTarget, 1200);
    expect(o.quality, 90);
    expect(
        DiscourseMediaOptimization.fromClientSettings(const {
          'composer_media_optimization_image_encode_quality': 60,
          'image_quality': 90,
        }).quality,
        60);
  });

  test('only width decides, and height follows the aspect', () {
    const o = DiscourseMediaOptimization();
    expect(o.targetSize(4032, 3024), (width: 1920, height: 1440));
    // Portrait: 3024 wide is over 1920, so it becomes 1920 x 2560.
    expect(o.targetSize(3024, 4032), (width: 1920, height: 2560));
    // Tall but narrow (a phone screenshot) is left alone, as on the web.
    expect(o.targetSize(1080, 2400), (width: 1080, height: 2400));
    expect(o.targetSize(1920, 1080), (width: 1920, height: 1080));
  });
}
