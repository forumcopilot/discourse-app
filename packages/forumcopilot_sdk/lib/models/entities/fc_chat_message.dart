import 'package:dart_mappable/dart_mappable.dart';

part 'fc_chat_message.mapper.dart';

/// One chat message (Discourse: from `/chat/api/channels/:id/messages`).
///
/// Phase 5.39 — promoted out of `discourse_core` (was
/// `DiscourseChatMessage`). Author avatar URL is pre-resolved against
/// the forum base URL by the proxy, so consumers don't need to
/// expand templates themselves.
@MappableClass()
class FCChatMessage with FCChatMessageMappable {
  int id;
  int channelId;
  int? threadId;

  /// Raw markdown the user typed.
  String message;

  /// Server-rendered HTML (with mentions, oneboxes, emoji expanded).
  /// Equivalent to a post's `cooked` field.
  String cooked;

  String? excerpt;

  int authorId;
  String authorUsername;
  String? authorName;

  /// Pre-resolved absolute avatar URL (the proxy expands any
  /// `{size}` template against the forum base URL before construct).
  String? authorAvatarUrl;

  DateTime createdAt;

  bool edited;
  bool deleted;

  /// True when the message is currently being LLM-streamed (token by
  /// token); UI should debounce updates and not allow edits.
  bool streaming;

  FCChatMessage({
    required this.id,
    required this.channelId,
    this.threadId,
    required this.message,
    required this.cooked,
    this.excerpt,
    required this.authorId,
    required this.authorUsername,
    this.authorName,
    this.authorAvatarUrl,
    required this.createdAt,
    this.edited = false,
    this.deleted = false,
    this.streaming = false,
  });
}
