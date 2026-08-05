import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/models/entities/fc_poll.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post.dart';
import 'package:get/get.dart';
import '../models/thread_view_data.dart';
import 'global_loader_controller.dart';
import 'package:discourse_ui/core/errors/error_handling_mixins.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';

enum LoadMode { initial, earlier, later }

class PostController extends DiscourseGlobalLoaderController with ErrorHandlingMixin {
  // Observable state to track initialization
  var isInitialized = false.obs;
  final Rx<ThreadViewData?> threadDataOutput = Rx<ThreadViewData?>(null);

  // Stream subscriptions for cleanup
  StreamSubscription? _threadDataSubscription;

  /// Applies thread data and isInitialized in the next frame to avoid
  /// setState/markNeedsBuild while the widget tree is locked (e.g. after route pop).
  Future<void> _applyThreadDataOnNextFrame(ThreadViewData data) async {
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      threadDataOutput.value = data;
      isInitialized.value = true;
      if (!completer.isCompleted) completer.complete();
    });
    await completer.future;
  }

  /// Merges [existing] and [incoming] posts, deduping by post id and keeping
  /// the result sorted by postNumber. The server does not guarantee
  /// page-aligned windows, so overlap between fetches is expected — incoming
  /// posts win on conflict (fresher data).
  static List<FCPost> _mergePosts(List<FCPost> existing, List<FCPost> incoming) {
    final byId = <String, FCPost>{};
    for (final p in existing) {
      byId[p.id] = p;
    }
    for (final p in incoming) {
      byId[p.id] = p;
    }
    final merged = byId.values.toList()
      ..sort((a, b) => (a.postNumber ?? 0).compareTo(b.postNumber ?? 0));
    return merged;
  }

  /// 0-based index of the first loaded post, derived from the ACTUAL returned
  /// posts' postNumber (1-based) rather than assuming the server honored the
  /// requested window exactly. [fallback] is used when no postNumber is
  /// available (should not happen for Discourse).
  static int _startNumFromPosts(List<FCPost> posts, int fallback) {
    if (posts.isEmpty) return fallback;
    final minPn = posts.first.postNumber;
    if (minPn == null || minPn < 1) return fallback;
    return minPn - 1;
  }

  /// 1-based post number of the last loaded post (used for [ThreadViewData.position]).
  static int _lastPostNumber(List<FCPost> posts, int startNum0Based) {
    if (posts.isEmpty) return startNum0Based;
    return posts.last.postNumber ?? (startNum0Based + posts.length);
  }

  Future<void> getThreadAsync(String topicId, int startNum, int lastNum, bool returnHtml, {LoadMode mode = LoadMode.initial}) async {
    try {
      // Note: startNum and lastNum here are in the format expected by the proxy/API.
      // For Discourse: API expects 1-based (position 1 = first post), so proxy
      // passes 1-based.
      // Internally, we store currentStartNum as 0-based for easier calculations.

      var postProxy = SiteProxyService.getPostProxy();
      var threadsResult = await postProxy.getThreadAsync(topicId, startNum, lastNum, returnHtml);

      // The proxy now returns FCPost objects directly, no conversion needed
      final fcPosts = threadsResult.posts;
      
      // Log warning if posts are empty (for all modes, but especially important for initial load)
      if (fcPosts.isEmpty) {
        AppLogger.warning('⚠️ [PostController] getThreadAsync returned empty posts list');
        AppLogger.warning('   Topic ID: $topicId');
        AppLogger.warning('   Load Mode: $mode');
        AppLogger.warning('   Start Num: $startNum, Last Num: $lastNum');
        AppLogger.warning('   Total Posts (from API): ${threadsResult.totalPostNum}');
        AppLogger.warning('   Thread Title: ${threadsResult.title}');
        AppLogger.warning('   Result: ${threadsResult.result}, Result Text: ${threadsResult.resultText}');
      }

      // Derive the loaded window from the ACTUAL returned posts (sorted,
      // deduped by id) — the server's window is not guaranteed to match the
      // requested [startNum, lastNum] or be page-aligned.
      final sortedNew = _mergePosts(const [], fcPosts);

      final ThreadViewData newData;
      if (mode == LoadMode.initial || threadDataOutput.value == null) {
        final newStartNum = _startNumFromPosts(sortedNew, startNum - 1);
        newData = ThreadViewData(
          topic: threadsResult,
          posts: sortedNew,
          currentStartNum: newStartNum, // 0-based, derived from min postNumber
          position: _lastPostNumber(sortedNew, newStartNum),
        );
      } else {
        final existing = threadDataOutput.value!;
        final mergedPosts = _mergePosts(existing.posts, sortedNew);
        final newStartNum = _startNumFromPosts(mergedPosts, existing.currentStartNum);
        newData = ThreadViewData(
          topic: threadsResult,
          posts: mergedPosts,
          currentStartNum: newStartNum, // 0-based, derived from min postNumber
          position: _lastPostNumber(mergedPosts, newStartNum),
        );
      }

      await _applyThreadDataOnNextFrame(newData);
    } catch (e, stackTrace) {
      await handleError(e, stackTrace, context: 'PostController.getThreadAsync');
      rethrow;
    }
  }

  Future<void> getThreadByUnreadAsync(String topicId, int postsPerRequest, bool returnHtml) async {
    try {
      var postProxy = SiteProxyService.getPostProxy();
      var threadsResult = await postProxy.getThreadByUnreadAsync(topicId, postsPerRequest, returnHtml);
      AppLogger.debug('getThreadByUnreadAsync result: ${threadsResult.toString()}');

      // Set post_level for each post
      final position = threadsResult.position; // 1-based index of first unread post

      // The proxy now returns FCPost objects directly, no conversion needed.
      // Sort/dedupe and derive the window start from the actual returned
      // posts — the server window around the anchor is not page-aligned.
      final fcPosts = _mergePosts(const [], threadsResult.posts);
      final currentStartNum =
          _startNumFromPosts(fcPosts, (position - 1).clamp(0, 1 << 30));
      
      // Log warning if posts are empty
      if (fcPosts.isEmpty) {
        AppLogger.warning('⚠️ [PostController] getThreadByUnreadAsync returned empty posts list');
        AppLogger.warning('   Topic ID: $topicId');
        AppLogger.warning('   Posts Per Request: $postsPerRequest');
        AppLogger.warning('   Position: $position');
        AppLogger.warning('   Total Posts (from API): ${threadsResult.totalPostNum}');
        AppLogger.warning('   Result: ${threadsResult.result}, Result Text: ${threadsResult.resultText}');
      }

      final newData = ThreadViewData(
        topic: threadsResult,
        posts: fcPosts,
        currentStartNum: currentStartNum,
        position: position,
      );
      await _applyThreadDataOnNextFrame(newData);
    } catch (e, stackTrace) {
      await handleError(e, stackTrace, context: 'PostController.getThreadByUnreadAsync');
      rethrow;
    }
  }

  Future<void> getThreadByPostAsync(String postId, int postsPerRequest, bool returnHtml) async {
    try {
      AppLogger.debug('🔍 [PostController] getThreadByPostAsync called: postId=$postId, postsPerRequest=$postsPerRequest');
      var postProxy = SiteProxyService.getPostProxy();
      var threadsResult = await postProxy.getThreadByPostAsync(postId, postsPerRequest, returnHtml);
      AppLogger.debug('🔍 [PostController] getThreadByPostAsync result: ${threadsResult.toString()}');

      // Set post_level for each post
      final position = threadsResult.position; // 1-based index of anchor post
      AppLogger.debug('🔍 [PostController] Position from API (1-based): $position');

      // The proxy now returns FCPost objects directly, no conversion needed.
      // Sort/dedupe and derive the window start from the actual returned
      // posts — the server window around the anchor is not page-aligned.
      final fcPosts = _mergePosts(const [], threadsResult.posts);
      final currentStartNum =
          _startNumFromPosts(fcPosts, (position - 1).clamp(0, 1 << 30));
      AppLogger.debug('🔍 [PostController] Derived currentStartNum (0-based): $currentStartNum from loaded window (anchor position $position)');
      AppLogger.debug('🔍 [PostController] Received ${fcPosts.length} posts');
      
      // Log warning if posts are empty
      if (fcPosts.isEmpty) {
        AppLogger.warning('⚠️ [PostController] getThreadByPostAsync returned empty posts list');
        AppLogger.warning('   Post ID: $postId');
        AppLogger.warning('   Posts Per Request: $postsPerRequest');
        AppLogger.warning('   Position: $position');
        AppLogger.warning('   Total Posts (from API): ${threadsResult.totalPostNum}');
        AppLogger.warning('   Result: ${threadsResult.result}, Result Text: ${threadsResult.resultText}');
      }

      // Log post IDs and postNumbers for debugging
      for (int i = 0; i < fcPosts.length && i < 5; i++) {
        final post = fcPosts[i];
        AppLogger.debug('🔍 [PostController] Post[$i]: id=${post.id}, postNumber=${post.postNumber}');
      }
      if (fcPosts.length > 5) {
        AppLogger.debug('🔍 [PostController] ... and ${fcPosts.length - 5} more posts');
      }

      final newData = ThreadViewData(
        topic: threadsResult,
        posts: fcPosts,
        currentStartNum: currentStartNum,
        position: position,
      );
      await _applyThreadDataOnNextFrame(newData);
    } catch (e, stackTrace) {
      await handleError(e, stackTrace, context: 'PostController.getThreadByPostAsync');
      rethrow;
    }
  }

  /// Replaces the current thread's poll with the updated poll (e.g. after voting).
  /// Keeps posts and position unchanged.
  /// Defers the update to the next frame to avoid markNeedsBuild while tree is locked.
  void updateThreadPoll(FCPoll poll) {
    final current = threadDataOutput.value;
    if (current == null) return;
    final updatedTopic = current.topic.copyWith(poll: poll, hasPoll: true);
    final newData = ThreadViewData(
      topic: updatedTopic,
      posts: current.posts,
      currentStartNum: current.currentStartNum,
      position: current.position,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      threadDataOutput.value = newData;
    });
  }

  /// Loads a specific page of posts by page number (1-based).
  ///
  /// Calculates startNum and lastNum based on the page number and page size, then calls getThreadAsync.
  /// Example: gotoPage = (totalPostNum-1)/postPerPage+1;
  ///
  /// Note: The API expects startNum and lastNum to be 1-based (position 1 = first post).
  /// getThreadAsync will convert to 0-based for internal storage.
  Future<void> getThreadByPageAsync(String topicId, int gotoPage, int postsPerPage, bool returnHtml) async {
    try {
      // Calculate startNum and lastNum for the requested page
      // gotoPage is 1-based: page 1 = posts 1-20, page 2 = posts 21-40, etc.
      // For page 11: startNum = (11-1)*20 + 1 = 201 (1-based)
      // The API expects 1-based, so we calculate in 1-based
      final startNum1Based = (gotoPage - 1) * postsPerPage + 1;
      final lastNum1Based = startNum1Based + postsPerPage - 1;

      // Pass 1-based to getThreadAsync (which will convert internally)
      await getThreadAsync(topicId, startNum1Based, lastNum1Based, returnHtml, mode: LoadMode.initial);
    } catch (e, stackTrace) {
      await handleError(e, stackTrace, context: 'PostController.getThreadByPageAsync');
      rethrow;
    }
  }

  @override
  void onClose() {
    // Cleanup resources to prevent memory leaks
    _threadDataSubscription?.cancel();
    _threadDataSubscription = null;

    // Clear reactive variables
    isInitialized.value = false;
    threadDataOutput.value = null;

    super.onClose();
  }
}
