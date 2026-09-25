import 'package:flutter/material.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities;
import 'package:get/get.dart';
import 'package:discourse_ui/controllers/site_controller.dart';
import 'package:discourse_ui/utils/number_utils.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart' as forumcopilot_sdk;
import 'package:discourse_ui/utils/safe_image.dart';
import 'package:discourse_ui/utils/avatar_color_utils.dart';
import '../../theme/design_tokens.dart';
import '../../services/forum_theme.dart';
import '../../theme/forum_brand_style.dart';
import 'brand_image.dart';
import '../../utils/initials.dart';

class ForumHeaderWidget extends StatelessWidget {
  final forumcopilot_sdk.FCBoardStatResult? boardStats;
  final bool extendUnderAppBar;

  /// Drawn until the site controller has a current site: the forum being
  /// opened, while it is still initializing. A header given one also keeps
  /// room for the stats it does not have yet.
  final forumcopilot_sdk.Site? pendingSite;

  const ForumHeaderWidget({
    Key? key,
    this.boardStats,
    this.extendUnderAppBar = false,
    this.pendingSite,
  }) : super(key: key);

  String? _getDomain(String? url) {
    if (url == null || url.isEmpty) return null;
    try {
      final uri = Uri.parse(url);
      return uri.host.isNotEmpty ? uri.host : null;
    } catch (e) {
      return null;
    }
  }

