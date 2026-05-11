import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_bookmark_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_bookmark.dart';
import 'package:forumcopilot_sdk/models/results/fc_bookmark_result.dart';

import '../base_discourse_proxy.dart';

/// Discourse implementation of [IFCBookmarkProxy] (Phase 5.33 — lifted
/// off `DiscoursePostProxy`).
///
/// Endpoints used:
///   * POST   `/bookmarks.json`              — create on a post (or topic)
///   * DELETE `/bookmarks/{id}.json`         — remove by bookmark id
///   * GET    `/u/{username}/bookmarks.json` — list current user's bookmarks
///
/// Discourse identifies bookmarks by their own numeric `id`, not by the
/// post id, so [removePostBookmarkAsync] does a list-lookup to translate.
/// Callers that already have the bookmark id from a list query should
/// use [removeBookmarkByIdAsync] to skip the round-trip.
class DiscourseBookmarkProxy extends BaseDiscourseProxy
    implements IFCBookmarkProxy {
  DiscourseBookmarkProxy(SiteContext context) : super(context);

  @override
  Future<FCAddBookmarkResult> addPostBookmarkAsync(String postId) async {
    if (!siteContext.isLoggedIn) {
      return FCAddBookmarkResult(result: false, resultText: 'Not signed in');
    }
    try {
      final response = await apiPost('/bookmarks.json', body: {
        'bookmarkable_type': 'Post',
        'bookmarkable_id': int.tryParse(postId) ?? postId,
      });
      // Discourse returns the new bookmark id at the top level on success.
      final bookmarkId = (response['id'] as num?)?.toInt();
      return FCAddBookmarkResult(
        result: true,
        isBookmarked: true,
        bookmarkId: bookmarkId,
      );
    } on DiscourseApiException catch (e) {
      return FCAddBookmarkResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCAddBookmarkResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCRemoveBookmarkResult> removePostBookmarkAsync(String postId) async {
    if (!siteContext.isLoggedIn) {
      return FCRemoveBookmarkResult(result: false, resultText: 'Not signed in');
    }
    final username = siteContext.currentUsername;
    if (username == null || username.isEmpty) {
      return FCRemoveBookmarkResult(result: false, resultText: 'Not signed in');
    }
    final pid = int.tryParse(postId);
    if (pid == null) {
      return FCRemoveBookmarkResult(
        result: false,
        resultText: 'Invalid post id',
      );
    }
    try {
      final response = await apiGet(
          '/u/${Uri.encodeComponent(username)}/bookmarks.json');
      final ub = (response['user_bookmark_list'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      final bookmarks = (ub['bookmarks'] as List?) ?? const [];
      int? bookmarkId;
      for (final raw in bookmarks.whereType<Map>()) {
        final b = raw.cast<String, dynamic>();
        // Discourse exposes either post_id or bookmarkable_id depending on
        // version. Match against either.
        final matchPostId = b['post_id'] == pid ||
            (b['bookmarkable_type'] == 'Post' && b['bookmarkable_id'] == pid);
        if (matchPostId) {
          bookmarkId = (b['id'] as num?)?.toInt();
          break;
        }
      }
      if (bookmarkId == null) {
        return FCRemoveBookmarkResult(
          result: false,
          resultText: 'Bookmark not found',
        );
      }
      return removeBookmarkByIdAsync(bookmarkId);
    } on DiscourseApiException catch (e) {
      return FCRemoveBookmarkResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCRemoveBookmarkResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCRemoveBookmarkResult> removeBookmarkByIdAsync(int bookmarkId) async {
    if (!siteContext.isLoggedIn) {
      return FCRemoveBookmarkResult(result: false, resultText: 'Not signed in');
    }
    try {
      await apiDelete('/bookmarks/$bookmarkId.json');
      return FCRemoveBookmarkResult(result: true, isBookmarked: false);
    } on DiscourseApiException catch (e) {
      return FCRemoveBookmarkResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCRemoveBookmarkResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCBookmarkListResult> getBookmarksAsync({int page = 0}) async {
    if (!siteContext.isLoggedIn) {
      return FCBookmarkListResult(
        result: false,
        resultText: 'Not signed in',
        total: 0,
        items: const [],
      );
    }
    final username = siteContext.currentUsername;
    if (username == null || username.isEmpty) {
      return FCBookmarkListResult(
        result: false,
        resultText: 'Not signed in',
        total: 0,
        items: const [],
      );
    }
    try {
      final qs = page > 0 ? '?page=$page' : '';
      final response = await apiGet(
          '/u/${Uri.encodeComponent(username)}/bookmarks.json$qs');
      final ub = (response['user_bookmark_list'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      final raw = (ub['bookmarks'] as List?) ?? const [];
      final items = raw
          .whereType<Map>()
          .map((b) => _bookmarkFromDiscourseJson(b.cast<String, dynamic>()))
          .toList();
      return FCBookmarkListResult(
        result: true,
        total: items.length,
        items: items,
      );
    } on DiscourseApiException catch (e) {
      return FCBookmarkListResult(
        result: false,
        resultText: e.userMessage,
        total: 0,
        items: const [],
      );
    } catch (e) {
      return FCBookmarkListResult(
        result: false,
        resultText: 'Error: $e',
        total: 0,
        items: const [],
      );
    }
  }

  FCBookmark _bookmarkFromDiscourseJson(Map<String, dynamic> json) {
    final avatarTemplate = json['avatar_template']?.toString();
    return FCBookmark(
      id: (json['id'] as num).toInt(),
      bookmarkableType: json['bookmarkable_type']?.toString(),
      bookmarkableId: (json['bookmarkable_id'] as num?)?.toInt(),
      topicId: (json['topic_id'] as num?)?.toInt(),
      postNumber: (json['post_number'] as num?)?.toInt() ??
          (json['linked_post_number'] as num?)?.toInt(),
      title: json['title']?.toString() ??
          json['fancy_title']?.toString() ??
          json['topic_title']?.toString(),
      excerpt: json['excerpt']?.toString(),
      name: json['name']?.toString(),
      username: json['username']?.toString(),
      avatarUrl: _resolveAvatarUrl(avatarTemplate),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  String? _resolveAvatarUrl(String? template, {int size = 90}) {
    if (template == null || template.isEmpty) return null;
    final filled = template.replaceAll('{size}', size.toString());
    if (filled.startsWith('http')) return filled;
    return '${siteContext.site.url}$filled';
  }
}
