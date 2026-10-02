import 'package:flutter/foundation.dart';

import '../../util/site_url.dart';

/// A person in a chat channel, as `chatable.users` and the membership list
/// serialize them.
class DiscourseChatUser {
  const DiscourseChatUser({
    required this.userId,
    required this.username,
    this.name,
    this.avatarUrl,
    this.statusEmoji,
  });

  final int userId;
  final String username;

  /// Display name; null when the forum hides names or the person set none.
  final String? name;

  /// Absolute avatar address at a list-friendly size, or null.
  final String? avatarUrl;

  /// The emoji of their user status ("🌴 on holiday"), as a shortcode.
  final String? statusEmoji;

  /// The name to show: the display name when there is one.
  String get displayName =>
      name != null && name!.trim().isNotEmpty ? name!.trim() : username;

  static DiscourseChatUser? fromJson(String siteUrl, Object? raw) {
    if (raw is! Map) return null;
    final u = raw.cast<String, dynamic>();
    final id = (u['id'] as num?)?.toInt();
    final username = u['username']?.toString();
    if (id == null || username == null || username.isEmpty) return null;
    final tpl = u['avatar_template']?.toString();
    final status = (u['status'] as Map?)?.cast<String, dynamic>();
    return DiscourseChatUser(
      userId: id,
      username: username,
      name: u['name']?.toString(),
      avatarUrl: tpl == null || tpl.isEmpty
          ? null
          : absoluteSiteUrl(DiscourseChatChannelDetails._trim(siteUrl), tpl.replaceAll('{size}', '96')),
      statusEmoji: status?['emoji']?.toString(),
    );
  }
}

/// What Discourse says about a chat channel beyond the shared
/// `FCChatChannel`: who is in a DM, how the channel looks (emoji, category
/// colour), its last message, and the reader's own settings (starred,
/// muted, notification level).
///
/// A side table keyed by forum and channel id, like
/// `DiscourseMessageDetails` for personal messages: these are Discourse-only
/// concepts, and the channel entity is shared SDK surface. Recorded by
/// `DiscourseChatProxy` from every channel it parses; the list and the info
/// screen read it. [revision] ticks on every change, so a list can redraw.
class DiscourseChatChannelDetails {
  const DiscourseChatChannelDetails({
    required this.channelId,
    this.isDirectMessage = false,
    this.isGroup = false,
    this.members = const [],
    this.membershipsCount = 0,
    this.emoji,
    this.color,
    this.lastMessageExcerpt,
    this.lastMessageAt,
    this.lastMessageUserId,
    this.starred = false,
    this.muted = false,
    this.notificationLevel = 'mention',
    this.threadingEnabled = false,
    this.allowChannelWideMentions = false,
    this.canRemoveMembers = false,
    this.canFlag = false,
    this.canModerate = false,
    this.canManagePins = false,
    this.newMessagesBusId,
  });

  final int channelId;
  final bool isDirectMessage;

  /// A DM with more than one other person, or a named one (`chatable.group`).
  final bool isGroup;

  /// For a DM: the other people in it (Discourse leaves the reader out
  /// unless they are alone in it).
  final List<DiscourseChatUser> members;

  /// How many people have joined (`memberships_count`); for a DM, everyone
  /// in it, the reader included.
  final int membershipsCount;

  /// The channel's own emoji (a shortcode), when an admin chose one.
  final String? emoji;

  /// The category's colour (`chatable.color`, hex without `#`) for a
  /// category channel.
  final String? color;

  final String? lastMessageExcerpt;
  final DateTime? lastMessageAt;

  /// Who sent the last message, when the payload said (live updates do;
  /// the channel list does not).
  final int? lastMessageUserId;

  final bool starred;
  final bool muted;

  /// `never`, `mention` or `always`: when the reader is notified.
  final String notificationLevel;

  final bool threadingEnabled;
  final bool allowChannelWideMentions;
  final bool canRemoveMembers;
  final bool canFlag;
  final bool canModerate;
  final bool canManagePins;

  /// Where `/chat/{id}/new-messages` was when the channel was read, so a
  /// list subscribing from there misses nothing.
  final int? newMessagesBusId;

