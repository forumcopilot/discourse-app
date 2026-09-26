import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

/// The heading over a group of list rows: settings groups, drawer
/// sections, badge tiers.
///
/// Material 3's list subheader: `titleSmall` (14sp w500) in sentence case,
/// in the primary colour, 16dp in from the start with 16dp above and 8dp
/// below. These were drawn four ways — 11sp w600 ALL CAPS with wide
/// tracking in the drawer and settings, 16sp sentence case in ABDA's
/// settings — so moving between them changed the look of the same thing.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key, this.color});

  final String text;

  /// Defaults to `colorScheme.primary`. The navigation drawer passes
  /// `onSurfaceVariant`, as Material 3's drawer headlines are.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spacingL,
        DesignTokens.spacingL,
        DesignTokens.spacingL,
        DesignTokens.spacingS,
      ),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: theme.textTheme.titleSmall?.copyWith(
            color: color ?? theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
