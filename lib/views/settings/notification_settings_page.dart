import 'package:flutter/material.dart';
import 'package:forumcopilot_flutter/services/site_proxy_service.dart';
import 'package:forumcopilot_flutter/theme/design_tokens.dart';
import 'package:forumcopilot_sdk/models/entities/fc_notification_prefs.dart';

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
