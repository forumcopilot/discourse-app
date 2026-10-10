import 'package:discourse_core/discourse_core.dart'
    show
        DiscourseMessageDetails,
        DiscourseModerationProxy,
        DiscourseSiteCapabilities,
        DiscourseSiteContextExtension,
        DiscourseTopicStatus;
import 'package:forumcopilot_sdk/models/entities/fc_notification_level.dart';
import 'package:flutter/material.dart';
import '../core/errors/action_refused.dart';
import '../l10n/generated/app_localizations.dart';
import '../utils/error_message.dart';
import '../utils/snackbar_helper.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'widgets/notification_level_sheet.dart';
import '../theme/design_tokens.dart';
import 'lists/posts_list.dart';
import 'appbars/posts_page_app_bar.dart';
import '../utils/url_utils.dart';
import 'widgets/sheet_title.dart';
import 'widgets/category_badge.dart';
import 'widgets/feature_topic_sheet.dart';
import 'private_messaging/message_actions.dart';
import 'private_messaging/message_participants_sheet.dart';
import 'package:discourse_ui/utils/app_navigation.dart';
import '../l10n/kit_strings.dart';

class PostPage extends StatefulWidget {
  const PostPage({
    required this.siteContext,
    required this.topicId,
    required this.title,
    this.mode = PostsListMode.normal,
    this.anchorPostId,
    this.gotoPage,
    this.gotoPostNumber,
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

  /// With [PostsListMode.goto_page], the post to land on — see
  /// [PostsList.gotoPostNumber].
  final int? gotoPostNumber;
  final String? forumId;
  final bool isAnnouncement;

  /// What the page closes with when it showed a private message that was
  /// archived, moved to the inbox or left — it no longer belongs in the
  /// list it was opened from.
  static const messageRemoved = 'message_removed';

  /// … or marked unread.
  static const messageMarkedUnread = 'message_marked_unread';

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  /// Where the topic opens. Asked for no particular post, a signed-in reader
  /// lands after their last read post, as a topic title link does on the web
  /// (Topic#lastUnreadUrl); only Latest used to, so Unread, New, Top, Hot,
  /// category, tag and suggested topics opened at post 1 — New and Unread
  /// being exactly the lists read to catch up. Guests start at the top.
  PostsListMode get _openingMode =>
      widget.mode == PostsListMode.normal && widget.siteContext.isLoggedIn
          ? PostsListMode.first_unread
          : widget.mode;

  String? _forumId;
  /// Refresh callback from PostsList. When [scrollToPostId] is passed (e.g. after reply),
  /// the list refreshes by loading the thread at that post and scrolling to it in place.
  void Function([String? scrollToPostId])? _refreshCallback;
  /// The topic's state and what the viewer may do about it, as its last
  /// load (or an action since) recorded it; null until it has loaded. The
  /// title's status icons, the footer and the ⋮ menu all read it, so they
  /// cannot disagree.
  DiscourseTopicStatus? get _status =>
      DiscourseTopicStatus.forTopic(widget.siteContext.site.url, widget.topicId);

  void _onStatusChanged() {
    if (mounted) setState(() {});
  }

  bool _isRefreshing = false; // Add loading state for refresh
  String _actualTopicTitle = ''; // Track the actual topic title from server

  /// Set once the thread has loaded, when it is a private message: the page
  /// then offers a message's actions (a Discourse message is a topic, so
  /// this page reads messages too).
  DiscourseMessageDetails? _message;

  void _syncMessage() {
    final message = DiscourseMessageDetails.forTopic(widget.topicId);
    if (!identical(message, _message) && mounted) {
      setState(() => _message = message);
    }
  }

  /// The app bar's message actions, or null for a topic.
  PostsPageMessageMenu? _messageMenu() {
    final m = _message;
    if (m == null || !widget.siteContext.isLoggedIn) return null;
    final id = widget.topicId;
    // Archive, Move to inbox and Leave take the message out of the list it
    // came from, and Mark unread changes its row: the page closes with
    // [messageRemoved] or [messageMarkedUnread] for the inbox to act on.
    void closeWith(bool done, String result) {
      if (done && mounted) context.popOwnRoute(result);
    }

    return PostsPageMessageMenu(
      participantCount: m.participants.length + m.groups.length,
      onParticipants: () => MessageParticipantsSheet.show(
        context,
        m.participants,
        widget.siteContext,
        canInvite: m.canInvite,
        conversationId: id,
        onInviteSuccess: () => _refreshCallback?.call(),
        groups: m.groups,
        canRemove: m.canRemoveParticipants,
      ),
      isArchived: m.isArchived,
      onArchive: () async =>
          closeWith(await MessageActions.setArchived(context, id, !m.isArchived),
              PostPage.messageRemoved),
      onMarkUnread: () async =>
          closeWith(await MessageActions.markUnread(context, id),
              PostPage.messageMarkedUnread),
      onEditTitle: m.canEdit
          ? () async {
              final saved = await MessageActions.editTitle(context,
                  siteContext: widget.siteContext, topicId: id, canClose: m.canClose);
              if (saved) _refreshCallback?.call();
            }
          : null,
      isClosed: _status?.closed ?? false,
      onClose: m.canClose
          ? () async {
              if (await MessageActions.setClosed(
                  context, id, !(_status?.closed ?? false))) {
                _refreshCallback?.call();
              }
            }
          : null,
      onLeave: m.canLeave
          ? () async => closeWith(
              await MessageActions.leave(context, id), PostPage.messageRemoved)
          : null,
      onDelete: m.canDelete
          ? () async => closeWith(
              await MessageActions.delete(context, id), PostPage.messageRemoved)
          : null,
    );
  }
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
    DiscourseTopicStatus.changes.addListener(_onStatusChanged);
  }

  @override
  void dispose() {
    DiscourseTopicStatus.changes.removeListener(_onStatusChanged);
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
        SnackbarHelper.showError(context, AppLocalizations.of(context)!.failedToShareTopic(describeError(e, context: context)));
      }
    }
  }

  void _handleViewOnWeb() async {
    if (_threadUrl == null || _threadUrl!.isEmpty) {
      return;
    }

    await UrlUtils.openUrl(_threadUrl!);
  }

  /// The topic's notification level (Discourse's Watching / Tracking /
  /// Normal / Muted), the same picker as the footer's.
  void _handleNotifications() async {
    final status = _status;
    await NotificationLevelSheet.showForTopic(
      context: context,
      topicId: widget.topicId,
      isMessage: status?.isMessage ?? _message != null,
      currentLevel: status == null
          ? null
          : FCNotificationLevel.fromInt(status.notificationLevel),
    );
  }

  /// Runs a staff action on the topic and reports it the way web leaves it:
  /// the status icon changes at once (the proxy records the change), the
  /// reload brings the "Closed 1 minute ago" line into the stream, and a
  /// snackbar says what happened.
  Future<void> _runTopicAction(
      Future<({bool ok, String? message})> Function() action,
      String done) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final r = await action();
      if (!r.ok) throw ActionRefused(r.message ?? '');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(done), duration: const Duration(seconds: 2)));
      _refreshCallback?.call();
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
            context, l10n.topicActionFailed(describeError(e, context: context)));
      }
    }
  }

  void _handleClose() {
    final closed = _status?.closed ?? false;
    final proxy = SiteProxyFactory.getModerationProxy();
    final l10n = AppLocalizations.of(context)!;
    _runTopicAction(() async {
      final r = closed
          ? await proxy.uncloseTopicAsync(widget.topicId)
          : await proxy.closeTopicAsync(widget.topicId);
      return (ok: r.result, message: r.resultText);
    }, closed ? l10n.topicOpened : l10n.topicClosed);
  }

  /// Web's "Pin Topic…": pins the topic for everyone, in its category or
  /// (staff and trust level 4) globally, until a date staff pick in the
  /// sheet. Un-Pin acts at once.
  void _handlePin() async {
    final status = _status;
    final proxy = SiteProxyFactory.getModerationProxy();
    final l10n = AppLocalizations.of(context)!;
    if (status?.isPinnedByStaff ?? false) {
      _runTopicAction(() async {
        final r = await proxy.unstickTopicAsync(widget.topicId);
        return (ok: r.result, message: r.resultText);
      }, l10n.topicUnpinned);
      return;
    }
    if (proxy is! DiscourseModerationProxy) return;
    final user = widget.siteContext.loginDataOutput?.user;
    final staff = user != null &&
        (user.canModerate || user.userType == 'admin' || user.userType == 'moderator');
    final choice = await showFeatureTopicSheet(
      context,
      categoryName: DiscourseSiteCapabilities.forSite(widget.siteContext.site.pluginUrl)
              .categoryNameFor(_forumId ?? '') ??
          '',
      // Discourse's own rule (feature-topic modal): pin_unpin permission,
      // and staff or trust level 4 (guardian.can_moderate?).
      canPinGlobally: (status?.canPinUnpin ?? false) &&
          (staff || widget.siteContext.trustLevel == 4),
    );
    if (choice == null || !mounted) return;
    _runTopicAction(() async {
      final r = await proxy.pinTopicAsync(widget.topicId,
          globally: choice.globally, until: choice.until);
      return (ok: r.result, message: r.resultText);
    }, l10n.topicPinned);
  }

  void _handleArchive() {
    final archived = _status?.archived ?? false;
    final l10n = AppLocalizations.of(context)!;
    _runTopicAction(() async {
      final r = await SiteProxyFactory.getModerationProxy()
          .archiveTopicAsync(widget.topicId, archived: !archived);
      return (ok: r.result, message: r.resultText);
    }, archived ? l10n.topicUnarchived : l10n.topicArchived);
  }

  void _handleToggleVisibility() {
    final visible = _status?.visible ?? true;
    final l10n = AppLocalizations.of(context)!;
    _runTopicAction(() async {
      final r = await SiteProxyFactory.getModerationProxy()
          .setTopicVisibilityAsync(widget.topicId, visible: !visible);
      return (ok: r.result, message: r.resultText);
    }, visible ? l10n.topicUnlisted : l10n.topicListed);
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
      SnackbarHelper.showError(
          context,
          AppLocalizations.of(context)!.topicActionFailed(
              result.resultText ?? AppLocalizations.of(context)!.anErrorOccurred));
    }
  }

  /// Phase 5.26 — show a category picker bottom sheet, then
  /// PUT `/t/{id}.json` with the chosen `category_id`. Reuses the
  /// existing `forumProxy.getForumAsync` to populate the list.
  void _handleMoveTopic() async {
    final forumProxy = SiteProxyFactory.getForumProxy();
    final messenger = ScaffoldMessenger.of(context);

    final forumResult = await forumProxy.getForumAsync(false, '', false);
    if (!mounted) return;
    if (!forumResult.result || forumResult.forums.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.couldNotLoadCategories)),
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: SheetTitle(AppLocalizations.of(context)!.moveToCategory),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final c = categories[i];
                      return ListTile(
                        // Each category's own mark, as its badge shows it.
                        leading: CategoryMark(
                          style: DiscourseSiteCapabilities.forSite(
                                  widget.siteContext.site.pluginUrl)
                              .categoryStyleFor(c.id),
                          size: 14,
                        ),
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
            ? AppLocalizations.of(context)!.topicMoved
            : AppLocalizations.of(context)!.topicActionFailed(
                result.resultText?.isNotEmpty == true
                    ? result.resultText!
                    : AppLocalizations.of(context)!.anErrorOccurred)),
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
          title: Text(AppLocalizations.of(context)!.mergeIntoTopic),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.mergeTopicExplanation,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: DesignTokens.spacingM),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.destinationTopicId,
                  hintText: '1234',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppLocalizations.of(context)!.kit.cancel),
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
              child: Text(AppLocalizations.of(context)!.merge),
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
            ? AppLocalizations.of(context)!.topicMerged
            : result.resultText?.isNotEmpty == true
                ? result.resultText!
                : AppLocalizations.of(context)!.mergeTopicError),
      ),
    );
    if (result.result && mounted) context.popOwnRoute();
  }

  /// Web's Delete Topic, behind its confirmation. Staff keep seeing the
  /// deleted topic (and may un-delete it); an author deleting their own
  /// topic loses access to it, so the page closes.
  void _handleDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteTopic),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.deleteTopicConfirmNo),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteTopicConfirmYes),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final staysVisible = _status?.canClose == true || _status?.canPinUnpin == true;
    try {
      final r = await SiteProxyFactory.getModerationProxy()
          .deleteTopicExtendedAsync(widget.topicId);
      if (!r.result) throw ActionRefused(r.resultText ?? '');
      if (!mounted) return;
      if (staysVisible) {
        _refreshCallback?.call();
      } else {
        context.popOwnRoute();
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
            context, l10n.topicActionFailed(describeError(e, context: context)));
      }
    }
  }

  /// Web's Un-Delete Topic: no confirmation, it only restores.
  void _handleRecover() {
    final l10n = AppLocalizations.of(context)!;
    _runTopicAction(() async {
      final r = await SiteProxyFactory.getModerationProxy()
          .undeleteTopicAsync(widget.topicId, '');
      return (ok: r.result, message: r.resultText);
    }, l10n.topicRecovered);
  }

  /// Removes a deleted topic from the database, which Discourse offers
  /// only to admins on a site that allows it, after the topic has been
  /// deleted for a while.
  void _handlePermanentlyDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.permanentlyDelete),
        content: Text(l10n.permanentlyDeleteTopicConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.kit.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.permanentlyDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final r = await SiteProxyFactory.getModerationProxy()
          .deleteTopicExtendedAsync(widget.topicId, hardDelete: true);
      if (!r.result) throw ActionRefused(r.resultText ?? '');
      if (mounted) context.popOwnRoute();
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
            context, l10n.topicActionFailed(describeError(e, context: context)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PostsPageAppBar(
        siteContext: widget.siteContext,
        message: _messageMenu(),
        key: _appBarKey,
        title: widget.title,
        onShare: _handleShare,
        onViewOnWeb: _threadUrl != null && _threadUrl!.isNotEmpty ? _handleViewOnWeb : null,
        topicStatus: _status,
        onNotifications: _handleNotifications,
        onClose: _handleClose,
        onPin: _handlePin,
        onDelete: _handleDelete,
        onRecover: _handleRecover,
        onPermanentlyDelete: _handlePermanentlyDelete,
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
              if (context.mounted) {
                SnackbarHelper.showError(context, AppLocalizations.of(context)!.refreshFailed(describeError(e, context: context)));
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
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Posts list
              Expanded(
                child: PostsList(
                  siteContext: widget.siteContext,
                  topicId: widget.topicId,
                  topicTitle: widget.title,
                  mode: _openingMode,
                  anchorPostId: widget.anchorPostId,
                  gotoPage: widget.gotoPage,
                  gotoPostNumber: widget.gotoPostNumber,
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
                  onTopicTitleLoaded: (topicTitle) {
                    _syncMessage();
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
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            ),
            Center(
              child: Container(
                padding: DesignTokens.paddingScreen,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
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
                      AppLocalizations.of(context)!.refreshing,
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
