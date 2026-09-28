import 'dart:async';

import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/models/entities/fc_forum.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';
import 'package:forumcopilot_sdk/models/results/fc_topic_result.dart';
import 'package:discourse_ui/services/topic_tracking_service.dart';
import 'package:discourse_core/discourse_core.dart' show DiscourseTopicProxy;
import 'package:get/get.dart';
import 'package:discourse_ui/views/post_page.dart';
import 'package:discourse_ui/controllers/login_controller.dart';
import 'package:discourse_ui/views/login_page.dart';
import '../listitems/topic_list_item.dart';
import '../widgets/empty_state_view.dart';
import '../../theme/design_tokens.dart';
import '../../utils/error_message.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';
import 'package:discourse_ui/utils/app_navigation.dart';

class ForumTopicList extends StatefulWidget {
  final SiteContext siteContext;
  final FCForum forum;
  final void Function(VoidCallback)? onRefreshAvailable;

  /// Which Discourse category feed to show: `latest`, `new`, `hot`, …
  /// (`/c/{id}/l/{filter}.json`). Web puts these on tabs; the page above
  /// owns the tab strip and passes the choice down.
  final String filter;

  /// The page's header and its feed chips, as slivers above the topics in
  /// the same scroll view: the category's header collapses into its bar
  /// and the chips pin under it.
  final List<Widget> headerSlivers;

  /// Where a refresh's spinner appears: under the page's bar.
  final double refreshEdgeOffset;

  const ForumTopicList({
    super.key,
    required this.siteContext,
    required this.forum,
    this.onRefreshAvailable,
    this.filter = 'latest',
    this.headerSlivers = const [],
    this.refreshEdgeOffset = 0,
  });

  @override
  State<ForumTopicList> createState() => _ForumTopicListState();
}

class _ForumTopicListState extends State<ForumTopicList> {
  List<FCTopic> _allItems = [];
  int _currentTopicCount = 0;
  String? _error;
  bool _isLoading = true;
  final int _pageSize = 20;
  bool _hasMoreTopics = true;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  /// Fetches the category feed for [ForumTopicList.filter].
  ///
  /// `latest` goes through the SDK contract; anything else is
  /// Discourse-only, so it needs the concrete proxy — the SDK offers a
  /// category list and a category *top* list and nothing between.
  Future<FCTopicDataResult> _fetch(
      dynamic topicProxy, int startNum, int lastNum) async {
    if (widget.filter != 'latest' && topicProxy is DiscourseTopicProxy) {
      return topicProxy.getCategoryTopicsAsync(widget.forum.id, startNum,
          filter: widget.filter);
    }
    return topicProxy.getTopicAsync(widget.forum.id, startNum, lastNum);
  }

  @override
  void didUpdateWidget(covariant ForumTopicList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Switching tabs must refetch — the widget is reused, so without this
    // the new tab would keep showing the previous feed's topics.
    if (oldWidget.filter != widget.filter) {
      _currentTopicCount = 0;
      _hasMoreTopics = true;
      _loadTopics();
    }
  }

