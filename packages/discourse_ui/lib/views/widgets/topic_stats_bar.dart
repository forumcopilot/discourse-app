import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';
import '../../utils/number_utils.dart';
import 'remote_circle_avatar.dart';

/// The topic summary Discourse's web UI renders under the first post (its
/// "topic map": `793 views · 7 likes · 4 links · 6 users`, plus the
/// participants' faces).
///
/// Laid out as web lays it out: each number above its label, the numbers
/// a step up in the accent colour and the labels small and muted, with the
/// most active participants' avatars at the end. It was a single line of
/// 12dp icons and caption-sized numbers between two rules, which read as
/// one more row of controls rather than as the summary that closes the
/// opening post — and the icons did not grow with the reader's text size.
///
/// Numbers are shown whenever they are non-zero. Web hides small like and
/// user counts (more than 5 of each) as noise; with the numbers this
/// small, a phone has the room.
///
/// The user count is the server's own `participantCount` rather than
/// `participatedUserIds.length`, because that list is a capped posters
/// summary and under-reports on busy topics. The avatars come from the
/// same list (`details.participants`, most posts first), so they need no
/// request of their own.
class TopicStatsBar extends StatelessWidget {
  const TopicStatsBar({super.key, required this.topic});

  final FCTopic topic;

  /// Web shows the faces once two people have taken part, at most five.
  static const int _minAvatars = 2;
  static const int _maxAvatars = 5;
  static const double _avatarRadius = 13;

  /// How much each face tucks under the one before it.
  static const double _avatarOverlap = 8;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Server's count first. Falls back to the posters-summary length only
    // when the payload did not report one — that list is capped, so it is
    // a floor, not the real number.
    final userCount = topic.participantCount > 0
        ? topic.participantCount
        : topic.participatedUserIds.length;

    final stats = <Widget>[
      if (topic.viewCount > 0)
        _stat(context, topic.viewCount,
            l10n.topicMapViews(topic.viewCount)),
      if (topic.likeCount > 0)
        _stat(context, topic.likeCount,
            l10n.topicMapLikes(topic.likeCount)),
      if (topic.linkCount > 0)
        _stat(context, topic.linkCount,
            l10n.topicMapLinks(topic.linkCount)),
      if (userCount > 0)
        _stat(context, userCount, l10n.topicMapUsers(userCount)),
    ];
    final faces = topic.participantIconUrls.length >= _minAvatars
        ? topic.participantIconUrls.take(_maxAvatars).toList()
        : const <String>[];

    // A topic with nothing to report should not leave an empty rule behind.
    if (stats.isEmpty && faces.isEmpty) return const SizedBox.shrink();

    final row = LayoutBuilder(
      builder: (context, box) => Row(
        children: [
          // The numbers get their natural width first, and scale down
          // rather than overflow when an accessibility text size makes
          // them wider than the phone.
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: box.maxWidth),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < stats.length; i++) ...[
                    if (i > 0) SizedBox(width: DesignTokens.spacingXL),
                    stats[i],
                  ],
                ],
              ),
            ),
          ),
          // The faces take what is left: as many as fit, like web's
          // clipped avatar strip.
          Expanded(child: _faces(colorScheme, faces)),
        ],
      ),
    );

    // Inset rule above, none below: the list follows the summary with a
    // section gap, and the rule separates the summary from the post's own
    // actions without cutting the post off from its summary.
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingL),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: DesignTokens.spacingM),
          child: row,
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, int value, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final number = formatNumber(context, value);
    return Semantics(
      label: '$number $label',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            number,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: DesignTokens.fontWeightMedium,
              height: 1.2,
            ),
          ),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _faces(ColorScheme colorScheme, List<String> urls) {
    if (urls.isEmpty) return const SizedBox.shrink();
    const diameter = _avatarRadius * 2;
    // A ring in the page colour marks where one face tucks under the next.
    const ring = 2.0;
    const outer = diameter + ring * 2;
    const step = outer - _avatarOverlap;
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, box) {
          final gap = DesignTokens.spacingM;
          final room = box.maxWidth - gap;
          final fit = room < outer ? 0 : ((room - outer) ~/ step) + 1;
          final shown = urls.take(fit).toList();
          if (shown.isEmpty) return const SizedBox.shrink();
          return Align(
            alignment: AlignmentDirectional.centerEnd,
            child: SizedBox(
              width: outer + step * (shown.length - 1),
              height: outer,
              child: Stack(
                children: [
                  for (var i = 0; i < shown.length; i++)
                    PositionedDirectional(
                      start: step * i,
                      child: Container(
                        padding: const EdgeInsets.all(ring),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                        child: RemoteCircleAvatar(
                          radius: _avatarRadius,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          imageUrl: shown[i],
                          fallback: Icon(
                            Icons.person,
                            size: _avatarRadius,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
