import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities;

import '../theme/design_tokens.dart';
import 'change_email_page.dart';
import 'ignored_users_page.dart';
import 'settings/notification_settings_page.dart';
import 'widgets/simple_list_app_bar.dart';
import '../utils/error_message.dart';
import '../l10n/generated/app_localizations.dart';

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
            title: Text(AppLocalizations.of(context)!.notifications),
            subtitle: Text(
              AppLocalizations.of(context)!.emailSettingsSubtitle,
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
            title: Text(AppLocalizations.of(context)!.manageAccountOnWeb),
            subtitle: Text(
              AppLocalizations.of(context)!.manageAccountSubtitle,
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
            title: Text(AppLocalizations.of(context)!.changeEmail),
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
            title: Text(AppLocalizations.of(context)!.changePassword),
            subtitle: Text(
              AppLocalizations.of(context)!.changePasswordSubtitle,
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
            title: Text(AppLocalizations.of(context)!.ignoredUsers),
            subtitle: Text(
              AppLocalizations.of(context)!.ignoredUsersSubtitle,
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
          // Legal links the forum publishes on /site.json. Rendered only
          // when it names them: the paths are per-forum (meta's tos_url is
          // the relative "/tos", its privacy policy an absolute
          // discourse.org URL), so both are resolved against the forum
          // base rather than assumed.
          ..._legalLinks(context, colorScheme, textTheme),
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
                    AppLocalizations.of(context)!.deleteAccount,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight:
                          DesignTokens.fontWeightSemiBold,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingS),
                  Text(
                    AppLocalizations.of(context)!.deleteAccountExplanation,
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
                    child: Text(AppLocalizations.of(context)!.deleteAccount),
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
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.verificationEmailSent,
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

  /// Terms / privacy rows, when the forum publishes them.
  ///
  /// App stores generally require a reachable privacy policy, and the
  /// forum is the only party that knows its own — so these are read
  /// rather than hardcoded, and simply absent on a forum that publishes
  /// neither.
  List<Widget> _legalLinks(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    final caps =
        DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl);
    final entries = <({String label, IconData icon, String url})>[
      if (caps.tosUrl?.isNotEmpty ?? false)
        (label: 'Terms of Service', icon: Icons.gavel_outlined, url: caps.tosUrl!),
      if (caps.privacyPolicyUrl?.isNotEmpty ?? false)
        (
          label: 'Privacy Policy',
          icon: Icons.privacy_tip_outlined,
          url: caps.privacyPolicyUrl!
        ),
    ];
    if (entries.isEmpty) return const [];
    return [
      for (final e in entries) ...[
        ListTile(
          leading: Icon(e.icon, color: colorScheme.onSurfaceVariant),
          title: Text(e.label),
          trailing: Icon(Icons.open_in_new,
              size: 18, color: colorScheme.onSurfaceVariant),
          onTap: () => _openForumUrl(context, e.url),
        ),
        const Divider(height: 1),
      ],
    ];
  }

  /// Opens a forum-published URL, which may be absolute or site-relative.
  Future<void> _openForumUrl(BuildContext context, String url) async {
    final uri = url.startsWith('http')
        ? Uri.parse(url)
        : Uri.parse(siteContext.site.url).resolve(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      _toast(context, "Couldn't open that page.");
    }
  }

  Future<void> _confirmPasswordReset(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.changePassword),
          content: Text(
            AppLocalizations.of(context)!.passwordResetExplanation,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                AppLocalizations.of(context)!.sendResetEmail,
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
        SnackBar(content: Text(describeError(e, fallback: 'Request failed.'))),
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
            AppLocalizations.of(context)!.deleteAccount,
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: DesignTokens.fontWeightMedium,
            ),
          ),
          content: Text(
            AppLocalizations.of(context)!.deleteAccountDialogBody,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                AppLocalizations.of(context)!.cancel,
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
                AppLocalizations.of(context)!.continueButton,
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
