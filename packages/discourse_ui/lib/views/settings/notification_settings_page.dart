import 'package:discourse_core/discourse_core.dart';
import 'package:flutter/material.dart';
import 'package:discourse_ui/config/app_forum_config.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/design_tokens.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_notification_prefs.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/site_controller.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/simple_list_app_bar.dart';

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
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  FCNotificationPrefs? _prefs;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  SiteContext? get _siteContext => Get.isRegistered<DiscourseSiteController>()
      ? Get.find<DiscourseSiteController>().currentSiteContext.value
      : null;

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
              : 'Failed to load notification preferences.';
          return;
        }
        _prefs = result.prefs ?? FCNotificationPrefs();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
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
            : "Couldn't save — check your connection",
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
      appBar: const SimpleListAppBar(title: 'Notifications'),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_prefs == null && _error != null) {
      return EmptyStateView(
        icon: Icons.notifications_off_outlined,
        message: _error!,
      );
    }
    final prefs = _prefs;
    if (prefs == null) {
      return const EmptyStateView(
        icon: Icons.notifications_off_outlined,
        message: 'Sign in to manage your notification preferences.',
      );
    }
    return ListView(
      padding: EdgeInsets.only(bottom: DesignTokens.spacingXL),
      children: [
        if (_saving) const LinearProgressIndicator(minHeight: 2),
        _Section(label: 'Push'),
        const _PushStatusTile(),
        const Divider(height: 1),
        // Do not disturb — Discourse-native (`/do-not-disturb.json`).
        // Only meaningful for a signed-in user; the tile manages its
        // own status fetch so the prefs load above stays untouched.
        if (_siteContext?.isLoggedIn ?? false) ...[
          _Section(label: 'Do not disturb'),
          _DoNotDisturbTile(siteContext: _siteContext!),
          const Divider(height: 1),
        ],
        _Section(label: 'Email'),
        _EnumTile(
          title: 'Email when away',
          subtitle: 'When to send emails about replies, mentions, '
              'and other topic activity',
          value: prefs.emailLevel,
          options: const [
            _EnumOption(value: 0, label: 'Always'),
            _EnumOption(value: 1, label: 'Only when away'),
            _EnumOption(value: 2, label: 'Never'),
          ],
          onChanged: (v) => _save(
            prefs.copyWith(emailLevel: v),
            prefs,
          ),
        ),
        _EnumTile(
          title: 'Email for messages',
          subtitle: 'PMs are tracked separately from topic activity',
          value: prefs.emailMessagesLevel,
          options: const [
            _EnumOption(value: 0, label: 'Always'),
            _EnumOption(value: 1, label: 'Only when away'),
            _EnumOption(value: 2, label: 'Never'),
          ],
          onChanged: (v) => _save(
            prefs.copyWith(emailMessagesLevel: v),
            prefs,
          ),
        ),
        _BoolTile(
          title: 'Send activity digest',
          subtitle: 'Periodic email summarising activity you missed',
          value: prefs.emailDigests && !prefs.mailingListMode,
          enabled: !prefs.mailingListMode,
          onChanged: (v) => _save(
            prefs.copyWith(emailDigests: v),
            prefs,
          ),
        ),
        if (prefs.emailDigests && !prefs.mailingListMode)
          _EnumTile(
            title: 'Digest frequency',
            value: prefs.digestAfterMinutes,
            options: const [
              _EnumOption(value: 1440, label: 'Daily'),
              _EnumOption(value: 10080, label: 'Weekly'),
              _EnumOption(value: 43200, label: 'Monthly'),
            ],
            onChanged: (v) => _save(
              prefs.copyWith(digestAfterMinutes: v),
              prefs,
            ),
          ),
        _BoolTile(
          title: 'Mailing list mode',
          subtitle: 'Email me every post (disables digest). '
              'Not recommended on high-traffic forums.',
          value: prefs.mailingListMode,
          onChanged: (v) => _save(
            prefs.copyWith(mailingListMode: v),
            prefs,
          ),
        ),
        const Divider(height: 1),
        _Section(label: 'Activity'),
        _EnumTile(
          title: 'When someone likes my post',
          value: prefs.likeNotificationFrequency,
          options: const [
            _EnumOption(value: 0, label: 'Always notify'),
            _EnumOption(value: 1, label: 'First time, then daily summary'),
            _EnumOption(value: 2, label: 'First time only'),
            _EnumOption(value: 3, label: 'Never'),
          ],
          onChanged: (v) => _save(
            prefs.copyWith(likeNotificationFrequency: v),
            prefs,
          ),
        ),
        _EnumTile(
          title: 'When I reply to a topic',
          subtitle: 'Discourse will set this notification level on '
              'topics you reply to',
          value: prefs.notificationLevelWhenReplying,
          options: const [
            _EnumOption(value: 3, label: 'Watching (all new posts)'),
            _EnumOption(value: 2, label: 'Tracking (counts in unread)'),
            _EnumOption(value: 1, label: 'Normal (no auto-follow)'),
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
            'Per-category and per-topic notification levels are set '
            'from those screens directly — tap the bell icon on any '
            'topic or category to override.',
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
        title: const Text('Push notifications'),
        subtitle: const Text('Not available in this build'),
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
        title: const Text('Push notifications'),
        subtitle: const Text('Enabled for this login'),
      );
    }

    return ListTile(
      leading: Icon(
        Icons.notification_important_outlined,
        color: colorScheme.error,
      ),
      title: const Text('Push notifications'),
      subtitle: const Text(
        'Not active for this login — log out and log back in to '
        'authorize push notifications',
      ),
    );
  }
}

