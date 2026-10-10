import 'dart:async';

import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:discourse_ui/views/widgets/resettable_widget.dart';
import 'package:discourse_ui/views/lists/latest_topics_list.dart';
import 'package:discourse_ui/views/widgets/filter_chip_bar.dart';
import 'package:discourse_ui/views/lists/hot_topics_list.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities, DiscourseTopicCounts, DiscourseTopicTracking;
import 'package:discourse_ui/services/topic_tracking_service.dart';
import 'package:discourse_ui/views/widgets/dismiss_topics.dart';
import 'package:discourse_ui/views/widgets/topic_tracking_live.dart';
import 'package:discourse_ui/views/lists/new_topics_list.dart';
import 'package:discourse_ui/views/lists/top_topics_list.dart';
import 'package:discourse_ui/views/lists/unread_topics_list.dart';
import 'package:discourse_ui/views/lists/categories_list.dart';
import 'package:discourse_ui/views/search_page.dart';
import 'package:discourse_ui/views/widgets/forum_masthead.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart' as forumcopilot_sdk;
import 'package:discourse_ui/core/logging/app_logger.dart';
import '../../l10n/kit_strings.dart';

/// The rows of the active filter as slivers.
///
/// Each topic is its own sliver child, so only the rows in (and just
/// beyond) the viewport are built and laid out. The previous shape — one
/// `Column` of every loaded row as a single `ListView` child — built and
/// laid out the whole feed on every rebuild, which is what made the Home
/// tab scroll at half frame rate once a few pages were loaded.
List<Widget> _topicSlivers(BuildContext context, List<Widget> items, Widget? emptyState) {
  if (items.length == 1 && items.first is Center &&
      (items.first as Center).child is CircularProgressIndicator) {
    return [SliverToBoxAdapter(child: items.first)];
  }
  if (items.isNotEmpty) {
    return [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => items[i],
          childCount: items.length,
        ),
      ),
    ];
  }
  if (emptyState != null) {
    return [SliverFillRemaining(hasScrollBody: false, child: emptyState)];
  }
  return const [
    SliverFillRemaining(
      hasScrollBody: false,
      child: Center(child: CircularProgressIndicator()),
    ),
  ];
}

class TopicListTab extends StatefulWidget {
  final SiteContext siteContext;
  final bool isActive;
  final forumcopilot_sdk.FCBoardStatResult? boardStats;

  /// Draws the forum's header above the views. Off where the page has an
  /// app bar of its own (a list opened from a link).
  final bool showMasthead;

  /// The view to open on, instead of the forum's homepage.
  final HomeView? initialView;

  const TopicListTab({
    Key? key,
    required this.siteContext,
    required this.isActive,
    this.boardStats,
    this.showMasthead = true,
    this.initialView,
  }) : super(key: key);

  @override
  TopicListTabState createState() => TopicListTabState();
}

class TopicListTabState extends FCStatefulWidget<TopicListTab> with FCTabStatefulWidget<TopicListTab> {
  /// The view the reader picked; until then, the forum's homepage.
  HomeView? _chosenView;
  bool _isLoadingMore = false;

  // Add keys for each list. Phase 5.17c reshuffled the indices to
  // match Discourse's native order: Latest, New, Unread, Top.
  // Subscribed + Participated moved off this tab (Phase 5.17d will
  // surface them under Profile).
  final GlobalKey<LatestTopicsListState> _latestTopicsKey = GlobalKey();
  final GlobalKey<NewTopicsListState> _newTopicsKey = GlobalKey();
  final GlobalKey<UnreadTopicsListState> _unreadTopicsKey = GlobalKey();
  final GlobalKey<TopTopicsListState> _topTopicsKey = GlobalKey();
  final GlobalKey<HotTopicsListState> _hotTopicsKey = GlobalKey();
  final GlobalKey<CategoriesListState> _categoriesKey = GlobalKey();

  /// Whether this forum offers `/hot.json`. Appended LAST rather than
  /// placed in web's Latest/Hot/New/Top order on purpose: every index in
  /// this widget is positional — six switch statements and the
  /// IndexedStack children — so inserting mid-list would renumber the
  /// existing tabs. Appending keeps their indices fixed, and the Hot
  /// index only exists when the tab does.
  bool get _offersHot => DiscourseSiteCapabilities.offersRoute(
      widget.siteContext.site.pluginUrl, 'hot');

