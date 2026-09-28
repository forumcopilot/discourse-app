import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import '../utils/html_colors.dart';
import 'design_tokens.dart';
import 'forum_colors.dart';
import 'forum_palette.dart';
import 'style_builders.dart';

/// Central theme configuration for the app.
///
/// Inside a forum the colours are the forum's own ([palette], set by
/// `ForumTheme`); outside one (a host's forum list) and when a fork turns
/// forum colours off, they come from [seedColor].
class AppTheme {
  static final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  /// The open forum's colours, or null for the app's own. The app shell
  /// reads [lightTheme]/[darkTheme] inside an `Obx`, so setting this
  /// re-themes the app.
  static final Rxn<ForumPalette> palette = Rxn<ForumPalette>();

  // Customizable seed color (defaults to blue, can be changed by admin)
  static Color _customSeedColor = Colors.blue;

  /// Sets the seed color for the app's own theme (no forum open, or forum
  /// colours turned off).
  static void setSeedColor(Color color) {
    _customSeedColor = color;
  }

  /// Gets the current seed color.
  static Color get seedColor => _customSeedColor;

  static ThemeData get lightTheme => themeFor(Brightness.light, palette.value);

  static ThemeData get darkTheme => themeFor(Brightness.dark, palette.value);

  // Built once per brightness, palette and seed: the shell's Obx rebuilds
  // on every locale or mode change, and fromSeed is not free.
  static final Map<(Brightness, ForumPalette?, Color), ThemeData> _themes = {};

  /// The theme for [brightness] in the colours of [palette] (null: the
  /// app's own).
  static ThemeData themeFor(Brightness brightness, ForumPalette? palette) =>
      _themes.putIfAbsent((brightness, palette, _customSeedColor), () {
        final colorScheme = colorSchemeFor(brightness, palette);
        final scheme = palette?.schemeFor(brightness);
        final (brand, onBrand) = brandContainerFor(brightness, palette);
        return _build(
          colorScheme,
          ForumColors.from(scheme ?? DiscourseScheme.stock(brightness),
              surface: colorScheme.surface, brand: brand, onBrand: onBrand),
        );
      });

  /// The [ColorScheme] for [brightness] in the colours of [palette].
  ///
  /// Balanced, the way Material 3 uses a brand colour: the forum's accent
  /// colours the accents (buttons, links, the selection, the New Topic
  /// button) and the page stays neutral, so that what is read stays easy
  /// to read. The forum's banner and its category colours carry the rest of
  /// its identity at full strength.
  ///
  /// It used to pin every colour of the forum's scheme exactly: an accent
  /// that made links hard to read (it needed only 3:1, where text needs
  /// 4.5:1, which 60% of forums' light accents miss), navy or purple pages
  /// with cyan text, and, for a forum with no dark mode, a dark scheme
  /// seeded from its accent with Material's "fidelity" variant: brown-red
  /// or blue pages and a deep-red navigation indicator for a red forum.
  static ColorScheme colorSchemeFor(
      Brightness brightness, ForumPalette? palette) {
    if (palette == null) {
      return ColorScheme.fromSeed(
          seedColor: _customSeedColor, brightness: brightness);
    }
    final scheme = palette.schemeFor(brightness);
    final accent = scheme?.tertiary ?? palette.accent;
    // Material's default variant (tonal spot): containers and panels in
    // muted tones of the accent.
    final seeded =
        ColorScheme.fromSeed(seedColor: accent, brightness: brightness);
    return _accents(
        _surfaces(seeded, brightness, scheme, accent), brightness, scheme, accent);
  }

  /// The forum's accent as a full-strength container, and text on it: its
  /// banner (`ForumBrandStyle`), on its home and in a host's list of
  /// forums, where its identity belongs. Material's "fidelity" variant keeps
  /// the brand's strength, which the app's own scheme no longer does
  /// ([colorSchemeFor]). Without a forum, the app's seed as before.
  static (Color, Color) brandContainerFor(
      Brightness brightness, ForumPalette? palette) {
    final cs = palette == null
        ? ColorScheme.fromSeed(seedColor: _customSeedColor, brightness: brightness)
        : ColorScheme.fromSeed(
            seedColor: palette.schemeFor(brightness)?.tertiary ?? palette.accent,
            brightness: brightness,
            dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
          );
    return (cs.primaryContainer, cs.onPrimaryContainer);
  }

