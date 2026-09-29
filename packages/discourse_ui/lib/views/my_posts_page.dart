import 'package:discourse_core/discourse_core.dart'
    show DiscoursePendingPost, DiscourseTopicProxy, DiscourseUserProxy;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';
import 'package:forumcopilot_sdk/models/results/fc_user_result.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/site_proxy_service.dart';
import '../theme/design_tokens.dart';
import '../utils/markdown_preview.dart';
import 'drafts_list_page.dart';
import 'lists/posts_list.dart';
import 'post_page.dart';
import 'widgets/activity_row.dart';
import 'widgets/empty_state_view.dart';
import 'widgets/filter_chip_bar.dart';

/// The signed-in reader's own posts — web's sidebar "My posts", which opens
/// their activity stream. It used to open their whole profile (edit and
/// settings buttons, the avatar camera, the stats) with the feed at the
/// bottom.
///
/// * Filters as web's activity tabs: All (topics and replies), Topics,
///   Replies, Likes, Solved, and Pending while something of theirs is
///   waiting for a moderator.
/// * Rows are [ActivityRow]s: what and when, the topic, its category, the
///   reader's own words quoted. Topics come from web's own list for them
///   (`/topics/created-by`), so they carry replies, views and likes.
/// * Time-ordered feeds are grouped Today / This week / Earlier, the
///   groups set apart by the band the topic page uses between sections.
/// * Saved drafts are announced at the top, as web's sidebar link turns
///   into "My drafts" while there are any.
class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key, required this.siteContext});

  final SiteContext siteContext;

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

enum _Filter { all, topics, replies, likes, solved, pending }

enum _Bucket { today, week, earlier }

class _MyPostsPageState extends State<MyPostsPage> {
  final _scroll = ScrollController();

