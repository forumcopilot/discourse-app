import 'discourse_emoji_data.dart';

/// Turns Discourse emoji shortcodes into the characters they stand for.
///
/// Cooked post HTML carries emoji as `<img class="emoji" alt=":warning:">`,
/// and the HTML renderer already swaps those for the system glyph. Plain
/// text does not go through that path: topic-list excerpts and titles come
/// off the API as literal text with the shortcode still in it, so a topic
/// opening with a warning sign rendered as `:warning: WARNING! The upgrade
/// requires…` in the list and as ⚠️ once opened.
///
/// Names are resolved against Discourse's own table (see
/// [discourseEmojiByName]), not a generic emoji library: Discourse's
/// vocabulary — `:studio_microphone:`, `:slight_smile:`, `:+1:`, the
/// `:wave:t3:` skin-tone suffix — only partly overlaps the short names other
/// libraries use, and a title on meta.discourse.org showed the raw
/// `:studio_microphone:` for exactly that reason.
///
/// Only shortcodes Discourse itself would render are replaced. Forum-custom
/// emoji (`:my_company_logo:`) have no character to become, and a
/// half-translated string is worse than an untouched one — those are left
/// exactly as they were.
String withEmojiShortcodes(String text) {
  if (text.isEmpty || !text.contains(':')) return text;
  return text.replaceAllMapped(_shortcode, (m) {
    return discourseEmojiChar(m.group(1)!, tone: m.group(2)) ?? m.group(0)!;
  });
}

/// The character for the Discourse shortcode [name] (without colons), or
/// null when Discourse has no Unicode emoji under that name.
///
/// [tone] is the digit of an optional `:tN:` suffix. `t1` is the unmodified
/// emoji; `t2`..`t6` apply the matching Fitzpatrick modifier the way
/// `Emoji.lookup_unicode` does in app/models/emoji.rb — inserted after the
/// first code point, replacing a variation selector if one sits there. A
/// tone on an emoji that does not take one is ignored.
String? discourseEmojiChar(String name, {String? tone}) {
  final char = discourseEmojiByName[name];
  if (char == null) return null;
  if (tone == null || tone == '1') return char;
  if (!discourseTonableEmoji.contains(name)) return char;
  final index = int.parse(tone) - 2;
  if (index < 0 || index >= discourseFitzpatrickScale.length) return char;
  final runes = char.runes.toList();
  if (runes.length > 1 && runes[1] == _variationSelector16) runes.removeAt(1);
  runes.insert(1, discourseFitzpatrickScale[index]);
  return String.fromCharCodes(runes);
}

const int _variationSelector16 = 0xfe0f;

/// `:name:` or `:name:tN:` where name is the shortcode charset Discourse
/// allows — letters, digits, `_`, `+`, `-` — and N a skin tone 1–6.
/// Deliberately strict: a loose pattern eats things like `10:30` and
/// `http://` out of ordinary prose.
final RegExp _shortcode =
    RegExp(r':([a-z0-9_+-]+)(?::t([1-6]))?:', caseSensitive: false);
