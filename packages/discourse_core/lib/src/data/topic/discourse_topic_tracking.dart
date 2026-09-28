import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../network/discourse_message_bus.dart';

/// How far the viewer has read one topic, as Discourse tracks it.
///
/// The shared `FCTopic` carries only "has new posts" and an unread count,
/// which cannot tell a topic you read to the end from one you never opened
/// — the row greyed both. Discourse's web client decides from three
/// numbers (models/topic.js, models/topic-tracking-state.js):
///
///  * **read** ("visited"): `last_read_post_number >= highest_post_number`.
///    Only these titles step back; `>=` covers deleted posts at the end.
///  * **new**: never opened (`last_read_post_number` null) and still inside
///    the viewer's new-topic window — the list's `unseen`.
///  * **unread**: opened, tracked or watched, with posts after the reader's
///    place (lib/unread.rb counts nothing below Tracking).
@immutable
class DiscourseTopicReadState {
  const DiscourseTopicReadState({
    required this.topicId,
    required this.highestPostNumber,
    this.lastReadPostNumber,
    this.notificationLevel,
    this.unseen = false,
    this.dismissed = false,
    this.categoryId,
    this.isPrivateMessage = false,
  });

  final String topicId;

  /// The last post the viewer has read; null when they never opened it.
  final int? lastReadPostNumber;

  /// The topic's newest post number (for staff, counting whispers).
  final int highestPostNumber;

  /// 0 muted, 1 normal, 2 tracking, 3 watching; null when the viewer has
  /// no row for the topic yet.
  final int? notificationLevel;

  /// The server's "new": never opened and created inside the viewer's
  /// new-topic window.
  final bool unseen;

  /// Dismissed from New in the app (Discourse's dismissed topic).
  final bool dismissed;

  final int? categoryId;

  /// PMs are topics too. They are never counted as new or unread topics,
  /// and a PM never opened is new whatever its age — the message list's
  /// rule (DiscoursePrivateConversationProxy._isUnreadOrNew).
  final bool isPrivateMessage;

  /// Discourse's `visited`: read to the end.
  bool get isRead {
    final lastRead = lastReadPostNumber;
    return lastRead != null && lastRead >= highestPostNumber;
  }

  bool get isNew {
    if (lastReadPostNumber != null || dismissed) return false;
    return isPrivateMessage ? highestPostNumber > 0 : unseen;
  }

  /// Posts after the reader's place, in a topic they track or watch.
  int get unreadCount {
    final lastRead = lastReadPostNumber;
    if (lastRead == null || (notificationLevel ?? 1) < 2) return 0;
    return math.max(0, highestPostNumber - lastRead);
  }

  DiscourseTopicReadState copyWith({
    int? lastReadPostNumber,
    int? highestPostNumber,
    int? notificationLevel,
    bool? unseen,
    bool? dismissed,
    int? categoryId,
    bool? isPrivateMessage,
  }) =>
      DiscourseTopicReadState(
        topicId: topicId,
        lastReadPostNumber: lastReadPostNumber ?? this.lastReadPostNumber,
        highestPostNumber: highestPostNumber ?? this.highestPostNumber,
        notificationLevel: notificationLevel ?? this.notificationLevel,
        unseen: unseen ?? this.unseen,
        dismissed: dismissed ?? this.dismissed,
        categoryId: categoryId ?? this.categoryId,
        isPrivateMessage: isPrivateMessage ?? this.isPrivateMessage,
      );
}

/// New and unread topics among those a count covers.
typedef DiscourseTopicCounts = ({int newTopics, int unreadTopics});

