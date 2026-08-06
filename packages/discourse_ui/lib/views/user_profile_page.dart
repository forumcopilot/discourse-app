import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/results/fc_user_result.dart';
import 'package:intl/intl.dart';
import 'package:discourse_ui/utils/error_dialog.dart';
import 'widgets/profile_view.dart';
import 'package:get/get.dart';
import 'package:discourse_ui/controllers/login_controller.dart';
import 'login_page.dart';
import '../theme/design_tokens.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';
import '../utils/error_message.dart';

class UserProfilePage extends StatefulWidget {
  final SiteContext siteContext;
  final String? userId;
  final String? userName;
  final String? profilePictureUrl;

  const UserProfilePage({
    super.key,
    required this.siteContext,
    this.userId,
    this.userName,
    this.profilePictureUrl,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  FCUserInfoResult? _userInfo;
  bool _isLoading = true;
  String? _error;
  int _postsRefreshKey = 0; // Key to force UserRepliedPosts to refresh
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _userRepliedPostsKey = GlobalKey();
  bool _didAttemptAutoLogin = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _attemptAutoLoginAndLoad();
  }

  void _attemptAutoLoginAndLoad() {
    if (_didAttemptAutoLogin) {
      return;
    }
    _didAttemptAutoLogin = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      if (!widget.siteContext.isLoggedIn) {
        if (!Get.isRegistered<DiscourseLoginController>()) {
          Get.put(DiscourseLoginController());
        }
        final loginController = Get.find<DiscourseLoginController>();
        final loginResult = await loginController.attemptAutomaticLogin(widget.siteContext);
        if (!loginResult.success && loginResult.hadCredentials && Get.currentRoute != '/LoginPage') {
          await Get.to(() => LoginPage(siteContext: widget.siteContext));
        }
      }
      if (!mounted) {
        return;
      }
      _fetchUserInfo();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      // Trigger load more via the widget's state
      final state = _userRepliedPostsKey.currentState;
      if (state is State) {
        // Use dynamic call to access checkAndLoadMore method
        (state as dynamic).checkAndLoadMore?.call(
              _scrollController.position.pixels,
              _scrollController.position.maxScrollExtent,
            );
      }
    }
  }

  Future<void> _fetchUserInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final proxy = SiteProxyService.getUserProxy();
      final info = await proxy.getUserInfoAsync(widget.userName, widget.userId);

      // Debug print statements for user info fields

      setState(() {
        _userInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.debug('Error fetching user info: $e');
      showErrorDialog('Failed to load user info: $e');
      setState(() {
        _error = describeError(e, fallback: 'Failed to load user info.');
        _isLoading = false;
      });
    }
  }

