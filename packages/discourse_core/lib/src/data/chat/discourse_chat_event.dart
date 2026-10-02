import 'package:forumcopilot_sdk/models/entities/fc_chat_message.dart';

/// A live change to a chat channel, as Discourse publishes it on the
/// channel's MessageBus channel `/chat/{id}` (Chat::Publisher). Delivered by
/// DiscourseChatProxy.watchChannel.
sealed class DiscourseChatEvent {
  const DiscourseChatEvent();
}

/// A whole message, new or changed. [kind] is Discourse's event type:
/// `sent`, `edit`, `processed` (the server's final rendering, after
/// oneboxes and image sizing), `restore` or `refresh`.
///
/// The payload is serialized for an anonymous viewer, so its reactions carry
/// no "reacted by me"; keep the reactions already on screen for an edit.
class DiscourseChatMessageChanged extends DiscourseChatEvent {
  const DiscourseChatMessageChanged(this.kind, this.message);

  final String kind;
  final FCChatMessage message;

  bool get isNew => kind == 'sent';
}

/// Messages deleted (one, or several at once by a moderator).
class DiscourseChatMessagesDeleted extends DiscourseChatEvent {
  const DiscourseChatMessagesDeleted(this.messageIds);

  final List<int> messageIds;
}

/// Someone added or removed a reaction.
class DiscourseChatReaction extends DiscourseChatEvent {
  const DiscourseChatReaction({
    required this.messageId,
    required this.emoji,
    required this.username,
    required this.added,
  });

  final int messageId;
  final String emoji;
  final String username;
  final bool added;
}

/// A change to the reader's channel list (see
/// `DiscourseChatProxy.watchChannelList`).
sealed class DiscourseChatListEvent {
  const DiscourseChatListEvent();
}

/// A new message in a listed channel. The channel's details already carry
/// its excerpt and time; the list bumps the channel and, for someone else's
/// message, its unread count until the tracking state confirms it.
class DiscourseChatListNewMessage extends DiscourseChatListEvent {
  const DiscourseChatListNewMessage({
    required this.channelId,
    required this.fromReader,
    required this.threadReply,
    this.at,
  });

  final int channelId;
  final bool fromReader;

  /// A reply inside a thread, which does not change the channel's own last
  /// message.
  final bool threadReply;
  final DateTime? at;
}

/// The reader's unread and mention counts for a channel, as the server
/// counts them.
class DiscourseChatListTracking extends DiscourseChatListEvent {
  const DiscourseChatListTracking({
    required this.channelId,
    required this.unreadCount,
    required this.mentionCount,
  });

  final int channelId;
  final int unreadCount;
  final int mentionCount;
}

/// The list itself changed (the reader was added to a channel): read it
/// again.
class DiscourseChatListChanged extends DiscourseChatListEvent {
  const DiscourseChatListChanged();
}
