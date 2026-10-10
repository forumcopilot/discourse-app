import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// What to do so a logo shows on a background.
enum LogoFix {
  /// It reads as it is.
  none,

  /// Draw it with [LogoTone.invertLightness]: right for one-tone artwork
  /// (a black wordmark on a dark card), whose colours survive the flip.
  invert,

  /// Draw it, untouched, on a small backing of the colour it was designed
  /// for: right for artwork with both light and dark parts (Python's grey
  /// wordmark and yellow snake), which inverting would spoil.
  plate,
}

/// How light a forum's logo is, measured from its pixels.
///
/// Logos are transparent artwork drawn for one background — the forum's
/// own header. On another (the brand card, a dark surface) a black
/// wordmark can vanish into near-black, or a white one into white.
/// [fixOn] says whether and how to help, from how much of the logo would
/// fade — measured per pixel, because a logo's average hides a thin grey
/// wordmark next to a bright mark — compared with how it fares on the
/// background it was drawn for, because some artwork is faint there too
/// (Python's yellow snake on white) and that is the designer's choice.
@immutable
class LogoTone {
  const LogoTone._(this._bins, this._invertedBins, this.coverage);

  // Alpha-weighted share of the visible pixels in each perceptual
  // lightness band (CIE L*, 0–100), as drawn and as inverted.
  final List<double> _bins;
  final List<double> _invertedBins;

  /// Share of the image its opaque pixels fill. Near 1, the artwork brings
  /// its own background (a JPEG, a badge) and reads on anything.
  final double coverage;

  static const int _bands = 50;

  /// A pixel below this contrast with the background is lost. Python's
  /// grey wordmark on a deep blue card measures 2.0 and is barely there;
  /// still under the 3:1 asked of icons, because shapes read a little.
  static const double _lost = 2.5;

  /// Help a logo when at least this share of it is lost…
  static const double _needsHelp = 0.3;

  /// …and that is at least this much more than on its own background…
  static const double _worseBy = 0.25;

  /// …and invert it only if that leaves no more than this share lost.
  static const double _invertLeaves = 0.12;

  /// Inverts lightness and keeps hue: `hue-rotate(180°) ∘ invert`, from the
  /// CSS Filter Effects matrices. Black ↔ white; a mid-tone colour stays
  /// close to itself.
  static const ColorFilter invertLightness = ColorFilter.matrix(<double>[
    0.574, -1.430, -0.144, 0, 255, //
    -0.426, -0.430, -0.144, 0, 255, //
    -0.426, -1.430, 0.856, 0, 255, //
    0, 0, 0, 1, 0, //
  ]);

  /// Share of the logo lost on [background], drawn as is or [inverted].
  double lostOn(Color background, {bool inverted = false}) {
    final bins = inverted ? _invertedBins : _bins;
    final lb = background.computeLuminance();
    var lost = 0.0;
    for (var i = 0; i < _bands; i++) {
      if (bins[i] == 0) continue;
      final l = _luminanceOfLightness((i + 0.5) * 100 / _bands);
      final hi = math.max(lb, l), lo = math.min(lb, l);
      if ((hi + 0.05) / (lo + 0.05) < _lost) lost += bins[i];
    }
    return lost;
  }

  /// How to draw this logo on [background], given the background it was
  /// [designedFor] — the forum's header colour for this logo variant. A
  /// [LogoFix.plate] is drawn in [designedFor].
  LogoFix fixOn(Color background, {required Color designedFor}) {
    if (coverage > 0.9) return LogoFix.none;
    final lost = lostOn(background);
    if (lost < _needsHelp || lost - lostOn(designedFor) < _worseBy) {
      return LogoFix.none;
    }
    return lostOn(background, inverted: true) <= _invertLeaves
        ? LogoFix.invert
        : LogoFix.plate;
  }

  static final Map<String, LogoTone?> _known = {};
  static final Map<String, Future<LogoTone?>> _pending = {};

  /// Whether [url] has been measured (its answer may be null: unmeasurable).
  static bool isKnown(String url) => _known.containsKey(url);

  /// The measured tone of [url], if it has been measured.
  static LogoTone? known(String url) => _known[url];

