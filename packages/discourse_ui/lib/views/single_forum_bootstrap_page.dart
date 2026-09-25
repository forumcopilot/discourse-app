import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/domain/site.dart';
import 'package:get/get.dart';
import 'package:discourse_ui/config/app_forum_config.dart';
import 'package:discourse_ui/controllers/global_loader_controller.dart';
import 'package:discourse_ui/controllers/login_controller.dart';
import 'package:discourse_ui/controllers/site_controller.dart';
import 'package:discourse_ui/controllers/topic_controller.dart';
import 'package:discourse_ui/services/user_state_service.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/theme/design_tokens.dart';
import 'package:discourse_ui/views/appbars/topics_tab_app_bar.dart';
import 'package:discourse_ui/views/site_home_page.dart';
import 'package:discourse_ui/services/site_initialization_service.dart';
import 'package:discourse_ui/services/discourse_route_navigator.dart';
import 'package:discourse_ui/services/forum_theme.dart';
import 'package:discourse_ui/services/notification_route.dart';
import 'package:discourse_ui/views/widgets/forum_header_widget.dart';
import 'package:discourse_ui/views/widgets/topic_list_skeleton.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';
import '../l10n/generated/app_localizations.dart';

/// Opens a forum.
///
/// While the forum initializes, this draws what its home will look like —
/// header, topic filters, topic list — as placeholders, and then swaps the
/// real [SiteHomePage] in on the same route. Opening a forum reads as one
/// screen filling in, rather than a loading screen followed by another.
class SingleForumBootstrapPage extends StatefulWidget {
  /// Site to connect to. When null (the standalone single-forum app),
  /// the compile-time [AppForumConfig] binding is used. Host apps that
  /// manage multiple sites pass the tapped site in.
  final Site? site;

  /// Where to take the reader once the forum is open — a topic or a post,
  /// when the host opened the forum from a link. The forum's home is
  /// underneath it, so Back lands there. Null opens the home.
  final DiscourseNotificationRoute? route;

  const SingleForumBootstrapPage({super.key, this.site, this.route});

  @override
  State<SingleForumBootstrapPage> createState() =>
      _SingleForumBootstrapPageState();
}

class _SingleForumBootstrapPageState extends State<SingleForumBootstrapPage> {
  late final Site _site = widget.site ?? AppForumConfig.buildSite();
  late final SiteContext _placeholderContext =
      SiteContext(siteType: _site.siteType, site: _site);

  bool _isInitializing = false;
  bool _ready = false;
  String? _errorMessage;
  bool _unreachable = false;
  bool _routeOpened = false;

  @override
  void initState() {
    super.initState();
    _ensureModuleSingletons();
    // The forum's colours from the first frame when they are remembered;
    // refreshed from /site.json once it opens.
    ForumTheme.enter(_site.pluginUrl);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForum();
    });
  }

  @override
  void dispose() {
    ForumTheme.leave(_site.pluginUrl);
    super.dispose();
  }

  /// The standalone app registers these in its own main/root widget; a
  /// host app enters the Discourse module here, so make registration
  /// idempotent at the module boundary.
  ///
  /// When the module is re-entered for a DIFFERENT site (multi-forum
  /// hosts), every singleton that carries per-site state must be
  /// dropped first, or the previous forum's branding/session leaks
  /// into the new one (e.g. the drawer header showing the old forum).
  void _ensureModuleSingletons() {
    final incoming = widget.site;
    if (incoming != null && Get.isRegistered<DiscourseSiteController>()) {
      final bound = Get.find<DiscourseSiteController>().currentSite.value;
      if (bound != null && bound.url != incoming.url) {
        Get.delete<DiscourseLatestTopicController>(force: true);
        Get.delete<DiscourseUnreadTopicController>(force: true);
        Get.delete<DiscourseSubscribedTopicController>(force: true);
        Get.delete<DiscourseParticipatedTopicController>(force: true);
        Get.delete<DiscourseLoginController>(force: true);
        Get.delete<DiscourseSiteController>(force: true);
      }
    }
    if (!Get.isRegistered<DiscourseUserStateService>()) {
      Get.put(DiscourseUserStateService());
    }
    if (!Get.isRegistered<DiscourseGlobalLoaderController>()) {
      Get.put(DiscourseGlobalLoaderController());
    }
    if (!Get.isRegistered<DiscourseSiteController>()) {
      Get.put(DiscourseSiteController());
    }
  }

  Future<void> _initializeForum() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      final result = await SiteInitializationService.initializeSite(_site);
      if (!mounted) return;

      if (result.success && result.siteContext != null) {
        ForumTheme.updateFromCapabilities(_site.pluginUrl);
        setState(() => _ready = true);
        _openRoute(result.siteContext!);
        return;
      }

      setState(() {
        _errorMessage = result.errorMessage ?? 'Failed to connect to forum.';
        _unreachable = result.unreachable;
      });
    } catch (error, stackTrace) {
      if (!mounted) return;

      AppLogger.error(
        'Single forum bootstrap initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
      setState(() {
        _errorMessage = error.toString();
        _unreachable = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  /// Opens [SingleForumBootstrapPage.route] over the home, once: after a
  /// failed first attempt it waits for the Retry that succeeds.
  void _openRoute(SiteContext siteContext) {
    final route = widget.route;
    if (route == null || _routeOpened) return;
    _routeOpened = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      DiscourseRouteNavigator.open(siteContext, route);
    });
  }

  @override
  Widget build(BuildContext context) {
    final home = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      // The home fades in over the placeholder, which stays opaque beneath
      // it. Fading both would let the route underneath show through halfway.
      transitionBuilder: (child, animation) => child is SiteHomePage
          ? FadeTransition(opacity: animation, child: child)
          : child,
      child: _ready
          ? const SiteHomePage(siteVerified: true)
          : _ForumEntryPlaceholder(
              site: _site,
              siteContext: _placeholderContext,
              errorMessage: _isInitializing ? null : _errorMessage,
              unreachable: _unreachable,
              onRetry: _initializeForum,
            ),
    );
    // The app-wide theme follows ForumTheme a frame later (it cannot change
    // mid-build); this page wears the forum's colours from its first frame,
    // and keeps them while it animates out after leave().
    // Always wrapped, so the palette arriving does not reshape the tree
    // and rebuild the home from scratch.
    final palette = ForumTheme.paletteFor(_site.pluginUrl);
    return Theme(
      data: palette == null
          ? Theme.of(context)
          : AppTheme.themeFor(Theme.of(context).brightness, palette),
      child: home,
    );
  }
}