/// Do-not-disturb control, backed by Discourse's native
/// `POST`/`DELETE /do-not-disturb.json` (via `DiscourseUserProxy`).
///
/// On mount it reads the current DND deadline (Discourse only exposes it
/// on `/session/current.json`, so this is one extra request). While a
/// window is active the tile reports "until <time>" with a Turn off
/// action; when inactive, tapping it opens a duration picker bottom
/// sheet matching the `_EnumTile` picker cadence.
class _DoNotDisturbTile extends StatefulWidget {
  final SiteContext siteContext;

  const _DoNotDisturbTile({required this.siteContext});

  @override
  State<_DoNotDisturbTile> createState() => _DoNotDisturbTileState();
}

class _DoNotDisturbTileState extends State<_DoNotDisturbTile> {
  bool _loading = true;
  bool _busy = false;
  DateTime? _endsAt;

  static const _durations = [
    _DndDuration(value: '30', label: '30 minutes'),
    _DndDuration(value: '60', label: '1 hour'),
    _DndDuration(value: '480', label: '8 hours'),
    _DndDuration(value: '1440', label: '24 hours'),
    _DndDuration(value: 'tomorrow', label: 'Until tomorrow'),
  ];

  bool get _isActive =>
      _endsAt != null && _endsAt!.isAfter(DateTime.now().toUtc());

  DiscourseUserProxy get _proxy => DiscourseUserProxy(widget.siteContext);

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final result = await _proxy.getDoNotDisturbStatusAsync();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.result) {
        _endsAt = result.endsAt;
      }
    });
  }

  Future<void> _enter(String duration) async {
    setState(() => _busy = true);
    final result = await _proxy.enterDoNotDisturbAsync(duration);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (result.result) {
        _endsAt = result.endsAt;
      }
    });
    if (!result.result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.resultText.isNotEmpty
              ? result.resultText
              : "Couldn't enable do not disturb"),
        ),
      );
    }
  }

  Future<void> _leave() async {
    setState(() => _busy = true);
    final result = await _proxy.leaveDoNotDisturbAsync();
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (result.result) {
        _endsAt = null;
      }
    });
    if (!result.result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.resultText.isNotEmpty
              ? result.resultText
              : "Couldn't turn off do not disturb"),
        ),
      );
    }
  }

  Future<void> _showDurationPicker() async {
    final duration = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  DesignTokens.spacingL,
                  0,
                  DesignTokens.spacingL,
                  DesignTokens.spacingS,
                ),
                child: Text(
                  'Pause notifications for…',
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                        fontWeight: DesignTokens.fontWeightSemiBold,
                      ),
                ),
              ),
              ..._durations.map(
                (d) => ListTile(
                  title: Text(d.label),
                  onTap: () => Navigator.of(sheetContext).pop(d.value),
                ),
              ),
              SizedBox(height: DesignTokens.spacingS),
            ],
          ),
        );
      },
    );
    if (duration != null) {
      await _enter(duration);
    }
  }

  String _untilLabel(BuildContext context, DateTime endsAt) {
    final local = endsAt.toLocal();
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).toString();
    final sameDay = local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    return sameDay
        ? DateFormat.jm(locale).format(local)
        : DateFormat.yMMMd(locale).add_jm().format(local);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_loading) {
      return const ListTile(
        leading: Icon(Icons.do_not_disturb_on_outlined),
        title: Text('Do not disturb'),
        subtitle: Text('Checking status…'),
        enabled: false,
      );
    }

    if (_isActive) {
      return ListTile(
        leading: Icon(
          Icons.do_not_disturb_on,
          color: colorScheme.primary,
        ),
        title: const Text('Do not disturb'),
        subtitle: Text('On until ${_untilLabel(context, _endsAt!)}'),
        trailing: TextButton(
          onPressed: _busy ? null : _leave,
          child: const Text('Turn off'),
        ),
      );
    }

    return ListTile(
      onTap: _busy ? null : _showDurationPicker,
      leading: Icon(
        Icons.do_not_disturb_on_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
      title: const Text('Do not disturb'),
      subtitle: const Text(
        'Pause notifications for a while — Discourse holds them '
        'until the window ends',
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _DndDuration {
  final String value;
  final String label;
  const _DndDuration({required this.value, required this.label});
}

class _Section extends StatelessWidget {
  final String label;
  const _Section({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final selected = options.firstWhere(
      (o) => o.value == value,
      orElse: () => options.first,
    );
    return ListTile(
      onTap: () => _showPicker(context),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            selected.label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: DesignTokens.fontWeightMedium,
            ),
          ),
          const SizedBox(width: DesignTokens.spacingXS),
          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    final result = await showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  DesignTokens.spacingL,
                  0,
                  DesignTokens.spacingL,
                  DesignTokens.spacingS,
                ),
                child: Text(
                  title,
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                        fontWeight: DesignTokens.fontWeightSemiBold,
                      ),
                ),
              ),
              ...options.map((opt) {
                final isSelected = opt.value == value;
                return RadioListTile<T>(
                  title: Text(opt.label),
                  value: opt.value,
                  groupValue: value,
                  onChanged: (v) {
                    if (v != null) Navigator.of(sheetContext).pop(v);
                  },
                  selected: isSelected,
                );
              }),
              SizedBox(height: DesignTokens.spacingS),
            ],
          ),
        );
      },
    );
    if (result != null && result != value) {
      onChanged(result);
    }
  }
}
