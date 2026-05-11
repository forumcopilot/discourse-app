/// A single entry from `/tags.json`'s `tags` array.
///
/// Discourse returns more fields than we surface — we only model what
/// the global Tags tab + tag-filtered topic list need.
class DiscourseTag {
  /// Database id (integer in modern Discourse).
  final int? id;

  /// Tag handle as used in URLs (`/tag/{name}.json`). Lowercase + slug
  /// safe; this is the value the SDK passes to `getTopicsByTagAsync`.
  final String name;

  /// Human-display label. Usually identical to [name] but Discourse
  /// can apply CSS-like display rules per locale so we keep both.
  final String text;

  /// Number of topics using this tag (excluding deleted/whispered).
  /// Used to sort the global list by popularity.
  final int count;

  /// Optional admin-set description shown under the name on the
  /// Discourse web tag page.
  final String? description;

  /// True when the tag is only valid on PMs (per-tag PM allowlist).
  /// We hide these from the public Tags list.
  final bool pmOnly;

  const DiscourseTag({
    required this.name,
    required this.text,
    this.id,
    this.count = 0,
    this.description,
    this.pmOnly = false,
  });

  factory DiscourseTag.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return DiscourseTag(
      id: rawId is num ? rawId.toInt() : null,
      name: (json['name'] ?? json['id'] ?? '').toString(),
      text: (json['text'] ?? json['name'] ?? '').toString(),
      count: (json['count'] as num?)?.toInt() ?? 0,
      description: json['description']?.toString(),
      pmOnly: json['pm_only'] == true,
    );
  }
}
