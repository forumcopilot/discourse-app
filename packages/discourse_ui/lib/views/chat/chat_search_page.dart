import 'dart:async';

import 'package:discourse_core/discourse_core.dart'
    show DiscourseChatChannelDetails, DiscourseChatMessageExtras, DiscourseChatProxy, stripHtmlToText;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_message.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../services/site_proxy_service.dart';
import '../../theme/design_tokens.dart';
import '../../utils/chat_time.dart';
import '../../utils/emoji_shortcodes.dart';
import '../widgets/user_avatar.dart';
import 'chat_channel_view.dart' show ChatChannelScreen;

/// Searching chat messages, as Discourse's chat search: across the reader's
/// channels from the chat list, or in one channel from its header. A result
/// opens its conversation at the message (in its thread, for a reply in
/// one). The app had no way to find an old chat message.
class ChatSearchPage extends StatefulWidget {
  const ChatSearchPage({super.key, required this.siteContext, this.channelId, this.channelTitle});

  final SiteContext siteContext;

  /// Search only this channel.
  final int? channelId;
  final String? channelTitle;

  @override
  State<ChatSearchPage> createState() => _ChatSearchPageState();
}

class _ChatSearchPageState extends State<ChatSearchPage> {
  final _query = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;
  List<({FCChatMessage message, String channelTitle})> _results = const [];
  String _searched = '';
  bool _loading = false;
  bool _hasMore = false;
  String? _error;

  /// Bumped per search, so a slow answer to an older query is dropped.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_hasMore && !_loading && _scroll.position.extentAfter < 400) _search(_searched, more: true);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(text.trim()));
  }

  Future<void> _search(String q, {bool more = false}) async {
    final proxy = SiteProxyService.getChatProxy();
    if (proxy is! DiscourseChatProxy) return;
    if (q.length < 2) {
      _generation++;
      setState(() {
        _results = const [];
        _searched = '';
        _hasMore = false;
        _error = null;
        _loading = false;
      });
      return;
    }
    final generation = more ? _generation : ++_generation;
    setState(() => _loading = true);
    final r = await proxy.searchChatAsync(q,
        channelId: widget.channelId, offset: more ? _results.length : 0);
    if (!mounted || generation != _generation) return;
    setState(() {
      _loading = false;
      _searched = q;
      _error = r.result ? null : r.resultText;
      _results = more ? [..._results, ...r.messages] : r.messages;
      _hasMore = r.result && r.hasMore;
    });
  }

  void _open(FCChatMessage m) {
    final site = widget.siteContext.site.url;
    // A reply in a thread shows only in its thread, where threads are on.
    final threaded = DiscourseChatChannelDetails.of(site, m.channelId)?.threadingEnabled ?? false;
    final startsThread = DiscourseChatMessageExtras.of(site, m.id)?.thread?.threadId == m.threadId;
    final inThread = threaded && m.threadId != null && !startsThread;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ChatChannelScreen(
        siteContext: widget.siteContext,
        channelId: m.channelId,
        threadId: inThread ? m.threadId : null,
        targetMessageId: m.id,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final Widget body;
    if (_error != null && _results.isEmpty) {
      body = _Message(text: _error!.isEmpty ? l10n.chatNotAvailable : _error!);
    } else if (_results.isEmpty && _loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_results.isEmpty && _searched.isNotEmpty) {
      body = _Message(text: l10n.chatSearchNoResults);
    } else {
      body = ListView.separated(
        controller: _scroll,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: _results.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, i) {
          if (i >= _results.length) {
            return const Padding(
              padding: EdgeInsets.all(DesignTokens.spacingL),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            );
          }
          final (:message, :channelTitle) = _results[i];
          final text = withEmojiShortcodes(
                  stripHtmlToText(message.cooked.isNotEmpty ? message.cooked : message.message))
              .trim();
          return InkWell(
            onTap: () => _open(message),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingM),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(
                    username: message.authorUsername,
                    iconUrl: message.authorAvatarUrl?.isEmpty ?? true ? null : message.authorAvatarUrl,
                    radius: 20,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(message.authorUsername,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                            ),
                            if (widget.channelId == null && channelTitle.isNotEmpty) ...[
                              const SizedBox(width: DesignTokens.spacingS),
                              Flexible(
                                child: Text(channelTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                              ),
                            ],
                            const Spacer(),
                            Text(formatChatListTime(context, message.createdAt),
                                style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(text, maxLines: 3, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    final scope = widget.channelTitle;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _query,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: widget.channelId != null && scope != null && scope.isNotEmpty
                ? '${l10n.chatSearchMessagesHint} · $scope'
                : l10n.chatSearchMessagesHint,
            border: InputBorder.none,
          ),
          onChanged: _onChanged,
          onSubmitted: (q) {
            _debounce?.cancel();
            _search(q.trim());
          },
        ),
        actions: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _query,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                    onPressed: () {
                      _query.clear();
                      _search('');
                    },
                  ),
          ),
        ],
      ),
      body: body,
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingXXL),
          child: Text(text,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
      );
}
