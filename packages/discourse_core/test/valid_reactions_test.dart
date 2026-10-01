import 'package:discourse_core/discourse_core.dart';
import 'package:test/test.dart';

/// `valid_reactions` is what the reaction picker may offer, per forum.
///
/// Regression cover for two real defects:
/// * `/discourse-reactions/custom-reactions` 404s on try.discourse.org while
///   the same forum serializes seven `valid_reactions` and its posts carry
///   heart and open_mouth. Treating that 404 as "reactions are unavailable,
///   offer only a like" left the picker showing one reaction on a forum
///   that accepts seven.
/// * The set was kept once for the whole app, and a forum without the
///   plugin never replaced it, so in ABDA the picker on Godot offered the
///   14 reactions last seen on Meta.
void main() {
  const meta = 'https://meta.discourse.org';
  const godot = 'https://forum.godotengine.org';

  setUp(DiscourseValidReactions.clear);

  Map<String, dynamic> topicView({Object? valid, bool postsHaveReactions = true}) => {
        if (valid != null) 'valid_reactions': valid,
        'post_stream': {
          'posts': [
            {'id': 1, if (postsHaveReactions) 'reactions': <Object>[]},
          ],
        },
      };

  test('unknown until a topic payload has been seen', () {
    expect(DiscourseValidReactions.forSite(meta), isNull,
        reason: 'null means unknown, so callers fall back instead of '
            'rendering an empty picker');
    expect(DiscourseValidReactions.mainReaction(meta), 'heart');
    expect(DiscourseValidReactions.likesOnly(meta), isFalse);
  });

  test('records the set a topic payload reports, main reaction first', () {
    DiscourseValidReactions.storeFromTopicView(meta, topicView(valid: [
      'heart', '+1', 'laughing', 'open_mouth', 'clap', 'confetti_ball', 'hugs'
    ]));
    expect(DiscourseValidReactions.forSite(meta), hasLength(7));
    expect(DiscourseValidReactions.forSite(meta), contains('open_mouth'));
    expect(DiscourseValidReactions.forSite(meta), isNot(contains('rocket')));
    expect(DiscourseValidReactions.mainReaction(meta), 'heart');
  });

  test('a forum that likes with another emoji says so first', () {
    DiscourseValidReactions.storeFromTopicView(meta, topicView(valid: ['+1', 'heart']));
    expect(DiscourseValidReactions.mainReaction(meta), '+1');
  });

  test('each forum keeps its own set', () {
    DiscourseValidReactions.storeFromTopicView(meta, topicView(valid: ['heart', 'rocket', 'eyes']));
    // Godot runs without the plugin: no valid_reactions, no reactions on
    // its posts.
    DiscourseValidReactions.storeFromTopicView(
        godot, topicView(postsHaveReactions: false));
    expect(DiscourseValidReactions.forSite(godot), ['heart']);
    expect(DiscourseValidReactions.likesOnly(godot), isTrue);
    expect(DiscourseValidReactions.forSite(meta), ['heart', 'rocket', 'eyes'],
        reason: "Godot's payload must not touch Meta's set");
    expect(DiscourseValidReactions.likesOnly(meta), isFalse);
  });

  test('the address is matched without case or a trailing slash', () {
    DiscourseValidReactions.storeFromTopicView(meta, topicView(valid: ['heart', 'eyes']));
    expect(DiscourseValidReactions.forSite('https://Meta.Discourse.org/'), ['heart', 'eyes']);
  });

  test('a payload that says nothing does not erase a known answer', () {
    DiscourseValidReactions.storeFromTopicView(meta, topicView(valid: ['heart', '+1']));
    // Posts carry reactions but the field is missing (an older plugin):
    // nothing is learnt.
    DiscourseValidReactions.storeFromTopicView(meta, topicView());
    DiscourseValidReactions.store(meta, null);
    DiscourseValidReactions.store(meta, const []);
    DiscourseValidReactions.store(meta, 'not a list');
    expect(DiscourseValidReactions.forSite(meta), ['heart', '+1']);
  });

  test('a later topic with the plugin on replaces likes-only', () {
    DiscourseValidReactions.storeFromTopicView(godot, topicView(postsHaveReactions: false));
    DiscourseValidReactions.storeFromTopicView(godot, topicView(valid: ['heart', 'clap']));
    expect(DiscourseValidReactions.likesOnly(godot), isFalse);
    expect(DiscourseValidReactions.forSite(godot), ['heart', 'clap']);
  });

  test('ignores non-string and empty entries', () {
    DiscourseValidReactions.store(meta, ['heart', '', 42, null, '+1']);
    expect(DiscourseValidReactions.forSite(meta), ['heart', '+1']);
  });
}
