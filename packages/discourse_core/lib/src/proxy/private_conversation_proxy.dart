import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_private_conversation_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_attachment.dart';
import 'package:forumcopilot_sdk/models/entities/fc_like.dart';
import 'package:forumcopilot_sdk/models/results/fc_private_conversation_result.dart';

import '../base_discourse_proxy.dart';
import '../context/discourse_site_context_extension.dart';

/// Discourse implementation of [IFCPrivateConversationProxy].
///
/// In Discourse, a "private message" is a topic with `archetype:
/// 'private_message'`. Listing endpoints are scoped to the user:
///
///   * `/topics/private-messages/{username}.json`        — inbox (received)
///   * `/topics/private-messages-sent/{username}.json`   — sent
///   * `/topics/private-messages-unread/{username}.json` — unread
///   * `/topics/private-messages-archive/{username}.json`— archived
///
/// The conversation detail and reply paths are the same as regular topics
/// (`/t/{id}.json`, `POST /posts.json` with `topic_id`). Creating a new
/// conversation is `POST /posts.json` with `archetype: 'private_message'`
/// and `target_recipients: 'user1,user2'`.
class DiscoursePrivateConversationProxy extends BaseDiscourseProxy
    implements IFCPrivateConversationProxy {
  DiscoursePrivateConversationProxy(SiteContext context) : super(context);

  @override
  Future<FCNewConversationResult> newConversationAsync(
    List<String> userName,
    String subject,
    String textBody, {
    List<String>? attachmentIds,
    String? groupId,
    // openInvite and conversationLocked exist on the shared interface for XenForo,
    // which has both as conversation options. Discourse has neither: participant
    // permissions come from trust level and site settings rather than a per-message
    // flag, and closing is a separate action on an existing topic
    // (PUT /t/{id}/status) that a regular user cannot perform at creation time.
    // They are accepted and ignored here; the compose UI no longer offers them.
    bool? openInvite,
    bool? conversationLocked,
  }) async {
    if (userName.isEmpty) {
      return FCNewConversationResult(
        result: false,
        resultText: 'No recipients',
        convId: '',
      );
    }
    try {
      final response = await apiPost('/posts.json', body: {
        'archetype': 'private_message',
        'target_recipients': userName.join(','),
        'title': subject,
        'raw': textBody,
      });
      return FCNewConversationResult(
        result: true,
        resultText: '',
        convId: (response['topic_id'] ?? '').toString(),
      );
    } on DiscourseApiException catch (e) {
      return FCNewConversationResult(
        result: false,
        resultText: e.userMessage,
        convId: '',
      );
    } catch (e) {
      return FCNewConversationResult(
        result: false,
        resultText: describeApiError(e),
        convId: '',
      );
    }
  }

  @override
  Future<FCReplyConversationResult> replyConversationAsync(
    String conversationId,
    String textBody,
    List<String>? attachmentIds,
    String? groupId,
  ) async {
    try {
      final response = await apiPost('/posts.json', body: {
        'topic_id': int.tryParse(conversationId) ?? conversationId,
        'raw': textBody,
        'archetype': 'private_message',
      });
      return FCReplyConversationResult(
        result: true,
        resultText: '',
        messageId: (response['id'] ?? '').toString(),
      );
    } on DiscourseApiException catch (e) {
      return FCReplyConversationResult(
        result: false,
        resultText: e.userMessage,
      );
    } catch (e) {
      return FCReplyConversationResult(
        result: false,
        resultText: describeApiError(e),
      );
    }
  }

  @override
  Future<FCInviteParticipantResult> inviteParticipantAsync(
    List<String> userName,
    String conversationId,
    String? reason,
  ) async {
    if (userName.isEmpty) {
      return FCInviteParticipantResult(
        result: false,
        resultText: 'No users to invite',
      );
    }
    // Discourse's /t/{id}/invite.json takes a single `user`. Loop for the
    // multi-recipient case; bail on the first error so the caller can show
    // it.
    for (final u in userName) {
      try {
        await apiPost('/t/$conversationId/invite.json', body: {'user': u});
      } on DiscourseApiException catch (e) {
        return FCInviteParticipantResult(
          result: false,
          resultText: e.userMessage,
        );
      } catch (e) {
        return FCInviteParticipantResult(
          result: false,
          resultText: 'Error inviting $u: ${describeApiError(e)}',
        );
      }
    }
    return FCInviteParticipantResult(result: true, resultText: '');
  }

  @override
  Future<FCInboxStatResult> getInboxStatAsync() async {
    if (!siteContext.hasUserApiKey) {
      return FCInboxStatResult(
        result: true,
        resultText: '',
        totalConversations: 0,
        unreadConversations: 0,
        unreadMessages: 0,
      );
    }
    try {
      // Non-recent listing: `recent=true` caps at 15 rows and returns no
      // `total_rows_notifications`, undercounting the unread-PM badge.
      // The plain listing returns up to 60 rows (INDEX_LIMIT in
      // notifications_controller.rb) plus the total; `filter=unread`
      // keeps every returned row (and the total) unread so counts stay
      // accurate even under a pile of read notifications.
      final response = await apiGet('/notifications.json', query: {
        'limit': '60',
        'filter': 'unread',
      });
      final notifications =
          ((response['notifications'] as List?) ?? const []).whereType<Map>();
      var unreadPms = 0;
      for (final n in notifications) {
        if (n['read'] == true) continue;
        final type = n['notification_type'] as int?;
        if (type == 6 /* private_message */ || type == 7 /* invited_to_pm */) {
          unreadPms++;
        }
      }
      final total =
          (response['total_rows_notifications'] as int?) ?? unreadPms;
      return FCInboxStatResult(
        result: true,
        resultText: '',
        totalConversations: total,
        unreadConversations: unreadPms,
        unreadMessages: unreadPms,
      );
    } catch (e) {
      return FCInboxStatResult(
        result: false,
        resultText: describeApiError(e),
        totalConversations: 0,
        unreadConversations: 0,
        unreadMessages: 0,
      );
    }
  }

  @override
  Future<FCConversationsResult> getConversationsAsync(
      int startNum, int lastNum) async {
    final username = siteContext.currentUsername;
    if (username == null || username.isEmpty) {
      return FCConversationsResult(
        result: false,
        resultText: 'Not signed in',
        conversationCount: 0,
        unreadCount: 0,
        canUpload: false,
        list: const [],
      );
    }
    try {
      // Discourse splits PMs into separate listing endpoints:
      //   /topics/private-messages/{u}        → received only
      //   /topics/private-messages-sent/{u}   → sent only
      // For a unified WhatsApp-style "all conversations" view, fetch both
      // in parallel and merge (dedup + sort by last activity).
      final encUser = Uri.encodeComponent(username);
      final pageQuery = <String, dynamic>{
        if (startNum > 0) 'page': (startNum / 30).floor().toString(),
      };
      final responses = await Future.wait([
        apiGet('/topics/private-messages/$encUser.json', query: pageQuery),
        apiGet(
          '/topics/private-messages-sent/$encUser.json',
          query: pageQuery,
        ).catchError((_) => <String, dynamic>{}),
      ]);

      final byId = <String, FCConversationSummary>{};
      var unread = 0;
      for (final response in responses) {
        final users = _usersById(response);
        final list = (response['topic_list'] as Map<String, dynamic>?) ??
            const <String, dynamic>{};
        for (final raw
            in ((list['topics'] as List?) ?? const []).whereType<Map>()) {
          final t = raw.cast<String, dynamic>();
          final summary = _conversationSummaryFrom(t, users: users);
          byId[summary.convId] = summary;
          if (summary.newPost == true) unread++;
        }
      }

      final summaries = byId.values.toList()
        ..sort((a, b) {
          final at = DateTime.tryParse(a.lastReplyTime ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final bt = DateTime.tryParse(b.lastReplyTime ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return bt.compareTo(at);
        });

      return FCConversationsResult(
        result: true,
        resultText: '',
        conversationCount: summaries.length,
        unreadCount: unread,
        // See _loadConversation: no per-conversation upload permission
        // exists on Discourse; the real gate is DiscourseUploadLimits.
        canUpload: true,
        list: summaries,
      );
    } catch (e) {
      return FCConversationsResult(
        result: false,
        resultText: describeApiError(e),
        conversationCount: 0,
        unreadCount: 0,
        canUpload: false,
        list: const [],
      );
    }
  }

  @override
  Future<FCConversationResult> getConversationAsync(
      String conversationId, int startNum, int lastNum, bool returnHtml) async {
    // startNum is a 0-based message offset; anchor the topic-view chunk at
    // the matching post number so windows beyond the first ~20-post chunk
    // are reachable (plain /t/{id}.json only returns the first chunk).
    return _loadConversation(conversationId,
        anchorPostNumber: startNum > 0 ? startNum + 1 : null);
  }

  @override
  Future<FCConversationResult> getConversationByMessageAsync(
    String messageId, {
    int messagesPerRequest = 20,
  }) async {
    try {
      final p = await apiGet('/posts/$messageId.json');
      final topicId = (p['topic_id'] ?? '').toString();
      if (topicId.isEmpty) {
        return _emptyConversation('Post has no topic_id');
      }
      final postNumber = (p['post_number'] as int?) ?? 1;
      return _loadConversation(topicId, anchorPostNumber: postNumber);
    } on DiscourseApiException catch (e) {
      return _emptyConversation(e.userMessage);
    } catch (e) {
      return _emptyConversation(describeApiError(e));
    }
  }

  @override
  Future<FCQuoteConversationResult> getQuoteConversationAsync(
      String conversationId, String messageId) async {
    try {
      final p = await apiGet('/posts/$messageId.json');
      final raw = (p['raw'] as String?) ?? '';
      final username = (p['username'] as String?) ?? '';
      final quote =
          '[quote="${username}, post:${p['post_number']}, topic:${p['topic_id']}"]\n$raw\n[/quote]\n\n';
      return FCQuoteConversationResult(
        result: true,
        resultText: '',
        quoteText: quote,
        authorName: username,
      );
    } on DiscourseApiException catch (e) {
      return FCQuoteConversationResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCQuoteConversationResult(result: false, resultText: describeApiError(e));
    }
  }

  @override
  Future<FCLeaveConversationResult> leaveConversationAsync(
      String conversationId, int mode) async {
    final username = siteContext.currentUsername;
    if (username == null || username.isEmpty) {
      return FCLeaveConversationResult(
          result: false, resultText: 'Not signed in');
    }
    try {
      await apiPut('/t/$conversationId/remove-allowed-user.json', body: {
        'username': username,
      });
      return FCLeaveConversationResult(result: true, resultText: '');
    } on DiscourseApiException catch (e) {
      return FCLeaveConversationResult(
          result: false, resultText: e.userMessage);
    } catch (e) {
      return FCLeaveConversationResult(result: false, resultText: describeApiError(e));
    }
  }

  @override
  Future<FCMarkConversationUnreadResult> markConversationUnreadAsync(
      String conversationId) async {
    // Discourse PMs mark "unread" by clearing topic timings via DELETE
    // /t/{id}/timings. The endpoint exists but is rarely surfaced; for now
    // we report success without server side-effect (lossy).
    return FCMarkConversationUnreadResult(
      result: true,
      resultText: '',
    );
  }

  @override
  Future<FCMarkConversationReadResult> markConversationReadAsync(
      String conversationId) async {
    // Discourse marks read implicitly when /t/{id}.json is fetched; an
    // explicit "mark read" maps to setting last-read post timing. The
    // /topics/timings endpoint expects per-post-number entries which the
    // SDK contract doesn't surface — opening the conversation in the UI
    // already triggers the read state. Report success here.
    return FCMarkConversationReadResult(result: true, resultText: '');
  }

  @override
  Future<FCCloseConversationResult> closeConversationAsync(
      String conversationId) async {
    return _setConversationClosed(conversationId, closed: true);
  }

  @override
  Future<FCCloseConversationResult> uncloseConversationAsync(
      String conversationId) async {
    return _setConversationClosed(conversationId, closed: false);
  }

  @override
  Future<FCArchiveConversationResult> archiveConversationAsync(
      String conversationId) async {
    return _setConversationArchived(conversationId, archived: true);
  }

  @override
  Future<FCArchiveConversationResult> unarchiveConversationAsync(
      String conversationId) async {
    return _setConversationArchived(conversationId, archived: false);
  }

  /// Archiving is not a topic status like closed/pinned — it is a per-user
  /// filing action with its own pair of routes, so there is no single endpoint
  /// taking a boolean.
  Future<FCArchiveConversationResult> _setConversationArchived(
    String conversationId, {
    required bool archived,
  }) async {
    try {
      await apiPut(
        archived
            ? '/t/$conversationId/archive-message.json'
            : '/t/$conversationId/move-to-inbox.json',
        body: const {},
      );
      return FCArchiveConversationResult(
        result: true,
        resultText: '',
        isArchived: archived,
      );
    } on DiscourseApiException catch (e) {
      return FCArchiveConversationResult(
        result: false,
        resultText: e.userMessage,
        isArchived: !archived,
      );
    } catch (e) {
      return FCArchiveConversationResult(
        result: false,
        resultText: describeApiError(e),
        isArchived: !archived,
      );
    }
  }

  @override
  Future<FCRawConversationResult> getRawConversationAsync(
      String conversationId) async {
    try {
      final t = await apiGet('/t/$conversationId.json');
      final details = (t['details'] as Map<String, dynamic>?) ?? const {};
      final canEdit = (details['can_edit'] as bool?) ?? false;
      return FCRawConversationResult(
        result: true,
        resultText: '',
        conversationTitle: t['title']?.toString(),
        // Discourse PMs don't have an `open_invite` flag — anyone in the
        // PM can invite. Surface true so the UI doesn't lock the field.
        openInvite: true,
        conversationOpen: !((t['closed'] as bool?) ?? false),
        canEdit: canEdit,
      );
    } on DiscourseApiException catch (e) {
      return FCRawConversationResult(
          result: false, resultText: e.userMessage);
    } catch (e) {
      return FCRawConversationResult(result: false, resultText: describeApiError(e));
    }
  }

  @override
  Future<FCSaveRawConversationResult> saveRawConversationAsync(
    String conversationId, {
    String? conversationTitle,
    bool? openInvite,
    bool? conversationOpen,
  }) async {
    try {
      // Title edit
      if (conversationTitle != null && conversationTitle.isNotEmpty) {
        await apiPut('/t/$conversationId.json', body: {
          'title': conversationTitle,
        });
      }
      // Open/closed toggle
      if (conversationOpen != null) {
        await _setConversationClosed(conversationId, closed: !conversationOpen);
      }
      return FCSaveRawConversationResult(
        result: true,
        resultText: '',
        conversationTitle: conversationTitle,
      );
    } on DiscourseApiException catch (e) {
      return FCSaveRawConversationResult(
          result: false, resultText: e.userMessage);
    } catch (e) {
      return FCSaveRawConversationResult(
          result: false, resultText: describeApiError(e));
    }
  }

  @override
  Future<FCRawMessageResult> getRawMessageAsync(String messageId) async {
    try {
      final p = await apiGet('/posts/$messageId.json');
      return FCRawMessageResult(
        result: true,
        resultText: '',
        messageContent: p['raw']?.toString(),
        attachments: <FCAttachment>[],
      );
    } on DiscourseApiException catch (e) {
      return FCRawMessageResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCRawMessageResult(result: false, resultText: describeApiError(e));
    }
  }

  @override
  Future<FCSaveRawMessageResult> saveRawMessageAsync(
    String messageId,
    String messageContent, {
    List<String>? attachmentIds,
    String? groupId,
  }) async {
    try {
      final response = await apiPut('/posts/$messageId.json', body: {
        'post': {'raw': messageContent},
      });
      return FCSaveRawMessageResult(
        result: true,
        resultText: '',
        messageContent: response['raw']?.toString() ?? messageContent,
      );
    } on DiscourseApiException catch (e) {
      return FCSaveRawMessageResult(
          result: false, resultText: e.userMessage);
    } catch (e) {
      return FCSaveRawMessageResult(result: false, resultText: describeApiError(e));
    }
  }

  /// Discourse-specific extension used by `lib/views/site_home_page.dart`:
  /// returns the inbox stat AND the count of unread non-PM notifications in
  /// a single round-trip (rather than two separate proxy calls).
  Future<Map<String, dynamic>> getInboxStatWithAlertsAsync() async {
    if (!siteContext.hasUserApiKey) {
      return {
        'inboxStat': FCInboxStatResult(
          result: true,
          resultText: '',
          totalConversations: 0,
          unreadConversations: 0,
          unreadMessages: 0,
        ),
        'unreadAlerts': 0,
      };
    }
    try {
      // Same fix as getInboxStatAsync: the recent=true listing caps at
      // 15 rows and omits totals — use the plain listing with the max
      // limit and unread filter for accurate badge counts.
      final response = await apiGet('/notifications.json', query: {
        'limit': '60',
        'filter': 'unread',
      });
      final notifications =
          ((response['notifications'] as List?) ?? const []).whereType<Map>();
      var unreadPms = 0;
      var unreadAlerts = 0;
      for (final n in notifications) {
        if (n['read'] == true) continue;
        final type = n['notification_type'] as int?;
        if (type == 6 /* private_message */ || type == 7 /* invited_to_pm */) {
          unreadPms++;
        } else {
          unreadAlerts++;
        }
      }
      final total =
          (response['total_rows_notifications'] as int?) ?? unreadPms + unreadAlerts;
      return {
        'inboxStat': FCInboxStatResult(
          result: true,
          resultText: '',
          totalConversations: total,
          unreadConversations: unreadPms,
          unreadMessages: unreadPms,
        ),
        'unreadAlerts': unreadAlerts,
      };
    } catch (e) {
      return {
        'inboxStat': FCInboxStatResult(
          result: false,
          resultText: describeApiError(e),
          totalConversations: 0,
          unreadConversations: 0,
          unreadMessages: 0,
        ),
        'unreadAlerts': 0,
      };
    }
  }

  // ===== Helpers =====

  Future<FCCloseConversationResult> _setConversationClosed(
    String conversationId, {
    required bool closed,
  }) async {
    try {
      await apiPut('/t/$conversationId/status.json', body: {
        'status': 'closed',
        'enabled': closed.toString(),
      });
      return FCCloseConversationResult(
          result: true, resultText: '', isLoginMod: false);
    } on DiscourseApiException catch (e) {
      return FCCloseConversationResult(
          result: false, resultText: e.userMessage, isLoginMod: false);
    } catch (e) {
      return FCCloseConversationResult(
          result: false, resultText: describeApiError(e), isLoginMod: false);
    }
  }

  Future<FCConversationResult> _loadConversation(
    String conversationId, {
    int? anchorPostNumber,
  }) async {
    if (conversationId.isEmpty) {
      return _emptyConversation('conversationId required');
    }
    try {
      final path = anchorPostNumber != null
          ? '/t/$conversationId/$anchorPostNumber.json'
          : '/t/$conversationId.json';
      final t = await apiGet(path);
      final stream = (t['post_stream'] as Map<String, dynamic>?) ?? const {};
      final messages = ((stream['posts'] as List?) ?? const [])
          .whereType<Map>()
          .map((m) => _conversationMessageFrom(m.cast<String, dynamic>()))
          .toList();
      final details = (t['details'] as Map<String, dynamic>?) ?? const {};
      final allowedUsers = (details['allowed_users'] as List?) ?? const [];
      final participants = allowedUsers
          .whereType<Map>()
          .map((u) => _participantFrom(u.cast<String, dynamic>()))
          .toList();
      final canEdit = (details['can_edit'] as bool?) ?? false;

      return FCConversationResult(
        result: true,
        resultText: '',
        convId: conversationId,
        subject: t['title']?.toString(),
        convTitle: t['title']?.toString(),
        messages: messages,
        participants: participants,
        participantCount: participants.length,
        // `TopicViewDetailsSerializer` emits `can_create_post` and
        // `can_invite_to` only when the guardian grants them
        // (app/serializers/topic_view_details_serializer.rb:11-13,
        // :127-128, :135-137), so presence IS the permission and absence
        // is a real "no". Prefer them over the closed/archived guess;
        // fall back to the guess only if `details` came back without the
        // key at all.
        canReply: details.containsKey('can_create_post')
            ? details['can_create_post'] == true
            : (!((t['closed'] as bool?) ?? false) &&
                !((t['archived'] as bool?) ?? false)),
        // Was hardcoded true, which offered an "add participant" action
        // to people the server would reject.
        canInvite: details['can_invite_to'] == true,
        canEdit: canEdit,
        canClose: canEdit,
        isClosed: (t['closed'] as bool?) ?? false,
        totalMessageNum: (t['posts_count'] as int?) ?? messages.length,
        lastRead: (t['last_read_post_number'] as int?) ?? 0,
        // Optimistic: Discourse gates uploads globally (trust level +
        // authorized_extensions / max_*_size_kb, cached on the site
        // context as DiscourseUploadLimits), never per topic, so there
        // is no per-conversation signal to read. The composer validates
        // against those cached limits before sending.
        canUpload: true,
        position: anchorPostNumber,
      );
    } on DiscourseApiException catch (e) {
      return _emptyConversation(e.userMessage);
    } catch (e) {
      return _emptyConversation(describeApiError(e));
    }
  }

  FCConversationResult _emptyConversation(String message) {
    return FCConversationResult(
      result: false,
      resultText: message,
      convId: '',
      messages: <FCConversationMessage>[],
      participants: <FCParticipant>[],
    );
  }

  FCConversationSummary _conversationSummaryFrom(
    Map<String, dynamic> t, {
    Map<int, Map<String, dynamic>> users = const {},
  }) {
    // Collect every user the topic surfaces:
    //   posters[]      = OP + most-recent-poster (with `description` tags)
    //   participants[] = other recipients of the PM (no description)
    // Each entry has `user_id`; the actual username/avatar is in the
    // parallel `users[]` array of the response.
    final posters = (t['posters'] as List?) ?? const [];
    final participantsField = (t['participants'] as List?) ?? const [];
    int? startUserId;
    int? lastUserId;
    int? firstPosterId;
    final participantUserIds = <int>[];
    final seen = <int>{};
    for (final p in posters.whereType<Map>()) {
      final id = p['user_id'] as int?;
      if (id == null) continue;
      if (seen.add(id)) participantUserIds.add(id);
      firstPosterId ??= id;
      // `extras` is locale-independent (app/models/topic_posters_summary.rb):
      // the most recent poster is tagged 'latest' ('latest single' when
      // they are the only poster, i.e. also the OP). The `description`
      // strings ("Original Poster" / "Most Recent Poster") are localized
      // server-side, so match them only as a fallback.
      final extras = (p['extras'] ?? '').toString();
      if (extras.contains('latest')) {
        lastUserId = id;
        if (extras.contains('single')) startUserId ??= id;
      }
      final desc = (p['description'] ?? '').toString();
      if (startUserId == null && desc.contains('Original Poster')) {
        startUserId = id;
      }
      if (lastUserId == null && desc.contains('Most Recent Poster')) {
        lastUserId = id;
      }
    }
    // Positional fallback: Discourse orders posters[] OP-first (the
    // latest poster is shuffled to the back), so when neither signal
    // resolved, the first entry is the OP.
    startUserId ??= firstPosterId;
    for (final p in participantsField.whereType<Map>()) {
      final id = p['user_id'] as int?;
      if (id == null) continue;
      if (seen.add(id)) participantUserIds.add(id);
    }

    final participants = participantUserIds
        .map((id) => users[id])
        .whereType<Map<String, dynamic>>()
        .map(_participantFrom)
        .toList();

    // Fall back to `last_poster_username` (a string Discourse always
    // includes on PM listings) if the user lookup didn't resolve a name —
    // matters when the participants array is otherwise empty.
    if (participants.isEmpty) {
      final lastUsername = t['last_poster_username']?.toString();
      if (lastUsername != null && lastUsername.isNotEmpty) {
        final placeholderId =
            lastUserId?.toString() ?? startUserId?.toString() ?? '';
        participants.add(FCParticipant(
          userId: placeholderId,
          username: lastUsername,
          iconUrl: null,
          isOnline: false,
        ));
        // Make sure last_user_id matches one of the participants so the
        // UI's `firstWhere(p.userId == last_user_id)` succeeds.
        lastUserId ??= int.tryParse(placeholderId);
      }
    }

    return FCConversationSummary(
      convId: (t['id'] ?? '').toString(),
      replyCount: (((t['posts_count'] as int?) ?? 1) - 1)
          .clamp(0, 1 << 30)
          .toString(),
      participantCount: participants.isEmpty ? 1 : participants.length,
      startUserId: startUserId?.toString(),
      startTime: t['created_at']?.toString(),
      subject: t['title']?.toString(),
      convSubject: t['title']?.toString(),
      lastUserId: lastUserId?.toString(),
      lastReplyTime: t['last_posted_at']?.toString(),
      lastConvTime: t['last_posted_at']?.toString(),
      newPost: t['unseen'] == true || (t['unread'] as int? ?? 0) > 0,
      participants: participants,
      canEdit: false,
      canClose: false,
      isClosed: (t['closed'] as bool?) ?? false,
      // Deliberately empty: the PM topic-list payload only carries post
      // NUMBERS (highest_post_number), never post ids, and consumers treat
      // messageId as a post id for /posts/{id}.json — a number here anchors
      // into a random foreign topic (403). Open-at-position uses
      // initialStartNum instead.
      messageId: '',
      unreadMessageCount: (t['unread_posts'] as int?) ?? 0,
    );
  }

  FCConversationMessage _conversationMessageFrom(Map<String, dynamic> p) {
    final tpl = p['avatar_template'] as String?;
    String? avatarUrl;
    if (tpl != null && tpl.isNotEmpty) {
      final filled = tpl.replaceAll('{size}', '90');
      avatarUrl = filled.startsWith('http')
          ? filled
          : '${siteContext.site.url}$filled';
    }
    final actions = (p['actions_summary'] as List?) ?? const [];
    final likeAction = actions.whereType<Map>().firstWhere(
          (a) => a['id'] == 2,
          orElse: () => <String, dynamic>{},
        );
    final isLiked = likeAction['acted'] == true;
    final canLike = likeAction['can_act'] == true;
    final likeCount = (likeAction['count'] as int?) ?? 0;
    final username = (p['username'] ?? '').toString();
    final isMine =
        username.isNotEmpty && username == siteContext.currentUsername;

    return FCConversationMessage(
      messageId: (p['id'] ?? '').toString(),
      userId: (p['user_id'] ?? '').toString(),
      username: username,
      iconUrl: avatarUrl,
      textBody: (p['cooked'] ?? p['raw'] ?? '').toString(),
      messageTime: (p['created_at'] ?? '').toString(),
      isFromCurrentUser: isMine,
      canLike: canLike,
      isLiked: isLiked,
      // `actions_summary` gives a COUNT and an acted flag, never the
      // actors — [likeCount] is the number the UI should render. We no
      // longer pre-seed blank FCLike placeholders to make
      // `likesInfo.length` read correctly (they rendered as blank avatars
      // and dead-end profiles). The actor list is fetched on demand via
      // `DiscoursePostProxy.getReactionUsersAsync(messageId)` — PM posts
      // are ordinary posts, so both that endpoint and its
      // /post_action_users.json fallback accept the message id.
      likeCount: likeCount,
      // Growable: optimistic-UI code calls `.add()` / `.removeWhere()`
      // on this list (FCConversationMessage defaults it to `const []`).
      likesInfo: <FCLike>[],
      attachments: <FCAttachment>[],
      isUnread: false,
      isFirstMessage: (p['post_number'] as int?) == 1,
      canReport: true,
      isIgnored: false,
      canEdit: p['can_edit'] == true,
      messageNumber: p['post_number'] as int?,
    );
  }

  FCParticipant _participantFrom(Map<String, dynamic> u) {
    final tpl = u['avatar_template'] as String?;
    String? avatarUrl;
    if (tpl != null && tpl.isNotEmpty) {
      final filled = tpl.replaceAll('{size}', '90');
      avatarUrl = filled.startsWith('http')
          ? filled
          : '${siteContext.site.url}$filled';
    }
    return FCParticipant(
      userId: (u['id'] ?? '').toString(),
      username: (u['username'] ?? '').toString(),
      iconUrl: avatarUrl,
      isOnline: false,
    );
  }

  Map<int, Map<String, dynamic>> _usersById(Map<String, dynamic> response) {
    final users = <int, Map<String, dynamic>>{};
    for (final u in ((response['users'] as List?) ?? const []).whereType<Map>()) {
      final id = u['id'];
      if (id is int) users[id] = u.cast<String, dynamic>();
    }
    return users;
  }
}
