import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../services/forum_media.dart';

/// A picture in a post, chat message or the image viewer: one of the
/// forum's secure uploads is fetched with the signed-in user's key (see
/// [ForumMediaAuth]); every other picture as any picture on the web,
/// without it.
ImageProvider forumImage(String url, ForumMediaAuth? auth) =>
    auth != null && auth.mustAuthenticate(url)
        ? ForumImageProvider(url, auth)
        : NetworkImage(url);

/// A secure upload, fetched through [ForumMedia] so the key reaches the
/// forum and not the S3 address it redirects to. Cached in memory like
/// [NetworkImage], and forgotten on failure so a later build tries again.
@immutable
class ForumImageProvider extends ImageProvider<ForumImageProvider> {
  const ForumImageProvider(this.url, this.auth, {this.scale = 1.0});

  final String url;
  final ForumMediaAuth auth;
  final double scale;

  @override
  Future<ForumImageProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<ForumImageProvider>(this);

  @override
  ImageStreamCompleter loadImage(ForumImageProvider key, ImageDecoderCallback decode) {
    final chunks = StreamController<ImageChunkEvent>();
    return MultiFrameImageStreamCompleter(
      codec: _load(key, decode, chunks),
      chunkEvents: chunks.stream,
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => [
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<ForumImageProvider>('Image key', key),
      ],
    );
  }

  Future<ui.Codec> _load(
    ForumImageProvider key,
    ImageDecoderCallback decode,
    StreamController<ImageChunkEvent> chunks,
  ) async {
    try {
      final response = await ForumMedia.getBytes(
        key.auth,
        key.url,
        onReceiveProgress: (received, total) => chunks.add(ImageChunkEvent(
          cumulativeBytesLoaded: received,
          expectedTotalBytes: total > 0 ? total : null,
        )),
      );
      final status = response.statusCode ?? 0;
      final bytes = response.data;
      if (status != 200 || bytes == null || bytes.isEmpty) {
        throw NetworkImageLoadException(statusCode: status, uri: Uri.parse(key.url));
      }
      final buffer = await ui.ImmutableBuffer.fromUint8List(
          bytes is Uint8List ? bytes : Uint8List.fromList(bytes));
      return decode(buffer);
    } catch (_) {
      scheduleMicrotask(() => PaintingBinding.instance.imageCache.evict(key));
      rethrow;
    } finally {
      unawaited(chunks.close());
    }
  }

  @override
  bool operator ==(Object other) =>
      other is ForumImageProvider &&
      other.url == url &&
      other.auth.siteUrl == auth.siteUrl &&
      other.scale == scale;

  @override
  int get hashCode => Object.hash(url, auth.siteUrl, scale);

  @override
  String toString() => '${objectRuntimeType(this, 'ForumImageProvider')}("$url", scale: $scale)';
}
