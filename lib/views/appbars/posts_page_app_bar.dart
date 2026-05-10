import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import '../../theme/design_tokens.dart';

class PostsPageAppBar extends StatefulWidget implements PreferredSizeWidget {
  const PostsPageAppBar({
    required this.siteContext,
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
    super.key,
  }) : _title = title;

  final SiteContext siteContext;
  final String _title;
  final VoidCallback? onShare;
  final VoidCallback? onViewOnWeb;
  final VoidCallback? onSubscribe;
  final VoidCallback? onClose;
  final VoidCallback? onSticky;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;
  final VoidCallback? onRename;
  final VoidCallback? onToggleVisibility;
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      title: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate available width for the title
          // Subtract space for back button and actions
          final availableWidth = constraints.maxWidth - 80; // 40 for back button, 40 for actions

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: _buildAdaptiveTitle(
                  _currentTitle,
                  colorScheme,
                  textTheme,
                  availableWidth,
                ),
              ),
            ],
          );
        },
      ),
      backgroundColor: colorScheme.surface,
      elevation: 3,
      shadowColor: colorScheme.shadow.withOpacity(DesignTokens.opacityLow),
      surfaceTintColor: colorScheme.surfaceTint,
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
      ),
      actions: _buildActions(context),
      centerTitle: false,
    );
  }

  Widget _buildAdaptiveTitle(String title, ColorScheme colorScheme, TextTheme textTheme, double availableWidth) {
    // Test if the title fits in one line with font size 20
    final textSpan = TextSpan(
      text: title,
      style: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: DesignTokens.fontWeightMedium,
        fontSize: DesignTokens.fontSizeL,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout(maxWidth: availableWidth);

    if (textPainter.didExceedMaxLines) {
      // Text is too long, use smaller font size for both lines
      return Text(
        title,
        style: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: DesignTokens.fontWeightMedium,
          fontSize: DesignTokens.fontSizeM,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      // Text fits in one line, use regular font size
      return Text(
        title,
        style: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
          fontSize: DesignTokens.fontSizeL,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  List<Widget> _buildActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return [
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
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
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
                    widget.isSubscribed ? Icons.watch_rounded : Icons.watch_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Text(
                    widget.isSubscribed
                        ? (AppLocalizations.of(context)?.unsubscribe ?? 'Unsubscribe')
                        : (AppLocalizations.of(context)?.subscribe ?? 'Subscribe'),
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
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
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
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
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
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
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
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
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
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
                    'Rename topic',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
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
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
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
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
        ],
        onSelected: (value) {
          switch (value) {
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
            case 'lock':
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      widget.isClosed ? 'Unlock Topic' : 'Lock Topic',
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    content: Text(
                      widget.isClosed
                          ? 'Are you sure you want to unlock this topic? Other users will be able to reply and interact with it again.'
                          : 'Are you sure you want to lock this topic? Other users will not be able to reply or interact with it.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancel',
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onClose?.call();
                        },
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
                        child: Text(
                          widget.isClosed ? 'Unlock' : 'Lock',
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.onPrimary,
                          ),
                        ),
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
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                    content: Text(
                      widget.isSticky
                          ? 'Are you sure you want to unstick this topic? It will no longer appear at the top of the forum.'
                          : 'Are you sure you want to stick this topic? It will appear at the top of the forum for all users.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancel',
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onSticky?.call();
                        },
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
                        child: Text(
                          widget.isSticky ? 'Unstick' : 'Stick',
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.onPrimary,
                          ),
                        ),
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
                        'Undelete Topic',
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                      content: Text(
                        'Are you sure you want to undelete this topic? It will be visible to other users again.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onDelete?.call();
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.error,
                            foregroundColor: colorScheme.onError,
                            padding: EdgeInsets.symmetric(
                              horizontal: DesignTokens.spacingXL,
                              vertical: DesignTokens.spacingM,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                            ),
                            elevation: DesignTokens.elevationMedium,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title,
              style: textTheme.titleLarge
                  ?.copyWith(color: colorScheme.onSurface)),
          content: Text(body,
              style: textTheme.bodyLarge
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
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
          title: const Text('Rename Topic'),
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
              child: const Text('Cancel'),
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
              child: const Text('Save'),
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