/// The viewer's read state for every topic the app has seen on one forum:
/// Discourse's TopicTrackingState, kept beside the shared models rather
/// than on them, like `DiscourseTopicSlugs` and `DiscourseAcceptedAnswers`.
///
/// Fed by:
///  * every topic payload the app fetches — lists, search, the topic view
///    (the proxies record them as they pass);
///  * `/u/{username}/topic-tracking-state.json`, the viewer's new and
///    unread topics, which the counts come from ([replaceReport]);
///  * reading in the app: each post the topic page reports to
///    `/topics/timings` ([recordRead]), so a list row changes the moment
///    you come back, not on the next refresh;
///  * dismissing ([applyDismissedNew], [applyDismissedUnread]);
///  * the forum's own live messages while a list is on screen
///    ([watchLive]) — reading on another device, replies in topics you
///    track — as its web client does.
///
/// Read positions only move forward: a payload fetched before a read was
/// reported cannot put the topic back to unread.
class DiscourseTopicTracking extends ChangeNotifier {
  DiscourseTopicTracking._();

  static final Map<String, DiscourseTopicTracking> _byForum = {};

  static String _key(String forumUrl) =>
      forumUrl.replaceAll(RegExp(r'/+$'), '').toLowerCase();

  /// The store for the forum at [forumUrl].
  static DiscourseTopicTracking of(String forumUrl) =>
      _byForum.putIfAbsent(_key(forumUrl), DiscourseTopicTracking._);

  /// The store for [context]'s forum and signed-in user. Read state is the
  /// user's: signing out, or in as someone else, starts it empty.
  static DiscourseTopicTracking forSite(SiteContext context) {
    final tracking = of(context.site.url);
    final owner = context.loginDataOutput?.user?.username;
    if (owner != tracking._owner) {
      // Silently: this can run while a row is building.
      tracking._reset();
      tracking._owner = owner;
    }
    return tracking;
  }

  /// Only for tests.
  @visibleForTesting
  static void clearAll() {
    for (final t in _byForum.values) {
      t._stopLive();
    }
    _byForum.clear();
  }

  String? _owner;
  final Map<String, DiscourseTopicReadState> _states = {};

  /// Topics the counts cover: the last report's, plus topics that turned
  /// unread since (a reply in a tracked topic, pushed live).
  final Set<String> _counted = {};
  DateTime? _reportLoadedAt;

  void _reset() {
    _states.clear();
    _counted.clear();
    _reportLoadedAt = null;
  }

  /// The read state of [topicId], or null when no payload has told us.
  DiscourseTopicReadState? stateOf(String topicId) => _states[topicId];

  /// When the report the counts come from was loaded; null before one was.
  DateTime? get reportLoadedAt => _reportLoadedAt;

  /// Whether the counts are worth showing: a report has been loaded.
  bool get hasCounts => _reportLoadedAt != null;

  /// New and unread topics, site-wide or in [categoryIds]; null until a
  /// report has been loaded, so a count is never a guess.
  DiscourseTopicCounts? counts({Set<int>? categoryIds}) {
    if (_reportLoadedAt == null) return null;
    var newTopics = 0;
    var unreadTopics = 0;
    for (final id in _counted) {
      final s = _states[id];
      if (s == null || s.isPrivateMessage) continue;
      if (categoryIds != null && !categoryIds.contains(s.categoryId)) {
        continue;
      }
      if (s.isNew) {
        newTopics++;
      } else if (s.unreadCount > 0) {
        unreadTopics++;
      }
    }
    return (newTopics: newTopics, unreadTopics: unreadTopics);
  }

  // ===== Recording =====

  /// Records a topic from a list or topic-view payload (the fields
  /// ListableTopicSerializer and TopicViewSerializer share). Ignores one
  /// without `highest_post_number`: there is nothing to decide with.
  void recordTopicJson(Map<String, dynamic> t) {
    final id = '${t['id'] ?? ''}';
    final highest = _int(t['highest_post_number']);
    if (id.isEmpty || highest == null) return;
    final details = t['details'];
    _mergeFromServer(
      id,
      lastRead: _int(t['last_read_post_number']),
      highest: highest,
      level: _int(t['notification_level']) ??
          (details is Map ? _int(details['notification_level']) : null),
      // Topic views carry no `unseen`; keep what a list said.
      unseen: t.containsKey('unseen') ? t['unseen'] == true : null,
      categoryId: _int(t['category_id']),
      isPrivateMessage: t['archetype'] == 'private_message',
    );
    _changed();
  }

