import 'package:discourse_core/discourse_core.dart';
import 'package:test/test.dart';

/// `valid_reactions` is what the reaction picker may offer.
///
/// Regression cover for a real defect: `/discourse-reactions/custom-reactions`
/// 404s on try.discourse.org while the same forum serializes seven
/// `valid_reactions` and its posts carry heart and open_mouth. Treating that
/// 404 as "reactions are unavailable, offer only a like" left the picker
/// showing one reaction on a forum that accepts seven.
void main() {
  setUp(DiscourseValidReactions.clear);

  test('unknown until a topic payload has been seen', () {
    expect(DiscourseValidReactions.current, isNull,
        reason: 'null means unknown, so callers fall back instead of '
            'rendering an empty picker');
  });

  test('records the set a topic payload reports', () {
    DiscourseValidReactions.store(
        ['heart', '+1', 'laughing', 'open_mouth', 'clap', 'confetti_ball', 'hugs']);
    expect(DiscourseValidReactions.current, hasLength(7));
    expect(DiscourseValidReactions.current, contains('open_mouth'));
    // Not the hardcoded fallback set: that one guesses tada/rocket/eyes,
    // which this forum does not enable.
    expect(DiscourseValidReactions.current, isNot(contains('rocket')));
  });

  test('a payload without the key does not erase a known answer', () {
    DiscourseValidReactions.store(['heart', '+1']);
    // Not every topic response carries it; a missing key says nothing.
    DiscourseValidReactions.store(null);
    DiscourseValidReactions.store(const []);
    DiscourseValidReactions.store('not a list');
    expect(DiscourseValidReactions.current, ['heart', '+1']);
  });

  test('ignores non-string and empty entries', () {
    DiscourseValidReactions.store(['heart', '', 42, null, '+1']);
    expect(DiscourseValidReactions.current, ['heart', '+1']);
  });
}
