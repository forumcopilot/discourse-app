import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_forum_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_forum.dart';
import 'package:forumcopilot_sdk/models/results/fc_forum_result.dart';

import '../base_discourse_proxy.dart';

/// Discourse implementation of [IFCForumProxy].
///
/// "Forum" in the FC SDK == "category" in Discourse. Discourse supports two
/// levels of category nesting; this proxy turns the flat `/categories.json`
/// list into a parent-child tree on [FCForum.childForums].
class DiscourseForumProxy extends BaseDiscourseProxy implements IFCForumProxy {
  DiscourseForumProxy(SiteContext context) : super(context);

  // Phase 5.41 — hex color, text color, topic/post counts and slug live
  // on FCForum itself so they survive the tree rebuild in [_buildTree].

  @override
  Future<FCForumDataResult> getForumAsync(
    bool returnDescription,
    String forumId,
    bool forceRefresh,
  ) async {
    try {
      final response = await apiGet('/categories.json',
          query: {'include_subcategories': 'true'});
      final list = (response['category_list'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      final raw = (list['categories'] as List?) ?? const [];
      final cats =
          raw.whereType<Map<String, dynamic>>().toList(growable: false);

      List<FCForum> forums;
      if (forumId.isNotEmpty) {
        final id = int.tryParse(forumId);
        if (id == null) {
          forums = const [];
        } else {
          forums = cats
              .where((c) => c['parent_category_id'] == id)
              .map((c) => _toForum(c, returnDescription: returnDescription))
              .toList();
        }
      } else {
        forums = _buildTree(cats, returnDescription: returnDescription);
      }

      return FCForumDataResult(
        result: true,
        resultText: '',
        forums: forums,
      );
    } catch (e) {
      return FCForumDataResult(
        result: false,
        resultText: 'Error loading categories: $e',
        forums: const [],
      );
    }
  }

  @override
  Future<FCParticipatedForumResult> getParticipatedForumAsync() async {
    // Discourse doesn't track per-category "user has participated here".
    // This is an APPROXIMATION: categories the user tracks or watches
    // (notification_level >= 2). It is not participation history — a
    // real one would need /user_actions.json aggregated by category,
    // which is several round-trips and is not attempted here.
    try {
      // include_subcategories=true: without it /categories.json omits
      // subcategories, hiding any tracked subcategory here.
      final response = await apiGet('/categories.json',
          query: {'include_subcategories': 'true'});
      final list = (response['category_list'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      final cats = ((list['categories'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .where((c) => (c['notification_level'] as int? ?? 1) >= 2)
          .map((c) => _toForum(c))
          .toList();
      return FCParticipatedForumResult(
        result: true,
        resultText: '',
        forums: cats,
      );
    } catch (e) {
      return FCParticipatedForumResult(
        result: false,
        resultText: 'Error: $e',
        forums: const [],
      );
    }
  }

  @override
  Future<FCMarkAllAsReadResult> markAllAsRead(String forumId) async {
    // Discourse: PUT /topics/bulk with filter=='unread' selects the user's
    // unread topics server-side; the operation type must come from
    // TopicsBulkAction.operations ('dismiss' is invalid) — 'dismiss_posts'
    // marks every post in each selected topic as read.
    try {
      final body = <String, dynamic>{
        'filter': 'unread',
        'operation': {'type': 'dismiss_posts'},
      };
      if (forumId.isNotEmpty) {
        body['category_id'] = int.tryParse(forumId) ?? forumId;
      }
      await apiPut('/topics/bulk', body: body);
      return FCMarkAllAsReadResult(result: true, resultText: '');
    } catch (e) {
      return FCMarkAllAsReadResult(
        result: false,
        resultText: 'Error: $e',
      );
    }
  }

  @override
  Future<FCLoginForumResult> loginForum(String forumId, String password) async {
    // Discourse categories use group permissions, not passwords.
    return FCLoginForumResult(
      result: false,
      resultText: 'Discourse categories use group permissions, not passwords',
    );
  }

  @override
  Future<FCIdByUrlResult> getIdByUrl(String url) async {
    // /t/{slug}/{topic_id}                  → topic
    // /t/{slug}/{topic_id}/{post_number}    → post within topic
    // /c/{slug}/{category_id}               → category
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return FCIdByUrlResult(result: false, resultText: 'Invalid URL');
    }
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length >= 3 && segments[0] == 't') {
      final topicId = segments[2];
      String? postId;
      if (segments.length >= 4) {
        // The URL's 4th segment is a post_number (position in the topic),
        // NOT a post id. Resolve the real id via the topic view, which
        // centers its post_stream chunk on the requested post_number.
        final postNumber = int.tryParse(segments[3]);
        if (postNumber != null) {
          try {
            final t = await apiGet('/t/$topicId/$postNumber.json');
            final stream =
                (t['post_stream'] as Map<String, dynamic>?) ?? const {};
            final posts = (stream['posts'] as List?) ?? const [];
            for (final raw in posts.whereType<Map>()) {
              if (raw['post_number'] == postNumber) {
                postId = raw['id']?.toString();
                break;
              }
            }
          } catch (_) {
            // Topic still resolved; leave postId null rather than
            // returning a post_number that callers would mistake for
            // a post id.
          }
        }
      }
      return FCIdByUrlResult(
        result: true,
        resultText: '',
        topicId: topicId,
        postId: postId,
      );
    }
    if (segments.length >= 3 && segments[0] == 'c') {
      return FCIdByUrlResult(
        result: true,
        resultText: '',
        forumId: segments.last,
      );
    }
    return FCIdByUrlResult(result: false, resultText: 'Unrecognized URL');
  }

  @override
  Future<FCUrlByIdResult> getUrlById(String mode, String id) async {
    final base = siteContext.site.url;
    switch (mode) {
      case 'topic':
        return FCUrlByIdResult(result: true, resultText: '', url: '$base/t/$id');
      case 'post':
        return FCUrlByIdResult(result: true, resultText: '', url: '$base/p/$id');
      case 'forum':
        return FCUrlByIdResult(result: true, resultText: '', url: '$base/c/$id');
      default:
        return FCUrlByIdResult(
          result: false,
          resultText: 'Unsupported mode: $mode',
        );
    }
  }

  @override
  Future<FCBoardStatResult> getBoardStatAsync() async {
    try {
      final about = await apiGet('/about.json');
      final inner = (about['about'] as Map<String, dynamic>?) ?? const {};
      final stats = (inner['stats'] as Map<String, dynamic>?);
      // `AboutSerializer#include_stats?` is gated on `can_see_about_stats`
      // (app/serializers/about_serializer.rb:34-36, :60-61), so the whole
      // `stats` block is absent for viewers the forum withholds it from.
      // Report that as a failed fetch instead of a forum with 0 topics,
      // 0 posts and 0 members — those zeros would be indistinguishable
      // from a genuinely empty forum.
      if (stats == null) {
        return FCBoardStatResult(
          result: false,
          resultText: 'Forum statistics are not visible to this account',
        );
      }
      return FCBoardStatResult(
        result: true,
        resultText: '',
        totalThreads: (stats['topics_count'] as int?) ?? 0,
        totalPosts: (stats['posts_count'] as int?) ?? 0,
        totalMembers: (stats['users_count'] as int?) ?? 0,
        activeMembers: (stats['active_users_30_days'] as int?) ?? 0,
      );
    } catch (e) {
      return FCBoardStatResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCForumStatusResult> getForumStatusAsync(List<String> forumIds) async {
    try {
      // include_subcategories=true: without it /categories.json omits
      // subcategories, so status lookups for them silently return nothing.
      final response = await apiGet('/categories.json',
          query: {'include_subcategories': 'true'});
      final list = (response['category_list'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      final cats = (list['categories'] as List?) ?? const [];
      final wanted = forumIds.toSet();
      final forums = cats
          .whereType<Map<String, dynamic>>()
          .where((c) => wanted.contains(c['id'].toString()))
          .map((c) => _toForum(c))
          .toList();
      return FCForumStatusResult(
        result: true,
        resultText: '',
        forums: forums,
      );
    } catch (e) {
      return FCForumStatusResult(
        result: false,
        resultText: 'Error: $e',
        forums: const [],
      );
    }
  }

  // ===== Helpers =====

  List<FCForum> _buildTree(
    List<Map<String, dynamic>> cats, {
    bool returnDescription = true,
  }) {
    final byId = <int, FCForum>{};
    for (final c in cats) {
      final id = c['id'];
      if (id is int) {
        byId[id] = _toForum(c, returnDescription: returnDescription);
      }
    }

    final roots = <FCForum>[];
    final children = <int, List<FCForum>>{};
    for (final c in cats) {
      final id = c['id'];
      if (id is! int) continue;
      final fcForum = byId[id]!;
      final parent = c['parent_category_id'];
      if (parent is int && byId.containsKey(parent)) {
        (children[parent] ??= <FCForum>[]).add(fcForum);
      } else {
        roots.add(fcForum);
      }
    }

    FCForum withChildren(FCForum f) {
      final id = int.tryParse(f.id);
      final kids = id == null ? const <FCForum>[] : (children[id] ?? const []);
      return FCForum(
        id: f.id,
        name: f.name,
        description: f.description,
        logoUrl: f.logoUrl,
        backgroundUrl: f.backgroundUrl,
        parentId: f.parentId,
        hasNewPosts: f.hasNewPosts,
        isProtected: f.isProtected,
        isSubscribed: f.isSubscribed,
        canSubscribe: f.canSubscribe,
        canPost: f.canPost,
        canUpload: f.canUpload,
        canViewContent: f.canViewContent,
        externalUrl: f.externalUrl,
        isLinkForum: f.isLinkForum,
        isSubForumContainer: f.isSubForumContainer || kids.isNotEmpty,
        childForums: kids.map(withChildren).toList(),
        color: f.color,
        textColor: f.textColor,
        topicCount: f.topicCount,
        postCount: f.postCount,
        slug: f.slug,
      );
    }

    return roots.map(withChildren).toList();
  }

  FCForum _toForum(
    Map<String, dynamic> c, {
    bool returnDescription = true,
  }) {
    final notificationLevel = (c['notification_level'] as int?) ?? 1;
    final readRestricted = c['read_restricted'] as bool? ?? false;
    // `permission` (BasicCategorySerializer, basic_category_serializer.rb:21)
    // is `CategoryGroup.permission_types` — full:1, create_post:2, readonly:3
    // (app/models/category_group.rb:10). On the category-LIST paths
    // Discourse fills it in `Category.preload_user_fields!`
    // (app/models/category.rb:279-280), which sets it to `:full` ONLY for
    // admins and users in `topic_create_allowed`, and otherwise leaves it
    // NIL. `Category.set_permission!` (the method that can also emit 2/3)
    // is reached only from lib/group_manager.rb:123. So on /categories.json
    // nil means "you may NOT start topics here", not "unknown" — treating
    // nil as postable (as this did) made every read-only category look
    // postable to every visitor, anonymous included.
    final permission = c['permission'];
    final canPost = permission == 1 || permission == 2;
    final logo =
        (c['uploaded_logo'] as Map<String, dynamic>?)?['url'] as String?;
    final bg =
        (c['uploaded_background'] as Map<String, dynamic>?)?['url'] as String?;

    return FCForum(
      id: (c['id'] ?? '').toString(),
      name: (c['name'] ?? '').toString(),
      description:
          returnDescription ? (c['description_text'] as String?) : null,
      logoUrl: _absoluteUrl(logo),
      backgroundUrl: _absoluteUrl(bg),
      parentId: c['parent_category_id']?.toString(),
      // BasicCategorySerializer carries no per-category unread signal —
      // Discourse tracks new/unread per TOPIC, not per category. Always
      // false here; it is not a claim that the category has been read.
      hasNewPosts: false,
      isProtected: readRestricted,
      isSubscribed: notificationLevel >= 2,
      // Subscribing writes CategoryUser state, which requires a session.
      canSubscribe: siteContext.isLoggedIn,
      canPost: canPost,
      // Discourse has NO per-category upload permission — uploading is
      // gated globally by trust level and the `authorized_extensions` /
      // `max_*_size_kb` site settings (see DiscourseUploadLimits, cached
      // on the site context by DiscourseConfigProxy). Aliasing canPost is
      // the closest honest approximation: if you can't post here you
      // can't attach anything here either.
      canUpload: canPost,
      // Everything /categories.json returns has already passed through
      // `Category.secured(guardian)`, so the viewer can see it by
      // construction. This used to be `!readRestricted || permission != null`,
      // which hid the topic list of any restricted category the viewer
      // could read but not post in (permission nil — see above).
      canViewContent: true,
      externalUrl: null,
      isLinkForum: false,
      // Heuristic, NOT a server field: Discourse has no "container
      // category" concept. `has_children` + `subcategory_count` are real
      // (basic_category_serializer.rb:27-28); the `topic_count == 0` half
      // is our own rule for "show the subcategory list instead of a topic
      // list". Note _buildTree widens this to any parent with children.
      isSubForumContainer: (c['has_children'] as bool? ?? false) &&
          (c['topic_count'] as int? ?? 0) == 0,
      childForums: const [],
      // Phase 5.41 — Discourse-only fields now first-class on FCForum.
      // Empty string fine for color/textColor; UI hides the stripe when
      // color is empty (e.g. when fetched via an endpoint that doesn't
      // include them).
      color: (c['color'] as String?) ?? '',
      // `text_color` is unconditionally serialized alongside `color`, so
      // this fallback is unreachable on a real response; it only guards a
      // hand-built map.
      textColor: (c['text_color'] as String?) ?? 'FFFFFF',
      topicCount: (c['topic_count'] as int?) ?? 0,
      postCount: (c['post_count'] as int?) ?? 0,
      slug: c['slug']?.toString(),
    );
  }

  String? _absoluteUrl(String? maybeRelative) {
    if (maybeRelative == null || maybeRelative.isEmpty) return null;
    if (maybeRelative.startsWith('http')) return maybeRelative;
    return '${siteContext.site.url}$maybeRelative';
  }
}

