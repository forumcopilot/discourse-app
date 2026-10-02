import 'discourse_chat_channel_details.dart';

/// The message a chat reply answers, as `in_reply_to` serializes it.
class DiscourseChatReplyTo {
  const DiscourseChatReplyTo({required this.messageId, this.excerpt, this.user});

  final int messageId;
  final String? excerpt;
  final DiscourseChatUser? user;
}

/// A thread started from a message, as the original message's `thread`
/// serializes it: how many replies, who took part, the latest reply.
class DiscourseChatThreadPreview {
  const DiscourseChatThreadPreview({
    required this.threadId,
    this.title,
    this.replyCount = 0,
    this.participants = const [],
    this.participantCount = 0,
    this.lastReplyAt,
    this.lastReplyExcerpt,
    this.lastReplyUser,
  });

  final int threadId;
  final String? title;
  final int replyCount;
  final List<DiscourseChatUser> participants;
  final int participantCount;
  final DateTime? lastReplyAt;
  final String? lastReplyExcerpt;
  final DiscourseChatUser? lastReplyUser;

  /// Reads `Chat::ThreadPreviewSerializer`'s JSON, from a message's `thread`
  /// or a live `update_thread_original_message`.
  static DiscourseChatThreadPreview fromPreviewJson(String siteUrl, int threadId, Map<String, dynamic> preview,
          {String? title, int? replyCount}) =>
      DiscourseChatThreadPreview(
        threadId: threadId,
        title: title,
        replyCount: (preview['reply_count'] as num?)?.toInt() ?? replyCount ?? 0,
        participants: [
          for (final raw in ((preview['participant_users'] as List?) ?? const []))
            if (DiscourseChatUser.fromJson(siteUrl, raw) case final u?) u,
        ],
        participantCount: (preview['participant_count'] as num?)?.toInt() ?? 0,
        lastReplyAt: DateTime.tryParse(preview['last_reply_created_at']?.toString() ?? ''),
        lastReplyExcerpt: DiscourseChatMessageExtras._text(preview['last_reply_excerpt']),
        lastReplyUser: DiscourseChatUser.fromJson(siteUrl, preview['last_reply_user']),
      );
}

/// What Discourse says about a chat message beyond the shared
/// `FCChatMessage`: the message it replies to, the thread it starts, and
/// the reader's own marks (bookmark, flag) and the message's pin. A side
/// table keyed by forum and message id, like the uploads and permissions
/// beside it; recorded by `DiscourseChatProxy` from every message it reads.
class DiscourseChatMessageExtras {
  const DiscourseChatMessageExtras({
    this.replyTo,
    this.thread,
    this.bookmarkId,
    this.pinned = false,
    this.availableFlags = const [],
    this.flagged = false,
    this.authorTitle,
  });

  final DiscourseChatReplyTo? replyTo;

  /// Set on a thread's original message.
  final DiscourseChatThreadPreview? thread;

  /// The reader's bookmark on the message, if any.
  final int? bookmarkId;
  final bool pinned;

  /// The flag types the reader may use on it (`available_flags`, by name
  /// key: `spam`, `inappropriate`, …); empty when they may not flag it.
  final List<String> availableFlags;

  bool get canFlag => availableFlags.isNotEmpty;

  /// The reader already flagged it.
  final bool flagged;

  /// The author's title, shown beside the name (as on posts).
  final String? authorTitle;

  DiscourseChatMessageExtras copyWith({
    DiscourseChatReplyTo? replyTo,
    DiscourseChatThreadPreview? thread,
    int? bookmarkId,
    bool clearBookmark = false,
    bool? pinned,
    bool? flagged,
  }) =>
      DiscourseChatMessageExtras(
        replyTo: replyTo ?? this.replyTo,
        thread: thread ?? this.thread,
        bookmarkId: clearBookmark ? null : (bookmarkId ?? this.bookmarkId),
        pinned: pinned ?? this.pinned,
        availableFlags: availableFlags,
        flagged: flagged ?? this.flagged,
        authorTitle: authorTitle,
      );

  /// Reads one message as `Chat::MessageSerializer` writes it.
  static DiscourseChatMessageExtras fromMessageJson(String siteUrl, Map<String, dynamic> json) {
    final reply = (json['in_reply_to'] as Map?)?.cast<String, dynamic>();
    final replyId = (reply?['id'] as num?)?.toInt();
    final thread = (json['thread'] as Map?)?.cast<String, dynamic>();
    final threadId = (thread?['id'] as num?)?.toInt();
    final preview = (thread?['preview'] as Map?)?.cast<String, dynamic>();
    final bookmark = (json['bookmark'] as Map?)?.cast<String, dynamic>();
    final flags = json['available_flags'];
    final user = (json['user'] as Map?)?.cast<String, dynamic>();
    return DiscourseChatMessageExtras(
      replyTo: replyId == null
          ? null
          : DiscourseChatReplyTo(
              messageId: replyId,
              excerpt: _text(reply?['excerpt']),
              user: DiscourseChatUser.fromJson(siteUrl, reply?['user']),
            ),
      thread: threadId == null || preview == null
          ? null
          : DiscourseChatThreadPreview.fromPreviewJson(siteUrl, threadId, preview,
              title: _text(thread?['title']) ?? _text(json['thread_title']),
              replyCount: (thread?['reply_count'] as num?)?.toInt()),
      bookmarkId: (bookmark?['id'] as num?)?.toInt(),
      pinned: json['pinned'] == true,
      availableFlags: flags is List ? [for (final f in flags) if (f != null) f.toString()] : const [],
      flagged: json['user_flag_status'] != null,
      authorTitle: _text(user?['title']),
    );
  }

  static String? _text(Object? v) {
    final s = v?.toString().trim();
    return s == null || s.isEmpty ? null : s;
  }

  static final Map<String, DiscourseChatMessageExtras> _byKey = {};

  static String _key(String siteUrl, int messageId) {
    var s = siteUrl.trim();
    while (s.endsWith('/')) {
      s = s.substring(0, s.length - 1);
    }
    return '$s|$messageId';
  }

  static DiscourseChatMessageExtras? of(String siteUrl, int messageId) =>
      _byKey[_key(siteUrl, messageId)];

  static void store(String siteUrl, int messageId, DiscourseChatMessageExtras extras) =>
      _byKey[_key(siteUrl, messageId)] = extras;

  static void update(String siteUrl, int messageId,
      DiscourseChatMessageExtras Function(DiscourseChatMessageExtras) change) {
    final current = of(siteUrl, messageId) ?? const DiscourseChatMessageExtras();
    store(siteUrl, messageId, change(current));
  }

  /// Only for tests and sign-out.
  static void clear() => _byKey.clear();
}
