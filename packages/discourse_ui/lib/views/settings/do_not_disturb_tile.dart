import 'dart:async';

import 'package:discourse_core/discourse_core.dart';
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../services/discourse_login_service.dart';
import '../../theme/design_tokens.dart';
import '../widgets/sheet_title.dart';

/// Do-not-disturb control, backed by Discourse's native
/// `POST`/`DELETE /do-not-disturb.json` (via `DiscourseUserProxy`).
///
/// On mount it reads the current DND deadline (Discourse only exposes it
/// on `/session/current.json`, so this is one extra request). While a
/// window is active the tile reports "until <time>" with a Turn off
/// action; when inactive, tapping it opens a duration picker bottom
/// sheet matching the `_EnumTile` picker cadence.
///
/// It lives on the Profile tab, as web's lives in the user menu. The other
/// way in is the status sheet's "Pause notifications", which calls
/// [notifyChanged] so a tile on screen reads the new state instead of
/// showing the one it loaded.
class DoNotDisturbTile extends StatefulWidget {
  final SiteContext siteContext;

  /// Stands in for the forum in tests.
  final DiscourseUserProxy? users;

  const DoNotDisturbTile({super.key, required this.siteContext, this.users});

  static final ValueNotifier<int> _changes = ValueNotifier(0);

  /// Do Not Disturb changed somewhere other than the tile itself.
  static void notifyChanged() => _changes.value++;

  @override
  State<DoNotDisturbTile> createState() => DoNotDisturbTileState();
}

class DoNotDisturbTileState extends State<DoNotDisturbTile> {
  bool _loading = true;
  bool _busy = false;
  DateTime? _endsAt;
  late final Object _accountSession;

  bool get _sessionCurrent =>
      identical(_accountSession, widget.siteContext.configurationSession);

  // This tile belongs to the account that opened it. A completed forum
  // request must not become a fresh relay request for a replacement account.
  bool _checkSession() {
    if (!mounted) return false;
    if (_sessionCurrent) return true;
    setState(() {
      _loading = false;
      _busy = false;
      _endsAt = null;
    });
    return false;
  }

  static List<_DndDuration> _durations(AppLocalizations l10n) => [
        _DndDuration(value: '30', label: l10n.durationMinutes(30)),
        _DndDuration(value: '60', label: l10n.durationHours(1)),
        _DndDuration(value: '480', label: l10n.durationHours(8)),
        _DndDuration(value: '1440', label: l10n.durationHours(24)),
        _DndDuration(
            value: 'tomorrow', label: l10n.pauseNotificationsUntilTomorrow),
      ];

  bool get _isActive =>
      _endsAt != null && _endsAt!.isAfter(DateTime.now().toUtc());

  late final DiscourseUserProxy _proxy =
      widget.users ?? DiscourseUserProxy(widget.siteContext);

  @override
  void initState() {
    super.initState();
    _accountSession = widget.siteContext.configurationSession;
    DoNotDisturbTile._changes.addListener(_loadStatus);
    _loadStatus();
  }

  @override
  void dispose() {
    DoNotDisturbTile._changes.removeListener(_loadStatus);
    super.dispose();
  }

  Future<void> _loadStatus() async {
    if (!mounted || !_checkSession()) return;
    final result = await _proxy.getDoNotDisturbStatusAsync();
    if (!mounted || !_checkSession()) return;
    setState(() {
      _loading = false;
      if (result.result) {
        _endsAt = result.endsAt;
      }
    });
    if (result.result) _reportToPushBackend();
  }

  /// The notifications backend polls with a key that cannot read Do Not
  /// Disturb, so it learns the window from the app: nothing is pushed during
  /// it, as Discourse drops its own push. A no-op without a grant here.
  void _reportToPushBackend() {
    unawaited(DiscourseLoginService(widget.siteContext).syncDoNotDisturb(_endsAt));
  }

  Future<void> _enter(String duration) async {
    if (!mounted || !_checkSession()) return;
    setState(() => _busy = true);
    final result = await _proxy.enterDoNotDisturbAsync(duration);
    if (!mounted || !_checkSession()) return;
    setState(() {
      _busy = false;
      if (result.result) {
        _endsAt = result.endsAt;
      }
    });
    if (result.result) _reportToPushBackend();
    if (!result.result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.resultText.isNotEmpty
              ? result.resultText
              : AppLocalizations.of(context)!.couldNotEnableDoNotDisturb),
        ),
      );
    }
  }

  Future<void> _leave() async {
    if (!mounted || !_checkSession()) return;
    setState(() => _busy = true);
    final result = await _proxy.leaveDoNotDisturbAsync();
    if (!mounted || !_checkSession()) return;
    setState(() {
      _busy = false;
      if (result.result) {
        _endsAt = null;
      }
    });
    if (result.result) _reportToPushBackend();
    if (!result.result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.resultText.isNotEmpty
              ? result.resultText
              : AppLocalizations.of(context)!.couldNotTurnOffDoNotDisturb),
        ),
      );
    }
  }

  Future<void> _showDurationPicker() async {
    if (!mounted || !_checkSession()) return;
    final duration = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetTitle(AppLocalizations.of(context)!.pauseNotificationsFor),
              ..._durations(AppLocalizations.of(context)!).map(
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
    if (!mounted || !_checkSession()) return;
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

    if (!_sessionCurrent) {
      return ListTile(
        leading: const Icon(Icons.do_not_disturb_on_outlined),
        title: Text(AppLocalizations.of(context)!.doNotDisturb),
        subtitle: Text(AppLocalizations.of(context)!.accountSessionChanged),
        enabled: false,
      );
    }

    if (_loading) {
      return ListTile(
        leading: Icon(Icons.do_not_disturb_on_outlined),
        title: Text(AppLocalizations.of(context)!.doNotDisturb),
        subtitle: Text(AppLocalizations.of(context)!.checkingStatus),
        enabled: false,
      );
    }

    if (_isActive) {
      return ListTile(
        leading: Icon(
          Icons.do_not_disturb_on,
          color: colorScheme.primary,
        ),
        title: Text(AppLocalizations.of(context)!.doNotDisturb),
        subtitle: Text(AppLocalizations.of(context)!.doNotDisturbOnUntil(_untilLabel(context, _endsAt!))),
        trailing: TextButton(
          onPressed: _busy ? null : _leave,
          child: Text(AppLocalizations.of(context)!.turnOff),
        ),
      );
    }

    return ListTile(
      onTap: _busy ? null : _showDurationPicker,
      leading: Icon(
        Icons.do_not_disturb_on_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
      title: Text(AppLocalizations.of(context)!.doNotDisturb),
      subtitle: Text(
        AppLocalizations.of(context)!.doNotDisturbExplanation,
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
