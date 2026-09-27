import 'package:forumcopilot_sdk/models/results/fc_private_conversation_result.dart';

import '../../util/site_url.dart';

/// What a private message says about itself and the viewer, where the SDK's
/// thread and conversation results have no field to carry it.
///
/// A message is a topic, and whichever loader reads its `/t/{id}.json` —
/// the topic loaders in DiscoursePostProxy or the message loader in
/// DiscoursePrivateConversationProxy — stores this beside the result, the
/// same side-channel DiscourseAcceptedAnswers uses. Its presence is how the
/// topic page knows it is showing a message ([isMessage]).
class DiscourseMessageDetails {
  const DiscourseMessageDetails({
    required this.canLeave,
    this.isArchived = false,
    this.groups = const [],
    this.participants = const [],
    this.canInvite = false,
    this.canEdit = false,
    this.canClose = false,
    this.canRemoveParticipants = false,
    this.canDelete = false,
  });

  /// The details of topic payload [t] when it is a private message
  /// (`archetype: private_message`), else null. [siteUrl] resolves avatars.
  static DiscourseMessageDetails? fromTopicView(
    Map<String, dynamic> t, {
    required String siteUrl,
  }) {
    if (t['archetype'] != 'private_message') return null;
    final details = (t['details'] as Map?)?.cast<String, dynamic>() ?? const {};
    return DiscourseMessageDetails(
      canLeave: details.containsKey('can_remove_self_id'),
      isArchived: t['message_archived'] == true,
      groups: [
        for (final g in (details['allowed_groups'] as List?) ?? const [])
          if (DiscourseMessageGroup.fromJson(g) case final group?) group,
      ],
      participants: participantsFrom(details, siteUrl: siteUrl),
      // TopicViewDetailsSerializer emits these only when the guardian grants
      // them, so presence is the permission.
      canInvite: details['can_invite_to'] == true,
      canEdit: details['can_edit'] == true,
      // Closing is for staff, trust level 4 and category moderators
      // (topic_guardian.rb), not whoever may edit the title.
      canClose: details['can_close_topic'] == true,
      canRemoveParticipants: details['can_remove_allowed_users'] == true,
      canDelete: details['can_delete'] == true,
    );
  }

  /// Everyone on the message, author first, de-duplicated by id.
  ///
  /// Discourse splits this across three fields of `details`, and reading
  /// only `allowed_users` lost people: the serializer drops from it anyone
  /// covered by one of the message's `allowed_groups` (except the viewer),
  /// which removes `system` — a member of every staff and trust-level group —
  /// from system messages, so a PM the user had replied to showed
  /// "1 participant" (topic_view_details_serializer.rb, `allowed_users`).
  /// `created_by` and `participants` (who has posted) bring them back, and
  /// the count then agrees with the inbox list, which counts posters too.
  static List<FCParticipant> participantsFrom(
    Map<String, dynamic> details, {
    required String siteUrl,
  }) {
    final seen = <String>{};
    final out = <FCParticipant>[];
    void add(Object? u) {
      if (u is! Map) return;
      final p = participantFrom(u.cast<String, dynamic>(), siteUrl: siteUrl);
      if (p.userId.isEmpty || !seen.add(p.userId)) return;
      out.add(p);
    }

    add(details['created_by']);
    for (final u in (details['allowed_users'] as List?) ?? const []) {
      add(u);
    }
    for (final u in (details['participants'] as List?) ?? const []) {
      add(u);
    }
    return out;
  }

  /// One user from a topic or list payload (`id`, `username`,
  /// `avatar_template`) as a participant, its avatar resolved on [siteUrl].
  static FCParticipant participantFrom(
    Map<String, dynamic> u, {
    required String siteUrl,
  }) {
    final tpl = u['avatar_template'] as String?;
    return FCParticipant(
      userId: (u['id'] ?? '').toString(),
      username: (u['username'] ?? '').toString(),
      iconUrl: tpl == null || tpl.isEmpty
          ? null
          : absoluteSiteUrl(siteUrl, tpl.replaceAll('{size}', '90')),
      isOnline: false,
    );
  }

  /// Whether topic [topicId], as last loaded, is a private message.
  static bool isMessage(String topicId) => forTopic(topicId) != null;

  /// Everyone on the message (people; [groups] are separate).
  final List<FCParticipant> participants;

  /// Whether the viewer may invite people or groups (`can_invite_to`).
  final bool canInvite;

  /// Whether the viewer may edit the message's title (`can_edit`).
  final bool canEdit;

  /// Whether the viewer may close or reopen the message (`can_close_topic`).
  final bool canClose;

  /// Whether the viewer may take people and groups off the message
  /// (`can_remove_allowed_users`).
  final bool canRemoveParticipants;

  /// Whether the viewer may delete the message (`can_delete`).
  final bool canDelete;

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

/// One of Discourse web's message lists (the user-private-messages routes):
/// the path segments after `/topics/` it merges, and a group for a group's
/// inbox.
class DiscourseMessageList {
  const DiscourseMessageList._(this.id, this.lists, {this.group});

  /// A stable name, e.g. for remembering the list last shown.
  final String id;
  final List<String> lists;
  final String? group;

  /// Everything the viewer is on that is not archived. The web's "Latest"
  /// is /private-messages, which leaves out messages the viewer started and
  /// no one has answered; merging in Sent makes one list of all of them.
  static const inbox =
      DiscourseMessageList._('inbox', ['private-messages', 'private-messages-sent']);
  static const unread =
      DiscourseMessageList._('unread', ['private-messages-unread']);
  static const newMessages =
      DiscourseMessageList._('new', ['private-messages-new']);
  static const sent = DiscourseMessageList._('sent', ['private-messages-sent']);
  static const archive =
      DiscourseMessageList._('archive', ['private-messages-archive']);

  /// A group's inbox.
  factory DiscourseMessageList.group(String name) => DiscourseMessageList._(
      'group:$name', const ['private-messages-group'],
      group: name);
}
