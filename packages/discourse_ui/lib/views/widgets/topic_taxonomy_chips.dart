import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../theme/design_tokens.dart';
import '../tag_topics_page.dart';
import 'category_badge.dart';

/// A topic's category badge and tag chips, in one row that wraps.
///
/// The same row on the topic list and the topic page, so a topic looks like
/// itself whether you are scanning a list or reading it. Discourse organises
/// everything by category and tag; the topic page named the topic and
/// nothing else, so the moment you opened something you lost all sense of
/// where it lived. The two used to be drawn separately and had drifted
/// apart (a border here, tappable tags there); now there is one.
class TopicTaxonomyChips extends StatelessWidget {
  const TopicTaxonomyChips({
    super.key,
    required this.siteContext,
    this.categoryId = '',
    this.categoryName = '',
    this.tags = const [],
    this.maxTags,
    this.large = false,
    this.padding = EdgeInsets.zero,
  });

  final SiteContext siteContext;

  /// The category to badge; empty for none (a row inside that category).
  final String categoryId;

  /// Shown until the forum's categories are known.
  final String categoryName;
  final List<String> tags;

  /// Tags beyond this become "+N": a list row is a glance, not an index.
  /// Null shows them all.
  final int? maxTags;

  /// The topic page's size.
  final bool large;

  /// Around the row, only when it draws something.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final showCategory = (categoryId.isNotEmpty || categoryName.isNotEmpty) &&
        CategoryBadge.shows(siteContext, categoryId, fallbackName: categoryName);
    if (!showCategory && tags.isEmpty) return const SizedBox.shrink();
    final limit = maxTags;
    final shown = limit == null ? tags : tags.take(limit);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: padding,
      child: Wrap(
        spacing: DesignTokens.spacingS,
        runSpacing: DesignTokens.spacingXS,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (showCategory)
            CategoryBadge(
              siteContext: siteContext,
              categoryId: categoryId,
              fallbackName: categoryName,
              large: large,
            ),
          for (final tag in shown) TagChip(siteContext: siteContext, tag: tag),
          if (limit != null && tags.length > limit)
            Text(
              '+${tags.length - limit}',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                letterSpacing: DesignTokens.letterSpacingWide,
              ),
            ),
        ],
      ),
    );
  }
}

/// A tag, as a chip that opens its topic list. Tags have no colour of their
/// own in Discourse; the web draws them in the forum's palette, and so does
/// this (the theme is the forum's).
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.siteContext, required this.tag});

  final SiteContext siteContext;
  final String tag;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(DesignTokens.radiusS);
    // A DecoratedBox, not a clipped Material: an antialiased clip is a
    // saveLayer per chip per row.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: radius,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => TagTopicsPage(siteContext: siteContext, tag: tag),
        )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Text(
            tag,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: DesignTokens.letterSpacingWide,
            ),
          ),
        ),
      ),
    );
  }
}
