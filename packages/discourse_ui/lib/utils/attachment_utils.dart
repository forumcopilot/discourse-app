import 'package:forumcopilot_sdk/models/entities/fc_attachment.dart';

/// Utility class for common attachment operations
class AttachmentUtils {
  /// Builds BBCode attribute string from FCAttachment fields
  /// This centralizes the logic currently in BBCodeProcessor.replaceInlineAttachmentUrlsAndFilter
  static String _buildBBCodeAttributes(FCAttachment attachment) {
    final attrs = <String>[];

    if (attachment.thumbnailUrl != null && attachment.thumbnailUrl!.isNotEmpty) {
      attrs.add('thumbnailUrl="${attachment.thumbnailUrl}"');
    }
    if (attachment.url.isNotEmpty) {
      attrs.add('url="${attachment.url}"');
    }
    if (attachment.filename.isNotEmpty) {
      attrs.add('filename="${attachment.filename}"');
    }
    if (attachment.contentType != null && attachment.contentType!.isNotEmpty) {
      attrs.add('contentType="${attachment.contentType}"');
    }
    if (attachment.fileSize > 0) {
      attrs.add('fileSize="${attachment.fileSize}"');
    }
    if (attachment.id.isNotEmpty) {
      attrs.add('id="${attachment.id}"');
    }
    if (attachment.isImage) {
      attrs.add('isImage="true"');
    }
    if (attachment.forumId != null && attachment.forumId!.isNotEmpty) {
      attrs.add('forumId="${attachment.forumId}"');
    }
    if (attachment.postId != null && attachment.postId!.isNotEmpty) {
      attrs.add('postId="${attachment.postId}"');
    }
    final bool? canViewUrl = attachment.canViewUrl;
    final bool? canViewThumbnailUrl = attachment.canViewThumbnailUrl;

    if (canViewUrl != null) {
      attrs.add('canViewUrl="$canViewUrl"');
    }
    if (canViewThumbnailUrl != null) {
      attrs.add('canViewThumbnailUrl="$canViewThumbnailUrl"');
    }

    return attrs.isNotEmpty ? ' ' + attrs.join(' ') : '';
  }

  /// Creates an inline attachment BBCode tag from an attachment
  static String createInlineAttachmentTag(FCAttachment attachment) {
    final attrString = _buildBBCodeAttributes(attachment);
    return '[inlineattachment$attrString]${attachment.url}[/inlineattachment]';
  }

  /// Filters attachments by URLs that have been processed
  /// Returns the remaining attachments that haven't been used
  static List<FCAttachment> filterUsedAttachments(List<FCAttachment> attachments, Set<String> usedUrls) {
    return attachments.where((att) => !usedUrls.contains(att.url)).toList();
  }
}
