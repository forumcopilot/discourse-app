import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import '../search_page.dart';

class TopicsTabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoggedIn;
  final SiteContext siteContext;

  /// Overrides the implied leading widget (the drawer's hamburger).
  final Widget? leading;

  const TopicsTabAppBar({
    required this.siteContext,
    this.isLoggedIn = false,
    this.leading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      // Phase 5.18a — auto-imply true so the parent Scaffold's drawer
      // hamburger renders as the leading icon. Chat moved out of the
      // AppBar actions because it lives in the primary bottom nav now
      // (when the plugin is enabled).
      leading: leading,
      title: Text(
        AppLocalizations.of(context)?.home ?? 'Home',
      ),
      actions: [
        if (isLoggedIn) _buildSearchButton(context, colorScheme),
      ],
    );
  }

  Widget _buildSearchButton(BuildContext context, ColorScheme colorScheme) {
    return IconButton(
      icon: const Icon(Icons.manage_search_rounded),
      tooltip: AppLocalizations.of(context)?.search ?? 'Search',
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SearchPage(siteContext: siteContext)),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

