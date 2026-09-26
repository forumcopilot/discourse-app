import 'package:flutter/material.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';
import 'package:discourse_ui/utils/time_utils.dart';
import 'package:discourse_ui/utils/number_utils.dart';
import 'package:discourse_ui/views/widgets/user_avatar.dart';
import '../../theme/design_tokens.dart';
import '../../utils/emoji_shortcodes.dart';
import '../../theme/style_builders.dart';
import '../../theme/forum_colors.dart';
import '../widgets/topic_taxonomy_chips.dart';
import '../widgets/unread_badge.dart';

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final unread = topic.hasNewPosts;
    final excerpt = topic.shortContent ?? '';

    // A Material 3 list item, title first: the author's avatar leading, the
    // title as the headline, then where the topic lives and what happened
    // last. It used to open with a three-line author block and put the
    // title under it, at ~200dp a row; this is ~90–115dp.
    return Material(
      color: colorScheme.surface,
      child: InkWell(
        onTap: _handleTap,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(
                    username: topic.authorName,
                    iconUrl: topic.authorIconUrl,
                    radius: DesignTokens.avatarRadiusM,
                  ),
                  const SizedBox(width: DesignTokens.spacingL),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (topic.isDeleted) ...[
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: _DeletedBadge(),
                              ),
                              const SizedBox(width: DesignTokens.spacingS),
                            ],
                            Expanded(
                              child: Text(
                                withEmojiShortcodes(topic.title),
                                // Unread titles in full strength; read ones
                                // step back, as visited topics do on web.
                                style: textTheme.titleMedium?.copyWith(
                                  color: unread
                                      ? colorScheme.onSurface
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: unread
                                      ? DesignTokens.fontWeightMedium
                                      : DesignTokens.fontWeightNormal,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (unread)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: DesignTokens.spacingS,
                                  top: 6,
                                ),
                                child: UnreadBadge(count: topic.unreadCount),
                              ),
                          ],
                        ),
                        if (excerpt.isNotEmpty && !topic.isAnnouncement)
                          Padding(
                            padding: const EdgeInsets.only(
                                top: DesignTokens.spacingXS),
                            child: Text(
                              withEmojiShortcodes(excerpt),
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        // The category badge and tags. Discourse's
                        // information architecture is category-first, and
                        // web puts the badge on every row, ahead of the
                        // tags. Suppressed inside a category, whose header
                        // already says where you are; draws nothing when
                        // there is neither.
                        TopicTaxonomyChips(
                          siteContext: siteContext,
                          categoryId: showCategory ? topic.forumId : '',
                          categoryName: showCategory ? topic.forumName : '',
                          tags: topic.tags,
                          maxTags: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: DesignTokens.spacingXS),
                          child: _MetaRow(topic: topic, topicIcon: topicIcon),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Inset to the text, as Material 3's list dividers are.
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

class _DeletedBadge extends StatelessWidget {
  const _DeletedBadge();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: StyleBuilders.badgeDecoration(
        colorScheme: colorScheme,
        backgroundColor: colorScheme.outline.withValues(alpha: DesignTokens.opacityLow),
        borderRadius: DesignTokens.radiusS,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline, size: 12, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: DesignTokens.spacingXS),
          Text(
            AppLocalizations.of(context)!.deleted,
            style: StyleBuilders.badgeTextStyle(
              colorScheme: colorScheme,
              textTheme: Theme.of(context).textTheme,
            ),
          ),
        ],
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
    final metaColor = colorScheme.onSurfaceVariant;
    final style = textTheme.bodySmall?.copyWith(color: metaColor);
    const iconSize = DesignTokens.iconSizeS;

    Widget count(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(left: DesignTokens.spacingM),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: metaColor),
              const SizedBox(width: DesignTokens.spacingXS),
              Text(text, style: style),
            ],
          ),
        );

    // "alice replied 3 hours ago" — web leads with the last voice, because
    // on a busy list it is the reason to open a topic. Before anyone has
    // replied: who started it, and when.
    final hasTime = topic.timestamp != DateTime.fromMillisecondsSinceEpoch(0);
    final String activity;
    if (topic.lastPosterName != null && topic.lastPostedAt != null) {
      activity = l10n?.topicLastReplyBy(topic.lastPosterName!,
              formatSmartDateTime(topic.lastPostedAt!, context)) ??
          '${topic.lastPosterName} replied '
              '${formatSmartDateTime(topic.lastPostedAt!, context)}';
    } else {
      final author =
          topic.authorName.isNotEmpty ? topic.authorName : 'Unknown';
      activity = hasTime
          ? '$author · ${formatSmartDateTime(topic.timestamp, context)}'
          : author;
    }

    // One badge, by how much it changes what the reader should expect.
    final (IconData, String, Color)? badge = topicIcon != null
        ? (topicIcon!, l10n?.announcement ?? 'Announcement', metaColor)
        : topic.isSolved
            ? (Icons.check_circle, l10n?.solved ?? 'Solved', ForumColors.of(context).success)
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

    // The activity text gives way to the counts beside it, and both to the
    // badge at the end. (A Flexible and a Spacer in one Row split the free
    // space evenly, which cut the activity off at half the width.)
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  activity,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style,
                ),
              ),
              if (topic.replyCount > 0)
                count(Icons.comment_outlined,
                    formatNumber(context, topic.replyCount)),
              if (topic.likeCount > 0)
                count(Icons.favorite_border,
                    formatNumber(context, topic.likeCount)),
              if (topic.voteCount > 0)
                count(Icons.arrow_upward,
                    formatNumber(context, topic.voteCount)),
            ],
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: DesignTokens.spacingS),
          Icon(badge.$1, size: iconSize, color: badge.$3),
          const SizedBox(width: DesignTokens.spacingXS),
          Text(
            badge.$2,
            maxLines: 1,
            style: style?.copyWith(color: badge.$3),
          ),
        ],
      ],
    );
  }
}
