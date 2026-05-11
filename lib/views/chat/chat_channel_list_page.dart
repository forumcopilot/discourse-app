import 'package:discourse_core/discourse_core.dart'
    show DiscourseChatChannel, DiscourseChatProxy;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../theme/design_tokens.dart';
import 'chat_channel_view.dart';

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
  State<ChatChannelListPage> createState() => _ChatChannelListPageState();
}

class _ChatChannelListPageState extends State<ChatChannelListPage> {
  List<DiscourseChatChannel>? _channels;
  bool _loading = false;
  String? _error;

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
      final proxy = DiscourseChatProxy.forCurrentSite();
      if (proxy == null) {
        setState(() {
          _channels = const [];
          _loading = false;
          _error = 'Chat is not available on this forum.';
        });
        return;
      }
      final channels = await proxy.getMyChannelsAsync();
      if (!mounted) return;
      setState(() {
        _channels = channels;
        _loading = false;
        if (channels.isEmpty) {
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

  void _open(DiscourseChatChannel ch) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text('#${ch.title}')),
          body: ChatChannelView(
            siteContext: widget.siteContext,
            channelId: ch.id,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = RefreshIndicator(
      onRefresh: _load,
      child: _buildBody(),
    );
    // Embedded mode (Phase 5.18a bottom-nav Chat slot): caller owns
    // the Scaffold + AppBar. We just render the list.
    if (widget.embedded) return body;
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
      body: body,
    );
  }

  Widget _buildBody() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final channels = _channels;

    if (_loading && channels == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if ((channels == null || channels.isEmpty) && _error != null) {
      return ListView(
        padding: const EdgeInsets.all(DesignTokens.spacingL),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline,
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
        ],
      );
    }
    return ListView.separated(
      itemCount: channels?.length ?? 0,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: colorScheme.outlineVariant.withOpacity(0.4),
      ),
      itemBuilder: (_, i) {
        final ch = channels![i];
        return _ChannelTile(channel: ch, onTap: () => _open(ch));
      },
    );
  }
}

class _ChannelTile extends StatelessWidget {
  final DiscourseChatChannel channel;
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
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          _iconFor(),
          color: colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              channel.title,
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
