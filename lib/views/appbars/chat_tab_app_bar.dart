import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../widgets/simple_list_app_bar.dart';

/// AppBar for the Chat bottom-nav tab (Phase 5.18a).
///
/// Phase 5.18d: rebuilt as a thin wrapper around `SimpleListAppBar`
/// so it picks up the same elevation / shadow / title cadence as
/// every other directory page in the app. We keep the dedicated
/// class so callers (`site_home_page.dart`'s `_buildAppBarForCurrentTab`)
/// can switch on it the same way they switch on
/// `TopicsTabAppBar` etc.
///
/// The Refresh action that used to live on the standalone
/// `ChatChannelListPage` AppBar stays dropped — the embedded body's
/// pull-to-refresh covers that, and a redundant icon button would
/// fight the search/markRead patterns used by sibling tabs.
class ChatTabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoggedIn;
  final SiteContext siteContext;

  const ChatTabAppBar({
    super.key,
    required this.siteContext,
    this.isLoggedIn = false,
  });

  @override
  Widget build(BuildContext context) {
    return const SimpleListAppBar(title: 'Chat');
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
