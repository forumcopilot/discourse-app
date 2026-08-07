import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../widgets/simple_list_app_bar.dart';

/// AppBar for the combined Chat + Messages bottom-nav slot.
///
/// That slot hosts two lists behind a sub-tab bar, so its header names the
/// section rather than the selected sub-tab. Titling it "Chat" (as the old
/// `ChatTabAppBar` did) sat directly above a "Chat | Messages" tab bar — the word
/// appeared twice, six pixels apart — and swapping the title per sub-tab just
/// moved the problem, leaving the header shifting under the user mid-swipe.
///
/// "Inbox" is the umbrella both halves belong to: Discourse has no single term
/// covering chat channels and private messages, and reusing either sub-tab's own
/// name for the parent is what caused the collision.
///
/// A thin wrapper around `SimpleListAppBar` like its siblings, so it picks up the
/// same elevation / shadow / title cadence as every other directory page.
class InboxTabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoggedIn;
  final SiteContext siteContext;

  const InboxTabAppBar({
    super.key,
    required this.siteContext,
    this.isLoggedIn = false,
  });

  @override
  Widget build(BuildContext context) {
    // Not localized yet, matching ChatTabAppBar's existing 'Chat'. Sibling bars
    // use AppLocalizations; adding an `inbox` key would bring this in line.
    return const SimpleListAppBar(title: 'Inbox');
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
