import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/models/results/fc_user_result.dart';

import '../theme/design_tokens.dart';
import 'user_profile_page.dart';
import 'widgets/empty_state_view.dart';
import 'widgets/simple_list_app_bar.dart';

/// Phase 5.25 — list users you've ignored (Discourse notification
/// level 2), with a per-row "Unignore" action.
///
/// Backed by `DiscourseUserProxy.getIgnoredUsersAsync` which reads
/// the current user's `user.ignored_usernames` array from
/// `/u/{me}.json`. Discourse doesn't expose a paginated endpoint for
/// this list — the full array is returned in one shot, so no
/// pagination here.
///
/// Toggling Unignore reuses the same `ignoreUserAsync` proxy method
/// the profile page calls (with mode=0 to clear).
class IgnoredUsersPage extends StatefulWidget {
  final SiteContext siteContext;

  const IgnoredUsersPage({super.key, required this.siteContext});

  @override
  State<IgnoredUsersPage> createState() => _IgnoredUsersPageState();
}

class _IgnoredUsersPageState extends State<IgnoredUsersPage> {
  List<FCIgnoredUser>? _users;
  bool _loading = true;
  String? _error;
  final Set<String> _busy = {}; // usernames being unignored

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final proxy = SiteProxyFactory.getUserProxy();
      // Discourse returns the full list at once; page/perpage are
      // ignored by the impl. Pass `0,0` so the SDK contract is
      // satisfied without implying a different page.
      final result = await proxy.getIgnoredUsersAsync(0, 0);
      if (!mounted) return;
      setState(() {
        _users = result.list;
        _loading = false;
        if (!result.result && (result.resultText?.isNotEmpty ?? false)) {
          _error = result.resultText;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  Future<void> _unignore(FCIgnoredUser user) async {
    if (_busy.contains(user.username)) return;
    setState(() {
      _busy.add(user.username);
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      final proxy = SiteProxyFactory.getUserProxy();
      final result = await proxy.ignoreUserAsync(user.username, 0);
      if (!mounted) return;
      if (result.result) {
        // Drop the row from the local list — no need to refetch.
        setState(() {
          _users = (_users ?? [])
              .where((u) => u.username != user.username)
              .toList();
          _busy.remove(user.username);
        });
        messenger.showSnackBar(
          SnackBar(content: Text('Stopped ignoring @${user.username}')),
        );
      } else {
        setState(() {
          _busy.remove(user.username);
        });
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              result.resultText?.isNotEmpty == true
                  ? result.resultText!
                  : "Couldn't update ignore state",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy.remove(user.username);
      });
      messenger.showSnackBar(
        SnackBar(content: Text('Unignore failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleListAppBar(title: 'Ignored users'),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final colorScheme = Theme.of(context).colorScheme;
    if (_loading && _users == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && (_users == null || _users!.isEmpty)) {
      return EmptyStateView(
        icon: Icons.notifications_off_outlined,
        message: _error!,
      );
    }
    final users = _users ?? const <FCIgnoredUser>[];
    if (users.isEmpty) {
      return const EmptyStateView(
        icon: Icons.notifications_off_outlined,
        message: "You're not ignoring anyone.",
        hint: 'Open a user profile and use "Ignore user" in the '
            'overflow menu to hide their posts and notifications.',
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        itemCount: users.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 72,
          color: colorScheme.outlineVariant
              .withOpacity(DesignTokens.opacityDivider),
        ),
        itemBuilder: (_, i) {
          final user = users[i];
          final busy = _busy.contains(user.username);
          return ListTile(
            leading: CircleAvatar(
              radius: DesignTokens.avatarRadiusM,
              backgroundColor: colorScheme.surfaceContainerHighest,
              child: Icon(Icons.person, color: colorScheme.onSurfaceVariant),
            ),
            title: Text(
              user.username,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: DesignTokens.fontWeightSemiBold,
                  ),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => UserProfilePage(
                  siteContext: widget.siteContext,
                  userName: user.username,
                ),
              ),
            ),
            trailing: TextButton(
              onPressed: busy ? null : () => _unignore(user),
              child: busy
                  ? SizedBox(
                      width: DesignTokens.iconSizeS,
                      height: DesignTokens.iconSizeS,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    )
                  : Text(
                      'Unignore',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: DesignTokens.fontWeightSemiBold,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
