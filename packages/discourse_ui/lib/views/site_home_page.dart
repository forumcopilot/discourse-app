import 'dart:math' as math;
import '../services/chat_unread.dart';

import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:discourse_ui/controllers/site_controller.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/models/domain/site.dart';
import 'package:forumcopilot_sdk/models/results/fc_forum_result.dart';
import 'package:forumcopilot_sdk/models/results/fc_private_conversation_result.dart';
import 'package:get/get.dart';
import 'package:discourse_core/discourse_core.dart';
import '../theme/design_tokens.dart';
import 'appbars/forum_app_bar.dart';
import 'appbars/topics_tab_app_bar.dart';
import 'appbars/messages_tab_app_bar.dart';
import 'appbars/notifications_tab_app_bar.dart';
import 'appbars/profile_tab_app_bar.dart';
import 'chat/chat_channel_list_page.dart';
import 'forum_topics_page.dart';
import 'new_topic_page.dart';
import 'tabs/topic_list_tab.dart';
import 'tabs/notification_list_tab.dart';
import 'tabs/privatemessage_list_tab.dart';
import 'tabs/profile_tab.dart';
import 'private_messaging/conversation/pages/new_conversation_page.dart';
import 'widgets/category_picker_sheet.dart';
import 'widgets/resettable_widget.dart';
import 'widgets/drawer_introduction.dart';
import 'widgets/site_drawer.dart';
import 'site_home_tab.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';
import 'package:discourse_ui/core/async/async_utils.dart';
import 'dart:async';
import 'package:discourse_ui/utils/app_navigation.dart';
import '../l10n/kit_strings.dart';

class SiteHomePage extends StatefulWidget {
  final Site? siteToInitialize;
  final bool showGlobalLoader;

  /// Tab to open on, instead of the topic feed. Honoured once that tab
  /// exists — the notifications tab only appears after the forum's config
  /// arrives — and ignored on a forum that does not have it.
  final SiteHomeTab? initialTab;

  /// True when the caller has just initialized the site, as
  /// [SingleForumBootstrapPage] does. The page then opens on the site
  /// controller's context straight away, instead of fetching the forum's
  /// config a second time behind an empty scaffold.
  final bool siteVerified;

  const SiteHomePage({
    super.key,
    this.siteToInitialize,
    this.showGlobalLoader = true,
    this.initialTab,
    this.siteVerified = false,
  });

  // Static flag to trigger autoShowLogin in ProfileTab after registration
  static bool triggerProfileAutoLogin = false;

  @override
  State<SiteHomePage> createState() => _SiteHomePageState();
}

