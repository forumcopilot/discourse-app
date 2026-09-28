import 'package:flutter/material.dart';
import 'package:discourse_ui/views/widgets/full_screen_image_viewer.dart';
import 'package:get/get.dart';
import 'package:discourse_ui/controllers/post_controller.dart';
import 'package:discourse_ui/utils/cooked_content.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/forum_media.dart';

class ImageActions {
  final PostController _postsController;
  final SiteContext? siteContext;

  ImageActions(this._postsController, {this.siteContext});

  /// Converts a relative URL to an absolute URL using the site's base URL
  String _makeAbsoluteUrl(String url) {
    // If already absolute, return as is
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // If no site context, return as is (can't convert)
    if (siteContext == null) {
      return url;
    }

    try {
      // Get the base URL from site context
      final baseUrl = siteContext!.site.url;
      if (baseUrl.isEmpty) {
        return url;
      }

      // Parse the base URL to extract origin (scheme + host + port)
      final baseUri = Uri.parse(baseUrl);
      final origin = '${baseUri.scheme}://${baseUri.host}${baseUri.hasPort ? ':${baseUri.port}' : ''}';

      // If relative URL starts with /, it's relative to domain root
      // Otherwise, it's relative to the base URL path
      if (url.startsWith('/')) {
        // URL is relative to domain root
        return '$origin$url';
      } else {
        // URL is relative to base URL path
        final basePath = baseUri.path;
        final cleanBasePath = basePath.endsWith('/') ? basePath : '$basePath/';
        return '$origin$cleanBasePath$url';
      }
    } catch (e) {
      AppLogger.debug('Error converting relative URL to absolute: $e');
      return url;
    }
  }

  /// The pictures in a post body ([cooked]), in the order the post shows
  /// them, and which of them [tappedUrl] is: 0 when none matches.
  ///
  /// A lightboxed upload is listed by its original (the anchor's href), so
  /// the body passes that address when one is tapped.
  static ({List<String> urls, int index}) bodyGallery(
    String cooked,
    String tappedUrl, {
    required String forumBaseUrl,
  }) {
    final urls = CookedContent.parse(cooked, forumBaseUrl: forumBaseUrl).imageUrls;
    final index = urls.indexOf(tappedUrl);
    return (urls: urls, index: index < 0 ? 0 : index);
  }

  void handleShowImage(String imageUrl, BuildContext context, String heroTag, String postId) {
    AppLogger.debug('Handling show image: $imageUrl');

    // Extract all images from the specified post only.
    final List<String> allImageUrls = [];
    final List<String> allHeroTags = [];
    int tappedIndex = 0;
    int currentIndex = 0;

    final data = _postsController.threadDataOutput.value;
    var postsList = data?.posts;
    if (postsList != null) {
      final post = postsList.firstWhereOrNull((p) => p.id == postId);
      if (post == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.postNotFound,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
          ),
        );
        return;
      }
      AppLogger.debug('\nCollecting all images from post $postId:');
      // 1. Images embedded in the post body.
      //
      // Discourse serves cooked HTML, so the images live in <img> tags —
      // lightboxed uploads additionally wrap the full-size original in an
      // `a.lightbox` href, which CookedContent prefers over the resized
      // <img src>. This used to scan for `[IMG]` BBCode tags, which never
      // appear in cooked HTML: inline images were silently absent from the
      // gallery, so tapping one opened the wrong image (or reported "no
      // images found" on a post with no attachments).
      final body = bodyGallery(
        post.content,
        _makeAbsoluteUrl(imageUrl),
        forumBaseUrl: siteContext?.site.url ?? '',
      );
      for (final url in body.urls) {
        allImageUrls.add(url);
        allHeroTags.add('${post.id}_image_$currentIndex');
        AppLogger.debug('  - Body image: $url');
        currentIndex++;
      }
      tappedIndex = body.index;
      // 2. Attachments (isImage or contentType starts with 'image/')
      for (var att in post.attachments) {
        final isImage = att.isImage || (att.contentType?.startsWith('image/') ?? false);
        final hasUrl = att.url.isNotEmpty || (att.thumbnailUrl?.isNotEmpty ?? false);
        if (isImage && hasUrl) {
          // Use full URL if available, otherwise use thumbnail
          final urlToUse = att.url.isNotEmpty ? att.url : (att.thumbnailUrl ?? '');
          allImageUrls.add(urlToUse);
          allHeroTags.add('${post.id}_attachment_$currentIndex');
          AppLogger.debug('  - Attachment: $urlToUse');
          if (urlToUse == imageUrl || att.url == imageUrl || att.thumbnailUrl == imageUrl) {
            tappedIndex = currentIndex;
          }
          currentIndex++;
        }
      }
      // 3. Inline attachments (isImage or contentType starts with 'image/').
      // Discourse has no separate inline-attachment concept — uploads are
      // embedded directly in the cooked HTML and are already collected in
      // step 1 — so this list is empty on Discourse forums and the loop is
      // a no-op. Kept so the gallery still works if the SDK ever populates it.
      for (var att in post.inlineAttachments) {
        final isImage = att.isImage || (att.contentType?.startsWith('image/') ?? false);
        final hasUrl = att.url.isNotEmpty || (att.thumbnailUrl?.isNotEmpty ?? false);
        if (isImage && hasUrl) {
          // Use full URL if available, otherwise use thumbnail
          final urlToUse = att.url.isNotEmpty ? att.url : (att.thumbnailUrl ?? '');
          allImageUrls.add(urlToUse);
          allHeroTags.add('${post.id}_inlineattachment_$currentIndex');
          AppLogger.debug('  - InlineAttachment: $urlToUse');
          if (urlToUse == imageUrl || att.url == imageUrl || att.thumbnailUrl == imageUrl) {
            tappedIndex = currentIndex;
          }
          currentIndex++;
        }
      }
      AppLogger.debug('Total images found: ${allImageUrls.length}\n');

      if (allImageUrls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.noImagesFoundToDisplay,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
            ),
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImageViewer(
            imageUrls: allImageUrls,
            initialIndex: tappedIndex,
            heroTag: allHeroTags[tappedIndex],
            auth: siteContext == null ? null : ForumMediaAuth.of(siteContext!),
          ),
        ),
      );
    }
  }
}
