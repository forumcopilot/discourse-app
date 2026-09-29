import 'package:discourse_core/discourse_core.dart' show DiscourseUserSummary;
import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';
import '../../utils/number_utils.dart';

/// A person's numbers — posts, likes received, days visited, and
/// solutions where discourse-solved reports them — each over its label as
/// the topic summary draws them. The Profile tab's and the public
/// profile's, so both read the same.
class ProfileStatsStrip extends StatelessWidget {
  const ProfileStatsStrip({
    super.key,
    required this.summary,
    this.onPosts,
    this.onSolved,
  });

  final DiscourseUserSummary summary;

  /// Where posts and solutions lead, when the numbers are the reader's
  /// own (My posts on that filter); null on someone else's profile.
  final VoidCallback? onPosts;
  final VoidCallback? onSolved;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Every post, the topics' opening posts included, as web's
    // "posts created" counts them.
    final posts = summary.postCount;
    final solved = summary.solvedCount;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingS, vertical: DesignTokens.spacingM),
      child: Row(
        children: [
          _Stat(value: posts, label: l10n.profileStatPosts(posts), onTap: onPosts),
          _Stat(
              value: summary.likesReceived,
              label: l10n.profileStatLikes(summary.likesReceived)),
          _Stat(
              value: summary.daysVisited,
              label: l10n.profileStatDays(summary.daysVisited)),
          // Only on forums running discourse-solved, which is also the
          // only way the summary carries the count.
          if (solved != null)
            _Stat(value: solved, label: l10n.profileStatSolved, onTap: onSolved),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.onTap});

  final int value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final number = formatNumber(context, value);
    return Expanded(
      // The number and its label read as one ("26 posts").
      child: MergeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
            child: Column(
              children: [
                Text(
                  number,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: DesignTokens.fontWeightMedium,
                    height: 1.2,
                  ),
                ),
                Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
