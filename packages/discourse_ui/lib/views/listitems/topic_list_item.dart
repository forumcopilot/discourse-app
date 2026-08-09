import 'package:flutter/material.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';
import 'package:discourse_ui/utils/time_utils.dart';
import 'package:discourse_ui/utils/number_utils.dart';
import 'package:discourse_ui/views/widgets/user_avatar.dart';
import 'package:discourse_ui/views/tag_topics_page.dart';
import '../../theme/design_tokens.dart';
import '../../theme/style_builders.dart';

/// Widget para representar un ítem de la lista de foros
class TopicListItem extends StatelessWidget {
  final SiteContext siteContext;
  final FCTopic topic;
  final VoidCallback? onTap;
  final IconData? topicIcon;
  final Function(String topicId)? onMarkAsRead;

  const TopicListItem({
    super.key,
    required this.siteContext,
    required this.topic,
    required this.onTap,
    this.topicIcon,
    this.onMarkAsRead,
  });

  void _handleTap() {
    // Mark as read immediately when tapped if the topic has new posts
    if (topic.hasNewPosts && onMarkAsRead != null) {
      onMarkAsRead!(topic.id);
    }
    // Call the original onTap callback
    onTap?.call();
  }

  Widget _buildBottomDivider(ColorScheme colorScheme) {
    return Divider(
      height: 1,
      thickness: 1,
      color: colorScheme.outlineVariant.withValues(alpha: DesignTokens.opacityLow),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surface,
      child: InkWell(
        onTap: _handleTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with avatar, username, and timestamp
            Padding(
              padding: EdgeInsets.all(DesignTokens.spacingL),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  UserAvatar(
                    username: topic.authorName,
                    iconUrl: topic.authorIconUrl,
                    radius: 20,
                  ),
                  SizedBox(width: DesignTokens.spacingL),
                  // Author info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.authorName.isNotEmpty ? topic.authorName : "Unknown",
                          style: textTheme.titleMedium?.copyWith(
                            color: topic.hasNewPosts ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                            fontWeight: topic.hasNewPosts ? DesignTokens.fontWeightSemiBold : DesignTokens.fontWeightMedium,
                            letterSpacing: DesignTokens.letterSpacingMedium,
                          ),
                        ),
                        if (topic.timestamp != DateTime.fromMillisecondsSinceEpoch(0)) ...[
                          SizedBox(height: DesignTokens.spacingXS),
                          Text(
                            formatSmartDateTime(topic.timestamp, context),
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: DesignTokens.letterSpacingWide,
                            ),
                          ),
                        ],
                        // "alice replied 3 hours ago" — web leads its rows
                        // with this because on a busy list the last voice is
                        // the reason to open a topic, and the person who
                        // started it usually is not. Null until someone has
                        // actually replied, so the opening post is never
                        // described as a reply to itself.
                        if (topic.lastPosterName != null &&
                            topic.lastPostedAt != null) ...[
                          SizedBox(height: DesignTokens.spacingXS),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              UserAvatar(
                                username: topic.lastPosterName!,
                                iconUrl: topic.lastPosterIconUrl,
                                radius: 8,
                              ),
                              SizedBox(width: DesignTokens.spacingXS),
                              Flexible(
                                child: Text(
                                  AppLocalizations.of(context)
                                          ?.topicLastReplyBy(
                                        topic.lastPosterName!,
                                        formatSmartDateTime(
                                            topic.lastPostedAt!, context),
                                      ) ??
                                      '${topic.lastPosterName} replied '
                                          '${formatSmartDateTime(topic.lastPostedAt!, context)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    letterSpacing:
                                        DesignTokens.letterSpacingWide,
                                  ),
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
            // Title row with badges (on its own line)
            Padding(
              padding: EdgeInsets.fromLTRB(DesignTokens.spacingL, 0.0, DesignTokens.spacingL, DesignTokens.spacingS),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (topic.hasNewPosts) ...[
                    // Phase 5.47 — when the server tells us how many
                    // posts are unread, show the count; otherwise fall
                    // back to the plain new-posts dot.
                    if (topic.unreadCount > 0)
                      Container(
                        margin: EdgeInsets.only(
                          top: DesignTokens.spacingXS,
                          right: DesignTokens.spacingS,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius:
                              BorderRadius.circular(DesignTokens.radiusM),
                        ),
                        child: Text(
                          topic.unreadCount > 99
                              ? '99+'
                              : '${topic.unreadCount}',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: DesignTokens.fontWeightSemiBold,
                            fontSize: DesignTokens.fontSizeXS - 1,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(
                          top: DesignTokens.spacingM - DesignTokens.spacingXS,
                          right: DesignTokens.spacingS,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                  if (topic.isDeleted) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacingM - DesignTokens.spacingXS,
                        vertical: DesignTokens.spacingXS / 2,
                      ),
                      decoration: StyleBuilders.badgeDecoration(
                        colorScheme: colorScheme,
                        backgroundColor: colorScheme.outline.withValues(alpha: DesignTokens.opacityLow),
                        borderRadius: DesignTokens.radiusS,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: DesignTokens.fontSizeXS,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: DesignTokens.spacingXS),
                          Text(
                            'DELETED',
                            style: StyleBuilders.smallTextStyle(
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: DesignTokens.fontWeightBold,
                            ).copyWith(fontSize: DesignTokens.fontSizeXS - 2),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: DesignTokens.spacingS),
                  ],
                  Expanded(
                    child: Text(
                      topic.title,
                      style: StyleBuilders.titleTextStyle(
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        fontSize: DesignTokens.fontSizeTopicTitle,
                        fontWeight: topic.hasNewPosts ? DesignTokens.fontWeightBold : DesignTokens.fontWeightMedium,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Topic tags (chips below the title). Topics without tags
            // hide the row entirely.
            Builder(
              builder: (context) {
                final tags = topic.tags;
                // Discourse's information architecture is category-first,
                // and the row showed no category at all — you could not
                // tell where a topic lived without opening it. Web puts the
                // category badge on every row, ahead of the tags.
                final category = topic.forumName.trim();
                if (tags.isEmpty && category.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    DesignTokens.spacingL,
                    0.0,
                    DesignTokens.spacingL,
                    DesignTokens.spacingS,
                  ),
                  child: Wrap(
                    spacing: DesignTokens.spacingXS,
                    runSpacing: DesignTokens.spacingXS,
                    children: [
                      if (category.isNotEmpty)
                        Material(
                          color: colorScheme.secondaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(DesignTokens.radiusS),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            child: Text(
                              category,
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                                fontWeight: DesignTokens.fontWeightSemiBold,
                                letterSpacing: DesignTokens.letterSpacingWide,
                              ),
                            ),
                          ),
                        ),
                      ...tags.map((tag) {
                      final chipShape = RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusS),
                      );
                      return Material(
                        color: colorScheme.surfaceContainerHighest,
                        shape: chipShape.copyWith(
                          side: BorderSide(
                            color: colorScheme.outlineVariant,
                            width: 0.5,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          customBorder: chipShape,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TagTopicsPage(
                                siteContext: siteContext,
                                tag: tag,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            child: Text(
                              tag,
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                letterSpacing: DesignTokens.letterSpacingWide,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    ],
                  ),
                );
              },
            ),
            // Short content if available
            if (topic.shortContent!.isNotEmpty && !topic.isAnnouncement) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(DesignTokens.spacingL, 0.0, DesignTokens.spacingL, DesignTokens.spacingS),
                child: Text(
                  topic.shortContent!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            // Metadata row
            Builder(
              builder: (context) {
                // Count status icons to determine if we should show labels
                final statusIconCount = [
                  if (topicIcon != null) 1,
                  if (topic.isSolved) 1,
                  if (topic.isHot) 1,
                  if (topic.isPinned) 1,
                  if (topic.isSubscribed) 1,
                  if (topic.isClosed) 1,
                  if (topic.hasPoll) 1,
                ].length;
                final showLabels = statusIconCount == 1;
                final metaColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.72);
                
                return Padding(
                  padding: EdgeInsets.fromLTRB(DesignTokens.spacingL, 0.0, DesignTokens.spacingL, DesignTokens.spacingL),
                  child: Wrap(
                    spacing: DesignTokens.spacingL,
                    runSpacing: DesignTokens.spacingXS,
                    children: [
                      if (topic.replyCount > 0) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              size: textTheme.bodySmall?.fontSize ?? 12,
                              color: metaColor,
                            ),
                            SizedBox(width: DesignTokens.spacingXS),
                            Text(
                              formatNumber(context, topic.replyCount),
                              style: textTheme.bodySmall?.copyWith(
                                color: metaColor,
                                letterSpacing: DesignTokens.letterSpacingWide,
                              ),
                            ),
                          ],
                        ),
                      ],
                      // Likes — web shows these on every row and they are a
                      // better signal of a topic worth opening than views.
                      if (topic.likeCount > 0) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: textTheme.bodySmall?.fontSize ?? 12,
                              color: metaColor,
                            ),
                            SizedBox(width: DesignTokens.spacingXS),
                            Text(
                              formatNumber(context, topic.likeCount),
                              style: textTheme.bodySmall?.copyWith(
                                color: metaColor,
                                letterSpacing: DesignTokens.letterSpacingWide,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (topic.viewCount > 0) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              size: textTheme.bodySmall?.fontSize ?? 12,
                              color: metaColor,
                            ),
                            SizedBox(width: DesignTokens.spacingXS),
                            Text(
                              formatNumber(context, topic.viewCount),
                              style: textTheme.bodySmall?.copyWith(
                                color: metaColor,
                                letterSpacing: DesignTokens.letterSpacingWide,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (topicIcon != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              topicIcon,
                              size: textTheme.bodySmall?.fontSize ?? 12,
                              color: metaColor,
                            ),
                            if (showLabels) ...[
                              SizedBox(width: DesignTokens.spacingXS),
                              Text(
                                'Announcement',
                                style: textTheme.bodySmall?.copyWith(
                                  color: metaColor,
                                  letterSpacing: DesignTokens.letterSpacingWide,
                                ),
                              ),
                            ],
                          ],
                        ),
                      if (topic.isSolved)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: textTheme.bodySmall?.fontSize ?? 12,
                              color: Colors.green.shade600,
                            ),
                            if (showLabels) ...[
                              SizedBox(width: DesignTokens.spacingXS),
                              Text(
                                'Solved',
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.green.shade600,
                                  letterSpacing: DesignTokens.letterSpacingWide,
                                ),
                              ),
                            ],
                          ],
                        ),
                      // Discourse's own trending flag (`is_hot`), which web
                      // badges on the row. Not derivable from the counts
                      // beside it — the server weighs recency and activity
                      // together — so it is shown only when the server says
                      // so, and tinted rather than left grey because "hot"
                      // is the one badge here that is an invitation.
                      if (topic.isHot)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: textTheme.bodySmall?.fontSize ?? 12,
                              color: Colors.deepOrange.shade400,
                            ),
                            if (showLabels) ...[
                              SizedBox(width: DesignTokens.spacingXS),
                              Text(
                                'Hot',
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.deepOrange.shade400,
                                  letterSpacing: DesignTokens.letterSpacingWide,
                                ),
                              ),
                            ],
                          ],
                        ),
                      if (topic.isPinned)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.push_pin_outlined,
                              size: textTheme.bodySmall?.fontSize ?? 12,
                              color: metaColor,
                            ),
                            if (showLabels) ...[
                              SizedBox(width: DesignTokens.spacingXS),
                              Text(
                                'Pinned',
                                style: textTheme.bodySmall?.copyWith(
                                  color: metaColor,
                                  letterSpacing: DesignTokens.letterSpacingWide,
                                ),
                              ),
                            ],
                          ],
                        ),
                      if (topic.isSubscribed)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.watch_outlined,
                              size: textTheme.bodySmall?.fontSize ?? 12,
                              color: metaColor,
                            ),
                            if (showLabels) ...[
                              SizedBox(width: DesignTokens.spacingXS),
                              Text(
                                'Subscribed',
                                style: textTheme.bodySmall?.copyWith(
                                  color: metaColor,
                                  letterSpacing: DesignTokens.letterSpacingWide,
                                ),
                              ),
                            ],
                          ],
                        ),
                      if (topic.isClosed)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outlined,
                              size: textTheme.bodySmall?.fontSize ?? 12,
                              color: metaColor,
                            ),
                            if (showLabels) ...[
                              SizedBox(width: DesignTokens.spacingXS),
                              Text(
                                'Locked',
                                style: textTheme.bodySmall?.copyWith(
                                  color: metaColor,
                                  letterSpacing: DesignTokens.letterSpacingWide,
                                ),
                              ),
                            ],
                          ],
                        ),
                      // Show poll icon in topic list so users can identify threads with polls.
                      if (topic.hasPoll)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.poll_outlined,
                              size: textTheme.bodySmall?.fontSize ?? 12,
                              color: metaColor,
                            ),
                            if (showLabels) ...[
                              SizedBox(width: DesignTokens.spacingXS),
                              Text(
                                'Poll',
                                style: textTheme.bodySmall?.copyWith(
                                  color: metaColor,
                                  letterSpacing: DesignTokens.letterSpacingWide,
                                ),
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
            // Bottom divider
            _buildBottomDivider(colorScheme),
          ],
        ),
      ),
    );
  }
}
