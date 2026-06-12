import 'package:flutter/material.dart';
import 'package:forumcopilot_flutter/services/site_proxy_service.dart';
import 'package:forumcopilot_flutter/utils/snackbar_helper.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_directory_item.dart';
import 'package:forumcopilot_sdk/models/entities/fc_group.dart';

import '../theme/design_tokens.dart';
import 'user_profile_page.dart';
import 'widgets/empty_state_view.dart';
import 'widgets/simple_list_app_bar.dart';
import 'widgets/trust_level_chip.dart';

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
  FCGroup? _group;
  final List<FCDirectoryItem> _members = [];
  bool _loadingGroup = true;
  bool _loadingMembers = false;
  bool _hasMore = true;
  int _offset = 0;
  String? _error;

  /// Phase 5.44 — membership-action state. [_membershipBusy] guards
  /// double-taps while a join/leave/request call is in flight;
  /// [_requestPending] remembers a successful membership request for
  /// the rest of the session (Discourse's group JSON doesn't expose
  /// outstanding requests, so we track it locally after sending one).
  bool _membershipBusy = false;
  bool _requestPending = false;

  /// Phase 5.46 — true when the members fetch failed while the group
  /// itself loaded (Discourse returns 403 when a group's member list
  /// is restricted, e.g. members_visibility_level > everyone). Renders
  /// an explanatory row instead of silent dead space below the header.
  bool _membersRestricted = false;

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
    try {
      final proxy = SiteProxyService.getGroupProxy();
      final groupFuture = proxy.getGroupAsync(widget.groupName);
      final membersFuture = proxy.getGroupMembersAsync(widget.groupName,
          offset: 0, limit: _pageSize);
      final groupResult = await groupFuture;
      final membersResult = await membersFuture;
      if (!mounted) return;
      setState(() {
        _group = groupResult.group;
        _members
          ..clear()
          ..addAll(membersResult.members);
        _membersRestricted =
            groupResult.result && !membersResult.result;
        _offset = membersResult.members.length;
        _hasMore = membersResult.result &&
            membersResult.members.length >= _pageSize;
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
    try {
      final result = await SiteProxyService.getGroupProxy()
          .getGroupMembersAsync(
        widget.groupName,
        offset: _offset,
        limit: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _members.addAll(result.members);
        _offset += result.members.length;
        if (result.members.length < _pageSize) _hasMore = false;
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

  Future<void> _handleJoin() async {
    final group = _group;
    if (group == null || _membershipBusy) return;
    setState(() => _membershipBusy = true);
    final result =
        await SiteProxyService.getGroupProxy().joinGroupAsync(group.id);
    if (!mounted) return;
    setState(() {
      _membershipBusy = false;
      if (result.result) {
        _group = group.copyWith(
          isMember: true,
          memberCount: group.memberCount + 1,
        );
      }
    });
    if (result.result) {
      SnackbarHelper.showSuccess(
          context, 'You joined ${group.displayName}');
      // Pull the fresh member list so the user appears in it.
      _load();
    } else {
      SnackbarHelper.showError(
          context,
          result.resultText?.isNotEmpty == true
              ? result.resultText!
              : 'Failed to join group');
    }
  }

  Future<void> _handleLeave() async {
    final group = _group;
    if (group == null || _membershipBusy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: const Text('Leave group?'),
          content: Text(
            'You will no longer be a member of ${group.displayName}. '
            'You can rejoin at any time.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: colorScheme.error),
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    setState(() => _membershipBusy = true);
    final result =
        await SiteProxyService.getGroupProxy().leaveGroupAsync(group.id);
    if (!mounted) return;
    setState(() {
      _membershipBusy = false;
      if (result.result) {
        _group = group.copyWith(
          isMember: false,
          memberCount:
              group.memberCount > 0 ? group.memberCount - 1 : 0,
        );
      }
    });
    if (result.result) {
      SnackbarHelper.showInfo(context, 'You left ${group.displayName}');
      _load();
    } else {
      SnackbarHelper.showError(
          context,
          result.resultText?.isNotEmpty == true
              ? result.resultText!
              : 'Failed to leave group');
    }
  }

  Future<void> _handleRequestMembership() async {
    final group = _group;
    if (group == null || _membershipBusy) return;
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Request to join ${group.displayName}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Why do you want to join? '
                'Group owners see this with your request.',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Send request'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null || !mounted) return;
    if (reason.isEmpty) {
      SnackbarHelper.showError(
          context, 'A reason is required to request membership');
      return;
    }
    setState(() => _membershipBusy = true);
    final result = await SiteProxyService.getGroupProxy()
        .requestMembershipAsync(group.name, reason);
    if (!mounted) return;
    setState(() {
      _membershipBusy = false;
      if (result.result) _requestPending = true;
    });
    if (result.result) {
      SnackbarHelper.showSuccess(
          context, 'Request sent — a group owner has to approve it');
    } else {
      SnackbarHelper.showError(
          context,
          result.resultText?.isNotEmpty == true
              ? result.resultText!
              : 'Failed to send membership request');
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _group?.displayName ?? widget.groupName;
    return Scaffold(
      appBar: SimpleListAppBar(title: title),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loadingGroup && _members.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _members.isEmpty) {
      return EmptyStateView(
        icon: Icons.error_outline,
        message: _error!,
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: 1 + _members.length + (_hasMore ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                if (_membersRestricted && _members.isEmpty)
                  _buildMembersRestrictedRow(),
              ],
            );
          }
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
            color: colorScheme.outlineVariant
                .withValues(alpha: DesignTokens.opacityDivider),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: DesignTokens.avatarRadiusL,
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
                        fontWeight: DesignTokens.fontWeightSemiBold,
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
          ..._buildMembershipAction(colorScheme, textTheme),
        ],
      ),
    );
  }

  /// Phase 5.44 — membership affordance under the group bio. Picks
  /// one action based on the group's flags and the user's current
  /// relationship to it:
  ///
  ///   member + publicExit          → "Leave group" (outlined, error tone)
  ///   member, no exit              → "Member" chip (no action possible)
  ///   guest of joinable group      → "Join group" (filled CTA)
  ///   guest of request-only group  → "Request to join" (tonal)
  ///   request already sent         → "Request pending" chip
  ///
  /// Hidden entirely for signed-out users (consistent with the app's
  /// other gated affordances) and for automatic groups (trust-level /
  /// staff groups can't be joined manually).
  List<Widget> _buildMembershipAction(
      ColorScheme colorScheme, TextTheme textTheme) {
    final group = _group;
    if (group == null ||
        !widget.siteContext.isLoggedIn ||
        group.automatic) {
      return const [];
    }

    final Widget child;
    if (group.isMember) {
      if (group.publicExit) {
        child = OutlinedButton.icon(
          onPressed: _membershipBusy ? null : _handleLeave,
          icon: _membershipBusy
              ? SizedBox(
                  width: DesignTokens.iconSizeS,
                  height: DesignTokens.iconSizeS,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.error,
                  ),
                )
              : const Icon(Icons.logout_rounded),
          label: const Text('Leave group'),
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.error,
            side: BorderSide(
              color: colorScheme.error
                  .withValues(alpha: DesignTokens.opacityMediumLow),
            ),
          ),
        );
      } else {
        child = _membershipChip(
          colorScheme,
          textTheme,
          icon: Icons.check_rounded,
          label: 'Member',
        );
      }
    } else if (_requestPending) {
      child = _membershipChip(
        colorScheme,
        textTheme,
        icon: Icons.hourglass_top_rounded,
        label: 'Request pending',
      );
    } else if (group.publicAdmission) {
      child = FilledButton.icon(
        onPressed: _membershipBusy ? null : _handleJoin,
        icon: _membershipBusy
            ? SizedBox(
                width: DesignTokens.iconSizeS,
                height: DesignTokens.iconSizeS,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.onPrimary,
                ),
              )
            : const Icon(Icons.group_add_rounded),
        label: Text(_membershipBusy ? 'Joining…' : 'Join group'),
      );
    } else if (group.allowMembershipRequests) {
      child = FilledButton.tonalIcon(
        onPressed: _membershipBusy ? null : _handleRequestMembership,
        icon: const Icon(Icons.outgoing_mail),
        label: const Text('Request to join'),
      );
    } else {
      return const [];
    }

    return [
      const SizedBox(height: DesignTokens.spacingL),
      SizedBox(width: double.infinity, child: child),
    ];
  }

  /// Quiet explanatory row for groups whose member list the server
  /// refuses to expose (403). Replaces what used to be silent dead
  /// space below the header.
  Widget _buildMembersRestrictedRow() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingL,
        vertical: DesignTokens.spacingXL,
      ),
      child: Column(
        children: [
          Icon(Icons.lock_outline_rounded,
              size: DesignTokens.iconSizeL,
              color: colorScheme.onSurfaceVariant),
          const SizedBox(height: DesignTokens.spacingM),
          Text(
            'The member list of this group is private.',
            style: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _membershipChip(
    ColorScheme colorScheme,
    TextTheme textTheme, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingM,
        vertical: DesignTokens.spacingS,
      ),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer
            .withValues(alpha: DesignTokens.opacityMediumLow),
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: DesignTokens.iconSizeS,
              color: colorScheme.onSecondaryContainer),
          const SizedBox(width: DesignTokens.spacingS),
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: DesignTokens.fontWeightMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final FCDirectoryItem item;
  final VoidCallback onTap;

  const _MemberRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: DesignTokens.avatarRadiusS,
        backgroundColor: colorScheme.surfaceContainerHighest,
        backgroundImage: item.avatarUrl.isNotEmpty
            ? NetworkImage(item.avatarUrl)
            : null,
        child: item.avatarUrl.isEmpty
            ? Icon(Icons.person,
                color: colorScheme.onSurfaceVariant,
                size: DesignTokens.iconSizeSMedium)
            : null,
      ),
      title: Text(
        item.username,
        style: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: DesignTokens.fontWeightMedium,
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
          ? TrustLevelChip(level: item.trustLevel!)
          : null,
    );
  }
}
