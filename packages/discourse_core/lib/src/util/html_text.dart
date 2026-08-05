/// Plain-text extraction for Discourse "cooked" HTML fragments.
///
/// Several Discourse serializers only ship cooked HTML (group bios,
/// badge descriptions, excerpts). The app renders these inside plain
/// [Text] widgets, so converters must flatten the markup first or the
/// user sees literal `<p>`/`<a href=…>` noise — exactly the bug this
/// helper fixes (Phase 5.46).
///
/// This is intentionally NOT an HTML renderer: links flatten to their
/// anchor text, block tags become line breaks, everything else is
/// dropped. Use a real HTML widget when layout fidelity matters.
String stripHtmlToText(String html) {
  if (html.isEmpty) return html;
  var text = html
      // Block-level closers + <br> become newlines so paragraphs stay
      // visually separated after tag-stripping.
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</(p|div|li|h[1-6]|blockquote|tr)>',
          caseSensitive: false), '\n')
      // List bullets read better with a dash.
      .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '- ')
      // Drop every remaining tag.
      .replaceAll(RegExp(r'<[^>]+>'), '');
  // Decode the entities Discourse actually emits in these fragments.
  // `&amp;` must be decoded LAST: decoding it first turns double-encoded
  // input like '&amp;lt;' into '&lt;' which the later passes would then
  // wrongly decode again into '<'.
  text = text
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&hellip;', '…')
      .replaceAll('&ndash;', '–')
      .replaceAll('&mdash;', '—');
  // Numeric character references: &#NNNN; and &#xHH;.
  text = text.replaceAllMapped(RegExp(r'&#(?:[xX]([0-9a-fA-F]+)|([0-9]+));'),
      (m) {
    final code = m[1] != null
        ? int.tryParse(m[1]!, radix: 16)
        : int.tryParse(m[2]!);
    // Reject out-of-range values and lone surrogates.
    if (code == null ||
        code <= 0 ||
        code > 0x10FFFF ||
        (code >= 0xD800 && code <= 0xDFFF)) {
      return m[0]!;
    }
    return String.fromCharCode(code);
  });
  text = text.replaceAll('&amp;', '&');
  // Collapse the whitespace the markup left behind: 3+ newlines → 2,
  // runs of spaces/tabs → one space, then trim.
  text = text
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .replaceAll(RegExp(r' ?\n ?'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
  return text;
}
