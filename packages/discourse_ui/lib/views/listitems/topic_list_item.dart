import 'package:flutter/material.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';
import 'package:discourse_ui/utils/time_utils.dart';
import 'package:discourse_ui/utils/number_utils.dart';
import 'package:discourse_ui/views/widgets/user_avatar.dart';
import 'package:discourse_ui/views/tag_topics_page.dart';
import '../../theme/design_tokens.dart';
import '../../utils/emoji_shortcodes.dart';
import '../../theme/style_builders.dart';

/// Widget para representar un ítem de la lista de foros
class TopicListItem extends StatelessWidget {
  /// Whether to show the category badge. False inside a category page,
  /// where the header already names it.
  final bool showCategory;

  final SiteContext siteContext;
  final FCTopic topic;
  final VoidCallback? onTap;
  final IconData? topicIcon;
  final Function(String topicId)? onMarkAsRead;

  const TopicListItem({
    super.key,
    required this.siteContext,
    required this.topic,
    this.showCategory = true,
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
                          Text(
                            AppLocalizations.of(context)?.topicLastReplyBy(
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
                              letterSpacing: DesignTokens.letterSpacingWide,
                            ),
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
                            AppLocalizations.of(context)!.deleted,
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
                      withEmojiShortcodes(topic.title),
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
                // Suppressed inside a category: the header two rows up
                // already says where you are, so repeating it on every
                // row is noise the eye has to filter out.
                final category = showCategory ? topic.forumName.trim() : '';
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
                        // A DecoratedBox, not a clipped Material: an
                        // antialiased clip is a saveLayer per chip per row.
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius:
                                BorderRadius.circular(DesignTokens.radiusS),
                          ),
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
                      // Two tags and a "+N": a row is a glance, not an
                      // index, and every chip is layout and paint.
                      ...tags.take(2).map((tag) {
                      final chipShape = RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusS),
                      );
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(DesignTokens.radiusS),
                          border: Border.all(
                            color: colorScheme.outlineVariant,
                            width: 0.5,
                          ),
                        ),
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
                      if (tags.length > 2)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          child: Text(
                            '+${tags.length - 2}',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: DesignTokens.letterSpacingWide,
                            ),
                          ),
                        ),
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
                  withEmojiShortcodes(topic.shortContent!),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            // Metadata row: the three counts (plus votes where a forum runs
            // topic voting) and one status badge. It was two Wraps of up
            // to nine items; the counts are what a row is scanned for, and
            // one badge says the one thing that matters about a topic.
            _MetaRow(topic: topic, topicIcon: topicIcon),
            // Bottom divider
            _buildBottomDivider(colorScheme),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.topic, required this.topicIcon});
  final FCTopic topic;
  final IconData? topicIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final metaColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.72);
    final size = textTheme.bodySmall?.fontSize ?? 12;
    final style = textTheme.bodySmall?.copyWith(
      color: metaColor,
      letterSpacing: DesignTokens.letterSpacingWide,
    );

    Widget count(IconData icon, String text) => Padding(
          padding: EdgeInsets.only(right: DesignTokens.spacingL),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: size, color: metaColor),
              SizedBox(width: DesignTokens.spacingXS),
              Text(text, style: style),
            ],
          ),
        );

    // One badge, by how much it changes what the reader should expect.
    final (IconData, String, Color)? badge = topicIcon != null
        ? (topicIcon!, l10n?.announcement ?? 'Announcement', metaColor)
        : topic.isSolved
            ? (Icons.check_circle, l10n?.solved ?? 'Solved', Colors.green.shade600)
            : topic.isClosed
                ? (Icons.lock_outlined, l10n?.locked ?? 'Locked', metaColor)
                : topic.isHot
                    ? (Icons.local_fire_department, l10n?.hot ?? 'Hot', Colors.deepOrange.shade400)
                    : topic.isPinned
                        ? (Icons.push_pin_outlined, l10n?.pinned ?? 'Pinned', metaColor)
                        : topic.hasPoll
                            ? (Icons.poll_outlined, l10n?.poll ?? 'Poll', metaColor)
                            : topic.isSubscribed
                                ? (Icons.watch_outlined, l10n?.subscribedLabel ?? 'Watching', metaColor)
                                : null;

    return Padding(
      padding: EdgeInsets.fromLTRB(DesignTokens.spacingL, 0.0, DesignTokens.spacingL, DesignTokens.spacingL),
      child: Row(
        children: [
          if (topic.replyCount > 0)
            count(Icons.comment_outlined, formatNumber(context, topic.replyCount)),
          if (topic.likeCount > 0)
            count(Icons.favorite_border, formatNumber(context, topic.likeCount)),
          if (topic.voteCount > 0)
            count(Icons.arrow_upward, l10n?.nVotes(topic.voteCount) ?? '${topic.voteCount} votes'),
          if (topic.viewCount > 0)
            count(Icons.visibility_outlined, formatNumber(context, topic.viewCount)),
          if (badge != null) ...[
            const Spacer(),
            Icon(badge.$1, size: size, color: badge.$3),
            SizedBox(width: DesignTokens.spacingXS),
            Flexible(
              child: Text(
                badge.$2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style?.copyWith(color: badge.$3),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