  /// The views, as the forum's own navigation bar lists them
  /// ([HomeView.viewsFor]).
  List<HomeView> get _filters => HomeView.viewsFor(
        menu: DiscourseSiteCapabilities.forSite(
                widget.siteContext.site.pluginUrl)
            .topMenu,
        signedIn: widget.siteContext.isLoggedIn,
        offersHot: _offersHot,
      );

  HomeView get _activeFilter {
    final filters = _filters;
    final chosen = _chosenView;
    return chosen != null && filters.contains(chosen) ? chosen : filters.first;
  }

  /// Switches to [view] (a link to the forum's categories, say).
  void showView(HomeView view) {
    if (!mounted) return;
    setState(() => _chosenView = view);
  }

  // Scroll controller for the main ListView
  final ScrollController _scrollController = ScrollController();

  // Track previous login state to detect changes
  bool _wasLoggedIn = false;
  String? _lastLoadedUsername;
  late final VoidCallback _authStateListener;

  List<String> _getFilterLabels(
      BuildContext context, DiscourseTopicCounts? counts) {
    final l10n = AppLocalizations.of(context)!;
    return _filters.map((f) {
      switch (f) {
        case HomeView.latest:
          return l10n.kit.latest;
        case HomeView.hot:
          return l10n.hot;
        case HomeView.newTopics:
          // Discourse's /new.json, with web's count: "New (5)".
          final n = counts?.newTopics ?? 0;
          return n > 0 ? l10n.filterNewWithCount(n) : l10n.filterNew;
        case HomeView.unread:
          final n = counts?.unreadTopics ?? 0;
          return n > 0 ? l10n.filterUnreadWithCount(n) : l10n.unread;
        case HomeView.top:
          return l10n.filterTop;
        case HomeView.categories:
          return l10n.categoriesView;
      }
    }).toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _chosenView = widget.initialView;
    _scrollController.addListener(_onScroll);

    // Initialize tracking variables
    _wasLoggedIn = widget.siteContext.isLoggedIn;
    _lastLoadedUsername = widget.siteContext.loginDataOutput?.user?.username;

    // Listen to credential changes and reset all lists
    _authStateListener = () {
      final isLoggedInStatus = widget.siteContext.isLoggedIn;
      final currentUsername = widget.siteContext.loginDataOutput?.user?.username;

      final authStateChanged = _wasLoggedIn != isLoggedInStatus;
      final userChanged = isLoggedInStatus && _lastLoadedUsername != currentUsername;

      if (authStateChanged || userChanged) {
        AppLogger.debug('📋 [TOPIC_LIST_TAB] Credential change detected - resetting all topic lists');
        _wasLoggedIn = isLoggedInStatus;
        _lastLoadedUsername = currentUsername;

        // Reset all child lists when credentials change
        _latestTopicsKey.currentState?.resetList();
        _newTopicsKey.currentState?.resetList();
        _unreadTopicsKey.currentState?.resetList();
        _topTopicsKey.currentState?.resetList();
        _hotTopicsKey.currentState?.resetList();
        _categoriesKey.currentState?.refreshList();
        TopicTrackingService.refresh(widget.siteContext,
            maxAge: Duration.zero);
      }
    };

    widget.siteContext.isLoggedInNotifier.addListener(_authStateListener);

    // The New and Unread counts (and every row's read state beyond what
    // the lists carry).
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => TopicTrackingService.refresh(widget.siteContext));
  }

  @override
  void didUpdateWidget(covariant TopicListTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If tab just became active, ensure the active list refreshes
    final tabJustBecameActive = !oldWidget.isActive && widget.isActive;
    if (tabJustBecameActive) {
      AppLogger.debug('📋 [TOPIC_LIST_TAB] Tab just became active - refreshing active list');
      // Trigger refresh on the active view.
      switch (_activeFilter) {
        case HomeView.latest:
          _latestTopicsKey.currentState?.refreshList();
          break;
        case HomeView.newTopics:
          _newTopicsKey.currentState?.refreshList();
          break;
        case HomeView.unread:
          _unreadTopicsKey.currentState?.refreshList();
          break;
        case HomeView.top:
          _topTopicsKey.currentState?.refreshList();
          break;
        case HomeView.hot:
          _hotTopicsKey.currentState?.refreshList();
          break;
        case HomeView.categories:
          // The categories load once; their counts refresh as the view
          // comes back (CategoriesList.didUpdateWidget).
          break;
      }
      TopicTrackingService.refresh(widget.siteContext);
      // Force rebuild to show updated content
      if (mounted) {
        setState(() {});
      }
    }
  }

  bool _redrawQueued = false;

  /// A list's state changed: redraw from it (this tab reads the lists
  /// through their keys). Lists call this from their own `initState` too —
  /// the categories do as they start loading — which runs while this tab's
  /// subtree is being built, when marking the tab dirty is an error. So
  /// the redraw always waits for the end of the frame.
  void notifyDataLoaded() {
    if (!mounted || _redrawQueued) return;
    _redrawQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redrawQueued = false;
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 && !_isLoadingMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    _isLoadingMore = true;
    setState(() {});

    try {
      // Call loadMore on the active topic list
      switch (_activeFilter) {
        case HomeView.latest:
          final state = _latestTopicsKey.currentState;
          if (state != null && state.hasMoreItems) {
            await state.loadMore();
          }
          break;
        case HomeView.newTopics:
          final state = _newTopicsKey.currentState;
          if (state != null && state.hasMoreItems) {
            await state.loadMore();
          }
          break;
        case HomeView.unread:
          final unreadState = _unreadTopicsKey.currentState;
          if (unreadState != null && unreadState.hasMoreItems) {
            await unreadState.loadMore();
          }
          break;
        case HomeView.top:
          final topState = _topTopicsKey.currentState;
          if (topState != null && topState.hasMoreItems) {
            await topState.loadMore();
          }
          break;
        case HomeView.hot:
          final hotState = _hotTopicsKey.currentState;
          if (hotState != null && hotState.hasMoreItems) {
            await hotState.loadMore();
          }
          break;
        case HomeView.categories:
          break;
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  void resetTab() {
    // Reset all child lists
    _latestTopicsKey.currentState?.resetList();
    _newTopicsKey.currentState?.resetList();
    _unreadTopicsKey.currentState?.resetList();
    _topTopicsKey.currentState?.resetList();

    _categoriesKey.currentState?.refreshList();

    // Back to the forum's homepage view.
    setState(() {
      _chosenView = null;
    });

    // Scroll back to top
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    widget.siteContext.isLoggedInNotifier.removeListener(_authStateListener);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildFilterChips() {
    Widget chips(DiscourseTopicCounts? counts) => FilterChipBar(
          options: [
            for (final label in _getFilterLabels(context, counts))
              FilterChipOption(label: label),
          ],
          selectedIndex: _filters.indexOf(_activeFilter),
          onSelected: (i) {
            setState(() => _chosenView = _filters[i]);
            // The chips stay pinned under the header; the new view starts
            // at its top rather than wherever the last one was scrolled to.
            _scrollToViewTop();
          },
        );
    if (!widget.siteContext.isLoggedIn) return chips(null);
    final tracking = DiscourseTopicTracking.forSite(widget.siteContext);
    return ListenableBuilder(
      listenable: tracking,
      builder: (context, _) => chips(tracking.counts()),
    );
  }

  /// "Dismiss new" / "Dismiss unread" above the New and Unread lists,
  /// where the topics it acts on are, as web places them. Only when the
  /// list has topics.
  Widget? _buildDismissBar() {
    if (!widget.siteContext.isLoggedIn) return null;
    final (kind, hasTopics, reload) = switch (_activeFilter) {
      HomeView.newTopics => (
          DismissKind.newTopics,
          _newTopicsKey.currentState?.hasTopics ?? false,
          () => _newTopicsKey.currentState?.refreshList(),
        ),
      HomeView.unread => (
          DismissKind.unread,
          _unreadTopicsKey.currentState?.hasTopics ?? false,
          () => _unreadTopicsKey.currentState?.refreshList(),
        ),
      _ => (null, false, () {}),
    };
    if (kind == null || !hasTopics) return null;
    return DismissTopicsBar(
      siteContext: widget.siteContext,
      kind: kind,
      onDismissed: () {
        reload();
      },
    );
  }

  // Build topic list items from the active list
  List<Widget> _buildTopicItems() {
    switch (_activeFilter) {
      case HomeView.latest:
        return _latestTopicsKey.currentState?.buildTopicItems() ?? [];
      case HomeView.newTopics:
        return _newTopicsKey.currentState?.buildTopicItems() ?? [];
      case HomeView.unread:
        return _unreadTopicsKey.currentState?.buildTopicItems() ?? [];
      case HomeView.top:
        return _topTopicsKey.currentState?.buildTopicItems() ?? [];
      case HomeView.hot:
        return _hotTopicsKey.currentState?.buildTopicItems() ?? [];
      case HomeView.categories:
        final state = _categoriesKey.currentState;
        if (state == null || state.isLoading) {
          return const [Center(child: CircularProgressIndicator())];
        }
        return state.buildItems();
    }
  }

  // Build error/not signed in widget
  Widget? _buildErrorOrNotSignedInWidget() {
    switch (_activeFilter) {
      case HomeView.latest:
        return _latestTopicsKey.currentState?.buildErrorOrNotSignedInWidget();
      case HomeView.newTopics:
        return _newTopicsKey.currentState?.buildErrorOrNotSignedInWidget();
      case HomeView.unread:
        return _unreadTopicsKey.currentState?.buildErrorOrNotSignedInWidget();
      case HomeView.top:
        return _topTopicsKey.currentState?.buildErrorOrNotSignedInWidget();
      case HomeView.hot:
        return _hotTopicsKey.currentState?.buildErrorOrNotSignedInWidget();
      case HomeView.categories:
        return _categoriesKey.currentState?.buildErrorWidget();
    }
  }

  // Build empty state widget
  Widget? _buildEmptyState() {
    switch (_activeFilter) {
      case HomeView.latest:
        return _latestTopicsKey.currentState?.buildEmptyState();
      case HomeView.newTopics:
        return _newTopicsKey.currentState?.buildEmptyState();
      case HomeView.unread:
        return _unreadTopicsKey.currentState?.buildEmptyState();
      case HomeView.top:
        return _topTopicsKey.currentState?.buildEmptyState();
      case HomeView.hot:
        return _hotTopicsKey.currentState?.buildEmptyState();
      case HomeView.categories:
        return _categoriesKey.currentState?.buildEmptyState();
    }
  }

  /// The five list states, kept mounted for their controllers and
  /// GlobalKeys but never laid out or painted: their `build()` returns
  /// `SizedBox.shrink()` and `Offstage` skips the rest. They used to sit
  /// at Positioned(-10000) inside Opacity(0), where Latest and Unread
  /// still built a complete second copy of the feed every frame.
  Widget _buildTopicListWidgets() {
    return Offstage(
      offstage: true,
      child: IndexedStack(
        index: _filters.indexOf(_activeFilter),
        children: [
          for (final f in _filters)
            switch (f) {
              HomeView.latest => LatestTopicsList(
                  key: _latestTopicsKey,
                  isActive: widget.isActive &&
                      _activeFilter == HomeView.latest,
                  siteContext: widget.siteContext,
                ),
              HomeView.hot => HotTopicsList(
                  key: _hotTopicsKey,
                  isActive: widget.isActive &&
                      _activeFilter == HomeView.hot,
                  siteContext: widget.siteContext,
                ),
              HomeView.newTopics => NewTopicsList(
                  key: _newTopicsKey,
                  isActive: widget.isActive &&
                      _activeFilter == HomeView.newTopics,
                  siteContext: widget.siteContext,
                ),
              HomeView.unread => UnreadTopicsList(
                  key: _unreadTopicsKey,
                  isActive: widget.isActive &&
                      _activeFilter == HomeView.unread,
                  siteContext: widget.siteContext,
                ),
              HomeView.top => TopTopicsList(
                  key: _topTopicsKey,
                  isActive: widget.isActive &&
                      _activeFilter == HomeView.top,
                  siteContext: widget.siteContext,
                ),
              HomeView.categories => CategoriesList(
                  key: _categoriesKey,
                  isActive: widget.isActive &&
                      _activeFilter == HomeView.categories,
                  siteContext: widget.siteContext,
                  onChanged: notifyDataLoaded,
                ),
            },
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    unawaited(TopicTrackingService.refresh(widget.siteContext,
        maxAge: Duration.zero));
    // Trigger refresh on the active topic list
    switch (_activeFilter) {
      case HomeView.latest:
        await _latestTopicsKey.currentState?.refreshList();
        break;
      case HomeView.newTopics:
        await _newTopicsKey.currentState?.refreshList();
        break;
      case HomeView.unread:
        await _unreadTopicsKey.currentState?.refreshList();
        break;
      case HomeView.top:
        await _topTopicsKey.currentState?.refreshList();
        break;
      case HomeView.hot:
        await _hotTopicsKey.currentState?.refreshList();
        break;
      case HomeView.categories:
        await _categoriesKey.currentState?.refreshList();
        break;
    }
  }

  /// Brings the top of the current view up under the pinned chips, if the
  /// page is scrolled past it.
  void _scrollToViewTop() {
    if (!_scrollController.hasClients) return;
    final collapsedAt = _mastheadCollapseOffset;
    if (_scrollController.offset > collapsedAt) {
      _scrollController.jumpTo(collapsedAt);
    }
  }

  /// Where the header has finished collapsing into its bar.
  double get _mastheadCollapseOffset => widget.showMasthead
      ? ForumMasthead.collapseDistance(
          context, widget.siteContext, widget.boardStats)
      : 0;

  void _openSearch() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => SearchPage(siteContext: widget.siteContext)));
  }

  List<Widget> _headerSlivers() => [
        if (widget.showMasthead)
          ForumMasthead(
            siteContext: widget.siteContext,
            boardStats: widget.boardStats,
            onSearch: _openSearch,
          ),
        // The views stay in reach at any depth, pinned under the bar.
        PinnedHeaderSliver(
          child: ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: _buildFilterChips(),
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    // Always build the hidden widgets first to ensure they're initialized
    final hiddenWidgets = _buildTopicListWidgets();

    // Check for error/not signed in state
    final errorWidget = _buildErrorOrNotSignedInWidget();
    if (errorWidget != null) {
      return Stack(
        children: [
          CustomScrollView(
            slivers: [
              ..._headerSlivers(),
              SliverFillRemaining(hasScrollBody: false, child: errorWidget),
            ],
          ),
          hiddenWidgets,
        ],
      );
    }

    final dismissBar = _buildDismissBar();
    return TopicTrackingLive(
      siteContext: widget.siteContext,
      active: widget.isActive,
      child: Stack(
      children: [
        RefreshIndicator(
          onRefresh: _handleRefresh,
          // Under the header's bar, not over the status bar.
          edgeOffset: widget.showMasthead
              ? MediaQuery.paddingOf(context).top +
                  ForumMasthead.toolbarHeight
              : 0,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              ..._headerSlivers(),
              if (dismissBar != null) SliverToBoxAdapter(child: dismissBar),
              ..._topicSlivers(context, _buildTopicItems(), _buildEmptyState()),
            ],
          ),
        ),
        hiddenWidgets,
      ],
      ),
    );
  }
}

/// Widget que muestra una lista de foros con datos mockup
class TopicList extends StatelessWidget {
  const TopicList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 0,
      itemBuilder: (context, index) => const SizedBox.shrink(),
    );
  }
}


