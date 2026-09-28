import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_forum.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../utils/discourse_color.dart';
import '../../utils/forum_navigation.dart';
import '../widgets/category_badge.dart' show categoryMarkColor;
import '../widgets/category_read_counts.dart';
import '../widgets/category_tile_mark.dart';

/// "15 new this week", or the category's topic count when the forum has not
/// said how its week went; null when there is nothing to say.
String? categoryActivityLine(
    BuildContext context, SiteContext siteContext, FCForum forum) {
  final l10n = AppLocalizations.of(context)!;
  final id = int.tryParse(forum.id);
  final week = id == null
      ? null
      : DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl)
          .topicsThisWeek[id];
  if (week != null && week > 0) return l10n.categoryNewThisWeek(week);
  if (forum.topicCount <= 0) return null;
  final compact = NumberFormat.compact(
      locale: Localizations.localeOf(context).toString());
  return l10n.countTopics(forum.topicCount, compact.format(forum.topicCount));
}

/// A category in the forum's Categories view: its own mark and name, how
/// active it is this week, two lines of description, and its subcategories
/// as small chips. A band of its colour runs down the left edge, as on
/// Discourse's category badges; a bell marks one you watch or track.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.siteContext,
    required this.forum,
    this.showSubcategories = true,
  });

  final SiteContext siteContext;
  final FCForum forum;
  final bool showSubcategories;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final style = DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl)
        .categoryStyleFor(forum.id);
    final color = categoryMarkColor(
      parseDiscourseHex(style?.colorHex ?? forum.color ?? '') ?? scheme.outline,
      scheme.surface,
    );
    final description = (forum.description?.trim().isNotEmpty ?? false)
        ? forum.description!.trim()
        : style?.description;
    final activity = categoryActivityLine(context, siteContext, forum);
    final subs = showSubcategories ? forum.childForums : const <FCForum>[];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => pushForumOrLinkForum(context, forum, siteContext),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: color, width: 4)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CategoryTileMark(
                        style: style,
                        size: 24,
                        fallbackColorHex: forum.color,
                        fallbackLogoUrl: forum.logoUrl,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          forum.name,
                          style: text.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (forum.isSubscribed) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.notifications_active_outlined,
                            size: 16, color: scheme.onSurfaceVariant),
                      ],
                      if (activity != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          activity,
                          style: text.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                  CategoryReadCounts(
                    siteContext: siteContext,
                    categoryId: forum.id,
                    padding: const EdgeInsets.only(top: 6),
                  ),
                  if (subs.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final sub in subs)
                          SubcategoryChip(siteContext: siteContext, forum: sub),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A subcategory as a small chip — its colour and name — that opens it.
/// 32dp tall to tap, so a tap meant for it does not open the card it
/// sits on.
class SubcategoryChip extends StatelessWidget {
  const SubcategoryChip({
    super.key,
    required this.siteContext,
    required this.forum,
    this.outlined = false,
  });

  final SiteContext siteContext;
  final FCForum forum;

  /// Drawn with an outline on the page rather than filled on a card.
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final style = DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl)
        .categoryStyleFor(forum.id);
    final color = categoryMarkColor(
      parseDiscourseHex(style?.colorHex ?? forum.color ?? '') ?? scheme.outline,
      scheme.surface,
    );
    final radius = BorderRadius.circular(8);
    return InkWell(
      borderRadius: radius,
      onTap: () => pushForumOrLinkForum(context, forum, siteContext),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: outlined ? null : scheme.surfaceContainerHigh,
            border: outlined ? Border.all(color: scheme.outlineVariant) : null,
            borderRadius: radius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  forum.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A parent category whose forum shows its subcategories as boxes (Asana
/// puts every category under one): a heading that opens the parent, above
/// its subcategories' own cards.
class CategorySectionHeading extends StatelessWidget {
  const CategorySectionHeading({
    super.key,
    required this.siteContext,
    required this.forum,
  });

  final SiteContext siteContext;
  final FCForum forum;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final activity = categoryActivityLine(context, siteContext, forum);
    return InkWell(
      onTap: () => pushForumOrLinkForum(context, forum, siteContext),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
        child: Row(
          children: [
            CategoryTileMark.forId(siteContext, forum.id,
                size: 20,
                fallbackColorHex: forum.color,
                fallbackLogoUrl: forum.logoUrl),
            const SizedBox(width: 10),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(forum.name,
                    style: text.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
            if (activity != null)
              Text(activity,
                  style:
                      text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
