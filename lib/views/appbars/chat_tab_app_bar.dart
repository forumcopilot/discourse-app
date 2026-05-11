import 'package:flutter/material.dart';
import 'package:forumcopilot_flutter/theme/design_tokens.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

/// AppBar for the Chat bottom-nav tab (Phase 5.18a). Matches the
/// visual cadence of `TopicsTabAppBar` / `ForumsTabAppBar` — surface
/// background, elevation 3, drawer hamburger in the leading slot via
/// `automaticallyImplyLeading: true`.
///
/// The Refresh action that used to live on `ChatChannelListPage`'s
/// standalone AppBar is intentionally dropped here — the embedded
/// `ChatChannelListPage(embedded: true)` body still exposes
/// pull-to-refresh, and a redundant button button would compete with
/// the search/markRead patterns used by sibling tabs. We can add it
/// back as an icon action later if the gesture proves unreliable.
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 3,
      shadowColor: colorScheme.shadow.withOpacity(DesignTokens.opacityLow),
      surfaceTintColor: colorScheme.surfaceTint,
      title: Text(
        'Chat',
        style: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
          fontSize: DesignTokens.fontSizeL,
        ),
      ),
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
