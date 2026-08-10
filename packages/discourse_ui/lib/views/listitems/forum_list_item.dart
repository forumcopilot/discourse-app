import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_forum.dart';
import 'package:discourse_ui/views/widgets/forum_actions.dart';
import 'package:discourse_ui/views/widgets/forum_icon_widget.dart';
import '../../theme/design_tokens.dart';
import '../../theme/style_builders.dart';

/// Parse a Discourse hex string like "BF1E2E" (no leading `#`) into a
/// Color. Returns null on bad input so the UI can hide the stripe.
Color? _parseDiscourseHex(String hex) {
  var clean = hex.replaceAll('#', '').trim();
  // Discourse stores whatever the admin typed, so 3-char shorthand is
  // common — `tech` on try.discourse.org is "444". Expand it rather than
  // dropping the colour, which is what made that category fall back to a
  // hashed tile.
  if (clean.length == 3) {
    clean = clean.split('').map((ch) => '$ch$ch').join();
  }
  if (clean.length != 6) return null;
  final v = int.tryParse(clean, radix: 16);
  if (v == null) return null;
  return Color(0xFF000000 | v);
}

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

  void _handleTap(BuildContext context) {
    if (forum.isProtected) {
      final forumActions = ForumActions();
      forumActions.enterProtectedForum(context, siteContext, forum);
    } else {
      onTap?.call();
    }
  }

  Widget _buildBottomDivider(ColorScheme colorScheme) {
    return Divider(
      height: 1,
      thickness: 1,
      color: colorScheme.outlineVariant
          .withValues(alpha: DesignTokens.opacityDivider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasDescription = forum.description != null && forum.description!.isNotEmpty;

    // Phase 5.41 — color + topic_count now live on FCForum directly
    // (was a DiscoursePostProxy.metaFor Expando sidecar that got lost
    // on tree rebuild). Empty color means the fetching endpoint didn't
    // include the field, so we skip the stripe + count badge.
    final colorHex = forum.color ?? '';
    // The category's own colour, used for the tile. There used to be a
    // 4px stripe down the left edge as well; it was originally meant to
    // signal unread, but Discourse's category payload carries no unread
    // count — that needs /u/{name}/topic-tracking-state.json and
    // client-side aggregation, which is not worth an extra request per
    // launch. Once the tile carried the real colour the stripe was just
    // the same colour twice, so it is gone.
    final categoryColor =
        colorHex.isNotEmpty ? _parseDiscourseHex(colorHex) : null;
    final topicCount = forum.topicCount;

    return Material(
      color: colorScheme.surface,
      child: InkWell(
        onTap: () => _handleTap(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: hasDescription
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                        children: [
                  ForumListItemIconWidget(
                    logoUrl: forum.logoUrl,
                    // The category's own colour, not a hash of its name.
                    // ForumListItemIconWidget falls back to
                    // AvatarColorUtils — fine for a person, wrong for a
                    // category, which has a colour the admin chose and
                    // which web shows as its swatch. Two different colours
                    // for one category (hashed tile, real stripe) read as
                    // two unrelated signals.
                    backgroundColor: categoryColor,
                    iconColor: categoryColor == null
                        ? null
                        : _parseDiscourseHex(forum.textColor ?? 'FFFFFF'),
                    fallbackIcon: Icons.forum_rounded,
                    forumName: forum.name,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                forum.name,
                                style: StyleBuilders.titleTextStyle(
                                  colorScheme: colorScheme,
                                  textTheme: textTheme,
                                  fontSize: DesignTokens.fontSizeTopicTitle,
                                  fontWeight: DesignTokens.fontWeightSemiBold,
                                ),
                              ),
                            ),
                            if (forum.isLinkForum)
                              Icon(
                                Icons.open_in_new,
                                size: DesignTokens.iconSizeS,
                                color: colorScheme.onSurfaceVariant,
                              ),
                          ],
                        ),
                        if (forum.description != null && forum.description!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            forum.description!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (topicCount > 0 || forum.childForums.isNotEmpty || forum.isProtected) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: DesignTokens.spacingS,
                            runSpacing: DesignTokens.spacingXS,
                            children: [
                              // Watching / tracking, as web marks on a
                              // category. FCForum flattens Discourse's
                              // five levels to a boolean (>= Tracking), so
                              // this is one icon rather than web's
                              // per-level glyph.
                              if (forum.isSubscribed) ...[
                                Icon(
                                  Icons.notifications_active_outlined,
                                  size: textTheme.bodySmall?.fontSize ?? 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                              ],
                              if (topicCount > 0)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: DesignTokens.spacingS,
                                    vertical: DesignTokens.spacingXS,
                                  ),
                                  decoration: StyleBuilders.badgeDecoration(
                                    colorScheme: colorScheme,
                                    backgroundColor: colorScheme
                                        .surfaceContainerHighest
                                        .withValues(alpha: DesignTokens.opacityMedium),
                                    borderRadius: DesignTokens.radiusM,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.forum_outlined,
                                        size: DesignTokens.iconSizeS,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(
                                          width: DesignTokens.spacingXS),
                                      Text(
                                        _formatCount(topicCount),
                                        style: StyleBuilders.smallTextStyle(
                                          colorScheme: colorScheme,
                                          textTheme: textTheme,
                                          color: colorScheme.onSurfaceVariant,
                                          fontWeight:
                                              DesignTokens.fontWeightMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if ((forum.childForums.length) != 0) ...[
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: DesignTokens.spacingS,
                                    vertical: DesignTokens.spacingXS,
                                  ),
                                  decoration: StyleBuilders.badgeDecoration(
                                    colorScheme: colorScheme,
                                    backgroundColor: colorScheme.surfaceVariant
                                        .withValues(alpha: DesignTokens.opacityMediumLow),
                                    borderRadius: DesignTokens.radiusM,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.folder_outlined,
                                        size: DesignTokens.iconSizeS,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: DesignTokens.spacingXS),
                                      Text(
                                        (forum.childForums.length).toString(),
                                        style: StyleBuilders.smallTextStyle(
                                          colorScheme: colorScheme,
                                          textTheme: textTheme,
                                          color: colorScheme.onSurfaceVariant,
                                          fontWeight: DesignTokens.fontWeightMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (forum.isProtected)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: DesignTokens.spacingS,
                                    vertical: DesignTokens.spacingXS,
                                  ),
                                  decoration: StyleBuilders.badgeDecoration(
                                    colorScheme: colorScheme,
                                    backgroundColor: colorScheme.errorContainer
                                        .withValues(alpha: DesignTokens.opacityMediumLow),
                                    borderRadius: DesignTokens.radiusM,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.lock_outline,
                                        size: DesignTokens.iconSizeS,
                                        color: colorScheme.onErrorContainer,
                                      ),
                                      const SizedBox(width: DesignTokens.spacingXS),
                                      Text(
                                        'Protected',
                                        style: StyleBuilders.smallTextStyle(
                                          colorScheme: colorScheme,
                                          textTheme: textTheme,
                                          color: colorScheme.onErrorContainer,
                                          fontWeight: DesignTokens.fontWeightMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
                  ), // close outer Expanded (Phase 5.17a stripe wrapper)
                ], // close outer Row children
              ), // close outer Row
            ), // close IntrinsicHeight
            _buildBottomDivider(colorScheme),
          ],
        ),
      ),
    );
  }
}
