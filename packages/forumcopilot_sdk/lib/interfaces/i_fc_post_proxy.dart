import '../models/entities/fc_poll.dart';
import '../models/entities/fc_post_vote.dart';
import '../models/results/fc_post_result.dart';
import '../models/results/fc_reaction_result.dart';

/// Interface for post management operations
/// This interface handles post creation, editing, retrieval, and management
abstract class IFCPostProxy {
  /// Report a problematic post to moderator. This should be used in conjunction
  /// with "can_report" flag in "get_thread". E.g. user cannot report its own post.
  ///
  /// [postId] ID of the post to report
  /// [reason] Reason for reporting the post
  Future<FCReportPostResult> reportPostAsync(String postId, String reason);

  /// Reply to an existing topic
  ///
  /// [forumId] Forum ID where the reply will be posted
  /// [topicId] Topic ID to reply to
  /// [subject] Subject of the reply
  /// [textBody] Content/body of the reply
  /// [attachmentIds] Optional list of attachment IDs
  /// [groupId] Optional group ID for attachments
  /// [returnHtml] Whether to return HTML content
  Future<FCReplyPostResult> replyPostAsync(String forumId, String topicId, String subject, String textBody, List<String>? attachmentIds, String? groupId, bool returnHtml);

  /// Returns a processed [quote] content just like when user click the "Quote" button
  /// on the web browser. This is to address different forum systems requires different
  /// [quote] format.
  ///
  /// [postId] ID of the post to quote
  Future<FCQuotePostResult> getQuotePostAsync(String postId);

  /// This function allows app to retrieve original content to display to user
  /// for post editing purpose.
  ///
  /// [postId] ID of the post to get raw content for
  Future<FCRawPostResult> getRawPostAsync(String postId);

  /// This function allows app save post content to an existing post.
  ///
  /// [postId] ID of the post to save
  /// [postTitle] New title for the post
  /// [postContent] New content for the post
  /// [returnHtml] Whether to return HTML content
  /// [reason] Optional reason for editing
  /// [attachmentIds] Optional list of attachment IDs
  /// [groupId] Optional group ID for attachments
  /// [prefix] Optional prefix ID to set for the thread (only applies when editing the first post)
  Future<FCSaveRawPostResult> saveRawPostAsync(String postId, String postTitle, String postContent, bool returnHtml, String? reason, List<String>? attachmentIds, String? groupId, String? prefix);

  /// Returns a list of posts under the same thread, given a topic_id
  ///
  /// [topicId] Topic ID to get posts for
  /// [startNum] Starting position for pagination
  /// [lastNum] Ending position for pagination
  /// [returnHtml] Whether to return HTML content
  Future<FCThreadResult> getThreadAsync(String topicId, int startNum, int lastNum, bool returnHtml);

  /// This function provides a mean to allow users to jump to the "First Unread" post
  /// within a thread he has previously participated. Please note that this function is
  /// used in conjunction with "goto_unread" in get_config function. If "goto_unread" is
  /// returned and is = "1", get_thread_by_unread is always called instead of get_thread
  /// function. Please be noted that this function is not invoked when under Guest mode.
  ///
  /// [topicId] Topic ID to get unread posts for
  /// [postsPerRequest] Number of posts per request
  /// [returnHtml] Whether to return HTML content
  Future<FCThreadByUnreadResult> getThreadByUnreadAsync(String topicId, int postsPerRequest, bool returnHtml);

  /// This function provides a mean to allow users to jump to the exact post within a thread
  /// given the post_id as the parameter. Please note that this function is used in conjunction
  /// with "goto_post" in get_config function. If "goto_post" is returned and is = "1",
  /// get_thread_by_post is always called instead of get_thread function when the app attempts
  /// to enter a thread from a list of posts.
  ///
  /// [postId] Post ID to jump to
  /// [postsPerRequest] Number of posts per request
  /// [returnHtml] Whether to return HTML content
  Future<FCThreadByPostResult> getThreadByPostAsync(String postId, int postsPerRequest, bool returnHtml);

  /// Submit or change the current user's vote on a poll. Auth required.
  ///
  /// [topicId] Thread (topic) ID that has the poll.
  /// [responseIds] IDs of the chosen options (from poll.responses[].id).
  /// Returns the updated poll on success, or null on failure.
  Future<FCPoll?> votePollAsync(String topicId, List<String> responseIds);

  /// Mark a post as the accepted answer for its topic
  /// (Discourse: discourse-solved plugin; XF-shaped backends would
  /// surface the equivalent of a "marked solution"). The post's
  /// `isSolution` flag and the topic's solved state both flip.
  /// Gated on `FCPost.canAcceptAnswer` — typically the topic OP
  /// or staff.
  ///
  /// [postId] ID of the post to mark.
  Future<FCAcceptAnswerResult> acceptAnswerAsync(String postId);

  /// Reverse of [acceptAnswerAsync]. Clears the solved state.
  ///
  /// [postId] ID of the post to unmark.
  Future<FCAcceptAnswerResult> unacceptAnswerAsync(String postId);

  /// Phase 5.36 — toggle an emoji reaction on [postId] (Discourse:
  /// `discourse-reactions` plugin). [reactionId] is the reaction
  /// shortcode (e.g. `"heart"`, `"tada"`). Toggling the viewer's
  /// current reaction removes it; toggling any other reaction
  /// replaces theirs. Returns the post's updated reaction list so
  /// the UI can swap state in-place. Returns `result:false` on
  /// 404 (plugin not installed) — UI should hide the picker in that
  /// case.
  Future<FCToggleReactionResult> toggleReactionAsync(
    String postId,
    String reactionId,
  );

  /// Phase 5.36 — fetch the forum's enabled reaction set so the
  /// picker can show the right emojis (Discourse:
  /// `GET /discourse-reactions/custom-reactions`). Implementations
  /// fall back to a built-in default list when the plugin endpoint
  /// 404s so the picker still works on plugin-less forums.
  Future<FCAvailableReactionsResult> getAvailableReactionsAsync();

  /// Phase 5.36 — cast a Q&A-style vote on [postId] (Discourse:
  /// `discourse-post-voting` plugin). [direction] is `"up"` or
  /// `"down"`. The plugin's response is bare-success so the
  /// returned `vote` is computed client-side from the previous state
  /// plus the requested direction — pass the post's current `vote`
  /// as [previous] so the result reflects the post-cast state.
  Future<FCPostVoteResult> castPostVoteAsync(
    String postId,
    String direction, {
    FCPostVote? previous,
  });

  /// Phase 5.36 — remove the viewer's vote on [postId]. Subject to
  /// the `post_voting_undo_vote_action_window` site setting
  /// (typically 10 seconds after voting). Same computed-vote
  /// convention as [castPostVoteAsync].
  Future<FCPostVoteResult> removePostVoteAsync(
    String postId, {
    FCPostVote? previous,
  });
}
