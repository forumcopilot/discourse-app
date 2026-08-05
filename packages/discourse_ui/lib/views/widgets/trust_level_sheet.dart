import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.spacingL,
                DesignTokens.spacingM,
                DesignTokens.spacingL,
                DesignTokens.spacingXS,
              ),
              child: Text(
                'Trust levels',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: DesignTokens.fontWeightSemiBold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.spacingL,
                0,
                DesignTokens.spacingL,
                DesignTokens.spacingM,
              ),
              child: Text(
                'Members earn trust by reading and participating. '
                'Each level unlocks new abilities.',
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
    return ListTile(
      tileColor:
          isCurrent ? colorScheme.primary.withValues(alpha: 0.08) : null,
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
            fontWeight: DesignTokens.fontWeightSemiBold,
          ),
        ),
      ),
      title: Text(
        'TL${entry.level} · ${entry.name}',
        style: textTheme.bodyLarge?.copyWith(
          fontWeight:
              isCurrent ? DesignTokens.fontWeightSemiBold : FontWeight.normal,
          color: isCurrent ? colorScheme.primary : null,
        ),
      ),
      subtitle: Text(
        entry.summary,
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing:
          isCurrent ? Icon(Icons.check, color: colorScheme.primary) : null,
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
