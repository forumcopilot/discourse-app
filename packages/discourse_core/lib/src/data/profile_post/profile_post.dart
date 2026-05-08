import 'package:dart_mappable/dart_mappable.dart';
import '../user/user.dart';
import '../attachment/attachment.dart';
import 'profile_post_comment.dart';

part 'profile_post.mapper.dart';

/// Discourse profile post data model based on official API documentation
@MappableClass()
class DiscourseProfilePost with DiscourseProfilePostMappable {
  /// Username
  final String? username;

  /// HTML parsed version of the message contents
  final String? messageParsed;

  /// Whether user can edit
  final bool? canEdit;

  /// Whether user can soft delete
  final bool? canSoftDelete;

  /// Whether user can hard delete
  final bool? canHardDelete;

  /// Whether user can react
  final bool? canReact;

  /// Whether user can view attachments
  final bool? canViewAttachments;

  /// View URL
  final String? viewUrl;

  /// User this profile post was left for
  final DiscourseUser? profileUser;

  /// Attachments to this profile post
  final List<DiscourseAttachment>? attachments;

  /// Latest comments on this profile post
  final List<DiscourseProfilePostComment>? latestComments;

  /// Whether the viewing user has reacted to this content
  final bool? isReactedTo;

  /// If the viewer reacted, the ID of the reaction they used
  final int? visitorReactionId;

  /// Profile post ID
  final int profilePostId;

  /// Profile user ID
  final int? profileUserId;

  /// User ID
  final int? userId;

  /// Post date (Unix timestamp)
  final int? postDate;

  /// Message content
  final String? message;

  /// Message state
  final String? messageState;

  /// Warning message
  final String? warningMessage;

  /// Comment count
  final int? commentCount;

  /// First comment date (Unix timestamp)
  final int? firstCommentDate;

  /// Last comment date (Unix timestamp)
  final int? lastCommentDate;

  /// Reaction score
  final int? reactionScore;

  /// User who posted
  final DiscourseUser? user;

  const DiscourseProfilePost({
    this.username,
    this.messageParsed,
    this.canEdit,
    this.canSoftDelete,
    this.canHardDelete,
    this.canReact,
    this.canViewAttachments,
    this.viewUrl,
    this.profileUser,
    this.attachments,
    this.latestComments,
    this.isReactedTo,
    this.visitorReactionId,
    required this.profilePostId,
    this.profileUserId,
    this.userId,
    this.postDate,
    this.message,
    this.messageState,
    this.warningMessage,
    this.commentCount,
    this.firstCommentDate,
    this.lastCommentDate,
    this.reactionScore,
    this.user,
  });

  factory DiscourseProfilePost.fromJson(Map<String, dynamic> json) {
    return DiscourseProfilePost(
      username: json['username'],
      messageParsed: json['message_parsed'],
      canEdit: json['can_edit'],
      canSoftDelete: json['can_soft_delete'],
      canHardDelete: json['can_hard_delete'],
      canReact: json['can_react'],
      canViewAttachments: json['can_view_attachments'],
      viewUrl: json['view_url'],
      profileUser: json['ProfileUser'] != null ? DiscourseUser.fromJson(json['ProfileUser']) : null,
      attachments: json['Attachments'] != null ? (json['Attachments'] as List).map((attachment) => DiscourseAttachment.fromJson(attachment)).toList() : null,
      latestComments: json['LatestComments'] != null ? (json['LatestComments'] as List).map((comment) => DiscourseProfilePostComment.fromJson(comment)).toList() : null,
      isReactedTo: json['is_reacted_to'],
      visitorReactionId: json['visitor_reaction_id'],
      profilePostId: json['profile_post_id'] ?? 0,
      profileUserId: json['profile_user_id'],
      userId: json['user_id'],
      postDate: json['post_date'],
      message: json['message'],
      messageState: json['message_state'],
      warningMessage: json['warning_message'],
      commentCount: json['comment_count'],
      firstCommentDate: json['first_comment_date'],
      lastCommentDate: json['last_comment_date'],
      reactionScore: json['reaction_score'],
      user: json['User'] != null ? DiscourseUser.fromJson(json['User']) : null,
    );
  }

  // Convenience getters for backward compatibility
  String get id => profilePostId.toString();
  String get content => message ?? '';
  DateTime get postDateTime => postDate != null ? DateTime.fromMillisecondsSinceEpoch(postDate! * 1000) : DateTime.now();
  String get authorId => userId?.toString() ?? '';
  String get authorName => username ?? '';
  String get authorUserType => user?.userTitle ?? '';
  String? get authorAvatarUrl => user?.avatarUrl;
  bool get canDelete => canSoftDelete ?? false;
  bool get canLike => canReact ?? false;
  bool get canReport => false; // Not available in API
  bool get canQuote => false; // Not available in API
  String? get url => viewUrl;
  int get likeCount => reactionScore ?? 0;
  bool get isLiked => isReactedTo ?? false;
  Map<String, dynamic>? get customFields => null; // Not available in API
  bool get isDeleted => messageState == 'deleted';
  bool get isApproved => messageState == 'visible';
  bool get isReported => false; // Not available in API
  String get title => ''; // Not available in API
  String get topicId => ''; // Not available in API
  DateTime get createDate => postDateTime;
  DateTime? get editDate => null; // Not available in API
  bool get isRead => true; // Assume read if accessible
}
