import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/models/entities/fc_forum.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:discourse_ui/views/lists/forum_topic_list.dart';
import 'package:discourse_ui/views/listitems/category_card.dart'
    show SubcategoryChip;
import 'package:discourse_ui/views/search_page.dart';
import 'package:discourse_ui/views/widgets/category_badge.dart'
    show categoryForum;
import 'package:discourse_ui/views/widgets/category_masthead.dart';
import 'package:forumcopilot_sdk/models/entities/fc_notification_level.dart';
import 'package:discourse_ui/views/widgets/filter_chip_bar.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities, DiscourseTopicCounts, DiscourseTopicTracking;
import 'package:discourse_ui/views/new_topic_page.dart';
import 'package:discourse_ui/services/topic_tracking_service.dart';
import 'package:discourse_ui/views/widgets/dismiss_topics.dart';
import 'package:discourse_ui/views/widgets/topic_tracking_live.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscourseSubscriptionProxy;
import 'package:discourse_ui/views/widgets/notification_level_sheet.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:discourse_ui/utils/app_navigation.dart';

class ForumTopicsPage extends StatefulWidget {
  final FCForum forum;
  final SiteContext siteContext;

  const ForumTopicsPage({
    super.key,
    required this.forum,
    required this.siteContext,
  });

  /// The New Topic button's hero tag, shared with Home's: the same action
  /// on both pages, so the button stays put as a category opens or closes.
  /// Every other FAB has a tag of its own or none — two heroes with one tag
  /// in a route (Home keeps all its tabs mounted) is an error.
  static const newTopicHeroTag = 'new-topic-fab';

  @override
  State<ForumTopicsPage> createState() => _ForumTopicsPageState();
}

class _ForumTopicsPageState extends State<ForumTopicsPage> {
  VoidCallback? _refreshCallback;

  /// The reader's notification level here, shown on the header's bell;
  /// null until read, and for a guest.
  FCNotificationLevel? _level;

