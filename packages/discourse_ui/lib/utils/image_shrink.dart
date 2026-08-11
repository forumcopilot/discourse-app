import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/painting.dart' show decodeImageFromList;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/logging/app_logger.dart';

/// The result of trying to bring an oversized image under the forum's cap.
class ShrinkResult {
  const ShrinkResult({
    required this.file,
    required this.originalBytes,
    required this.newBytes,
    required this.originalSize,
    required this.newSize,
  });

  final File file;
  final int originalBytes;
  final int newBytes;

  /// Pixel dimensions before and after, for telling the user what changed.
  final ({int width, int height})? originalSize;
  final ({int width, int height})? newSize;
}

/// Shrinks an image just far enough to fit [maxBytes].
///
/// Deliberately *minimal*: the app used to hand every picked image to
/// image_picker's re-encoder, which rewrote it as JPEG at quality 80 and
/// capped it at 1920px whether or not it needed to. That flattened
/// transparency, put JPEG artefacts on screenshots, turned a 4.7 KB PNG
/// into 15.9 KB, and — because it ran before the size check — quietly
/// pushed a 20 MB file under a 10 MB limit that could then never fire.
///
/// This runs only when a file is genuinely over the cap, and searches for
/// the *largest* version that still fits rather than jumping to a fixed
/// preset. Format is preserved: a PNG stays a PNG (scaled, still
/// lossless, transparency intact), a JPEG stays a JPEG.
///
/// Returns null when the image cannot be read or cannot be brought under
/// the cap, so the caller can fall back to refusing the file with the
/// server's own limit rather than uploading something doomed.
Future<ShrinkResult?> shrinkImageToFit(
  File source, {
  required int maxBytes,
}) async {
  final originalBytes = await source.length();
  if (originalBytes <= maxBytes) return null;

  final format = _formatFor(source.path);
  if (format == null) return null;

  final original = await _dimensions(source);
  if (original == null) return null;

  // Write into a unique directory under the ORIGINAL filename. XFile's
  // io implementation derives `name` from the path basename and ignores
  // the `name:` constructor argument (that only works on web), so the
  // only way to keep the user's filename through the upload is to keep
  // it on disk. Otherwise the server records the temp name and the post
  // shows "shrunk_3dd7012c_0.png".
  final root = await getTemporaryDirectory();
  final stamp = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
  final ext = p.extension(source.path);
  final baseName = p.basename(source.path);

  // First guess from the area ratio: bytes scale roughly with pixel count,
  // so the linear factor is the square root. The 0.97 keeps the first
  // attempt just inside the cap instead of just outside it.
  var scale = math.sqrt(maxBytes / originalBytes) * 0.97;

  ShrinkResult? best;
  for (var attempt = 0; attempt < 5; attempt++) {
    final targetW = math.max(1, (original.width * scale).round());
    final targetH = math.max(1, (original.height * scale).round());
    final dir = Directory(p.join(root.path, 'shrink_${stamp}_$attempt'));
    await dir.create(recursive: true);
    final target = p.join(dir.path, baseName);

    final out = await FlutterImageCompress.compressAndGetFile(
      source.path,
      target,
      minWidth: targetW,
      minHeight: targetH,
      // PNG ignores quality (it is lossless); for JPEG stay high, because
      // the point here is to lose as little as possible while fitting.
      quality: format == CompressFormat.png ? 100 : 92,
      format: format,
    );
    AppLogger.debug(
      'shrinkImageToFit: format=$format target=$target '
      'scale=${scale.toStringAsFixed(3)} -> ${out?.path}',
    );
    if (out == null) return best;

    final outFile = File(out.path);
    final bytes = await outFile.length();
    if (bytes <= maxBytes) {
      best = ShrinkResult(
        file: outFile,
        originalBytes: originalBytes,
        newBytes: bytes,
        originalSize: original,
        newSize: await _dimensions(outFile),
      );
      // Comfortably under: try once more at a larger scale so we hand back
      // the biggest image that fits, not the first one that happens to.
      if (bytes < maxBytes * 0.75 && attempt < 4) {
        scale *= math.min(1.35, math.sqrt(maxBytes / bytes) * 0.97);
        continue;
      }
      return best;
    }
    scale *= 0.82;
  }
  return best;
}

CompressFormat? _formatFor(String path) {
  switch (p.extension(path).toLowerCase()) {
    case '.png':
      return CompressFormat.png;
    case '.jpg':
    case '.jpeg':
      return CompressFormat.jpeg;
    case '.webp':
      return CompressFormat.webp;
    case '.heic':
    case '.heif':
      return CompressFormat.heic;
  }
  // GIF (animation would be destroyed) and SVG (not a raster image) are
  // deliberately absent — there is no safe way to shrink either here.
  return null;
}

Future<({int width, int height})?> _dimensions(File file) async {
  try {
    final decoded = await decodeImageFromList(await file.readAsBytes());
    return (width: decoded.width, height: decoded.height);
  } catch (_) {
    return null;
  }
}
