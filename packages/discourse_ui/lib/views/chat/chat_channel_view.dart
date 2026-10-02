import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscourseChatMessageExtras, DiscourseChatPermissions, DiscourseSiteContextExtension;
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../widgets/empty_state_view.dart';
import '../../utils/error_message.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_channel.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_message.dart';
import 'package:get/get.dart';

import '../../controllers/chat_channel_controller.dart';
import '../../services/attachment_upload_service.dart';
import '../../theme/design_tokens.dart';
import 'widgets/chat_composer.dart';
import 'widgets/chat_message_row.dart';
import 'widgets/chat_reaction_chips.dart';
import '../widgets/reaction_glyph.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/app_l10n.dart';

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

  /// Whether the reader is at the newest message, so the list should stay
  /// there as the content below grows — an image or reaction laying out
  /// after the scroll to a new message used to leave it half off screen.
  bool _atBottom = true;

  /// The target message's row, for scrolling to it.
  final _targetKey = GlobalKey();

  /// The message shown highlighted, briefly, after jumping to it.
  int? _highlightedId;

  /// Whether the first position (the unread line, a notified message, or
  /// the newest) has been taken; later arrivals only follow a reader who is
  /// at the newest message.
  bool _positioned = false;

  /// The "last visit" line, for opening there.
  final _unreadKey = GlobalKey();

  /// Shown while the reader is away from the newest message: the jump
  /// button, with how many messages arrived meanwhile.
  final _awayFromBottom = ValueNotifier<bool>(false);
  final _arrivedWhileAway = ValueNotifier<int>(0);

  int? get _myId => int.tryParse(widget.siteContext.currentUserId ?? '');

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
    // The first position waits for the first load to settle (the unread
    // line may need the messages around it); later arrivals follow the
    // reader only when they are at the newest message. A new message used to
    // pull the list to the bottom even while the reader was reading back.
    ever<bool>(_controller.isLoadingInitial, (loading) {
      if (!loading && !_positioned && _controller.messages.isNotEmpty) _takeFirstPosition();
    });
    ever<List>(_controller.messages, (list) {
      if (list.isEmpty) return;
      final last = list.last as FCChatMessage;
      final previous = _lastAutoScrolledId;
      if (last.id <= previous) return;
      _lastAutoScrolledId = last.id;
      if (!_positioned) {
        if (!_controller.isLoadingInitial.value) _takeFirstPosition();
        return;
      }
      if (_atBottom || last.authorId == _myId) {
        _scrollToBottom();
      } else {
        _arrivedWhileAway.value += list
            .cast<FCChatMessage>()
            .where((m) => m.id > previous && m.authorId != _myId)
            .length;
      }
    });
    _scroll.addListener(_onScroll);
  }

  void _takeFirstPosition() {
    _positioned = true;
    final list = _controller.messages;
    if (list.isEmpty) return;
    _lastAutoScrolledId = list.last.id;
    final target = widget.targetMessageId;
    if (target != null) {
      final index = list.indexWhere((m) => m.id == target);
      if (index >= 0) {
        _setAtBottom(false);
        _jumpTo(index, list.length, target);
        return;
      }
    }
    final unread = _controller.firstUnreadId.value;
    if (unread != null) {
      final index = list.indexWhere((m) => m.id == unread);
      if (index > 0) {
        _setAtBottom(false);
        _jumpTo(index, list.length, null, key: _unreadKey, alignment: 0.15);
        return;
      }
    }
    _scrollToBottom(jump: true);
  }

  void _setAtBottom(bool value) {
    _atBottom = value;
    _awayFromBottom.value = !value || _controller.hasMoreNewer.value;
    if (value && !_controller.hasMoreNewer.value) _arrivedWhileAway.value = 0;
  }

  void _scrollToBottom({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final max = _scroll.position.maxScrollExtent;
      if (jump) {
        _scroll.jumpTo(max);
      } else {
        _scroll.animateTo(max, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
      _setAtBottom(true);
    });
  }

  /// The jump button: to the newest message, loading it first when the
  /// conversation opened further back.
  Future<void> _jumpToLatest() async {
    if (_controller.hasMoreNewer.value) await _controller.jumpToLatest();
    _arrivedWhileAway.value = 0;
    _scrollToBottom();
  }

  /// A reply's preview: go to the message it answers, when it is loaded.
  void _goToMessage(int id) {
    final list = _controller.messages;
    final index = list.indexWhere((m) => m.id == id);
    if (index < 0) return;
    _setAtBottom(false);
    _jumpTo(index, list.length, id);
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
  void _jumpTo(int index, int count, int? id, {GlobalKey? key, double alignment = 0.3}) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_scroll.hasClients) return;
      final max = _scroll.position.maxScrollExtent;
      _scroll.jumpTo(count <= 1 ? 0 : max * index / (count - 1));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final ctx = (key ?? (id == widget.targetMessageId ? _targetKey : _rowKey(id))).currentContext;
      if (ctx != null && ctx.mounted) {
        await Scrollable.ensureVisible(ctx,
            alignment: alignment, duration: const Duration(milliseconds: 200));
      }
      if (!mounted || id == null) return;
      setState(() => _highlightedId = id);
      await Future<void>.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _highlightedId = null);
    });
  }

  void _onScroll() {
    final position = _scroll.position;
    // Only the reader's own scrolling moves them off (or back onto) the
    // newest message; growth below them does not.
    if (position.userScrollDirection != ScrollDirection.idle) {
      _setAtBottom(position.pixels >= position.maxScrollExtent - 48);
    }
    // Scrolling down from an unread line or a notified message: the next
    // messages load as the end comes near.
    if (_controller.hasMoreNewer.value &&
        position.pixels >= position.maxScrollExtent - 300 &&
        !_controller.isLoadingNewer.value) {
      _controller.loadNewer();
    }
    // Load older messages when the reader scrolls up to near the top. Only a
    // scroll toward the start counts: with fewer messages than fill the
    // screen the list always sits at the top, and the automatic scroll to a
    // newly arrived message asked for older ones every time.
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
    _awayFromBottom.dispose();
    _arrivedWhileAway.dispose();
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
            final entries = _entries();
            return Stack(
              children: [
                NotificationListener<ScrollMetricsNotification>(
                  onNotification: (n) {
                    // Content grew under a reader at the newest message: keep
                    // them there.
                    final p = n.metrics;
                    if (_atBottom &&
                        _positioned &&
                        _scroll.hasClients &&
                        p.pixels < p.maxScrollExtent) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scroll.hasClients && _atBottom) {
                          _scroll.jumpTo(_scroll.position.maxScrollExtent);
                        }
                      });
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
                    itemCount: entries.length +
                        (_controller.isLoadingOlder.value ? 1 : 0) +
                        (_controller.isLoadingNewer.value ? 1 : 0),
                    itemBuilder: (_, i) {
                      final older = _controller.isLoadingOlder.value ? 1 : 0;
                      if ((older == 1 && i == 0) || i - older >= entries.length) {
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
                      return _buildEntry(entries[i - older], theme);
                    },
                  ),
                ),
                Positioned(
                  right: DesignTokens.spacingL,
                  bottom: DesignTokens.spacingM,
                  child: _JumpToLatest(
                    away: _awayFromBottom,
                    arrived: _arrivedWhileAway,
                    pending: _controller.pendingNewer,
                    onTap: _jumpToLatest,
                  ),
                ),
              ],
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
            onSend: (text, uploadIds) =>
                _controller.send(text, uploadIds: uploadIds),
            onUpload: ch != null &&
                    !readonly &&
                    widget.siteContext.chatAllowUploads
                ? _upload
                : null,
          );
        }),
      ],
    );
  }

  final Map<int, GlobalKey> _rowKeys = {};
  GlobalKey _rowKey(int? id) => _rowKeys.putIfAbsent(id ?? -1, GlobalKey.new);

  /// The conversation as Discourse lays it out: a line for each day, the
  /// "last visit" line before the first unread message, and each message
  /// with its avatar and name only when it starts a run.
  List<_Entry> _entries() {
    final list = _controller.messages;
    final unreadId = _controller.firstUnreadId.value;
    final out = <_Entry>[];
    FCChatMessage? previous;
    for (final m in list) {
      final day = m.createdAt.toLocal();
      final newDay = previous == null ||
          previous.createdAt.toLocal().day != day.day ||
          previous.createdAt.toLocal().month != day.month ||
          previous.createdAt.toLocal().year != day.year;
      if (newDay) out.add(_DayEntry(DateTime(day.year, day.month, day.day)));
      final unreadLine = m.id == unreadId;
      if (unreadLine) out.add(const _UnreadEntry());
      final replyTo = DiscourseChatMessageExtras.of(widget.siteContext.site.url, m.id)?.replyTo;
      final continues = !newDay && !unreadLine && chatMessageContinuesRun(previous, m, replyTo: replyTo);
      out.add(_MessageEntry(m, showHeader: !continues));
      previous = m;
    }
    return out;
  }

  Widget _buildEntry(_Entry entry, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    switch (entry) {
      case _DayEntry(:final day):
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final label = day == today
            ? l10n.chatToday
            : day == today.subtract(const Duration(days: 1))
                ? l10n.chatYesterday
                : DateFormat.yMMMMEEEEd(Localizations.localeOf(context).toLanguageTag()).format(day);
        return _Separator(label: label, color: theme.colorScheme.onSurfaceVariant, line: theme.colorScheme.outlineVariant);
      case _UnreadEntry():
        return KeyedSubtree(
          key: _unreadKey,
          child: _Separator(label: l10n.chatLastVisit, color: theme.colorScheme.error, line: theme.colorScheme.error),
        );
      case _MessageEntry(:final message, :final showHeader):
        return _buildMessage(message, showHeader, theme);
    }
  }

  Widget _buildMessage(FCChatMessage m, bool showHeader, ThemeData theme) {
    final isSelf = _myId != null && m.authorId == _myId;
    // Discourse's rules (see DiscourseChatPermissions): only in a channel
    // the viewer may write in; edit your own; delete your own or, as a
    // moderator, anyone's. Reactions follow the same rule: they ignored a
    // closed channel and a silenced reader.
    final perms = _permissions;
    final status = _controller.channel.value?.status ?? 'open';
    final canWrite = perms?.canWriteIn(status) ?? (status == 'open');
    final canEdit = canWrite && isSelf;
    final canDelete = canWrite &&
        (isSelf ? (perms?.canDeleteSelf ?? true) : (perms?.canDeleteOthers ?? false));
    final loggedIn = widget.siteContext.isLoggedIn;
    final isTarget = m.id == widget.targetMessageId;
    final row = ChatMessageRow(
      message: m,
      siteContext: widget.siteContext,
      showHeader: showHeader,
      highlighted: m.id == _highlightedId,
      onLongPress: loggedIn ? () => _showMessageActions(m, canEdit: canEdit, canDelete: canDelete) : null,
      onToggleReaction: loggedIn && canWrite
          ? (emoji, {required bool add}) => _controller.toggleReaction(m.id, emoji, add: add)
          : null,
      onReplyTap: _goToMessage,
    );
    // What the reader has seen on screen is what counts as read.
    return VisibilityDetector(
      key: ValueKey('chat-seen-${widget.channelId}-${m.id}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction >= 0.5) _controller.noteSeen(m.id);
      },
      child: KeyedSubtree(key: isTarget ? _targetKey : _rowKey(m.id), child: row),
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

  /// Uploads a file picked in the composer as a chat upload; says why when
  /// it could not.
  Future<int?> _upload(XFile file, int alreadyAttached) async {
    final outcome = await AttachmentUploadService.upload(
      context: context,
      file: file,
      uploadType: 'chat',
      targetId: '${widget.channelId}',
      groupId: '',
      currentAttachmentCount: alreadyAttached,
    );
    if (outcome.cancelled) return null;
    final id = outcome.uploadId;
    if (!outcome.succeeded || id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(outcome.errorMessage ??
              AppLocalizations.of(context)!.failedToUploadFilePleaseTryAgain),
        ));
      }
      return null;
    }
    return id;
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
                        child: ReactionGlyph(
                            reactionId: emoji, size: 24, siteContext: widget.siteContext),
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
  return '#${ch.title.isNotEmpty ? ch.title : appL10n().chatChannelNumbered(ch.id)}';
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

