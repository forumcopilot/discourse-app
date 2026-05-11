import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_moderation_proxy.dart';
import 'package:forumcopilot_sdk/models/results/fc_moderation_result.dart';

import '../base_discourse_proxy.dart';

/// Discourse implementation of [IFCModerationProxy].
///
/// Maps the XF/Tapatalk moderation operations to Discourse's REST surface.
/// Most actions live under `/t/{id}/...` or `/posts/{id}/...` and require
/// the User API Key holder to be staff (admin or moderator). The user
/// admin actions (suspend, silence, delete-with-posts) hit
/// `/admin/users/{id}/...`.
///
/// Lossy mappings worth flagging:
/// - `doLoginModAsync` is a no-op success. Discourse has no separate
///   "moderator login" — the User API Key carries the user's role.
/// - `mode` / `reason` parameters that don't fit Discourse's body shape
///   are dropped (the SDK contract is XF-flavored).
/// - The review-queue listings (`getModerateTopic`, `getDeletedPost`,
///   `getReportedPost`, …) live behind `/review.json` which has its own
///   unified shape; for v1 we surface empty lists rather than a half
///   translation. The dedicated review UI in xenforoapp's inherited code
///   was XF-specific anyway.
class DiscourseModerationProxy extends BaseDiscourseProxy
    implements IFCModerationProxy {
  DiscourseModerationProxy(SiteContext context) : super(context);

  // ===== Topic status toggles =====

  @override
  Future<FCStickTopicResult> stickTopicAsync(String topicId) async {
    return _setStatus(topicId,
        status: 'pinned',
        enabled: true,
        successResult: () => FCStickTopicResult(result: true, resultText: ''),
        errorResult: (m) => FCStickTopicResult(result: false, resultText: m));
  }

  @override
  Future<FCStickTopicResult> unstickTopicAsync(String topicId) async {
    return _setStatus(topicId,
        status: 'pinned',
        enabled: false,
        successResult: () => FCStickTopicResult(result: true, resultText: ''),
        errorResult: (m) => FCStickTopicResult(result: false, resultText: m));
  }

  @override
  Future<FCCloseTopicResult> closeTopicAsync(String topicId) async {
    return _setStatus(topicId,
        status: 'closed',
        enabled: true,
        successResult: () => FCCloseTopicResult(
            result: true, resultText: '', isLoginMod: true),
        errorResult: (m) => FCCloseTopicResult(
            result: false, resultText: m, isLoginMod: true));
  }

  @override
  Future<FCCloseTopicResult> uncloseTopicAsync(String topicId) async {
    return _setStatus(topicId,
        status: 'closed',
        enabled: false,
        successResult: () => FCCloseTopicResult(
            result: true, resultText: '', isLoginMod: true),
        errorResult: (m) => FCCloseTopicResult(
            result: false, resultText: m, isLoginMod: true));
  }

  @override
  Future<FCDeleteTopicResult> archiveTopicAsync(
    String topicId, {
    required bool archived,
  }) async {
    return _setStatus(
      topicId,
      status: 'archived',
      enabled: archived,
      successResult: () =>
          FCDeleteTopicResult(result: true, resultText: '', isLoginMod: true),
      errorResult: (m) =>
          FCDeleteTopicResult(result: false, resultText: m, isLoginMod: true),
    );
  }

  @override
  Future<FCDeleteTopicResult> setTopicVisibilityAsync(
    String topicId, {
    required bool visible,
  }) async {
    return _setStatus(
      topicId,
      status: 'visible',
      enabled: visible,
      successResult: () =>
          FCDeleteTopicResult(result: true, resultText: '', isLoginMod: true),
      errorResult: (m) =>
          FCDeleteTopicResult(result: false, resultText: m, isLoginMod: true),
    );
  }

  // ===== Topic delete / restore =====

  @override
  Future<FCDeleteTopicResult> deleteTopicAsync(
      String topicId, int mode, String reason) async {
    // Discourse: DELETE /t/{id}.json soft-deletes (recoverable).
    // mode / reason are XF-specific; ignored.
    try {
      await apiDelete('/t/$topicId.json');
      return FCDeleteTopicResult(
          result: true, resultText: '', isLoginMod: true);
    } on DiscourseApiException catch (e) {
      return FCDeleteTopicResult(
          result: false, resultText: e.userMessage, isLoginMod: true);
    } catch (e) {
      return FCDeleteTopicResult(
          result: false, resultText: 'Error: $e', isLoginMod: true);
    }
  }

  @override
  Future<FCUndeleteTopicResult> undeleteTopicAsync(
      String topicId, String reason) async {
    try {
      await apiPut('/t/$topicId/recover.json');
      return FCUndeleteTopicResult(
          result: true, resultText: '', isLoginMod: true);
    } on DiscourseApiException catch (e) {
      return FCUndeleteTopicResult(
          result: false, resultText: e.userMessage, isLoginMod: true);
    } catch (e) {
      return FCUndeleteTopicResult(
          result: false, resultText: 'Error: $e', isLoginMod: true);
    }
  }

  // ===== Post delete / restore =====

  @override
  Future<FCDeletePostResult> deletePostAsync(
      String postId, int mode, String reason) async {
    try {
      await apiDelete('/posts/$postId.json');
      return FCDeletePostResult(
          result: true, resultText: '', isLoginMod: true);
    } on DiscourseApiException catch (e) {
      return FCDeletePostResult(
          result: false, resultText: e.userMessage, isLoginMod: true);
    } catch (e) {
      return FCDeletePostResult(
          result: false, resultText: 'Error: $e', isLoginMod: true);
    }
  }

  @override
  Future<FCUndeletePostResult> undeletePostAsync(
      String postId, String reason) async {
    try {
      await apiPut('/posts/$postId/recover.json');
      return FCUndeletePostResult(
          result: true, resultText: '', isLoginMod: true);
    } on DiscourseApiException catch (e) {
      return FCUndeletePostResult(
          result: false, resultText: e.userMessage, isLoginMod: true);
    } catch (e) {
      return FCUndeletePostResult(
          result: false, resultText: 'Error: $e', isLoginMod: true);
    }
  }

  // ===== Move / rename / merge =====

  @override
  Future<FCMoveTopicResult> moveTopicAsync(
      String topicId, String forumId, bool redirect) async {
    // Discourse moves a topic to another category by PUTting
    // /t/{id}.json with the target category_id. `redirect` (XF: leave a
    // forwarding link in old forum) has no Discourse equivalent.
    try {
      await apiPut('/t/$topicId.json', body: {
        'category_id': int.tryParse(forumId) ?? forumId,
      });
      return FCMoveTopicResult(result: true, resultText: '', isLoginMod: true);
    } on DiscourseApiException catch (e) {
      return FCMoveTopicResult(
          result: false, resultText: e.userMessage, isLoginMod: true);
    } catch (e) {
      return FCMoveTopicResult(
          result: false, resultText: 'Error: $e', isLoginMod: true);
    }
  }

  @override
  Future<FCRenameTopicResult> renameTopicAsync(
      String topicId, String title) async {
    try {
      await apiPut('/t/$topicId.json', body: {'title': title});
      return FCRenameTopicResult(
          result: true, resultText: '', isLoginMod: true);
    } on DiscourseApiException catch (e) {
      return FCRenameTopicResult(
          result: false, resultText: e.userMessage, isLoginMod: true);
    } catch (e) {
      return FCRenameTopicResult(
          result: false, resultText: 'Error: $e', isLoginMod: true);
    }
  }

  @override
  Future<FCMovePostResult> movePostAsync(String postId, String? topicId,
      String? topicTitle, String? forumId) async {
    // Discourse: POST /t/{src_topic_id}/move-posts.json
    //   { post_ids: [<post>], destination_topic_id: <target?>, title: <new?>,
    //     category_id: <cat?>, archetype: 'regular' }
    // We don't have the source topic_id here — look it up first.
    try {
      final post = await apiGet('/posts/$postId.json');
      final srcTopicId = post['topic_id'];
      if (srcTopicId == null) {
        return FCMovePostResult(
            result: false,
            resultText: 'Could not resolve source topic',
            isLoginMod: true);
      }
      final body = <String, dynamic>{
        'post_ids': [int.tryParse(postId) ?? postId],
        'archetype': 'regular',
      };
      if (topicId != null && topicId.isNotEmpty) {
        body['destination_topic_id'] = int.tryParse(topicId) ?? topicId;
      } else if (topicTitle != null && topicTitle.isNotEmpty) {
        body['title'] = topicTitle;
        if (forumId != null && forumId.isNotEmpty) {
          body['category_id'] = int.tryParse(forumId) ?? forumId;
        }
      }
      await apiPost('/t/$srcTopicId/move-posts.json', body: body);
      return FCMovePostResult(result: true, resultText: '', isLoginMod: true);
    } on DiscourseApiException catch (e) {
      return FCMovePostResult(
          result: false, resultText: e.userMessage, isLoginMod: true);
    } catch (e) {
      return FCMovePostResult(
          result: false, resultText: 'Error: $e', isLoginMod: true);
    }
  }

  @override
  Future<FCMergeTopicResult> mergeTopicAsync(
      String topicId1, String topicId2, bool redirect) async {
    // Merge "topicId2 → topicId1": move all of topic2's posts to topic1.
    // Discourse: POST /t/{topicId2}/merge-topic.json with { destination_topic_id: <id1> }.
    try {
      await apiPost('/t/$topicId2/merge-topic.json', body: {
        'destination_topic_id': int.tryParse(topicId1) ?? topicId1,
      });
      return FCMergeTopicResult(result: true, resultText: '', isLoginMod: true);
    } on DiscourseApiException catch (e) {
      return FCMergeTopicResult(
          result: false, resultText: e.userMessage, isLoginMod: true);
    } catch (e) {
      return FCMergeTopicResult(
          result: false, resultText: 'Error: $e', isLoginMod: true);
    }
  }

  // ===== User moderation =====

  @override
  Future<FCBanUserResult> banUserAsync(String userName, String reason,
      int banExpires, int deletePostMode, int deletePostValue) async {
    // Resolve username → user id (admin endpoint requires id).
    final userId = await _resolveUserId(userName);
    if (userId == null) {
      return FCBanUserResult(
          result: false,
          resultText: 'User not found: $userName',
          isLoginMod: true);
    }
    // banExpires semantics: SDK passes seconds-from-now or 0 for
    // permanent. Discourse expects an absolute ISO-8601 timestamp;
    // permanent suspension uses a far-future date.
    final until = banExpires > 0
        ? DateTime.now().add(Duration(seconds: banExpires)).toUtc()
        : DateTime.utc(3000, 1, 1);
    try {
      await apiPut('/admin/users/$userId/suspend.json', body: {
        'suspend_until': until.toIso8601String(),
        'reason': reason,
      });
      return FCBanUserResult(result: true, resultText: '', isLoginMod: true);
    } on DiscourseApiException catch (e) {
      return FCBanUserResult(
          result: false, resultText: e.userMessage, isLoginMod: true);
    } catch (e) {
      return FCBanUserResult(
          result: false, resultText: 'Error: $e', isLoginMod: true);
    }
  }

  @override
  Future<FCUnbanUserResult> unbanUserAsync(String userId) async {
    final id = int.tryParse(userId);
    if (id == null) {
      return FCUnbanUserResult(
          result: false,
          resultText: 'Numeric user id required',
          isLoginMod: true);
    }
    try {
      await apiPut('/admin/users/$id/unsuspend.json');
      return FCUnbanUserResult(result: true, resultText: '', isLoginMod: true);
    } on DiscourseApiException catch (e) {
      return FCUnbanUserResult(
          result: false, resultText: e.userMessage, isLoginMod: true);
    } catch (e) {
      return FCUnbanUserResult(
          result: false, resultText: 'Error: $e', isLoginMod: true);
    }
  }

  @override
  Future<FCMarkAsSpamResult> markAsSpamAsync(String userId) async {
    // Discourse's closest analogue is "silence" — silenced users can't
    // post but their account is intact. Mark-as-spam typically also
    // deletes their posts; that's spamCleanUserAsync.
    final id = int.tryParse(userId);
    if (id == null) {
      return FCMarkAsSpamResult(
          result: false,
          resultText: 'Numeric user id required',
          isLoginMod: true);
    }
    try {
      await apiPut('/admin/users/$id/silence.json', body: {
        'reason': 'Marked as spam by mobile app',
      });
      return FCMarkAsSpamResult(
          result: true, resultText: '', isLoginMod: true);
    } on DiscourseApiException catch (e) {
      return FCMarkAsSpamResult(
          result: false, resultText: e.userMessage, isLoginMod: true);
    } catch (e) {
      return FCMarkAsSpamResult(
          result: false, resultText: 'Error: $e', isLoginMod: true);
    }
  }

  @override
  Future<FCSpamCleanUserResult> spamCleanUserAsync({
    String? userId,
    String? username,
    bool actionThreads = false,
    bool deleteMessages = false,
    bool deleteConversations = false,
    bool banUser = false,
  }) async {
    int? id = userId == null ? null : int.tryParse(userId);
    id ??= username == null ? null : await _resolveUserId(username);
    if (id == null) {
      return FCSpamCleanUserResult(
        result: false,
        resultText: 'User not found',
      );
    }
    try {
      // First silence (or suspend, if banUser=true).
      if (banUser) {
        await apiPut('/admin/users/$id/suspend.json', body: {
          'suspend_until': DateTime.utc(3000, 1, 1).toIso8601String(),
          'reason': 'Spam cleanup',
        });
      } else {
        await apiPut('/admin/users/$id/silence.json', body: {
          'reason': 'Spam cleanup',
        });
      }
      // Then delete the account with their posts when requested.
      if (actionThreads || deleteMessages || deleteConversations) {
        await apiDelete('/admin/users/$id.json', query: {
          'delete_posts': 'true',
        });
      }
      return FCSpamCleanUserResult(result: true, resultText: '');
    } on DiscourseApiException catch (e) {
      return FCSpamCleanUserResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCSpamCleanUserResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCDeleteTopicResult> deleteTopicExtendedAsync(
    String topicId, {
    bool deleteForReal = false,
  }) async {
    try {
      await apiDelete('/t/$topicId.json',
          query: deleteForReal ? {'delete_for_real': 'true'} : null);
      return FCDeleteTopicResult(
          result: true, resultText: '', isLoginMod: true);
    } on DiscourseApiException catch (e) {
      return FCDeleteTopicResult(
          result: false, resultText: e.userMessage, isLoginMod: true);
    } catch (e) {
      return FCDeleteTopicResult(
          result: false, resultText: 'Error: $e', isLoginMod: true);
    }
  }

  // ===== Helpers =====

  Future<R> _setStatus<R>(
    String topicId, {
    required String status,
    required bool enabled,
    required R Function() successResult,
    required R Function(String message) errorResult,
  }) async {
    try {
      await apiPut('/t/$topicId/status.json', body: {
        'status': status,
        'enabled': enabled.toString(),
      });
      return successResult();
    } on DiscourseApiException catch (e) {
      return errorResult(e.userMessage);
    } catch (e) {
      return errorResult('Error: $e');
    }
  }

  Future<int?> _resolveUserId(String username) async {
    if (username.isEmpty) return null;
    try {
      final response =
          await apiGet('/u/${Uri.encodeComponent(username)}.json');
      final user = response['user'] as Map<String, dynamic>?;
      final id = user?['id'];
      return id is int ? id : (id is String ? int.tryParse(id) : null);
    } catch (_) {
      return null;
    }
  }
}
