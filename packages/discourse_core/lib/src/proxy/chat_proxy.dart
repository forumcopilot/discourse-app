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
///   * `PUT    /chat/api/channels/:cid/read/:mid`    — mark read
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
      // Shape: { public_channels: [...], direct_message_channels: [...] }
      final channels = <FCChatChannel>[];
      for (final key in const ['public_channels', 'direct_message_channels']) {
        final list = (response[key] as List?) ?? const [];
        for (final raw in list.whereType<Map>()) {
          channels.add(_channelFromJson(raw.cast<String, dynamic>()));
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
      return FCChatChannelListResult(result: false, resultText: 'Error: $e');
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
      return FCChatChannelResult(result: false, resultText: 'Error: $e');
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
      final query = <String, String>{
        'page_size': pageSize.toString(),
        if (targetMessageId != null)
          'target_message_id': targetMessageId.toString()
        else
          'direction': direction,
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
      return FCChatMessageListResult(result: false, resultText: 'Error: $e');
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
      // Response shape: { chat_message: {...} } or echoes the message
      // at the top level depending on Discourse version.
      final raw =
          (response['chat_message'] as Map?)?.cast<String, dynamic>() ??
              response.cast<String, dynamic>();
      if (!raw.containsKey('id')) {
        return FCChatMessageResult(
          result: false,
          resultText: 'Server returned no message id',
        );
      }
      return FCChatMessageResult(
        result: true,
        message: _messageFromJson(raw),
      );
    } on DiscourseApiException catch (e) {
      return FCChatMessageResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCChatMessageResult(result: false, resultText: 'Error: $e');
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
      return FCChatActionResult(result: false, resultText: 'Error: $e');
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
      return FCChatActionResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCChatActionResult> markChannelReadAsync(
    int channelId, {
    int? messageId,
  }) async {
    try {
      final path = messageId == null
          ? '/chat/api/channels/$channelId/read'
          : '/chat/api/channels/$channelId/read/$messageId';
      await apiPut(path);
      return FCChatActionResult(result: true);
    } on DiscourseApiException catch (e) {
      return FCChatActionResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCChatActionResult(result: false, resultText: 'Error: $e');
    }
  }

  FCChatChannel _channelFromJson(Map<String, dynamic> json) {
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
      unreadCount: (membership?['unread_count'] as num?)?.toInt() ?? 0,
      mentionCount: (membership?['mention_count'] as num?)?.toInt() ?? 0,
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
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      edited: json['edited'] == true,
      deleted: json['deleted_at'] != null,
      streaming: json['streaming'] == true,
    );
  }
}