/// The views of a forum's Home: the list routes of Discourse's navigation
/// bar (`top_menu`) the app draws.
enum HomeView {
  latest,
  hot,
  newTopics,
  unread,
  top,
  categories;

  /// A forum's Home views: its own navigation bar ([menu], its `top_menu`)
  /// in its order, homepage first. New and Unread need a session, as on
  /// the website; Hot needs the forum to offer it. Every forum gets Latest
  /// and Categories, wherever its menu puts them, and a forum whose menu is
  /// not known yet gets Discourse's defaults.
  static List<HomeView> viewsFor({
    required List<String> menu,
    required bool signedIn,
    required bool offersHot,
  }) {
    final items = menu.isNotEmpty
        ? menu
        : const ['latest', 'hot', 'new', 'unread', 'top', 'categories'];
    final views = <HomeView>[];
    for (final item in items) {
      final view = fromMenuItem(item);
      if (view == null || views.contains(view)) continue;
      if (view == hot && !offersHot) continue;
      if ((view == newTopics || view == unread) && !signedIn) continue;
      views.add(view);
    }
    if (!views.contains(latest)) views.insert(0, latest);
    if (!views.contains(categories)) views.add(categories);
    return views;
  }

  /// The view a `top_menu` item names, or null for one the app does not
  /// draw (Bookmarks, Posted, Votes…).
  static HomeView? fromMenuItem(String item) => switch (item.toLowerCase()) {
        'latest' => latest,
        'hot' => hot,
        'new' => newTopics,
        'unread' => unread,
        'top' => top,
        'categories' => categories,
        _ => null,
      };
}
