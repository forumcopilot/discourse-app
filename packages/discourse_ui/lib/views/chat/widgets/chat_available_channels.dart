import 'package:discourse_core/discourse_core.dart';
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../services/site_proxy_service.dart';
import '../../../theme/design_tokens.dart';
import '../../../utils/snackbar_helper.dart';
import 'chat_channel_avatar.dart';

/// Discovery stays independent of joined chats and their unread tracking.
class ChatAvailableChannels extends StatefulWidget {
  const ChatAvailableChannels(
      {super.key,
      required this.siteContext,
      required this.joinedIds,
      required this.revision,
      required this.onOpen,
      required this.onJoined});
  final SiteContext siteContext;
  final Set<int> joinedIds;
  final int revision;
  final Future<void> Function(FCChatChannel) onOpen;
  final void Function(FCChatChannel) onJoined;
  @override
  State<ChatAvailableChannels> createState() => _ChatAvailableChannelsState();
}

class _ChatAvailableChannelsState extends State<ChatAvailableChannels> {
  static const _pageSize = 25;
  final Map<int, FCChatChannel> _channels = {};
  final Set<int> _joining = {};
  bool _loading = true;
  bool _hasMore = false;
  int _offset = 0;
  int _generation = 0;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(ChatAvailableChannels oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.revision != widget.revision) _load();
  }

  Future<void> _load({bool more = false}) async {
    final proxy = SiteProxyService.getChatProxy();
    if (proxy is! DiscourseChatProxy) return;
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await proxy.browseChannelsAsync(
          offset: more ? _offset : 0, limit: _pageSize);
      if (!mounted || generation != _generation) return;
      setState(() {
        _loading = false;
        if (!result.result) {
          _error = result.resultText?.isNotEmpty == true
              ? result.resultText
              : AppLocalizations.of(context)!.chatNotAvailable;
          return;
        }
        if (!more) {
          _channels.clear();
          _offset = 0;
        }
        _offset += result.channels.length;
        for (final channel in result.channels) {
          // Never offer private conversations as discoverable channels.
          if (channel.chatableType != 'DirectMessage') {
            _channels[channel.id] = channel;
          }
        }
        _hasMore = result.channels.length >= _pageSize;
      });
    } catch (e) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  Future<void> _join(FCChatChannel channel) async {
    if (_joining.contains(channel.id)) return;
    final proxy = SiteProxyService.getChatProxy();
    if (proxy is! DiscourseChatProxy) return;
    setState(() => _joining.add(channel.id));
    final result = await proxy.joinChannelAsync(channel.id);
    if (!mounted) return;
    setState(() => _joining.remove(channel.id));
    if (result.result) {
      channel.isFollowing = true;
      widget.onJoined(channel);
    } else {
      SnackbarHelper.showError(
          context,
          result.resultText?.isNotEmpty == true
              ? result.resultText!
              : AppLocalizations.of(context)!.chatNotAvailable);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final available = _channels.values
        .where((c) => !widget.joinedIds.contains(c.id) && !c.isFollowing)
        .toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: DesignTokens.spacingL),
      const Divider(height: 1),
      Container(
          color: colors.surfaceContainerLow,
          padding: const EdgeInsets.all(DesignTokens.spacingL),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Semantics(
                header: true,
                child:
                    Text(l10n.chatAvailableChannels, style: text.titleSmall)),
            const SizedBox(height: DesignTokens.spacingXS),
            Text(l10n.chatAvailableChannelsDescription,
                style:
                    text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
          ])),
      for (final channel in available) _tile(channel),
      if (_error != null)
        Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingL),
            child: Column(children: [
              Text(_error!),
              TextButton(
                  onPressed:
                      _loading ? null : () => _load(more: _channels.isNotEmpty),
                  child: Text(l10n.retry))
            ])),
      if (_loading)
        const Padding(
            padding: EdgeInsets.all(DesignTokens.spacingL),
            child: Center(child: CircularProgressIndicator()))
      else if (_error == null && _hasMore)
        Center(
            child: TextButton(
                onPressed: () => _load(more: true), child: Text(l10n.loadMore)))
      else if (_error == null && available.isEmpty)
        Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingL),
            child: Text(
                widget.joinedIds.isEmpty
                    ? l10n.chatNoChannelsFound
                    : l10n.chatAllChannelsJoined,
                style:
                    text.bodyMedium?.copyWith(color: colors.onSurfaceVariant))),
    ]);
  }

  Widget _tile(FCChatChannel channel) {
    final l10n = AppLocalizations.of(context)!;
    final details =
        DiscourseChatChannelDetails.of(widget.siteContext.site.url, channel.id);
    final busy = _joining.contains(channel.id);
    final canJoin = channel.canJoin && !channel.isClosed && !channel.isArchived;
    final action = busy
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2))
        : canJoin
            ? FilledButton.tonal(
                onPressed: () => _join(channel), child: Text(l10n.chatJoin))
            : TextButton(
                onPressed: () => widget.onOpen(channel),
                child: Text(l10n.chatViewChannel));
    return LayoutBuilder(builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final stacked = constraints.maxWidth / scale < 320;
      return ListTile(
        key: ValueKey('available-channel-${channel.id}'),
        onTap: () => widget.onOpen(channel),
        leading: ChatChannelAvatar(
            channel: channel,
            details: details,
            siteContext: widget.siteContext),
        title:
            Text(channel.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (channel.description?.isNotEmpty == true)
                Text(channel.description!,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              Text(l10n.chatMembersCount(details?.membershipsCount ?? 0)),
              if (!channel.isOpen)
                Text(channel.isArchived
                    ? l10n.chatFilterArchived
                    : channel.isClosed
                        ? l10n.chatFilterClosed
                        : l10n.chatPlaceholderReadOnly),
              if (stacked)
                Padding(
                  padding: const EdgeInsets.only(top: DesignTokens.spacingS),
                  child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: action),
                ),
            ]),
        trailing: stacked ? null : action,
      );
    });
  }
}
