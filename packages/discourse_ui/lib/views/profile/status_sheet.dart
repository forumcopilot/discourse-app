import 'dart:async';

import 'package:discourse_core/discourse_core.dart';
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../services/discourse_login_service.dart';
import '../../theme/design_tokens.dart';
import '../../utils/app_navigation.dart';
import '../../utils/discourse_emoji_data.dart';
import '../../utils/error_message.dart';
import '../widgets/reaction_glyph.dart';
import '../widgets/sheet_title.dart';

/// Whether this forum offers statuses (`enable_user_status`). False until
/// its settings are read.
bool forumHasUserStatus(SiteContext siteContext) =>
    DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl)
        .profileSettings
        ?.enableUserStatus ??
    false;

/// The "What are you doing?" sheet, as web's user menu opens it: an emoji,
/// a line, when it clears, and whether notifications pause until then.
/// Saves on its own (PUT /user-status.json). True when the status changed.
Future<bool> showStatusSheet({
  required BuildContext context,
  required SiteContext siteContext,
  DiscourseUserStatus? current,
  DiscourseProfileProxy? proxy,
  DiscourseUserProxy? users,
}) async {
  final changed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
      child: _StatusSheet(
        siteContext: siteContext,
        current: current,
        proxy: proxy ?? DiscourseProfileProxy(siteContext),
        users: users ?? DiscourseUserProxy(siteContext),
      ),
    ),
  );
  return changed == true;
}

/// When a status clears.
enum _Ends { hour, twoHours, tomorrow, never, custom }

class _StatusSheet extends StatefulWidget {
  const _StatusSheet({
    required this.siteContext,
    required this.current,
    required this.proxy,
    required this.users,
  });

  final SiteContext siteContext;
  final DiscourseUserStatus? current;
  final DiscourseProfileProxy proxy;
  final DiscourseUserProxy users;

  @override
  State<_StatusSheet> createState() => _StatusSheetState();
}

class _StatusSheetState extends State<_StatusSheet> {
  late final TextEditingController _text =
      TextEditingController(text: widget.current?.description ?? '');
  late String? _emoji = widget.current?.emoji;
  late _Ends _ends =
      widget.current?.endsAt == null ? _Ends.never : _Ends.custom;
  late DateTime? _customEnd = widget.current?.endsAt;
  bool _pause = false;
  bool _dndActive = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
    _readDoNotDisturb();
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _readDoNotDisturb() async {
    final result = await widget.users.getDoNotDisturbStatusAsync();
    if (!mounted || !result.result) return;
    setState(() {
      _dndActive = result.isActive;
      _pause = result.isActive;
    });
  }

  /// When the status clears, as Discourse's time shortcuts put it:
  /// tomorrow is 8 in the morning.
  DateTime? get _endsAt {
    final now = DateTime.now();
    return switch (_ends) {
      _Ends.hour => now.add(const Duration(hours: 1)),
      _Ends.twoHours => now.add(const Duration(hours: 2)),
      _Ends.tomorrow => DateTime(now.year, now.month, now.day + 1, 8),
      _Ends.never => null,
      _Ends.custom => _customEnd,
    };
  }

  Future<void> _pickEnd() async {
    final now = DateTime.now();
    final initial = _customEnd ?? now.add(const Duration(days: 1));
    final day = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;
    setState(() {
      _customEnd = DateTime(day.year, day.month, day.day, time.hour, time.minute);
      _ends = _Ends.custom;
    });
  }

  Future<void> _pickEmoji() async {
    final picked = await showStatusEmojiPicker(context, widget.siteContext);
    if (picked != null && mounted) setState(() => _emoji = picked);
  }

  /// Do Not Disturb follows the status, as web's status service does it.
  Future<void> _syncDoNotDisturb({required bool on, DateTime? until}) async {
    DiscourseDoNotDisturbResult? result;
    if (on) {
      final end = until ?? DateTime(3000);
      final minutes = end.difference(DateTime.now()).inMinutes;
      if (minutes > 0) {
        result = await widget.users.enterDoNotDisturbAsync('$minutes');
      }
    } else if (_dndActive) {
      result = await widget.users.leaveDoNotDisturbAsync();
    }
    if (result != null && result.result) {
      unawaited(DiscourseLoginService(widget.siteContext)
          .syncDoNotDisturb(on ? result.endsAt : null));
    }
  }

