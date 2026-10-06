import 'dart:async';

import 'package:discourse_core/discourse_core.dart' show DiscourseCustomEmoji;
import 'package:discourse_ui/utils/emoji_shortcodes.dart';
import 'package:discourse_ui/views/widgets/reaction_glyph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

const _forum = 'https://glyph.example';

SiteContext _ctx() => SiteContext(
      siteType: 'glyph-test',
      site: Site(
        id: null,
        name: 'Glyph',
        url: _forum,
        description: '',
        endpoint: null,
        baseUrl: _forum,
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'glyph-test',
      ),
    );

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

String _imageUrl(WidgetTester tester) {
  final image = tester.widget<Image>(find.byType(Image));
  return ((image.image as ResizeImage).imageProvider as NetworkImage).url;
}

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

  group('a skin tone (`:tN`)', () {
    test('keeps the emoji and applies the tone', () {
      final toned = discourseEmojiChar('wave', tone: '3');
      expect(toned, isNot(discourseEmojiChar('wave')));
      expect(ReactionGlyph.unicodeFor('wave:t3'), toned);
      expect(ReactionGlyph.unicodeFor(':wave:t3:'), toned);
      expect(ReactionGlyph.unicodeFor('wave:t1'), discourseEmojiChar('wave'),
          reason: 'tone 1 is the plain emoji');
      expect(ReactionGlyph.normalize(':wave:t3:'), 'wave:t3');
      expect(ReactionGlyph.parse('wave:t3'), (name: 'wave', tone: 3));
    });

    testWidgets('is drawn as the toned emoji, not the unknown outline',
        (tester) async {
      await tester.pumpWidget(_app(const ReactionGlyph(reactionId: 'wave:t3')));
      expect(find.text(discourseEmojiChar('wave', tone: '3')!), findsOneWidget);
      expect(find.byIcon(Icons.emoji_emotions_outlined), findsNothing);
    });

    testWidgets("the forum's artwork is the toned image, as the web's",
        (tester) async {
      DiscourseCustomEmoji.clear();
      final arrived = Completer<Object?>();
      DiscourseCustomEmoji.fetchOverride = (_) => arrived.future;
      addTearDown(() {
        DiscourseCustomEmoji.fetchOverride = null;
        DiscourseCustomEmoji.clear();
      });
      await tester.pumpWidget(_app(ReactionGlyph(
          reactionId: 'wave:t3',
          size: 20,
          siteContext: _ctx(),
          preferImage: true)));
      arrived.complete({
        'people': [
          {'name': 'wave', 'url': '/images/emoji/twitter/wave.png?v=12'},
        ],
      });
      await tester.pump();
      await tester.pump();
      expect(_imageUrl(tester), '$_forum/images/emoji/twitter/wave/3.png?v=12');
    });
  });
}
