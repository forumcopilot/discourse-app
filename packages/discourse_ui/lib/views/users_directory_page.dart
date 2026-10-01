import 'package:flutter/material.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscourseUserProxy, DiscourseUserSearchGroups;
import 'widgets/filter_chip_bar.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_directory_item.dart';
import 'package:forumcopilot_sdk/models/results/fc_user_result.dart';

import '../theme/design_tokens.dart';
import 'profile/user_card_sheet.dart';
import 'widgets/empty_state_view.dart';
import 'widgets/simple_list_app_bar.dart';
import 'widgets/search_text_field.dart';
import 'widgets/user_list_row.dart';
import '../utils/error_message.dart';
import '../l10n/generated/app_localizations.dart';

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
/// Tapping a row opens the person's user card (`showUserCard`). The
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
  /// Discourse's own period names (the web's period chooser).
  String label(AppLocalizations l10n) {
    switch (this) {
      case _DirectoryPeriod.all:
        return l10n.directoryPeriodAllTime;
      case _DirectoryPeriod.yearly:
        return l10n.directoryPeriodYear;
      case _DirectoryPeriod.quarterly:
        return l10n.directoryPeriodQuarter;
      case _DirectoryPeriod.monthly:
        return l10n.directoryPeriodMonth;
      case _DirectoryPeriod.weekly:
        return l10n.directoryPeriodWeek;
      case _DirectoryPeriod.daily:
        return l10n.directoryPeriodToday;
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
  /// The web directory's column names; likes received is "Received"
  /// beside a heart, as there.
  String label(AppLocalizations l10n) {
    switch (this) {
      case _DirectoryOrder.likesReceived:
        return l10n.directoryOrderReceived;
      case _DirectoryOrder.postCount:
        return l10n.directoryOrderReplies;
      case _DirectoryOrder.topicCount:
        return l10n.directoryOrderTopics;
      case _DirectoryOrder.daysVisited:
        return l10n.directoryOrderVisits;
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
      // People only: this is the member directory, and a group row opened
      // a profile page that could only 404 (/u/<group>.json).
      final proxy = SiteProxyService.getUserProxy();
      final result = proxy is DiscourseUserProxy
          ? await proxy.searchUsersAsync(q,
              groups: DiscourseUserSearchGroups.none)
          : await proxy.searchUserAsync(q, 1, 20);
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
              : AppLocalizations.of(context)!.directoryLoadFailed;
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: SimpleListAppBar(title: l10n.users),
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
              hintText: l10n.searchUsers,
              onSearch: _runSearch,
              autoSearch: true,
              onClear: () => _runSearch(''),
            ),
          ),
          // Order and period rank the directory; neither applies to a name
          // search, so they step aside while searching rather than sitting
          // there looking like they filter the results.
          if (!_isSearchMode) ...[
            // The shared bar, not bare ChoiceChips on Material defaults —
            // these read as outlined boxes next to the filled pills used
            // for the same gesture everywhere else in the app.
            FilterChipBar(
              options: [
                for (final o in _DirectoryOrder.values)
                  FilterChipOption(label: o.label(l10n), icon: o.icon),
              ],
              selectedIndex: _DirectoryOrder.values.indexOf(_order),
              onSelected: (i) => _setOrder(_DirectoryOrder.values[i]),
              padding: EdgeInsets.fromLTRB(DesignTokens.spacingL,
                  DesignTokens.spacingS, DesignTokens.spacingL, 0),
            ),
            FilterChipBar(
              options: [
                for (final p in _DirectoryPeriod.values)
                  FilterChipOption(label: p.label(l10n)),
              ],
              selectedIndex: _DirectoryPeriod.values.indexOf(_period),
              onSelected: (i) => _setPeriod(_DirectoryPeriod.values[i]),
              padding: EdgeInsets.fromLTRB(DesignTokens.spacingL,
                  DesignTokens.spacingS, DesignTokens.spacingL,
                  DesignTokens.spacingS),
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
      return EmptyStateView(
        icon: Icons.search_off_rounded,
        message: AppLocalizations.of(context)!.directoryNoUsersMatch,
      );
    }
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.separated(
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 72,
        color: colorScheme.outlineVariant,
      ),
      itemBuilder: (_, i) {
        final u = _searchResults[i];
        return UserListRow(
          username: u.username,
          subtitle: u.displayText,
          avatarUrl: u.iconUrl,
          onTap: () => showUserCard(context,
              siteContext: widget.siteContext,
              username: u.username,
              avatarUrl: u.iconUrl),
        );
      },
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
        message: describeError(_error, context: context),
        onRetry: () => _load(reset: true),
      );
    }
    if (_items.isEmpty) {
      return EmptyStateView(
        icon: Icons.people_outline,
        message: AppLocalizations.of(context)!.directoryNoUsersForPeriod,
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
          color: colorScheme.outlineVariant,
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
            onTap: () => showUserCard(context,
                siteContext: widget.siteContext,
                username: item.username,
                avatarUrl: item.avatarUrl),
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