/// [SiteHomePage]'s first frame, before the forum has answered: the same app
/// bar and header, the filter bar and topic list as placeholders — or, when
/// the forum could not be reached, why, with a way to try again.
class _ForumEntryPlaceholder extends StatelessWidget {
  const _ForumEntryPlaceholder({
    required this.site,
    required this.siteContext,
    required this.errorMessage,
    required this.unreachable,
    required this.onRetry,
  });

  final Site site;
  final SiteContext siteContext;
  final String? errorMessage;
  final bool unreachable;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final error = errorMessage;
    // The home's leading slot holds its drawer button. A pushed route keeps
    // its back button meanwhile, so a slow forum can still be left; a root
    // route reserves the slot, so the title does not jump when the home
    // takes over.
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    return Scaffold(
      appBar: TopicsTabAppBar(
        siteContext: siteContext,
        leading: canPop
            ? null
            : const IconButton(onPressed: null, icon: Icon(Icons.menu)),
      ),
      body: Column(
        children: [
          ForumHeaderWidget(pendingSite: site, extendUnderAppBar: true),
          if (error == null) ...[
            const _FilterBarPlaceholder(),
            Expanded(
              child: Semantics(
                label: AppLocalizations.of(context)!.initializingForum,
                liveRegion: true,
                child: const ExcludeSemantics(child: TopicListSkeleton()),
              ),
            ),
          ] else
            Expanded(
              child: _ConnectionError(
                site: site,
                message: error,
                unreachable: unreachable,
                onRetry: onRetry,
              ),
            ),
        ],
      ),
    );
  }
}

/// [FilterChipBar]'s footprint. Which filters a forum offers is part of what
/// is still loading, so the chips are drawn as blocks.
class _FilterBarPlaceholder extends StatelessWidget {
  const _FilterBarPlaceholder();

  static const _chipWidths = [86.0, 66.0, 71.0, 90.0];

  @override
  Widget build(BuildContext context) {
    final block = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingL,
        vertical: DesignTokens.spacingM,
      ),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          // Latest, Hot, New, Unread as FilterChipBar draws them in
          // English, so the fade to the real bar lines up.
          itemCount: _chipWidths.length,
          separatorBuilder: (_, __) => SizedBox(width: DesignTokens.spacingS),
          itemBuilder: (_, index) => Center(
            child: Container(
              width: _chipWidths[index],
              height: 38,
              decoration: BoxDecoration(
                color: block,
                borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConnectionError extends StatelessWidget {
  const _ConnectionError({
    required this.site,
    required this.message,
    required this.unreachable,
    required this.onRetry,
  });

  final Site site;
  final String message;

  /// The forum did not answer, so the likely fix is the user's connection.
  final bool unreachable;
  final VoidCallback onRetry;

  /// The service reports `Exception: Failed to connect to forum: <reason>`,
  /// and the heading above the reason already says the first half.
  static String _reason(String raw) {
    var text = raw;
    for (final prefix in const ['Exception: ', 'Failed to connect to forum: ']) {
      if (text.startsWith(prefix)) text = text.substring(prefix.length);
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Offline is worth a sentence in the user's language. Anything else is
    // a failure they cannot act on beyond Retry; its English reason is kept
    // for debug builds.
    final detail = unreachable
        ? l10n.checkConnectionAndRetry
        : (kDebugMode ? _reason(message) : null);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.failedToConnectToSiteName(site.name),
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              if (detail != null) ...[
                const SizedBox(height: 8),
                Text(
                  detail,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retryConnection),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
