import 'package:forumcopilot_sdk/models/entities/fc_chat_message.dart';

import 'discourse_chat_channel_details.dart';

/// A chat thread, as `Chat::ThreadSerializer` writes one: its channel, title,
/// original message, replies and latest reply, and the reader's unread count.
class DiscourseChatThread {
  const DiscourseChatThread({
    required this.threadId,
    required this.channelId,
    this.channelTitle,
    this.title,
    this.originalMessage,
    this.replyCount = 0,
    this.lastReplyAt,
    this.lastReplyExcerpt,
    this.lastReplyUser,
    this.participants = const [],
    this.unreadCount = 0,
    this.busLastId,
  });

  final int threadId;
  final int channelId;
  final String? channelTitle;
  final String? title;
  final FCChatMessage? originalMessage;
  final int replyCount;
  final DateTime? lastReplyAt;
  final String? lastReplyExcerpt;
  final DiscourseChatUser? lastReplyUser;
  final List<DiscourseChatUser> participants;
  final int unreadCount;

  /// Where `/chat/{channel}/thread/{id}` was when the thread was read.
  final int? busLastId;
}
