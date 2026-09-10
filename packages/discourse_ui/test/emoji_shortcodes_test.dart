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

  test('resolves names only Discourse uses', () {
    // Discourse's table, not a generic emoji library, is the authority.
    // These are all names the `emojis` package does not know, and the
    // first one is the title on meta.discourse.org that showed the raw
    // shortcode in the topic list.
    expect(withEmojiShortcodes('Voice rooms :studio_microphone:'),
        'Voice rooms \u{1F399}\u{FE0F}');
    expect(withEmojiShortcodes(':slight_smile:'), '\u{1F642}');
    expect(withEmojiShortcodes(':face_savoring_food:'), '\u{1F60B}');
    expect(withEmojiShortcodes(':melting_face:'), '\u{1FAE0}');
    expect(withEmojiShortcodes(':+1: and :-1:'), '\u{1F44D} and \u{1F44E}');
  });

  test('resolves a Discourse alias to the same character as its target', () {
    expect(withEmojiShortcodes(':wave:'), withEmojiShortcodes(':waving_hand:'));
  });

  test('applies a skin-tone suffix', () {
    expect(withEmojiShortcodes(':wave:t3:'), '\u{1F44B}\u{1F3FC}');
    // t1 is the unmodified emoji.
    expect(withEmojiShortcodes(':wave:t1:'), '\u{1F44B}');
    // A tone on something that does not take one is ignored, not kept raw.
    expect(withEmojiShortcodes(':warning:t3:'), '\u{26A0}\u{FE0F}');
  });

  test('keeps the presentation selector Discourse omits from its codes', () {
    // Discourse stores `heart` as bare U+2764; without U+FE0F it renders as
    // the monochrome dingbat on most platforms.
    expect(withEmojiShortcodes(':heart:'), '\u{2764}\u{FE0F}');
  });

  test('leaves a name Discourse itself would not render alone', () {
    // `flag_ao` is a short name in the `emojis` package but not one
    // Discourse knows, so Discourse shows it raw and so do we.
    const raw = 'visit :flag_ao: soon';
    expect(withEmojiShortcodes(raw), raw);
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
