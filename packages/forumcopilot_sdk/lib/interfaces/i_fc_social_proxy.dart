import '../models/results/fc_social_result.dart';

/// Social operations exposed to the app.
///
/// Trimmed Discourse-native surface. The XF-flavored `thankPostAsync`
/// is gone — Discourse has likes + (optionally) emoji reactions, no
/// separate "thanks" concept. PM-message likes are also dropped:
/// Discourse PMs don't support likes.
///
/// Phase 5.30 — follow/unfollow are now first-class on this
/// interface (Discourse implementation lives in
/// `DiscourseSocialProxy`). The earlier
/// `DiscourseUserProxy.followUserAsync/unfollowUserAsync` sidecar
/// was deleted because it duplicated the contract.
abstract class IFCSocialProxy {
  /// Follow the user identified by [username]. Implementations may
  /// interpret the identifier however their backend requires —
  /// Discourse uses the username directly against its `/follow/{u}`
  /// endpoint (the discourse-follow plugin); XF-shaped backends
  /// would resolve the username to a user id internally.
  Future<FCFollowResult> followAsync(String username);

  /// Stop following the user identified by [username]. Mirrors
  /// [followAsync] — same identifier conventions.
  Future<FCUnfollowResult> unfollowAsync(String username);

  /// Like a post.
  Future<FCLikePostResult> likePostAsync(String postId);

  /// Remove a like from a post.
  Future<FCUnlikePostResult> unlikePostAsync(String postId);

  /// Get user alerts (notifications).
  Future<FCAlertResult> getAlertAsync(int page, int perpage, bool forceRefresh);

  /// Get user activity stream.
  Future<FCActivityResult> getActivityAsync(int page, int perpage);
}
