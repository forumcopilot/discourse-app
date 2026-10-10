import 'dart:async';

import 'package:discourse_core/discourse_core.dart';
import 'package:flutter/material.dart';
import 'package:discourse_ui/config/app_forum_config.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/design_tokens.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_notification_prefs.dart';
import 'package:get/get.dart';

import '../../controllers/site_controller.dart';
import '../../services/discourse_login_service.dart';
import '../../services/notification_key_service.dart';
import '../enable_notifications_page.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/simple_list_app_bar.dart';
import '../../utils/error_message.dart';
import '../../utils/snackbar_helper.dart';
import '../widgets/sheet_title.dart';
import '../widgets/section_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/kit_strings.dart';

/// Phase 5.20b — notification preferences screen, rebuilt to sync
/// against Discourse's user_option API.
///
/// Previously the page was 780 LOC of XF-shaped per-type toggles
/// (newPosts / replies / mentions / quotes / likes / subscriptions /
/// PMs / system) backed only by SharedPreferences — flipping a
/// toggle did nothing the server could see. Discourse doesn't model
/// notifications as per-type opt-out: it decides what is a
/// notification, and the user controls *delivery cadence* (email
/// frequency, like aggregation, etc.). The new page surfaces only
/// the controls that genuinely round-trip:
///
///   • Email when away — `email_level`
///   • Email for messages — `email_messages_level`
///   • Send email digest — `email_digests` + `digest_after_minutes`
///   • Mailing list mode — `mailing_list_mode`
///   • When someone likes my post — `like_notification_frequency`
///   • When I reply — `notification_level_when_replying`
///
/// Each control fires an immediate `PUT /u/{me}.json` with the
/// changed field. Optimistic UI: state flips immediately, reverts on
/// network failure with a snackbar.
///
/// Two sections, each saying where it applies, because they differ and
/// nothing else on the page shows it: "On this device" is the app's push
/// from this forum to this device alone; "Your [forum] account" is the
/// reader's settings on the forum, which hold on the web, by email and on
/// every device. Do Not Disturb is account-wide too, but it lives on the
/// Profile tab (as web's lives in the user menu, not in preferences).
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key, this.siteContext});

  /// The forum; the open one when null.
  final SiteContext? siteContext;

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  FCNotificationPrefs? _prefs;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  SiteContext? get _siteContext =>
      widget.siteContext ??
      (Get.isRegistered<DiscourseSiteController>()
          ? Get.find<DiscourseSiteController>().currentSiteContext.value
          : null);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result =
          await SiteProxyService.getAccountProxy().getNotificationPrefsAsync();
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (!result.result) {
          _error = result.resultText?.isNotEmpty == true
              ? result.resultText
              : AppLocalizations.of(context)!.notificationPrefsLoadFailed;
          return;
        }
        _prefs = result.prefs ?? FCNotificationPrefs();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = describeError(e);
      });
    }
  }

  /// Push `next` to the server. Optimistic flip; on failure revert
  /// to `previous` and show a snackbar.
  Future<void> _save(
    FCNotificationPrefs next,
    FCNotificationPrefs previous,
  ) async {
    setState(() {
      _prefs = next;
      _saving = true;
    });
    final result = await SiteProxyService.getAccountProxy()
        .updateNotificationPrefsAsync(next);
    if (!mounted) return;
    if (!result.result) {
      _revert(
        previous,
        result.resultText?.isNotEmpty == true
            ? result.resultText!
            : AppLocalizations.of(context)!.notificationPrefsSaveFailed,
      );
    } else {
      setState(() {
        _saving = false;
      });
    }
  }

  void _revert(FCNotificationPrefs previous, String message) {
    setState(() {
      _prefs = previous;
      _saving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleListAppBar(
          title: AppLocalizations.of(context)!.notificationSettings),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_prefs == null && _error != null) {
      // A failure, not an absence: error tone and a way to try again.
      return EmptyStateView.error(
        message: describeError(_error, context: context),
        onRetry: _load,
      );
    }
    final l10n = AppLocalizations.of(context)!;
    final prefs = _prefs;
    if (prefs == null) {
      return EmptyStateView(
        icon: Icons.notifications_off_outlined,
        message: l10n.signInToManageNotificationPrefs,
      );
    }
    final site = _siteContext;
    final forumName = site == null ? '' : forumNameOf(site);
    return ListView(
      padding: EdgeInsets.only(bottom: DesignTokens.spacingXL),
      children: [
        if (_saving) const LinearProgressIndicator(minHeight: 2),
        _Section(label: l10n.notificationsThisDeviceSection),
        _Caption(l10n.notificationsThisDeviceCaption(forumName)),
        // Two different mechanisms with different states: the notifications
        // grant (a backend polls the forum with a key the user approved) and
        // the relay (Discourse pushes to an allowlisted URL). Show the one
        // this build uses; a build with neither keeps the relay tile's
        // "not available" row so the section still says something.
        if (AppForumConfig.isNotificationsGrantEnabled && site != null)
          _NotificationsGrantTile(siteContext: site)
        else
          const _PushStatusTile(),
        const Divider(height: 1),
        _Section(label: l10n.notificationsAccountSection(forumName)),
        _Caption(l10n.notificationsAccountCaption),
        _EnumTile(
          title: l10n.emailWhenAwayTitle,
          subtitle: l10n.emailLevelDescription,
          value: prefs.emailLevel,
          options: [
            _EnumOption(value: 0, label: l10n.notificationPrefAlways),
            _EnumOption(value: 1, label: l10n.notificationPrefOnlyWhenAway),
            _EnumOption(value: 2, label: l10n.notificationPrefNever),
          ],
          onChanged: (v) => _save(
            prefs.copyWith(emailLevel: v),
            prefs,
          ),
        ),
        _EnumTile(
          title: l10n.emailForMessagesTitle,
          subtitle: l10n.emailMessagesLevelDescription,
          value: prefs.emailMessagesLevel,
          options: [
            _EnumOption(value: 0, label: l10n.notificationPrefAlways),
            _EnumOption(value: 1, label: l10n.notificationPrefOnlyWhenAway),
            _EnumOption(value: 2, label: l10n.notificationPrefNever),
          ],
          onChanged: (v) => _save(
            prefs.copyWith(emailMessagesLevel: v),
            prefs,
          ),
        ),
        _BoolTile(
          title: l10n.activitySummaryTitle,
          subtitle: l10n.activitySummaryDescription,
          value: prefs.emailDigests && !prefs.mailingListMode,
          enabled: !prefs.mailingListMode,
          onChanged: (v) => _save(
            prefs.copyWith(emailDigests: v),
            prefs,
          ),
        ),
        if (prefs.emailDigests && !prefs.mailingListMode)
          _EnumTile(
            title: l10n.activitySummaryFrequencyTitle,
            value: prefs.digestAfterMinutes,
            options: [
              _EnumOption(value: 1440, label: l10n.activitySummaryDaily),
              _EnumOption(value: 10080, label: l10n.activitySummaryWeekly),
              _EnumOption(value: 43200, label: l10n.activitySummaryMonthly),
            ],
            onChanged: (v) => _save(
              prefs.copyWith(digestAfterMinutes: v),
              prefs,
            ),
          ),
        _BoolTile(
          title: l10n.mailingListModeTitle,
          subtitle: l10n.mailingListModeDescription,
          value: prefs.mailingListMode,
          onChanged: (v) => _save(
            prefs.copyWith(mailingListMode: v),
            prefs,
          ),
        ),
        const Divider(
            indent: DesignTokens.spacingL, endIndent: DesignTokens.spacingL),
        _EnumTile(
          // Discourse's words (user.like_notification_frequency).
          title: l10n.likeNotificationFrequencyTitle,
          value: prefs.likeNotificationFrequency,
          options: [
            _EnumOption(value: 0, label: l10n.notificationPrefAlways),
            _EnumOption(
                value: 1, label: l10n.likeNotificationFirstTimeAndDaily),
            _EnumOption(value: 2, label: l10n.likeNotificationFirstTime),
            _EnumOption(value: 3, label: l10n.notificationPrefNever),
          ],
          onChanged: (v) => _save(
            prefs.copyWith(likeNotificationFrequency: v),
            prefs,
          ),
        ),
        _EnumTile(
          // Discourse's words (user.notification_level_when_replying).
          title: l10n.whenPostingTitle,
          subtitle: l10n.whenPostingDescription,
          value: prefs.notificationLevelWhenReplying,
          options: [
            _EnumOption(value: 3, label: l10n.whenPostingWatchTopic),
            _EnumOption(value: 2, label: l10n.whenPostingTrackTopic),
            _EnumOption(value: 1, label: l10n.whenPostingDoNothing),
          ],
          onChanged: (v) => _save(
            prefs.copyWith(notificationLevelWhenReplying: v),
            prefs,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            DesignTokens.spacingL,
            DesignTokens.spacingXL,
            DesignTokens.spacingL,
            DesignTokens.spacingS,
          ),
          child: Text(
            l10n.perTopicNotificationLevelsNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}

/// Read-only status row for push notifications. Push state is not a
/// user-flippable preference in the Discourse model — it is decided by
/// build config ([AppForumConfig.pushApiBaseUrl]) plus whether the current
/// User API Key was granted the `push` scope + `push_url` at login — so
/// this tile only reports which of the three states applies:
///
///   * unconfigured — this build ships without a push relay;
///   * enabled — the key carries the push grant, Discourse pushes to the relay;
///   * re-login required — push was configured after this login; a User API
///     Key's scopes/push_url can't be amended, only a fresh handshake helps.
///
/// Everything here is guarded — no [PushNotificationService] call is made,
/// so the page is safe to open with the push backend disabled.
class _PushStatusTile extends StatelessWidget {
  const _PushStatusTile();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!AppForumConfig.isPushBackendEnabled) {
      return ListTile(
        leading: Icon(
          Icons.notifications_off_outlined,
          color: colorScheme.onSurfaceVariant,
        ),
        title: Text(AppLocalizations.of(context)!.pushNotifications),
        subtitle: Text(AppLocalizations.of(context)!.pushNotAvailableInThisBuild),
        enabled: false,
      );
    }

    final ctx = Get.isRegistered<DiscourseSiteController>()
        ? Get.find<DiscourseSiteController>().currentSiteContext.value
        : null;
    final pushGranted = ctx?.userApiPushEnabled ?? false;

    if (pushGranted) {
      return ListTile(
        leading: Icon(
          Icons.notifications_active_outlined,
          color: colorScheme.primary,
        ),
        title: Text(AppLocalizations.of(context)!.pushNotifications),
        subtitle: Text(AppLocalizations.of(context)!.pushEnabledForThisLogin),
      );
    }

    return ListTile(
      leading: Icon(
        Icons.notification_important_outlined,
        color: colorScheme.error,
      ),
      title: Text(AppLocalizations.of(context)!.pushNotifications),
      subtitle: Text(
        AppLocalizations.of(context)!.pushNotActiveForThisLogin,
      ),
    );
  }
}

/// The notifications grant for this device, with a way to change the answer
/// given at sign-in. "On" means the backend holds a notifications-only key
/// for this forum and polls it for this device; "Turn on" runs the same
/// [EnableNotificationsPage] the sign-in flow shows. While on, the per-type
/// switches are the everyday control — they quiet a kind of notification
/// and keep the grant — and "Stop push on this device", after
/// [confirmStopPush], tells the backend to delete the key (it revokes it on
/// the forum) and forgets the grant, so the next sign-in offers it again.
///
/// The state is the locally remembered grant, not a server query: the
/// backend has no read endpoint, and the flag is written only once the
/// backend confirmed it stored the key.
class _NotificationsGrantTile extends StatefulWidget {
  final SiteContext siteContext;

  const _NotificationsGrantTile({required this.siteContext});

  @override
  State<_NotificationsGrantTile> createState() =>
      _NotificationsGrantTileState();
}

class _NotificationsGrantTileState extends State<_NotificationsGrantTile> {
  bool _loading = true;
  bool _busy = false;
  bool _granted = false;

  /// Per-type switches exist for grants made under the phone's installation.
  bool _installBound = false;
  Set<String> _muted = const {};
  String? _savingGroup;

  DiscourseLoginService get _loginService =>
      DiscourseLoginService(widget.siteContext);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final granted = await _loginService.hasNotificationsGrant();
    final bound = granted && await _loginService.isNotificationsGrantInstallBound();
    final muted = bound ? await _loginService.mutedPushGroups() : const <String>{};
    if (!mounted) return;
    setState(() {
      _loading = false;
      _granted = granted;
      _installBound = bound;
      _muted = muted;
    });
  }

  Future<void> _setGroup(String group, bool on) async {
    setState(() => _savingGroup = group);
    final ok = await _loginService.setPushGroupMuted(group, !on);
    if (!mounted) return;
    setState(() {
      _savingGroup = null;
      if (ok) _muted = on ? ({..._muted}..remove(group)) : {..._muted, group};
    });
    if (!ok) {
      SnackbarHelper.showError(
          context, AppLocalizations.of(context)!.couldNotChangePushSetting);
    }
  }

  (String, String) _groupLabel(String group, AppLocalizations l10n) =>
      switch (group) {
        'messages' => (l10n.pushGroupMessages, l10n.pushGroupMessagesHint),
        'replies' => (l10n.pushGroupReplies, l10n.pushGroupRepliesHint),
        'reactions' => (l10n.pushGroupReactions, l10n.pushGroupReactionsHint),
        _ => (l10n.pushGroupOther, l10n.pushGroupOtherHint),
      };

  Future<void> _turnOn() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => EnableNotificationsPage(siteContext: widget.siteContext),
      ),
    );
    if (!mounted) return;
    // Re-read the remembered grant rather than trusting the pop value: the
    // page records it only once the backend took the key.
    await _load();
  }

  Future<void> _stopPush() async {
    final go = await confirmStopPush(context,
        forumName: forumNameOf(widget.siteContext));
    if (go && mounted) await _turnOff();
  }

  Future<void> _turnOff() async {
    setState(() => _busy = true);
    final site = widget.siteContext.site;
    final clientId = await _loginService.notificationsClientId();
    final revoked = await NotificationKeyService.revoke(
      siteUrl: site.url,
      siteId: site.id,
      clientId: clientId,
    );
    // Only a confirmed revoke flips the state: forgetting the grant while the
    // backend still polls would keep delivering to a user who asked for
    // silence — the opposite of what they just did.
    if (revoked) await _loginService.clearNotificationsGrant();
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (revoked) _granted = false;
    });
    if (!revoked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.couldNotTurnOffNotifications),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final forumName = forumNameOf(widget.siteContext);

    final tile = ListTile(
      leading: Icon(
        _granted
            ? Icons.notifications_active_outlined
            : Icons.notifications_off_outlined,
        color: _granted ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(l10n.pushNotifications),
      subtitle: Text(_granted
          ? l10n.pushOnThisDeviceSubtitle(forumName)
          : l10n.pushOffThisDeviceSubtitle(forumName)),
      trailing: _loading || _busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : _granted
              ? null
              : TextButton(onPressed: _turnOn, child: Text(l10n.turnOn)),
    );
    if (!_granted || _loading) return tile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tile,
        // Which kinds of notification this forum pushes to this device. All
        // on unless turned off; the backend skips what is off. Only grants
        // made under the phone's installation have them.
        if (_installBound)
          for (final group in NotificationKeyService.pushGroups)
            Builder(builder: (context) {
              final (title, hint) = _groupLabel(group, l10n);
              return SwitchListTile(
                contentPadding: const EdgeInsets.only(
                    left: DesignTokens.spacingXL * 2,
                    right: DesignTokens.spacingM),
                title: Text(title),
                subtitle: Text(hint),
                value: !_muted.contains(group),
                onChanged: _savingGroup != null || _busy
                    ? null
                    : (on) => _setGroup(group, on),
              );
            }),
        ListTile(
          leading: Icon(Icons.notifications_off_outlined,
              color: colorScheme.error),
          title: Text(l10n.stopPushOnThisDevice,
              style: TextStyle(color: colorScheme.error)),
          onTap: _busy ? null : _stopPush,
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  const _Section({required this.label});

  @override
  Widget build(BuildContext context) => SectionHeader(label);
}

/// The line under a section header that says where its settings apply.
class _Caption extends StatelessWidget {
  final String text;
  const _Caption(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL, 0,
          DesignTokens.spacingL, DesignTokens.spacingS),
      child: Text(
        text,
        style: theme.textTheme.bodySmall
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

/// The forum's name, or its address when it has none.
String forumNameOf(SiteContext site) {
  final name = site.site.name.trim();
  if (name.isNotEmpty) return name;
  return Uri.tryParse(site.site.url)?.host ?? site.site.url;
}

/// Asks before stopping push from [forumName] on this device, saying what
/// that does and does not change — the button alone cannot: only this
/// device, nothing on the web or by email, and the permission given on the
/// forum is deleted, so turning push back on means approving it there again.
/// True to go ahead.
Future<bool> confirmStopPush(BuildContext context,
    {required String forumName}) async {
  final l10n = AppLocalizations.of(context)!;
  final theme = Theme.of(context);
  Widget fact(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: DesignTokens.spacingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
          ],
        ),
      );
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(l10n.stopPushTitle(forumName)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            fact(Icons.smartphone_outlined, l10n.stopPushOnlyThisDevice),
            fact(Icons.public, l10n.stopPushNothingElseChanges),
            fact(Icons.key_outlined, l10n.stopPushPermissionDeleted(forumName)),
            Text(
              l10n.stopPushQuietHint,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialog).pop(false),
          child: Text(l10n.kit.cancel),
        ),
        TextButton(
          style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error),
          onPressed: () => Navigator.of(dialog).pop(true),
          child: Text(l10n.stopPush),
        ),
      ],
    ),
  );
  return confirmed == true;
}

