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
  // app/models/notification.rb#types — we only enumerate types we surface
  // a friendly label for; everything else falls through to a generic msg.
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
  Future<FCFollowResult> followAsync(String userId) async {
    // discourse-follow plugin: PUT /follow/{username}.json. Without the
    // plugin the route 404s. For now report as unsupported so the UI
    // surfaces a clear message; Phase 2.x can detect the plugin and
    // enable the call.
    return FCFollowResult(
      result: false,
      resultText:
          'Follow requires the discourse-follow plugin — not implemented yet.',
    );
  }

  @override
  Future<FCUnfollowResult> unfollowAsync(String userId) async {
    return FCUnfollowResult(
      result: false,
      resultText:
          'Unfollow requires the discourse-follow plugin — not implemented yet.',
    );
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
    final readableMessage = _readableNotification(type, fromUser, topicTitle);
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

  String _readableNotification(int type, String from, String topic) {
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
        return 'You earned a new badge';
      default:
        return 'New activity in "$topic"';
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
    switch (type) {
      case _ntMentioned:
        return 'mention';
      case _ntReplied:
      case _ntPosted:
        return 'reply';
      case _ntQuoted:
        return 'quote';
      case _ntLiked:
        return 'like';
      case _ntPrivateMessage:
      case _ntInvitedToPm:
        return 'pm';
      case _ntLinked:
        return 'link';
      case _ntGrantedBadge:
        return 'badge';
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