  @override
  void initState() {
    super.initState();
    // The counts on the New and Unread chips.
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => TopicTrackingService.refresh(widget.siteContext));
    _loadLevel();
  }

  Future<void> _loadLevel() async {
    if (!widget.siteContext.isLoggedIn) return;
    try {
      final result = await SiteProxyFactory.getSubscriptionProxy()
          .getCategoryNotificationLevelAsync(widget.forum.id);
      if (mounted && result.result) setState(() => _level = result.level);
    } catch (_) {
      // The bell then reads Normal until changed.
    }
  }

  /// The category's subcategories, from the forum's `/site.json` (so a
  /// category opened from a badge or link has them too), else the list's.
  List<FCForum> get _subcategories {
    final id = int.tryParse(widget.forum.id);
    final caps =
        DiscourseSiteCapabilities.forSite(widget.siteContext.site.pluginUrl);
    final fromSite = id == null
        ? const <FCForum>[]
        : [
            for (final c in caps.categories)
              if (c['parent_category_id'] == id && c['id'] is int)
                categoryForum(widget.siteContext, '${c['id']}'),
          ];
    return fromSite.isNotEmpty ? fromSite : widget.forum.childForums;
  }

  /// Search opens with Discourse's filter for this category (`#slug`, or
  /// `#parent:child` for a subcategory) for the reader to finish.
  void _openSearch() {
    final caps =
        DiscourseSiteCapabilities.forSite(widget.siteContext.site.pluginUrl);
    final style = caps.categoryStyleFor(widget.forum.id);
    final slug = style?.slug ?? widget.forum.slug;
    final parentSlug = style?.parentId == null
        ? null
        : caps.categoryStyleFor('${style!.parentId}')?.slug;
    final filter = slug == null
        ? null
        : '#${parentSlug == null ? '' : '$parentSlug:'}$slug ';
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            SearchPage(siteContext: widget.siteContext, prefill: filter)));
  }

  /// This category and every one below it: what web counts as in it.
  Set<int>? get _categoryIds {
    final id = int.tryParse(widget.forum.id);
    if (id == null) return null;
    return DiscourseSiteCapabilities.forSite(widget.siteContext.site.pluginUrl)
        .categoryWithDescendants(id);
  }

  Future<void> _handleNewTopic() async {
    if (!widget.siteContext.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.pleaseLoginToCreateANewTopic,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
          ),
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    var topicCreated = false;
    // The composer becomes the new topic once it is posted (see
    // NewTopicPage), so this completes as the topic opens.
    final result = await AppNavigation.pushForm<Object?>(
      context,
      NewTopicPage(
        siteContext: widget.siteContext,
        forumId: widget.forum.id,
        forumName: widget.forum.name,
        onTopicCreated: (_, __) => topicCreated = true,
      ),
    );

    if ((result == true || topicCreated) && _refreshCallback != null) {
      _refreshCallback!();
    }
  }

  Future<void> _handleSubscribe() async {
    if (!widget.siteContext.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.pleaseLoginToSubscribeToForums,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
          ),
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final subscriptionProxy = SiteProxyFactory.getSubscriptionProxy();
    if (subscriptionProxy is DiscourseSubscriptionProxy) {
      // Discourse-native picker: Watching / Watching First Post / Tracking
      // / Normal / Muted. The 'isSubscribed' field on the forum is binary
      // (>= Tracking) — we leave it for the next refresh to update.
      await NotificationLevelSheet.showForCategory(
        context: context,
        categoryId: widget.forum.id,
        // The level the bell shows, when it has been read; otherwise the
        // sheet reads it (a guess from the subscribed flag showed Watching
        // as Tracking and Muted as Normal).
        currentLevel: _level,
        onChanged: () {
          if (!mounted) return;
          _loadLevel();
          if (_refreshCallback != null) _refreshCallback!();
        },
      );
      return;
    }

    try {
      final isSubscribed = widget.forum.isSubscribed;

      if (isSubscribed) {
        await subscriptionProxy.unsubscribeForumAsync(widget.forum.id);
      } else {
        await subscriptionProxy.subscribeForumAsync(widget.forum.id, 1);
      }

      if (mounted) {
        setState(() {
          widget.forum.isSubscribed = !isSubscribed;
        });
      }
    } catch (e) {
      // Error handled silently
    }
  }

  /// The ⋮ menu's "Dismiss new and unread": both of web's dismissals,
  /// for this category and its subcategories.
  Future<void> _handleMarkRead() => dismissNewAndUnread(
        context,
        widget.siteContext,
        categoryId: widget.forum.id,
        categoryName: widget.forum.name,
        onDismissed: () => _refreshCallback?.call(),
      );

  void _onRefreshAvailable(VoidCallback callback) {
    // Defer setState to avoid calling it during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _refreshCallback = callback;
        });
      }
    });
  }


  /// Web puts Latest / New / Hot on every category page; the app showed a
  /// single list. Named rather than positional, like the Home sub-tabs —
  /// New needs a session and Hot needs the forum to offer the route, so
  /// which tabs exist varies and indices would drift.
  List<_CategoryFilter> get _filters => [
        _CategoryFilter.latest,
        if (DiscourseSiteCapabilities.offersRoute(
            widget.siteContext.site.pluginUrl, 'hot'))
          _CategoryFilter.hot,
        // `/c/{id}/l/new.json` and `unread.json` answer 403 to a guest,
        // so they are only offered to someone who can actually use them.
        if (widget.siteContext.isLoggedIn) _CategoryFilter.newTopics,
        if (widget.siteContext.isLoggedIn) _CategoryFilter.unread,
      ];

  _CategoryFilter _activeFilter = _CategoryFilter.latest;

  String _chipLabel(
      AppLocalizations l10n, _CategoryFilter f, DiscourseTopicCounts? counts) {
    final n = switch (f) {
      _CategoryFilter.newTopics => counts?.newTopics ?? 0,
      _CategoryFilter.unread => counts?.unreadTopics ?? 0,
      _ => 0,
    };
    return switch (f) {
      _CategoryFilter.latest => l10n.latest,
      _CategoryFilter.hot => l10n.hot,
      _CategoryFilter.newTopics when n > 0 => l10n.filterNewWithCount(n),
      _CategoryFilter.newTopics => l10n.filterNew,
      _CategoryFilter.unread when n > 0 => l10n.filterUnreadWithCount(n),
      _CategoryFilter.unread => l10n.unread,
    };
  }

  /// Rebuilds [builder] as the reader's new/unread counts change (for this
  /// category and its subcategories); a guest has none.
  Widget _withCounts(Widget Function(DiscourseTopicCounts?) builder) {
    if (!widget.siteContext.isLoggedIn) return builder(null);
    final tracking = DiscourseTopicTracking.forSite(widget.siteContext);
    return ListenableBuilder(
      listenable: tracking,
      builder: (context, _) =>
          builder(tracking.counts(categoryIds: _categoryIds)),
    );
  }

  /// The feed chips, pinned under the header's bar. A lone feed is a
  /// label, not a choice, so there are no chips then.
  Widget? _buildFilterTabs(BuildContext context) {
    final filters = _filters;
    if (filters.length < 2) return null;
    final l10n = AppLocalizations.of(context)!;
    return _withCounts((counts) => ColoredBox(
          color: Theme.of(context).colorScheme.surface,
          child: FilterChipBar(
            options: [
              for (final f in filters)
                FilterChipOption(label: _chipLabel(l10n, f, counts)),
            ],
            selectedIndex: filters.indexOf(_activeFilter),
            onSelected: (i) => setState(() => _activeFilter = filters[i]),
          ),
        ));
  }

  /// Dismiss above the New and Unread feeds, as on Home; hidden once the
  /// counts say there is nothing to dismiss.
  Widget _buildDismissBar() {
    final kind = switch (_activeFilter) {
      _CategoryFilter.newTopics => DismissKind.newTopics,
      _CategoryFilter.unread => DismissKind.unread,
      _ => null,
    };
    if (kind == null) return const SizedBox.shrink();
    return _withCounts((counts) {
      final remaining = kind == DismissKind.newTopics
          ? counts?.newTopics
          : counts?.unreadTopics;
      if (remaining == 0) return const SizedBox.shrink();
      return DismissTopicsBar(
        siteContext: widget.siteContext,
        kind: kind,
        categoryId: int.tryParse(widget.forum.id),
        onDismissed: () => _refreshCallback?.call(),
      );
    });
  }

  Widget? _buildMenu(BuildContext context) {
    if (!widget.siteContext.isLoggedIn) return null;
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      tooltip: l10n.moreOptions,
      onSelected: (value) {
        if (value == 'dismiss') _handleMarkRead();
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'dismiss',
          child: Row(children: [
            Icon(Icons.done_all_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Text(l10n.dismissNewAndUnread),
          ]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final subcategories = _subcategories;
    final chips = _buildFilterTabs(context);
    final signedIn = widget.siteContext.isLoggedIn;
    return Scaffold(
      body: TopicTrackingLive(
        siteContext: widget.siteContext,
        active: true,
        child: ForumTopicList(
          siteContext: widget.siteContext,
          forum: widget.forum,
          onRefreshAvailable: _onRefreshAvailable,
          filter: _activeFilter.route,
          refreshEdgeOffset: MediaQuery.paddingOf(context).top +
              CategoryMasthead.toolbarHeight,
          headerSlivers: [
            CategoryMasthead(
              siteContext: widget.siteContext,
              forum: widget.forum,
              level: _level,
              onBell: signedIn && widget.forum.canSubscribe
                  ? _handleSubscribe
                  : null,
              onSearch: _openSearch,
              menu: _buildMenu(context),
            ),
            // Subcategories as chips under the header, not rows before the
            // topics.
            if (subcategories.isNotEmpty)
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(children: [
                    for (final sub in subcategories)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SubcategoryChip(
                          siteContext: widget.siteContext,
                          forum: sub,
                          outlined: true,
                        ),
                      ),
                  ]),
                ),
              ),
            if (chips != null) PinnedHeaderSliver(child: chips),
            SliverToBoxAdapter(child: _buildDismissBar()),
          ],
        ),
      ),
      // Where a thumb is, in the forum's accent (the app's FAB theme), and
      // always reachable.
      floatingActionButton:
          signedIn && widget.forum.canPost
              ? FloatingActionButton.extended(
                  heroTag: ForumTopicsPage.newTopicHeroTag,
                  onPressed: _handleNewTopic,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(AppLocalizations.of(context)!.newTopic),
                )
              : null,
    );
  }
}


/// A category's topic feeds, mirroring web's tabs.
enum _CategoryFilter {
  latest('latest'),
  hot('hot'),
  newTopics('new'),
  unread('unread');

  const _CategoryFilter(this.route);

  /// The `/c/{id}/l/{route}.json` segment.
  final String route;
}
