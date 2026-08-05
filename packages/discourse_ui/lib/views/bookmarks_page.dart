import 'package:flutter/material.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_core/discourse_core.dart'
    show
        DiscourseBookmarkProxy,
        DiscourseBookmarkEntry,
        DiscourseBookmarkAutoDelete;
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_bookmark.dart';

import '../core/logging/app_logger.dart';
import '../theme/design_tokens.dart';
import '../utils/time_utils.dart';
import 'lists/posts_list.dart';
import 'post_page.dart';
import 'widgets/bookmark_reminder_sheet.dart';
import 'widgets/user_avatar.dart';

/// Discourse-native bookmarks list. Backed by `/u/{me}/bookmarks.json`,
/// reachable from the user profile page (own profile only). Tapping an
/// entry deep-links into the topic at the bookmarked post. Entries with
/// a pending reminder show a clock chip; the per-entry overflow menu
/// edits or clears the reminder.
class BookmarksPage extends StatefulWidget {
  final SiteContext siteContext;

  const BookmarksPage({super.key, required this.siteContext});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  final List<DiscourseBookmarkEntry> _entries = [];
  final ScrollController _scrollController = ScrollController();
  int _page = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading &&
        _hasMore) {
      _load(reset: false);
    }
  }

  DiscourseBookmarkProxy? get _discourseBookmarkProxy {
    final proxy = SiteProxyService.getBookmarkProxy();
    return proxy is DiscourseBookmarkProxy ? proxy : null;
  }

  Future<void> _load({required bool reset}) async {
    if (reset) {
      _entries.clear();
      _page = 0;
      _hasMore = true;
      _error = null;
    }
    setState(() => _isLoading = true);
    try {
      final proxy = _discourseBookmarkProxy;
      if (proxy == null) {
        setState(() {
          _error = 'Bookmarks are unavailable';
          _isLoading = false;
          _hasMore = false;
        });
        return;
      }
      // Reminder-aware listing (same endpoint/page as getBookmarksAsync,
      // plus each row's reminder_at/pinned and the server's own
      // more_bookmarks_url pagination signal).
      final result = await proxy.getBookmarksWithRemindersAsync(page: _page);
      if (!mounted) return;
      if (!result.result) {
        setState(() {
          _error = result.resultText?.isNotEmpty == true
              ? result.resultText
              : 'Failed to load bookmarks';
          _isLoading = false;
          _hasMore = false;
        });
        return;
      }
      final batch = result.entries;
      setState(() {
        _entries.addAll(batch);
        _hasMore = result.hasMore;
        if (batch.isNotEmpty) _page++;
        _isLoading = false;
      });
    } catch (e, st) {
      AppLogger.error('BookmarksPage load failed', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  Future<void> _refresh() => _load(reset: true);

  Future<void> _removeBookmark(DiscourseBookmarkEntry entry) async {
    // We have the bookmark id directly; bypass the lookup that
    // removePostBookmarkAsync does by deleting it via the bookmark id
    // endpoint.
    final result = await SiteProxyService.getBookmarkProxy()
        .removeBookmarkByIdAsync(entry.bookmark.id);
    if (!mounted) return;
    if (result.result) {
      setState(() => _entries.remove(entry));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.resultText?.isNotEmpty == true
              ? result.resultText!
              : 'Failed to remove bookmark'),
        ),
      );
    }
  }

  /// Opens the shared reminder preset sheet and applies the choice via
  /// the update endpoint.
  Future<void> _editReminder(DiscourseBookmarkEntry entry) async {
    final choice = await BookmarkReminderSheet.show(
      context,
      title: entry.reminderAt != null ? 'Edit reminder' : 'Add reminder',
      currentReminderAt: entry.reminderAt,
    );
    if (choice == null || !mounted) return;
    await _applyReminder(entry, choice.reminderAt);
  }

  Future<void> _clearReminder(DiscourseBookmarkEntry entry) =>
      _applyReminder(entry, null);

  Future<void> _applyReminder(
      DiscourseBookmarkEntry entry, DateTime? reminderAt) async {
    final proxy = _discourseBookmarkProxy;
    if (proxy == null) return;
    final result = await proxy.updateBookmarkAsync(
      entry.bookmark.id,
      // Overwrite semantics: omitting reminderAt clears the reminder
      // (that's the clear path), and the name/note must be resent
      // untouched or the server wipes it.
      reminderAt: reminderAt,
      name: entry.bookmark.name,
      autoDeletePreference: reminderAt != null
          ? DiscourseBookmarkAutoDelete.clearReminder
          : null,
    );
    if (!mounted) return;
    if (result.result) {
      setState(() {
        final index = _entries.indexOf(entry);
        if (index >= 0) {
          _entries[index] = DiscourseBookmarkEntry(
            bookmark: entry.bookmark,
            reminderAt: reminderAt,
            pinned: entry.pinned,
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.resultText?.isNotEmpty == true
              ? result.resultText!
              : 'Failed to update reminder'),
        ),
      );
    }
  }

  void _open(FCBookmark b) {
    final tid = b.topicId;
    if (tid == null) return;
    final isPost = b.bookmarkableType == 'Post' && b.bookmarkableId != null;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostPage(
          siteContext: widget.siteContext,
          topicId: tid.toString(),
          title: b.title ?? '',
          mode: isPost ? PostsListMode.thread_by_post : PostsListMode.normal,
          anchorPostId: isPost ? b.bookmarkableId!.toString() : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.bookmark, size: 20),
            SizedBox(width: 8),
            Text('Bookmarks'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_entries.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_entries.isEmpty && _error != null) {
      return ListView(
        padding: const EdgeInsets.all(DesignTokens.spacingL),
        children: [
          Center(
            child: Text(
              _error!,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }
    if (_entries.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(DesignTokens.spacingL),
        children: [
          Center(
            child: Text(
              'No bookmarks yet',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      controller: _scrollController,
      itemCount: _entries.length + (_hasMore || _isLoading ? 1 : 0),
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: colorScheme.outlineVariant.withValues(alpha: DesignTokens.opacityDivider),
      ),
      itemBuilder: (context, index) {
        if (index == _entries.length) {
          return const Padding(
            padding: EdgeInsets.all(DesignTokens.spacingL),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final entry = _entries[index];
        return _BookmarkTile(
          siteContext: widget.siteContext,
          entry: entry,
          onTap: () => _open(entry.bookmark),
          onEditReminder: () => _editReminder(entry),
          onClearReminder:
              entry.reminderAt != null ? () => _clearReminder(entry) : null,
          onRemove: () => _removeBookmark(entry),
        );
      },
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  final SiteContext siteContext;
  final DiscourseBookmarkEntry entry;
  final VoidCallback onTap;
  final VoidCallback onEditReminder;
  final VoidCallback? onClearReminder;
  final VoidCallback onRemove;

  const _BookmarkTile({
    required this.siteContext,
    required this.entry,
    required this.onTap,
    required this.onEditReminder,
    this.onClearReminder,
    required this.onRemove,
  });

  FCBookmark get bookmark => entry.bookmark;

  /// Compact relative rendering of a pending reminder ("45m", "2h",
  /// "3d", ...). Reminders in the past (fired but not yet cleared
  /// server-side) render as "due".
  static String _formatReminderCompact(DateTime reminderAt) {
    final diff = reminderAt.toLocal().difference(DateTime.now());
    if (diff.isNegative) return 'due';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 30) return '${diff.inDays}d';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo';
    return '${(diff.inDays / 365).floor()}y';
  }

  Widget _buildReminderChip(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingS,
        vertical: DesignTokens.spacingXS / 2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.alarm,
            size: DesignTokens.iconSizeXS,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: DesignTokens.spacingXS),
          Text(
            _formatReminderCompact(entry.reminderAt!),
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: DesignTokens.fontWeightMedium,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final username = bookmark.username ?? '';
    final avatarUrl = bookmark.avatarUrl;
    final title = (bookmark.title?.isNotEmpty ?? false)
        ? bookmark.title!
        : '(untitled)';
    final excerpt = bookmark.excerpt;
    final created = bookmark.createdAt;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingL,
          vertical: DesignTokens.spacingM,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(
              username: username,
              iconUrl: avatarUrl,
              radius: DesignTokens.avatarRadiusM,
            ),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (excerpt != null && excerpt.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      excerpt,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (entry.reminderAt != null) ...[
                        _buildReminderChip(colorScheme, textTheme),
                        const SizedBox(width: 8),
                      ],
                      if (username.isNotEmpty) ...[
                        Text(
                          '@$username',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (created != null)
                        Text(
                          formatTimeAgo(created, context),
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
              tooltip: 'Bookmark options',
              onSelected: (value) {
                switch (value) {
                  case 'edit_reminder':
                    onEditReminder();
                    break;
                  case 'clear_reminder':
                    onClearReminder?.call();
                    break;
                  case 'remove':
                    onRemove();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'edit_reminder',
                  child: Row(
                    children: [
                      Icon(Icons.alarm,
                          size: DesignTokens.iconSizeM,
                          color: colorScheme.primary),
                      const SizedBox(width: DesignTokens.spacingM),
                      Text(entry.reminderAt != null
                          ? 'Edit reminder'
                          : 'Add reminder'),
                    ],
                  ),
                ),
                if (onClearReminder != null)
                  PopupMenuItem<String>(
                    value: 'clear_reminder',
                    child: Row(
                      children: [
                        Icon(Icons.alarm_off,
                            size: DesignTokens.iconSizeM,
                            color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: DesignTokens.spacingM),
                        const Text('Clear reminder'),
                      ],
                    ),
                  ),
                PopupMenuItem<String>(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.bookmark_remove_outlined,
                          size: DesignTokens.iconSizeM,
                          color: colorScheme.error),
                      const SizedBox(width: DesignTokens.spacingM),
                      const Text('Remove bookmark'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
