import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_group_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_directory_item.dart';
import 'package:forumcopilot_sdk/models/entities/fc_group.dart';
import 'package:forumcopilot_sdk/models/results/fc_group_result.dart';

import '../base_discourse_proxy.dart';
import '../util/html_text.dart';

/// Discourse implementation of [IFCGroupProxy] (Phase 5.40 — lifted
/// off the old `forCurrentSite()` sidecar, which is now gone; Phase 5.44
/// adds membership actions). Reach this through
/// `SiteProxyService.getGroupProxy()`.
///
/// Endpoints used:
///   * `GET    /groups.json`                       — paginated directory
///   * `GET    /groups/{name}.json`                — single-group details
///   * `GET    /groups/{name}/members.json`        — paginated members
///   * `PUT    /groups/{id}/join.json`             — self-join
///   * `DELETE /groups/{id}/leave.json`            — self-leave
///   * `POST   /groups/{name}/request_membership.json` — request to join
class DiscourseGroupProxy extends BaseDiscourseProxy implements IFCGroupProxy {
  DiscourseGroupProxy(SiteContext context) : super(context);

  @override
  Future<FCGroupListResult> getGroupsAsync({int page = 1}) async {
    try {
      final response = await apiGet('/groups.json', query: {
        if (page > 1) 'page': page.toString(),
      });
      final raw = (response['groups'] as List?) ?? const [];
      final groups = raw
          .whereType<Map>()
          .map((g) => _groupFromJson(g.cast<String, dynamic>()))
          .toList(growable: false);
      // `GroupsController#index` returns the real grand total in
      // `total_rows_groups` (groups_controller.rb:111) and a next-page
      // URL in `load_more_groups` (groups_controller.rb:112). Populate
      // `total` from total_rows_groups (authoritative, not page length).
      //
      // `load_more_groups` is emitted UNCONDITIONALLY (always a
      // groups_path string), so its presence alone can't mean "more" —
      // Discourse's own client loads it and stops when a page comes back
      // empty. Derive hasMore precisely from the authoritative total
      // instead: there is more when the total exceeds what we've paged
      // through so far. `page` is 1-based here; the server pages 0-based
      // at 36/page (15 on mobile UAs — we send a desktop UA).
      final total = (response['total_rows_groups'] as num?)?.toInt() ?? 0;
      const pageSize = 36;
      final loadedThrough = page * pageSize;
      final hasMore = groups.isNotEmpty && total > loadedThrough;
      return FCGroupListResult(
        result: true,
        groups: groups,
        total: total,
        hasMore: hasMore,
      );
    } on DiscourseApiException catch (e) {
      return FCGroupListResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCGroupListResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCGroupResult> getGroupAsync(String name) async {
    try {
      final response =
          await apiGet('/groups/${Uri.encodeComponent(name)}.json');
      final raw = (response['group'] as Map?)?.cast<String, dynamic>();
      if (raw == null) return FCGroupResult(result: true);
      return FCGroupResult(result: true, group: _groupFromJson(raw));
    } on DiscourseApiException catch (e) {
      return FCGroupResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCGroupResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCGroupMembersResult> getGroupMembersAsync(
    String name, {
    int offset = 0,
    int limit = 50,
  }) async {
    try {
      final response = await apiGet(
        '/groups/${Uri.encodeComponent(name)}/members.json',
        query: {
          if (offset > 0) 'offset': offset.toString(),
          'limit': limit.toString(),
        },
      );
      // Discourse returns `members: [...]` plus `owners: [...]` for
      // group admins — and `members` already INCLUDES the owners, so a
      // plain concat duplicates every owner row. Dedupe by user id while
      // iterating owners first, which keeps owners at the top (their
      // owner entry wins over the duplicate member entry).
      final members = <FCDirectoryItem>[];
      final seenIds = <int>{};
      for (final key in const ['owners', 'members']) {
        final list = (response[key] as List?) ?? const [];
        for (final raw in list.whereType<Map>()) {
          final user = raw.cast<String, dynamic>();
          // Skip rows with no usable id instead of minting user 0 — a
          // fabricated id 0 renders as a real member row whose profile
          // link goes nowhere, and several of them can appear at once
          // because they can't be deduped.
          final id = (user['id'] as num?)?.toInt();
          if (id == null || !seenIds.add(id)) continue;
          String avatarUrl = '';
          final tpl = user['avatar_template'] as String?;
          if (tpl != null && tpl.isNotEmpty) {
            final filled = tpl.replaceAll('{size}', '90');
            avatarUrl = filled.startsWith('http')
                ? filled
                : '${siteContext.site.url}$filled';
          }
          members.add(FCDirectoryItem(
            id: id,
            username: (user['username'] ?? '').toString(),
            name: (user['name'] as String?)?.trim().isNotEmpty == true
                ? user['name'] as String
                : null,
            avatarUrl: avatarUrl,
            trustLevel: (user['trust_level'] as num?)?.toInt(),
          ));
        }
      }
      // `GroupsController#members` returns the real member count in
      // `meta.total` (groups_controller.rb:94). Populate `total` from it
      // rather than guessing from `members.length` (which is one page,
      // and further shrinks after owner dedupe above).
      final meta = (response['meta'] as Map?)?.cast<String, dynamic>();
      final total = (meta?['total'] as num?)?.toInt() ?? 0;
      return FCGroupMembersResult(
        result: true,
        members: members,
        total: total,
      );
    } on DiscourseApiException catch (e) {
      return FCGroupMembersResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCGroupMembersResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCGroupMembershipResult> joinGroupAsync(int groupId) async {
    if (!siteContext.isLoggedIn) {
      return FCGroupMembershipResult(
          result: false, resultText: 'Not signed in');
    }
    try {
      await apiPut('/groups/$groupId/join.json');
      return FCGroupMembershipResult(result: true, isMember: true);
    } on DiscourseApiException catch (e) {
      return FCGroupMembershipResult(
          result: false, resultText: e.userMessage);
    } catch (e) {
      return FCGroupMembershipResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCGroupMembershipResult> leaveGroupAsync(int groupId) async {
    if (!siteContext.isLoggedIn) {
      return FCGroupMembershipResult(
          result: false, resultText: 'Not signed in');
    }
    try {
      await apiDelete('/groups/$groupId/leave.json');
      return FCGroupMembershipResult(result: true, isMember: false);
    } on DiscourseApiException catch (e) {
      return FCGroupMembershipResult(
          result: false, resultText: e.userMessage);
    } catch (e) {
      return FCGroupMembershipResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCGroupMembershipResult> requestMembershipAsync(
    String groupName,
    String reason,
  ) async {
    if (!siteContext.isLoggedIn) {
      return FCGroupMembershipResult(
          result: false, resultText: 'Not signed in');
    }
    if (reason.trim().isEmpty) {
      return FCGroupMembershipResult(
          result: false, resultText: 'A reason is required');
    }
    try {
      // Discourse renders "already requested" as HTTP 200 with
      // success:false + error — surface that text rather than
      // treating it as a granted request.
      final response = await apiPost(
        '/groups/${Uri.encodeComponent(groupName)}/request_membership.json',
        body: {'reason': reason.trim()},
      );
      final error = response['error']?.toString();
      if (error != null && error.isNotEmpty) {
        return FCGroupMembershipResult(result: false, resultText: error);
      }
      return FCGroupMembershipResult(result: true, requestPending: true);
    } on DiscourseApiException catch (e) {
      return FCGroupMembershipResult(
          result: false, resultText: e.userMessage);
    } catch (e) {
      return FCGroupMembershipResult(result: false, resultText: 'Error: $e');
    }
  }

  /// Group bio, flattened to plain text. `bio_raw` (markdown) reads
  /// fine as-is; the cooked/excerpt fallbacks are HTML and need
  /// stripping.
  static String? _plainBio(Map<String, dynamic> json) {
    final raw = json['bio_raw']?.toString();
    if (raw != null && raw.trim().isNotEmpty) return raw;
    final cooked =
        (json['bio_cooked'] ?? json['bio_excerpt'])?.toString();
    if (cooked == null || cooked.trim().isEmpty) return null;
    final text = stripHtmlToText(cooked);
    return text.isEmpty ? null : text;
  }

  FCGroup _groupFromJson(Map<String, dynamic> json) {
    return FCGroup(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      fullName: (json['full_name'] as String?)?.trim().isNotEmpty == true
          ? json['full_name'] as String
          : null,
      // bio_cooked / bio_excerpt arrive as HTML fragments; flatten to
      // plain text because the UI renders the bio in a Text widget
      // (Phase 5.46 — literal <p> tags were showing on group pages).
      bio: _plainBio(json),
      memberCount: (json['user_count'] as num?)?.toInt() ?? 0,
      automatic: (json['automatic'] as bool?) ?? false,
      // `BasicGroupSerializer` has no `visible` attribute — it emits
      // `visibility_level` (app/serializers/basic_group_serializer.rb:10),
      // an enum from app/models/group.rb:143
      // (public:0, logged_on_users:1, members:2, staff:3, owners:4).
      // Reading a key the server never sends meant EVERY group came back
      // `visible: true`. "Visible" for our purposes = listed to the
      // viewer without being a members/staff-only group. If the field is
      // genuinely absent we fall back to true, because the server only
      // returns groups the viewer is allowed to see anyway.
      visible: switch ((json['visibility_level'] as num?)?.toInt()) {
        null => true,
        0 || 1 => true,
        _ => false,
      },
      publicAdmission: (json['public_admission'] as bool?) ?? false,
      publicExit: (json['public_exit'] as bool?) ?? false,
      allowMembershipRequests:
          (json['allow_membership_requests'] as bool?) ?? false,
      isMember: (json['is_group_user'] as bool?) ?? false,
      isOwner: (json['is_group_owner'] as bool?) ?? false,
      mentionableLevel: (json['mentionable_level'] as num?)?.toInt(),
      messageableLevel: (json['messageable_level'] as num?)?.toInt(),
      flairColor: (json['flair_color'] as String?)?.trim().isNotEmpty == true
          ? json['flair_color'] as String
          : null,
      flairBgColor:
          (json['flair_bg_color'] as String?)?.trim().isNotEmpty == true
              ? json['flair_bg_color'] as String
              : null,
      flairUrl: (json['flair_url'] as String?)?.trim().isNotEmpty == true
          ? json['flair_url'] as String
          : null,
    );
  }
}
