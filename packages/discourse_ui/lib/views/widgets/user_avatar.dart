import 'package:flutter/material.dart';
import 'package:discourse_ui/views/widgets/cached_redirect_image.dart';
import 'package:discourse_ui/utils/avatar_color_utils.dart';

class UserAvatar extends StatelessWidget {
  final String username;
  final String? iconUrl;
  final double radius;
  final VoidCallback? onTap;
  final bool showOnlineIndicator;
  final bool isOnline;
  final double onlineIndicatorSizeMultiplier;
  final String? cacheKey;

  const UserAvatar({
    super.key,
    required this.username,
    this.iconUrl,
    this.radius = 20,
    this.onTap,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.onlineIndicatorSizeMultiplier = 0.4,
    this.cacheKey,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    // Get dynamic colors for the user
    final avatarColors = AvatarColorUtils.getUserAvatarColorScheme(
      username,
      isLightTheme: isLightTheme,
    );
    
    // Get gradient colors for the avatar background
    final gradientColors = AvatarColorUtils.getGradientColors(
      username,
      isLightTheme: isLightTheme,
    );

    // Calculate cache size based on display size and device pixel ratio
    final displaySize = radius * 2;
    final cacheSize = (displaySize * devicePixelRatio).round();

    Widget avatar = (iconUrl != null && iconUrl!.isNotEmpty)
        ? ClipOval(
            child: SizedBox(
              width: radius * 2,
              height: radius * 2,
              child: CachedRedirectImage(
                imageUrl: iconUrl!,
                fit: BoxFit.cover,
                cacheKey: cacheKey,
                cacheWidth: cacheSize,
                cacheHeight: cacheSize,
                // A flat tinted disc. The shimmer it replaces ran an
                // animation controller per avatar until the image landed.
                placeholder: (context, url) => Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avatarColors['background'],
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '?',
                    style: textTheme.titleMedium?.copyWith(
                      color: avatarColors['text']!,
                      fontWeight: FontWeight.w600,
                      fontSize: radius,
                    ),
                  ),
                ),
              ),
            ),
          )
        : Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : '?',
              style: textTheme.titleMedium?.copyWith(
                color: avatarColors['text']!,
                fontWeight: FontWeight.w600,
                fontSize: radius,
              ),
            ),
          );

    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    if (showOnlineIndicator) {
      return Stack(
        children: [
          avatar,
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: radius * onlineIndicatorSizeMultiplier,
                height: radius * onlineIndicatorSizeMultiplier,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.surface,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 2,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    return avatar;
  }
}
