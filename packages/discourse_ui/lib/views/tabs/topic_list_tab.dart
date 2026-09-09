import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:discourse_ui/views/widgets/resettable_widget.dart';
import 'package:discourse_ui/views/lists/latest_topics_list.dart';
import 'package:discourse_ui/views/widgets/filter_chip_bar.dart';
import 'package:discourse_ui/views/lists/hot_topics_list.dart';
import 'package:discourse_core/discourse_core.dart' show DiscourseSiteCapabilities;
import 'package:discourse_ui/views/lists/new_topics_list.dart';
import 'package:discourse_ui/views/lists/top_topics_list.dart';
import 'package:discourse_ui/views/lists/unread_topics_list.dart';
import 'package:discourse_ui/views/widgets/forum_header_widget.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart' as forumcopilot_sdk;
import 'package:discourse_ui/core/logging/app_logger.dart';

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
  const TopicListTab({Key? key, required this.siteContext, required this.isActive, this.boardStats}) : super(key: key);

  @override
  TopicListTabState createState() => TopicListTabState();
}

class TopicListTabState extends FCStatefulWidget<TopicListTab> with FCTabStatefulWidget<TopicListTab> {
  int _selectedFilterIndex = 0;
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

  /// Whether this forum offers `/hot.json`. Appended LAST rather than
  /// placed in web's Latest/Hot/New/Top order on purpose: every index in
  /// this widget is positional — six switch statements and the
  /// IndexedStack children — so inserting mid-list would renumber the
  /// existing tabs. Appending keeps their indices fixed, and the Hot
  /// index only exists when the tab does.
  bool get _offersHot => DiscourseSiteCapabilities.offersRoute(
      widget.siteContext.site.pluginUrl, 'hot');

  /// The sub-tabs, in Discourse's own order (web: Latest, Hot, New, Top).
  /// Unread sits before Top because this app surfaces it here rather than
  /// in a sidebar as web does.
  ///
  /// Everything index-driven below reads through this list rather than
  /// hardcoding positions, so a forum without `/hot.json` simply has a
  /// shorter list instead of renumbering every branch.
  List<_HomeFilter> get _filters => [
        _HomeFilter.latest,
        if (_offersHot) _HomeFilter.hot,
        _HomeFilter.newTopics,
        _HomeFilter.unread,
        _HomeFilter.top,
      ];

  _HomeFilter get _activeFilter {
    final filters = _filters;
    final i = _selectedFilterIndex;
    return i >= 0 && i < filters.length ? filters[i] : _HomeFilter.latest;
  }

  // Scroll controller for the main ListView
  final ScrollController _scrollController = ScrollController();

  // Track previous login state to detect changes
  bool _wasLoggedIn = false;
  String? _lastLoadedUsername;
  late final VoidCallback _authStateListener;

