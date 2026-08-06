import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_chat_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_channel.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_message.dart';
import 'package:forumcopilot_sdk/models/results/fc_chat_result.dart';

import '../base_discourse_proxy.dart';

/// Discourse implementation of [IFCChatProxy] (Phase 5.39 — lifted
/// off the `DiscourseChatProxy.forCurrentSite()` sidecar).
///
/// Endpoints used:
///   * `GET    /chat/api/me/channels`                — list user's channels
///   * `GET    /chat/api/channels/:id`               — single channel
///   * `GET    /chat/api/channels/:id/messages`      — page of messages
///   * `POST   /chat/:channel_id`                    — send a message
///   * `PUT    /chat/api/channels/:cid/messages/:mid` — edit a message
///   * `DELETE /chat/api/channels/:cid/messages/:mid` — delete a message
///   * `PUT    /chat/api/channels/:cid/read`          — mark read
///                                                      (message_id in body)
///   * `POST   /chat/api/direct-message-channels`     — create/reuse a DM
///   * `PUT    /chat/:cid/react/:mid`                 — add/remove a
///                                                      message reaction
///
/// Polling: no Discourse-native long-poll for chat (web uses
/// MessageBus + websockets). For mobile we re-fetch the recent
/// message slice with `target_message_id` / `direction=newer`. A
/// future revision can subscribe via MessageBus for realtime updates.
///
/// All methods return `result:false` results when the plugin isn't
/// installed (404) so UI degrades gracefully.
class DiscourseChatProxy extends BaseDiscourseProxy implements IFCChatProxy {
  DiscourseChatProxy(SiteContext context) : super(context);

