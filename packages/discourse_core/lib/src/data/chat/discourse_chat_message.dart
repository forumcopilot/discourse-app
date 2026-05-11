/// One Discourse Chat message. Maps the fields from the Chat plugin's
/// MessageSerializer that the UI cares about; deletes/streaming/blocks
/// stay in the raw response.
class DiscourseChatMessage {
  final int id;
  final int channelId;
  final int? threadId;

  /// Raw markdown the user typed.
  final String message;

  /// Server-rendered HTML (with mentions, oneboxes, emoji expanded).
  /// Equivalent to a post's `cooked` field.
  final String cooked;

  final String? excerpt;

  /// Author. Always present unless the message belongs to a deleted user
  /// (Chat::NullUser); we collapse that into an empty username.
  final int authorId;
  final String authorUsername;
  final String? authorName;
  final String? authorAvatarTemplate;

  final DateTime createdAt;

  /// True when the message has been edited at least once.
  final bool edited;

  final bool deleted;

  /// True when the chat message is currently being LLM-streamed (token
  /// by token); UI should debounce updates and not allow edits.
  final bool streaming;

  DiscourseChatMessage({
    required this.id,
    required this.channelId,
    this.threadId,
    required this.message,
    required this.cooked,
    this.excerpt,
    required this.authorId,
    required this.authorUsername,
    this.authorName,
    this.authorAvatarTemplate,
    required this.createdAt,
    this.edited = false,
    this.deleted = false,
    this.streaming = false,
  });

  factory DiscourseChatMessage.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] as Map?)?.cast<String, dynamic>() ?? const {};
    return DiscourseChatMessage(
      id: (json['id'] as num).toInt(),
      channelId: (json['chat_channel_id'] as num?)?.toInt() ?? 0,
      threadId: (json['thread_id'] as num?)?.toInt(),
      message: (json['message'] ?? '').toString(),
      cooked: (json['cooked'] ?? json['message'] ?? '').toString(),
      excerpt: json['excerpt']?.toString(),
      authorId: (user['id'] as num?)?.toInt() ?? 0,
      authorUsername: (user['username'] ?? '').toString(),
      authorName: user['name']?.toString(),
      authorAvatarTemplate: user['avatar_template']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      edited: json['edited'] == true,
      deleted: json['deleted_at'] != null,
      streaming: json['streaming'] == true,
    );
  }

  /// Build an absolute avatar URL from the author's template, or null
  /// when no template is set.
  String? avatarUrl(String forumBaseUrl, {int size = 60}) {
    final tpl = authorAvatarTemplate;
    if (tpl == null || tpl.isEmpty) return null;
    final filled = tpl.replaceAll('{size}', size.toString());
    return filled.startsWith('http') ? filled : '$forumBaseUrl$filled';
  }

  DiscourseChatMessage copyWith({
    String? message,
    String? cooked,
    bool? edited,
    bool? deleted,
  }) =>
      DiscourseChatMessage(
        id: id,
        channelId: channelId,
        threadId: threadId,
        message: message ?? this.message,
        cooked: cooked ?? this.cooked,
        excerpt: excerpt,
        authorId: authorId,
        authorUsername: authorUsername,
        authorName: authorName,
        authorAvatarTemplate: authorAvatarTemplate,
        createdAt: createdAt,
        edited: edited ?? this.edited,
        deleted: deleted ?? this.deleted,
        streaming: streaming,
      );
}