class _SiteHomePageState extends State<SiteHomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  int _previousTabIndex = 0;

  /// True when the user is looking at private messages. The
  /// new-conversation button keys off this.
  bool get _isViewingMessages => _isCurrentTab(_messagesTab);

  // Add keys for each tab
  GlobalKey<TopicListTabState> _topicListKey = GlobalKey();
  GlobalKey<PrivateMessageListTabState> _pmListKey = GlobalKey();
  GlobalKey<NotificationListTabState> _notificationTabKey = GlobalKey();
  GlobalKey<ProfileTabState> _profileTabKey = GlobalKey();
  GlobalKey<ChatChannelListPageState> _chatListKey = GlobalKey();

  // Add workers to listen for auth or forum changes
  Worker? _siteWorker;
  SiteContext? _siteContext;
  SiteContext? _listenedContext;

  // Store listener callbacks so we can remove them in dispose
  VoidCallback? _loginStateListener;

  // Track if we need to wait for initialization
  bool _waitingForInitialization = false;

  // Track unread conversations count for badge
  int _unreadConversationsCount = 0;

  // Track unread alerts count for badge
  int _unreadAlertsCount = 0;

  // Shared board stats for both Topics and Forums tabs
  FCBoardStatResult? _boardStats;

  // Track last logged values to reduce debug noise
  int? _lastLoggedTabCount;
  int? _lastLoggedTabIndex;
  bool? _lastLoggedShouldShowFAB;

  // Track last stable login state to prevent rebuilds from temporary API fluctuations
  bool? _lastStableLoginState;
  Timer? _loginStateDebounceTimer;

  // Helper method to get tab count
  int get _tabCount {
    return _enabledTabs.length;
  }

  /// A tab this page has been asked to open on but could not yet — the tab
  /// may not exist until the forum's config has been read. Cleared once
  /// applied.
  SiteHomeTab? _pendingTab;
  Worker? _requestedTabWorker;

  String? _tabIdFor(SiteHomeTab tab) {
    switch (tab) {
      case SiteHomeTab.topics:
      // Categories is one of Home's views (see _applyPendingTab).
      case SiteHomeTab.categories:
        return _topicsTab;
      case SiteHomeTab.inbox:
        return _isChatEnabled ? _chatTab : _messagesTab;
      case SiteHomeTab.messages:
        return _messagesTab;
      case SiteHomeTab.notifications:
        return _notificationsTab;
      case SiteHomeTab.profile:
        return _profileTab;
    }
  }

  /// Switch to [_pendingTab] if the forum has it. Called after every change
  /// to the tab set, because the request usually arrives before the tabs do.
  void _applyPendingTab() {
    final pending = _pendingTab;
    if (pending == null || !mounted) return;

    final id = _tabIdFor(pending);
    final index = id == null ? -1 : _enabledTabs.indexOf(id);
    // Not there yet — keep the request; the config may still be loading.
    if (index < 0 || index >= _tabController.length) return;

    _pendingTab = null;
    if (Get.isRegistered<DiscourseSiteController>()) {
      Get.find<DiscourseSiteController>().requestedHomeTab.value = null;
    }
    if (pending == SiteHomeTab.categories) {
      // Home's Categories view, on the Home tab.
      if (_topicListKey.currentState != null) {
        _topicListKey.currentState!.showView(HomeView.categories);
      } else {
        WidgetsBinding.instance.addPostFrameCallback(
            (_) => _topicListKey.currentState?.showView(HomeView.categories));
      }
    }
    if (_tabController.index == index) return;

    AppLogger.debug('🧭 [SITE_HOME] Opening on the $id tab as requested');
    setState(() {
      _tabController.index = index;
      _previousTabIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
    _previousTabIndex = _tabController.index; // Initialize to match initial index
    _tabController.addListener(_onTabChanged);

    // A tab asked for at construction and one asked for later through the site
    // controller are the same thing to this page: a pending request, applied
    // as soon as the tab it names exists.
    _pendingTab = widget.initialTab;
    if (Get.isRegistered<DiscourseSiteController>()) {
      final siteController = Get.find<DiscourseSiteController>();
      _pendingTab ??= siteController.requestedHomeTab.value;
      _requestedTabWorker =
          ever<SiteHomeTab?>(siteController.requestedHomeTab, (tab) {
        if (tab == null || !mounted) return;
        _pendingTab = tab;
        _applyPendingTab();
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyPendingTab());

    // If siteToInitialize is null, site was already initialized in bootstrap flow.
    // Do not set context, listener, or load here when site is initialized: the block
    // below runs getConfig first, then sets context, listener, and loads. That way we
    // always validate session with getConfig before any other API calls.
    if (widget.siteToInitialize == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (Get.isRegistered<DiscourseSiteController>()) {
          final siteController = Get.find<DiscourseSiteController>();
          final alreadyInitialized = siteController.isInitialized.value &&
              siteController.currentSiteContext.value != null;
          if (alreadyInitialized) {
            // Let the verification block below handle everything (getConfig then load).
            return;
          }
        }
      });
    } else {
      // Initialize site if provided (legacy path - should not be used anymore)
      setState(() {
        _waitingForInitialization = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _siteContext = await _initializeSite(widget.siteToInitialize!);
        if (_siteContext != null) {
          _setupLoginStateListener();

          // Load board stats and fetch inbox stat if user is logged in
          _loadBoardStats();
          if (_siteContext!.isLoggedIn) {
            Future.delayed(const Duration(milliseconds: 500), () {
              final context = _siteContext;
              if (mounted && context != null && context.isLoggedIn) {
                AppLogger.debug('📬 [SITE_HOME] Fetching inbox stat after initialization (auto login case)...');
                _fetchInboxStat();
              }
            });
          }
        }
      });
    }

    // Set up listeners for auth and site changes

    if (Get.isRegistered<DiscourseSiteController>()) {
      final siteController = Get.find<DiscourseSiteController>();

      // Check if site is already initialized when page loads (re-entering forum)
      // This handles the case when user navigates back to an already initialized forum
      // CRITICAL: Even if site appears initialized, we must verify it's still accessible
      if (siteController.isInitialized.value && widget.siteToInitialize == null) {
        AppLogger.debug('🏁 [SITE_HOME] Site appears initialized - verifying site is still accessible...');
        // Get the current site context if available
        final currentContext = siteController.currentSiteContext.value;
        final currentSite = siteController.currentSite.value;

        if (currentContext != null && currentSite != null && widget.siteVerified) {
          SiteProxyService.initialize(currentContext);
          _siteContext = currentContext;
          _setupLoginStateListener();
          _loadBoardStats();
          if (currentContext.isLoggedIn) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _fetchInboxStat();
            });
          }
        } else if (currentContext != null && currentSite != null) {
          // Show loading state while verifying
          setState(() {
            _waitingForInitialization = true;
          });

          // Verify site is still accessible by calling getConfig
          // This prevents using stale cached data when site is down
          // Use post-frame callback to make this async operation safe
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            try {
              AppLogger.debug('🏁 [SITE_HOME] Verifying site accessibility with getConfig...');
              SiteProxyService.initialize(currentContext);
              var configProxy = SiteProxyService.getConfigProxy();

              await AsyncUtils.withTimeout(
                () => configProxy.getConfig(currentSite.pluginUrl, forceRefresh: true),
                timeout: const Duration(seconds: 10),
                operationName: 'getConfig verification',
              );

              AppLogger.debug('🏁 [SITE_HOME] ✅ Site verification successful - using cached context');
              if (mounted) {
                setState(() {
                  _waitingForInitialization = false;
                });
                _siteContext = currentContext;
                _setupLoginStateListener();

                // Load board stats and fetch inbox stat if user is logged in
                _loadBoardStats();
                if (currentContext.isLoggedIn) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      AppLogger.debug('📬 [SITE_HOME] Fetching inbox stat for already initialized site...');
                      _fetchInboxStat();
                    }
                  });
                }
              }
            } on TimeoutException {
              AppLogger.error('🏁 [SITE_HOME] ❌ Site verification timed out - site may be down');
              // Site is down - show error and navigate back
              if (mounted) {
                setState(() {
                  _waitingForInitialization = false;
                });
                _showErrorAndGoBack(currentSite, AppLocalizations.of(context)!.connectionTimedOutSiteUnreachable);
              }
            } catch (e) {
              AppLogger.error('🏁 [SITE_HOME] ❌ Site verification failed: $e - site may be down');
              // Site is down - show error and navigate back
              if (mounted) {
                setState(() {
                  _waitingForInitialization = false;
                });
                _showErrorAndGoBack(currentSite, AppLocalizations.of(context)!.failedToConnectToSite);
              }
            }
          });
        } else {
          AppLogger.warning('🏁 [SITE_HOME] Site marked as initialized but context or site is null - forcing re-initialization');
          // Force re-initialization if context is missing
          setState(() {
            _waitingForInitialization = true;
          });
          if (currentSite != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              _siteContext = await _initializeSite(currentSite);
              if (_siteContext != null) {
                _setupLoginStateListener();
                _loadBoardStats();
                if (_siteContext!.isLoggedIn) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    final context = _siteContext;
                    if (mounted && context != null && context.isLoggedIn) {
                      AppLogger.debug('📬 [SITE_HOME] Fetching inbox stat after re-initialization...');
                      _fetchInboxStat();
                    }
                  });
                }
              }
            });
          }
        }
      }

      _siteWorker = ever(siteController.isInitialized, (isInitialized) {
        if (isInitialized) {
          _adoptSiteContext(siteController.currentSiteContext.value);
          AppLogger.debug('🏁 [SITE_HOME] Site initialization completed - refreshing all tabs');
          _recreateTabController();
          _applyPendingTab();
          _resetAllTabs();
          // Load board stats once for sharing between tabs
          _loadBoardStats();
          // Fetch inbox stat when entering forum
          // Use a small delay to ensure auto login has completed if it's happening
          Future.delayed(const Duration(milliseconds: 500), () {
            final context = _siteContext;
            if (mounted && context != null && context.isLoggedIn) {
              AppLogger.debug('📬 [SITE_HOME] Fetching inbox stat after site initialization (auto login case)...');
              _fetchInboxStat();
            }
          });
          // Force rebuild to update UI with new tab structure
          if (mounted) {
            setState(() {});
          }
        }
      });
    }
  }

  /// Logout reinitializes the controller with a new context. Recreate the
  /// account-bound tabs so their listeners, proxies and requests belong to it.
  void _adoptSiteContext(SiteContext? next) {
    if (next == null || identical(next, _siteContext)) return;
    _detachLoginStateListener();
    _siteContext = next;
    SiteProxyService.initialize(next);
    _topicListKey = GlobalKey();
    _pmListKey = GlobalKey();
    _notificationTabKey = GlobalKey();
    _profileTabKey = GlobalKey();
    _chatListKey = GlobalKey();
    _boardStats = null;
    _unreadConversationsCount = 0;
    _unreadAlertsCount = 0;
    _setupLoginStateListener();
  }

  void _detachLoginStateListener() {
    _loginStateDebounceTimer?.cancel();
    if (_loginStateListener != null) {
      _listenedContext?.isLoggedInNotifier.removeListener(_loginStateListener!);
    }
    _listenedContext = null;
    _loginStateListener = null;
  }

  /// Set up login state listener for site context
  void _setupLoginStateListener() {
    if (_siteContext == null) return;
    _detachLoginStateListener();
    _listenedContext = _siteContext;

    // Initialize stable login state
    _lastStableLoginState = _siteContext!.isLoggedIn;

    _loginStateListener = () {
      if (!mounted) return;

      final currentLoginState = _siteContext!.isLoggedIn;

      // Cancel any pending debounce timer
      _loginStateDebounceTimer?.cancel();

      // Check if this is a "real" login/logout (loginDataOutput changed) vs temporary API fluctuation
      final hasLoginData = _siteContext!.loginDataOutput != null;
      final isRealLoginChange = (currentLoginState && hasLoginData) || (!currentLoginState && !hasLoginData);

      // If it's a real login/logout, react immediately
      // Otherwise, debounce to avoid reacting to temporary API fluctuations
      if (isRealLoginChange && currentLoginState != _lastStableLoginState) {
        _handleLoginStateChange(currentLoginState);
        _lastStableLoginState = currentLoginState;
      } else {
        // Debounce temporary fluctuations - only react if state is stable for 500ms
        _loginStateDebounceTimer = Timer(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          final stableState = _siteContext!.isLoggedIn;
          if (stableState != _lastStableLoginState) {
            _handleLoginStateChange(stableState);
            _lastStableLoginState = stableState;
          }
        });
      }
    };
    _siteContext!.isLoggedInNotifier.addListener(_loginStateListener!);
  }

  /// Handle login state change - only called for stable, meaningful changes
  void _handleLoginStateChange(bool isLoggedIn) {
    if (!mounted) return;
    _recreateTabController();
    _applyPendingTab();
    _resetAllTabs();
    // Fetch inbox stat after login to update badge
    if (isLoggedIn) {
      _fetchInboxStat();
    } else {
      // Clear badges when logged out
      if (mounted) {
        setState(() {
          _unreadConversationsCount = 0;
          _unreadAlertsCount = 0;
        });
      }
    }
    // Force rebuild to update UI with new tab structure
    if (mounted) {
      setState(() {});
    }
  }

  Future<SiteContext?> _initializeSite(Site site) async {
    if (!mounted) return null;
    SiteContext? siteContext;
    try {
      AppLogger.debug('🏁 [SITE_HOME] Starting site initialization for ${site.name}');
      final siteController = Get.find<DiscourseSiteController>();

      // Create SiteContext
      final context = SiteContext(siteType: site.siteType, site: site);

      SiteProxyService.initialize(context);
      // Initialize the site (DiscourseGlobalLoaderController will handle the loading UI)
      // getConfig and all initialization must complete successfully before proceeding
      // Auto-login failures will show the Login screen before continuing as guest
      siteContext = await siteController.initializeSite(
        site,
        showGlobalLoader: widget.showGlobalLoader,
      );
      // IMPORTANT: Re-initialize proxy service with the actual SiteContext returned by initialization.
      // The controller may load a persisted SiteContext, so we must ensure proxies target that context.
      if (siteContext != null) {
        SiteProxyService.initialize(siteContext);
      }

      // Mark initialization as complete so UI can be built
      if (mounted) {
        // Verify initialization was successful - siteContext should not be null
        if (!siteController.isInitialized.value || siteContext == null) {
          AppLogger.debug('🏁 [SITE_HOME] Site initialization failed - siteContext is null or not initialized');
          setState(() {
            _waitingForInitialization = false;
          });
          // Error dialog should have been shown by DiscourseSiteController, just navigate back
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) this.context.popOwnRoute();
          });
          return null;
        }

        setState(() {
          _waitingForInitialization = false;
        });
        AppLogger.debug('🏁 [SITE_HOME] Site initialization completed successfully');

        // Load board stats and fetch inbox stat if site is already initialized and user is logged in
        // This handles the case when re-entering the forum
        // Use a small delay to ensure any auto login has completed
        if (siteContext.isLoggedIn) {
          _loadBoardStats();
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && (siteContext?.isLoggedIn ?? false)) {
              AppLogger.debug('📬 [SITE_HOME] Site already initialized, fetching inbox stat...');
              _fetchInboxStat();
            }
          });
        }
      }
      // The page will automatically update when the forum is initialized
      // due to the _siteWorker listener
    } catch (e) {
      if (mounted) {
        setState(() {
          _waitingForInitialization = false;
        });
        AppLogger.debug('🏁 [SITE_HOME] Site initialization failed with exception: $e');
        // Show error dialog and go back (in case DiscourseSiteController didn't show one)
        _showErrorAndGoBack(site, e.toString());
      }
    }
    return siteContext;
  }

  void _showErrorAndGoBack(Site site, String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final textTheme = Theme.of(context).textTheme;

        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.connectionFailed,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.failedToConnectToSiteName(site.name),
              ),
              const SizedBox(height: DesignTokens.spacingS),
              Text(error, style: textTheme.bodySmall),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Then this page, if nothing has closed it yet: two plain
                // pops here, with the one scheduled when start-up failed,
                // could close the page under it too.
                this.context.popOwnRoute();
              },
              child: Text(AppLocalizations.of(context)!.kit.okButton),
            ),
          ],
        );
      },
    );
  }

  // Method to recreate tab controller when notification permission changes
  void _recreateTabController() {
    final newTabCount = _tabCount;
    final currentTabCount = _tabController.length;

    AppLogger.debug('🔄 [SITE_HOME] _recreateTabController called - Current: $currentTabCount, New: $newTabCount');

    if (currentTabCount != newTabCount) {
      final currentIndex = _tabController.index;
      AppLogger.debug('🔄 [SITE_HOME] Recreating TabController - Current index: $currentIndex');

      _tabController.dispose();
      _previousTabIndex = 0; // Reset previous index when recreating controller
      _tabController = TabController(length: newTabCount, vsync: this);
      _tabController.addListener(_onTabChanged);

      // Try to maintain the same tab index if possible
      final newEnabledTabs = _enabledTabs;
      int newIndex = 0;

      if (currentIndex < newEnabledTabs.length) {
        // If the current index is still valid, use it
        newIndex = currentIndex;
      } else {
        // If current index is out of bounds, go to Profile tab
        newIndex = _getTabIndex(_profileTab);
      }

      // Ensure the index is within bounds
      if (newIndex >= 0 && newIndex < newTabCount) {
        _tabController.index = newIndex;
        _previousTabIndex = newIndex;
        AppLogger.debug('🔄 [SITE_HOME] Set TabController index to: $newIndex');
      } else {
        // Fallback to first tab if index is still invalid
        _tabController.index = 0;
        _previousTabIndex = 0;
        AppLogger.debug('🔄 [SITE_HOME] Fallback to index 0');
      }
    }
  }

  // Method to reset all tabs
  void _resetAllTabs() {
    final enabledTabs = _enabledTabs;

    // Reset all tab controllers using the ResettableTabState mixin
    final tabStates = enabledTabs.map((tabType) {
      switch (tabType) {
        case _topicsTab:
          return _topicListKey.currentState;
        case _messagesTab:
          return _pmListKey.currentState;
        case _chatTab:
          return _chatListKey.currentState;
        case _notificationsTab:
          return _notificationTabKey.currentState;
        case _profileTab:
          return _profileTabKey.currentState;
        default:
          return null;
      }
    }).where((state) => state != null);

    for (final state in tabStates) {
      if (state is FCTabStatefulWidget) {
        state.resetTab();
      }
    }

    // Refresh badge when Messages tab is reset (e.g., after returning from viewing messages)
    if (_siteContext?.isLoggedIn ?? false) {
      _fetchInboxStat();
    }

    // Force rebuild if needed
    if (mounted) {
      setState(() {});
    }
  }

  // Tab change listener that checks mounted before setState
  void _onTabChanged() {
    if (!mounted) return;
    if (_tabController.index != _previousTabIndex) {
      _previousTabIndex = _tabController.index;
      setState(() {});
    }
  }

  void _onNewMessagePressed() async {
    if (_siteContext == null) return;

    // Discourse PMs are always conversations; the XF-style traditional
    // inbox/sent split was removed for discourseapp.
    // The new message opens once sent; the list under it refreshes.
    final sent = await NewConversationPage.open(context,
        siteContext: _siteContext!);
    if (sent) {
      _pmListKey.currentState?.resetTab();
    }
  }

  /// Home's New topic: which category first, then the composer. The
  /// composer becomes the topic once posted; Home refreshes under it.
  Future<void> _onNewTopicPressed() async {
    final siteContext = _siteContext;
    if (siteContext == null) return;
    final category = await pickCategoryForNewTopic(context, siteContext);
    if (category == null || !mounted) return;
    var created = false;
    final result = await AppNavigation.pushForm<Object?>(
      context,
      NewTopicPage(
        siteContext: siteContext,
        forumId: category.id,
        forumName: category.name,
        onTopicCreated: (_, __) => created = true,
      ),
    );
    if ((result == true || created) && mounted) {
      _topicListKey.currentState?.resetTab();
    }
  }

  /// Phase 5.32 — clears every unread notification on the server via
  /// `IFCSocialProxy.markAllAlertsReadAsync` (Discourse:
  /// `PUT /notifications/mark-read`) and refreshes the visible list so
  /// the user sees the cleared state without manually pulling-to-refresh.
  Future<void> _handleMarkAllNotificationsRead() async {
    if (_siteContext == null || !(_siteContext!.isLoggedIn)) return;

    final messenger = ScaffoldMessenger.of(context);
    final result =
        await SiteProxyService.getSocialProxy().markAllAlertsReadAsync();

    if (!mounted) return;

    if (result.result) {
      _notificationTabKey.currentState?.resetTab();
      messenger.showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.allNotificationsMarkedAsRead)),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.resultText?.isNotEmpty == true
              ? result.resultText!
              : AppLocalizations.of(context)!.failedToMarkNotificationsRead),
        ),
      );
    }
  }

  // Define tab types for better organization
  static const String _topicsTab = 'topics';
  static const String _chatTab = 'chat';
  static const String _messagesTab = 'messages';
  static const String _notificationsTab = 'notifications';
  static const String _profileTab = 'profile';

  /// Whether the forum has chat for this reader (Discourse's Chat plugin,
  /// on for them). Chat then has a tab of its own beside Messages.
  bool get _isChatEnabled => _siteContext?.chatEnabled ?? false;

  // The bottom bar: what changes and wants a badge. Categories is one of
  // Home's views (and a list in the drawer), not a tab; Chat and Messages
  // each have their own, so each can show its unread count.
  List<String> get _enabledTabs {
    final tabs = <String>[_topicsTab];
    if (_isChatEnabled) tabs.add(_chatTab);
    tabs.add(_messagesTab);
    if (_siteContext?.configDataOutput?.alert ?? false) tabs.add(_notificationsTab);
    tabs.add(_profileTab);
    return tabs;
  }

  // Helper methods to get tab indices
  int _getTabIndex(String tabType) => _enabledTabs.indexOf(tabType);
  bool _isCurrentTab(String tabType) => _tabController.index == _getTabIndex(tabType);

  /// Stands in for the forum while it is being opened: its name is the
  /// word for loading.
  SiteContext _loadingSiteContext() => SiteContext(
      siteType: 'none',
      site: Site(
          name: AppLocalizations.of(context)!.loading,
          url: '',
          description: '',
          siteType: 'none'));

  // Build the appropriate app bar for the current tab. Home has none: its
  // header is the forum's own, inside the tab's scroll view.
  PreferredSizeWidget? _buildAppBarForCurrentTab(bool isLoggedIn, bool canSendPM) {
    if (_siteContext == null) {
      return ForumAppBar(
        siteContext: _loadingSiteContext(),
        isLoggedIn: false,
      );
    }

    final currentTabType = _enabledTabs[_tabController.index];

    switch (currentTabType) {
      case _topicsTab:
        return null;
      case _chatTab:
        return AppBar(title: Text(AppLocalizations.of(context)!.chat));
      case _messagesTab:
        return MessagesTabAppBar(
          siteContext: _siteContext!,
          isLoggedIn: isLoggedIn,
        );
      case _notificationsTab:
        return NotificationsTabAppBar(
          siteContext: _siteContext!,
          isLoggedIn: isLoggedIn,
          onMarkAllRead:
              isLoggedIn ? _handleMarkAllNotificationsRead : null,
        );
      case _profileTab:
        return ProfileTabAppBar(
          siteContext: _siteContext!,
          isLoggedIn: isLoggedIn,
        );
      default:
        return ForumAppBar(
          siteContext: _siteContext!,
          isLoggedIn: isLoggedIn,
        );
    }
  }

  /// How far in from the edge a swipe opens the drawer: Flutter's 20 beyond
  /// the safe area, or beyond the system's gesture strip when that is wider.
  static double _drawerEdgeDragWidth(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final gestures = MediaQuery.systemGestureInsetsOf(context);
    final taken = Directionality.of(context) == TextDirection.rtl
        ? math.max(padding.right, gestures.right)
        : math.max(padding.left, gestures.left);
    return 20 + taken;
  }

  /// Whether the drawer is open. Back closes it before anything else.
  bool _drawerOpen = false;

  /// Whether the drawer opened by itself, the one time it introduces itself
  /// ([DrawerIntroduction]); its introduction shows until it closes.
  bool _introducingDrawer = false;

  /// Whether Back returns to the first tab rather than leaving: on Android,
  /// from any other tab, as Material's navigation bar has it (the first tab
  /// is the fixed start destination). It used to leave the forum, or close
  /// the app, from whichever tab was showing. iOS has no Back here, and its
  /// edge swipe leaves from any tab, as tab bars do there.
  bool _backReturnsToFirstTab(BuildContext context) =>
      Theme.of(context).platform == TargetPlatform.android &&
      _tabController.index != 0 &&
      !_drawerOpen;

  @override
  Widget build(BuildContext context) {
    // Don't build the main UI until initialization is complete
    if (_waitingForInitialization) {
      // Show a minimal scaffold with just the app bar while waiting
      // The DiscourseGlobalLoaderController will show the loading overlay
      return Scaffold(
        appBar: TopicsTabAppBar(
          siteContext: _siteContext ?? _loadingSiteContext(),
          isLoggedIn: false, // Not logged in during initialization
        ),
        body: const SizedBox.shrink(), // Empty body, loading overlay will show
      );
    }

    // If siteContext is null after initialization, show error and prevent UI entry
    // This can happen if initialization failed
    if (_siteContext == null && !_waitingForInitialization) {
      // If we have a site to initialize but failed, show error dialog and go back
      if (widget.siteToInitialize != null) {
        // Error dialog should have already been shown by _initializeSite or DiscourseSiteController
        // But ensure we navigate back after a delay to allow dialog to be shown
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Only this page: build runs again before the pop lands, and each
          // run scheduled another pop, closing the page under this one too.
          if (mounted && _siteContext == null &&
              (ModalRoute.of(context)?.isCurrent ?? false)) {
            Navigator.of(context).pop();
          }
        });
      }

      // Return minimal error state while navigating back
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.errorTitle),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Debug logging for tab counts (only log when values actually change to reduce noise)
    final enabledTabs = _enabledTabs;
    final destinations = _buildNavigationDestinations();
    // Only log if tab count or index changed (not on every rebuild)
    if (_lastLoggedTabCount != enabledTabs.length || _lastLoggedTabIndex != _tabController.index) {
      AppLogger.debug('🔍 [SITE_HOME] Build - Enabled tabs: ${enabledTabs.length}, TabController: ${_tabController.length}, Destinations: ${destinations.length}');
      AppLogger.debug('🔍 [SITE_HOME] Enabled tabs: $enabledTabs');
      AppLogger.debug('🔍 [SITE_HOME] Current TabController index: ${_tabController.index}');
      _lastLoggedTabCount = enabledTabs.length;
      _lastLoggedTabIndex = _tabController.index;
    }

    // Check if TabController needs to be recreated due to tab count change
    if (_tabController.length != enabledTabs.length) {
      AppLogger.debug('🔄 [SITE_HOME] Tab count mismatch detected in build - recreating TabController');
      _recreateTabController();
      // Inside build, so setState is out; take the request on the next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) => _applyPendingTab());
    }

    final isLoggedIn = _siteContext!.isLoggedIn;
    final canSendPM = isLoggedIn && (_siteContext?.loginDataOutput?.user?.canSendPM ?? false);
    // Keyed off the messages *view*, not the tab index: on forums with chat the
    // Messages tab does not exist, so the old `_isCurrentTab(_messagesTab)` was
    // permanently false (_getTabIndex returns -1) and the compose button never
    // appeared anywhere in the app.
    final isOnMessagesTab = _isViewingMessages;
    final shouldShowFAB = isLoggedIn && isOnMessagesTab && canSendPM;
    // Home's New topic, as the website has one on its home.
    final showNewTopic = isLoggedIn && _isCurrentTab(_topicsTab);

    // Only log FAB visibility when it changes to reduce noise
    if (_lastLoggedShouldShowFAB != shouldShowFAB) {
      AppLogger.debug('🔍 [SITE_HOME] FAB visibility changed:');
      AppLogger.debug('   - isLoggedIn: $isLoggedIn');
      AppLogger.debug('   - isOnMessagesTab: $isOnMessagesTab (currentIndex: ${_tabController.index}, messagesTabIndex: ${_getTabIndex(_messagesTab)})');
      AppLogger.debug('   - canSendPM: $canSendPM');
      AppLogger.debug('   - FAB should show: $shouldShowFAB');
      _lastLoggedShouldShowFAB = shouldShowFAB;
    }

    // Pushed over a host's forum list (ABDA), rather than the app's root.
    final hostedHome = ModalRoute.canPopOf(context) ?? false;

    return PopScope(
      canPop: !_backReturnsToFirstTab(context),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _tabController.index == 0) return;
        setState(() {
          _tabController.index = 0;
          _previousTabIndex = 0;
        });
      },
      child: Scaffold(
        appBar: _buildAppBarForCurrentTab(isLoggedIn, canSendPM),
        onDrawerChanged: (open) {
          setState(() {
            _drawerOpen = open;
            if (!open) _introducingDrawer = false;
          });
          // Opened by the reader: found, so it never opens by itself.
          if (open) DrawerIntroduction.markSeen();
        },
        // Phase 5.18a — hamburger drawer hosts the moved Tags tab plus
        // future community directories (Users / Groups / Badges) and
        // account actions. Drawer is mounted at the Scaffold level so
        // every tab's AppBar can open it via the auto-imply leading
        // hamburger.
        drawer: SiteDrawer(
          siteContext: _siteContext!,
          homeIsCurrent: _isCurrentTab(_topicsTab),
          introduction: _introducingDrawer,
        ),
        // Pushed over a host's forum list, the home's left edge means Back:
        // iOS's swipe and Android's system gesture both claim it, except that
        // on older Android a finger resting at the edge first opened the drawer
        // instead. One meaning per edge, so there the drawer opens from its
        // button only. A root home (the single-forum app) has nothing behind
        // it, so its edge opens the drawer.
        drawerEnableOpenDragGesture: !hostedHome,
        // Android's gesture navigation keeps the outermost strip of the edge
        // for its own Back, which from a root home would close the app. The
        // drawer's strip starts where the system's ends; without gesture
        // navigation that inset is zero and this is Flutter's default.
        drawerEdgeDragWidth: _drawerEdgeDragWidth(context),
        // With the edge taken by Back, the drawer opens from ☰ only: it
        // shows itself once, so the button is known.
        body: DrawerIntroduction(
          enabled: hostedHome,
          onIntroduce: () => setState(() => _introducingDrawer = true),
          child: IndexedStack(
            index: _tabController.index,
            children: _buildTabWidgets(),
          ),
        ),
        // One line per label, ellipsized: a long word ("Nachrichten",
        // "Сообщения" at large text) broke mid-word onto a second line.
        bottomNavigationBar: DefaultTextStyle.merge(
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          child: NavigationBar(
          onDestinationSelected: (int index) {
            AppLogger.debug('🎯 [SITE_HOME] NavigationBar onDestinationSelected: index=$index, TabController.length=${_tabController.length}');
            setState(() {
              _tabController.index = index;
              _previousTabIndex = index;
            });
            // Refresh badge when Messages tab becomes active
            if (_enabledTabs[index] == _messagesTab && (_siteContext?.isLoggedIn ?? false)) {
              _fetchInboxStat();
            }
          },
          selectedIndex: _tabController.index,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: _buildNavigationDestinations(),
          ),
        ),
        floatingActionButton: shouldShowFAB
            ? FloatingActionButton.extended(
                heroTag: 'new-message-fab',
                onPressed: _onNewMessagePressed,
                icon: const Icon(Icons.post_add_rounded),
                label: Text(AppLocalizations.of(context)!.newConversation),
              )
            : showNewTopic
                ? FloatingActionButton.extended(
                    heroTag: ForumTopicsPage.newTopicHeroTag,
                    onPressed: _onNewTopicPressed,
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(AppLocalizations.of(context)!.newTopic),
                  )
                : null,
      ),
    );
  }

  // Build tab widgets based on enabled tabs
  List<Widget> _buildTabWidgets() {
    return _enabledTabs.map((tabType) {
      switch (tabType) {
        case _topicsTab:
          return TopicListTab(
              key: _topicListKey,
              isActive: _isCurrentTab(_topicsTab),
              siteContext: _siteContext ?? _loadingSiteContext(),
              boardStats: _boardStats);
        case _chatTab:
          return ChatChannelListPage(
            key: _chatListKey,
            siteContext: _siteContext ?? _loadingSiteContext(),
            embedded: true,
          );
        case _messagesTab:
          return PrivateMessageListTab(
              key: _pmListKey,
              isActive: _isCurrentTab(_messagesTab),
              siteContext: _siteContext ?? _loadingSiteContext());
        case _notificationsTab:
          return NotificationListTab(
              key: _notificationTabKey,
              isActive: _isCurrentTab(_notificationsTab),
              siteContext: _siteContext ?? _loadingSiteContext());
        case _profileTab:
          return ProfileTab(
            key: _profileTabKey,
            isActive: _isCurrentTab(_profileTab),
            autoShowLogin: SiteHomePage.triggerProfileAutoLogin,
            boardStats: _boardStats,
            siteContext: _siteContext ?? _loadingSiteContext(),
          );
        default:
          throw ArgumentError('Unknown tab type: $tabType');
      }
    }).toList();
  }

  // Build navigation destinations based on enabled tabs. Labelled, as
  // Material 3 shows them: three of the icons are speech bubbles, and an
  // empty label left screen readers with nothing to say.
  List<NavigationDestination> _buildNavigationDestinations() {
    final l10n = AppLocalizations.of(context)!;
    return _enabledTabs.map((tabType) {
      switch (tabType) {
        case _topicsTab:
          return NavigationDestination(
            selectedIcon: const Icon(Icons.chat_bubble),
            icon: const Icon(Icons.chat_bubble_outline),
            label: l10n.home,
          );
        case _chatTab:
          // Phase 5.18a — distinct icon from Topics' chat_bubble so
          // users can tell the two surfaces apart. Forum chat lives
          // under the chat-launch icon (chat_outlined / chat_rounded);
          // Topics is a single "speech bubble".
          // Mentions and unread direct messages as a number, anything else
          // unread as a dot, as Discourse's chat footer badges them (the
          // chat list publishes them; see ChatUnread).
          final chatSite = _siteContext;
          Widget chatBadge(Widget icon) => chatSite == null
              ? icon
              : ValueListenableBuilder<ChatUnreadState>(
                  valueListenable: ChatUnread.of(chatSite),
                  builder: (context, unread, _) => Badge(
                    label: unread.urgent > 0
                        ? Text(unread.urgent > 99 ? '99+' : '${unread.urgent}')
                        : null,
                    smallSize: 8,
                    isLabelVisible: unread.any,
                    child: icon,
                  ),
                );
          return NavigationDestination(
            selectedIcon: chatBadge(const Icon(Icons.chat_rounded)),
            icon: chatBadge(const Icon(Icons.chat_outlined)),
            label: l10n.chat,
          );
        case _messagesTab:
          return NavigationDestination(
            selectedIcon: const Icon(Icons.mail),
            icon: Badge(
              label: Text('$_unreadConversationsCount'),
              isLabelVisible: _unreadConversationsCount > 0,
              child: const Icon(Icons.mail_outline),
            ),
            label: l10n.kit.messages,
          );
        case _notificationsTab:
          return NavigationDestination(
            selectedIcon: const Icon(Icons.notifications),
            icon: Badge(
              label: Text('$_unreadAlertsCount'),
              isLabelVisible: _unreadAlertsCount > 0,
              child: const Icon(Icons.notifications_outlined),
            ),
            label: l10n.notificationsTab,
            tooltip: l10n.kit.notifications,
          );
        case _profileTab:
          return NavigationDestination(
            selectedIcon: const Icon(Icons.person),
            icon: const Icon(Icons.person_outlined),
            label: l10n.profile,
          );
        default:
          throw ArgumentError('Unknown tab type: $tabType');
      }
    }).toList();
  }

  /// Load board statistics once for sharing between tabs
  Future<void> _loadBoardStats() async {
    final owner = _siteContext;
    final session = owner?.configurationSession;
    if (_siteContext == null) {
      return;
    }

    try {
      AppLogger.debug('📊 [SITE_HOME] Loading board stats...');
      final forumProxy = SiteProxyFactory.getForumProxy();
      final stats = await forumProxy.getBoardStatAsync();
      if (mounted && identical(owner, _siteContext) &&
              identical(session, owner?.configurationSession)) {
        setState(() {
          _boardStats = stats;
        });
        AppLogger.debug('📊 [SITE_HOME] Board stats loaded successfully');
      }
    } catch (e) {
      AppLogger.debug('📊 [SITE_HOME] Error loading board stats: $e');
      // Silently fail - board stats are not critical
    }
  }

  /// Fetch inbox statistics to update the badge count
  Future<void> _fetchInboxStat() async {
    final owner = _siteContext;
    final session = owner?.configurationSession;
    if (_siteContext == null || !_siteContext!.isLoggedIn) {
      return;
    }

    try {
      AppLogger.debug('📬 [SITE_HOME] Fetching inbox stat...');
      final conversationProxy = SiteProxyFactory.getPrivateConversationProxy();

      // Check if this is a Discourse proxy that supports getInboxStatWithAlertsAsync
      if (conversationProxy is DiscoursePrivateConversationProxy) {
        final result = await conversationProxy.getInboxStatWithAlertsAsync();
        final inboxStat = result['inboxStat'] as FCInboxStatResult;
        final unreadAlerts = result['unreadAlerts'] as int;

        if (inboxStat.result) {
          AppLogger.debug('📬 [SITE_HOME] Inbox stat fetched: ${inboxStat.unreadConversations} unread conversations, $unreadAlerts unread alerts');
          if (mounted && identical(owner, _siteContext) &&
              identical(session, owner?.configurationSession)) {
            setState(() {
              _unreadConversationsCount = inboxStat.unreadConversations;
              _unreadAlertsCount = unreadAlerts;
            });
          }
        } else {
          AppLogger.debug('📬 [SITE_HOME] Failed to fetch inbox stat: ${inboxStat.resultText}');
        }
      } else {
        // Fallback for proxies that don't support unread alert counts
        final inboxStat = await conversationProxy.getInboxStatAsync();
        if (inboxStat.result) {
          AppLogger.debug('📬 [SITE_HOME] Inbox stat fetched: ${inboxStat.unreadConversations} unread conversations');
          if (mounted && identical(owner, _siteContext) &&
              identical(session, owner?.configurationSession)) {
            setState(() {
              _unreadConversationsCount = inboxStat.unreadConversations;
              // unreadAlerts not available for this proxy type
              _unreadAlertsCount = 0;
            });
          }
        } else {
          AppLogger.debug('📬 [SITE_HOME] Failed to fetch inbox stat: ${inboxStat.resultText}');
        }
      }
    } catch (e) {
      AppLogger.debug('📬 [SITE_HOME] Error fetching inbox stat: $e');
      // Silently fail since this is not urgent
    }
  }

  /// The route this page is on, told to the site controller so a link to
  /// the forum's home, one of its lists or the inbox can return here
  /// (`DiscourseLinkHandler`).
  ModalRoute<dynamic>? _homeRoute;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route != _homeRoute &&
        Get.isRegistered<DiscourseSiteController>()) {
      _homeRoute = route;
      Get.find<DiscourseSiteController>().homeRoute = route;
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<DiscourseSiteController>()) {
      final controller = Get.find<DiscourseSiteController>();
      if (controller.homeRoute == _homeRoute) controller.homeRoute = null;
    }
    // Cancel login state debounce timer
    _loginStateDebounceTimer?.cancel();
    _loginStateDebounceTimer = null;

    // Remove tab controller listener
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();

    _requestedTabWorker?.dispose();
    _requestedTabWorker = null;

    // Remove login state listener if it exists
    _detachLoginStateListener();

    // Dispose worker
    _siteWorker?.dispose();
    _siteWorker = null;

    super.dispose();
  }
}
