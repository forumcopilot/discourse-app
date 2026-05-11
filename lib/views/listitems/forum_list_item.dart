import 'package:discourse_core/discourse_core.dart' show DiscourseForumProxy;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_forum.dart';
import 'package:forumcopilot_flutter/views/widgets/forum_actions.dart';
import 'package:forumcopilot_flutter/views/widgets/forum_icon_widget.dart';
import '../../theme/design_tokens.dart';
import '../../theme/style_builders.dart';

/// Parse a Discourse hex string like "BF1E2E" (no leading `#`) into a
/// Color. Returns null on bad input so the UI can hide the stripe.
Color? _parseDiscourseHex(String hex) {
  final clean = hex.replaceAll('#', '').trim();
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
      color: colorScheme.outlineVariant.withOpacity(0.3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasDescription = forum.description != null && forum.description!.isNotEmpty;

    // Discourse-only sidecar with color + topic_count. Null on non-
    // Discourse forums; in that case we skip the stripe + count badge.
    final meta = DiscourseForumProxy.metaFor(forum);
    final stripeColor =
        (meta != null && meta.color.isNotEmpty) ? _parseDiscourseHex(meta.color) : null;
    final topicCount = meta?.topicCount ?? 0;

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
                  // 4px Discourse-category color stripe down the left
                  // edge. Hidden on non-Discourse forums (stripeColor
                  // null), and on Discourse forums where the color
                  // field is absent from the response.
                  if (stripeColor != null)
                    Container(width: 4, color: stripeColor),
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
                                        .withOpacity(0.6),
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
                                    backgroundColor: colorScheme.surfaceVariant.withOpacity(0.5),
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
                                    backgroundColor: colorScheme.errorContainer.withOpacity(0.5),
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