  @override
  Future<FCChatChannelListResult> getMyChannelsAsync() async {
    try {
      final response = await apiGet('/chat/api/me/channels');
      // Shape: { public_channels: [...], direct_message_channels: [...],
      //          tracking: { channel_tracking: { "<id>": { unread_count,
      //          mention_count, ... } } } }
      // Unread/mention counts live in the top-level `tracking` object
      // (structured_channel_serializer), NOT on
      // current_user_membership — pass the per-channel entry through.
      final tracking = (response['tracking'] as Map?)?.cast<String, dynamic>();
      final channelTracking =
          (tracking?['channel_tracking'] as Map?)?.cast<String, dynamic>();
      final channels = <FCChatChannel>[];
      for (final key in const ['public_channels', 'direct_message_channels']) {
        final list = (response[key] as List?) ?? const [];
        for (final raw in list.whereType<Map>()) {
          final json = raw.cast<String, dynamic>();
          final trackingInfo =
              (channelTracking?['${json['id']}'] as Map?)
                  ?.cast<String, dynamic>();
          channels.add(_channelFromJson(json, tracking: trackingInfo));
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
      return FCChatChannelListResult(result: true, channels: channels);
    } on DiscourseApiException catch (e) {
      return FCChatChannelListResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCChatChannelListResult(result: false, resultText: describeApiError(e));
    }
  }

  @override
  Future<FCChatChannelResult> getChannelAsync(int channelId) async {
    try {
      final response = await apiGet('/chat/api/channels/$channelId');
      final ch = (response['channel'] as Map?)?.cast<String, dynamic>();
      if (ch == null) return FCChatChannelResult(result: true);
      return FCChatChannelResult(result: true, channel: _channelFromJson(ch));
    } on DiscourseApiException catch (e) {
      return FCChatChannelResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCChatChannelResult(result: false, resultText: describeApiError(e));
    }
  }

  @override
  Future<FCChatMessageListResult> getMessagesAsync(
    int channelId, {
    int pageSize = 30,
    int? targetMessageId,
    String direction = 'past',
  }) async {
    try {
      // Send BOTH params when a target is given: the server treats
      // `target_message_id` without `direction` as "fetch messages
      // AROUND the target" (Chat::MessagesQuery#query_around_target),
      // which re-delivers old messages — with `direction` it paginates
      // strictly past/future of the target as intended.
      final query = <String, String>{
        'page_size': pageSize.toString(),
        'direction': direction,
        if (targetMessageId != null)
          'target_message_id': targetMessageId.toString(),
      };
      final response = await apiGet(
        '/chat/api/channels/$channelId/messages',
        query: query,
      );
      final list = (response['messages'] as List?) ?? const [];
      final messages = list
          .whereType<Map>()
          .map((m) => _messageFromJson(m.cast<String, dynamic>()))
          .where((m) => !m.deleted)
          .toList(growable: false);
      return FCChatMessageListResult(result: true, messages: messages);
    } on DiscourseApiException catch (e) {
      return FCChatMessageListResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCChatMessageListResult(result: false, resultText: describeApiError(e));
    }
  }

  @override
  Future<FCChatMessageListResult> pollNewerAsync(
    int channelId, {
    required int lastMessageId,
    int pageSize = 50,
  }) async {
    if (lastMessageId <= 0) {
      return getMessagesAsync(
        channelId,
        pageSize: pageSize,
        direction: 'past',
      );
    }
    return getMessagesAsync(
      channelId,
      pageSize: pageSize,
      targetMessageId: lastMessageId,
      direction: 'future',
    );
  }

  @override
  Future<FCChatMessageResult> sendMessageAsync(
    int channelId,
    String message,
  ) async {
    if (message.trim().isEmpty) {
      return FCChatMessageResult(
        result: false,
        resultText: 'Message is empty',
      );
    }
    try {
      // POST /chat/:channel_id (NOT /chat/api/...) — the create route
      // lives outside the API namespace for legacy reasons.
      final response = await apiPost('/chat/$channelId', body: {
        'message': message,
      });
      // Response shape: success_json.merge(message_id:) — i.e.
      // { success: "OK", message_id: 123 }
      // (chat/api/channel_messages_controller.rb#create). The created
      // message is NOT echoed back, so synthesize a local echo from
      // what we sent; the next poll replaces it with the server copy.
      final messageId = (response['message_id'] as num?)?.toInt();
      if (messageId == null) {
        return FCChatMessageResult(
          result: false,
          resultText: 'Server returned no message id',
        );
      }
      return FCChatMessageResult(
        result: true,
        message: FCChatMessage(
          id: messageId,
          channelId: channelId,
          message: message,
          cooked: message,
          authorId: int.tryParse(siteContext.currentUserId ?? '') ?? 0,
          authorUsername: siteContext.currentUsername ?? '',
          // CLIENT clock, not a server timestamp: the create response
          // carries only `message_id` (see above), so this is the local
          // echo's own send time. Replaced by the server's `created_at`
          // on the next poll.
          createdAt: DateTime.now(),
          edited: false,
          deleted: false,
          streaming: false,
        ),
      );
    } on DiscourseApiException catch (e) {
      return FCChatMessageResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCChatMessageResult(result: false, resultText: describeApiError(e));
    }
  }

  @override
  Future<FCChatActionResult> editMessageAsync(
    int channelId,
    int messageId,
    String message,
  ) async {
    if (message.trim().isEmpty) {
      return FCChatActionResult(result: false, resultText: 'Message is empty');
    }
    try {
      await apiPut(
        '/chat/api/channels/$channelId/messages/$messageId',
        body: {'message': message},
      );
      return FCChatActionResult(result: true);
    } on DiscourseApiException catch (e) {
      return FCChatActionResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCChatActionResult(result: false, resultText: describeApiError(e));
    }
  }

  @override
  Future<FCChatActionResult> deleteMessageAsync(
    int channelId,
    int messageId,
  ) async {
    try {
      await apiDelete('/chat/api/channels/$channelId/messages/$messageId');
      return FCChatActionResult(result: true);
    } on DiscourseApiException catch (e) {
      return FCChatActionResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCChatActionResult(result: false, resultText: describeApiError(e));
    }
  }

  @override
  Future<FCChatActionResult> markChannelReadAsync(
    int channelId, {
    int? messageId,
  }) async {
    try {
      // Route: PUT /chat/api/channels/:channel_id/read with message_id
      // in the body (plugins/chat/config/routes.rb). The
      // Chat::UpdateUserChannelLastRead service REQUIRES message_id, so
      // when the caller doesn't know one, resolve the channel's latest
      // message id first.
      var targetId = messageId;
      if (targetId == null) {
        final channel = await apiGet('/chat/api/channels/$channelId');
        final ch = (channel['channel'] as Map?)?.cast<String, dynamic>();
        final lastMessage =
            (ch?['last_message'] as Map?)?.cast<String, dynamic>();
        targetId = (lastMessage?['id'] as num?)?.toInt();
        if (targetId == null) {
          // Empty channel — nothing to mark as read.
          return FCChatActionResult(result: true);
        }
      }
      await apiPut('/chat/api/channels/$channelId/read',
          body: {'message_id': targetId});
      return FCChatActionResult(result: true);
    } on DiscourseApiException catch (e) {
      return FCChatActionResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCChatActionResult(result: false, resultText: describeApiError(e));
    }
  }

  // ===== Discourse-native surface (no IFC interface methods) =====

  /// Creates (or reuses) a direct-message channel with [usernames].
  ///
  /// `POST /chat/api/direct-message-channels` with `target_usernames`
  /// (plugins/chat/config/routes.rb →
  /// Chat::Api::DirectMessagesController#create →
  /// Chat::CreateDirectMessageChannel). The current user is added
  /// implicitly — pass only the other participants. For 1:1 DMs the
  /// existing channel is reused automatically; for group DMs (2+
  /// targets) pass [upsert] true to reuse an existing channel with the
  /// same member set instead of creating another.
  ///
  /// Policy failures (DMs disabled, a target doesn't accept DMs, too
  /// many members) come back as 400/422 with a readable message,
  /// surfaced via `resultText`.
  Future<FCChatChannelResult> createDirectMessageChannelAsync(
    List<String> usernames, {
    bool upsert = false,
  }) async {
    final targets = usernames.where((u) => u.trim().isNotEmpty).toList();
    if (targets.isEmpty) {
      return FCChatChannelResult(
          result: false, resultText: 'No usernames supplied');
    }
    try {
      final response =
          await apiPost('/chat/api/direct-message-channels', body: {
        'target_usernames': targets,
        if (upsert) 'upsert': true,
      });
      final ch = (response['channel'] as Map?)?.cast<String, dynamic>();
      if (ch == null) {
        return FCChatChannelResult(
            result: false, resultText: 'Server returned no channel');
      }
      return FCChatChannelResult(result: true, channel: _channelFromJson(ch));
    } on DiscourseApiException catch (e) {
      return FCChatChannelResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCChatChannelResult(result: false, resultText: describeApiError(e));
    }
  }

  /// Adds or removes an emoji reaction on a chat message.
  ///
  /// `PUT /chat/{channel_id}/react/{message_id}` — the legacy
  /// non-API-namespace route (plugins/chat/config/routes.rb →
  /// Chat::ChatController#react, which requires `message_id`, `emoji`
  /// and `react_action` params; Chat::MessageReactor accepts
  /// react_action `add` / `remove`). [emoji] is the Discourse emoji
  /// name WITHOUT colons (e.g. `heart`, `tada`); unknown names 400.
  ///
  /// The server does not echo the new reaction state — callers keep
  /// their optimistic update on [FCChatMessage.reactions] client-side
  /// (reverting on `result:false`); the next message fetch re-parses
  /// the authoritative state.
  Future<FCChatActionResult> toggleChatMessageReactionAsync(
    int channelId,
    int messageId,
    String emoji, {
    required bool add,
  }) async {
    if (emoji.trim().isEmpty) {
      return FCChatActionResult(result: false, resultText: 'Emoji required');
    }
    try {
      await apiPut('/chat/$channelId/react/$messageId', body: {
        'emoji': emoji,
        'react_action': add ? 'add' : 'remove',
      });
      return FCChatActionResult(result: true);
    } on DiscourseApiException catch (e) {
      return FCChatActionResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCChatActionResult(result: false, resultText: describeApiError(e));
    }
  }

  FCChatChannel _channelFromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? tracking,
  }) {
    final membership =
        (json['current_user_membership'] as Map?)?.cast<String, dynamic>();
    final meta = (json['meta'] as Map?)?.cast<String, dynamic>();
    final lastMessage =
        (json['last_message'] as Map?)?.cast<String, dynamic>();
    return FCChatChannel(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      slug: json['slug']?.toString(),
      chatableType: (json['chatable_type'] ?? 'Category').toString(),
      // Prefer the response-level tracking entry; the membership fields
      // are kept as a fallback for older serializer shapes.
      unreadCount: (tracking?['unread_count'] as num?)?.toInt() ??
          (membership?['unread_count'] as num?)?.toInt() ??
          0,
      mentionCount: (tracking?['mention_count'] as num?)?.toInt() ??
          (membership?['mention_count'] as num?)?.toInt() ??
          0,
      lastReadMessageId:
          (membership?['last_read_message_id'] as num?)?.toInt(),
      isFollowing: membership?['following'] == true,
      canJoin: meta?['can_join_chat_channel'] == true,
      status: (json['status'] ?? 'open').toString(),
      lastMessageAt: DateTime.tryParse(
              lastMessage?['created_at']?.toString() ?? '') ??
          DateTime.tryParse(
              json['last_message_sent_at']?.toString() ?? ''),
    );
  }

