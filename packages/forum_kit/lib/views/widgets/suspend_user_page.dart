import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:forum_kit/l10n/kit_l10n.dart';
import '../../theme/design_tokens.dart';

/// What staff chose: the reason shown to the user, and when the suspension
/// ends (Unix seconds; 0 for forever).
typedef SuspendUserChoice = ({String reason, int expires});

/// Web's Suspend User modal, as a full-screen dialog: how long, then why
/// (Discourse's own reasons, or a custom one). It was two popups in a row,
/// a list and a free-text reason squeezed under the keyboard on a phone.
/// Null when closed.
Future<SuspendUserChoice?> showSuspendUserPage(BuildContext context) =>
    Navigator.of(context).push<SuspendUserChoice>(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const _SuspendUserPage(),
    ));

class _SuspendUserPage extends StatefulWidget {
  const _SuspendUserPage();

  @override
  State<_SuspendUserPage> createState() => _SuspendUserPageState();
}

class _SuspendUserPageState extends State<_SuspendUserPage> {
  bool _forever = true;
  DateTime? _until;
  String? _reason;
  final _customReason = TextEditingController();
  bool _showErrors = false;

  @override
  void dispose() {
    _customReason.dispose();
    super.dispose();
  }

  Future<void> _pickUntil() async {
    final now = DateTime.now();
    final day = await showDatePicker(
      context: context,
      initialDate: _until ?? now.add(const Duration(days: 7)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_until ?? now),
    );
    if (!mounted) return;
    setState(() => _until = DateTime(day.year, day.month, day.day,
        time?.hour ?? 23, time?.minute ?? 59, time == null ? 59 : 0));
  }

  void _submit(KitLocalizations l10n) {
    final custom = _reason == l10n.suspendReasonCustom;
    final reason = custom ? _customReason.text.trim() : _reason;
    if ((!_forever && _until == null) || reason == null || reason.isEmpty) {
      setState(() => _showErrors = true);
      return;
    }
    Navigator.of(context).pop((
      reason: reason,
      expires: _forever ? 0 : _until!.millisecondsSinceEpoch ~/ 1000,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = kitL10n(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Discourse's own suspension reasons (admin.user.suspend_reasons), as
    // its Suspend User modal offers them, then a custom one.
    final reasons = [
      l10n.suspendReasonNotListening,
      l10n.suspendReasonStaffTime,
      l10n.suspendReasonCombative,
      l10n.suspendReasonWrongPlace,
      l10n.suspendReasonNoPurpose,
      l10n.suspendReasonCustom,
    ];
    final until = _until;
    Widget header(String text) => Padding(
          padding: const EdgeInsets.only(
              top: DesignTokens.spacingL, bottom: DesignTokens.spacingXS),
          child: Text(text,
              style: textTheme.titleSmall?.copyWith(color: colorScheme.primary)),
        );

    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(l10n.suspendUser),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: DesignTokens.spacingS),
            child: FilledButton(
              key: const ValueKey('suspend-submit'),
              onPressed: _reason == null ? null : () => _submit(l10n),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: Text(l10n.suspendUser),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL, 0,
              DesignTokens.spacingL, DesignTokens.spacingXL),
          children: [
            header(l10n.suspendUntil),
            RadioGroup<bool>(
              groupValue: _forever,
              onChanged: (v) => setState(() => _forever = v ?? true),
              child: Column(
                children: [
                  RadioListTile<bool>(
                    key: const ValueKey('suspend-forever'),
                    value: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.suspendForever),
                  ),
                  RadioListTile<bool>(
                    key: const ValueKey('suspend-temporary'),
                    value: false,
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.temporary),
                  ),
                ],
              ),
            ),
            if (!_forever)
              Padding(
                padding: const EdgeInsets.only(left: DesignTokens.spacingXXXL),
                child: InkWell(
                  onTap: _pickUntil,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.suspendUntil,
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                      errorText: _showErrors && until == null
                          ? l10n.pleaseSelectSuspensionEndDate
                          : null,
                    ),
                    child: Text(until == null
                        ? l10n.selectDate
                        : DateFormat.yMMMd(Localizations.localeOf(context).toString())
                            .add_jm()
                            .format(until)),
                  ),
                ),
              ),
            header(l10n.reason),
            Text(
              l10n.suspendReasonQuestion,
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            RadioGroup<String>(
              groupValue: _reason,
              onChanged: (v) => setState(() => _reason = v),
              child: Column(
                children: [
                  for (final reason in reasons) ...[
                    RadioListTile<String>(
                      value: reason,
                      contentPadding: EdgeInsets.zero,
                      title: Text(reason),
                    ),
                    if (reason == l10n.suspendReasonCustom && _reason == reason)
                      Padding(
                        padding:
                            const EdgeInsets.only(left: DesignTokens.spacingXXXL),
                        child: TextField(
                          key: const ValueKey('suspend-custom-reason'),
                          controller: _customReason,
                          autofocus: true,
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (_) {
                            if (_showErrors) setState(() => _showErrors = false);
                          },
                          decoration: InputDecoration(
                            labelText: l10n.pleaseSpecifyReason,
                            border: const OutlineInputBorder(),
                            errorText:
                                _showErrors && _customReason.text.trim().isEmpty
                                    ? l10n.pleaseSpecifyReason
                                    : null,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
