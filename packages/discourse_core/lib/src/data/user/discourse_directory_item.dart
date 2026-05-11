/// One row from `/directory_items.json` (the GET — Discourse's user
/// directory endpoint). Carries the user identity plus the activity
/// stats Discourse sorts the directory by — likes given/received,
/// post/topic counts, days visited.
///
/// Phase 5.18c-1 uses this for the hamburger drawer's **Users**
/// destination. The list view renders username + avatar + the
/// currently-selected sort metric (so the column the user sorted by
/// is visible on the row), and tapping a row drills into
/// `UserProfilePage`.
class DiscourseDirectoryItem {
  /// Numeric Discourse user id. Stable across rename.
  final int id;

  /// Login handle. The directory rows display this as the primary
  /// label.
  final String username;

  /// Optional human display name. Discourse forums vary on whether
  /// this is populated and whether it's shown alongside `username`.
  final String? name;

  /// Discourse `avatar_template` (e.g. `/letter_avatar_proxy/.../{size}.png`)
  /// pre-resolved to a 90px URL absolute against the site URL. Empty
  /// string when the user has no avatar template (rare).
  final String avatarUrl;

  /// Discourse trust level: 0 (New) → 4 (Leader). Null when the
  /// directory response didn't include it (older Discourse versions).
  final int? trustLevel;

  /// Likes the user has received on their own posts.
  final int likesReceived;

  /// Likes the user has given to other posts.
  final int likesGiven;

  /// How many distinct topics the user has entered/read.
  final int topicsEntered;

  /// Posts read by the user.
  final int postsRead;

  /// Distinct days the user has been seen active.
  final int daysVisited;

  /// Topics created by the user.
  final int topicCount;

  /// Posts authored by the user (replies + topic OPs).
  final int postCount;

  const DiscourseDirectoryItem({
    required this.id,
    required this.username,
    required this.avatarUrl,
    this.name,
    this.trustLevel,
    this.likesReceived = 0,
    this.likesGiven = 0,
    this.topicsEntered = 0,
    this.postsRead = 0,
    this.daysVisited = 0,
    this.topicCount = 0,
    this.postCount = 0,
  });

  /// Pull the integer value matching a directory `order` key — used
  /// by the list view to show the right "score" alongside each row.
  /// Unknown keys fall back to 0 rather than throwing.
  int statFor(String order) {
    switch (order) {
      case 'likes_received':
        return likesReceived;
      case 'likes_given':
        return likesGiven;
      case 'topics_entered':
        return topicsEntered;
      case 'posts_read':
        return postsRead;
      case 'days_visited':
        return daysVisited;
      case 'topic_count':
        return topicCount;
      case 'post_count':
        return postCount;
      default:
        return 0;
    }
  }

  /// Build from `directory_items[i]` map. `siteUrl` is used to resolve
  /// the user's relative `avatar_template` to an absolute URL.
  factory DiscourseDirectoryItem.fromJson(
    Map<String, dynamic> json, {
    required String siteUrl,
  }) {
    final user = (json['user'] as Map<String, dynamic>?) ?? const {};
    String avatarUrl = '';
    final tpl = user['avatar_template'] as String?;
    if (tpl != null && tpl.isNotEmpty) {
      final filled = tpl.replaceAll('{size}', '90');
      avatarUrl = filled.startsWith('http') ? filled : '$siteUrl$filled';
    }
    // Discourse exposes the stats either at the top level of the
    // directory item or nested under `user` depending on version.
    // Prefer top-level (newer), fall back to user (older).
    int statAt(String key) {
      final raw = json[key] ?? user[key];
      if (raw is num) return raw.toInt();
      return 0;
    }

    return DiscourseDirectoryItem(
      id: (user['id'] as num?)?.toInt() ?? 0,
      username: (user['username'] ?? '').toString(),
      name: (user['name'] as String?)?.trim().isNotEmpty == true
          ? user['name'] as String
          : null,
      avatarUrl: avatarUrl,
      trustLevel: (user['trust_level'] as num?)?.toInt(),
      likesReceived: statAt('likes_received'),
      likesGiven: statAt('likes_given'),
      topicsEntered: statAt('topics_entered'),
      postsRead: statAt('posts_read'),
      daysVisited: statAt('days_visited'),
      topicCount: statAt('topic_count'),
      postCount: statAt('post_count'),
    );
  }
}
