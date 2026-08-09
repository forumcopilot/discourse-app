import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/models/entities/fc_forum.dart';
import 'package:forumcopilot_sdk/models/entities/fc_notification_level.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:discourse_ui/views/appbars/forum_topics_app_bar.dart';
import 'package:discourse_ui/views/lists/forum_topic_list.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities;
import 'package:discourse_ui/theme/design_tokens.dart';
import 'package:discourse_ui/views/new_topic_page.dart';
import 'package:discourse_ui/views/post_page.dart';
import 'package:get/get.dart';
import 'package:discourse_ui/views/widgets/forum_actions.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscourseSubscriptionProxy;
import 'package:discourse_ui/views/widgets/notification_level_sheet.dart';

class ForumTopicsPage extends StatefulWidget {
  final FCForum forum;
  final SiteContext siteContext;

  const ForumTopicsPage({
    super.key,
    required this.forum,
    required this.siteContext,
  });

  @override
  State<ForumTopicsPage> createState() => _ForumTopicsPageState();
}

class _ForumTopicsPageState extends State<ForumTopicsPage> {
  final ForumActions _forumActions = ForumActions();
  VoidCallback? _refreshCallback;

  @override
  void initState() {
    super.initState();
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

    // Open what was just created, as web does and as sending a PM already
    // did. Done here rather than inside the composer: the composer pops
    // itself on success, which would pop any route it pushed.
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

    if ((result == true || topicCreated) && _refreshCallback != null) {
      _refreshCallback!();
    }
  }

  Future<void> _handleSubscribe() async {
    if (!widget.siteContext.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please login to subscribe to forums',
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

    final subscriptionProxy = SiteProxyFactory.getSubscriptionProxy();
    if (subscriptionProxy is DiscourseSubscriptionProxy) {
      // Discourse-native picker: Watching / Watching First Post / Tracking
      // / Normal / Muted. The 'isSubscribed' field on the forum is binary
      // (>= Tracking) — we leave it for the next refresh to update.
      await NotificationLevelSheet.showForCategory(
        context: context,
        categoryId: widget.forum.id,
        currentLevel: widget.forum.isSubscribed
            ? FCNotificationLevel.tracking
            : FCNotificationLevel.normal,
        onChanged: () {
          if (!mounted) return;
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

  Future<void> _handleMarkRead() async {
    await _forumActions.markAllAsRead(context, widget.forum.id);
    if (_refreshCallback != null) {
      _refreshCallback!();
    }
  }

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
        // `/c/{id}/l/new.json` answers 403 to a guest, so it is only
        // offered to someone who can actually use it.
        if (widget.siteContext.isLoggedIn) _CategoryFilter.newTopics,
      ];

  _CategoryFilter _activeFilter = _CategoryFilter.latest;

  Widget _buildFilterTabs(BuildContext context) {
    final filters = _filters;
    // A lone tab is a label, not a choice.
    if (filters.length < 2) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingL),
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: DesignTokens.spacingS),
        itemBuilder: (context, i) {
          final f = filters[i];
          final selected = f == _activeFilter;
          return Center(
            child: ChoiceChip(
              label: Text(f.label),
              selected: selected,
              onSelected: (_) {
                if (selected) return;
                setState(() => _activeFilter = f);
              },
              labelStyle: TextStyle(
                color: selected
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ForumTopicsAppBar(
        title: widget.forum.name,
        forumId: widget.forum.id,
        onNewTopic: widget.siteContext.isLoggedIn && widget.forum.canPost ? _handleNewTopic : null,
        onSubscribe: widget.siteContext.isLoggedIn && widget.forum.canSubscribe ? _handleSubscribe : null,
        onMarkRead: widget.siteContext.isLoggedIn ? _handleMarkRead : null,
        isSubscribed: widget.forum.isSubscribed,
        showMarkRead: true,
        isLoggedIn: widget.siteContext.isLoggedIn,
        canPost: widget.forum.canPost,
        canSubscribe: widget.forum.canSubscribe,
      ),
      body: Column(
        children: [
          _buildFilterTabs(context),
          Expanded(
            child: ForumTopicList(
              siteContext: widget.siteContext,
              forum: widget.forum,
              showSubforumHeader: true,
              onRefreshAvailable: _onRefreshAvailable,
              filter: _activeFilter.route,
            ),
          ),
        ],
      ),
    );
  }
}


/// A category's topic feeds, mirroring web's tabs.
enum _CategoryFilter {
  latest('latest', 'Latest'),
  hot('hot', 'Hot'),
  newTopics('new', 'New');

  const _CategoryFilter(this.route, this.label);

  /// The `/c/{id}/l/{route}.json` segment.
  final String route;
  final String label;
}
