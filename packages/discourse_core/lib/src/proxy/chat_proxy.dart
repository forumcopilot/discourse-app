import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';

import '../base_discourse_proxy.dart';
import '../data/chat/discourse_chat_channel.dart';
import '../data/chat/discourse_chat_message.dart';

/// Discourse Chat plugin (`plugins/chat/`) — channel + message API.
///
/// Endpoints used:
///   * `GET    /chat/api/me/channels`                         — list user's joined channels
///   * `GET    /chat/api/channels/:id`                        — channel details
///   * `GET    /chat/api/channels/:id/messages`               — message history (load older)
///   * `POST   /chat/:channel_id`                             — send message (note: no /api prefix)
///   * `PUT    /chat/api/channels/:cid/messages/:mid`         — edit message
///   * `DELETE /chat/api/channels/:cid/messages/:mid`         — delete message
///   * `PUT    /chat/api/channels/:cid/read/:mid`             — mark up to message read
///
/// Polling: there's no Discourse-native long-poll for chat (the web
/// client uses MessageBus + websockets). For mobile we re-fetch the
/// recent message slice with `target_message_id` / `target_date` to
/// catch up on anything posted since `lastMessageId`. A future revision
/// can subscribe to `/chat/:channel_id` via MessageBus for real-time
/// updates.
///
/// All methods degrade gracefully when the plugin isn't installed
/// (returns empty results instead of throwing).
class DiscourseChatProxy extends BaseDiscourseProxy {
  DiscourseChatProxy(SiteContext context) : super(context);

  /// Convenience accessor: returns a chat proxy bound to the current
  /// site context, or null when no site is initialised. Discourse-only
  /// callers don't have to round-trip through the factory's typed
  /// IFC*Proxy registry (chat isn't on that surface).
  static DiscourseChatProxy? forCurrentSite() {
    final ctx = SiteProxyFactory.context;
    if (ctx == null) return null;
    return DiscourseChatProxy(ctx);
  }

  /// List the channels the current user has access to. Returns an
  /// empty list when the chat plugin isn't installed or the user
  /// isn't logged in.
  Future<List<DiscourseChatChannel>> getMyChannelsAsync() async {
    try {
      final response = await apiGet('/chat/api/me/channels');
      // Shape: { public_channels: [...], direct_message_channels: [...] }
      final channels = <DiscourseChatChannel>[];
      for (final key in const ['public_channels', 'direct_message_channels']) {
        final list = (response[key] as List?) ?? const [];
        for (final raw in list.whereType<Map>()) {
          channels.add(
              DiscourseChatChannel.fromJson(raw.cast<String, dynamic>()));
        }
      }
      // Sort: unread first, then by last activity desc.
      channels.sort((a, b) {
        if ((a.unreadCount > 0) != (b.unreadCount > 0)) {
          return a.unreadCount > 0 ? -1 : 1;
        }
        final aTime = a.lastMessageAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.lastMessageAt?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });
      return channels;
    } catch (_) {
      return const [];
    }
  }

  /// Fetch metadata for a single channel.
  Future<DiscourseChatChannel?> getChannelAsync(int channelId) async {
    try {
      final response = await apiGet('/chat/api/channels/$channelId');
      final ch = (response['channel'] as Map?)?.cast<String, dynamic>();
      if (ch == null) return null;
      return DiscourseChatChannel.fromJson(ch);
    } catch (_) {
      return null;
    }
  }

  /// Fetch a slice of messages from the channel.
  ///
  /// - [pageSize]: how many messages to load (default 50, max 100).
  /// - [targetMessageId]: anchor message; loads older + newer around it.
  ///   Used for jumping to a specific message (e.g. from a notification).
  /// - [direction]: 'older' or 'newer'. With [targetMessageId] this is
  ///   ignored. Without it, 'older' loads from the most recent backward.
  Future<List<DiscourseChatMessage>> getMessagesAsync(
    int channelId, {
    int pageSize = 50,
    int? targetMessageId,
    String direction = 'older',
  }) async {
    try {
      final query = <String, String>{
        'page_size': pageSize.toString(),
        if (targetMessageId != null)
          'target_message_id': targetMessageId.toString()
        else
          'direction': direction,
      };
      final response =
          await apiGet('/chat/api/channels/$channelId/messages', query: query);
      final list = (response['messages'] as List?) ?? const [];
      return list
          .whereType<Map>()
          .map((m) =>
              DiscourseChatMessage.fromJson(m.cast<String, dynamic>()))
          .where((m) => !m.deleted)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  /// Polling helper: fetch any messages newer than [lastMessageId].
  /// Returns an empty list when there's nothing new (or the plugin's
  /// absent / channel doesn't exist).
  Future<List<DiscourseChatMessage>> pollNewerAsync(
    int channelId, {
    required int lastMessageId,
    int pageSize = 50,
  }) async {
    if (lastMessageId <= 0) {
      return getMessagesAsync(channelId, pageSize: pageSize, direction: 'older');
    }
    return getMessagesAsync(
      channelId,
      pageSize: pageSize,
      targetMessageId: lastMessageId,
      direction: 'newer',
    );
  }

  /// Send a new message to [channelId]. Returns the parsed message
  /// (so the UI can append it optimistically) or null on failure.
  ///
  /// Note: POST /chat/:channel_id (NOT /chat/api/...) — the create
  /// route lives outside the API namespace for legacy reasons.
  Future<DiscourseChatMessage?> sendMessageAsync(
      int channelId, String text) async {
    if (text.trim().isEmpty) return null;
    try {
      final response = await apiPost('/chat/$channelId', body: {
        'message': text,
      });
      // Response shape: { chat_message: {...} } or echoes the message
      // at the top level depending on Discourse version.
      final raw = (response['chat_message'] as Map?)?.cast<String, dynamic>() ??
          response.cast<String, dynamic>();
      if (!raw.containsKey('id')) return null;
      return DiscourseChatMessage.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  /// Edit a previously-sent message. Returns true on success.
  Future<bool> editMessageAsync(
      int channelId, int messageId, String text) async {
    if (text.trim().isEmpty) return false;
    try {
      await apiPut(
        '/chat/api/channels/$channelId/messages/$messageId',
        body: {'message': text},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Soft-delete a message. Returns true on success.
  Future<bool> deleteMessageAsync(int channelId, int messageId) async {
    try {
      await apiDelete('/chat/api/channels/$channelId/messages/$messageId');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Mark the channel as read up to [messageId]. Updates the user's
  /// last_read_message_id so the unread count drops to 0 for messages
  /// at or below this id.
  Future<bool> markChannelReadAsync(int channelId, {int? messageId}) async {
    try {
      final path = messageId == null
          ? '/chat/api/channels/$channelId/read'
          : '/chat/api/channels/$channelId/read/$messageId';
      await apiPut(path);
      return true;
    } catch (_) {
      return false;
    }
  }
}
