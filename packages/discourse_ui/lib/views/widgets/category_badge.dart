import 'package:discourse_core/discourse_core.dart'
    show DiscourseCategoryStyle, DiscourseSiteCapabilities;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_forum.dart';

import '../../theme/design_tokens.dart';
import '../../utils/discourse_color.dart';
import '../../utils/discourse_icons.dart';
import '../../utils/emoji_shortcodes.dart';
import '../../utils/html_colors.dart';
import '../forum_topics_page.dart';

/// A category as Discourse badges it everywhere: a small mark in the
/// category's colour — split with its parent's for a subcategory, or its
/// emoji when the category is styled that way — then its name.
///
/// One widget for every place a category is named (topic rows, the topic
/// page, search, pickers), so a category looks the same wherever it
/// appears. The colour is the category's own, nudged only as far as it
/// needs to show on the page (a near-black category on a dark screen).
/// "Uncategorized" draws nothing, as on the web. Tapping opens the
/// category, as the web's badge link does.
class CategoryBadge extends StatelessWidget {
  const CategoryBadge({
    super.key,
    required this.siteContext,
    required this.categoryId,
    this.fallbackName = '',
    this.large = false,
    this.tappable = true,
  });

  final SiteContext siteContext;
  final String categoryId;

  /// The name to show when the forum's categories are not known yet.
  final String fallbackName;

  /// The topic page's size; the default suits a list row.
  final bool large;
  final bool tappable;

  /// Whether a badge for [categoryId] draws anything.
  static bool shows(SiteContext siteContext, String categoryId,
      {String fallbackName = ''}) {
    final caps = DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl);
    if (caps.isUncategorized(categoryId)) return false;
    final name = caps.categoryStyleFor(categoryId)?.name ?? fallbackName.trim();
    return name.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (!shows(siteContext, categoryId, fallbackName: fallbackName)) {
      return const SizedBox.shrink();
    }
    final caps = DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl);
    final style = caps.categoryStyleFor(categoryId);
    final parentId = style?.parentId;
    final parent = parentId == null ? null : caps.categoryStyleFor('$parentId');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final badge = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CategoryMark(style: style, parent: parent, size: large ? 12 : 10),
        SizedBox(width: large ? 6 : 4),
        Flexible(
          child: Text(
            style?.name ?? fallbackName.trim(),
            style: (large ? textTheme.labelLarge : textTheme.labelMedium)?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
    if (!tappable) return badge;
    return InkWell(
      borderRadius: BorderRadius.circular(DesignTokens.radiusS),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ForumTopicsPage(
          siteContext: siteContext,
          forum: categoryForum(siteContext, categoryId, fallbackName: fallbackName),
        ),
      )),
      // 32dp high to tap (it was ~20).
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: badge,
      ),
    );
  }
}

/// The badge's mark: the category's colour as a square (half its
/// parent's, for a subcategory), or its emoji.
class CategoryMark extends StatelessWidget {
  const CategoryMark({super.key, this.style, this.parent, this.size = 10});

  final DiscourseCategoryStyle? style;
  final DiscourseCategoryStyle? parent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = this.style;
    if (style != null && style.styleType == 'emoji' && style.emoji != null) {
      final glyph = discourseEmojiChar(style.emoji!);
      if (glyph != null) {
        return Text(glyph, style: TextStyle(fontSize: size + 2, height: 1));
      }
    }
    final surface = Theme.of(context).colorScheme.surface;
    final outline = Theme.of(context).colorScheme.outline;
    Color tone(DiscourseCategoryStyle? s) => categoryMarkColor(
        parseDiscourseHex(s?.colorHex ?? '') ?? outline, surface);
    final own = tone(style);
    // An `icon` category names a Font Awesome icon: the closest Material
    // one in the category's colour, as the website draws it; one the app
    // has no match for keeps the square.
    if (style != null && style.styleType == 'icon') {
      final icon = materialIconForDiscourseIcon(style.icon);
      if (icon != null) return Icon(icon, size: size + 2, color: own);
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: parent == null ? own : null,
        gradient: parent == null
            ? null
            : LinearGradient(
                colors: [tone(parent), tone(parent), own, own],
                stops: const [0, 0.5, 0.5, 1],
              ),
      ),
    );
  }
}

/// A category colour as a small mark on [surface]: its own, moved only as
/// far as it takes to show (a near-black category on a dark screen).
Color categoryMarkColor(Color color, Color surface) =>
    readableOn(color, surface, minContrast: 1.8);

/// The category [id] as an [FCForum] to open, with its name, colours,
/// description and counts from the forum's `/site.json` — a category opened
/// from a badge, a link or the drawer then gets its full header.
FCForum categoryForum(SiteContext siteContext, String id,
    {String fallbackName = ''}) {
  final style = DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl)
      .categoryStyleFor(id);
  return FCForum(
    id: id,
    name: style?.name ?? fallbackName,
    // What its page's header shows, as a category opened from the list
    // would have it.
    description: style?.description,
    logoUrl: style?.logoUrl,
    backgroundUrl: style?.backgroundUrl,
    topicCount: style?.topicCount ?? 0,
    postCount: style?.postCount ?? 0,
    slug: style?.slug,
    parentId: style?.parentId?.toString(),
    color: style?.colorHex ?? '',
    textColor: style?.textColorHex ?? 'FFFFFF',
  );
}

/// The logo to draw for [forum], a category, on a light or [dark] page:
/// the dark-mode upload when the admin made one, else its logo. The
/// category's `/site.json` entry carries both; the list payload only one.
String? categoryLogoUrl(SiteContext siteContext, FCForum forum,
        {required bool dark}) =>
    DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl)
        .categoryStyleFor(forum.id)
        ?.logoFor(dark: dark) ??
    forum.logoUrl;

/// The background image for [forum] on a light or [dark] page, likewise.
String? categoryBackgroundUrl(SiteContext siteContext, FCForum forum,
        {required bool dark}) =>
    DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl)
        .categoryStyleFor(forum.id)
        ?.backgroundFor(dark: dark) ??
    forum.backgroundUrl;

