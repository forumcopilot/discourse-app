import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_social_proxy.dart';
import 'package:forumcopilot_sdk/models/results/fc_social_result.dart';

import '../base_discourse_proxy.dart';

/// Discourse implementation of [IFCSocialProxy].
///
/// Endpoints used:
///   * POST   `/post_actions`           — create a like (post_action_type_id=2)
///   * DELETE `/post_actions/{post_id}` — remove a like
///   * GET    `/notifications.json`     — alerts feed
///   * GET    `/user_actions.json`      — activity feed
///
/// Notes / gaps:
/// - `follow/unfollow` require the optional `discourse-follow` plugin.
///   Stubbed `result:false` so the UI's follow button reports clearly when
///   the feature isn't available on the forum. Discourse-native
///   integrations should use `DiscourseUserProxy.followUserAsync` / its
///   unfollow counterpart (Phase 5.8), which target the plugin endpoint
///   directly with a username.
class DiscourseSocialProxy extends BaseDiscourseProxy implements IFCSocialProxy {
  DiscourseSocialProxy(SiteContext context) : super(context);

  // PostActionType id for "Like" — see app/models/post_action_type.rb in
  // Discourse.
  static const int _likeType = 2;

  // Discourse Notification type ids (subset). Full list lives in
  // app/models/notification.rb#types — Phase 5.20c extended this from
  // the original 12 to cover every documented Discourse notification
  // type, including the chat plugin's five (29–33), reactions (25),
  // bookmark reminders, post-approval, event invites, assignment,
  // and the various "consolidated" digest types Discourse emits when
  // it batches multiple events into a single notification. Anything
  // we don't recognise still falls through to a generic message.
  static const int _ntMentioned = 1;
  static const int _ntReplied = 2;
  static const int _ntQuoted = 3;
  static const int _ntEdited = 4;
  static const int _ntLiked = 5;
  static const int _ntPrivateMessage = 6;
  static const int _ntInvitedToPm = 7;
  static const int _ntInviteeAccepted = 8;
  static const int _ntPosted = 9;
  static const int _ntMovedPost = 10;
  static const int _ntLinked = 11;
  static const int _ntGrantedBadge = 12;
  static const int _ntInvitedToTopic = 13;
  static const int _ntCustom = 14;
  static const int _ntGroupMentioned = 15;
  static const int _ntGroupMessageSummary = 16;
  static const int _ntWatchingFirstPost = 17;
  static const int _ntTopicReminder = 18;
  static const int _ntLikedConsolidated = 19;
  static const int _ntPostApproved = 20;
  static const int _ntCodeReviewCommitApproved = 21;
  static const int _ntMembershipRequestAccepted = 22;
  static const int _ntMembershipRequestConsolidated = 23;
  static const int _ntBookmarkReminder = 24;
  static const int _ntReaction = 25;
  static const int _ntVotesReleased = 26;
  static const int _ntEventReminder = 27;
  static const int _ntEventInvitation = 28;
  static const int _ntChatMention = 29;
  static const int _ntChatMessage = 30;
  static const int _ntChatInvitation = 31;
  static const int _ntChatGroupMention = 32;
  static const int _ntChatQuoted = 33;
  static const int _ntAssigned = 34;
  static const int _ntQuestionAnswerUserCommented = 35;
  static const int _ntWatchingCategoryOrTag = 36;
  static const int _ntNewFeatures = 37;
  static const int _ntAdminProblems = 38;
  static const int _ntLinkedConsolidated = 39;

  @override
  Future<FCLikePostResult> likePostAsync(String postId) =>
      _toggleLike(postId, like: true,
          buildResult: (result) => FCLikePostResult(
                result: result.success,
                resultText: result.resultText,
                isLiked: result.isLiked,
                likeCount: result.likeCount,
              ));

  @override
  Future<FCUnlikePostResult> unlikePostAsync(String postId) async {
    final r = await _toggleLikeRaw(postId, like: false);
    return FCUnlikePostResult(
      result: r.success,
      resultText: r.resultText,
      isLiked: r.isLiked,
      likeCount: r.likeCount,
    );
  }

