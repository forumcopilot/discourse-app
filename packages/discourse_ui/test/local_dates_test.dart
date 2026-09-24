import 'package:discourse_ui/utils/local_dates.dart';
import 'package:discourse_ui/utils/post_events.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Local dates and calendar events are stored as wall time in the author's
/// zone; the web shows them in the reader's. The expectations below are
/// built from `toLocal()` so they hold in any zone the test machine is in.
void main() {
  setUpAll(() => initializeDateFormatting('de'));

  final words = RelativeDayWords(
    today: (t) => 'Today $t',
    tomorrow: (t) => 'Tomorrow $t',
    yesterday: (t) => 'Yesterday $t',
  );

  String fmt(Map<Object, String> a, {DateTime? now, String locale = 'en', bool h24 = false,
          Map<Object, String>? from}) =>
      formatLocalDate(a,
          now: now ?? DateTime(2030, 1, 1),
          locale: locale,
          use24Hour: h24,
          words: words,
          rangeFrom: from)!;

  test('a date with a time is converted to the reader\'s zone, in LLL', () {
    // 11:12 in Berlin (UTC+2 in September) is 09:12 UTC.
    final a = {'data-date': '2026-09-18', 'data-time': '11:12', 'data-timezone': 'Europe/Berlin'};
    final local = DateTime.utc(2026, 9, 18, 9, 12).toLocal();
    expect(fmt(a), formatMoment(local, 'LLL', 'en'));
    expect(fmt(a), contains('2026'));
  });

  test('the post\'s own data-format wins; locale names are used', () {
    final a = {
      'data-date': '2025-11-06', 'data-time': '11:54:49', 'data-timezone': 'UTC', 'data-format': 'll',
    };
    final local = DateTime.utc(2025, 11, 6, 11, 54, 49).toLocal();
    expect(fmt(a), formatMoment(local, 'll', 'en'));
    expect(fmt(a, locale: 'de'), formatMoment(local, 'll', 'de'));
    expect(formatMoment(DateTime(2025, 11, 6), 'll', 'en'), 'Nov 6, 2025');
    expect(formatMoment(DateTime(2025, 11, 6), 'LL', 'de'), '6. November 2025');
  });

  test('moment tokens and literals', () {
    final d = DateTime(2026, 3, 1, 14, 5);
    expect(formatMoment(d, 'YYYY-MM-DD HH:mm', 'en'), '2026-03-01 14:05');
    expect(formatMoment(d, 'dddd, MMMM Do [at] h:mm A', 'en'), 'Sunday, March 1st at 2:05 PM');
    expect(formatMoment(d, 'LT', 'en', use24Hour: true), '14:05');
  });

  test('within a day of now: Today / Tomorrow / Yesterday', () {
    final a = {'data-date': '2026-09-18', 'data-time': '09:12', 'data-timezone': 'UTC'};
    final local = DateTime.utc(2026, 9, 18, 9, 12).toLocal();
    final time = formatMoment(local, 'LT', 'en');
    DateTime on(int dayOffset) =>
        DateTime(local.year, local.month, local.day + dayOffset, 12);
    expect(fmt(a, now: on(0)), 'Today $time');
    expect(fmt(a, now: on(-1)), 'Tomorrow $time');
    expect(fmt(a, now: on(1)), 'Yesterday $time');
    expect(fmt({...a, 'data-calendar': 'off'}, now: on(0)), formatMoment(local, 'LLL', 'en'));
  });

  test('a date without a time is the calendar day as written', () {
    expect(fmt({'data-date': '2026-12-25', 'data-timezone': 'UTC'}, now: DateTime(2020)),
        anyOf('December 25, 2026', startsWith('December 25, 2026 (')));
  });

  test('a pinned display zone is named', () {
    final a = {
      'data-date': '2026-09-18', 'data-time': '11:12', 'data-timezone': 'Europe/Berlin',
      'data-displayed-timezone': 'Asia/Tokyo',
    };
    final s = fmt(a);
    // Tokyo is never the zone of every test machine; when it is not, it is named.
    if (DateTime.now().timeZoneOffset != const Duration(hours: 9)) {
      expect(s, endsWith('(Tokyo)'));
      expect(s.replaceAll('\u202f', ' '), contains('6:12 PM'));
    }
  });

  test('the end of a same-day range shows only its time', () {
    final from = {'data-date': '2026-09-18', 'data-time': '10:00', 'data-timezone': 'UTC', 'data-range': 'from'};
    final to = {'data-date': '2026-09-18', 'data-time': '11:30', 'data-timezone': 'UTC', 'data-range': 'to'};
    final local = DateTime.utc(2026, 9, 18, 11, 30).toLocal();
    final sameLocalDay = DateTime.utc(2026, 9, 18, 10).toLocal().day == local.day;
    if (sameLocalDay) expect(fmt(to, from: from), formatMoment(local, 'LT', 'en'));
  });

  test('unparseable attributes: null, the cooked text stays', () {
    expect(
        formatLocalDate({'data-date': 'soon'},
            now: DateTime(2030), locale: 'en', use24Hour: false, words: words),
        isNull);
  });

  group('events', () {
    test('a one-off event and its expiry', () {
      final e = PostEvent.fromAttributes({
        'data-start': '2026-06-05 22:00', 'data-end': '2026-06-05 22:30',
        'data-timezone': 'Europe/London', 'data-name': 'Reset',
      })!;
      expect(e.start, DateTime.utc(2026, 6, 5, 21));
      expect(e.isExpired(DateTime.utc(2026, 7)), isTrue);
      expect(e.isExpired(DateTime.utc(2026, 6)), isFalse);
    });

    test('a weekly event shows its next occurrence', () {
      final e = PostEvent.fromAttributes({
        'data-start': '2026-06-05 22:00', 'data-end': '2026-06-05 22:02',
        'data-timezone': 'Europe/London', 'data-recurrence': 'every_week',
      })!;
      final (start, end) = e.occurrenceAt(DateTime.utc(2026, 9, 23, 12));
      expect(start, DateTime.utc(2026, 9, 25, 21), reason: 'Friday 22:00 London (BST)');
      expect(end, DateTime.utc(2026, 9, 25, 21, 2));
      expect(e.isExpired(DateTime.utc(2026, 9, 23)), isFalse);
    });

    test('a monthly event keeps its weekday of the month, across DST', () {
      // Thursday 10 September 2026 is the second Thursday.
      final e = PostEvent.fromAttributes({
        'data-start': '2026-09-10 11:00', 'data-end': '2026-09-10 12:30',
        'data-timezone': 'Europe/Oslo', 'data-recurrence': 'every_month',
      })!;
      final (start, _) = e.occurrenceAt(DateTime.utc(2026, 11, 1));
      // Second Thursday of November, 11:00 Oslo = 10:00 UTC (winter time).
      expect(start, DateTime.utc(2026, 11, 12, 10));
    });

    test('no start, no event', () {
      expect(PostEvent.fromAttributes({'data-name': 'x'}), isNull);
    });
  });
}
