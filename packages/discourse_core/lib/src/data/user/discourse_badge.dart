/// A single Discourse badge as exposed by `/u/{username}/badges.json`.
/// Discourse's payload nests badge definitions under `badges` and the
/// per-user grants under `user_badges`; we flatten both into one model
/// so the UI can render a row of chips without juggling two arrays.
class DiscourseBadge {
  /// Badge id (stable across users).
  final int id;

  /// Display name (e.g. "First Like", "Out of Love", "Leader").
  final String name;

  /// Optional short description shown in tooltip / dialog.
  final String? description;

  /// Optional icon name (Font Awesome short name like "fa-heart"). When
  /// null, the UI falls back to a generic medal icon.
  final String? icon;

  /// Optional uploaded image URL — overrides [icon] when present.
  final String? imageUrl;

  /// Bronze=1, Silver=2, Gold=3 per Discourse convention.
  final int badgeTypeId;

  /// When this user was granted the badge.
  final DateTime? grantedAt;

  /// How many times the user has been granted this badge (some badges
  /// can stack, e.g. "Nice Reply").
  final int grantCount;

  /// True when the badge was granted on the user's profile (rather than
  /// inferred). For now we always set this true for granted badges.
  final bool granted;

  DiscourseBadge({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.imageUrl,
    this.badgeTypeId = 1,
    this.grantedAt,
    this.grantCount = 1,
    this.granted = true,
  });

  /// Construct from the merged record:
  ///   * [definition]   — entry from `badges[]`.
  ///   * [grant]        — entry from `user_badges[]` (for grant time/count).
  factory DiscourseBadge.fromJson({
    required Map<String, dynamic> definition,
    Map<String, dynamic>? grant,
  }) {
    return DiscourseBadge(
      id: (definition['id'] as num).toInt(),
      name: (definition['name'] ?? '').toString(),
      description: definition['description']?.toString(),
      icon: definition['icon']?.toString(),
      imageUrl: definition['image_url']?.toString(),
      badgeTypeId: (definition['badge_type_id'] as num?)?.toInt() ?? 1,
      grantedAt:
          DateTime.tryParse(grant?['granted_at']?.toString() ?? ''),
      grantCount: (grant?['count'] as num?)?.toInt() ?? 1,
      granted: grant != null,
    );
  }

  /// Bronze, Silver, or Gold label for the chip color.
  DiscourseBadgeTier get tier {
    switch (badgeTypeId) {
      case 3:
        return DiscourseBadgeTier.gold;
      case 2:
        return DiscourseBadgeTier.silver;
      default:
        return DiscourseBadgeTier.bronze;
    }
  }
}

enum DiscourseBadgeTier { bronze, silver, gold }
