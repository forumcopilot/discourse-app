import 'dart:io';
import 'dart:ui' as ui;

import 'package:discourse_core/discourse_core.dart'
    show DiscourseMediaOptimization;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/logging/app_logger.dart';

/// A photo prepared the way the forum's own composer prepares it, or null to
/// upload the original.
///
/// Discourse's website optimizes photos in the browser before uploading
/// (see [DiscourseMediaOptimization]): a phone photo of 3–5 MB goes up as a
/// few hundred KB, 1920 px wide, at the forum's image quality. The app
/// uploaded originals, so the same photo cost ten times the data and storage
/// from the app. This applies the forum's settings to JPEG photos only.
/// Discourse re-encodes PNGs to JPEG as well, which flattens transparency and
/// puts artefacts on screenshots — the damage the app already undid once (see
/// shrinkImageToFit) — so PNG, GIF and everything else upload untouched.
///
/// Orientation is applied to the pixels and the metadata is dropped, as a
/// browser's canvas does; that also takes GPS location out of the photo.
/// The original is kept when the result is not smaller, or smaller than
/// Discourse's 20,000-byte "suspiciously small" floor.
Future<File?> optimizePhotoForForum(
  File source,
  DiscourseMediaOptimization? settings,
) async {
  if (settings == null || !settings.enabled) return null;
  if (Platform.isIOS && !settings.enabledOnIos) return null;
  // Already done once (a composer prepares a photo before handing it to the
  // upload service, which would otherwise encode it a second time).
  if (p.basename(p.dirname(source.path)).startsWith(_outputPrefix)) {
    return null;
  }
  final ext = p.extension(source.path).toLowerCase();
  if (ext != '.jpg' && ext != '.jpeg') return null;

  try {
    final originalBytes = await source.length();
    if (originalBytes < settings.bytesThreshold) return null;

    final size = await _displayedSize(source);
    if (size == null) return null;
    final target = settings.targetSize(size.width, size.height);

    // A unique directory under the original filename, so the server records
    // the user's name for the file rather than a temp one (as
    // shrinkImageToFit does, for the same XFile reason).
    final root = await getTemporaryDirectory();
    final dir = Directory(p.join(root.path,
        '$_outputPrefix${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}'));
    await dir.create(recursive: true);
    final out = await FlutterImageCompress.compressAndGetFile(
      source.path,
      p.join(dir.path, p.basename(source.path)),
      // Never enlarges; the plugin swaps these for a rotated photo.
      minWidth: target.width,
      minHeight: target.height,
      quality: settings.quality,
      format: CompressFormat.jpeg,
    );
    if (out == null) return null;
    final result = File(out.path);
    final newBytes = await result.length();
    AppLogger.debug(
      'optimizePhotoForForum: ${size.width}x${size.height} '
      '$originalBytes B -> ${target.width}x${target.height} $newBytes B '
      '(q${settings.quality})',
    );
    if (newBytes < DiscourseMediaOptimization.minimumResultBytes ||
        newBytes >= originalBytes) {
      return null;
    }
    return result;
  } catch (e) {
    AppLogger.debug('optimizePhotoForForum failed, uploading original: $e');
    return null;
  }
}

/// Names the directories optimized photos are written to.
const _outputPrefix = 'forum_optimized_';

/// Width and height as the photo is shown, orientation applied — what the
/// browser measures before deciding to resize. Read from the header, without
/// decoding the pixels.
Future<({int width, int height})?> _displayedSize(File file) async {
  final buffer =
      await ui.ImmutableBuffer.fromUint8List(await file.readAsBytes());
  try {
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final size = (width: descriptor.width, height: descriptor.height);
    descriptor.dispose();
    return size;
  } catch (_) {
    return null;
  } finally {
    buffer.dispose();
  }
}
