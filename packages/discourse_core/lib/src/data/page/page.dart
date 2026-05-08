import 'package:dart_mappable/dart_mappable.dart';

part 'page.mapper.dart';

/// Discourse page data model based on official API documentation
@MappableClass()
class DiscoursePage with DiscoursePageMappable {
  /// Publish date (Unix timestamp)
  final int? publishDate;

  /// View count
  final int? viewCount;

  const DiscoursePage({
    this.publishDate,
    this.viewCount,
  });

  factory DiscoursePage.fromJson(Map<String, dynamic> json) {
    return DiscoursePage(
      publishDate: json['publish_date'],
      viewCount: json['view_count'],
    );
  }

  // Convenience getters for backward compatibility
  DateTime? get publishDateTime => publishDate != null ? DateTime.fromMillisecondsSinceEpoch(publishDate! * 1000) : null;
  int get views => viewCount ?? 0;
  bool get isPublished => publishDate != null;
}
