import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

/// Shimmer placeholder that mirrors `TopicListItem`'s footprint: leading
/// circular avatar, a two-line title, the category/tag chips, the activity
/// line and an inset divider — the same height as a real row, so the list
/// doesn't jump when the topics arrive. Renders a fixed [rowCount] of placeholder rows wrapped in a
/// single [Shimmer.fromColors] so the gradient sweep stays in sync
/// across rows.
///
/// Used as the first-load state on the high-traffic topic lists so the
/// user sees the eventual layout taking shape instead of an empty
/// spinner — perceived performance win at zero cost.
class TopicListSkeleton extends StatelessWidget {
  final int rowCount;

  /// Set true when the skeleton is embedded as an item inside a parent
  /// scroll view (e.g. the Home tab renders list items into an outer
  /// ListView via `buildTopicItems()`); the inner ListView then sizes
  /// itself to its children instead of demanding unbounded height.
  final bool shrinkWrap;

  const TopicListSkeleton({
    super.key,
    this.rowCount = 8,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Static rows. The shimmer was a ShaderMask saveLayer on every frame
    // during first load, when the UI thread is already the bottleneck.
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: shrinkWrap,
        itemCount: rowCount,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          thickness: 1,
          indent: 72,
          color: colorScheme.outlineVariant,
        ),
        itemBuilder: (context, _) => const _TopicSkeletonRow(),
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
          const SizedBox(width: DesignTokens.spacingL),
          // Title, chips and activity placeholders, at the real row's
          // line heights.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: DesignTokens.spacingXS),
                _ShimmerBar(width: double.infinity, height: 16, color: block),
                const SizedBox(height: DesignTokens.spacingS),
                _ShimmerBar(width: 200, height: 16, color: block),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _ShimmerBar(width: 88, height: 20, color: block),
                    const SizedBox(width: DesignTokens.spacingS),
                    _ShimmerBar(width: 56, height: 20, color: block),
                  ],
                ),
                const SizedBox(height: 10),
                _ShimmerBar(width: 180, height: 12, color: block),
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
