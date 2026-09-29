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
///
/// Links into a forum — pasted, shared from a browser, or tapped — name the
/// same destinations, so [DiscourseNotificationRoute.fromLink] reads a
/// [DiscourseLink] into a route and one navigator serves both
/// (`DiscourseRouteNavigator`).
library;

import 'package:discourse_core/discourse_core.dart' show DiscourseLink;

/// What kind of destination a payload names.
enum NotificationRouteKind {
  /// A specific post, by id: the topic can be opened centred on it. A post
  /// short link (`/p/{id}`) names no topic; the navigator asks the forum.
  post,

  /// A topic and a post number, but no post id: the topic can be opened at
  /// the page containing that post.
  topicPage,

  /// A personal message (topic id), optionally at a post: opened in the
  /// message screen, with its archive, leave and participants actions,
  /// rather than the topic reader.
  conversation,

  /// A chat channel, at a message when the payload named one outside a
  /// thread (chat mentions, invitations, DMs, watched threads).
  chat,

  /// A badge the reader earned: its sheet, over the page on screen.
  badge,

  /// A group's message inbox (`group_message_summary`): the Messages page,
  /// on that group's list.
  groupInbox,

  /// A group's page (membership accepted, membership requests).
  group,

  /// A person's profile (an invitee who joined, a new follower).
  profile,

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
    this.chatChannelId,
    this.chatMessageId,
    this.badgeId,
    this.groupName,
    this.username,
    this.notificationId,
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

  /// For [NotificationRouteKind.chat]: the channel, and the message to
  /// scroll to — null inside a thread, whose replies are not in the
  /// channel's timeline.
  final int? chatChannelId;
  final int? chatMessageId;

  /// For [NotificationRouteKind.badge].
  final int? badgeId;

  /// For [NotificationRouteKind.groupInbox] and [NotificationRouteKind.group].
  final String? groupName;

  /// For [NotificationRouteKind.profile].
  final String? username;

  /// The Discourse notification behind the push, marked read once opened.
  /// Null for chat messages, which have no notification row.
  final int? notificationId;

  /// Posts per page, matching `PostsList`'s own page size — the page number
  /// is only useful if both sides agree on how long a page is.
  static const int postsPerPage = 20;

  /// True when [data] came from the notifications backend rather than the
  /// ForumCopilot plugin, and so should be routed by this class.
  static bool handles(Map<String, dynamic> data) =>
      (data['type'] ?? '').toString().toLowerCase() == 'discourse_notification';

