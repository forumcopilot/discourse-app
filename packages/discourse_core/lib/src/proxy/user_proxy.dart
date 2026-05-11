import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_user_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_badge.dart';
import 'package:forumcopilot_sdk/models/entities/fc_directory_item.dart';
import 'package:forumcopilot_sdk/models/entities/fc_user.dart';
import 'package:forumcopilot_sdk/models/entities/fc_tfa_provider.dart';
import 'package:forumcopilot_sdk/models/results/fc_directory_result.dart';
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
  Future<String> getAvatarAsync(String userId, String username) async {
    // Discourse avatars are content-addressable; the canonical URL pattern
    // is /letter_avatar_proxy/v4/letter/{first}/{color_hex}/{size}.png for
    // letter-style or /user_avatar/{forum_host}/{username}/{size}/{id}.png
    // for uploaded. We don't have an `avatar_id` here, so we hit
    // /u/{username}.json's avatar_template and fill {size}=120. For empty
    // username, fall back to a placeholder URL the UI can show.
    if (username.isEmpty) return '';
    try {
      final response = await apiGet('/u/${Uri.encodeComponent(username)}.json');
      final user = (response['user'] as Map<String, dynamic>?) ?? const {};
      final tpl = user['avatar_template'] as String?;
      if (tpl == null || tpl.isEmpty) return '';
      final filled = tpl.replaceAll('{size}', '120');
      return filled.startsWith('http')
          ? filled
          : '${siteContext.site.url}$filled';
    } catch (_) {
      return '';
    }
  }

  @override
  Future<FCIgnoredUserResult> getIgnoredUsersAsync(int page, int perpage) async {
    // Discourse keeps ignored usernames on UserOption.ignored_usernames.
    // The current user's profile JSON exposes them via /u/{me}.json's
    // `user.ignored_usernames` field (empty array when none). There is no
    // dedicated paginated endpoint — we return the full list at once.
    final username = siteContext.currentUsername;
    if (username == null || username.isEmpty) {
      return FCIgnoredUserResult(
        result: false,
        resultText: 'Not signed in',
        total: 0,
        list: const [],
      );
    }
    try {
      final response =
          await apiGet('/u/${Uri.encodeComponent(username)}.json');
      final user = (response['user'] as Map<String, dynamic>?) ?? const {};
      final names =
          ((user['ignored_usernames'] as List?) ?? const []).whereType<String>();
      final list = names
          .map((name) => FCIgnoredUser(
                id: '',
                username: name,
              ))
          .toList();
      return FCIgnoredUserResult(
        result: true,
        resultText: '',
        total: list.length,
        list: list,
      );
    } on DiscourseApiException catch (e) {
      return FCIgnoredUserResult(
        result: false,
        resultText: e.userMessage,
        total: 0,
        list: const [],
      );
    } catch (e) {
      return FCIgnoredUserResult(
        result: false,
        resultText: 'Error: $e',
        total: 0,
        list: const [],
      );
    }
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
  Future<FCOnlineUserResult> getOnlineUsersAsync(
      int page, int perpage, String? id, String? area) async {
    // Discourse has no "currently online" REST endpoint — presence is
    // tracked via MessageBus (websocket-style). The closest REST proxy
    // is /directory_items.json sorted by last seen, which lists the
    // most-recently-active users for a period. We use period=daily so the
    // result feels "online-ish".
    //
    // The `id` and `area` parameters (XF: forum/thread filter) have no
    // Discourse equivalent — we ignore them.
    try {
      final response = await apiGet('/directory_items.json', query: {
        'period': 'daily',
        'order': 'days_visited',
        if (page > 0) 'page': page.toString(),
      });
      final items = ((response['directory_items'] as List?) ?? const [])
          .whereType<Map>()
          .map((d) => d.cast<String, dynamic>())
          .toList();
      final userList = items.map((item) {
        final user = (item['user'] as Map<String, dynamic>?) ?? const {};
        String? avatarUrl;
        final tpl = user['avatar_template'] as String?;
        if (tpl != null && tpl.isNotEmpty) {
          final filled = tpl.replaceAll('{size}', '90');
          avatarUrl = filled.startsWith('http')
              ? filled
              : '${siteContext.site.url}$filled';
        }
        return FCOnlineUser(
          id: (user['id'] ?? '').toString(),
          username: (user['username'] ?? '').toString(),
          iconUrl: avatarUrl,
          // /directory_items doesn't expose live presence; surface false
          // to be honest about it. The list is "recently active" not
          // "online right now".
          isOnline: false,
        );
      }).toList();
      final meta = (response['meta'] as Map<String, dynamic>?) ?? const {};
      final total = (meta['total_rows_directory_items'] as int?) ?? userList.length;
      return FCOnlineUserResult(
        result: true,
        resultText: '',
        total: total,
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

  /// Phase 5.18c-1 — fetch a page of the Discourse user directory.
  /// Hits `/directory_items.json?period={period}&order={order}&page={page}`
  /// and returns rich `DiscourseDirectoryItem` rows (username + avatar
  /// + the seven stats Discourse sorts the directory by).
  ///
  /// This is the Discourse-native equivalent of the legacy
  /// XF-shaped `getOnlineUsersAsync` (which is hard-pinned to
  /// `daily/days_visited`). Callers that want all-time top likes,
  /// most posts in the last month, etc. should use this method
  /// instead — `getOnlineUsersAsync` stays for the existing Members
  /// page only.
  ///
  /// [period] is one of `all` / `yearly` / `quarterly` / `monthly` /
  /// `weekly` / `daily` (Discourse defaults to `weekly`).
  /// [order] is one of `likes_received` / `likes_given` /
  /// `topics_entered` / `topic_count` / `post_count` / `posts_read` /
  /// `days_visited`.
  /// [page] is 1-indexed; Discourse returns 50 rows per page.
  @override
  Future<FCDirectoryItemResult> getDirectoryItemsAsync(
    String period,
    String order,
    int page,
  ) async {
    try {
      final response = await apiGet('/directory_items.json', query: {
        'period': period,
        'order': order,
        if (page > 1) 'page': page.toString(),
      });
      final raw = ((response['directory_items'] as List?) ?? const [])
          .whereType<Map>()
          .map((d) => d.cast<String, dynamic>())
          .toList();
      final items = raw
          .map((j) => _directoryItemFromJson(j))
          .toList(growable: false);
      final total = (response['total_rows_directory_items'] as num?)
              ?.toInt() ??
          items.length;
      return FCDirectoryItemResult(
        result: true,
        total: total,
        items: items,
      );
    } on DiscourseApiException catch (e) {
      return FCDirectoryItemResult(
        result: false,
        resultText: e.userMessage,
        total: 0,
        items: const [],
      );
    } catch (e) {
      return FCDirectoryItemResult(
        result: false,
        resultText: 'Error: $e',
        total: 0,
        items: const [],
      );
    }
  }

  @override
  Future<FCBadgeResult> getAllBadgesAsync() async {
    try {
      final response = await apiGet('/badges.json');
      final raw = (response['badges'] as List?) ?? const [];
      final badges = raw
          .whereType<Map>()
          .map((d) => _badgeFromJson(definition: d.cast<String, dynamic>()))
          .toList();
      badges.sort((a, b) => b.grantCount.compareTo(a.grantCount));
      return FCBadgeResult(result: true, badges: badges);
    } on DiscourseApiException catch (e) {
      return FCBadgeResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCBadgeResult(result: false, resultText: 'Error: $e');
    }
  }

  FCDirectoryItem _directoryItemFromJson(Map<String, dynamic> json) {
    final user = (json['user'] as Map<String, dynamic>?) ?? const {};
    String avatarUrl = '';
    final tpl = user['avatar_template'] as String?;
    if (tpl != null && tpl.isNotEmpty) {
      final filled = tpl.replaceAll('{size}', '90');
      avatarUrl =
          filled.startsWith('http') ? filled : '${siteContext.site.url}$filled';
    }
    int statAt(String key) {
      final raw = json[key] ?? user[key];
      if (raw is num) return raw.toInt();
      return 0;
    }

    return FCDirectoryItem(
      id: (user['id'] as num?)?.toInt() ?? 0,
      username: (user['username'] ?? '').toString(),
      name: (user['name'] as String?)?.trim().isNotEmpty == true
          ? user['name'] as String
          : null,
      avatarUrl: avatarUrl,
      trustLevel: (user['trust_level'] as num?)?.toInt(),
      likesReceived: statAt('likes_received'),
      likesGiven: statAt('likes_given'),
      topicsEntered: statAt('topics_entered'),
      postsRead: statAt('posts_read'),
      daysVisited: statAt('days_visited'),
      topicCount: statAt('topic_count'),
      postCount: statAt('post_count'),
    );
  }

  FCBadge _badgeFromJson({
    required Map<String, dynamic> definition,
    Map<String, dynamic>? grant,
  }) {
    return FCBadge(
      id: (definition['id'] as num).toInt(),
      name: (definition['name'] ?? '').toString(),
      description: definition['description']?.toString(),
      icon: definition['icon']?.toString(),
      imageUrl: definition['image_url']?.toString(),
      badgeTypeId: (definition['badge_type_id'] as num?)?.toInt() ?? 1,
      grantedAt: DateTime.tryParse(grant?['granted_at']?.toString() ?? ''),
      grantCount: (grant?['count'] as num?)?.toInt() ?? 1,
      granted: grant != null,
    );
  }

  // Phase 5.43 — `getRecommendedUsersAsync` deleted from IFCUserProxy
  // (Discourse has no equivalent concept; PM recipient picker uses
  // typeahead-only).

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
        // Discourse 3.x exposes follow state inline on the user JSON.
        // `is_followed` is true when the viewer follows this user;
        // `can_follow` is true when the user permits being followed.
        isFollowing: user['is_followed'] == true,
        isFollowingMe: user['is_following_me'] == true,
        acceptsFollowers: user['can_follow'] != false,
        followingCount: (user['total_following'] as int?) ?? 0,
        followerCount: (user['total_followers'] as int?) ?? 0,
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
        trustLevel: user['trust_level'] as int?,
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
  Future<FCUserReplyResult> getUserReplyPostAsync(
      int startNum,
      int lastNum,
      String? searchId,
      String? username,
      String? userId) async {
    if (username == null || username.isEmpty) {
      return FCUserReplyResult(
        result: false,
        resultText: 'username required',
        total: 0,
        list: const [],
      );
    }
    try {
      // /user_actions filter values:
      //   1=Like, 2=WasLiked, 3=Bookmark, 4=NewTopic, 5=Reply,
      //   6=Response (got replied to), 7=Mention, 9=Quote, 11=Edit,
      //   12=Message
      // We surface 5 (replies the user wrote).
      final response = await apiGet('/user_actions.json', query: {
        'username': username,
        'filter': '5',
        if (startNum > 0) 'offset': startNum.toString(),
      });
      final actions = ((response['user_actions'] as List?) ?? const [])
          .whereType<Map>()
          .map((a) => a.cast<String, dynamic>())
          .toList();
      final replyList = actions.map((a) {
        String? avatarUrl;
        final tpl = a['avatar_template'] as String?;
        if (tpl != null && tpl.isNotEmpty) {
          final filled = tpl.replaceAll('{size}', '90');
          avatarUrl = filled.startsWith('http')
              ? filled
              : '${siteContext.site.url}$filled';
        }
        return FCUserReply(
          postId: (a['post_id'] ?? '').toString(),
          topicId: (a['topic_id'] ?? '').toString(),
          topicTitle: (a['title'] ?? '').toString(),
          forumId: (a['category_id'] ?? '').toString(),
          forumName: '',
          authorId: (a['user_id'] ?? '').toString(),
          authorName: (a['username'] ?? '').toString(),
          authorIconUrl: avatarUrl,
          postTime: DateTime.tryParse(a['created_at']?.toString() ?? '') ??
              DateTime.now(),
          replyNumber: (a['post_number'] as int?) ?? 0,
          postContent: a['excerpt']?.toString(),
          shortContent: a['excerpt']?.toString(),
        );
      }).toList();
      return FCUserReplyResult(
        result: true,
        resultText: '',
        total: replyList.length,
        list: replyList,
      );
    } on DiscourseApiException catch (e) {
      return FCUserReplyResult(
        result: false,
        resultText: e.userMessage,
        total: 0,
        list: const [],
      );
    } catch (e) {
      return FCUserReplyResult(
        result: false,
        resultText: 'Error: $e',
        total: 0,
        list: const [],
      );
    }
  }

  @override
  Future<FCUserTopicResult> getUserTopicAsync(
      String? username, String? userId) async {
    if (username == null || username.isEmpty) {
      return FCUserTopicResult(
        result: false,
        resultText: 'username required',
        total: 0,
        list: const [],
      );
    }
    try {
      // /user_actions filter=4 → "new_topic" (topics the user created).
      final response = await apiGet('/user_actions.json', query: {
        'username': username,
        'filter': '4',
      });
      final actions = ((response['user_actions'] as List?) ?? const [])
          .whereType<Map>()
          .map((a) => a.cast<String, dynamic>())
          .toList();
      final topics = <FCUserTopic>[];
      final seen = <String>{};
      for (final a in actions) {
        final topicId = a['topic_id']?.toString() ?? '';
        if (topicId.isEmpty || !seen.add(topicId)) continue;
        topics.add(FCUserTopic(
          topicId: topicId,
          topicTitle: (a['title'] ?? '').toString(),
          forumId: (a['category_id'] ?? '').toString(),
          forumName: '',
          authorId: (a['user_id'] ?? '').toString(),
          authorName: (a['username'] ?? '').toString(),
          postTime:
              DateTime.tryParse(a['created_at']?.toString() ?? '') ??
                  DateTime.now(),
          shortContent: a['excerpt']?.toString(),
        ));
      }
      return FCUserTopicResult(
        result: true,
        resultText: '',
        total: topics.length,
        list: topics,
      );
    } on DiscourseApiException catch (e) {
      return FCUserTopicResult(
        result: false,
        resultText: e.userMessage,
        total: 0,
        list: const [],
      );
    } catch (e) {
      return FCUserTopicResult(
        result: false,
        resultText: 'Error: $e',
        total: 0,
        list: const [],
      );
    }
  }

  @override
  Future<FCIgnoreUserResult> ignoreUserAsync(String userId, int mode) async {
    // The SDK contract takes `userId` but Discourse's notification-level
    // endpoint expects a username. We accept either: numeric → look up via
    // /admin/users/{id}.json (admin only) or assume the caller actually
    // passed a username.
    String username = userId;
    final asInt = int.tryParse(userId);
    if (asInt != null) {
      // userId looks numeric — try resolving via the public /u path. If
      // that fails (Discourse returns 404 for id-based lookups by
      // default), fall through and pass it as-is.
      try {
        final user = await apiGet('/u/by-external-or-id/$asInt.json',
                query: {'external': 'false'})
            .catchError((_) => <String, dynamic>{});
        final u = user['user'] as Map<String, dynamic>?;
        final name = u?['username']?.toString();
        if (name != null && name.isNotEmpty) username = name;
      } catch (_) {
        // Best-effort; fall back to the raw value.
      }
    }
    // Discourse user notification levels:
    //   0 = muted, 1 = normal, 2 = ignored
    // SDK contract: mode 1 = ignore, 0 = unignore.
    final level = mode == 1 ? 2 : 1;
    try {
      await apiPut('/u/${Uri.encodeComponent(username)}/notification_level.json',
          body: {'notification_level': level});
      return FCIgnoreUserResult(result: true, resultText: '');
    } on DiscourseApiException catch (e) {
      return FCIgnoreUserResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCIgnoreUserResult(result: false, resultText: 'Error: $e');
    }
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
    // Discourse handles passkeys inside its own login webview (which is
    // also the User API Key grant page). The mobile app doesn't issue
    // its own challenge — falling out of this method makes the caller
    // skip passkey UI and use the standard handshake. See
    // [loginWithPasskeyAsync] just below.
    return FCPasskeyChallengeResult(
      result: false,
      resultText:
          'Passkey login on Discourse is handled in the User API Key '
          'webview, not as a separate challenge.',
      challenge: null,
      rpId: null,
      timeout: null,
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
  Future<FCReportUserResult> reportUserAsync(
      String userId, String reason) async {
    // Discourse has no first-class "report user" REST endpoint for
    // non-staff: reports happen via flagging individual posts or PMs
    // (`POST /post_actions`). Staff users can silence or suspend a
    // user (`PUT /admin/users/{id}/{silence,suspend}.json`), but that's
    // a heavier action than what "report user" implies in the XF UI.
    //
    // For non-staff this returns a clear failure pointing the user at
    // post-level flagging. Staff use the moderation surface in
    // `DiscourseModerationProxy.markAsSpamAsync` / `banUserAsync`.
    try {
      // No-op REST round-trip; we deliberately don't escalate to
      // silence/suspend from a plain "report" intent. Phase 2.x could
      // route reasons here to a Discourse flag with type=spam against
      // the user's most recent post.
      return FCReportUserResult(
        result: false,
        resultText:
            'Reporting a user is done by flagging their posts on Discourse. '
            'Open one of their posts and use the flag action.',
      );
    } catch (e) {
      return FCReportUserResult(
        result: false,
        resultText: 'Error reporting user: $e',
      );
    }
  }

  // Phase 5.30 — `followUserAsync` / `unfollowUserAsync` deleted.
  // Follow/unfollow moved to `IFCSocialProxy.followAsync` /
  // `unfollowAsync` (with the real Discourse impl in
  // `DiscourseSocialProxy`). Callers should reach for the social
  // proxy via `SiteProxyFactory.getSocialProxy()` — `FCFollowResult`
  // / `FCUnfollowResult` give richer error surfacing than the
  // bool-returning sidecar did (e.g. "requires the discourse-follow
  // plugin" vs. a silent false).

  @override
  Future<FCBadgeResult> getUserBadgesAsync(String username) async {
    if (username.isEmpty) {
      return FCBadgeResult(result: false, resultText: 'username required');
    }
    try {
      final response = await apiGet(
          '/user-badges/${Uri.encodeComponent(username)}.json');
      final defs = <int, Map<String, dynamic>>{};
      for (final raw in ((response['badges'] as List?) ?? const [])
          .whereType<Map>()) {
        final d = raw.cast<String, dynamic>();
        final id = d['id'];
        if (id is int) defs[id] = d;
      }
      final out = <FCBadge>[];
      // Discourse may return user_badges or user_badge_info — we accept
      // both shapes. The list is the per-user grants (one entry per
      // grant, so duplicates exist for stackable badges). First wins
      // for newest-first if Discourse returns them in granted order.
      final grants = ((response['user_badges'] as List?) ?? const [])
          .whereType<Map>()
          .toList();
      final seen = <int>{};
      for (final raw in grants) {
        final g = raw.cast<String, dynamic>();
        final badgeId = (g['badge_id'] as num?)?.toInt();
        if (badgeId == null || !seen.add(badgeId)) continue;
        final def = defs[badgeId];
        if (def == null) continue;
        out.add(_badgeFromJson(definition: def, grant: g));
      }
      return FCBadgeResult(result: true, badges: out);
    } on DiscourseApiException catch (e) {
      return FCBadgeResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCBadgeResult(result: false, resultText: 'Error: $e');
    }
  }
}
