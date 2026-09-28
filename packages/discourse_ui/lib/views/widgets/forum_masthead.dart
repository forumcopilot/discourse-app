import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/results/fc_forum_result.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/forum_identity.dart';
import 'brand_image.dart';
import 'forum_icon_tile.dart';

/// The top of a forum's Home: the forum's own header, as its website draws
/// it, with the forum's name, one line about the forum, how active it is,
/// and a search field. A line in the forum's accent runs along the bottom.
///
/// The name is always on screen once: beside the icon in the bar, or, when
/// the bar shows the forum's logo instead, as the first line under it. A
/// logo may not say the name at all (Discourse Meta's is its speech bubble).
///
/// It collapses into the app bar as the page scrolls: the drawer button,
/// the forum's icon and name, and a search button, with the accent line
/// still under it, so the screen always says whose it is. The same pattern
/// as a host's own home (ABDA's ink top bar) and a category's page.
class ForumMasthead extends StatelessWidget {
  const ForumMasthead({
    super.key,
    required this.siteContext,
    required this.onSearch,
    this.boardStats,
    this.leading,
  });

  final SiteContext siteContext;

  /// Opens search; null while the forum is still loading.
  final VoidCallback? onSearch;
  final FCBoardStatResult? boardStats;

  /// In place of the drawer button the bar implies (a placeholder while
  /// the forum loads).
  final Widget? leading;

  static const toolbarHeight = 64.0;
  static const lineHeight = 3.0;
  static const searchHeight = 48.0;

  /// "1.9k active this month · 56.8k members · 18.5k topics", or null
  /// before the forum's stats have loaded.
  static String? statsLine(BuildContext context, FCBoardStatResult? stats) {
    if (stats == null || !stats.result) return null;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final compact = NumberFormat.compact(locale: locale);
    final parts = [
      if (stats.activeMembers > 0)
        l10n.countActiveThisMonth(compact.format(stats.activeMembers)),
      if (stats.totalMembers > 0)
        l10n.countMembers(
            stats.totalMembers, compact.format(stats.totalMembers)),
      if (stats.totalThreads > 0)
        l10n.countTopics(
            stats.totalThreads, compact.format(stats.totalThreads)),
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// The intro's height at the user's text size: the name when the bar
  /// shows a logo, the description and stats lines that exist, then the
  /// search field.
  static double _introHeight(BuildContext context, ForumIdentity identity,
      {required bool hasStats}) {
    final text = Theme.of(context).textTheme;
    final scaler = MediaQuery.textScalerOf(context);
    double line(TextStyle? s) =>
        (scaler.scale(s?.fontSize ?? 14) * (s?.height ?? 1.4) - 1e-6)
            .ceilToDouble();
    final hasDescription = identity.description != null;
    var h = 0.0;
    if (identity.wordmark != null) {
      h += line(text.titleLarge);
      if (hasDescription || hasStats) h += 2;
    }
    if (hasDescription) h += line(text.bodyMedium);
    if (hasStats) h += 2 + line(text.bodySmall);
    if (h > 0) h += 12;
    return h + searchHeight + 16;
  }

  /// How far the page scrolls before the header is down to its bar.
  static double collapseDistance(BuildContext context, SiteContext siteContext,
      FCBoardStatResult? boardStats) {
    final identity = ForumIdentity.of(context, siteContext.site);
    return _introHeight(context, identity,
        hasStats: statsLine(context, boardStats) != null);
  }

  @override
  Widget build(BuildContext context) {
    final identity = ForumIdentity.of(context, siteContext.site);
    final stats = statsLine(context, boardStats);
    final expanded = toolbarHeight +
        _introHeight(context, identity, hasStats: stats != null) +
        lineHeight;
    final overlay = identity.hasDarkBackground
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    return SliverAppBar(
      pinned: true,
      expandedHeight: expanded,
      toolbarHeight: toolbarHeight,
      backgroundColor: identity.background,
      foregroundColor: identity.foreground,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      systemOverlayStyle: overlay.copyWith(statusBarColor: Colors.transparent),
      titleSpacing: 4,
      leading: leading,
      title: _MastheadTitle(identity: identity),
      actions: [
        _CollapsedOnly(
          child: IconButton(
            tooltip: AppLocalizations.of(context)!.search,
            icon: const Icon(Icons.search),
            onPressed: onSearch,
          ),
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: _MastheadIntro(
        identity: identity,
        stats: stats,
        onSearch: onSearch,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(lineHeight),
        child: ColoredBox(
          color: identity.accent,
          child: const SizedBox(height: lineHeight, width: double.infinity),
        ),
      ),
    );
  }
}

/// How far the masthead has collapsed: 1 fully open, 0 down to its bar.
double _openness(BuildContext context) {
  final settings =
      context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
  if (settings == null) return 1;
  final range = settings.maxExtent - settings.minExtent;
  if (range <= 0) return 0;
  return ((settings.currentExtent - settings.minExtent) / range)
      .clamp(0.0, 1.0);
}

/// The forum's wordmark while the header is open, where there is room and
/// it has one drawn for this background; its icon and name once the header
/// has become the bar.
class _MastheadTitle extends StatelessWidget {
  const _MastheadTitle({required this.identity});

  final ForumIdentity identity;

  @override
  Widget build(BuildContext context) {
    final open = _openness(context) > 0.5;
    final wordmark = identity.wordmark;
    final Widget child;
    if (open && wordmark != null) {
      child = Semantics(
        key: const ValueKey('wordmark'),
        header: true,
        label: identity.name,
        child: ExcludeSemantics(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 36, maxWidth: 240),
            child: BrandImage(
              wordmark,
              height: 36,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              background: identity.background,
              designedFor: identity.wordmarkDesignedFor,
              fallback: (_) => _iconAndName(context),
            ),
          ),
        ),
      );
    } else {
      child = KeyedSubtree(
        key: const ValueKey('iconAndName'),
        child: _iconAndName(context),
      );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      layoutBuilder: (current, previous) => Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [...previous, if (current != null) current],
      ),
      child: child,
    );
  }

  Widget _iconAndName(BuildContext context) => Semantics(
        header: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ForumIconTile(name: identity.name, url: identity.icon, size: 28),
            const SizedBox(width: 12),
            Flexible(
              child: LayoutBuilder(
                builder: (context, constraints) => Text(
                  identity.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _nameStyle(context, constraints.maxWidth),
                ),
              ),
            ),
          ],
        ),
      );

  /// The name at title size, or a size down when that would cut it short
  /// ("Discussions on Python.org" in dark mode, where its wordmark is not
  /// shown).
  TextStyle? _nameStyle(BuildContext context, double width) {
    final text = Theme.of(context).textTheme;
    TextStyle? styled(TextStyle? s) =>
        s?.copyWith(color: identity.foreground, fontWeight: FontWeight.w500);
    final large = styled(text.titleLarge);
    final painter = TextPainter(
      text: TextSpan(text: identity.name, style: large),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final fits = !painter.didExceedMaxLines && painter.width <= width;
    painter.dispose();
    return fits ? large : styled(text.titleMedium);
  }
}

