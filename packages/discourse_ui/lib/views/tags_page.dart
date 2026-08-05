import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import 'tabs/tags_tab.dart';
import 'widgets/simple_list_app_bar.dart';

/// Standalone wrapper around `TagsTab` for full-page navigation.
///
/// Phase 5.18a moved Tags out of the primary bottom nav (Chat or
/// Messages takes that slot now) and into the hamburger drawer. The
/// drawer pushes `TagsPage` as a `MaterialPageRoute`; the inner
/// `TagsTab` content is unchanged, just hosted under our own
/// `Scaffold` with an AppBar instead of being a tab in `SiteHomePage`.
///
/// Phase 5.18d: AppBar consolidated onto the shared `SimpleListAppBar`
/// to keep the visual cadence consistent with every other drawer-
/// pushed destination (Users / Groups / Badges / Drafts / Messages).
class TagsPage extends StatelessWidget {
  final SiteContext siteContext;

  const TagsPage({super.key, required this.siteContext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleListAppBar(title: 'Tags'),
      body: TagsTab(
        isActive: true,
        siteContext: siteContext,
      ),
    );
  }
}
