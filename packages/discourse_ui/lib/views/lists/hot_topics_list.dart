import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:discourse_core/discourse_core.dart' show DiscourseTopicProxy;
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';

import '../../theme/design_tokens.dart';
import '../listitems/topic_list_item.dart';
import '../tabs/topic_list_tab.dart';
import '../post_page.dart';
import '../widgets/resettable_widget.dart';
import '../widgets/topic_list_skeleton.dart';

/// Home tab — **Hot** sub-segment. Backed by `/hot.json` (Discourse-
/// native: a recency-weighted activity ranking, distinct from Top's
/// per-period like count).
///
/// Only mounted when `/site.json`'s `top_menu_items` lists "hot" — a
/// forum can turn the route off, and it 404s when it has.
///
/// Built with the same external surface as `LatestTopicsList` /
/// `UnreadTopicsList` so `TopicListTab` can wire it in without
/// refactoring the hidden IndexedStack pattern. Internally it uses
/// plain setState — no GetX controller — because the New feed is
/// simpler than Latest (no participated/subscribed cross-cuts) and
/// not shared across other screens.
class HotTopicsList extends StatefulWidget {
  final SiteContext siteContext;
  final bool isActive;
  const HotTopicsList(
      {Key? key, required this.siteContext, required this.isActive})
      : super(key: key);

  @override
  HotTopicsListState createState() => HotTopicsListState();
}

class HotTopicsListState extends FCStatefulWidget<HotTopicsList>
    with FCListStatefulWidget<HotTopicsList>, AutomaticKeepAliveClientMixin {
  final List<FCTopic> _topics = [];
  int _page = 0;
  bool _hasLoaded = false;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  static const int _pageSize = 30;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _load(reset: true);
    }
  }

  @override
  void didUpdateWidget(covariant HotTopicsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive && !_hasLoaded) {
      _load(reset: true);
    }
  }

  Future<void> _load({required bool reset}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      if (reset) _error = null;
    });
    try {
      // Discourse-only route, so the concrete proxy rather than the
      // SDK interface — see DiscourseTopicProxy.getHotTopicsAsync for why
      // Hot is not folded into Top.
      final proxy = SiteProxyFactory.getTopicProxy() as DiscourseTopicProxy;
      final result =
          await proxy.getHotTopicsAsync(reset ? 0 : _page * _pageSize);
      if (!mounted) return;
      setState(() {
        if (reset) {
          _topics.clear();
          _page = 0;
          _hasMore = true;
        }
        if (result.result) {
          _topics.addAll(result.topics);
          if (result.topics.length < _pageSize) _hasMore = false;
          _page++;
          _error = null;
        } else {
          _error = result.resultText;
          _hasMore = false;
        }
        _hasLoaded = true;
        _isLoading = false;
      });
      // TopicListTab renders our rows via buildTopicItems(), so our own
      // setState is not enough — the parent has to rebuild too, or the
      // skeleton stays up until something else happens to rebuild it.
      // Same hand-off LatestTopicsList and UnreadTopicsList use.
      if (mounted) {
        context
            .findAncestorStateOfType<TopicListTabState>()
            ?.notifyDataLoaded();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _hasMore = false;
        _hasLoaded = true;
        _isLoading = false;
      });
    }
  }

  @override
  void resetList() {
    setState(() {
      _topics.clear();
      _page = 0;
      _hasMore = true;
      _hasLoaded = false;
      _error = null;
    });
    if (widget.isActive) _load(reset: true);
  }

  @override
  Future<void> refreshList() => _load(reset: true);

  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;
    await _load(reset: false);
  }

  bool get hasMoreItems => _hasMore;

  /// Required by TopicListTab — returns the rendered topic rows so
  /// the parent ListView can splice them in alongside the header.
  List<Widget> buildTopicItems() {
    if (!_hasLoaded || (_isLoading && _topics.isEmpty)) {
      return [const TopicListSkeleton(shrinkWrap: true)];
    }
    return [
      ..._topics.map((t) => TopicListItem(
            siteContext: widget.siteContext,
            topic: t,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PostPage(
                    siteContext: widget.siteContext,
                    topicId: t.id,
                    title: t.title,
                    forumId: t.forumId,
                  ),
                ),
              );
            },
          )),
      if (_hasMore && _topics.isNotEmpty)
        const Padding(
          padding: EdgeInsets.all(DesignTokens.spacingL),
          child: Center(child: CircularProgressIndicator()),
        ),
    ];
  }

  /// Required by TopicListTab — null = no error, otherwise return a
  /// not-signed-in / generic-error widget that's swapped in instead
  /// of the list.
  Widget? buildErrorOrNotSignedInWidget() {
    // No sign-in gate, unlike New/Unread: /hot.json is a public ranking
    // and a guest can read it, so gating would hide a working list.
    return null;
  }

  Widget? buildEmptyState() {
    if (!_hasLoaded || _isLoading) return null;
    if (_topics.isNotEmpty) return null;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fiber_new,
                size: 48, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: DesignTokens.spacingM),
            Text(
              _error ?? 'No new topics since your last visit.',
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Hidden state holder — TopicListTab renders the rows via
    // buildTopicItems(). Return a no-op widget; the parent's Stack
    // positions this off-screen anyway.
    return const SizedBox.shrink();
  }
}
