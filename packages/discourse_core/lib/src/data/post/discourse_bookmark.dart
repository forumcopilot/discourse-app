/// A single bookmark entry as returned by Discourse's
/// `/u/{username}/bookmarks.json` endpoint. We only model the fields the
/// app actually displays/navigates with; everything else stays in the raw
/// map (Discourse's bookmark shape is fairly large and version-dependent).
class DiscourseBookmark {
  /// Bookmark id (used for DELETE /bookmarks/{id}.json).
  final int id;

  /// What this bookmark points to. Almost always 'Post' or 'Topic'.
  final String? bookmarkableType;

  /// Numeric id of the bookmarked post or topic.
  final int? bookmarkableId;

  /// Topic id used for navigation. May differ from [bookmarkableId] when
  /// the bookmark is on an individual post.
  final int? topicId;

  /// 1-based post number within the topic. Lets us deep-link into the
  /// thread at the bookmarked post.
  final int? postNumber;

  /// Topic title at the time the bookmark was loaded.
  final String? title;

  /// Snippet/excerpt from the bookmarked post (HTML-stripped on the
  /// server side).
  final String? excerpt;

  /// Optional user-supplied note attached to the bookmark.
  final String? name;

  /// Author of the bookmarked post.
  final String? username;
  final String? avatarTemplate;

  /// When the bookmark was created on the server.
  final DateTime? createdAt;

  DiscourseBookmark({
    required this.id,
    this.bookmarkableType,
    this.bookmarkableId,
    this.topicId,
    this.postNumber,
    this.title,
    this.excerpt,
    this.name,
    this.username,
    this.avatarTemplate,
    this.createdAt,
  });

  factory DiscourseBookmark.fromJson(Map<String, dynamic> json) {
    return DiscourseBookmark(
      id: (json['id'] as num).toInt(),
      bookmarkableType: json['bookmarkable_type']?.toString(),
      bookmarkableId: (json['bookmarkable_id'] as num?)?.toInt(),
      topicId: (json['topic_id'] as num?)?.toInt(),
      postNumber: (json['post_number'] as num?)?.toInt() ??
          (json['linked_post_number'] as num?)?.toInt(),
      title: json['title']?.toString() ??
          json['fancy_title']?.toString() ??
          json['topic_title']?.toString(),
      excerpt: json['excerpt']?.toString(),
      name: json['name']?.toString(),
      username: json['username']?.toString(),
      avatarTemplate: json['avatar_template']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  /// Builds an absolute avatar URL from the Discourse avatar_template, or
  /// returns null if no template is set.
  String? avatarUrl(String forumBaseUrl, {int size = 90}) {
    final tpl = avatarTemplate;
    if (tpl == null || tpl.isEmpty) return null;
    final filled = tpl.replaceAll('{size}', size.toString());
    return filled.startsWith('http') ? filled : '$forumBaseUrl$filled';
  }
}
