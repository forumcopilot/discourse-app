import 'package:dart_mappable/dart_mappable.dart';

part 'link_forum.mapper.dart';

/// Discourse link forum data model based on official API documentation
@MappableClass()
class DiscourseLinkForum with DiscourseLinkForumMappable {
  /// Link URL
  final String? linkUrl;

  /// Redirect count
  final int? redirectCount;

  const DiscourseLinkForum({
    this.linkUrl,
    this.redirectCount,
  });

  factory DiscourseLinkForum.fromJson(Map<String, dynamic> json) {
    return DiscourseLinkForum(
      linkUrl: json['link_url'],
      redirectCount: json['redirect_count'],
    );
  }

  // Convenience getters for backward compatibility
  String get url => linkUrl ?? '';
  int get redirects => redirectCount ?? 0;
  bool get isActive => linkUrl != null;
}
