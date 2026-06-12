import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';
import 'package:forumcopilot_flutter/utils/time_utils.dart';
import 'package:forumcopilot_flutter/utils/number_utils.dart';
import 'package:forumcopilot_flutter/views/widgets/user_avatar.dart';
import '../../theme/design_tokens.dart';
import '../../theme/style_builders.dart';

/// Phase 5.20c — map a notification's "action verb" (from
/// `social_proxy._alertActionVerb`) to a Material icon for the
/// small overlay badge on the avatar. The verbs are coupled to
/// the proxy; keep them in sync when extending notification
/// coverage.
///
/// Bundles a foreground icon + a background tint so the badge
/// visually distinguishes a "like" notification (heart on the
/// theme's like-red, say) from a "reply" (chat bubble on primary).
class NotificationBadgeStyle {
  final IconData icon;
  final Color Function(ColorScheme) tint;

  const NotificationBadgeStyle({required this.icon, required this.tint});

  static NotificationBadgeStyle? forAction(String? action) {
    if (action == null || action.isEmpty) return null;
    switch (action) {
      case 'mention':
        return NotificationBadgeStyle(
          icon: Icons.alternate_email,
          tint: (cs) => cs.primary,
        );
      case 'reply':
        return NotificationBadgeStyle(
          icon: Icons.reply_rounded,
          tint: (cs) => cs.primary,
        );
      case 'quote':
        return NotificationBadgeStyle(
          icon: Icons.format_quote_rounded,
          tint: (cs) => cs.primary,
        );
      case 'edit':
        return NotificationBadgeStyle(
          icon: Icons.edit_outlined,
          tint: (cs) => cs.tertiary,
        );
      case 'like':
        return NotificationBadgeStyle(
          icon: Icons.favorite_rounded,
          tint: (cs) => cs.error,
        );
      case 'reaction':
        return NotificationBadgeStyle(
          icon: Icons.emoji_emotions_rounded,
          tint: (cs) => cs.tertiary,
        );
      case 'pm':
      case 'group_message':
        return NotificationBadgeStyle(
          icon: Icons.mail_rounded,
          tint: (cs) => cs.primary,
        );
      case 'link':
        return NotificationBadgeStyle(
          icon: Icons.link_rounded,
          tint: (cs) => cs.secondary,
        );
      case 'badge':
        return NotificationBadgeStyle(
          icon: Icons.emoji_events_rounded,
          tint: (cs) => cs.tertiary,
        );
      case 'reminder':
        return NotificationBadgeStyle(
          icon: Icons.alarm_rounded,
          tint: (cs) => cs.tertiary,
        );
      case 'approved':
        return NotificationBadgeStyle(
          icon: Icons.check_circle_rounded,
          tint: (cs) => cs.primary,
        );
      case 'group_request':
        return NotificationBadgeStyle(
          icon: Icons.group_add_rounded,
          tint: (cs) => cs.primary,
        );
      case 'chat':
        return NotificationBadgeStyle(
          icon: Icons.chat_rounded,
          tint: (cs) => cs.primary,
        );
      case 'assigned':
        return NotificationBadgeStyle(
          icon: Icons.assignment_ind_rounded,
          tint: (cs) => cs.secondary,
        );
      case 'qa_comment':
        return NotificationBadgeStyle(
          icon: Icons.question_answer_rounded,
          tint: (cs) => cs.secondary,
        );
      case 'vote':
        return NotificationBadgeStyle(
          icon: Icons.how_to_vote_rounded,
          tint: (cs) => cs.tertiary,
        );
      case 'moved':
        return NotificationBadgeStyle(
          icon: Icons.swap_horiz_rounded,
          tint: (cs) => cs.onSurfaceVariant,
        );
      case 'accepted':
        return NotificationBadgeStyle(
          icon: Icons.check_circle_outline_rounded,
          tint: (cs) => cs.primary,
        );
      case 'new_feature':
        return NotificationBadgeStyle(
          icon: Icons.new_releases_rounded,
          tint: (cs) => cs.tertiary,
        );
      case 'admin':
        return NotificationBadgeStyle(
          icon: Icons.warning_rounded,
          tint: (cs) => cs.error,
        );
      default:
        return null;
    }
  }
}

class NotificationListItem extends StatelessWidget {
  final FCTopic topic;
  final VoidCallback? onTap;
  final IconData? topicIcon;
  final String? contentType;

  /// Phase 5.20c — the action verb from `FCAlert.action` (e.g.
  /// 'mention' / 'like' / 'chat' / 'reaction'). Drives the small
  /// overlay badge on the avatar so users can scan the list and
  /// tell notification types apart at a glance.
  final String? action;

  /// Phase 5.47 — unread rows render with a tinted background, a
  /// leading primary dot, and a semibold message so they pop against
  /// already-seen notifications (from `FCAlert.isRead == false`).
  final bool isUnread;

