import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';
import 'sheet_title.dart';
import '../../l10n/generated/app_localizations.dart';

/// Purely informational bottom sheet explaining Discourse's five trust
/// levels, opened by tapping the "TL{n} · {name}" chip on a profile.
/// The profile user's current level row is highlighted.
class TrustLevelSheet extends StatelessWidget {
  /// The profile user's trust level (0–4). Out-of-range values simply
  /// highlight nothing.
  final int currentLevel;

  const TrustLevelSheet({super.key, required this.currentLevel});

  /// Convenience opener matching the style of the other sheet widgets
  /// (e.g. `NotificationLevelSheet.showForTopic`).
  static Future<void> show({
    required BuildContext context,
    required int currentLevel,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => TrustLevelSheet(currentLevel: currentLevel),
    );
  }

  // Discourse's names for the levels (trust_levels.names); the one-liners
  // are kept faithful to stock Discourse defaults.
  static List<_TrustLevelEntry> _levels(AppLocalizations l10n) => [
        _TrustLevelEntry(
          level: 0,
          name: l10n.trustLevelNameNewUser,
          summary: l10n.trustLevelSummary0,
        ),
        _TrustLevelEntry(
          level: 1,
          name: l10n.trustLevelNameBasic,
          summary: l10n.trustLevelSummary1,
        ),
        _TrustLevelEntry(
          level: 2,
          name: l10n.trustLevelNameMember,
          summary: l10n.trustLevelSummary2,
        ),
        _TrustLevelEntry(
          level: 3,
          name: l10n.trustLevelNameRegular,
          summary: l10n.trustLevelSummary3,
        ),
        _TrustLevelEntry(
          level: 4,
          name: l10n.trustLevelNameLeader,
          summary: l10n.trustLevelSummary4,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    // Scrolls, and may grow past the default 9/16 of the screen: at a
    // larger text size or on a short phone the options no longer fit.
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: DesignTokens.spacingS),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetTitle(l10n.trustLevels),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.spacingL,
                0,
                DesignTokens.spacingL,
                DesignTokens.spacingM,
              ),
              child: Text(
                l10n.trustLevelsExplanation,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const Divider(height: 1),
            for (final entry in _levels(l10n))
              _buildRow(entry, l10n, colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    _TrustLevelEntry entry,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isCurrent = entry.level == currentLevel;
    // The theme's selected row, as the notification-level sheet draws the
    // current level.
    return ListTile(
      selected: isCurrent,
      leading: CircleAvatar(
        radius: DesignTokens.avatarRadiusS,
        backgroundColor: isCurrent
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        child: Text(
          '${entry.level}',
          style: textTheme.labelLarge?.copyWith(
            color:
                isCurrent ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      title: Text(l10n.trustLevelRowTitle(entry.level, entry.name)),
      subtitle: Text(entry.summary),
      trailing: isCurrent ? const Icon(Icons.check) : null,
    );
  }
}

class _TrustLevelEntry {
  final int level;
  final String name;
  final String summary;
  const _TrustLevelEntry({
    required this.level,
    required this.name,
    required this.summary,
  });
}
