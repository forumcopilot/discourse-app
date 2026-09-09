import 'package:flutter/material.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities;
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:get/get.dart';

import '../../config/app_forum_config.dart';
import '../../controllers/login_controller.dart';
import '../../theme/design_tokens.dart';
import '../badges_directory_page.dart';
import '../bookmarks_page.dart';
import '../drafts_list_page.dart';
import '../groups_list_page.dart';
import '../invites_page.dart';
import '../login_page.dart';
import '../moderation/reviewables_page.dart';
import '../settings/notification_settings_page.dart';
import '../tags_page.dart';
import '../users_directory_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../host/discourse_host.dart';
import 'brand_image.dart';

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
                  // Only inside a multi-forum host: the way back to its
                  // list. A host says so through DiscourseHost.switchForum;
                  // failing that, a route below this shell means we were
                  // pushed on top of one. Standalone builds show nothing.
                  if (DiscourseHost.switchForum != null ||
                      Navigator.of(context).canPop()) ...[
                    _DrawerRow(
                      icon: Icons.grid_view_rounded,
                      title: AppLocalizations.of(context)!.switchForum,
                      onTap: () {
                        Navigator.of(context).pop(); // close drawer
                        final hook = DiscourseHost.switchForum;
                        if (hook != null) {
                          hook();
                        } else {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        }
                      },
                    ),
                    const Divider(height: 1),
                  ],
                  _SectionLabel(label: AppLocalizations.of(context)!.explore),
                  _DrawerRow(
                    icon: Icons.label_outline,
                    title: AppLocalizations.of(context)!.tags,
                    onTap: () => _push(
                      context,
                      TagsPage(siteContext: siteContext),
                    ),
                  ),
                  const Divider(height: 1),
                  _SectionLabel(label: AppLocalizations.of(context)!.community),
                  _DrawerRow(
                    icon: Icons.people_outline,
                    title: AppLocalizations.of(context)!.users,
                    onTap: () => _push(
                      context,
                      UsersDirectoryPage(siteContext: siteContext),
                    ),
                  ),
                  _DrawerRow(
                    icon: Icons.groups_outlined,
                    title: AppLocalizations.of(context)!.groups,
                    onTap: () => _push(
                      context,
                      GroupsListPage(siteContext: siteContext),
                    ),
                  ),
                  _DrawerRow(
                    icon: Icons.emoji_events_outlined,
                    title: AppLocalizations.of(context)!.badges,
                    onTap: () => _push(
                      context,
                      BadgesDirectoryPage(siteContext: siteContext),
                    ),
                  ),
                  // Invites — Discourse-native shareable invite links /
                  // email invites. Whether the user may actually invite is
                  // decided server-side (invite_allowed_groups); the page
                  // surfaces the 403 case itself, so the row only gates on
                  // being signed in.
                  if (siteContext.isLoggedIn)
                    _DrawerRow(
                      icon: Icons.person_add_alt_outlined,
                      title: AppLocalizations.of(context)!.invites,
                      onTap: () => _push(
                        context,
                        InvitesPage(siteContext: siteContext),
                      ),
                    ),
                  // Review queue — staff-only surface (flags, queued
                  // posts). `canModerate` is set at login from the
                  // current-user payload (`admin || moderator`), which is
                  // exactly Discourse's "staff" notion.
                  if (siteContext.isLoggedIn &&
                      (siteContext.loginDataOutput?.user?.canModerate ??
                          false))
                    _DrawerRow(
                      icon: Icons.fact_check_outlined,
                      title: AppLocalizations.of(context)!.reviewQueue,
                      onTap: () => _push(
                        context,
                        ReviewablesPage(siteContext: siteContext),
                      ),
                    ),
                  const Divider(height: 1),
                  _SectionLabel(label: AppLocalizations.of(context)!.account),
                  // Your own content, above the settings rows — Bookmarks
                  // and Drafts are things you go *read*, while Notifications
                  // and Privacy are things you go *configure*. Both moved
                  // off the Profile tab, which had grown a second nav card
                  // duplicating this section.
                  if (siteContext.isLoggedIn) ...[
                    _DrawerRow(
                      icon: Icons.bookmark_outline,
                      title: AppLocalizations.of(context)!.bookmarks,
                      onTap: () => _push(
                        context,
                        BookmarksPage(siteContext: siteContext),
                      ),
                    ),
                    _DrawerRow(
                      icon: Icons.edit_note_outlined,
                      title: AppLocalizations.of(context)!.drafts,
                      onTap: () => _push(
                        context,
                        DraftsListPage(siteContext: siteContext),
                      ),
                    ),
                  ],
                  _DrawerRow(
                    icon: Icons.settings_outlined,
                    title: AppLocalizations.of(context)!.notifications,
                    onTap: () => _push(
                      context,
                      const NotificationSettingsPage(),
                    ),
                  ),
                  // Real links, not a "coming soon" snackbar. /site.json
                  // has carried tos_url and privacy_policy_url all along —
                  // the connector was already parsing both into
                  // DiscourseSiteCapabilities and nothing read them.
                  _DrawerRow(
                    icon: Icons.gavel_outlined,
                    title: AppLocalizations.of(context)!.termsOfService,
                    onTap: () => _openLegal(context, _legalUrl(
                      DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl)
                          .tosUrl,
                      '/tos',
                    )),
                  ),
                  _DrawerRow(
                    icon: Icons.policy_outlined,
                    title: AppLocalizations.of(context)!.privacyPolicy,
                    onTap: () => _openLegal(context, _legalUrl(
                      DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl)
                          .privacyPolicyUrl,
                      '/privacy',
                    )),
                  ),
                  if (siteContext.isLoggedIn)
                    _DrawerRow(
                      icon: Icons.logout,
                      title: AppLocalizations.of(context)!.signOut,
                      iconColor: colorScheme.error,
                      onTap: () => _confirmSignOut(context),
                    )
                ],
              ),
            ),
            // Build / version footer so users can identify which app
            // build they're on when filing issues. Quiet, low-contrast.
            _Footer(siteName: siteContext.site.name),
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

  /// Resolves a legal URL from the site setting, falling back to
  /// Discourse's canonical path.
  ///
  /// The setting comes both ways: meta.discourse.org returns "/tos"
  /// (site-relative) and an absolute "https://www.discourse.org/privacy"
  /// for the privacy policy, because a hosted forum can point that one at
  /// the company's own page. Absolute wins as given; relative is joined
  /// to the forum; empty falls back to the built-in page, which every
  /// Discourse serves.
  String _legalUrl(String? configured, String fallbackPath) {
    final base = siteContext.site.url.replaceAll(RegExp(r'/+$'), '');
    final value = (configured ?? '').trim();
    if (value.isEmpty) return '$base$fallbackPath';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return '$base${value.startsWith('/') ? '' : '/'}$value';
  }

  Future<void> _openLegal(BuildContext context, String url) async {
    Navigator.of(context).pop();
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ignore: unused_element
  void _comingSoon(BuildContext context, String label) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.comingSoon(label)),
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
          title: Text(AppLocalizations.of(context)!.signOutQuestion),
          content: Text(
            AppLocalizations.of(context)!.signOutWarning(siteContext.site.name),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: colorScheme.error),
              child: Text(AppLocalizations.of(context)!.signOut),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    final loginController = Get.isRegistered<DiscourseLoginController>()
        ? Get.find<DiscourseLoginController>()
        : Get.put(DiscourseLoginController());
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
    final caps = DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl);
    // Same rule as the forum header: a dark-mode logo only if the forum
    // ships one; the header block is our primaryContainer either way.
    final wideLogo = caps.wideLogoFor(
      dark: Theme.of(context).brightness == Brightness.dark && caps.hasDarkLogo,
    );
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
          // The forum's wordmark, where web puts it. This slot is
          // full-width, which is the shape the wide logo is drawn for —
          // and the wordmark *is* the forum's name as art, so it replaces
          // the name text rather than sitting beside it and saying the
          // same thing twice. Forums that publish no logo keep the
          // icon-and-name treatment.
          if (wideLogo != null)
            Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                // Height-bounded, width free: Discourse's logo has no
                // fixed aspect ratio (148×40 here, but arbitrary), so the
                // only safe constraint is the one web uses — cap the
                // height and let the width follow.
                constraints: const BoxConstraints(maxHeight: 32),
                child: BrandImage(
                  wideLogo,
                  height: 32,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                  fallback: _nameRow,
                ),
              ),
            )
          else
            _nameRow(context),
          const SizedBox(height: DesignTokens.spacingM),
          Text(
            isLoggedIn && username != null
                ? AppLocalizations.of(context)!.signedInAs(username)
                : AppLocalizations.of(context)!.notSignedIn,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimaryContainer
                  .withValues(alpha: DesignTokens.opacityHigh),
            ),
          ),
          // Sign in where the state is announced, not at the end of the
          // list. Web keeps its Log In button in the header for the same
          // reason: it is the first thing a visitor looks for.
          if (!isLoggedIn) ...[
            const SizedBox(height: DesignTokens.spacingM),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop(); // close drawer
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => LoginPage(siteContext: siteContext),
                ));
              },
              icon: const Icon(Icons.login, size: 18),
              label: Text(AppLocalizations.of(context)!.signIn),
            ),
          ],
        ],
      ),
    );
  }
}

extension _HeaderFallback on _Header {
  /// The pre-logo treatment: a generic forum glyph and the site's name.
  /// Kept as the fallback for forums that publish no logo, and for a logo
  /// that fails to load.
  Widget _nameRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
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
            siteContext.site.name,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: DesignTokens.fontWeightSemiBold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
  final Color? iconColor;
  final VoidCallback onTap;

  const _DrawerRow({
    required this.icon,
    required this.title,
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
      onTap: onTap,
    );
  }
}

class _Footer extends StatelessWidget {
  final String? siteName;
  const _Footer({this.siteName});

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
        '${siteName ?? AppForumConfig.forumName} · v1',
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant
              .withValues(alpha: DesignTokens.opacityMedium),
        ),
      ),
    );
  }
}

