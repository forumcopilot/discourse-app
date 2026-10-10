import 'package:flutter/material.dart';

import '../../utils/avatar_color_utils.dart';
import '../../utils/initials.dart';
import 'brand_image.dart';

/// A forum's square logo as a tile, corners 28% of the side: in its header
/// once the header has scrolled up, and in the drawer. A transparent logo
/// sits on white, as it was drawn to; a forum with no logo gets its initial
/// on a colour from its name.
class ForumIconTile extends StatelessWidget {
  const ForumIconTile({
    super.key,
    required this.name,
    this.url,
    this.size = 28,
  });

  final String name;
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.28);
    Widget initial(BuildContext context) {
      final light = Theme.of(context).brightness == Brightness.light;
      final colors =
          AvatarColorUtils.getGradientColors(name, isLightTheme: light);
      final text = AvatarColorUtils.getUserAvatarColorScheme(name,
          isLightTheme: light)['text']!;
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: Center(
          child: Text(
            initialOf(name, fallback: 'F'),
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.w600,
              fontSize: size * 0.5,
            ),
          ),
        ),
      );
    }

    final url = this.url;
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: size,
        height: size,
        color: Colors.white,
        foregroundDecoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: url == null || url.isEmpty
            ? initial(context)
            : BrandImage(
                url,
                width: size,
                height: size,
                fit: BoxFit.contain,
                alignment: Alignment.center,
                fallback: initial,
              ),
      ),
    );
  }
}