/// Shown only once the header has collapsed (the search button, which the
/// open header has as a field).
class _CollapsedOnly extends StatelessWidget {
  const _CollapsedOnly({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final shown = _openness(context) < 0.3;
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

/// The open header's lower half: the forum's name when the bar shows its
/// logo, a line about the forum, its stats and the search field. It sits between the toolbar and the accent line and is
/// clipped there, so on scroll it slides under the toolbar, fading.
class _MastheadIntro extends StatelessWidget {
  const _MastheadIntro({
    required this.identity,
    required this.stats,
    required this.onSearch,
  });

  final ForumIdentity identity;
  final String? stats;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    final t = _openness(context);
    final opacity = ((t - 0.3) / 0.7).clamp(0.0, 1.0);
    final hidden = opacity < 0.5;
    final text = Theme.of(context).textTheme;
    final fg = identity.foreground;
    final l10n = AppLocalizations.of(context)!;
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The bar's logo already names the forum to a screen reader.
          if (identity.wordmark != null) ...[
            ExcludeSemantics(
              child: Text(
                identity.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.titleLarge
                    ?.copyWith(color: fg, fontWeight: FontWeight.w600),
              ),
            ),
            if (identity.description != null || stats != null)
              const SizedBox(height: 2),
          ],
          if (identity.description != null)
            Text(
              identity.description!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  text.bodyMedium?.copyWith(color: fg.withValues(alpha: 0.8)),
            ),
          if (stats != null) ...[
            const SizedBox(height: 2),
            Text(
              stats!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall?.copyWith(color: fg.withValues(alpha: 0.7)),
            ),
          ],
          if (identity.wordmark != null ||
              identity.description != null ||
              stats != null)
            const SizedBox(height: 12),
          SizedBox(
            height: ForumMasthead.searchHeight,
            child: Semantics(
              button: true,
              child: Material(
                color: Color.alphaBlend(
                    fg.withValues(
                        alpha: identity.hasDarkBackground ? 0.12 : 0.06),
                    identity.background),
                shape: const StadiumBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onSearch,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(children: [
                      Icon(Icons.search, color: fg),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.searchForumName(identity.name),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyLarge
                              ?.copyWith(color: fg.withValues(alpha: 0.7)),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return Stack(children: [
      Positioned(
        top: MediaQuery.paddingOf(context).top + ForumMasthead.toolbarHeight,
        left: 0,
        right: 0,
        bottom: ForumMasthead.lineHeight,
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
