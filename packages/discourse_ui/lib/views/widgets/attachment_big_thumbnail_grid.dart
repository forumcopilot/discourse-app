import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/models/entities/fc_attachment.dart';
import 'broken_image_widget.dart';
import 'cached_redirect_image.dart';
import 'post_body_extensions.dart' show ImageGrid;
import '../../theme/design_tokens.dart';

/// A grid widget for displaying image attachments in big thumbnail mode
/// Dynamically sizes thumbnails based on screen width, maintaining aspect ratios.
/// Drawn like a post's own image grid ([ImageGrid]): the same gap and corner
/// radius, no frame; the file name under each picture.
class AttachmentBigThumbnailGrid extends StatelessWidget {
  final List<FCAttachment> attachments;
  final Function(String imageUrl, BuildContext context, String heroTag)? onImageTap;
  final Function(BuildContext context)? onLoginRequired;

  const AttachmentBigThumbnailGrid({
    super.key,
    required this.attachments,
    this.onImageTap,
    this.onLoginRequired,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Get screen size for dynamic sizing
        final mediaQuery = MediaQuery.of(context);
        final screenSize = mediaQuery.size;
        final availableWidth = constraints.maxWidth;
        
        // Calculate optimal item size based on available width
        // Aim for 2-3 items per row on phones, more on tablets
        const spacing = ImageGrid.gap;
        final minItemWidth = 120.0; // Minimum width for readability
        final maxItemWidth = 200.0; // Maximum width for consistency
        final preferredItemWidth = (availableWidth - spacing * 2) / 3; // Try for 3 columns
        final itemWidth = preferredItemWidth.clamp(minItemWidth, maxItemWidth);
        
        // Set max dimension to ensure consistent sizing across portrait/landscape
        final maxDimension = screenSize.width * 0.4;

        // The gap above is the one the file list under a post has too.
        return Padding(
          padding: const EdgeInsets.only(top: DesignTokens.spacingS),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: attachments.map((attachment) {
              return _buildThumbnailItem(
                context,
                attachment,
                itemWidth,
                maxDimension,
                colorScheme,
                textTheme,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildThumbnailItem(
    BuildContext context,
    FCAttachment attachment,
    double preferredWidth,
    double maxDimension,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    // Prefer thumbnail for performance, fall back to full image
    final imageUrl = attachment.thumbnailUrl?.isNotEmpty == true
        ? attachment.thumbnailUrl!
        : attachment.url;

    // Calculate actual width (don't exceed maxDimension)
    final actualWidth = preferredWidth < maxDimension ? preferredWidth : maxDimension;

    return SizedBox(
      width: actualWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Big thumbnail - respects aspect ratio with max constraints
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxDimension,
              maxHeight: maxDimension,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ImageGrid.radius),
              child: Stack(
                children: [
                  // Image - respects aspect ratio, fits within max dimension
                  // The image will size itself to fit within both width and height constraints
                  // while maintaining its natural aspect ratio
                  GestureDetector(
                    onTap: attachment.canViewUrl == true
                        ? () => onImageTap?.call(attachment.url, context, attachment.id)
                        : () => onLoginRequired?.call(context),
                    child: CachedRedirectImage(
                      imageUrl: imageUrl,
                      width: actualWidth,
                      fit: BoxFit.contain, // Maintains aspect ratio, fits within constraints
                      errorWidget: (context, error, stackTrace) {
                        // Square, the same broken-image box as in a post.
                        return BrokenImagePlaceholder(
                          width: actualWidth,
                          height: actualWidth,
                        );
                      },
                    ),
                  ),
                  // Lock overlay if can't view
                  if (attachment.canViewUrl != true)
                    Positioned(
                      top: DesignTokens.spacingS,
                      right: DesignTokens.spacingS,
                      child: Container(
                        padding: const EdgeInsets.all(DesignTokens.spacingXS),
                        decoration: BoxDecoration(
                          color: colorScheme.error.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
                        ),
                        child: Icon(
                          Icons.lock,
                          size: 14,
                          color: colorScheme.onError,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // The file name, as a caption: bodySmall in onSurfaceVariant.
          Padding(
            padding: const EdgeInsets.only(top: DesignTokens.spacingXS),
            child: _buildFilenameWithExtension(
              attachment.filename,
              textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant) ??
                  TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a filename widget that ensures the file extension is always visible
  /// even when the filename is truncated with ellipsis.
  Widget _buildFilenameWithExtension(String filename, TextStyle style) {
    // Find the last dot to separate base name and extension
    final lastDotIndex = filename.lastIndexOf('.');
    
    // If no extension found, just display the filename normally
    if (lastDotIndex == -1 || lastDotIndex == filename.length - 1) {
      return Text(
        filename,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }
    
    // Split into base name and extension
    final baseName = filename.substring(0, lastDotIndex);
    final extension = filename.substring(lastDotIndex);
    
    // Use Row to ensure extension is always visible
    return Row(
      children: [
        Flexible(
          child: Text(
            baseName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        Text(
          extension,
          style: style,
        ),
      ],
    );
  }
}

