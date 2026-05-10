/// A single entry from `/t/{id}.json`'s `suggested_topics` array.
/// Discourse returns a richer object than what we surface — this model
/// keeps just the fields needed to render the "Suggested Topics" footer
/// card and navigate on tap.
class DiscourseSuggestedTopic {
  final int id;
  final String title;
  final String? slug;
  final int? postsCount;

  /// Last activity, as returned by Discourse (`bumped_at` or
  /// `last_posted_at`). Null when the server omits it.
  final DateTime? lastActivity;

  /// Username of the last poster ("posters[].user_id"-resolved). Null
  /// when no posters list was inlined.
  final String? lastPosterUsername;
  final String? lastPosterAvatarTemplate;

  /// True when Discourse marks the topic as having unread posts for the
  /// current user. Drives a small dot on the card.
  final bool hasUnread;

  /// True when the topic has zero posts the current user has read.
  final bool isNew;

  DiscourseSuggestedTopic({
    required this.id,
    required this.title,
    this.slug,
    this.postsCount,
    this.lastActivity,
    this.lastPosterUsername,
    this.lastPosterAvatarTemplate,
    this.hasUnread = false,
    this.isNew = false,
  });

  /// Builds an absolute avatar URL from the Discourse template, or null
  /// when no template is set.
  String? avatarUrl(String forumBaseUrl, {int size = 60}) {
    final tpl = lastPosterAvatarTemplate;
    if (tpl == null || tpl.isEmpty) return null;
    final filled = tpl.replaceAll('{size}', size.toString());
    return filled.startsWith('http') ? filled : '$forumBaseUrl$filled';
  }
}
