import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';

class NotificationsTabAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool isLoggedIn;
  final SiteContext siteContext;

  /// Phase 5.32 — when supplied, an action icon
  /// (Icons.done_all_rounded) appears in the AppBar that calls
  /// `IFCSocialProxy.markAllAlertsReadAsync` and refreshes the
  /// list. Optional so the AppBar still renders cleanly on guest
  /// view (where there's nothing to mark).
  final VoidCallback? onMarkAllRead;

  const NotificationsTabAppBar({
    required this.siteContext,
    this.isLoggedIn = false,
    this.onMarkAllRead,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Phase 5.18a — auto-imply true so the drawer hamburger renders.
      title: Text(
        kitL10n(context).notifications,
      ),
      actions: [
        if (isLoggedIn && onMarkAllRead != null)
          IconButton(
            // Discourse's name for PUT /notifications/mark-read.
            tooltip: kitL10n(context).dismissAllNotifications,
            icon: const Icon(Icons.done_all_rounded),
            onPressed: onMarkAllRead,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
