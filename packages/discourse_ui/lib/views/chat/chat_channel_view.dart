import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';
import 'dart:async';

import 'package:discourse_core/discourse_core.dart'
    show
        DiscourseChatChannelDetails,
        DiscourseChatDrafts,
        DiscourseChatMessageExtras,
        DiscourseChatPermissions,
        DiscourseChatProxy,
        DiscourseChatSettings,
        DiscourseChatThread,
        DiscourseChatUser,
        DiscourseSiteContextExtension;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
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
import '../../services/site_proxy_service.dart';
import '../../services/attachment_upload_service.dart';
import '../../theme/design_tokens.dart';
import 'chat_channel_info_page.dart';
import 'chat_search_page.dart';
import 'widgets/chat_channel_avatar.dart';
import 'widgets/chat_composer.dart';
import 'widgets/chat_message_actions.dart';
import 'widgets/chat_message_row.dart';
import '../widgets/discourse_report_dialog.dart';
import '../widgets/emoji_picker_sheet.dart';
import '../../utils/snackbar_helper.dart';
import 'widgets/chat_reaction_chips.dart';
import 'widgets/chat_thread_indicator.dart';
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
    this.threadId,
    this.targetMessageId,
    this.onChannelLoaded,
    this.onThreadLoaded,
  });

  final SiteContext siteContext;
  final int channelId;
  final bool isActive;

  /// Called once the thread loads, in a thread, for its title.
  final void Function(DiscourseChatThread thread)? onThreadLoaded;

  /// Show this thread of the channel instead of the channel: its original
  /// message and replies, with the thread's own composer.
  final int? threadId;

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

  /// The message being replied to or edited in the composer.
  FCChatMessage? _replyTo;
  FCChatMessage? _editing;

  /// Who else is typing here ("X is typing…").
  List<DiscourseChatUser> _typing = const [];
  void Function()? _stopTypingWatch;
  Timer? _draftTimer;

  DiscourseChatProxy? get _discourse {
    final proxy = SiteProxyService.getChatProxy();
    return proxy is DiscourseChatProxy ? proxy : null;
  }

  // One controller per view: the same channel opened twice (a notification
  // over the list) used to share one, and closing the top one tore down the
  // one underneath.
  late final String _tag =
      'chatChannel-${widget.channelId}-${widget.threadId ?? 0}-${identityHashCode(this)}';

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      ChatChannelController(
        channelId: widget.channelId,
        threadId: widget.threadId,
        targetMessageId: widget.targetMessageId,
      ),
      tag: _tag,
    );
    ever<FCChatChannel?>(_controller.channel, (ch) {
      if (ch != null) widget.onChannelLoaded?.call(ch);
    });
    ever<DiscourseChatThread?>(_controller.thread, (t) {
      if (t != null) widget.onThreadLoaded?.call(t);
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
    final discourse = _discourse;
    if (discourse != null && widget.siteContext.isLoggedIn) {
      _stopTypingWatch = discourse.watchTyping(widget.channelId, (typing) {
        if (mounted) setState(() => _typing = typing);
      }, threadId: widget.threadId);
    }
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
    _stopTypingWatch?.call();
    _draftTimer?.cancel();
    unawaited(_discourse?.setTypingAsync(widget.channelId, typing: false, threadId: widget.threadId));
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
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_typing.isNotEmpty) _TypingLine(users: _typing),
              ChatComposer(
                enabled: !readonly,
                hintText: _composerHint(ch, readonly),
                replyTo: _replyTo,
                editing: _editing,
                onCancelContext: () => setState(() {
                  _replyTo = null;
                  _editing = null;
                }),
                initialText:
                    DiscourseChatDrafts.of(widget.siteContext.site.url, widget.channelId, threadId: widget.threadId),
                onTextChanged: _onComposerChanged,
                suggest: _discourse == null ? null : _suggest,
                onSend: _send,
                onUpload: ch != null &&
                        !readonly &&
                        widget.siteContext.chatAllowUploads
                    ? _upload
                    : null,
              ),
            ],
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
      // As the web: no "replying to" line inside a thread, nor over a reply
      // to the message just above it.
      final showReplyTo = widget.threadId == null && (replyTo == null || replyTo.messageId != previous?.id);
      out.add(_MessageEntry(m, showHeader: !continues, showReplyTo: showReplyTo));
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
      case _MessageEntry(:final message, :final showHeader, :final showReplyTo):
        return _buildMessage(message, showHeader, theme, showReplyTo: showReplyTo);
    }
  }

  Widget _buildMessage(FCChatMessage m, bool showHeader, ThemeData theme, {bool showReplyTo = true}) {
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
    final thread = DiscourseChatMessageExtras.of(widget.siteContext.site.url, m.id)?.thread;
    final row = ChatMessageRow(
      message: m,
      siteContext: widget.siteContext,
      showHeader: showHeader,
      highlighted: m.id == _highlightedId,
      onLongPress: loggedIn
          ? () => _showMessageActions(m, canEdit: canEdit, canDelete: canDelete, canWrite: canWrite)
          : null,
      onToggleReaction: loggedIn && canWrite
          ? (emoji, {required bool add}) => _controller.toggleReaction(m.id, emoji, add: add)
          : null,
      onReplyTap: _goToMessage,
      showReplyTo: showReplyTo,
      footer: thread != null && thread.replyCount > 0 && widget.threadId == null
          ? ChatThreadIndicator(preview: thread, onTap: () => _openThread(m))
          : null,
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
    if (widget.threadId != null) return l10n.chatPlaceholderThread;
    if (ch.chatableType == 'DirectMessage' &&
        (DiscourseChatChannelDetails.of(widget.siteContext.site.url, ch.id)?.isGroup ?? false)) {
      return l10n.chatPlaceholderGroup;
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

  /// Sends what the composer holds: an edit of the reader's message, a reply,
  /// or a new message. The draft and "typing" end with it.
  Future<bool> _send(String text, List<int> uploadIds) async {
    final editing = _editing;
    final bool ok;
    if (editing != null) {
      ok = await _controller.edit(editing.id, text);
    } else {
      ok = await _controller.send(text, uploadIds: uploadIds, inReplyTo: _replyTo);
    }
    if (ok && mounted) {
      setState(() {
        _editing = null;
        _replyTo = null;
      });
      _draftTimer?.cancel();
      final discourse = _discourse;
      if (discourse != null && editing == null) {
        unawaited(discourse.saveChatDraftAsync(widget.channelId, '', threadId: widget.threadId));
        unawaited(discourse.setTypingAsync(widget.channelId, typing: false, threadId: widget.threadId));
      }
    }
    return ok;
  }

  /// The draft is kept (on the server, as the web keeps it) a moment after
  /// typing stops, and others see "typing" while there is text.
  void _onComposerChanged(String text) {
    final discourse = _discourse;
    if (discourse == null || _editing != null) return;
    unawaited(discourse.setTypingAsync(widget.channelId, typing: text.trim().isNotEmpty, threadId: widget.threadId));
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(seconds: 2), () {
      unawaited(discourse.saveChatDraftAsync(widget.channelId, text, threadId: widget.threadId));
    });
  }

  Future<List<ChatSuggestion>> _suggest(String trigger, String term) async {
    final discourse = _discourse;
    if (discourse == null) return const [];
    if (trigger == '@') {
      final found = await discourse.searchMentionsAsync(term, channelId: widget.channelId);
      return [
        for (final u in found)
          ChatSuggestion(
            insert: '@${u.username}',
            title: u.username,
            subtitle: u.name,
            avatarUrl: u.avatarUrl,
            icon: u.isGroup ? Icons.group_outlined : null,
          ),
      ];
    }
    if (term.isEmpty) return const [];
    final found = await discourse.searchHashtagsAsync(term);
    return [
      for (final h in found)
        ChatSuggestion(
          insert: '#${h.ref}',
          title: h.text,
          icon: h.type == 'tag' ? Icons.sell_outlined : (h.type == 'channel' ? Icons.forum_outlined : Icons.tag),
        ),
    ];
  }

  /// The long-press sheet, and what was chosen in it.
  Future<void> _showMessageActions(FCChatMessage m, {required bool canEdit, required bool canDelete, required bool canWrite}) async {
    final site = widget.siteContext.site.url;
    final extras = DiscourseChatMessageExtras.of(site, m.id);
    final details = DiscourseChatChannelDetails.of(site, widget.channelId);
    final isSelf = _myId != null && m.authorId == _myId;
    final choice = await showChatMessageActions(
      context,
      message: m,
      siteContext: widget.siteContext,
      can: ChatMessagePermissions(
        react: canWrite,
        reply: canWrite,
        // Reply opens the thread in a channel with threads; this opens one
        // that already has replies.
        thread: _threaded && (extras?.thread?.replyCount ?? 0) > 0,
        edit: canEdit,
        delete: canDelete,
        pin: details?.canManagePins ?? false,
        pinned: extras?.pinned ?? false,
        flag: !isSelf && (extras?.canFlag ?? false) && !(extras?.flagged ?? false),
        bookmark: _discourse != null,
        bookmarked: extras?.bookmarkId != null,
      ),
    );
    if (!mounted || choice == null) return;
    final l10n = AppLocalizations.of(context)!;
    final discourse = _discourse;
    switch (choice) {
      case ChatReact(:final emoji):
        await _controller.toggleReaction(m.id, emoji, add: true);
      case ChatMoreReactions():
        final emoji = await showEmojiPickerSheet(context, first: kChatDefaultReactions);
        if (emoji != null) await _controller.toggleReaction(m.id, emoji, add: true);
      case ChatMessageActionChoice(:final action):
        switch (action) {
          case ChatMessageAction.reply:
            // In a channel with threads a reply goes in the message's thread,
            // as on the web: a plain reply would start one there unseen.
            if (_threaded) return _openThread(m);
            setState(() {
              _editing = null;
              _replyTo = m;
            });
          case ChatMessageAction.thread:
            await _openThread(m);
          case ChatMessageAction.copyText:
            await Clipboard.setData(ClipboardData(text: m.message));
            if (mounted) SnackbarHelper.showInfo(context, l10n.chatTextCopied);
          case ChatMessageAction.copyLink:
            final slug = _controller.channel.value?.slug;
            final base = site.endsWith('/') ? site.substring(0, site.length - 1) : site;
            final thread = widget.threadId == null ? '' : '/t/${widget.threadId}';
            await Clipboard.setData(ClipboardData(
                text: '$base/chat/c/${slug == null || slug.isEmpty ? '-' : slug}/${widget.channelId}$thread/${m.id}'));
            if (mounted) SnackbarHelper.showInfo(context, l10n.linkCopied);
          case ChatMessageAction.edit:
            setState(() {
              _replyTo = null;
              _editing = m;
            });
          case ChatMessageAction.bookmark:
            if (discourse == null) return;
            final r = await discourse.setChatBookmarkAsync(m.id, bookmarked: extras?.bookmarkId == null);
            if (!mounted) return;
            if (r.result) {
              _controller.messages.refresh();
            } else {
              SnackbarHelper.showError(context, r.resultText ?? l10n.chatNotAvailable);
            }
          case ChatMessageAction.pin:
            if (discourse == null) return;
            final r = await discourse.setChatPinnedAsync(widget.channelId, m.id, pinned: !(extras?.pinned ?? false));
            if (!mounted) return;
            if (r.result) {
              _controller.messages.refresh();
            } else {
              SnackbarHelper.showError(context, r.resultText ?? l10n.chatNotAvailable);
            }
          case ChatMessageAction.flag:
            if (discourse == null) return;
            await showDiscourseReportDialog(
              context,
              postId: '${m.id}',
              authorUsername: m.authorUsername,
              onlyTypes: (extras?.availableFlags ?? const <String>[]).toSet(),
              submit: (type, message) async {
                final r = await discourse.flagChatMessageAsync(widget.channelId, m.id, type.id, message: message);
                return (result: r.result, resultText: r.resultText);
              },
            );
          case ChatMessageAction.delete:
            final ok = await _confirmDelete();
            if (ok) await _controller.deleteMessage(m.id);
        }
    }
  }

  /// The channel has threads, and this is the channel (not a thread).
  bool get _threaded =>
      widget.threadId == null &&
      (DiscourseChatChannelDetails.of(widget.siteContext.site.url, widget.channelId)?.threadingEnabled ?? false);

  /// Opens [m]'s thread, starting it first when it has none (as the web
  /// does on Reply).
  Future<void> _openThread(FCChatMessage m) async {
    final discourse = _discourse;
    if (discourse == null) return;
    var threadId = DiscourseChatMessageExtras.of(widget.siteContext.site.url, m.id)?.thread?.threadId;
    threadId ??= (await discourse.createThreadAsync(widget.channelId, m.id))?.threadId;
    if (!mounted) return;
    if (threadId == null) {
      SnackbarHelper.showError(context, AppLocalizations.of(context)!.chatNotAvailable);
      return;
    }
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ChatChannelScreen(
        siteContext: widget.siteContext,
        channelId: widget.channelId,
        threadId: threadId,
        initialTitle: _controller.channel.value == null ? '' : chatChannelTitle(_controller.channel.value!),
      ),
    ));
    // The summary may have changed while the thread was open.
    if (mounted) _controller.messages.refresh();
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
///
/// Its header is the conversation's, as Discourse's: the channel's avatar,
/// its name and how many are in it, opening the channel's info and
/// settings; with search beside it. A thread ([threadId]) is titled with
/// the thread and its channel.
class ChatChannelScreen extends StatefulWidget {
  const ChatChannelScreen({
    super.key,
    required this.siteContext,
    required this.channelId,
    this.threadId,
    this.initialTitle = '',
    this.targetMessageId,
  });

  final SiteContext siteContext;
  final int channelId;
  final int? threadId;
  final String initialTitle;
  final int? targetMessageId;

  @override
  State<ChatChannelScreen> createState() => _ChatChannelScreenState();
}

class _ChatChannelScreenState extends State<ChatChannelScreen> {
  late String _title = widget.initialTitle;
  FCChatChannel? _channel;
  String? _threadTitle;

  bool get _discourse => SiteProxyService.getChatProxy() is DiscourseChatProxy;

  Future<void> _openInfo() async {
    final ch = _channel;
    if (ch == null || !_discourse || !widget.siteContext.isLoggedIn) return;
    final left = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => ChatChannelInfoPage(siteContext: widget.siteContext, channel: ch),
    ));
    if (left == true && mounted) Navigator.of(context).pop();
  }

  void _openSearch() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ChatSearchPage(siteContext: widget.siteContext, channelId: widget.channelId, channelTitle: _title),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final inThread = widget.threadId != null;
    final ch = _channel;
    final canSearch = !inThread &&
        _discourse &&
        widget.siteContext.isLoggedIn &&
        DiscourseChatSettings.forSite(widget.siteContext.site.url).searchEnabled;
    final Widget title;
    if (inThread) {
      title = _HeaderTitle(title: _threadTitle ?? l10n.chatThread, subtitle: _title.isEmpty ? null : _title);
    } else if (ch == null) {
      title = Text(_title);
    } else {
      title = ValueListenableBuilder<int>(
        valueListenable: DiscourseChatChannelDetails.revision,
        builder: (context, _, __) {
          final d = DiscourseChatChannelDetails.of(widget.siteContext.site.url, ch.id);
          final group = d?.isGroup ?? false;
          final count = d?.membershipsCount ?? 0;
          final String? subtitle;
          if (ch.chatableType == 'DirectMessage' && !group) {
            final other = d?.members.firstOrNull;
            subtitle = other != null && other.displayName != _title ? other.displayName : null;
          } else {
            subtitle = count > 0 ? l10n.chatMembersCount(count) : null;
          }
          return InkWell(
            onTap: _discourse && widget.siteContext.isLoggedIn ? _openInfo : null,
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingXS),
              child: Row(
                children: [
                  ChatChannelAvatar(channel: ch, details: d, siteContext: widget.siteContext, size: 36),
                  const SizedBox(width: DesignTokens.spacingM),
                  Expanded(child: _HeaderTitle(title: _title, subtitle: subtitle)),
                ],
              ),
            ),
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(
        titleSpacing: ch == null || inThread ? null : 0,
        title: DefaultTextStyle.merge(style: theme.textTheme.titleMedium, child: title),
        actions: [
          if (canSearch)
            IconButton(icon: const Icon(Icons.search), tooltip: l10n.chatSearchTitle, onPressed: _openSearch),
          if (!inThread && ch != null && _discourse && widget.siteContext.isLoggedIn)
            IconButton(icon: const Icon(Icons.info_outline), tooltip: l10n.chatChannelSettings, onPressed: _openInfo),
        ],
      ),
      body: ChatChannelView(
        siteContext: widget.siteContext,
        channelId: widget.channelId,
        threadId: widget.threadId,
        targetMessageId: widget.targetMessageId,
        onChannelLoaded: (ch) {
          final t = chatChannelTitle(ch);
          if (mounted) {
            setState(() {
              _title = t;
              _channel = ch;
            });
          }
        },
        onThreadLoaded: (thread) {
          if (mounted && thread.title != _threadTitle) setState(() => _threadTitle = thread.title);
        },
      ),
    );
  }
}

/// The header's name over a smaller line (members, or the channel).
class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
        if (subtitle != null)
          Text(subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
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
  const _MessageEntry(this.message, {required this.showHeader, this.showReplyTo = true});
  final FCChatMessage message;
  final bool showHeader;
  final bool showReplyTo;
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

/// "X is typing…", as Discourse writes it, under the conversation.
class _TypingLine extends StatelessWidget {
  const _TypingLine({required this.users});

  final List<DiscourseChatUser> users;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final names = [for (final u in users) u.username];
    final String text;
    if (names.length == 1) {
      text = l10n.chatTypingOne(names.first);
    } else if (names.length <= 3) {
      text = l10n.chatTypingTwo(names.sublist(0, names.length - 1).join(', '), names.last);
    } else {
      text = l10n.chatTypingMany(names.take(2).join(', '), names.length - 2);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL, DesignTokens.spacingXS, DesignTokens.spacingL, 0),
      child: Text(
        '$text…',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