  /// Records that the reader has seen [postNumber] in [topicId] (the topic
  /// page reports it to `/topics/timings`, which moves
  /// `last_read_post_number` to the highest post reported).
  void recordRead(String topicId, int postNumber) {
    if (topicId.isEmpty || postNumber <= 0) return;
    final s = _states[topicId];
    if (s == null) {
      _states[topicId] = DiscourseTopicReadState(
          topicId: topicId,
          highestPostNumber: postNumber,
          lastReadPostNumber: postNumber);
    } else {
      final lastRead = s.lastReadPostNumber;
      if (lastRead != null && lastRead >= postNumber) return;
      _states[topicId] = s.copyWith(
        lastReadPostNumber: postNumber,
        highestPostNumber: math.max(s.highestPostNumber, postNumber),
        unseen: false,
      );
    }
    _changed();
  }

  /// Replaces the counted set with a `/u/{username}/topic-tracking-state`
  /// report (TopicTrackingStateItemSerializer rows): the viewer's new and
  /// unread topics.
  void replaceReport(List<Map<String, dynamic>> rows) {
    _counted.clear();
    for (final r in rows) {
      final id = '${r['topic_id'] ?? ''}';
      final highest = _int(r['highest_post_number']);
      if (id.isEmpty || highest == null) continue;
      final lastRead = _int(r['last_read_post_number']);
      final level = _int(r['notification_level']);
      _mergeFromServer(
        id,
        lastRead: lastRead,
        highest: highest,
        level: level,
        // isNew in models/topic-tracking-state.js: never read, in the new
        // period, and not below Tracking once the viewer has a level.
        unseen: lastRead == null &&
            r['created_in_new_period'] == true &&
            (level == null || level >= 2),
        categoryId: _int(r['category_id']),
        isPrivateMessage: false,
      );
      _counted.add(id);
    }
    _reportLoadedAt = DateTime.now();
    _changed();
  }

  /// Topics PUT /topics/reset-new dismissed: no longer new.
  void applyDismissedNew(Iterable<String> topicIds) {
    for (final id in topicIds) {
      final s = _states[id];
      if (s != null) _states[id] = s.copyWith(dismissed: true, unseen: false);
    }
    _changed();
  }

  /// Topics whose new replies were dismissed (`dismiss_posts`): read up to
  /// their newest post.
  void applyDismissedUnread(Iterable<String> topicIds) {
    for (final id in topicIds) {
      final s = _states[id];
      if (s != null) {
        _states[id] = s.copyWith(lastReadPostNumber: s.highestPostNumber);
      }
    }
    _changed();
  }

  /// Topics set back to Normal ("Stop tracking these topics"): they keep
  /// their read place but no longer count as unread.
  void applyUntracked(Iterable<String> topicIds) {
    for (final id in topicIds) {
      final s = _states[id];
      if (s != null) _states[id] = s.copyWith(notificationLevel: 1);
    }
    _changed();
  }

  /// Applies one message from the forum's `/unread` or `/unread/{user_id}`
  /// channel (TopicTrackingState.publish_read / publish_unread /
  /// publish_dismiss_new / publish_dismiss_new_posts).
  @visibleForTesting
  void applyBusMessage(Map<String, dynamic> data) {
    final type = data['message_type'];
    final id = '${data['topic_id'] ?? ''}';
    final payload = data['payload'];
    final p = payload is Map ? payload.cast<String, dynamic>() : const {};
    switch (type) {
      case 'read':
        // Read here or on another device.
        final highest = _int(p['highest_post_number']);
        final lastRead = _int(p['last_read_post_number']);
        if (id.isEmpty || highest == null) return;
        _mergeFromServer(id,
            lastRead: lastRead,
            highest: highest,
            level: _int(p['notification_level']),
            unseen: lastRead == null ? null : false);
      case 'unread':
        // A new post in a topic the viewer tracks (sent only to them).
        final highest = _int(p['highest_post_number']);
        if (id.isEmpty || highest == null) return;
        final s = _states[id];
        _states[id] = s == null
            // Not seen yet: it was read to the end, or it would have been
            // in the report — so this post is the unread one.
            ? DiscourseTopicReadState(
                topicId: id,
                highestPostNumber: highest,
                lastReadPostNumber: highest - 1,
                notificationLevel: 2,
                categoryId: _int(p['category_id']),
              )
            : s.copyWith(
                highestPostNumber: math.max(s.highestPostNumber, highest));
        _counted.add(id);
      case 'dismiss_new':
        applyDismissedNew(_ids(p['topic_ids']));
        return;
      case 'dismiss_new_posts':
        applyDismissedUnread(_ids(p['topic_ids']));
        return;
      default:
        return;
    }
    _changed();
  }

