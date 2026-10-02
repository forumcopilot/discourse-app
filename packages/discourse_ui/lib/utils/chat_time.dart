import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/generated/app_localizations.dart';

/// When a chat's last message was, as Discourse's chat list says it: the
/// time today, "Yesterday", the weekday within the week, then a short date
/// (with the year once it is not this year's).
String formatChatListTime(BuildContext context, DateTime when, {DateTime? now}) {
  final local = when.toLocal();
  final today = now ?? DateTime.now();
  final locale = Localizations.localeOf(context).toLanguageTag();
  final day = DateTime(local.year, local.month, local.day);
  final todayDay = DateTime(today.year, today.month, today.day);
  final daysAgo = todayDay.difference(day).inDays;
  if (daysAgo <= 0) {
    final use24 = MediaQuery.maybeAlwaysUse24HourFormatOf(context) ?? false;
    return (use24 ? DateFormat.Hm(locale) : DateFormat.jm(locale)).format(local);
  }
  if (daysAgo == 1) return AppLocalizations.of(context)!.chatYesterday;
  if (daysAgo < 7) return DateFormat.E(locale).format(local);
  if (local.year == today.year) return DateFormat.MMMd(locale).format(local);
  return DateFormat.yMMMd(locale).format(local);
}
