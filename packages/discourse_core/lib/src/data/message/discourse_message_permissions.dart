/// What the signed-in user may do to a private message, where
/// FCConversationResult has no field to say it.
///
/// Filled from the topic's `details` each time a message loads
/// (DiscoursePrivateConversationProxy), read by the message screen — the same
/// side-channel DiscourseAcceptedAnswers uses for topics.
class DiscourseMessagePermissions {
  const DiscourseMessagePermissions({required this.canLeave});

  /// Whether the viewer may remove themselves. Discourse serializes
  /// `details.can_remove_self_id` only when `can_remove_allowed_users?`
  /// allows it (staff; the author at trust level 2+; anyone else while
  /// other people remain) — topic_view_details_serializer.rb. The Leave
  /// action used to be offered to everyone.
  final bool canLeave;

  static final Map<String, DiscourseMessagePermissions> _byTopicId = {};

  static void store(String topicId, DiscourseMessagePermissions permissions) {
    if (topicId.isEmpty) return;
    _byTopicId[topicId] = permissions;
  }

  static DiscourseMessagePermissions? forTopic(String topicId) =>
      topicId.isEmpty ? null : _byTopicId[topicId];

  /// Only for tests and sign-out; one small entry per message opened.
  static void clear() => _byTopicId.clear();
}
