import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/models/entities/fc_notification_level.dart';
import 'package:forumcopilot_sdk/models/results/fc_moderation_result.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscourseModerationProxy, DiscourseSubscriptionProxy;
import 'widgets/notification_level_sheet.dart';
import '../theme/design_tokens.dart';
import '../core/logging/app_logger.dart';
import 'widgets/forum_breadcrumb.dart';
import 'lists/posts_list.dart';
import 'reply_page.dart';
import 'widgets/post_actions.dart';
import 'widgets/delete_topic_dialog.dart';
import 'appbars/posts_page_app_bar.dart';
import '../utils/url_utils.dart';

class PostPage extends StatefulWidget {
  const PostPage({
    required this.siteContext,
    required this.topicId,
    required this.title,
    this.mode = PostsListMode.normal,
    this.anchorPostId,
    this.gotoPage,
    this.forumId,
    this.isAnnouncement = false,
    super.key,
  });

  final SiteContext siteContext;
  final String topicId;
  final String title;
  final PostsListMode mode;
  final String? anchorPostId;
  final int? gotoPage;
  final String? forumId;
  final bool isAnnouncement;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  String? _forumId;
  /// Refresh callback from PostsList. When [scrollToPostId] is passed (e.g. after reply),
  /// the list refreshes by loading the thread at that post and scrolling to it in place.
  void Function([String? scrollToPostId])? _refreshCallback;
  bool _isSubscribed = false;
  bool _isClosed = false;
  bool _isSticky = false;
  bool _isDeleted = false;
  bool _isArchived = false;
  bool _isVisible = true;
  bool _showDeletedBanner = true;
  bool _showClosedBanner = true;
  bool _showStickyBanner = true;
  bool _showSubscribedBanner = true;
  String? _forumName;
  bool _canSubscribe = false;
  bool _canClose = false;
  bool _canSticky = false;
  bool _canDelete = false;
  bool _canArchive = false;
  bool _canRename = false;
  // Phase 5.26 — move/merge ride on the same mod cap cluster as
  // close/archive/rename/unlist (Discourse's `can_perform_action`
  // for mods).
  bool _canMove = false;
  bool _canMerge = false;
  bool _canToggleVisibility = false;
  bool _isRefreshing = false; // Add loading state for refresh
  String _actualTopicTitle = ''; // Track the actual topic title from server
  String? _threadUrl; // Track the thread URL from server

  // GlobalKey to reference the app bar state
  final GlobalKey<PostsPageAppBarState> _appBarKey = GlobalKey<PostsPageAppBarState>();

