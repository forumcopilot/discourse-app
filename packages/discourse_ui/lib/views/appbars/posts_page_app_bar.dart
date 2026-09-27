import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import '../../theme/design_tokens.dart';
import '../../utils/emoji_shortcodes.dart';
import '../widgets/adaptive_app_bar_title.dart';

/// What the app bar offers when the topic page shows a private message (a
/// Discourse message is a topic): who is on it, and filing it away. Its
/// callbacks are set by what the viewer may do; a null one hides its item.
class PostsPageMessageMenu {
  const PostsPageMessageMenu({
    required this.participantCount,
    required this.onParticipants,
    required this.isArchived,
    required this.onArchive,
    required this.onMarkUnread,
    this.onEditTitle,
    this.isClosed = false,
    this.onClose,
    this.onLeave,
    this.onDelete,
  });

  final int participantCount;
  final VoidCallback onParticipants;

  /// Whether the viewer has archived it: [onArchive] then moves it back to
  /// the inbox.
  final bool isArchived;
  final VoidCallback onArchive;
  final VoidCallback onMarkUnread;
  final VoidCallback? onEditTitle;

  /// Whether it is closed: [onClose] then opens it again.
  final bool isClosed;
  final VoidCallback? onClose;
  final VoidCallback? onLeave;
  final VoidCallback? onDelete;
}

class PostsPageAppBar extends StatefulWidget implements PreferredSizeWidget {
  const PostsPageAppBar({
    required this.siteContext,
    this.message,
    required String title,
    this.onShare,
    this.onViewOnWeb,
    this.onSubscribe,
    this.onClose,
    this.onSticky,
    this.onDelete,
    this.onArchive,
    this.onRename,
    this.onToggleVisibility,
    this.onMove,
    this.onMerge,
    this.onRefresh,
    this.isSubscribed = false,
    this.showMarkRead = false,
    this.isClosed = false,
    this.isDeleted = false,
    this.isSticky = false,
    this.isArchived = false,
    this.isVisible = true,
    this.canSubscribe = false,
    this.canClose = false,
    this.canSticky = false,
    this.canDelete = false,
    this.canArchive = false,
    this.canRename = false,
    this.canToggleVisibility = false,
    this.canMove = false,
    this.canMerge = false,
    super.key,
  }) : _title = title;

  final SiteContext siteContext;
  final String _title;

  /// Set when the page shows a private message.
  final PostsPageMessageMenu? message;
  final VoidCallback? onShare;
  final VoidCallback? onViewOnWeb;
  final VoidCallback? onSubscribe;
  final VoidCallback? onClose;
  final VoidCallback? onSticky;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;
  final VoidCallback? onRename;
  final VoidCallback? onToggleVisibility;
  final VoidCallback? onMove;
  final VoidCallback? onMerge;
  final VoidCallback? onRefresh;
  final bool isSubscribed;
  final bool showMarkRead;
  final bool isClosed;
  final bool isDeleted;
  final bool isSticky;
  final bool isArchived;
  final bool isVisible;
  final bool canSubscribe;
  final bool canClose;
  final bool canSticky;
  final bool canDelete;
  final bool canArchive;
  final bool canRename;
  final bool canToggleVisibility;
  final bool canMove;
  final bool canMerge;