  /// Measures [url], once per process. Reads the file from the same disk
  /// cache the logo is drawn from, so it costs no second download. Null
  /// when the image cannot be read.
  static Future<LogoTone?> of(String url) => _pending[url] ??= _measure(url)
      .then((tone) => _known[url] = tone);

  static Future<LogoTone?> _measure(String url) async {
    try {
      final file = await DefaultCacheManager().getSingleFile(url);
      final bytes = await file.readAsBytes();
      final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
      final image = path.endsWith('.svg')
          ? await _rasterizeSvg(bytes)
          : await _decode(bytes);
      if (image == null) return null;
      final data =
          await image.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
      image.dispose();
      return data == null ? null : fromRgba(data.buffer.asUint8List());
    } catch (e) {
      debugPrint('LogoTone: could not measure $url: $e');
      return null;
    }
  }

  // Small: a distribution needs no detail, and a wordmark decoded at full
  // size would cost more than it tells.
  static const int _sample = 96;

  static Future<ui.Image?> _decode(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: _sample);
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  }

  static Future<ui.Image?> _rasterizeSvg(Uint8List bytes) async {
    final info = await vg.loadPicture(SvgBytesLoader(bytes), null);
    try {
      final w = info.size.width, h = info.size.height;
      if (w <= 0 || h <= 0) return null;
      final scale = _sample / math.max(w, h);
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder)
        ..scale(scale)
        ..drawPicture(info.picture);
      final picture = recorder.endRecording();
      final image = await picture.toImage(
          math.max(1, (w * scale).round()), math.max(1, (h * scale).round()));
      picture.dispose();
      return image;
    } finally {
      info.picture.dispose();
    }
  }

  /// The tone of straight-alpha RGBA pixels; null when nothing is visible.
  @visibleForTesting
  static LogoTone? fromRgba(Uint8List rgba) {
    final n = rgba.length ~/ 4;
    final bins = List<double>.filled(_bands, 0);
    final inverted = List<double>.filled(_bands, 0);
    var weight = 0.0;
    var opaque = 0;
    for (var i = 0; i < n; i++) {
      final a = rgba[i * 4 + 3] / 255.0;
      if (a < 0.1) continue;
      if (a > 0.9) opaque++;
      final r = rgba[i * 4], g = rgba[i * 4 + 1], b = rgba[i * 4 + 2];
      bins[_band(Color.fromARGB(255, r, g, b))] += a;
      inverted[_band(_invert(r, g, b))] += a;
      weight += a;
    }
    if (weight == 0) return null;
    for (var i = 0; i < _bands; i++) {
      bins[i] /= weight;
      inverted[i] /= weight;
    }
    return LogoTone._(bins, inverted, opaque / n);
  }

  static int _band(Color c) {
    final lStar = _lightnessOfLuminance(c.computeLuminance());
    return (lStar / 100 * _bands).floor().clamp(0, _bands - 1);
  }

  static Color _invert(int r, int g, int b) {
    const m = [
      0.574, -1.430, -0.144, 255.0, //
      -0.426, -0.430, -0.144, 255.0, //
      -0.426, -1.430, 0.856, 255.0, //
    ];
    int ch(int row) =>
        (m[row * 4] * r + m[row * 4 + 1] * g + m[row * 4 + 2] * b + m[row * 4 + 3])
            .round()
            .clamp(0, 255);
    return Color.fromARGB(255, ch(0), ch(1), ch(2));
  }

  // CIE L* ↔ relative luminance Y.
  static double _lightnessOfLuminance(double y) =>
      y <= 216 / 24389 ? y * 24389 / 27 : 116 * math.pow(y, 1 / 3) - 16;
  static double _luminanceOfLightness(double l) => l <= 8
      ? l * 27 / 24389
      : math.pow((l + 16) / 116, 3).toDouble();

  @visibleForTesting
  static void remember(String url, LogoTone? tone) {
    _known[url] = tone;
    _pending[url] = Future.value(tone);
  }

  @visibleForTesting
  static void reset() {
    _known.clear();
    _pending.clear();
  }
}
