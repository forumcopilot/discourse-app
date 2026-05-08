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
    // Discourse doesn't track per-category "user has participated here";
    // approximate by surfacing categories with notification_level >=
    // Tracking (2). Phase 2 follow-up: hit /user-actions to compute real
    // participation history.
    try {
      final response = await apiGet('/categories.json');
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
    // Discourse: PUT /topics/bulk { filter:'unread', operation:{type:'dismiss'}, [category_id] }.
    try {
      final body = <String, dynamic>{
        'filter': 'unread',
        'operation': {'type': 'dismiss'},
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
      return FCIdByUrlResult(
        result: true,
        resultText: '',
        topicId: segments[2],
        postId: segments.length >= 4 ? segments[3] : null,
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
      final stats = (inner['stats'] as Map<String, dynamic>?) ?? const {};
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
      final response = await apiGet('/categories.json');
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
    final permission = c['permission'];
    final canPost = permission == null || permission == 1 || permission == 2;
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
      hasNewPosts: false,
      isProtected: readRestricted,
      isSubscribed: notificationLevel >= 2,
      canSubscribe: true,
      canPost: canPost,
      canUpload: canPost,
      canViewContent: !readRestricted || permission != null,
      externalUrl: null,
      isLinkForum: false,
      isSubForumContainer: (c['has_children'] as bool? ?? false) &&
          (c['topic_count'] as int? ?? 0) == 0,
      childForums: const [],
    );
  }

  String? _absoluteUrl(String? maybeRelative) {
    if (maybeRelative == null || maybeRelative.isEmpty) return null;
    if (maybeRelative.startsWith('http')) return maybeRelative;
    return '${siteContext.site.url}$maybeRelative';
  }
}
