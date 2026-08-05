import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

/// Outcome of [BookmarkReminderSheet.show].
///
/// A null return from `show` means the sheet was dismissed without a
/// choice; a [BookmarkReminderChoice] with a null [reminderAt] means the
/// user explicitly picked "No reminder".
class BookmarkReminderChoice {
  final DateTime? reminderAt;

  const BookmarkReminderChoice(this.reminderAt);
}

/// Bottom sheet offering the Discourse-standard bookmark reminder
/// presets (In two hours / Tomorrow / Next week / Custom date & time /
/// No reminder). Purely a picker — callers own the create/update call.
class BookmarkReminderSheet {
  BookmarkReminderSheet._();

  static Future<BookmarkReminderChoice?> show(
    BuildContext context, {
    String title = 'Bookmark with reminder',
    DateTime? currentReminderAt,
  }) {
    return showModalBottomSheet<BookmarkReminderChoice>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusL)),
      ),
      builder: (sheetContext) =>
          _BookmarkReminderSheetBody(
        title: title,
        currentReminderAt: currentReminderAt,
      ),
    );
  }

  // ===== Discourse-standard preset times =====

  static DateTime inTwoHours() => DateTime.now().add(const Duration(hours: 2));

  /// Tomorrow at 8:00 AM (Discourse's "Tomorrow" preset).
  static DateTime tomorrowMorning() {
    final t = DateTime.now().add(const Duration(days: 1));
    return DateTime(t.year, t.month, t.day, 8);
  }

  /// Next Monday at 8:00 AM (Discourse's "Next week" preset).
  static DateTime nextWeekMorning() {
    final now = DateTime.now();
    var days = (DateTime.monday - now.weekday + 7) % 7;
    if (days == 0) days = 7;
    final t = now.add(Duration(days: days));
    return DateTime(t.year, t.month, t.day, 8);
  }
}

class _BookmarkReminderSheetBody extends StatelessWidget {
  final String title;
  final DateTime? currentReminderAt;

  const _BookmarkReminderSheetBody({
    required this.title,
    this.currentReminderAt,
  });

  String _describe(BuildContext context, DateTime dt) {
    final local = dt.toLocal();
    final date = MaterialLocalizations.of(context).formatMediumDate(local);
    final time = TimeOfDay.fromDateTime(local).format(context);
    return '$date, $time';
  }

  void _pick(BuildContext context, DateTime? reminderAt) {
    Navigator.pop(context, BookmarkReminderChoice(reminderAt));
  }

  Future<void> _pickCustom(BuildContext context) async {
    final now = DateTime.now();
    final initial = currentReminderAt?.toLocal().isAfter(now) == true
        ? currentReminderAt!.toLocal()
        : now.add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !context.mounted) return;
    final chosen =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (!chosen.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder time must be in the future')),
      );
      return;
    }
    _pick(context, chosen);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final twoHours = BookmarkReminderSheet.inTwoHours();
    final tomorrow = BookmarkReminderSheet.tomorrowMorning();
    final nextWeek = BookmarkReminderSheet.nextWeekMorning();

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.spacingL,
              DesignTokens.spacingL,
              DesignTokens.spacingL,
              DesignTokens.spacingS,
            ),
            child: Row(
              children: [
                Icon(Icons.alarm, color: colorScheme.primary),
                const SizedBox(width: DesignTokens.spacingS),
                Expanded(
                  child: Text(title, style: textTheme.titleMedium),
                ),
                if (currentReminderAt != null)
                  Text(
                    _describe(context, currentReminderAt!),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.schedule, color: colorScheme.primary),
            title: const Text('In two hours'),
            subtitle: Text(_describe(context, twoHours)),
            onTap: () => _pick(context, twoHours),
          ),
          ListTile(
            leading: Icon(Icons.wb_sunny_outlined, color: colorScheme.primary),
            title: const Text('Tomorrow'),
            subtitle: Text(_describe(context, tomorrow)),
            onTap: () => _pick(context, tomorrow),
          ),
          ListTile(
            leading: Icon(Icons.next_week_outlined, color: colorScheme.primary),
            title: const Text('Next week'),
            subtitle: Text(_describe(context, nextWeek)),
            onTap: () => _pick(context, nextWeek),
          ),
          ListTile(
            leading: Icon(Icons.calendar_month, color: colorScheme.primary),
            title: const Text('Custom date & time'),
            onTap: () => _pickCustom(context),
          ),
          ListTile(
            leading: Icon(Icons.alarm_off, color: colorScheme.onSurfaceVariant),
            title: Text(
              currentReminderAt != null ? 'Clear reminder' : 'No reminder',
            ),
            onTap: () => _pick(context, null),
          ),
          const SizedBox(height: DesignTokens.spacingS),
        ],
      ),
    );
  }
}
