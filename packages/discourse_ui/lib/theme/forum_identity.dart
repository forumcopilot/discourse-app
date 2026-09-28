import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/models/domain/site.dart';

import '../utils/discourse_color.dart';
import '../utils/html_colors.dart';
import 'forum_colors.dart';

/// How a forum presents itself at the top of its screens: the header its
/// website draws, in the current mode.
///
/// The background and text are the forum's own header colours for this
/// mode (from its colour scheme, [ForumColors]). The wordmark is shown only
/// on the kind of background it was drawn for — light-mode logos on light
/// headers, the forum's dark-mode logo on dark ones — and otherwise the
/// forum's square icon and name stand in, so no logo ever needs a plate or
/// an inverted copy.
@immutable
class ForumIdentity {
  const ForumIdentity({
    required this.name,
    required this.background,
    required this.foreground,
    required this.accent,
    this.description,
    this.wordmark,
    this.wordmarkDesignedFor = Colors.white,
    this.icon,
  });

  factory ForumIdentity.of(BuildContext context, Site site) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final colors = ForumColors.of(context);
    final caps = DiscourseSiteCapabilities.forSite(site.pluginUrl);

    final background = colors.headerBackground;
    var foreground = colors.headerPrimary;
    if (contrastRatio(foreground, background) < 4.5) {
      foreground = contrastRatio(Colors.white, background) >=
              contrastRatio(Colors.black, background)
          ? Colors.white
          : Colors.black;
    }

    // What the forum's light-mode logos were drawn on: its light header,
    // white on the stock scheme.
    final lightHeader =
        parseDiscourseHex(caps.headerBackgroundFor(dark: false) ?? '') ??
            Colors.white;
    bool isDarkColour(Color c) => c.computeLuminance() < 0.2;

    String? wordmark;
    var designedFor = lightHeader;
    final configured = site.logoUrl;
    if (configured != null && configured.isNotEmpty) {
      // A fork's hardcoded logo is its own choice, drawn for its header.
      wordmark = configured;
      designedFor = background;
    } else if (dark && caps.hasDarkLogo) {
      wordmark = caps.wideLogoFor(dark: true);
      designedFor = background;
    } else if (isDarkColour(lightHeader) == isDarkColour(background)) {
      wordmark = caps.wideLogoFor(dark: false);
    }

    final description = site.description.trim();
    return ForumIdentity(
      name: site.name,
      description: description.isEmpty ? null : description,
      background: background,
      foreground: foreground,
      accent: colors.brand,
      wordmark: (wordmark == null || wordmark.isEmpty) ? null : wordmark,
      wordmarkDesignedFor: designedFor,
      icon: caps.logoFor(dark: dark),
    );
  }

  final String name;
  final String? description;
  final Color background;
  final Color foreground;

  /// The forum's accent at full strength: the line under its header.
  final Color accent;

  /// The wide logo to show, or null for the icon and name.
  final String? wordmark;
  final Color wordmarkDesignedFor;

  /// The forum's square logo (`logo_small`), or null.
  final String? icon;

  bool get hasDarkBackground =>
      ThemeData.estimateBrightnessForColor(background) == Brightness.dark;
}
