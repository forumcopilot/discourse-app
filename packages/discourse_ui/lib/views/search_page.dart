import 'package:flutter/material.dart';
import 'widgets/filter_chip_bar.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import '../models/cache_context.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscourseSearchProxy;
import 'package:forumcopilot_sdk/models/search/fc_search_filters.dart';
import '../theme/design_tokens.dart';
import '../theme/style_builders.dart';
import 'listitems/topic_list_item.dart';
import 'lists/posts_list.dart';
import 'post_page.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import 'login_page.dart';
import 'widgets/search_filters_sheet.dart';

class SearchPage extends StatefulWidget {
  final SiteContext siteContext;
  const SearchPage({super.key, required this.siteContext});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _searchHistory = [];
  List<String> _filteredHistory = [];

  // Search results state
  String? _currentQuery;
  int _selectedFilterIndex = 0; // 0 = All (Posts), 1 = Topics Only, 2 = Titles Only
  List<String> _getFilterLabels(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [l10n.all, l10n.topicsOnly, l10n.titlesOnly];
  }

  int _topicPage = 1;
  int _postPage = 1;
  int _titlesOnlyPage = 1;
  final int _pageSize = 20;
  bool _isLoadingTopics = false;
  bool _isLoadingPosts = false;
  bool _isLoadingTitlesOnly = false;
  bool _hasMoreTopics = true;
  bool _hasMorePosts = true;
  bool _hasMoreTitlesOnly = true;
  final List<FCTopic> _topics = [];
  final List<FCPost> _posts = [];
  final List<FCTopic> _titlesOnlyTopics = [];
  final ScrollController _topicScrollController = ScrollController();
  final ScrollController _postScrollController = ScrollController();
  final ScrollController _titlesOnlyScrollController = ScrollController();
  String? _postSearchId;
  String? _topicSearchId;
  String? _titlesOnlySearchId;

  /// Monotonic token identifying the current query. Every fetch
  /// captures it at start; responses (and their finally-blocks) that
  /// come back with a stale token are discarded so an in-flight fetch
  /// for query "a" can never append into the lists of query "b".
  int _querySeq = 0;

  // Per-tab error flags so the snackbar's Retry knows what to re-run.
  bool _topicsError = false;
  bool _postsError = false;
  bool _titlesOnlyError = false;
  int _errorSnackSeq = -1;

