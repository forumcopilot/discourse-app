import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_forum.dart';
import 'package:forumcopilot_sdk/models/entities/fc_notification_level.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../utils/discourse_color.dart';
import '../forum_topics_page.dart';
import 'brand_image.dart';
import 'category_badge.dart' show categoryForum, categoryMarkColor;
import 'category_tile_mark.dart';
import 'sheet_title.dart';
import '../../l10n/kit_strings.dart';

/// The top of a category's page, laid out like the forum's own header: where
/// it sits (the forum, and the parent for a subcategory), the category's own
/// mark and name, its notification level, two lines of description, and how
/// active it is — on a tint of its colour, with the colour itself as a line
/// along the bottom, as on Discourse's category badges.
///
/// A tint rather than a banner of the colour: category colours are picked
/// for small badges and are often bright, and a full banner either fails as
/// a background for text or has to be darkened into another colour. The
/// exact colour stays where it is recognised, in the mark and the line.
///
/// It collapses into the page's bar with the mark and name, the bell and
/// search; the line stays.
class CategoryMasthead extends StatelessWidget {
  const CategoryMasthead({
    super.key,
    required this.siteContext,
    required this.forum,
    required this.onSearch,
    this.level,
    this.onBell,
    this.menu,
  });

  final SiteContext siteContext;
  final FCForum forum;
  final VoidCallback onSearch;

  /// The reader's notification level for the category; null when unknown.
  final FCNotificationLevel? level;

  /// Opens the notification-level sheet; null hides the bell (a guest).
  final VoidCallback? onBell;

  /// The page's ⋮ menu, if it has one.
  final Widget? menu;

  static const toolbarHeight = 64.0;
  static const lineHeight = 4.0;

  static String levelLabel(AppLocalizations l10n, FCNotificationLevel level) =>
      switch (level) {
        FCNotificationLevel.watching => l10n.levelWatching,
        FCNotificationLevel.watchingFirstPost => l10n.levelWatchingFirstPost,
        FCNotificationLevel.tracking => l10n.levelTracking,
        FCNotificationLevel.normal => l10n.levelNormal,
        FCNotificationLevel.muted => l10n.levelMuted,
      };

  static IconData levelIcon(FCNotificationLevel? level) => switch (level) {
        FCNotificationLevel.watching ||
        FCNotificationLevel.watchingFirstPost =>
          Icons.notifications_active_outlined,
        FCNotificationLevel.tracking => Icons.notifications_outlined,
        FCNotificationLevel.muted => Icons.notifications_off_outlined,
        _ => Icons.notifications_none,
      };

  @override
  Widget build(BuildContext context) {
    final details = _CategoryDetails.of(context, siteContext, forum);
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tint = Color.lerp(scheme.surface, details.color, dark ? 0.16 : 0.12)!;
    final expanded = toolbarHeight + details.introHeight(context) + lineHeight;
    final l10n = AppLocalizations.of(context)!;
    return SliverAppBar(
      pinned: true,
      expandedHeight: expanded,
      toolbarHeight: toolbarHeight,
      backgroundColor: tint,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      title: _CollapsedTitle(siteContext: siteContext, details: details),
      actions: [
        if (onBell != null)
          _Collapsed(
            child: IconButton(
              tooltip: level == null ? null : levelLabel(l10n, level!),
              icon: Icon(levelIcon(level)),
              onPressed: onBell,
            ),
          ),
        IconButton(
          tooltip: l10n.kit.search,
          icon: const Icon(Icons.search),
          onPressed: onSearch,
        ),
        if (menu != null) menu!,
      ],
      flexibleSpace: _CategoryIntro(
        siteContext: siteContext,
        details: details,
        level: level,
        onBell: onBell,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(lineHeight),
        child: ColoredBox(
          color: details.color,
          child: const SizedBox(height: lineHeight, width: double.infinity),
        ),
      ),
    );
  }
}

/// What the header says about the category, from its `/site.json` entry
/// with the list's [FCForum] as the fallback.
class _CategoryDetails {
  _CategoryDetails({
    required this.forum,
    required this.color,
    required this.name,
    required this.description,
    required this.stats,
    required this.parent,
    required this.background,
  });

  factory _CategoryDetails.of(
      BuildContext context, SiteContext siteContext, FCForum forum) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final caps = DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl);
    final style = caps.categoryStyleFor(forum.id);
    final color = categoryMarkColor(
      parseDiscourseHex(style?.colorHex ?? forum.color ?? '') ?? scheme.outline,
      scheme.surface,
    );
    final description = (style?.description?.isNotEmpty ?? false)
        ? style!.description
        : ((forum.description?.trim().isNotEmpty ?? false)
            ? forum.description!.trim()
            : null);
    final id = int.tryParse(forum.id);
    final week = id == null ? null : caps.topicsThisWeek[id];
    final topics = (style?.topicCount ?? 0) > 0
        ? style!.topicCount
        : forum.topicCount;
    final compact = NumberFormat.compact(
        locale: Localizations.localeOf(context).toString());
    final stats = [
      if (week != null && week > 0) l10n.categoryNewThisWeek(week),
      if (topics > 0) l10n.countTopics(topics, compact.format(topics)),
    ].join(' · ');
    final parentId = style?.parentId ?? int.tryParse(forum.parentId ?? '');
    return _CategoryDetails(
      forum: forum,
      color: color,
      name: style?.name ?? forum.name,
      description: description,
      stats: stats.isEmpty ? null : stats,
      parent: parentId == null
          ? null
          : categoryForum(siteContext, '$parentId'),
      background: style?.backgroundFor(dark: dark) ?? forum.backgroundUrl,
    );
  }

  final FCForum forum;
  final Color color;
  final String name;
  final String? description;
  final String? stats;
  final FCForum? parent;
  final String? background;

  double introHeight(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scaler = MediaQuery.textScalerOf(context);
    double line(TextStyle? s) =>
        (scaler.scale(s?.fontSize ?? 14) * (s?.height ?? 1.4) - 1e-6)
            .ceilToDouble();
    var h = line(text.bodySmall) + 8; // breadcrumb
    h += (line(text.titleLarge) > 40 ? line(text.titleLarge) : 40) + 8;
    if (description != null) h += 2 * line(text.bodyMedium);
    if (stats != null) h += 6 + line(text.bodySmall);
    return h + 14;
  }
}

