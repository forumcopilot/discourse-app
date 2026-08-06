import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_subscription_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_notification_level.dart';
import 'package:forumcopilot_sdk/models/results/fc_notification_result.dart';
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
/// The Discourse-native path landed in Phase 2 and is preferred over the
/// XF-shaped subscribe/unsubscribe pair above: see
/// [setTopicNotificationLevelAsync] / [setCategoryNotificationLevelAsync]
/// and their getters, which speak [FCNotificationLevel] directly.
class DiscourseSubscriptionProxy extends BaseDiscourseProxy
    implements IFCSubscriptionProxy {
  DiscourseSubscriptionProxy(SiteContext context) : super(context);

  static const int _levelMuted = 0;
  static const int _levelRegular = 1;
  static const int _levelTracking = 2;
  static const int _levelWatching = 3;

  /// Public level constants, exported so callers can avoid magic numbers.
  /// (The UI currently still passes literal ints to the XF-shaped
  /// subscribe methods; prefer [FCNotificationLevel] for new code.)
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
      return FCSubscribeTopicResult(result: false, resultText: describeApiError(e));
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
      return FCUnsubscribeTopicResult(result: false, resultText: describeApiError(e));
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
      return FCSubscribeForumResult(result: false, resultText: describeApiError(e));
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
      return FCUnsubscribeForumResult(result: false, resultText: describeApiError(e));
    }
  }

  @override
  Future<FCSubscribedForumResult> getSubscribedForumAsync() async {
    try {
      // include_subcategories=true: without it /categories.json omits
      // subcategories, hiding any watched/tracked subcategory here.
      final response = await apiGet('/categories.json',
          query: {'include_subcategories': 'true'});
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
        // Same `permission` semantics as DiscourseForumProxy._toForum:
        // full:1 / create_post:2 (app/models/category_group.rb:10), and
        // NIL on /categories.json means "may not start topics here"
        // (Category.preload_user_fields!, app/models/category.rb:279-280).
        // Was hardcoded true, which advertised posting in read-only
        // categories.
        final permission = c['permission'];
        forums.add(FCSubscribedForum(
          forumId: (c['id'] ?? '').toString(),
          forumName: (c['name'] ?? '').toString(),
          iconUrl: _absoluteUrl(logo),
          isProtected: c['read_restricted'] as bool? ?? false,
          // No per-category unread signal exists on Discourse (unread is
          // tracked per topic), so this is "unknown", not "nothing new".
          newPost: false,
          canPost: permission == 1 || permission == 2,
          subscribeMode: _discourseLevelToXfSubscribeMode(level),
          // Both true by construction: we only reach here for rows whose
          // notification_level is already >= Tracking.
          isSubscribed: true,
          canSubscribe: true,
        ));
      }
      return FCSubscribedForumResult(
        result: true,
        resultText: '',
        // Exact: /categories.json is not paginated, so this really is
        // every tracked/watched category, not a page of them.
        totalForumsNum: forums.length,
        forums: forums,
      );
    } catch (e) {
      return FCSubscribedForumResult(
        result: false,
        resultText: describeApiError(e),
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
    // includes topics the user can see — a watched topic that has fallen
    // off the user's latest feed won't appear at all, so the list is a
    // SUBSET of what the user actually watches, never a complete one.
    //
    // [lastNum] is unused: /latest.json takes a page number, not an item
    // span, and its page size is fixed server-side
    // (`SiteSetting.topics_per_page`, 30 by default — the constant below
    // mirrors that default because we must pick a page before we can read
    // the response's real `topic_list.per_page`).
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
        // Rows kept from THIS page after the notification_level filter —
        // not a total. Discourse reports no count of watched topics, and
        // the source list is itself only one page of /latest.json.
        totalTopicNum: topics.length,
        topics: topics,
      );
    } catch (e) {
      return FCSubscribedTopicResult(
        result: false,
        resultText: describeApiError(e),
        totalTopicNum: 0,
      );
    }
  }

  @override
  Future<FCNotificationLevelResult> setTopicNotificationLevelAsync(
    String topicId,
    FCNotificationLevel level,
  ) async {
    try {
      await apiPost('/t/$topicId/notifications.json', body: {
        'notification_level': level.level,
      });
      return FCNotificationLevelResult(result: true, level: level);
    } on DiscourseApiException catch (e) {
      return FCNotificationLevelResult(
          result: false, resultText: e.userMessage);
    } catch (e) {
      return FCNotificationLevelResult(result: false, resultText: describeApiError(e));
    }
  }

  @override
  Future<FCNotificationLevelResult> setCategoryNotificationLevelAsync(
    String categoryId,
    FCNotificationLevel level,
  ) async {
    try {
      await apiPost('/category/$categoryId/notifications.json', body: {
        'notification_level': level.level,
      });
      return FCNotificationLevelResult(result: true, level: level);
    } on DiscourseApiException catch (e) {
      return FCNotificationLevelResult(
          result: false, resultText: e.userMessage);
    } catch (e) {
      return FCNotificationLevelResult(result: false, resultText: describeApiError(e));
    }
  }

  @override
  Future<FCNotificationLevelResult> getTopicNotificationLevelAsync(
    String topicId,
  ) async {
    try {
      final t = await apiGet('/t/$topicId.json');
      // Topic-view payloads carry notification_level under `details`
      // (app/serializers/topic_view_details_serializer.rb); only list
      // payloads have it top-level. Read details first, then fall back.
      final details = t['details'] as Map<String, dynamic>?;
      final raw = (details?['notification_level'] as int?) ??
          (t['notification_level'] as int?);
      return FCNotificationLevelResult(
        result: true,
        level: raw != null ? FCNotificationLevel.fromInt(raw) : null,
      );
    } on DiscourseApiException catch (e) {
      return FCNotificationLevelResult(
          result: false, resultText: e.userMessage);
    } catch (e) {
      return FCNotificationLevelResult(result: false, resultText: describeApiError(e));
    }
  }

  @override
  Future<FCNotificationLevelResult> getCategoryNotificationLevelAsync(
    String categoryId,
  ) async {
    try {
      // include_subcategories=true: without it /categories.json omits
      // subcategories, so their notification level silently reads as null.
      final response = await apiGet('/categories.json',
          query: {'include_subcategories': 'true'});
      final list = (response['category_list'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      final cats = ((list['categories'] as List?) ?? const [])
          .whereType<Map>();
      for (final raw in cats) {
        final c = raw.cast<String, dynamic>();
        if (c['id'].toString() == categoryId) {
          final lvl = c['notification_level'] as int?;
          return FCNotificationLevelResult(
            result: true,
            level: lvl != null ? FCNotificationLevel.fromInt(lvl) : null,
          );
        }
      }
      return FCNotificationLevelResult(result: true);
    } on DiscourseApiException catch (e) {
      return FCNotificationLevelResult(
          result: false, resultText: e.userMessage);
    } catch (e) {
      return FCNotificationLevelResult(result: false, resultText: describeApiError(e));
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

  /// Lossy by construction: Muted(0), Regular(1) and Tracking(2) all
  /// collapse to XF mode 0 ("no email"), so a MUTED item is
  /// indistinguishable from a tracked one at this boundary. Callers that
  /// need the real state must use [getTopicNotificationLevelAsync] /
  /// [getCategoryNotificationLevelAsync]. Both list methods above filter
  /// to level >= Tracking before mapping, so muted rows can't leak
  /// through today.
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
    // Server contract (app/models/topic_posters_summary.rb): posters are
    // ordered topic-creator-first — the latest poster is shuffled to the
    // back unless they ARE the creator — and only `extras` ('latest' /
    // 'latest single') is a structured marker; `description` is localized
    // and must not be matched. So posters[0] is the Original Poster.
    int? opUserId = posters.isNotEmpty && posters.first is Map
        ? (posters.first as Map)['user_id'] as int?
        : null;
    if (opUserId == null) {
      // Last-resort fallback for non-standard payloads: the English
      // description string.
      for (final p in posters.whereType<Map>()) {
        final desc = (p['description'] ?? '').toString();
        if (desc.contains('Original Poster')) {
          opUserId = p['user_id'] as int?;
          break;
        }
      }
    }
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
      // /latest.json's topic rows carry `category_id` but no category
      // NAME, and the response has no side-loaded category list to join
      // against. Left empty rather than synthesised ("Category 5").
      forumName: '',
      topicId: (t['id'] ?? '').toString(),
      topicTitle: (t['title'] ?? '').toString(),
      postAuthorName: (opUser?['username'] ?? '').toString(),
      postAuthorId: (opUserId ?? '').toString(),
      isClosed: (t['closed'] as bool?) ?? false,
      iconUrl: avatarUrl,
      // `created_at` is always present on a topic-list row; the epoch
      // fallback is a last resort that is obviously wrong on screen
      // rather than silently plausible (DateTime.now() made undated
      // topics sort and read as brand new).
      postTime: DateTime.tryParse(t['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
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
