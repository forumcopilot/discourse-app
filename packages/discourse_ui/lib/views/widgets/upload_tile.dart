import 'dart:io';

import 'package:discourse_core/discourse_core.dart'
    show DiscourseUploadKind, discourseUploadKind;
import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';
import '../../l10n/kit_strings.dart';

/// One upload in the strip: a thumbnail for a photo, the file's kind
/// otherwise, a spinner while it uploads, and a remove button (a 48dp
/// target). Both composers use it: the post composer's strip and chat's.
class UploadTile extends StatelessWidget {
  const UploadTile({
    super.key,
    required this.fileName,
    required this.path,
    required this.uploading,
    this.onRemove,
    this.removeTooltip,
  });

  static const double size = 64;

  /// The tile plus room for its remove badge: the badge's 48dp target is
  /// centred 10dp in from the tile's corner.
  static const double extent = size + 14;

  final String fileName;

  /// The picked file on the device, for a photo's thumbnail.
  final String path;
  final bool uploading;

  /// Null hides the remove badge (e.g. while a chat message is sending).
  final VoidCallback? onRemove;
  final String? removeTooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final name = fileName;
    final kind = discourseUploadKind(name);
    final dot = name.lastIndexOf('.');
    final ext = dot > 0 ? name.substring(dot + 1).toUpperCase() : '';

    final Widget face = kind == DiscourseUploadKind.image
        ? Image.file(
            File(path),
            fit: BoxFit.cover,
            // A thumbnail, not the full photo in memory.
            cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
            errorBuilder: (_, __, ___) =>
                Icon(Icons.image_outlined, color: colorScheme.onSecondaryContainer),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                switch (kind) {
                  DiscourseUploadKind.video => Icons.videocam_outlined,
                  DiscourseUploadKind.audio => Icons.audiotrack_outlined,
                  _ => Icons.insert_drive_file_outlined,
                },
                color: colorScheme.onSecondaryContainer,
              ),
              if (ext.isNotEmpty)
                Text(
                  ext,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium
                      ?.copyWith(color: colorScheme.onSecondaryContainer),
                ),
            ],
          );

    final radius = BorderRadius.circular(DesignTokens.radiusS);
    // The remove button sits on the tile's top-right corner, as a badge.
    // The tile gets that much room above and to its right, because a Stack
    // takes taps only within its own bounds and the button's 48dp target
    // reaches past the tile.
    return Semantics(
      label: name,
      child: SizedBox.square(
        dimension: extent,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              bottom: 0,
              width: size,
              height: size,
              child: ClipRRect(
                borderRadius: radius,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: colorScheme.secondaryContainer, child: face),
                    if (uploading)
                      ColoredBox(
                        color: colorScheme.scrim.withValues(alpha: 0.4),
                        child: const Center(
                          child: SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (onRemove != null)
              Positioned(
                top: 0,
                right: 0,
                child: IconButton.filledTonal(
                  onPressed: onRemove,
                  tooltip: removeTooltip ?? AppLocalizations.of(context)!.kit.remove,
                  iconSize: 16,
                  style: IconButton.styleFrom(
                    minimumSize: const Size.square(24),
                    fixedSize: const Size.square(24),
                    padding: EdgeInsets.zero,
                    // A 24dp circle in a 48dp target.
                    tapTargetSize: MaterialTapTargetSize.padded,
                  ),
                  icon: const Icon(Icons.close),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
