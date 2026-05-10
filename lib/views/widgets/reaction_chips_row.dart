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

    return Padding(
      padding: const EdgeInsets.only(top: DesignTokens.spacingS),
      child: Wrap(
        spacing: DesignTokens.spacingXS,
        runSpacing: DesignTokens.spacingXS,
        children: [
          for (final r in reactions)
            InkWell(
              onTap: () => onTap(r.id),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: r.viewerReacted
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest
                          .withOpacity(0.55),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: r.viewerReacted
                        ? colorScheme.primary.withOpacity(0.6)
                        : colorScheme.outlineVariant.withOpacity(0.45),
                    width: r.viewerReacted ? 1.0 : 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_glyphFor(r.id),
                        style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 4),
                    Text(
                      r.count.toString(),
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
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
