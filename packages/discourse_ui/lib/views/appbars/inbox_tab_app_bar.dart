import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

/// Header for the combined Chat + Messages bottom-nav slot: no title.
///
/// The slot's own "Chat | Messages" tab bar is the header. A title above it
/// either repeated one of those words ("Chat" over "Chat | Messages") or
/// invented an umbrella — "Inbox" — that Discourse uses for something else
/// (the personal-message folder, which the Messages tab now shows as
/// "Inbox | Archive"). Discourse has no term covering chat and personal
/// messages together, so this bar only paints behind the status bar and
/// takes no height of its own.
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
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      toolbarHeight: 0,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(0);
}