  _Filter _filter = _Filter.all;
  List<Object> _items = const [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  String? _error;
  int _offset = 0;
  int _page = 0;

  /// Bumped on every fresh load, so a slow page for a filter the reader
  /// has left does not land in the one they switched to.
  int _generation = 0;

  int _draftCount = 0;
  List<DiscoursePendingPost> _pending = const [];

  String? get _username => widget.siteContext.currentUsername;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load();
    _loadDrafts();
    _loadPending();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients || !_hasMore || _loadingMore || _loading) return;
    final p = _scroll.position;
    if (p.pixels >= p.maxScrollExtent - 400) _load(more: true);
  }

  Future<void> _refresh() async {
    await Future.wait([_load(), _loadDrafts(), _loadPending()]);
  }

  Future<void> _loadDrafts() async {
    try {
      final result = await SiteProxyService.getDraftProxy().getMyDraftsAsync();
      if (!mounted) return;
      setState(() => _draftCount = result.result ? result.items.length : 0);
    } catch (_) {
      // The banner is a courtesy; no drafts shown is not an error.
    }
  }

  Future<void> _loadPending() async {
    final username = _username;
    final proxy = _userProxy;
    if (username == null || proxy == null) return;
    final pending = await proxy.getPendingPostsAsync(username);
    if (!mounted || pending == null) return;
    setState(() {
      _pending = pending;
      if (_filter == _Filter.pending) _items = pending;
    });
  }

  DiscourseUserProxy? get _userProxy {
    try {
      final p = SiteProxyFactory.getUserProxy();
      return p is DiscourseUserProxy ? p : null;
    } catch (_) {
      return null;
    }
  }

  DiscourseTopicProxy? get _topicProxy {
    try {
      final p = SiteProxyFactory.getTopicProxy();
      return p is DiscourseTopicProxy ? p : null;
    } catch (_) {
      return null;
    }
  }

  static int? _actionFilter(_Filter f) => switch (f) {
        _Filter.replies => ActivityFilters.replies,
        _Filter.likes => ActivityFilters.likes,
        _Filter.solved => ActivityFilters.solved,
        _ => null,
      };

  Future<void> _load({bool more = false}) async {
    final username = _username;
    if (username == null) {
      setState(() => _loading = false);
      return;
    }
    final generation = more ? _generation : ++_generation;
    setState(() {
      if (more) {
        _loadingMore = true;
      } else {
        _loading = true;
        _error = null;
        _offset = 0;
        _page = 0;
      }
    });

    List<Object> batch = const [];
    var hasMore = false;
    String? error;
    switch (_filter) {
      case _Filter.pending:
        batch = _pending;
      case _Filter.topics:
        final proxy = _topicProxy;
        if (proxy == null) break;
        final r = await proxy.getTopicsCreatedByAsync(username, page: _page);
        batch = r.topics;
        hasMore = r.hasMore;
        error = r.error;
      default:
        final proxy = _userProxy;
        if (proxy == null) break;
        final FCUserReplyResult r = await proxy.getUserActionsAsync(
          _offset,
          username,
          actionFilter: _actionFilter(_filter) ?? ActivityFilters.replies,
          actionFilters: _filter == _Filter.all
              ? const [ActivityFilters.topics, ActivityFilters.replies]
              : null,
        );
        if (!r.result) error = r.resultText;
        batch = r.posts;
        hasMore = _offset + r.posts.length < r.total;
    }

    if (!mounted || generation != _generation) return;
    setState(() {
      _items = more ? [..._items, ...batch] : batch;
      _hasMore = hasMore && batch.isNotEmpty;
      _offset += batch.length;
      _page++;
      _loading = false;
      _loadingMore = false;
      if (!more) _error = (error?.isNotEmpty ?? false) ? error : null;
    });
  }

  void _select(_Filter f) {
    if (f == _filter) return;
    setState(() => _filter = f);
    if (_scroll.hasClients) _scroll.jumpTo(0);
    _load();
  }

  Future<void> _openDrafts() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DraftsListPage(siteContext: widget.siteContext),
    ));
    if (mounted) _loadDrafts();
  }

  void _openPost(FCUserReply post) {
    if (post.topicId.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PostPage(
        siteContext: widget.siteContext,
        topicId: post.topicId,
        title: post.topicTitle,
        mode: post.postId.isNotEmpty
            ? PostsListMode.thread_by_post
            : PostsListMode.first_unread,
        anchorPostId: post.postId.isNotEmpty ? post.postId : null,
        forumId: post.forumId.isNotEmpty ? post.forumId : null,
      ),
    ));
  }

  void _openTopic(String topicId, String title, {String? forumId}) {
    if (topicId.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PostPage(
        siteContext: widget.siteContext,
        topicId: topicId,
        title: title,
        forumId: forumId,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final filters = [
      _Filter.all,
      _Filter.topics,
      _Filter.replies,
      _Filter.likes,
      _Filter.solved,
      if (_pending.isNotEmpty || _filter == _Filter.pending) _Filter.pending,
    ];
    String label(_Filter f) => switch (f) {
          _Filter.all => l10n.all,
          _Filter.topics => l10n.activityFilterTopics,
          _Filter.replies => l10n.activityFilterReplies,
          _Filter.likes => l10n.activityFilterLikes,
          _Filter.solved => l10n.solved,
          _Filter.pending =>
            '${l10n.activityFilterPending} (${_pending.length})',
        };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myPosts)),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (_draftCount > 0)
              SliverToBoxAdapter(
                child: _DraftsBanner(count: _draftCount, onTap: _openDrafts),
              ),
            // Pinned, so switching filters never means scrolling back up.
            PinnedHeaderSliver(
              child: Material(
                color: colorScheme.surface,
                child: FilterChipBar(
                  options: [
                    for (final f in filters) FilterChipOption(label: label(f)),
                  ],
                  selectedIndex: filters.indexOf(_filter),
                  onSelected: (i) => _select(filters[i]),
                ),
              ),
            ),
            ..._content(context, l10n),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, AppLocalizations l10n) {
    if (_username == null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyStateView(
            icon: Icons.forum_outlined,
            message: l10n.myPostsEmpty,
          ),
        ),
      ];
    }
    if (_loading && _items.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_error != null && _items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyStateView.error(message: _error!, onRetry: _load),
        ),
      ];
    }
    if (_items.isEmpty) {
      final (icon, message, hint) = switch (_filter) {
        _Filter.topics => (Icons.topic_outlined, l10n.activityEmptyTopics, null),
        _Filter.replies => (Icons.reply_rounded, l10n.activityEmptyReplies, null),
        _Filter.likes => (Icons.favorite_border, l10n.activityEmptyLikes, null),
        _Filter.solved =>
          (Icons.check_circle_outline, l10n.activityEmptySolved, null),
        _ => (Icons.forum_outlined, l10n.myPostsEmpty, l10n.myPostsEmptyHint),
      };
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyStateView(icon: icon, message: message, hint: hint),
        ),
      ];
    }

    // Topics are listed by latest activity, not by when they were started,
    // so their dates do not fall into time groups.
    final grouped = _filter != _Filter.topics;
    final entries = <Object>[];
    _Bucket? bucket;
    for (final item in _items) {
      if (grouped) {
        final b = _bucketOf(_timeOf(item));
        if (b != bucket) {
          entries.add(_Header(b, first: bucket == null));
          bucket = b;
        }
      }
      entries.add(item);
    }

    return [
      SliverList.builder(
        itemCount: entries.length,
        itemBuilder: (context, i) {
          final entry = entries[i];
          if (entry is _Header) return _sectionHeader(context, l10n, entry);
          final row = _row(context, l10n, entry);
          final next = i + 1 < entries.length ? entries[i + 1] : null;
          // A rule between rows, but not above a section's band.
          if (next == null || next is _Header) return row;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              row,
              Divider(
                height: 1,
                thickness: 1,
                indent: DesignTokens.spacingL,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ],
          );
        },
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingL),
          child: _loadingMore
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox.shrink(),
        ),
      ),
    ];
  }

  static DateTime? _timeOf(Object item) => switch (item) {
        FCUserReply p => p.postTime,
        FCTopic t => t.timestamp,
        DiscoursePendingPost p => p.createdAt,
        _ => null,
      };

  static _Bucket _bucketOf(DateTime? time) {
    if (time == null) return _Bucket.earlier;
    final local = time.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (!local.isBefore(today)) return _Bucket.today;
    if (!local.isBefore(today.subtract(const Duration(days: 6)))) {
      return _Bucket.week;
    }
    return _Bucket.earlier;
  }

  Widget _sectionHeader(
      BuildContext context, AppLocalizations l10n, _Header header) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = switch (header.bucket) {
      _Bucket.today => l10n.sectionToday,
      _Bucket.week => l10n.sectionThisWeek,
      _Bucket.earlier => l10n.sectionEarlier,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!header.first)
          ColoredBox(
            color: colorScheme.surfaceContainer,
            child: const SizedBox(height: DesignTokens.spacingS),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
              DesignTokens.spacingM, DesignTokens.spacingL, 0),
          child: Semantics(
            header: true,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, AppLocalizations l10n, Object item) {
    final site = widget.siteContext;
    switch (item) {
      case FCTopic t:
        return ActivityRow(
          kind: l10n.activityStartedTopic,
          title: t.title,
          time: t.timestamp,
          siteContext: site,
          categoryId: t.forumId,
          tags: t.tags,
          replyCount: t.replyCount,
          viewCount: t.viewCount,
          likeCount: t.likeCount,
          solved: t.isSolved,
          onTap: () => _openTopic(t.id, t.title, forumId: t.forumId),
        );
      case DiscoursePendingPost p:
        return ActivityRow(
          kind: l10n.activityAwaitingApproval,
          title: p.topicTitle ?? '',
          excerpt: markdownPreviewText(p.rawText),
          time: p.createdAt,
          siteContext: site,
          categoryId: p.categoryId?.toString(),
          onTap: () => _openTopic(p.topicId?.toString() ?? '', p.topicTitle ?? ''),
        );
      case FCUserReply p:
        final filter = _actionFilter(_filter) ?? ActivityFilters.replies;
        return ActivityRow(
          kind: activityKindLabel(l10n, filter: filter, postNumber: p.replyNumber),
          title: p.topicTitle,
          excerpt: p.shortContent,
          time: p.postTime,
          postNumber: p.replyNumber,
          attribution: _attribution(l10n, p),
          siteContext: site,
          categoryId: p.forumId,
          onTap: () => _openPost(p),
        );
    }
    return const SizedBox.shrink();
  }

  /// Whose words the quote holds, on Likes (somebody else's post), or who
  /// accepted the answer, on Solved; nothing on the reader's own posts.
  ActivityAttribution? _attribution(AppLocalizations l10n, FCUserReply p) {
    final me = (_username ?? '').toLowerCase();
    if (_filter == _Filter.likes &&
        p.authorName.isNotEmpty &&
        p.authorName.toLowerCase() != me) {
      return ActivityAttribution(
          username: p.authorName, avatarUrl: p.authorIconUrl);
    }
    final actor = p.actorName;
    if (_filter == _Filter.solved && actor != null && actor.isNotEmpty) {
      return ActivityAttribution(
        username: actor,
        avatarUrl: p.actorIconUrl,
        label: l10n.activityAcceptedBy,
      );
    }
    return null;
  }
}

class _Header {
  const _Header(this.bucket, {required this.first});
  final _Bucket bucket;
  final bool first;
}

/// "2 drafts waiting · Resume", above the filters.
class _DraftsBanner extends StatelessWidget {
  const _DraftsBanner({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
          DesignTokens.spacingS, DesignTokens.spacingL, 0),
      child: Material(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        child: InkWell(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingM,
                vertical: DesignTokens.spacingXS),
            child: Row(
              children: [
                Icon(Icons.edit_note,
                    color: colorScheme.onSecondaryContainer),
                const SizedBox(width: DesignTokens.spacingS),
                Expanded(
                  child: Text(
                    l10n.draftsWaiting(count),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onSecondaryContainer,
                  ),
                  child: Text(l10n.resumeDrafts),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
