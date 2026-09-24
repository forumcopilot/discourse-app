import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

bool _timeZonesLoaded = false;

/// The IANA zone called [name], or null when unknown. The zone database is
/// loaded the first time a post needs it.
tz.Location? timeZoneNamed(String? name) {
  if (name == null || name.trim().isEmpty) return null;
  if (!_timeZonesLoaded) {
    tzdata.initializeTimeZones();
    _timeZonesLoaded = true;
  }
  try {
    return tz.getLocation(name.trim());
  } catch (_) {
    return null;
  }
}

/// The instant a wall-clock time in [zone] stands for (UTC when the zone is
/// unknown), as a plain UTC [DateTime].
///
/// Not a TZDateTime: its `toLocal()` converts to the timezone package's own
/// `local`, which is UTC unless set, rather than the device's zone.
DateTime instantIn(String? zone, int y, int m, int d, [int h = 0, int min = 0, int s = 0]) {
  final location = timeZoneNamed(zone);
  if (location == null) return DateTime.utc(y, m, d, h, min, s);
  return DateTime.fromMillisecondsSinceEpoch(
      tz.TZDateTime(location, y, m, d, h, min, s).millisecondsSinceEpoch,
      isUtc: true);
}

/// [instant] as wall-clock time in [zone] (the device's zone when unknown).
DateTime wallTimeIn(String? zone, DateTime instant) {
  final location = timeZoneNamed(zone);
  return location == null ? instant.toLocal() : tz.TZDateTime.from(instant, location);
}

/// "Today %{time}" and its siblings, in the reader's language.
class RelativeDayWords {
  const RelativeDayWords({
    required this.today,
    required this.tomorrow,
    required this.yesterday,
  });

  final String Function(String time) today;
  final String Function(String time) tomorrow;
  final String Function(String time) yesterday;
}

/// A `span.discourse-local-date` (discourse-local-dates, also used inside
/// GitHub oneboxes and events) in the reader's time zone, as the web shows
/// it. The cooked text is a UTC fallback (`2026-09-18T09:12:00Z`) meant for
/// email; the web replaces it with the local time, and so does this.
///
/// Mirrors the plugin's LocalDateBuilder: `LLL` for a date with a time,
/// `LL` without, or the post's own `data-format`; "Today 3:00 PM" and
/// friends within a day of now; a date shown in another zone than the
/// reader's names that zone. Returns null when the attributes do not parse,
/// so the caller keeps the cooked text.
String? formatLocalDate(
  Map<Object, String> a, {
  required DateTime now,
  required String locale,
  required bool use24Hour,
  required RelativeDayWords words,
  Map<Object, String>? rangeFrom,
}) {
  final date = _parseDate(a['data-date']);
  if (date == null) return null;
  final time = _parseTime(a['data-time']);
  final hasTime = time != null;
  final zone = _nonEmpty(a['data-timezone']) ?? 'UTC';
  final instant = instantIn(zone, date.$1, date.$2, date.$3, time?.$1 ?? 0, time?.$2 ?? 0, time?.$3 ?? 0);

  // A date alone is a calendar day where it was written; a time is shown
  // in the reader's zone unless the post pins another.
  final displayedZone = _nonEmpty(a['data-displayed-timezone']) ?? (hasTime ? null : zone);
  final displayLocation = timeZoneNamed(displayedZone);
  final shown = displayLocation == null
      ? instant.toLocal()
      : tz.TZDateTime.from(instant, displayLocation);
  final sameZone = displayLocation == null ||
      shown.timeZoneOffset == instant.toLocal().timeZoneOffset;
  String withZone(String s) =>
      sameZone ? s : '$s (${_zoneLabel(displayedZone!)})';

  final timeOnly = use24Hour ? 'HH:mm' : 'LT';

  // The end of a range on the same day as its start shows just the time.
  if (rangeFrom != null && hasTime) {
    final from = _parseDate(rangeFrom['data-date']);
    final fromTime = _parseTime(rangeFrom['data-time']);
    if (from != null && fromTime != null) {
      final start = instantIn(_nonEmpty(rangeFrom['data-timezone']) ?? 'UTC', from.$1, from.$2,
              from.$3, fromTime.$1, fromTime.$2, fromTime.$3)
          .toLocal();
      final end = instant.toLocal();
      if (start.year == end.year && start.month == end.month && start.day == end.day) {
        return withZone(formatMoment(shown, timeOnly, locale));
      }
    }
  }

  final calendar = (a['data-calendar'] ?? 'on') != 'off';
  if (calendar && sameZone) {
    final local = instant.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    final windowStart = local.subtract(const Duration(days: 2));
    final windowEnd = DateTime(day.year, day.month, day.day + 2);
    if (now.isAfter(windowStart) && now.isBefore(windowEnd)) {
      if (hasTime && local.hour == 0 && local.minute == 0) {
        return formatMoment(local, 'dddd', locale);
      }
      final today = DateTime(now.year, now.month, now.day);
      final days = DateTime.utc(day.year, day.month, day.day)
          .difference(DateTime.utc(today.year, today.month, today.day))
          .inDays;
      final t = hasTime ? formatMoment(local, timeOnly, locale) : '';
      switch (days) {
        case 0:
          return words.today(t).trim();
        case 1:
          return words.tomorrow(t).trim();
        case -1:
          return words.yesterday(t).trim();
        default:
          return formatMoment(local, 'L', locale);
      }
    }
  }

  final format = _nonEmpty(a['data-format']) ?? (hasTime ? 'LLL' : 'LL');
  return withZone(formatMoment(shown, format, locale, use24Hour: use24Hour));
}

