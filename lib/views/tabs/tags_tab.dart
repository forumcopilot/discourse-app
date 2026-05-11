import 'package:discourse_core/discourse_core.dart'
    show DiscourseTag, DiscourseTopicProxy;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';

import '../../theme/design_tokens.dart';
import '../tag_topics_page.dart';

/// Global Tags tab — lists every tag the current user can see, sorted
/// by topic count (most-used first). Tapping a tag drills into the
/// existing `TagTopicsPage` (which we already built in Phase 5.1).
///
/// Used in two places:
///   1. As a primary bottom-nav tab on `site_home_page.dart`.
///   2. Reachable from the Categories tab when the user wants to
///      browse-by-tag rather than browse-by-category.
///
/// Hides on non-Discourse forums by reporting "Tags require a Discourse
/// forum" rather than crashing — the proxy returns the wrong type when
/// run against an XF-shaped backend.
class TagsTab extends StatefulWidget {
  final SiteContext siteContext;
  final bool isActive;

  const TagsTab({
    super.key,
    required this.siteContext,
    this.isActive = true,
  });

  @override
  State<TagsTab> createState() => _TagsTabState();
}

class _TagsTabState extends State<TagsTab> with AutomaticKeepAliveClientMixin {
  final TextEditingController _filterController = TextEditingController();

  List<DiscourseTag> _allTags = const [];
  bool _loading = false;
  bool _loaded = false;
  String? _error;
  _SortMode _sort = _SortMode.byCount;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _filterController.addListener(() => setState(() {}));
    if (widget.isActive) {
      _load();
    }
  }

  @override
  void didUpdateWidget(covariant TagsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_loaded && !_loading) {
      _load();
    }
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final proxy = SiteProxyFactory.getTopicProxy();
    if (proxy is! DiscourseTopicProxy) {
      setState(() {
        _allTags = const [];
        _loaded = true;
        _error = 'Tags require a Discourse forum.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tags = await proxy.getAllTagsAsync();
      if (!mounted) return;
      setState(() {
        _allTags = tags;
        _loading = false;
        _loaded = true;
        if (tags.isEmpty) {
          _error = 'No tags yet on this forum.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _allTags = const [];
        _loading = false;
        _loaded = true;
        _error = '$e';
      });
    }
  }

  Future<void> _refresh() async {
    _loaded = false;
    await _load();
  }

  List<DiscourseTag> get _filteredTags {
    final q = _filterController.text.trim().toLowerCase();
    Iterable<DiscourseTag> base = _allTags;
    if (q.isNotEmpty) {
      base = base.where((t) =>
          t.name.toLowerCase().contains(q) ||
          (t.description?.toLowerCase().contains(q) ?? false));
    }
    final out = base.toList();
    switch (_sort) {
      case _SortMode.byCount:
        // Already sorted by count desc in the proxy; re-sort in case
        // the user just switched mode.
        out.sort((a, b) {
          final c = b.count.compareTo(a.count);
          if (c != 0) return c;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case _SortMode.alphabetical:
        out.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
    }
    return out;
  }

  void _openTag(DiscourseTag tag) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TagTopicsPage(
          siteContext: widget.siteContext,
          tag: tag.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: _refresh,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_loading && !_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _filteredTags;

    return CustomScrollView(
      slivers: [
        // Sticky controls row: search input + sort toggle.
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.spacingL,
              DesignTokens.spacingM,
              DesignTokens.spacingL,
              DesignTokens.spacingS,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _filterController,
                    decoration: InputDecoration(
                      hintText: 'Search tags…',
                      prefixIcon: Icon(Icons.search,
                          color: colorScheme.onSurfaceVariant, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      filled: true,
                      fillColor:
                          colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _filterController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 18),
                              onPressed: () => _filterController.clear(),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingS),
                IconButton(
                  icon: Icon(
                    _sort == _SortMode.byCount
                        ? Icons.bar_chart
                        : Icons.sort_by_alpha,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  tooltip: _sort == _SortMode.byCount
                      ? 'Sorted by topic count — tap to switch to A→Z'
                      : 'Sorted alphabetically — tap to switch to popularity',
                  onPressed: () => setState(() {
                    _sort = _sort == _SortMode.byCount
                        ? _SortMode.alphabetical
                        : _SortMode.byCount;
                  }),
                ),
              ],
            ),
          ),
        ),
        if (_allTags.isEmpty && _error != null)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingL),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.label_outline,
                        size: 48, color: colorScheme.onSurfaceVariant),
                    const SizedBox(height: DesignTokens.spacingM),
                    Text(
                      _error!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (filtered.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingL),
              child: Center(
                child: Text(
                  'No tags match "${_filterController.text}".',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final t = filtered[i];
                return _TagTile(tag: t, onTap: () => _openTag(t));
              },
              childCount: filtered.length,
            ),
          ),
      ],
    );
  }
}

enum _SortMode { byCount, alphabetical }

class _TagTile extends StatelessWidget {
  final DiscourseTag tag;
  final VoidCallback onTap;

  const _TagTile({required this.tag, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasDescription =
        tag.description != null && tag.description!.isNotEmpty;
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withOpacity(0.4),
              width: 0.5,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingL,
          vertical: DesignTokens.spacingM,
        ),
        child: Row(
          children: [
            Icon(Icons.tag, size: 18, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: DesignTokens.spacingS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tag.name,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasDescription) ...[
                    const SizedBox(height: 2),
                    Text(
                      tag.description!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: DesignTokens.spacingM),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _formatCount(tag.count),
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right,
                size: 18, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  String _formatCount(int n) {
    if (n < 1000) return n.toString();
    if (n < 10000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '${(n / 1000).floor()}k';
  }
}
