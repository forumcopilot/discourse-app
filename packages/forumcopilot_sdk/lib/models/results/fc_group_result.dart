import 'package:forumcopilot_sdk/models/entities/fc_directory_item.dart';
import 'package:forumcopilot_sdk/models/entities/fc_group.dart';

/// Paginated group directory (Discourse: `GET /groups.json`).
///
/// Group result types follow the chat-result pattern: plain classes
/// with the same `result`/`resultText` shape as `FCBaseResult` but
/// without the dart_mappable mixin (proxy→UI flows that don't need
/// JSON round-trip).
class FCGroupListResult {
  final bool result;
  final String? resultText;
  final List<FCGroup> groups;

  FCGroupListResult({
    required this.result,
    this.resultText,
    this.groups = const [],
  });
}

/// Single group lookup (Discourse: `GET /groups/{name}.json`).
class FCGroupResult {
  final bool result;
  final String? resultText;
  final FCGroup? group;

  FCGroupResult({
    required this.result,
    this.resultText,
    this.group,
  });
}

/// Paginated group members (Discourse:
/// `GET /groups/{name}/members.json`).
class FCGroupMembersResult {
  final bool result;
  final String? resultText;
  final List<FCDirectoryItem> members;

  FCGroupMembersResult({
    required this.result,
    this.resultText,
    this.members = const [],
  });
}
