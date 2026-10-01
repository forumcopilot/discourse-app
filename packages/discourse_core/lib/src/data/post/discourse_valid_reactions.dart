/// The reaction set a forum actually accepts, as the server reports it.
///
/// Discourse serializes `valid_reactions` on every `/t/{id}.json` response —
/// it is the `discourse_reactions_enabled_reactions` site setting, so it is
/// a property of the forum, not of the topic it arrived on. That makes it
/// the authoritative answer to "what may the picker offer", and it costs
/// nothing: the topic view is already fetched to read the topic.
///
/// A side table rather than a field on the thread result, because that
/// result type is shared SDK surface and this is a Discourse-only concept —
/// same reasoning as [DiscourseAcceptedAnswers].
///
/// Why this exists at all: `GET /discourse-reactions/custom-reactions`
/// 404s on forums where reactions plainly work (try.discourse.org is one —
/// the route is absent while `valid_reactions` lists seven, and posts there
/// carry heart and open_mouth reactions). Treating that 404 as "only a like
/// can succeed" left the picker offering a single reaction on a forum that
/// accepts seven. The route's absence says nothing about which reactions
/// are enabled; this field says it directly.
///
/// Kept per forum. It was one value for the whole app, and a forum without
/// the plugin never replaced it, so in a multi-forum host the picker on
/// Godot offered the 14 reactions last seen on Meta, all but the heart
/// failing. A topic view without the field now records the forum as
/// likes-only (see [storeFromTopicView]).
class DiscourseValidReactions {
  DiscourseValidReactions._();

  /// The id a plain like goes by when a forum has no reactions plugin, and
  /// the plugin's default main reaction
  /// (`discourse_reactions_reaction_for_like`).
  static const String like = 'heart';

  static final Map<String, List<String>> _bySite = {};
  static final Set<String> _likesOnly = {};

  static String _key(String siteUrl) {
    var key = siteUrl.trim().toLowerCase();
    while (key.endsWith('/')) {
      key = key.substring(0, key.length - 1);
    }
    return key;
  }

  /// Records what a topic view says about [siteUrl]'s reactions.
  ///
  /// With the plugin on, every topic view carries `valid_reactions`
  /// (`add_to_serializer(:topic_view, :valid_reactions)`, gated on the
  /// plugin being enabled) and every post a `reactions` list. Without the
  /// field and without `reactions` on its posts, the forum has no reactions
  /// at all: a like is all it accepts. Without the field but WITH
  /// `reactions` on the posts (an older plugin), nothing is learnt.
  static void storeFromTopicView(String siteUrl, Map<String, dynamic> topicView) {
    final valid = topicView['valid_reactions'];
    if (valid is List) {
      store(siteUrl, valid);
      return;
    }
    final stream = topicView['post_stream'];
    final posts = stream is Map ? stream['posts'] : null;
    if (posts is! List || posts.isEmpty) return;
    final first = posts.first;
    if (first is Map && !first.containsKey('reactions')) {
      final key = _key(siteUrl);
      _bySite[key] = const [like];
      _likesOnly.add(key);
    }
  }

  /// Records the set [siteUrl] reports. Ignores anything that is not a
  /// non-empty list of names: it says nothing, and must not erase a good
  /// answer from an earlier fetch.
  static void store(String siteUrl, Object? validReactions) {
    if (validReactions is! List) return;
    final parsed = validReactions
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    if (parsed.isEmpty) return;
    final key = _key(siteUrl);
    _bySite[key] = parsed;
    _likesOnly.remove(key);
  }

  /// [siteUrl]'s enabled reactions, its main reaction (the like) first, or
  /// null if no topic of that forum has been loaded yet. Null means
  /// "unknown" — not "none" — so callers should fall back rather than show
  /// an empty picker.
  static List<String>? forSite(String siteUrl) => _bySite[_key(siteUrl)];

  /// Whether [siteUrl] is known to run without the reactions plugin, so a
  /// like goes through `/post_actions` and there is nothing to pick from.
  static bool likesOnly(String siteUrl) => _likesOnly.contains(_key(siteUrl));

  /// The reaction a plain like stands for on [siteUrl]: the first of the
  /// set (the server puts `discourse_reactions_reaction_for_like` first),
  /// or [like] while the set is unknown.
  static String mainReaction(String siteUrl) {
    final known = forSite(siteUrl);
    return known == null || known.isEmpty ? like : known.first;
  }

  /// Only for tests and sign-out.
  static void clear() {
    _bySite.clear();
    _likesOnly.clear();
  }
}
