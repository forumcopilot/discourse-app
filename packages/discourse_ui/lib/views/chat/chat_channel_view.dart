import 'package:flutter/material.dart';
import 'package:discourse_core/discourse_core.dart' show DiscourseChatPermissions;
import '../widgets/empty_state_view.dart';
import '../../utils/error_message.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_channel.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_message.dart';
import 'package:get/get.dart';

import '../../controllers/chat_channel_controller.dart';
import '../../theme/design_tokens.dart';
import 'widgets/chat_composer.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/chat_reaction_chips.dart';
import '../../l10n/generated/app_localizations.dart';

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
    this.targetMessageId,
    this.onChannelLoaded,
  });

  final SiteContext siteContext;
  final int channelId;
  final bool isActive;

  /// Open scrolled to this message, highlighted (from a notification).
  final int? targetMessageId;

  /// Called once the channel's details load, for a title.
  final void Function(FCChatChannel channel)? onChannelLoaded;

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

  /// The target message's row, for scrolling to it.
  final _targetKey = GlobalKey();
  bool _jumpedToTarget = false;

  /// The message shown highlighted, briefly, after jumping to it.
  int? _highlightedId;

  // One controller per view: the same channel opened twice (a notification
  // over the list) used to share one, and closing the top one tore down the
  // one underneath.
  late final String _tag =
      'chatChannel-${widget.channelId}-${identityHashCode(this)}';

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      ChatChannelController(
        channelId: widget.channelId,
        targetMessageId: widget.targetMessageId,
      ),
      tag: _tag,
    );
    ever<FCChatChannel?>(_controller.channel, (ch) {
      if (ch != null) widget.onChannelLoaded?.call(ch);
    });
    if (widget.isActive) {
      _controller.start();
    }
    // Auto-scroll to the bottom whenever new messages arrive.
    ever<List>(_controller.messages, (list) {
      final lastId =
          list.isEmpty ? 0 : (list.last as FCChatMessage).id;
      if (lastId <= _lastAutoScrolledId) return;
      _lastAutoScrolledId = lastId;
      // Opened on a message: go there instead of to the end, once.
      final target = widget.targetMessageId;
      if (target != null && !_jumpedToTarget) {
        final index = list.indexWhere((m) => (m as FCChatMessage).id == target);
        if (index >= 0) {
          _jumpedToTarget = true;
          _jumpTo(index, list.length, target);
          return;
        }
      }
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

  /// Bring the message at [index] into view and highlight it. The list is
  /// built lazily, so first jump to its estimated offset (so its row
  /// exists), then let ensureVisible place it exactly.
  void _jumpTo(int index, int count, int id) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_scroll.hasClients) return;
      final max = _scroll.position.maxScrollExtent;
      _scroll.jumpTo(count <= 1 ? 0 : max * index / (count - 1));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final ctx = _targetKey.currentContext;
      if (ctx != null && ctx.mounted) {
        await Scrollable.ensureVisible(ctx,
            alignment: 0.3, duration: const Duration(milliseconds: 200));
      }
      if (!mounted) return;
      setState(() => _highlightedId = id);
      await Future<void>.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _highlightedId = null);
    });
  }

  void _onScroll() {
    // Load older messages when the reader scrolls up to near the top. Only a
    // scroll toward the start counts: with fewer messages than fill the
    // screen the list always sits at the top, and the automatic scroll to a
    // newly arrived message asked for older ones every time.
    final position = _scroll.position;
    if (position.pixels <= 50 &&
        position.userScrollDirection == ScrollDirection.forward &&
        !_controller.isLoadingOlder.value) {
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
            if (_controller.messages.isEmpty && _controller.loadFailed.value) {
              // Used to fall through to "No messages yet — say hi", which
              // invited writing into a channel that had not loaded.
              return EmptyStateView.error(
                message: describeError(_controller.lastError.value),
                onRetry: _controller.retry,
              );
            }
            if (_controller.messages.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.spacingXXL),
                  child: Text(
                    AppLocalizations.of(context)!.noMessagesYetSayHi,
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
                // Discourse's rules (see DiscourseChatPermissions): only in a
                // channel the viewer may write in; edit your own; delete your
                // own or, as a moderator, anyone's. This offered edit and
                // delete on your own messages everywhere, and nothing else.
                final perms = _permissions;
                final status = _controller.channel.value?.status ?? 'open';
                final canWrite = perms?.canWriteIn(status) ?? (status == 'open');
                final canEdit = canWrite && isSelf;
                final canDelete = canWrite &&
                    (isSelf
                        ? (perms?.canDeleteSelf ?? true)
                        : (perms?.canDeleteOthers ?? false));
                final loggedIn = widget.siteContext.isLoggedIn;
                final bubble = ChatMessageBubble(
                  message: m,
                  siteContext: widget.siteContext,
                  isSelf: isSelf,
                  // Long-press opens the reaction picker for everyone
                  // logged in; edit/delete rows only for own messages.
                  onLongPress: loggedIn
                      ? () => _showMessageActions(m,
                          canEdit: canEdit, canDelete: canDelete)
                      : null,
                  onToggleReaction: loggedIn
                      ? (emoji, {required bool add}) =>
                          _controller.toggleReaction(m.id, emoji, add: add)
                      : null,
                );
                final isTarget = m.id == widget.targetMessageId;
                final highlighted = m.id == _highlightedId;
                if (!isTarget && !highlighted) return bubble;
                return AnimatedContainer(
                  key: isTarget ? _targetKey : null,
                  duration: const Duration(milliseconds: 400),
                  color: highlighted
                      ? theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.5)
                      : Colors.transparent,
                  child: bubble,
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
          // Staff may still post in a closed channel; nobody while silenced.
          final readonly = ch != null &&
              !(_permissions?.canWriteIn(ch.status) ?? ch.isOpen);
          return ChatComposer(
            enabled: !readonly,
            hintText: _composerHint(ch, readonly),
            onSend: _controller.send,
          );
        }),
      ],
    );
  }

  /// Discourse's composer placeholders (chat.placeholder_*): why nothing can
  /// be sent, or where the message goes.
  String _composerHint(FCChatChannel? ch, bool readonly) {
    final l10n = AppLocalizations.of(context)!;
    if (ch == null) return '';
    if (_permissions?.silenced == true) return l10n.chatPlaceholderSilenced;
    if (readonly) {
      return switch (ch.status) {
        'archived' => l10n.chatPlaceholderArchived,
        'closed' => l10n.chatPlaceholderClosed,
        _ => l10n.chatPlaceholderReadOnly,
      };
    }
    if (ch.chatableType == 'DirectMessage') {
      // A DM is titled with the other members; with nobody else it is the
      // viewer's own notes channel.
      final me = widget.siteContext.currentUsername;
      return ch.title.isEmpty || ch.title == me
          ? l10n.chatPlaceholderSelf
          : l10n.chatPlaceholderUsers(ch.title);
    }
    // Discourse names the channel with its hash: "Chat in #general".
    return l10n.chatPlaceholderChannel('#${ch.title}');
  }

  DiscourseChatPermissions? get _permissions => DiscourseChatPermissions.forChannel(
      widget.siteContext.site.url, widget.channelId);

  void _showMessageActions(FCChatMessage m,
      {required bool canEdit, required bool canDelete}) {
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
            if (canEdit || canDelete) const Divider(height: 1),
            if (canEdit)
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(AppLocalizations.of(context)!.edit),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(m.id, m.message);
                },
              ),
            if (canDelete)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(AppLocalizations.of(context)!.delete),
                onTap: () async {
                  Navigator.pop(context);
                  final ok = await _confirmDelete();
                  if (ok) await _controller.deleteMessage(m.id);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        // Discourse's own confirmation. (The old "removes it for everyone"
        // overstated it: a deleted chat message can be restored.)
        content: Text(AppLocalizations.of(context)!.chatDeleteConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.delete),
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
        title: Text(AppLocalizations.of(context)!.edit),
        content: TextField(controller: ctrl, maxLines: 4, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
            onPressed: () async {
              final txt = ctrl.text.trim();
              Navigator.pop(context);
              if (txt.isNotEmpty && txt != oldText) {
                await _controller.edit(id, txt);
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
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

/// How a channel is titled: `#name` for a channel, the members for a DM.
String chatChannelTitle(FCChatChannel ch) {
  if (ch.chatableType == 'DirectMessage') {
    return ch.title;
  }
  return '#${ch.title.isNotEmpty ? ch.title : 'channel ${ch.id}'}';
}

/// A channel as a full screen, titled from the channel once it loads — what
/// the channel list and a chat notification open. The notification list used
/// to title it with the whole notification sentence.
class ChatChannelScreen extends StatefulWidget {
  const ChatChannelScreen({
    super.key,
    required this.siteContext,
    required this.channelId,
    this.initialTitle = '',
    this.targetMessageId,
  });

  final SiteContext siteContext;
  final int channelId;
  final String initialTitle;
  final int? targetMessageId;

  @override
  State<ChatChannelScreen> createState() => _ChatChannelScreenState();
}

class _ChatChannelScreenState extends State<ChatChannelScreen> {
  late String _title = widget.initialTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: ChatChannelView(
        siteContext: widget.siteContext,
        channelId: widget.channelId,
        targetMessageId: widget.targetMessageId,
        onChannelLoaded: (ch) {
          final t = chatChannelTitle(ch);
          if (mounted && t != _title) setState(() => _title = t);
        },
      ),
    );
  }
}
