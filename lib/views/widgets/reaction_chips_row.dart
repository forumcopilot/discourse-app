import 'package:discourse_core/discourse_core.dart' show DiscourseReaction;
import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

/// Horizontal chip row showing emoji reactions on a Discourse post:
/// `❤️ 5`, `🚀 2`, etc. Tapping a chip the viewer already reacted with
/// (highlighted) toggles it off; tapping any other chip switches their
/// reaction to that emoji.
///
/// Hidden when [reactions] is empty so it doesn't take up space on
/// forums without the plugin.
class ReactionChipsRow extends StatelessWidget {
  final List<DiscourseReaction> reactions;
  final ValueChanged<String> onTap;

  const ReactionChipsRow({
    super.key,
    required this.reactions,
    required this.onTap,
  });

  String _glyphFor(String shortcode) {
    final clean = shortcode.replaceAll(':', '').trim();
    final emoji = Emoji.byShortName(clean);
    if (emoji != null && emoji.char.isNotEmpty) return emoji.char;
    return ':$clean:';
  }

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
            InkWell(
              onTap: () => onTap(r.id),
              borderRadius: BorderRadius.circular(DesignTokens.radiusL - 6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingS,
                  vertical: DesignTokens.spacingXS - 1,
                ),
                decoration: BoxDecoration(
                  color: r.viewerReacted
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest
                          .withOpacity(DesignTokens.opacityMediumLow),
                  borderRadius:
                      BorderRadius.circular(DesignTokens.radiusL - 6),
                  border: Border.all(
                    color: r.viewerReacted
                        ? colorScheme.primary
                            .withOpacity(DesignTokens.opacityMedium)
                        : colorScheme.outlineVariant
                            .withOpacity(DesignTokens.opacityDivider),
                    width: r.viewerReacted
                        ? DesignTokens.borderWidthThin
                        : DesignTokens.borderWidthThin / 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _glyphFor(r.id),
                      style: const TextStyle(
                          fontSize: DesignTokens.fontSizeS - 1),
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
            ),
        ],
      ),
    );
  }
}
