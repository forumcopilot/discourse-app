/// The reaction set the forum actually accepts, as the server reports it.
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
class DiscourseValidReactions {
  DiscourseValidReactions._();

  static List<String>? _reactions;

  /// Records the set parsed from a topic payload. Ignores null and empty:
  /// a payload that omits the key tells us nothing, and must not erase a
  /// good answer from an earlier fetch.
  static void store(Object? validReactions) {
    if (validReactions is! List) return;
    final parsed = validReactions
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    if (parsed.isEmpty) return;
    _reactions = parsed;
  }

  /// The forum's enabled reactions, or null if no topic has been loaded yet
  /// this session. Null means "unknown" — not "none" — so callers should
  /// fall back rather than show an empty picker.
  static List<String>? get current => _reactions;

  /// Only for tests and sign-out.
  static void clear() => _reactions = null;
}
