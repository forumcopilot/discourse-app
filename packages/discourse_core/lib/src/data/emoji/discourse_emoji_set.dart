import '../../util/site_url.dart';

/// Where a forum keeps the artwork of Discourse's standard emoji: its
/// emoji set (`emoji_set`, e.g. twitter, apple, google) and, when the forum
/// serves them from elsewhere, `external_emoji_url`. Both are client
/// settings, read from `/site/settings.json` with the rest.
///
/// With them a standard emoji's image has a known address, as on the web
/// (`buildEmojiUrl` in pretty-text/emoji.js, `Emoji.url_for` on the
/// server): `<base>/images/emoji/<set>/<name>.png`, a skin tone as
/// `<name>/<tone>.png`. Asking the forum's `/emojis.json` (about 250 KB)
/// for that is needed only for its own, custom emoji
/// (DiscourseCustomEmoji).
class DiscourseEmojiSet {
  const DiscourseEmojiSet._(this.name, this.externalUrl);

  /// The set's directory name (`emoji_set`).
  final String name;

  /// `external_emoji_url`, without a trailing slash; empty when the forum
  /// serves the images itself.
  final String externalUrl;

  /// Discourse's emoji image version (`Emoji::EMOJI_VERSION`,
  /// `IMAGE_VERSION` on the web), a cache-buster on every address.
  static const String imageVersion = '15';

  static final Map<String, DiscourseEmojiSet> _bySite = {};

  static String _key(String siteUrl) {
    var key = siteUrl.trim();
    while (key.endsWith('/')) {
      key = key.substring(0, key.length - 1);
    }
    return key;
  }

  /// Records [siteUrl]'s set from its client settings; leaves what was known
  /// when they carry no `emoji_set`.
  static void storeFromClientSettings(
      String siteUrl, Map<String, dynamic> settings) {
    final set = settings['emoji_set'];
    if (set is! String || set.trim().isEmpty) return;
    var external = (settings['external_emoji_url'] as Object?)?.toString() ?? '';
    external = external.trim();
    while (external.endsWith('/')) {
      external = external.substring(0, external.length - 1);
    }
    _bySite[_key(siteUrl)] = DiscourseEmojiSet._(set.trim(), external);
  }

  /// The image of standard emoji [name] (canonical or alias; Discourse keeps
  /// a file under each) on [siteUrl]'s forum, in skin [tone] when given, or
  /// null while the forum's set is not known.
  static String? urlFor(String siteUrl, String name, {int? tone}) {
    final key = _key(siteUrl);
    final set = _bySite[key];
    if (set == null || name.isEmpty) return null;
    final file = tone == null ? name : '$name/$tone';
    final path = '${set.name}/$file.png?v=$imageVersion';
    return set.externalUrl.isEmpty
        ? absoluteSiteUrl(key, '/images/emoji/$path')
        : absoluteSiteUrl(key, '${set.externalUrl}/$path');
  }

  /// Only for tests.
  static void set(String siteUrl, String emojiSet, {String externalUrl = ''}) =>
      storeFromClientSettings(siteUrl,
          {'emoji_set': emojiSet, 'external_emoji_url': externalUrl});

  /// Only for tests.
  static void clear() => _bySite.clear();
}
