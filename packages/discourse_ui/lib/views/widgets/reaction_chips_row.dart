import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post_reaction.dart';

import '../../theme/design_tokens.dart';
import 'reaction_glyph.dart';

/// Horizontal chip row showing emoji reactions on a Discourse post:
/// `❤️ 5`, `🚀 2`, etc. Tapping a chip the viewer already reacted with
/// (highlighted) toggles it off; tapping any other chip switches their
/// reaction to that emoji. Long-pressing a chip lists the users behind
/// that count ([onLongPress]); the trailing `+` chip opens the full
/// emoji picker ([onAddReaction]).
///
/// The proxy synthesizes a single heart entry on forums without the
/// `discourse-reactions` plugin, so a plain like shows up here too.
/// Hidden when [reactions] is empty — with nothing to count there is
/// nothing to show, and the react button carries the affordance.
class ReactionChipsRow extends StatelessWidget {
  final List<FCPostReaction> reactions;
  final ValueChanged<String> onTap;

  /// Long-press on a chip. Receives the reaction id so the caller can
  /// open the reactor list filtered to that emoji.
  final ValueChanged<String>? onLongPress;

  /// Used to resolve custom-emoji images in [ReactionGlyph].
  final SiteContext? siteContext;

  const ReactionChipsRow({
    super.key,
    required this.reactions,
    required this.onTap,
    this.onLongPress,
    this.siteContext,
  });

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Phase 5.29 — token-aligned chip styling. The pill radius
    // (14) is bigger than `radiusS` (8) and smaller than `radiusM`
    // (12); it intentionally hugs the chip content. Padding uses
    // `spacingS` horizontal / `spacingXS` vertical to read as a
    // compact pill at the same vertical rhythm as `TrustLevelChip`.
    return Padding(
      padding: const EdgeInsets.only(top: DesignTokens.spacingS),
      child: Wrap(
        spacing: DesignTokens.spacingXS,
        runSpacing: DesignTokens.spacingXS,
        children: [
          for (final r in reactions)
            _Chip(
              // Tap toggles, long-press lists who reacted.
              onTap: () => onTap(r.id),
              onLongPress:
                  onLongPress == null ? null : () => onLongPress!(r.id),
              semanticLabel: r.viewerReacted
                  ? 'Remove your ${r.id} reaction. ${r.count} total. Long press to see who reacted.'
                  : 'React with ${r.id}. ${r.count} total. Long press to see who reacted.',
              selected: r.viewerReacted,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ReactionGlyph(
                    reactionId: r.id,
                    size: DesignTokens.fontSizeS - 1,
                    siteContext: siteContext,
                  ),
                  const SizedBox(width: DesignTokens.spacingXS),
                  Text(
                    r.count.toString(),
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: DesignTokens.fontWeightSemiBold,
                      color: r.viewerReacted
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One pill in the row. The fill lives on a [Material] (not on the
/// child's `BoxDecoration`) so the [InkWell] ripple paints *above* the
/// chip background instead of being hidden behind it.
class _Chip extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String semanticLabel;
  final bool selected;
  final Widget child;

  const _Chip({
    required this.onTap,
    required this.semanticLabel,
    required this.selected,
    required this.child,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(DesignTokens.radiusL - 6);

    return Semantics(
      label: semanticLabel,
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest
                .withValues(alpha: DesignTokens.opacityMediumLow),
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: radius,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingS,
              vertical: DesignTokens.spacingXS - 1,
            ),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: selected
                    ? colorScheme.primary
                        .withValues(alpha: DesignTokens.opacityMedium)
                    : colorScheme.outlineVariant
                        .withValues(alpha: DesignTokens.opacityDivider),
                width: selected
                    ? DesignTokens.borderWidthThin
                    : DesignTokens.borderWidthThin / 2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
