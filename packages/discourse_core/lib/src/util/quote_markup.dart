/// Preparing a post's raw Markdown to be quoted.
///
/// Discourse never nests a quote inside a quote. On web the quote button is
/// selection-driven — `buildQuote(post, contents)` in `lib/quote.js` takes
/// the text the reader selected out of the *rendered* post, so quote markup
/// from the original never comes along.
///
/// This app quotes a whole post rather than a selection, so it starts from
/// `raw` and has to remove what web never picks up. Without this, quoting a
/// post that itself quotes something produces a wall of nested markup:
/// attributes, channel ids and all, in place of the words.
class DiscourseQuoteMarkup {
  const DiscourseQuoteMarkup._();

  /// Discourse's own nested-quote pattern (`lib/quote.js`, `QUOTE_REGEXP`).
  /// The lookahead stops a match from swallowing a later sibling quote.
  static final RegExp _quoteBlock = RegExp(
    r'\[quote=([^\]]*)\]((?:[\s\S](?!\[quote=[^\]]*\]))*?)\[\/quote\]',
    caseSensitive: false,
    multiLine: true,
  );

  /// `[chat quote=…]…[/chat]`, from the chat plugin. Not matched by
  /// [_quoteBlock] — it opens with `[chat`, not `[quote=` — but it is the
  /// same problem, and it carries the noisiest attributes of the two.
  static final RegExp _chatQuoteBlock = RegExp(
    r'\[chat\b[^\]]*\][\s\S]*?\[\/chat\]',
    caseSensitive: false,
    multiLine: true,
  );

  /// The quotable body of [raw]: the post's own words, with any quotes it
  /// was itself carrying removed.
  ///
  /// Loops because quotes nest — one pass leaves the outer levels behind.
  ///
  /// Returns **null** when stripping leaves nothing, i.e. the post was
  /// *only* a quote. There is no good answer in raw at that point: emitting
  /// an empty `[quote][/quote]` reads as a bug, and quoting the raw back
  /// reproduces the markup this exists to remove. The caller should fall
  /// back to the post's rendered text, which is what web would have
  /// inserted — its quote copies rendered text, never source.
  static String? quotableBody(String raw) {
    var body = raw;
    for (var pass = 0; pass < 8; pass++) {
      final before = body;
      body = body.replaceAll(_chatQuoteBlock, '');
      body = body.replaceAll(_quoteBlock, '');
      if (body == before) break;
    }
    final trimmed = body.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
