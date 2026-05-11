import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import 'tabs/tags_tab.dart';

/// Standalone wrapper around `TagsTab` for full-page navigation.
///
/// Phase 5.18a moved Tags out of the primary bottom nav (Chat or
/// Messages takes that slot now) and into the hamburger drawer. The
/// drawer pushes `TagsPage` as a `MaterialPageRoute`; the inner
/// `TagsTab` content is unchanged, just hosted under our own
/// `Scaffold` with an AppBar instead of being a tab in `SiteHomePage`.
class TagsPage extends StatelessWidget {
  final SiteContext siteContext;

  const TagsPage({super.key, required this.siteContext});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 3,
        shadowColor: colorScheme.shadow.withOpacity(0.3),
        surfaceTintColor: colorScheme.surfaceTint,
        title: Text(
          'Tags',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: TagsTab(
        isActive: true,
        siteContext: siteContext,
      ),
    );
  }
}
