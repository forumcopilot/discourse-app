import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_private_message_proxy.dart';
import 'package:forumcopilot_sdk/models/results/fc_private_message_result.dart';

import '../base_discourse_proxy.dart';
import '../context/discourse_site_context_extension.dart';

/// Discourse implementation of [IFCPrivateMessageProxy].
///
/// Discourse doesn't have a traditional "inbox / sent boxes with single
/// messages" PM model — every private message is a topic with
/// `archetype: 'private_message'` and any number of posts inside it. This
/// proxy maps the legacy XF traditional-PM contract onto that:
///
///   * boxId == 'inbox' → `/topics/private-messages/{username}.json`
///   * boxId == 'sent'  → `/topics/private-messages-sent/{username}.json`
///   * each PM topic surfaces as one item in the box list
///   * `messageId` ↔ topic id (the first post represents the PM body)
///
/// The modern conversation flow ([DiscoursePrivateConversationProxy]) is
/// the primary path; this proxy exists so the inherited XF traditional PM
/// pages don't crash when the user navigates to them.
class DiscoursePrivateMessageProxy extends BaseDiscourseProxy
    implements IFCPrivateMessageProxy {
  DiscoursePrivateMessageProxy(SiteContext context) : super(context);

  static const String _boxInbox = 'inbox';
  static const String _boxSent = 'sent';

  @override
  Future<FCBoxInfoResult> getBoxInfoAsync() async {
    final username = siteContext.currentUsername;
    if (username == null || username.isEmpty) {
      return FCBoxInfoResult(
        result: false,
        resultText: 'Not signed in',
        messageRoomCount: 0,
        list: const [],
      );
    }
    final boxes = <FCBoxInfo>[
      FCBoxInfo(
        boxId: _boxInbox,
        boxName: 'Inbox',
        boxType: 'INBOX',
        messageCount: 0,
        unreadCount: await _unreadPmCount(),
      ),
      FCBoxInfo(
        boxId: _boxSent,
        boxName: 'Sent',
        boxType: 'SENT',
        messageCount: 0,
        unreadCount: 0,
      ),
    ];
    return FCBoxInfoResult(
      result: true,
      resultText: '',
      messageRoomCount: 0,
      list: boxes,
    );
  }

  @override
  Future<FCBoxResult> getBoxAsync(
      String boxId, int startNum, int endNum) async {
    final username = siteContext.currentUsername;
    if (username == null || username.isEmpty) {
      return FCBoxResult(
        result: false,
        resultText: 'Not signed in',
        totalMessageNum: 0,
        list: const [],
      );
    }
    final path = boxId == _boxSent
        ? '/topics/private-messages-sent/${Uri.encodeComponent(username)}.json'
        : '/topics/private-messages/${Uri.encodeComponent(username)}.json';
    try {
      final response = await apiGet(path, query: {
        if (startNum > 0) 'page': (startNum / 30).floor().toString(),
      });
      final users = _usersById(response);
      final list = (response['topic_list'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      final messages = ((list['topics'] as List?) ?? const [])
          .whereType<Map>()
          .map((t) => _pmFromTopic(t.cast<String, dynamic>(), users: users))
          .toList();
      return FCBoxResult(
        result: true,
        resultText: '',
        totalMessageNum: messages.length,
        list: messages,
      );
    } on DiscourseApiException catch (e) {
      return FCBoxResult(
        result: false,
        resultText: e.userMessage,
        totalMessageNum: 0,
        list: const [],
      );
    } catch (e) {
      return FCBoxResult(
        result: false,
        resultText: 'Error: $e',
        totalMessageNum: 0,
        list: const [],
      );
    }
  }

  @override
  Future<FCMessageResult> getMessageAsync(
      String messageId, String boxId, bool returnHtml) async {
    try {
      // messageId is the topic id in our mapping. Fetch the topic and
      // surface the first post as the "message body".
      final t = await apiGet('/t/$messageId.json');
      final stream = (t['post_stream'] as Map<String, dynamic>?) ?? const {};
      final posts = ((stream['posts'] as List?) ?? const []).whereType<Map>();
      final first = posts.isEmpty ? null : posts.first.cast<String, dynamic>();
      if (first == null) {
        return FCMessageResult(
          result: false,
          resultText: 'No content',
          msgId: messageId,
          subject: (t['title'] ?? '').toString(),
          authorId: '',
          authorName: '',
          textBody: '',
          msgTime: '',
          isUnread: false,
        );
      }

      String? avatarUrl;
      final tpl = first['avatar_template'] as String?;
      if (tpl != null && tpl.isNotEmpty) {
        final filled = tpl.replaceAll('{size}', '90');
        avatarUrl = filled.startsWith('http')
            ? filled
            : '${siteContext.site.url}$filled';
      }

      return FCMessageResult(
        result: true,
        resultText: '',
        msgId: messageId,
        subject: (t['title'] ?? '').toString(),
        authorId: (first['user_id'] ?? '').toString(),
        authorName: (first['username'] ?? '').toString(),
        msgFrom: (first['username'] ?? '').toString(),
        iconUrl: avatarUrl,
        textBody: returnHtml
            ? (first['cooked'] ?? '').toString()
            : (first['raw'] ?? '').toString(),
        msgTime: (first['created_at'] ?? '').toString(),
        isUnread: t['unseen'] == true,
        canReply: !((t['closed'] as bool?) ?? false) &&
            !((t['archived'] as bool?) ?? false),
        canForward: false,
        canReport: true,
      );
    } on DiscourseApiException catch (e) {
      return FCMessageResult(
        result: false,
        resultText: e.userMessage,
        msgId: messageId,
        subject: '',
        authorId: '',
        authorName: '',
        textBody: '',
        msgTime: '',
        isUnread: false,
      );
    } catch (e) {
      return FCMessageResult(
        result: false,
        resultText: 'Error: $e',
        msgId: messageId,
        subject: '',
        authorId: '',
        authorName: '',
        textBody: '',
        msgTime: '',
        isUnread: false,
      );
    }
  }

  @override
  Future<FCCreateMessageResult> createMessageAsync(
    List<String> userName,
    String subject,
    String textBody,
    int? action,
    String? pmId,
    List<String>? attachmentIds,
    String? groupId,
  ) async {
    if (action == 1 && pmId != null && pmId.isNotEmpty) {
      // Reply: post into the existing PM topic.
      try {
        final response = await apiPost('/posts.json', body: {
          'topic_id': int.tryParse(pmId) ?? pmId,
          'raw': textBody,
          'archetype': 'private_message',
        });
        return FCCreateMessageResult(
          result: true,
          resultText: '',
          msgId: (response['topic_id'] ?? pmId).toString(),
        );
      } on DiscourseApiException catch (e) {
        return FCCreateMessageResult(
            result: false, resultText: e.userMessage, msgId: '');
      } catch (e) {
        return FCCreateMessageResult(
            result: false, resultText: 'Error: $e', msgId: '');
      }
    }

    // New PM (or forward — Discourse doesn't have a forward primitive, so
    // the UI is responsible for prefixing the original content into the
    // body if it wants forward semantics).
    if (userName.isEmpty) {
      return FCCreateMessageResult(
        result: false,
        resultText: 'No recipients',
        msgId: '',
      );
    }
    try {
      final response = await apiPost('/posts.json', body: {
        'archetype': 'private_message',
        'target_recipients': userName.join(','),
        'title': subject,
        'raw': textBody,
      });
      return FCCreateMessageResult(
        result: true,
        resultText: '',
        msgId: (response['topic_id'] ?? '').toString(),
      );
    } on DiscourseApiException catch (e) {
      return FCCreateMessageResult(
          result: false, resultText: e.userMessage, msgId: '');
    } catch (e) {
      return FCCreateMessageResult(
          result: false, resultText: 'Error: $e', msgId: '');
    }
  }

  @override
  Future<FCQuotePMResult> getQuotePmAsync(String messageId) async {
    // messageId is a topic id; quote the first post.
    try {
      final t = await apiGet('/t/$messageId.json');
      final posts = ((t['post_stream'] as Map<String, dynamic>?)?['posts']
              as List?) ??
          const [];
      if (posts.isEmpty) {
        return FCQuotePMResult(result: false, resultText: 'No content');
      }
      final first = (posts.first as Map).cast<String, dynamic>();
      final pid = first['id'];
      final p = pid == null ? first : await apiGet('/posts/$pid.json');
      final raw = (p['raw'] as String?) ?? '';
      final username = (p['username'] as String?) ?? '';
      final quote =
          '[quote="$username, post:${p['post_number']}, topic:${p['topic_id']}"]\n$raw\n[/quote]\n\n';
      return FCQuotePMResult(
        result: true,
        resultText: '',
        quoteText: quote,
        authorName: username,
      );
    } on DiscourseApiException catch (e) {
      return FCQuotePMResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCQuotePMResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCDeleteMessageResult> deleteMessageAsync(
      String messageId, String boxId) async {
    // Discourse: archiving moves a PM out of the inbox; outright deletion
    // is staff-only on the topic. Use archive.
    final path = boxId == _boxSent
        ? '/t/$messageId/archive-message.json'
        : '/t/$messageId/move-to-inbox.json';
    try {
      await apiPut(path);
      return FCDeleteMessageResult(result: true, resultText: '');
    } on DiscourseApiException catch (e) {
      return FCDeleteMessageResult(
          result: false, resultText: e.userMessage);
    } catch (e) {
      return FCDeleteMessageResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCMarkPMUnreadResult> markPmUnreadAsync(String messageId) async {
    // No client API for "mark unread" on Discourse PMs; report success
    // without a server side-effect (lossy).
    return FCMarkPMUnreadResult(result: true, resultText: '');
  }

  @override
  Future<FCMarkPMReadResult> markPmReadAsync(List<String> messageIds) async {
    // Read-state is implicit on /t/{id}.json fetches. No-op success.
    return FCMarkPMReadResult(result: true, resultText: '');
  }

  @override
  Future<FCReportPMResult> reportPmAsync(String msgId, String? reason) async {
    // Report the first post of the PM topic.
    try {
      final t = await apiGet('/t/$msgId.json');
      final posts = ((t['post_stream'] as Map<String, dynamic>?)?['posts']
              as List?) ??
          const [];
      if (posts.isEmpty) {
        return FCReportPMResult(result: false, resultText: 'No content');
      }
      final firstPostId = (posts.first as Map)['id'];
      final actionTypeId = (reason ?? '').trim().isEmpty ? 4 : 8;
      await apiPost('/post_actions.json', body: {
        'id': firstPostId,
        'post_action_type_id': actionTypeId,
        if ((reason ?? '').trim().isNotEmpty) 'message': reason,
      });
      return FCReportPMResult(result: true, resultText: '');
    } on DiscourseApiException catch (e) {
      return FCReportPMResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCReportPMResult(result: false, resultText: 'Error: $e');
    }
  }

  // ===== Helpers =====

  Future<int> _unreadPmCount() async {
    if (!siteContext.hasUserApiKey) return 0;
    try {
      final response = await apiGet('/notifications.json', query: {
        'recent': 'true',
      });
      var unread = 0;
      for (final n
          in ((response['notifications'] as List?) ?? const []).whereType<Map>()) {
        if (n['read'] == true) continue;
        final type = n['notification_type'] as int?;
        if (type == 6 || type == 7) unread++;
      }
      return unread;
    } catch (_) {
      return 0;
    }
  }

  FCPrivateMessage _pmFromTopic(
    Map<String, dynamic> t, {
    Map<int, Map<String, dynamic>> users = const {},
  }) {
    final posters = (t['posters'] as List?) ?? const [];
    int? opUserId;
    for (final p in posters.whereType<Map>()) {
      final desc = (p['description'] ?? '').toString();
      if (desc.contains('Original Poster')) {
        opUserId = p['user_id'] as int?;
        break;
      }
    }
    opUserId ??=
        posters.isNotEmpty ? (posters.first as Map)['user_id'] as int? : null;
    final opUser = opUserId == null ? null : users[opUserId];
    String? avatarUrl;
    final tpl = opUser?['avatar_template'] as String?;
    if (tpl != null && tpl.isNotEmpty) {
      final filled = tpl.replaceAll('{size}', '90');
      avatarUrl = filled.startsWith('http')
          ? filled
          : '${siteContext.site.url}$filled';
    }
    final fromUsername = (opUser?['username'] ?? '').toString();
    final isMine = fromUsername.isNotEmpty &&
        fromUsername == siteContext.currentUsername;
    final isUnread =
        t['unseen'] == true || (t['unread_posts'] as int? ?? 0) > 0;

    return FCPrivateMessage(
      msgId: (t['id'] ?? '').toString(),
      subject: (t['title'] ?? '').toString(),
      msgSubject: (t['title'] ?? '').toString(),
      msgFrom: fromUsername,
      msgTo: ((t['allowed_user_ids'] as List?) ?? const [])
          .whereType<int>()
          .map((id) => (users[id]?['username'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toList(),
      authorId: (opUserId ?? '').toString(),
      authorName: fromUsername,
      iconUrl: avatarUrl,
      textBody: (t['excerpt'] as String?) ?? '',
      msgTime: (t['last_posted_at'] ?? t['created_at'] ?? '').toString(),
      sentDate: (t['created_at'] ?? '').toString(),
      msgState: isUnread ? 1 : 0,
      isUnread: isUnread,
      isFromCurrentUser: isMine,
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
