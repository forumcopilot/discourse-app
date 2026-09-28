import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_forum.dart';
import 'package:discourse_ui/views/widgets/forum_icon_widget.dart';
import '../../theme/design_tokens.dart';
import '../../utils/discourse_color.dart';
import '../../l10n/generated/app_localizations.dart';
import '../widgets/category_badge.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities, DiscourseTopicCounts, DiscourseTopicTracking;

/// Parse a Discourse hex string like "BF1E2E" (no leading `#`) into a
/// Color. Returns null on bad input so the UI can hide the stripe.

/// Compact integer for badges: 1,234 → "1.2k", 12,345 → "12k".
String _formatCount(int n) {
  if (n < 1000) return n.toString();
  if (n < 10000) return '${(n / 1000).toStringAsFixed(1)}k';
  return '${(n / 1000).floor()}k';
}

class ForumListItem extends StatelessWidget {
  final FCForum forum;
  final SiteContext siteContext;
  final VoidCallback? onTap;
  final Function(bool)? onSubscriptionChanged;

  const ForumListItem({
    Key? key,
    required this.siteContext,
    required this.forum,
    this.onTap,
    this.onSubscriptionChanged,
  }) : super(key: key);

  // A read-restricted category is one the server already let this user
  // see (it is in /site.json), so it opens like any other. The lock badge
  // stays as information.
  void _handleTap(BuildContext context) => onTap?.call();

  @override
  Widget build(BuildContext context) {
    final categoryId = int.tryParse(forum.id);
    if (!siteContext.isLoggedIn || categoryId == null) {
      return _buildRow(context, null);
    }
    // "3 new · 2 unread", counted over the category and its subcategories
    // as web's categories page does, from the viewer's tracking report.
    final tracking = DiscourseTopicTracking.forSite(siteContext);
    final ids = DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl)
        .categoryWithDescendants(categoryId);
    return ListenableBuilder(
      listenable: tracking,
      builder: (context, _) =>
          _buildRow(context, tracking.counts(categoryIds: ids)),
    );
  }

  Widget _buildRow(BuildContext context, DiscourseTopicCounts? counts) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final newTopics = counts?.newTopics ?? 0;
    final unreadTopics = counts?.unreadTopics ?? 0;
    final hasDescription = forum.description != null && forum.description!.isNotEmpty;

    // Phase 5.41 — color + topic_count now live on FCForum directly
    // (was a DiscoursePostProxy.metaFor Expando sidecar that got lost
    // on tree rebuild). Empty color means the fetching endpoint didn't
    // include the field, so we skip the stripe + count badge.
    final colorHex = forum.color ?? '';
    // The category's own colour, used for the tile. There used to be a
    // 4px stripe down the left edge as well, meant to signal unread; the
    // category payload carries no unread count, so it only ever repeated
    // the colour. The counts now come from the viewer's tracking report
    // (see build) and are spelled out in the meta line.
    final categoryColor =
        colorHex.isNotEmpty ? parseDiscourseHex(colorHex) : null;
    final topicCount = forum.topicCount;

    final metaColor = colorScheme.onSurfaceVariant;
    final metaStyle = textTheme.bodySmall?.copyWith(color: metaColor);
    Widget meta(IconData icon, String? text, {Color? color}) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: DesignTokens.iconSizeS, color: color ?? metaColor),
            if (text != null) ...[
              const SizedBox(width: DesignTokens.spacingXS),
              Text(text, style: metaStyle?.copyWith(color: color)),
            ],
          ],
        );

    // The app's list row: 40dp leading tile in the category's colour, the
    // name as the headline, the description, then a meta line like the
    // topic rows' — instead of 56dp tiles, 16sp w600 names and tonal count
    // pills at 92–140dp a row.
    return Material(
      color: colorScheme.surface,
      child: InkWell(
        onTap: () => _handleTap(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.spacingL,
                DesignTokens.spacingM,
                DesignTokens.spacingL,
                DesignTokens.spacingM,
              ),
              child: Row(
                crossAxisAlignment: hasDescription
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  ForumListItemIconWidget(
                    logoUrl: categoryLogoUrl(siteContext, forum,
                        dark: Theme.of(context).brightness == Brightness.dark),
                    // The category's own colour, not a hash of its name:
                    // a category has a colour its admin chose, which web
                    // shows as its swatch.
                    backgroundColor: categoryColor,
                    iconColor: categoryColor == null
                        ? null
                        : parseDiscourseHex(forum.textColor ?? 'FFFFFF'),
                    fallbackIcon: Icons.forum_rounded,
                    forumName: forum.name,
                    size: 40,
                  ),
                  const SizedBox(width: DesignTokens.spacingL),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                forum.name,
                                style: textTheme.titleMedium,
                              ),
                            ),
                            if (forum.isLinkForum)
                              Icon(
                                Icons.open_in_new,
                                size: DesignTokens.iconSizeS,
                                color: metaColor,
                              ),
                          ],
                        ),
                        if (hasDescription) ...[
                          const SizedBox(height: DesignTokens.spacingXS),
                          Text(
                            forum.description!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: metaColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (topicCount > 0 ||
                            newTopics > 0 ||
                            unreadTopics > 0 ||
                            forum.childForums.isNotEmpty ||
                            forum.isProtected ||
                            forum.isSubscribed) ...[
                          const SizedBox(height: DesignTokens.spacingXS),
                          Wrap(
                            spacing: DesignTokens.spacingM,
                            runSpacing: DesignTokens.spacingXS,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (topicCount > 0)
                                meta(Icons.forum_outlined,
                                    _formatCount(topicCount)),
                              // In the accent, as web's category list
                              // links them to the category's New and
                              // Unread.
                              if (newTopics > 0)
                                Text(
                                  AppLocalizations.of(context)!
                                      .categoryNewTopics(newTopics),
                                  style: metaStyle?.copyWith(
                                      color: colorScheme.primary),
                                ),
                              if (unreadTopics > 0)
                                Text(
                                  AppLocalizations.of(context)!
                                      .categoryUnreadTopics(unreadTopics),
                                  style: metaStyle?.copyWith(
                                      color: colorScheme.primary),
                                ),
                              if (forum.childForums.isNotEmpty)
                                meta(Icons.folder_outlined,
                                    forum.childForums.length.toString()),
                              // Watching / tracking, as web marks on a
                              // category. FCForum flattens Discourse's
                              // five levels to a boolean (>= Tracking), so
                              // this is one icon rather than web's
                              // per-level glyph.
                              if (forum.isSubscribed)
                                meta(Icons.notifications_active_outlined,
                                    null),
                              if (forum.isProtected)
                                meta(Icons.lock_outline,
                                    AppLocalizations.of(context)!.protected,
                                    color: colorScheme.error),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              indent: 72,
              color: colorScheme.outlineVariant,
            ),
          ],
        ),
      ),
    );
  }
}
