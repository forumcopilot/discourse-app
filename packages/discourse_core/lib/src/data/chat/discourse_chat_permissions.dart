/// What the viewer may do in a chat channel, from the channel's `meta`
/// (Chat::ChannelSerializer) — FCChatChannel has no fields for it. Kept per
/// forum and channel, filled whenever DiscourseChatProxy parses a channel.
///
/// The rules they feed are Discourse's (plugins/chat guardian_extensions):
/// post and change messages in an open channel, or a closed one if you
/// moderate it; not while silenced; delete your own if `can_delete_self`,
/// anyone's if `can_delete_others`.
class DiscourseChatPermissions {
  const DiscourseChatPermissions({
    this.canDeleteSelf = false,
    this.canDeleteOthers = false,
    this.canModerate = false,
    this.silenced = false,
  });

  final bool canDeleteSelf;
  final bool canDeleteOthers;

  /// Staff, or a moderator of the channel's category (`can_moderate`).
  final bool canModerate;

  /// The viewer is silenced (`user_silenced`): no posting, editing, deleting
  /// or reacting.
  final bool silenced;

  static final Map<String, DiscourseChatPermissions> _byChannel = {};

  static String _key(String siteUrl, int channelId) => '$siteUrl|$channelId';

  static void store(String siteUrl, int channelId, DiscourseChatPermissions p) =>
      _byChannel[_key(siteUrl, channelId)] = p;

  static DiscourseChatPermissions? forChannel(String siteUrl, int channelId) =>
      _byChannel[_key(siteUrl, channelId)];

  /// Only for tests and sign-out.
  static void clear() => _byChannel.clear();

  /// Whether messages can be posted or changed in a channel with [status].
  bool canWriteIn(String status) =>
      !silenced && (status == 'open' || (status == 'closed' && canModerate));
}
