import 'package:flutter/material.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_directory_item.dart';
import 'package:forumcopilot_sdk/models/results/fc_user_result.dart';

import '../theme/design_tokens.dart';
import 'user_profile_page.dart';
import 'widgets/empty_state_view.dart';
import 'widgets/simple_list_app_bar.dart';
import 'widgets/search_text_field.dart';
import 'widgets/user_list_row.dart';
import '../utils/error_message.dart';

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

  // Search folded in from the old Members page. The two screens both listed
  // users and both reached /directory_items.json — Members' "online users" was
  // just period=daily&order=days_visited — so search was the only thing it had
  // that this page did not.
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<FCSearchUser> _searchResults = const [];
  bool _searching = false;
  String _query = '';

  bool get _isSearchMode => _query.isNotEmpty;

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

  Future<void> _runSearch(String term) async {
    final q = term.trim();
    setState(() {
      _query = q;
      if (q.isEmpty) {
        _searchResults = const [];
        _searching = false;
      }
    });
    if (q.isEmpty) return;

    setState(() => _searching = true);
    try {
      final result =
          await SiteProxyService.getUserProxy().searchUserAsync(q, 1, 20);
      if (!mounted || q != _query) return;
      setState(() {
        _searchResults = result.list;
        _searching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searchResults = const [];
        _searching = false;
      });
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
        _error = describeError(e);
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
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingL,
              vertical: DesignTokens.spacingS,
            ),
            child: SearchTextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              hintText: 'Search users...',
              onSearch: _runSearch,
              autoSearch: true,
              onClear: () => _runSearch(''),
            ),
          ),
          // Order and period rank the directory; neither applies to a name
          // search, so they step aside while searching rather than sitting
          // there looking like they filter the results.
          if (!_isSearchMode) ...[
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
          ],
          Divider(
            height: 1,
            color: colorScheme.outlineVariant
                .withValues(alpha: DesignTokens.opacityDivider),
          ),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  /// Search results reuse the directory's row, so a person looks the same
  /// whether you browse to them or search for them. /u/search/users.json carries
  /// no trust level or stats, so those slots stay empty rather than costing a
  /// profile request per result.
  Widget _buildSearchResults() {
    if (_searching && _searchResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_searchResults.isEmpty) {
      return const EmptyStateView(
        icon: Icons.search_off_rounded,
        message: 'No users match that name.',
      );
    }
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (_, i) {
        final u = _searchResults[i];
        return UserListRow(
          username: u.username,
          subtitle: u.displayText,
          avatarUrl: u.iconUrl,
          leadingIcon: u.userType == 'group' ? Icons.groups_rounded : null,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => UserProfilePage(
                siteContext: widget.siteContext,
                userId: u.id,
                userName: u.username,
                profilePictureUrl: u.iconUrl,
              ),
            ),
          ),
        );
      },
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
    if (_isSearchMode) return _buildSearchResults();

    if (_items.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty && _error != null) {
      return EmptyStateView.error(
        message: _error!,
        onRetry: () => _load(reset: true),
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
              .withValues(alpha: DesignTokens.opacityDivider),
        ),
        itemBuilder: (_, i) {
          if (i >= _items.length) {
            return const Padding(
              padding: EdgeInsets.all(DesignTokens.spacingL),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final item = _items[i];
          return UserListRow(
            username: item.username,
            subtitle: item.name,
            avatarUrl: item.avatarUrl,
            trustLevel: item.trustLevel,
            statLabel: _formatCount(item.statFor(_order.apiName)),
            statIcon: _order.icon,
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


/// Compact stat label for a directory row (1200 -> "1.2k").
String _formatCount(int value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
  return value.toString();
}
