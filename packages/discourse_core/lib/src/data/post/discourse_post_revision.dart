/// A single edit revision of a post, from
/// `/posts/{id}/revisions/latest.json` or `/posts/{id}/revisions/{rev}.json`
/// (`PostRevisionSerializer`). Discourse numbers revisions starting at 2 —
/// revision N describes the edit that produced version N, diffed against
/// version N-1 — so an unedited post has no revisions at all (404).
class DiscoursePostRevision {
  final int postId;

  /// The revision number this payload describes (`current_revision`).
  final int currentRevision;

  /// First / last revision numbers visible to the viewer, for building
  /// prev/next navigation bounds.
  final int firstRevision;
  final int lastRevision;

  /// Neighbouring revision numbers, null at either end of the history.
  final int? previousRevision;
  final int? nextRevision;

  /// Post version counters (`current_version` / `version_count`) for
  /// "edited N times" style labels.
  final int currentVersion;
  final int versionCount;

  /// The editor who made this revision.
  final String username;
  final String? displayUsername;

  /// Avatar template with a `{size}` placeholder; use [avatarUrl].
  final String? avatarTemplate;

  final DateTime? createdAt;

  /// Only present when the server chose to include it (staff, or the
  /// immediately-following revision).
  final String? editReason;

  /// Body diffs (`body_changes`): rendered-HTML inline diff, rendered-HTML
  /// side-by-side diff, and a raw-Markdown side-by-side diff. Null when the
  /// server hit its diff-size limit (`diff_error`).
  final String? bodyInlineHtml;
  final String? bodySideBySideHtml;
  final String? bodySideBySideMarkdown;

  /// Title diffs (`title_changes`) — only present when the title changed
  /// (or always for the first post).
  final String? titleInlineHtml;
  final String? titleSideBySideHtml;

  /// True when the server flagged the diff as too complex to render
  /// (`diff_error`); the diff fields above will be null.
  final bool diffError;

  /// Whether the viewer may edit the post itself (`can_edit`).
  final bool canEdit;

  const DiscoursePostRevision({
    required this.postId,
    required this.currentRevision,
    required this.firstRevision,
    required this.lastRevision,
    this.previousRevision,
    this.nextRevision,
    required this.currentVersion,
    required this.versionCount,
    required this.username,
    this.displayUsername,
    this.avatarTemplate,
    this.createdAt,
    this.editReason,
    this.bodyInlineHtml,
    this.bodySideBySideHtml,
    this.bodySideBySideMarkdown,
    this.titleInlineHtml,
    this.titleSideBySideHtml,
    this.diffError = false,
    this.canEdit = false,
  });

  /// Builds an absolute avatar URL from the Discourse template, or null
  /// when no template is set.
  String? avatarUrl(String forumBaseUrl, {int size = 90}) {
    final tpl = avatarTemplate;
    if (tpl == null || tpl.isEmpty) return null;
    final filled = tpl.replaceAll('{size}', size.toString());
    return filled.startsWith('http') ? filled : '$forumBaseUrl$filled';
  }
}
