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

  // One-liners kept faithful to stock Discourse defaults.
  static const _levels = <_TrustLevelEntry>[
    _TrustLevelEntry(
      level: 0,
      name: 'New',
      summary: 'Just joined. Can read and post, with limits on links, '
          'images and messages.',
    ),
    _TrustLevelEntry(
      level: 1,
      name: 'Basic',
      summary: 'Unlocks core posting features: images and attachments, '
          'more links, flagging posts.',
    ),
    _TrustLevelEntry(
      level: 2,
      name: 'Member',
      summary: 'Can send invites, ignore users, and edit their own posts '
          'for longer.',
    ),
    _TrustLevelEntry(
      level: 3,
      name: 'Regular',
      summary: 'Can recategorize and rename topics, create tags, and their '
          'spam flags carry more weight.',
    ),
    _TrustLevelEntry(
      level: 4,
      name: 'Leader',
      summary: 'Granted by staff. Can edit any post and pin, close, split '
          'or merge topics.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Scrolls, and may grow past the default 9/16 of the screen: at a
    // larger text size or on a short phone the options no longer fit.
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: DesignTokens.spacingS),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetTitle(AppLocalizations.of(context)!.trustLevels),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.spacingL,
                0,
                DesignTokens.spacingL,
                DesignTokens.spacingM,
              ),
              child: Text(
                AppLocalizations.of(context)!.trustLevelsExplanation,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const Divider(height: 1),
            for (final entry in _levels)
              _buildRow(entry, colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    _TrustLevelEntry entry,
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
      title: Text('TL${entry.level} · ${entry.name}'),
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
