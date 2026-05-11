import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_group_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_directory_item.dart';
import 'package:forumcopilot_sdk/models/entities/fc_group.dart';
import 'package:forumcopilot_sdk/models/results/fc_group_result.dart';

import '../base_discourse_proxy.dart';

/// Discourse implementation of [IFCGroupProxy] (Phase 5.40 — lifted
/// off the `DiscourseGroupProxy.forCurrentSite()` sidecar).
///
/// Endpoints used:
///   * `GET /groups.json`                       — paginated directory
///   * `GET /groups/{name}.json`                — single-group details
///   * `GET /groups/{name}/members.json`        — paginated members
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
      allowMembershipRequests:
          (json['allow_membership_requests'] as bool?) ?? false,
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
