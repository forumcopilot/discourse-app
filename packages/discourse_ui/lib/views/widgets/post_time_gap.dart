import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';

/// The "3 months later" divider Discourse inserts between posts far apart in
/// time, so a topic that was revived after a long silence does not read as
/// one continuous conversation.
///
/// Thresholds and wording follow Discourse's own
/// `components/post/time-gap.gjs` exactly:
///   * `< 30` days  → "N days later"
///   * `< 365` days → "N months later", days/30 rounded
///   * otherwise    → "N years later", days/365 rounded
///
/// Whether to show one at all is the caller's decision, because it depends on
/// the forum's `show_time_gap_days` setting rather than on this widget.
class PostTimeGap extends StatelessWidget {
  const PostTimeGap({super.key, required this.daysSince});

  final int daysSince;

  /// Whole days between two posts, floored — Discourse's `daysBetween`.
  static int daysBetween(DateTime earlier, DateTime later) =>
      later.difference(earlier).inDays;

  /// Discourse shows the divider on `daysSince > show_time_gap_days`, a
  /// strict comparison: at exactly the threshold it stays hidden.
  static bool shouldShow(int daysSince, int showTimeGapDays) =>
      daysSince > showTimeGapDays;

  String _describe(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (daysSince < 30) {
      return l10n?.timeGapDaysLater(daysSince) ?? '$daysSince days later';
    }
    if (daysSince < 365) {
      final months = (daysSince / 30).round();
      return l10n?.timeGapMonthsLater(months) ?? '$months months later';
    }
    final years = (daysSince / 365).round();
    return l10n?.timeGapYearsLater(years) ?? '$years years later';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    final rule = theme.dividerColor.withValues(alpha: 0.5);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingL,
        vertical: DesignTokens.spacingM,
      ),
      child: Row(
        children: [
          Expanded(child: Divider(color: rule)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingM),
            child: Text(
              _describe(context),
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontStyle: FontStyle.italic,
                letterSpacing: DesignTokens.letterSpacingWide,
              ),
            ),
          ),
          Expanded(child: Divider(color: rule)),
        ],
      ),
    );
  }
}
