/// Data classes for `GET /u/{username}/summary.json`
/// (app/controllers/users_controller.rb#summary,
/// app/serializers/user_summary_serializer.rb).
///
/// The numeric stats are gated server-side by `can_see_summary_stats` —
/// when the viewer can't see them Discourse simply omits the fields, so
/// they surface here as 0 with [canSeeSummaryStats] false.

/// A topic row referenced by the summary (`BasicTopicSerializer` +
/// `category_id`, `like_count`, `created_at`). Top topics arrive as
/// `user_summary.topic_ids` resolved against the side-loaded top-level
/// `topics` array; reply/link rows reference the same array by
/// `topic_id`.
class DiscourseSummaryTopic {
  final int id;
  final String title;
  final String? slug;
  final int? categoryId;
  final int likeCount;
  final int? postsCount;
  final DateTime? createdAt;

  DiscourseSummaryTopic({
    required this.id,
    required this.title,
    this.slug,
    this.categoryId,
    this.likeCount = 0,
    this.postsCount,
    this.createdAt,
  });
}

/// One of the user's most-liked replies (`ReplySerializer`: post_number,
/// like_count, created_at + embedded topic reference).
class DiscourseSummaryReply {
  final int topicId;
  final String topicTitle;
  final String? topicSlug;
  final int postNumber;
  final int likeCount;
  final DateTime? createdAt;

  DiscourseSummaryReply({
    required this.topicId,
    required this.topicTitle,
    this.topicSlug,
    required this.postNumber,
    this.likeCount = 0,
    this.createdAt,
  });
}

/// One of the user's top links (`LinkSerializer`: url, title, clicks,
/// post_number + embedded topic reference).
class DiscourseSummaryLink {
  final String url;
  final String title;
  final int clicks;
  final int? topicId;
  final String? topicTitle;
  final int? postNumber;

  DiscourseSummaryLink({
    required this.url,
    required this.title,
    this.clicks = 0,
    this.topicId,
    this.topicTitle,
    this.postNumber,
  });
}

/// A user + interaction count row (`UserWithCountSerializer`), used for
/// most-liked-by / most-liked / most-replied-to lists. [avatarUrl] is
/// pre-resolved against the forum base URL by the proxy.
class DiscourseSummaryUser {
  final int id;
  final String username;
  final String? name;
  final int count;
  final String avatarUrl;
  final bool admin;
  final bool moderator;
  final int? trustLevel;

  DiscourseSummaryUser({
    required this.id,
    required this.username,
    this.name,
    required this.count,
    this.avatarUrl = '',
    this.admin = false,
    this.moderator = false,
    this.trustLevel,
  });
}

/// The profile-summary stats block (`user_summary` root).
class DiscourseUserSummary {
  final int likesGiven;
  final int likesReceived;
  final int daysVisited;
  final int topicsEntered;
  final int postsReadCount;
  final int postCount;
  final int topicCount;

  /// Total / recent reading time, in seconds.
  final int timeRead;
  final int recentTimeRead;

  /// Only present when viewing one's own summary.
  final int? bookmarkCount;

  /// False when Discourse hid the numeric stats from this viewer (all
  /// stat fields above will be 0 in that case).
  final bool canSeeSummaryStats;

  /// Number of badge grants inlined in the summary. Full badge details
  /// are available via `DiscourseUserProxy.getUserBadgesAsync`.
  final int badgeCount;

  final List<DiscourseSummaryTopic> topTopics;
  final List<DiscourseSummaryReply> topReplies;
  final List<DiscourseSummaryLink> topLinks;
  final List<DiscourseSummaryUser> mostLikedByUsers;
  final List<DiscourseSummaryUser> mostLikedUsers;
  final List<DiscourseSummaryUser> mostRepliedToUsers;

  DiscourseUserSummary({
    this.likesGiven = 0,
    this.likesReceived = 0,
    this.daysVisited = 0,
    this.topicsEntered = 0,
    this.postsReadCount = 0,
    this.postCount = 0,
    this.topicCount = 0,
    this.timeRead = 0,
    this.recentTimeRead = 0,
    this.bookmarkCount,
    this.canSeeSummaryStats = false,
    this.badgeCount = 0,
    this.topTopics = const [],
    this.topReplies = const [],
    this.topLinks = const [],
    this.mostLikedByUsers = const [],
    this.mostLikedUsers = const [],
    this.mostRepliedToUsers = const [],
  });
}

/// FC-style result wrapper for [DiscourseUserSummary].
class DiscourseUserSummaryResult {
  final bool result;
  final String resultText;
  final DiscourseUserSummary? summary;

  DiscourseUserSummaryResult({
    required this.result,
    this.resultText = '',
    this.summary,
  });
}