/// Formats [dt] with a moment.js pattern (what `data-format` holds), using
/// the reader's locale for names and long forms: `LLL` is
/// "September 18, 2026 11:12 AM" in English, "18. September 2026 11:12" in
/// German. Tokens moment knows but a phone reader has no use for (zone
/// names, offsets) are dropped.
String formatMoment(DateTime dt, String pattern, String locale, {bool use24Hour = false}) {
  String f(String skeleton) => DateFormat(skeleton, locale).format(dt);
  String time({bool seconds = false}) => use24Hour
      ? f(seconds ? 'Hms' : 'Hm')
      : (seconds ? DateFormat.jms(locale) : DateFormat.jm(locale)).format(dt);
  String two(int n) => n.toString().padLeft(2, '0');
  final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;

  final out = StringBuffer();
  for (final m in _momentToken.allMatches(pattern)) {
    final t = m.group(0)!;
    if (t.startsWith('[')) {
      out.write(t.substring(1, t.length - 1));
      continue;
    }
    switch (t) {
      case 'LTS':
        out.write(time(seconds: true));
      case 'LT':
        out.write(time());
      case 'LLLL':
        out.write('${DateFormat.yMMMMEEEEd(locale).format(dt)} ${time()}');
      case 'LLL':
        out.write('${DateFormat.yMMMMd(locale).format(dt)} ${time()}');
      case 'LL':
        out.write(DateFormat.yMMMMd(locale).format(dt));
      case 'L':
      case 'l':
        out.write(DateFormat.yMd(locale).format(dt));
      case 'llll':
        out.write('${DateFormat.yMMMEd(locale).format(dt)} ${time()}');
      case 'lll':
        out.write('${DateFormat.yMMMd(locale).format(dt)} ${time()}');
      case 'll':
        out.write(DateFormat.yMMMd(locale).format(dt));
      case 'YYYY':
        out.write(dt.year);
      case 'YY':
        out.write(two(dt.year % 100));
      case 'MMMM':
        out.write(f('MMMM'));
      case 'MMM':
        out.write(f('MMM'));
      case 'MM':
        out.write(two(dt.month));
      case 'M':
        out.write(dt.month);
      case 'Do':
        out.write(locale.startsWith('en') ? _englishOrdinal(dt.day) : '${dt.day}.');
      case 'DD':
        out.write(two(dt.day));
      case 'D':
        out.write(dt.day);
      case 'dddd':
        out.write(f('EEEE'));
      case 'ddd':
      case 'dd':
        out.write(f('EEE'));
      case 'HH':
        out.write(two(dt.hour));
      case 'H':
        out.write(dt.hour);
      case 'hh':
        out.write(two(h12));
      case 'h':
        out.write(h12);
      case 'mm':
        out.write(two(dt.minute));
      case 'm':
        out.write(dt.minute);
      case 'ss':
        out.write(two(dt.second));
      case 's':
        out.write(dt.second);
      case 'A':
        out.write(f('a'));
      case 'a':
        out.write(f('a').toLowerCase());
      case 'ZZ':
      case 'Z':
      case 'zz':
      case 'z':
        break;
      default:
        out.write(t);
    }
  }
  return out.toString().replaceAll(RegExp(r'\s{2,}'), ' ').trim();
}

final RegExp _momentToken = RegExp(
    r'\[[^\]]*\]|LTS|LT|LLLL|LLL|LL|L|llll|lll|ll|l|YYYY|YY|MMMM|MMM|MM|M|Do|DD|D|dddd|ddd|dd|HH|H|hh|h|mm|m|ss|s|A|a|ZZ|Z|zz|z|.',
    dotAll: true);

String _englishOrdinal(int n) {
  final mod100 = n % 100;
  if (mod100 >= 11 && mod100 <= 13) return '${n}th';
  return switch (n % 10) { 1 => '${n}st', 2 => '${n}nd', 3 => '${n}rd', _ => '${n}th' };
}

/// "Europe/Berlin" → "Berlin", "America/Argentina/Buenos_Aires" → "Argentina",
/// as the plugin labels a zone.
String _zoneLabel(String zone) {
  final parts = zone.replaceAll('_', ' ').replaceAll('Etc/', '').split('/');
  return parts.length > 1 ? parts[1] : parts[0];
}

(int, int, int)? _parseDate(String? s) {
  final m = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(s?.trim() ?? '');
  if (m == null) return null;
  return (int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
}

(int, int, int)? _parseTime(String? s) {
  final m = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?').firstMatch(s?.trim() ?? '');
  if (m == null) return null;
  return (int.parse(m.group(1)!), int.parse(m.group(2)!), int.tryParse(m.group(3) ?? '') ?? 0);
}

String? _nonEmpty(String? s) {
  final t = s?.trim();
  return (t == null || t.isEmpty) ? null : t;
}