  /// The wordmark, contained, at header height — never squeezed into a
  /// square. Falls back to the square tile when the forum has no wide logo.
  Widget _buildLogoBlock(BuildContext context, String? wideLogo,
      String? squareLogo, String siteName, Color cardColor,
      DiscourseSiteCapabilities caps) {
    if (wideLogo != null && wideLogo.isNotEmpty) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 44, maxWidth: 260),
        child: BrandImage(
          wideLogo,
          height: 44,
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
          // Drawn straight on the card, so it must read on the card.
          background: cardColor,
          designedFor: ForumBrandStyle.logoDesignedFor(caps, wideLogo),
          fallback: (context) =>
              _buildLogoTile(context, squareLogo, siteName, caps),
        ),
      );
    }
    return _buildLogoTile(context, squareLogo, siteName, caps);
  }

  /// Where the logo will go, at the wordmark's height: most forums have one,
  /// and [_buildLogoBlock] draws it 44 tall.
  Widget _buildLogoPlaceholder(BuildContext context) {
    return Container(
      width: 132,
      height: 44,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
      ),
    );
  }

  Widget _buildLogoTile(BuildContext context, String? logoUrl, String siteName,
      DiscourseSiteCapabilities caps) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: DesignTokens.opacityLow),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        child: _buildLogoContent(context, logoUrl, siteName, caps),
      ),
    );
  }

  Widget _buildLogoContent(BuildContext context, String? logoUrl,
      String siteName, DiscourseSiteCapabilities caps) {
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return BrandImage(
        logoUrl,
        width: 60,
        height: 60,
        // The tile is the page colour (see _buildLogoTile).
        background: Theme.of(context).colorScheme.surface,
        designedFor: ForumBrandStyle.logoDesignedFor(caps, logoUrl),
        // contain, not cover: a forum logo is artwork with a fixed aspect
        // ratio, and cropping it to fill a square cuts the wordmark in half.
        fit: BoxFit.contain,
        alignment: Alignment.center,
        fallback: (context) => _buildInitialAvatar(context, siteName),
      );
    }
    return _buildInitialAvatar(context, siteName);
  }

  Widget _buildInitialAvatar(BuildContext context, String siteName) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    
    // Get color scheme for the site name
    final avatarColors = AvatarColorUtils.getUserAvatarColorScheme(
      siteName,
      isLightTheme: isLightTheme,
    );
    
    // Generate gradient colors from the base color
    final gradientColors = AvatarColorUtils.getGradientColors(
      siteName,
      isLightTheme: isLightTheme,
    );
    
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Center(
        child: Text(
          initialOf(siteName, fallback: 'F'),
          style: TextStyle(
            color: avatarColors['text']!,
            fontWeight: DesignTokens.fontWeightSemiBold,
            fontSize: 30, // 60 * 0.5
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final siteController = Get.put(DiscourseSiteController());

    return Obx(() {
      final site = siteController.currentSite.value ?? pendingSite;
      // The forum's own logo, from /site/settings.json. AppForumConfig
      // ships logoUrl as null — a fork is expected to hardcode one — so
      // without this the header always fell back to a generated initial
      // tile even though the server had been handing us the real logo all
      // along, on a payload already being read for the upload limits.
      // A hardcoded config value still wins: that is the fork's override.
      final configuredLogo = site?.logoUrl;
      // The square logo sits on its own page-coloured tile.
      final logoUrl = (configuredLogo != null && configuredLogo.isNotEmpty)
          ? configuredLogo
          : DiscourseSiteCapabilities.forSite(site?.pluginUrl ?? '').logoFor(
              dark: isDarkMode,
            );
      final siteName = site?.name ?? (AppLocalizations.of(context)?.forum ?? 'Forum');
      // The forum's identity card: its wordmark on a gradient in its own
      // colour — its web header when that is branded, else its accent
      // (ForumBrandStyle). Colours come from the theme, which is the forum's
      // own scheme inside a forum; logos from /site/settings.json.
      final caps = DiscourseSiteCapabilities.forSite(site?.pluginUrl ?? '');
      final brand = ForumBrandStyle.of(context);
      // The forum being opened, before its config has said how it looks.
      // Draw the header's shape rather than guess at its brand: a generated
      // initial on a name-tinted pattern would flash up, then be replaced by
      // the real wordmark on the real colour.
      final awaitingBrand = pendingSite != null && !caps.resolved;
      // A remembered palette already knows the card's colour; only the
      // logo is still to come.
      final colourKnown = !awaitingBrand ||
          ForumTheme.paletteFor(site?.pluginUrl ?? '') != null;
      // Wordmarks are transparent artwork drawn for one background, so the
      // variant follows the card, not the app's mode: the dark-mode logo
      // on a dark card, the normal one on a light card. One that still
      // would not show (a forum with no dark logo) is inverted by
      // BrandImage.
      final wideLogo = (configuredLogo != null && configuredLogo.isNotEmpty)
          ? configuredLogo
          : caps.wideLogoFor(dark: brand.isDark);
      // A host-configured banner photo sits under a page-coloured veil
      // (below), so text and logo belong to the page there, not the brand.
      final hasBanner = (site?.backgroundUrl ?? '').isNotEmpty;
      final cardColor = hasBanner ? colorScheme.surface : brand.base;
      final fg = hasBanner ? colorScheme.onSurface : brand.foreground;
      final domain = _getDomain(site?.url);
      final statsLineStyle = TextStyle(
        color: fg.withValues(alpha: DesignTokens.opacityHigh),
        fontWeight: DesignTokens.fontWeightMedium,
        fontSize: DesignTokens.fontSizeXS,
      );

      // Calculate padding based on whether it should extend under app bar
      final topPadding = extendUnderAppBar ? DesignTokens.spacingXL : DesignTokens.spacingL;
      final bottomPadding = DesignTokens.spacingL;

      // The Stack sizes itself to its one non-positioned child (the
      // content column); the background is Positioned.fill. The
      // IntrinsicHeight that used to wrap this forced a second layout
      // pass over the whole header on every rebuild for the same result.
      return ClipRect(
          child: Container(
            width: double.infinity,
            child: Stack(
              children: [
                // Background Image - covers full height, clipped to container bounds
                Positioned.fill(
                  child: ClipRect(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                    // The forum's colour, as a gradient; a quiet placeholder
                    // while a forum opened for the first time has not yet
                    // said what its colour is.
                    colourKnown
                        ? DecoratedBox(
                            decoration: BoxDecoration(gradient: brand.gradient))
                        : ColoredBox(color: colorScheme.surfaceContainerLow),
                    // Network background (only shown if URL exists and loads successfully)
                    Builder(
                      builder: (context) {
                        final backgroundUrl = site?.backgroundUrl;
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
                                  ? Colors.black.withValues(alpha: 0.5)
                                  : Colors.white.withValues(alpha: 0.7),
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
                // Forum Logo and Name - Left aligned
                Padding(
                padding: EdgeInsets.only(
                  left: DesignTokens.paddingScreenHorizontal.left,
                  right: DesignTokens.paddingScreenHorizontal.right,
                  top: topPadding,
                  bottom: bottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    awaitingBrand
                        ? _buildLogoPlaceholder(context)
                        : _buildLogoBlock(context, wideLogo, logoUrl,
                            siteName, cardColor, caps),
                    SizedBox(height: DesignTokens.spacingS),
                    Text(
                      site?.name ?? 'Forum',
                      style: TextStyle(
                        color: fg,
                        fontWeight: DesignTokens.fontWeightBold,
                        fontSize: DesignTokens.fontSizeL,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (domain != null) ...[
                      SizedBox(height: DesignTokens.spacingXS / 2),
                      Text(
                        domain,
                        style: TextStyle(
                          color: fg.withValues(alpha: DesignTokens.opacityMedium),
                          fontSize: DesignTokens.fontSizeS,
                          fontWeight: DesignTokens.fontWeightNormal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: DesignTokens.spacingS),
                    // Forum Description
                    Text(
                      site?.description ?? 'No description available.',
                      style: TextStyle(
                        color: fg.withValues(alpha: DesignTokens.opacityHigh),
                        fontSize: DesignTokens.fontSizeS,
                        fontWeight: DesignTokens.fontWeightMedium,
                      ),
                      textAlign: TextAlign.left,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: DesignTokens.spacingS),
                    // Forum Statistics - Separate lines
                    if (boardStats != null && ((boardStats?.total_posts ?? 0) > 0 || (boardStats?.total_members ?? 0) > 0)) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((boardStats?.total_posts ?? 0) > 0)
                            Text(
                              AppLocalizations.of(context)!.postsCount(formatNumber(context, boardStats?.total_posts ?? 0)),
                              style: statsLineStyle,
                              textAlign: TextAlign.left,
                            ),
                          if ((boardStats?.total_posts ?? 0) > 0 && (boardStats?.total_members ?? 0) > 0)
                            SizedBox(height: DesignTokens.spacingXS / 2),
                          if ((boardStats?.total_members ?? 0) > 0)
                            Text(
                              AppLocalizations.of(context)?.membersCount(boardStats?.total_members ?? 0) ?? '${formatNumber(context, boardStats?.total_members ?? 0)} Members',
                              style: statsLineStyle,
                              textAlign: TextAlign.left,
                            ),
                        ],
                      ),
                    ] else if (pendingSite != null && boardStats == null) ...[
                      // Room for the two stats lines. The forum's home has
                      // them from its first frame (they come from the
                      // /about.json the initialization has just read), so
                      // a placeholder without them would jump when it hands
                      // over.
                      Visibility(
                        visible: false,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: Column(
                          children: [
                            Text('0', style: statsLineStyle),
                            SizedBox(height: DesignTokens.spacingXS / 2),
                            Text('0', style: statsLineStyle),
                          ],
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
    });
  }
}
