import 'package:discourse_core/discourse_core.dart' show DiscourseTopicTracking;
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
import '../../utils/topic_read_mark.dart';
import '../../l10n/kit_strings.dart';

/// Widget para representar un ítem de la lista de foros
class TopicListItem extends StatelessWidget {
  /// Whether to show the category badge. False inside a category page,
  /// where the header already names it.
  final bool showCategory;

  final SiteContext siteContext;
  final FCTopic topic;
  final VoidCallback? onTap;
  final IconData? topicIcon;

  const TopicListItem({
    super.key,
    required this.siteContext,
    required this.topic,
    this.showCategory = true,
    required this.onTap,
    this.topicIcon,
  });

  // The row does not mark the topic read when tapped: it used to, before
  // anything was read, so backing straight out left it looking read until
  // the next refresh brought it back. The topic page reports what the
  // reader actually saw, and the row follows (TopicReadMarkBuilder).
  @override
  Widget build(BuildContext context) => TopicReadMarkBuilder(
        siteContext: siteContext,
        topicId: topic.id,
        hasNewPosts: topic.hasNewPosts,
        unreadCount: topic.unreadCount,
        builder: _buildRow,
      );

  Widget _buildRow(BuildContext context, TopicReadMark mark) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final excerpt = topic.shortContent ?? '';

    // A Material 3 list item, title first: the author's avatar leading, the
    // title as the headline, then where the topic lives and what happened
    // last. It used to open with a three-line author block and put the
    // title under it, at ~200dp a row; this is ~90–115dp.
    return Material(
      color: colorScheme.surface,
      child: InkWell(
        onTap: onTap,
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
                                // Only a topic read to the end steps back,
                                // as visited topics do on web; one never
                                // opened keeps full strength.
                                style: textTheme.titleMedium?.copyWith(
                                  color: mark.isRead
                                      ? colorScheme.onSurfaceVariant
                                      : colorScheme.onSurface,
                                  fontWeight: mark.isRead
                                      ? DesignTokens.fontWeightNormal
                                      : DesignTokens.fontWeightMedium,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (mark.isNew || mark.unreadCount > 0)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: DesignTokens.spacingS,
                                  top: 6,
                                ),
                                child: mark.unreadCount > 0
                                    ? UnreadBadge(
                                        count: mark.unreadCount,
                                        semanticLabel: l10n
                                            .topicUnreadReplies(mark.unreadCount),
                                      )
                                    : UnreadBadge(
                                        semanticLabel: l10n.topicIsNew),
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
                          child: _MetaRow(
                            topic: topic,
                            topicIcon: topicIcon,
                            // The reader's level on the topic, as the
                            // proxies recorded it from the list payload.
                            notificationLevel: siteContext.isLoggedIn
                                ? DiscourseTopicTracking.forSite(siteContext)
                                    .stateOf(topic.id)
                                    ?.notificationLevel
                                : null,
                          ),
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
  const _MetaRow(
      {required this.topic, required this.topicIcon, this.notificationLevel});
  final FCTopic topic;
  final IconData? topicIcon;

  /// 3 Watching, 2 Tracking; null when not known.
  final int? notificationLevel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
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
      activity = l10n.topicLastReplyBy(topic.lastPosterName!,
          formatSmartDateTime(topic.lastPostedAt!, context));
    } else {
      final author = topic.authorName.isNotEmpty
          ? topic.authorName
          : l10n.topicAuthorUnknown;
      activity = hasTime
          ? '$author · ${formatSmartDateTime(topic.timestamp, context)}'
          : author;
    }

    // One badge, by how much it changes what the reader should expect.
    // A pinned-globally topic leads a category list (forum_topic_list);
    // Discourse calls it "Pinned Globally".
    final (IconData, String, Color)? badge = topicIcon != null
        ? (topicIcon!, l10n.topicStatusPinnedGloballyTitle, metaColor)
        : topic.isSolved
            ? (Icons.check_circle, l10n.kit.solved, ForumColors.of(context).success)
            : topic.isClosed
                ? (Icons.lock_outlined, l10n.kit.closedLabel, metaColor)
                : topic.isHot
                    ? (Icons.local_fire_department, l10n.hot, Colors.deepOrange.shade400)
                    : topic.isPinned
                        ? (Icons.push_pin_outlined, l10n.pinned, metaColor)
                        : topic.hasPoll
                            ? (Icons.poll_outlined, l10n.poll, metaColor)
                            // The reader's level by Discourse's name for it;
                            // nothing when the list did not say which.
                            : notificationLevel == 3
                                ? (Icons.notifications_active_outlined, l10n.notificationLevelWatching, metaColor)
                                : notificationLevel == 2
                                    ? (Icons.notifications_outlined, l10n.notificationLevelTracking, metaColor)
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
