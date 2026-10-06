import 'package:discourse_core/discourse_core.dart'
    show DiscourseCustomEmoji, DiscourseEmojiSet;
import 'package:flutter/material.dart';

import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../utils/emoji_shortcodes.dart';
import '../../utils/discourse_emoji_data.dart';

/// Renders a Discourse reaction id (an emoji shortcode like `heart`,
/// `+1`, `party_parrot`, with an optional skin tone: `wave:t3`) as a glyph.
///
/// Resolution order:
///   1. Unicode emoji, when Discourse's own table maps the shortcode to one.
///      With [preferImage] (channel icons, which should look as the forum
///      draws them) the forum's artwork for it instead: its address follows
///      from the forum's emoji set ([DiscourseEmojiSet]), so nothing is
///      fetched; the character stands in while the set is unknown or the
///      image fails.
///   2. The forum's own image for it, from its `/emojis.json`
///      ([DiscourseCustomEmoji]): emoji an admin uploaded have no unicode
///      form. The list is read once per forum, the first time such a name
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

  /// Draw a standard emoji as the forum's artwork (its emoji set) rather
  /// than the platform's character: channel icons, which should match the
  /// web.
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

  @override
  Widget build(BuildContext context) {
    final unicode = unicodeFor(reactionId);
    if (unicode != null && !preferImage) return _character(unicode);
    final site = siteContext;
    final (:name, :tone) = parse(reactionId);
    if (site == null || name.isEmpty) {
      return unicode == null ? _fallback(context) : _character(unicode);
    }
    if (unicode != null) {
      // A standard emoji: the forum's artwork is at a known address in its
      // emoji set (aliases included), so the ~250 KB /emojis.json is not
      // needed for it.
      final url = DiscourseEmojiSet.urlFor(site.site.url, name,
          tone: _artworkTone(name, tone));
      return url == null
          ? _character(unicode)
          : _image(context, url, () => _character(unicode));
    }
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
        return _image(context, url, () => _fallback(context));
      },
    );
  }

  Widget _character(String unicode) =>
      Text(unicode, style: TextStyle(fontSize: size));

  /// The image at [url], blank (not another glyph) until it has loaded, so
  /// a channel icon does not flash the platform's emoji before the forum's.
  Widget _image(BuildContext context, String url, Widget Function() onError) {
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
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
          wasSynchronouslyLoaded || frame != null
              ? child
              : SizedBox(width: size, height: size),
      errorBuilder: (_, __, ___) => onError(),
    );
  }

  Widget _fallback(BuildContext context) => Icon(
        Icons.emoji_emotions_outlined,
        size: size,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        semanticLabel: ':${normalize(reactionId)}:',
      );
}