  List<String> _getFilterLabels(BuildContext context) {
    // Discourse-native order: Latest, New, Unread, Top. "Subscribed" /
    // "Participated" from the old XF-flavored chip set moved out of
    // this tab in Phase 5.17c; they'll resurface under the Profile
    // tab as Watching / Posted-in in Phase 5.17d.
    final l10n = AppLocalizations.of(context)!;
    return _filters.map((f) {
      switch (f) {
        case _HomeFilter.latest:
          return l10n.latest;
        case _HomeFilter.hot:
          return 'Hot'; // Discourse's /hot.json
        case _HomeFilter.newTopics:
          return 'New'; // Discourse's /new.json
        case _HomeFilter.unread:
          return l10n.unread;
        case _HomeFilter.top:
          return 'Top'; // Discourse's /top.json with period selector
      }
    }).toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
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
      }
    };

    widget.siteContext.isLoggedInNotifier.addListener(_authStateListener);
  }

  @override
  void didUpdateWidget(covariant TopicListTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If tab just became active, ensure the active list refreshes
    final tabJustBecameActive = !oldWidget.isActive && widget.isActive;
    if (tabJustBecameActive) {
      AppLogger.debug('📋 [TOPIC_LIST_TAB] Tab just became active - refreshing active list');
      // Trigger refresh on the active topic list. Index map: 0=Latest,
      // 1=New, 2=Unread, 3=Top.
      switch (_activeFilter) {
        case _HomeFilter.latest:
          _latestTopicsKey.currentState?.refreshList();
          break;
        case _HomeFilter.newTopics:
          _newTopicsKey.currentState?.refreshList();
          break;
        case _HomeFilter.unread:
          _unreadTopicsKey.currentState?.refreshList();
          break;
        case _HomeFilter.top:
          _topTopicsKey.currentState?.refreshList();
          break;
        case _HomeFilter.hot:
          _hotTopicsKey.currentState?.refreshList();
          break;
      }
      // Force rebuild to show updated content
      if (mounted) {
        setState(() {});
      }
    }
  }

  // Method to notify parent that data has been loaded - child can call this
  void notifyDataLoaded() {
    AppLogger.debug('📢 [TOPIC_LIST_TAB] notifyDataLoaded called - forcing rebuild');
    if (mounted) {
      setState(() {});
    }
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
        case _HomeFilter.latest:
          final state = _latestTopicsKey.currentState;
          if (state != null && state.hasMoreItems) {
            await state.loadMore();
          }
          break;
        case _HomeFilter.newTopics:
          final state = _newTopicsKey.currentState;
          if (state != null && state.hasMoreItems) {
            await state.loadMore();
          }
          break;
        case _HomeFilter.unread:
          final unreadState = _unreadTopicsKey.currentState;
          if (unreadState != null && unreadState.hasMoreItems) {
            await unreadState.loadMore();
          }
          break;
        case _HomeFilter.top:
          final topState = _topTopicsKey.currentState;
          if (topState != null && topState.hasMoreItems) {
            await topState.loadMore();
          }
          break;
        case _HomeFilter.hot:
          final hotState = _hotTopicsKey.currentState;
          if (hotState != null && hotState.hasMoreItems) {
            await hotState.loadMore();
          }
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

    // Reset to first filter if needed
    setState(() {
      _selectedFilterIndex = 0;
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
    return FilterChipBar(
      options: [
        for (final label in _getFilterLabels(context)) FilterChipOption(label: label),
      ],
      selectedIndex: _selectedFilterIndex,
      onSelected: (i) => setState(() => _selectedFilterIndex = i),
    );
  }

  // Build topic list items from the active list
  List<Widget> _buildTopicItems() {
    switch (_activeFilter) {
      case _HomeFilter.latest:
        return _latestTopicsKey.currentState?.buildTopicItems() ?? [];
      case _HomeFilter.newTopics:
        return _newTopicsKey.currentState?.buildTopicItems() ?? [];
      case _HomeFilter.unread:
        return _unreadTopicsKey.currentState?.buildTopicItems() ?? [];
      case _HomeFilter.top:
        return _topTopicsKey.currentState?.buildTopicItems() ?? [];
      case _HomeFilter.hot:
        return _hotTopicsKey.currentState?.buildTopicItems() ?? [];
    }
  }

  // Build error/not signed in widget
  Widget? _buildErrorOrNotSignedInWidget() {
    switch (_activeFilter) {
      case _HomeFilter.latest:
        return _latestTopicsKey.currentState?.buildErrorOrNotSignedInWidget();
      case _HomeFilter.newTopics:
        return _newTopicsKey.currentState?.buildErrorOrNotSignedInWidget();
      case _HomeFilter.unread:
        return _unreadTopicsKey.currentState?.buildErrorOrNotSignedInWidget();
      case _HomeFilter.top:
        return _topTopicsKey.currentState?.buildErrorOrNotSignedInWidget();
      case _HomeFilter.hot:
        return _hotTopicsKey.currentState?.buildErrorOrNotSignedInWidget();
    }
  }

  // Build empty state widget
  Widget? _buildEmptyState() {
    switch (_activeFilter) {
      case _HomeFilter.latest:
        return _latestTopicsKey.currentState?.buildEmptyState();
      case _HomeFilter.newTopics:
        return _newTopicsKey.currentState?.buildEmptyState();
      case _HomeFilter.unread:
        return _unreadTopicsKey.currentState?.buildEmptyState();
      case _HomeFilter.top:
        return _topTopicsKey.currentState?.buildEmptyState();
      case _HomeFilter.hot:
        return _hotTopicsKey.currentState?.buildEmptyState();
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
        index: _selectedFilterIndex,
        children: [
          for (final f in _filters)
            switch (f) {
              _HomeFilter.latest => LatestTopicsList(
                  key: _latestTopicsKey,
                  isActive: widget.isActive &&
                      _activeFilter == _HomeFilter.latest,
                  siteContext: widget.siteContext,
                ),
              _HomeFilter.hot => HotTopicsList(
                  key: _hotTopicsKey,
                  isActive: widget.isActive &&
                      _activeFilter == _HomeFilter.hot,
                  siteContext: widget.siteContext,
                ),
              _HomeFilter.newTopics => NewTopicsList(
                  key: _newTopicsKey,
                  isActive: widget.isActive &&
                      _activeFilter == _HomeFilter.newTopics,
                  siteContext: widget.siteContext,
                ),
              _HomeFilter.unread => UnreadTopicsList(
                  key: _unreadTopicsKey,
                  isActive: widget.isActive &&
                      _activeFilter == _HomeFilter.unread,
                  siteContext: widget.siteContext,
                ),
              _HomeFilter.top => TopTopicsList(
                  key: _topTopicsKey,
                  isActive: widget.isActive &&
                      _activeFilter == _HomeFilter.top,
                  siteContext: widget.siteContext,
                ),
            },
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // Trigger refresh on the active topic list
    switch (_activeFilter) {
      case _HomeFilter.latest:
        await _latestTopicsKey.currentState?.refreshList();
        break;
      case _HomeFilter.newTopics:
        await _newTopicsKey.currentState?.refreshList();
        break;
      case _HomeFilter.unread:
        await _unreadTopicsKey.currentState?.refreshList();
        break;
      case _HomeFilter.top:
        await _topTopicsKey.currentState?.refreshList();
        break;
      case _HomeFilter.hot:
        await _hotTopicsKey.currentState?.refreshList();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Always build the hidden widgets first to ensure they're initialized
    final hiddenWidgets = _buildTopicListWidgets();

    // Check for error/not signed in state
    final errorWidget = _buildErrorOrNotSignedInWidget();
    if (errorWidget != null) {
      return Stack(
        children: [
          Column(
            children: [
              ForumHeaderWidget(
                boardStats: widget.boardStats,
                extendUnderAppBar: true,
              ),
              _buildFilterChips(),
              Expanded(child: errorWidget),
            ],
          ),
          hiddenWidgets,
        ],
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ForumHeaderWidget(
                  boardStats: widget.boardStats,
                  extendUnderAppBar: true,
                ),
              ),
              SliverToBoxAdapter(child: _buildFilterChips()),
              ..._topicSlivers(context, _buildTopicItems(), _buildEmptyState()),
            ],
          ),
        ),
        hiddenWidgets,
      ],
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


/// The Home tab's sub-filters. Named rather than positional because a
/// forum can turn `/hot.json` off, and with indices that made every
/// branch below depend on which tabs happened to exist.
enum _HomeFilter { latest, hot, newTopics, unread, top }
