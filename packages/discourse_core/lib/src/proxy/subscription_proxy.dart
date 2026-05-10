import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_subscription_proxy.dart';
import 'package:forumcopilot_sdk/models/results/fc_subscription_result.dart';

import '../base_discourse_proxy.dart';

/// Discourse implementation of [IFCSubscriptionProxy].
///
/// Discourse exposes topic/category subscription as a 4-state
/// `notification_level`:
///
/// | Level | Meaning            |
/// |-------|--------------------|
/// |   0   | Muted              |
/// |   1   | Regular (default)  |
/// |   2   | Tracking           |
/// |   3   | Watching           |
/// |   4   | Watching first post|
///
/// The FC SDK was modeled on XenForo's boolean subscribe/unsubscribe with
/// an `email mode` int — that's lossy but workable. We map:
///
///   * subscribe   → POST notification_level=3 (Watching)
///   * unsubscribe → POST notification_level=1 (Regular = no email/notif)
///
/// Phase 2.x will extend the SDK with a Discourse-native enum so the UI
/// can offer all four levels.
class DiscourseSubscriptionProxy extends BaseDiscourseProxy
    implements IFCSubscriptionProxy {
  DiscourseSubscriptionProxy(SiteContext context) : super(context);

  static const int _levelMuted = 0;
  static const int _levelRegular = 1;
  static const int _levelTracking = 2;
  static const int _levelWatching = 3;

  /// Public level constants. UI uses these instead of magic numbers when
  /// calling [setTopicNotificationLevelAsync] /
  /// [setCategoryNotificationLevelAsync].
  static const int levelMuted = _levelMuted;
  static const int levelRegular = _levelRegular;
  static const int levelTracking = _levelTracking;
  static const int levelWatching = _levelWatching;
  // 4 == Watching first post (per-category); per-topic doesn't use it.
  static const int levelWatchingFirstPost = 4;

  @override
  Future<FCSubscribeTopicResult> subscribeTopicAsync(
      String topicId, int subscribeMode) async {
    final level = _xfSubscribeModeToDiscourseLevel(subscribeMode);
    try {
      await apiPost('/t/$topicId/notifications.json', body: {
        'notification_level': level,
      });
      return FCSubscribeTopicResult(result: true, resultText: '');
    } catch (e) {
      return FCSubscribeTopicResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCUnsubscribeTopicResult> unsubscribeTopicAsync(String topicId) async {
    try {
      await apiPost('/t/$topicId/notifications.json', body: {
        'notification_level': _levelRegular,
      });
      return FCUnsubscribeTopicResult(result: true, resultText: '');
    } catch (e) {
      return FCUnsubscribeTopicResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCSubscribeForumResult> subscribeForumAsync(
      String forumId, int subscribeMode) async {
    final level = _xfSubscribeModeToDiscourseLevel(subscribeMode);
    try {
      await apiPost('/category/$forumId/notifications.json', body: {
        'notification_level': level,
      });
      return FCSubscribeForumResult(result: true, resultText: '');
    } catch (e) {
      return FCSubscribeForumResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCUnsubscribeForumResult> unsubscribeForumAsync(String forumId) async {
    try {
      await apiPost('/category/$forumId/notifications.json', body: {
        'notification_level': _levelRegular,
      });
      return FCUnsubscribeForumResult(result: true, resultText: '');
    } catch (e) {
      return FCUnsubscribeForumResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCSubscribedForumResult> getSubscribedForumAsync() async {
    try {
      final response = await apiGet('/categories.json');
      final list = (response['category_list'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      final cats = ((list['categories'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>();
      final forums = <FCSubscribedForum>[];
      for (final c in cats) {
        final level = (c['notification_level'] as int?) ?? _levelRegular;
        if (level < _levelTracking) continue;
        final logo =
            (c['uploaded_logo'] as Map<String, dynamic>?)?['url'] as String?;
        forums.add(FCSubscribedForum(
          forumId: (c['id'] ?? '').toString(),
          forumName: (c['name'] ?? '').toString(),
          iconUrl: _absoluteUrl(logo),
          isProtected: c['read_restricted'] as bool? ?? false,
          newPost: false,
          canPost: true,
          subscribeMode: _discourseLevelToXfSubscribeMode(level),
          isSubscribed: true,
          canSubscribe: true,
        ));
      }
      return FCSubscribedForumResult(
        result: true,
        resultText: '',
        totalForumsNum: forums.length,
        forums: forums,
      );
    } catch (e) {
      return FCSubscribedForumResult(
        result: false,
        resultText: 'Error: $e',
        totalForumsNum: 0,
      );
    }
  }

  @override
  Future<FCSubscribedTopicResult> getSubscribedTopicAsync(
      int startNum, int lastNum) async {
    // Discourse's "watched topics" listing surfaces under /latest.json with
    // the per-topic notification_level on `topic_list.topics`. We page-fetch
    // /latest.json and filter to topics with notification_level >= Tracking.
    //
    // Caveat: this is best-effort. /latest.json is paginated and only
    // includes topics the user can see — the user's _watched topic outside
    // their normal feed_ won't appear. Phase 2.x can swap in a
    // /u/{username}/messages-tracked-style endpoint when we identify one.
    try {
      final response = await apiGet('/latest.json', query: {
        if (startNum > 0) 'page': (startNum / 30).floor().toString(),
      });
      final users = <int, Map<String, dynamic>>{};
      for (final u in ((response['users'] as List?) ?? const []).whereType<Map>()) {
        final id = u['id'];
        if (id is int) users[id] = u.cast<String, dynamic>();
      }
      final list = (response['topic_list'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      final topics = <FCSubscribedTopic>[];
      for (final raw in ((list['topics'] as List?) ?? const []).whereType<Map>()) {
        final t = raw.cast<String, dynamic>();
        final level = (t['notification_level'] as int?) ?? _levelRegular;
        if (level < _levelTracking) continue;
        topics.add(_toSubscribedTopic(t, users: users));
      }
      return FCSubscribedTopicResult(
        result: true,
        resultText: '',
        totalTopicNum: topics.length,
        topics: topics,
      );
    } catch (e) {
      return FCSubscribedTopicResult(
        result: false,
        resultText: 'Error: $e',
        totalTopicNum: 0,
      );
    }
  }

  /// Discourse-native: set the per-topic notification level directly.
  /// [level] must be one of [levelMuted], [levelRegular], [levelTracking],
  /// [levelWatching]. Returns true on success.
  Future<bool> setTopicNotificationLevelAsync(
      String topicId, int level) async {
    try {
      await apiPost('/t/$topicId/notifications.json', body: {
        'notification_level': level,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Discourse-native: set the per-category notification level directly.
  /// [level] supports [levelWatchingFirstPost] in addition to the four
  /// topic levels. Returns true on success.
  Future<bool> setCategoryNotificationLevelAsync(
      String categoryId, int level) async {
    try {
      await apiPost('/category/$categoryId/notifications.json', body: {
        'notification_level': level,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Discourse-native: read the current per-topic notification level.
  /// Returns null if the topic can't be loaded. Hits `/t/{id}.json`.
  Future<int?> getTopicNotificationLevelAsync(String topicId) async {
    try {
      final t = await apiGet('/t/$topicId.json');
      return t['notification_level'] as int?;
    } catch (_) {
      return null;
    }
  }

  /// Discourse-native: read the current per-category notification level.
  /// Pulls from `/categories.json` (only categories the user can see are
  /// returned). Returns null when the category isn't found.
  Future<int?> getCategoryNotificationLevelAsync(String categoryId) async {
    try {
      final response = await apiGet('/categories.json');
      final list = (response['category_list'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      final cats = ((list['categories'] as List?) ?? const [])
          .whereType<Map>();
      for (final raw in cats) {
        final c = raw.cast<String, dynamic>();
        if (c['id'].toString() == categoryId) {
          return c['notification_level'] as int?;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ===== Helpers =====

  /// XF "subscribe mode" → Discourse `notification_level`. The XF/FC enum
  /// roughly says: 0 = no email (notifications only), 1 = instant, 2 =
  /// daily, 3 = weekly. Discourse doesn't have email-cadence levels — it
  /// has tracking depth instead. Anything non-zero becomes Watching;
  /// 0 stays at Tracking (track without email but show in unread).
  int _xfSubscribeModeToDiscourseLevel(int xfMode) {
    switch (xfMode) {
      case 0:
        return _levelTracking;
      default:
        return _levelWatching;
    }
  }

  int _discourseLevelToXfSubscribeMode(int level) {
    switch (level) {
      case _levelMuted:
      case _levelRegular:
        return 0;
      case _levelTracking:
        return 0;
      case _levelWatching:
      default:
        return 1;
    }
  }

  FCSubscribedTopic _toSubscribedTopic(
    Map<String, dynamic> t, {
    Map<int, Map<String, dynamic>> users = const {},
  }) {
    final posters = (t['posters'] as List?) ?? const [];
    int? opUserId;
    for (final p in posters.whereType<Map>()) {
      final desc = (p['description'] ?? '').toString();
      if (desc.contains('Original Poster')) {
        opUserId = p['user_id'] as int?;
        break;
      }
    }
    opUserId ??=
        posters.isNotEmpty ? (posters.first as Map)['user_id'] as int? : null;
    final opUser = opUserId == null ? null : users[opUserId];
    final tpl = opUser?['avatar_template'] as String?;
    String? avatarUrl;
    if (tpl != null && tpl.isNotEmpty) {
      final filled = tpl.replaceAll('{size}', '90');
      avatarUrl = filled.startsWith('http')
          ? filled
          : '${siteContext.site.url}$filled';
    }

    return FCSubscribedTopic(
      forumId: (t['category_id'] ?? '').toString(),
      forumName: '',
      topicId: (t['id'] ?? '').toString(),
      topicTitle: (t['title'] ?? '').toString(),
      postAuthorName: (opUser?['username'] ?? '').toString(),
      postAuthorId: (opUserId ?? '').toString(),
      isClosed: (t['closed'] as bool?) ?? false,
      iconUrl: avatarUrl,
      postTime: DateTime.tryParse(t['created_at']?.toString() ?? '') ??
          DateTime.now(),
      replyNumber: (((t['posts_count'] as int?) ?? 1) - 1).clamp(0, 1 << 30),
      newPost: t['unseen'] == true || (t['unread_posts'] as int? ?? 0) > 0,
      subscribeMode: _discourseLevelToXfSubscribeMode(
          (t['notification_level'] as int?) ?? _levelRegular),
      viewNumber: (t['views'] as int?) ?? 0,
      shortContent: (t['excerpt'] as String?) ?? '',
      isPinned: (t['pinned'] as bool?) ?? false,
      isAnnouncement: (t['pinned_globally'] as bool?) ?? false,
      isArchived: (t['archived'] as bool?) ?? false,
      isSubscribed: true,
    );
  }

  String? _absoluteUrl(String? maybeRelative) {
    if (maybeRelative == null || maybeRelative.isEmpty) return null;
    if (maybeRelative.startsWith('http')) return maybeRelative;
    return '${siteContext.site.url}$maybeRelative';
  }
}
