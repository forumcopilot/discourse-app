import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/models/entities/fc_forum.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';
import 'package:forumcopilot_sdk/models/results/fc_topic_result.dart';
import 'package:discourse_core/discourse_core.dart' show DiscourseTopicProxy;
import 'package:get/get.dart';
import 'package:discourse_ui/utils/forum_navigation.dart';
import 'package:discourse_ui/views/post_page.dart';
import 'package:discourse_ui/views/new_topic_page.dart';
import 'package:discourse_ui/controllers/login_controller.dart';
import 'package:discourse_ui/views/login_page.dart';
import '../listitems/topic_list_item.dart';
import '../listitems/forum_list_item.dart';
import '../widgets/subforum_header_widget.dart';
import '../../theme/design_tokens.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';

class ForumTopicList extends StatefulWidget {
  final SiteContext siteContext;
  final FCForum forum;
  final bool showSubforumHeader;
  final void Function(VoidCallback)? onRefreshAvailable;

  /// Which Discourse category feed to show: `latest`, `new`, `hot`, …
  /// (`/c/{id}/l/{filter}.json`). Web puts these on tabs; the page above
  /// owns the tab strip and passes the choice down.
  final String filter;

  /// Rendered directly beneath the subforum header, inside the scroll
  /// view. The category's filter chips live here so they sit under the
  /// header card rather than floating above it.
  final Widget? headerTrailing;

  const ForumTopicList({
    super.key,
    required this.siteContext,
    required this.forum,
    this.showSubforumHeader = false,
    this.onRefreshAvailable,
    this.filter = 'latest',
    this.headerTrailing,
  });

  @override
  State<ForumTopicList> createState() => _ForumTopicListState();
}

class _ForumTopicListState extends State<ForumTopicList> {
  List<FCTopic> _allItems = [];
  List<FCForum> _childForums = [];
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
        List<FCForum> childForums = []; // Separate list for child forums

        // Add child forums if they exist
        if (widget.forum.childForums.isNotEmpty) {
          AppLogger.debug('[ForumTopicList] Adding ${widget.forum.childForums.length} child forums');
          childForums.addAll(widget.forum.childForums);
        }
        bool hasMoreTopics = false;

        // Check if user can view content in this forum
        final canViewContent = widget.forum.canViewContent;
        AppLogger.debug('[ForumTopicList] canViewContent: $canViewContent');

        if (!widget.forum.isSubForumContainer && canViewContent) {
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
            _childForums = childForums;
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

  Future<void> _handleNewTopic() async {
    if (!widget.siteContext.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please login to create a new topic',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          margin: const EdgeInsets.all(8),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    var topicCreated = false;
    String? newTopicId;
    var newTopicTitle = '';
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewTopicPage(
          siteContext: widget.siteContext,
          forumId: widget.forum.id,
          forumName: widget.forum.name,
          onTopicCreated: (topicId, title) {
            topicCreated = true;
            if (topicId.isNotEmpty) {
              newTopicId = topicId;
              newTopicTitle = title;
            }
          },
        ),
      ),
    );

    if (result == true || topicCreated) {
      _loadTopics();
    }

    // Open what was just created, as web does. This list owns the header's
    // New Topic button, so the navigation belongs here as well as on the
    // page's app-bar action — the two entry points are separate.
    if (newTopicId != null && mounted) {
      await Get.to(() => PostPage(
            siteContext: widget.siteContext,
            topicId: newTopicId!,
            // The topic's title, not the category's — the first post
            // renders whatever is passed here as its heading.
            title: newTopicTitle,
            forumId: widget.forum.id,
          ));
    }
  }

