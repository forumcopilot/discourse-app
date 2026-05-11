/// One row from `/groups.json` — Discourse's groups directory.
/// Groups are bundles of users with shared permissions; the
/// hamburger drawer's **Groups** destination lists them, and
/// tapping one drills into a `GroupDetailPage` showing the group's
/// members and metadata.
///
/// Built-in groups (`admins`, `moderators`, `staff`, `trust_level_*`,
/// `everyone`) live alongside custom groups in this list — Discourse
/// surfaces them all together but tags them via `automatic: true`
/// so the UI can de-emphasise built-ins if it wants to.
class DiscourseGroup {
  /// Numeric Discourse group id.
  final int id;

  /// Slug-style name (`team`, `moderators`, `trust_level_2`).
  /// Used in API paths: `/groups/{name}.json`,
  /// `/groups/{name}/members.json`.
  final String name;

  /// Human-friendly display name. Often null for built-in groups;
  /// falls back to `name` in the UI when empty.
  final String? fullName;

  /// Short bio shown on the group page. Markdown source — the
  /// detail page will render it via the same renderer used for
  /// topics.
  final String? bio;

  /// Total members of the group (Discourse reports this as
  /// `user_count`; we keep the more idiomatic name).
  final int memberCount;

  /// True for Discourse's auto-managed groups (trust level, staff,
  /// everyone). Lets the directory de-emphasise them visually.
  final bool automatic;

  /// True when the group is visible to non-members. We only ever
  /// see groups we can see, so this is `true` for every row we
  /// receive, but it's worth keeping for completeness.
  final bool visible;

  /// True when anyone (not just admins) can request membership.
  /// The detail page exposes a Join button when this is set.
  final bool publicAdmission;

  /// True when membership has to be approved by group admins.
  final bool allowMembershipRequests;

  /// Optional `mentionable_level` / `messageable_level` — Discourse
  /// uses 0–99 to gate who can @mention or @message the group as a
  /// whole. We surface them so an Admin / Power UI could read them;
  /// the default detail page ignores them.
  final int? mentionableLevel;
  final int? messageableLevel;

  /// Hex flair color (`'BF1E2E'`, no `#`). Used to tint the row icon
  /// where available — built-in groups generally don't have one.
  final String? flairColor;
  final String? flairBgColor;

  /// Optional uploaded icon URL (relative or absolute), shown
  /// alongside the group name in places where flair makes sense.
  final String? flairUrl;

  const DiscourseGroup({
    required this.id,
    required this.name,
    this.fullName,
    this.bio,
    this.memberCount = 0,
    this.automatic = false,
    this.visible = true,
    this.publicAdmission = false,
    this.allowMembershipRequests = false,
    this.mentionableLevel,
    this.messageableLevel,
    this.flairColor,
    this.flairBgColor,
    this.flairUrl,
  });

  /// Display name with sensible fallback: `fullName` when present,
  /// otherwise the slug. Useful so callers don't have to repeat the
  /// `?? name` everywhere.
  String get displayName =>
      (fullName?.trim().isNotEmpty == true) ? fullName! : name;

  factory DiscourseGroup.fromJson(Map<String, dynamic> json) {
    return DiscourseGroup(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      fullName: (json['full_name'] as String?)?.trim().isNotEmpty == true
          ? json['full_name'] as String
          : null,
      bio: (json['bio_raw'] ?? json['bio_cooked'] ?? json['bio_excerpt'])
          ?.toString(),
      memberCount: (json['user_count'] as num?)?.toInt() ?? 0,
      automatic: (json['automatic'] as bool?) ?? false,
      visible: (json['visible'] as bool?) ?? true,
      publicAdmission: (json['public_admission'] as bool?) ?? false,
      allowMembershipRequests:
          (json['allow_membership_requests'] as bool?) ?? false,
      mentionableLevel: (json['mentionable_level'] as num?)?.toInt(),
      messageableLevel: (json['messageable_level'] as num?)?.toInt(),
      flairColor: (json['flair_color'] as String?)?.trim().isNotEmpty == true
          ? json['flair_color'] as String
          : null,
      flairBgColor:
          (json['flair_bg_color'] as String?)?.trim().isNotEmpty == true
              ? json['flair_bg_color'] as String
              : null,
      flairUrl: (json['flair_url'] as String?)?.trim().isNotEmpty == true
          ? json['flair_url'] as String
          : null,
    );
  }
}
