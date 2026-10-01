import 'package:flutter/foundation.dart' show ValueNotifier;

/// A topic's state as Discourse's topic page shows it, and what the viewer
/// may do about it.
///
/// The SDK's topic carries closed, pinned and subscribed as booleans, which
/// is the XenForo shape: no archived or unlisted, no "pinned for everyone
/// but unpinned by you", no notification level or the reason for it, no
/// topic timer, and none of the staff permissions `details` sends. Those
/// are what web draws the topic's status from (TopicStatus before the
/// title, PinnedButton and TopicNotificationsButton in the footer,
/// TopicTimerInfo and SlowModeInfo under the last post), so the topic
/// loaders in DiscoursePostProxy store this beside the thread result, the
/// side table DiscourseMessageDetails and DiscourseAcceptedAnswers use.
class DiscourseTopicStatus {
  const DiscourseTopicStatus({
    this.pinned = false,
    this.unpinned = false,
    this.pinnedGlobally = false,
    this.pinnedUntil,
    this.closed = false,
    this.archived = false,
    this.visible = true,
    this.deleted = false,
    this.isWarning = false,
    this.isMessage = false,
    this.notificationLevel = 1,
    this.notificationsReasonId,
    this.timer,
    this.slowModeSeconds = 0,
    this.canCreatePost = false,
    this.canEdit = false,
    this.canPinUnpin = false,
    this.canClose = false,
    this.canArchive = false,
    this.canToggleVisibility = false,
    this.canDelete = false,
    this.canRecover = false,
    this.canPermanentlyDelete = false,
    this.canMovePosts = false,
  });

  /// Parses topic-view payload [t] (`/t/{id}.json` and its windowed forms;
  /// TopicViewSerializer + TopicViewDetailsSerializer). The permission
  /// flags are emitted only when the guardian grants them, so absence is
  /// a no.
  factory DiscourseTopicStatus.fromTopicView(Map<String, dynamic> t) {
    final details =
        (t['details'] as Map?)?.cast<String, dynamic>() ?? const {};
    final timer = t['topic_timer'];
    return DiscourseTopicStatus(
      pinned: t['pinned'] == true,
      unpinned: t['unpinned'] == true,
      pinnedGlobally: t['pinned_globally'] == true,
      pinnedUntil: DateTime.tryParse(t['pinned_until']?.toString() ?? ''),
      closed: t['closed'] == true,
      archived: t['archived'] == true,
      // Absent on payloads that don't serialize it: listed.
      visible: t['visible'] != false,
      deleted: t['deleted_at'] != null,
      isWarning: t['is_warning'] == true,
      isMessage: t['archetype'] == 'private_message',
      notificationLevel: (details['notification_level'] as num?)?.toInt() ?? 1,
      notificationsReasonId:
          (details['notifications_reason_id'] as num?)?.toInt(),
      timer: timer is Map
          ? DiscourseTopicTimer.fromJson(timer.cast<String, dynamic>())
          : null,
      slowModeSeconds: (t['slow_mode_seconds'] as num?)?.toInt() ?? 0,
      canCreatePost: details['can_create_post'] == true,
      canEdit: details['can_edit'] == true,
      canPinUnpin: details['can_pin_unpin_topic'] == true,
      canClose: details['can_close_topic'] == true,
      canArchive: details['can_archive_topic'] == true,
      canToggleVisibility: details['can_toggle_topic_visibility'] == true,
      canDelete: details['can_delete'] == true,
      canRecover: details['can_recover'] == true,
      canPermanentlyDelete: details['can_permanently_delete'] == true,
      canMovePosts: details['can_move_posts'] == true,
    );
  }

  /// Pinned, and the viewer has not unpinned it for themselves
  /// (PinnedCheck.pinned?). Web shows the thumbtack.
  final bool pinned;

  /// Pinned, but the viewer cleared the pin for themselves
  /// (PUT /t/{id}/clear-pin): it lists in regular order for them only.
  /// Web shows the thumbtack crossed out.
  final bool unpinned;

  /// Pinned at the top of Latest as well as of its category.
  final bool pinnedGlobally;

  /// When the pin lapses, if staff set an end date.
  final DateTime? pinnedUntil;

  final bool closed;

  /// Frozen: no replies and no edits.
  final bool archived;

  /// False when unlisted: reachable by link only.
  final bool visible;

  /// Soft-deleted; only staff (and the author, briefly) still see it.
  final bool deleted;

  /// A staff warning, sent as a personal message.
  final bool isWarning;
  final bool isMessage;

  /// The viewer's notification level on the topic: 0 Muted, 1 Normal,
  /// 2 Tracking, 3 Watching.
  final int notificationLevel;