  /// Read a route out of one FCM data payload.
  ///
  /// Each Discourse notification type opens what its row in Discourse's own
  /// notification menu opens: a topic or message at its post, a chat
  /// channel at its message, a badge, a group's inbox or page, a profile.
  factory DiscourseNotificationRoute.from(Map<String, dynamic> data) {
    final topicId = _intFrom(data['topic_id']);
    final postId = _intFrom(data['content_id']);
    final postNumber = _intFrom(data['post_number']);
    final siteUrl = _stringFrom(data['site_url']);
    final notificationId = _intFrom(data['notification_id']);
    final type = _intFrom(data['notification_type']);

    // Chat: a mention, an invitation, a DM, a watched thread, and a chat
    // bookmark whose only address is its link.
    var channelId = _intFrom(data['chat_channel_id']);
    var messageId = _intFrom(data['chat_message_id']);
    var threadId = _intFrom(data['chat_thread_id']);
    if (channelId == null) {
      final chat = _chatFromUrl(_stringFrom(data['url']));
      channelId = chat?.channel;
      messageId ??= chat?.message;
      threadId ??= chat?.thread;
    }
    if (channelId != null) {
      return DiscourseNotificationRoute(
        kind: NotificationRouteKind.chat,
        chatChannelId: channelId,
        chatMessageId: threadId == null ? messageId : null,
        siteUrl: siteUrl,
        notificationId: notificationId,
      );
    }

    // A personal message (private_message 6, invited_to_private_message 7)
    // opens where the notifications tab opens it: the message screen. The
    // backend passes Discourse's notification_type along; this used to be
    // ignored, so a message push landed in the topic reader.
    if (topicId != null && (type == 6 || type == 7)) {
      return DiscourseNotificationRoute(
        kind: NotificationRouteKind.conversation,
        topicId: topicId.toString(),
        postId: postId?.toString(),
        postNumber: postNumber,
        siteUrl: siteUrl,
        notificationId: notificationId,
      );
    }

    // A post id is the better anchor: Discourse resolves it to its exact
    // position, where a post number only gets us to the surrounding page.
    if (topicId != null && postId != null) {
      return DiscourseNotificationRoute(
        kind: NotificationRouteKind.post,
        topicId: topicId.toString(),
        postId: postId.toString(),
        postNumber: postNumber,
        siteUrl: siteUrl,
        notificationId: notificationId,
      );
    }
    if (topicId != null && postNumber != null && postNumber > 0) {
      return DiscourseNotificationRoute(
        kind: NotificationRouteKind.topicPage,
        topicId: topicId.toString(),
        postNumber: postNumber,
        page: ((postNumber - 1) ~/ postsPerPage) + 1,
        siteUrl: siteUrl,
        notificationId: notificationId,
      );
    }
    // A topic with no position at all still beats the notification list.
    if (topicId != null) {
      return DiscourseNotificationRoute(
        kind: NotificationRouteKind.topicPage,
        topicId: topicId.toString(),
        page: 1,
        siteUrl: siteUrl,
        notificationId: notificationId,
      );
    }

    // No topic: the types whose destination is a badge, a group or a person.
    final badgeId = _intFrom(data['badge_id']);
    if (type == 12 && badgeId != null) {
      return DiscourseNotificationRoute(
        kind: NotificationRouteKind.badge,
        badgeId: badgeId,
        siteUrl: siteUrl,
        notificationId: notificationId,
      );
    }
    final group = _stringFrom(data['group_name']);
    if (group != null && type == 16) {
      return DiscourseNotificationRoute(
        kind: NotificationRouteKind.groupInbox,
        groupName: group,
        siteUrl: siteUrl,
        notificationId: notificationId,
      );
    }
    if (group != null && (type == 22 || type == 23)) {
      return DiscourseNotificationRoute(
        kind: NotificationRouteKind.group,
        groupName: group,
        siteUrl: siteUrl,
        notificationId: notificationId,
      );
    }
    // An invitee who joined, a new follower — and likes or links spread
    // over several posts, whose person is the one thing they share (the
    // notification list opens the same).
    final username = _stringFrom(data['username']);
    if (username != null && const {8, 19, 39, 25, 800}.contains(type)) {
      return DiscourseNotificationRoute(
        kind: NotificationRouteKind.profile,
        username: username,
        siteUrl: siteUrl,
        notificationId: notificationId,
      );
    }
    return DiscourseNotificationRoute(
      kind: NotificationRouteKind.notificationsTab,
      siteUrl: siteUrl,
      notificationId: notificationId,
    );
  }

  /// A chat address (`…/chat/c/<slug>/<channel>/<message>`, or
  /// `…/t/<thread>[/<message>]` inside a thread) as its parts.
  static ({int channel, int? message, int? thread})? _chatFromUrl(String? url) {
    if (url == null) return null;
    final path = Uri.tryParse(url)?.path ?? url;
    final m = RegExp(r'/chat/c/[^/]+/(\d+)(?:/t/(\d+))?(?:/(\d+))?/?$')
        .firstMatch(path);
    if (m == null) return null;
    return (
      channel: int.parse(m.group(1)!),
      thread: m.group(2) == null ? null : int.parse(m.group(2)!),
      message: m.group(3) == null ? null : int.parse(m.group(3)!),
    );
  }

  /// Where a link into the forum leads: a post short link to that post, a
  /// topic link to its post number when it has one, else to the topic.
  /// Null when the link names only the forum — its home, a category, a
  /// user, a tag — and the forum's home is the destination.
  static DiscourseNotificationRoute? fromLink(DiscourseLink link) {
    final postId = link.postId;
    if (postId != null) {
      return DiscourseNotificationRoute(
        kind: NotificationRouteKind.post,
        postId: postId.toString(),
        siteUrl: link.forumUrl,
      );
    }
    final topicId = link.topicId;
    if (topicId == null) return null;
    final postNumber = link.postNumber;
    return DiscourseNotificationRoute(
      kind: NotificationRouteKind.topicPage,
      topicId: topicId.toString(),
      postNumber: postNumber,
      page: postNumber == null ? 1 : ((postNumber - 1) ~/ postsPerPage) + 1,
      siteUrl: link.forumUrl,
    );
  }

  @override
  String toString() => 'DiscourseNotificationRoute($kind, topic=$topicId, '
      'post=$postId, postNumber=$postNumber, page=$page, chat=$chatChannelId/'
      '$chatMessageId, badge=$badgeId, group=$groupName, user=$username, '
      'notification=$notificationId, site=$siteUrl)';

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
