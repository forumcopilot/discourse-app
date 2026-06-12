import 'package:flutter/material.dart';
import 'package:forumcopilot_flutter/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';

import '../core/logging/app_logger.dart';
import '../theme/design_tokens.dart';
import 'listitems/topic_list_item.dart';
import 'post_page.dart';

/// Tag-filtered topic list. Reachable from a tappable tag chip in the
/// Latest tab; hits Discourse's `/tag/{name}.json` endpoint.
class TagTopicsPage extends StatefulWidget {
  final SiteContext siteContext;
  final String tag;

  const TagTopicsPage({
    super.key,
    required this.siteContext,
    required this.tag,
  });

  @override
  State<TagTopicsPage> createState() => _TagTopicsPageState();
}

class _TagTopicsPageState extends State<TagTopicsPage> {
  static const int _pageSize = 30;

  final List<FCTopic> _topics = [];
  final ScrollController _scrollController = ScrollController();
  int _page = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading &&
        _hasMore) {
      _load(reset: false);
    }
  }

  Future<void> _load({required bool reset}) async {
    if (reset) {
      _topics.clear();
      _page = 0;
      _hasMore = true;
      _error = null;
    }
    setState(() => _isLoading = true);
    try {
      final result = await SiteProxyService.getTagProxy()
          .getTopicsByTagAsync(widget.tag, page: _page);
      if (!mounted) return;
      setState(() {
        if (result.result) {
          _topics.addAll(result.topics);
          if (result.topics.length < _pageSize) _hasMore = false;
          _page++;
        } else {
          _error = (result.resultText?.isEmpty ?? true) ? 'Failed to load' : result.resultText;
          _hasMore = false;
        }
        _isLoading = false;
      });
    } catch (e, st) {
      AppLogger.error('TagTopicsPage load failed', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  Future<void> _refresh() => _load(reset: true);

  void _openTopic(FCTopic topic) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostPage(
          siteContext: widget.siteContext,
          topicId: topic.id,
          title: topic.title,
          forumId: topic.forumId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.tag, size: 18, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(widget.tag),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _buildBody(textTheme, colorScheme),
      ),
    );
  }

  Widget _buildBody(TextTheme textTheme, ColorScheme colorScheme) {
    if (_topics.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_topics.isEmpty && _error != null) {
      return ListView(
        padding: const EdgeInsets.all(DesignTokens.spacingL),
        children: [
          Center(
            child: Text(
              _error!,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }
    if (_topics.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(DesignTokens.spacingL),
        children: [
          Center(
            child: Text(
              'No topics tagged "${widget.tag}"',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      controller: _scrollController,
      itemCount: _topics.length + (_hasMore || _isLoading ? 1 : 0),
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: colorScheme.outlineVariant.withOpacity(DesignTokens.opacityDivider),
      ),
      itemBuilder: (context, index) {
        if (index == _topics.length) {
          return const Padding(
            padding: EdgeInsets.all(DesignTokens.spacingL),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final topic = _topics[index];
        return TopicListItem(
          siteContext: widget.siteContext,
          topic: topic,
          onTap: () => _openTopic(topic),
        );
      },
    );
  }
}
