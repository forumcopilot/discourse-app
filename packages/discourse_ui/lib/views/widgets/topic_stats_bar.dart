import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';

import '../../theme/design_tokens.dart';
import '../../utils/number_utils.dart';

/// The topic-level summary Discourse's web UI renders under the first post
/// (`793 views · 7 likes · 4 links · 6 users`).
///
/// Icons rather than web's written labels: the topic rows already established
/// icon+count as this app's idiom for the same three numbers, it survives a
/// narrow phone without wrapping, and it needs no new translated strings.
///
/// Two of web's four entries are deliberately absent rather than faked:
///   * **links** — `details.links` from `/t/{id}.json` is not carried on
///     [FCTopic], so there is nothing to read. Adding it is an SDK model
///     change, which belongs in the canonical SDK first.
///   * **participant avatars** — [FCTopic.participatedUserIds] gives ids but
///     no avatar URLs, and Discourse avatar URLs come from a per-user
///     template. Rendering them would mean a second fetch per topic.
class TopicStatsBar extends StatelessWidget {
  const TopicStatsBar({super.key, required this.topic});

  final FCTopic topic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metaColor = theme.colorScheme.onSurfaceVariant;

    // `participatedUserIds` is the posters summary, which is who web counts
    // as "users" — not reply count, and not everyone who merely read.
    final userCount = topic.participatedUserIds.length;

    final entries = <Widget>[
      if (topic.viewCount > 0)
        _stat(context, Icons.visibility_outlined, topic.viewCount, metaColor),
      if (topic.likeCount > 0)
        _stat(context, Icons.favorite_border, topic.likeCount, metaColor),
      if (userCount > 0)
        _stat(context, Icons.people_outline, userCount, metaColor),
    ];

    // A topic with nothing to report should not leave an empty rule behind.
    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingL,
        vertical: DesignTokens.spacingS,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
        ),
      ),
      child: Wrap(
        spacing: DesignTokens.spacingL,
        runSpacing: DesignTokens.spacingXS,
        children: entries,
      ),
    );
  }

  Widget _stat(BuildContext context, IconData icon, int value, Color color) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: textTheme.bodySmall?.fontSize ?? 12, color: color),
        SizedBox(width: DesignTokens.spacingXS),
        Text(
          formatNumber(context, value),
          style: textTheme.bodySmall?.copyWith(
            color: color,
            letterSpacing: DesignTokens.letterSpacingWide,
          ),
        ),
      ],
    );
  }
}
