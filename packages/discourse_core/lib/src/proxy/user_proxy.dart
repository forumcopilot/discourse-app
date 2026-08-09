import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_user_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_badge.dart';
import 'package:forumcopilot_sdk/models/entities/fc_directory_item.dart';
import 'package:forumcopilot_sdk/models/entities/fc_user.dart';
import 'package:forumcopilot_sdk/models/results/fc_directory_result.dart';
import 'package:forumcopilot_sdk/models/results/fc_passkey_result.dart';
import 'package:forumcopilot_sdk/models/results/fc_private_conversation_result.dart';
import 'package:forumcopilot_sdk/models/results/fc_user_result.dart';
import '../base_discourse_proxy.dart';
import '../context/discourse_site_context_extension.dart';
import '../data/user/discourse_do_not_disturb.dart';
import '../data/user/discourse_user_summary.dart';
import '../util/html_text.dart';

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
      // `ignored_usernames` is a bare array of usernames on the user
      // preferences payload — Discourse attaches no user ids to it, so
      // the id stays empty rather than being faked. Every ignore/unignore
      // route is keyed by username anyway.
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
        resultText: describeApiError(e),
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
    // total count of unread notifications (Discourse doesn't expose a
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
      // Use the non-recent listing: `recent=true` caps at 15 rows and
      // omits `total_rows_notifications`, undercounting unread badges.
      // The plain listing returns up to 60 rows (INDEX_LIMIT in
      // notifications_controller.rb) plus the grand total, and doesn't
      // bump the server-side "seen" watermark as a side effect.
      // `filter=unread` makes every returned row (and the total) an
      // unread notification, so the counts stay accurate even when many
      // read notifications sit on top of the feed.
      final response = await apiGet('/notifications.json', query: {
        'limit': '60',
        'filter': 'unread',
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
        resultText: describeApiError(e),
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
        resultText: 'Error getting online users: ${describeApiError(e)}',
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
      // Server-side `page` is 0-based (directory_items_controller.rb
      // offsets by limit * page), while this method's [page] is
      // 1-indexed — translate here.
      final response = await apiGet('/directory_items.json', query: {
        'period': period,
        'order': order,
        if (page > 1) 'page': (page - 1).toString(),
      });
      final raw = ((response['directory_items'] as List?) ?? const [])
          .whereType<Map>()
          .map((d) => d.cast<String, dynamic>())
          .toList();
      final items = raw
          .map((j) => _directoryItemFromJson(j))
          .toList(growable: false);
      // `total_rows_directory_items` lives under `meta:` in the
      // response, not at the top level.
      final meta = (response['meta'] as Map<String, dynamic>?) ?? const {};
      final total = (meta['total_rows_directory_items'] as num?)?.toInt() ??
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
        resultText: describeApiError(e),
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
      return FCBadgeResult(result: false, resultText: describeApiError(e));
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
      // Badge descriptions ship as cooked HTML (e.g. the "Member"
      // badge embeds an <a href>); flatten for the Text-widget renders
      // on the badges page (Phase 5.46).
      description: definition['description'] == null
          ? null
          : stripHtmlToText(definition['description'].toString()),
      icon: definition['icon']?.toString(),
      imageUrl: definition['image_url']?.toString(),
      badgeTypeId: (definition['badge_type_id'] as num?)?.toInt() ?? 1,
      grantedAt: DateTime.tryParse(grant?['granted_at']?.toString() ?? ''),
      // With a grant, count is the user's own stack count (grouped
      // user-badges). Catalog rows (no grant) reuse the field for the
      // definition's forum-wide `grant_count` — the badges directory
      // ranks and labels by it ("Earned by N users").
      grantCount: grant != null
          ? (grant['count'] as num?)?.toInt() ?? 1
          : (definition['grant_count'] as num?)?.toInt() ?? 1,
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

      // Discourse publishes NO presence flag on UserSerializer — there is
      // no `is_online`. This is a client-side inference from the real
      // `last_seen_at` timestamp against a 5-minute window (the same
      // convention Discourse's own "seen recently" copy uses). It is a
      // heuristic, not something the server asserted.
      final lastSeenAt = parseTs(user['last_seen_at']);
      final fiveMinAgo = DateTime.now().subtract(const Duration(minutes: 5));
      final isOnline = lastSeenAt != null && lastSeenAt.isAfter(fiveMinAgo);

      // Moderation affordances. The user JSON carries no can_suspend /
      // can_silence flags, so mirror the server's guardian rules
      // (lib/guardian.rb#can_suspend?, user_guardian.rb#can_silence_user?):
      // viewer must be staff and the target must not be staff. Both
      // actions are wired through DiscourseModerationProxy
      // (/admin/users/{id}/suspend|silence.json), which moderators can
      // call, so lighting the menu up for staff is honest.
      final viewerIsStaff =
          siteContext.loginDataOutput?.user?.canModerate == true;
      final targetIsStaff =
          user['admin'] == true || user['moderator'] == true;
      final targetUsername = (user['username'] ?? '').toString();
      final isSelf = targetUsername.toLowerCase() ==
          (siteContext.currentUsername ?? '').toLowerCase();
      final canModerateTarget = viewerIsStaff && !targetIsStaff && !isSelf;

      // `post_count` on UserSerializer is a staff-only attribute, so for
      // non-staff viewers it is simply absent and profiles would show 0.
      // When missing, fall back to /u/{username}/summary.json, whose
      // `post_count` (user_summary_serializer.rb) is visible to anyone
      // who can see the profile's summary stats. One extra request, only
      // when needed.
      var postCount = user['post_count'] as int?;
      if (postCount == null) {
        try {
          final summary = await apiGet(
              '/u/${Uri.encodeComponent(username)}/summary.json');
          final userSummary =
              (summary['user_summary'] as Map<String, dynamic>?) ?? const {};
          postCount = (userSummary['post_count'] as num?)?.toInt();
        } catch (_) {
          // Best-effort; keep the profile usable without a post count.
        }
      }

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
        postCount: postCount ?? 0,
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
        // Only report true when the follow plugin actually surfaced the
        // field — on stock Discourse `can_follow` is absent and
        // `!= false` would falsely light up the follow UI.
        acceptsFollowers: user['can_follow'] == true,
        followingCount: (user['total_following'] as int?) ?? 0,
        followerCount: (user['total_followers'] as int?) ?? 0,
        canBan: canModerateTarget,
        // The serializer has no `suspended` boolean — it includes
        // `suspended_till` (and `suspend_reason`) only while the
        // suspension is active (user_card_serializer.rb
        // include_suspended_till? => object.suspended?), so presence of
        // the key IS the suspended signal.
        isBanned: user['suspended_till'] != null,
        isIgnored: user['ignored'] == true,
        // `can_ignore_user` (user_card_serializer.rb, inherited by
        // UserSerializer) is the per-target guardian check
        // `scope.can_ignore_user?(object)` — false for guests, self,
        // and staff targets. Gates the Ignore/Unignore menu item.
        canIgnore: user['can_ignore_user'] == true,
        canSpamClean: canModerateTarget,
        // Discourse has no per-user report action (reportUserAsync
        // intentionally returns guidance to flag posts instead), so
        // don't advertise one. Post-level flagging stays fully wired.
        canBeReported: false,
        userGroups: groups,
        customFields: customFields,
        canModerate: user['moderator'] == true,
        // Profile density web shows and the app did not: view count, badge
        // count, and — importantly — the server's own answer to whether
        // this viewer may chat with this person. That is a different
        // question from whether chat is installed, which is all the app
        // could previously infer.
        profileViewCount: (user['profile_view_count'] as int?) ?? 0,
        canChatUser: user['can_chat_user'] == true,
        badgeCount: (user['badge_count'] as int?) ?? 0,
        canSearch: false,
        currentActivity: null,
        currentTopicId: null,
        displayText: user['name']?.toString(),
        email: null,
        location: user['location']?.toString(),
        website: user['website_name']?.toString() ?? user['website']?.toString(),
        signature: null,
        // Prefer the full markdown bio; the cooked/excerpt fallbacks
        // are HTML fragments that need flattening (Phase 5.47 —
        // matches the group-bio treatment).
        bio: (user['bio_raw']?.toString().trim().isNotEmpty == true)
            ? user['bio_raw'].toString()
            : ((user['bio_cooked'] ?? user['bio_excerpt']) == null
                ? null
                : stripHtmlToText(
                    (user['bio_cooked'] ?? user['bio_excerpt'])
                        .toString())),
        trustLevel: user['trust_level'] as int?,
      );
    } catch (e) {
      return FCUserInfoResult(
        result: false,
        resultText: 'Error getting user info: ${describeApiError(e)}',
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
          // UserActionSerializer emits `category_id` but no category
          // name, and /user_actions.json side-loads categories only when
          // `can_lazy_load_categories` is on. Left empty, not invented.
          forumName: '',
          authorId: (a['user_id'] ?? '').toString(),
          authorName: (a['username'] ?? '').toString(),
          authorIconUrl: avatarUrl,
          postTime: DateTime.tryParse(a['created_at']?.toString() ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
          replyNumber: (a['post_number'] as int?) ?? 0,
          postContent: a['excerpt']?.toString(),
          shortContent: a['excerpt']?.toString(),
        );
      }).toList();
      return FCUserReplyResult(
        result: true,
        resultText: '',
        // Page length, not a grand total — UserActionsController#index
        // returns no count (app/controllers/user_actions_controller.rb:35-43).
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
        resultText: describeApiError(e),
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
          // See getUserReplyAsync: no category name in this payload.
          forumName: '',
          authorId: (a['user_id'] ?? '').toString(),
          authorName: (a['username'] ?? '').toString(),
          postTime:
              DateTime.tryParse(a['created_at']?.toString() ?? '') ??
                  DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
          shortContent: a['excerpt']?.toString(),
        ));
      }
      return FCUserTopicResult(
        result: true,
        resultText: '',
        // Page length after topic-dedupe, not a grand total — see
        // getUserReplyAsync.
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
        resultText: describeApiError(e),
        total: 0,
        list: const [],
      );
    }
  }

  @override
  Future<FCIgnoreUserResult> ignoreUserAsync(String userId, int mode) async {
    // The SDK contract calls this `userId`, but Discourse's
    // notification-level endpoint is keyed by username and every caller
    // (ignored_users_page, user_profile_page) passes a username. There is
    // no public Discourse route that resolves a numeric user id to a
    // username, so the value is used as a username verbatim — a stale
    // numeric id simply 404s into a clean failure result.
    final username = userId;
    // Discourse matches `notification_level` as the strings
    // "ignore" / "mute" / "normal" (app/controllers/users_controller.rb,
    // users#notification_level). SDK contract: mode 1 = ignore,
    // 0 = unignore.
    //
    // "ignore" additionally REQUIRES `expiring_at` (the server
    // Time.parse()s it unconditionally). The SDK interface has no
    // duration parameter, so mirror the longest option Discourse's own
    // UI offers: 4 months from now.
    final body = <String, dynamic>{
      'notification_level': mode == 1 ? 'ignore' : 'normal',
      if (mode == 1)
        'expiring_at': DateTime.now()
            .add(const Duration(days: 120))
            .toUtc()
            .toIso8601String(),
    };
    try {
      await apiPut('/u/${Uri.encodeComponent(username)}/notification_level.json',
          body: body);
      return FCIgnoreUserResult(result: true, resultText: '');
    } on DiscourseApiException catch (e) {
      return FCIgnoreUserResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCIgnoreUserResult(result: false, resultText: describeApiError(e));
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

  /// Discourse 2FA happens inside the User API Key handshake webview
  /// (same as passkeys) — there is no separate two-step endpoint for the
  /// app to call. Soft-fail like the sibling login stubs instead of
  /// throwing.
  @override
  Future<FCLoginTwoStepResult> loginTwoStepAsync(
      String codeTwoStep, bool trust) async {
    return FCLoginTwoStepResult(
      result: false,
      resultText:
          'Discourse two-factor auth happens inside the User API Key '
          'handshake webview. See DiscourseAuthManager.beginHandshake.',
      id: '',
      username: '',
    );
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
        // Discourse messages can be addressed to a group, not just to people —
        // `target_recipients` on POST /posts.json accepts group names alongside
        // usernames. This was 'false', so messaging a group was impossible from
        // the app even though the platform supports it.
        'include_groups': 'true',
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
          // The user-search payload carries only id/username/name/
          // avatar_template. postCount 0 / isOnline false are NOT
          // reported values — they are the non-nullable fields' neutral
          // state, and the row is not a claim that this user has zero
          // posts. Fetch the profile for real numbers.
          postCount: 0,
          registrationTime: null,
          isOnline: false,
        );
      }).toList();

      // Groups come back in their own array. They address a message exactly like
      // a username does, so they join the same recipient list rather than needing
      // a parallel one — FCSearchUser.username carries the group name, which is
      // what target_recipients expects. `id` is prefixed so a group can never
      // collide with a user id in a picker keyed on it.
      final groups = (response['groups'] as List?) ?? const [];
      list.addAll(groups.whereType<Map>().map((g) {
        final m = g.cast<String, dynamic>();
        final name = (m['name'] ?? '').toString();
        return FCSearchUser(
          id: 'group:${m['id'] ?? name}',
          username: name,
          // Lets a picker tell a group apart from a person without a new model
          // field — FCSearchUser already carries userType.
          userType: 'group',
          // full_name is the human label ("Site Moderators"); fall back to the
          // handle when a group has none set.
          displayText: (m['full_name'] as String?)?.isNotEmpty == true
              ? m['full_name'] as String
              : name,
          iconUrl: null,
          postCount: 0,
          registrationTime: null,
          isOnline: false,
        );
      }).where((g) => g.username.isNotEmpty));

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
        resultText: describeApiError(e),
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
        resultText: 'Error reporting user: ${describeApiError(e)}',
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
      return FCBadgeResult(result: false, resultText: describeApiError(e));
    }
  }

  // ===== Discourse-native surface (no IFC interface methods) =====

  /// Starts a do-not-disturb window for the current user.
  ///
  /// `POST /do-not-disturb.json` (do_not_disturb_controller.rb#create).
  /// [duration] is either a number of minutes as a string (e.g. `'30'`,
  /// `'60'`) or the literal `'tomorrow'` (until end of day UTC) — any
  /// other value is a 400 InvalidParameters. The response carries the
  /// window's `ends_at`, surfaced on the result.
  Future<DiscourseDoNotDisturbResult> enterDoNotDisturbAsync(
      String duration) async {
    if (!siteContext.isLoggedIn) {
      return DiscourseDoNotDisturbResult(
          result: false, resultText: 'Not signed in');
    }
    try {
      final response =
          await apiPost('/do-not-disturb.json', body: {'duration': duration});
      return DiscourseDoNotDisturbResult(
        result: true,
        endsAt: DateTime.tryParse((response['ends_at'] ?? '').toString()),
      );
    } on DiscourseApiException catch (e) {
      return DiscourseDoNotDisturbResult(
          result: false, resultText: e.userMessage);
    } catch (e) {
      return DiscourseDoNotDisturbResult(
          result: false, resultText: describeApiError(e));
    }
  }

  /// Ends any active do-not-disturb window (and releases shelved
  /// notifications server-side).
  ///
  /// `DELETE /do-not-disturb.json` (do_not_disturb_controller.rb#destroy).
  Future<DiscourseDoNotDisturbResult> leaveDoNotDisturbAsync() async {
    if (!siteContext.isLoggedIn) {
      return DiscourseDoNotDisturbResult(
          result: false, resultText: 'Not signed in');
    }
    try {
      await apiDelete('/do-not-disturb.json');
      return DiscourseDoNotDisturbResult(result: true);
    } on DiscourseApiException catch (e) {
      return DiscourseDoNotDisturbResult(
          result: false, resultText: e.userMessage);
    } catch (e) {
      return DiscourseDoNotDisturbResult(
          result: false, resultText: describeApiError(e));
    }
  }

  /// Reads the current do-not-disturb state.
  ///
  /// Discourse has no dedicated status endpoint — the DND deadline is
  /// only serialized as `do_not_disturb_until` on the current-user
  /// payload (current_user_serializer.rb), so this helper fetches
  /// `GET /session/current.json` and reads it from there. Callers that
  /// already hold a fresh `/session/current.json` payload should read
  /// `current_user.do_not_disturb_until` directly instead of paying for
  /// this extra request.
  Future<DiscourseDoNotDisturbResult> getDoNotDisturbStatusAsync() async {
    if (!siteContext.isLoggedIn) {
      return DiscourseDoNotDisturbResult(
          result: false, resultText: 'Not signed in');
    }
    try {
      final response = await apiGet('/session/current.json');
      final user =
          (response['current_user'] as Map?)?.cast<String, dynamic>() ??
              const {};
      return DiscourseDoNotDisturbResult(
        result: true,
        endsAt: DateTime.tryParse(
            (user['do_not_disturb_until'] ?? '').toString()),
      );
    } on DiscourseApiException catch (e) {
      return DiscourseDoNotDisturbResult(
          result: false, resultText: e.userMessage);
    } catch (e) {
      return DiscourseDoNotDisturbResult(
          result: false, resultText: describeApiError(e));
    }
  }

  /// Fetches the profile-summary stats block for [username].
  ///
  /// `GET /u/{username}/summary.json` (users_controller.rb#summary,
  /// user_summary_serializer.rb). Numeric stats are omitted by the
  /// server when the viewer lacks `can_see_summary_stats` (they come
  /// back as 0 with `canSeeSummaryStats` false); the top-topics list is
  /// resolved from `user_summary.topic_ids` against the side-loaded
  /// top-level `topics` array, which reply/link rows also reference by
  /// `topic_id`.
  Future<DiscourseUserSummaryResult> getUserSummaryAsync(
      String username) async {
    if (username.isEmpty) {
      return DiscourseUserSummaryResult(
          result: false, resultText: 'username required');
    }
    try {
      final response =
          await apiGet('/u/${Uri.encodeComponent(username)}/summary.json');
      final summary =
          (response['user_summary'] as Map?)?.cast<String, dynamic>() ??
              const {};

      // Side-loaded topic rows, keyed by id, shared by top-topics,
      // replies and links.
      final topicsById = <int, DiscourseSummaryTopic>{};
      for (final raw
          in ((response['topics'] as List?) ?? const []).whereType<Map>()) {
        final t = raw.cast<String, dynamic>();
        final id = (t['id'] as num?)?.toInt();
        if (id == null) continue;
        topicsById[id] = DiscourseSummaryTopic(
          id: id,
          title: stripHtmlToText(
              (t['fancy_title'] ?? t['title'] ?? '').toString()),
          slug: t['slug']?.toString(),
          categoryId: (t['category_id'] as num?)?.toInt(),
          likeCount: (t['like_count'] as num?)?.toInt() ?? 0,
          postsCount: (t['posts_count'] as num?)?.toInt(),
          createdAt: DateTime.tryParse(t['created_at']?.toString() ?? ''),
        );
      }

      int stat(String key) => (summary[key] as num?)?.toInt() ?? 0;

      List<DiscourseSummaryUser> users(String key) =>
          ((summary[key] as List?) ?? const [])
              .whereType<Map>()
              .map((raw) {
                final u = raw.cast<String, dynamic>();
                return DiscourseSummaryUser(
                  id: (u['id'] as num?)?.toInt() ?? 0,
                  username: (u['username'] ?? '').toString(),
                  name: u['name']?.toString(),
                  count: (u['count'] as num?)?.toInt() ?? 0,
                  avatarUrl:
                      _resolveAvatar(u['avatar_template'] as String?, 90),
                  admin: u['admin'] == true,
                  moderator: u['moderator'] == true,
                  trustLevel: (u['trust_level'] as num?)?.toInt(),
                );
              })
              .toList(growable: false);

      final topTopics = ((summary['topic_ids'] as List?) ?? const [])
          .whereType<num>()
          .map((id) => topicsById[id.toInt()])
          .whereType<DiscourseSummaryTopic>()
          .toList(growable: false);

      final topReplies = ((summary['replies'] as List?) ?? const [])
          .whereType<Map>()
          .map((raw) {
            final r = raw.cast<String, dynamic>();
            final topicId = (r['topic_id'] as num?)?.toInt() ?? 0;
            final topic = topicsById[topicId];
            return DiscourseSummaryReply(
              topicId: topicId,
              topicTitle: topic?.title ?? '',
              topicSlug: topic?.slug,
              postNumber: (r['post_number'] as num?)?.toInt() ?? 0,
              likeCount: (r['like_count'] as num?)?.toInt() ?? 0,
              createdAt: DateTime.tryParse(r['created_at']?.toString() ?? ''),
            );
          })
          .toList(growable: false);

      final topLinks = ((summary['links'] as List?) ?? const [])
          .whereType<Map>()
          .map((raw) {
            final l = raw.cast<String, dynamic>();
            final topicId = (l['topic_id'] as num?)?.toInt();
            return DiscourseSummaryLink(
              url: (l['url'] ?? '').toString(),
              title: stripHtmlToText((l['title'] ?? '').toString()),
              clicks: (l['clicks'] as num?)?.toInt() ?? 0,
              topicId: topicId,
              topicTitle: topicId == null ? null : topicsById[topicId]?.title,
              postNumber: (l['post_number'] as num?)?.toInt(),
            );
          })
          .toList(growable: false);

      return DiscourseUserSummaryResult(
        result: true,
        summary: DiscourseUserSummary(
          likesGiven: stat('likes_given'),
          likesReceived: stat('likes_received'),
          daysVisited: stat('days_visited'),
          topicsEntered: stat('topics_entered'),
          postsReadCount: stat('posts_read_count'),
          postCount: stat('post_count'),
          topicCount: stat('topic_count'),
          timeRead: stat('time_read'),
          recentTimeRead: stat('recent_time_read'),
          bookmarkCount: (summary['bookmark_count'] as num?)?.toInt(),
          canSeeSummaryStats: summary['can_see_summary_stats'] == true,
          badgeCount: ((summary['badges'] as List?) ?? const []).length,
          topTopics: topTopics,
          topReplies: topReplies,
          topLinks: topLinks,
          mostLikedByUsers: users('most_liked_by_users'),
          mostLikedUsers: users('most_liked_users'),
          mostRepliedToUsers: users('most_replied_to_users'),
        ),
      );
    } on DiscourseApiException catch (e) {
      return DiscourseUserSummaryResult(
          result: false, resultText: e.userMessage);
    } catch (e) {
      return DiscourseUserSummaryResult(
          result: false, resultText: describeApiError(e));
    }
  }

  String _resolveAvatar(String? tpl, int size) {
    if (tpl == null || tpl.isEmpty) return '';
    final filled = tpl.replaceAll('{size}', size.toString());
    return filled.startsWith('http')
        ? filled
        : '${siteContext.site.url}$filled';
  }

  @override
  Future<FCRecommendedUserResult> getRecommendedUsersAsync(
          int page, int perpage, int mode) async =>
      // Discourse has no "recommended users for messaging" concept; the
      // PM recipient picker uses username typeahead instead.
      FCRecommendedUserResult(
          result: false,
          resultText: 'Recommended users are not supported on Discourse');
}