  Future<void> _save() async {
    final description = _text.text.trim();
    if (description.isEmpty || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final ends = _endsAt;
      await widget.proxy.setStatus(DiscourseUserStatus(
          description: description, emoji: _emoji, endsAt: ends));
      await _syncDoNotDisturb(on: _pause, until: ends);
      if (mounted) context.popOwnRoute(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = describeError(e);
        });
      }
    }
  }

  Future<void> _clear() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.proxy.clearStatus();
      await _syncDoNotDisturb(on: false);
      if (mounted) context.popOwnRoute(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = describeError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    final custom = _customEnd;
    Widget chip(_Ends value, String label) => ChoiceChip(
          label: Text(label),
          selected: _ends == value,
          onSelected: _saving ? null : (_) => setState(() => _ends = value),
        );

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: DesignTokens.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetTitle(l10n.setStatus),
            Padding(
              padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
                  DesignTokens.spacingS, DesignTokens.spacingL, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(DesignTokens.radiusXS)),
                      ),
                      onPressed: _saving ? null : _pickEmoji,
                      child: Semantics(
                        label: l10n.chooseEmoji,
                        child: _emoji == null
                            ? Icon(Icons.add_reaction_outlined,
                                color: colorScheme.onSurfaceVariant)
                            : ReactionGlyph(
                                reactionId: _emoji!,
                                size: 28,
                                siteContext: widget.siteContext),
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spacingS),
                  Expanded(
                    child: TextField(
                      controller: _text,
                      autofocus: widget.current == null,
                      enabled: !_saving,
                      maxLength: 100,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _save(),
                      decoration: InputDecoration(
                        labelText: l10n.whatAreYouDoing,
                        counterText: '',
                        suffixIcon: _text.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: l10n.clearText,
                                icon: const Icon(Icons.cancel_outlined),
                                onPressed: _text.clear,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.notifications_paused_outlined),
              title: Text(l10n.pauseNotifications),
              subtitle: Text(l10n.pauseNotificationsUntilStatusClears),
              value: _pause,
              onChanged: _saving ? null : (v) => setState(() => _pause = v),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
                  DesignTokens.spacingS, DesignTokens.spacingL, DesignTokens.spacingS),
              child: Text(l10n.removeStatusAfter,
                  style: textTheme.titleSmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL),
              child: Wrap(
                spacing: DesignTokens.spacingS,
                runSpacing: DesignTokens.spacingS,
                children: [
                  chip(_Ends.hour, l10n.inOneHour),
                  chip(_Ends.twoHours, l10n.inTwoHours),
                  chip(_Ends.tomorrow, l10n.tomorrow),
                  chip(_Ends.never, l10n.never),
                  ChoiceChip(
                    avatar: const Icon(Icons.event_outlined),
                    label: Text(_ends == _Ends.custom && custom != null
                        ? DateFormat.MMMEd(locale).add_jm().format(custom)
                        : l10n.pickATime),
                    selected: _ends == _Ends.custom,
                    onSelected: _saving ? null : (_) => _pickEnd(),
                  ),
                ],
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
                    DesignTokens.spacingM, DesignTokens.spacingL, 0),
                child: Text(_error!,
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.error)),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(DesignTokens.spacingS,
                  DesignTokens.spacingL, DesignTokens.spacingL, 0),
              child: Row(
                children: [
                  if (widget.current != null)
                    TextButton.icon(
                      onPressed: _saving ? null : _clear,
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.clearStatus),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: _saving ? null : () => context.popOwnRoute(false),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: DesignTokens.spacingS),
                  FilledButton(
                    onPressed:
                        _saving || _text.text.trim().isEmpty ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(l10n.save),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Emoji people use for a status, first in the picker. Names as Discourse
/// spells them; any this forum's emoji set lacks are left out.
const List<String> _statusEmoji = [
  'speech_balloon', 'palm_tree', 'beach_umbrella', 'airplane', 'house',
  'computer', 'calendar', 'spiral_calendar', 'coffee', 'face_with_thermometer',
  'sleeping', 'headphones', 'books', 'briefcase', 'car', 'train', 'bike',
  'baby', 'birthday', 'tada', 'construction', 'mute', 'zzz', 'hourglass',
  'pray', 'heart', 'eyes', 'writing_hand', 'rocket', 'video_game',
];

/// A grid of emoji with a search, for the status. Returns a shortcode.
Future<String?> showStatusEmojiPicker(
    BuildContext context, SiteContext siteContext) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.75,
      child: _EmojiPicker(siteContext: siteContext),
    ),
  );
}

class _EmojiPicker extends StatefulWidget {
  const _EmojiPicker({required this.siteContext});
  final SiteContext siteContext;

  @override
  State<_EmojiPicker> createState() => _EmojiPickerState();
}

class _EmojiPickerState extends State<_EmojiPicker> {
  String _query = '';

  /// One name per character: the table lists aliases too.
  static final List<String> _all = () {
    final seen = <String>{};
    return [
      for (final e in discourseEmojiByName.entries)
        if (seen.add(e.value)) e.key,
    ];
  }();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final q = _query.trim().toLowerCase().replaceAll(' ', '_');
    final names = q.isEmpty
        ? [
            ..._statusEmoji.where(discourseEmojiByName.containsKey),
            ..._all.where((n) => !_statusEmoji.contains(n)),
          ]
        : discourseEmojiByName.keys.where((n) => n.contains(q)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetTitle(l10n.chooseEmoji),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              DesignTokens.spacingL, 0, DesignTokens.spacingL, DesignTokens.spacingS),
          child: SearchBar(
            hintText: l10n.searchEmoji,
            leading: const Icon(Icons.search),
            elevation: const WidgetStatePropertyAll(0),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingS),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 52,
            ),
            itemCount: names.length,
            itemBuilder: (context, i) {
              final name = names[i];
              return Tooltip(
                message: ':$name:',
                child: InkWell(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                  onTap: () => Navigator.pop(context, name),
                  child: Center(
                    child: Text(discourseEmojiByName[name] ?? '',
                        style: const TextStyle(fontSize: 28)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Clears the status without the sheet (the × on the Profile tab's chip),
/// and ends a Do Not Disturb that was paused for it, as web's does.
Future<void> clearUserStatus(SiteContext siteContext,
    {DiscourseProfileProxy? proxy, DiscourseUserProxy? users}) async {
  await (proxy ?? DiscourseProfileProxy(siteContext)).clearStatus();
  final u = users ?? DiscourseUserProxy(siteContext);
  final dnd = await u.getDoNotDisturbStatusAsync();
  if (dnd.result && dnd.isActive) {
    final left = await u.leaveDoNotDisturbAsync();
    if (left.result) {
      unawaited(DiscourseLoginService(siteContext).syncDoNotDisturb(null));
    }
  }
}
