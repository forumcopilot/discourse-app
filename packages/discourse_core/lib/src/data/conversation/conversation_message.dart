import 'package:dart_mappable/dart_mappable.dart';
import '../user/user.dart';
import '../attachment/attachment.dart';
import 'conversation.dart';

part 'conversation_message.mapper.dart';

/// Discourse conversation message data model based on official API documentation
@MappableClass()
class DiscourseConversationMessage with DiscourseConversationMessageMappable {
  /// Username
  final String? username;

  /// Whether this conversation message is unread
  final bool? isUnread;

  /// HTML parsed version of the message contents
  final String? messageParsed;

  /// Whether user can edit
  final bool? canEdit;

  /// Whether user can react
  final bool? canReact;

  /// View URL
  final String? viewUrl;

  /// Conversation this message is part of
  final DiscourseConversation? conversation;

  /// Attachments to this message
  final List<DiscourseAttachment>? attachments;

  /// Whether the viewing user has reacted to this content
  final bool? isReactedTo;

  /// If the viewer reacted, the ID of the reaction they used
  final int? visitorReactionId;

  /// Message ID
  final int messageId;

  /// Conversation ID
  final int? conversationId;

  /// Message date (Unix timestamp)
  final int? messageDate;

  /// User ID
  final int? userId;

  /// Message content
  final String? message;

  /// Attachment count
  final int? attachCount;

  /// Reaction score
  final int? reactionScore;

  /// User who posted the message
  final DiscourseUser? user;

  const DiscourseConversationMessage({
    this.username,
    this.isUnread,
    this.messageParsed,
    this.canEdit,
    this.canReact,
    this.viewUrl,
    this.conversation,
    this.attachments,
    this.isReactedTo,
    this.visitorReactionId,
    required this.messageId,
    this.conversationId,
    this.messageDate,
    this.userId,
    this.message,
    this.attachCount,
    this.reactionScore,
    this.user,
  });

  factory DiscourseConversationMessage.fromJson(Map<String, dynamic> json) {
    return DiscourseConversationMessage(
      username: json['username'],
      isUnread: json['is_unread'],
      messageParsed: json['message_parsed'],
      canEdit: json['can_edit'],
      canReact: json['can_react'],
      viewUrl: json['view_url'],
      conversation: json['Conversation'] != null ? DiscourseConversation.fromJson(json['Conversation']) : null,
      attachments: json['Attachments'] != null ? (json['Attachments'] as List).map((attachment) => DiscourseAttachment.fromJson(attachment)).toList() : null,
      isReactedTo: json['is_reacted_to'],
      visitorReactionId: json['visitor_reaction_id'],
      messageId: json['message_id'] ?? 0,
      conversationId: json['conversation_id'],
      messageDate: json['message_date'],
      userId: json['user_id'],
      message: json['message'],
      attachCount: json['attach_count'],
      reactionScore: json['reaction_score'],
      user: json['User'] != null ? DiscourseUser.fromJson(json['User']) : null,
    );
  }

  // Convenience getters for backward compatibility
  String get id => messageId.toString();
  String get content => message ?? '';
  DateTime get messageDateTime => messageDate != null ? DateTime.fromMillisecondsSinceEpoch(messageDate! * 1000) : DateTime.now();
  String get authorId => userId?.toString() ?? '';
  String get authorName => username ?? '';
  bool get isRead => !(isUnread ?? false);
  int get likeCount => reactionScore ?? 0;
  bool get isLiked => isReactedTo ?? false;
}