  @override
  void initState() {
    super.initState();
    AppLogger.debug('\n[ForumTopicList] Initializing for forum: ${widget.forum.name} (ID: ${widget.forum.id})');
    _scrollController.addListener(_onScroll);
    _loadTopics();
    widget.onRefreshAvailable?.call(_loadTopics);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8 && !_isLoadingMore && _hasMoreTopics) {
      _loadMoreTopics();
    }
  }

  Future<void> _loadTopics() async {
    // The chips' counts and the subcategories' "3 new", with the feed.
    unawaited(TopicTrackingService.refresh(widget.siteContext,
        maxAge: const Duration(seconds: 10)));
    AppLogger.debug('\n[ForumTopicList] Starting to load topics for forum: ${widget.forum.name}');
    AppLogger.debug('[ForumTopicList] Current state - Loading: $_isLoading, Error: $_error');

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      AppLogger.debug('[ForumTopicList] State updated - Loading started, Error cleared');

      final topicProxy = SiteProxyFactory.getTopicProxy();
      AppLogger.debug('[ForumTopicList] TopicProxy initialized');

      try {
        AppLogger.debug('[ForumTopicList] Calling getTopicAsync with params:');
        AppLogger.debug('  - forumId: ${widget.forum.id}');
        AppLogger.debug('  - startNum: 0');
        AppLogger.debug('  - lastNum: $_pageSize');
        AppLogger.debug('  - mode: TOPIC');

        List<FCTopic> allItems = []; // Clear the list before adding new items
        bool hasMoreTopics = false;

        // Check if user can view content in this forum
        final canViewContent = widget.forum.canViewContent;
        AppLogger.debug('[ForumTopicList] canViewContent: $canViewContent');

        // A parent category has topics too — its own and its
        // subcategories', as its page on the website lists them.
        if (canViewContent) {
          // Pinned topics head the list on Latest only. On Hot or New the
          // feed has its own ordering, so prepending pinned-by-top both
          // masks it and costs an extra /c/{id}/l/top.json — web does not
          // do it either. Only this section is skipped; the feed itself
          // below is always fetched.
          final topTopicData = widget.filter == 'latest'
              ? await topicProxy.getTopTopicAsync(widget.forum.id, 0, 19)
              : null;
          if (topTopicData != null && topTopicData.topics.isNotEmpty) {
            AppLogger.debug('[ForumTopicList] Adding ${topTopicData.topics.length} sticky topics');
            // Mark as sticky and convert to FCTopic
            for (final t in topTopicData.topics) {
              t.isStickySource = true;
            }
            var topTopicsList = topTopicData.topics;
            // Mark FCTopics as pinned
            for (final topic in topTopicsList) {
              topic.isPinned = true;
            }
            allItems.addAll(topTopicsList);
          }

          // Load regular topics
          final forumTopicData = await _fetch(topicProxy, 0, _pageSize);
          if (forumTopicData.topics.isNotEmpty) {
            AppLogger.debug('[ForumTopicList] Adding ${forumTopicData.topics.length} regular topics');
            // Dedupe by topic id: pinned topics also appear in the regular
            // list — the sticky/announcement section above wins.
            final pinnedIds = allItems.map((t) => t.id).toSet();
            var topicsList = forumTopicData.topics
                .where((t) => !pinnedIds.contains(t.id))
                .toList();
            allItems.addAll(topicsList);
            // Pagination offset tracks the server-side list, so count the
            // raw (pre-dedupe) page length.
            _currentTopicCount = forumTopicData.topics.length;
          }
          hasMoreTopics = forumTopicData.topics.length >= _pageSize;
        }
        AppLogger.debug('\n[ForumTopicList] Items loaded successfully:');
        AppLogger.debug('  - Total items: ${allItems.length}');

        if (mounted) {
          setState(() {
            _allItems = allItems;
            _isLoading = false;
            _hasMoreTopics = hasMoreTopics;
          });
          AppLogger.debug('[ForumTopicList] State updated - Loading completed');
          AppLogger.debug('  - Total items: ${_allItems.length}');
          AppLogger.debug('  - Has more topics: $_hasMoreTopics');
          AppLogger.debug('  - Loading state: $_isLoading');
        } else {
          AppLogger.debug('[ForumTopicList] Widget no longer mounted, state update skipped');
        }
      } catch (e, stackTrace) {
        AppLogger.debug('\n[ForumTopicList] Error during getTopicAsync:');
        AppLogger.debug('  - Error: $e');
        AppLogger.debug('  - Stack trace: $stackTrace');
        rethrow;
      }
    } catch (e) {
      AppLogger.debug('\n[ForumTopicList] Error handling:');
      AppLogger.debug('  - Error: $e');

      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
        AppLogger.debug('[ForumTopicList] State updated with error');
        AppLogger.debug('  - Error message: $_error');
        AppLogger.debug('  - Loading state: $_isLoading');
      } else {
        AppLogger.debug('[ForumTopicList] Widget no longer mounted, error state update skipped');
      }
    }
  }

  Future<void> _loadMoreTopics() async {
    if (_isLoadingMore || !_hasMoreTopics) return;

    // Don't load more topics if user cannot view content
    if (!widget.forum.canViewContent) return;

    AppLogger.debug('\n[ForumTopicList] Loading more topics');
    AppLogger.debug('  - Current topic count: ${_allItems.length}');

    setState(() => _isLoadingMore = true);

    try {
      final topicProxy = SiteProxyFactory.getTopicProxy();

      AppLogger.debug('[ForumTopicList] Calling getTopicAsync for more topics:');
      AppLogger.debug('  - Start num: $_currentTopicCount');
      AppLogger.debug('  - Last num: ${_currentTopicCount + _pageSize}');

      final moreTopics = await _fetch(
          topicProxy, _currentTopicCount, _currentTopicCount + _pageSize);

      if (mounted) {
        setState(() {
          // Add new topics to the _allItems list
          if (moreTopics.topics.isNotEmpty) {
            // Dedupe by topic id against what's already shown (pinned
            // topics resurface in paginated regular pages).
            final existingIds = _allItems.map((t) => t.id).toSet();
            var topicsList = moreTopics.topics
                .where((t) => !existingIds.contains(t.id))
                .toList();
            _allItems.addAll(topicsList);
            // Offset tracks the server-side list: count the raw page length.
            _currentTopicCount += moreTopics.topics.length;
          }

          _hasMoreTopics = moreTopics.topics.length >= _pageSize;
          _isLoadingMore = false;
        });

        AppLogger.debug('\n[ForumTopicList] More topics loaded:');
        AppLogger.debug('  - New topics count: ${moreTopics.topics.length}');
        AppLogger.debug('  - Total items now: ${_allItems.length}');
        AppLogger.debug('  - Has more topics: $_hasMoreTopics');
      }
    } catch (e) {
      AppLogger.debug('\n[ForumTopicList] Error loading more topics:');
      AppLogger.debug('  - Error: $e');

      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }



  Future<void> _openTopic(FCTopic topic, {bool announcement = false}) async {
    if (!widget.siteContext.isLoggedIn) {
      if (!Get.isRegistered<DiscourseLoginController>()) {
        Get.put(DiscourseLoginController());
      }
      final loginController = Get.find<DiscourseLoginController>();
      final loginResult =
          await loginController.attemptAutomaticLogin(widget.siteContext);
      if (!loginResult.success &&
          loginResult.hadCredentials &&
          Get.currentRoute != '/LoginPage') {
        await LoginPage.open(widget.siteContext);
      }
    }
    AppNavigation.pushGlobal(PostPage(
      siteContext: widget.siteContext,
      topicId: topic.id,
      title: topic.title,
      isAnnouncement: announcement,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    List<Widget> content;
    if (_isLoading) {
      content = const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    } else if (_error != null) {
      // The category's header and its feed chips stay above the error: a
      // feed that fails (say Hot) can be switched away from without
      // leaving the category.
      content = [
        SliverToBoxAdapter(
          child: EmptyStateView.error(
            message: describeError(_error, context: context),
            onRetry: _loadTopics,
          ),
        ),
      ];
    } else {
      final topics = _allItems;
      final canViewContent = widget.forum.canViewContent;
      final announcements =
          topics.where((topic) => topic.isAnnouncement == true).toList();
      final stickyTopics = topics
          .where((topic) => topic.isPinned == true && topic.isAnnouncement != true)
          .toList();
      final regularTopics = topics
          .where((topic) => topic.isAnnouncement != true && topic.isPinned != true)
          .toList();
      TopicListItem row(FCTopic topic, {bool announcement = false}) =>
          TopicListItem(
            // Inside a category — its header already names it.
            showCategory: false,
            siteContext: widget.siteContext,
            topic: topic,
            topicIcon: announcement ? Icons.campaign_outlined : null,
            onTap: () => _openTopic(topic, announcement: announcement),
          );
      final rows = <Widget>[
        if (!canViewContent)
          Padding(
            padding: DesignTokens.paddingL,
            child: Container(
              padding: DesignTokens.paddingM,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: colorScheme.onSurfaceVariant, size: 20),
                  const SizedBox(width: DesignTokens.spacingM),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.noPermissionToViewSubforum,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ),
        // An empty New or Unread feed is a caught-up reader, not an empty
        // category: the Home tab's words, not "No discussions yet".
        if (topics.isEmpty && canViewContent)
          switch (widget.filter) {
            'new' => EmptyStateView(
                icon: Icons.fiber_new,
                message: AppLocalizations.of(context)!.noNewTopicsSinceLastVisit,
              ),
            'unread' => EmptyStateView(
                icon: Icons.inbox_rounded,
                message: AppLocalizations.of(context)!.youAreAllCaughtUp,
                hint: AppLocalizations.of(context)!.thereAreNoUnreadTopics,
              ),
            _ => EmptyStateView(
                icon: Icons.forum_outlined,
                message: AppLocalizations.of(context)!.noDiscussionsYet,
              ),
          },
        for (final t in announcements) row(t, announcement: true),
        for (final t in stickyTopics) row(t),
        for (final t in regularTopics) row(t),
        if (_hasMoreTopics)
          const Padding(
            padding: DesignTokens.paddingS,
            child: Center(child: CircularProgressIndicator()),
          ),
        // Room for the category page's New Topic button, so the last
        // topic can scroll clear of it.
        const SizedBox(height: 88),
      ];
      content = [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => rows[i],
            childCount: rows.length,
          ),
        ),
      ];
    }

    return RefreshIndicator(
      onRefresh: _loadTopics,
      edgeOffset: widget.refreshEdgeOffset,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          ...widget.headerSlivers,
          ...content,
        ],
      ),
    );
  }

  @override
  void dispose() {
    AppLogger.debug('\n[ForumTopicList] Disposing widget for forum: ${widget.forum.name}');
    _scrollController.dispose();
    super.dispose();
  }
}