  @override
  void initState() {
    super.initState();
    // Initialize _forumId from widget.forumId if provided
    if (widget.forumId != null) {
      _forumId = widget.forumId;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleShare() async {
    try {
      final topicTitle = _actualTopicTitle.isNotEmpty ? _actualTopicTitle : widget.title;

      // Use the URL from API if available, otherwise fall back to manual construction
      String? urlToShare = _threadUrl;

      if (urlToShare == null || urlToShare.isEmpty) {
        // Fallback to manual URL construction for backward compatibility
        final forumUrl = widget.siteContext.site.pluginUrl;
        final forumType = widget.siteContext.ConfigData.forumType;
        final subForumId = _forumId ?? '';

        urlToShare = UrlUtils.getPostUrl(
          siteContext: widget.siteContext,
          postId: '',
          topicTitle: topicTitle,
          subForumId: subForumId,
          threadId: widget.topicId,
          forumUrl: forumUrl,
          forumType: UrlUtils.parseForumType(forumType),
        );
      }

      await UrlUtils.shareUrl(urlToShare);
    } catch (e) {
      // If sharing fails, show an error message
      if (mounted) {
        // Capture ScaffoldMessengerState to ensure dismiss button works correctly
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedToShareTopic(e.toString()),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            behavior: SnackBarBehavior.floating,
            margin: DesignTokens.paddingS,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            ),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: AppLocalizations.of(context)?.dismiss ?? 'Dismiss',
              textColor: Theme.of(context).colorScheme.onErrorContainer,
              onPressed: () {
                scaffoldMessenger.hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }

  void _handleViewOnWeb() async {
    if (_threadUrl == null || _threadUrl!.isEmpty) {
      return;
    }

    await UrlUtils.openUrl(_threadUrl!);
  }

  void _handleSubscribe() async {
    // Check if user is logged in before proceeding with subscription
    if (!widget.siteContext.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.pleaseLoginToSubscribe,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          margin: DesignTokens.paddingS,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusS),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final proxy = SiteProxyFactory.getSubscriptionProxy();
    if (proxy is DiscourseSubscriptionProxy) {
      // Discourse-native: surface the full 4-level Watching/Tracking/
      // Normal/Muted picker instead of a binary toggle.
      await NotificationLevelSheet.showForTopic(
        context: context,
        topicId: widget.topicId,
        currentLevel: _isSubscribed
            ? FCNotificationLevel.watching
            : FCNotificationLevel.normal,
        onChanged: () {
          if (!mounted) return;
          // Refresh /t/{id}.json so the subscribed banner + bell icon
          // reflect the new level. We intentionally don't try to mirror
          // the chosen level locally — the picker may set Tracking or
          // Muted, neither of which maps cleanly to _isSubscribed.
          if (_refreshCallback != null) _refreshCallback!();
        },
      );
      return;
    }

    try {
      final subscriptionProxy = proxy;

      if (_isSubscribed) {
        await subscriptionProxy.unsubscribeTopicAsync(widget.topicId);
      } else {
        await subscriptionProxy.subscribeTopicAsync(widget.topicId, 1); // mode 1 for subscribe
      }

      if (mounted) {
        setState(() {
          _isSubscribed = !_isSubscribed;
        });
      }
    } catch (e) {
      if (mounted) {
        // Capture ScaffoldMessengerState to ensure dismiss button works correctly
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        // Hide any existing SnackBar before showing a new one
        scaffoldMessenger.hideCurrentSnackBar();
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedToSubscribeToThread,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            ),
            margin: DesignTokens.paddingS,
            padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingL - DesignTokens.spacingXS),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: AppLocalizations.of(context)?.dismiss ?? 'Dismiss',
              textColor: Theme.of(context).colorScheme.onErrorContainer,
              onPressed: () {
                scaffoldMessenger.hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }

  void _handleClose() async {
    final moderationProxy = SiteProxyFactory.getModerationProxy();
    try {
      if (_isClosed) {
        await moderationProxy.uncloseTopicAsync(widget.topicId);
      } else {
        await moderationProxy.closeTopicAsync(widget.topicId);
      }
      if (mounted) {
        setState(() {
          _isClosed = !_isClosed;
        });
        // Capture ScaffoldMessengerState to ensure dismiss button works correctly
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              _isClosed ? AppLocalizations.of(context)!.topicClosed : AppLocalizations.of(context)!.topicOpened,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
            ),
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            ),
            margin: DesignTokens.paddingS,
            padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingL - DesignTokens.spacingXS),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: AppLocalizations.of(context)?.dismiss ?? 'Dismiss',
              textColor: Theme.of(context).colorScheme.inversePrimary,
              onPressed: () {
                scaffoldMessenger.hideCurrentSnackBar();
              },
            ),
          ),
        );
        _refreshCallback?.call();
      }
    } catch (e) {
      if (mounted) {
        // Capture ScaffoldMessengerState to ensure dismiss button works correctly
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${_isClosed ? 'open' : 'close'} topic: $e',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            ),
            margin: DesignTokens.paddingS,
            padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingL - DesignTokens.spacingXS),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: AppLocalizations.of(context)?.dismiss ?? 'Dismiss',
              textColor: Theme.of(context).colorScheme.onErrorContainer,
              onPressed: () {
                scaffoldMessenger.hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }

  void _handleSticky() async {
    final moderationProxy = SiteProxyFactory.getModerationProxy();
    try {
      if (_isSticky) {
        await moderationProxy.unstickTopicAsync(widget.topicId);
      } else {
        await moderationProxy.stickTopicAsync(widget.topicId);
      }
      if (mounted) {
        setState(() {
          _isSticky = !_isSticky;
        });
        // Capture ScaffoldMessengerState to ensure dismiss button works correctly
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              _isSticky ? AppLocalizations.of(context)!.topicStickied : AppLocalizations.of(context)!.topicUnstickied,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
            ),
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            ),
            margin: DesignTokens.paddingS,
            padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingL - DesignTokens.spacingXS),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: AppLocalizations.of(context)?.dismiss ?? 'Dismiss',
              textColor: Theme.of(context).colorScheme.inversePrimary,
              onPressed: () {
                scaffoldMessenger.hideCurrentSnackBar();
              },
            ),
          ),
        );
        _refreshCallback?.call();
      }
    } catch (e) {
      if (mounted) {
        // Capture ScaffoldMessengerState to ensure dismiss button works correctly
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${_isSticky ? 'unstick' : 'stick'} topic: $e',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            ),
            margin: DesignTokens.paddingS,
            padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingL - DesignTokens.spacingXS),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: AppLocalizations.of(context)?.dismiss ?? 'Dismiss',
              textColor: Theme.of(context).colorScheme.onErrorContainer,
              onPressed: () {
                scaffoldMessenger.hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }

  void _handleArchive() async {
    final wasArchived = _isArchived;
    setState(() => _isArchived = !wasArchived);
    final result = await SiteProxyFactory.getModerationProxy()
        .archiveTopicAsync(widget.topicId, archived: !wasArchived);
    if (!mounted) return;
    if (!result.result) {
      setState(() => _isArchived = wasArchived);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.resultText?.isNotEmpty == true
              ? result.resultText!
              : (wasArchived
                  ? 'Failed to unarchive topic'
                  : 'Failed to archive topic')),
        ),
      );
    } else {
      _refreshCallback?.call();
    }
  }

  void _handleToggleVisibility() async {
    final wasVisible = _isVisible;
    setState(() => _isVisible = !wasVisible);
    final result = await SiteProxyFactory.getModerationProxy()
        .setTopicVisibilityAsync(widget.topicId, visible: !wasVisible);
    if (!mounted) return;
    if (!result.result) {
      setState(() => _isVisible = wasVisible);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.resultText?.isNotEmpty == true
              ? result.resultText!
              : (wasVisible
                  ? 'Failed to unlist topic'
                  : 'Failed to list topic')),
        ),
      );
    } else {
      _refreshCallback?.call();
    }
  }

  void _handleRename() async {
    final pending = _appBarKey.currentState?.pendingRename;
    if (pending == null || pending.trim().isEmpty) return;
    final proxy = SiteProxyFactory.getModerationProxy();
    final result = await proxy.renameTopicAsync(widget.topicId, pending);
    if (!mounted) return;
    if (result.result) {
      // Optimistically update both our cached title and the app bar's.
      setState(() {
        _actualTopicTitle = pending;
      });
      _appBarKey.currentState?.updateTitle(pending);
      _refreshCallback?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Failed to rename: ${result.resultText ?? "unknown error"}')),
      );
    }
  }

  /// Phase 5.26 — show a category picker bottom sheet, then
  /// PUT `/t/{id}.json` with the chosen `category_id`. Reuses the
  /// existing `forumProxy.getForumAsync` to populate the list.
  void _handleMoveTopic() async {
    final forumProxy = SiteProxyFactory.getForumProxy();
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final forumResult = await forumProxy.getForumAsync(false, '', false);
    if (!mounted) return;
    if (!forumResult.result || forumResult.forums.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't load categories.")),
      );
      return;
    }
    final categories = forumResult.forums;

    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.85,
          initialChildSize: 0.6,
          builder: (_, scrollController) => SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DesignTokens.spacingL, 0,
                    DesignTokens.spacingL, DesignTokens.spacingS,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Move to category',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: DesignTokens.fontWeightSemiBold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final c = categories[i];
                      return ListTile(
                        leading: Icon(Icons.folder_outlined,
                            color: colorScheme.onSurfaceVariant),
                        title: Text(c.name),
                        onTap: () =>
                            Navigator.of(sheetContext).pop(c.id),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked == null || !mounted) return;

    final modProxy = SiteProxyFactory.getModerationProxy();
    final result = await modProxy.moveTopicAsync(
      widget.topicId,
      picked,
      false,
    );
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(result.result
            ? 'Moved.'
            : result.resultText?.isNotEmpty == true
                ? result.resultText!
                : "Couldn't move topic"),
      ),
    );
    if (result.result) _refreshCallback?.call();
  }

  /// Phase 5.26 — merge this topic into another. Discourse: POST
  /// `/t/{source}/merge-topic.json { destination_topic_id: <id> }`.
  /// Power-user surface; the picker is just a numeric topic-id
  /// input. Most mods know their target ids from web admin tools.
  void _handleMergeTopic() async {
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final controller = TextEditingController();

    final confirmed = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Merge into topic'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "All posts from this topic will be moved into the "
                "target topic. This can't be undone via the app — "
                'recover via web admin if needed.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: DesignTokens.spacingM),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Destination topic id',
                  hintText: 'e.g. 1234',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final v = controller.text.trim();
                if (v.isEmpty || int.tryParse(v) == null) return;
                Navigator.of(dialogContext).pop(v);
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: const Text('Merge'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (confirmed == null || !mounted) return;

    final modProxy = SiteProxyFactory.getModerationProxy();
    // mergeTopicAsync(topicId1, topicId2) is "merge topic2 into
    // topic1" — caller-facing semantics flip the args.
    final result = await modProxy.mergeTopicAsync(
      confirmed,
      widget.topicId,
      false,
    );
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(result.result
            ? 'Merged.'
            : result.resultText?.isNotEmpty == true
                ? result.resultText!
                : "Couldn't merge topic"),
      ),
    );
    if (result.result) Navigator.of(context).pop();
  }

  void _handleDelete() async {
    final moderationProxy = SiteProxyFactory.getModerationProxy();

    // Handle undelete with simple confirmation (already handled in app bar)
    if (_isDeleted) {
      try {
        await moderationProxy.undeleteTopicAsync(widget.topicId, '');
        if (mounted) {
          setState(() {
            _isDeleted = false;
          });
          _refreshCallback?.call();
        }
      } catch (e) {
        // Error handling - no toast message
      }
      return;
    }

    // Handle delete with comprehensive dialog
    final result = await DeleteTopicDialog.show(
      context,
      topicTitle: widget.title,
    );

    if (result == null) {
      // User cancelled
      return;
    }

    final hardDelete = result['hardDelete'] as bool;
    final reason = result['reason'] as String? ?? '';

    try {
      // Phase 5.42 — deleteTopicExtendedAsync is on IFCModerationProxy
      // now; no more is-DiscourseModerationProxy cast.
      final deleteResult = await moderationProxy.deleteTopicExtendedAsync(
        widget.topicId,
        deleteForReal: hardDelete,
      );
      // The XF-shaped `reason` parameter doesn't round-trip on
      // Discourse; preserve it for audit trail in the snackbar only.
      if (reason.isNotEmpty) {
        AppLogger.debug('Topic delete reason (Discourse drops): $reason');
      }

      if (!deleteResult.result) {
        throw Exception(deleteResult.resultText ?? 'Failed to delete topic');
      }

      if (mounted) {
        setState(() {
          _isDeleted = true;
        });
        _refreshCallback?.call();

        // If hard delete was successful, navigate back to previous screen
        if (hardDelete) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      // Error handling - no toast message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PostsPageAppBar(
        siteContext: widget.siteContext,
        key: _appBarKey,
        title: widget.title,
        onShare: _handleShare,
        onViewOnWeb: _threadUrl != null && _threadUrl!.isNotEmpty ? _handleViewOnWeb : null,
        onSubscribe: _handleSubscribe,
        onClose: _handleClose,
        onSticky: _handleSticky,
        onDelete: _handleDelete,
        onArchive: _handleArchive,
        onRename: _handleRename,
        onMove: _handleMoveTopic,
        onMerge: _handleMergeTopic,
        onToggleVisibility: _handleToggleVisibility,
        onRefresh: () async {
          if (_refreshCallback != null && !_isRefreshing) {
            setState(() {
              _isRefreshing = true;
            });
            try {
              await Future.delayed(Duration.zero); // Allow UI to update
              _refreshCallback!();
              // Wait for the refresh to complete with a reasonable timeout
              await Future.delayed(const Duration(milliseconds: 800));
            } catch (e) {
              // Handle any errors during refresh
              if (mounted) {
                // Capture ScaffoldMessengerState to ensure dismiss button works correctly
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Refresh failed: $e',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                    ),
                    margin: DesignTokens.paddingS,
                    padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingL - DesignTokens.spacingXS),
                    duration: const Duration(seconds: 4),
                    action: SnackBarAction(
                      label: AppLocalizations.of(context)?.dismiss ?? 'Dismiss',
                      textColor: Theme.of(context).colorScheme.onErrorContainer,
                      onPressed: () {
                        scaffoldMessenger.hideCurrentSnackBar();
                      },
                    ),
                  ),
                );
              }
            } finally {
              if (mounted) {
                setState(() {
                  _isRefreshing = false;
                });
              }
            }
          }
        },
        isSubscribed: _isSubscribed,
        showMarkRead: false,
        isClosed: _isClosed,
        isDeleted: _isDeleted,
        isSticky: _isSticky,
        canSubscribe: _canSubscribe,
        canClose: _canClose,
        canSticky: _canSticky,
        canDelete: _canDelete,
        canArchive: _canArchive,
        canRename: _canRename,
        canMove: _canMove,
        canMerge: _canMerge,
        canToggleVisibility: _canToggleVisibility,
        isArchived: _isArchived,
        isVisible: _isVisible,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Status banners
              if ((_isDeleted && _showDeletedBanner) || (_isClosed && _showClosedBanner) || (_isSticky && _showStickyBanner) || (_isSubscribed && _showSubscribedBanner)) ...[
                // Deleted banner
                if (_isDeleted && _showDeletedBanner)
                  Container(
                    width: double.infinity,
                    padding: DesignTokens.paddingInput,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer.withOpacity(DesignTokens.opacityHigh),
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(DesignTokens.opacityMediumLow),
                          width: DesignTokens.borderWidthThin,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.delete_rounded,
                          size: DesignTokens.iconSizeM,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: DesignTokens.spacingM),
                        Expanded(
                          child: Text(
                            'This topic is deleted and hidden from other users',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: DesignTokens.iconSizeM,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          onPressed: () {
                            setState(() {
                              _showDeletedBanner = false;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: DesignTokens.iconSizeM,
                        ),
                      ],
                    ),
                  ),
                // Closed banner
                if (_isClosed && _showClosedBanner)
                  Container(
                    width: double.infinity,
                    padding: DesignTokens.paddingInput,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(DesignTokens.opacityHigh),
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(DesignTokens.opacityMediumLow),
                          width: DesignTokens.borderWidthThin,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          size: DesignTokens.iconSizeM,
                          color: Theme.of(context).colorScheme.onTertiaryContainer,
                        ),
                        const SizedBox(width: DesignTokens.spacingM),
                        Expanded(
                          child: Text(
                            'This topic is closed and no longer accepting replies',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                                ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: DesignTokens.iconSizeM,
                            color: Theme.of(context).colorScheme.onTertiaryContainer,
                          ),
                          onPressed: () {
                            setState(() {
                              _showClosedBanner = false;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: DesignTokens.iconSizeM,
                        ),
                      ],
                    ),
                  ),
                // Sticky banner
                if (_isSticky && _showStickyBanner)
                  Container(
                    width: double.infinity,
                    padding: DesignTokens.paddingInput,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(DesignTokens.opacityHigh),
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(DesignTokens.opacityMediumLow),
                          width: DesignTokens.borderWidthThin,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.push_pin_outlined,
                          size: DesignTokens.iconSizeM,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: DesignTokens.spacingM),
                        Expanded(
                          child: Text(
                            'This topic is pinned to the top of the forum',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: DesignTokens.iconSizeM,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          onPressed: () {
                            setState(() {
                              _showStickyBanner = false;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: DesignTokens.iconSizeM,
                        ),
                      ],
                    ),
                  ),
                // Subscribed banner
                if (_isSubscribed && _showSubscribedBanner)
                  Container(
                    width: double.infinity,
                    padding: DesignTokens.paddingInput,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(DesignTokens.opacityHigh),
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(DesignTokens.opacityMediumLow),
                          width: DesignTokens.borderWidthThin,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          size: DesignTokens.iconSizeM,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: DesignTokens.spacingM),
                        Expanded(
                          child: Text(
                            'You are subscribed to this topic',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: DesignTokens.iconSizeM,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                          onPressed: () {
                            setState(() {
                              _showSubscribedBanner = false;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: DesignTokens.iconSizeM,
                        ),
                      ],
                    ),
                  ),
              ],
              // Posts list
              Expanded(
                child: PostsList(
                  siteContext: widget.siteContext,
                  topicId: widget.topicId,
                  topicTitle: widget.title,
                  mode: widget.mode,
                  anchorPostId: widget.anchorPostId,
                  gotoPage: widget.gotoPage,
                  isAnnouncement: widget.isAnnouncement,
                  forumId: _forumId,
                  onForumIdAvailable: (forumId) {
                    setState(() => _forumId = forumId);
                  },
                  onRefreshAvailable: (refreshCallback) {
                    setState(() {
                      _refreshCallback = refreshCallback;
                    });
                  },
                  onSubscriptionStatusChanged: (isSubscribed) {
                    setState(() {
                      _isSubscribed = isSubscribed;
                    });
                  },
                  onClosedStatusChanged: (isClosed) {
                    setState(() {
                      _isClosed = isClosed;
                    });
                  },
                  onStickyStatusChanged: (isSticky) {
                    setState(() {
                      _isSticky = isSticky;
                    });
                  },
                  onDeletedStatusChanged: (isDeleted) {
                    setState(() {
                      _isDeleted = isDeleted;
                    });
                  },
                  onCanSubscribeChanged: (canSubscribe) {
                    setState(() {
                      _canSubscribe = canSubscribe;
                    });
                  },
                  onCanCloseChanged: (canClose) {
                    setState(() {
                      _canClose = canClose;
                      // Discourse mods who can close can also archive,
                      // unlist, and rename. We piggyback on canClose
                      // rather than wiring three more PostsList
                      // callbacks for caps that always move together.
                      _canArchive = canClose;
                      _canRename = canClose;
                      _canToggleVisibility = canClose;
                      _canMove = canClose;
                      _canMerge = canClose;
                    });
                  },
                  onCanStickyChanged: (canSticky) {
                    setState(() {
                      _canSticky = canSticky;
                    });
                  },
                  onCanDeleteChanged: (canDelete) {
                    setState(() {
                      _canDelete = canDelete;
                    });
                  },
                  onTopicTitleLoaded: (topicTitle) {
                    if (topicTitle.isNotEmpty && topicTitle != _actualTopicTitle) {
                      setState(() {
                        _actualTopicTitle = topicTitle;
                      });
                      // Update the app bar title
                      _appBarKey.currentState?.updateTitle(topicTitle);
                    }
                  },
                  onThreadUrlAvailable: (threadUrl) {
                    setState(() {
                      _threadUrl = threadUrl;
                    });
                  },
                ),
              ),
            ],
          ),
          // Loading overlay when refreshing
          if (_isRefreshing) ...[
            ModalBarrier(
              dismissible: false,
              color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ),
            Center(
              child: Container(
                padding: DesignTokens.paddingScreen,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Refreshing...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
