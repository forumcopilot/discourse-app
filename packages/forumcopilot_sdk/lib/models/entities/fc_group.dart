import 'package:dart_mappable/dart_mappable.dart';

part 'fc_group.mapper.dart';

/// One group (Discourse: from `/groups.json` or `/groups/{name}.json`).
/// Groups are bundles of users with shared permissions.
///
/// Phase 5.40 — promoted out of `discourse_core` (was
/// `DiscourseGroup`).
@MappableClass()
class FCGroup with FCGroupMappable {
  int id;

  /// Slug-style name (`team`, `moderators`, `trust_level_2`).
  String name;

  /// Human-friendly display name. Often null for built-in groups;
  /// callers should fall back to [name] via [displayName].
  String? fullName;

  /// Short bio (markdown).
  String? bio;

  int memberCount;

  /// True for auto-managed groups (trust level, staff, everyone).
  bool automatic;

  /// Visible to non-members.
  bool visible;

  /// Anyone can request membership.
  bool publicAdmission;

  /// Membership has to be approved by group admins.
  bool allowMembershipRequests;

  /// Discourse 0–99 levels gating who can @mention / @message the
  /// group as a whole.
  int? mentionableLevel;
  int? messageableLevel;

  /// Flair color, no `#` prefix.
  String? flairColor;
  String? flairBgColor;
  String? flairUrl;

  FCGroup({
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

  /// Display name with sensible fallback: [fullName] when present,
  /// otherwise [name].
  String get displayName =>
      (fullName?.trim().isNotEmpty == true) ? fullName! : name;
}
