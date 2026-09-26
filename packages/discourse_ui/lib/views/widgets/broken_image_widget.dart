import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/design_tokens.dart';
import '../../l10n/generated/app_localizations.dart';

/// A picture that failed to load, the same wherever it was — in a post, an
/// image grid, the uploads under a post, an avatar: a surfaceContainerHighest
/// box with radius 8, a 24dp broken-image icon, and the picture's alt text
/// when it has one. It fills the space the picture was given, and is only
/// as big as its contents when given none.
class BrokenImagePlaceholder extends StatelessWidget {
  const BrokenImagePlaceholder({super.key, this.alt, this.width, this.height});

  final String? alt;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = alt?.trim() ?? '';
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(DesignTokens.spacingS),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DesignTokens.radiusS),
      ),
      // A Wrap, not a Column: in a box smaller than its contents it is
      // clipped instead of reporting an overflow.
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: DesignTokens.spacingS,
        runSpacing: DesignTokens.spacingXS,
        children: [
          Icon(Icons.broken_image, size: DesignTokens.iconSizeL, color: colorScheme.onSurfaceVariant),
          if (label.isNotEmpty)
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}

/// A broken picture with a link to open it elsewhere: [BrokenImagePlaceholder]'s
/// box and icon, the picture's address as a button, or "Image not available".
class BrokenImageWidget extends StatelessWidget {
  final double width;
  final double height;

  /// Kept for callers; the icon is always the placeholder's 24dp.
  final double iconSize;

  /// Kept for callers; the text is always bodySmall (12), the smallest
  /// readable size.
  final double fontSize;
  final String? imageUrl;
  final VoidCallback? onTap;

  const BrokenImageWidget({
    super.key,
    required this.width,
    required this.height,
    this.iconSize = 24.0,
    this.fontSize = 12.0,
    this.imageUrl,
    this.onTap,
  });

  /// Creates a broken image widget specifically for inline images with URL
  factory BrokenImageWidget.forInlineImage({
    required double width,
    required double height,
    required String imageUrl,
    double iconSize = 32.0,
    double fontSize = 11.0,
    VoidCallback? onTap,
  }) {
    return BrokenImageWidget(
      width: width,
      height: height,
      imageUrl: imageUrl,
      iconSize: iconSize,
      fontSize: fontSize,
      onTap: onTap,
    );
  }

  /// Shortens a URL to make it more readable
  static String shortenUrl(String url) {
    try {
      final uri = Uri.parse(url);
      String host = uri.host;

      // Remove 'www.' prefix if present
      if (host.startsWith('www.')) {
        host = host.substring(4);
      }

      // If the host is too long, truncate it
      if (host.length > 20) {
        host = '${host.substring(0, 17)}...';
      }

      // If there's a path, try to show a bit of it
      String path = uri.path;
      if (path.isNotEmpty && path != '/') {
        // Get the last segment of the path (filename)
        final segments = path.split('/').where((s) => s.isNotEmpty).toList();
        if (segments.isNotEmpty) {
          String filename = segments.last;
          // If filename is too long, truncate it
          if (filename.length > 15) {
            filename = '${filename.substring(0, 12)}...';
          }
          return '$host/$filename';
        }
      }

      return host;
    } catch (e) {
      // If URL parsing fails, return a truncated version of the original
      if (url.length > 30) {
        return '${url.substring(0, 27)}...';
      }
      return url;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final small = textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DesignTokens.radiusS),
      ),
      child: Padding(
        padding: DesignTokens.paddingM,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: DesignTokens.iconSizeL,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: DesignTokens.spacingS),
            if (imageUrl != null) ...[
              // A standard text button: a 48dp target, where the old chip
              // was about 20dp tall.
              TextButton.icon(
                onPressed: onTap ??
                    () async {
                      try {
                        final uri = Uri.parse(imageUrl!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)?.couldNotOpenLink(e.toString()) ?? 'Could not open link: ${e.toString()}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                icon: const Icon(Icons.link, size: DesignTokens.iconSizeSMedium),
                label: Text(
                  shortenUrl(imageUrl!),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.tapToOpen,
                style: small,
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Text(
                AppLocalizations.of(context)!.imageNotAvailable,
                style: small,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
