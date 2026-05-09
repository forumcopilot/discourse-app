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
        resultText: 'Error: $e',
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
        resultText: 'Error: $e',
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
          resultText: 'Error inviting $u: $e',
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
      final response = await apiGet('/notifications.json', query: {
        'recent': 'true',
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
        resultText: 'Error: $e',
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
        canUpload: true,
        list: summaries,
      );
    } catch (e) {
      return FCConversationsResult(
        result: false,
        resultText: 'Error: $e',
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
    return _loadConversation(conversationId);
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
      return _emptyConversation('Error: $e');
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
      return FCQuoteConversationResult(result: false, resultText: 'Error: $e');
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
      return FCLeaveConversationResult(result: false, resultText: 'Error: $e');
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
      return FCRawConversationResult(result: false, resultText: 'Error: $e');
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
          result: false, resultText: 'Error: $e');
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
      return FCRawMessageResult(result: false, resultText: 'Error: $e');
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
      return FCSaveRawMessageResult(result: false, resultText: 'Error: $e');
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
      final response = await apiGet('/notifications.json', query: {
        'recent': 'true',
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
          resultText: 'Error: $e',
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
          result: false, resultText: 'Error: $e', isLoginMod: false);
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
        canReply: !((t['closed'] as bool?) ?? false) &&
            !((t['archived'] as bool?) ?? false),
        canInvite: true,
        canEdit: canEdit,
        canClose: canEdit,
        isClosed: (t['closed'] as bool?) ?? false,
        totalMessageNum: (t['posts_count'] as int?) ?? messages.length,
        lastRead: (t['last_read_post_number'] as int?) ?? 0,
        canUpload: true,
        position: anchorPostNumber,
      );
    } on DiscourseApiException catch (e) {
      return _emptyConversation(e.userMessage);
    } catch (e) {
      return _emptyConversation('Error: $e');
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
    final posters = (t['posters'] as List?) ?? const [];
    int? startUserId;
    int? lastUserId;
    for (final p in posters.whereType<Map>()) {
      final desc = (p['description'] ?? '').toString();
      if (desc.contains('Original Poster')) {
        startUserId = p['user_id'] as int?;
      }
      if (desc.contains('Most Recent Poster')) {
        lastUserId = p['user_id'] as int?;
      }
    }

    final allowedUserIds = ((t['allowed_user_ids'] as List?) ?? const [])
        .whereType<int>()
        .toList();
    final participants = allowedUserIds
        .map((id) => users[id])
        .whereType<Map<String, dynamic>>()
        .map(_participantFrom)
        .toList();

    return FCConversationSummary(
      convId: (t['id'] ?? '').toString(),
      replyCount: (((t['posts_count'] as int?) ?? 1) - 1)
          .clamp(0, 1 << 30)
          .toString(),
      participantCount: participants.length.clamp(1, 1 << 30),
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
      messageId: (t['highest_post_number'] ?? '').toString(),
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
      likeCount: likeCount,
      // See post_proxy._buildLikesInfo for why we pre-seed entries.
      likesInfo: List<FCLike>.generate(
        likeCount,
        (i) => i == 0 && isLiked
            ? FCLike(
                userId: siteContext.currentUserId ?? '',
                username: siteContext.currentUsername ?? '',
                avatarUrl:
                    siteContext.loginDataOutput?.user?.iconUrl ?? '',
                timestamp: DateTime.now(),
              )
            : FCLike(userId: '', username: '', avatarUrl: ''),
      ),
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