  /// Up to this chroma (HCT) a page colour is near-neutral (white, an
  /// off-white, a warm or cool grey) and the forum's own page is kept.
  static const double _neutralChroma = 8;

  /// Body text's aim: 7:1 against the page.
  static const double _bodyContrast = 7;

  /// The page, its text and Material's container steps.
  ///
  /// The forum's own page and text when the page is near-neutral and the
  /// text reads on it; otherwise Material's neutral tones with a hint of
  /// the forum's hue: the page's own when it is coloured (a navy dark theme
  /// stays a navy-grey), else the accent's.
  static ColorScheme _surfaces(ColorScheme cs, Brightness brightness,
      DiscourseScheme? s, Color accent) {
    final dark = brightness == Brightness.dark;
    final page = s == null ? null : Hct.fromInt(s.secondary.toARGB32());
    if (s != null && page!.chroma <= _neutralChroma) {
      final text = _readableText(s.primary, s.secondary);
      if (contrastRatio(text, s.secondary) >= _bodyContrast) {
        // Material's containers step away from the page towards its text,
        // as Discourse mixes `primary-low` and friends.
        Color mix(double t) => Color.lerp(s.secondary, text, t)!;
        return cs.copyWith(
          surface: s.secondary,
          onSurface: text,
          surfaceDim: dark ? s.secondary : mix(0.1),
          surfaceBright: dark ? mix(0.15) : s.secondary,
          surfaceContainerLowest: s.secondary,
          surfaceContainerLow: mix(0.03),
          surfaceContainer: mix(0.06),
          surfaceContainerHigh: mix(0.09),
          surfaceContainerHighest: mix(0.12),
          onSurfaceVariant: readableOn(mix(0.7), s.secondary),
          outline: mix(0.45),
          outlineVariant: mix(0.18),
          inverseSurface: text,
          onInverseSurface: s.secondary,
        );
      }
    }
    final coloured = page != null && page.chroma > _neutralChroma;
    final hue = coloured ? page.hue : Hct.fromInt(accent.toARGB32()).hue;
    final neutral = TonalPalette.of(hue, coloured ? 6 : 3);
    final neutralVariant = TonalPalette.of(hue, coloured ? 8 : 5);
    // A coloured page keeps its lightness, within Material's range for a
    // page in this mode.
    final base = coloured
        ? (dark ? page.tone.clamp(4.0, 12.0) : page.tone.clamp(92.0, 99.0))
        : (dark ? 6.0 : 98.0);
    Color tone(double offset) =>
        Color(neutral.get((base + offset).clamp(0.0, 100.0).round()));
    // Material's steps from the page to its containers, lowest to highest.
    final steps = dark
        ? const [-2.0, 4.0, 6.0, 11.0, 16.0]
        : const [2.0, -2.0, -4.0, -6.0, -8.0];
    return cs.copyWith(
      surface: tone(0),
      surfaceDim: dark ? tone(0) : tone(-11),
      surfaceBright: dark ? tone(18) : tone(0),
      surfaceContainerLowest: tone(steps[0]),
      surfaceContainerLow: tone(steps[1]),
      surfaceContainer: tone(steps[2]),
      surfaceContainerHigh: tone(steps[3]),
      surfaceContainerHighest: tone(steps[4]),
      onSurface: Color(neutral.get(dark ? 90 : 10)),
      onSurfaceVariant: Color(neutralVariant.get(dark ? 80 : 30)),
      outline: Color(neutralVariant.get(dark ? 60 : 50)),
      outlineVariant: Color(neutralVariant.get(dark ? 30 : 80)),
      inverseSurface: Color(neutral.get(dark ? 90 : 20)),
      onInverseSurface: Color(neutral.get(dark ? 20 : 95)),
    );
  }

  /// The forum's text colour as body text on [page]: most of the colour
  /// taken out when it is coloured (cyan body text read as one long link),
  /// then darkened or lightened until it reaches [_bodyContrast].
  static Color _readableText(Color text, Color page) {
    var h = Hct.fromInt(text.toARGB32());
    if (h.chroma > 24) h = Hct.from(h.hue, 4, h.tone);
    return _legible(Color(h.toInt()), page, _bodyContrast);
  }

