import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';

/// What Discourse lists under a topic to read next: its **suggested** topics
/// (unread and new ones first, then more from the category) and, on forums
/// running discourse-ai's related topics, its **related** ones. A private
/// message's are other messages (`related_messages` for the related list).
///
/// Every topic payload (`/t/{id}.json`, `/t/{id}/{n}.json`) carries both
/// lists, so the post proxy records them from the load it already made
/// ([storeFrom]) and `DiscourseTopicProxy.getMoreTopicsAsync` maps them
/// like list rows. The suggestions footer used to fetch the whole topic a
/// second time just to read them.
///
/// A side table rather than a field on the thread result, because that
/// result type is shared SDK surface — see `DiscourseAcceptedAnswers`.
/// Keyed by forum as well as topic: a multi-forum host opens topics of
/// several forums, and their ids collide.
class DiscourseMoreTopics {
  const DiscourseMoreTopics({
    this.suggested = const [],
    this.related = const [],
  });

  final List<FCTopic> suggested;
  final List<FCTopic> related;

  bool get isEmpty => suggested.isEmpty && related.isEmpty;

  static final Map<String, ({List<Map<String, dynamic>> suggested, List<Map<String, dynamic>> related})>
      _raw = {};

  static String _key(String forumUrl, String topicId) => '$forumUrl#$topicId';

  static List<Map<String, dynamic>> _list(Object? raw) =>
      ((raw as List?) ?? const [])
          .whereType<Map>()
          .map((m) => m.cast<String, dynamic>())
          .toList(growable: false);

  /// Records both lists from a topic payload, replacing what an earlier
  /// load of the topic recorded (an empty list included: the forum has
  /// nothing more to suggest).
  static void storeFrom(
      String forumUrl, String topicId, Map<String, dynamic> topicJson) {
    if (topicId.isEmpty) return;
    _raw[_key(forumUrl, topicId)] = (
      suggested: _list(topicJson['suggested_topics']),
      related: _list(topicJson['related_topics'] ?? topicJson['related_messages']),
    );
  }

  /// The payload's lists as recorded, or null when the topic has not been
  /// loaded in this session.
  static ({List<Map<String, dynamic>> suggested, List<Map<String, dynamic>> related})?
      rawFor(String forumUrl, String topicId) => _raw[_key(forumUrl, topicId)];

  /// Whether the topic's last load listed anything to read next.
  static bool hasAny(String forumUrl, String topicId) {
    final raw = rawFor(forumUrl, topicId);
    return raw != null && (raw.suggested.isNotEmpty || raw.related.isNotEmpty);
  }

  /// Only for tests and sign-out; one small entry per topic opened.
  static void clear() => _raw.clear();
}
