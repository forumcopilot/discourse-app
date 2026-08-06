import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_message.dart';
import 'package:get/get.dart';

import '../../controllers/chat_channel_controller.dart';
import '../../theme/design_tokens.dart';
import 'widgets/chat_composer.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/chat_reaction_chips.dart';

/// Embeds a single Discourse Chat channel — message list + composer —
/// without its own Scaffold/AppBar so it can plug into a tab body or
/// a full-page route equally. Polling pauses when [isActive] is false.
///
/// Ported from the XenForo app's Siropu chat room view, with the Siropu
/// API swapped out for Discourse Chat.
class ChatChannelView extends StatefulWidget {
  const ChatChannelView({
    super.key,
    required this.siteContext,
    required this.channelId,
    this.isActive = true,
  });

  final SiteContext siteContext;
  final int channelId;
  final bool isActive;

  @override
  State<ChatChannelView> createState() => _ChatChannelViewState();
}

class _ChatChannelViewState extends State<ChatChannelView> {
  late final ChatChannelController _controller;
  final _scroll = ScrollController();

  /// Newest message id we already auto-scrolled for. The controller
  /// fires the messages listener on every poll tick (it calls
  /// `messages.refresh()` so reaction chips stay fresh), so only
  /// scroll when a genuinely newer message arrived.
  int _lastAutoScrolledId = 0;

  String get _tag => 'chatChannel-${widget.channelId}';

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      ChatChannelController(channelId: widget.channelId),
      tag: _tag,
    );
    if (widget.isActive) {
      _controller.start();
    }
    // Auto-scroll to the bottom whenever new messages arrive.
    ever<List>(_controller.messages, (list) {
      final lastId =
          list.isEmpty ? 0 : (list.last as FCChatMessage).id;
      if (lastId <= _lastAutoScrolledId) return;
      _lastAutoScrolledId = lastId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    });
    _scroll.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant ChatChannelView old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _controller.start();
    } else if (!widget.isActive && old.isActive) {
      _controller.stop();
    }
  }

  void _onScroll() {
    // Load older messages when scrolled near the top.
    if (_scroll.position.pixels <= 50 && !_controller.isLoadingOlder.value) {
      _controller.loadOlder();
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    Get.delete<ChatChannelController>(tag: _tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (_controller.isLoadingInitial.value &&
                _controller.messages.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_controller.messages.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.spacingXXL),
                  child: Text(
                    'No messages yet — say hi.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              );
            }
            final currentUserId =
                widget.siteContext.loginDataOutput?.user?.id;
            return ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(
                  vertical: DesignTokens.spacingS),
              itemCount: _controller.messages.length +
                  (_controller.isLoadingOlder.value ? 1 : 0),
              itemBuilder: (_, i) {
                if (_controller.isLoadingOlder.value && i == 0) {
                  return const Padding(
                    padding: EdgeInsets.all(DesignTokens.spacingS),
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                final idx =
                    i - (_controller.isLoadingOlder.value ? 1 : 0);
                final m = _controller.messages[idx];
                final isSelf =
                    currentUserId != null &&
                    m.authorId.toString() == currentUserId;
                final canEditOrDelete = isSelf;
                final loggedIn = widget.siteContext.isLoggedIn;
                return ChatMessageBubble(
                  message: m,
                  siteContext: widget.siteContext,
                  isSelf: isSelf,
                  // Long-press opens the reaction picker for everyone
                  // logged in; edit/delete rows only for own messages.
                  onLongPress: loggedIn
                      ? () => _showMessageActions(m,
                          canEditOrDelete: canEditOrDelete)
                      : null,
                  onToggleReaction: loggedIn
                      ? (emoji, {required bool add}) =>
                          _controller.toggleReaction(m.id, emoji, add: add)
                      : null,
                );
              },
            );
          }),
        ),
        Obx(() {
          final err = _controller.lastError.value;
          if (err.isEmpty) return const SizedBox.shrink();
          return _ErrorBanner(
              message: err,
              onDismiss: () => _controller.lastError.value = '');
        }),
        Obx(() {
          final ch = _controller.channel.value;
          final readonly = ch != null && !ch.isOpen;
          final isDm = ch?.chatableType == 'DirectMessage';
          return ChatComposer(
            enabled: !readonly,
            hintText: readonly
                ? 'Channel is read-only'
                // DM titles are the member usernames — no '#' prefix.
                : isDm
                    ? 'Message ${ch!.title.isNotEmpty ? ch.title : 'group'}…'
                    : 'Type a message in #${ch?.title ?? 'chat'}…',
            onSend: _controller.send,
          );
        }),
      ],
    );
  }

  void _showMessageActions(FCChatMessage m, {required bool canEditOrDelete}) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Compact reaction picker — Discourse's default reaction set.
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingM,
                vertical: DesignTokens.spacingS,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final emoji in kChatDefaultReactions)
                    InkWell(
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusM),
                      onTap: () {
                        Navigator.pop(context);
                        _controller.toggleReaction(m.id, emoji, add: true);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(DesignTokens.spacingS),
                        child: Text(
                          chatEmojiLabel(emoji),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (canEditOrDelete) ...[
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(m.id, m.message);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete'),
                onTap: () async {
                  Navigator.pop(context);
                  final ok = await _confirmDelete();
                  if (ok) await _controller.deleteMessage(m.id);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete message?'),
        content: const Text('This will remove the message for everyone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showEditDialog(int id, String oldText) {
    final ctrl = TextEditingController(text: oldText);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit message'),
        content: TextField(controller: ctrl, maxLines: 4, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final txt = ctrl.text.trim();
              Navigator.pop(context);
              if (txt.isNotEmpty && txt != oldText) {
                await _controller.edit(id, txt);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingM,
        vertical: DesignTokens.spacingS,
      ),
      color: theme.colorScheme.errorContainer,
      child: Row(
        children: [
          Icon(Icons.error_outline,
              size: 18, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: DesignTokens.spacingS),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onErrorContainer),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: theme.colorScheme.onErrorContainer,
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}
