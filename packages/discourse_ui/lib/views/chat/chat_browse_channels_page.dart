import 'dart:async';

import 'package:discourse_core/discourse_core.dart'
    show DiscourseChatChannelDetails, DiscourseChatProxy;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_channel.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../services/site_proxy_service.dart';
import '../../theme/design_tokens.dart';
import '../../utils/snackbar_helper.dart';
import '../widgets/empty_state_view.dart';
import 'chat_channel_view.dart';
import 'widgets/chat_channel_avatar.dart';

/// The forum's public chat channels, to find and join, as Discourse's
/// "Browse channels": a search by name, All / Open / Closed / Archived, and
/// each channel with its description, member count and Join or Leave.
///
/// The chat list had no way here: a reader who had joined nothing saw
/// "You have not joined any channels yet!" and nothing to tap.
class ChatBrowseChannelsPage extends StatefulWidget {
  const ChatBrowseChannelsPage({super.key, required this.siteContext});

  final SiteContext siteContext;

  @override
  State<ChatBrowseChannelsPage> createState() => _ChatBrowseChannelsPageState();
}

class _ChatBrowseChannelsPageState extends State<ChatBrowseChannelsPage> {
  static const int _pageSize = 25;

  final _search = TextEditingController();
  final List<FCChatChannel> _channels = [];
  final Set<int> _busy = {};
  String? _status;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  String? _error;
  Timer? _debounce;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({bool more = false}) async {
    final proxy = SiteProxyService.getChatProxy();
    if (proxy is! DiscourseChatProxy) {
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context)!.chatNotAvailable;
      });
      return;
    }
    final generation = more ? _generation : ++_generation;
    setState(() {
      if (more) {
        _loadingMore = true;
      } else {
        _loading = true;
        _error = null;
      }
    });
    final result = await proxy.browseChannelsAsync(
      filter: _search.text,
      status: _status,
      offset: more ? _channels.length : 0,
      limit: _pageSize,
    );
    if (!mounted || generation != _generation) return;
    setState(() {
      _loading = false;
      _loadingMore = false;
      if (!result.result) {
        if (!more) _error = result.resultText;
        return;
      }
      if (!more) _channels.clear();
      _channels.addAll(result.channels);
      _hasMore = result.channels.length >= _pageSize;
    });
  }

  void _onSearch(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _load);
  }

  Future<void> _toggleMembership(FCChatChannel ch) async {
    final proxy = SiteProxyService.getChatProxy();
    if (proxy is! DiscourseChatProxy) return;
    setState(() => _busy.add(ch.id));
    final joining = !ch.isFollowing;
    final result = joining
        ? await proxy.joinChannelAsync(ch.id)
        : await proxy.leaveChannelAsync(ch.id);
    if (!mounted) return;
    setState(() {
      _busy.remove(ch.id);
      if (result.result) ch.isFollowing = joining;
    });
    if (!result.result) {
      SnackbarHelper.showError(
          context,
          result.resultText?.isNotEmpty == true
              ? result.resultText!
              : AppLocalizations.of(context)!.chatNotAvailable);
    }
  }

  void _open(FCChatChannel ch) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChatChannelScreen(
        siteContext: widget.siteContext,
        channelId: ch.id,
        initialTitle: '#${ch.title}',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filters = <(String?, String)>[
      (null, l10n.chatFilterAll),
      ('open', l10n.chatFilterOpen),
      ('closed', l10n.chatFilterClosed),
      ('archived', l10n.chatFilterArchived),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatBrowseChannels)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                DesignTokens.spacingL,
                DesignTokens.spacingS,
                DesignTokens.spacingL,
                DesignTokens.spacingXS),
            child: SearchBar(
              controller: _search,
              hintText: l10n.chatBrowseSearch,
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              onChanged: _onSearch,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingL,
                vertical: DesignTokens.spacingS),
            child: Row(
              children: [
                for (final (status, label) in filters)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        end: DesignTokens.spacingS),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _status == status,
                      showCheckmark: false,
                      onSelected: (_) {
                        setState(() => _status = status);
                        _load();
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: _buildList(l10n)),
        ],
      ),
    );
  }

  Widget _buildList(AppLocalizations l10n) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return EmptyStateView.error(message: _error!, onRetry: _load);
    }
    if (_channels.isEmpty) {
      return EmptyStateView(icon: Icons.tag, message: l10n.chatNoChannelsFound);
    }
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ListView.builder(
      itemCount: _channels.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= _channels.length) {
          if (!_loadingMore) _load(more: true);
          return const Padding(
            padding: EdgeInsets.all(DesignTokens.spacingL),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final ch = _channels[i];
        final details =
            DiscourseChatChannelDetails.of(widget.siteContext.site.url, ch.id);
        final members = details?.membershipsCount ?? 0;
        final busy = _busy.contains(ch.id);
        return ListTile(
          onTap: () => _open(ch),
          leading: ChatChannelAvatar(
              channel: ch, details: details, siteContext: widget.siteContext),
          title: Text(ch.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (ch.description?.isNotEmpty == true)
                Text(ch.description!,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              Text(
                l10n.chatMembersCount(members),
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          isThreeLine: ch.description?.isNotEmpty == true,
          trailing: busy
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : ch.isFollowing
                  ? OutlinedButton(
                      onPressed: () => _toggleMembership(ch),
                      child: Text(l10n.chatLeave))
                  : (ch.canJoin
                      ? FilledButton.tonal(
                          onPressed: () => _toggleMembership(ch),
                          child: Text(l10n.chatJoin))
                      : null),
        );
      },
    );
  }
}
