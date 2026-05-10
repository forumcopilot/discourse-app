/// Per-post voting state from the `discourse-post-voting` plugin.
/// Populated on each post in a Q&A-style topic; null/zero on regular
/// topics or when the plugin isn't installed.
class DiscoursePostVote {
  /// Net score (upvotes − downvotes).
  final int voteCount;

  /// Whether the post has any votes at all (used by the renderer to
  /// suppress the score chip when nobody's voted yet).
  final bool hasVotes;

  /// The viewer's vote direction on this post: 'up', 'down', or null
  /// when they haven't voted.
  final String? viewerDirection;

  const DiscoursePostVote({
    this.voteCount = 0,
    this.hasVotes = false,
    this.viewerDirection,
  });

  factory DiscoursePostVote.fromJson(Map<String, dynamic> json) {
    return DiscoursePostVote(
      voteCount: (json['post_voting_vote_count'] as num?)?.toInt() ?? 0,
      hasVotes: json['post_voting_has_votes'] == true,
      viewerDirection: json['post_voting_user_voted_direction']?.toString(),
    );
  }

  bool get viewerVotedUp => viewerDirection == 'up';
  bool get viewerVotedDown => viewerDirection == 'down';
  bool get viewerVoted => viewerDirection != null;

  DiscoursePostVote copyWith({
    int? voteCount,
    bool? hasVotes,
    String? viewerDirection,
    bool clearViewer = false,
  }) =>
      DiscoursePostVote(
        voteCount: voteCount ?? this.voteCount,
        hasVotes: hasVotes ?? this.hasVotes,
        viewerDirection:
            clearViewer ? null : (viewerDirection ?? this.viewerDirection),
      );
}
