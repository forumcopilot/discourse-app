import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/models/entities/fc_forum.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import '../../theme/design_tokens.dart';
import '../../theme/style_builders.dart';
import '../../utils/safe_image.dart';
import '../../utils/avatar_color_utils.dart';
import 'forum_icon_widget.dart';
import '../../utils/discourse_color.dart';
import '../../theme/forum_brand_style.dart';
import 'category_badge.dart';

/// Widget that displays subforum icon, name, and description
/// Used in the subforum view page below the breadcrumb
class SubforumHeaderWidget extends StatelessWidget {
  final FCForum forum;
  final SiteContext? siteContext;

  const SubforumHeaderWidget({
    super.key,
    required this.forum,
    this.siteContext,
  });

  // The category's uploads for this page's mode: its dark-mode logo and
  // background when the admin made them.
  String? _logoUrl(bool dark) => siteContext == null
      ? forum.logoUrl
      : categoryLogoUrl(siteContext!, forum, dark: dark);
  String? _backgroundUrl(bool dark) => siteContext == null
      ? forum.backgroundUrl
      : categoryBackgroundUrl(siteContext!, forum, dark: dark);

  /// Gets the primary color for the background based on whether a logo is present
  /// If no logo, uses the avatar's base color to match the default logo
  Color _getBackgroundThemeColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // The category's own colour, when Discourse gave us one. This header
    // was tinting itself from a hash of the category *name*, so
    // Announcements (#ED207B, pink in the category list and on every
    // topic row) opened to a green banner — the same category wearing two
    // different colours one tap apart.
    final ownColor = parseDiscourseHex(forum.color ?? '');
    if (ownColor != null) return ownColor;

    // No colour set: fall back to the name-derived palette so the header
    // still matches the initial-letter tile beside it.
    if (forum.name.isEmpty) {
      return colorScheme.primary;
    }
    
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    
    // Get gradient colors to extract the base color family
    final gradientColors = AvatarColorUtils.getGradientColors(
      forum.name,
      isLightTheme: isLightTheme,
    );
    
    if (gradientColors.isEmpty) {
      return colorScheme.primary;
    }
    
    // Use the more saturated color from the gradient for background tinting
    // For light mode: gradient goes shade100 -> shade300, use shade300 (more visible)
    // For dark mode: gradient goes shade700 -> shade500, use shade500 (more vibrant)
    // This will create a cohesive look with the default avatar logo
    return gradientColors.length >= 2 ? gradientColors[1] : gradientColors[0];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // The category's colour as a gradient — the forum card's treatment, so
    // a forum's home and its categories read as one family. A configured
    // background photo sits under a page-coloured veil instead, and text
    // follows the page there.
    final backgroundUrl = _backgroundUrl(isDarkMode);
    final hasPhoto = (backgroundUrl ?? '').isNotEmpty;
    final style = ForumBrandStyle.forColor(
      _getBackgroundThemeColor(context),
      preferredText: parseDiscourseHex(forum.textColor ?? ''),
      brightness: Theme.of(context).brightness,
    );
    final fg = hasPhoto ? colorScheme.onSurface : style.foreground;
    final fgMuted = hasPhoto
        ? colorScheme.onSurfaceVariant
        : style.foreground.withValues(alpha: DesignTokens.opacityHigh);

    return ClipRect(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: DesignTokens.opacityMediumLow),
              width: DesignTokens.borderWidthThin,
            ),
          ),
        ),
        child: Stack(
          children: [
            // Background Image - covers full height, clipped to container bounds
            Positioned.fill(
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                        decoration: BoxDecoration(gradient: style.gradient)),
                    // Network background (only shown if URL exists and loads successfully)
                    Builder(
                      builder: (context) {
                        if (backgroundUrl != null && backgroundUrl.isNotEmpty) {
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              // Network background image
                              SafeImageNetwork.networkSafe(
                                backgroundUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  // Return empty container when network image fails - default background will show
                                  return Container();
                                },
                              ),
                              // Color overlay for better text readability
                              Container(
                                color: isDarkMode 
                                  ? Colors.black.withValues(alpha: DesignTokens.opacityMediumLow)
                                  : Colors.white.withValues(alpha: DesignTokens.opacityHigh),
                              ),
                            ],
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Content - Centered icon, name, and description
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingL,
                vertical: DesignTokens.spacingXL,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Centered icon
                  ForumListItemIconWidget(
                    logoUrl: _logoUrl(isDarkMode),
                    fallbackIcon: Icons.forum_rounded,
                    forumName: forum.name,
                    // On the category's own colour now, so a translucent
                    // disc of the text colour sets the mark apart.
                    backgroundColor: fg.withValues(alpha: 0.16),
                    iconColor: fg,
                  ),
                  // Spacing between icon and name
                  const SizedBox(height: DesignTokens.spacingL),
                  // Subforum name
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      forum.name,
                      style: StyleBuilders.titleTextStyle(
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        fontSize: DesignTokens.fontSizeXL,
                        fontWeight: DesignTokens.fontWeightSemiBold,
                      ).copyWith(color: fg),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Description (if available)
                  if (forum.description != null && forum.description!.isNotEmpty) ...[
                    const SizedBox(height: DesignTokens.spacingM),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingL),
                      child: Text(
                        forum.description!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: fgMuted,
                          height: DesignTokens.lineHeightRelaxed,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

