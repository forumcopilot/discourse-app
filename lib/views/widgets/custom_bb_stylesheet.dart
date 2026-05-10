import 'package:flutter/material.dart';

/// Tap-callback bundle that originally drove the BBCode renderer. The
/// BBCode pipeline is gone (Discourse posts arrive as cooked HTML, which
/// RichTextContent renders directly via flutter_html), but the callsites
/// still construct one of these to keep the URL/mention tap logic
/// centralised. RichTextContent currently uses the default URL launcher
/// for taps and ignores the callbacks — this class will go away once
/// every callsite has migrated to direct flutter_html tap handlers.
class BBCodeCallbacks {
  /// Called when a URL is tapped
  final Function(String url)? onUrlTap;

  /// Called when an image is tapped
  final Function(String imageUrl, BuildContext context, String heroTag)?
      onImageTap;

  /// Called when a video is tapped
  final Function(String videoUrl)? onVideoTap;

  /// Called when a mention is tapped
  final Function(String username)? onMentionTap;

  /// Called when a user tag is tapped (with optional userId)
  final Function(String username, String? userId)? onUserTap;

  /// Called when an attachment is tapped
  final Function(String url, bool isImage, bool canView)? onAttachmentTap;

  /// List of inline attachments available for lookup by ID
  final List<dynamic>? inlineAttachments;

  /// List of regular attachments available for lookup by ID
  final List<dynamic>? attachments;

  const BBCodeCallbacks({
    this.onUrlTap,
    this.onImageTap,
    this.onVideoTap,
    this.onMentionTap,
    this.onUserTap,
    this.onAttachmentTap,
    this.inlineAttachments,
    this.attachments,
  });
}
