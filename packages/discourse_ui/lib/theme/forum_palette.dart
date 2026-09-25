import 'package:flutter/material.dart';

import '../utils/discourse_color.dart';

/// One Discourse colour scheme: the twelve base colours every palette
/// defines (`ColorScheme::BASE_COLORS` in the Discourse source).
///
/// On the web, `primary` is the text colour, `secondary` the background,
/// `tertiary` the accent (links, primary buttons), `quaternary` the
/// navigation accent, and the rest are named for their one job.
@immutable
class DiscourseScheme {
  const DiscourseScheme({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.quaternary,
    required this.headerBackground,
    required this.headerPrimary,
    required this.highlight,
    required this.selected,
    required this.hover,
    required this.danger,
    required this.success,
    required this.love,
  });

  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color quaternary;
  final Color headerBackground;
  final Color headerPrimary;
  final Color highlight;
  final Color selected;
  final Color hover;
  final Color danger;
  final Color success;
  final Color love;

  /// Discourse's stock "Light" — what a forum shows when `/site.json`
  /// names no light scheme (`common/foundation/colors.scss`).
  static const light = DiscourseScheme(
    primary: Color(0xFF222222),
    secondary: Color(0xFFFFFFFF),
    tertiary: Color(0xFF0088CC),
    quaternary: Color(0xFFE45735),
    headerBackground: Color(0xFFFFFFFF),
    headerPrimary: Color(0xFF333333),
    highlight: Color(0xFFFFFF4D),
    selected: Color(0xFFD1F0FF),
    hover: Color(0xFFF2F2F2),
    danger: Color(0xFFC80001),
    success: Color(0xFF009900),
    love: Color(0xFFFA6C8D),
  );

  /// Discourse's built-in "Dark" (`ColorScheme::BUILT_IN_SCHEMES[:Dark]`).
  static const dark = DiscourseScheme(
    primary: Color(0xFFDDDDDD),
    secondary: Color(0xFF222222),
    tertiary: Color(0xFF099DD7),
    quaternary: Color(0xFFC14924),
    headerBackground: Color(0xFF111111),
    headerPrimary: Color(0xFFDDDDDD),
    highlight: Color(0xFFA87137),
    selected: Color(0xFF052E3D),
    hover: Color(0xFF313131),
    danger: Color(0xFFE45735),
    success: Color(0xFF1CA551),
    love: Color(0xFFFA6C8D),
  );

  /// The stock scheme for [brightness].
  static DiscourseScheme stock(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  /// Builds a scheme from `{name: hex}` as `/site.json` gives it. A colour
  /// that is missing or malformed comes from [fallback] — `/site.json`
  /// resolves the base colours itself, so this only guards a payload we
  /// did not expect.
  factory DiscourseScheme.fromHex(
    Map<String, String> hex, {
    DiscourseScheme fallback = DiscourseScheme.light,
  }) {
    Color pick(String name, Color otherwise) =>
        parseDiscourseHex(hex[name] ?? '') ?? otherwise;
    return DiscourseScheme(
      primary: pick('primary', fallback.primary),
      secondary: pick('secondary', fallback.secondary),
      tertiary: pick('tertiary', fallback.tertiary),
      quaternary: pick('quaternary', fallback.quaternary),
      headerBackground: pick('header_background', fallback.headerBackground),
      headerPrimary: pick('header_primary', fallback.headerPrimary),
      highlight: pick('highlight', fallback.highlight),
      selected: pick('selected', fallback.selected),
      hover: pick('hover', fallback.hover),
      danger: pick('danger', fallback.danger),
      success: pick('success', fallback.success),
      love: pick('love', fallback.love),
    );
  }

  /// Dark when the text is brighter than the background — Discourse's own
  /// test (`ColorScheme#is_dark?`), which is why a forum's "light" default
  /// can be a dark scheme.
  bool get isDark => primary.computeLuminance() > secondary.computeLuminance();

  Map<String, String> toHex() => {
        'primary': _hex(primary),
        'secondary': _hex(secondary),
        'tertiary': _hex(tertiary),
        'quaternary': _hex(quaternary),
        'header_background': _hex(headerBackground),
        'header_primary': _hex(headerPrimary),
        'highlight': _hex(highlight),
        'selected': _hex(selected),
        'hover': _hex(hover),
        'danger': _hex(danger),
        'success': _hex(success),
        'love': _hex(love),
      };

  static String _hex(Color c) =>
      (c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0');

  @override
  bool operator ==(Object other) =>
      other is DiscourseScheme && _mapEquals(toHex(), other.toHex());

  @override
  int get hashCode => Object.hashAll(toHex().values);
}

/// A forum's colours: its default light and dark Discourse schemes, as
/// `/site.json` gives them.
@immutable
class ForumPalette {
  const ForumPalette({this.light, this.dark});

  /// The forum's light default, or null for the stock Discourse "Light".
  final DiscourseScheme? light;

  /// The forum's dark default, or null when the forum has no dark mode.
  final DiscourseScheme? dark;

  /// From the `{name: hex}` maps `DiscourseSiteCapabilities` keeps.
  factory ForumPalette.fromHex({
    Map<String, String>? light,
    Map<String, String>? dark,
  }) =>
      ForumPalette(
        light: light == null ? null : DiscourseScheme.fromHex(light),
        dark: dark == null
            ? null
            : DiscourseScheme.fromHex(dark, fallback: DiscourseScheme.dark),
      );

  /// The forum's own scheme for [brightness], or null when it has none.
  ///
  /// Matched on what each scheme *is*, not which slot it came in: a forum
  /// whose default is a dark scheme and that sets no dark one is a
  /// dark-only forum, and in the app's light mode it has no light scheme.
  DiscourseScheme? schemeFor(Brightness brightness) {
    final wantDark = brightness == Brightness.dark;
    for (final s in [light ?? DiscourseScheme.light, if (dark != null) dark!]) {
      if (s.isDark == wantDark) return s;
    }
    return null;
  }

  /// The forum's accent — what a scheme it lacks is derived from.
  Color get accent => (light ?? dark ?? DiscourseScheme.light).tertiary;

  Map<String, Object?> toJson() => {
        'light': light?.toHex(),
        'dark': dark?.toHex(),
      };

  static ForumPalette? fromJson(Object? json) {
    if (json is! Map) return null;
    Map<String, String>? hex(Object? m) => m is Map
        ? m.map((k, v) => MapEntry(k.toString(), v.toString()))
        : null;
    return ForumPalette.fromHex(light: hex(json['light']), dark: hex(json['dark']));
  }

  @override
  bool operator ==(Object other) =>
      other is ForumPalette && other.light == light && other.dark == dark;

  @override
  int get hashCode => Object.hash(light, dark);
}

bool _mapEquals(Map<String, String> a, Map<String, String> b) {
  if (a.length != b.length) return false;
  for (final e in a.entries) {
    if (b[e.key] != e.value) return false;
  }
  return true;
}
