import 'package:forumcopilot_sdk/models/entities/fc_post.dart';
import '../data/post/post.dart';
import 'discourse_attachment_converter.dart';

/// Converter for Discourse post data to FCPost
class DiscoursePostConverter {
  /// Convert Discourse post to FCPost
  static FCPost toFCPost(DiscoursePost discoursePost) {
    return FCPost(
      id: discoursePost.id,
      title: discoursePost.title,
      content: discoursePost.content,
      topicId: discoursePost.topicId,
      authorId: discoursePost.authorId,
      authorName: discoursePost.authorName,
      authorUserType: discoursePost.authorUserType,
      timestamp: discoursePost.postDateTime,
      authorIconUrl: discoursePost.authorAvatarUrl,
      isAuthorOnline: discoursePost.user?.isOnline ?? false,
      canEdit: discoursePost.canEdit ?? false,
      allowSmilies: true, // Assume smilies are allowed
      attachments: (discoursePost.attachments ?? []).map((attachment) => DiscourseAttachmentConverter.toFCAttachment(attachment)).toList(),
      inlineAttachments: const [],
      thanksInfo: const [],
      likesInfo: const [],
      postNumber: discoursePost.postNumber,
      canBan: false, // Not available in API
      canDelete: discoursePost.canDelete,
      canApprove: false, // Not available in API
      canMove: false, // Not available in API
      canReport: discoursePost.canReport,
      isBanned: discoursePost.user?.isBanned ?? false,
      isDeleted: discoursePost.isDeleted,
      isApproved: discoursePost.isApproved,
      isLiked: discoursePost.isLiked,
      isThanked: false, // Not available in API
      canLike: discoursePost.canLike,
      canThank: false, // Not available in API
    );
  }

  /// Convert list of Discourse posts to list of FCPosts
  static List<FCPost> toFCPostList(List<DiscoursePost> discoursePosts) {
    return discoursePosts.map((post) => toFCPost(post)).toList();
  }
}
