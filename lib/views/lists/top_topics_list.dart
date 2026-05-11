import 'package:discourse_core/discourse_core.dart' show DiscourseTopicProxy;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';

import '../../theme/design_tokens.dart';
import '../listitems/topic_list_item.dart';
import '../post_page.dart';
import '../widgets/resettable_widget.dart';

/// Discourse Top periods. Matches the URL fragments
/// `/top/{period}.json` accepts. `all` collapses to plain `/top.json`.
enum TopPeriod { all, yearly, quarterly, monthly, weekly, daily }

extension on TopPeriod {
  String get apiName => name;
  String get label {
    switch (this) {
      case TopPeriod.all:
        return 'All';
      case TopPeriod.yearly:
        return 'Year';
      case TopPeriod.quarterly:
        return 'Quarter';
      case TopPeriod.monthly:
        return 'Month';
      case TopPeriod.weekly:
        return 'Week';
      case TopPeriod.daily:
        return 'Today';
    }
  }
}

/// Home tab — **Top** sub-segment. Backed by `/top.json` (and
/// `/top/{period}.json` when a period filter is active).
///
/// Renders a horizontal chip strip with the 6 periods Discourse
/// supports. Period switch resets the list + reloads. Same external
/// surface as `NewTopicsList` / `LatestTopicsList` so it slots into
/// `TopicListTab` without bespoke wiring.
class TopTopicsList extends StatefulWidget {
  final SiteContext siteContext;
  final bool isActive;
  const TopTopicsList(
      {Key? key, required this.siteContext, required this.isActive})
      : super(key: key);

  @override
  TopTopicsListState createState() => TopTopicsListState();
}

class TopTopicsListState extends FCStatefulWidget<TopTopicsList>
    with FCListStatefulWidget<TopTopicsList>, AutomaticKeepAliveClientMixin {
  final List<FCTopic> _topics = [];
  TopPeriod _period = TopPeriod.weekly; // sensible default — matches Discourse web
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
    if (widget.isActive) _load(reset: true);
  }

  @override
  void didUpdateWidget(covariant TopTopicsList oldWidget) {
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
      if (proxy is! DiscourseTopicProxy) {
        setState(() {
          _isLoading = false;
          _hasMore = false;
          _hasLoaded = true;
          _error = 'Top requires a Discourse forum.';
        });
        return;
      }
      final result = await proxy.getTopTopicsGlobalAsync(
        period: _period.apiName,
        page: reset ? 0 : _page + 1,
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

  void _switchPeriod(TopPeriod next) {
    if (next == _period) return;
    setState(() {
      _period = next;
      _topics.clear();
      _page = 0;
      _hasMore = true;
      _hasLoaded = false;
    });
    _load(reset: true);
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

  /// Period selector chip strip, rendered as the first widget in the
  /// parent's ListView so it scrolls with the topic list (rather than
  /// pinning at the top — Discourse web pins, but on mobile pinning
  /// would eat real estate from a short list).
  Widget _buildPeriodSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingL,
        vertical: DesignTokens.spacingS,
      ),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: TopPeriod.values.length,
          separatorBuilder: (_, __) =>
              const SizedBox(width: DesignTokens.spacingS),
          itemBuilder: (_, i) {
            final p = TopPeriod.values[i];
            final selected = p == _period;
            return ChoiceChip(
              label: Text(p.label),
              selected: selected,
              onSelected: (_) => _switchPeriod(p),
              labelStyle: TextStyle(
                color: selected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: selected
                    ? DesignTokens.fontWeightSemiBold
                    : DesignTokens.fontWeightNormal,
              ),
              selectedColor: colorScheme.primaryContainer,
              backgroundColor: colorScheme.surfaceContainerHighest
                  .withOpacity(DesignTokens.opacityMediumLow),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              ),
              showCheckmark: false,
            );
          },
        ),
      ),
    );
  }

  List<Widget> buildTopicItems() {
    final header = _buildPeriodSelector();
    if (!_hasLoaded || (_isLoading && _topics.isEmpty)) {
      return [header, const Center(child: CircularProgressIndicator())];
    }
    return [
      header,
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

  Widget? buildErrorOrNotSignedInWidget() {
    // Top is publicly visible on most forums — no signed-in gate.
    return null;
  }

  Widget? buildEmptyState() {
    if (!_hasLoaded || _isLoading) return null;
    if (_topics.isNotEmpty) return null;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spacingXL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_outlined,
              size: 48, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: DesignTokens.spacingM),
          Text(
            _error ??
                'No top topics in the ${_period.label.toLowerCase()} period.',
            style: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const SizedBox.shrink();
  }
}
