import 'package:forumcopilot_sdk/models/results/fc_private_conversation_result.dart';

/// A window of the message lists, and whether Discourse has more after it.
///
/// Discourse pages each message list 30 at a time and says when more
/// follow (`topic_list.more_topics_url`); the XenForo-shaped result has only
/// a count. The list screen used to guess "more" from the number of rows —
/// inbox and sent merged, compared with 20 — so anyone with 30 or more
/// messages never got past the first load.
class DiscourseConversationsResult extends FCConversationsResult {
  DiscourseConversationsResult({
    required super.result,
    super.resultText,
    required super.conversationCount,
    required super.unreadCount,
    required super.canUpload,
    required super.list,
    required this.hasMore,
  });

  /// Whether any of the merged lists has a further page.
  final bool hasMore;
}
