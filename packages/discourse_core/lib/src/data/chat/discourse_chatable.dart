/// Someone or something a chat can be started with, as Discourse's chat
/// search answers it (GET /chat/api/chatables, Chat::ChatablesSerializer):
/// a person or a group.
class DiscourseChatable {
  const DiscourseChatable({
    required this.isGroup,
    required this.name,
    this.label,
    this.avatarUrl,
    required this.canChat,
  });

  final bool isGroup;

  /// Username, or group name — what the DM request names them by.
  final String name;

  /// Full name / group display name, when there is one.
  final String? label;

  final String? avatarUrl;

  /// Whether a DM with them can be started now: a person who can chat and
  /// has chat on (`can_chat` && `has_chat_enabled`), or a group small
  /// enough for a DM (`can_chat`). Discourse drops anyone else from the
  /// request without saying so.
  final bool canChat;
}
