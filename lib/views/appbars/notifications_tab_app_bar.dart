import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_flutter/theme/design_tokens.dart';
import '../../l10n/generated/app_localizations.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 3,
      shadowColor: colorScheme.shadow.withValues(alpha: DesignTokens.opacityLow),
      surfaceTintColor: colorScheme.surfaceTint,
      // Phase 5.18a — auto-imply true so the drawer hamburger renders.
      title: Text(
        AppLocalizations.of(context)?.notifications ?? 'Notifications',
        style: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
          fontSize: DesignTokens.fontSizeL,
        ),
      ),
      centerTitle: false,
      actions: [
        if (isLoggedIn && onMarkAllRead != null)
          IconButton(
            tooltip: 'Mark all read',
            icon: const Icon(Icons.done_all_rounded),
            onPressed: onMarkAllRead,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
