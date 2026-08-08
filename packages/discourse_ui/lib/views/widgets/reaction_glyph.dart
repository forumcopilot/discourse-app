import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';

import 'package:forumcopilot_sdk/context/site_context.dart';

/// Renders a Discourse reaction id (an emoji shortcode like `heart`,
/// `+1`, `party_parrot`) as a glyph.
///
/// Resolution order, mirroring the chain xenforoapp's `ReactionGlyph`
/// settled on:
///   1. Unicode emoji, when the shortcode maps to one.
///   2. Discourse's custom-emoji image at `/images/emoji/.../<name>.png`,
///      for emoji an admin uploaded — these have no unicode form.
///   3. A heart icon, so a chip is never blank.
///
/// Step 2 is the reason this exists as a shared widget: the chips row
/// previously fell back to printing the raw `:shortcode:` text, so any
/// custom emoji on the forum showed up as literal characters. Both the
/// chips row and the react button now go through here, so they can never
/// disagree about what a reaction looks like.
class ReactionGlyph extends StatelessWidget {
  /// Discourse reaction id / emoji shortcode, with or without colons.
  final String reactionId;
  final double size;

  /// Needed to build the custom-emoji URL. When null, step 2 is skipped
  /// and an unmapped shortcode falls straight through to the heart.
  final SiteContext? siteContext;

  const ReactionGlyph({
    super.key,
    required this.reactionId,
    this.size = 16,
    this.siteContext,
  });

  static String normalize(String reactionId) =>
      reactionId.replaceAll(':', '').trim();

  /// Discourse shortcodes the `emojis` package does not know under that
  /// name. `+1`/`-1` are the ones that matter: they are in Discourse's
  /// default reaction set, and without this they rendered as the literal
  /// text ":+1:" in the picker.
  static const Map<String, String> _aliases = {
    '+1': '👍',
    'thumbsup': '👍',
    '-1': '👎',
    'thumbsdown': '👎',
    'heart': '❤️',
    'laughing': '😆',
    'open_mouth': '😮',
    'clap': '👏',
    'partying_face': '🥳',
    'tada': '🎉',
    'rocket': '🚀',
    'eyes': '👀',
    'confetti_ball': '🎊',
    'hugs': '🤗',
  };

  /// The unicode character for [reactionId], or null when Discourse's
  /// shortcode has no unicode equivalent (i.e. it is a custom emoji).
  static String? unicodeFor(String reactionId) {
    final clean = normalize(reactionId);
    if (clean.isEmpty) return null;
    final alias = _aliases[clean];
    if (alias != null) return alias;
    final emoji = Emoji.byShortName(clean);
    if (emoji != null && emoji.char.isNotEmpty) return emoji.char;
    return null;
  }

  String? _customEmojiUrl() {
    final base = siteContext?.site.url;
    if (base == null || base.isEmpty) return null;
    final clean = normalize(reactionId);
    if (clean.isEmpty) return null;
    // Discourse serves custom emoji from a stable path; a miss 404s and
    // the errorBuilder drops us to the heart.
    return '${base.replaceAll(RegExp(r'/$'), '')}'
        '/images/emoji/twitter/$clean.png';
  }

  @override
  Widget build(BuildContext context) {
    final unicode = unicodeFor(reactionId);
    if (unicode != null) {
      return Text(unicode, style: TextStyle(fontSize: size));
    }

    final url = _customEmojiUrl();
    if (url != null) {
      return Image.network(
        url,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => _fallback(context),
      );
    }
    return _fallback(context);
  }

  Widget _fallback(BuildContext context) => Icon(
        Icons.favorite,
        size: size,
        color: Theme.of(context).colorScheme.error,
      );
}
