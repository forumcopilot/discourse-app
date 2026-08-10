import 'package:flutter/material.dart';

import 'cached_redirect_image.dart';

/// A circular remote image with a fallback that also covers *failure*, not
/// just absence.
///
/// Replaces `CircleAvatar(backgroundImage: NetworkImage(url))`, which has no
/// error path: its `child` renders only when you pass no image at all, so a
/// URL that is present but undecodable leaves a blank circle. Discourse
/// serves SVG for some avatars and most badge images, and Flutter's raster
/// codec cannot decode them — meta.discourse.org's user directory hits this
/// on the "Discourse" account. The decode threw all the way out to
/// `FlutterError.onError`, which pops a modal error dialog in debug builds.
///
/// Also routes through [CachedRedirectImage] rather than `NetworkImage`, so
/// these images get the same disk cache, cookie headers and redirect
/// following as every other image in the app.
class RemoteCircleAvatar extends StatelessWidget {
  const RemoteCircleAvatar({
    super.key,
    required this.radius,
    required this.backgroundColor,
    required this.fallback,
    this.imageUrl,
  });

  final double radius;
  final Color backgroundColor;

  /// Shown when there is no URL, when the fetch fails, and when the bytes
  /// will not decode. Callers pass their own so a group keeps its group
  /// glyph and a badge keeps its trophy.
  final Widget fallback;

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    Widget circle(Widget child) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: child,
        );

    final url = imageUrl;
    if (url == null || url.isEmpty) return circle(fallback);

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: CachedRedirectImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, __) => circle(const SizedBox.shrink()),
          errorWidget: (_, __, ___) => circle(fallback),
        ),
      ),
    );
  }
}
