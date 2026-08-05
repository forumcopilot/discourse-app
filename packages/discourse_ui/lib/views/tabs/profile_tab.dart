import 'package:flutter/material.dart';
import 'package:discourse_ui/views/widgets/resettable_widget.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/models/results/fc_user_result.dart';
import 'dart:async';
import 'package:discourse_ui/utils/error_dialog.dart';
import '../../theme/design_tokens.dart';

// Import the new component widgets
import '../widgets/profile_view.dart';
import '../widgets/not_signed_in_view.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';
import 'package:get/get.dart';
import 'package:discourse_ui/controllers/login_controller.dart';
import '../login_page.dart';

class ProfileTab extends StatefulWidget {
  final SiteContext siteContext;
  final bool isActive;
  final bool autoShowLogin;
  const ProfileTab({
    super.key,
    required this.siteContext,
    required this.isActive,
    this.autoShowLogin = false,
  });

  @override
  ProfileTabState createState() => ProfileTabState();
}

class ProfileTabState extends FCStatefulWidget<ProfileTab> with FCTabStatefulWidget<ProfileTab> {
  bool _hasLoaded = false;
  FCUserInfoResult? _userInfo;
  List<FCUserReply>? _recentPosts;
  bool _isLoadingRecentPosts = false;
  bool _isLoadingMorePosts = false;
  String? _recentPostsError;
  int _totalPosts = 0;
  static const int _pageSize = 20;
  final ScrollController _scrollController = ScrollController();
  bool _didAttemptAutoLogin = false;

  @override
  void didUpdateWidget(covariant ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchUserInfo();
  }

  late final VoidCallback _authStateListener;

  // Track last logged login state to reduce debug noise
  bool? _lastLoggedIsLoggedIn;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo(); // Initial fetch
    _attemptAutoLoginIfNeeded();

    _authStateListener = () {
      final isLoggedInStatus = widget.siteContext.isLoggedIn;
      AppLogger.debug('👤 [PROFILE_TAB] Auth status changed: $isLoggedInStatus');
      if (isLoggedInStatus) {
        AppLogger.debug('👤 [PROFILE_TAB] User logged in - checking if user info needs to be fetched');
        // User logged in, fetch user info if not already loaded or if username changed
        final currentUsername = widget.siteContext.loginDataOutput?.user?.username;
        AppLogger.debug('👤 [PROFILE_TAB] Current username: $currentUsername');
        AppLogger.debug('👤 [PROFILE_TAB] Existing user info: ${_userInfo?.username}');

        if (_userInfo == null || (_userInfo?.username != null && _userInfo!.username != currentUsername)) {
          AppLogger.debug('👤 [PROFILE_TAB] Fetching user info due to auth status change');
          _hasLoaded = false; // Reset loaded state to force refresh
          _fetchUserInfo();
        } else {
          AppLogger.debug('👤 [PROFILE_TAB] User info already loaded and username matches');
        }
      } else {
        AppLogger.debug('👤 [PROFILE_TAB] User logged out - clearing user info');
        // User logged out, clear user info
        if (mounted) {
          setState(() {
            _userInfo = null;
            _hasLoaded = false;
          });
        }
      }
    };

