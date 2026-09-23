import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_chat_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_channel.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_message.dart';
import 'package:forumcopilot_sdk/models/results/fc_chat_result.dart';

import 'package:flutter/foundation.dart' show visibleForTesting;

import '../base_discourse_proxy.dart';
import '../data/chat/discourse_chat_event.dart';
import '../data/chat/discourse_chatable.dart';
import '../data/chat/discourse_chat_uploads.dart';
import '../data/chat/discourse_chat_permissions.dart';
import 'package:forumcopilot_sdk/models/entities/fc_attachment.dart';
import '../network/discourse_message_bus.dart';

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
/// Live updates: [watchChannel] subscribes to the channel's MessageBus
/// channel `/chat/{id}` (long-polled by DiscourseMessageBus), which is how
/// Discourse web stays current. Polling with `direction=future` remains for a
/// key the forum refuses message-bus access to.
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
      _recordBusLastId(channelId, ch);
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
      // An empty [direction] with a target asks for the messages AROUND
      // it, for opening a channel on one message (a notification).
      final query = <String, String>{
        'page_size': pageSize.toString(),
        if (direction.isNotEmpty) 'direction': direction,
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
        body: {
          'message': message,
          // Without these Discourse detaches the message's images and files
          // (Chat::UpdateMessage#modify_message reads a missing list as none).
          'upload_ids': DiscourseChatUploads.idsFor(siteContext.site.url, messageId),
        },
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
  ///
  /// [groups] are sent as `target_groups` — they used to go in
  /// `target_usernames`, where Discourse cannot resolve them.
  Future<FCChatChannelResult> createDirectMessageChannelAsync(
    List<String> usernames, {
    List<String> groups = const [],
    bool upsert = false,
  }) async {
    final targets = usernames.where((u) => u.trim().isNotEmpty).toList();
    final targetGroups = groups.where((g) => g.trim().isNotEmpty).toList();
    if (targets.isEmpty && targetGroups.isEmpty) {
      return FCChatChannelResult(
          result: false, resultText: 'No usernames supplied');
    }
    try {
      final response =
          await apiPost('/chat/api/direct-message-channels', body: {
        if (targets.isNotEmpty) 'target_usernames': targets,
        if (targetGroups.isNotEmpty) 'target_groups': targetGroups,
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

  /// Discourse-only: people and groups a chat can be started with, from the
  /// chat plugin's own search (GET /chat/api/chatables). Unlike the general
  /// user search it says whether each can actually chat, so a pick that
  /// Discourse would silently drop — and that could leave a DM with only
  /// yourself — is never offered as available.
  Future<List<DiscourseChatable>> searchChatablesAsync(String term) async {
    final t = term.trim().replaceFirst(RegExp(r'^@'), '');
    if (t.isEmpty) return const [];
    try {
      final response = await apiGet('/chat/api/chatables.json', query: {
        'term': t,
        'include_users': 'true',
        'include_groups': 'true',
        'include_category_channels': 'false',
        'include_direct_message_channels': 'false',
      });
      final out = <DiscourseChatable>[];
      for (final entry in ((response['users'] as List?) ?? const []).whereType<Map>()) {
        final m = (entry['model'] as Map?)?.cast<String, dynamic>();
        final username = m?['username']?.toString();
        if (m == null || username == null || username.isEmpty) continue;
        final tpl = m['avatar_template']?.toString();
        String? avatar;
        if (tpl != null && tpl.isNotEmpty) {
          final filled = tpl.replaceAll('{size}', '60');
          avatar = filled.startsWith('http') ? filled : '${siteContext.site.url}$filled';
        }
        out.add(DiscourseChatable(
          isGroup: false,
          name: username,
          label: (m['name'] as String?)?.isNotEmpty == true ? m['name'] as String : null,
          avatarUrl: avatar,
          canChat: m['can_chat'] == true && m['has_chat_enabled'] == true,
        ));
      }
      for (final entry in ((response['groups'] as List?) ?? const []).whereType<Map>()) {
        final m = (entry['model'] as Map?)?.cast<String, dynamic>();
        final name = m?['name']?.toString();
        if (m == null || name == null || name.isEmpty) continue;
        out.add(DiscourseChatable(
          isGroup: true,
          name: name,
          label: (m['full_name'] as String?)?.isNotEmpty == true ? m['full_name'] as String : null,
          canChat: m['can_chat'] == true,
        ));
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  // ===== Live updates (Discourse-only) =====

  /// Each channel's MessageBus position as of its last fetch
  /// (`meta.message_bus_last_ids.channel_message_bus_last_id`), keyed by forum
  /// and channel: subscribing from there delivers exactly what was published
  /// after the messages on screen were loaded.
  static final Map<String, int> _busLastIds = {};

  String _busKey(int channelId) => '${siteContext.site.url}|$channelId';

  void _recordBusLastId(int channelId, Map<String, dynamic> channelJson) {
    final ids = ((channelJson['meta'] as Map?)?['message_bus_last_ids'] as Map?);
    final id = (ids?['channel_message_bus_last_id'] as num?)?.toInt();
    if (id != null) _busLastIds[_busKey(channelId)] = id;
  }

  /// Whether [watchChannel] can deliver: false once the forum has refused this
  /// key's message-bus requests (a key minted without the `message_bus`
  /// scope). Callers then fall back to fetching.
  bool get liveUpdatesAvailable =>
      !DiscourseMessageBus.of(siteContext).isUnavailable;

  /// Discourse-only: call [onEvent] for every change published to
  /// [channelId] after its last [getChannelAsync] — new, edited, deleted and
  /// restored messages, and reactions. Returns a function that stops
  /// watching, or null when live updates are unavailable.
  void Function()? watchChannel(
    int channelId,
    void Function(DiscourseChatEvent event) onEvent,
  ) {
    final bus = DiscourseMessageBus.of(siteContext);
    if (bus.isUnavailable) return null;
    return bus.subscribe(
      '/chat/$channelId',
      (data) {
        final event = chatEventFrom(data);
        if (event != null) onEvent(event);
      },
      lastId: _busLastIds[_busKey(channelId)] ?? -1,
    );
  }

  /// One MessageBus payload from `/chat/{id}` as an event, or null for kinds
  /// the app does not show (threads, notices, flags).
  @visibleForTesting
  DiscourseChatEvent? chatEventFrom(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    switch (type) {
      case 'sent' || 'edit' || 'processed' || 'restore' || 'refresh':
        final m = data['chat_message'];
        if (m is! Map) return null;
        return DiscourseChatMessageChanged(
            type!, _messageFromJson(m.cast<String, dynamic>()));
      case 'delete':
        final id = (data['deleted_id'] as num?)?.toInt();
        return id == null ? null : DiscourseChatMessagesDeleted([id]);
      case 'bulk_delete':
        final ids = ((data['deleted_ids'] as List?) ?? const [])
            .whereType<num>()
            .map((n) => n.toInt())
            .toList();
        return ids.isEmpty ? null : DiscourseChatMessagesDeleted(ids);
      case 'reaction':
        final id = (data['chat_message_id'] as num?)?.toInt();
        final user = (data['user'] as Map?)?['username']?.toString();
        final emoji = data['emoji']?.toString();
        if (id == null || user == null || emoji == null) return null;
        return DiscourseChatReaction(
          messageId: id,
          emoji: emoji,
          username: user,
          added: data['action'] == 'add',
        );
    }
    return null;
  }

  FCChatChannel _channelFromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? tracking,
  }) {
    final membership =
        (json['current_user_membership'] as Map?)?.cast<String, dynamic>();
    final meta = (json['meta'] as Map?)?.cast<String, dynamic>();
    if (meta != null && meta.containsKey('can_delete_self')) {
      DiscourseChatPermissions.store(
        siteContext.site.url,
        (json['id'] as num).toInt(),
        DiscourseChatPermissions(
          canDeleteSelf: meta['can_delete_self'] == true,
          canDeleteOthers: meta['can_delete_others'] == true,
          canModerate: meta['can_moderate'] == true,
          silenced: meta['user_silenced'] == true,
        ),
      );
    }
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

  FCAttachment _uploadFrom(Map<String, dynamic> u) {
    String? abs(Object? url) {
      final s = url?.toString();
      if (s == null || s.isEmpty) return null;
      if (s.startsWith('http')) return s;
      // Protocol-relative (Discourse's `url` for an original): take the
      // forum's own scheme, as a browser would. Forcing https broke images on
      // a forum served over http.
      if (s.startsWith('//')) {
        return '${Uri.parse(siteContext.site.url).scheme}:$s';
      }
      return '${siteContext.site.url}$s';
    }

    final url = abs(u['url']) ?? '';
    final ext = (u['extension'] ?? '').toString().toLowerCase();
    final isImage = u['width'] != null ||
        const {'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif', 'avif', 'svg'}
            .contains(ext);
    final thumb = (u['thumbnail'] as Map?)?['url'];
    return FCAttachment(
      id: (u['id'] ?? '').toString(),
      filename: (u['original_filename'] ?? 'file${ext.isEmpty ? '' : '.$ext'}').toString(),
      contentType: isImage ? 'image/${ext.isEmpty ? 'jpeg' : ext}' : null,
      fileSize: (u['filesize'] as num?)?.toInt() ?? 0,
      url: url,
      thumbnailUrl: isImage ? (abs(thumb) ?? url) : null,
      isImage: isImage,
      // The attachment widgets draw a lock and refuse the tap unless these
      // are set; a chat upload is always viewable by whoever sees the message.
      canViewUrl: true,
      canViewThumbnailUrl: true,
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
    final id = (json['id'] as num).toInt();
    DiscourseChatUploads.store(siteContext.site.url, id, [
      for (final raw in ((json['uploads'] as List?) ?? const []).whereType<Map>())
        _uploadFrom(raw.cast<String, dynamic>()),
    ]);
    return FCChatMessage(
      id: id,
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
