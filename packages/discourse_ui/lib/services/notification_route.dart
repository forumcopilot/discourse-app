/// Where a push notification should take the user, decided from its payload
/// alone — no navigator, no network — so the rules sit in one readable,
/// testable place.
///
/// This covers notifications from the notifications backend (the poller in
/// `abda-push`), which speaks Discourse's own vocabulary rather than the
/// ForumCopilot plugin's `content_type` shape:
///
///   * `topic_id` and `post_number` for anything that happened in a topic;
///   * `content_id` — the post id — only when `/notifications.json` exposed
///     one (`data.original_post_id`, which Discourse sets for replies,
///     mentions, quotes, likes, links and messages);
///   * neither, for a badge or a bookmark reminder, which have no
///     destination beyond the notification list itself.
///
/// FCM data payloads are string-to-string, so every number arrives as text;
/// the parsing here is deliberately forgiving about that (and about the
/// `"580.0"` spelling some senders produce).
library;

/// What kind of destination a payload names.
enum NotificationRouteKind {
  /// A specific post, by id: the topic can be opened centred on it.
  post,

  /// A topic and a post number, but no post id: the topic can be opened at
  /// the page containing that post.
  topicPage,

  /// Nothing to open. The notification list is the honest destination.
  notificationsTab,
}

/// The decision, plus whatever the payload gave to act on it.
class DiscourseNotificationRoute {
  const DiscourseNotificationRoute({
    required this.kind,
    this.topicId,
    this.postId,
    this.postNumber,
    this.page,
    this.siteUrl,
  });

  final NotificationRouteKind kind;

  /// Discourse topic id, when the payload named one.
  final String? topicId;

  /// Discourse post id, for [NotificationRouteKind.post].
  final String? postId;

  /// 1-based position of the post within its topic, when known.
  final int? postNumber;

  /// 1-based page holding [postNumber], for [NotificationRouteKind.topicPage].
  final int? page;

  /// The forum the notification came from, as the backend spelled it.
  final String? siteUrl;

  /// Posts per page, matching `PostsList`'s own page size — the page number
  /// is only useful if both sides agree on how long a page is.
  static const int postsPerPage = 20;

  /// True when [data] came from the notifications backend rather than the
  /// ForumCopilot plugin, and so should be routed by this class.
  static bool handles(Map<String, dynamic> data) =>
      (data['type'] ?? '').toString().toLowerCase() == 'discourse_notification';

  /// Read a route out of one FCM data payload.
  factory DiscourseNotificationRoute.from(Map<String, dynamic> data) {
    final topicId = _intFrom(data['topic_id']);
    final postId = _intFrom(data['content_id']);
    final postNumber = _intFrom(data['post_number']);
    final siteUrl = _stringFrom(data['site_url']);

    // A post id is the better anchor: Discourse resolves it to its exact
    // position, where a post number only gets us to the surrounding page.
    if (topicId != null && postId != null) {
      return DiscourseNotificationRoute(
        kind: NotificationRouteKind.post,
        topicId: topicId.toString(),
        postId: postId.toString(),
        postNumber: postNumber,
        siteUrl: siteUrl,
      );
    }
    if (topicId != null && postNumber != null && postNumber > 0) {
      return DiscourseNotificationRoute(
        kind: NotificationRouteKind.topicPage,
        topicId: topicId.toString(),
        postNumber: postNumber,
        page: ((postNumber - 1) ~/ postsPerPage) + 1,
        siteUrl: siteUrl,
      );
    }
    // A topic with no position at all still beats the notification list.
    if (topicId != null) {
      return DiscourseNotificationRoute(
        kind: NotificationRouteKind.topicPage,
        topicId: topicId.toString(),
        page: 1,
        siteUrl: siteUrl,
      );
    }
    return DiscourseNotificationRoute(
      kind: NotificationRouteKind.notificationsTab,
      siteUrl: siteUrl,
    );
  }

  @override
  String toString() => 'DiscourseNotificationRoute($kind, topic=$topicId, '
      'post=$postId, postNumber=$postNumber, page=$page, site=$siteUrl)';

  /// Ints arrive as strings over FCM, and occasionally as `"580.0"` where a
  /// sender pushed them through a float. Anything else is not a number.
  static int? _intFrom(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.truncate();
    var text = value.toString().trim();
    if (text.isEmpty) return null;
    if (text.contains('.')) text = text.split('.').first;
    return int.tryParse(text);
  }

  static String? _stringFrom(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
