/// A post of the signed-in user's that is waiting for a moderator
/// (`/posts/{username}/pending.json`, `PendingPostSerializer`) — what web
/// lists under Activity › Pending. A newcomer's first posts and anything
/// the forum's watched words hold land here, and until now the app gave no
/// sign they existed after the "awaiting approval" snackbar went away.
///
/// Only the user themself (and staff) may read the list.
class DiscoursePendingPost {
  const DiscoursePendingPost({
    required this.id,
    required this.rawText,
    this.topicId,
    this.topicTitle,
    this.categoryId,
    this.createdAt,
  });

  final int id;

  /// The post as written (Markdown); there is no cooked version until it
  /// is approved.
  final String rawText;

  /// Null for a new topic that is itself waiting.
  final int? topicId;
  final String? topicTitle;
  final int? categoryId;
  final DateTime? createdAt;

  factory DiscoursePendingPost.fromJson(Map<String, dynamic> json) =>
      DiscoursePendingPost(
        id: (json['id'] as num?)?.toInt() ?? 0,
        rawText: (json['raw_text'] ?? '').toString(),
        topicId: (json['topic_id'] as num?)?.toInt(),
        topicTitle: json['title']?.toString(),
        categoryId: (json['category_id'] as num?)?.toInt(),
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      );
}
