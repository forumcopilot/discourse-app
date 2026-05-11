import 'package:flutter/material.dart';
import 'package:forumcopilot_flutter/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_directory_item.dart';

import '../theme/design_tokens.dart';
import 'user_profile_page.dart';
import 'widgets/empty_state_view.dart';
import 'widgets/simple_list_app_bar.dart';
import 'widgets/trust_level_chip.dart';

/// Phase 5.18c-1 — the Discourse Users directory.
///
/// Backed by `/directory_items.json` via
/// `DiscourseUserProxy.getDirectoryItemsAsync`. The directory rows
/// show each user's username + avatar + the currently-selected sort
/// metric. The user picks the metric (likes received, posts, etc.)
/// and the period (all-time, year, month, week, day) via two
/// horizontal `ChoiceChip` strips at the top; changing either
/// re-fetches from page 1.
///
/// Tapping a row drills into the existing `UserProfilePage`. The
/// page also supports infinite scroll (loads next page when the
/// list is scrolled near its end).
class UsersDirectoryPage extends StatefulWidget {
  final SiteContext siteContext;

  const UsersDirectoryPage({super.key, required this.siteContext});

  @override
  State<UsersDirectoryPage> createState() => _UsersDirectoryPageState();
}

enum _DirectoryPeriod { all, yearly, quarterly, monthly, weekly, daily }

extension _DirectoryPeriodX on _DirectoryPeriod {
  String get label {
    switch (this) {
      case _DirectoryPeriod.all:
        return 'All';
      case _DirectoryPeriod.yearly:
        return 'Year';
      case _DirectoryPeriod.quarterly:
        return 'Quarter';
      case _DirectoryPeriod.monthly:
        return 'Month';
      case _DirectoryPeriod.weekly:
        return 'Week';
      case _DirectoryPeriod.daily:
        return 'Day';
    }
  }

  String get apiName {
    switch (this) {
      case _DirectoryPeriod.all:
        return 'all';
      case _DirectoryPeriod.yearly:
        return 'yearly';
      case _DirectoryPeriod.quarterly:
        return 'quarterly';
      case _DirectoryPeriod.monthly:
        return 'monthly';
      case _DirectoryPeriod.weekly:
        return 'weekly';
      case _DirectoryPeriod.daily:
        return 'daily';
    }
  }
}

enum _DirectoryOrder { likesReceived, postCount, topicCount, daysVisited }

extension _DirectoryOrderX on _DirectoryOrder {
  String get label {
    switch (this) {
      case _DirectoryOrder.likesReceived:
        return 'Likes';
      case _DirectoryOrder.postCount:
        return 'Posts';
      case _DirectoryOrder.topicCount:
        return 'Topics';
      case _DirectoryOrder.daysVisited:
        return 'Active';
    }
  }

  /// Matches Discourse's `order` query param.
  String get apiName {
    switch (this) {
      case _DirectoryOrder.likesReceived:
        return 'likes_received';
      case _DirectoryOrder.postCount:
        return 'post_count';
      case _DirectoryOrder.topicCount:
        return 'topic_count';
      case _DirectoryOrder.daysVisited:
        return 'days_visited';
    }
  }

  IconData get icon {
    switch (this) {
      case _DirectoryOrder.likesReceived:
        return Icons.favorite_outline;
      case _DirectoryOrder.postCount:
        return Icons.forum_outlined;
      case _DirectoryOrder.topicCount:
        return Icons.topic_outlined;
      case _DirectoryOrder.daysVisited:
        return Icons.event_available_outlined;
    }
  }
}

