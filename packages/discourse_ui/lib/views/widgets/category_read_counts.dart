import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities, DiscourseTopicTracking;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';

/// "1 new · 2 unread" for a category and its subcategories, in the accent,
/// as web's categories page shows them. Nothing for a guest, before the
/// viewer's tracking report has loaded, or when both are zero.
class CategoryReadCounts extends StatelessWidget {
  const CategoryReadCounts({
    super.key,
    required this.siteContext,
    required this.categoryId,
    this.padding = EdgeInsets.zero,
  });

  final SiteContext siteContext;
  final String categoryId;

  /// Around the counts when there are any; nothing is drawn, padding
  /// included, when there are none.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(categoryId);
    if (!siteContext.isLoggedIn || id == null) return const SizedBox.shrink();
    final tracking = DiscourseTopicTracking.forSite(siteContext);
    final ids = DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl)
        .categoryWithDescendants(id);
    return ListenableBuilder(
      listenable: tracking,
      builder: (context, _) {
        final counts = tracking.counts(categoryIds: ids);
        final newTopics = counts?.newTopics ?? 0;
        final unreadTopics = counts?.unreadTopics ?? 0;
        if (newTopics == 0 && unreadTopics == 0) {
          return const SizedBox.shrink();
        }
        final l10n = AppLocalizations.of(context)!;
        final style = Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.primary);
        return Padding(
          padding: padding,
          child: Wrap(
            spacing: DesignTokens.spacingM,
            children: [
              if (newTopics > 0)
                Text(l10n.categoryNewTopics(newTopics), style: style),
              if (unreadTopics > 0)
                Text(l10n.categoryUnreadTopics(unreadTopics), style: style),
            ],
          ),
        );
      },
    );
  }
}
