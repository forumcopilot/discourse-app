import 'package:discourse_core/discourse_core.dart' show DiscourseCustomEmoji;
import 'package:flutter/material.dart';

import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../utils/emoji_shortcodes.dart';

/// Renders a Discourse reaction id (an emoji shortcode like `heart`,
/// `+1`, `party_parrot`) as a glyph.
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

  const ReactionGlyph({
    super.key,
    required this.reactionId,
    this.size = 16,
    this.siteContext,
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

  @override
  Widget build(BuildContext context) {
    final unicode = unicodeFor(reactionId);
    if (unicode != null) {
      return Text(unicode, style: TextStyle(fontSize: size));
    }
    final site = siteContext;
    final name = normalize(reactionId);
    if (site == null || name.isEmpty) return _fallback(context);
    return ValueListenableBuilder<int>(
      valueListenable: DiscourseCustomEmoji.revision,
      builder: (context, _, __) {
        final url = DiscourseCustomEmoji.urlFor(site.site.url, name);
        if (url == null) {
          if (!DiscourseCustomEmoji.isLoaded(site.site.url)) {
            // ignore: discarded_futures
            DiscourseCustomEmoji.ensureLoaded(site);
          }
          return _fallback(context);
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
          errorBuilder: (_, __, ___) => _fallback(context),
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
