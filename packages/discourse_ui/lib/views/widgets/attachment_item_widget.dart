import 'package:flutter/material.dart';
import '../widgets/cached_redirect_image.dart';
import '../../theme/design_tokens.dart';
import '../../utils/file_utils.dart';
import 'post_body_extensions.dart' show FileRow;

/// A reusable widget for rendering individual attachment items: the file
/// row a cooked attachment and an embed use too ([FileRow]).
class AttachmentItemWidget extends StatelessWidget {
  final dynamic attachment;
  final VoidCallback? onTap;
  final bool showDownloadIcon;
  final bool isInline;

  const AttachmentItemWidget({
    super.key,
    required this.attachment,
    this.onTap,
    this.showDownloadIcon = true,
    this.isInline = false,
  });

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
    
    // Use RichText to ensure extension is always visible
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isImage = isImageFile(attachment.filename);

    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacingXS),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(DesignTokens.radiusS),
          onTap: onTap,
          child: FileRow(
            leading: Container(
              decoration: BoxDecoration(
                color: isImage
                    ? colorScheme.surfaceContainerHighest
                    : getFileTypeColor(attachment.filename),
                borderRadius: BorderRadius.circular(DesignTokens.radiusS),
              ),
              child: Stack(
                children: [
                  // Main content
                  isImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                          child: CachedRedirectImage(
                            // Use thumbnail if available, otherwise use full image (similar to carousel)
                            // Don't check canViewThumbnailUrl - just try to use thumbnail if it exists
                            imageUrl: attachment.thumbnailUrl?.isNotEmpty == true
                                ? attachment.thumbnailUrl!
                                : attachment.url,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  getFileIcon(attachment.filename),
                                  size: DesignTokens.iconSizeL,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Icon(
                            getFileIcon(attachment.filename),
                            size: DesignTokens.iconSizeL,
                            color: Colors.white,
                          ),
                        ),
                  // Lock icon overlay if can't view URL (for all attachment types)
                  if (attachment.canViewUrl != true)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: colorScheme.error.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
                        ),
                        child: Icon(
                          Icons.lock,
                          size: 12,
                          color: colorScheme.onError,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            title: _buildFilenameWithExtension(
              attachment.filename,
              FileRow.titleStyle(context) ?? const TextStyle(),
            ),
            subtitle: Text(
              '${getFileType(attachment.filename)} • ${formatFileSize(attachment.fileSize)}',
            ),
            trailing: [
              if (!isImage && !isInline && showDownloadIcon && attachment.canViewUrl == true) ...[
                const SizedBox(width: DesignTokens.spacingS),
                Icon(
                  Icons.download,
                  size: DesignTokens.iconSizeM,
                  color: colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