  /// The accent, the selection and the error colour.
  static ColorScheme _accents(ColorScheme cs, Brightness brightness,
      DiscourseScheme? s, Color accent) {
    final dark = brightness == Brightness.dark;
    final a = Hct.fromInt(accent.toARGB32());
    // `primary` is text too (links, text buttons), so it reads at 4.5:1.
    // Light: the forum's accent itself, darkened only as far as that needs
    // (usually a shade). Dark: the forum's own dark accent when it reads
    // and is not glaring; else Material's pale accent (tone 80) in its hue,
    // as saturated colours glare on a dark page.
    final Color primary;
    if (!dark) {
      primary = _legible(accent, cs.surface, 4.5);
    } else if (s != null &&
        contrastRatio(accent, cs.surface) >= 4.5 &&
        a.chroma <= 48) {
      primary = accent;
    } else {
      final pale = Color(Hct.from(a.hue, math.min(a.chroma, 48), 80).toInt());
      primary = _legible(pale, cs.surface, 4.5);
    }
    cs = cs.copyWith(
      primary: primary,
      onPrimary: _onColor(primary, preferred: cs.surface),
      surfaceTint: primary,
    );
    // Selected chips and the navigation indicator: the forum's own
    // "selected" when it goes with the accent (a grey, or a soft tint of
    // the accent's hue) and its text reads; else Material's container.
    // Discourse's untouched light blue is not kept for a purple forum.
    final selected = s?.selected;
    if (selected != null &&
        _suitsAccent(selected, a) &&
        contrastRatio(cs.onSurface, selected) >= 4.5) {
      cs = cs.copyWith(
          secondaryContainer: selected, onSecondaryContainer: cs.onSurface);
    }
    final danger = s?.danger;
    if (danger != null) {
      final error = _legible(danger, cs.surface, 4.5);
      cs = cs.copyWith(
          error: error, onError: _onColor(error, preferred: cs.surface));
    }
    return cs;
  }

  /// Whether a selection colour goes with the accent: a grey, or a soft tint
  /// within 40° of its hue.
  static bool _suitsAccent(Color selected, Hct accent) {
    final h = Hct.fromInt(selected.toARGB32());
    if (h.chroma <= _neutralChroma) return true;
    final apart = (h.hue - accent.hue).abs();
    return h.chroma <= 24 && math.min(apart, 360 - apart) <= 40;
  }

  /// [color]'s hue and chroma at the tone nearest its own that reads at
  /// [ratio] on [page]: darker on a light page, lighter on a dark one.
  static Color _legible(Color color, Color page, double ratio) {
    if (contrastRatio(color, page) >= ratio) return color;
    final h = Hct.fromInt(color.toARGB32());
    final darker = page.computeLuminance() > 0.18;
    for (var t = h.tone; t >= 0 && t <= 100; t += darker ? -1 : 1) {
      final candidate = Color(Hct.from(h.hue, h.chroma, t).toInt());
      if (contrastRatio(candidate, page) >= ratio) return candidate;
    }
    return darker ? Colors.black : Colors.white;
  }

  /// Text for a fill of [fill]: [preferred] (Discourse puts `secondary` on
  /// its buttons) when it reads, else black or white, whichever reads better.
  static Color _onColor(Color fill, {required Color preferred}) {
    if (contrastRatio(preferred, fill) >= 4.5) return preferred;
    return contrastRatio(Colors.white, fill) >= contrastRatio(Colors.black, fill)
        ? Colors.white
        : Colors.black;
  }

  /// Material 3's defaults wherever the spec has one. Screens take their
  /// look from here instead of restyling each component, which is how the
  /// app bars, dialogs and sheets had drifted into several looks each.
  static ThemeData _build(ColorScheme colorScheme, ForumColors forumColors) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: [forumColors],
      // Small top app bar: titleLarge, aligned to the start, flat until
      // content scrolls under it.
      appBarTheme: const AppBarTheme(centerTitle: false),
      // Floating buttons (New Topic, New Message) in the forum's accent —
      // its buttons' colour on the web — not Material's tonal container.
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      cardTheme: StyleBuilders.cardTheme(
        colorScheme: colorScheme,
        elevation: DesignTokens.elevationMedium,
        borderRadius: DesignTokens.radiusM,
      ),
      // Outlined text field: 4dp corners and 56dp high (see paddingInput).
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: DesignTokens.paddingInput,
      ),
      // Sheets keep M3's 28dp top corners and get its drag handle.
      bottomSheetTheme: const BottomSheetThemeData(showDragHandle: true),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
