import 'package:discourse_ui/utils/discourse_markup.dart';
import 'package:flutter/services.dart' show TextEditingValue, TextSelection;
import 'package:flutter_test/flutter_test.dart';

/// Selection helper: `value('ab|cd')` puts the caret at `|`, and
/// `value('a[bc]d')` selects `bc`.
TextEditingValue _at(String text, int offset) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );

TextEditingValue _sel(String text, int start, int end) => TextEditingValue(
      text: text,
      selection: TextSelection(baseOffset: start, extentOffset: end),
    );

void main() {
  group('Markdown where Markdown has the concept', () {
    test('bold and italic wrap the selection with asterisks', () {
      expect(DiscourseMarkup.apply(_sel('make me bold', 8, 12), 'B').text,
          'make me **bold**');
      expect(DiscourseMarkup.apply(_sel('make me loud', 8, 12), 'I').text,
          'make me *loud*');
    });

    test('strikethrough uses ~~, not [s]', () {
      expect(DiscourseMarkup.apply(_sel('oops nope', 5, 9), 'S').text,
          'oops ~~nope~~');
    });

    test('inline code uses backticks; multi-line uses a fence', () {
      expect(DiscourseMarkup.apply(_sel('run ls now', 4, 6), 'CODE').text,
          'run `ls` now');
      expect(DiscourseMarkup.apply(_sel('a\nb', 0, 3), 'CODE').text,
          '```\na\nb\n```');
    });

    test('link and image use Markdown syntax', () {
      expect(DiscourseMarkup.apply(_sel('see docs here', 4, 8), 'URL').text,
          'see [docs](url) here');
      expect(DiscourseMarkup.apply(_at('', 0), 'IMG').text, '![]()');
    });
  });

  group('BBCode only where it is the native spelling', () {
    test('underline emits [u] — Markdown has no underline', () {
      expect(DiscourseMarkup.apply(_sel('hello there', 6, 11), 'U').text,
          'hello [u]there[/u]');
    });

    test('quote emits the block [quote] Discourse parses', () {
      expect(DiscourseMarkup.apply(_sel('cited', 0, 5), 'QUOTE').text,
          '[quote]\ncited\n[/quote]');
    });

    test('spoiler emits [spoiler] from the bundled plugin', () {
      expect(DiscourseMarkup.apply(_sel('ending', 0, 6), 'SPOILER').text,
          '[spoiler]ending[/spoiler]');
    });
  });

  group('Actions Discourse has no markup for', () {
    test('lists become per-line Markdown markers, not [LIST]/[*]', () {
      // The regression: `[LIST]` and `[*]` are not in Discourse's BBCode
      // subset and posted as literal bracketed text.
      final bulleted = DiscourseMarkup.apply(_sel('one\ntwo\nthree', 0, 13), 'LIST');
      expect(bulleted.text, '- one\n- two\n- three\n');
      expect(bulleted.text, isNot(contains('[')));

      final numbered =
          DiscourseMarkup.apply(_sel('one\ntwo\nthree', 0, 13), 'LIST=1');
      expect(numbered.text, '1. one\n2. two\n3. three\n');
    });

    test('an empty list insert starts an item on its own line', () {
      expect(DiscourseMarkup.apply(_at('intro', 5), 'LIST').text, 'intro\n- ');
      expect(DiscourseMarkup.apply(_at('', 0), 'LIST=1').text, '1. ');
    });

    test('video isolates the URL on its own line so Discourse oneboxes it', () {
      final r = DiscourseMarkup.apply(
          _sel('watch https://youtu.be/abc now', 6, 26), 'VIDEO');
      expect(r.text, 'watch \nhttps://youtu.be/abc\n now');
      expect(r.text, isNot(contains('[video]')));
    });

    test('alignment tags are not supported and leave the text untouched', () {
      // The new-conversation composer used to offer these; they are gone
      // from the toolbar now, and the mapping refuses them regardless.
      for (final tag in ['LEFT', 'CENTER', 'RIGHT', 'COLOR', 'SIZE']) {
        final before = _sel('text', 0, 4);
        expect(DiscourseMarkup.apply(before, tag).text, 'text',
            reason: '$tag must not emit markup Discourse cannot parse');
        expect(DiscourseMarkup.supportedActions, isNot(contains(tag)));
      }
    });
  });

  group('Cursor placement', () {
    test('with no selection the caret lands between the markers', () {
      final r = DiscourseMarkup.apply(_at('ab', 1), 'B');
      expect(r.text, 'a****b');
      expect(r.selection.baseOffset, 3); // between ** and **
    });

    test('with a selection the caret lands after the wrapped text', () {
      final r = DiscourseMarkup.apply(_sel('ab', 0, 2), 'B');
      expect(r.text, '**ab**');
      expect(r.selection.baseOffset, 6);
    });

    test('an invalid cursor position appends instead of throwing', () {
      final r = DiscourseMarkup.apply(_at('tail', -1), 'B');
      expect(r.text, 'tail****');
      expect(r.selection.baseOffset, 6);
    });
  });

  group('Attachment references', () {
    test('images embed inline, other files render as a download link', () {
      expect(DiscourseMarkup.attachmentRef('upload://abc.png', isImage: true),
          '![image](upload://abc.png)');
      expect(DiscourseMarkup.attachmentRef('upload://abc.zip', isImage: false),
          '[file|attachment](upload://abc.zip)');
    });
  });
}
