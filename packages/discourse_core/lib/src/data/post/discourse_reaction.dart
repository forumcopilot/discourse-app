/// A single emoji reaction on a Discourse post, as exposed by the
/// `discourse-reactions` plugin (`reactions: []` field on the post
/// payload). Each entry describes one emoji and how many users reacted
/// with it.
class DiscourseReaction {
  /// The reaction id — for stock plugin reactions this is the emoji
  /// shortcode (e.g. "heart", "tada", "rocket"). On forums with
  /// `discourse_reactions_allow_any_emoji` enabled it can be any valid
  /// emoji shortcode.
  final String id;

  /// Reaction type — almost always 'emoji'.
  final String type;

  /// Number of users who reacted with this emoji.
  final int count;

  /// True when the current user has applied this reaction. Discourse
  /// only allows one reaction per user per post, so at most one entry
  /// in a post's reaction list can have [viewerReacted] == true.
  final bool viewerReacted;

  /// Whether the viewer is allowed to remove this reaction (rate-limit
  /// window: typically 1 minute after applying on most forums).
  final bool canUndo;

  const DiscourseReaction({
    required this.id,
    this.type = 'emoji',
    required this.count,
    this.viewerReacted = false,
    this.canUndo = false,
  });

  /// Build from the post JSON's `reactions[]` entry. The viewer
  /// reaction is matched against the post-level `current_user_reaction`
  /// field by id.
  factory DiscourseReaction.fromJson(
    Map<String, dynamic> json, {
    String? viewerReactionId,
    bool? viewerCanUndo,
  }) {
    final id = (json['id'] ?? '').toString();
    final isViewer = viewerReactionId != null && viewerReactionId == id;
    return DiscourseReaction(
      id: id,
      type: (json['type'] ?? 'emoji').toString(),
      count: (json['count'] as num?)?.toInt() ?? 0,
      viewerReacted: isViewer,
      canUndo: isViewer ? (viewerCanUndo ?? true) : false,
    );
  }

  DiscourseReaction copyWith({
    int? count,
    bool? viewerReacted,
    bool? canUndo,
  }) =>
      DiscourseReaction(
        id: id,
        type: type,
        count: count ?? this.count,
        viewerReacted: viewerReacted ?? this.viewerReacted,
        canUndo: canUndo ?? this.canUndo,
      );
}