  @override
  State<PostsPageAppBar> createState() => PostsPageAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class PostsPageAppBarState extends State<PostsPageAppBar> {
  String _currentTitle = '';

  @override
  void initState() {
    super.initState();
    _currentTitle = widget._title;
  }

  void updateTitle(String newTitle) {
    if (newTitle.isNotEmpty && newTitle != _currentTitle) {
      setState(() {
        _currentTitle = newTitle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: AdaptiveAppBarTitle(withEmojiShortcodes(_currentTitle)),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
      ),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final message = widget.message;
    final l10n = AppLocalizations.of(context)!;
    PopupMenuItem<String> item(String value, IconData icon, String label,
            {bool danger = false}) =>
        PopupMenuItem<String>(
          value: value,
          child: Row(
            children: [
              Icon(icon,
                  color: danger ? colorScheme.error : colorScheme.onSurfaceVariant),
              const SizedBox(width: DesignTokens.spacingM),
              Text(label,
                  style: danger ? TextStyle(color: colorScheme.error) : null),
            ],
          ),
        );

    return [
      if (message != null)
        IconButton(
          icon: const Icon(Icons.people_outline_rounded),
          tooltip: l10n.participants(message.participantCount),
          onPressed: message.onParticipants,
        ),
      PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert_rounded,
          color: colorScheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'refresh',
            child: Row(
              children: [
                Icon(
                  Icons.refresh_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: DesignTokens.spacingM),
                Text(
                  AppLocalizations.of(context)?.refresh ?? 'Refresh',
                ),
              ],
            ),
          ),
          if (widget.siteContext.isLoggedIn && widget.canSubscribe && widget.onSubscribe != null)
            PopupMenuItem(
              value: 'subscribe',
              child: Row(
                children: [
                  Icon(
                    // Bell is filled when the user is at least at the
                    // Tracking level on Discourse (the proxy maps this
                    // to isSubscribed).
                    widget.isSubscribed
                        ? Icons.notifications_active
                        : Icons.notifications_none,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Text(
                    AppLocalizations.of(context)?.subscribe ?? 'Notifications',
                  ),
                ],
              ),
            ),
          // A message's own actions, as its page used to offer them.
          if (message != null) ...[
            message.isArchived
                ? item('msg_archive', Icons.move_to_inbox_outlined, l10n.moveToInbox)
                : item('msg_archive', Icons.archive_outlined, l10n.archiveMessage),
            item('msg_unread', Icons.mark_email_unread_outlined, l10n.markAsUnread),
            if (message.onEditTitle != null)
              item('msg_edit', Icons.edit_outlined, l10n.editConversation),
            if (message.onClose != null)
              message.isClosed
                  ? item('msg_close', Icons.lock_open_outlined, l10n.openConversation)
                  : item('msg_close', Icons.lock_outline, l10n.closeConversation),
          ],
          if (widget.siteContext.isLoggedIn && widget.canClose)
            PopupMenuItem(
              value: 'lock',
              child: Row(
                children: [
                  Icon(
                    widget.isClosed ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Text(
                    widget.isClosed 
                        ? (AppLocalizations.of(context)?.unlock ?? 'Unlock')
                        : (AppLocalizations.of(context)?.lock ?? 'Lock'),
                  ),
                ],
              ),
            ),
          if (widget.siteContext.isLoggedIn && widget.canSticky)
            PopupMenuItem(
              value: 'sticky',
              child: Row(
                children: [
                  Icon(
                    widget.isSticky ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Text(
                    widget.isSticky 
                        ? (AppLocalizations.of(context)?.unstick ?? 'Unstick')
                        : (AppLocalizations.of(context)?.stick ?? 'Stick'),
                  ),
                ],
              ),
            ),
          if (widget.siteContext.isLoggedIn && widget.canArchive)
            PopupMenuItem(
              value: 'archive',
              child: Row(
                children: [
                  Icon(
                    widget.isArchived
                        ? Icons.unarchive_outlined
                        : Icons.archive_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Text(
                    widget.isArchived ? 'Unarchive' : 'Archive',
                  ),
                ],
              ),
            ),
          if (widget.siteContext.isLoggedIn && widget.canToggleVisibility)
            PopupMenuItem(
              value: 'visibility',
              child: Row(
                children: [
                  Icon(
                    widget.isVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Text(
                    widget.isVisible ? 'Unlist topic' : 'List topic',
                  ),
                ],
              ),
            ),
          if (widget.siteContext.isLoggedIn && widget.canRename)
            PopupMenuItem(
              value: 'rename',
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Text(
                    AppLocalizations.of(context)!.renameTopic,
                  ),
                ],
              ),
            ),
          // Phase 5.26 — Move topic (re-categorise). Rides on the
          // same mod permissions as rename.
          if (widget.siteContext.isLoggedIn && widget.canMove)
            PopupMenuItem(
              value: 'move',
              child: Row(
                children: [
                  Icon(
                    Icons.drive_file_move_outline,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Text(
                    AppLocalizations.of(context)!.moveToCategory,
                  ),
                ],
              ),
            ),
          // Phase 5.26 — Merge into another topic. Mod-only.
          if (widget.siteContext.isLoggedIn && widget.canMerge)
            PopupMenuItem(
              value: 'merge',
              child: Row(
                children: [
                  Icon(
                    Icons.merge_type_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Text(
                    AppLocalizations.of(context)!.mergeIntoTopic,
                  ),
                ],
              ),
            ),
          if (widget.siteContext.isLoggedIn && widget.canDelete)
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    widget.isDeleted ? Icons.restore_from_trash_rounded : Icons.delete_outline_rounded,
                    color: colorScheme.error,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Text(
                    widget.isDeleted ? (AppLocalizations.of(context)?.undelete ?? 'Undelete') : (AppLocalizations.of(context)?.delete ?? 'Delete'),
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          if (widget.onShare != null)
            PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(
                    Icons.share_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Text(
                    AppLocalizations.of(context)?.share ?? 'Share',
                  ),
                ],
              ),
            ),
          if (widget.onViewOnWeb != null)
            PopupMenuItem(
              value: 'view_on_web',
              child: Row(
                children: [
                  Icon(
                    Icons.open_in_browser_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Text(
                    AppLocalizations.of(context)?.viewOnWeb ?? 'View on Web',
                  ),
                ],
              ),
            ),
          if (message?.onLeave != null || message?.onDelete != null)
            const PopupMenuDivider(),
          if (message?.onLeave != null)
            item('msg_leave', Icons.exit_to_app_rounded, l10n.leaveConversation2,
                danger: true),
          if (message?.onDelete != null)
            item('msg_delete', Icons.delete_outline_rounded, l10n.deleteMessage,
                danger: true),
        ],
        onSelected: (value) {
          switch (value) {
            case 'msg_archive':
              message?.onArchive();
              break;
            case 'msg_unread':
              message?.onMarkUnread();
              break;
            case 'msg_edit':
              message?.onEditTitle?.call();
              break;
            case 'msg_close':
              message?.onClose?.call();
              break;
            case 'msg_leave':
              message?.onLeave?.call();
              break;
            case 'msg_delete':
              message?.onDelete?.call();
              break;
            case 'refresh':
              widget.onRefresh?.call();
              break;
            case 'subscribe':
              widget.onSubscribe?.call();
              break;
            case 'share':
              widget.onShare?.call();
              break;
            case 'view_on_web':
              widget.onViewOnWeb?.call();
              break;
            case 'archive':
              _confirmAndDo(
                context: context,
                title: widget.isArchived ? 'Unarchive Topic' : 'Archive Topic',
                body: widget.isArchived
                    ? 'Reopen the topic for replies and edits?'
                    : 'Archiving locks the topic against any further '
                        'replies and edits. Existing content stays visible.',
                confirmLabel: widget.isArchived ? 'Unarchive' : 'Archive',
                onConfirm: () => widget.onArchive?.call(),
              );
              break;
            case 'visibility':
              _confirmAndDo(
                context: context,
                title: widget.isVisible ? 'Unlist Topic' : 'List Topic',
                body: widget.isVisible
                    ? 'Unlisted topics stay accessible by URL but are '
                        'hidden from category and Latest listings.'
                    : 'Re-list this topic so it appears in category and '
                        'Latest listings again.',
                confirmLabel:
                    widget.isVisible ? 'Unlist' : 'List',
                onConfirm: () => widget.onToggleVisibility?.call(),
              );
              break;
            case 'rename':
              _showRenameDialog(context: context);
              break;
            // Phase 5.26 — Move + Merge handlers fire callbacks
            // owned by `post_page.dart`. The handlers there show
            // their own picker UI (category sheet for move; topic-
            // id dialog for merge) and call the moderation proxy.
            case 'move':
              widget.onMove?.call();
              break;
            case 'merge':
              widget.onMerge?.call();
              break;
            case 'lock':
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      widget.isClosed ? 'Unlock Topic' : 'Lock Topic',
                    ),
                    content: Text(
                      widget.isClosed
                          ? 'Are you sure you want to unlock this topic? Other users will be able to reply and interact with it again.'
                          : 'Are you sure you want to lock this topic? Other users will not be able to reply or interact with it.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onClose?.call();
                        },
                        child: Text(widget.isClosed ? 'Unlock' : 'Lock'),
                      ),
                    ],
                  );
                },
              );
              break;
            case 'sticky':
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      widget.isSticky ? 'Unstick Topic' : 'Stick Topic',
                    ),
                    content: Text(
                      widget.isSticky
                          ? 'Are you sure you want to unstick this topic? It will no longer appear at the top of the forum.'
                          : 'Are you sure you want to stick this topic? It will appear at the top of the forum for all users.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onSticky?.call();
                        },
                        child: Text(widget.isSticky ? 'Unstick' : 'Stick'),
                      ),
                    ],
                  );
                },
              );
              break;
            case 'delete':
              // For undelete, show simple confirmation dialog
              if (widget.isDeleted) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        AppLocalizations.of(context)!.undeleteTopic,
                      ),
                      content: Text(
                        AppLocalizations.of(context)!.undeleteTopicConfirmation,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onDelete?.call();
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.error,
                            foregroundColor: colorScheme.onError,
                          ),
                          child: Text(
                            AppLocalizations.of(context)?.undelete ?? 'Undelete',
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onError,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else {
                // For delete, let _handleDelete show the comprehensive dialog
                widget.onDelete?.call();
              }
              break;
          }
        },
      ),
    ];
  }

  /// Generic confirm-dialog helper used by the archive / unlist actions.
  void _confirmAndDo({
    required BuildContext context,
    required String title,
    required String body,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirm();
              },
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
  }

  /// Rename-topic dialog. Pre-fills the current title and emits the
  /// new value through onRename when the user taps Save.
  void _showRenameDialog({required BuildContext context}) {
    final controller = TextEditingController(text: _currentTitle);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.renameTopic),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'New title',
              border: OutlineInputBorder(),
            ),
            maxLength: 255,
            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              final trimmed = value.trim();
              if (trimmed.isEmpty || trimmed == _currentTitle) {
                Navigator.of(dialogContext).pop();
                return;
              }
              Navigator.of(dialogContext).pop();
              _renameTo(trimmed);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            FilledButton(
              onPressed: () {
                final trimmed = controller.text.trim();
                if (trimmed.isEmpty || trimmed == _currentTitle) {
                  Navigator.of(dialogContext).pop();
                  return;
                }
                Navigator.of(dialogContext).pop();
                _renameTo(trimmed);
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }

  /// Stash the candidate title so [PostsPageAppBarState.updateTitle] can
  /// be called optimistically by post_page when the rename completes.
  String? _pendingRename;
  String? get pendingRename => _pendingRename;
  void _renameTo(String title) {
    _pendingRename = title;
    widget.onRename?.call();
  }
}
