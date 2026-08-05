import 'dart:async';

import 'package:discourse_core/discourse_core.dart' show DiscourseChatProxy;
import 'package:flutter/material.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_channel.dart';
import 'package:forumcopilot_sdk/models/results/fc_user_result.dart';

import '../../theme/design_tokens.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/resettable_widget.dart';
import '../widgets/user_avatar.dart';
import 'chat_channel_view.dart';

/// DM channel titles come back from the serializer already filled with
/// the other members' usernames (channel_serializer.rb:
/// `object.name || object.title(scope.user)`), so they are normally
/// non-empty. Guard anyway — `FCChatChannel` carries no member list to
/// fall back on client-side.
String _channelDisplayTitle(FCChatChannel ch) {
  if (ch.title.isNotEmpty) return ch.title;
  return ch.chatableType == 'DirectMessage'
      ? 'Direct message'
      : 'Channel ${ch.id}';
}

/// Top-level Chat surface: lists the user's joined channels and opens
/// the selected one in a full-page route.
///
/// Discourse Chat users typically belong to a handful of category-
/// linked public channels plus DMs. We render both groups in one list
/// (public channels first), each with unread + mention badges.
class ChatChannelListPage extends StatefulWidget {
  final SiteContext siteContext;

  /// When true, render the channel list as a tab body (no Scaffold /
  /// AppBar of our own — the parent provides them). Used by Phase
  /// 5.18a's bottom-nav Chat slot, where `SiteHomePage` owns the
  /// Scaffold + drawer + AppBar and embeds us via IndexedStack.
  ///
  /// Default (false) is the legacy push-as-route mode: we wrap the
  /// list in our own Scaffold + AppBar.
  final bool embedded;

  const ChatChannelListPage({
    super.key,
    required this.siteContext,
    this.embedded = false,
  });

  @override
  State<ChatChannelListPage> createState() => ChatChannelListPageState();
}

