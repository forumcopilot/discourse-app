import 'package:dart_mappable/dart_mappable.dart';

part 'fc_forum.mapper.dart';

/// FCForum (Forum Consolidated) is a unified forum model for UI consumption
/// that abstracts away the specific implementation details of different forum sources.
@MappableClass()
class FCForum with FCForumMappable {
  /// Unique identifier for the forum
  String id;

  /// Display name of the forum
  String name;

  /// Optional description of the forum
  String? description;

  /// URL to the forum logo/icon
  String? logoUrl;

  /// URL to the forum background image
  String? backgroundUrl;

  /// Parent forum ID, null if this is a root forum
  String? parentId;

  /// Indicates if the forum has new/unread posts
  bool hasNewPosts;

  /// Indicates if the forum is password protected
  bool isProtected;

  /// Indicates if the user is subscribed to this forum
  bool isSubscribed;

  /// Indicates if the user can subscribe to this forum
  bool canSubscribe;

  /// Indicates if the user can post in this forum
  bool canPost;

  /// Indicates if the user can upload attachments in this forum
  bool canUpload;

  /// Indicates if the user can view topics/content in this forum
  /// If false, the app should not call getTopics/getTopTopic etc. for this forum
  bool canViewContent;

  /// External URL if this forum is just a link to another webpage
  String? externalUrl;

  /// Indicates if this forum is a link forum (external link; open url, do not call getTopic)
  bool isLinkForum;

  /// Indicates if this forum is only a container for sub-forums
  bool isSubForumContainer;

  /// Child forums, if any
  List<FCForum> childForums;

  /// Phase 5.41 — Discourse category color hex (e.g. `"BF1E2E"`), no
  /// leading `#`. Empty when not available — UI hides the stripe.
  String? color;

  /// Phase 5.41 — Discourse category text color hex, no leading `#`.
  String? textColor;

  /// Phase 5.41 — number of topics in this forum (Discourse:
  /// `topic_count`). 0 when not available.
  int topicCount;

  /// Phase 5.41 — number of posts in this forum (Discourse:
  /// `post_count`). 0 when not available.
  int postCount;

  /// Phase 5.41 — slug-style identifier for URLs (Discourse: `slug`).
  String? slug;

  FCForum({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.backgroundUrl,
    this.parentId,
    this.hasNewPosts = false,
    this.isProtected = false,
    this.isSubscribed = false,
    this.canSubscribe = true,
    this.canPost = true,
    this.canUpload = true,
    this.canViewContent = true,
    this.externalUrl,
    this.isLinkForum = false,
    this.isSubForumContainer = false,
    this.childForums = const [],
    this.color,
    this.textColor,
    this.topicCount = 0,
    this.postCount = 0,
    this.slug,
  });
}
