/// One emoji reaction chip on a chat message, parsed from the message
/// serializer's `reactions` field (plugins/chat
/// app/serializers/chat/message_serializer.rb — only present when a
/// message has at least one reaction).
class DiscourseChatMessageReaction {
  /// Discourse emoji name without colons, e.g. `heart`, `tada`.
  final String emoji;
  final int count;

  /// True when the current user is among the reactors — drives the
  /// chip's highlighted state and whether a tap should add or remove.
  final bool reacted;

  /// Up to five reactor usernames (the serializer caps the sample).
  final List<String> usernames;

  DiscourseChatMessageReaction({
    required this.emoji,
    required this.count,
    this.reacted = false,
    this.usernames = const [],
  });
}
