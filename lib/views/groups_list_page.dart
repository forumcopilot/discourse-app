import 'package:flutter/material.dart';
import 'package:forumcopilot_flutter/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_group.dart';

import '../theme/design_tokens.dart';
import 'group_detail_page.dart';
import 'widgets/empty_state_view.dart';
import 'widgets/simple_list_app_bar.dart';

/// Phase 5.18c-2 — Groups directory, the second drawer destination
/// under **Community**. Lists every visible group on the forum
/// (custom + built-in) with member counts; tapping drills into
/// `GroupDetailPage`.
///
/// Built-in groups (`admins`, `staff`, `trust_level_*`, `everyone`)
/// are rendered with a muted icon so users can scan past them in
/// favour of the custom groups specific to the forum.
class GroupsListPage extends StatefulWidget {
  final SiteContext siteContext;

  const GroupsListPage({super.key, required this.siteContext});

  @override
  State<GroupsListPage> createState() => _GroupsListPageState();
}

class _GroupsListPageState extends State<GroupsListPage> {
  final ScrollController _scrollController = ScrollController();
  final List<FCGroup> _groups = [];
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
      final result = await SiteProxyService.getGroupProxy()
          .getGroupsAsync(page: fetchedPage);
      if (!mounted) return;
      setState(() {
        if (reset) {
          _groups.clear();
          _page = 1;
        }
        if (!result.result) {
          _hasMore = false;
          _error = result.resultText?.isNotEmpty == true
              ? result.resultText
              : 'Failed to load groups.';
        } else if (result.groups.isEmpty) {
          _hasMore = false;
        } else {
          _groups.addAll(result.groups);
          _page = fetchedPage;
          if (result.groups.length < 36) _hasMore = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleListAppBar(title: 'Groups'),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final colorScheme = Theme.of(context).colorScheme;
    if (_groups.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_groups.isEmpty && _error != null) {
      return EmptyStateView(
        icon: Icons.groups_outlined,
        message: _error!,
      );
    }
    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: ListView.separated(
        controller: _scrollController,
        itemCount: _groups.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 72,
          color: colorScheme.outlineVariant
              .withValues(alpha: DesignTokens.opacityDivider),
        ),
        itemBuilder: (_, i) {
          if (i >= _groups.length) {
            return const Padding(
              padding: EdgeInsets.all(DesignTokens.spacingL),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final group = _groups[i];
          return _GroupRow(
            group: group,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GroupDetailPage(
                  siteContext: widget.siteContext,
                  groupName: group.name,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GroupRow extends StatelessWidget {
  final FCGroup group;
  final VoidCallback onTap;

  const _GroupRow({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Built-in groups get a muted icon and slightly de-emphasised
    // text so the user can scan past them quickly to the
    // forum-specific groups.
    final iconBg = group.automatic
        ? colorScheme.surfaceContainerHighest
        : colorScheme.primaryContainer;
    final iconFg = group.automatic
        ? colorScheme.onSurfaceVariant
        : colorScheme.onPrimaryContainer;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: DesignTokens.avatarRadiusM,
        backgroundColor: iconBg,
        child: Icon(Icons.groups, color: iconFg),
      ),
      title: Text(
        group.displayName,
        style: textTheme.titleSmall?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: DesignTokens.fontWeightSemiBold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        group.automatic ? 'Built-in group' : '@${group.name}',
        style: textTheme.bodySmall
            ?.copyWith(color: colorScheme.onSurfaceVariant),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline,
              size: DesignTokens.iconSizeXS,
              color: colorScheme.onSurfaceVariant),
          const SizedBox(width: DesignTokens.spacingXS),
          Text(
            group.memberCount.toString(),
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: DesignTokens.fontWeightSemiBold,
            ),
          ),
        ],
      ),
    );
  }
}
