import 'dart:convert' show HtmlEscape, jsonEncode;

import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_chat_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_channel.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_message.dart';
import 'package:forumcopilot_sdk/models/results/fc_chat_result.dart';

import 'package:flutter/foundation.dart' show visibleForTesting;

import '../base_discourse_proxy.dart';
import '../data/chat/discourse_chat_channel_details.dart';
import '../data/chat/discourse_chat_drafts.dart';
import '../data/chat/discourse_chat_event.dart';
import '../data/chat/discourse_chat_thread.dart';
import '../data/chat/discourse_chat_message_extras.dart';
import '../data/chat/discourse_chatable.dart';
import '../data/chat/discourse_chat_uploads.dart';
import '../data/chat/discourse_chat_permissions.dart';
import 'package:forumcopilot_sdk/models/entities/fc_attachment.dart';
import '../network/discourse_message_bus.dart';
import '../util/site_url.dart';

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

  /// [uploadIds] are files already uploaded from the chat composer
  /// (`/uploads.json`, `upload_type: chat-composer`). With them the text may
  /// be empty, as Chat::CreateMessage allows.
  ///
  /// [inReplyTo] makes it a reply to that message (`in_reply_to_id`; in a
  /// channel with threads, Discourse starts or continues the thread), and
  /// [threadId] sends it inside a thread.
  @override
  Future<FCChatMessageResult> sendMessageAsync(
    int channelId,
    String message, {
    List<int> uploadIds = const [],
    FCChatMessage? inReplyTo,
    int? threadId,
  }) async {
    if (message.trim().isEmpty && uploadIds.isEmpty) {
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
        if (uploadIds.isNotEmpty) 'upload_ids': uploadIds,
        if (inReplyTo != null) 'in_reply_to_id': inReplyTo.id,
        if (threadId != null) 'thread_id': threadId,
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
      if (uploadIds.isNotEmpty) {
        DiscourseChatUploads.store(siteContext.site.url, messageId,
            DiscourseChatUploads.takeUploads(siteContext.site.url, uploadIds));
      }
      if (inReplyTo != null) {
        DiscourseChatMessageExtras.store(
          siteContext.site.url,
          messageId,
          DiscourseChatMessageExtras(
            replyTo: DiscourseChatReplyTo(
              messageId: inReplyTo.id,
              excerpt: inReplyTo.excerpt ?? inReplyTo.message,
              user: DiscourseChatUser(
                userId: inReplyTo.authorId,
                username: inReplyTo.authorUsername,
                name: inReplyTo.authorName,
                avatarUrl: inReplyTo.authorAvatarUrl,
              ),
            ),
          ),
        );
      }
      return FCChatMessageResult(
        result: true,
        message: FCChatMessage(
          id: messageId,
          channelId: channelId,
          threadId: threadId,
          message: message,
          // Escaped paragraphs until the server's rendering arrives (it
          // drew the raw markdown, `<` and all).
          cooked: plainCooked(message),
          authorId: int.tryParse(siteContext.currentUserId ?? '') ?? 0,
          authorUsername: siteContext.currentUsername ?? '',
          authorAvatarUrl: siteContext.currentAvatarUrl,
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
    String? name,
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
        // A group chat's name; a named one is a group chat whatever its size.
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
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
          avatar = absoluteSiteUrl(siteContext.site.url, filled);
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

  /// Discourse-only: the forum's public channels the reader may see, for
  /// browsing and joining (`GET /chat/api/channels`). [status] is `open`,
  /// `closed` or `archived`; null for all. Pages of [limit].
  Future<FCChatChannelListResult> browseChannelsAsync({
    String filter = '',
    String? status,
    int offset = 0,
    int limit = 25,
  }) async {
    try {
      final response = await apiGet('/chat/api/channels', query: {
        if (filter.trim().isNotEmpty) 'filter': filter.trim(),
        if (status != null) 'status': status,
        'offset': offset,
        'limit': limit,
      });
      final channels = [
        for (final raw in ((response['channels'] as List?) ?? const []).whereType<Map>())
          _channelFromJson(raw.cast<String, dynamic>()),
      ];
      return FCChatChannelListResult(result: true, channels: channels);
    } on DiscourseApiException catch (e) {
      return FCChatChannelListResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCChatChannelListResult(result: false, resultText: describeApiError(e));
    }
  }

  /// Discourse-only: join a public channel (`POST …/memberships/me`).
  Future<FCChatActionResult> joinChannelAsync(int channelId) =>
      _action(() => apiPost('/chat/api/channels/$channelId/memberships/me'));

  /// Discourse-only: leave a channel, or close a DM, as the web's Leave
  /// does (`DELETE …/memberships/me`).
  Future<FCChatActionResult> leaveChannelAsync(int channelId) =>
      _action(() => apiDelete('/chat/api/channels/$channelId/memberships/me'));

  /// Discourse-only: close a DM, as a swipe on the web's list does: it
  /// leaves the list until someone writes in it again
  /// (`DELETE …/memberships/me/follows`).
  Future<FCChatActionResult> closeDirectMessageAsync(int channelId) =>
      _action(() => apiDelete('/chat/api/channels/$channelId/memberships/me/follows'));

  /// Discourse-only: star or unstar a channel for the reader
  /// (`PUT …/memberships/me`, `starred`).
  Future<FCChatActionResult> setChannelStarredAsync(int channelId, bool starred) async {
    final result = await _action(() => apiPut(
        '/chat/api/channels/$channelId/memberships/me',
        body: {'starred': starred}));
    if (result.result) {
      DiscourseChatChannelDetails.update(
          siteContext.site.url, channelId, (d) => d.copyWith(starred: starred));
    }
    return result;
  }

  /// Discourse-only: the reader's notifications for a channel
  /// (`PUT …/notifications-settings/me`): [muted], and [level] one of
  /// `never`, `mention`, `always`.
  Future<FCChatActionResult> updateChannelNotificationsAsync(
    int channelId, {
    bool? muted,
    String? level,
  }) async {
    final result = await _action(() => apiPut(
          '/chat/api/channels/$channelId/notifications-settings/me',
          body: {
            'notifications_settings': {
              if (muted != null) 'muted': muted,
              if (level != null) 'notification_level': level,
            },
          },
        ));
    if (result.result) {
      DiscourseChatChannelDetails.update(siteContext.site.url, channelId,
          (d) => d.copyWith(muted: muted, notificationLevel: level));
    }
    return result;
  }

  /// Discourse-only: the people in a channel, a page at a time
  /// (`GET …/memberships`), optionally filtered by [username].
  Future<({bool result, String resultText, List<DiscourseChatUser> users, int total})>
      getChannelMembersAsync(int channelId,
          {int offset = 0, int limit = 50, String username = ''}) async {
    try {
      final response = await apiGet('/chat/api/channels/$channelId/memberships', query: {
        'offset': offset,
        'limit': limit,
        if (username.trim().isNotEmpty) 'username': username.trim(),
      });
      final list = (response['memberships'] as List?) ?? (response['users'] as List?) ?? const [];
      final users = <DiscourseChatUser>[
        for (final raw in list.whereType<Map>())
          if (DiscourseChatUser.fromJson(
                  siteContext.site.url, raw['user'] ?? raw)
              case final u?)
            u,
      ];
      final meta = (response['meta'] as Map?)?.cast<String, dynamic>();
      return (
        result: true,
        resultText: '',
        users: users,
        total: (meta?['total_rows'] as num?)?.toInt() ?? users.length,
      );
    } on DiscourseApiException catch (e) {
      return (result: false, resultText: e.userMessage, users: const <DiscourseChatUser>[], total: 0);
    } catch (e) {
      return (result: false, resultText: describeApiError(e), users: const <DiscourseChatUser>[], total: 0);
    }
  }

  /// Discourse-only: add people (or groups) to a group chat
  /// (`POST …/memberships`).
  Future<FCChatActionResult> addChannelMembersAsync(int channelId,
          {List<String> usernames = const [], List<String> groups = const []}) =>
      _action(() => apiPost('/chat/api/channels/$channelId/memberships', body: {
            if (usernames.isNotEmpty) 'usernames': usernames,
            if (groups.isNotEmpty) 'groups': groups,
          }));

  /// Discourse-only: remove someone from a channel (admins, group chat
  /// owners; `DELETE …/memberships/:user_id`).
  Future<FCChatActionResult> removeChannelMemberAsync(int channelId, int userId) =>
      _action(() => apiDelete('/chat/api/channels/$channelId/memberships/$userId'));

  /// Discourse-only: rename a channel or group chat (`PUT …/channels/:id`).
  Future<FCChatChannelResult> renameChannelAsync(int channelId, String name) async {
    try {
      final response = await apiPut('/chat/api/channels/$channelId',
          body: {'channel': {'name': name}});
      final ch = (response['channel'] as Map?)?.cast<String, dynamic>();
      return FCChatChannelResult(
          result: true, channel: ch == null ? null : _channelFromJson(ch));
    } on DiscourseApiException catch (e) {
      return FCChatChannelResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCChatChannelResult(result: false, resultText: describeApiError(e));
    }
  }

  /// Discourse-only: flag a chat message (`POST …/messages/:id/flags`)
  /// with one of the forum's flag types, and a [message] for the types
  /// that take one.
  Future<FCChatActionResult> flagChatMessageAsync(int channelId, int messageId, int flagTypeId,
      {String? message}) async {
    final result = await _action(() => apiPost(
          '/chat/api/channels/$channelId/messages/$messageId/flags',
          body: {
            'flag_type_id': flagTypeId,
            if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
          },
        ));
    if (result.result) {
      DiscourseChatMessageExtras.update(siteContext.site.url, messageId, (e) => e.copyWith(flagged: true));
    }
    return result;
  }

  /// Discourse-only: bookmark a chat message for the reader
  /// (`POST /bookmarks`, a `Chat::Message`), or remove their bookmark.
  Future<FCChatActionResult> setChatBookmarkAsync(int messageId, {required bool bookmarked}) async {
    final site = siteContext.site.url;
    try {
      if (bookmarked) {
        final response = await apiPost('/bookmarks.json', body: {
          'bookmarkable_type': 'Chat::Message',
          'bookmarkable_id': messageId,
        });
        final id = (response['id'] as num?)?.toInt();
        DiscourseChatMessageExtras.update(site, messageId, (e) => e.copyWith(bookmarkId: id ?? -1));
      } else {
        final id = DiscourseChatMessageExtras.of(site, messageId)?.bookmarkId;
        if (id != null && id > 0) await apiDelete('/bookmarks/$id.json');
        DiscourseChatMessageExtras.update(site, messageId, (e) => e.copyWith(clearBookmark: true));
      }
      return FCChatActionResult(result: true);
    } on DiscourseApiException catch (e) {
      return FCChatActionResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCChatActionResult(result: false, resultText: describeApiError(e));
    }
  }

  /// Discourse-only: pin or unpin a message in its channel (people in
  /// `chat_pinning_messages_allowed_groups`).
  Future<FCChatActionResult> setChatPinnedAsync(int channelId, int messageId, {required bool pinned}) async {
    final path = '/chat/api/channels/$channelId/messages/$messageId/pin';
    final result = await _action(() => pinned ? apiPost(path) : apiDelete(path));
    if (result.result) {
      DiscourseChatMessageExtras.update(siteContext.site.url, messageId, (e) => e.copyWith(pinned: pinned));
    }
    return result;
  }

  /// Discourse-only: keep the reader's unsent text for a channel (or a
  /// thread) on the server, as the web's composer does; empty text drops
  /// the draft.
  Future<FCChatActionResult> saveChatDraftAsync(int channelId, String text, {int? threadId}) {
    DiscourseChatDrafts.remember(siteContext.site.url, channelId, text, threadId: threadId);
    final path = threadId == null
        ? '/chat/api/channels/$channelId/drafts'
        : '/chat/api/channels/$channelId/threads/$threadId/drafts';
    return _action(() => apiPost(path, body: {
          'data': text.trim().isEmpty ? '' : jsonEncode({'message': text}),
        }));
  }

  /// Discourse-only: people and groups whose names start with [term], for
  /// the composer's @mention suggestions (`/u/search/users`).
  Future<List<({String username, String? name, String? avatarUrl, bool isGroup})>> searchMentionsAsync(
      String term, {int? channelId}) async {
    try {
      final response = await apiGet('/u/search/users.json', query: {
        'term': term,
        'include_groups': true,
        'limit': 6,
        if (channelId != null) 'chat_channel_id': channelId,
      });
      return [
        for (final raw in ((response['users'] as List?) ?? const []).whereType<Map>())
          (
            username: (raw['username'] ?? '').toString(),
            name: raw['name']?.toString(),
            avatarUrl: raw['avatar_template'] == null
                ? null
                : absoluteSiteUrl(siteContext.site.url,
                    raw['avatar_template'].toString().replaceAll('{size}', '48')),
            isGroup: false,
          ),
        for (final raw in ((response['groups'] as List?) ?? const []).whereType<Map>())
          (
            username: (raw['name'] ?? '').toString(),
            name: raw['full_name']?.toString(),
            avatarUrl: null,
            isGroup: true,
          ),
      ];
    } catch (_) {
      return const [];
    }
  }

  /// Discourse-only: channels, categories and tags matching [term], for the
  /// composer's #hashtag suggestions (`/hashtags/search`).
  Future<List<({String ref, String text, String type})>> searchHashtagsAsync(String term) async {
    try {
      final response = await apiGet('/hashtags/search.json', query: {
        'term': term,
        'order[]': ['channel', 'category', 'tag'],
      });
      return [
        for (final raw in ((response['results'] as List?) ?? const []).whereType<Map>())
          (
            ref: (raw['ref'] ?? raw['slug'] ?? '').toString(),
            text: (raw['text'] ?? '').toString(),
            type: (raw['type'] ?? '').toString(),
          ),
      ];
    } catch (_) {
      return const [];
    }
  }

  /// Discourse-only: who is typing in a channel (or a thread), as the web's
  /// "X is typing…" shows it: the `/chat-reply/{id}` presence channel, read
  /// once and then followed on the message bus. [onChange] gets everyone
  /// typing except the reader. Returns a function that stops watching.
  void Function() watchTyping(int channelId, void Function(List<DiscourseChatUser> typing) onChange,
      {int? threadId}) {
    final name = threadId == null ? '/chat-reply/$channelId' : '/chat-reply/$channelId/thread/$threadId';
    final bus = DiscourseMessageBus.of(siteContext);
    final me = int.tryParse(siteContext.currentUserId ?? '');
    final typing = <int, DiscourseChatUser>{};
    var stopped = false;
    void Function()? unsubscribe;
    void emit() {
      if (!stopped) onChange(typing.values.where((u) => u.userId != me).toList());
    }

    () async {
      int lastId = -1;
      try {
        final state = await apiGet('/presence/get', query: {'channels[]': [name]});
        final channel = (state[name] as Map?)?.cast<String, dynamic>();
        lastId = (channel?['last_message_id'] as num?)?.toInt() ?? -1;
        for (final raw in ((channel?['users'] as List?) ?? const [])) {
          final u = DiscourseChatUser.fromJson(siteContext.site.url, raw);
          if (u != null) typing[u.userId] = u;
        }
        emit();
      } catch (_) {}
      if (stopped || bus.isUnavailable) return;
      unsubscribe = bus.subscribe('/presence$name', (data) {
        for (final raw in ((data['entering_users'] as List?) ?? const [])) {
          final u = DiscourseChatUser.fromJson(siteContext.site.url, raw);
          if (u != null) typing[u.userId] = u;
        }
        for (final id in ((data['leaving_user_ids'] as List?) ?? const [])) {
          if (id is num) typing.remove(id.toInt());
        }
        emit();
      }, lastId: lastId);
    }();
    return () {
      stopped = true;
      unsubscribe?.call();
    };
  }

  final Map<String, DateTime> _typingSince = {};

  /// Discourse-only: tell others the reader is typing ([typing] true) or
  /// stopped. Announced at most every 30 s while typing (presence lasts a
  /// minute), so a burst of keystrokes costs one request.
  Future<void> setTypingAsync(int channelId, {required bool typing, int? threadId}) async {
    final name = threadId == null ? '/chat-reply/$channelId' : '/chat-reply/$channelId/thread/$threadId';
    final since = _typingSince[name];
    if (typing && since != null && DateTime.now().difference(since) < const Duration(seconds: 30)) return;
    if (!typing && since == null) return;
    if (typing) {
      _typingSince[name] = DateTime.now();
    } else {
      _typingSince.remove(name);
    }
    try {
      await apiPost('/presence/update', body: {
        'client_id': DiscourseMessageBus.of(siteContext).clientId,
        if (typing) 'present_channels': [name] else 'leave_channels': [name],
      });
    } catch (_) {}
  }

  DiscourseChatThread _threadFromJson(Map<String, dynamic> t, {Map<String, dynamic>? tracking}) {
    final site = siteContext.site.url;
    final om = (t['original_message'] as Map?)?.cast<String, dynamic>();
    final preview = (t['preview'] as Map?)?.cast<String, dynamic>();
    final channel = (t['channel'] as Map?)?.cast<String, dynamic>();
    final ids = ((t['meta'] as Map?)?['message_bus_last_ids'] as Map?);
    final channelId = (t['channel_id'] as num?)?.toInt() ?? (channel?['id'] as num?)?.toInt() ?? 0;
    FCChatMessage? original;
    if (om != null && om['id'] != null) {
      original = _messageFromJson({...om, 'chat_channel_id': om['chat_channel_id'] ?? channelId});
    }
    return DiscourseChatThread(
      threadId: (t['id'] as num).toInt(),
      channelId: channelId,
      channelTitle: channel?['title']?.toString(),
      title: (t['title']?.toString().trim().isEmpty ?? true) ? null : t['title'].toString().trim(),
      originalMessage: original,
      replyCount: (t['reply_count'] as num?)?.toInt() ?? (preview?['reply_count'] as num?)?.toInt() ?? 0,
      lastReplyAt: DateTime.tryParse(preview?['last_reply_created_at']?.toString() ?? ''),
      lastReplyExcerpt: preview?['last_reply_excerpt']?.toString(),
      lastReplyUser: DiscourseChatUser.fromJson(site, preview?['last_reply_user']),
      participants: [
        for (final raw in ((preview?['participant_users'] as List?) ?? const []))
          if (DiscourseChatUser.fromJson(site, raw) case final u?) u,
      ],
      unreadCount: (tracking?['unread_count'] as num?)?.toInt() ?? 0,
      busLastId: (ids?['thread_message_bus_last_id'] as num?)?.toInt(),
    );
  }

  /// Discourse-only: one thread, with its original message.
  Future<DiscourseChatThread?> getThreadAsync(int channelId, int threadId) async {
    try {
      final response = await apiGet('/chat/api/channels/$channelId/threads/$threadId');
      final t = (response['thread'] as Map?)?.cast<String, dynamic>();
      return t == null ? null : _threadFromJson(t);
    } catch (_) {
      return null;
    }
  }

  /// Discourse-only: starts a thread on [originalMessageId], as the web does
  /// before the first reply in a channel with threads; returns it, or null.
  Future<DiscourseChatThread?> createThreadAsync(int channelId, int originalMessageId) async {
    try {
      final response = await apiPost('/chat/api/channels/$channelId/threads',
          body: {'original_message_id': originalMessageId});
      final t = (response['thread'] as Map?)?.cast<String, dynamic>() ?? response;
      if (t['id'] == null) return null;
      final thread = _threadFromJson({...t, 'channel_id': t['channel_id'] ?? channelId});
      DiscourseChatMessageExtras.update(
          siteContext.site.url,
          originalMessageId,
          (e) => e.thread != null
              ? e
              : e.copyWith(thread: DiscourseChatThreadPreview(threadId: thread.threadId, title: thread.title)));
      return thread;
    } catch (_) {
      return null;
    }
  }

  /// Discourse-only: a page of a thread's replies (`…/threads/:id/messages`),
  /// the newest by default, or [direction] of [targetMessageId].
  Future<FCChatMessageListResult> getThreadMessagesAsync(int channelId, int threadId,
      {int pageSize = 50, int? targetMessageId, String direction = 'past'}) async {
    try {
      final response = await apiGet('/chat/api/channels/$channelId/threads/$threadId/messages', query: {
        'page_size': pageSize,
        if (targetMessageId != null) 'target_message_id': targetMessageId,
        if (targetMessageId != null && direction.isNotEmpty) 'direction': direction,
        // Without a target the server opens at the reader's last read reply,
        // and the newest would never load.
        if (targetMessageId == null) 'fetch_from_last_message': true,
      });
      final messages = [
        for (final raw in ((response['messages'] as List?) ?? const []).whereType<Map>())
          _messageFromJson(raw.cast<String, dynamic>()),
      ].where((m) => !m.deleted).toList();
      return FCChatMessageListResult(result: true, messages: messages);
    } on DiscourseApiException catch (e) {
      return FCChatMessageListResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCChatMessageListResult(result: false, resultText: describeApiError(e));
    }
  }

  /// Discourse-only: live changes in a thread (`/chat/{channel}/thread/{id}`,
  /// the same events as a channel's).
  void Function()? watchThread(int channelId, int threadId, void Function(DiscourseChatEvent event) onEvent,
      {int lastId = -1}) {
    final bus = DiscourseMessageBus.of(siteContext);
    if (bus.isUnavailable) return null;
    return bus.subscribe('/chat/$channelId/thread/$threadId', (data) {
      final event = chatEventFrom(data);
      if (event != null) onEvent(event);
    }, lastId: lastId);
  }

  /// Discourse-only: the reader has read a thread up to [messageId].
  Future<FCChatActionResult> markThreadReadAsync(int channelId, int threadId, {required int messageId}) =>
      _action(() => apiPut('/chat/api/channels/$channelId/threads/$threadId/read',
          body: {'message_id': messageId}));

  /// Discourse-only: the threads the reader takes part in, newest activity
  /// first (`/chat/api/me/threads`).
  Future<({bool result, String resultText, List<DiscourseChatThread> threads})> getMyThreadsAsync() async {
    try {
      final response = await apiGet('/chat/api/me/threads');
      final tracking = ((response['tracking'] as Map?)?['thread_tracking'] as Map?)?.cast<String, dynamic>();
      final threads = [
        for (final raw in ((response['threads'] as List?) ?? const []).whereType<Map>())
          _threadFromJson(raw.cast<String, dynamic>(),
              tracking: (tracking?['${raw['id']}'] as Map?)?.cast<String, dynamic>()),
      ];
      return (result: true, resultText: '', threads: threads);
    } on DiscourseApiException catch (e) {
      return (result: false, resultText: e.userMessage, threads: const <DiscourseChatThread>[]);
    } catch (e) {
      return (result: false, resultText: describeApiError(e), threads: const <DiscourseChatThread>[]);
    }
  }

  /// Discourse-only: chat messages matching [query] (`/chat/api/search`),
  /// across the reader's channels or in [channelId]. Each message carries
  /// its channel's title.
  Future<({bool result, String resultText, List<({FCChatMessage message, String channelTitle})> messages, bool hasMore})>
      searchChatAsync(String query, {int? channelId, int offset = 0}) async {
    try {
      final response = await apiGet('/chat/api/search', query: {
        'query': query,
        if (channelId != null) 'channel_id': channelId,
        'offset': offset,
        'limit': 20,
      });
      final out = <({FCChatMessage message, String channelTitle})>[];
      for (final raw in ((response['messages'] as List?) ?? const []).whereType<Map>()) {
        final m = raw.cast<String, dynamic>();
        final channel = (m['channel'] as Map?)?.cast<String, dynamic>();
        if (channel != null) _channelFromJson(channel);
        out.add((message: _messageFromJson(m), channelTitle: (channel?['title'] ?? '').toString()));
      }
      final meta = (response['meta'] as Map?)?.cast<String, dynamic>();
      return (result: true, resultText: '', messages: out, hasMore: meta?['has_more'] == true);
    } on DiscourseApiException catch (e) {
      return (result: false, resultText: e.userMessage, messages: const <({FCChatMessage message, String channelTitle})>[], hasMore: false);
    } catch (e) {
      return (result: false, resultText: describeApiError(e), messages: const <({FCChatMessage message, String channelTitle})>[], hasMore: false);
    }
  }

  Future<FCChatActionResult> _action(Future<Object?> Function() call) async {
    try {
      await call();
      return FCChatActionResult(result: true);
    } on DiscourseApiException catch (e) {
      return FCChatActionResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCChatActionResult(result: false, resultText: describeApiError(e));
    }
  }

  /// Discourse-only: keeps a channel list current, as the web's sidebar is.
  /// For each of [channelIds], `/chat/{id}/new-messages` carries every new
  /// message (its excerpt, time and sender), and the reader's
  /// `/chat/user-tracking-state/{id}` the authoritative unread and mention
  /// counts whenever they change; `/chat/new-channel` announces a channel
  /// the reader was just added to. All ride the forum's one long-poll.
  /// Returns a function that stops watching, or null without live updates.
  void Function()? watchChannelList(
    List<int> channelIds,
    void Function(DiscourseChatListEvent event) onEvent,
  ) =>
      watchChannelListOn(DiscourseMessageBus.of(siteContext), channelIds, onEvent);

  /// [watchChannelList] on a given [bus] (tests).
  @visibleForTesting
  void Function()? watchChannelListOn(
    DiscourseMessageBus bus,
    List<int> channelIds,
    void Function(DiscourseChatListEvent event) onEvent,
  ) {
    if (bus.isUnavailable) return null;
    final siteUrl = siteContext.site.url;
    final userId = int.tryParse(siteContext.loginDataOutput?.user?.id ?? '');
    final stops = <void Function()>[];
    for (final id in channelIds) {
      final details = DiscourseChatChannelDetails.of(siteUrl, id);
      stops.add(bus.subscribe('/chat/$id/new-messages', (data) {
        final m = (data['message'] as Map?)?.cast<String, dynamic>();
        if (m == null) return;
        final excerpt = (m['excerpt'] ?? m['message'])?.toString();
        final at = DateTime.tryParse(m['created_at']?.toString() ?? '');
        final senderId = ((m['user'] as Map?)?['id'] as num?)?.toInt();
        final isThreadReply = data['type'] == 'thread';
        if (!isThreadReply) {
          DiscourseChatChannelDetails.update(
              siteUrl,
              id,
              (d) => d.copyWith(
                  lastMessageExcerpt: excerpt, lastMessageAt: at, lastMessageUserId: senderId));
        }
        onEvent(DiscourseChatListNewMessage(
          channelId: id,
          fromReader: userId != null && senderId == userId,
          threadReply: isThreadReply,
          at: at,
        ));
      }, lastId: details?.newMessagesBusId ?? -1));
    }
    if (userId != null) {
      stops.add(bus.subscribe('/chat/user-tracking-state/$userId', (data) {
        final id = (data['channel_id'] as num?)?.toInt();
        if (id == null) return;
        onEvent(DiscourseChatListTracking(
          channelId: id,
          unreadCount: (data['unread_count'] as num?)?.toInt() ?? 0,
          mentionCount: (data['mention_count'] as num?)?.toInt() ?? 0,
        ));
      }));
    }
    stops.add(bus.subscribe('/chat/new-channel', (_) => onEvent(const DiscourseChatListChanged())));
    return () {
      for (final stop in stops) {
        stop();
      }
    };
  }

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
      case 'update_thread_original_message':
        final om = (data['original_message_id'] as num?)?.toInt();
        final threadId = (data['thread_id'] as num?)?.toInt();
        final preview = (data['preview'] as Map?)?.cast<String, dynamic>();
        if (om == null || threadId == null || preview == null) return null;
        final site = siteContext.site.url;
        DiscourseChatMessageExtras.update(
            site,
            om,
            (e) => e.copyWith(
                thread: DiscourseChatThreadPreview.fromPreviewJson(site, threadId, preview, title: e.thread?.title)));
        return DiscourseChatThreadUpdated(om);
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
    // Who is in a DM, the channel's emoji and colour, its last message and
    // the reader's own settings: Discourse-only, kept beside the channel.
    DiscourseChatChannelDetails.store(siteContext.site.url,
        DiscourseChatChannelDetails.fromChannelJson(siteContext.site.url, json));
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

  FCAttachment _uploadFrom(Map<String, dynamic> u) =>
      DiscourseChatUploads.fromJson(siteContext.site.url, u);

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
          absoluteSiteUrl(siteContext.site.url, filled);
    }
    final id = (json['id'] as num).toInt();
    var extras = DiscourseChatMessageExtras.fromMessageJson(siteContext.site.url, json);
    // A live edit of a thread's original message comes without the thread's
    // summary: keep the one already known.
    final known = DiscourseChatMessageExtras.of(siteContext.site.url, id)?.thread;
    if (extras.thread == null && known != null && (json['thread_id'] as num?)?.toInt() == known.threadId) {
      extras = extras.copyWith(thread: known);
    }
    DiscourseChatMessageExtras.store(siteContext.site.url, id, extras);
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

  /// [text] as escaped HTML paragraphs: a stand-in for the server's
  /// rendering of a message just sent or edited.
  static String plainCooked(String text) => text
      .split(RegExp(r'\n{2,}'))
      .map((p) => '<p>${const HtmlEscape().convert(p).replaceAll('\n', '<br>')}</p>')
      .join();
}
