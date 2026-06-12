import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_group_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_directory_item.dart';
import 'package:forumcopilot_sdk/models/entities/fc_group.dart';
import 'package:forumcopilot_sdk/models/results/fc_group_result.dart';

import '../base_discourse_proxy.dart';

/// Discourse implementation of [IFCGroupProxy] (Phase 5.40 — lifted
/// off the `DiscourseGroupProxy.forCurrentSite()` sidecar; Phase 5.44
/// adds membership actions).
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

  /// Convenience accessor used during the transition from the old
  /// `forCurrentSite()` pattern. New callers should reach the proxy
  /// via `SiteProxyService.getGroupProxy()`.
  static DiscourseGroupProxy? forCurrentSite() {
    final ctx = SiteProxyFactory.context;
    if (ctx == null) return null;
    return DiscourseGroupProxy(ctx);
  }

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
      return FCGroupListResult(result: true, groups: groups);
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
      // group admins. Merge both — owners appear at the top as
      // returned.
      final members = <FCDirectoryItem>[];
      for (final key in const ['owners', 'members']) {
        final list = (response[key] as List?) ?? const [];
        for (final raw in list.whereType<Map>()) {
          final user = raw.cast<String, dynamic>();
          String avatarUrl = '';
          final tpl = user['avatar_template'] as String?;
          if (tpl != null && tpl.isNotEmpty) {
            final filled = tpl.replaceAll('{size}', '90');
            avatarUrl = filled.startsWith('http')
                ? filled
                : '${siteContext.site.url}$filled';
          }
          members.add(FCDirectoryItem(
            id: (user['id'] as num?)?.toInt() ?? 0,
            username: (user['username'] ?? '').toString(),
            name: (user['name'] as String?)?.trim().isNotEmpty == true
                ? user['name'] as String
                : null,
            avatarUrl: avatarUrl,
            trustLevel: (user['trust_level'] as num?)?.toInt(),
          ));
        }
      }
      return FCGroupMembersResult(result: true, members: members);
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

  FCGroup _groupFromJson(Map<String, dynamic> json) {
    return FCGroup(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      fullName: (json['full_name'] as String?)?.trim().isNotEmpty == true
          ? json['full_name'] as String
          : null,
      bio: (json['bio_raw'] ?? json['bio_cooked'] ?? json['bio_excerpt'])
          ?.toString(),
      memberCount: (json['user_count'] as num?)?.toInt() ?? 0,
      automatic: (json['automatic'] as bool?) ?? false,
      visible: (json['visible'] as bool?) ?? true,
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
