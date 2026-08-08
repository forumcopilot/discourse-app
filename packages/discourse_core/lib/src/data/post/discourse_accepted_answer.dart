/// The `accepted_answer` object from `/t/{id}.json`, added by the
/// discourse-solved plugin.
///
/// Discourse's own web UI renders this as a panel directly under the FIRST post — see
/// `shouldRender` in the plugin's `extend-for-solved-button.gjs`:
///
///   args.post?.post_number === 1 && args.post?.topic?.accepted_answer
///
/// so a reader of a long solved topic sees the answer without scrolling. The app had the
/// solved badge in topic lists and a banner on the answer post itself, but nothing on the
/// first post, which meant scrolling a 50-reply topic to find the answer.
///
/// Deliberately a Discourse-only model rather than a field on the shared `FCTopic`:
/// accepted answers are the discourse-solved plugin's concept, and putting them on the
/// cross-platform model would drag XenForo into a shape it does not have. It also avoids
/// a `dart_mappable` regeneration across both duplicated SDK copies.
class DiscourseAcceptedAnswer {
  /// Post number of the answer WITHIN the topic — not a post id. Discourse's payload
  /// carries no post id here, which is why jumping to it goes by number.
  final int postNumber;

  /// Who wrote the answer.
  final String username;
  final String? name;
  final String? avatarTemplate;

  /// Cooked HTML of the answer. Null when the forum sets `solved_quote_length` to 0,
  /// in which case the panel shows a title-only form (the web does the same).
  final String? excerptHtml;

  /// Who marked it solved. Only serialized when `show_who_marked_solved` is on.
  final String? accepterUsername;
  final String? accepterName;

  const DiscourseAcceptedAnswer({
    required this.postNumber,
    required this.username,
    this.name,
    this.avatarTemplate,
    this.excerptHtml,
    this.accepterUsername,
    this.accepterName,
  });

  /// Returns null when the topic has no accepted answer, or when the payload lacks the
  /// two fields the panel cannot render without.
  static DiscourseAcceptedAnswer? fromTopicJson(Map<String, dynamic> topic) {
    final raw = topic['accepted_answer'];
    if (raw is! Map) return null;
    final a = raw.cast<String, dynamic>();

    final postNumber = (a['post_number'] as num?)?.toInt();
    final username = (a['username'] ?? '').toString();
    if (postNumber == null || username.isEmpty) return null;

    String? str(Object? v) {
      final s = v?.toString();
      return (s == null || s.isEmpty) ? null : s;
    }

    return DiscourseAcceptedAnswer(
      postNumber: postNumber,
      username: username,
      name: str(a['name']),
      avatarTemplate: str(a['avatar_template']),
      excerptHtml: str(a['excerpt']),
      accepterUsername: str(a['accepter_username']),
      accepterName: str(a['accepter_name']),
    );
  }

  /// Display name, following the forum's `display_name_on_posts` convention as the web
  /// component does: full name when there is one, username otherwise.
  String get solverDisplayName => name ?? username;
  String? get accepterDisplayName => accepterName ?? accepterUsername;
}

/// Accepted answers for topics whose thread payload has been loaded, keyed by topic id.
///
/// A side table rather than a field on the thread result, because the thread result type
/// is shared SDK surface. It is written by the Discourse post proxy whenever it parses a
/// `/t/{id}.json` response and read by the Discourse-only solution panel.
///
/// Entries are overwritten on every load of the same topic, so accepting or unaccepting
/// an answer is reflected on the next fetch. Removal on unaccept is explicit: a topic
/// that loses its solution serializes no `accepted_answer` at all, so the parse returns
/// null and [store] clears the entry.
class DiscourseAcceptedAnswers {
  DiscourseAcceptedAnswers._();

  static final Map<String, DiscourseAcceptedAnswer> _byTopicId = {};

  /// Records (or clears) the accepted answer parsed from a topic payload.
  static void store(String topicId, DiscourseAcceptedAnswer? answer) {
    if (topicId.isEmpty) return;
    if (answer == null) {
      _byTopicId.remove(topicId);
    } else {
      _byTopicId[topicId] = answer;
    }
  }

  static DiscourseAcceptedAnswer? forTopic(String topicId) =>
      topicId.isEmpty ? null : _byTopicId[topicId];

  /// Only for tests and sign-out; the map is small (one entry per topic opened).
  static void clear() => _byTopicId.clear();
}
