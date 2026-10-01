import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';
import 'sheet_title.dart';

/// How staff chose to pin a topic.
typedef FeatureTopicChoice = ({bool globally, DateTime until});

/// Web's "Feature this topic" modal (topic.actions.pin, "Pin Topic…"): pin
/// at the top of [categoryName] until a date, or, with [canPinGlobally]
/// (staff and trust level 4), at the top of every topic list. Discourse
/// asks for the end date and unpins the topic then. Null when dismissed.
Future<FeatureTopicChoice?> showFeatureTopicSheet(
  BuildContext context, {
  required String categoryName,
  required bool canPinGlobally,
}) =>
    showModalBottomSheet<FeatureTopicChoice>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext)!;
        final textTheme = Theme.of(sheetContext).textTheme;
        void pin(bool globally, DateTime until) =>
            Navigator.of(sheetContext).pop((globally: globally, until: until));
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: DesignTokens.spacingL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SheetTitle(l10n.featureTopicTitle),
                _PinSection(
                  key: const ValueKey('pin-in-category'),
                  message: l10n.pinInCategoryUntil(categoryName),
                  buttonLabel: l10n.pinTopic,
                  onPin: (until) => pin(false, until),
                ),
                if (canPinGlobally) ...[
                  const Divider(height: DesignTokens.spacingXL),
                  _PinSection(
                    key: const ValueKey('pin-globally'),
                    message: l10n.pinGloballyUntil,
                    buttonLabel: l10n.pinTopicGlobally,
                    onPin: (until) => pin(true, until),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
                      DesignTokens.spacingL, DesignTokens.spacingL, 0),
                  child: Text(
                    l10n.pinNote,
                    style: textTheme.bodySmall?.copyWith(
                        color: Theme.of(sheetContext).colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

/// One way to pin: what it does, the end date, and the button.
class _PinSection extends StatefulWidget {
  const _PinSection({
    super.key,
    required this.message,
    required this.buttonLabel,
    required this.onPin,
  });

  final String message;
  final String buttonLabel;
  final void Function(DateTime until) onPin;

  @override
  State<_PinSection> createState() => _PinSectionState();
}

class _PinSectionState extends State<_PinSection> {
  DateTime? _until;
  bool _missingDate = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _until ?? now.add(const Duration(days: 7)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null && mounted) {
      setState(() {
        _until = picked;
        _missingDate = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final until = _until;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.message, style: textTheme.bodyLarge),
          const SizedBox(height: DesignTokens.spacingM),
          Wrap(
            spacing: DesignTokens.spacingM,
            runSpacing: DesignTokens.spacingS,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.event),
                label: Text(until == null
                    ? l10n.pinUntil
                    : DateFormat.yMMMd(Localizations.localeOf(context).toString())
                        .format(until)),
              ),
              FilledButton.icon(
                onPressed: () {
                  if (until == null) {
                    setState(() => _missingDate = true);
                    return;
                  }
                  widget.onPin(until);
                },
                icon: const Icon(Icons.push_pin_outlined),
                label: Text(widget.buttonLabel),
              ),
            ],
          ),
          if (_missingDate)
            Padding(
              padding: const EdgeInsets.only(top: DesignTokens.spacingS),
              child: Text(
                l10n.pinDateRequired,
                style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }
}
