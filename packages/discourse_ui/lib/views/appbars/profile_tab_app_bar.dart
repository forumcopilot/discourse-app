import 'package:flutter/material.dart';
import 'package:discourse_ui/controllers/login_controller.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:get/get.dart';

class ProfileTabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoggedIn;
  final SiteContext siteContext;
  const ProfileTabAppBar({
    required this.siteContext,
    this.isLoggedIn = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      // Phase 5.18a — auto-imply true so the drawer hamburger renders.
      // The sign-out action moved into the drawer's Account section
      // but we keep the AppBar logout icon as a discoverability backup.
      title: Text(
        AppLocalizations.of(context)?.profile ?? 'Profile',
      ),
      actions: [
        // Users lives in the drawer. It was in both places, and the app
        // bar is the wrong one — a people directory is forum-wide
        // navigation, not an action on the profile you are looking at.
        if (isLoggedIn) _buildLogoutButton(context, colorScheme),
      ],
    );
  }


  Widget _buildLogoutButton(BuildContext context, ColorScheme colorScheme) {
    return IconButton(
      icon: const Icon(Icons.logout_rounded),
      tooltip: AppLocalizations.of(context)?.logout ?? 'Logout',
      onPressed: () => _showLogoutConfirmation(context, colorScheme),
    );
  }

  void _showLogoutConfirmation(BuildContext context, ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)?.logout ?? 'Logout',
          ),
          content: Text(
            AppLocalizations.of(context)?.areYouSureYouWantToLogout ?? 'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final loginController = Get.isRegistered<DiscourseLoginController>() ? Get.find<DiscourseLoginController>() : Get.put(DiscourseLoginController());
                await loginController.handleLogout(siteContext);
              },
              child: Text(
                AppLocalizations.of(context)?.logout ?? 'Logout',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
