import 'package:discourse_ui/views/widgets/reaction_glyph.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reaction ids are Discourse emoji names. They used to go through a
/// generic emoji library plus a hand-kept alias table for the names that
/// library files differently; now they resolve against Discourse's own
/// table. These are the entries the alias table carried, so deleting it
/// cannot silently regress the default reaction set.
void main() {
  test('resolves Discourse default reactions', () {
    expect(ReactionGlyph.unicodeFor('+1'), '\u{1F44D}');
    expect(ReactionGlyph.unicodeFor(':-1:'), '\u{1F44E}');
    expect(ReactionGlyph.unicodeFor('heart'), '\u{2764}\u{FE0F}');
    expect(ReactionGlyph.unicodeFor('laughing'), '\u{1F606}');
    expect(ReactionGlyph.unicodeFor('open_mouth'), '\u{1F62E}');
    expect(ReactionGlyph.unicodeFor('clap'), '\u{1F44F}');
    expect(ReactionGlyph.unicodeFor('hugs'), '\u{1F917}');
    expect(ReactionGlyph.unicodeFor('confetti_ball'), '\u{1F38A}');
  });

  test('resolves names only Discourse uses', () {
    expect(ReactionGlyph.unicodeFor('slight_smile'), '\u{1F642}');
    expect(ReactionGlyph.unicodeFor('studio_microphone'), isNotNull);
  });

  test('custom emoji and empty ids fall through', () {
    expect(ReactionGlyph.unicodeFor('party_parrot'), isNull);
    expect(ReactionGlyph.unicodeFor('::'), isNull);
  });
}
