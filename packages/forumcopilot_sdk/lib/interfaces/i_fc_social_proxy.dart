import '../models/results/fc_social_result.dart';

/// Social operations exposed to the app.
///
/// Trimmed Discourse-native surface. The XF-flavored `thankPostAsync`
/// is gone — Discourse has likes + (optionally) emoji reactions, no
/// separate "thanks" concept. PM-message likes are also dropped:
/// Discourse PMs don't support likes. Follow/unfollow stay here for
/// SDK compatibility, but the Discourse implementation lives on
/// `DiscourseUserProxy.followUserAsync` / `unfollowUserAsync` (Phase
/// 5.8) since Discourse's follow endpoint is keyed by username, not
/// user id.
abstract class IFCSocialProxy {
  /// Follow a user by id. Discourse-native callers should prefer
  /// `DiscourseUserProxy.followUserAsync(username)`.
  Future<FCFollowResult> followAsync(String userId);

  /// Unfollow a user by id. Discourse-native callers should prefer
  /// `DiscourseUserProxy.unfollowUserAsync(username)`.
  Future<FCUnfollowResult> unfollowAsync(String userId);

  /// Like a post.
  Future<FCLikePostResult> likePostAsync(String postId);

  /// Remove a like from a post.
  Future<FCUnlikePostResult> unlikePostAsync(String postId);

  /// Get user alerts (notifications).
  Future<FCAlertResult> getAlertAsync(int page, int perpage, bool forceRefresh);

  /// Get user activity stream.
  Future<FCActivityResult> getActivityAsync(int page, int perpage);
}
