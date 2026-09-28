import 'package:flutter/material.dart';

import '../utils/html_colors.dart';
import 'forum_palette.dart';

/// The Discourse colours Material's [ColorScheme] has no slot for, as the
/// forum defines them: the like heart ([love]), solved and success marks
/// ([success]), the new-post highlight ([highlight]), the web header's
/// own colours, and the forum's accent at full strength for its banner
/// ([brand]), where the app's balanced scheme keeps its containers muted.
///
/// Read with [ForumColors.of]. Values are already legible on the theme's
/// surface, so widgets can use them for icons and text directly.
@immutable
class ForumColors extends ThemeExtension<ForumColors> {
  const ForumColors({
    required this.love,
    required this.success,
    required this.highlight,
    required this.quaternary,
    required this.headerBackground,
    required this.headerPrimary,
    required this.brand,
    required this.onBrand,
  });

  final Color love;
  final Color success;
  final Color highlight;
  final Color quaternary;
  final Color headerBackground;
  final Color headerPrimary;

  /// The forum's accent as a full-strength container, and text on it: its
  /// banner, where the forum's identity belongs.
  final Color brand;
  final Color onBrand;

  /// From [scheme], with [love] (icons) and [success] (icons and text,
  /// "Solution") nudged until they read on [surface] — a forum's green can
  /// be too pale for a white page.
  ///
  /// [brand] and [onBrand] default to [scheme]'s accent at full strength,
  /// for a host's own theme that names none (ABDA's own screens).
  factory ForumColors.from(
    DiscourseScheme scheme, {
    required Color surface,
    Color? brand,
    Color? onBrand,
  }) {
    if (brand == null || onBrand == null) {
      final full = ColorScheme.fromSeed(
        seedColor: scheme.tertiary,
        brightness: surface.computeLuminance() < 0.18
            ? Brightness.dark
            : Brightness.light,
        dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
      );
      brand ??= full.primaryContainer;
      onBrand ??= full.onPrimaryContainer;
    }
    return ForumColors(
      love: readableOn(scheme.love, surface, minContrast: 3),
      success: readableOn(scheme.success, surface),
      highlight: scheme.highlight,
      quaternary: scheme.quaternary,
      headerBackground: scheme.headerBackground,
      headerPrimary: scheme.headerPrimary,
      brand: brand,
      onBrand: onBrand,
    );
  }

  /// The theme's forum colours; Discourse's stock ones when the theme
  /// carries none (a host's own theme, a test).
  static ForumColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<ForumColors>() ??
        ForumColors.from(DiscourseScheme.stock(theme.brightness),
            surface: theme.colorScheme.surface,
            brand: theme.colorScheme.primaryContainer,
            onBrand: theme.colorScheme.onPrimaryContainer);
  }

  @override
  ForumColors copyWith({
    Color? love,
    Color? success,
    Color? highlight,
    Color? quaternary,
    Color? headerBackground,
    Color? headerPrimary,
    Color? brand,
    Color? onBrand,
  }) =>
      ForumColors(
        love: love ?? this.love,
        success: success ?? this.success,
        highlight: highlight ?? this.highlight,
        quaternary: quaternary ?? this.quaternary,
        headerBackground: headerBackground ?? this.headerBackground,
        headerPrimary: headerPrimary ?? this.headerPrimary,
        brand: brand ?? this.brand,
        onBrand: onBrand ?? this.onBrand,
      );

  @override
  ForumColors lerp(ForumColors? other, double t) {
    if (other == null) return this;
    return ForumColors(
      love: Color.lerp(love, other.love, t)!,
      success: Color.lerp(success, other.success, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      quaternary: Color.lerp(quaternary, other.quaternary, t)!,
      headerBackground: Color.lerp(headerBackground, other.headerBackground, t)!,
      headerPrimary: Color.lerp(headerPrimary, other.headerPrimary, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      onBrand: Color.lerp(onBrand, other.onBrand, t)!,
    );
  }
}
