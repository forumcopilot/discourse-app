import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// Discourse holds a new user's first post as "typed too fast" when
/// typing_duration_msecs is under fast_typing_threshold (3 s by default), and
/// reads a missing value as 0 — so these fields decide whether a newcomer's
/// first post from the app is published.
void main() {
  final timing = DiscourseComposerTiming.instance;
  late DateTime now;

  setUp(() {
    now = DateTime.utc(2026, 9, 29, 1);
    timing.clock = () => now;
  });

  void advance(int ms) => now = now.add(Duration(milliseconds: ms));

  test('counts 100 ms per 100 ms in which the text changed, as the web composer does', () {
    final s = timing.open();
    for (var i = 0; i < 40; i++) {
      timing.typed(s);
      advance(100); // steady typing: 4 s
    }
    advance(20000); // reading, not typing
    timing.typed(s);
    expect(timing.current, {
      DiscourseComposerTiming.typingKey: 4100,
      DiscourseComposerTiming.openKey: 24000,
    });
    timing.close(s);
  });

  test('a burst of changes inside 100 ms (a paste) counts once', () {
    final s = timing.open();
    for (var i = 0; i < 50; i++) {
      timing.typed(s);
      advance(1);
    }
    expect(timing.current![DiscourseComposerTiming.typingKey], 100);
    timing.close(s);
  });

  test('added to POST /posts.json only, and never over what the body says', () {
    final s = timing.open();
    timing.typed(s);
    advance(5000);
    final body = timing.applyTo('/posts.json', <String, dynamic>{'raw': 'hi'}) as Map;
    expect(body['raw'], 'hi');
    expect(body[DiscourseComposerTiming.typingKey], 100);
    expect(body[DiscourseComposerTiming.openKey], 5000);
    expect(timing.applyTo('/drafts.json', <String, dynamic>{'raw': 'hi'}), {'raw': 'hi'});
    final own = timing.applyTo('/posts.json',
        <String, dynamic>{DiscourseComposerTiming.typingKey: 9999}) as Map;
    expect(own[DiscourseComposerTiming.typingKey], 9999);
    timing.close(s);
  });

  test('kept after a post, so a retried post still carries it', () {
    final s = timing.open();
    timing.typed(s);
    expect(timing.applyTo('/posts.json', <String, dynamic>{}), isNot(isEmpty));
    expect(timing.applyTo('/posts.json', <String, dynamic>{}), isNot(isEmpty));
    timing.close(s);
  });

  test('nothing is added with no composer open, and a late close cannot clear the next composer', () {
    expect(timing.current, isNull);
    expect(timing.applyTo('/posts.json', <String, dynamic>{'raw': 'x'}), {'raw': 'x'});
    final first = timing.open();
    final second = timing.open();
    timing.typed(first); // the old composer no longer counts
    timing.close(first); // nor can it clear the new one
    expect(timing.current, isNotNull);
    expect(timing.current![DiscourseComposerTiming.typingKey], 0);
    timing.close(second);
    expect(timing.current, isNull);
  });
}
