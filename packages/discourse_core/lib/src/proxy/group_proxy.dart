import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/models/entities/fc_directory_item.dart';

import '../base_discourse_proxy.dart';
import '../data/group/discourse_group.dart';

/// Discourse-only proxy for the Groups API.
///
/// Phase 5.18c-2 surfaces three endpoints:
/// - `GET /groups.json` — paginated directory of all visible groups.
/// - `GET /groups/{name}.json` — single-group metadata (bio, flair,
///   membership policy).
/// - `GET /groups/{name}/members.json` — paginated member listing.
///
/// Following the same pattern as `DiscourseChatProxy`: not part of
/// the typed `IFC*Proxy` registry (groups are a Discourse-native
/// concept the XF-shaped SDK doesn't model), so callers reach us
/// via a static `forCurrentSite()` factory.
class DiscourseGroupProxy extends BaseDiscourseProxy {
  DiscourseGroupProxy(SiteContext context) : super(context);

  /// Convenience accessor: returns a proxy bound to the current site
  /// context, or null when no site is initialised. Mirrors
  /// `DiscourseChatProxy.forCurrentSite` so Discourse-only callsites
  /// don't have to round-trip through the typed factory registry.
  static DiscourseGroupProxy? forCurrentSite() {
    final ctx = SiteProxyFactory.context;
    if (ctx == null) return null;
    return DiscourseGroupProxy(ctx);
  }

  /// List a page of groups. Discourse returns 36 per page by default
  /// and includes a `load_more_groups` URL in the response; we keep
  /// it simple and just use `page=N` (1-indexed).
  Future<List<DiscourseGroup>> getGroupsAsync({int page = 1}) async {
    try {
      final response = await apiGet('/groups.json', query: {
        if (page > 1) 'page': page.toString(),
      });
      final raw = (response['groups'] as List?) ?? const [];
      return raw
          .whereType<Map>()
          .map((g) => DiscourseGroup.fromJson(g.cast<String, dynamic>()))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  /// Fetch a single group by its slug name (e.g. `moderators`,
  /// `trust_level_3`). Returns null on 404 or other failure — the
  /// caller's UI shows a "group not found" message.
  Future<DiscourseGroup?> getGroupAsync(String name) async {
    try {
      final response = await apiGet('/groups/${Uri.encodeComponent(name)}.json');
      final raw = (response['group'] as Map?)?.cast<String, dynamic>();
      if (raw == null) return null;
      return DiscourseGroup.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  /// List the members of a group. Reuses [FCDirectoryItem] because
  /// Discourse returns the same user shape here as in
  /// `/directory_items.json` (without the activity stats — those
  /// fall back to 0).
  ///
  /// [limit] caps the page size; Discourse accepts up to 200 but
  /// defaults to 50 if absent.
  Future<List<FCDirectoryItem>> getGroupMembersAsync(
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
      // The response wraps members in `members: [...]` plus
      // `owners: [...]` for the group's admins. Merge both so the UI
      // shows everyone — owners appear at the top as the API returns.
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
      return members;
    } catch (_) {
      return const [];
    }
  }
}
