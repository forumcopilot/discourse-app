/// A short plain-text preview of Discourse Markdown the server has not
/// cooked yet — a pending post, a draft — for a two- or three-line quote.
///
/// Not a Markdown renderer: it keeps the words a reader would recognise and
/// drops the syntax around them, so a preview stops opening with
/// `![image|690x388](upload://…)` or a `[quote="bob, post:3"]` block.
///
/// * Images become "[image]"; links keep their text.
/// * Quotes (`[quote]…[/quote]` and `> ` lines) and fenced code are
///   dropped — they are someone else's words or noise in a preview.
/// * Emphasis, headings, list bullets and inline code marks are stripped.
/// * Whitespace collapses to single spaces.
String markdownPreviewText(String raw, {String imageLabel = '[image]'}) {
  var s = raw;
  s = s.replaceAll(RegExp(r'\[quote[^\]]*\][\s\S]*?\[/quote\]'), ' ');
  s = s.replaceAll(RegExp(r'```[\s\S]*?```'), ' ');
  s = s.replaceAll(RegExp(r'^\s*>.*$', multiLine: true), ' ');
  s = s.replaceAll(RegExp(r'!\[[^\]]*\]\([^)]*\)'), ' $imageLabel ');
  s = s.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\([^)]*\)'), (m) => m.group(1) ?? '');
  s = s.replaceAll(RegExp(r'^\s{0,3}#{1,6}\s+', multiLine: true), '');
  s = s.replaceAll(RegExp(r'^\s*([-*+]|\d+[.)])\s+', multiLine: true), '');
  // Paired markers only, so snake_case names and a lone * survive.
  for (final marker in [r'\*\*', '__', '~~', r'\*', '`']) {
    s = s.replaceAllMapped(
        RegExp('$marker(\\S(?:.*?\\S)?)$marker'), (m) => m.group(1) ?? '');
  }
  s = s.replaceAllMapped(
      RegExp(r'(?<![\w])_(\S(?:.*?\S)?)_(?![\w])'), (m) => m.group(1) ?? '');
  s = s.replaceAll(RegExp(r'<[^>]+>'), ' ');
  return s.replaceAll(RegExp(r'\s+'), ' ').trim();
}
