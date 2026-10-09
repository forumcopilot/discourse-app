import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/logo_tone.dart';

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
    this.background,
    this.designedFor = const Color(0xFFFFFFFF),
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final Widget Function(BuildContext) fallback;

  /// What the logo is drawn on, when that is not the forum's own header.
  /// Given it, a logo that would vanish there is helped — inverted if it is
  /// one-tone (a black wordmark on a dark card), on a small backing of its
  /// own tone if not; see [LogoTone.fixOn]. The logo waits for that
  /// measurement rather than flashing the wrong way.
  final Color? background;

  /// The background the logo was drawn for: the forum's header colour for
  /// this variant (white for most light-mode logos). The logo is only
  /// helped when it fares clearly worse on [background] than here, and a
  /// backing is drawn in this colour.
  final Color designedFor;

  static bool isSvg(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    return path.endsWith('.svg');
  }

  @override
  Widget build(BuildContext context) {
    final background = this.background;
    if (background == null || kIsWeb) return _image(context);
    if (LogoTone.isKnown(url)) {
      return _adapted(context, LogoTone.known(url), background);
    }
    return FutureBuilder<LogoTone?>(
      future: LogoTone.of(url),
      builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.done
              ? _adapted(context, snapshot.data, background)
              : SizedBox(width: width, height: height),
    );
  }

  Widget _adapted(BuildContext context, LogoTone? tone, Color background) {
    final image = _image(context);
    switch (tone?.fixOn(background, designedFor: designedFor) ?? LogoFix.none) {
      case LogoFix.none:
        return image;
      case LogoFix.invert:
        return ColorFiltered(colorFilter: LogoTone.invertLightness, child: image);
      case LogoFix.plate:
        // Hugs the artwork, even in a full-width slot: the logo keeps its
        // own aspect ratio inside the loose constraints Align gives it.
        return Align(
          alignment: alignment,
          widthFactor: 1,
          heightFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: designedFor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: image,
            ),
          ),
        );
    }
  }

  Widget _image(BuildContext context) {
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
