/// One person behind a post's reactions, as `reactions-users-list.json`
/// (or, without the plugin, `post_action_users.json`) lists them.
///
/// Discourse-only, beside [DiscourseReactionUsersResult]: the SDK's
/// `FCLike` has no display name, and "who reacted" should lead with the
/// name people know each other by, as the web's list does.
class DiscourseReactionUser {
  const DiscourseReactionUser({
    required this.userId,
    required this.username,
    this.name,
    this.avatarUrl = '',
    this.reaction,
  });

  final String userId;
  final String username;

  /// Display name; null or empty when the forum hides names or the person
  /// set none.
  final String? name;

  /// Absolute avatar address, or empty.
  final String avatarUrl;

  /// The reaction's id (an emoji shortcode such as `heart`), or null when
  /// the server did not say (a plain like on a forum without the plugin is
  /// reported as the like).
  final String? reaction;
}

/// A page of [DiscourseReactionUser]s, with the total across all pages.
class DiscourseReactionUsersResult {
  const DiscourseReactionUsersResult({
    required this.result,
    this.resultText = '',
    this.users = const [],
    this.total = 0,
  });

  final bool result;
  final String resultText;
  final List<DiscourseReactionUser> users;
  final int total;
}
