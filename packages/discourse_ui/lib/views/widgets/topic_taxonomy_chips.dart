import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

/// A topic's category badge and tag chips, in one row that wraps.
///
/// The same pair the topic list row shows, so a topic looks like itself
/// whether you are scanning a list or reading it. Discourse organises
/// everything by category and tag; the topic page named the topic and
/// nothing else, so the moment you opened something you lost all sense of
/// where it lived.
class TopicTaxonomyChips extends StatelessWidget {
  const TopicTaxonomyChips({
    super.key,
    required this.category,
    required this.tags,
  });

  final String category;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (category.isEmpty && tags.isEmpty) return const SizedBox.shrink();

    Widget chip(String label, {required bool isCategory}) => Material(
          color: isCategory
              ? colorScheme.secondaryContainer
              : colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusS),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: isCategory
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: isCategory
                    ? DesignTokens.fontWeightSemiBold
                    : DesignTokens.fontWeightNormal,
                letterSpacing: DesignTokens.letterSpacingWide,
              ),
            ),
          ),
        );

    return Wrap(
      spacing: DesignTokens.spacingXS,
      runSpacing: DesignTokens.spacingXS,
      children: [
        if (category.isNotEmpty) chip(category, isCategory: true),
        for (final t in tags) chip(t, isCategory: false),
      ],
    );
  }
}
