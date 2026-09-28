import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/models/entities/fc_forum.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:discourse_ui/views/appbars/forum_topics_app_bar.dart';
import 'package:discourse_ui/views/lists/forum_topic_list.dart';
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

  @override
  State<ForumTopicsPage> createState() => _ForumTopicsPageState();
}

class _ForumTopicsPageState extends State<ForumTopicsPage> {
  VoidCallback? _refreshCallback;

  @override
  void initState() {
    super.initState();
    // The counts on the New and Unread chips.
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => TopicTrackingService.refresh(widget.siteContext));
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
        // Read by the sheet: a guess from the subscribed flag showed
        // Watching as Tracking and Muted as Normal.
        currentLevel: null,
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

  Widget? _buildFilterTabs(BuildContext context) {
    final filters = _filters;
    // A lone tab is a label, not a choice.
    if (filters.length < 2) return null;
    final l10n = AppLocalizations.of(context)!;
    String label(_CategoryFilter f, DiscourseTopicCounts? counts) {
      final n = switch (f) {
        _CategoryFilter.newTopics => counts?.newTopics ?? 0,
        _CategoryFilter.unread => counts?.unreadTopics ?? 0,
        _ => 0,
      };
      return switch (f) {
        _CategoryFilter.newTopics when n > 0 => l10n.filterNewWithCount(n),
        _CategoryFilter.unread when n > 0 => l10n.filterUnreadWithCount(n),
        _CategoryFilter.unread => l10n.unread,
        _ => f.label,
      };
    }

    Widget build(DiscourseTopicCounts? counts) {
      final chips = FilterChipBar(
        options: [
          for (final f in filters) FilterChipOption(label: label(f, counts)),
        ],
        selectedIndex: filters.indexOf(_activeFilter),
        onSelected: (i) => setState(() => _activeFilter = filters[i]),
      );
      // Dismiss sits above the New and Unread feeds, as on Home; hidden
      // once the counts say there is nothing to dismiss.
      final kind = switch (_activeFilter) {
        _CategoryFilter.newTopics => DismissKind.newTopics,
        _CategoryFilter.unread => DismissKind.unread,
        _ => null,
      };
      final remaining = switch (kind) {
        DismissKind.newTopics => counts?.newTopics,
        DismissKind.unread => counts?.unreadTopics,
        null => 0,
      };
      if (kind == null || remaining == 0) return chips;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          chips,
          DismissTopicsBar(
            siteContext: widget.siteContext,
            kind: kind,
            categoryId: int.tryParse(widget.forum.id),
            onDismissed: () => _refreshCallback?.call(),
          ),
        ],
      );
    }

    if (!widget.siteContext.isLoggedIn) return build(null);
    final tracking = DiscourseTopicTracking.forSite(widget.siteContext);
    return ListenableBuilder(
      listenable: tracking,
      builder: (context, _) =>
          build(tracking.counts(categoryIds: _categoryIds)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ForumTopicsAppBar(
        title: widget.forum.name,
        forumId: widget.forum.id,
        onSubscribe: widget.siteContext.isLoggedIn && widget.forum.canSubscribe ? _handleSubscribe : null,
        onMarkRead: widget.siteContext.isLoggedIn ? _handleMarkRead : null,
        isSubscribed: widget.forum.isSubscribed,
        showMarkRead: true,
        isLoggedIn: widget.siteContext.isLoggedIn,
        canPost: widget.forum.canPost,
        canSubscribe: widget.forum.canSubscribe,
      ),
      // The filter bar is handed to the list rather than stacked above it,
      // so it sits *under* the category header card and scrolls with the
      // content — the header is the first item inside that list.
      body: TopicTrackingLive(
        siteContext: widget.siteContext,
        active: true,
        child: ForumTopicList(
          siteContext: widget.siteContext,
          forum: widget.forum,
          showSubforumHeader: true,
          onRefreshAvailable: _onRefreshAvailable,
          filter: _activeFilter.route,
          headerTrailing: _buildFilterTabs(context),
        ),
      ),
      // Where a thumb is, in the forum's accent (the app's FAB theme), and
      // always reachable — it used to sit in the category header, which
      // scrolls away with the first topics.
      floatingActionButton:
          widget.siteContext.isLoggedIn && widget.forum.canPost
              ? FloatingActionButton.extended(
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
  latest('latest', 'Latest'),
  hot('hot', 'Hot'),
  newTopics('new', 'New'),
  unread('unread', 'Unread');

  const _CategoryFilter(this.route, this.label);

  /// The `/c/{id}/l/{route}.json` segment.
  final String route;
  final String label;
}