    widget.siteContext.isLoggedInNotifier.addListener(_authStateListener);
    _scrollController.addListener(_onScroll);
  }

  void _attemptAutoLoginIfNeeded() {
    if (_didAttemptAutoLogin) {
      return;
    }
    _didAttemptAutoLogin = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || widget.siteContext.isLoggedIn) {
        return;
      }
      if (!Get.isRegistered<DiscourseLoginController>()) {
        Get.put(DiscourseLoginController());
      }
      final loginController = Get.find<DiscourseLoginController>();
      final loginResult = await loginController.attemptAutomaticLogin(widget.siteContext);
      if (!loginResult.success && loginResult.hadCredentials && Get.currentRoute != '/LoginPage') {
        await Get.to(() => LoginPage(siteContext: widget.siteContext));
      }
    });
  }

  @override
  void dispose() {
    widget.siteContext.isLoggedInNotifier.removeListener(_authStateListener);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 && !_isLoadingMorePosts && _hasMorePosts && _recentPosts != null && _recentPosts!.isNotEmpty) {
      final username = widget.siteContext.loginDataOutput?.user?.username;
      if (username != null) {
        _fetchRecentPosts(username, loadMore: true);
      }
    }
  }

  @override
  void resetTab() {
    _hasLoaded = false;
    clearError();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    AppLogger.debug('👤 [PROFILE_TAB] _fetchUserInfo() called');
    AppLogger.debug('👤 [PROFILE_TAB] isActive: ${widget.isActive}, hasLoaded: $_hasLoaded');
    AppLogger.debug('👤 [PROFILE_TAB] Current login state: ${widget.siteContext.isLoginInformationAvailable}');

    if (widget.isActive && !_hasLoaded) {
      setState(() {
        // Loading state handled by individual components
      });
      try {
        final username = widget.siteContext.loginDataOutput?.user?.username;
        AppLogger.debug('👤 [PROFILE_TAB] Username from context: $username');

        if (username == null) {
          AppLogger.debug('👤 [PROFILE_TAB] ❌ No username found - user not logged in');
          return;
        }

        AppLogger.debug('👤 [PROFILE_TAB] Making getUserInfo API call for username: $username');
        final proxy = SiteProxyFactory.getUserProxy();
        final info = await proxy.getUserInfoAsync(username, null);

        AppLogger.debug('👤 [PROFILE_TAB] ✅ getUserInfo API call completed successfully');
        // Debug logging for display text
        AppLogger.debug('=== Profile Tab Debug Info ===');
        AppLogger.debug('username: $username');
        AppLogger.debug('display_text: ${info.displayText} (length: ${info.displayText?.length})');
        AppLogger.debug('========================');

        if (mounted) {
          setState(() {
            _userInfo = info;
          });
          _fetchRecentPosts(username); // Fetch recent posts after user info
        }
        _hasLoaded = true;
        AppLogger.debug('👤 [PROFILE_TAB] ✅ User info loaded successfully');
      } catch (e) {
        AppLogger.debug('👤 [PROFILE_TAB] ❌ Error fetching user info: $e');
        showErrorDialogFromException(e);
        // Error handling is done by individual components
      }
    } else {
      AppLogger.debug('👤 [PROFILE_TAB] Skipping fetch - not active or already loaded');
    }
  }

  Future<void> _fetchRecentPosts(String username, {bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingMorePosts || _recentPosts == null) return;
      setState(() {
        _isLoadingMorePosts = true;
        _recentPostsError = null;
      });
    } else {
      setState(() {
        _isLoadingRecentPosts = true;
        _recentPostsError = null;
        _recentPosts = null;
        _totalPosts = 0;
      });
    }
    try {
      final currentCount = _recentPosts?.length ?? 0;
      final startNum = loadMore ? currentCount : 0;
      final lastNum = startNum + _pageSize - 1;

      AppLogger.debug('Fetching recent posts for username: $username, startNum: $startNum, lastNum: $lastNum');
      final proxy = SiteProxyFactory.getUserProxy();
      final result = await proxy.getUserReplyPostAsync(startNum, lastNum, null, username, null);
      AppLogger.debug('Result from getUserReplyPostAsync: total: ${result.total}, posts count: ${result.posts.length}');
      if (mounted) {
        setState(() {
          if (loadMore) {
            _recentPosts = [...(_recentPosts ?? []), ...result.posts];
          } else {
            _recentPosts = result.posts;
            _totalPosts = result.total;
          }
          _isLoadingRecentPosts = false;
          _isLoadingMorePosts = false;
          // Update total if we got a new value
          if (result.total > _totalPosts) {
            _totalPosts = result.total;
          }
        });
      }
    } catch (e, stack) {
      AppLogger.debug('Error in _fetchRecentPosts: ' + e.toString());
      AppLogger.debug('Stack trace: $stack');
      final errorMessage = extractErrorMessage(e);
      showErrorDialogFromException(e);
      if (mounted) {
        setState(() {
          _recentPostsError = errorMessage;
          _isLoadingRecentPosts = false;
          _isLoadingMorePosts = false;
        });
      }
    }
  }

  bool get _hasMorePosts {
    if (_recentPosts == null) return false;
    return _recentPosts!.length < _totalPosts;
  }

  /// Pull-to-refresh: same reset semantics as an edit-save — null the
  /// cached userInfo AND reset `_hasLoaded` (fetch no-ops while it's
  /// true), then refetch.
  Future<void> _handleRefresh() async {
    setState(() {
      _userInfo = null;
      _hasLoaded = false;
    });
    clearError();
    await _fetchUserInfo();
  }

  Widget _buildLoggedInContent() {
    // The whole logged-in body is the shared ProfileView (subtraction
    // model — one profile experience for the tab and the avatar-tap
    // page). The tab keeps owning: NotSignedInView, resetTab/auth-
    // listener wiring, and the _userInfo/_hasLoaded fetch mechanics.
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (_userInfo == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: DesignTokens.spacingXXL),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            ProfileView(
              siteContext: widget.siteContext,
              userInfo: _userInfo!,
              isSelf: true,
              onEdited: () {
                // Force a fresh fetch so name / bio / location /
                // website re-render with the saved values.
                // _hasLoaded must be reset too: _fetchUserInfo()
                // no-ops while it is true, and the profile body only
                // renders when _userInfo is non-null — without the
                // reset the section vanished after an edit.
                setState(() {
                  _userInfo = null;
                  _hasLoaded = false;
                });
                _fetchUserInfo();
              },
              onAvatarUploaded: () {
                // Refresh user info when the avatar changes (login
                // context already carries the new iconUrl).
                _hasLoaded = false;
                _fetchUserInfo();
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only log when login state changes to reduce noise
    final currentIsLoggedIn = widget.siteContext.isLoggedIn;
    if (_lastLoggedIsLoggedIn != currentIsLoggedIn) {
      AppLogger.debug('👤 [PROFILE_TAB] build() called - userIsLoggedIn: $currentIsLoggedIn');
      _lastLoggedIsLoggedIn = currentIsLoggedIn;
    }
    return ValueListenableBuilder<bool>(
      valueListenable: widget.siteContext.isLoggedInNotifier,
      builder: (context, isLoggedIn, child) {
        if (!isLoggedIn) {
          AppLogger.debug('👤 [PROFILE_TAB] Showing NotSignedInView - user not logged in');
          // Show only Not Signed In view when user is not logged in (no forum header)
          return NotSignedInView(
            siteContext: widget.siteContext,
            title: 'Sign in to view profile',
            message: 'You need to be signed in to view your profile.',
            icon: Icons.person_outline_rounded,
          );
        }

        AppLogger.debug('👤 [PROFILE_TAB] User is logged in - showing profile content');
        // Show profile content without forum header when user is logged in
        return _buildLoggedInContent();
      },
    );
  }
}

// _ProfileActionsSection / _ActionRow moved into the shared
// ProfileView (views/widgets/profile_view.dart) as part of the
// profile unification.
