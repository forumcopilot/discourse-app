import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';
import '../listitems/topic_list_item.dart';
import '../post_page.dart';
import '../widgets/not_signed_in_view.dart';
import '../widgets/resettable_widget.dart';
import '../widgets/topic_list_skeleton.dart';

/// Home tab — **New** sub-segment. Backed by `/new.json` (Discourse-
/// native: topics created since your last visit + haven't dismissed).
///
/// Built with the same external surface as `LatestTopicsList` /
/// `UnreadTopicsList` so `TopicListTab` can wire it in without
/// refactoring the hidden IndexedStack pattern. Internally it uses
/// plain setState — no GetX controller — because the New feed is
/// simpler than Latest (no participated/subscribed cross-cuts) and
/// not shared across other screens.
class NewTopicsList extends StatefulWidget {
  final SiteContext siteContext;
  final bool isActive;
  const NewTopicsList(
      {Key? key, required this.siteContext, required this.isActive})
      : super(key: key);

  @override
  NewTopicsListState createState() => NewTopicsListState();
}

class NewTopicsListState extends FCStatefulWidget<NewTopicsList>
    with FCListStatefulWidget<NewTopicsList>, AutomaticKeepAliveClientMixin {
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
  void didUpdateWidget(covariant NewTopicsList oldWidget) {
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
      final proxy = SiteProxyFactory.getTopicProxy();
      final result = await proxy.getNewTopicAsync(
        reset ? 0 : _page * _pageSize,
        (reset ? 1 : _page + 1) * _pageSize - 1,
      );
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
    if (!widget.siteContext.isLoggedIn) {
      return NotSignedInView(
        siteContext: widget.siteContext,
        title:
            AppLocalizations.of(context)?.signInToViewUnreadTopics ??
                'Sign in to view new topics',
        message:
            'New topics show what was created since your last visit.',
        icon: Icons.fiber_new,
      );
    }
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