class ChatChannelListPageState extends FCStatefulWidget<ChatChannelListPage>
    with FCTabStatefulWidget<ChatChannelListPage> {
  List<FCChatChannel>? _channels;
  bool _loading = false;
  String? _error;

  // Track login state so the channel list reloads after an in-session
  // login/logout (same pattern as NotificationListTab). Without this
  // the page keeps the guest-time "You need to be logged in" error
  // until the app is restarted — it lives inside SiteHomePage's
  // IndexedStack, so initState only ever runs once.
  bool _wasLoggedIn = false;
  String? _lastLoadedUsername;
  late final VoidCallback _authStateListener;

  @override
  void initState() {
    super.initState();
    _wasLoggedIn = widget.siteContext.isLoggedIn;
    _lastLoadedUsername = widget.siteContext.loginDataOutput?.user?.username;
    _load();

    _authStateListener = () {
      if (!mounted) return;
      final isLoggedIn = widget.siteContext.isLoggedIn;
      final username = widget.siteContext.loginDataOutput?.user?.username;
      if (isLoggedIn != _wasLoggedIn || username != _lastLoadedUsername) {
        _wasLoggedIn = isLoggedIn;
        _lastLoadedUsername = username;
        _load();
      }
    };
    widget.siteContext.isLoggedInNotifier.addListener(_authStateListener);
  }

  @override
  void dispose() {
    widget.siteContext.isLoggedInNotifier.removeListener(_authStateListener);
    super.dispose();
  }

  /// Called by SiteHomePage._resetAllTabs on login/logout and site
  /// re-initialization, mirroring the other bottom-nav tabs.
  @override
  void resetTab() {
    _wasLoggedIn = widget.siteContext.isLoggedIn;
    _lastLoadedUsername = widget.siteContext.loginDataOutput?.user?.username;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result =
          await SiteProxyService.getChatProxy().getMyChannelsAsync();
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (!result.result) {
          _channels = const [];
          _error = result.resultText?.isNotEmpty == true
              ? result.resultText
              : 'Chat is not available on this forum.';
          return;
        }
        _channels = result.channels;
        if (result.channels.isEmpty) {
          _error =
              'No chat channels yet. Ask an admin to invite you to one.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _channels = const [];
        _loading = false;
        _error = '$e';
      });
    }
  }

  void _open(FCChatChannel ch) {
    final title = _channelDisplayTitle(ch);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          // DM titles are usernames — the '#' prefix only fits
          // category/topic channels.
          appBar: AppBar(
              title: Text(ch.chatableType == 'DirectMessage'
                  ? title
                  : '#$title')),
          body: ChatChannelView(
            siteContext: widget.siteContext,
            channelId: ch.id,
          ),
        ),
      ),
    );
  }

  Future<void> _startNewDm() async {
    final channel = await showModalBottomSheet<FCChatChannel>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _NewDmSheet(),
    );
    if (channel == null || !mounted) return;
    // Refresh so the (possibly brand-new) channel shows up in the
    // list, then open it right away.
    unawaited(_load());
    _open(channel);
  }

  @override
  Widget build(BuildContext context) {
    final body = RefreshIndicator(
      onRefresh: _load,
      child: _buildBody(),
    );
    final fab = widget.siteContext.isLoggedIn
        ? FloatingActionButton(
            tooltip: 'New direct message',
            onPressed: _startNewDm,
            child: const Icon(Icons.add_comment_outlined),
          )
        : null;
    // Embedded mode (Phase 5.18a bottom-nav Chat slot): caller owns
    // the Scaffold + AppBar. We just render the list (plus our own
    // overlaid FAB — the parent Scaffold's FAB slot belongs to the
    // page, not this tab).
    if (widget.embedded) {
      if (fab == null) return body;
      return Stack(
        children: [
          body,
          Positioned(
            right: DesignTokens.spacingM,
            bottom: DesignTokens.spacingM,
            child: fab,
          ),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.chat_bubble_outline, size: 20),
            SizedBox(width: 8),
            Text('Chat'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      floatingActionButton: fab,
      body: body,
    );
  }

  Widget _buildBody() {
    final colorScheme = Theme.of(context).colorScheme;
    final channels = _channels;

    if (_loading && channels == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if ((channels == null || channels.isEmpty) && _error != null) {
      return EmptyStateView.scrollable(
        icon: Icons.chat_bubble_outline,
        message: _error!,
      );
    }
    return ListView.separated(
      itemCount: channels?.length ?? 0,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: colorScheme.outlineVariant
            .withValues(alpha: DesignTokens.opacityDivider),
      ),
      itemBuilder: (_, i) {
        final ch = channels![i];
        return _ChannelTile(channel: ch, onTap: () => _open(ch));
      },
    );
  }
}

class _ChannelTile extends StatelessWidget {
  final FCChatChannel channel;
  final VoidCallback onTap;

  const _ChannelTile({required this.channel, required this.onTap});

  IconData _iconFor() {
    switch (channel.chatableType) {
      case 'DirectMessage':
        return Icons.person_outline;
      case 'TopicChat':
        return Icons.forum_outlined;
      case 'Category':
      default:
        return Icons.tag;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasUnread = channel.unreadCount > 0;
    final hasMention = channel.mentionCount > 0;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: DesignTokens.avatarRadiusM,
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: Icon(
          _iconFor(),
          color: colorScheme.onSurfaceVariant,
          size: DesignTokens.iconSizeM,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              _channelDisplayTitle(channel),
              style: textTheme.titleSmall?.copyWith(
                fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!channel.isOpen) ...[
            const SizedBox(width: 6),
            Icon(
              channel.isReadOnly ? Icons.lock_outline : Icons.archive_outlined,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ],
      ),
      subtitle: channel.description != null && channel.description!.isNotEmpty
          ? Text(
              channel.description!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: hasUnread || hasMention
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasMention)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '@${channel.mentionCount}',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onError,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                if (hasUnread) ...[
                  if (hasMention) const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      channel.unreadCount.toString(),
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            )
          : null,
    );
  }
}

/// "New direct message" bottom sheet: a username input with type-ahead
/// suggestions from the same `/u/search/users` typeahead the mention /
/// PM pickers use, plus plain comma-separated entry as a fallback.
/// Pops with the created (or reused — 1:1 DMs are deduped server-side)
/// [FCChatChannel]; policy failures (DMs disabled, target doesn't
/// accept DMs, …) surface inline via the result's `resultText`.
class _NewDmSheet extends StatefulWidget {
  const _NewDmSheet();

  @override
  State<_NewDmSheet> createState() => _NewDmSheetState();
}

class _NewDmSheetState extends State<_NewDmSheet> {
  final _input = TextEditingController();
  final _selected = <FCSearchUser>[];
  List<FCSearchUser> _suggestions = const [];
  Timer? _debounce;
  bool _searching = false;
  bool _creating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _input.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _input.dispose();
    super.dispose();
  }

  /// The fragment being typed — text after the last comma — so
  /// comma-separated raw entry keeps working alongside the type-ahead.
  String _currentTerm() {
    final raw = _input.text;
    final tail =
        raw.contains(',') ? raw.substring(raw.lastIndexOf(',') + 1) : raw;
    return tail.trim().replaceFirst(RegExp(r'^@'), '');
  }

  void _onQueryChanged() {
    // Rebuild for the create-button enablement either way.
    setState(() {});
    _debounce?.cancel();
    final term = _currentTerm();
    if (term.isEmpty) {
      setState(() => _suggestions = const []);
      return;
    }
    _debounce =
        Timer(const Duration(milliseconds: 300), () => _search(term));
  }

  Future<void> _search(String term) async {
    setState(() => _searching = true);
    try {
      final result =
          await SiteProxyService.getUserProxy().searchUserAsync(term, 1, 10);
      if (!mounted || term != _currentTerm()) return;
      final picked = {for (final u in _selected) u.username.toLowerCase()};
      setState(() {
        _suggestions = result.list
            .where((u) => !picked.contains(u.username.toLowerCase()))
            .toList();
      });
    } catch (_) {
      // Suggestions are best-effort — typing a raw username still works.
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _pick(FCSearchUser user) {
    setState(() {
      _selected.add(user);
      // Keep any comma-separated names typed before the current
      // fragment; only the fragment was consumed by the pick.
      final raw = _input.text;
      _input.text =
          raw.contains(',') ? raw.substring(0, raw.lastIndexOf(',') + 1) : '';
      _suggestions = const [];
    });
  }

  Future<void> _create() async {
    final usernames = <String>[];
    final seen = <String>{};
    void addName(String name) {
      final n = name.trim().replaceFirst(RegExp(r'^@'), '');
      if (n.isEmpty || !seen.add(n.toLowerCase())) return;
      usernames.add(n);
    }

    for (final u in _selected) {
      addName(u.username);
    }
    for (final part in _input.text.split(RegExp(r'[,\s]+'))) {
      addName(part);
    }
    if (usernames.isEmpty) {
      setState(() => _error = 'Enter at least one username.');
      return;
    }
    final proxy = SiteProxyService.getChatProxy();
    if (proxy is! DiscourseChatProxy) {
      setState(() => _error = 'Direct messages are not available.');
      return;
    }
    setState(() {
      _creating = true;
      _error = null;
    });
    try {
      final result = await proxy.createDirectMessageChannelAsync(
        usernames,
        // Reuse an existing group DM with the same member set instead
        // of minting a duplicate (1:1 DMs are reused automatically).
        upsert: usernames.length > 1,
      );
      if (!mounted) return;
      final channel = result.channel;
      if (!result.result || channel == null) {
        setState(() {
          _creating = false;
          _error = result.resultText?.isNotEmpty == true
              ? result.resultText
              : 'Could not start the direct message.';
        });
        return;
      }
      Navigator.of(context).pop(channel);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _creating = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canCreate = !_creating &&
        (_selected.isNotEmpty || _input.text.trim().isNotEmpty);

    return Padding(
      padding: EdgeInsets.only(
        left: DesignTokens.spacingM,
        right: DesignTokens.spacingM,
        top: DesignTokens.spacingM,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + DesignTokens.spacingM,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'New direct message',
            style:
                textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: DesignTokens.spacingM),
          if (_selected.isNotEmpty) ...[
            Wrap(
              spacing: DesignTokens.spacingXS,
              runSpacing: DesignTokens.spacingXS,
              children: [
                for (final u in _selected)
                  InputChip(
                    avatar: UserAvatar(
                      username: u.username,
                      iconUrl: u.iconUrl,
                      radius: 12,
                    ),
                    label: Text(u.username),
                    onDeleted: _creating
                        ? null
                        : () => setState(() => _selected.remove(u)),
                  ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacingS),
          ],
          TextField(
            controller: _input,
            autofocus: true,
            enabled: !_creating,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _create(),
            decoration: InputDecoration(
              hintText: _selected.isEmpty
                  ? 'Type a username…'
                  : 'Add another username…',
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              ),
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
          ),
          if (_suggestions.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.spacingXS),
            for (final u in _suggestions.take(5))
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacingS),
                leading: UserAvatar(
                  username: u.username,
                  iconUrl: u.iconUrl,
                  radius: 14,
                ),
                title: Text(u.username),
                onTap: () => _pick(u),
              ),
          ],
          if (_error != null) ...[
            const SizedBox(height: DesignTokens.spacingS),
            Text(
              _error!,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
            ),
          ],
          const SizedBox(height: DesignTokens.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed:
                    _creating ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: DesignTokens.spacingS),
              FilledButton(
                onPressed: canCreate ? _create : null,
                child: _creating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Start chat'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
