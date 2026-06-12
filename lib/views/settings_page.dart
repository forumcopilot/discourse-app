import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/design_tokens.dart';
import 'change_email_page.dart';
import 'ignored_users_page.dart';
import 'settings/notification_settings_page.dart';
import 'widgets/simple_list_app_bar.dart';

/// Phase 5.20d — Forum Settings page rebuilt as a curated Discourse-
/// native section list.
///
/// The original implementation called `getUserSettingsCategories()`
/// (XF-shaped flat list of typed categories) which returned `[]` on
/// Discourse — Discourse exposes preferences as a flat structure
/// under `/u/{me}.json#user_option`, not as nested categories. The
/// resulting page rendered an empty "No settings available" state
/// with just a Delete Account block at the bottom.
///
/// New page surfaces the actual settings entry points the app
/// supports natively, plus a link to the full Discourse-web prefs
/// for anything not modelled in the app.
class ForumSettingsPage extends StatelessWidget {
  final SiteContext siteContext;

  const ForumSettingsPage({super.key, required this.siteContext});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: const SimpleListAppBar(title: 'Account & preferences'),
      body: ListView(
        children: [
          _Section(label: 'Preferences'),
          ListTile(
            leading: Icon(Icons.notifications_outlined,
                color: colorScheme.onSurfaceVariant),
            title: const Text('Notifications'),
            subtitle: Text(
              'Email frequency, like aggregation, digest schedule',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NotificationSettingsPage(),
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.open_in_new_rounded,
                color: colorScheme.onSurfaceVariant),
            title: const Text('Manage account on web'),
            subtitle: Text(
              'Profile, email, password, security, advanced settings',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant),
            onTap: () => _openWebPreferences(context),
          ),
          const Divider(height: 1),
          _Section(label: 'Account'),
          ListTile(
            leading: Icon(Icons.alternate_email_rounded,
                color: colorScheme.onSurfaceVariant),
            title: const Text('Change email'),
            subtitle: Text(
              "We'll send a verification link to the new address",
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant),
            onTap: () => _openChangeEmail(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.password_rounded,
                color: colorScheme.onSurfaceVariant),
            title: const Text('Change password'),
            subtitle: Text(
              'Trigger a password-reset email to your current address',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant),
            onTap: () => _confirmPasswordReset(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.notifications_off_outlined,
                color: colorScheme.onSurfaceVariant),
            title: const Text('Ignored users'),
            subtitle: Text(
              'See and manage users whose posts are hidden from you',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    IgnoredUsersPage(siteContext: siteContext),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.spacingL,
              DesignTokens.spacingL,
              DesignTokens.spacingL,
              DesignTokens.spacingL,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius:
                    BorderRadius.circular(DesignTokens.radiusM),
                border: Border.all(
                  color: colorScheme.outlineVariant
                      .withValues(alpha: DesignTokens.opacityDivider),
                  width: DesignTokens.borderWidthThin,
                ),
              ),
              padding:
                  const EdgeInsets.all(DesignTokens.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delete account',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight:
                          DesignTokens.fontWeightSemiBold,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingS),
                  Text(
                    'Removing your account is handled on the forum. '
                    'Continue to open the site and contact the staff '
                    'team — Discourse forums process deletions per '
                    'their own policy.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingM),
                  FilledButton(
                    onPressed: () => _showDeleteAccountDialog(
                        context, colorScheme, textTheme),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                      padding: DesignTokens.paddingExtendedButton,
                      elevation: DesignTokens.elevationMedium,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            DesignTokens.radiusExtendedButton),
                      ),
                    ),
                    child: const Text('Delete account'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Phase 5.23 — push the dedicated change-email page. On success
  /// (the user submitted a new address and Discourse accepted the
  /// request, sending a verification email), surface a confirm
  /// snackbar so the user knows to check their inbox.
  Future<void> _openChangeEmail(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final sent = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChangeEmailPage(siteContext: siteContext),
      ),
    );
    if (sent == true) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Verification email sent — click the link to confirm '
            'your new address.',
          ),
        ),
      );
    }
  }

  /// Phase 5.23 — trigger Discourse's password-reset flow. There's
  /// no inline "change password" against the User API Key surface
  /// (the web UI uses session cookies + CSRF), so Discourse's mobile
  /// pattern is "send me a reset email" — same flow as forgot-
  /// password, just initiated by an authenticated user.
  ///
  /// Confirmation dialog first because this triggers an immediate
  /// email — accidental taps would be annoying.
  Future<void> _confirmPasswordReset(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Change password'),
          content: const Text(
            'We’ll email you a password-reset link. Click it to '
            'choose a new password — the change is handled on the '
            'forum, not in this app.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'Send reset email',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: DesignTokens.fontWeightSemiBold,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final proxy = SiteProxyFactory.getAccountProxy();
      // The XF-shape API passes (oldPassword, newPassword) — the
      // Discourse impl ignores both and just POSTs the reset
      // endpoint. Empty strings keep the IFC contract satisfied.
      final result = await proxy.updatePassword('', '');
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.result
                ? (result.resultText?.isNotEmpty == true
                    ? result.resultText!
                    : 'Password-reset email sent.')
                : (result.resultText?.isNotEmpty == true
                    ? result.resultText!
                    : "Couldn't send reset email"),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Request failed: $e')),
      );
    }
  }

  /// Open the Discourse user-preferences page in the system browser.
  /// The user is already signed in there (or gets prompted), and the
  /// full prefs surface — themes, sidebar tags, watched categories,
  /// security, group memberships — is well outside what we model in
  /// the app's typed prefs page.
  Future<void> _openWebPreferences(BuildContext context) async {
    final baseUrl = siteContext.site.url;
    if (baseUrl.isEmpty) {
      _toast(context, 'Forum URL is unavailable.');
      return;
    }
    // Discourse maps `/my/preferences` to the current user's
    // preferences page — works without needing to know the
    // username here.
    final uri = Uri.parse(baseUrl).resolve('/my/preferences');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _toast(context, "Couldn't open the preferences page.");
    }
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            'Delete account',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: DesignTokens.fontWeightMedium,
            ),
          ),
          content: Text(
            'Your account is managed by the forum. Please contact the '
            'forum staff directly to request account removal. Continue '
            'will open the forum in your browser so you can use the '
            'site’s own contact / staff message flow.',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _openForumHomePage(context);
              },
              child: Text(
                'Continue',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openForumHomePage(BuildContext context) async {
    final url = siteContext.site.url;
    if (url.isEmpty) {
      _toast(context, 'Forum URL is unavailable.');
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _toast(context, "Couldn't open the forum URL.");
    }
  }

  void _toast(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
        ),
        backgroundColor: colorScheme.errorContainer,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  const _Section({required this.label});

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
