import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_search_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_attachment.dart';
import 'package:forumcopilot_sdk/models/entities/fc_like.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post.dart';
import 'package:forumcopilot_sdk/models/entities/fc_thanks.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';
import 'package:forumcopilot_sdk/models/results/fc_search_result.dart';
import 'package:forumcopilot_sdk/models/search/fc_search_filters.dart';

import '../base_discourse_proxy.dart';

/// Discourse implementation of [IFCSearchProxy].
///
/// Endpoints:
///   * GET `/search.json?q=...&page=N` — full-text search across topics + posts.
///
/// `/search.json` returns `{ posts: [], topics: [], users: [], categories: [],
/// tags: [], groups: [] }`. We extract topics and posts; the search-topic
/// endpoint and search-post endpoint share this single Discourse call.
///
/// Discourse exposes a rich query DSL (operators concatenated into `q`):
///   - `@username`           — by author
///   - `#category-slug`      — in category
///   - `tag:foo`             — by tag
///   - `topic:123`           — within topic
///   - `before:2026-01-01`   — date range
///   - `in:title`            — title only
///
/// We translate the SDK's advanced-search params into this DSL.
class DiscourseSearchProxy extends BaseDiscourseProxy
    implements IFCSearchProxy {
  DiscourseSearchProxy(SiteContext context) : super(context);

  static const int _defaultPerPage = 20;

  @override
  Future<FCSearchTopicResult> searchTopicAsync(
    String searchString,
    int startNum,
    int lastNum,
    String? searchId,
  ) async {
    if (searchString.trim().length < 2) {
      return FCSearchTopicResult(
        result: false,
        resultText: 'Search query too short',
        totalTopicNum: 0,
        topics: const [],
      );
    }
    try {
      final response = await _searchRaw(searchString,
          page: _pageOf(startNum), perPage: _spanFromIndices(startNum, lastNum));
      final users = _usersById(response);
      final topics = ((response['topics'] as List?) ?? const [])
          .whereType<Map>()
          .map((t) =>
              _topicFromSearchResult(t.cast<String, dynamic>(), users: users))
          .toList();
      return FCSearchTopicResult(
        result: true,
        resultText: '',
        totalTopicNum:
            (response['grouped_search_result']?['type_filter'] as String?) ==
                    'topic'
                ? topics.length
                : topics.length,
        searchId: null,
        topics: topics,
      );
    } catch (e) {
      return FCSearchTopicResult(
        result: false,
        resultText: 'Error: $e',
        totalTopicNum: 0,
        topics: const [],
      );
    }
  }

  @override
  Future<FCSearchPostResult> searchPostAsync(
    String searchString,
    int startNum,
    int lastNum,
    String? searchId,
  ) async {
    if (searchString.trim().length < 2) {
      return FCSearchPostResult(
        result: false,
        resultText: 'Search query too short',
        totalPostNum: 0,
        posts: const [],
      );
    }
    try {
      final response = await _searchRaw(searchString,
          page: _pageOf(startNum), perPage: _spanFromIndices(startNum, lastNum));
      final posts = ((response['posts'] as List?) ?? const [])
          .whereType<Map>()
          .map((p) => _postFromSearchResult(p.cast<String, dynamic>()))
          .toList();
      return FCSearchPostResult(
        result: true,
        resultText: '',
        totalPostNum: posts.length,
        searchId: null,
        posts: posts,
      );
    } catch (e) {
      return FCSearchPostResult(
        result: false,
        resultText: 'Error: $e',
        totalPostNum: 0,
        posts: const [],
      );
    }
  }

  @override
  Future<FCSearchDataResultTopic> advanceSearchTopicAsync(
    String keywords,
    int page,
    int perpage,
    String? searchId,
    bool titleOnly,
    String? userId,
    String? searchUser,
    String? forumId,
    String? topicId,
    List<String>? onlyIn,
    List<String>? notIn,
    bool startedBy,
    int? searchTime,
  ) async {
    try {
      final q = _buildAdvancedQuery(
        keywords: keywords,
        titleOnly: titleOnly,
        searchUser: searchUser,
        forumId: forumId,
        topicId: topicId,
        onlyIn: onlyIn,
        notIn: notIn,
        startedBy: startedBy,
        searchTimeSeconds: searchTime,
      );
      final response =
          await _searchRaw(q, page: page <= 0 ? 0 : page, perPage: perpage);
      final users = _usersById(response);
      final topics = ((response['topics'] as List?) ?? const [])
          .whereType<Map>()
          .map((t) =>
              _topicFromSearchResult(t.cast<String, dynamic>(), users: users))
          .toList();
      return FCSearchDataResultTopic(
        result: true,
        resultText: '',
        totalTopicNum: topics.length,
        topics: topics,
      );
    } catch (e) {
      return FCSearchDataResultTopic(
        result: false,
        resultText: 'Error: $e',
        totalTopicNum: 0,
        topics: const [],
      );
    }
  }

  @override
  Future<FCSearchDataResultPost> advanceSearchPostAsync(
    String keywords,
    int page,
    int perpage,
    String? searchId,
    bool titleOnly,
    String? userId,
    String? searchUser,
    String? forumId,
    String? topicId,
    List<String>? onlyIn,
    List<String>? notIn,
    bool startedBy,
  ) async {
    try {
      final q = _buildAdvancedQuery(
        keywords: keywords,
        titleOnly: titleOnly,
        searchUser: searchUser,
        forumId: forumId,
        topicId: topicId,
        onlyIn: onlyIn,
        notIn: notIn,
        startedBy: startedBy,
      );
      final response =
          await _searchRaw(q, page: page <= 0 ? 0 : page, perPage: perpage);
      final posts = ((response['posts'] as List?) ?? const [])
          .whereType<Map>()
          .map((p) => _postFromSearchResult(p.cast<String, dynamic>()))
          .toList();
      return FCSearchDataResultPost(
        result: true,
        resultText: '',
        totalPostNum: posts.length,
        posts: posts,
      );
    } catch (e) {
      return FCSearchDataResultPost(
        result: false,
        resultText: 'Error: $e',
        totalPostNum: 0,
        posts: const [],
      );
    }
  }

  /// Discourse-native: search topics + posts with structured
  /// [FCSearchFilters] layered on top of free-text [keywords].
  ///
  /// Returns the raw split { topics, posts } so callers can decide how
  /// to render. Pass [page] to paginate (1-indexed, matching Discourse).
  Future<DiscourseSearchResult> searchWithFiltersAsync({
    required String keywords,
    FCSearchFilters filters = const FCSearchFilters(),
    int page = 1,
    int perPage = _defaultPerPage,
  }) async {
    final fragment = filters.toQueryFragment();
    final q = [keywords.trim(), fragment]
        .where((p) => p.isNotEmpty)
        .join(' ')
        .trim();
    if (q.isEmpty) {
      return const DiscourseSearchResult(topics: [], posts: []);
    }
    try {
      final response =
          await _searchRaw(q, page: page <= 1 ? 0 : page - 1, perPage: perPage);
      final users = _usersById(response);
      final topics = ((response['topics'] as List?) ?? const [])
          .whereType<Map>()
          .map((t) =>
              _topicFromSearchResult(t.cast<String, dynamic>(), users: users))
          .toList();
      final posts = ((response['posts'] as List?) ?? const [])
          .whereType<Map>()
          .map((p) => _postFromSearchResult(p.cast<String, dynamic>()))
          .toList();
      return DiscourseSearchResult(topics: topics, posts: posts);
    } catch (_) {
      return const DiscourseSearchResult(topics: [], posts: []);
    }
  }

  // ===== Helpers =====

  Future<Map<String, dynamic>> _searchRaw(
    String q, {
    int page = 0,
    int perPage = _defaultPerPage,
  }) {
    return apiGet('/search.json', query: {
      'q': q,
      if (page > 0) 'page': page.toString(),
    });
  }

  String _buildAdvancedQuery({
    required String keywords,
    bool titleOnly = false,
    String? searchUser,
    String? forumId,
    String? topicId,
    List<String>? onlyIn,
    List<String>? notIn,
    bool startedBy = false,
    int? searchTimeSeconds,
  }) {
    final parts = <String>[];
    if (keywords.trim().isNotEmpty) parts.add(keywords.trim());
    if (titleOnly) parts.add('in:title');
    if (searchUser != null && searchUser.isNotEmpty) {
      parts.add('@${searchUser.trim()}');
    }
    // Discourse's category filter takes a slug; without one we encode the
    // raw id which Discourse also accepts in the form `category:N`.
    if (forumId != null && forumId.isNotEmpty) {
      parts.add('category:$forumId');
    }
    if (topicId != null && topicId.isNotEmpty) {
      parts.add('topic:$topicId');
    }
    if (onlyIn != null) {
      for (final cid in onlyIn) {
        parts.add('category:$cid');
      }
    }
    if (notIn != null) {
      for (final cid in notIn) {
        parts.add('-category:$cid');
      }
    }
    if (startedBy && searchUser != null && searchUser.isNotEmpty) {
      parts.add('in:first');
    }
    if (searchTimeSeconds != null && searchTimeSeconds > 0) {
      final since =
          DateTime.now().toUtc().subtract(Duration(seconds: searchTimeSeconds));
      final iso = '${since.year.toString().padLeft(4, '0')}-'
          '${since.month.toString().padLeft(2, '0')}-'
          '${since.day.toString().padLeft(2, '0')}';
      parts.add('after:$iso');
    }
    return parts.join(' ');
  }

  Map<int, Map<String, dynamic>> _usersById(Map<String, dynamic> response) {
    final users = <int, Map<String, dynamic>>{};
    for (final u in ((response['users'] as List?) ?? const []).whereType<Map>()) {
      final id = u['id'];
      if (id is int) users[id] = u.cast<String, dynamic>();
    }
    return users;
  }

  FCTopic _topicFromSearchResult(
    Map<String, dynamic> t, {
    Map<int, Map<String, dynamic>> users = const {},
  }) {
    final id = (t['id'] ?? '').toString();
    final slug = t['slug']?.toString();
    final categoryId = (t['category_id'] ?? '').toString();
    return FCTopic(
      id: id,
      title: (t['title'] ?? '').toString(),
      forumId: categoryId,
      forumName: '',
      authorId: '',
      authorName: '',
      timestamp:
          DateTime.tryParse(t['created_at']?.toString() ?? '') ?? DateTime.now(),
      replyCount: (((t['posts_count'] as int?) ?? 1) - 1).clamp(0, 1 << 30),
      viewCount: (t['views'] as int?) ?? 0,
      hasNewPosts: false,
      isClosed: (t['closed'] as bool?) ?? false,
      isSubscribed: false,
      canSubscribe: true,
      url: slug != null && slug.isNotEmpty
          ? '${siteContext.site.url}/t/$slug/$id'
          : '${siteContext.site.url}/t/$id',
      shortContent: (t['excerpt'] as String?) ?? '',
      isPinned: (t['pinned'] as bool?) ?? false,
      isAnnouncement: false,
      canReply: !(t['closed'] == true || t['archived'] == true),
      canReport: true,
      canLike: true,
      isLiked: (t['liked'] as bool?) ?? false,
      likeCount: 0,
      hasPoll: false,
    );
  }

  FCPost _postFromSearchResult(Map<String, dynamic> p) {
    final tpl = p['avatar_template'] as String?;
    String? avatarUrl;
    if (tpl != null && tpl.isNotEmpty) {
      final filled = tpl.replaceAll('{size}', '90');
      avatarUrl = filled.startsWith('http')
          ? filled
          : '${siteContext.site.url}$filled';
    }
    return FCPost(
      id: (p['id'] ?? '').toString(),
      title: '',
      // Search results give us a `blurb` (text excerpt) rather than full
      // cooked HTML. That's actually nicer for the UI here.
      content: (p['blurb'] ?? '').toString(),
      topicId: (p['topic_id'] ?? '').toString(),
      authorId: '',
      authorName: (p['username'] ?? '').toString(),
      authorIconUrl: avatarUrl,
      timestamp: DateTime.tryParse(p['created_at']?.toString() ?? ''),
      postNumber: p['post_number'] as int?,
      canEdit: false,
      canDelete: false,
      canReport: true,
      canLike: true,
      isLiked: false,
      // Mutable lists so optimistic-UI in post_actions.dart can call .add().
      attachments: <FCAttachment>[],
      inlineAttachments: <FCAttachment>[],
      thanksInfo: <FCThanks>[],
      likesInfo: List<FCLike>.generate(
        (p['like_count'] as int?) ?? 0,
        (_) => FCLike(userId: '', username: '', avatarUrl: ''),
      ),
    );
  }

  int _pageOf(int startNum) => startNum <= 0 ? 0 : (startNum / _defaultPerPage).floor();

  int _spanFromIndices(int startNum, int lastNum) {
    final s = startNum < 0 ? 0 : startNum;
    final e = lastNum < s ? s + _defaultPerPage : lastNum;
    final span = e - s + 1;
    return span > 0 ? span.clamp(1, 50) : _defaultPerPage;
  }
}

/// Result of [DiscourseSearchProxy.searchWithFiltersAsync] — keeps
/// topics and posts separated so the UI can present them on different
/// tabs.
class DiscourseSearchResult {
  final List<FCTopic> topics;
  final List<FCPost> posts;
  const DiscourseSearchResult({
    required this.topics,
    required this.posts,
  });
}
