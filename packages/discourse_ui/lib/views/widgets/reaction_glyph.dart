import 'package:discourse_core/discourse_core.dart' show DiscourseCustomEmoji;
import 'package:flutter/material.dart';

import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../utils/emoji_shortcodes.dart';
import '../../utils/discourse_emoji_data.dart';

/// Renders a Discourse reaction id (an emoji shortcode like `heart`,
/// `+1`, `party_parrot`) as a glyph.
///
/// Channel avatars can prefer the forum artwork via [preferImage], with
/// Unicode as a loading or network-error fallback.
///
/// Resolution order:
///   1. Unicode emoji, when Discourse's own table maps the shortcode to one.
///   2. The forum's own image for it, from its `/emojis.json`
///      ([DiscourseCustomEmoji]): emoji an admin uploaded have no unicode
///      form. The list is read once per forum, the first time a glyph
///      needs it, and the glyph redraws when it arrives.
///   3. A neutral emoji outline while the list is loading or lacks the
///      name. It was a red heart, so a forum's own reaction read as a like.
///
/// Reactions, the picker and people's status emoji all go through here, so
/// they can never disagree about what an emoji looks like.
class ReactionGlyph extends StatelessWidget {
  /// Discourse reaction id / emoji shortcode, with or without colons.
  final String reactionId;
  final double size;

  /// The forum the emoji belongs to. Without it a name that is not in
  /// Unicode cannot be looked up and shows the outline.
  final SiteContext? siteContext;

  /// Channel icons match the forum artwork, including its chosen emoji set.
  final bool preferImage;

  const ReactionGlyph({
    super.key,
    required this.reactionId,
    this.size = 16,
    this.siteContext,
    this.preferImage = false,
  });

  /// [reactionId] without the colons around it: `wave`, or `wave:t3` with
  /// a skin tone, as Discourse writes the name in `:wave:t3:`.
  static String normalize(String reactionId) {
    final (:name, :tone) = parse(reactionId);
    return tone == null ? name : '$name:t$tone';
  }

  /// The emoji name and its skin tone (1–6), read as Discourse reads one
  /// (`Emoji.normalize_name`): `wave`, `:wave:`, `wave:t3` and `:wave:t3:`
  /// are all wave, the last two with tone 3. Stripping every colon made
  /// `wave:t3` the unknown name `wavet3`, drawn as the grey outline.
  static ({String name, int? tone}) parse(String reactionId) {
    final m = _idPattern.firstMatch(reactionId.trim());
    if (m == null) return (name: '', tone: null);
    return (
      name: m.group(1)!.replaceAll(':', '').trim(),
      tone: int.tryParse(m.group(2) ?? ''),
    );
  }

  static final RegExp _idPattern = RegExp(r'^:?(.+?)(?::t([1-6]))?:?$');

  /// The unicode character for [reactionId], or null when Discourse's
  /// shortcode has no unicode equivalent (i.e. it is a custom emoji).
  ///
  /// Resolved against Discourse's own emoji table, so names like `+1`,
  /// `-1` and `hugs` — which a generic emoji library files under other
  /// short names — come out as the glyph Discourse itself shows, with the
  /// skin tone a `:tN` suffix asks for.
  static String? unicodeFor(String reactionId) {
    final (:name, :tone) = parse(reactionId);
    if (name.isEmpty) return null;
    return discourseEmojiChar(name, tone: tone?.toString());
  }

  /// The tone whose artwork to draw: Discourse keeps a toned emoji's images
  /// beside its plain one, as `<name>/<tone>.png` for tones 2–6; tone 1 is
  /// the plain image, and an emoji that takes no tone has only that.
  static int? _artworkTone(String name, int? tone) =>
      tone != null && tone > 1 && discourseTonableEmoji.contains(name)
          ? tone
          : null;

  /// [url] (an emoji's `<name>.png`) for [tone], as the web builds it:
  /// `…/wave.png?v=15` → `…/wave/3.png?v=15`.
  static String _withTone(String url, int? tone) {
    if (tone == null) return url;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.path.endsWith('.png')) return url;
    final base = uri.path.substring(0, uri.path.length - '.png'.length);
    return uri.replace(path: '$base/$tone.png').toString();
  }

  static final Map<String, List<String>> _namesByUnicode = () {
    final names = <String, List<String>>{};
    for (final entry in discourseEmojiByName.entries) {
      (names[entry.value] ??= []).add(entry.key);
    }
    return names;
  }();

  String? _imageUrl(String siteUrl, String name, int? tone) {
    final exact = DiscourseCustomEmoji.urlFor(siteUrl, name);
    if (exact != null) return _withTone(exact, _artworkTone(name, tone));
    final unicode = discourseEmojiChar(name);
    if (unicode == null) return null;
    // /emojis.json lists canonical names, while channel settings also accept
    // aliases such as art (artist_palette) and computer (laptop).
    for (final alias in _namesByUnicode[unicode] ?? const <String>[]) {
      final url = DiscourseCustomEmoji.urlFor(siteUrl, alias);
      if (url != null) return _withTone(url, _artworkTone(alias, tone));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final unicode = unicodeFor(reactionId);
    if (unicode != null && !preferImage) {
      return Text(unicode, style: TextStyle(fontSize: size));
    }
    final site = siteContext;
    final (:name, :tone) = parse(reactionId);
    if (site == null || name.isEmpty) {
      return unicode == null
          ? _fallback(context)
          : Text(unicode, style: TextStyle(fontSize: size));
    }
    return ValueListenableBuilder<int>(
      valueListenable: DiscourseCustomEmoji.revision,
      builder: (context, _, __) {
        final url = _imageUrl(site.site.url, name, tone);
        if (url == null) {
          if (!DiscourseCustomEmoji.isLoaded(site.site.url)) {
            // ignore: discarded_futures
            DiscourseCustomEmoji.ensureLoaded(site);
          }
          return unicode == null
              ? _fallback(context)
              : Text(unicode, style: TextStyle(fontSize: size));
        }
        // Decode at display size: a custom emoji PNG can be hundreds of
        // pixels wide, and there are several per reaction row.
        final px = (size * MediaQuery.devicePixelRatioOf(context)).ceil();
        return Image.network(
          url,
          width: size,
          height: size,
          cacheWidth: px,
          cacheHeight: px,
          semanticLabel: ':${normalize(reactionId)}:',
          errorBuilder: (_, __, ___) => unicode == null
              ? _fallback(context)
              : Text(unicode, style: TextStyle(fontSize: size)),
        );
      },
    );
  }

  Widget _fallback(BuildContext context) => Icon(
        Icons.emoji_emotions_outlined,
        size: size,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        semanticLabel: ':${normalize(reactionId)}:',
      );
}
