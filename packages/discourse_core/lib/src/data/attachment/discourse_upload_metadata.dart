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

/// What kind of upload a file name is, by the extensions Discourse web uses
/// to choose its Markdown (`isImage` / `isVideo` / `isAudio` in
/// `lib/uploads.js`). One list for the whole app: the composer, the proxy
/// and the post renderer each had their own, and AVIF, JXL, video and audio
/// fell through to plain file links.
enum DiscourseUploadKind { image, video, audio, file }

final _imageName = RegExp(r'\.(png|webp|jpe?g|gif|svg|ico|heic|heif|avif|jxl)$',
    caseSensitive: false);
final _videoName =
    RegExp(r'\.(mov|mp4|webm|m4v|3gp|ogv|avi|mpeg)$', caseSensitive: false);
final _audioName = RegExp(r'\.(mp3|og[ga]|opus|wav|m4[abpr]|aac|flac)$',
    caseSensitive: false);

DiscourseUploadKind discourseUploadKind(String fileName) {
  if (_imageName.hasMatch(fileName)) return DiscourseUploadKind.image;
  if (_videoName.hasMatch(fileName)) return DiscourseUploadKind.video;
  if (_audioName.hasMatch(fileName)) return DiscourseUploadKind.audio;
  return DiscourseUploadKind.file;
}

/// Discourse's own Markdown for an upload, from `lib/uploads.js`:
///
///   image  -> `![name|WIDTHxHEIGHT](short_url)`
///   video  -> `![name|video](short_url)`, which plays in the post
///   audio  -> `![name|audio](short_url)`
///   other  -> `[name.ext|attachment](short_url) (12.3 KB)`
///
/// Public and shared because two callers need it — the proxy, when it
/// appends refs on send, and the composer, when the user inserts one at
/// the cursor. They had separate hardcoded copies, which is why both
/// wrote "image" and "file".
String discourseUploadMarkdown(String shortUrl) {
  final meta = DiscourseUploadMetadata.forShortUrl(shortUrl);
  final rawName = meta?.fileName;
  // The short_url keeps the file's extension; the original name is better
  // when known (a HEIC converted on upload, say).
  final kind = discourseUploadKind(
      (rawName == null || rawName.isEmpty) ? shortUrl : rawName);

  switch (kind) {
    case DiscourseUploadKind.image:
      // Web uses the filename without its extension as the alt text.
      final alt = (rawName == null || rawName.isEmpty)
          ? 'image'
          : _escape(_stripExtension(rawName));
      final w = meta?.thumbnailWidth ?? meta?.width;
      final h = meta?.thumbnailHeight ?? meta?.height;
      final dims = (w != null && h != null) ? '|${w}x$h' : '';
      return '![$alt$dims]($shortUrl)';
    case DiscourseUploadKind.video:
    case DiscourseUploadKind.audio:
      final alt = (rawName == null || rawName.isEmpty)
          ? kind.name
          : _escape(_stripExtension(rawName));
      return '![$alt|${kind.name}]($shortUrl)';
    case DiscourseUploadKind.file:
      final name =
          (rawName == null || rawName.isEmpty) ? 'file' : _escape(rawName);
      final size = meta == null ? '' : ' (${_humanSize(meta.fileSize)})';
      return '[$name|attachment]($shortUrl)$size';
  }
}

/// Web's `escapeMarkdownCharacters` for the characters that would end or
/// break a link label.
String _escape(String name) =>
    name.replaceAllMapped(RegExp(r'([\[\]|()*_`])'), (m) => '\\${m[1]}');

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