  /// Why the viewer is at [notificationLevel] (TopicUser.notification_reasons):
  /// 1 created the topic, 2 chose it, 4 replied, 5 watched automatically,
  /// 6 watching the category, 7 muted category, 8 tracking the category,
  /// 10 watching a tag. Null when Discourse sent none.
  final int? notificationsReasonId;

  /// The topic's public timer, if one is set.
  final DiscourseTopicTimer? timer;

  /// Minimum seconds between one user's posts, 0 when slow mode is off.
  final int slowModeSeconds;

  final bool canCreatePost;

  /// May edit the topic: its title, category and tags.
  final bool canEdit;

  /// May pin or unpin it for everyone (staff, category moderators).
  final bool canPinUnpin;
  final bool canClose;
  final bool canArchive;

  /// May list or unlist it.
  final bool canToggleVisibility;
  final bool canDelete;
  final bool canRecover;

  /// May delete it for good (`force_destroy`), which needs the site's
  /// `can_permanently_delete` and a topic already deleted long enough.
  final bool canPermanentlyDelete;

  /// May move its posts to another topic (merging it into one).
  final bool canMovePosts;

  /// This status after an action the app took, ahead of the next load.
  DiscourseTopicStatus copyWith({
    bool? pinned,
    bool? unpinned,
    bool? pinnedGlobally,
    bool? closed,
    bool? archived,
    bool? visible,
    bool? deleted,
    int? notificationLevel,
    int? notificationsReasonId,
  }) =>
      DiscourseTopicStatus(
        pinned: pinned ?? this.pinned,
        unpinned: unpinned ?? this.unpinned,
        pinnedGlobally: pinnedGlobally ?? this.pinnedGlobally,
        pinnedUntil: pinnedUntil,
        closed: closed ?? this.closed,
        archived: archived ?? this.archived,
        visible: visible ?? this.visible,
        deleted: deleted ?? this.deleted,
        isWarning: isWarning,
        isMessage: isMessage,
        notificationLevel: notificationLevel ?? this.notificationLevel,
        notificationsReasonId:
            notificationsReasonId ?? this.notificationsReasonId,
        timer: timer,
        slowModeSeconds: slowModeSeconds,
        canCreatePost: canCreatePost,
        canEdit: canEdit,
        canPinUnpin: canPinUnpin,
        canClose: canClose,
        canArchive: canArchive,
        canToggleVisibility: canToggleVisibility,
        canDelete: canDelete,
        canRecover: canRecover,
        canPermanentlyDelete: canPermanentlyDelete,
        canMovePosts: canMovePosts,
      );

  /// Staff pinned it, whether or not the viewer has unpinned it.
  bool get isPinnedByStaff => pinned || unpinned;

  static final Map<String, DiscourseTopicStatus> _byTopic = {};

  static String _key(String siteUrl, String topicId) => '$siteUrl|$topicId';

  /// Records [status] for [topicId] on the forum at [siteUrl]. Overwritten
  /// on every load of the topic, so a change shows on the next fetch.
  static void store(String siteUrl, String topicId, DiscourseTopicStatus status) {
    if (topicId.isEmpty) return;
    _byTopic[_key(siteUrl, topicId)] = status;
    changes.value++;
  }

  /// Bumped on every [store], so the topic page's title, footer and menu
  /// redraw together when a load or an action changes the record.
  static final ValueNotifier<int> changes = ValueNotifier(0);

  static DiscourseTopicStatus? forTopic(String siteUrl, String topicId) =>
      topicId.isEmpty ? null : _byTopic[_key(siteUrl, topicId)];

  /// Only for tests and sign-out; one small entry per topic opened.
  static void clear() => _byTopic.clear();
}

/// A topic's public timer (TopicTimerSerializer): what happens to the topic
/// and when. Web's TopicTimerInfo writes it under the last post.
class DiscourseTopicTimer {
  const DiscourseTopicTimer({
    required this.statusType,
    this.executeAt,
    this.durationMinutes,
    this.basedOnLastPost = false,
    this.categoryId,
  });

  factory DiscourseTopicTimer.fromJson(Map<String, dynamic> j) =>
      DiscourseTopicTimer(
        statusType: (j['status_type'] ?? '').toString(),
        executeAt: DateTime.tryParse(j['execute_at']?.toString() ?? ''),
        durationMinutes: (j['duration_minutes'] as num?)?.toInt(),
        basedOnLastPost: j['based_on_last_post'] == true,
        categoryId: (j['category_id'] as num?)?.toInt(),
      );

  /// `close`, `open`, `publish_to_category`, `delete`, `reminder`, `bump`,
  /// `delete_replies`, `silent_close` (TopicTimer.types).
  final String statusType;
  final DateTime? executeAt;
  final int? durationMinutes;

  /// Counts from the last reply, so every reply pushes it back.
  final bool basedOnLastPost;

  /// Where `publish_to_category` moves the topic.
  final int? categoryId;
}
