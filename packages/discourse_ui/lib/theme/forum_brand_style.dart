import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities;
import 'package:flutter/material.dart';

import '../utils/discourse_color.dart';
import '../utils/html_colors.dart';
import 'app_theme.dart';
import 'forum_colors.dart';
import 'forum_palette.dart';

/// How a forum presents itself on its identity card (the header on its
/// home) and at the top of its drawer: a gradient in the forum's colour,
/// with text that reads on it.
///
/// The colour is the forum's web header when that is branded — Docker's
/// navy, a coloured bar — and otherwise its accent: most forums keep the
/// header the colour of the page and carry their brand in `tertiary`
/// (meta's purple, Asana's). Both come from the current theme, so they
/// follow light and dark mode and fall back to the app's own colours
/// outside a forum.
@immutable
class ForumBrandStyle {
  const ForumBrandStyle._(this.colors, this.foreground);

  /// Top-left to bottom-right; the middle stop is the brand colour itself.
  final List<Color> colors;

  /// Text and icons on the card: the forum's own header text (or the
  /// accent's) when it reads across the whole gradient, otherwise white or
  /// black.
  final Color foreground;

  Color get base => colors[1];

  /// True for a dark card, which wants the forum's dark-mode logo.
  bool get isDark =>
      ThemeData.estimateBrightnessForColor(base) == Brightness.dark;

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
        stops: const [0, 0.55, 1],
      );

  /// A header this far from the page counts as branded; below it the web
  /// header is the page colour and says nothing about the brand.
  static const double _brandedHeaderContrast = 1.5;

  /// The lightest an accent-coloured card gets in dark mode.
  static const double _darkCardLightness = 0.3;

  /// The style inside a forum: from the theme, which is the forum's own.
  factory ForumBrandStyle.of(BuildContext context) {
    final theme = Theme.of(context);
    final fc = ForumColors.of(context);
    return ForumBrandStyle._build(theme.colorScheme, fc.headerBackground,
        fc.headerPrimary, theme.brightness);
  }

  static final Map<(ForumPalette?, Brightness), ForumBrandStyle> _byPalette = {};

  /// The style of a forum that is not open — a host's list of forums —
  /// from its [palette], exactly as it will look inside. Cheap to call per
  /// row: only the colour scheme is derived, and results are kept.
  static ForumBrandStyle forPalette(ForumPalette? palette, Brightness brightness) {
    final key = (palette, brightness);
    final known = _byPalette[key];
    if (known != null) return known;
    final scheme = palette?.schemeFor(brightness) ?? DiscourseScheme.stock(brightness);
    final style = ForumBrandStyle._build(
      AppTheme.colorSchemeFor(brightness, palette),
      scheme.headerBackground,
      scheme.headerPrimary,
      brightness,
    );
    if (_byPalette.length >= 400) _byPalette.remove(_byPalette.keys.first);
    return _byPalette[key] = style;
  }

  /// A card in [color] — a category's own — drawn like the forum card:
  /// the same gradient, deepened on a dark screen, with [preferredText]
  /// (the category's `text_color`) when it reads.
  static ForumBrandStyle forColor(Color color,
          {Color? preferredText, required Brightness brightness}) =>
      ForumBrandStyle._withBase(
        brightness == Brightness.dark ? _deepened(color) : color,
        preferredText ?? Colors.white,
      );

  factory ForumBrandStyle._build(ColorScheme cs, Color headerBackground,
      Color headerPrimary, Brightness brightness) {
    final branded =
        contrastRatio(headerBackground, cs.surface) >= _brandedHeaderContrast;
    var base = branded ? headerBackground : cs.primaryContainer;
    // A bright accent (Let's Encrypt's cyan) would light up a dark screen;
    // in dark mode the card is the same hue, deep. A forum's own header
    // colour is its choice and stays as it is.
    if (!branded && brightness == Brightness.dark) base = _deepened(base);
    return ForumBrandStyle._withBase(
        base, branded ? headerPrimary : cs.onPrimaryContainer);
  }

  static Color _deepened(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl.lightness > _darkCardLightness
        ? hsl.withLightness(_darkCardLightness).toColor()
        : c;
  }

  factory ForumBrandStyle._withBase(Color base, Color preferred) {
    var colors = [
      _shift(base, lightness: 0.07, hue: -8),
      base,
      _shift(base, lightness: -0.09, hue: 8),
    ];
    if (_worst(preferred, colors) >= 4.5) return ForumBrandStyle._(colors, preferred);
    final fg = _worst(Colors.white, colors) >= _worst(Colors.black, colors)
        ? Colors.white
        : Colors.black;
    // A mid-tone brand (a saturated cyan) can leave neither white nor black
    // readable across the whole gradient; move the card away from the
    // text, a step at a time, until it reads.
    for (var i = 0; i < 12 && _worst(fg, colors) < 4.5; i++) {
      final step = fg == Colors.white ? -0.03 : 0.03;
      colors = [for (final c in colors) _shift(c, lightness: step, hue: 0)];
    }
    return ForumBrandStyle._(colors, fg);
  }

  // A little lighter and a little darker, turning the hue a few degrees
  // each way: enough to read as depth, not as a second colour. Greys have
  // no hue to turn.
  static Color _shift(Color c, {required double lightness, required double hue}) {
    final hsl = HSLColor.fromColor(c);
    final turned = hsl.saturation < 0.08
        ? hsl
        : hsl.withHue((hsl.hue + hue) % 360);
    return turned
        .withLightness((hsl.lightness + lightness).clamp(0.0, 1.0))
        .toColor();
  }

  /// The header colour the forum's logo at [url] was drawn for: its dark
  /// header for a dark-mode logo, its light header otherwise (white on a
  /// stock forum). See `BrandImage.designedFor`.
  static Color logoDesignedFor(DiscourseSiteCapabilities caps, String? url) {
    final dark = url != null &&
        [caps.logoDarkUrl, caps.mobileLogoDarkUrl, caps.smallLogoDarkUrl]
            .contains(url);
    return parseDiscourseHex(caps.headerBackgroundFor(dark: dark) ?? '') ??
        (dark ? const Color(0xFF111111) : Colors.white);
  }

  /// [fg]'s weakest contrast anywhere on the gradient.
  static double _worst(Color fg, List<Color> over) =>
      over.map((c) => contrastRatio(fg, c)).reduce((a, b) => a < b ? a : b);
}
