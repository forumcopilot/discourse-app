import 'dart:async';

import 'package:discourse_core/discourse_core.dart'
    show DiscourseChatProxy, DiscourseChatSettings;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_channel.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../services/site_proxy_service.dart';
import '../../theme/design_tokens.dart';
import '../../utils/snackbar_helper.dart';
import '../widgets/empty_state_view.dart';
import 'chat_channel_view.dart';
import 'widgets/chat_channel_browse_tile.dart';
import 'widgets/chat_channel_pages.dart';

/// The forum's public channels, to find, join and leave, as Discourse's
/// "Browse channels" (routes chat.browse.*): a search by name, the web's
/// status tabs (All, Open, Closed, and Archived where the forum archives
/// channels), opening on Open, and each channel with its description,
/// member count and Join or Leave, a page at a time.
///
/// It is also where a channel the reader follows turns up once it is no
/// longer open: Discourse lists only open channels in the reader's chats
/// (`/chat/api/me/channels`), so a followed channel closed or archived
/// since is found under Closed, Archived or All, opened and left there.
class ChatBrowseChannelsPage extends StatefulWidget {
  const ChatBrowseChannelsPage({super.key, required this.siteContext});

  final SiteContext siteContext;

  @override
  State<ChatBrowseChannelsPage> createState() => _ChatBrowseChannelsPageState();
}

class _ChatBrowseChannelsPageState extends State<ChatBrowseChannelsPage> {
  final _search = TextEditingController();
  final _pages = ChatChannelPages(status: 'open');
  final Set<int> _busy = {};
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _pages.ensureLoaded();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _pages.dispose();
    super.dispose();
  }

  void _onSearch(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted || _pages.filter == text.trim()) return;
      _pages.filter = text.trim();
      unawaited(_pages.reload());
    });
  }

  void _show(String? status) {
    if (_pages.status == status) return;
    _pages.status = status;
    unawaited(_pages.reload());
  }

  Future<void> _toggleMembership(FCChatChannel ch) async {
    final proxy = SiteProxyService.getChatProxy();
    if (proxy is! DiscourseChatProxy || _busy.contains(ch.id)) return;
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
    final archiving = DiscourseChatSettings.forSite(widget.siteContext.site.url)
        .archivingAllowed;
    // The web's tabs, in its order (`all` is no status filter).
    final filters = <(String?, String)>[
      (null, l10n.chatFilterAll),
      ('open', l10n.chatFilterOpen),
      ('closed', l10n.chatFilterClosed),
      if (archiving) ('archived', l10n.chatFilterArchived),
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
          ListenableBuilder(
            listenable: _pages,
            builder: (context, _) => SingleChildScrollView(
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
                        selected: _pages.status == status,
                        showCheckmark: false,
                        onSelected: (_) => _show(status),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: _pages,
              builder: (context, _) => _buildList(l10n),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(AppLocalizations l10n) {
    final channels = _pages.channels;
    final error = _pages.error;
    if (channels.isEmpty) {
      if (_pages.loading || !_pages.loaded && error == null) {
        return const Center(child: CircularProgressIndicator());
      }
      if (error != null) {
        return EmptyStateView.error(
            message: error.isNotEmpty ? error : l10n.chatNotAvailable,
            onRetry: _pages.retry);
      }
      return EmptyStateView(icon: Icons.tag, message: l10n.chatNoChannelsFound);
    }
    final more = _pages.hasMore || _pages.loading || error != null;
    return ListView.builder(
      itemCount: channels.length + (more ? 1 : 0),
      itemBuilder: (context, i) {
        if (i < channels.length) {
          final ch = channels[i];
          return ChatChannelBrowseTile(
            channel: ch,
            siteContext: widget.siteContext,
            busy: _busy.contains(ch.id),
            onOpen: () => _open(ch),
            onJoin: () => _toggleMembership(ch),
            onLeave: () => _toggleMembership(ch),
          );
        }
        if (error != null && !_pages.loading) {
          return Center(
            child: TextButton(onPressed: _pages.retry, child: Text(l10n.retry)),
          );
        }
        // The end of the list is in sight: read the next page, after this
        // frame (not while the list is being laid out).
        if (!_pages.loading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) unawaited(_pages.loadMore());
          });
        }
        return const Padding(
          padding: EdgeInsets.all(DesignTokens.spacingL),
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
