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
/// Paging contract (verified against the Discourse source):
///   * `page` is 1-based — `SearchController#show` clamps it with
///     `[page.to_i, 1].max` and rejects pages above `PAGE_LIMIT` (10)
///     with a 400.
///   * The controller itself sets `type_filter: "topic"` for
///     `/search.json`, so the paging offset
///     (`(page - 1) * Search.per_filter`) always applies; there is no
///     client-side `type_filter` parameter (only `q` and `page` are
///     permitted).
///   * Page size is fixed server-side by `SiteSetting.search_page_size`
///     (default 50); there is no per-page parameter — a requested span
///     is advisory at best.
///   * With `type_filter: "topic"` the server runs a single aggregate
///     search (best post per topic): the response's `posts` and
///     `topics` arrays are two views of the same result set and page in
///     lockstep with the one `page` param. Users/categories/tags are
///     only produced by the un-paged header search (`/search/query`),
///     so a users list cannot be paged via the stock API.
///   * Has-more is signalled by
///     `grouped_search_result.more_full_page_results` (true when the
///     server found a full page plus at least one extra row).
///   * There is NO grand total. `GroupedSearchResultSerializer`
///     (app/serializers/grouped_search_result_serializer.rb:8-17)
///     exposes only `more_posts` / `more_users` / `more_categories` /
///     `more_full_page_results` — booleans, not counts. The SDK's
///     `totalTopicNum` / `totalPostNum` therefore carry the number of
///     rows in THIS page, which is all the server tells us. Callers
///     must not treat them as a result total.
///
/// `/search.json` returns `{ posts: [], topics: [], users: [], categories: [],
/// tags: [], groups: [], grouped_search_result: {...} }`. We extract topics
/// and posts; the search-topic endpoint and search-post endpoint share this
/// single Discourse call.
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

  /// `SearchController::PAGE_LIMIT` — `/search.json` rejects `page`
  /// values above this with a 400, so paging is capped explicitly here
  /// rather than re-serving (or erroring on) deep pages.
  static const int _maxPage = 10;

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
      final page = _pageOf(startNum, lastNum);
      if (page > _maxPage) {
        // Beyond the server's 10-page window — stop paging instead of
        // erroring or silently re-serving the last page.
        return FCSearchTopicResult(
          result: true,
          resultText: '',
          totalTopicNum: 0,
          searchId: null,
          topics: const [],
        );
      }
      final response = await _searchRaw(searchString, page: page);
      final topics = ((response['topics'] as List?) ?? const [])
          .whereType<Map>()
          .map((t) => _topicFromSearchResult(t.cast<String, dynamic>()))
          .toList();
      return FCSearchTopicResult(
        result: true,
        resultText: '',
        // Page length, not a grand total — see the class doc.
        totalTopicNum: topics.length,
        searchId: null,
        topics: topics,
        hasMore: _hasMoreFrom(response, page),
      );
    } catch (e) {
      return FCSearchTopicResult(
        result: false,
        resultText: describeApiError(e),
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
      final page = _pageOf(startNum, lastNum);
      if (page > _maxPage) {
        return FCSearchPostResult(
          result: true,
          resultText: '',
          totalPostNum: 0,
          searchId: null,
          posts: const [],
        );
      }
      final response = await _searchRaw(searchString, page: page);
      final titles = _topicTitles(response);
      final posts = ((response['posts'] as List?) ?? const [])
          .whereType<Map>()
          .map((p) => _postFromSearchResult(p.cast<String, dynamic>(),
              topicTitles: titles))
          .toList();
      return FCSearchPostResult(
        result: true,
        resultText: '',
        // Page length, not a grand total — see the class doc.
        totalPostNum: posts.length,
        searchId: null,
        posts: posts,
        hasMore: _hasMoreFrom(response, page),
      );
    } catch (e) {
      return FCSearchPostResult(
        result: false,
        resultText: describeApiError(e),
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
      if (page > _maxPage) {
        return FCSearchDataResultTopic(
          result: true,
          resultText: '',
          totalTopicNum: 0,
          topics: const [],
        );
      }
      final effectivePage = page < 1 ? 1 : page;
      final response = await _searchRaw(q, page: effectivePage);
      final topics = ((response['topics'] as List?) ?? const [])
          .whereType<Map>()
          .map((t) => _topicFromSearchResult(t.cast<String, dynamic>()))
          .toList();
      return FCSearchDataResultTopic(
        result: true,
        resultText: '',
        // Page length, not a grand total — see the class doc.
        totalTopicNum: topics.length,
        topics: topics,
        hasMore: _hasMoreFrom(response, effectivePage),
      );
    } catch (e) {
      return FCSearchDataResultTopic(
        result: false,
        resultText: describeApiError(e),
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
      if (page > _maxPage) {
        return FCSearchDataResultPost(
          result: true,
          resultText: '',
          totalPostNum: 0,
          posts: const [],
        );
      }
      final effectivePage = page < 1 ? 1 : page;
      final response = await _searchRaw(q, page: effectivePage);
      final titles = _topicTitles(response);
      final posts = ((response['posts'] as List?) ?? const [])
          .whereType<Map>()
          .map((p) => _postFromSearchResult(p.cast<String, dynamic>(),
              topicTitles: titles))
          .toList();
      return FCSearchDataResultPost(
        result: true,
        resultText: '',
        // Page length, not a grand total — see the class doc.
        totalPostNum: posts.length,
        posts: posts,
        hasMore: _hasMoreFrom(response, effectivePage),
      );
    } catch (e) {
      return FCSearchDataResultPost(
        result: false,
        resultText: describeApiError(e),
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
  /// The page size is fixed server-side (`SiteSetting.search_page_size`)
  /// and topics/posts page in lockstep — they are two views of the same
  /// aggregate result set. Check [DiscourseSearchResult.hasMore] for
  /// whether another page exists; pages beyond the server's 10-page
  /// window return empty results with `hasMore: false`.
  ///
  /// Throws on network/API errors so callers can surface them and
  /// offer a retry.
  Future<DiscourseSearchResult> searchWithFiltersAsync({
    required String keywords,
    FCSearchFilters filters = const FCSearchFilters(),
    int page = 1,
  }) async {
    final fragment = filters.toQueryFragment();
    final q = [keywords.trim(), fragment]
        .where((p) => p.isNotEmpty)
        .join(' ')
        .trim();
    if (q.isEmpty || page > _maxPage) {
      return const DiscourseSearchResult(topics: [], posts: []);
    }
    final response = await _searchRaw(q, page: page < 1 ? 1 : page);
    final topics = ((response['topics'] as List?) ?? const [])
        .whereType<Map>()
        .map((t) => _topicFromSearchResult(t.cast<String, dynamic>()))
        .toList();
    final posts = ((response['posts'] as List?) ?? const [])
        .whereType<Map>()
        .map((p) => _postFromSearchResult(p.cast<String, dynamic>(),
            topicTitles: _topicTitles(response)))
        .toList();
    return DiscourseSearchResult(
      topics: topics,
      posts: posts,
      hasMore: _hasMoreFrom(response, page),
    );
  }

  // ===== Helpers =====

  /// Whether the server signalled another full page of results.
  ///
  /// `/search.json` runs with `type_filter: "topic"` (a full-page
  /// search), so the authoritative signal is
  /// `grouped_search_result.more_full_page_results`
  /// (grouped_search_result_serializer.rb:14) — a boolean, not a count.
  /// The per-type `more_posts` / `more_users` / `more_categories`
  /// booleans are only meaningful for the un-paged header search, so we
  /// do not consult them here. Topics and posts page in lockstep, so
  /// this one signal covers both lists. Also gated on the server's
  /// 10-page window ([_maxPage]) beyond which paging is refused.
  bool _hasMoreFrom(Map<String, dynamic> response, int page) {
    final more = (response['grouped_search_result'] as Map?)
            ?['more_full_page_results'] ==
        true;
    return more && page < _maxPage;
  }

  /// GET `/search.json`. [page] is 1-based; the server clamps missing/low
  /// values to 1, so page 1 is sent implicitly. Callers must not exceed
  /// [_maxPage] (the server 400s above it). There is no per-page
  /// parameter — the server returns `SiteSetting.search_page_size`
  /// results per page.
  Future<Map<String, dynamic>> _searchRaw(
    String q, {
    int page = 1,
  }) {
    return apiGet('/search.json', query: {
      'q': q,
      if (page > 1) 'page': page.toString(),
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

  /// Maps one row of the response's side-loaded `topics` array
  /// (`SearchTopicListItemSerializer < ListableTopicSerializer`, see
  /// `app/serializers/search_topic_list_item_serializer.rb:4`).
  ///
  /// Fields that serializer deliberately does NOT emit, and therefore
  /// cannot be filled here (they stay at their neutral value rather
  /// than being invented):
  ///   * author (`ListableTopicSerializer` only side-loads
  ///     `last_poster`, and only when `include_last_poster` is set by
  ///     the topic list — search never sets it) → author id/name empty.
  ///   * `views` → [FCTopic.viewCount] is a non-nullable int, so it
  ///     stays 0; it is NOT a real view count. `views` is only on
  ///     `TopicListItemSerializer`.
  ///   * `like_count` → same, stays 0.
  ///   * `pinned_globally` → [FCTopic.isAnnouncement] stays false.
  ///   * category name → only `category_id` is serialized
  ///     (`search_topic_list_item_serializer.rb:7`).
  FCTopic _topicFromSearchResult(Map<String, dynamic> t) {
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
      // `reply_count` on Discourse counts cross-thread replies, so total
      // replies is `posts_count - 1` (matches DiscourseTopicProxy).
      replyCount: (((t['posts_count'] as int?) ?? 1) - 1).clamp(0, 1 << 30),
      viewCount: 0,
      // `unseen` / `unread_posts` are serialized whenever the topic has
      // user_data (i.e. the viewer is logged in) — listable_topic_serializer.rb:8-13.
      hasNewPosts: t['unseen'] == true || (t['unread_posts'] as int? ?? 0) > 0,
      unreadCount: (t['unread_posts'] as int?) ?? (t['new_posts'] as int?) ?? 0,
      isClosed: (t['closed'] as bool?) ?? false,
      // `notification_level` is serialized when user_data is present
      // (listable_topic_serializer.rb:25); >= 2 is tracking/watching.
      isSubscribed: (t['notification_level'] as int? ?? 1) >= 2,
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
      // TopicTagsMixin is included by SearchTopicListItemSerializer, so
      // `tags` is present when tagging is enabled.
      tags: ((t['tags'] as List?) ?? const [])
          .map<String>((entry) {
            if (entry is String) return entry;
            if (entry is Map) return (entry['name'] ?? '').toString();
            return '';
          })
          .where((s) => s.isNotEmpty)
          .toList(growable: false),
    );
  }

  /// topic_id → title, from the `topics` array that rides alongside
  /// `posts` in every `/search.json` response.
  ///
  /// `SearchPostSerializer` carries no title — only `topic_id` — because
  /// the payload side-loads topics separately. Without this join every
  /// search result rendered as an author, a date and an excerpt with a
  /// blank where the topic name belongs, so there was no way to tell
  /// what any result was about.
  Map<String, String> _topicTitles(Map<String, dynamic> response) {
    final titles = <String, String>{};
    for (final t in ((response['topics'] as List?) ?? const [])) {
      if (t is! Map) continue;
      final id = t['id']?.toString();
      final title = t['title']?.toString();
      if (id != null && id.isNotEmpty && title != null && title.isNotEmpty) {
        titles[id] = title;
      }
    }
    return titles;
  }

  FCPost _postFromSearchResult(
    Map<String, dynamic> p, {
    Map<String, String> topicTitles = const {},
  }) {
    final tpl = p['avatar_template'] as String?;
    String? avatarUrl;
    if (tpl != null && tpl.isNotEmpty) {
      final filled = tpl.replaceAll('{size}', '90');
      avatarUrl = filled.startsWith('http')
          ? filled
          : '${siteContext.site.url}$filled';
    }
    final topicId = (p['topic_id'] ?? '').toString();
    return FCPost(
      id: (p['id'] ?? '').toString(),
      title: topicTitles[topicId] ?? '',
      // Search results give us a `blurb` (text excerpt) rather than full
      // cooked HTML. That's actually nicer for the UI here.
      content: (p['blurb'] ?? '').toString(),
      topicId: topicId,
      // `SearchPostSerializer < BasicPostSerializer` serializes
      // name/username/avatar_template but NOT `user_id`
      // (app/serializers/basic_post_serializer.rb:5), so there is no
      // numeric author id to hand the UI. Left empty rather than
      // guessed; profile navigation from a search row has to go by
      // username.
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
      // `SearchPostSerializer` emits `like_count` but never the actors
      // (app/serializers/search_post_serializer.rb:6). Carry the real
      // count and leave the actor list empty — the sheet fetches actors
      // on demand via `DiscoursePostProxy.getReactionUsersAsync`. We do
      // NOT pad the list with blank FCLike placeholders to make
      // `likesInfo.length` read right (that rendered blank avatars and
      // dead-end profile links).
      likeCount: (p['like_count'] as int?) ?? 0,
      // Mutable lists so optimistic-UI in post_actions.dart can call .add().
      attachments: <FCAttachment>[],
      inlineAttachments: <FCAttachment>[],
      thanksInfo: <FCThanks>[],
      likesInfo: <FCLike>[],
    );
  }

  /// Maps the SDK's inclusive item-index span onto a 1-based Discourse
  /// page: page N covers `startNum = (N-1)*span .. lastNum = N*span - 1`.
  ///
  /// Note the server ignores the requested span and returns
  /// `SiteSetting.search_page_size`-sized pages (default 50), so a
  /// caller paging with a different span may see gaps or overlap between
  /// pages — but never the same page served twice for distinct spans.
  /// Prefer [searchWithFiltersAsync], which pages natively.
  int _pageOf(int startNum, int lastNum) {
    final start = startNum < 0 ? 0 : startNum;
    final span = lastNum >= start ? (lastNum - start + 1) : _defaultPerPage;
    return (start ~/ span) + 1;
  }
}

/// Result of [DiscourseSearchProxy.searchWithFiltersAsync] — keeps
/// topics and posts separated so the UI can present them on different
/// tabs.
class DiscourseSearchResult {
  final List<FCTopic> topics;
  final List<FCPost> posts;

  /// True when the server reported another full page
  /// (`grouped_search_result.more_full_page_results`) and the next page
  /// is still within the server's 10-page window. Topics and posts page
  /// together, so this signal covers both lists.
  final bool hasMore;

  const DiscourseSearchResult({
    required this.topics,
    required this.posts,
    this.hasMore = false,
  });
}
