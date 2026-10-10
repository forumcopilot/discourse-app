import 'dart:io';

import 'package:dio/dio.dart' show CancelToken;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../services/forum_media.dart';
import '../../theme/design_tokens.dart';
import '../../utils/error_message.dart';
import '../../utils/file_utils.dart';
import '../../utils/url_utils.dart';
import 'post_body_extensions.dart' show EmbeddedCard, FileRow;
import '../../l10n/kit_strings.dart';

/// A file in a post or a chat message — a cooked `a.attachment`, a chat
/// upload — as the one [FileRow] in an [EmbeddedCard]: the type tile, the
/// name over its type and size, Share and Download.
///
/// Opening it (the row, or Download) fetches the file through [ForumMedia],
/// as the signed-in user, into a temporary file, and hands that to the
/// system's share sheet, where it opens in an app or is saved. It used to
/// open the address in the browser, which is signed out: a file in a
/// private message, or on a forum with prevent_anons_from_downloading_files,
/// came back "not found". While it downloads, Download becomes the progress
/// ring, and tapping it cancels. Share still shares the address.
class AttachmentFileCard extends StatefulWidget {
  const AttachmentFileCard({
    super.key,
    required this.name,
    required this.url,
    this.size,
    this.auth,
  });

  /// The file's name, as its author uploaded it.
  final String name;

  /// Its absolute address; empty when the post gave none.
  final String url;

  /// Its size as the forum wrote it ("117 Bytes", "1.2 MB"), if known.
  final String? size;

  /// The forum's media rules for the signed-in user; null for none.
  final ForumMediaAuth? auth;

  @override
  State<AttachmentFileCard> createState() => _AttachmentFileCardState();
}

class _AttachmentFileCardState extends State<AttachmentFileCard> {
  CancelToken? _cancel;

  /// Share of the file received, null until the size is known.
  double? _progress;

  bool get _busy => _cancel != null;

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }

  /// Where the share sheet points from on an iPad: this card.
  Rect? _origin() {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Future<void> _open() async {
    if (_busy || widget.url.isEmpty) return;
    final cancel = CancelToken();
    setState(() {
      _cancel = cancel;
      _progress = null;
    });
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final origin = _origin();

    void fail(Object error) {
      if (!mounted) return;
      final reason = describeError(error, context: context);
      messenger?.showSnackBar(SnackBar(
        content: Text(
          l10n.errorDownloading(widget.name, reason),
          style: TextStyle(color: colorScheme.onErrorContainer),
        ),
        backgroundColor: colorScheme.errorContainer,
      ));
    }

    File? file;
    try {
      file = await ForumMedia.download(
        widget.auth,
        widget.url,
        widget.name,
        cancelToken: cancel,
        onReceiveProgress: (received, total) {
          if (!mounted || total <= 0) return;
          setState(() => _progress = received / total);
        },
      );
    } catch (e) {
      if (!cancel.isCancelled) fail(e);
    } finally {
      if (mounted) {
        setState(() {
          _cancel = null;
          _progress = null;
        });
      }
    }
    if (file == null || !mounted) return;
    try {
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        sharePositionOrigin: origin,
      ));
    } catch (e) {
      fail(e);
    }
  }

  void _share() {
    // ignore: discarded_futures
    UrlUtils.shareUrl(widget.url, sharePositionOrigin: _origin());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final label = widget.name.isEmpty ? l10n.attachmentDefaultName : widget.name;
    final hasUrl = widget.url.isNotEmpty;
    final progress = _progress;

    return EmbeddedCard(
      onTap: hasUrl && !_busy ? _open : null,
      padding: EdgeInsets.zero,
      child: FileRow(
        // The 48dp type tile the composer draws, from the same helpers, so
        // a file looks the same about to be posted and read back.
        leading: DecoratedBox(
          decoration: BoxDecoration(
            color: getFileTypeColor(label),
            borderRadius: BorderRadius.circular(DesignTokens.radiusS),
          ),
          child: Icon(
            getFileIcon(label),
            size: DesignTokens.iconSizeL,
            color: Colors.white,
          ),
        ),
        title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text([
          getFileType(label).toUpperCase(),
          if (widget.size != null && widget.size!.isNotEmpty) widget.size!,
        ].join(' • ')),
        trailing: [
          IconButton(
            tooltip: l10n.kit.share,
            onPressed: hasUrl ? _share : null,
            icon: Icon(Icons.share_outlined,
                size: DesignTokens.iconSizeM, color: colorScheme.onSurfaceVariant),
          ),
          if (_busy)
            IconButton(
              tooltip: l10n.kit.cancel,
              onPressed: () => _cancel?.cancel(),
              icon: SizedBox(
                width: DesignTokens.iconSizeM,
                height: DesignTokens.iconSizeM,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2.5,
                  semanticsLabel: l10n.downloading(label),
                  semanticsValue: progress == null ? null : '${(progress * 100).round()}%',
                ),
              ),
            )
          else
            IconButton(
              tooltip: l10n.download,
              onPressed: hasUrl ? _open : null,
              icon: Icon(Icons.download_rounded,
                  size: DesignTokens.iconSizeM, color: colorScheme.primary),
            ),
        ],
      ),
    );
  }
}