class _BoolTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _BoolTile({
    required this.title,
    this.subtitle,
    required this.value,
    this.enabled = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }
}

class _EnumOption<T> {
  final T value;
  final String label;
  const _EnumOption({required this.value, required this.label});
}

class _EnumTile<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final T value;
  final List<_EnumOption<T>> options;
  final ValueChanged<T> onChanged;

  const _EnumTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = options.firstWhere(
      (o) => o.value == value,
      orElse: () => options.first,
    );
    // The current choice is the supporting text, as in Android's settings.
    // It sat at the end of the row, where a label like "Only when away"
    // squeezed the title onto two or three lines; the explanation moves
    // into the picker.
    return ListTile(
      onTap: () => _showPicker(context),
      title: Text(title),
      subtitle: Text(selected.label),
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    final result = await showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: RadioGroup<T>(
            groupValue: value,
            onChanged: (v) {
              if (v != null) Navigator.of(sheetContext).pop(v);
            },
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SheetTitle(title),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        DesignTokens.spacingL,
                        0,
                        DesignTokens.spacingL,
                        DesignTokens.spacingS,
                      ),
                      child: Text(
                        subtitle!,
                        style: Theme.of(sheetContext)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: Theme.of(sheetContext)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ),
                  ...options.map((opt) {
                    final isSelected = opt.value == value;
                    return RadioListTile<T>(
                      title: Text(opt.label),
                      value: opt.value,
                      selected: isSelected,
                    );
                  }),
                  SizedBox(height: DesignTokens.spacingS),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (result != null && result != value) {
      onChanged(result);
    }
  }
}
