import 'package:discourse_core/discourse_core.dart'
    show DiscourseCategoryStyle, DiscourseSiteCapabilities;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../utils/discourse_color.dart';
import '../../utils/discourse_icons.dart';
import '../../utils/emoji_shortcodes.dart';
import '../../utils/html_colors.dart';
import 'brand_image.dart';
import 'category_badge.dart' show categoryMarkColor;

/// A category's mark as a tile, the way the forum set it up: its uploaded
/// logo, else its icon or emoji (Discourse's category styles), else a plain
/// square in its colour — at 20dp in the drawer, 24dp on a card or in a
/// collapsed bar, 40dp in the category's header.
///
/// Every kind is the same rounded square (corners 28% of the side), so a
/// list of categories reads evenly whatever each one chose. The small badge
/// on topic rows is [CategoryMark]; this is its larger sibling.
class CategoryTileMark extends StatelessWidget {
  const CategoryTileMark({
    super.key,
    required this.style,
    this.size = 24,
    this.fallbackColorHex,
    this.fallbackLogoUrl,
  });

  /// Looks the category up by [categoryId] in the forum's `/site.json`.
  factory CategoryTileMark.forId(
    SiteContext siteContext,
    String categoryId, {
    Key? key,
    double size = 24,
    String? fallbackColorHex,
    String? fallbackLogoUrl,
  }) =>
      CategoryTileMark(
        key: key,
        style: DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl)
            .categoryStyleFor(categoryId),
        size: size,
        fallbackColorHex: fallbackColorHex,
        fallbackLogoUrl: fallbackLogoUrl,
      );

  final DiscourseCategoryStyle? style;
  final double size;

  /// The colour and logo to use when [style] is unknown (a category the
  /// forum's `/site.json` has not described yet).
  final String? fallbackColorHex;
  final String? fallbackLogoUrl;

  static const cornerRatio = 0.28;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(size * cornerRatio);
    final style = this.style;
    final color = categoryMarkColor(
      parseDiscourseHex(style?.colorHex ?? fallbackColorHex ?? '') ??
          scheme.outline,
      scheme.surface,
    );

    Widget square() => DecoratedBox(
          decoration: BoxDecoration(color: color, borderRadius: radius),
          child: SizedBox.square(dimension: size),
        );

    final logo = style?.logoFor(dark: dark) ?? fallbackLogoUrl;
    if (logo != null && logo.isNotEmpty) {
      // Logos are artwork of their own; a transparent one sits on white,
      // as it was drawn to, so it reads on a dark page too.
      return ClipRRect(
        borderRadius: radius,
        child: Container(
          width: size,
          height: size,
          color: Colors.white,
          foregroundDecoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: BrandImage(
            logo,
            width: size,
            height: size,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            fallback: (_) => square(),
          ),
        ),
      );
    }

    if (style?.styleType == 'emoji' && style?.emoji != null) {
      final glyph = discourseEmojiChar(style!.emoji!);
      if (glyph != null) {
        // An emoji brings its own colours: a tint, not a solid square.
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color.lerp(scheme.surface, color, dark ? 0.28 : 0.18),
            borderRadius: radius,
          ),
          child: Text(
            glyph,
            textScaler: TextScaler.noScaling,
            style: TextStyle(fontSize: size * 0.62, height: 1),
          ),
        );
      }
    }

    if (style?.styleType == 'icon') {
      final icon = materialIconForDiscourseIcon(style?.icon);
      if (icon != null) {
        // The category's own text colour, which Discourse picks to read on
        // its colour, when it does; else white or black.
        final preferred = parseDiscourseHex(style?.textColorHex ?? '');
        final onColor = preferred != null && contrastRatio(preferred, color) >= 3
            ? preferred
            : (contrastRatio(Colors.white, color) >=
                    contrastRatio(Colors.black, color)
                ? Colors.white
                : Colors.black);
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, borderRadius: radius),
          child: Icon(icon, size: size * 0.62, color: onColor),
        );
      }
    }

    return square();
  }
}
