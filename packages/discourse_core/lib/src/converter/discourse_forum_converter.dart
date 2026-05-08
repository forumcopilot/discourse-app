import 'package:forumcopilot_sdk/models/entities/fc_forum.dart';
import '../data/node/node.dart';

/// Converter for Discourse forum data to FCForum
class DiscourseForumConverter {
  /// Convert Discourse node (forum) to FCForum
  static FCForum toFCForum(DiscourseNode node) {
    final typeData = node.typeData ?? const {};
    return FCForum(
      id: node.id,
      name: node.title ?? '',
      description: node.description,
      logoUrl: null,
      backgroundUrl: null,
      parentId: node.parentId.isEmpty ? null : node.parentId,
      hasNewPosts: false,
      isProtected: false,
      isSubscribed: false,
      canSubscribe: true,
      canPost: (typeData['allow_posting'] as bool?) ?? true,
      externalUrl: typeData['link_url'] as String?,
      isSubForumContainer: false,
      childForums: const [],
    );
  }

  /// Convert list of Discourse forums to list of FCForums
  static List<FCForum> toFCForumList(List<DiscourseNode> nodes) {
    return nodes.map((forumNode) => toFCForum(forumNode)).toList();
  }
}