sealed class _Entry {
  const _Entry();
}

class _DayEntry extends _Entry {
  const _DayEntry(this.day);
  final DateTime day;
}

class _UnreadEntry extends _Entry {
  const _UnreadEntry();
}

class _MessageEntry extends _Entry {
  const _MessageEntry(this.message, {required this.showHeader});
  final FCChatMessage message;
  final bool showHeader;
}

/// A centred label between two rules: a day, or where the unread begins.
class _Separator extends StatelessWidget {
  const _Separator({required this.label, required this.color, required this.line});

  final String label;
  final Color color;
  final Color line;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingS),
      child: Row(
        children: [
          Expanded(child: Divider(color: line, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingS),
            child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color)),
          ),
          Expanded(child: Divider(color: line, height: 1)),
        ],
      ),
    );
  }
}

/// Back to the newest message, shown while the reader is away from it:
/// "N new messages" when some arrived meanwhile, an arrow otherwise.
class _JumpToLatest extends StatelessWidget {
  const _JumpToLatest({
    required this.away,
    required this.arrived,
    required this.pending,
    required this.onTap,
  });

  final ValueNotifier<bool> away;
  final ValueNotifier<int> arrived;
  final RxInt pending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<bool>(
      valueListenable: away,
      builder: (context, isAway, _) {
        if (!isAway) return const SizedBox.shrink();
        return ValueListenableBuilder<int>(
          valueListenable: arrived,
          builder: (context, count, _) => Obx(() {
            final total = count + pending.value;
            if (total > 0) {
              return FloatingActionButton.extended(
                heroTag: null,
                onPressed: onTap,
                icon: const Icon(Icons.arrow_downward),
                label: Text(l10n.chatNewMessagesCount(total)),
              );
            }
            return FloatingActionButton.small(
              heroTag: null,
              tooltip: l10n.chatScrollToBottom,
              onPressed: onTap,
              child: const Icon(Icons.arrow_downward),
            );
          }),
        );
      },
    );
  }
}
