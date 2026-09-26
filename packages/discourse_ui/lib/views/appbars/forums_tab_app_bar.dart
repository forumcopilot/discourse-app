import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import '../search_page.dart';
import '../widgets/forum_actions.dart';

class ForumsTabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoggedIn;
  final SiteContext siteContext;
  const ForumsTabAppBar({
    required this.siteContext,
    this.isLoggedIn = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      // Phase 5.18a — auto-imply true so the parent Scaffold's drawer
      // hamburger renders in the leading slot.
      title: Text(
        AppLocalizations.of(context)?.forums ?? 'Categories',
      ),
      actions: [
        if (isLoggedIn) _buildSearchButton(context, colorScheme),
        if (isLoggedIn) _buildMarkReadButton(context, colorScheme),
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

  Widget _buildMarkReadButton(BuildContext context, ColorScheme colorScheme) {
    return IconButton(
      icon: const Icon(Icons.done_all_rounded),
      tooltip: AppLocalizations.of(context)?.markForumRead ?? 'Mark category read',
      onPressed: () => _showMarkReadConfirmation(context),
    );
  }

  void _showMarkReadConfirmation(BuildContext context) {

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)?.markAllForumsAsRead ?? 'Mark all categories as read?',
        ),
        content: Text(
          AppLocalizations.of(context)?.markAllForumsAsReadMessage ?? 'This will mark all categories and topics as read. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ForumActions().markAllAsRead(context, '0');
            },
            child: Text(AppLocalizations.of(context)?.markAsRead ?? 'Mark as Read'),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
