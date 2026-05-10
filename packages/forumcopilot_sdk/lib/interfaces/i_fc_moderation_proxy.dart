import '../models/results/fc_moderation_result.dart';

/// Moderation operations exposed to the app.
///
/// This is the trimmed Discourse-native surface. The XF/Tapatalk
/// review-queue methods (getModerateTopic/Post, getDeleted*, getReported*,
/// approveTopic/Post, doLoginMod) have been dropped — Discourse's review
/// queue lives at `/review.json` with a unified shape that doesn't map
/// onto these signatures, and no UI in `lib/` ever called them. If the
/// review queue is wired in a future phase it should land as new
/// Discourse-shaped methods, not the inherited XF ones.
abstract class IFCModerationProxy {
  // ===== Topic status toggles =====

  /// Stick (pin) a topic.
  Future<FCStickTopicResult> stickTopicAsync(String topicId);

  /// Unstick a topic.
  Future<FCStickTopicResult> unstickTopicAsync(String topicId);

  /// Close a topic (prevent replies).
  Future<FCCloseTopicResult> closeTopicAsync(String topicId);

  /// Reopen a closed topic.
  Future<FCCloseTopicResult> uncloseTopicAsync(String topicId);

  // ===== Delete / restore =====

  /// Soft-delete a topic. `mode` / `reason` are XF-flavored and ignored
  /// by the Discourse implementation.
  Future<FCDeleteTopicResult> deleteTopicAsync(
      String topicId, int mode, String reason);

  /// Soft-delete a post. `mode` / `reason` are XF-flavored.
  Future<FCDeletePostResult> deletePostAsync(
      String postId, int mode, String reason);

  /// Restore a previously-deleted topic.
  Future<FCUndeleteTopicResult> undeleteTopicAsync(
      String topicId, String reason);

  /// Restore a previously-deleted post.
  Future<FCUndeletePostResult> undeletePostAsync(
      String postId, String reason);

  // ===== Move / rename / merge =====

  /// Move a topic into another category. `redirect` (XF "leave
  /// forwarding link") has no Discourse equivalent.
  Future<FCMoveTopicResult> moveTopicAsync(
      String topicId, String forumId, bool redirect);

  /// Rename a topic.
  Future<FCRenameTopicResult> renameTopicAsync(String topicId, String title);

  /// Move a post into another topic (split). Pass either a destination
  /// topic id or a new topic title + category.
  Future<FCMovePostResult> movePostAsync(String postId, String? topicId,
      String? topicTitle, String? forumId);

  /// Merge `topicId2` into `topicId1` (move topic2's posts to topic1).
  Future<FCMergeTopicResult> mergeTopicAsync(
      String topicId1, String topicId2, bool redirect);

  // ===== User moderation =====

  /// Suspend a user.
  Future<FCBanUserResult> banUserAsync(
      String userName,
      String reason,
      int banExpires,
      int deletePostMode,
      int deletePostValue);

  /// Lift a user suspension.
  Future<FCUnbanUserResult> unbanUserAsync(String userId);

  /// Silence a user (Discourse: can't post, account intact).
  Future<FCMarkAsSpamResult> markAsSpamAsync(String userId);

  /// Suspend (or silence) + optionally delete the user's content.
  Future<FCSpamCleanUserResult> spamCleanUserAsync({
    String? userId,
    String? username,
    bool actionThreads = false,
    bool deleteMessages = false,
    bool deleteConversations = false,
    bool banUser = false,
  });
}
