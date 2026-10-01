import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:discourse_core/discourse_core.dart' show DiscourseUserProxy;

import '../controllers/login_controller.dart';
import '../theme/design_tokens.dart';
import 'change_email_page.dart';
import 'ignored_users_page.dart';
import 'widgets/simple_list_app_bar.dart';
import '../utils/error_message.dart';
import 'widgets/section_header.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:discourse_ui/utils/app_navigation.dart';

/// Account and privacy, opened from the Profile tab: changing email and
/// password, ignored users, the website's preferences for everything the
/// app doesn't model, and deleting the account.
class ForumSettingsPage extends StatelessWidget {
  final SiteContext siteContext;

  const ForumSettingsPage({super.key, required this.siteContext});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    Widget row(IconData icon, String title, String subtitle,
            VoidCallback onTap,
            {IconData trailing = Icons.chevron_right_rounded}) =>
        ListTile(
          leading: Icon(icon, color: colorScheme.onSurfaceVariant),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Icon(trailing, color: colorScheme.onSurfaceVariant),
          onTap: onTap,
        );
    // Notifications, Appearance and the forum's Terms and Privacy are on
    // the Profile tab that opens this page, so they are not repeated here.
    return Scaffold(
      appBar: SimpleListAppBar(title: l10n.accountAndPrivacy),
      body: ListView(
        children: [
          _Section(label: l10n.account),
          row(Icons.alternate_email_rounded, l10n.changeEmail,
              l10n.changeEmailSubtitle, () => _openChangeEmail(context)),
          row(Icons.password_rounded, l10n.changePassword,
              l10n.changePasswordSubtitle,
              () => _confirmPasswordReset(context)),
          _Section(label: l10n.privacySection),
          row(
            Icons.notifications_off_outlined,
            l10n.ignoredUsers,
            l10n.ignoredUsersSubtitle,
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => IgnoredUsersPage(siteContext: siteContext),
              ),
            ),
          ),
          const Divider(height: 1),
          // Everything the app doesn't model (security keys, sessions,
          // email frequency, sidebar…) is on the website's preferences.
          row(Icons.manage_accounts_outlined, l10n.manageAccountOnWeb,
              l10n.manageAccountSubtitle, () => _openWebPreferences(context),
              trailing: Icons.open_in_new_rounded),
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingL),
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
                    l10n.deleteAccount,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingS),
                  Text(
                    l10n.deleteAccountExplanation,
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
                    ),
                    child: Text(l10n.deleteAccount),
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
      FormPageRoute(
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

  Future<void> _confirmPasswordReset(BuildContext context) async {
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
              child: Text(AppLocalizations.of(context)!.sendResetEmail),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
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
                    : l10n.passwordResetEmailSent)
                : (result.resultText?.isNotEmpty == true
                    ? result.resultText!
                    : l10n.couldNotSendResetEmail),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
            content: Text(describeError(e,
                fallback: l10n.accountRequestFailed, context: context))),
      );
    }
  }

  /// Open the Discourse user-preferences page in the system browser.
  /// The user is already signed in there (or gets prompted), and the
  /// full prefs surface — themes, sidebar tags, watched categories,
  /// security, group memberships — is well outside what we model in
  /// the app's typed prefs page.
  Future<void> _openWebPreferences(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final baseUrl = siteContext.site.url;
    if (baseUrl.isEmpty) {
      _toast(context, l10n.forumUrlUnavailable);
      return;
    }
    // Discourse maps `/my/preferences` to the current user's
    // preferences page — works without needing to know the
    // username here.
    final uri = Uri.parse(baseUrl).resolve('/my/preferences');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _toast(context, l10n.couldNotOpenPreferencesPage);
    }
  }

  /// Deleting an account. Where Discourse lets the member do it
  /// (`can_delete_account`), the app deletes it the way the website's
  /// Delete My Account does, then signs out. Otherwise the forum is
  /// opened, to ask its staff.
  Future<void> _showDeleteAccountDialog(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) async {
    final proxy = SiteProxyFactory.getUserProxy();
    if (proxy is DiscourseUserProxy &&
        await proxy.canDeleteOwnAccountAsync() == true) {
      if (context.mounted) await _deleteOwnAccount(context, proxy);
      return;
    }
    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.deleteAccount,
          ),
          content: Text(
            AppLocalizations.of(context)!.deleteAccountDialogBody,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _openForumHomePage(context);
              },
              child: Text(AppLocalizations.of(context)!.continueButton),
            ),
          ],
        );
      },
    );
  }

  /// The website's Delete My Account: its confirmation, the delete, and its
  /// messages (preferences/account.js). The account's key goes with it, so
  /// the app signs out and returns to the forum's first screen.
  Future<void> _deleteOwnAccount(
      BuildContext context, DiscourseUserProxy proxy) async {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: colorScheme.error),
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: Text(l10n.deleteMyAccount),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final navigator = Navigator.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
    final result = await proxy.deleteOwnAccountAsync();
    if (result.deleted) {
      final loginController = Get.isRegistered<DiscourseLoginController>()
          ? Get.find<DiscourseLoginController>()
          : Get.put(DiscourseLoginController());
      await loginController.handleLogout(siteContext);
    }
    navigator.pop(); // the progress indicator
    if (result.deleted) {
      navigator.popUntil((route) => route.isFirst);
      await Get.dialog<void>(AlertDialog(
        content: Text(l10n.deletedYourself),
        actions: [
          TextButton(onPressed: Get.back, child: Text(l10n.okButton)),
        ],
      ));
      return;
    }
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(result.message.trim().isNotEmpty
            ? result.message.trim()
            : l10n.deleteYourselfNotAllowed),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.okButton),
          ),
        ],
      ),
    );
  }

  Future<void> _openForumHomePage(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final url = siteContext.site.url;
    if (url.isEmpty) {
      _toast(context, l10n.forumUrlUnavailable);
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _toast(context, l10n.couldNotOpenForumUrl);
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
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  const _Section({required this.label});

  @override
  Widget build(BuildContext context) => SectionHeader(label);
}
