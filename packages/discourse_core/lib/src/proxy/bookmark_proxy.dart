import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_bookmark_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_bookmark.dart';
import 'package:forumcopilot_sdk/models/results/fc_bookmark_result.dart';

import '../base_discourse_proxy.dart';
import '../util/html_text.dart';

/// Discourse implementation of [IFCBookmarkProxy] (Phase 5.33 — lifted
/// off `DiscoursePostProxy`).
///
/// Endpoints used:
///   * POST   `/bookmarks.json`              — create on a post (or topic)
///   * PUT    `/bookmarks/{id}.json`         — edit name/reminder by id
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
      // users#bookmarks paginates via `page` (its `q` search param matches
      // titles/notes, not post ids, so it can't shortcut this lookup).
      // Scan pages until the post's bookmark shows up; capped so a huge
      // bookmark list can't loop forever.
      const maxPages = 25;
      int? bookmarkId;
      for (var page = 0; page < maxPages && bookmarkId == null; page++) {
        final response = await apiGet(
          '/u/${Uri.encodeComponent(username)}/bookmarks.json',
          query: {if (page > 0) 'page': page.toString()},
        );
        final ub = (response['user_bookmark_list'] as Map<String, dynamic>?) ??
            const <String, dynamic>{};
        // Past the last page the server renders a bare `{bookmarks: []}`
        // with no user_bookmark_list wrapper — both shapes end the scan.
        final bookmarks = (ub['bookmarks'] as List?) ?? const [];
        if (bookmarks.isEmpty) break;
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
      final response = await apiGet(
        '/u/${Uri.encodeComponent(username)}/bookmarks.json',
        query: {if (page > 0) 'page': page.toString()},
      );
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

  // ===== Discourse-native bookmark reminders =====
  //
  // `bookmarks#create` / `bookmarks#update` permit `name`, `reminder_at`
  // and `auto_delete_preference` alongside the bookmarkable columns, and
  // the user bookmark list serializes `reminder_at` per row — none of
  // which the XF-era interface methods above can express.

  /// Discourse-only: create a bookmark on a post, optionally with a
  /// reminder (`POST /bookmarks.json`).
  ///
  /// [reminderAt] is sent as UTC ISO-8601 and must be in the future
  /// (server-validated). [autoDeletePreference] takes the
  /// [DiscourseBookmarkAutoDelete] values; when omitted the server falls
  /// back to the user's `bookmark_auto_delete_preference` setting, then
  /// to clear-reminder. [name] is the user's private note (Discourse
  /// caps it at 100 chars).
  ///
  /// On success [FCAddBookmarkResult.bookmarkId] carries the new
  /// bookmark id (needed for [updateBookmarkAsync] /
  /// [removeBookmarkByIdAsync]).
  Future<FCAddBookmarkResult> createBookmarkAsync({
    required int postId,
    DateTime? reminderAt,
    int? autoDeletePreference,
    String? name,
  }) async {
    if (!siteContext.isLoggedIn) {
      return FCAddBookmarkResult(result: false, resultText: 'Not signed in');
    }
    try {
      final response = await apiPost('/bookmarks.json', body: {
        'bookmarkable_type': 'Post',
        'bookmarkable_id': postId,
        if (name != null && name.isNotEmpty) 'name': name,
        if (reminderAt != null)
          'reminder_at': reminderAt.toUtc().toIso8601String(),
        if (autoDeletePreference != null)
          'auto_delete_preference': autoDeletePreference,
      });
      return FCAddBookmarkResult(
        result: true,
        isBookmarked: true,
        bookmarkId: (response['id'] as num?)?.toInt(),
      );
    } on DiscourseApiException catch (e) {
      return FCAddBookmarkResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCAddBookmarkResult(result: false, resultText: 'Error: $e');
    }
  }

  /// Discourse-only: edit a bookmark's note/reminder
  /// (`PUT /bookmarks/{id}.json`).
  ///
  /// The endpoint overwrites, it does not patch: the server reassigns
  /// `name` and `reminder_at` from the request on every call, so an
  /// omitted (null) [reminderAt] **clears** any existing reminder and an
  /// omitted [name] clears the note — resend the values you want kept.
  /// An omitted [autoDeletePreference] likewise resets to the user's
  /// default preference (falling back to clear-reminder).
  Future<DiscourseBookmarkUpdateResult> updateBookmarkAsync(
    int bookmarkId, {
    DateTime? reminderAt,
    String? name,
    int? autoDeletePreference,
  }) async {
    if (!siteContext.isLoggedIn) {
      return const DiscourseBookmarkUpdateResult(
        result: false,
        resultText: 'Not signed in',
      );
    }
    try {
      await apiPut('/bookmarks/$bookmarkId.json', body: {
        if (name != null && name.isNotEmpty) 'name': name,
        if (reminderAt != null)
          'reminder_at': reminderAt.toUtc().toIso8601String(),
        if (autoDeletePreference != null)
          'auto_delete_preference': autoDeletePreference,
      });
      return const DiscourseBookmarkUpdateResult(result: true);
    } on DiscourseApiException catch (e) {
      return DiscourseBookmarkUpdateResult(
        result: false,
        resultText: e.userMessage,
      );
    } catch (e) {
      return DiscourseBookmarkUpdateResult(
        result: false,
        resultText: 'Error: $e',
      );
    }
  }

  /// Discourse-only: list the current user's bookmarks with the
  /// reminder metadata [FCBookmark] cannot carry.
  ///
  /// Same `GET /u/{username}/bookmarks.json` page as
  /// [getBookmarksAsync]; each entry wraps the mapped [FCBookmark]
  /// (which already surfaces `id` and the `name` note) and adds the
  /// row's `reminder_at` / `pinned`. [DiscourseBookmarkListResult
  /// .hasMore] reflects the server's `more_bookmarks_url`.
  Future<DiscourseBookmarkListResult> getBookmarksWithRemindersAsync({
    int page = 0,
  }) async {
    final username = siteContext.currentUsername;
    if (!siteContext.isLoggedIn || username == null || username.isEmpty) {
      return const DiscourseBookmarkListResult(
        result: false,
        resultText: 'Not signed in',
      );
    }
    try {
      final response = await apiGet(
        '/u/${Uri.encodeComponent(username)}/bookmarks.json',
        query: {if (page > 0) 'page': page.toString()},
      );
      final ub = (response['user_bookmark_list'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      final raw = (ub['bookmarks'] as List?) ?? const [];
      final entries = raw.whereType<Map>().map((b) {
        final json = b.cast<String, dynamic>();
        return DiscourseBookmarkEntry(
          bookmark: _bookmarkFromDiscourseJson(json),
          reminderAt:
              DateTime.tryParse(json['reminder_at']?.toString() ?? ''),
          pinned: json['pinned'] == true,
        );
      }).toList();
      return DiscourseBookmarkListResult(
        result: true,
        entries: entries,
        hasMore: ub['more_bookmarks_url'] != null,
      );
    } on DiscourseApiException catch (e) {
      return DiscourseBookmarkListResult(
        result: false,
        resultText: e.userMessage,
      );
    } catch (e) {
      return DiscourseBookmarkListResult(
        result: false,
        resultText: 'Error: $e',
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
      // fancy_title (and sometimes excerpt) are entity-encoded —
      // flatten before they land in plain-text fields (Phase 5.47).
      // stripHtmlToText is a no-op on already-plain `title`.
      title: _plain(json['title']?.toString() ??
          json['fancy_title']?.toString() ??
          json['topic_title']?.toString()),
      excerpt: _plain(json['excerpt']?.toString()),
      name: json['name']?.toString(),
      username: json['username']?.toString(),
      avatarUrl: _resolveAvatarUrl(avatarTemplate),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  static String? _plain(String? maybeHtml) =>
      maybeHtml == null ? null : stripHtmlToText(maybeHtml);

  String? _resolveAvatarUrl(String? template, {int size = 90}) {
    if (template == null || template.isEmpty) return null;
    final filled = template.replaceAll('{size}', size.toString());
    if (filled.startsWith('http')) return filled;
    return '${siteContext.site.url}$filled';
  }
}

/// Discourse's `Bookmark.auto_delete_preferences` enum — what happens
/// to a bookmark after its reminder fires or the owner replies.
abstract final class DiscourseBookmarkAutoDelete {
  /// Keep the bookmark (and its reminder timestamp) forever.
  static const int never = 0;

  /// Delete the bookmark as soon as the reminder notification is sent.
  static const int whenReminderSent = 1;

  /// Delete the bookmark when its owner replies to the topic.
  static const int onOwnerReply = 2;

  /// Keep the bookmark but clear `reminder_at` once the reminder fires.
  static const int clearReminder = 3;
}

/// Result of [DiscourseBookmarkProxy.updateBookmarkAsync]. The server
/// returns no payload on success, so this is just success/error.
class DiscourseBookmarkUpdateResult {
  final bool result;
  final String? resultText;

  const DiscourseBookmarkUpdateResult({required this.result, this.resultText});
}

/// One row of [DiscourseBookmarkProxy.getBookmarksWithRemindersAsync]:
/// the SDK-level [FCBookmark] plus the reminder fields it can't carry.
class DiscourseBookmarkEntry {
  final FCBookmark bookmark;

  /// When the reminder notification will fire; null when no reminder is
  /// set (or it already fired under the clear-reminder preference).
  final DateTime? reminderAt;

  /// Pinned to the top of the user's bookmark list.
  final bool pinned;

  const DiscourseBookmarkEntry({
    required this.bookmark,
    this.reminderAt,
    this.pinned = false,
  });
}

/// Result of [DiscourseBookmarkProxy.getBookmarksWithRemindersAsync].
class DiscourseBookmarkListResult {
  final bool result;
  final String? resultText;
  final List<DiscourseBookmarkEntry> entries;

  /// True when the server reported another page (`more_bookmarks_url`).
  final bool hasMore;

  const DiscourseBookmarkListResult({
    required this.result,
    this.resultText,
    this.entries = const [],
    this.hasMore = false,
  });
}
