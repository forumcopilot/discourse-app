import 'dart:convert' show jsonDecode;

/// One draft from `/drafts.json` (the GET — Discourse's list-drafts
/// endpoint). The Profile tab's Drafts row uses this to render a
/// preview of each saved draft (topic title + body excerpt + time).
///
/// Discourse encodes draft `data` as a JSON-encoded string blob —
/// we parse it here so callers don't need to.
class DiscourseDraft {
  /// `topic_<id>` for reply drafts, `new_topic` for new-topic drafts,
  /// `new_private_message` for PM drafts. Used to navigate to the
  /// composer pre-filled.
  final String draftKey;

  /// Sequence counter — Discourse's optimistic-concurrency token.
  /// Bump-by-one on every save. Caller passes this back to
  /// `Draft.set` (we already do that in `saveDraftAsync`).
  final int sequence;

  /// Parsed contents of the draft's `data` blob. Typically contains
  /// `reply` (body markdown), `title` (for new topics), `action`,
  /// `categoryId`, `tags`.
  final Map<String, dynamic> data;

  /// Topic id when this is a reply draft, null otherwise.
  final int? topicId;

  /// Topic title for reply drafts, when Discourse includes it.
  final String? title;

  /// Category id for new-topic drafts (parsed out of `data.categoryId`
  /// where possible).
  final int? categoryId;

  /// Server-recorded last-modified time. Used to sort the Drafts
  /// list newest-first.
  final DateTime? updatedAt;

  DiscourseDraft({
    required this.draftKey,
    required this.sequence,
    required this.data,
    this.topicId,
    this.title,
    this.categoryId,
    this.updatedAt,
  });

  /// Reply body text (raw markdown) the user was typing. Empty when
  /// the draft is title-only or has no body yet.
  String get reply => (data['reply'] ?? '').toString();

  /// Title of the new-topic draft, or null when this is a reply.
  String? get topicTitle =>
      data['title']?.toString().isNotEmpty == true
          ? data['title'] as String
          : null;

  /// True when this draft is for a new topic (vs a reply to an
  /// existing topic).
  bool get isNewTopic =>
      draftKey == 'new_topic' || draftKey == 'new_private_message';

  factory DiscourseDraft.fromJson(Map<String, dynamic> json) {
    // `data` arrives as a JSON-encoded string in the GET response.
    Map<String, dynamic> parsed;
    final rawData = json['data'];
    if (rawData is Map) {
      parsed = rawData.cast<String, dynamic>();
    } else if (rawData is String && rawData.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawData);
        parsed = decoded is Map ? decoded.cast<String, dynamic>() : {};
      } catch (_) {
        parsed = {};
      }
    } else {
      parsed = {};
    }
    return DiscourseDraft(
      draftKey: (json['draft_key'] ?? '').toString(),
      sequence: (json['sequence'] as num?)?.toInt() ?? 0,
      data: parsed,
      topicId: (json['topic_id'] as num?)?.toInt(),
      title: (json['title'] ?? json['topic_title'])?.toString(),
      categoryId: (parsed['categoryId'] as num?)?.toInt(),
      updatedAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