  @override
  Future<FCFollowResult> followAsync(String username) async {
    // Phase 5.30 — implementation lifted from the deleted
    // `DiscourseUserProxy.followUserAsync` sidecar. The
    // discourse-follow plugin exposes `PUT /follow/{username}.json`;
    // when the plugin isn't installed the route 404s and we surface
    // a clear error rather than a generic failure.
    if (username.isEmpty) {
      return FCFollowResult(
        result: false,
        resultText: 'No username supplied',
      );
    }
    try {
      await apiPut('/follow/${Uri.encodeComponent(username)}.json');
      return FCFollowResult(result: true, resultText: '');
    } on DiscourseApiException catch (e) {
      if (e.statusCode == 404) {
        return FCFollowResult(
          result: false,
          resultText:
              'Follow requires the discourse-follow plugin on this forum.',
        );
      }
      return FCFollowResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCFollowResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCUnfollowResult> unfollowAsync(String username) async {
    if (username.isEmpty) {
      return FCUnfollowResult(
        result: false,
        resultText: 'No username supplied',
      );
    }
    try {
      await apiDelete('/follow/${Uri.encodeComponent(username)}.json');
      return FCUnfollowResult(result: true, resultText: '');
    } on DiscourseApiException catch (e) {
      if (e.statusCode == 404) {
        return FCUnfollowResult(
          result: false,
          resultText:
              'Unfollow requires the discourse-follow plugin on this forum.',
        );
      }
      return FCUnfollowResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCUnfollowResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCAlertResult> getAlertAsync(int page, int perpage, bool forceRefresh) async {
    try {
      final perPage = perpage <= 0 ? 30 : perpage;
      final response = await apiGet('/notifications.json', query: {
        if (page > 0) 'offset': (page * perPage).toString(),
        'limit': perPage.toString(),
      });
      final items = ((response['notifications'] as List?) ?? const [])
          .whereType<Map>()
          .map((n) => _toAlert(n.cast<String, dynamic>()))
          .toList();
      return FCAlertResult(
        result: true,
        resultText: '',
        total: (response['total_rows_notifications'] as int?) ?? items.length,
        items: items,
      );
    } catch (e) {
      return FCAlertResult(
        result: false,
        resultText: 'Error: $e',
        total: 0,
        items: const [],
      );
    }
  }

  @override
  Future<FCActivityResult> getActivityAsync(int page, int perpage) async {
    final username = siteContext.currentUsername;
    if (username == null || username.isEmpty) {
      return FCActivityResult(
        result: false,
        resultText: 'Not signed in',
        total: 0,
        items: const [],
      );
    }
    try {
      final perPage = perpage <= 0 ? 30 : perpage;
      final response = await apiGet('/user_actions.json', query: {
        'username': username,
        // Filter values: 1=Like, 2=WasLiked, 3=Bookmark, 4=NewTopic,
        // 5=Reply, 6=Response, 7=Mention, 9=Quote, 11=Edit, 12=Message,
        // 13=GotPrivateMessage, 14=Pending. We surface user-driven ones.
        'filter': '4,5,9,12',
        if (page > 0) 'offset': (page * perPage).toString(),
      });
      final actions = ((response['user_actions'] as List?) ?? const [])
          .whereType<Map>()
          .map((a) => _toActivity(a.cast<String, dynamic>()))
          .toList();
      return FCActivityResult(
        result: true,
        resultText: '',
        total: actions.length,
        items: actions,
      );
    } catch (e) {
      return FCActivityResult(
        result: false,
        resultText: 'Error: $e',
        total: 0,
        items: const [],
      );
    }
  }

  @override
  Future<FCMarkAlertsReadResult> markAllAlertsReadAsync() async {
    // Phase 5.32 — Discourse: `PUT /notifications/mark-read` with no
    // body clears every unread notification for the current user in
    // one call. Returns 200 on success, 403/404 on auth failure.
    if (!siteContext.isLoggedIn) {
      return FCMarkAlertsReadResult(
        result: false,
        resultText: 'Not signed in',
      );
    }
    try {
      await apiPut('/notifications/mark-read');
      return FCMarkAlertsReadResult(result: true, resultText: '');
    } on DiscourseApiException catch (e) {
      return FCMarkAlertsReadResult(
        result: false,
        resultText: e.userMessage,
      );
    } catch (e) {
      return FCMarkAlertsReadResult(
        result: false,
        resultText: 'Error: $e',
      );
    }
  }

  // ===== Helpers =====

  Future<_LikeOutcome> _toggleLikeRaw(String postId,
      {required bool like}) async {
    try {
      Map<String, dynamic> response;
      if (like) {
        response = await apiPost('/post_actions.json', body: {
          'id': int.tryParse(postId) ?? postId,
          'post_action_type_id': _likeType,
        });
      } else {
        response = await apiDelete('/post_actions/$postId.json',
            query: {'post_action_type_id': _likeType.toString()});
      }
      final actions = (response['actions_summary'] as List?) ?? const [];
      final likeAction = actions.whereType<Map>().firstWhere(
            (a) => a['id'] == _likeType,
            orElse: () => <String, dynamic>{},
          );
      return _LikeOutcome(
        success: true,
        resultText: '',
        isLiked: likeAction['acted'] == true,
        likeCount: (likeAction['count'] as int?) ?? 0,
      );
    } catch (e) {
      return _LikeOutcome(
        success: false,
        resultText: 'Error: $e',
        isLiked: !like, // best-effort: keep prior state on failure
        likeCount: 0,
      );
    }
  }

  Future<R> _toggleLike<R>(
    String postId, {
    required bool like,
    required R Function(_LikeOutcome) buildResult,
  }) async {
    final r = await _toggleLikeRaw(postId, like: like);
    return buildResult(r);
  }

  FCAlert _toAlert(Map<String, dynamic> n) {
    final type = (n['notification_type'] as int?) ?? 0;
    final data = (n['data'] as Map<String, dynamic>?) ?? const {};
    final fromUser = data['display_username']?.toString() ?? '';
    final topicTitle =
        (n['fancy_title'] ?? data['topic_title'] ?? '').toString();
    final topicId = n['topic_id']?.toString();
    final postNumber = n['post_number'] as int?;
    final readableMessage =
        _readableNotification(type, fromUser, topicTitle, data);
    final contentType = _alertContentType(type);
    final contentId =
        contentType == 'topic' ? (topicId ?? '') : (postNumber?.toString() ?? '');

    String? actionUrl;
    if (topicId != null && (n['slug'] ?? '').toString().isNotEmpty) {
      actionUrl = '${siteContext.site.url}/t/${n['slug']}/$topicId'
          '${postNumber != null ? '/$postNumber' : ''}';
    }

    // The FC SDK contract for FCAlert.timestamp is a millisecond-epoch
    // string (the notification list tab parses it with `int.parse` then
    // `DateTime.fromMillisecondsSinceEpoch`). Discourse returns ISO 8601
    // in `created_at`, so we convert here. Without this conversion the
    // list ends up silently empty because the tab's .map() throws on
    // every row.
    final createdAtRaw = (n['created_at'] ?? '').toString();
    final timestampMs = createdAtRaw.isEmpty
        ? DateTime.now().millisecondsSinceEpoch
        : (DateTime.tryParse(createdAtRaw)?.millisecondsSinceEpoch ??
            DateTime.now().millisecondsSinceEpoch);

    return FCAlert(
      userId: (n['user_id'] ?? '').toString(),
      username: fromUser,
      iconUrl: '',
      message: readableMessage,
      timestamp: timestampMs.toString(),
      contentType: contentType,
      contentId: contentId,
      topicId: topicId,
      position: postNumber,
      postId: null,
      conversationId: type == _ntPrivateMessage ? topicId : null,
      actionUrl: actionUrl,
      fromUsername: fromUser,
      action: _alertActionVerb(type),
    );
  }

  FCActivity _toActivity(Map<String, dynamic> a) {
    final actionType = (a['action_type'] as int?) ?? 0;
    // FCActivity.timestamp follows the same contract as FCAlert.timestamp:
    // millisecond-epoch string. Convert ISO 8601 → ms here so consumers
    // can `int.parse` without surprises.
    final createdAtRaw = (a['created_at'] ?? '').toString();
    final timestampMs = createdAtRaw.isEmpty
        ? DateTime.now().millisecondsSinceEpoch
        : (DateTime.tryParse(createdAtRaw)?.millisecondsSinceEpoch ??
            DateTime.now().millisecondsSinceEpoch);
    return FCActivity(
      userId: (a['user_id'] ?? '').toString(),
      username: (a['username'] ?? '').toString(),
      iconUrl: '',
      message: _readableActivity(actionType, a),
      timestamp: timestampMs.toString(),
      contentType: 'topic',
      contentId: (a['topic_id'] ?? '').toString(),
      topicId: a['topic_id']?.toString(),
    );
  }

  String _readableNotification(
    int type,
    String from,
    String topic,
    Map<String, dynamic> data,
  ) {
    // Read a hint from the data blob — Discourse stuffs supplementary
    // fields (group name, chat channel name, badge name, etc.) here.
    String s(String key) => (data[key] ?? '').toString();
    int? i(String key) {
      final raw = data[key];
      if (raw is num) return raw.toInt();
      if (raw is String) return int.tryParse(raw);
      return null;
    }

    switch (type) {
      case _ntMentioned:
        return '$from mentioned you in "$topic"';
      case _ntReplied:
        return '$from replied to your post in "$topic"';
      case _ntQuoted:
        return '$from quoted your post in "$topic"';
      case _ntEdited:
        return '$from edited your post in "$topic"';
      case _ntLiked:
        return '$from liked your post in "$topic"';
      case _ntPrivateMessage:
        return 'New message from $from: "$topic"';
      case _ntInvitedToPm:
        return '$from invited you to a private message: "$topic"';
      case _ntInviteeAccepted:
        return '$from accepted your invitation';
      case _ntPosted:
        return '$from posted in "$topic"';
      case _ntMovedPost:
        return 'A post was moved to "$topic"';
      case _ntLinked:
        return '$from linked to your post in "$topic"';
      case _ntGrantedBadge:
        final badgeName = s('badge_name');
        return badgeName.isNotEmpty
            ? 'You earned the "$badgeName" badge'
            : 'You earned a new badge';
      // Phase 5.20c additions:
      case _ntInvitedToTopic:
        return '$from invited you to "$topic"';
      case _ntCustom:
        // Discourse plugins fire `custom` with their own message
        // payload — fall back to topic title when present.
        return topic.isNotEmpty ? topic : 'New activity';
      case _ntGroupMentioned:
        final group = s('group_name');
        return group.isNotEmpty
            ? '$from mentioned @$group in "$topic"'
            : '$from mentioned your group in "$topic"';
      case _ntGroupMessageSummary:
        final count = i('inbox_count') ?? 0;
        final group = s('group_name');
        if (count > 0 && group.isNotEmpty) {
          return '$count new messages in @$group';
        }
        return 'New group messages';
      case _ntWatchingFirstPost:
        return 'New topic: "$topic"';
      case _ntTopicReminder:
        return 'Reminder: "$topic"';
      case _ntLikedConsolidated:
        final count = i('count') ?? 0;
        return count > 0
            ? 'Your posts received $count likes'
            : 'Your posts received new likes';
      case _ntPostApproved:
        return 'Your post in "$topic" was approved';
      case _ntCodeReviewCommitApproved:
        return 'A commit you submitted was approved';
      case _ntMembershipRequestAccepted:
        final group = s('group_name');
        return group.isNotEmpty
            ? 'You joined @$group'
            : 'Membership request accepted';
      case _ntMembershipRequestConsolidated:
        final count = i('count') ?? 0;
        return count > 0
            ? '$count new membership requests'
            : 'New membership requests';
      case _ntBookmarkReminder:
        return 'Reminder: "$topic"';
      case _ntReaction:
        final actor = from.isNotEmpty ? from : s('username');
        return actor.isNotEmpty
            ? '$actor reacted to your post in "$topic"'
            : 'New reaction on your post in "$topic"';
      case _ntVotesReleased:
        return 'Votes released on "$topic"';
      case _ntEventReminder:
        return 'Event reminder: "$topic"';
      case _ntEventInvitation:
        return '$from invited you to "$topic"';
      case _ntChatMention:
        final channel = s('chat_channel_title');
        return channel.isNotEmpty
            ? '$from mentioned you in #$channel'
            : '$from mentioned you in chat';
      case _ntChatMessage:
        final channel = s('chat_channel_title');
        return channel.isNotEmpty
            ? 'New message in #$channel'
            : 'New chat message';
      case _ntChatInvitation:
        return '$from invited you to chat';
      case _ntChatGroupMention:
        final group = s('identifier');
        final channel = s('chat_channel_title');
        if (group.isNotEmpty && channel.isNotEmpty) {
          return '@$group was mentioned in #$channel';
        }
        return 'Your group was mentioned in chat';
      case _ntChatQuoted:
        return '$from quoted you in chat';
      case _ntAssigned:
        return '"$topic" was assigned to you';
      case _ntQuestionAnswerUserCommented:
        return '$from commented on the accepted answer in "$topic"';
      case _ntWatchingCategoryOrTag:
        return 'New topic: "$topic"';
      case _ntNewFeatures:
        return 'New features available';
      case _ntAdminProblems:
        return 'Admin: site problem detected';
      case _ntLinkedConsolidated:
        final count = i('count') ?? 0;
        return count > 0
            ? 'Your post was linked $count times'
            : 'Your post was linked';
      default:
        return topic.isNotEmpty
            ? 'New activity in "$topic"'
            : 'New notification';
    }
  }

  String _readableActivity(int actionType, Map<String, dynamic> a) {
    final title = (a['title'] ?? '').toString();
    switch (actionType) {
      case 4:
        return 'Created topic "$title"';
      case 5:
        return 'Replied to "$title"';
      case 9:
        return 'Quoted in "$title"';
      case 12:
        return 'Sent message: "$title"';
      default:
        return title.isNotEmpty ? title : 'Activity';
    }
  }

  String _alertContentType(int type) {
    switch (type) {
      case _ntPrivateMessage:
      case _ntInvitedToPm:
        return 'message';
      case _ntGrantedBadge:
        return 'badge';
      default:
        return 'topic';
    }
  }

  String _alertActionVerb(int type) {
    // Phase 5.20c — the UI uses this verb as a key for the small
    // overlay icon on the notification list row. New verbs match
    // the icon mapper in `notification_list_item.dart::iconForAction`.
    switch (type) {
      case _ntMentioned:
      case _ntGroupMentioned:
        return 'mention';
      case _ntReplied:
      case _ntPosted:
      case _ntWatchingFirstPost:
      case _ntWatchingCategoryOrTag:
        return 'reply';
      case _ntQuoted:
      case _ntChatQuoted:
        return 'quote';
      case _ntEdited:
        return 'edit';
      case _ntLiked:
      case _ntLikedConsolidated:
        return 'like';
      case _ntPrivateMessage:
      case _ntInvitedToPm:
      case _ntInvitedToTopic:
      case _ntEventInvitation:
        return 'pm';
      case _ntGroupMessageSummary:
        return 'group_message';
      case _ntLinked:
      case _ntLinkedConsolidated:
        return 'link';
      case _ntGrantedBadge:
        return 'badge';
      case _ntBookmarkReminder:
      case _ntTopicReminder:
      case _ntEventReminder:
        return 'reminder';
      case _ntReaction:
        return 'reaction';
      case _ntPostApproved:
      case _ntCodeReviewCommitApproved:
      case _ntMembershipRequestAccepted:
        return 'approved';
      case _ntMembershipRequestConsolidated:
        return 'group_request';
      case _ntChatMention:
      case _ntChatMessage:
      case _ntChatInvitation:
      case _ntChatGroupMention:
        return 'chat';
      case _ntAssigned:
        return 'assigned';
      case _ntQuestionAnswerUserCommented:
        return 'qa_comment';
      case _ntVotesReleased:
        return 'vote';
      case _ntMovedPost:
        return 'moved';
      case _ntInviteeAccepted:
        return 'accepted';
      case _ntNewFeatures:
        return 'new_feature';
      case _ntAdminProblems:
        return 'admin';
      case _ntCustom:
      default:
        return 'activity';
    }
  }
}

class _LikeOutcome {
  final bool success;
  final String resultText;
  final bool isLiked;
  final int likeCount;
  const _LikeOutcome({
    required this.success,
    required this.resultText,
    required this.isLiked,
    required this.likeCount,
  });
}
