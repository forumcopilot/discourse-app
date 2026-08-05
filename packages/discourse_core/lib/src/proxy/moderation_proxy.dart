import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_moderation_proxy.dart';
import 'package:forumcopilot_sdk/models/results/fc_moderation_result.dart';

import '../base_discourse_proxy.dart';
import '../data/moderation/discourse_reviewable.dart';

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
/// - The XF review-queue listings (`getModerateTopic`, `getDeletedPost`,
///   `getReportedPost`, …) stub-fail — Discourse's unified queue is
///   surfaced natively via `getReviewablesAsync` /
///   `performReviewableActionAsync` (`/review.json`) instead.
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
    bool hardDelete = false,
    String? reason,
    bool starterAlert = false,
    String? starterAlertReason,
  }) async {
    // [hardDelete] maps to Discourse's `force_destroy` param
    // (topics_controller.rb#destroy); [reason] and the starter-alert
    // fields are XF-flavored and have no Discourse equivalent, so they
    // are ignored.
    try {
      await apiDelete('/t/$topicId.json',
          query: hardDelete ? {'force_destroy': 'true'} : null);
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

  // ===== Discourse-native review queue (no IFC interface methods) =====

  /// Fetches a page of the moderator review queue.
  ///
  /// `GET /review.json` (reviewables_controller.rb#index). Requires the
  /// signed-in user to be able to see the queue (staff, or a reviewer
  /// group member) — everyone else gets 403.
  ///
  /// [type] filters by reviewable class name (`ReviewableFlaggedPost`,
  /// `ReviewableQueuedPost`, `ReviewableUser`, …); invalid values 400.
  /// [status] is one of `pending` / `approved` / `rejected` / `ignored`
  /// / `deleted` / `reviewed` / `all` (controller `allowed_statuses`).
  /// [offset] is a row offset; the server returns 10 rows per page
  /// (`PER_PAGE`) and the result's `total` carries
  /// `meta.total_rows_reviewables` for "load more" logic.
  Future<DiscourseReviewableListResult> getReviewablesAsync({
    String? type,
    String status = 'pending',
    int offset = 0,
  }) async {
    try {
      final response = await apiGet('/review.json', query: {
        'status': status,
        if (type != null && type.isNotEmpty) 'type': type,
        if (offset > 0) 'offset': offset.toString(),
      });

      // The index renders with `rest_serializer: true`, so associations
      // are side-loaded top-level and rows carry `*_ids` references:
      //   reviewables[].bundled_action_ids → bundled_actions[] (each
      //   with action_ids) → actions[] (label/icon/confirm details),
      //   created_by_id / target_created_by_id → users[],
      //   topic_id → topics[].
      Map<Object?, Map<String, dynamic>> byId(String key) => {
            for (final raw
                in ((response[key] as List?) ?? const []).whereType<Map>())
              raw['id']: raw.cast<String, dynamic>(),
          };
      final users = byId('users');
      final topics = byId('topics');
      final bundles = byId('bundled_actions');
      final actionDetails = byId('actions');

      List<DiscourseReviewableAction> actionsFor(Map<String, dynamic> row) {
        final out = <DiscourseReviewableAction>[];
        for (final bundleId
            in ((row['bundled_action_ids'] as List?) ?? const [])) {
          final bundle = bundles[bundleId];
          if (bundle == null) continue;
          for (final actionId
              in ((bundle['action_ids'] as List?) ?? const [])) {
            final a = actionDetails[actionId] ?? const <String, dynamic>{};
            out.add(DiscourseReviewableAction(
              id: actionId.toString(),
              bundleId: bundleId.toString(),
              label: (a['label'] ?? bundle['label'])?.toString(),
              icon: (a['icon'] ?? bundle['icon'])?.toString(),
              buttonClass: a['button_class']?.toString(),
              description: a['description']?.toString(),
              confirmMessage: a['confirm_message']?.toString(),
              requireRejectReason: a['require_reject_reason'] == true,
            ));
          }
        }
        return out;
      }

      final reviewables = ((response['reviewables'] as List?) ?? const [])
          .whereType<Map>()
          .map((raw) {
            final r = raw.cast<String, dynamic>();
            final topic = topics[r['topic_id']];
            String? usernameOf(Object? userId) =>
                users[userId]?['username']?.toString();
            return DiscourseReviewable(
              id: (r['id'] as num?)?.toInt() ?? 0,
              type: (r['type'] ?? '').toString(),
              status: (r['status'] as num?)?.toInt() ?? 0,
              createdAt:
                  DateTime.tryParse(r['created_at']?.toString() ?? ''),
              version: (r['version'] as num?)?.toInt() ?? 0,
              score: (r['score'] as num?)?.toDouble() ?? 0,
              topicId: (r['topic_id'] as num?)?.toInt(),
              topicTitle: topic?['fancy_title']?.toString() ??
                  topic?['title']?.toString(),
              categoryId: (r['category_id'] as num?)?.toInt(),
              targetType: r['target_type']?.toString(),
              targetId: (r['target_id'] as num?)?.toInt(),
              targetUrl: r['target_url']?.toString(),
              createdByUsername: usernameOf(r['created_by_id']),
              targetCreatedByUsername:
                  usernameOf(r['target_created_by_id']),
              payload:
                  (r['payload'] as Map?)?.cast<String, dynamic>() ?? const {},
              actions: actionsFor(r),
            );
          })
          .toList(growable: false);

      final meta = (response['meta'] as Map?)?.cast<String, dynamic>();
      return DiscourseReviewableListResult(
        result: true,
        total: (meta?['total_rows_reviewables'] as num?)?.toInt() ??
            reviewables.length,
        reviewables: reviewables,
      );
    } on DiscourseApiException catch (e) {
      return DiscourseReviewableListResult(
          result: false, resultText: e.userMessage);
    } catch (e) {
      return DiscourseReviewableListResult(
          result: false, resultText: 'Error: $e');
    }
  }

  /// Performs a moderator action on a reviewable.
  ///
  /// `PUT /review/{id}/perform/{action_id}.json?version=`
  /// (reviewables_controller.rb#perform). [actionId] is a
  /// `DiscourseReviewableAction.id` from [getReviewablesAsync].
  ///
  /// The server REQUIRES `version` (422 `missing_version` when blank —
  /// `version_required` before_action) and 409s with a conflict message
  /// when another moderator changed the reviewable first; the result
  /// flags that case with `conflict: true` so the UI can re-fetch the
  /// row. When [version] is null, the current version is looked up via
  /// `GET /review/{id}.json` first (one extra request).
  Future<DiscourseReviewablePerformResult> performReviewableActionAsync(
    int reviewableId,
    String actionId, {
    int? version,
  }) async {
    try {
      var v = version;
      if (v == null) {
        final show = await apiGet('/review/$reviewableId.json');
        final row =
            (show['reviewable'] as Map?)?.cast<String, dynamic>() ?? const {};
        v = (row['version'] as num?)?.toInt() ?? 0;
      }
      final response = await apiPut(
        '/review/$reviewableId/perform/'
        '${Uri.encodeComponent(actionId)}.json',
        query: {'version': v.toString()},
      );
      // ReviewablePerformResultSerializer, nested under
      // `reviewable_perform_result`.
      final perform = (response['reviewable_perform_result'] as Map?)
              ?.cast<String, dynamic>() ??
          response;
      return DiscourseReviewablePerformResult(
        result: perform['success'] != false,
        removeReviewableIds:
            ((perform['remove_reviewable_ids'] as List?) ?? const [])
                .whereType<num>()
                .map((id) => id.toInt())
                .toList(growable: false),
        version: (perform['version'] as num?)?.toInt(),
        reviewableCount: (perform['reviewable_count'] as num?)?.toInt(),
        unseenReviewableCount:
            (perform['unseen_reviewable_count'] as num?)?.toInt(),
        createdPostId: (perform['created_post_id'] as num?)?.toInt(),
        createdPostTopicId:
            (perform['created_post_topic_id'] as num?)?.toInt(),
      );
    } on DiscourseApiException catch (e) {
      return DiscourseReviewablePerformResult(
        result: false,
        resultText: e.userMessage,
        conflict: e.statusCode == 409,
      );
    } catch (e) {
      return DiscourseReviewablePerformResult(
          result: false, resultText: 'Error: $e');
    }
  }

  // ===== XF review-queue surface =====
  // The XF-shaped listing/approve contracts below don't map cleanly onto
  // Discourse's unified reviewable rows, so they stay stub-failures;
  // Discourse-native callers should use `getReviewablesAsync` /
  // `performReviewableActionAsync` above instead.

  @override
  Future<FCLoginModResult> doLoginModAsync(
          String username, String password) async =>
      // No separate moderator login on Discourse - the User API Key
      // already carries the user's role, so this is a no-op success.
      FCLoginModResult(result: true, resultText: '');

  @override
  Future<FCModerateTopicResult> getModerateTopicAsync(
          int startNum, int lastNum) async =>
      FCModerateTopicResult(
          result: false,
          resultText: 'Moderation queues are not supported on Discourse',
          total: 0,
          list: const []);

  @override
  Future<FCModeratePostResult> getModeratePostAsync(
          int startNum, int lastNum) async =>
      FCModeratePostResult(
          result: false,
          resultText: 'Moderation queues are not supported on Discourse',
          total: 0,
          list: const []);

  @override
  Future<FCDeletedTopicResult> getDeletedTopicAsync(
          int startNum, int lastNum) async =>
      FCDeletedTopicResult(
          result: false,
          resultText: 'Moderation queues are not supported on Discourse',
          total: 0,
          list: const []);

  @override
  Future<FCDeletedPostResult> getDeletedPostAsync(
          int startNum, int lastNum) async =>
      FCDeletedPostResult(
          result: false,
          resultText: 'Moderation queues are not supported on Discourse',
          total: 0,
          list: const []);

  @override
  Future<FCReportedPostResult> getReportedPostAsync(
          int startNum, int lastNum) async =>
      FCReportedPostResult(
          result: false,
          resultText: 'Moderation queues are not supported on Discourse',
          total: 0,
          list: const []);

  @override
  Future<FCApproveTopicResult> approveTopicAsync(String topicId) async =>
      FCApproveTopicResult(
          result: false,
          resultText: 'Moderation queues are not supported on Discourse');

  @override
  Future<FCApprovePostResult> approvePostAsync(String postId) async =>
      FCApprovePostResult(
          result: false,
          resultText: 'Moderation queues are not supported on Discourse');
}
