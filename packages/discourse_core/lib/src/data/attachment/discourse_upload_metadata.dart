import 'package:flutter/foundation.dart' show visibleForTesting;

/// What `/uploads.json` said about an upload, kept so the Markdown that
/// references it can be written the way Discourse writes it.
///
/// The post body can only carry a `upload://…` short_url, and by the time
/// the proxy assembles the raw that is all it has — which is why every
/// attachment this app posted was called "file" and every image "image".
/// Discourse web has the whole upload record in hand at that moment and
/// writes `![notes|900x600](…)` / `[notes.txt|attachment](…) (117 Bytes)`.
///
/// A side table keyed by short_url closes that gap without widening the
/// SDK: the response already contains all of it, it was simply dropped.
/// Same shape as the other Discourse-only lookups (accepted answers,
/// valid reactions) — process-lifetime only, and absence is always
/// tolerable because the caller falls back to the old generic label.
class DiscourseUploadMetadata {
  const DiscourseUploadMetadata({
    required this.fileName,
    required this.fileSize,
    this.width,
    this.height,
    this.thumbnailWidth,
    this.thumbnailHeight,
  });

  final String fileName;
  final int fileSize;

  /// Full pixel dimensions, absent for non-images.
  final int? width;
  final int? height;

  /// What web puts in `![name|WxH]`. Discourse sizes the rendered image
  /// from these, and its ×50%/×75% scale syntax builds on them.
  final int? thumbnailWidth;
  final int? thumbnailHeight;

  static final Map<String, DiscourseUploadMetadata> _byShortUrl = {};

  static void remember(String? shortUrl, DiscourseUploadMetadata meta) {
    if (shortUrl == null || shortUrl.isEmpty) return;
    _byShortUrl[shortUrl] = meta;
  }

  static DiscourseUploadMetadata? forShortUrl(String shortUrl) =>
      _byShortUrl[shortUrl];

  @visibleForTesting
  static void reset() => _byShortUrl.clear();
}

/// Discourse's own Markdown for an upload, from `lib/uploads.js`:
///
///   image  -> `![name|WIDTHxHEIGHT](short_url)`
///   other  -> `[name|attachment](short_url) (12.3 KB)`
///
/// Public and shared because two callers need it — the proxy, when it
/// appends refs on send, and the composer, when the user inserts one at
/// the cursor. They had separate hardcoded copies, which is why both
/// wrote "image" and "file".
String discourseUploadMarkdown(String shortUrl) {
  final lower = shortUrl.toLowerCase();
  const imageExts = [
    '.png', '.jpg', '.jpeg', '.gif', '.webp', '.heic', '.bmp', '.svg',
  ];
  final isImage = imageExts.any(lower.endsWith);
  final meta = DiscourseUploadMetadata.forShortUrl(shortUrl);
  final rawName = meta?.fileName;

  if (isImage) {
    // Web uses the filename without its extension as the alt text.
    final alt = (rawName == null || rawName.isEmpty)
        ? 'image'
        : _stripExtension(rawName);
    final w = meta?.thumbnailWidth ?? meta?.width;
    final h = meta?.thumbnailHeight ?? meta?.height;
    final dims = (w != null && h != null) ? '|${w}x$h' : '';
    return '![$alt$dims]($shortUrl)';
  }
  final name = (rawName == null || rawName.isEmpty) ? 'file' : rawName;
  final size = meta == null ? '' : ' (${_humanSize(meta.fileSize)})';
  return '[$name|attachment]($shortUrl)$size';
}

String _stripExtension(String name) {
  final dot = name.lastIndexOf('.');
  return dot <= 0 ? name : name.substring(0, dot);
}

/// Matches the units Discourse prints beside an attachment link.
String _humanSize(int bytes) {
  if (bytes < 1024) return '$bytes Bytes';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