double _openness(BuildContext context) {
  final settings =
      context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
  if (settings == null) return 1;
  final range = settings.maxExtent - settings.minExtent;
  if (range <= 0) return 0;
  return ((settings.currentExtent - settings.minExtent) / range)
      .clamp(0.0, 1.0);
}

/// Shown only once the header has become the bar.
class _Collapsed extends StatelessWidget {
  const _Collapsed({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final shown = _openness(context) < 0.35;
    return AnimatedOpacity(
      opacity: shown ? 1 : 0,
      duration: const Duration(milliseconds: 150),
      child: ExcludeSemantics(
        excluding: !shown,
        child: IgnorePointer(ignoring: !shown, child: child),
      ),
    );
  }
}

/// The bar's title once the header has collapsed: the mark and the name.
class _CollapsedTitle extends StatelessWidget {
  const _CollapsedTitle({required this.siteContext, required this.details});

  final SiteContext siteContext;
  final _CategoryDetails details;

  @override
  Widget build(BuildContext context) {
    return _Collapsed(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CategoryTileMark.forId(siteContext, details.forum.id,
              size: 24,
              fallbackColorHex: details.forum.color,
              fallbackLogoUrl: details.forum.logoUrl),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              details.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

/// The open header: breadcrumb, mark and name with the bell, description
/// and stats, clipped between the bar and the line so it slides under the
/// bar as the page scrolls.
class _CategoryIntro extends StatelessWidget {
  const _CategoryIntro({
    required this.siteContext,
    required this.details,
    required this.level,
    required this.onBell,
  });

  final SiteContext siteContext;
  final _CategoryDetails details;
  final FCNotificationLevel? level;
  final VoidCallback? onBell;

  void _showDescription(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetTitle(details.name),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(details.description ?? '',
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = _openness(context);
    final opacity = ((t - 0.3) / 0.7).clamp(0.0, 1.0);
    final hidden = opacity < 0.5;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final parent = details.parent;
    final muted = text.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
    final crumb = Row(children: [
      Icon(Icons.forum_outlined, size: 16, color: scheme.onSurfaceVariant),
      const SizedBox(width: 6),
      Flexible(
        child: Text(siteContext.site.name,
            style: muted, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      if (parent != null) ...[
        Icon(Icons.chevron_right, size: 16, color: scheme.onSurfaceVariant),
        Flexible(
          child: InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    ForumTopicsPage(siteContext: siteContext, forum: parent))),
            child: Text(parent.name,
                style: muted?.copyWith(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    ]);

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          crumb,
          const SizedBox(height: 8),
          Row(children: [
            CategoryTileMark.forId(siteContext, details.forum.id,
                size: 40,
                fallbackColorHex: details.forum.color,
                fallbackLogoUrl: details.forum.logoUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(details.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w500)),
              ),
            ),
            if (onBell != null) ...[
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onBell,
                style: OutlinedButton.styleFrom(
                  backgroundColor: scheme.surface,
                  visualDensity: VisualDensity.compact,
                ),
                icon: Icon(CategoryMasthead.levelIcon(level), size: 18),
                label: Text(level == null
                    ? l10n.levelNormal
                    : CategoryMasthead.levelLabel(l10n, level!)),
              ),
            ],
          ]),
          const SizedBox(height: 8),
          if (details.description != null)
            GestureDetector(
              onTap: () => _showDescription(context),
              child: Text(details.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant)),
            ),
          if (details.stats != null) ...[
            const SizedBox(height: 6),
            Text(details.stats!, style: muted, maxLines: 1),
          ],
        ],
      ),
    );

    final background = details.background;
    return Stack(children: [
      if (background != null && background.isNotEmpty)
        Positioned.fill(
          child: Opacity(
            opacity: opacity,
            child: Stack(fit: StackFit.expand, children: [
              BrandImage(background,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  fallback: (_) => const SizedBox.shrink()),
              // A veil of the page, so the text reads on any photo.
              ColoredBox(color: scheme.surface.withValues(alpha: 0.82)),
            ]),
          ),
        ),
      Positioned(
        top: MediaQuery.paddingOf(context).top + CategoryMasthead.toolbarHeight,
        left: 0,
        right: 0,
        bottom: CategoryMasthead.lineHeight,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.bottomCenter,
            minHeight: 0,
            maxHeight: double.infinity,
            child: Opacity(
              opacity: opacity,
              child: IgnorePointer(
                ignoring: hidden,
                child: ExcludeSemantics(excluding: hidden, child: content),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}