  void _mergeFromServer(
    String id, {
    required int? lastRead,
    required int highest,
    required int? level,
    required bool? unseen,
    int? categoryId,
    bool? isPrivateMessage,
  }) {
    final s = _states[id];
    if (s == null) {
      _states[id] = DiscourseTopicReadState(
        topicId: id,
        lastReadPostNumber: lastRead,
        highestPostNumber: highest,
        notificationLevel: level,
        unseen: unseen ?? false,
        categoryId: categoryId,
        isPrivateMessage: isPrivateMessage ?? false,
      );
      return;
    }
    final known = s.lastReadPostNumber;
    _states[id] = DiscourseTopicReadState(
      topicId: id,
      // Forward only: this payload may predate a read the app reported.
      lastReadPostNumber: known == null || lastRead == null
          ? (known ?? lastRead)
          : math.max(known, lastRead),
      // The server's own: it drops when the last post is deleted.
      highestPostNumber: highest,
      notificationLevel: level ?? s.notificationLevel,
      unseen: unseen ?? s.unseen,
      dismissed: s.dismissed,
      categoryId: categoryId ?? s.categoryId,
      isPrivateMessage: isPrivateMessage ?? s.isPrivateMessage,
    );
  }

  // ===== Live updates =====

  int _liveWatchers = 0;
  List<void Function()> _unsubscribe = const [];

  /// Keeps this store current from the forum's live messages until the
  /// returned function is called. Shared: the channels are subscribed
  /// while at least one caller is watching. Costs one long-poll per ~25 s
  /// on the forum's message bus (see [DiscourseMessageBus]), so callers
  /// watch only while a list is on screen.
  void Function() watchLive(SiteContext context) {
    final userId = context.loginDataOutput?.user?.id;
    if (userId == null || userId.isEmpty) return () {};
    if (_liveWatchers++ == 0) {
      final bus = DiscourseMessageBus.of(context);
      _unsubscribe = [
        bus.subscribe('/unread/$userId', applyBusMessage),
        bus.subscribe('/unread', applyBusMessage),
      ];
    }
    var stopped = false;
    return () {
      if (stopped) return;
      stopped = true;
      if (--_liveWatchers == 0) _stopLive();
    };
  }

  void _stopLive() {
    for (final u in _unsubscribe) {
      u();
    }
    _unsubscribe = const [];
    _liveWatchers = 0;
  }

  /// Whether the live channels are subscribed, for tests.
  @visibleForTesting
  bool get isLive => _unsubscribe.isNotEmpty;

  // ===== Helpers =====

  bool _notifyScheduled = false;

  /// One notification per burst: a list of 30 topics, or a batch of live
  /// messages, rebuilds the rows once.
  void _changed() {
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    scheduleMicrotask(() {
      _notifyScheduled = false;
      notifyListeners();
    });
  }

  static int? _int(Object? v) =>
      v is num ? v.toInt() : (v is String ? int.tryParse(v) : null);

  static Iterable<String> _ids(Object? v) =>
      v is List ? v.map((e) => '$e').where((e) => e.isNotEmpty) : const [];
}
