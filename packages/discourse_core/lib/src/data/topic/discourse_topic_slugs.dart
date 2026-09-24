/// Topic slugs, as the forum reported them, for building the topic's web
/// address.
///
/// Copy link and Share hand out the address the forum's website would —
/// `/t/{slug}/{topic_id}/{post_number}` — and a post only knows its topic's
/// id. Every topic payload the app already fetches (the topic view, topic
/// lists, search results) carries the slug, so it is recorded here as it
/// passes, rather than added to the shared SDK models for a Discourse-only
/// concept — the same reasoning as `DiscourseAcceptedAnswers`.
///
/// Keyed by forum and topic: a multi-forum host opens many forums in one
/// session, and topic 123 on one is a different topic from 123 on another.
class DiscourseTopicSlugs {
  DiscourseTopicSlugs._();

  static final Map<String, String> _slugs = {};

  static String _key(String forumUrl, String topicId) =>
      '${forumUrl.replaceAll(RegExp(r'/+$'), '').toLowerCase()} $topicId';

  /// Records [slug] for [topicId] on the forum at [forumUrl]. Ignores an
  /// empty slug: a payload without one tells us nothing.
  static void store(String forumUrl, String topicId, Object? slug) {
    if (topicId.isEmpty || slug is! String || slug.trim().isEmpty) return;
    _slugs[_key(forumUrl, topicId)] = slug.trim();
  }

  /// The slug last seen for [topicId], or null when no payload has named it.
  static String? of(String forumUrl, String topicId) =>
      topicId.isEmpty ? null : _slugs[_key(forumUrl, topicId)];

  /// Only for tests.
  static void clear() => _slugs.clear();
}
