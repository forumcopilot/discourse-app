import 'package:flutter/material.dart';

import '../../settings_context.dart';
import '../../theme/design_tokens.dart';
import '../../utils/file_utils.dart';

/// What the user chose when an image came in over the forum's size cap.
enum OversizedImageChoice { resize, skip }

/// Asks before rewriting a file the user picked.
///
/// Resizing to fit is a genuinely useful thing an app can do that the web
/// composer cannot — a phone photo is often over the cap and would simply
/// be refused. But doing it silently is how a 20 MB PNG became a 2.2 MB
/// JPEG with no one told. So: say what will happen, in the units that
/// matter, and let the answer be remembered.
Future<OversizedImageChoice?> showOversizedImageSheet(
  BuildContext context, {
  required String fileName,
  required int fileBytes,
  required int maxBytes,
}) {
  return showModalBottomSheet<OversizedImageChoice>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) => _OversizedImageSheet(
      fileName: fileName,
      fileBytes: fileBytes,
      maxBytes: maxBytes,
    ),
  );
}

class _OversizedImageSheet extends StatefulWidget {
  const _OversizedImageSheet({
    required this.fileName,
    required this.fileBytes,
    required this.maxBytes,
  });

  final String fileName;
  final int fileBytes;
  final int maxBytes;

  @override
  State<_OversizedImageSheet> createState() => _OversizedImageSheetState();
}

class _OversizedImageSheetState extends State<_OversizedImageSheet> {
  bool _dontAskAgain = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(DesignTokens.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.photo_size_select_large,
                    color: colorScheme.primary, size: DesignTokens.iconSizeL),
                SizedBox(width: DesignTokens.spacingM),
                Expanded(
                  child: Text(
                    'Image is too large to upload',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: DesignTokens.fontWeightBold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: DesignTokens.spacingM),
            Text(
              '${widget.fileName} is ${formatFileSize(widget.fileBytes)}. '
              'This forum allows up to ${formatFileSize(widget.maxBytes)}.',
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            SizedBox(height: DesignTokens.spacingS),
            Text(
              'It can be scaled down just enough to fit, keeping its format '
              'and as much detail as the limit allows.',
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            SizedBox(height: DesignTokens.spacingS),
            CheckboxListTile(
              value: _dontAskAgain,
              onChanged: (v) => setState(() => _dontAskAgain = v ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              title: Text("Don't ask again — always resize to fit",
                  style: textTheme.bodyMedium),
            ),
            SizedBox(height: DesignTokens.spacingS),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context)
                      .pop(OversizedImageChoice.skip),
                  child: const Text("Don't upload"),
                ),
                SizedBox(width: DesignTokens.spacingS),
                FilledButton(
                  onPressed: () async {
                    if (_dontAskAgain) {
                      await SettingsContext.instance
                          .setAlwaysResizeOversizedImages(true);
                    }
                    if (!context.mounted) return;
                    Navigator.of(context).pop(OversizedImageChoice.resize);
                  },
                  child: const Text('Resize and upload'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
