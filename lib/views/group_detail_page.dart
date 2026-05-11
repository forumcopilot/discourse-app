import 'package:discourse_core/discourse_core.dart';
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../theme/design_tokens.dart';
import 'user_profile_page.dart';

/// Phase 5.18c-2 — single-group screen. Fetches the group's metadata
/// (`/groups/{name}.json`) and the first page of members
/// (`/groups/{name}/members.json`) in parallel, then renders a
/// header card with the bio + member count followed by a list of
/// member avatars.
///
/// Tapping a member opens `UserProfilePage`. Pagination is simple
/// "load more" via scroll — Discourse caps `/members.json` at 200
/// rows per page, so we set 50 as a friendly default.
class GroupDetailPage extends StatefulWidget {
  final SiteContext siteContext;
  final String groupName;

  const GroupDetailPage({
    super.key,
    required this.siteContext,
    required this.groupName,
  });

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final ScrollController _scrollController = ScrollController();
  DiscourseGroup? _group;
  final List<DiscourseDirectoryItem> _members = [];
  bool _loadingGroup = true;
  bool _loadingMembers = false;
  bool _hasMore = true;
  int _offset = 0;
  String? _error;

  static const int _pageSize = 50;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loadingMembers) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loadingGroup = true;
      _error = null;
    });
    final proxy = DiscourseGroupProxy.forCurrentSite();
    if (proxy == null) {
      setState(() {
        _loadingGroup = false;
        _error = 'Groups require a Discourse forum.';
      });
      return;
    }
    try {
      final results = await Future.wait([
        proxy.getGroupAsync(widget.groupName),
        proxy.getGroupMembersAsync(widget.groupName,
            offset: 0, limit: _pageSize),
      ]);
      if (!mounted) return;
      final group = results[0] as DiscourseGroup?;
      final members = results[1] as List<DiscourseDirectoryItem>;
      setState(() {
        _group = group;
        _members
          ..clear()
          ..addAll(members);
        _offset = members.length;
        _hasMore = members.length >= _pageSize;
        _loadingGroup = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingGroup = false;
        _error = '$e';
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMembers || !_hasMore) return;
    setState(() {
      _loadingMembers = true;
    });
    final proxy = DiscourseGroupProxy.forCurrentSite();
    if (proxy == null) return;
    try {
      final next = await proxy.getGroupMembersAsync(
        widget.groupName,
        offset: _offset,
        limit: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _members.addAll(next);
        _offset += next.length;
        if (next.length < _pageSize) _hasMore = false;
        _loadingMembers = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingMembers = false;
        _hasMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final title = _group?.displayName ?? widget.groupName;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 3,
        shadowColor: colorScheme.shadow.withOpacity(0.3),
        surfaceTintColor: colorScheme.surfaceTint,
        title: Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: false,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (_loadingGroup && _members.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _members.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: DesignTokens.spacingM),
              Text(
                _error!,
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: 1 + _members.length + (_hasMore ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == 0) return _buildHeader();
          final idx = i - 1;
          if (idx >= _members.length) {
            return const Padding(
              padding: EdgeInsets.all(DesignTokens.spacingL),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final m = _members[idx];
          return _MemberRow(
            item: m,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => UserProfilePage(
                  siteContext: widget.siteContext,
                  userId: m.id.toString(),
                  userName: m.username,
                  profilePictureUrl: m.avatarUrl,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final group = _group;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignTokens.spacingL),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.4),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(Icons.groups,
                    color: colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: DesignTokens.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group?.displayName ?? widget.groupName,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '@${widget.groupName}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (group != null) ...[
                Icon(Icons.person_outline,
                    size: 14, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  group.memberCount.toString(),
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          if (group?.bio != null && group!.bio!.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.spacingM),
            Text(
              group.bio!,
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final DiscourseDirectoryItem item;
  final VoidCallback onTap;

  const _MemberRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: colorScheme.surfaceContainerHighest,
        backgroundImage: item.avatarUrl.isNotEmpty
            ? NetworkImage(item.avatarUrl)
            : null,
        child: item.avatarUrl.isEmpty
            ? Icon(Icons.person, color: colorScheme.onSurfaceVariant, size: 18)
            : null,
      ),
      title: Text(
        item.username,
        style: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
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
      trailing: item.trustLevel != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'TL${item.trustLevel}',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }
}
