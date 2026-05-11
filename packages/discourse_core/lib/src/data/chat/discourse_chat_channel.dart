/// One Discourse Chat channel as exposed by `/chat/api/me/channels` and
/// `/chat/api/channels/:id`. We only model the fields the mobile UI
/// needs; everything else (chatable, threading_enabled, etc.) stays in
/// the raw response for callers that want it.
class DiscourseChatChannel {
  final int id;

  /// Channel title — the human-readable name. For category channels
  /// this defaults to the category name; for DMs it's a comma-joined
  /// participant list.
  final String title;

  final String? description;
  final String? slug;

  /// Channel type: 'Category', 'DirectMessage', or 'TopicChat'.
  final String chatableType;

  /// Number of unread messages for the current user.
  final int unreadCount;

  /// Number of unread mentions (counted separately from the badge).
  final int mentionCount;

  /// Most-recent message id the user has read. Used for the
  /// mark-channel-read call.
  final int? lastReadMessageId;

  /// Channel-level membership status flags.
  final bool isFollowing;
  final bool canJoin;

  /// Status: 'open', 'closed', 'archived', 'read_only'. UI greys out
  /// the composer when not 'open'.
  final String status;

  /// Last message timestamp, used for sorting the channel list.
  final DateTime? lastMessageAt;

  DiscourseChatChannel({
    required this.id,
    required this.title,
    this.description,
    this.slug,
    this.chatableType = 'Category',
    this.unreadCount = 0,
    this.mentionCount = 0,
    this.lastReadMessageId,
    this.isFollowing = false,
    this.canJoin = false,
    this.status = 'open',
    this.lastMessageAt,
  });

  bool get isOpen => status == 'open';
  bool get isReadOnly => status == 'read_only';
  bool get isArchived => status == 'archived';
  bool get isClosed => status == 'closed';

  factory DiscourseChatChannel.fromJson(Map<String, dynamic> json) {
    final membership =
        (json['current_user_membership'] as Map?)?.cast<String, dynamic>();
    final meta = (json['meta'] as Map?)?.cast<String, dynamic>();
    final lastMessage = (json['last_message'] as Map?)?.cast<String, dynamic>();
    return DiscourseChatChannel(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      slug: json['slug']?.toString(),
      chatableType: (json['chatable_type'] ?? 'Category').toString(),
      unreadCount:
          (membership?['unread_count'] as num?)?.toInt() ?? 0,
      mentionCount:
          (membership?['mention_count'] as num?)?.toInt() ?? 0,
      lastReadMessageId:
          (membership?['last_read_message_id'] as num?)?.toInt(),
      isFollowing: membership?['following'] == true,
      canJoin: meta?['can_join_chat_channel'] == true,
      status: (json['status'] ?? 'open').toString(),
      lastMessageAt:
          DateTime.tryParse(lastMessage?['created_at']?.toString() ?? '') ??
              DateTime.tryParse(json['last_message_sent_at']?.toString() ?? ''),
    );
  }
}
