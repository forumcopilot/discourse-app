import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_topic_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';
import 'package:forumcopilot_sdk/models/results/fc_topic_result.dart';

import '../base_discourse_proxy.dart';
import '../data/post/discourse_more_topics.dart';
import '../data/site/discourse_site_capabilities.dart';
import '../context/discourse_site_context_extension.dart';
import '../util/html_text.dart';
import '../data/topic/discourse_topic_slugs.dart';
import '../data/topic/discourse_topic_tracking.dart';
import '../util/discourse_link.dart';
import '../util/site_url.dart';

/// Discourse implementation of [IFCTopicProxy].
///
/// Topic-list endpoints used:
///   * `/latest.json`              — newest activity (default home tab)
///   * `/top.json`                 — top by recent period
///   * `/new.json`                 — new since last visit (auth required)
///   * `/unread.json`              — unread replies (auth required)
///   * `/c/{id}.json`              — topics in a category
///   * `/c/{id}/l/{filter}.json`   — filtered topic list within a category
///
/// All return `{ users: [], topic_list: { topics: [] } }`. We resolve a
/// topic's original poster by joining `topic.posters[].user_id` against the
/// parallel `users` array.
class DiscourseTopicProxy extends BaseDiscourseProxy implements IFCTopicProxy {
  DiscourseTopicProxy(SiteContext context) : super(context);

  static const int _perPage = 30;

  // Process-lifetime cache of category id → name, per forum (keyed by
  // `site.pluginUrl`, as [DiscourseSiteCapabilities] is): category ids are
  // the forum's own, so a host with several forums open (ABDA) must never
  // name forum B's rows from forum A's table. Warmed lazily on the first
  // topic-list call; a stale name is acceptable, categories rarely rename.
  static final Map<String, Map<int, String>> _catNamesBySite = {};
  static final Map<String, Future<Map<int, String>>> _catNamesLoading = {};

  /// Only for tests.
  @visibleForTesting
  static void clearCategoryNames() {
    _catNamesBySite.clear();
    _catNamesLoading.clear();
  }

  @override
  Future<FCLatestTopicResult> getLatestTopicAsync(
    int startNum,
    int lastNum, {
    String? searchId,
    List<String>? filters,
  }) async {
    try {
      final page = _pageOf(startNum);
      final list = await _listTopics('/latest.json', page: page);
      return FCLatestTopicResult(
        result: true,
        resultText: '',
        totalLatestNum: _totalFor(page, list),
        topics: list.topics,
      );
    } catch (e) {
      return FCLatestTopicResult(
        result: false,
        resultText: describeApiError(e),
        totalLatestNum: 0,
      );
    }
  }

  @override
  Future<FCLatestTopicResult> getNewTopicAsync(
    int startNum,
    int lastNum, {
    String? searchId,
    List<String>? filters,
  }) async {
    final path = siteContext.hasUserApiKey ? '/new.json' : '/latest.json';
    try {
      final page = _pageOf(startNum);
      final list = await _listTopics(path, page: page);
      return FCLatestTopicResult(
        result: true,
        resultText: '',
        totalLatestNum: _totalFor(page, list),
        topics: list.topics,
      );
    } catch (e) {
      return FCLatestTopicResult(
        result: false,
        resultText: describeApiError(e),
        totalLatestNum: 0,
      );
    }
  }

  @override
  Future<FCTopicDataResult> getTopicAsync(
      String forumId, int startNum, int lastNum) async {
    return _topicListInForum(forumId, startNum, filter: 'latest');
  }

  @override
  Future<FCTopicDataResult> getTopTopicAsync(
      String forumId, int startNum, int lastNum) async {
    return _topicListInForum(forumId, startNum, filter: 'top');
  }

  /// Discourse-only: a category's topic list under an arbitrary filter
  /// (`/c/{id}/l/{filter}.json` — latest, new, unread, top, hot).
  ///
  /// Not on [IFCTopicProxy]: the SDK's contract offers a category list and
  /// a category *top* list and nothing between, because XenForo has no
  /// equivalent of Discourse's per-category feeds. Web puts Latest / New /
  /// Hot tabs on every category page, so the app needs the general form.
  ///
  /// `new` and `unread` require a session and answer 403 without one;
  /// `hot` requires the forum to offer the route (`top_menu_items`).
  /// Callers should not offer a filter the viewer cannot use.
  Future<FCTopicDataResult> getCategoryTopicsAsync(
    String forumId,
    int startNum, {
    required String filter,
  }) =>
      _topicListInForum(forumId, startNum, filter: filter);

