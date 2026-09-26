import 'package:flutter/material.dart';
import 'package:discourse_core/discourse_core.dart' show DiscourseTagProxy;
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_tag.dart';

import '../../theme/design_tokens.dart';
import '../tag_topics_page.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/notification_level_sheet.dart';
import '../../utils/error_message.dart';
import '../../l10n/generated/app_localizations.dart';

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

  List<FCTag> _allTags = const [];
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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await SiteProxyService.getTagProxy().getAllTagsAsync();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loaded = true;
        if (!result.result) {
          _allTags = const [];
          _error = result.resultText?.isNotEmpty == true
              ? result.resultText
              : 'Failed to load tags.';
          return;
        }
        // An empty list is not an error: _buildBody shows it as the
        // empty state, and keeps the error tone and Retry for failures.
        _allTags = result.items;
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

  List<FCTag> get _filteredTags {
    final q = _filterController.text.trim().toLowerCase();
    Iterable<FCTag> base = _allTags;
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

  void _openTag(FCTag tag) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TagTopicsPage(
          siteContext: widget.siteContext,
          tag: tag.name,
        ),
      ),
    );
  }

  /// Whether the per-row notification bell should render: needs a signed-in
  /// user and the Discourse tag proxy (tag watching is Discourse-native).
  bool get _canManageTagNotifications =>
      widget.siteContext.isLoggedIn &&
      SiteProxyService.getTagProxy() is DiscourseTagProxy;

  Future<void> _showTagNotificationSheet(FCTag tag) async {
    await NotificationLevelSheet.showForTag(
      context: context,
      tagName: tag.name,
      onChanged: (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.tagNotificationLevelUpdated(tag.name)),
          ),
        );
      },
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
                          color: colorScheme.onSurfaceVariant),
                      // The app's search bar: a filled pill, 56dp high.
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHigh,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(28)),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(28)),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(28)),
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
            child: EmptyStateView.error(message: describeError(_error, context: context), onRetry: _refresh),
          )
        else if (_allTags.isEmpty && _loaded)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateView(
              icon: Icons.label_outline,
              message: 'No tags yet on this forum.',
            ),
          )
        else if (filtered.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateView(
              icon: Icons.search_off,
              message: AppLocalizations.of(context)!.noTagsMatch(_filterController.text),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final t = filtered[i];
                return _TagTile(
                  tag: t,
                  onTap: () => _openTag(t),
                  onBellTap: _canManageTagNotifications
                      ? () => _showTagNotificationSheet(t)
                      : null,
                );
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
  final FCTag tag;
  final VoidCallback onTap;

  /// When non-null, renders a small trailing bell that opens the tag
  /// notification-level sheet (logged-in Discourse only).
  final VoidCallback? onBellTap;

  const _TagTile({required this.tag, required this.onTap, this.onBellTap});

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
              color: colorScheme.outlineVariant.withValues(alpha: DesignTokens.opacityDivider),
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
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
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
            if (onBellTap != null) ...[
              const SizedBox(width: 2),
              IconButton(
                icon: Icon(Icons.notifications_none,
                    size: 18, color: colorScheme.onSurfaceVariant),
                tooltip: 'Notification level',
                visualDensity: VisualDensity.compact,
                onPressed: onBellTap,
              ),
            ],
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
