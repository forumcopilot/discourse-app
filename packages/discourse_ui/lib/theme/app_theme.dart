import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        return _build(
          colorScheme,
          ForumColors.from(scheme ?? DiscourseScheme.stock(brightness),
              surface: colorScheme.surface),
        );
      });

  /// The [ColorScheme] for [brightness] in the colours of [palette].
  ///
  /// With a forum scheme for this brightness, Material's scheme is seeded
  /// from its accent (`tertiary`) and then the colours a reader recognises
  /// the forum by are pinned to the forum's exact values: background and
  /// text (`secondary`/`primary`), accent, error (`danger`) and selection
  /// (`selected`), with Material's container greys mixed from the forum's
  /// own background and text the way Discourse mixes `primary-low` and
  /// friends. A pinned colour that would not be legible is left to the
  /// seeded scheme. Without one (a forum with no dark mode, say) the whole
  /// scheme is seeded from the forum's accent.
  static ColorScheme colorSchemeFor(
      Brightness brightness, ForumPalette? palette) {
    if (palette == null) {
      return ColorScheme.fromSeed(
          seedColor: _customSeedColor, brightness: brightness);
    }
    final scheme = palette.schemeFor(brightness);
    final seeded = ColorScheme.fromSeed(
      seedColor: scheme?.tertiary ?? palette.accent,
      brightness: brightness,
      // Keeps the seeded primary close to the forum's accent; the default
      // tonal spot washes a saturated brand colour out.
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
    return scheme == null ? seeded : _pin(seeded, scheme);
  }

  static ColorScheme _pin(ColorScheme cs, DiscourseScheme s) {
    final bg = s.secondary;
    final fg = s.primary;
    if (contrastRatio(fg, bg) >= 4.5) {
      Color mix(double t) => Color.lerp(bg, fg, t)!;
      cs = cs.copyWith(
        surface: bg,
        onSurface: fg,
        surfaceContainerLowest: bg,
        surfaceContainerLow: mix(0.03),
        surfaceContainer: mix(0.06),
        surfaceContainerHigh: mix(0.09),
        surfaceContainerHighest: mix(0.12),
        onSurfaceVariant: readableOn(mix(0.7), bg),
        outline: mix(0.45),
        outlineVariant: mix(0.18),
        inverseSurface: fg,
        onInverseSurface: bg,
      );
      if (contrastRatio(fg, s.selected) >= 4.5) {
        cs = cs.copyWith(secondaryContainer: s.selected, onSecondaryContainer: fg);
      }
    }
    if (contrastRatio(s.tertiary, cs.surface) >= 3) {
      cs = cs.copyWith(
        primary: s.tertiary,
        onPrimary: _onColor(s.tertiary, preferred: s.secondary),
        surfaceTint: s.tertiary,
      );
    }
    if (contrastRatio(s.danger, cs.surface) >= 3) {
      cs = cs.copyWith(
        error: s.danger,
        onError: _onColor(s.danger, preferred: s.secondary),
      );
    }
    return cs;
  }

  /// Text for a fill of [fill]: [preferred] (Discourse puts `secondary` on
  /// its buttons) when it reads, else black or white, whichever reads better.
  static Color _onColor(Color fill, {required Color preferred}) {
    if (contrastRatio(preferred, fill) >= 4.5) return preferred;
    return contrastRatio(Colors.white, fill) >= contrastRatio(Colors.black, fill)
        ? Colors.white
        : Colors.black;
  }

  static ThemeData _build(ColorScheme colorScheme, ForumColors forumColors) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: [forumColors],
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: DesignTokens.elevationNone,
      ),
      cardTheme: StyleBuilders.cardTheme(
        colorScheme: colorScheme,
        elevation: DesignTokens.elevationMedium,
        borderRadius: DesignTokens.radiusM,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: StyleBuilders.elevatedButtonStyle(
          colorScheme: colorScheme,
          elevation: DesignTokens.elevationNone,
          borderRadius: DesignTokens.radiusS,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: StyleBuilders.textButtonStyle(
          colorScheme: colorScheme,
          borderRadius: DesignTokens.radiusS,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusS),
        ),
        contentPadding: DesignTokens.paddingInput,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        ),
        titleTextStyle: TextStyle(
          fontSize: DesignTokens.fontSizeL,
          fontWeight: DesignTokens.fontWeightBold,
          color: colorScheme.onSurface,
        ),
        contentTextStyle: TextStyle(
          fontSize: DesignTokens.fontSizeM,
          color: colorScheme.onSurface,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignTokens.radiusM),
          ),
        ),
      ),
    );
  }
}
