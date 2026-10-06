import 'dart:async';

import 'package:discourse_core/discourse_core.dart';
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../services/site_proxy_service.dart';
import '../../../theme/design_tokens.dart';
import '../../../utils/snackbar_helper.dart';
import 'chat_channel_browse_tile.dart';
import 'chat_channel_pages.dart';

/// Channels to join, under the joined ones. Its pages ([pages]) belong to
/// the chat list, so they outlive this section; it stays independent of
/// joined chats and their unread tracking.
class ChatAvailableChannels extends StatefulWidget {
  const ChatAvailableChannels(
      {super.key,
      required this.siteContext,
      required this.pages,
      required this.joinedIds,
      required this.onOpen,
      required this.onJoined,
      required this.onBrowse});
  final SiteContext siteContext;
  final ChatChannelPages pages;

  /// The channels in the reader's list: not offered here.
  final Set<int> joinedIds;
  final Future<void> Function(FCChatChannel) onOpen;
  final void Function(FCChatChannel) onJoined;

  /// Opens Browse channels: every channel, by name and status.
  final VoidCallback onBrowse;
  @override
  State<ChatAvailableChannels> createState() => _ChatAvailableChannelsState();
}

class _ChatAvailableChannelsState extends State<ChatAvailableChannels> {
  /// Pages read in a row on their own when each brought nothing to show
  /// (every channel on it already joined), before waiting for Load more.
  static const _maxAutoPages = 3;

  final Set<int> _joining = {};
  int _autoPages = 0;
  int _pagesSeen = 0;

  @override
  void initState() {
    super.initState();
    _pagesSeen = widget.pages.pagesRead;
    widget.pages.addListener(_onPages);
    widget.pages.ensureLoaded();
  }

  @override
  void didUpdateWidget(ChatAvailableChannels oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pages != widget.pages) {
      oldWidget.pages.removeListener(_onPages);
      _pagesSeen = widget.pages.pagesRead;
      _autoPages = 0;
      widget.pages.addListener(_onPages);
      widget.pages.ensureLoaded();
      return;
    }
    // A channel left the reader's list (left elsewhere, or no longer open):
    // read the shown pages again, so it is offered (or not) as it is now.
    // Nothing else needs a request: a joined channel is simply hidden.
    if (oldWidget.joinedIds.difference(widget.joinedIds).isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(widget.pages.refresh());
      });
    }
  }

  @override
  void dispose() {
    widget.pages.removeListener(_onPages);
    super.dispose();
  }

  bool _offered(FCChatChannel c) =>
      !widget.joinedIds.contains(c.id) && !c.isFollowing;

  List<FCChatChannel> get _available =>
      widget.pages.channels.where(_offered).toList();

  /// A page of channels the reader has all joined would leave only "Load
  /// more" to tap: read the next one at once, a few pages at most.
  void _onPages() {
    final pages = widget.pages;
    if (!mounted || pages.pagesRead == _pagesSeen) return;
    _pagesSeen = pages.pagesRead;
    if (pages.lastPage.any(_offered)) {
      _autoPages = 0;
      return;
    }
    if (pages.error != null || !pages.hasMore || _autoPages >= _maxAutoPages) {
      return;
    }
    _autoPages++;
    scheduleMicrotask(() {
      if (mounted) unawaited(pages.loadMore());
    });
  }

  void _loadMore() {
    _autoPages = 0;
    unawaited(widget.pages.loadMore());
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
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: widget.pages, builder: _build);

  Widget _build(BuildContext context, Widget? _) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final pages = widget.pages;
    // In the server's order: sorting each page by name moved the rows
    // already shown whenever another page arrived.
    final available = _available;
    final error = pages.error;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: DesignTokens.spacingL),
      const Divider(height: 1),
      // The way to every channel, searchable and by status, as the web's
      // "Browse channels"; below it the open ones to join from here.
      Material(
        color: colors.surfaceContainerLow,
        child: Semantics(
          button: true,
          child: InkWell(
            onTap: widget.onBrowse,
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingL),
              child: Row(children: [
                Expanded(
                  child: Semantics(
                      header: true,
                      child: Text(l10n.chatBrowseChannels,
                          style: text.titleSmall)),
                ),
                Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
              ]),
            ),
          ),
        ),
      ),
      for (final channel in available)
        ChatChannelBrowseTile(
          channel: channel,
          siteContext: widget.siteContext,
          busy: _joining.contains(channel.id),
          onOpen: () => widget.onOpen(channel),
          onJoin: () => _join(channel),
        ),
      if (error != null)
        Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingL),
            child: Column(children: [
              Text(error.isNotEmpty ? error : l10n.chatNotAvailable),
              TextButton(
                  onPressed: pages.loading ? null : pages.retry,
                  child: Text(l10n.retry))
            ])),
      if (pages.loading)
        const Padding(
            padding: EdgeInsets.all(DesignTokens.spacingL),
            child: Center(child: CircularProgressIndicator()))
      else if (error == null && pages.hasMore)
        Center(
            child: TextButton(onPressed: _loadMore, child: Text(l10n.loadMore)))
      else if (error == null && available.isEmpty)
        // The web's Browse channels says this when it has nothing to list.
        Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingL),
            child: Text(l10n.chatNoChannelsFound,
                style:
                    text.bodyMedium?.copyWith(color: colors.onSurfaceVariant))),
    ]);
  }
}
