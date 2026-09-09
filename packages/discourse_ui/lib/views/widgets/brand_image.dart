import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A forum's logo from the network, whatever format the admin uploaded.
///
/// Discourse serves wordmarks and icons as PNG, JPEG or — for a good share
/// of forums — SVG, which the plain image widget cannot decode and silently
/// turns into the fallback initial. Picks the decoder from the URL.
///
/// Both paths go through the on-disk cache (`flutter_cache_manager`, thirty
/// days), because a multi-forum host paints hundreds of these on its
/// directory screens and re-downloading every logo on every launch is both
/// slow and rude to the forums. Raster images use `CachedNetworkImage`;
/// SVGs are fetched as a file through the same cache and decoded locally.
/// On web there is no file system, so SVGs fall back to the plain network
/// loader (the browser cache covers that case).
class BrandImage extends StatelessWidget {
  const BrandImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.centerLeft,
    required this.fallback,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final Widget Function(BuildContext) fallback;

  static bool isSvg(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    return path.endsWith('.svg');
  }

  @override
  Widget build(BuildContext context) {
    if (isSvg(url)) return _svg(context);
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: (_, __) => SizedBox(width: width, height: height),
      errorWidget: (context, _, __) => fallback(context),
    );
  }

  Widget _svg(BuildContext context) {
    if (kIsWeb) {
      return SvgPicture.network(
        url,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        placeholderBuilder: (_) => SizedBox(width: width, height: height),
        errorBuilder: (context, _, __) => fallback(context),
      );
    }
    return FutureBuilder<File>(
      future: DefaultCacheManager().getSingleFile(url),
      builder: (context, snapshot) {
        if (snapshot.hasError) return fallback(context);
        final file = snapshot.data;
        if (file == null) return SizedBox(width: width, height: height);
        return SvgPicture.file(
          file,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          errorBuilder: (context, _, __) => fallback(context),
        );
      },
    );
  }
}
