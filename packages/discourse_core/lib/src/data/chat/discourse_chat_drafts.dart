import 'dart:convert';

/// The reader's unsent chat messages, per forum and channel (and thread).
///
/// Discourse keeps them on the server (`POST …/drafts`, read back as the
/// current user's `chat_drafts`), so a draft started on the web is there in
/// the app and the other way round. Kept here from the current user as the
/// app reads it, and updated as the reader types, so a channel opens with
/// what was left in it. Text only; a draft's files are not restored.
class DiscourseChatDrafts {
  DiscourseChatDrafts._();

  static final Map<String, String> _byKey = {};

  static String _key(String siteUrl, int channelId, int? threadId) {
    var s = siteUrl.trim();
    while (s.endsWith('/')) {
      s = s.substring(0, s.length - 1);
    }
    return '$s|$channelId|${threadId ?? ''}';
  }

  /// Records the current user's `chat_drafts`
  /// (`[{channel_id, thread_id, data: "{\"message\":…}"}]`).
  static void storeFromCurrentUser(String siteUrl, Object? drafts) {
    if (drafts is! List) return;
    for (final raw in drafts.whereType<Map>()) {
      final channelId = (raw['channel_id'] as num?)?.toInt();
      if (channelId == null) continue;
      final threadId = (raw['thread_id'] as num?)?.toInt();
      final message = messageOf(raw['data']);
      if (message != null && message.trim().isNotEmpty) {
        _byKey[_key(siteUrl, channelId, threadId)] = message;
      }
    }
  }

  /// The message text inside a draft's `data` (a JSON string, or already
  /// decoded).
  static String? messageOf(Object? data) {
    Object? decoded = data;
    if (data is String) {
      try {
        decoded = jsonDecode(data);
      } catch (_) {
        return null;
      }
    }
    return decoded is Map ? decoded['message']?.toString() : null;
  }

  static String? of(String siteUrl, int channelId, {int? threadId}) =>
      _byKey[_key(siteUrl, channelId, threadId)];

  static void remember(String siteUrl, int channelId, String text, {int? threadId}) {
    final key = _key(siteUrl, channelId, threadId);
    if (text.trim().isEmpty) {
      _byKey.remove(key);
    } else {
      _byKey[key] = text;
    }
  }

  /// Only for tests and sign-out.
  static void clear() => _byKey.clear();
}