  /// Discourse-native filter set. Layered onto every
  /// DiscourseSearchProxy.searchWithFiltersAsync call (the fetchers
  /// always take the Discourse-native route when the proxy supports
  /// it); the XF-flavored search methods are the non-Discourse
  /// fallback only.
  FCSearchFilters _filters = const FCSearchFilters();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onInputChanged);
    _loadSearchHistory();
    _topicScrollController.addListener(_onTopicScroll);
    _postScrollController.addListener(_onPostScroll);
    _titlesOnlyScrollController.addListener(_onTitlesOnlyScroll);
    // Focus the field on open. Without this the search screen arrived
    // with no keyboard and nothing focused, so the first thing typed
    // went nowhere and the user had to tap the field they had just
    // navigated to. Post-frame because the focus node is not attached
    // to the TextField until the first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onInputChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _topicScrollController.dispose();
    _postScrollController.dispose();
    _titlesOnlyScrollController.dispose();
    super.dispose();
  }

  void _onTopicScroll() {
    if (_topicScrollController.position.pixels >= _topicScrollController.position.maxScrollExtent - 300 && !_isLoadingTopics && _hasMoreTopics && _currentQuery != null) {
      _fetchTopics();
    }
  }

  void _onPostScroll() {
    if (_postScrollController.position.pixels >= _postScrollController.position.maxScrollExtent - 300 && !_isLoadingPosts && _hasMorePosts && _currentQuery != null) {
      _fetchPosts();
    }
  }

  void _onTitlesOnlyScroll() {
    if (_titlesOnlyScrollController.position.pixels >= _titlesOnlyScrollController.position.maxScrollExtent - 300 && !_isLoadingTitlesOnly && _hasMoreTitlesOnly && _currentQuery != null) {
      _fetchTitlesOnly();
    }
  }

  Future<void> _loadSearchHistory() async {
    await CacheContext.instance.loadFromDevice();
    setState(() {
      _searchHistory = CacheContext.instance.getSearchHistory();
      _filteredHistory = _searchHistory.take(5).toList();
    });
  }

  void _onInputChanged() {
    final input = _searchController.text.trim().toLowerCase();
    setState(() {
      if (input.isEmpty) {
        _filteredHistory = _searchHistory.take(5).toList();
      } else {
        _filteredHistory = _searchHistory.where((q) => q.toLowerCase().contains(input)).take(5).toList();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _querySeq++; // invalidate any in-flight fetches
      _searchController.clear();
      _currentQuery = null;
      _resetResultState();
    });
    _searchFocusNode.requestFocus();
  }

  /// Resets all per-query result state. Only call inside setState, and
  /// after bumping [_querySeq] so stale fetches can't repopulate it.
  void _resetResultState() {
    _topics.clear();
    _posts.clear();
    _titlesOnlyTopics.clear();
    _topicPage = 1;
    _postPage = 1;
    _titlesOnlyPage = 1;
    _hasMoreTopics = true;
    _hasMorePosts = true;
    _hasMoreTitlesOnly = true;
    // In-flight fetches belong to the previous query; their stale token
    // stops them from touching state, so they must not block the new
    // query's fetches either.
    _isLoadingTopics = false;
    _isLoadingPosts = false;
    _isLoadingTitlesOnly = false;
    _topicsError = false;
    _postsError = false;
    _titlesOnlyError = false;
    _postSearchId = null;
    _topicSearchId = null;
    _titlesOnlySearchId = null;
  }

  Future<void> _openFiltersSheet() async {
    final updated = await SearchFiltersSheet.show(
      context: context,
      initial: _filters,
      loggedIn: widget.siteContext.isLoggedIn,
    );
    if (updated == null) return;
    setState(() => _filters = updated);
    // If a query is already active, re-run it with the new filters.
    final q = _currentQuery;
    if (q != null && q.isNotEmpty) {
      // Force a re-search by clearing _currentQuery so _performSearch
      // doesn't bail on the "same query" guard.
      _currentQuery = null;
      _performSearch(q);
    }
  }

  void _performSearch(String query) async {
    if (query.isEmpty) return;

    final trimmedQuery = query.trim();
    if (trimmedQuery == _currentQuery) return; // Don't re-search the same query

    await CacheContext.instance.addSearchQuery(trimmedQuery);
    setState(() {
      _searchHistory = CacheContext.instance.getSearchHistory();
      _onInputChanged(); // re-filter after adding
      _querySeq++; // invalidate any in-flight fetches of the old query
      _currentQuery = trimmedQuery;
      _searchController.text = trimmedQuery;
      _resetResultState();
    });

    // Fetch results
    _fetchTopics();
    _fetchPosts();
    _fetchTitlesOnly();
  }

  /// Surfaces a fetch failure and marks the failed tab(s) so the
  /// snackbar's Retry (and the scroll listeners — `_hasMoreX` stays
  /// true on error) can re-run them. One snackbar per query.
  void _reportSearchError(int seq, String? message,
      {bool topics = false, bool posts = false, bool titlesOnly = false}) {
    if (topics) _topicsError = true;
    if (posts) _postsError = true;
    if (titlesOnly) _titlesOnlyError = true;
    if (_errorSnackSeq == seq) return;
    _errorSnackSeq = seq;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(
            message == null || message.isEmpty ? 'Search failed' : message),
        action: SnackBarAction(
          label: AppLocalizations.of(context)?.retry ?? 'Retry',
          onPressed: () {
            if (!mounted || seq != _querySeq) return;
            _errorSnackSeq = -1; // re-arm the snackbar if the retry fails
            if (_topicsError) _fetchTopics();
            if (_postsError) _fetchPosts();
            if (_titlesOnlyError) _fetchTitlesOnly();
          },
        ),
      ),
    );
  }

  Future<void> _fetchTopics() async {
    if (_isLoadingTopics || !_hasMoreTopics || _currentQuery == null) return;
    final seq = _querySeq;
    final query = _currentQuery!;
    setState(() {
      _isLoadingTopics = true;
      _topicsError = false;
    });
    final hasAdvancedSearch = widget.siteContext.ConfigData.advancedSearch == true;
    final proxy = SiteProxyService.getSearchProxy();

    try {
      // Discourse-native route: /search.json pages are 1-based and
      // server-sized, and has-more comes from the server's
      // more_full_page_results signal rather than counting rows.
      // Structured filters ride along when set.
      if (proxy is DiscourseSearchProxy) {
        final result = await proxy.searchWithFiltersAsync(
          keywords: query,
          filters: _filters,
          page: _topicPage,
        );
        if (!mounted || seq != _querySeq) return;
        setState(() {
          _topics.addAll(result.topics);
          _hasMoreTopics = result.hasMore;
          if (_hasMoreTopics) _topicPage++;
        });
      } else if (!hasAdvancedSearch) {
        final startNum = (_topicPage - 1) * _pageSize;
        final lastNum = startNum + _pageSize - 1;
        final result = await proxy.searchTopicAsync(query, startNum, lastNum, null);
        if (!mounted || seq != _querySeq) return;
        if (!result.result) {
          _reportSearchError(seq, result.resultText, topics: true);
          return;
        }
        setState(() {
          _topics.addAll(result.topics);
          _hasMoreTopics = result.topics.length >= _pageSize;
          if (_hasMoreTopics) _topicPage++;
        });
      } else {
        // Use advanced search for topics
        final result = await proxy.advanceSearchTopicAsync(
          query, // keywords
          _topicPage, // page
          _pageSize, // perpage
          _topicSearchId, // searchId for pagination
          false, // titleOnly
          null, // userId
          null, // searchUser
          null, // forumId
          null, // topicId
          null, // onlyIn
          null, // notIn
          false, // startedBy
          null, // searchTime
        );
        if (!mounted || seq != _querySeq) return;
        if (!result.result) {
          _reportSearchError(seq, result.resultText, topics: true);
          return;
        }
        // Only update searchId if this is the first page
        if (_topicSearchId == null && result.search_id != null && result.search_id!.isNotEmpty) {
          _topicSearchId = result.search_id;
        }
        setState(() {
          _topics.addAll(result.topics);
          _hasMoreTopics = result.topics.length >= _pageSize;
          if (_hasMoreTopics) _topicPage++;
        });
      }
    } catch (e) {
      if (!mounted || seq != _querySeq) return;
      _reportSearchError(seq, 'Search failed: $e', topics: true);
    } finally {
      if (mounted && seq == _querySeq) {
        setState(() {
          _isLoadingTopics = false;
        });
      }
    }
  }

  Future<void> _fetchPosts() async {
    if (_isLoadingPosts || !_hasMorePosts || _currentQuery == null) return;
    final seq = _querySeq;
    final query = _currentQuery!;
    setState(() {
      _isLoadingPosts = true;
      _postsError = false;
    });
    final hasAdvancedSearch = widget.siteContext.ConfigData.advancedSearch == true;
    final proxy = SiteProxyService.getSearchProxy();

    try {
      if (proxy is DiscourseSearchProxy) {
        final result = await proxy.searchWithFiltersAsync(
          keywords: query,
          filters: _filters,
          page: _postPage,
        );
        if (!mounted || seq != _querySeq) return;
        setState(() {
          _posts.addAll(result.posts);
          _hasMorePosts = result.hasMore;
          if (_hasMorePosts) _postPage++;
        });
      } else if (!hasAdvancedSearch) {
        final startNum = (_postPage - 1) * _pageSize;
        final lastNum = startNum + _pageSize - 1;
        final result = await proxy.searchPostAsync(query, startNum, lastNum, '');
        if (!mounted || seq != _querySeq) return;
        if (!result.result) {
          _reportSearchError(seq, result.resultText, posts: true);
          return;
        }
        setState(() {
          _posts.addAll(result.posts);
          _hasMorePosts = result.posts.length >= _pageSize;
          if (_hasMorePosts) _postPage++;
        });
      } else {
        // Use advanced search for posts
        final result = await proxy.advanceSearchPostAsync(
          query, // keywords
          _postPage, // page
          _pageSize, // perpage
          _postSearchId, // searchId for pagination
          false, // titleOnly
          null, // userId
          null, // searchUser
          null, // forumId
          null, // topicId
          null, // onlyIn
          null, // notIn
          false, // startedBy
        );
        if (!mounted || seq != _querySeq) return;
        if (!result.result) {
          _reportSearchError(seq, result.resultText, posts: true);
          return;
        }
        // Only update searchId if this is the first page
        if (_postSearchId == null && result.search_id != null && result.search_id!.isNotEmpty) {
          _postSearchId = result.search_id;
        }
        setState(() {
          _posts.addAll(result.posts);
          _hasMorePosts = result.posts.length >= _pageSize;
          if (_hasMorePosts) _postPage++;
        });
      }
    } catch (e) {
      if (!mounted || seq != _querySeq) return;
      _reportSearchError(seq, 'Search failed: $e', posts: true);
    } finally {
      if (mounted && seq == _querySeq) {
        setState(() {
          _isLoadingPosts = false;
        });
      }
    }
  }

  Future<void> _fetchTitlesOnly() async {
    if (_isLoadingTitlesOnly || !_hasMoreTitlesOnly || _currentQuery == null) return;
    final seq = _querySeq;
    final query = _currentQuery!;
    setState(() {
      _isLoadingTitlesOnly = true;
      _titlesOnlyError = false;
    });
    final hasAdvancedSearch = widget.siteContext.ConfigData.advancedSearch == true;
    final proxy = SiteProxyService.getSearchProxy();

    try {
      if (proxy is DiscourseSearchProxy) {
        // Discourse-native route with `in:title` layered on top of any
        // user-selected filters.
        final result = await proxy.searchWithFiltersAsync(
          keywords: query,
          filters: _filters.copyWith(titleOnly: true),
          page: _titlesOnlyPage,
        );
        if (!mounted || seq != _querySeq) return;
        setState(() {
          _titlesOnlyTopics.addAll(result.topics);
          _hasMoreTitlesOnly = result.hasMore;
          if (_hasMoreTitlesOnly) _titlesOnlyPage++;
        });
      } else if (!hasAdvancedSearch) {
        // If advanced search is not available, fall back to regular topic search
        final startNum = (_titlesOnlyPage - 1) * _pageSize;
        final lastNum = startNum + _pageSize - 1;
        final result = await proxy.searchTopicAsync(query, startNum, lastNum, null);
        if (!mounted || seq != _querySeq) return;
        if (!result.result) {
          _reportSearchError(seq, result.resultText, titlesOnly: true);
          return;
        }
        setState(() {
          _titlesOnlyTopics.addAll(result.topics);
          _hasMoreTitlesOnly = result.topics.length >= _pageSize;
          if (_hasMoreTitlesOnly) _titlesOnlyPage++;
        });
      } else {
        // Use advanced search with titleOnly = true
        final result = await proxy.advanceSearchTopicAsync(
          query, // keywords
          _titlesOnlyPage, // page
          _pageSize, // perpage
          _titlesOnlySearchId, // searchId for pagination
          true, // titleOnly - this is the key difference
          null, // userId
          null, // searchUser
          null, // forumId
          null, // topicId
          null, // onlyIn
          null, // notIn
          false, // startedBy
          null, // searchTime
        );
        if (!mounted || seq != _querySeq) return;
        if (!result.result) {
          _reportSearchError(seq, result.resultText, titlesOnly: true);
          return;
        }
        // Only update searchId if this is the first page
        if (_titlesOnlySearchId == null && result.search_id != null && result.search_id!.isNotEmpty) {
          _titlesOnlySearchId = result.search_id;
        }
        setState(() {
          _titlesOnlyTopics.addAll(result.topics);
          _hasMoreTitlesOnly = result.topics.length >= _pageSize;
          if (_hasMoreTitlesOnly) _titlesOnlyPage++;
        });
      }
    } catch (e) {
      if (!mounted || seq != _querySeq) return;
      _reportSearchError(seq, 'Search failed: $e', titlesOnly: true);
    } finally {
      if (mounted && seq == _querySeq) {
        setState(() {
          _isLoadingTitlesOnly = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.search ?? 'Search',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: DesignTokens.fontWeightMedium,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 3,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
        surfaceTintColor: colorScheme.surfaceTint,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.tune),
                if (!_filters.isEmpty)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Filters',
            onPressed: _openFiltersSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: DesignTokens.paddingL,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: DesignTokens.opacityLow),
                  width: 1,
                ),
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)?.enterKeywordsToSearchTopics ?? 'Enter keywords to search topics...',
                hintStyle: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: _currentQuery != null
                            ? _clearSearch
                            : () {
                                _searchController.clear();
                                _searchFocusNode.requestFocus();
                              },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: DesignTokens.borderWidthMedium,
                  ),
                ),
                filled: true,
                fillColor: colorScheme.surfaceVariant.withValues(alpha: DesignTokens.opacityLow),
                contentPadding: DesignTokens.paddingInput,
              ),
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _performSearch(value.trim());
                }
              },
            ),
          ),
          // Content: Either search history or results
          Expanded(
            child: _currentQuery == null ? _buildSearchHistory(colorScheme, textTheme) : _buildSearchResults(colorScheme, textTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory(ColorScheme colorScheme, TextTheme textTheme) {
    if (_filteredHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: DesignTokens.spacingL),
            Text(
              'Search for topics',
              style: StyleBuilders.titleTextStyle(
                colorScheme: colorScheme,
                textTheme: textTheme,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingS),
            Text(
              AppLocalizations.of(context)?.enterKeywordsToFindTopicsAndPosts ?? 'Enter keywords to find topics and posts',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: DesignTokens.paddingVerticalS,
      itemCount: _filteredHistory.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingXS),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingS),
            leading: Icon(
              Icons.history_rounded,
              color: colorScheme.onSurfaceVariant,
              size: DesignTokens.iconSizeM,
            ),
            title: Text(
              _filteredHistory[index],
              style: StyleBuilders.bodyTextStyle(
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ),
            trailing: Icon(
              Icons.arrow_upward_rounded,
              color: colorScheme.onSurfaceVariant,
              size: DesignTokens.iconSizeS,
            ),
            onTap: () => _performSearch(_filteredHistory[index]),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        // Filter Chips
        _buildFilterChips(colorScheme, textTheme),
        // Content
        Expanded(
          child: _selectedFilterIndex == 0
              ? _buildPostsTab(colorScheme, textTheme)
              : _selectedFilterIndex == 1
                  ? _buildTopicsTab(colorScheme, textTheme)
                  : _buildTitlesOnlyTab(colorScheme, textTheme),
        ),
      ],
    );
  }

  Widget _buildFilterChips(ColorScheme colorScheme, TextTheme textTheme) {
    // Was a hand-rolled copy of FilterChipBar — same styling, same
    // layout, its own code — which is why it still wore the checkmark
    // over the selected chip after the shared bar had dropped it.
    final labels = _getFilterLabels(context);
    return FilterChipBar(
      options: [for (final l in labels) FilterChipOption(label: l)],
      selectedIndex: _selectedFilterIndex,
      onSelected: (i) => setState(() => _selectedFilterIndex = i),
    );
  }

  Widget _buildTopicsTab(ColorScheme colorScheme, TextTheme textTheme) {
    if (_isLoadingTopics && _topics.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_topics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.topic_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: DesignTokens.spacingL),
            Text(
              'No topics found',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingS),
            Text(
              'Try searching with different keywords',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _topicScrollController,
      itemCount: _topics.length + (_hasMoreTopics ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _topics.length) {
          final t = _topics[index];
          return TopicListItem(
            siteContext: widget.siteContext,
            topic: t,
            onTap: () async {
              if (!widget.siteContext.isLoggedIn) {
                if (!Get.isRegistered<DiscourseLoginController>()) {
                  Get.put(DiscourseLoginController());
                }
                final loginController = Get.find<DiscourseLoginController>();
                final loginResult = await loginController.attemptAutomaticLogin(widget.siteContext);
                if (!loginResult.success && loginResult.hadCredentials && Get.currentRoute != '/LoginPage') {
                  await Get.to(() => LoginPage(siteContext: widget.siteContext));
                }
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostPage(
                    siteContext: widget.siteContext,
                    topicId: t.id,
                    title: t.title,
                  ),
                ),
              );
            },
          );
        } else {
          return const Padding(
            padding: DesignTokens.paddingL,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget _buildPostsTab(ColorScheme colorScheme, TextTheme textTheme) {
    if (_isLoadingPosts && _posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: DesignTokens.spacingL),
            Text(
              'No posts found',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingS),
            Text(
              'Try searching with different keywords',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _postScrollController,
      itemCount: _posts.length + (_hasMorePosts ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _posts.length) {
          final p = _posts[index];
          return TopicListItem(
            siteContext: widget.siteContext,
            topic: FCTopic(
              id: p.topicId,
              title: p.topicTitle ?? p.title,
              shortContent: p.content,
              timestamp: p.timestamp ?? DateTime.now(),
              authorId: p.authorId,
              authorName: p.authorName,
              authorIconUrl: p.authorIconUrl ?? '',
              authorUserType: p.authorUserType,
              forumId: p.topicId, // Use topicId as forumId for now
              forumName: '', // No forum name in FCPost
              replyCount: 0,
              isPinned: false,
              isAnnouncement: false,
              isSubscribed: false,
            ),
            onTap: () async {
              if (!widget.siteContext.isLoggedIn) {
                if (!Get.isRegistered<DiscourseLoginController>()) {
                  Get.put(DiscourseLoginController());
                }
                final loginController = Get.find<DiscourseLoginController>();
                final loginResult = await loginController.attemptAutomaticLogin(widget.siteContext);
                if (!loginResult.success && loginResult.hadCredentials && Get.currentRoute != '/LoginPage') {
                  await Get.to(() => LoginPage(siteContext: widget.siteContext));
                }
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostPage(
                    siteContext: widget.siteContext,
                    topicId: p.topicId,
                    title: p.topicTitle ?? p.title,
                    mode: PostsListMode.thread_by_post,
                    anchorPostId: p.id,
                    forumId: p.topicId,
                  ),
                ),
              );
            },
          );
        } else {
          return const Padding(
            padding: DesignTokens.paddingL,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget _buildTitlesOnlyTab(ColorScheme colorScheme, TextTheme textTheme) {
    if (_isLoadingTitlesOnly && _titlesOnlyTopics.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_titlesOnlyTopics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.title_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: DesignTokens.spacingL),
            Text(
              'No topics found',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingS),
            Text(
              'Try searching with different keywords',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _titlesOnlyScrollController,
      itemCount: _titlesOnlyTopics.length + (_hasMoreTitlesOnly ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _titlesOnlyTopics.length) {
          final t = _titlesOnlyTopics[index];
          return TopicListItem(
            siteContext: widget.siteContext,
            topic: t,
            onTap: () async {
              if (!widget.siteContext.isLoggedIn) {
                if (!Get.isRegistered<DiscourseLoginController>()) {
                  Get.put(DiscourseLoginController());
                }
                final loginController = Get.find<DiscourseLoginController>();
                final loginResult = await loginController.attemptAutomaticLogin(widget.siteContext);
                if (!loginResult.success && loginResult.hadCredentials && Get.currentRoute != '/LoginPage') {
                  await Get.to(() => LoginPage(siteContext: widget.siteContext));
                }
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostPage(
                    siteContext: widget.siteContext,
                    topicId: t.id,
                    title: t.title,
                  ),
                ),
              );
            },
          );
        } else {
          return const Padding(
            padding: DesignTokens.paddingL,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
