import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/design_tokens.dart';

/// Shimmer placeholder that mirrors `TopicListItem`'s footprint: leading
/// circular avatar, two stacked title lines, a meta-row, and a bottom
/// divider. Renders a fixed [rowCount] of placeholder rows wrapped in a
/// single [Shimmer.fromColors] so the gradient sweep stays in sync
/// across rows.
///
/// Used as the first-load state on the high-traffic topic lists so the
/// user sees the eventual layout taking shape instead of an empty
/// spinner — perceived performance win at zero cost.
class TopicListSkeleton extends StatelessWidget {
  final int rowCount;

  const TopicListSkeleton({super.key, this.rowCount = 8});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final base = colorScheme.surfaceContainerHighest;
    final highlight = colorScheme.surface;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      // Use a slower period than the default so the sweep doesn't feel
      // anxious on screens that load quickly.
      period: const Duration(milliseconds: 1400),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rowCount,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          thickness: 1,
          color: colorScheme.outlineVariant
              .withOpacity(DesignTokens.opacityLow),
        ),
        itemBuilder: (context, _) => const _TopicSkeletonRow(),
      ),
    );
  }
}

class _TopicSkeletonRow extends StatelessWidget {
  const _TopicSkeletonRow();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final block = colorScheme.surfaceContainerHighest;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingL,
        vertical: DesignTokens.spacingM,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar placeholder
          CircleAvatar(
            radius: DesignTokens.avatarRadiusM,
            backgroundColor: block,
          ),
          const SizedBox(width: DesignTokens.spacingM),
          // Title + meta placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBar(width: double.infinity, height: 14, color: block),
                const SizedBox(height: DesignTokens.spacingXS + 2),
                _ShimmerBar(width: 220, height: 14, color: block),
                const SizedBox(height: DesignTokens.spacingM),
                _ShimmerBar(width: 140, height: 10, color: block),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _ShimmerBar({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
      ),
    );
  }
}
