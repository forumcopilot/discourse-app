import 'package:flutter/foundation.dart' show ValueNotifier;

/// The reader's new and unread messages, as Discourse's
/// PrivateMessageTopicTrackingState keeps them (services/
/// pm-topic-tracking-state.js): one row per message from
/// `/u/{username}/private-message-topic-tracking-state`, kept current by the
/// MessageBus channels `/private-message-topic-tracking-state/user/{id}` and
/// `…/group/{id}`. The counts on the messages page's New and Unread come
/// from here, per inbox (the reader's own or a group's), as on the web.
///
/// Per forum and sign-in: the reader's credentials changing (signing out, or
/// in as someone else) forgets the rows ([resetSite]), so the next account's
/// counts never start from the previous one's. [revision] ticks on every
/// change.
class DiscourseMessageTracking {
  DiscourseMessageTracking._();

  static final Map<String, DiscourseMessageTracking> _bySite = {};

  static String _key(String siteUrl) {
    var s = siteUrl.trim();
    while (s.endsWith('/')) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }

  static DiscourseMessageTracking forSite(String siteUrl) =>
      _bySite.putIfAbsent(_key(siteUrl), DiscourseMessageTracking._);

  /// Only for tests.
  static void clear() => _bySite.clear();

  /// Forgets what the forum at [siteUrl] reported: it was another sign-in's.
  /// Counts are unknown ([isLoaded] false) until the next report loads, and
  /// whoever watches [revision] hears it, so no "Unread (3)" outlives the
  /// account it counted. Called whenever the forum's credentials change.
  static void resetSite(String siteUrl) => _bySite[_key(siteUrl)]?._reset();

  void _reset() {
    if (_states.isEmpty && !_loaded) return;
    _states.clear();
    _loaded = false;
    revision.value++;
  }

  final Map<int, Map<String, dynamic>> _states = {};
  final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// The report has loaded: counts mean something.
  bool get isLoaded => _loaded;
  bool _loaded = false;

  /// Replaces everything with a tracking-state report.
  void replaceReport(List<Map<String, dynamic>> rows) {
    _states.clear();
    for (final row in rows) {
      final id = (row['topic_id'] as num?)?.toInt();
      if (id != null) _states[id] = Map<String, dynamic>.of(row);
    }
    _loaded = true;
    revision.value++;
  }

  /// One MessageBus message (`message_type`, `topic_id`, `payload`), merged
  /// into the message's row as the web merges it. Returns its type when it
  /// changed something worth showing ("new_topic", "unread",
  /// "group_archive"), else null. [myUserId] skips the reader's own new
  /// messages.
  String? apply(Map<String, dynamic> message, {int? myUserId}) {
    final type = message['message_type']?.toString();
    final id = (message['topic_id'] as num?)?.toInt();
    final payload = (message['payload'] as Map?)?.cast<String, dynamic>() ?? const {};
    if (id == null) return null;
    switch (type) {
      case 'new_topic':
        if (myUserId != null && (payload['created_by_user_id'] as num?)?.toInt() == myUserId) return null;
        _merge(id, payload);
        return type;
      case 'unread':
        _merge(id, payload);
        return type;
      case 'read':
        _merge(id, payload);
        return null;
      case 'group_archive':
        if (myUserId != null && (payload['acting_user_id'] as num?)?.toInt() == myUserId) return null;
        return type;
    }
    return null;
  }

  void _merge(int id, Map<String, dynamic> payload) {
    _states[id] = {...?_states[id], ...payload, 'topic_id': id};
    revision.value++;
  }

  /// The message's groups.
  List<int> groupsOf(Map<String, dynamic> state) =>
      [for (final g in (state['group_ids'] as List?) ?? const []) if (g is num) g.toInt()];

  static bool _isNew(Map<String, dynamic> s) {
    final level = (s['notification_level'] as num?)?.toInt();
    return s['last_read_post_number'] == null && (level == null || level >= 2) && s['is_seen'] != true;
  }

  static bool _isUnread(Map<String, dynamic> s) {
    final lastRead = (s['last_read_post_number'] as num?)?.toInt() ?? 0;
    final highest = (s['highest_post_number'] as num?)?.toInt() ?? 0;
    final level = (s['notification_level'] as num?)?.toInt() ?? 0;
    return lastRead > 0 && lastRead < highest && level >= 2;
  }

  /// How many messages are new ([unread] false) or unread in an inbox: a
  /// group's ([groupId]), or the reader's own — messages sent to none of
  /// [myGroupIds].
  int count({required bool unread, int? groupId, Set<int> myGroupIds = const {}}) {
    var n = 0;
    for (final s in _states.values) {
      if (!(unread ? _isUnread(s) : _isNew(s))) continue;
      final groups = groupsOf(s);
      final inInbox = groupId != null ? groups.contains(groupId) : !groups.any(myGroupIds.contains);
      if (inInbox) n++;
    }
    return n;
  }

  /// Whether a message the bus named belongs in an inbox (see [count]).
  bool belongsTo(Map<String, dynamic> message, {int? groupId, Set<int> myGroupIds = const {}}) {
    final payload = (message['payload'] as Map?)?.cast<String, dynamic>() ?? const {};
    final groups = groupsOf(payload);
    return groupId != null ? groups.contains(groupId) : !groups.any(myGroupIds.contains);
  }
}
