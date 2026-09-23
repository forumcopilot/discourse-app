import 'package:forumcopilot_sdk/context/site_context.dart';

/// How the forum wants photos prepared before upload — the settings behind
/// Discourse's own composer optimization (`media-optimization-worker.js`,
/// `media-optimization-bundle.js`), all `client: true` in
/// `/site/settings.json`:
///
/// * a JPEG or PNG of at least [bytesThreshold] bytes is optimized;
/// * when it is wider than [resizeThreshold] pixels it is scaled to
///   [widthTarget] wide, keeping its aspect;
/// * it is re-encoded as JPEG at [quality];
/// * a result under 20,000 bytes is thrown away as broken.
///
/// On iOS it also needs `composer_ios_media_optimisation_image_enabled`.
class DiscourseMediaOptimization {
  const DiscourseMediaOptimization({
    this.enabled = true,
    this.enabledOnIos = true,
    this.bytesThreshold = 524288,
    this.resizeThreshold = 1920,
    this.widthTarget = 1920,
    this.quality = 70,
  });

  /// `composer_media_optimization_image_enabled`.
  final bool enabled;

  /// `composer_ios_media_optimisation_image_enabled`.
  final bool enabledOnIos;

  /// `composer_media_optimization_image_bytes_optimization_threshold`.
  final int bytesThreshold;

  /// `composer_media_optimization_image_resize_dimensions_threshold`.
  final int resizeThreshold;

  /// `composer_media_optimization_image_resize_width_target`.
  final int widthTarget;

  /// `composer_media_optimization_image_encode_quality`, or the forum's
  /// `image_quality` when that is 0 (its default).
  final int quality;

  /// Discourse drops an optimized image smaller than this as "suspiciously
  /// small" and uploads the original.
  static const int minimumResultBytes = 20000;

  /// Parse the `/site/settings.json` payload; anything missing keeps
  /// Discourse's default.
  factory DiscourseMediaOptimization.fromClientSettings(
      Map<String, dynamic> json) {
    const d = DiscourseMediaOptimization();
    int? positive(Object? raw) {
      final v = raw is num ? raw.toInt() : int.tryParse(raw?.toString() ?? '');
      return (v != null && v > 0) ? v : null;
    }

    bool flag(Object? raw, bool fallback) => raw is bool ? raw : fallback;

    return DiscourseMediaOptimization(
      enabled:
          flag(json['composer_media_optimization_image_enabled'], d.enabled),
      enabledOnIos: flag(json['composer_ios_media_optimisation_image_enabled'],
          d.enabledOnIos),
      bytesThreshold: positive(json[
              'composer_media_optimization_image_bytes_optimization_threshold']) ??
          d.bytesThreshold,
      resizeThreshold: positive(json[
              'composer_media_optimization_image_resize_dimensions_threshold']) ??
          d.resizeThreshold,
      widthTarget: positive(
              json['composer_media_optimization_image_resize_width_target']) ??
          d.widthTarget,
      quality:
          positive(json['composer_media_optimization_image_encode_quality']) ??
              positive(json['image_quality']) ??
              d.quality,
    );
  }

  /// The size an image of [width] x [height] (as displayed, after its
  /// orientation) is scaled to: [widthTarget] wide when wider than
  /// [resizeThreshold], rounding the height as Discourse's
  /// `resizeWithAspect` does; otherwise unchanged.
  ({int width, int height}) targetSize(int width, int height) {
    if (width <= resizeThreshold || width <= 0) {
      return (width: width, height: height);
    }
    return (
      width: widthTarget,
      height: (height / width * widthTarget).round(),
    );
  }
}

/// Per-site cache, the same Expando-on-[SiteContext] pattern as the upload
/// limits. Populated by `DiscourseConfigProxy.getConfig`; null until then
/// (callers then upload photos as they are).
extension DiscourseMediaOptimizationContext on SiteContext {
  static final Expando<DiscourseMediaOptimization> _settings =
      Expando('discourseMediaOptimization');

  DiscourseMediaOptimization? get mediaOptimization => _settings[this];

  void setMediaOptimization(DiscourseMediaOptimization? settings) {
    _settings[this] = settings;
  }
}
