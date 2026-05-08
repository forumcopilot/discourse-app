import 'package:forumcopilot_sdk/models/entities/fc_attachment.dart';
import '../data/attachment/attachment.dart';

/// Converter for Discourse attachment data to FCAttachment
class DiscourseAttachmentConverter {
  /// Convert Discourse attachment to FCAttachment
  static FCAttachment toFCAttachment(DiscourseAttachment discourseAttachment) {
    return FCAttachment(
      id: discourseAttachment.id,
      filename: discourseAttachment.filename,
      contentType: discourseAttachment.mimeType,
      fileSize: discourseAttachment.fileSize,
      url: discourseAttachment.url,
      thumbnailUrl: discourseAttachment.thumbnailUrl,
      isImage: discourseAttachment.isImage,
      forumId: '', // Not available in attachment data
      postId: discourseAttachment.contentId?.toString() ?? '',
      canViewUrl: discourseAttachment.directUrl != null,
      canViewThumbnailUrl: discourseAttachment.thumbnailUrl != null,
    );
  }

  /// Convert list of Discourse attachments to list of FCAttachments
  static List<FCAttachment> toFCAttachmentList(List<DiscourseAttachment> discourseAttachments) {
    return discourseAttachments.map((attachment) => toFCAttachment(attachment)).toList();
  }
}