  /// Discourse-only: site-wide Top feed for a time [period] (`all` /
  /// `yearly` / `quarterly` / `monthly` / `weekly` / `daily`), 0-based
  /// [page].
  ///
  /// Always `/top.json?period=`: `/top/{period}.json` answers with a 301 to
  /// that URL and drops `page` on the way, so every page after the first
  /// was the first again; and `/top.json` with no period is not all-time
  /// but ListController.best_period_for the reader's last visit.
  ///
  /// Used by the Home tab's Top sub-segment (Phase 5.17c).
  Future<FCLatestTopicResult> getTopTopicsGlobalAsync({
    String period = 'all',
    int page = 0,
  }) async {
    try {
      final list = await _listTopics('/top.json',
          page: page, extraQuery: {'period': period});
      return FCLatestTopicResult(
        result: true,
        resultText: '',
        totalLatestNum: _totalFor(page, list),
        topics: list.topics,
      );
    } catch (e) {
      return FCLatestTopicResult(
        result: false,
        resultText: describeApiError(e),
        totalLatestNum: 0,
      );
    }
  }

  @override
  Future<FCTopicDataResult> getAnnTopicAsync(
      String forumId, int startNum, int lastNum) async {
    // Discourse doesn't expose announcements separately; surface
    // globally-pinned topics from /latest.json instead.
    try {
      final list = await _listTopics('/latest.json',
          page: _pageOf(startNum), filterPinnedGlobally: true);
      return FCTopicDataResult(
        result: true,
        resultText: '',
        forumId: forumId,
        forumName: '',
        canPost: false,
        canUpload: false,
        // Discourse reports no per-category unread breakdown by
        // pinned/announcement; these are "unknown", not "none".
        unreadStickyCount: 0,
        unreadAnnounceCount: 0,
        // Subscribing writes CategoryUser/TopicUser state — needs a session.
        canSubscribe: siteContext.isLoggedIn,
        isSubscribed: false,
        requirePrefix: false,
        prefixes: const [],
        // Page length, not a grand total: Discourse's `topic_list` block
        // exposes `per_page` and `more_topics_url` but never a count of
        // all matching topics.
        totalTopicNum: list.topics.length,
        topics: list.topics,
      );
    } catch (e) {
      return _emptyTopicData(
        forumId: forumId,
        message: describeApiError(e),
      );
    }
  }

  @override
  Future<FCUnreadTopicResult> getUnreadTopicAsync(
    int startNum,
    int lastNum, {
    String? searchId,
    List<String>? filters,
  }) async {
    final path = siteContext.hasUserApiKey ? '/unread.json' : '/latest.json';
    try {
      final page = _pageOf(startNum);
      final list = await _listTopics(path, page: page);
      return FCUnreadTopicResult(
        result: true,
        resultText: '',
        totalUnreadNum: _totalFor(page, list),
        topics: list.topics,
      );
    } catch (e) {
      return FCUnreadTopicResult(
        result: false,
        resultText: describeApiError(e),
        totalUnreadNum: 0,
      );
    }
  }

