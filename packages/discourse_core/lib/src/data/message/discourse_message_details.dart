/// What a private message says about itself and the viewer, where
/// FCConversationResult has no field to carry it.
///
/// Filled from the topic payload each time a message loads
/// (DiscoursePrivateConversationProxy), read by the message screen — the same
/// side-channel DiscourseAcceptedAnswers uses for topics.
class DiscourseMessageDetails {
  const DiscourseMessageDetails({
    required this.canLeave,
    this.isArchived = false,
    this.groups = const [],
  });

  /// Whether the viewer may remove themselves. Discourse serializes
  /// `details.can_remove_self_id` only when `can_remove_allowed_users?`
  /// allows it (staff; the author at trust level 2+; anyone else while
  /// other people remain) — topic_view_details_serializer.rb. The Leave
  /// action used to be offered to everyone.
  final bool canLeave;

  /// Whether the viewer has archived the message (`message_archived`).
  /// Decides between Archive and Move to Inbox; archived messages are not in
  /// the inbox or sent lists.
  final bool isArchived;

  /// Groups on the message (`details.allowed_groups`). Discourse lists them
  /// ahead of people, and a member of one is left out of `allowed_users` —
  /// which is how `system` went missing from system messages.
  final List<DiscourseMessageGroup> groups;

  static final Map<String, DiscourseMessageDetails> _byTopicId = {};

  static void store(String topicId, DiscourseMessageDetails details) {
    if (topicId.isEmpty) return;
    _byTopicId[topicId] = details;
  }

  static DiscourseMessageDetails? forTopic(String topicId) =>
      topicId.isEmpty ? null : _byTopicId[topicId];

  /// Post numbers of the small actions ("invited …", "left", "closed this")
  /// in the loaded windows of message [topicId]. The message view shows no
  /// row for them, but they are posts: a message notification points at the
  /// reader's first unread post, which may be one, and only its timing
  /// clears the notification (Notification.mark_posts_read). They are
  /// reported read with the messages around them.
  static Set<int> hiddenPostNumbers(String topicId) =>
      _hiddenByTopicId[topicId] ?? const {};

  static void addHiddenPostNumbers(String topicId, Iterable<int> numbers) {
    if (topicId.isEmpty || numbers.isEmpty) return;
    (_hiddenByTopicId[topicId] ??= <int>{}).addAll(numbers);
  }

  static final Map<String, Set<int>> _hiddenByTopicId = {};

  /// Only for tests and sign-out; one small entry per message opened.
  static void clear() {
    _byTopicId.clear();
    _hiddenByTopicId.clear();
  }
}

/// A group a private message is addressed to (BasicGroupSerializer).
class DiscourseMessageGroup {
  const DiscourseMessageGroup({
    required this.name,
    this.displayName,
    this.userCount,
  });

  /// The handle, e.g. `moderators` — what invite-group and profile links use.
  final String name;

  /// The human label, when the group has one set.
  final String? displayName;

  final int? userCount;

  /// What to show a reader.
  String get label =>
      (displayName != null && displayName!.isNotEmpty) ? displayName! : name;

  static DiscourseMessageGroup? fromJson(Object? json) {
    if (json is! Map) return null;
    final name = (json['name'] ?? '').toString();
    if (name.isEmpty) return null;
    return DiscourseMessageGroup(
      name: name,
      displayName: json['display_name'] as String?,
      userCount: json['user_count'] as int?,
    );
  }
}
