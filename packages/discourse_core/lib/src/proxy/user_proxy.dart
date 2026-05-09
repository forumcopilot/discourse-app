import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_user_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_user.dart';
import 'package:forumcopilot_sdk/models/entities/fc_tfa_provider.dart';
import 'package:forumcopilot_sdk/models/results/fc_passkey_result.dart';
import 'package:forumcopilot_sdk/models/results/fc_private_conversation_result.dart';
import 'package:forumcopilot_sdk/models/results/fc_user_result.dart';
import 'package:forumcopilot_sdk/services/fc_http_overrides.dart';
import '../base_discourse_proxy.dart';
import '../context/discourse_site_context_extension.dart';

/// Discourse implementation of IFCUserProxy
/// Handles user operations and profile management for Discourse forums
class DiscourseUserProxy extends BaseDiscourseProxy implements IFCUserProxy {
  DiscourseUserProxy(SiteContext context) : super(context);

  @override
  Future<String> getAvatarAsync(String userId, String username) {
    // TODO: implement getAvatarAsync
    throw UnimplementedError();
  }

  @override
  Future<FCIgnoredUserResult> getIgnoredUsersAsync(int page, int perpage) {
    // TODO: implement getIgnoredUsersAsync
    throw UnimplementedError();
  }

  @override
  Future<FCInboxStatResult> getInboxStatAsync(
      DateTime pmLastCheckedTime, DateTime subscribedTopicLastCheckedTime) async {
    // Drives the home-tab unread badge. We approximate the FC inbox stat
    // shape from /notifications.json: unread PMs (notification_type=6 or 7)
    // map to unread conversations/messages; totalConversations is the
    // grand-total count of notifications (Discourse doesn't expose a
    // separate "all conversations ever" number).
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
      var unreadOther = 0;
      for (final n in notifications) {
        if (n['read'] == true) continue;
        final type = n['notification_type'] as int?;
        if (type == 6 /* private_message */ || type == 7 /* invited_to_pm */) {
          unreadPms++;
        } else {
          unreadOther++;
        }
      }
      final total =
          (response['total_rows_notifications'] as int?) ?? unreadPms + unreadOther;
      return FCInboxStatResult(
        result: true,
        resultText: '',
        totalConversations: total,
        unreadConversations: unreadPms,
        unreadMessages: unreadPms,
      );
    } catch (e) {
      // Failure shouldn't crash the home tab — just report zero unreads.
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
  Future<FCOnlineUserResult> getOnlineUsersAsync(int page, int perpage, String? id, String? area) async {
    print('✅ [DISCOURSE_USER] getOnlineUsersAsync called via plugin API');

    try {
      final params = <String, dynamic>{
        'page': page,
        'perpage': perpage,
      };
      if (id != null && id.isNotEmpty) {
        params['id'] = id;
      }
      if (area != null && area.isNotEmpty) {
        params['area'] = area;
      }

      final response = await callPluginApi('getOnlineUsers', params);

      // Parse user list
      final List<FCOnlineUser> userList = [];
      if (response['list'] != null && response['list'] is List) {
        for (var userData in response['list'] as List) {
          if (userData is Map<String, dynamic>) {
            userList.add(FCOnlineUser(
              id: userData['id']?.toString() ?? '',
              username: userData['username']?.toString() ?? '',
              iconUrl: userData['iconUrl']?.toString(),
              isOnline: userData['isOnline'] ?? false,
              currentActivity: userData['currentActivity']?.toString(),
              currentTopicId: userData['currentTopicId']?.toString(),
              lastActivityTime: userData['lastActivityTime'] != null ? DateTime.fromMillisecondsSinceEpoch(userData['lastActivityTime'] as int) : null,
            ));
          }
        }
      }

      return FCOnlineUserResult(
        result: response['result'] ?? false,
        resultText: response['resultText']?.toString(),
        total: response['total'] ?? 0,
        list: userList,
      );
    } catch (e) {
      print('❌ [DISCOURSE_USER] getOnlineUsersAsync error: $e');
      return FCOnlineUserResult(
        result: false,
        resultText: 'Error getting online users: $e',
        total: 0,
        list: [],
      );
    }
  }

  @override
  Future<FCRecommendedUserResult> getRecommendedUsersAsync(int page, int perpage, int mode) {
    // TODO: implement getRecommendedUsersAsync
    throw UnimplementedError();
  }

  @override
  Future<FCUserInfoResult> getUserInfoAsync(String? username, String? userId) async {
    if ((username == null || username.isEmpty) && (userId == null || userId.isEmpty)) {
      return FCUserInfoResult(
        result: false,
        resultText: 'username or userId required',
        id: '',
        username: '',
      );
    }
    if (username == null || username.isEmpty) {
      // Discourse exposes `/u/{username}.json`; resolving id-only requires an
      // admin endpoint we don't want to depend on. Phase 2: hit `/admin/users/{id}.json`
      // when the caller has staff scopes.
      return FCUserInfoResult(
        result: false,
        resultText: 'Discourse user lookup requires a username (id-only lookup not yet supported)',
        id: userId ?? '',
        username: '',
      );
    }

    try {
      final response = await apiGet('/u/${Uri.encodeComponent(username)}.json');
      final user = (response['user'] as Map<String, dynamic>?) ?? const {};

      String? avatarUrl;
      final avatarTemplate = user['avatar_template'] as String?;
      if (avatarTemplate != null && avatarTemplate.isNotEmpty) {
        final filled = avatarTemplate.replaceAll('{size}', '240');
        avatarUrl = filled.startsWith('http')
            ? filled
            : '${siteContext.site.url}$filled';
      }

      DateTime? parseTs(Object? raw) {
        if (raw == null) return null;
        if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
        if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
        return null;
      }

      final groupsRaw = user['groups'] as List? ?? const [];
      final groups = groupsRaw
          .whereType<Map>()
          .map((g) => (g['name'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toList();

      final customFields = <FCUserCustomField>[];
      final cfRaw = user['custom_fields'];
      if (cfRaw is Map) {
        cfRaw.forEach((k, v) {
          customFields.add(FCUserCustomField(name: k.toString(), value: v?.toString() ?? ''));
        });
      }

      final lastSeenAt = parseTs(user['last_seen_at']);
      final fiveMinAgo = DateTime.now().subtract(const Duration(minutes: 5));
      final isOnline = lastSeenAt != null && lastSeenAt.isAfter(fiveMinAgo);

      return FCUserInfoResult(
        result: true,
        resultText: '',
        id: (user['id'] ?? '').toString(),
        username: (user['username'] ?? '').toString(),
        loginName: (user['username'] ?? '').toString(),
        userType: (user['admin'] == true)
            ? 'admin'
            : ((user['moderator'] == true) ? 'moderator' : 'normal'),
        iconUrl: avatarUrl,
        postCount: (user['post_count'] as int?) ?? 0,
        registrationTime: parseTs(user['created_at']),
        lastActivityTime: lastSeenAt,
        isOnline: isOnline,
        acceptsPM: user['can_send_private_message_to_user'] == true,
        canSendPM: false,
        canPM: false,
        isFollowing: false,
        isFollowingMe: false,
        acceptsFollowers: false,
        followingCount: 0,
        followerCount: 0,
        canBan: false,
        isBanned: user['suspended'] == true,
        isIgnored: user['ignored'] == true,
        canSpamClean: false,
        canBeReported: true,
        userGroups: groups,
        customFields: customFields,
        canModerate: user['moderator'] == true,
        canSearch: false,
        currentActivity: null,
        currentTopicId: null,
        displayText: user['name']?.toString(),
        email: null,
        location: user['location']?.toString(),
        website: user['website_name']?.toString() ?? user['website']?.toString(),
        signature: null,
        bio: (user['bio_excerpt'] ?? user['bio_raw'])?.toString(),
      );
    } catch (e) {
      return FCUserInfoResult(
        result: false,
        resultText: 'Error getting user info: $e',
        id: '',
        username: '',
      );
    }
  }

  @override
  Future<FCUserReplyResult> getUserReplyPostAsync(int startNum, int lastNum, String? searchId, String? username, String? userId) async {
    print('✅ [DISCOURSE_USER] getUserReplyPostAsync called via plugin API');

    try {
      final params = <String, dynamic>{
        'startNum': startNum,
        'lastNum': lastNum,
      };
      if (searchId != null && searchId.isNotEmpty) {
        params['searchId'] = searchId;
      }
      if (username != null && username.isNotEmpty) {
        params['username'] = username;
      }
      if (userId != null && userId.isNotEmpty) {
        params['userId'] = userId;
      }

      final response = await callPluginApi('getUserReplyPost', params);

      // Parse reply list
      final List<FCUserReply> replyList = [];
      if (response['list'] != null && response['list'] is List) {
        for (var replyData in response['list'] as List) {
          if (replyData is Map<String, dynamic>) {
            replyList.add(FCUserReply(
              postId: replyData['postId']?.toString() ?? '',
              topicId: replyData['topicId']?.toString() ?? '',
              topicTitle: replyData['topicTitle']?.toString() ?? '',
              forumId: replyData['forumId']?.toString() ?? '',
              forumName: replyData['forumName']?.toString() ?? '',
              authorId: replyData['authorId']?.toString() ?? '',
              authorName: replyData['authorName']?.toString() ?? '',
              authorIconUrl: replyData['authorIconUrl']?.toString(),
              postTime: replyData['postTime'] != null ? DateTime.fromMillisecondsSinceEpoch(replyData['postTime'] as int) : DateTime.now(),
              replyNumber: replyData['replyNumber'] ?? 0,
              postContent: replyData['postContent']?.toString(),
              shortContent: replyData['shortContent']?.toString(),
            ));
          }
        }
      }

      return FCUserReplyResult(
        result: response['result'] ?? false,
        resultText: response['resultText']?.toString(),
        total: response['total'] ?? 0,
        list: replyList,
      );
    } catch (e) {
      print('❌ [DISCOURSE_USER] getUserReplyPostAsync error: $e');
      return FCUserReplyResult(
        result: false,
        resultText: 'Error getting user reply posts: $e',
        total: 0,
        list: [],
      );
    }
  }

  @override
  Future<FCUserTopicResult> getUserTopicAsync(String? username, String? userId) {
    // TODO: implement getUserTopicAsync
    throw UnimplementedError();
  }

  @override
  Future<FCIgnoreUserResult> ignoreUserAsync(String userId, int mode) {
    // TODO: implement ignoreUserAsync
    throw UnimplementedError();
  }

  /// Discourse does not expose a username/password JSON login endpoint to
  /// third-party clients — mobile auth goes through the User API Key
  /// handshake (RSA-encrypted, scoped, per-device key).
  ///
  /// This method is left in place to satisfy the SDK contract; Phase 1.x
  /// will rewrite the login UI to call [DiscourseAuthManager.beginHandshake]
  /// in a webview and pass the redirect payload to
  /// [DiscourseAuthManager.completeHandshake]. Until then, the existing
  /// username/password form returns a guidance message.
  @override
  Future<FCLoginResult> loginAsync(
    String loginname,
    String password,
    bool anonymous,
    String? trustCode, {
    bool remember = true,
    String? tfaCode,
    String? tfaProvider,
    String? webauthnChallenge,
    Map<String, String>? webauthnPayload,
    bool trustDevice = false,
  }) async {
    return FCLoginResult(
      result: false,
      resultText:
          'Discourse mobile login uses User API Keys (handshake via webview). '
          'Phase 1.x will wire the new flow into the UI; for now, see '
          'DiscourseAuthManager.beginHandshake in packages/discourse_core.',
      user: null,
    );
  }

  @override
  Future<FCPasskeyChallengeResult> getPasskeyChallengeAsync() async {
    print('✅ [DISCOURSE_USER] getPasskeyChallengeAsync called - IMPLEMENTED');

    final response = await callPluginApi('getPasskeyChallenge', {});
    final timeout = response['timeout'] != null ? (response['timeout'] is int ? response['timeout'] as int : int.tryParse(response['timeout'].toString())) : null;

    return FCPasskeyChallengeResult(
      result: response['result'] ?? true,
      resultText: response['resultText']?.toString(),
      challenge: response['challenge']?.toString(),
      rpId: response['rpId']?.toString(),
      timeout: timeout,
    );
  }

  /// Discourse handles passkeys via its own login UI (which the User API Key
  /// handshake webview lands on). The mobile app does not need a separate
  /// passkey path — when the webview shows Discourse's login page, passkey
  /// works there.
  @override
  Future<FCLoginResult> loginWithPasskeyAsync({
    required String webauthnChallenge,
    required Map<String, String> webauthnPayload,
  }) async {
    return FCLoginResult(
      result: false,
      resultText:
          'Discourse passkey auth happens inside the User API Key handshake webview. '
          'See DiscourseAuthManager.beginHandshake.',
      user: null,
    );
  }

  @override
  Future<FCLoginTwoStepResult> loginTwoStepAsync(String codeTwoStep, bool trust) {
    // TODO: implement loginTwoStepAsync
    throw UnimplementedError();
  }

  @override
  Future<void> logoutUserAsync() async {
    // Best-effort: ask Discourse to revoke the User API Key, then drop it
    // locally regardless of the network response.
    try {
      await apiPost('/user-api-key/revoke');
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ [DISCOURSE_USER] /user-api-key/revoke failed (continuing local logout): $e');
    }
    await siteContext.clearUserApiCredentials();
    siteContext.resetOnLogout();
  }

  @override
  Future<FCSearchUserResult> searchUserAsync(
      String keywords, int page, int perpage) async {
    // Discourse user typeahead. The `topic_allowed_users=true` flag is
    // important for PM-recipient pickers — it filters out users who can't
    // be added to PMs (suspended, etc.). The endpoint returns up to 5
    // matches by default; we don't paginate (the SDK's page/perpage are
    // not honored).
    if (keywords.trim().length < 1) {
      return FCSearchUserResult(
        result: true,
        resultText: '',
        total: 0,
        list: const [],
      );
    }
    try {
      final response = await apiGet('/u/search/users.json', query: {
        'term': keywords.trim(),
        'topic_allowed_users': 'true',
        'include_groups': 'false',
      });
      final users = (response['users'] as List?) ?? const [];
      final list = users.whereType<Map>().map((u) {
        final m = u.cast<String, dynamic>();
        String? avatarUrl;
        final tpl = m['avatar_template'] as String?;
        if (tpl != null && tpl.isNotEmpty) {
          final filled = tpl.replaceAll('{size}', '90');
          avatarUrl = filled.startsWith('http')
              ? filled
              : '${siteContext.site.url}$filled';
        }
        return FCSearchUser(
          id: (m['id'] ?? '').toString(),
          username: (m['username'] ?? '').toString(),
          iconUrl: avatarUrl,
          postCount: 0,
          registrationTime: null,
          isOnline: false,
        );
      }).toList();
      return FCSearchUserResult(
        result: true,
        resultText: '',
        total: list.length,
        list: list,
      );
    } on DiscourseApiException catch (e) {
      return FCSearchUserResult(
        result: false,
        resultText: e.userMessage,
        total: 0,
        list: const [],
      );
    } catch (e) {
      return FCSearchUserResult(
        result: false,
        resultText: 'Error: $e',
        total: 0,
        list: const [],
      );
    }
  }

  @override
  Future<FCReportUserResult> reportUserAsync(String userId, String reason) async {
    print('✅ [DISCOURSE_USER] reportUserAsync called - IMPLEMENTED');
    print('   📋 Parameters: userId=$userId, reason=$reason');

    try {
      final response = await callPluginApi('reportUser', {
        'userId': userId,
        'reason': reason,
      });

      return FCReportUserResult(
        result: response['result'] ?? false,
        resultText: response['resultText']?.toString(),
      );
    } catch (e) {
      print('❌ [DISCOURSE_USER] reportUserAsync error: $e');
      return FCReportUserResult(
        result: false,
        resultText: 'Error reporting user: $e',
      );
    }
  }
}
