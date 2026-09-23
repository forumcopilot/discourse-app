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
