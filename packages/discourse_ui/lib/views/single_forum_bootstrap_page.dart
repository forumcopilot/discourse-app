import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/models/domain/site.dart';
import 'package:get/get.dart';
import 'package:discourse_ui/config/app_forum_config.dart';
import 'package:discourse_ui/controllers/global_loader_controller.dart';
import 'package:discourse_ui/controllers/login_controller.dart';
import 'package:discourse_ui/controllers/site_controller.dart';
import 'package:discourse_ui/controllers/topic_controller.dart';
import 'package:discourse_ui/services/user_state_service.dart';
import 'package:discourse_ui/views/site_home_page.dart';
import 'package:discourse_ui/services/site_initialization_service.dart';
import 'package:discourse_ui/views/widgets/progress_dialog.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';

class SingleForumBootstrapPage extends StatefulWidget {
  /// Site to connect to. When null (the standalone single-forum app),
  /// the compile-time [AppForumConfig] binding is used. Host apps that
  /// manage multiple sites pass the tapped site in.
  final Site? site;

  const SingleForumBootstrapPage({super.key, this.site});

  @override
  State<SingleForumBootstrapPage> createState() =>
      _SingleForumBootstrapPageState();
}

class _SingleForumBootstrapPageState extends State<SingleForumBootstrapPage> {
  bool _isInitializing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _ensureModuleSingletons();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForum();
    });
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

    final site = widget.site ?? AppForumConfig.buildSite();
    final domain = Uri.tryParse(site.url)?.host ?? site.url;
    final progress = ProgressDialog.showWithUpdater(
      context,
      'Connecting to $domain...',
    );

    try {
      final result = await SiteInitializationService.initializeSite(
        site,
        onProgress: (message) {
          progress.messageNotifier.value = message;
        },
      );

      await progress.close();

      if (!mounted) return;

      if (result.success && result.siteContext != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const SiteHomePage(siteToInitialize: null),
          ),
        );
        return;
      }

      setState(() {
        _errorMessage = result.errorMessage ?? 'Failed to connect to forum.';
      });
    } catch (error, stackTrace) {
      await progress.close();
      if (!mounted) return;

      AppLogger.error(
        'Single forum bootstrap initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final configuredSite = widget.site ?? AppForumConfig.buildSite();
    final configuredDomain =
        Uri.tryParse(configuredSite.url)?.host ?? configuredSite.url;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: 56,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    configuredSite.name,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    configuredDomain,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  if (_isInitializing) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Initializing forum…',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ] else ...[
                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],
                    FilledButton.icon(
                      onPressed: _initializeForum,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry Connection'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