  DiscourseChatChannelDetails copyWith({
    String? lastMessageExcerpt,
    DateTime? lastMessageAt,
    int? lastMessageUserId,
    bool? starred,
    bool? muted,
    String? notificationLevel,
    List<DiscourseChatUser>? members,
    int? membershipsCount,
  }) =>
      DiscourseChatChannelDetails(
        channelId: channelId,
        isDirectMessage: isDirectMessage,
        isGroup: isGroup,
        members: members ?? this.members,
        membershipsCount: membershipsCount ?? this.membershipsCount,
        emoji: emoji,
        color: color,
        lastMessageExcerpt: lastMessageExcerpt ?? this.lastMessageExcerpt,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        lastMessageUserId: lastMessageUserId ?? this.lastMessageUserId,
        starred: starred ?? this.starred,
        muted: muted ?? this.muted,
        notificationLevel: notificationLevel ?? this.notificationLevel,
        threadingEnabled: threadingEnabled,
        allowChannelWideMentions: allowChannelWideMentions,
        canRemoveMembers: canRemoveMembers,
        canFlag: canFlag,
        canModerate: canModerate,
        canManagePins: canManagePins,
        newMessagesBusId: newMessagesBusId,
      );

  /// Reads one channel as `ChannelSerializer` writes it.
  static DiscourseChatChannelDetails fromChannelJson(
      String siteUrl, Map<String, dynamic> json) {
    final id = (json['id'] as num).toInt();
    final isDm = json['chatable_type']?.toString() == 'DirectMessage';
    final chatable = (json['chatable'] as Map?)?.cast<String, dynamic>();
    final membership = (json['current_user_membership'] as Map?)?.cast<String, dynamic>();
    final meta = (json['meta'] as Map?)?.cast<String, dynamic>();
    final busIds = (meta?['message_bus_last_ids'] as Map?)?.cast<String, dynamic>();
    final last = (json['last_message'] as Map?)?.cast<String, dynamic>();
    final members = <DiscourseChatUser>[
      if (isDm)
        for (final raw in ((chatable?['users'] as List?) ?? const []))
          if (DiscourseChatUser.fromJson(siteUrl, raw) case final u?) u,
    ];
    final excerpt = (last?['excerpt'] ?? last?['message'])?.toString().trim();
    return DiscourseChatChannelDetails(
      channelId: id,
      isDirectMessage: isDm,
      isGroup: isDm && (chatable?['group'] == true || members.length > 1),
      members: members,
      membershipsCount: (json['memberships_count'] as num?)?.toInt() ?? 0,
      emoji: _nonEmpty(json['emoji']),
      color: isDm ? null : _nonEmpty(chatable?['color']),
      lastMessageExcerpt: excerpt == null || excerpt.isEmpty ? null : excerpt,
      lastMessageAt: DateTime.tryParse(last?['created_at']?.toString() ?? '') ??
          DateTime.tryParse(json['last_message_sent_at']?.toString() ?? ''),
      lastMessageUserId: ((last?['user'] as Map?)?['id'] as num?)?.toInt(),
      starred: membership?['starred'] == true,
      muted: membership?['muted'] == true,
      notificationLevel: _nonEmpty(membership?['notification_level']) ?? 'mention',
      threadingEnabled: json['threading_enabled'] == true,
      allowChannelWideMentions: json['allow_channel_wide_mentions'] == true,
      canRemoveMembers: meta?['can_remove_members'] == true,
      canFlag: meta?['can_flag'] == true,
      canModerate: meta?['can_moderate'] == true,
      canManagePins: meta?['can_manage_pins'] == true,
      newMessagesBusId: (busIds?['new_messages'] as num?)?.toInt(),
    );
  }

  static String? _nonEmpty(Object? v) {
    final s = v?.toString().trim();
    return s == null || s.isEmpty ? null : s;
  }

  static String _trim(String siteUrl) {
    var s = siteUrl.trim();
    while (s.endsWith('/')) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }

  static final Map<String, DiscourseChatChannelDetails> _byKey = {};

  /// Ticks on every change, so a list showing details can redraw.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static String _key(String siteUrl, int channelId) => '${_trim(siteUrl)}|$channelId';

  static DiscourseChatChannelDetails? of(String siteUrl, int channelId) =>
      _byKey[_key(siteUrl, channelId)];

  static void store(String siteUrl, DiscourseChatChannelDetails details) {
    _byKey[_key(siteUrl, details.channelId)] = details;
    revision.value++;
  }

  /// Changes one channel's details in place (a live message, a setting the
  /// reader changed); nothing when the channel has not been read.
  static void update(
    String siteUrl,
    int channelId,
    DiscourseChatChannelDetails Function(DiscourseChatChannelDetails) change,
  ) {
    final current = of(siteUrl, channelId);
    if (current == null) return;
    store(siteUrl, change(current));
  }

  /// Only for tests and sign-out.
  static void clear() {
    _byKey.clear();
    revision.value++;
  }
}
