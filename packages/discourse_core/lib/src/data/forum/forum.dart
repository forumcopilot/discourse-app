import 'package:dart_mappable/dart_mappable.dart';

part 'forum.mapper.dart';

/// Discourse Forum type data (matches datatype/Forum.md exactly)
@MappableClass()
class DiscourseForum with DiscourseForumMappable {
  /// Forum type ID
  final String? forumTypeId;

  /// Whether posting is allowed in this forum
  final bool? allowPosting;

  /// Whether a prefix is required to post
  final bool? requirePrefix;

  /// Minimum number of tags required
  final int? minTags;

  const DiscourseForum({
    this.forumTypeId,
    this.allowPosting,
    this.requirePrefix,
    this.minTags,
  });

  factory DiscourseForum.fromJson(Map<String, dynamic> json) {
    return DiscourseForum(
      forumTypeId: json['forum_type_id'],
      allowPosting: json['allow_posting'],
      requirePrefix: json['require_prefix'],
      minTags: json['min_tags'],
    );
  }
}