  @override
  Future<FCParticipatedTopicResult> getParticipatedTopicAsync(
    String username,
    int startNum,
    int lastNum, {
    String? searchId,
    String? userId,
  }) async {
    if (username.isEmpty) {
      return FCParticipatedTopicResult(
        result: false,
        resultText: 'username required',
        totalParticipatedNum: 0,
      );
    }
    try {
      final response = await apiGet('/user_actions.json', query: {
        'username': username,
        'filter': '4,5', // 4=new_topic, 5=reply
        'offset': startNum.toString(),
      });
      final actions = (response['user_actions'] as List?) ?? const [];
      final topics = <FCTopic>[];
      final seen = <String>{};
      for (final raw in actions.whereType<Map>()) {
        final m = raw.cast<String, dynamic>();
        final id = m['topic_id']?.toString() ?? '';
        if (id.isEmpty || !seen.add(id)) continue;
        topics.add(FCTopic(
          id: id,
          title: (m['title'] ?? '').toString(),
          forumId: (m['category_id'] ?? '').toString(),
          // /user_actions.json rows carry `category_id` but no category
          // NAME and no side-loaded category list. Left empty rather
          // than synthesised.
          forumName: '',
          authorId: (m['user_id'] ?? '').toString(),
          authorName: (m['username'] ?? '').toString(),
          timestamp: DateTime.tryParse(m['created_at']?.toString() ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
          shortContent: (m['excerpt'] as String?) ?? '',
        ));
      }
      return FCParticipatedTopicResult(
        result: true,
        resultText: '',
        totalParticipatedNum: topics.length,
        topics: topics,
      );
    } catch (e) {
      return FCParticipatedTopicResult(
        result: false,
        resultText: describeApiError(e),
        totalParticipatedNum: 0,
      );
    }
  }

  @override
  Future<FCMarkTopicReadResult> markTopicReadAsync(
      List<String> topicIds) async {
    // PUT /topics/bulk requires `topic_ids` (or filter=='unread') and an
    // operation type from TopicsBulkAction.operations — 'dismiss' is not
    // one (topics_controller#bulk / lib/topics_bulk_action.rb). Marking a
    // topic read == 'dismiss_posts' (sets last_read_post_number to the
    // topic's highest post, which also clears its "new" state).
    final ids = topicIds
        .map(int.tryParse)
        .whereType<int>()
        .toList(growable: false);
    if (ids.isEmpty) {
      return FCMarkTopicReadResult(result: true, resultText: '');
    }
    try {
      await apiPut('/topics/bulk', body: {
        'topic_ids': ids,
        'operation': {'type': 'dismiss_posts'},
      });
      return FCMarkTopicReadResult(result: true, resultText: '');
    } catch (e) {
      return FCMarkTopicReadResult(result: false, resultText: describeApiError(e));
    }
  }

  /// Discourse-only: loads the viewer's new and unread topics — the report
  /// web preloads on every page, GET /u/{username}/topic-tracking-state
  /// (UsersController#topic_tracking_state) — into
  /// [DiscourseTopicTracking], which the New and Unread counts come from.
  /// False when signed out or the request failed.
  Future<bool> loadTopicTrackingStateAsync() async {
    final username = siteContext.loginDataOutput?.user?.username;
    if (!siteContext.isLoggedIn || username == null || username.isEmpty) {
      return false;
    }
    try {
      final r = await apiGet(
          '/u/${Uri.encodeComponent(username)}/topic-tracking-state.json');
      // A bare JSON array, which apiGet wraps under `_value`.
      final rows = r['_value'];
      if (rows is! List) return false;
      DiscourseTopicTracking.forSite(siteContext).replaceReport([
        for (final row in rows.whereType<Map>()) row.cast<String, dynamic>(),
      ]);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Discourse-only: web's "Dismiss New" — PUT /topics/reset-new
  /// (TopicsController#reset_new). `dismiss_topics` names new topics under
  /// both the classic view and the experimental new-new view, where
  /// without it nothing is dismissed. A [categoryId] takes its
  /// subcategories, as web's category pages do; neither, and Discourse also
  /// moves the viewer's "new since" to now.
  Future<FCMarkTopicReadResult> dismissNewAsync(
      {int? categoryId, String? tagName}) async {
    try {
      final r = await apiPut('/topics/reset-new', body: {
        'dismiss_topics': true,
        ..._dismissScope(categoryId: categoryId, tagName: tagName),
      });
      DiscourseTopicTracking.forSite(siteContext)
          .applyDismissedNew(_topicIdsOf(r));
      return FCMarkTopicReadResult(result: true, resultText: '');
    } on DiscourseApiException catch (e) {
      return FCMarkTopicReadResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCMarkTopicReadResult(
          result: false, resultText: describeApiError(e));
    }
  }

  /// Discourse-only: web's "Dismiss all unread" — PUT /topics/bulk over
  /// the viewer's unread topics (`filter: unread`). Marks their new replies
  /// read (`dismiss_posts`), or, with [stopTracking] (the dialog's "Stop
  /// tracking these topics…"), sets them back to Normal instead, as web's
  /// BulkSelectHelper#dismissRead does, so they stop counting as unread.
  Future<FCMarkTopicReadResult> dismissUnreadAsync(
      {int? categoryId, String? tagName, bool stopTracking = false}) async {
    try {
      final r = await apiPut('/topics/bulk', body: {
        'filter': 'unread',
        'operation': stopTracking
            ? {'type': 'change_notification_level', 'notification_level_id': 1}
            : {'type': 'dismiss_posts'},
        ..._dismissScope(categoryId: categoryId, tagName: tagName),
      });
      final tracking = DiscourseTopicTracking.forSite(siteContext);
      final ids = _topicIdsOf(r);
      stopTracking
          ? tracking.applyUntracked(ids)
          : tracking.applyDismissedUnread(ids);
      return FCMarkTopicReadResult(result: true, resultText: '');
    } on DiscourseApiException catch (e) {
      return FCMarkTopicReadResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCMarkTopicReadResult(
          result: false, resultText: describeApiError(e));
    }
  }

  static Map<String, dynamic> _dismissScope(
          {int? categoryId, String? tagName}) =>
      {
        if (categoryId != null && categoryId > 0) ...{
          'category_id': categoryId,
          'include_subcategories': true,
        },
        if (tagName != null && tagName.isNotEmpty) 'tag_name': tagName,
      };

  /// The `topic_ids` both dismiss endpoints answer with.
  static List<String> _topicIdsOf(Map<String, dynamic> r) =>
      ((r['topic_ids'] as List?) ?? const []).map((e) => '$e').toList();

  @override
  Future<FCMarkTopicReadResult> markPostsReadAsync({
    required String topicId,
    required List<int> postNumbers,
    int msPerPost = 2000,
  }) async {
    // Guests have no server-side read state; succeed as a no-op so
    // callers can fire-and-forget without branching on login.
    if (!siteContext.isLoggedIn || postNumbers.isEmpty) {
      return FCMarkTopicReadResult(result: true, resultText: '');
    }
    final tid = int.tryParse(topicId);
    if (tid == null) {
      return FCMarkTopicReadResult(
          result: false, resultText: 'Invalid topic id');
    }
    try {
      // POST /topics/timings — Discourse's read-tracking beacon. The
      // web client sends one entry per post that scrolled into view;
      // we credit [msPerPost] to each post in the fetched chunk.
      // Rails parses the nested JSON map into the `timings` params
      // hash the controller expects.
      await apiPost('/topics/timings', body: {
        'topic_id': tid,
        'topic_time': msPerPost * postNumbers.length,
        'timings': {
          for (final n in postNumbers) '$n': msPerPost,
        },
      });
      return FCMarkTopicReadResult(result: true, resultText: '');
    } on DiscourseApiException catch (e) {
      return FCMarkTopicReadResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCMarkTopicReadResult(result: false, resultText: describeApiError(e));
    }
  }

  @override
  Future<FCTopicStatusResult> getTopicStatusAsync(
      List<String> topicIds) async {
    final statuses = <FCTopicStatus>[];
    for (final id in topicIds) {
      try {
        final t = await apiGet('/t/$id.json');
        statuses.add(FCTopicStatus(
          topicId: id,
          newPost: t['unseen'] == true,
          replyNumber: ((t['posts_count'] as int?) ?? 1) - 1,
          viewNumber: (t['views'] as int?) ?? 0,
          isClosed: (t['closed'] as bool?) ?? false,
          isSubscribed: (t['notification_level'] as int? ?? 1) >= 2,
          canSubscribe: siteContext.isLoggedIn,
          lastReplyTime:
              DateTime.tryParse(t['last_posted_at']?.toString() ?? ''),
          timestamp: t['created_at']?.toString(),
        ));
      } catch (_) {
        // skip individual failures
      }
    }
    return FCTopicStatusResult(
      result: true,
      resultText: '',
      topics: statuses,
    );
  }

  @override
  Future<FCTopicByIdsResult> getTopicByIds(List<String> topicIds) async {
    final topics = <FCTopic>[];
    for (final id in topicIds) {
      try {
        final t = await apiGet('/t/$id.json');
        topics.add(_topicFromTopicJson(t, users: const {}));
      } catch (_) {
        // skip
      }
    }
    return FCTopicByIdsResult(
      result: true,
      resultText: '',
      topics: topics,
    );
  }

  @override
  Future<FCNewTopicResult> newTopic(
    String forumId,
    String subject,
    String textBody, {
    String? prefixId,
    List<String>? attachmentIds,
    String? groupId,
    List<String>? tags,
  }) async {
    try {
      // Phase 5.19 — `attachmentIds` carries Discourse `upload://` short
      // URLs (not numeric IDs; the SDK param name is XF-flavoured but
      // we reinterpret it for Discourse). Append Markdown image/file
      // refs to the body before posting — otherwise the upload exists
      // server-side but the post has no reference to it and Discourse
      // garbage-collects the upload after 7 days.
      final rawWithAttachments =
          appendAttachmentMarkdown(textBody, attachmentIds);
      final body = <String, dynamic>{
        'title': subject,
        'raw': rawWithAttachments,
        'category': int.tryParse(forumId) ?? forumId,
        'archetype': 'regular',
      };
      // Discourse-native: in a JSON body Rails wants the plain `tags` key
      // with an array value ('tags[]' is form-encoding syntax only — in
      // JSON it would create a literal "tags[]" param the server ignores).
      if (tags != null && tags.isNotEmpty) {
        body['tags'] = tags;
      }
      final response = await apiPost('/posts.json', body: body);
      // Held for a moderator: Discourse answers {action: "enqueued",
      // pending_post} with no topic yet. State 1 is the SDK's "awaiting
      // moderation" (Tapatalk's convention), which the composer reports.
      final queued = response['action']?.toString() == 'enqueued';
      return FCNewTopicResult(
        result: true,
        resultText: '',
        topicId: queued ? '' : (response['topic_id'] ?? '').toString(),
        state: queued ? 1 : 0,
      );
    } on DiscourseApiException catch (e) {
      return FCNewTopicResult(
        result: false,
        resultText: e.userMessage,
        topicId: '',
        state: 0,
      );
    } catch (e) {
      return FCNewTopicResult(
        result: false,
        resultText: describeApiError(e),
        topicId: '',
        state: 0,
      );
    }
  }

  // Phase 5.35 — getAllTagsAsync / searchTagsAsync / getTopicsByTagAsync
  // moved to DiscourseTagProxy (IFCTagProxy). DiscourseTagProxy reuses
  // [listTopicsByPathAsync] below for the topics-by-tag query so the
  // topic-list parser doesn't have to be duplicated.

  /// Discourse-only public helper: fetch a topic-list-shaped endpoint
  /// (`/latest.json`, `/tag/{name}.json`, `/c/{id}.json`, …) and parse
  /// it into the SDK's [FCTopicDataResult]. Intended for use by other
  /// Discourse-specific proxies (e.g. [DiscourseTagProxy]) that need a
  /// topic listing but don't want to duplicate the user-resolution +
  /// category-name lookup logic.
  ///
  /// [forumName] is surfaced as the result's display label — pass
  /// `'#tagname'` for tag pages, the category name for categories, etc.
  Future<FCTopicDataResult> listTopicsByPathAsync({
    required String path,
    int page = 0,
    String forumName = '',
  }) async {
    try {
      final list = await _listTopics(path, page: page);
      return FCTopicDataResult(
        result: true,
        resultText: '',
        forumId: '',
        forumName: forumName,
        canPost: list.canPost,
        canUpload: list.canPost,
        // Discourse reports no per-category unread breakdown by
        // pinned/announcement; these are "unknown", not "none".
        unreadStickyCount: 0,
        unreadAnnounceCount: 0,
        // Subscribing writes CategoryUser/TopicUser state — needs a session.
        canSubscribe: siteContext.isLoggedIn,
        isSubscribed: false,
        requirePrefix: false,
        prefixes: const [],
        // Page length, not a grand total: Discourse's `topic_list` block
        // exposes `per_page` and `more_topics_url` but never a count of
        // all matching topics.
        totalTopicNum: list.topics.length,
        topics: list.topics,
      );
    } on DiscourseApiException catch (e) {
      return _emptyTopicData(forumId: '', message: e.userMessage);
    } catch (e) {
      return _emptyTopicData(forumId: '', message: describeApiError(e));
    }
  }

  // ===== Helpers =====

  Future<FCTopicDataResult> _topicListInForum(
    String forumId,
    int startNum, {
    required String filter,
  }) async {
    if (forumId.isEmpty) {
      return _emptyTopicData(
          forumId: forumId, message: 'forumId required');
    }
    try {
      final page = _pageOf(startNum);
      final list = await _listTopics(
        '/c/$forumId/l/$filter.json',
        page: page,
      );
      final catId = int.tryParse(forumId);
      final forumName = catId == null
          ? ''
          : (_catNamesBySite[siteContext.site.pluginUrl]?[catId] ?? '');
      return FCTopicDataResult(
        result: true,
        resultText: '',
        forumId: forumId,
        forumName: forumName,
        canPost: list.canPost,
        canUpload: list.canPost,
        // Discourse reports no per-category unread breakdown by
        // pinned/announcement; these are "unknown", not "none".
        unreadStickyCount: 0,
        unreadAnnounceCount: 0,
        // Subscribing writes CategoryUser/TopicUser state — needs a session.
        canSubscribe: siteContext.isLoggedIn,
        isSubscribed: false,
        requirePrefix: false,
        prefixes: const [],
        totalTopicNum: _totalFor(page, list),
        topics: list.topics,
      );
    } catch (e) {
      return _emptyTopicData(forumId: forumId, message: describeApiError(e));
    }
  }

  Future<_TopicListResponse> _listTopics(
    String path, {
    int page = 0,
    bool filterPinnedGlobally = false,
    Map<String, String> extraQuery = const {},
  }) async {
    final responseFuture = apiGet(path, query: {
      ...extraQuery,
      if (page > 0) 'page': page.toString(),
    });
    final catNamesFuture = _loadCategoryNames();
    final response = await responseFuture;
    final catNames = await catNamesFuture;

    final users = <int, Map<String, dynamic>>{};
    for (final u
        in ((response['users'] as List?) ?? const []).whereType<Map>()) {
      final id = u['id'];
      if (id is int) users[id] = u.cast<String, dynamic>();
    }
    final list =
        (response['topic_list'] as Map<String, dynamic>?) ?? const {};
    final topics = <FCTopic>[];
    for (final raw
        in ((list['topics'] as List?) ?? const []).whereType<Map>()) {
      final m = raw.cast<String, dynamic>();
      if (filterPinnedGlobally && m['pinned_globally'] != true) continue;
      topics.add(_topicFromTopicJson(m, users: users, catNames: catNames));
    }
    return _TopicListResponse(
      topics: topics,
      canPost: (list['can_create_topic'] as bool?) ?? false,
      // Topic lists carry no total count; `more_topics_url` is the server's
      // only has-more signal.
      hasMore: list['more_topics_url'] != null,
    );
  }

  /// Total to report for a windowed list page. Discourse never sends a real
  /// total, so callers get "items before this page + this page + 1 sentinel
  /// when more pages exist" — enough for `loadedCount < total` has-more
  /// checks without ever claiming a count the server didn't back.
  int _totalFor(int page, _TopicListResponse list) =>
      page * _perPage + list.topics.length + (list.hasMore ? 1 : 0);

  /// Warm-once cache of category id → name. Resolves [FCTopic.forumName]
  /// on topic listings without paying for /categories.json on every call.
  Future<Map<int, String>> _loadCategoryNames() async {
    final site = siteContext.site.pluginUrl;
    final cached = _catNamesBySite[site];
    if (cached != null) return cached;
    final loading = _catNamesLoading[site];
    if (loading != null) return loading;
    // /site.json first: the app already fetches it once per forum for
    // capabilities, and it carries every category including subcategories.
    // /categories.json does not — meta.discourse.org returns 12 of its 45
    // there and ignores include_subcategories entirely, so the topic list
    // could not name the category of most of its own rows and the badge
    // silently vanished from nearly every row.
    final fromSite = DiscourseSiteCapabilities.forSite(site).categories;
    if (fromSite.isNotEmpty) {
      final m = <int, String>{};
      for (final c in fromSite) {
        final id = c['id'];
        final name = c['name']?.toString();
        if (id is int && name != null && name.isNotEmpty) m[id] = name;
      }
      if (m.isNotEmpty) {
        _catNamesBySite[site] = m;
        return m;
      }
    }
    final completer = Completer<Map<int, String>>();
    _catNamesLoading[site] = completer.future;
    try {
      // include_subcategories=true: without it /categories.json omits
      // subcategories, leaving their names unresolvable (blank labels).
      final response = await apiGet('/categories.json',
          query: {'include_subcategories': 'true'});
      final list = (response['category_list'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      final cats = (list['categories'] as List?) ?? const [];
      final m = <int, String>{};
      for (final c in cats.whereType<Map<String, dynamic>>()) {
        final id = c['id'];
        final name = c['name']?.toString();
        if (id is int && name != null && name.isNotEmpty) m[id] = name;
      }
      _catNamesBySite[site] = m;
      completer.complete(m);
      return m;
    } catch (_) {
      _catNamesBySite[site] = const {};
      completer.complete(const {});
      return const {};
    } finally {
      _catNamesLoading.remove(site);
    }
  }

  /// Build an [FCTopic] from a Discourse topic object — works for the
  /// Discourse-native **Hot** list (`/hot.json`).
  ///
  /// Not on [IFCTopicProxy]: the SDK's XenForo-shaped contract has no
  /// "hot" concept, and coercing it into Top would lose the distinction —
  /// Top ranks by a period's likes, Hot is Discourse's own recency-weighted
  /// activity heuristic, and a forum can offer either, both, or neither
  /// (`top_menu_items` on /site.json says which).
  ///
  /// Callers should check `DiscourseSiteCapabilities.offersRoute(url,
  /// 'hot')` first; a forum without the route answers 404 here.
  Future<FCLatestTopicResult> getHotTopicsAsync(int startNum) async {
    try {
      final page = _pageOf(startNum);
      final list = await _listTopics('/hot.json', page: page);
      return FCLatestTopicResult(
        result: true,
        resultText: '',
        totalLatestNum: _totalFor(page, list),
        topics: list.topics,
      );
    } catch (e) {
      return FCLatestTopicResult(
        result: false,
        resultText: describeApiError(e),
        totalLatestNum: 0,
        topics: const [],
      );
    }
  }

  /// What to read after topic [topicId]: its suggested and related topics,
  /// as rows like any topic list's (category, tags, last poster, counts,
  /// unread state).
  ///
  /// Read from the topic load that opened it (see [DiscourseMoreTopics]);
  /// fetched only when this session has not loaded the topic. Never
  /// throws: a failure is an empty footer, not an error on a page the
  /// reader has finished.
  Future<DiscourseMoreTopics> getMoreTopicsAsync(String topicId) async {
    if (topicId.isEmpty) return const DiscourseMoreTopics();
    final forumUrl = siteContext.site.url;
    try {
      var raw = DiscourseMoreTopics.rawFor(forumUrl, topicId);
      if (raw == null) {
        DiscourseMoreTopics.storeFrom(
            forumUrl, topicId, await apiGet('/t/$topicId.json'));
        raw = DiscourseMoreTopics.rawFor(forumUrl, topicId);
      }
      if (raw == null) return const DiscourseMoreTopics();
      final catNames = await _loadCategoryNames();
      return DiscourseMoreTopics(
        suggested: _topicViewListTopics(raw.suggested, catNames),
        related: _topicViewListTopics(raw.related, catNames),
      );
    } catch (_) {
      return const DiscourseMoreTopics();
    }
  }

  /// A topic view's embedded topic list (`suggested_topics`,
  /// `related_topics`) as rows.
  ///
  /// Those embed each poster's user (`SuggestedPosterSerializer`: `{extras,
  /// description, user: {...}}`) where a topic list ships `user_id` plus a
  /// `users[]` table, so each is put in the list's shape and mapped by
  /// [_topicFromTopicJson] — a suggested topic then reads exactly as it does
  /// in Latest. Reading `user_id` off these posters found nobody, and every
  /// suggestion was drawn with a placeholder instead of a face.
  List<FCTopic> _topicViewListTopics(
      List<Map<String, dynamic>> topics, Map<int, String> catNames) {
    final out = <FCTopic>[];
    for (final t in topics) {
      final users = <int, Map<String, dynamic>>{};
      final posters = <Map<String, dynamic>>[];
      for (final p in ((t['posters'] as List?) ?? const []).whereType<Map>()) {
        final poster = p.cast<String, dynamic>();
        final user = poster['user'];
        final id = user is Map ? user['id'] : poster['user_id'];
        if (user is Map && id is int) users[id] = user.cast<String, dynamic>();
        posters.add({...poster, 'user_id': id});
      }
      try {
        out.add(_topicFromTopicJson({...t, 'posters': posters},
            users: users, catNames: catNames));
      } catch (_) {
        // One malformed entry should not empty the whole footer.
      }
    }
    return out;
  }

  /// Absolute avatar URL from a Discourse `avatar_template`.
  ///
  /// Templates carry a literal `{size}` placeholder and are usually
  /// site-relative (`/user_avatar/.../{size}/12_2.png`), so they are not
  /// loadable until both are resolved.
  String? _avatarUrlFrom(Object? avatarTemplate) {
    final template = avatarTemplate as String?;
    if (template == null || template.isEmpty) return null;
    final filled = template.replaceAll('{size}', '120');
    return absoluteSiteUrl(siteContext.site.url, filled);
  }

  /// summary form returned in /latest.json (and friends) and for the fuller
  /// form returned by /t/{id}.json.
  FCTopic _topicFromTopicJson(
    Map<String, dynamic> t, {
    Map<int, Map<String, dynamic>> users = const {},
    Map<int, String> catNames = const {},
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

    // /t/{id}.json inlines details.created_by as the canonical author.
    final details = t['details'] as Map<String, dynamic>?;
    final createdBy = details?['created_by'] as Map<String, dynamic>?;
    final authorMap = opUser ?? createdBy;
    final authorId = (authorMap?['id'] ?? opUserId ?? '').toString();
    final authorName = (authorMap?['username'] ?? '').toString();
    final authorIconUrl = _avatarUrlFrom(authorMap?['avatar_template']);

    // Last poster — the "X replied 2 hours ago" half of a web topic row.
    //
    // Same contract as the OP lookup above, read from the other end: the
    // latest poster is marked with `extras` ('latest', or 'latest single'
    // when they are the only poster). `extras` is the structured marker;
    // `description` is localized, so matching that would work in English
    // and quietly fail on every other locale.
    Map<String, dynamic>? latestPoster;
    for (final p in posters.whereType<Map>()) {
      if ((p['extras'] ?? '').toString().contains('latest')) {
        latestPoster = users[p['user_id'] as int?];
        break;
      }
    }
    // Only meaningful once someone has actually replied. On a topic with a
    // single post the latest poster IS the author, and "X replied" would
    // be a false statement about the opening post — leave it null so the
    // UI falls back to the topic's own author and timestamp.
    final hasReplies = ((t['posts_count'] as int?) ?? 1) > 1;
    final lastPosterName =
        hasReplies ? (latestPoster?['username'] as String?) : null;

    final id = (t['id'] ?? '').toString();
    final slug = t['slug']?.toString();
    DiscourseTopicSlugs.store(siteContext.site.url, id, slug);
    // How far the viewer has read it, for the row (see
    // DiscourseTopicTracking); a guest's payload carries none.
    if (siteContext.isLoggedIn) {
      DiscourseTopicTracking.forSite(siteContext).recordTopicJson(t);
    }
    final categoryIdInt = t['category_id'] as int?;
    final categoryId = (t['category_id'] ?? '').toString();
    final participatedUserIds = posters
        .whereType<Map>()
        .map((p) => p['user_id']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList(growable: false);

    return FCTopic(
      id: id,
      title: (t['title'] ?? '').toString(),
      forumId: categoryId,
      forumName: categoryIdInt == null ? '' : (catNames[categoryIdInt] ?? ''),
      authorId: authorId,
      authorName: authorName,
      authorIconUrl: authorIconUrl,
      timestamp:
          DateTime.tryParse(t['created_at']?.toString() ?? '') ?? DateTime.now(),
      // Discourse's `reply_count` is "cross-thread replies" (not what we
      // want). Total replies in the topic is `posts_count - 1`.
      replyCount: (((t['posts_count'] as int?) ?? 1) - 1).clamp(0, 1 << 30),
      viewCount: (t['views'] as int?) ?? 0,
      hasNewPosts: t['unseen'] == true || (t['unread_posts'] as int? ?? 0) > 0,
      // Phase 5.47 — surface the actual unread count (drives the
      // "N new" chip on topic rows). `new_posts` covers older
      // serializer variants.
      unreadCount:
          (t['unread_posts'] as int?) ?? (t['new_posts'] as int?) ?? 0,
      isClosed: (t['closed'] as bool?) ?? false,
      isSubscribed: (t['notification_level'] as int? ?? 1) >= 2,
      canSubscribe: true,
      url: DiscourseLink.webUrl(siteContext.site.url, topicId: id, slug: slug),
      // Some inherited UI does `topic.shortContent!.isNotEmpty` (XF assumed
      // non-null); keep this string non-null so we don't trip the null check.
      // Excerpts are entity-encoded ("&hellip;", "&amp;") — flatten
      // before they reach a Text widget (Phase 5.47).
      shortContent: stripHtmlToText((t['excerpt'] as String?) ?? ''),
      participatedUserIds: participatedUserIds,
      isPinned: (t['pinned'] as bool?) ?? false,
      isAnnouncement: (t['pinned_globally'] as bool?) ?? false,
      canReply: !(t['closed'] == true || t['archived'] == true),
      // Optimistic: any signed-in user can flag/like a topic's first
      // post on a stock Discourse. Topic-list rows carry no
      // `actions_summary`, so there is no per-row signal to read — the
      // server is the real gate and will 403 if it disagrees.
      canReport: true,
      canLike: true,
      isLiked: (t['liked'] as bool?) ?? false,
      likeCount: (t['like_count'] as int?) ?? 0,
      hasPoll: false,
      // Discourse returns tags as either:
      //   ["foo","bar"]                          (older endpoints)
      //   [{id,name,slug}, ...]                  (post tag-system upgrade)
      // Accept both shapes.
      tags: ((t['tags'] as List?) ?? const [])
          .map<String>((entry) {
            if (entry is String) return entry;
            if (entry is Map) return (entry['name'] ?? '').toString();
            return '';
          })
          .where((s) => s.isNotEmpty)
          .toList(growable: false),
      isSolved: (t['has_accepted_answer'] as bool?) ?? false,
      // Discourse's own trending heuristic, not anything derivable from
      // the counts on this row.
      isHot: (t['is_hot'] as bool?) ?? false,
      // discourse-topic-voting. Absent on forums without the plugin, and
      // on categories where it is off, so all three default to "no voting"
      // rather than to zero-votes-but-votable.
      voteCount: (t['vote_count'] as int?) ?? 0,
      canVote: t['can_vote'] == true,
      userVoted: t['user_voted'] == true,
      // The server's count, not participatedUserIds.length — the posters
      // summary is capped, so the list under-reports on busy topics.
      participantCount: (t['participant_count'] as int?) ?? 0,
      // Faces for the row's participant cluster, in posters order. The
      // topic-list payload ships `users[]` alongside `posters[]`, so this
      // costs no extra request; entries the payload does not name are
      // dropped rather than padded with a placeholder.
      participantIconUrls: posters
          .whereType<Map>()
          .map((p) => _avatarUrlFrom(users[p['user_id'] as int?]?['avatar_template']))
          .whereType<String>()
          .toList(growable: false),
      linkCount: ((t['details'] as Map<String, dynamic>?)?['links'] as List?)
              ?.length ??
          0,
      lastPosterName: lastPosterName,
      // Avatar and time only make sense alongside the name; without it the
      // row has nothing to attribute them to.
      lastPosterIconUrl: lastPosterName == null
          ? null
          : _avatarUrlFrom(latestPoster?['avatar_template']),
      // `last_posted_at` is when the newest post landed. `bumped_at` is
      // not a substitute — a topic bumps on edits and moves too, so it
      // would date a reply that never happened.
      lastPostedAt: lastPosterName == null
          ? null
          : DateTime.tryParse(t['last_posted_at']?.toString() ?? ''),
    );
  }

  FCTopicDataResult _emptyTopicData({
    required String forumId,
    required String message,
  }) {
    return FCTopicDataResult(
      result: false,
      resultText: message,
      forumId: forumId,
      forumName: '',
      canPost: false,
      canUpload: false,
      unreadStickyCount: 0,
      unreadAnnounceCount: 0,
      canSubscribe: true,
      isSubscribed: false,
      requirePrefix: false,
      prefixes: const [],
      totalTopicNum: 0,
    );
  }

  int _pageOf(int startNum) =>
      startNum <= 0 ? 0 : (startNum / _perPage).floor();
}

class _TopicListResponse {
  final List<FCTopic> topics;
  final bool canPost;
  final bool hasMore;
  const _TopicListResponse(
      {required this.topics, required this.canPost, this.hasMore = false});
}
