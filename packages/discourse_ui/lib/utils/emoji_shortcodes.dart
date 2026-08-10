import 'package:emojis/emoji.dart';

/// Turns Discourse emoji shortcodes into the characters they stand for.
///
/// Cooked post HTML carries emoji as `<img class="emoji" alt=":warning:">`,
/// and the HTML renderer already swaps those for the system glyph. Plain
/// text does not go through that path: topic-list excerpts and titles come
/// off the API as literal text with the shortcode still in it, so a topic
/// opening with a warning sign rendered as `:warning: WARNING! The upgrade
/// requires…` in the list and as ⚠️ once opened.
///
/// Only shortcodes that resolve to a real Unicode emoji are replaced.
/// Forum-custom emoji (`:my_company_logo:`) have no character to become,
/// and a half-translated string is worse than an untouched one — those are
/// left exactly as they were.
String withEmojiShortcodes(String text) {
  if (text.isEmpty || !text.contains(':')) return text;
  return text.replaceAllMapped(_shortcode, (m) {
    final name = m.group(1)!;
    final char = Emoji.byShortName(name)?.char;
    return char ?? m.group(0)!;
  });
}

/// `:name:` where name is the shortcode charset Discourse allows —
/// letters, digits, `_`, `+`, `-`. Deliberately strict: a loose pattern
/// eats things like `10:30` and `http://` out of ordinary prose.
final RegExp _shortcode = RegExp(r':([a-z0-9_+-]+):', caseSensitive: false);
