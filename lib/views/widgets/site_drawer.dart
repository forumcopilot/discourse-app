import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:get/get.dart';

import '../../config/app_forum_config.dart';
import '../../controllers/login_controller.dart';
import '../../theme/design_tokens.dart';
import '../badges_directory_page.dart';
import '../groups_list_page.dart';
import '../login_page.dart';
import '../settings/notification_settings_page.dart';
import '../tags_page.dart';
import '../users_directory_page.dart';

/// Phase 5.18a — hamburger drawer ("More" menu).
///
/// Discourse web's mobile view hides utility surfaces under a hamburger
/// drawer; we follow that pattern so the bottom nav can stay at 5 items
/// while still exposing Tags, the community directories, and account
/// actions. The drawer slides over content (default Material drawer
/// behaviour) and is rooted on `SiteHomePage`'s `Scaffold`.
///
/// Sections — ordered by recency of need (frequent on top):
///   • Header — forum name, logged-in identity or sign-in CTA.
///   • Explore — Tags (moved out of bottom nav in 5.18a).
///   • Community — Users / Groups / Badges directories (5.18c lands
///     the real screens; currently placeholder rows so the IA is
///     visible in 5.18a).
///   • Account — Settings, Privacy & Terms (5.18b adds this), Sign
///     in / Sign out.
///
/// Each tap closes the drawer first (so the page transition is on top
/// of the closed-drawer state) and then pushes a `MaterialPageRoute`
/// to the destination. Destinations that don't exist yet show a
/// "coming soon" snackbar rather than crashing.
class SiteDrawer extends StatelessWidget {
  final SiteContext siteContext;

  const SiteDrawer({super.key, required this.siteContext});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Drawer(
      backgroundColor: colorScheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(siteContext: siteContext),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _SectionLabel(label: 'Explore'),
                  _DrawerRow(
                    icon: Icons.label_outline,
                    title: 'Tags',
                    subtitle: 'Browse every tag on the forum',
                    onTap: () => _push(
                      context,
                      TagsPage(siteContext: siteContext),
                    ),
                  ),
                  const Divider(height: 1),
                  _SectionLabel(label: 'Community'),
                  _DrawerRow(
                    icon: Icons.people_outline,
                    title: 'Users',
                    subtitle: 'Browse the user directory',
                    onTap: () => _push(
                      context,
                      UsersDirectoryPage(siteContext: siteContext),
                    ),
                  ),
                  _DrawerRow(
                    icon: Icons.groups_outlined,
                    title: 'Groups',
                    subtitle: 'See community groups',
                    onTap: () => _push(
                      context,
                      GroupsListPage(siteContext: siteContext),
                    ),
                  ),
                  _DrawerRow(
                    icon: Icons.emoji_events_outlined,
                    title: 'Badges',
                    subtitle: 'Achievements you can earn',
                    onTap: () => _push(
                      context,
                      BadgesDirectoryPage(siteContext: siteContext),
                    ),
                  ),
                  const Divider(height: 1),
                  _SectionLabel(label: 'Account'),
                  _DrawerRow(
                    icon: Icons.settings_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage notification preferences',
                    onTap: () => _push(
                      context,
                      const NotificationSettingsPage(),
                    ),
                  ),
                  _DrawerRow(
                    icon: Icons.policy_outlined,
                    title: 'Privacy & Terms',
                    onTap: () => _comingSoon(context, 'Privacy & Terms'),
                  ),
                  if (siteContext.isLoggedIn)
                    _DrawerRow(
                      icon: Icons.logout,
                      title: 'Sign out',
                      iconColor: colorScheme.error,
                      onTap: () => _confirmSignOut(context),
                    )
                  else
                    _DrawerRow(
                      icon: Icons.login,
                      title: 'Sign in',
                      onTap: () => _push(
                        context,
                        LoginPage(siteContext: siteContext),
                      ),
                    ),
                ],
              ),
            ),
            // Build / version footer so users can identify which app
            // build they're on when filing issues. Quiet, low-contrast.
            _Footer(),
          ],
        ),
      ),
    );
  }

  // Always close the drawer first so the route transition starts from
  // the closed state — looks cleaner and prevents the drawer being
  // re-opened by gestures while a destination is animating in.
  void _push(BuildContext context, Widget page) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _comingSoon(BuildContext context, String label) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — coming soon'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    Navigator.of(context).pop(); // close drawer first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: const Text('Sign out?'),
          content: Text(
            'You will be signed out of ${AppForumConfig.forumName}. You can sign back in any time.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: colorScheme.error),
              child: const Text('Sign out'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    final loginController = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put(LoginController());
    await loginController.handleLogout(siteContext);
  }
}

/// Drawer header. Logged in → forum name + username + trust-level chip.
/// Guest → forum name + "Not signed in" caption (the Sign in row in the
/// list handles the actual sign-in tap).
class _Header extends StatelessWidget {
  final SiteContext siteContext;
  const _Header({required this.siteContext});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLoggedIn = siteContext.isLoggedIn;
    final username = siteContext.loginDataOutput?.user?.username;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spacingL,
        DesignTokens.spacingL,
        DesignTokens.spacingL,
        DesignTokens.spacingL,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: DesignTokens.avatarRadiusM,
                backgroundColor: colorScheme.primary,
                child: Icon(
                  Icons.forum,
                  color: colorScheme.onPrimary,
                  size: DesignTokens.iconSizeM,
                ),
              ),
              const SizedBox(width: DesignTokens.spacingM),
              Expanded(
                child: Text(
                  AppForumConfig.forumName,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: DesignTokens.fontWeightSemiBold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingM),
          Text(
            isLoggedIn && username != null
                ? 'Signed in as $username'
                : 'Not signed in',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimaryContainer
                  .withOpacity(DesignTokens.opacityHigh),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spacingL,
        DesignTokens.spacingL,
        DesignTokens.spacingL,
        DesignTokens.spacingS,
      ),
      child: Text(
        label.toUpperCase(),
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          letterSpacing: DesignTokens.letterSpacingExtraWide,
          fontWeight: DesignTokens.fontWeightSemiBold,
        ),
      ),
    );
  }
}

class _DrawerRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final VoidCallback onTap;

  const _DrawerRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      leading: Icon(icon, color: iconColor ?? colorScheme.onSurfaceVariant),
      title: Text(
        title,
        style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingL,
        vertical: DesignTokens.spacingS,
      ),
      child: Text(
        '${AppForumConfig.forumName} · v1',
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant
              .withOpacity(DesignTokens.opacityMedium),
        ),
      ),
    );
  }
}

