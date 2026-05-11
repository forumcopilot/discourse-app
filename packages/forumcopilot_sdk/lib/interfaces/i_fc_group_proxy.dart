import '../models/results/fc_group_result.dart';

/// Group operations exposed to the app (Discourse: bundles of users
/// with shared permissions).
///
/// Phase 5.40 — promoted out of `DiscourseGroupProxy.forCurrentSite()`
/// sidecar onto a proper IFC proxy.
///
/// Discourse endpoints used by the reference implementation:
///   * `GET /groups.json`                      — directory of groups
///   * `GET /groups/{name}.json`               — single group
///   * `GET /groups/{name}/members.json`       — paginated members
abstract class IFCGroupProxy {
  /// List a page of groups (1-indexed).
  Future<FCGroupListResult> getGroupsAsync({int page = 1});

  /// Fetch a single group by slug name (`team`, `moderators`,
  /// `trust_level_2`).
  Future<FCGroupResult> getGroupAsync(String name);

  /// List the members of a group. [limit] caps the page size
  /// (Discourse accepts up to 200).
  Future<FCGroupMembersResult> getGroupMembersAsync(
    String name, {
    int offset = 0,
    int limit = 50,
  });
}
