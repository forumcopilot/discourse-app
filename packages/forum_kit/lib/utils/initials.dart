import 'package:flutter/widgets.dart';

/// The first visible character of [text], upper-cased, for letter avatars
/// and icon fallbacks.
///
/// `text[0]` is a UTF-16 code unit, not a character: for a name that starts
/// with an emoji ("🎓 Docs", "💫 The Prodigy Game…") it is half of a
/// surrogate pair, and a Text holding it throws "string is not well-formed
/// UTF-16" on every layout — an error box where the category icon should be.
/// `characters` walks grapheme clusters, so "👩‍💻" or "🇫🇷" stay whole too.
String initialOf(String text, {String fallback = '?'}) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return fallback;
  return trimmed.characters.first.toUpperCase();
}