class _UsersDirectoryPageState extends State<UsersDirectoryPage> {
  final ScrollController _scrollController = ScrollController();
  final List<FCDirectoryItem> _items = [];
  _DirectoryPeriod _period = _DirectoryPeriod.all;
  _DirectoryOrder _order = _DirectoryOrder.likesReceived;
  int _page = 1;
  bool _loading = false;
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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loading) return;
    // Pre-fetch when within 400px of the bottom — typical infinite-
    // scroll buffer; keeps the spinner from showing during normal
    // dragging.
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      _load(reset: false);
    }
  }

  Future<void> _load({required bool reset}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      if (reset) _error = null;
    });
    try {
      final fetchedPage = reset ? 1 : _page + 1;
      final result = await SiteProxyService.getUserProxy()
          .getDirectoryItemsAsync(
        _period.apiName,
        _order.apiName,
        fetchedPage,
      );
      if (!mounted) return;
      setState(() {
        if (reset) {
          _items.clear();
          _page = 1;
        }
        if (!result.result) {
          _error = result.resultText?.isNotEmpty == true
              ? result.resultText
              : 'Failed to load directory.';
          _hasMore = false;
        } else if (result.items.isEmpty) {
          _hasMore = false;
        } else {
          _items.addAll(result.items);
          _page = fetchedPage;
          // Discourse returns 50 per page by default; anything less
          // is the last page.
          if (result.items.length < 50) _hasMore = false;
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
        _hasMore = false;
      });
    }
  }

  void _setPeriod(_DirectoryPeriod p) {
    if (_period == p) return;
    setState(() {
      _period = p;
      _hasMore = true;
    });
    _load(reset: true);
  }

  void _setOrder(_DirectoryOrder o) {
    if (_order == o) return;
    setState(() {
      _order = o;
      _hasMore = true;
    });
    _load(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const SimpleListAppBar(title: 'Users'),
      body: Column(
        children: [
          _buildSelector(
            children: _DirectoryOrder.values.map((o) {
              return Padding(
                padding: const EdgeInsets.only(right: DesignTokens.spacingS),
                child: ChoiceChip(
                  avatar: Icon(o.icon, size: DesignTokens.iconSizeS),
                  label: Text(o.label),
                  selected: _order == o,
                  onSelected: (_) => _setOrder(o),
                ),
              );
            }).toList(),
          ),
          _buildSelector(
            children: _DirectoryPeriod.values.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: DesignTokens.spacingS),
                child: ChoiceChip(
                  label: Text(p.label),
                  selected: _period == p,
                  onSelected: (_) => _setPeriod(p),
                ),
              );
            }).toList(),
          ),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant
                .withOpacity(DesignTokens.opacityDivider),
          ),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildSelector({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingL,
        vertical: DesignTokens.spacingS,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: children),
      ),
    );
  }

  Widget _buildList() {
    final colorScheme = Theme.of(context).colorScheme;

    if (_items.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty && _error != null) {
      return EmptyStateView(
        icon: Icons.people_outline,
        message: _error!,
      );
    }
    if (_items.isEmpty) {
      return const EmptyStateView(
        icon: Icons.people_outline,
        message: 'No users found for this period.',
      );
    }
    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: ListView.separated(
        controller: _scrollController,
        itemCount: _items.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 72,
          color: colorScheme.outlineVariant
              .withOpacity(DesignTokens.opacityDivider),
        ),
        itemBuilder: (_, i) {
          if (i >= _items.length) {
            return const Padding(
              padding: EdgeInsets.all(DesignTokens.spacingL),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final item = _items[i];
          return _UserRow(
            item: item,
            order: _order,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => UserProfilePage(
                  siteContext: widget.siteContext,
                  userId: item.id.toString(),
                  userName: item.username,
                  profilePictureUrl: item.avatarUrl,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final FCDirectoryItem item;
  final _DirectoryOrder order;
  final VoidCallback onTap;

  const _UserRow({
    required this.item,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final stat = item.statFor(order.apiName);
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: DesignTokens.avatarRadiusM,
        backgroundColor: colorScheme.surfaceContainerHighest,
        backgroundImage: item.avatarUrl.isNotEmpty
            ? NetworkImage(item.avatarUrl)
            : null,
        child: item.avatarUrl.isEmpty
            ? Icon(Icons.person, color: colorScheme.onSurfaceVariant)
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.username,
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: DesignTokens.fontWeightSemiBold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (item.trustLevel != null) ...[
            const SizedBox(width: DesignTokens.spacingS),
            TrustLevelChip(level: item.trustLevel!),
          ],
        ],
      ),
      subtitle: item.name != null
          ? Text(
              item.name!,
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(order.icon,
              size: DesignTokens.iconSizeXS,
              color: colorScheme.onSurfaceVariant),
          const SizedBox(width: DesignTokens.spacingXS),
          Text(
            _formatCount(stat),
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: DesignTokens.fontWeightSemiBold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}
