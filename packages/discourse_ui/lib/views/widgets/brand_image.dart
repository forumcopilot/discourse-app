import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/safe_image.dart';

/// A forum's logo from the network, whatever format the admin uploaded.
///
/// Discourse serves wordmarks and icons as PNG, JPEG or — for a good share
/// of forums — SVG, which the plain image widget cannot decode and silently
/// turns into the fallback initial. Picks the decoder from the URL.
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
    if (isSvg(url)) {
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
    return SafeImageNetwork.networkSafe(
      url,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: (context, _, __) => fallback(context),
    );
  }
}