  /// Refresh the entire user profile page by resetting state and fetching fresh data
  Future<void> _refreshProfile() async {
    AppLogger.debug('Refreshing user profile page');
    setState(() {
      _userInfo = null;
      _isLoading = true;
      _error = null;
      _postsRefreshKey++;
    });
    await _fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: DesignTokens.elevationNone,
        surfaceTintColor: colorScheme.surfaceTint,
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: DesignTokens.iconSizeL,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _isLoading
            ? Text(AppLocalizations.of(context)?.loading ?? 'Loading...')
            : _userInfo != null
                ? (widget.siteContext.loginDataOutput != null && widget.siteContext.loginDataOutput?.user?.id != _userInfo!.id)
                    ? const SizedBox.shrink() // Hide title when viewing another user's profile
                    : Text(
                        _userInfo!.username,
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: DesignTokens.fontWeightBold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                : Text(AppLocalizations.of(context)?.userProfile ?? 'User Profile'),
        centerTitle: true,
        actions: [
          if (_userInfo != null &&
              widget.siteContext.loginDataOutput != null &&
              widget.siteContext.loginDataOutput?.user?.id != _userInfo!.id &&
              // Don't render an empty overflow menu when the viewer has
              // no per-user actions available.
              (_userInfo!.canIgnore ||
                  _userInfo!.canBan ||
                  _userInfo!.canSpamClean))
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  // 'report' case removed in Phase 5.20a along with
                  // the menu item — see commentary further down.
                  case 'ignore':
                    _handleToggleIgnore(context);
                    break;
                  case 'ban':
                    if (_userInfo!.isBanned) {
                      _handleUnbanUser(context);
                    } else {
                      _handleBanUser(context);
                    }
                    break;
                  case 'spamCleaner':
                    _handleSpamCleanUser(context);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                // Phase 5.20a — "Report user" removed: Discourse
                // doesn't have a per-user report action. The user-
                // level proxy method (`userProxy.reportUserAsync`)
                // intentionally returns guidance saying "open one of
                // their posts and use the flag action" — so the menu
                // item itself was net-negative UX. Per-post flagging
                // remains fully wired via `reportPostAsync` (see
                // `post_actions.dart`).
                // Phase 5.25 — Ignore / Unignore. Wires
                // `userProxy.ignoreUserAsync` which PUTs the user's
                // notification level to 2 (ignored) or 1 (normal).
                // Gated on the server's `can_ignore_user` guardian
                // check (false for guests, self, and staff targets).
                if (_userInfo!.canIgnore)
                  PopupMenuItem<String>(
                    value: 'ignore',
                    child: Row(
                      children: [
                        Icon(
                          _userInfo!.isIgnored
                              ? Icons.notifications_active_outlined
                              : Icons.notifications_off_outlined,
                          color: colorScheme.onSurface,
                        ),
                        const SizedBox(width: DesignTokens.spacingM),
                        Text(
                          _userInfo!.isIgnored
                              ? 'Unignore user'
                              : 'Ignore user',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Ban/Unban User - only show if user has permission
                if (_userInfo!.canBan)
                  PopupMenuItem<String>(
                    value: 'ban',
                    child: Row(
                      children: [
                        Icon(
                          _userInfo!.isBanned ? Icons.block_outlined : Icons.block,
                          color: colorScheme.error,
                        ),
                        const SizedBox(width: DesignTokens.spacingM),
                        Text(
                          _userInfo!.isBanned ? AppLocalizations.of(context)!.unbanUser : AppLocalizations.of(context)!.banUser,
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Spam Cleaner - only show if user has permission
                if (_userInfo!.canSpamClean)
                  PopupMenuItem<String>(
                    value: 'spamCleaner',
                    child: Row(
                      children: [
                        Icon(Icons.cleaning_services, color: colorScheme.error),
                        const SizedBox(width: DesignTokens.spacingM),
                        Text(
                          AppLocalizations.of(context)?.spamCleaner ?? 'Spam Cleaner',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: DesignTokens.paddingScreen,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: DesignTokens.spacingL),
                        Text(
                          AppLocalizations.of(context)?.unableToLoadProfile ?? 'Unable to Load Profile',
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.error,
                            fontWeight: DesignTokens.fontWeightBold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: DesignTokens.spacingS),
                        Text(
                          _error!,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: DesignTokens.spacingXL),
                        FilledButton.icon(
                          onPressed: _fetchUserInfo,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(AppLocalizations.of(context)?.tryAgain ?? 'Try Again'),
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: EdgeInsets.symmetric(
                              horizontal: DesignTokens.spacingXL,
                              vertical: DesignTokens.spacingM,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                            ),
                            elevation: DesignTokens.elevationMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _userInfo == null
                  ? Center(child: Text(AppLocalizations.of(context)?.userInformationNotAvailable ?? 'User information not available'))
                  : RefreshIndicator(
                      onRefresh: _refreshProfile,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh even when content doesn't scroll
                        // The whole profile body is the shared
                        // ProfileView (subtraction model — one profile
                        // experience for the tab and this page). This
                        // page keeps owning: the app bar + moderation
                        // overflow menu, the userInfo fetch, and the
                        // pull-to-refresh wrapper.
                        child: ProfileView(
                          siteContext: widget.siteContext,
                          userInfo: _userInfo!,
                          isSelf: widget.siteContext.loginDataOutput?.user?.id ==
                              _userInfo!.id,
                          fallbackAvatarUrl: widget.profilePictureUrl,
                          repliesKey: _userRepliedPostsKey,
                          refreshToken: _postsRefreshKey,
                          onEdited: () {
                            _refreshProfile();
                          },
                          onAvatarUploaded: () {
                            _refreshProfile();
                          },
                        ),
                      ),
                    ),
    );
  }

  /// Phase 5.25 — toggle the ignore state for the viewed user.
  /// Discourse: `PUT /u/{username}/notification_level.json` with
  /// `notification_level: 2` (ignored) or `1` (normal). The proxy's
  /// `ignoreUserAsync(userId, mode)` API takes `mode == 1` to
  /// ignore, `0` to unignore.
  Future<void> _handleToggleIgnore(BuildContext context) async {
    if (_userInfo == null) return;
    final wantIgnore = !_userInfo!.isIgnored;
    final messenger = ScaffoldMessenger.of(context);
    final username = _userInfo!.username;
    // Optimistic flip — the menu's next render shows the new state.
    // Reverted on failure. `isIgnored` is a mutable field on FCUser
    // (no `final`), so direct mutation inside setState is fine.
    setState(() {
      _userInfo!.isIgnored = wantIgnore;
    });
    try {
      final proxy = SiteProxyService.getUserProxy();
      final result = await proxy.ignoreUserAsync(username, wantIgnore ? 1 : 0);
      if (!mounted) return;
      if (!result.result) {
        setState(() {
          _userInfo!.isIgnored = !wantIgnore;
        });
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              result.resultText?.isNotEmpty == true
                  ? result.resultText!
                  : "Couldn't update ignore state",
            ),
          ),
        );
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            wantIgnore
                ? "You're ignoring @$username. Their posts will be hidden."
                : "Stopped ignoring @$username.",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _userInfo!.isIgnored = !wantIgnore;
      });
      messenger.showSnackBar(
        SnackBar(content: Text(describeError(e, fallback: 'Ignore toggle failed.'))),
      );
    }
  }

  Future<void> _handleBanUser(BuildContext context) async {
    if (_userInfo == null) return;

    AppLogger.debug('Handling ban of user: ${_userInfo!.id}');

    // Common ban reasons
    final l10n = AppLocalizations.of(context)!;
    final banReasons = [
      l10n.violationOfCommunityGuidelines,
      l10n.spamOrAdvertising,
      l10n.harassmentOrAbusiveBehavior,
      l10n.postingInappropriateContent,
      l10n.accountCompromiseOrSecurityIssue,
      l10n.otherPleaseSpecify,
    ];

    String? reasonResult;
    Map<String, dynamic>? banConfigResult;

    // Loop to allow going back from second dialog to first dialog
    while (true) {
      if (!context.mounted) return;

      // Step 1: Select reason
      reasonResult = await showDialog<String?>(
        context: context,
        builder: (BuildContext context) {
          String? selectedReason;
          final TextEditingController customReasonController = TextEditingController();
          final formKey = GlobalKey<FormState>();

          return StatefulBuilder(
            builder: (context, setState) {
              final colorScheme = Theme.of(context).colorScheme;
              final textTheme = Theme.of(context).textTheme;

              return AlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.banUser,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.pleaseSelectReasonForBanningUser(_userInfo!.username),
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.spacingL),
                        ...banReasons.map((reason) {
                          return RadioListTile<String>(
                            title: Text(
                              reason,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            value: reason,
                            groupValue: selectedReason,
                            onChanged: (value) {
                              setState(() {
                                selectedReason = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          );
                        }).toList(),
                        if (selectedReason == l10n.otherPleaseSpecify) ...[
                          const SizedBox(height: DesignTokens.spacingM),
                          TextFormField(
                            controller: customReasonController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.pleaseSpecifyReason,
                              hintText: AppLocalizations.of(context)!.enterReasonForBanningUser,
                              border: const OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (selectedReason == l10n.otherPleaseSpecify && (value == null || value.trim().isEmpty)) {
                                return AppLocalizations.of(context)!.pleaseSpecifyReason;
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                  FilledButton(
                    onPressed: selectedReason == null
                        ? null
                        : () {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }

                            final reason = selectedReason == 'Other (please specify)' ? customReasonController.text.trim() : selectedReason!;

                            Navigator.of(context).pop(reason);
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: Text(AppLocalizations.of(context)?.next ?? 'Next'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (reasonResult == null || !context.mounted) return;

      // Step 2: Select ban type and expiration
      banConfigResult = await showDialog<Map<String, dynamic>?>(
        context: context,
        builder: (BuildContext context) {
          String? banLength = 'permanent'; // 'permanent' or 'temporary'
          DateTime? selectedEndDate;

          return StatefulBuilder(
            builder: (context, setState) {
              final colorScheme = Theme.of(context).colorScheme;
              final textTheme = Theme.of(context).textTheme;

              return AlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.banUser,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.setBanDurationFor(_userInfo!.username) ?? 'Set the ban duration for ${_userInfo!.username}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spacingL),
                      RadioListTile<String>(
                        title: Text(
                          AppLocalizations.of(context)?.permanent ?? 'Permanent',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        value: 'permanent',
                        groupValue: banLength,
                        onChanged: (value) {
                          setState(() {
                            banLength = value;
                            selectedEndDate = null;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<String>(
                        title: Text(
                          AppLocalizations.of(context)?.temporary ?? 'Temporary',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        value: 'temporary',
                        groupValue: banLength,
                        onChanged: (value) {
                          setState(() {
                            banLength = value;
                            // Default to 7 days from now if no date selected
                            if (selectedEndDate == null) {
                              selectedEndDate = DateTime.now().add(const Duration(days: 7));
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      // Date picker for temporary ban
                      if (banLength == 'temporary') ...[
                        const SizedBox(height: DesignTokens.spacingM),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedEndDate ?? DateTime.now().add(const Duration(days: 7)),
                              firstDate: DateTime.now().add(const Duration(days: 1)),
                              lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
                            );
                            if (picked != null) {
                              // If time picker is available, show it
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(selectedEndDate ?? DateTime.now()),
                              );
                              setState(() {
                                if (time != null) {
                                  selectedEndDate = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    time.hour,
                                    time.minute,
                                  );
                                } else {
                                  selectedEndDate = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    23,
                                    59,
                                    59,
                                  );
                                }
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.banUntil,
                              border: const OutlineInputBorder(),
                              suffixIcon: const Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              selectedEndDate != null ? DateFormat.yMMMd().add_jm().format(selectedEndDate!) : AppLocalizations.of(context)!.selectDate,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        if (selectedEndDate == null) ...[
                          const SizedBox(height: DesignTokens.spacingXS),
                          Text(
                            AppLocalizations.of(context)?.pleaseSelectEndDate ?? 'Please select an end date',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: Text(
                      AppLocalizations.of(context)?.back ?? 'Back',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      if (banLength == 'temporary' && selectedEndDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)?.pleaseSelectEndDateForTemporaryBan ?? 'Please select an end date for temporary ban'),
                            backgroundColor: colorScheme.error,
                          ),
                        );
                        return;
                      }

                      int banExpires = 0;
                      if (banLength == 'temporary' && selectedEndDate != null) {
                        banExpires = selectedEndDate!.millisecondsSinceEpoch ~/ 1000;
                      }

                      Navigator.of(context).pop({
                        'reason': reasonResult,
                        'banExpires': banExpires,
                      });
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                    ),
                    child: Text(AppLocalizations.of(context)?.banUser ?? 'Ban User'),
                  ),
                ],
              );
            },
          );
        },
      );

      // If banConfigResult is null, user clicked "Back", so loop back to first dialog
      // If banConfigResult is not null, user completed the flow, so break out of loop
      if (banConfigResult != null) {
        break;
      }
      // Otherwise, continue loop to show first dialog again
    }

    if (context.mounted) {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: DesignTokens.iconSizeM,
                height: DesignTokens.iconSizeM,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onInverseSurface,
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spacingM),
              Text(
                AppLocalizations.of(context)?.banningUser ?? 'Banning user...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusS),
          ),
          margin: DesignTokens.paddingS,
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingL,
            vertical: DesignTokens.spacingM,
          ),
          duration: const Duration(seconds: 30),
        ),
      );

      try {
        AppLogger.debug('Banning user: ${_userInfo!.username} with reason: ${banConfigResult['reason']}, expires: ${banConfigResult['banExpires']}');
        final moderationProxy = SiteProxyService.getModerationProxy();
        final banResult = await moderationProxy.banUserAsync(
          _userInfo!.username,
          banConfigResult['reason'] as String,
          banConfigResult['banExpires'] as int,
          0, // deletePostMode - not used by Discourse API
          0, // deletePostValue - not used by Discourse API
        );

        AppLogger.debug('Ban result: ${banResult.result}, resultText: ${banResult.resultText}');

        if (context.mounted) {
          // Hide loading snackbar
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          // Check if the ban was successful
          if (banResult.result) {
            AppLogger.debug('User banned successfully: ${_userInfo!.id}');
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                    const SizedBox(width: DesignTokens.spacingM),
                    Text(
                      AppLocalizations.of(context)?.userBannedSuccessfully ?? 'User banned successfully',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onInverseSurface,
                          ),
                    ),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                ),
                margin: DesignTokens.paddingS,
                padding: EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingL,
                  vertical: DesignTokens.spacingM,
                ),
                duration: const Duration(seconds: 4),
              ),
            );
            // Refresh entire page to reflect ban status
            await _refreshProfile();
          } else {
            final errorMessage = (banResult.resultText != null && banResult.resultText!.isNotEmpty) ? banResult.resultText! : (AppLocalizations.of(context)?.failedToBanUser ?? 'Failed to ban user');
            AppLogger.debug('Ban failed for user: ${_userInfo!.id}, error: $errorMessage');
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: DesignTokens.spacingM),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                ),
                margin: DesignTokens.paddingS,
                padding: EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingL,
                  vertical: DesignTokens.spacingM,
                ),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } catch (e) {
        AppLogger.debug('Exception occurred while banning user: ${_userInfo!.id}, error: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Expanded(
                    child: Text(
                      'Failed to ban user: ${e.toString()}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusS),
              ),
              margin: DesignTokens.paddingS,
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingL,
                vertical: DesignTokens.spacingM,
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  Future<void> _handleUnbanUser(BuildContext context) async {
    if (_userInfo == null) return;

    AppLogger.debug('Handling unban of user: ${_userInfo!.id}');

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.unbanUser,
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Are you sure you want to unban ${_userInfo!.username}?',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text(AppLocalizations.of(context)?.unban ?? 'Unban'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: DesignTokens.iconSizeM,
              height: DesignTokens.iconSizeM,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.spacingM),
            Text(
              AppLocalizations.of(context)?.unbanningUser ?? 'Unbanning user...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusS),
        ),
        margin: DesignTokens.paddingS,
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingL,
          vertical: DesignTokens.spacingM,
        ),
        duration: const Duration(seconds: 30),
      ),
    );

    try {
      AppLogger.debug('Unbanning user: ${_userInfo!.id}');
      final moderationProxy = SiteProxyService.getModerationProxy();
      final unbanResult = await moderationProxy.unbanUserAsync(_userInfo!.id);

      AppLogger.debug('Unban result: ${unbanResult.result}, resultText: ${unbanResult.resultText}');

      if (context.mounted) {
        // Hide loading snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // Check if the unban was successful
        if (unbanResult.result) {
          AppLogger.debug('User unbanned successfully: ${_userInfo!.id}');
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Text(
                    AppLocalizations.of(context)?.userUnbannedSuccessfully ?? 'User unbanned successfully',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        ),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.inverseSurface,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusS),
              ),
              margin: DesignTokens.paddingS,
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingL,
                vertical: DesignTokens.spacingM,
              ),
              duration: const Duration(seconds: 4),
            ),
          );
          // Refresh entire page to reflect unban status
          await _refreshProfile();
        } else {
          final errorMessage =
              (unbanResult.resultText != null && unbanResult.resultText!.isNotEmpty) ? unbanResult.resultText! : (AppLocalizations.of(context)?.failedToUnbanUser ?? 'Failed to unban user');
          AppLogger.debug('Unban failed for user: ${_userInfo!.id}, error: $errorMessage');
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusS),
              ),
              margin: DesignTokens.paddingS,
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingL,
                vertical: DesignTokens.spacingM,
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.debug('Exception occurred while unbanning user: ${_userInfo!.id}, error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(width: DesignTokens.spacingM),
                Expanded(
                  child: Text(
                    'Failed to unban user: ${e.toString()}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _handleSpamCleanUser(BuildContext context) async {
    if (_userInfo == null) return;

    AppLogger.debug('Handling spam clean of user: ${_userInfo!.id}');

    // Initialize all checkboxes to true (checked)
    bool actionThreads = true;
    bool deleteMessages = true;
    bool deleteConversations = true;
    bool banUser = true;

    final result = await showDialog<Map<String, bool>?>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final colorScheme = Theme.of(context).colorScheme;
            final textTheme = Theme.of(context).textTheme;

            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)?.spamCleanUser ?? 'Spam Clean User',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spam Clean ${_userInfo!.username}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacingL),
                    Text(
                      AppLocalizations.of(context)?.selectActionsToPerform ?? 'Select the actions to perform:',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacingM),
                    CheckboxListTile(
                      title: Text(
                        AppLocalizations.of(context)?.handleThreads ?? 'Handle Threads',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context)?.moveOrDeleteThreadsBasedOnAdminSettings ?? 'Move or delete threads based on admin settings',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      value: actionThreads,
                      onChanged: (value) {
                        setState(() {
                          actionThreads = value ?? true;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: Text(
                        AppLocalizations.of(context)?.deleteMessages ?? 'Delete Messages',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        'Delete posts, profile posts, and comments',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      value: deleteMessages,
                      onChanged: (value) {
                        setState(() {
                          deleteMessages = value ?? true;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: Text(
                        AppLocalizations.of(context)?.deleteConversations ?? 'Delete Conversations',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context)?.deletePrivateConversations ?? 'Delete private conversations',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      value: deleteConversations,
                      onChanged: (value) {
                        setState(() {
                          deleteConversations = value ?? true;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: Text(
                        AppLocalizations.of(context)!.banUser,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context)?.banTheUserAccount ?? 'Ban the user account',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      value: banUser,
                      onChanged: (value) {
                        setState(() {
                          banUser = value ?? true;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: DesignTokens.spacingL),
                    Text(
                      'This action cannot be undone.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: DesignTokens.fontWeightMedium,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop({
                      'actionThreads': actionThreads,
                      'deleteMessages': deleteMessages,
                      'deleteConversations': deleteConversations,
                      'banUser': banUser,
                    });
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                  ),
                  child: Text(AppLocalizations.of(context)?.cleanSpam ?? 'Clean Spam'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || !context.mounted) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        final selectedActions = <String>[];
        final l10n = AppLocalizations.of(context)!;
        if (result['actionThreads'] == true) selectedActions.add(l10n.handleThreads);
        if (result['deleteMessages'] == true) selectedActions.add(l10n.deleteMessages);
        if (result['deleteConversations'] == true) selectedActions.add(l10n.deleteConversations);
        if (result['banUser'] == true) selectedActions.add(l10n.banUser);

        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.confirmSpamClean,
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to spam clean ${_userInfo!.username}?',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              if (selectedActions.isNotEmpty) ...[
                const SizedBox(height: DesignTokens.spacingL),
                Text(
                  'Selected actions:',
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingS),
                ...selectedActions.map((action) => Padding(
                      padding: const EdgeInsets.only(left: DesignTokens.spacingM, bottom: DesignTokens.spacingXS),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: DesignTokens.iconSizeS,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: DesignTokens.spacingS),
                          Text(
                            action,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
              const SizedBox(height: DesignTokens.spacingL),
              Text(
                'This action cannot be undone.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                  fontWeight: DesignTokens.fontWeightMedium,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: Text(AppLocalizations.of(context)?.confirm ?? 'Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: DesignTokens.iconSizeM,
              height: DesignTokens.iconSizeM,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.spacingM),
            Text(
              AppLocalizations.of(context)?.cleaningSpam ?? 'Cleaning spam...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusS),
        ),
        margin: DesignTokens.paddingS,
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingL,
          vertical: DesignTokens.spacingM,
        ),
        duration: const Duration(seconds: 30),
      ),
    );

    try {
      AppLogger.debug('Spam cleaning user: ${_userInfo!.username} (${_userInfo!.id}) with actions: $result');
      final moderationProxy = SiteProxyService.getModerationProxy();
      final spamCleanResult = await moderationProxy.spamCleanUserAsync(
        userId: _userInfo!.id,
        username: _userInfo!.username,
        actionThreads: result['actionThreads'] ?? false,
        deleteMessages: result['deleteMessages'] ?? false,
        deleteConversations: result['deleteConversations'] ?? false,
        banUser: result['banUser'] ?? false,
      );

      AppLogger.debug('Spam clean result: ${spamCleanResult.result}, resultText: ${spamCleanResult.resultText}');

      if (context.mounted) {
        // Hide loading snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // Check if the spam clean was successful
        if (spamCleanResult.result) {
          AppLogger.debug('User spam cleaned successfully: ${_userInfo!.id}');

          // Build success message with actions performed
          final actionsPerformed = <String>[];
          final l10n = AppLocalizations.of(context);
          if (spamCleanResult.actions != null) {
            if (spamCleanResult.actions!['action_threads'] == true) {
              actionsPerformed.add(l10n?.handledThreads ?? 'Handled threads');
            }
            if (spamCleanResult.actions!['delete_messages'] == true) {
              actionsPerformed.add(l10n?.deletedMessages ?? 'Deleted messages');
            }
            if (spamCleanResult.actions!['delete_conversations'] == true) {
              actionsPerformed.add(l10n?.deletedConversations ?? 'Deleted conversations');
            }
            if (spamCleanResult.actions!['ban_user'] == true) {
              actionsPerformed.add(l10n?.bannedUser ?? 'Banned user');
            }
          }

          final successMessage = actionsPerformed.isNotEmpty
              ? (l10n?.successfullyCleanedSpam(spamCleanResult.username ?? _userInfo!.username, actionsPerformed.join(', ')) ??
                  'Successfully cleaned spam for ${spamCleanResult.username ?? _userInfo!.username}. Actions: ${actionsPerformed.join(', ')}')
              : 'Successfully cleaned spam for ${spamCleanResult.username ?? _userInfo!.username}';

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Expanded(
                    child: Text(
                      successMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onInverseSurface,
                          ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.inverseSurface,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusS),
              ),
              margin: DesignTokens.paddingS,
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingL,
                vertical: DesignTokens.spacingM,
              ),
              duration: const Duration(seconds: 5),
            ),
          );
          // Refresh entire page state to reflect all changes
          // This will cause all widgets including UserRepliedPosts to rebuild and fetch fresh data
          if (context.mounted) {
            await _refreshProfile();
          }
        } else {
          final errorMessage = (spamCleanResult.resultText != null && spamCleanResult.resultText!.isNotEmpty) ? spamCleanResult.resultText! : 'Failed to clean spam';
          AppLogger.debug('Spam clean failed for user: ${_userInfo!.id}, error: $errorMessage');
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusS),
              ),
              margin: DesignTokens.paddingS,
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingL,
                vertical: DesignTokens.spacingM,
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.debug('Exception occurred while spam cleaning user: ${_userInfo!.id}, error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(width: DesignTokens.spacingM),
                Expanded(
                  child: Text(
                    'Failed to clean spam: ${e.toString()}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            ),
            margin: DesignTokens.paddingS,
            padding: EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingL,
              vertical: DesignTokens.spacingM,
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
