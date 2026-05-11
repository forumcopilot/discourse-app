import 'package:flutter/material.dart';
import 'package:forumcopilot_flutter/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_bookmark.dart';

import '../core/logging/app_logger.dart';
import '../theme/design_tokens.dart';
import '../utils/time_utils.dart';
import 'lists/posts_list.dart';
import 'post_page.dart';
import 'widgets/user_avatar.dart';

/// Discourse-native bookmarks list. Backed by `/u/{me}/bookmarks.json`,
/// reachable from the user profile page (own profile only). Tapping an
/// entry deep-links into the topic at the bookmarked post.
class BookmarksPage extends StatefulWidget {
  final SiteContext siteContext;

  const BookmarksPage({super.key, required this.siteContext});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  final List<FCBookmark> _bookmarks = [];
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

  Future<void> _load({required bool reset}) async {
    if (reset) {
      _bookmarks.clear();
      _page = 0;
      _hasMore = true;
      _error = null;
    }
    setState(() => _isLoading = true);
    try {
      final result =
          await SiteProxyService.getBookmarkProxy().getBookmarksAsync(
        page: _page,
      );
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
      final batch = result.items;
      setState(() {
        _bookmarks.addAll(batch);
        // Discourse returns up to 30 per page; treat anything short as
        // end-of-list. An empty page also ends pagination.
        if (batch.length < 30) _hasMore = false;
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

  Future<void> _removeBookmark(FCBookmark b) async {
    // We have the bookmark id directly; bypass the lookup that
    // removePostBookmarkAsync does by deleting it via the bookmark id
    // endpoint.
    final result =
        await SiteProxyService.getBookmarkProxy().removeBookmarkByIdAsync(b.id);
    if (!mounted) return;
    if (result.result) {
      setState(() => _bookmarks.remove(b));
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

    if (_bookmarks.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_bookmarks.isEmpty && _error != null) {
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
    if (_bookmarks.isEmpty) {
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
      itemCount: _bookmarks.length + (_hasMore || _isLoading ? 1 : 0),
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: colorScheme.outlineVariant.withOpacity(0.4),
      ),
      itemBuilder: (context, index) {
        if (index == _bookmarks.length) {
          return const Padding(
            padding: EdgeInsets.all(DesignTokens.spacingL),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final b = _bookmarks[index];
        return _BookmarkTile(
          siteContext: widget.siteContext,
          bookmark: b,
          onTap: () => _open(b),
          onRemove: () => _removeBookmark(b),
        );
      },
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  final SiteContext siteContext;
  final FCBookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _BookmarkTile({
    required this.siteContext,
    required this.bookmark,
    required this.onTap,
    required this.onRemove,
  });

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
            IconButton(
              icon: const Icon(Icons.bookmark_remove_outlined),
              tooltip: 'Remove bookmark',
              color: colorScheme.onSurfaceVariant,
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
