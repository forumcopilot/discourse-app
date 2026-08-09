import 'package:discourse_core/discourse_core.dart';
import 'package:test/test.dart';

/// Regression cover for quoting a post that itself contains a quote.
///
/// Found on try.discourse.org: "Reply with Quote" on a post whose raw was a
/// `[chat quote=…]` block produced a quote containing channel ids, thread
/// titles and an `onmouseover=` attribute in place of the words. Web never
/// shows this because its quote is selection-driven — it copies rendered
/// text, so quote markup from the original is never collected.
void main() {
  test('drops a nested [quote] block', () {
    const raw = '''
Before.

[quote="alice, post:2, topic:9"]
something alice said
[/quote]

After.''';
    final body = DiscourseQuoteMarkup.quotableBody(raw);
    expect(body, contains('Before.'));
    expect(body, contains('After.'));
    expect(body, isNot(contains('[quote=')));
    expect(body, isNot(contains('something alice said')));
  });

  test('drops a [chat quote] block, which the quote pattern does not match',
      () {
    const raw = '''
[chat quote="bob;1;2026-08-08T00:00:00Z" channelId="1" threadId="1"]
prueba
[/chat]
my own words''';
    final body = DiscourseQuoteMarkup.quotableBody(raw);
    expect(body, 'my own words');
    expect(body, isNot(contains('channelId')));
  });

  test('handles quotes nested inside quotes', () {
    const raw = '''
[quote="alice, post:2, topic:9"]
[quote="bob, post:1, topic:9"]
innermost
[/quote]
alice replying
[/quote]
outermost words''';
    final body = DiscourseQuoteMarkup.quotableBody(raw);
    expect(body, 'outermost words');
  });

  test('a post that is only a quote yields null, not markup', () {
    const raw = '[quote="alice, post:2, topic:9"]\njust this\n[/quote]';
    // No good answer exists in raw here: an empty [quote][/quote] reads as
    // a bug, and echoing the raw reproduces the markup this removes. Null
    // tells the caller to use the post's rendered text instead — which is
    // what web's selection-based quote would have inserted.
    expect(DiscourseQuoteMarkup.quotableBody(raw), isNull);
  });

  test('a chat-only post also yields null', () {
    const raw = '[chat quote="bob;1;x" channelId="1"]\nprueba\n[/chat]';
    expect(DiscourseQuoteMarkup.quotableBody(raw), isNull);
  });

  test('leaves an ordinary post untouched', () {
    const raw = 'Plain **markdown** with a [link](https://example.com).';
    expect(DiscourseQuoteMarkup.quotableBody(raw), raw);
  });
}
