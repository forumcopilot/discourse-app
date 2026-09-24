import 'local_dates.dart';

/// A discourse-calendar event, from the `div.discourse-post-event` the
/// plugin cooks into a post. The div is empty apart from the description;
/// everything the web's event card shows is in its `data-*` attributes:
/// `data-start`/`data-end` ("2026-09-10 11:00", wall time in
/// `data-timezone`), `data-name`, `data-location`, `data-status`,
/// `data-recurrence`.
class PostEvent {
  const PostEvent({
    required this.name,
    required this.start,
    this.end,
    this.location,
    this.recurrence,
    this.status,
    this.zone,
  });

  final String? name;

  /// First occurrence, as an instant.
  final DateTime start;
  final DateTime? end;
  final String? location;

  /// `every_day`, `every_weekday`, `every_week`, `every_two_weeks`,
  /// `every_four_weeks` or `every_month` (same weekday of the month).
  final String? recurrence;

  /// `public`, `private` or `standalone`.
  final String? status;

  /// The IANA zone the event was set in; repeats follow its wall clock.
  final String? zone;

  static PostEvent? fromAttributes(Map<Object, String> a) {
    final zone = a['data-timezone'];
    final start = _parse(a['data-start'], zone);
    if (start == null) return null;
    return PostEvent(
      name: _nonEmpty(a['data-name']),
      start: start,
      end: _parse(a['data-end'], zone),
      location: _nonEmpty(a['data-location']),
      recurrence: _nonEmpty(a['data-recurrence']),
      status: _nonEmpty(a['data-status']),
      zone: _nonEmpty(zone),
    );
  }

  Duration get _length => end == null ? Duration.zero : end!.difference(start);

  /// The occurrence the web would show at [now]: the event itself, or for a
  /// repeating event the one in progress or next to come.
  (DateTime start, DateTime? end) occurrenceAt(DateTime now) {
    final length = _length;
    if (recurrence == null || !start.add(length).isBefore(now)) {
      return (start, end);
    }
    // Step in the event's own wall-clock time, so a repeat stays at 11:00
    // Oslo time across a daylight-saving change, as the web keeps it.
    DateTime at(int y, int m, int d, int h, int min) => instantIn(zone, y, m, d, h, min);
    final original = wallTimeIn(zone, start);
    var s = start;
    DateTime next(DateTime instant) {
      final d = wallTimeIn(zone, instant);
      switch (recurrence) {
        case 'every_day':
          return at(d.year, d.month, d.day + 1, d.hour, d.minute);
        case 'every_weekday':
          var add = 1;
          while (true) {
            final n = DateTime(d.year, d.month, d.day + add);
            if (n.weekday != DateTime.saturday && n.weekday != DateTime.sunday) {
              return at(n.year, n.month, n.day, d.hour, d.minute);
            }
            add++;
          }
        case 'every_week':
          return at(d.year, d.month, d.day + 7, d.hour, d.minute);
        case 'every_two_weeks':
          return at(d.year, d.month, d.day + 14, d.hour, d.minute);
        case 'every_four_weeks':
          return at(d.year, d.month, d.day + 28, d.hour, d.minute);
        case 'every_month':
          // "Every month at this weekday": the same n-th weekday, skipping
          // months that have no fifth one.
          final nth = (original.day - 1) ~/ 7;
          var y = d.year, m = d.month;
          while (true) {
            m++;
            if (m > 12) {
              m = 1;
              y++;
            }
            final offset = (original.weekday - DateTime(y, m, 1).weekday + 7) % 7;
            final day = 1 + offset + nth * 7;
            if (DateTime(y, m, day).month == m) {
              return at(y, m, day, d.hour, d.minute);
            }
          }
        default:
          return instant;
      }
    }

    for (var i = 0; i < 5000; i++) {
      if (!s.add(length).isBefore(now)) break;
      final n = next(s);
      if (!n.isAfter(s)) return (start, end);
      s = n;
    }
    return (s, end == null ? null : s.add(length));
  }

  /// Over, and not coming back.
  bool isExpired(DateTime now) =>
      recurrence == null && (end ?? start).isBefore(now);

  static DateTime? _parse(String? s, String? zone) {
    final m = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})(?:[ T](\d{1,2}):(\d{2}))?')
        .firstMatch(s?.trim() ?? '');
    if (m == null) return null;
    return instantIn(
      zone,
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
      int.tryParse(m.group(4) ?? '') ?? 0,
      int.tryParse(m.group(5) ?? '') ?? 0,
    );
  }

  static String? _nonEmpty(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}
