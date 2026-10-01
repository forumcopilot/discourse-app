import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import '../../theme/design_tokens.dart';
import '../../utils/emoji_shortcodes.dart';
import '../widgets/adaptive_app_bar_title.dart';
import '../widgets/topic_status.dart' show notificationLevelLabel;
import 'package:discourse_core/discourse_core.dart' show DiscourseTopicStatus;

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
    this.topicStatus,
    this.onShare,
    this.onViewOnWeb,
    this.onNotifications,
    this.onClose,
    this.onPin,
    this.onArchive,
    this.onToggleVisibility,
    this.onRename,
    this.onMove,
    this.onMerge,
    this.onDelete,
    this.onRecover,
    this.onPermanentlyDelete,
    this.onRefresh,
    super.key,
  }) : _title = title;

  final SiteContext siteContext;
  final String _title;

  /// Set when the page shows a private message.
  final PostsPageMessageMenu? message;

  /// The topic's state and the viewer's permissions on it, once loaded:
  /// which of web's topic actions to offer, and which way round.
  final DiscourseTopicStatus? topicStatus;
  final VoidCallback? onShare;
  final VoidCallback? onViewOnWeb;
  final VoidCallback? onNotifications;
  final VoidCallback? onClose;
  final VoidCallback? onPin;
  final VoidCallback? onArchive;
  final VoidCallback? onToggleVisibility;
  final VoidCallback? onRename;
  final VoidCallback? onMove;
  final VoidCallback? onMerge;
  final VoidCallback? onDelete;
  final VoidCallback? onRecover;
  final VoidCallback? onPermanentlyDelete;
  final VoidCallback? onRefresh;

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
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
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
              Flexible(
                child: Text(label,
                    style: danger ? TextStyle(color: colorScheme.error) : null),
              ),
            ],
          ),
        );

    // Web's topic admin menu, for whoever Discourse lets act on the topic
    // (TopicViewDetailsSerializer's can_* flags). A message keeps its own
    // actions instead.
    final s = message == null ? widget.topicStatus : null;
    final level = widget.topicStatus?.notificationLevel ?? 1;
    final staffItems = <PopupMenuEntry<String>>[
      if (s != null && s.canClose)
        s.closed
            ? item('close', Icons.lock_open_rounded, l10n.openTopic)
            : item('close', Icons.lock_outline_rounded, l10n.closeTopic),
      if (s != null && s.canPinUnpin && !s.deleted)
        s.isPinnedByStaff
            ? item('pin', Icons.push_pin_outlined, l10n.unpinTopic)
            : item('pin', Icons.push_pin_outlined, l10n.pinTopicMenu),
      if (s != null && s.canArchive)
        s.archived
            ? item('archive', Icons.unarchive_outlined, l10n.unarchiveTopic)
            : item('archive', Icons.archive_outlined, l10n.archiveTopic),
      if (s != null && s.canToggleVisibility)
        s.visible
            ? item('visibility', Icons.visibility_off_outlined, l10n.unlistTopic)
            : item('visibility', Icons.visibility_outlined, l10n.listTopic),
      if (s != null && s.canEdit)
        item('rename', Icons.edit_outlined, l10n.renameTopic),
      if (s != null && s.canEdit)
        item('move', Icons.drive_file_move_outline, l10n.moveToCategory),
      if (s != null && s.canMovePosts)
        item('merge', Icons.merge_type_rounded, l10n.mergeIntoTopic),
    ];
    final deleteItems = <PopupMenuEntry<String>>[
      if (s != null && s.deleted && s.canRecover)
        item('recover', Icons.restore_from_trash_rounded, l10n.undeleteTopic),
      if (s != null && s.deleted && s.canPermanentlyDelete)
        item('permanently_delete', Icons.delete_forever_outlined,
            l10n.permanentlyDelete,
            danger: true),
      if (s != null && !s.deleted && s.canDelete)
        item('delete', Icons.delete_outline_rounded, l10n.deleteTopic,
            danger: true),
    ];

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
          item('refresh', Icons.refresh_rounded, l10n.refresh),
          if (widget.siteContext.isLoggedIn && widget.onNotifications != null)
            // The bell of the reader's level, as web's tracking button.
            item('notifications', notificationLevelLabel(l10n, level).$2,
                l10n.notifications),
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
          if (widget.onShare != null)
            item('share', Icons.share_rounded, l10n.share),
          if (widget.onViewOnWeb != null)
            item('view_on_web', Icons.open_in_browser_rounded, l10n.viewOnWeb),
          if (staffItems.isNotEmpty) ...[
            const PopupMenuDivider(),
            ...staffItems,
          ],
          if (deleteItems.isNotEmpty) ...[
            const PopupMenuDivider(),
            ...deleteItems,
          ],
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
            case 'msg_unread':
              message?.onMarkUnread();
            case 'msg_edit':
              message?.onEditTitle?.call();
            case 'msg_close':
              message?.onClose?.call();
            case 'msg_leave':
              message?.onLeave?.call();
            case 'msg_delete':
              message?.onDelete?.call();
            case 'refresh':
              widget.onRefresh?.call();
            case 'notifications':
              widget.onNotifications?.call();
            case 'share':
              widget.onShare?.call();
            case 'view_on_web':
              widget.onViewOnWeb?.call();
            // Web acts on these at once: each is undone from the same menu,
            // and leaves a "Closed 1 minute ago" line in the topic.
            case 'close':
              widget.onClose?.call();
            case 'pin':
              widget.onPin?.call();
            case 'archive':
              widget.onArchive?.call();
            case 'visibility':
              widget.onToggleVisibility?.call();
            case 'rename':
              _showRenameDialog(context: context);
            // Move and merge show their own pickers (post_page.dart).
            case 'move':
              widget.onMove?.call();
            case 'merge':
              widget.onMerge?.call();
            case 'delete':
              widget.onDelete?.call();
            case 'recover':
              widget.onRecover?.call();
            case 'permanently_delete':
              widget.onPermanentlyDelete?.call();
          }
        },
      ),
    ];
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
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.topicTitlePlaceholder,
              border: const OutlineInputBorder(),
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