  FCChatMessage _messageFromJson(Map<String, dynamic> json) {
    // The message serializer omits `reactions` entirely when there are
    // none — mapping the absent field to an empty list means a removed
    // last reaction clears stale chips on the next fetch.
    final reactions = ((json['reactions'] as List?) ?? const [])
        .whereType<Map>()
        .map((raw) {
          final r = raw.cast<String, dynamic>();
          return FCChatMessageReaction(
            emoji: (r['emoji'] ?? '').toString(),
            count: (r['count'] as num?)?.toInt() ?? 0,
            reacted: r['reacted'] == true,
            usernames: ((r['users'] as List?) ?? const [])
                .whereType<Map>()
                .map((u) => (u['username'] ?? '').toString())
                .where((u) => u.isNotEmpty)
                .toList(growable: false),
          );
        })
        .toList(growable: false);
    final user = (json['user'] as Map?)?.cast<String, dynamic>() ?? const {};
    final tpl = user['avatar_template']?.toString();
    String? avatarUrl;
    if (tpl != null && tpl.isNotEmpty) {
      final filled = tpl.replaceAll('{size}', '60');
      avatarUrl =
          filled.startsWith('http') ? filled : '${siteContext.site.url}$filled';
    }
    return FCChatMessage(
      id: (json['id'] as num).toInt(),
      channelId: (json['chat_channel_id'] as num?)?.toInt() ?? 0,
      threadId: (json['thread_id'] as num?)?.toInt(),
      message: (json['message'] ?? '').toString(),
      cooked: (json['cooked'] ?? json['message'] ?? '').toString(),
      excerpt: json['excerpt']?.toString(),
      authorId: (user['id'] as num?)?.toInt() ?? 0,
      authorUsername: (user['username'] ?? '').toString(),
      authorName: user['name']?.toString(),
      authorAvatarUrl: avatarUrl,
      // `created_at` is always serialized on a chat message; epoch is a
      // visible sentinel for a malformed row rather than a plausible
      // "just now".
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      edited: json['edited'] == true,
      deleted: json['deleted_at'] != null,
      streaming: json['streaming'] == true,
      reactions: reactions,
    );
  }
}