  const NotificationListItem({
    Key? key,
    required this.topic,
    required this.onTap,
    this.topicIcon,
    this.contentType,
    this.action,
    this.isUnread = false,
  }) : super(key: key);

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
      // Unread rows get a faint primary-container wash; read rows stay
      // on plain surface (mirrors Discourse web's unread styling).
      color: isUnread
          ? colorScheme.primaryContainer
              .withValues(alpha: DesignTokens.opacityLow / 2)
          : colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(DesignTokens.spacingL),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phase 5.20c — avatar with a small notification-
                  // type badge overlaid bottom-right. The badge style
                  // is keyed off the action verb produced by
                  // `social_proxy._alertActionVerb`.
                  _AvatarWithBadge(
                    username: topic.authorName,
                    iconUrl: topic.authorIconUrl,
                    radius: DesignTokens.spacingXL + DesignTokens.spacingXS,
                    badgeStyle: NotificationBadgeStyle.forAction(action),
                  ),
                  SizedBox(width: DesignTokens.spacingL),
                  // Message and metadata on the right
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Message text (flexible wrapping). Unread
                        // rows lead with a primary dot + semibold text.
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isUnread)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(
                                  top: 6,
                                  right: DesignTokens.spacingS,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Expanded(
                              child: Text(
                                topic.title,
                                style: StyleBuilders.titleTextStyle(
                                  colorScheme: colorScheme,
                                  textTheme: textTheme,
                                  fontSize: DesignTokens.fontSizeS,
                                  fontWeight: isUnread
                                      ? DesignTokens.fontWeightSemiBold
                                      : DesignTokens.fontWeightMedium,
                                ),
                                // No maxLines restriction — wraps freely
                              ),
                            ),
                          ],
                        ),
                        // Metadata row at the bottom
                        SizedBox(height: DesignTokens.spacingS),
                        Wrap(
                          spacing: DesignTokens.spacingM,
                          runSpacing: DesignTokens.spacingXS,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (topic.replyCount > 0) ...[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.comment_outlined,
                                    size: DesignTokens.iconSizeS,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  SizedBox(width: DesignTokens.spacingXS),
                                  Text(
                                    formatNumber(context, topic.replyCount),
                                    style: StyleBuilders.smallTextStyle(
                                      colorScheme: colorScheme,
                                      textTheme: textTheme,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (topic.timestamp != DateTime.fromMillisecondsSinceEpoch(0)) ...[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: DesignTokens.iconSizeS,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  SizedBox(width: DesignTokens.spacingXS),
                                  Text(
                                    formatSmartDateTime(topic.timestamp, context),
                                    style: StyleBuilders.smallTextStyle(
                                      colorScheme: colorScheme,
                                      textTheme: textTheme,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (topicIcon != null) ...[
                              Icon(
                                topicIcon!,
                                size: DesignTokens.iconSizeS,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ],
                            if (topic.isPinned) ...[
                              Icon(
                                Icons.push_pin_outlined,
                                size: DesignTokens.iconSizeS,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ],
                            if (topic.isSubscribed) ...[
                              Icon(
                                Icons.watch_outlined,
                                size: DesignTokens.iconSizeS,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom divider
            _buildBottomDivider(colorScheme),
          ],
        ),
      ),
    );
  }
}

/// Notification-row avatar with a small badge icon overlaid in the
/// bottom-right corner, indicating the notification's type (like /
/// reply / mention / etc.). When `badgeStyle` is null, falls back
/// to a plain `UserAvatar`.
class _AvatarWithBadge extends StatelessWidget {
  final String username;
  final String? iconUrl;
  final double radius;
  final NotificationBadgeStyle? badgeStyle;

  const _AvatarWithBadge({
    required this.username,
    required this.iconUrl,
    required this.radius,
    required this.badgeStyle,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = UserAvatar(
      username: username,
      iconUrl: iconUrl,
      radius: radius,
    );
    final style = badgeStyle;
    if (style == null) return avatar;

    final colorScheme = Theme.of(context).colorScheme;
    final badgeSize = radius * 0.85;
    final iconSize = badgeSize * 0.65;
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: avatar),
          Positioned(
            right: -badgeSize * 0.15,
            bottom: -badgeSize * 0.15,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: style.tint(colorScheme),
                shape: BoxShape.circle,
                border: Border.all(
                  // Surface-coloured ring so the badge "punches out"
                  // of the avatar — looks the same in light + dark
                  // mode.
                  color: colorScheme.surface,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                style.icon,
                size: iconSize,
                color: _onTint(style.tint(colorScheme), colorScheme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Pick a foreground colour that contrasts against the badge
  /// background. We pair each scheme role with its `on*` partner
  /// so the icon stays legible whatever theme variant the user
  /// has chosen.
  Color _onTint(Color tint, ColorScheme cs) {
    if (tint == cs.primary) return cs.onPrimary;
    if (tint == cs.secondary) return cs.onSecondary;
    if (tint == cs.tertiary) return cs.onTertiary;
    if (tint == cs.error) return cs.onError;
    return cs.onSurface;
  }
}
