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

  static String normalize(String reactionId) =>
      reactionId.replaceAll(':', '').trim();

  /// The unicode character for [reactionId], or null when Discourse's
  /// shortcode has no unicode equivalent (i.e. it is a custom emoji).
  ///
  /// Resolved against Discourse's own emoji table, so names like `+1`,
  /// `-1` and `hugs` — which a generic emoji library files under other
  /// short names — come out as the glyph Discourse itself shows.
  static String? unicodeFor(String reactionId) {
    final clean = normalize(reactionId);
    if (clean.isEmpty) return null;
    return discourseEmojiChar(clean);
  }

  static final Map<String, List<String>> _namesByUnicode = () {
    final names = <String, List<String>>{};
    for (final entry in discourseEmojiByName.entries) {
      (names[entry.value] ??= []).add(entry.key);
    }
    return names;
  }();

  String? _imageUrl(String siteUrl, String name, String? unicode) {
    final exact = DiscourseCustomEmoji.urlFor(siteUrl, name);
    if (exact != null || unicode == null) return exact;
    // /emojis.json lists canonical names, while channel settings also accept
    // aliases such as art (artist_palette) and computer (laptop).
    for (final alias in _namesByUnicode[unicode] ?? const <String>[]) {
      final url = DiscourseCustomEmoji.urlFor(siteUrl, alias);
      if (url != null) return url;
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
    final name = normalize(reactionId);
    if (site == null || name.isEmpty) {
      return unicode == null
          ? _fallback(context)
          : Text(unicode, style: TextStyle(fontSize: size));
    }
    return ValueListenableBuilder<int>(
      valueListenable: DiscourseCustomEmoji.revision,
      builder: (context, _, __) {
        final url = _imageUrl(site.site.url, name, unicode);
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
          semanticLabel: ':$name:',
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
