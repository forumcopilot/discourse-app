import 'dart:async';

import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_topic_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';
import 'package:forumcopilot_sdk/models/results/fc_topic_result.dart';

import '../base_discourse_proxy.dart';
import '../context/discourse_site_context_extension.dart';
import '../data/tag/discourse_tag.dart';

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

  // Process-lifetime cache of category id → name. /categories.json is the
  // only place to resolve `forumName`, so we warm this lazily on the first
  // topic-list call. A stale cache is acceptable for v1 — categories rarely
  // rename. Phase 2.x: invalidate on logout / forum switch.
  static Map<int, String>? _catNamesById;
  static Future<Map<int, String>>? _catNamesLoading;

  @override
  Future<FCLatestTopicResult> getLatestTopicAsync(
    int startNum,
    int lastNum, {
    String? searchId,
    List<String>? filters,
  }) async {
    try {
      final list = await _listTopics('/latest.json', page: _pageOf(startNum));
      return FCLatestTopicResult(
        result: true,
        resultText: '',
        totalLatestNum: list.topics.length,
        topics: list.topics,
      );
    } catch (e) {
      return FCLatestTopicResult(
        result: false,
        resultText: 'Error: $e',
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
      final list = await _listTopics(path, page: _pageOf(startNum));
      return FCLatestTopicResult(
        result: true,
        resultText: '',
        totalLatestNum: list.topics.length,
        topics: list.topics,
      );
    } catch (e) {
      return FCLatestTopicResult(
        result: false,
        resultText: 'Error: $e',
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

  /// Discourse-only: site-wide Top feed, optionally scoped to a time
  /// [period]. Maps to `/top.json` (all-time) or `/top/{period}.json`
  /// (`all` / `yearly` / `quarterly` / `monthly` / `weekly` / `daily`).
  ///
  /// Used by the Home tab's Top sub-segment (Phase 5.17c).
  Future<FCLatestTopicResult> getTopTopicsGlobalAsync({
    String period = 'all',
    int page = 0,
  }) async {
    final path = period == 'all'
        ? '/top.json'
        : '/top/${Uri.encodeComponent(period)}.json';
    try {
      final list = await _listTopics(path, page: page);
      return FCLatestTopicResult(
        result: true,
        resultText: '',
        totalLatestNum: list.topics.length,
        topics: list.topics,
      );
    } catch (e) {
      return FCLatestTopicResult(
        result: false,
        resultText: 'Error: $e',
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
        unreadStickyCount: 0,
        unreadAnnounceCount: 0,
        canSubscribe: true,
        isSubscribed: false,
        requirePrefix: false,
        prefixes: const [],
        totalTopicNum: list.topics.length,
        topics: list.topics,
      );
    } catch (e) {
      return _emptyTopicData(
        forumId: forumId,
        message: 'Error: $e',
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
      final list = await _listTopics(path, page: _pageOf(startNum));
      return FCUnreadTopicResult(
        result: true,
        resultText: '',
        totalUnreadNum: list.topics.length,
        topics: list.topics,
      );
    } catch (e) {
      return FCUnreadTopicResult(
        result: false,
        resultText: 'Error: $e',
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
          forumName: '',
          authorId: (m['user_id'] ?? '').toString(),
          authorName: (m['username'] ?? '').toString(),
          timestamp: DateTime.tryParse(m['created_at']?.toString() ?? '') ??
              DateTime.now(),
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
        resultText: 'Error: $e',
        totalParticipatedNum: 0,
      );
    }
  }

  @override
  Future<FCMarkTopicReadResult> markTopicReadAsync(
      List<String> topicIds) async {
    try {
      await apiPut('/topics/bulk', body: {
        'filter': 'new',
        'operation': {'type': 'dismiss'},
      });
      return FCMarkTopicReadResult(result: true, resultText: '');
    } catch (e) {
      return FCMarkTopicReadResult(result: false, resultText: 'Error: $e');
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
          canSubscribe: true,
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
      // Discourse-native: pass tags as `tags[]`. Dio handles the array
      // encoding correctly when given a List value.
      if (tags != null && tags.isNotEmpty) {
        body['tags[]'] = tags;
      }
      final response = await apiPost('/posts.json', body: body);
      return FCNewTopicResult(
        result: true,
        resultText: '',
        topicId: (response['topic_id'] ?? '').toString(),
        state: 0,
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
        resultText: 'Error: $e',
        topicId: '',
        state: 0,
      );
    }
  }

  /// Discourse-only: full tag listing. Hits `/tags.json` and returns
  /// every tag the current user can see, with topic counts. Powers the
  /// global Tags tab on the home screen.
  ///
  /// [includePmOnly] defaults to false — PM-only tags are admin-set
  /// allowlists for private messages and don't belong on the public
  /// tags browser.
  Future<List<DiscourseTag>> getAllTagsAsync({bool includePmOnly = false}) async {
    try {
      final response = await apiGet('/tags.json');
      final list = (response['tags'] as List?) ?? const [];
      final tags = list
          .whereType<Map>()
          .map((t) => DiscourseTag.fromJson(t.cast<String, dynamic>()))
          .where((t) => includePmOnly || !t.pmOnly)
          .toList();
      // Sort by topic count desc, then alphabetical for ties — matches
      // the Discourse web /tags page.
      tags.sort((a, b) {
        final byCount = b.count.compareTo(a.count);
        if (byCount != 0) return byCount;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      return tags;
    } catch (_) {
      return const [];
    }
  }

  /// Discourse-only: autocomplete tag names. Hits
  /// `/tags/filter/search.json?q={prefix}&limit={N}` and returns the
  /// matching tag names. Used by the tag-input field in the composer.
  Future<List<String>> searchTagsAsync(String query, {int limit = 10}) async {
    if (query.trim().isEmpty) return const [];
    try {
      final response = await apiGet('/tags/filter/search.json', query: {
        'q': query.trim(),
        'limit': limit.toString(),
      });
      final results = (response['results'] as List?) ?? const [];
      return results
          .whereType<Map>()
          .map((r) => r['name']?.toString() ?? '')
          .where((n) => n.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  /// Discourse-only: list topics filtered by [tagName]. Hits
  /// `/tag/{tagName}.json` (paginated). Used by the tag-chip → tag-page
  /// navigation in the topic list. Not exposed on IFCTopicProxy because
  /// XF-shaped forums don't have a tag concept.
  Future<FCTopicDataResult> getTopicsByTagAsync(
    String tagName, {
    int page = 0,
  }) async {
    if (tagName.isEmpty) {
      return _emptyTopicData(forumId: '', message: 'tag required');
    }
    try {
      final list = await _listTopics(
        '/tag/${Uri.encodeComponent(tagName)}.json',
        page: page,
      );
      return FCTopicDataResult(
        result: true,
        resultText: '',
        forumId: '',
        forumName: '#$tagName',
        canPost: list.canPost,
        canUpload: list.canPost,
        unreadStickyCount: 0,
        unreadAnnounceCount: 0,
        canSubscribe: true,
        isSubscribed: false,
        requirePrefix: false,
        prefixes: const [],
        totalTopicNum: list.topics.length,
        topics: list.topics,
      );
    } on DiscourseApiException catch (e) {
      return _emptyTopicData(forumId: '', message: e.userMessage);
    } catch (e) {
      return _emptyTopicData(forumId: '', message: 'Error: $e');
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
      final list = await _listTopics(
        '/c/$forumId/l/$filter.json',
        page: _pageOf(startNum),
      );
      final catId = int.tryParse(forumId);
      final forumName =
          catId == null ? '' : (_catNamesById?[catId] ?? '');
      return FCTopicDataResult(
        result: true,
        resultText: '',
        forumId: forumId,
        forumName: forumName,
        canPost: list.canPost,
        canUpload: list.canPost,
        unreadStickyCount: 0,
        unreadAnnounceCount: 0,
        canSubscribe: true,
        isSubscribed: false,
        requirePrefix: false,
        prefixes: const [],
        totalTopicNum: list.topics.length,
        topics: list.topics,
      );
    } catch (e) {
      return _emptyTopicData(forumId: forumId, message: 'Error: $e');
    }
  }

  Future<_TopicListResponse> _listTopics(
    String path, {
    int page = 0,
    bool filterPinnedGlobally = false,
  }) async {
    final responseFuture = apiGet(path, query: {
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
    );
  }

  /// Warm-once cache of category id → name. Resolves [FCTopic.forumName]
  /// on topic listings without paying for /categories.json on every call.
  Future<Map<int, String>> _loadCategoryNames() async {
    if (_catNamesById != null) return _catNamesById!;
    if (_catNamesLoading != null) return _catNamesLoading!;
    final completer = Completer<Map<int, String>>();
    _catNamesLoading = completer.future;
    try {
      final response = await apiGet('/categories.json');
      final list = (response['category_list'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      final cats = (list['categories'] as List?) ?? const [];
      final m = <int, String>{};
      for (final c in cats.whereType<Map<String, dynamic>>()) {
        final id = c['id'];
        final name = c['name']?.toString();
        if (id is int && name != null && name.isNotEmpty) m[id] = name;
      }
      _catNamesById = m;
      completer.complete(m);
      return m;
    } catch (_) {
      _catNamesById = const {};
      completer.complete(const {});
      return const {};
    } finally {
      _catNamesLoading = null;
    }
  }

  /// Build an [FCTopic] from a Discourse topic object — works for the
  /// summary form returned in /latest.json (and friends) and for the fuller
  /// form returned by /t/{id}.json.
  FCTopic _topicFromTopicJson(
    Map<String, dynamic> t, {
    Map<int, Map<String, dynamic>> users = const {},
    Map<int, String> catNames = const {},
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

    // /t/{id}.json inlines details.created_by as the canonical author.
    final details = t['details'] as Map<String, dynamic>?;
    final createdBy = details?['created_by'] as Map<String, dynamic>?;
    final authorMap = opUser ?? createdBy;
    final authorId = (authorMap?['id'] ?? opUserId ?? '').toString();
    final authorName = (authorMap?['username'] ?? '').toString();
    final avatarTemplate = authorMap?['avatar_template'] as String?;
    String? authorIconUrl;
    if (avatarTemplate != null && avatarTemplate.isNotEmpty) {
      final filled = avatarTemplate.replaceAll('{size}', '120');
      authorIconUrl = filled.startsWith('http')
          ? filled
          : '${siteContext.site.url}$filled';
    }

    final id = (t['id'] ?? '').toString();
    final slug = t['slug']?.toString();
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
      isClosed: (t['closed'] as bool?) ?? false,
      isSubscribed: (t['notification_level'] as int? ?? 1) >= 2,
      canSubscribe: true,
      url: slug != null && slug.isNotEmpty
          ? '${siteContext.site.url}/t/$slug/$id'
          : '${siteContext.site.url}/t/$id',
      // Some inherited UI does `topic.shortContent!.isNotEmpty` (XF assumed
      // non-null); keep this string non-null so we don't trip the null check.
      shortContent: (t['excerpt'] as String?) ?? '',
      participatedUserIds: participatedUserIds,
      isPinned: (t['pinned'] as bool?) ?? false,
      isAnnouncement: (t['pinned_globally'] as bool?) ?? false,
      canReply: !(t['closed'] == true || t['archived'] == true),
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
  const _TopicListResponse({required this.topics, required this.canPost});
}