  Future<void> _handleSubscription(String forumId, bool subscribe) async {
    // Check if user is logged in before proceeding with subscription
    if (!widget.siteContext.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please login to ${subscribe ? 'subscribe to' : 'unsubscribe from'} forums',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          margin: const EdgeInsets.all(8),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      final subscriptionProxy = SiteProxyFactory.getSubscriptionProxy();

      if (subscribe) {
        await subscriptionProxy.subscribeForumAsync(forumId, 1); // mode 1 for subscribe
      } else {
        await subscriptionProxy.unsubscribeForumAsync(forumId);
      }

      // Update the forum's subscription status in the list
      setState(() {
        for (var forum in _allItems) {
          if (forum is FCForum && forum.id == forumId) {
            forum.isSubscribed = subscribe;
          }
        }
      });
    } catch (e) {
      AppLogger.debug('[ForumTopicList] Error handling subscription: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading content: $_error',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.error),
            ),
            SizedBox(height: DesignTokens.spacingL),
            FilledButton(
              onPressed: _loadTopics,
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
              child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
            ),
          ],
        ),
      );
    }

    // Use separate lists for forums and topics
    final forums = _childForums;
    final topics = _allItems;
    final canViewContent = widget.forum.canViewContent;

    // Separate topics into different categories
    final announcements = topics.where((topic) => topic.isAnnouncement == true).toList();
    final stickyTopics = topics.where((topic) => topic.isPinned == true && topic.isAnnouncement != true).toList();
    final regularTopics = topics.where((topic) => topic.isAnnouncement != true && topic.isPinned != true).toList();

    return RefreshIndicator(
      onRefresh: _loadTopics,
      child: ListView(
        controller: _scrollController,
        children: [
          // Subforum header (icon, name, description) - scrolls with content
          if (widget.showSubforumHeader)
            SubforumHeaderWidget(
              forum: widget.forum,
              siteContext: widget.siteContext,
              onNewTopic: _handleNewTopic,
            ),
          if (widget.headerTrailing != null) widget.headerTrailing!,
          // Show permission message if user cannot view content
          if (!canViewContent)
            Padding(
              padding: DesignTokens.paddingL,
              child: Container(
                padding: DesignTokens.paddingM,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: DesignTokens.spacingM),
                    Expanded(
                      child: Text(
                        'You do not have permission to view topics in this subforum.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // If there are no forums and no topics, show empty state
          if (forums.isEmpty && topics.isEmpty && canViewContent)
            Padding(
              padding: DesignTokens.paddingXXL,
              child: Center(
                child: Text(
                  'No discussions yet.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          if (forums.isNotEmpty) ...[
            ...forums.map((forum) => ForumListItem(
                  siteContext: widget.siteContext,
                  forum: forum,
                  onSubscriptionChanged: (subscribe) => _handleSubscription(forum.id.isEmpty ? "0" : forum.id, subscribe),
                  onTap: () {
                    pushForumOrLinkForum(context, forum, widget.siteContext);
                  },
                )),
            // Separator between Forums and Topics
            if (announcements.isNotEmpty || stickyTopics.isNotEmpty || regularTopics.isNotEmpty)
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant.withValues(alpha: DesignTokens.opacityLow),
                ),
              ),
          ],
          if (announcements.isNotEmpty) ...[
            ...announcements.map((topic) => TopicListItem(
                  siteContext: widget.siteContext,
                  topic: topic,
                  topicIcon: Icons.campaign_outlined,
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
                    Get.to(() => PostPage(
                          siteContext: widget.siteContext,
                          topicId: topic.id,
                          title: topic.title,
                          isAnnouncement: true,
                        ));
                  },
                )),
          ],
          if (stickyTopics.isNotEmpty) ...[
            ...stickyTopics.map((topic) => TopicListItem(
                  siteContext: widget.siteContext,
                  topic: topic,
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
                    Get.to(() => PostPage(siteContext: widget.siteContext, topicId: topic.id, title: topic.title));
                  },
                )),
          ],
          if (regularTopics.isNotEmpty) ...[
            ...regularTopics.map((topic) => TopicListItem(
                  siteContext: widget.siteContext,
                  topic: topic,
                  topicIcon: null,
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
                    Get.to(() => PostPage(siteContext: widget.siteContext, topicId: topic.id, title: topic.title));
                  },
                )),
          ],
          if (_hasMoreTopics)
            const Padding(
              padding: DesignTokens.paddingS,
              child: Center(child: CircularProgressIndicator()),
            ),
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
