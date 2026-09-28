import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_attachment.dart';

import '../../../services/forum_media.dart';
import '../../../utils/file_utils.dart' show formatFileSize;
import '../../widgets/attachment_file_card.dart';
import '../../widgets/broken_image_widget.dart';
import '../../widgets/embed_cards.dart';
import '../../widgets/forum_image.dart';
import '../../widgets/full_screen_image_viewer.dart';
import '../../widgets/post_body_extensions.dart' show GridImage, ImageGrid, kPostBlockGap;

/// A chat message's uploads, drawn with the widgets a post draws the same
/// files with: a picture as a post's picture (several as the post's image
/// grid), a video as [PostVideoCard], a sound as [PostAudioPlayer], and any
/// other file as [AttachmentFileCard].
///
/// They used to go through the XenForo-era attachment list in its inline
/// mode, which gave a file no tap and no download, showed a video as a file
/// row that did nothing, and captioned every picture with its file name.
///
/// Which is which is decided by the file name, as chat-upload.gjs does on
/// the web (discourse/lib/uploads isImage, isVideo, isAudio).
class ChatUploads extends StatelessWidget {
  const ChatUploads({
    super.key,
    required this.uploads,
    required this.siteContext,
    required this.messageId,
  });

  final List<FCAttachment> uploads;
  final SiteContext siteContext;
  final int messageId;

  static final RegExp _image =
      RegExp(r'\.(png|webp|jpe?g|gif|svg|ico|heic|heif|avif|jxl)$', caseSensitive: false);
  static final RegExp _video =
      RegExp(r'\.(mov|mp4|webm|m4v|3gp|ogv|avi|mpeg)$', caseSensitive: false);
  static final RegExp _audio =
      RegExp(r'\.(mp3|og[ga]|opus|wav|m4[abpr]|aac|flac)$', caseSensitive: false);

  /// Discourse's own limits for a picture shown in a post or a message
  /// (the max_image_width and max_image_height defaults); a post's cooked
  /// picture arrives already sized to them.
  static const double _maxWidth = 690;
  static const double _maxHeight = 500;

  static bool _isImage(FCAttachment u) => _image.hasMatch(u.filename) || u.isImage;

  void _openGallery(BuildContext context, List<FCAttachment> images, int index, ForumMediaAuth auth) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => FullScreenImageViewer(
        imageUrls: [for (final u in images) u.url],
        initialIndex: index < 0 ? 0 : index,
        heroTag: 'chat_${messageId}_$index',
        auth: auth,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final auth = ForumMediaAuth.of(siteContext);
    final images = [for (final u in uploads) if (_isImage(u)) u];

    final blocks = <Widget>[
      if (images.length == 1)
        _picture(context, images.single, () => _openGallery(context, images, 0, auth), auth)
      else if (images.length > 1)
        ImageGrid(
          items: [
            for (final u in images)
              GridImage(
                src: u.thumbnailUrl?.isNotEmpty == true ? u.thumbnailUrl! : u.url,
                full: u.url,
                ratio: (u.width ?? 0) > 0 && (u.height ?? 0) > 0 ? u.width! / u.height! : null,
              ),
          ],
          onImageTap: (full, tapContext) => _openGallery(
              tapContext, images, images.indexWhere((u) => u.url == full), auth),
          auth: auth,
        ),
      for (final u in uploads)
        if (!_isImage(u))
          if (_video.hasMatch(u.filename))
            PostVideoCard(src: u.url, title: u.filename, auth: auth)
          else if (_audio.hasMatch(u.filename))
            PostAudioPlayer(src: u.url, auth: auth)
          else
            AttachmentFileCard(
              name: u.filename,
              url: u.url,
              size: u.fileSize > 0 ? formatFileSize(u.fileSize) : null,
              auth: auth,
            ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (i > 0) const SizedBox(height: kPostBlockGap),
          blocks[i],
        ],
      ],
    );
  }

  /// One picture, as a post draws one: at its proportions, no wider than
  /// Discourse would show it, the grid's corner radius; tapping opens it.
  Widget _picture(BuildContext context, FCAttachment u, VoidCallback onTap, ForumMediaAuth auth) {
    final src = u.thumbnailUrl?.isNotEmpty == true ? u.thumbnailUrl! : u.url;
    final w = u.width?.toDouble();
    final h = u.height?.toDouble();
    final picture = Image(
      image: forumImage(src, auth),
      fit: BoxFit.contain,
      errorBuilder: (context, _, __) => const BrokenImagePlaceholder(),
    );
    Widget sized = picture;
    if (w != null && h != null && w > 0 && h > 0) {
      final scale = math.min(1.0, math.min(_maxWidth / w, _maxHeight / h));
      sized = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: w * scale),
        child: AspectRatio(aspectRatio: w / h, child: picture),
      );
    }
    return Semantics(
      image: true,
      button: true,
      label: u.filename,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ImageGrid.radius),
          child: sized,
        ),
      ),
    );
  }
}
