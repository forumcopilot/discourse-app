/// Discourse user-level notification preferences as exposed by
/// `/u/{username}.json` → `user.user_option.*` and writable via
/// `PUT /u/{username}.json` (top-level params, see
/// `app/services/user_updater.rb::OPTION_ATTR`).
///
/// Phase 5.20b replaces the legacy XF-shaped per-type toggles
/// (newPosts / replies / mentions / quotes / likes / subscriptions
/// / privateMessages / systemNotifications) which never persisted
/// anywhere except SharedPreferences. Discourse doesn't model
/// notifications as per-type opt-out — it decides what's a
/// notification, and the user controls when/how it's *delivered*
/// (email frequency, like aggregation, etc.). This model surfaces
/// the controls that genuinely round-trip to Discourse.
class DiscourseUserNotificationPrefs {
  /// Email frequency for activity (replies, mentions, quotes, etc.).
  /// 0 = always · 1 = only when away · 2 = never.
  final int emailLevel;

  /// Email frequency for private messages. Same enum as
  /// [emailLevel]; tracked separately on Discourse because PMs are
  /// often higher-priority than general topic activity.
  final int emailMessagesLevel;

  /// When true, Discourse periodically sends a digest of activity
  /// the user missed. Mutually exclusive with [mailingListMode]
  /// (server auto-disables digests when MLM is on).
  final bool emailDigests;

  /// Window between digest emails, in minutes. Discourse-canonical
  /// values: 1440 (daily) · 10080 (weekly, default) · 43200 (monthly).
  final int digestAfterMinutes;

  /// When true, every public post is emailed to the user like a
  /// mailing list. High-volume forums: not recommended.
  final bool mailingListMode;

  /// How often to notify the user when their posts get liked.
  /// 0 = always · 1 = first time + daily digest · 2 = first time
  /// only · 3 = never.
  final int likeNotificationFrequency;

  /// Notification level Discourse auto-applies to a topic when the
  /// user replies to it. Matches the topic-watch enum:
  /// 1 = Normal · 2 = Tracking · 3 = Watching.
  final int notificationLevelWhenReplying;

  const DiscourseUserNotificationPrefs({
    this.emailLevel = 1,
    this.emailMessagesLevel = 1,
    this.emailDigests = true,
    this.digestAfterMinutes = 10080,
    this.mailingListMode = false,
    this.likeNotificationFrequency = 0,
    this.notificationLevelWhenReplying = 2,
  });

  /// Build from the `user.user_option` block in `/u/{username}.json`.
  /// Defaults match Discourse's out-of-the-box settings so missing
  /// fields don't surface as a "Never" / "Off" state by accident.
  factory DiscourseUserNotificationPrefs.fromUserOption(
    Map<String, dynamic>? userOption,
  ) {
    if (userOption == null) return const DiscourseUserNotificationPrefs();
    int asInt(String key, int fallback) {
      final v = userOption[key];
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    bool asBool(String key, bool fallback) {
      final v = userOption[key];
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) {
        if (v.toLowerCase() == 'true') return true;
        if (v.toLowerCase() == 'false') return false;
      }
      return fallback;
    }

    return DiscourseUserNotificationPrefs(
      emailLevel: asInt('email_level', 1),
      emailMessagesLevel: asInt('email_messages_level', 1),
      emailDigests: asBool('email_digests', true),
      digestAfterMinutes: asInt('digest_after_minutes', 10080),
      mailingListMode: asBool('mailing_list_mode', false),
      likeNotificationFrequency: asInt('like_notification_frequency', 0),
      notificationLevelWhenReplying:
          asInt('notification_level_when_replying', 2),
    );
  }

  /// Body for `PUT /u/{username}.json`. Discourse accepts these as
  /// top-level params (the controller forwards them into
  /// `UserUpdater#update`'s `OPTION_ATTR` whitelist).
  Map<String, dynamic> toUpdateBody() {
    return {
      'email_level': emailLevel,
      'email_messages_level': emailMessagesLevel,
      'email_digests': emailDigests,
      'digest_after_minutes': digestAfterMinutes,
      'mailing_list_mode': mailingListMode,
      'like_notification_frequency': likeNotificationFrequency,
      'notification_level_when_replying': notificationLevelWhenReplying,
    };
  }

  /// Builder copy used by the settings page for optimistic UI:
  /// flip a single field, fire the update, revert on failure.
  DiscourseUserNotificationPrefs copyWith({
    int? emailLevel,
    int? emailMessagesLevel,
    bool? emailDigests,
    int? digestAfterMinutes,
    bool? mailingListMode,
    int? likeNotificationFrequency,
    int? notificationLevelWhenReplying,
  }) {
    return DiscourseUserNotificationPrefs(
      emailLevel: emailLevel ?? this.emailLevel,
      emailMessagesLevel: emailMessagesLevel ?? this.emailMessagesLevel,
      emailDigests: emailDigests ?? this.emailDigests,
      digestAfterMinutes: digestAfterMinutes ?? this.digestAfterMinutes,
      mailingListMode: mailingListMode ?? this.mailingListMode,
      likeNotificationFrequency:
          likeNotificationFrequency ?? this.likeNotificationFrequency,
      notificationLevelWhenReplying:
          notificationLevelWhenReplying ?? this.notificationLevelWhenReplying,
    );
  }
}
