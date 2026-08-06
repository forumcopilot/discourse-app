import 'package:flutter/material.dart';

/// Tap-callback bundle that originally drove the BBCode renderer. The
/// BBCode pipeline is gone (Discourse posts arrive as cooked HTML, which
/// RichTextContent renders directly via flutter_html), but the callsites
/// still construct one of these to keep the URL/mention/image tap logic
/// centralised. RichTextContent is the only consumer: it dispatches
/// `mention`-class anchors to [onMentionTap], `lightbox` anchors and
/// content `<img>` taps to [onImageTap], and everything else to
/// [onUrlTap] (falling back to an external launch when unset). The
/// class keeps its historical name and will go away once every callsite
/// has migrated to direct flutter_html tap handlers.
class PostContentCallbacks {
  /// Called when a URL is tapped
  final Function(String url)? onUrlTap;

  /// Called when an image is tapped
  final Function(String imageUrl, BuildContext context, String heroTag)?
      onImageTap;

  /// Called when a mention is tapped
  final Function(String username)? onMentionTap;

  const PostContentCallbacks({
    this.onUrlTap,
    this.onImageTap,
    this.onMentionTap,
  });
}
