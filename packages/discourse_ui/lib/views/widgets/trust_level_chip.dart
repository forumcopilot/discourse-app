import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

/// Phase 5.18d — compact trust-level pill used wherever a directory
/// row needs to surface a user's TL (Users directory, Group members,
/// search results, etc.). Centralising it keeps the radius, padding,
/// and font weight from drifting across screens.
class TrustLevelChip extends StatelessWidget {
  /// Discourse trust level: 0 (New) → 4 (Leader). The chip renders
  /// `TL{n}` regardless of the value, so any positive integer works.
  final int level;

  const TrustLevelChip({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingS - 2, // 6px — pill snugness
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DesignTokens.radiusS),
      ),
      child: Text(
        'TL$level',
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: DesignTokens.fontWeightSemiBold,
        ),
      ),
    );
  }
}
