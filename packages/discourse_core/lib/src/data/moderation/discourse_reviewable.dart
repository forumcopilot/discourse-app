/// Data classes for the Discourse review queue
/// (`GET /review.json` / `PUT /review/{id}/perform/{action_id}.json`,
/// app/controllers/reviewables_controller.rb,
/// app/serializers/reviewable_serializer.rb).

/// One action a moderator can take on a reviewable. Flattened from the
/// response's `bundled_actions[]` (each carrying `action_ids`) joined
/// against the side-loaded top-level `actions[]`
/// (reviewable_bundled_action_serializer.rb /
/// reviewable_action_serializer.rb).
class DiscourseReviewableAction {
  /// Server action id, e.g. `approve_post`, `agree_and_keep`,
  /// `delete_user`. Pass to
  /// `DiscourseModerationProxy.performReviewableActionAsync`.
  final String id;

  /// The bundle this action belongs to (Discourse renders one button
  /// per bundle, with the bundle's extra actions in a dropdown).
  final String bundleId;
  final String? label;
  final String? icon;
  final String? buttonClass;
  final String? description;

  /// When set, the UI should confirm before performing.
  final String? confirmMessage;

  /// True when the server expects a reject reason with this action.
  final bool requireRejectReason;

  DiscourseReviewableAction({
    required this.id,
    required this.bundleId,
    this.label,
    this.icon,
    this.buttonClass,
    this.description,
    this.confirmMessage,
    this.requireRejectReason = false,
  });
}

/// One row of the review queue. `status` is Discourse's integer enum
/// (app/models/reviewable.rb: 0=pending, 1=approved, 2=rejected,
/// 3=ignored, 4=deleted); [statusName] is the readable form.
class DiscourseReviewable {
  final int id;

  /// Reviewable class name, e.g. `ReviewableFlaggedPost`,
  /// `ReviewableQueuedPost`, `ReviewableUser`.
  final String type;
  final int status;
  final DateTime? createdAt;

  /// Concurrency token — pass to `performReviewableActionAsync` so the
  /// server can 409 when another moderator acted first.
  final int version;
  final double score;

  final int? topicId;
  final String? topicTitle;
  final int? categoryId;

  /// What is being reviewed: `Post` / `User` / chat message, plus its
  /// id and (when present) a canonical URL.
  final String? targetType;
  final int? targetId;
  final String? targetUrl;

  /// Username of the user who created the reviewable (e.g. the
  /// flagger), resolved from the side-loaded `users[]`.
  final String? createdByUsername;

  /// Username of the author of the flagged/queued content.
  final String? targetCreatedByUsername;

  /// Type-specific payload (e.g. `raw` for queued posts). Slice of
  /// whatever the concrete reviewable serializer exposes.
  final Map<String, dynamic> payload;

  final List<DiscourseReviewableAction> actions;

  DiscourseReviewable({
    required this.id,
    required this.type,
    required this.status,
    this.createdAt,
    this.version = 0,
    this.score = 0,
    this.topicId,
    this.topicTitle,
    this.categoryId,
    this.targetType,
    this.targetId,
    this.targetUrl,
    this.createdByUsername,
    this.targetCreatedByUsername,
    this.payload = const {},
    this.actions = const [],
  });

  String get statusName {
    switch (status) {
      case 0:
        return 'pending';
      case 1:
        return 'approved';
      case 2:
        return 'rejected';
      case 3:
        return 'ignored';
      case 4:
        return 'deleted';
      default:
        return 'unknown';
    }
  }
}

/// Result of `GET /review.json`.
class DiscourseReviewableListResult {
  final bool result;
  final String resultText;

  /// `meta.total_rows_reviewables` — total rows matching the filters
  /// (the list itself is paged 10 at a time, PER_PAGE in
  /// reviewables_controller.rb).
  final int total;
  final List<DiscourseReviewable> reviewables;

  DiscourseReviewableListResult({
    required this.result,
    this.resultText = '',
    this.total = 0,
    this.reviewables = const [],
  });
}

/// Result of `PUT /review/{id}/perform/{action_id}.json`
/// (reviewable_perform_result_serializer.rb).
class DiscourseReviewablePerformResult {
  final bool result;
  final String resultText;

  /// True when the failure was a 409 version conflict — the reviewable
  /// changed under us and the queue row should be re-fetched.
  final bool conflict;

  /// Reviewable ids the UI should drop from its queue (the acted-on
  /// one plus any the action resolved transitively).
  final List<int> removeReviewableIds;

  /// The reviewable's new version after the action.
  final int? version;

  /// Updated pending counts for the current moderator.
  final int? reviewableCount;
  final int? unseenReviewableCount;

  /// Set when approving a queued post created content.
  final int? createdPostId;
  final int? createdPostTopicId;

  DiscourseReviewablePerformResult({
    required this.result,
    this.resultText = '',
    this.conflict = false,
    this.removeReviewableIds = const [],
    this.version,
    this.reviewableCount,
    this.unseenReviewableCount,
    this.createdPostId,
    this.createdPostTopicId,
  });
}
