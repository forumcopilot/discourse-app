import 'package:discourse_ui/utils/emoji_shortcodes.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cover for the shortcode → emoji swap used in topic-list titles and
/// excerpts. The risk here is not the happy path; it is a greedy pattern
/// eating colons out of ordinary prose, which would corrupt text that was
/// perfectly fine before.
void main() {
  test('replaces a known shortcode', () {
    expect(withEmojiShortcodes(':warning: WARNING!'), '⚠️ WARNING!');
  });

  test('replaces several in one string', () {
    final out = withEmojiShortcodes('start :tada: middle :rocket: end');
    expect(out, isNot(contains(':tada:')));
    expect(out, isNot(contains(':rocket:')));
    expect(out, startsWith('start '));
    expect(out, endsWith(' end'));
  });

  test('leaves a forum-custom shortcode alone', () {
    // No Unicode character exists for it, and half-translated text is
    // worse than untouched text.
    const raw = 'ship it :my_company_logo: now';
    expect(withEmojiShortcodes(raw), raw);
  });

  test('does not eat a clock time', () {
    expect(withEmojiShortcodes('meeting at 10:30:45 today'),
        'meeting at 10:30:45 today');
  });

  test('does not eat a URL', () {
    const raw = 'see https://meta.discourse.org/t/1 for details';
    expect(withEmojiShortcodes(raw), raw);
  });

  test('leaves text with no colons untouched', () {
    const raw = 'nothing to do here';
    expect(identical(withEmojiShortcodes(raw), raw), isTrue);
  });

  test('handles an empty string', () {
    expect(withEmojiShortcodes(''), '');
  });
}
