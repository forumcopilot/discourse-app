import 'dart:async';
import 'dart:convert' show HtmlEscape;

import 'package:discourse_core/discourse_core.dart'
    show
        DiscourseChatChannelDetails,
        DiscourseChatEvent,
        DiscourseChatMessageChanged,
        DiscourseChatMessagesDeleted,
        DiscourseChatProxy,
        DiscourseChatReaction,
        DiscourseChatThread,
        DiscourseChatThreadUpdated;
import 'package:flutter/widgets.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_channel.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_message.dart';
import 'package:forumcopilot_sdk/models/results/fc_chat_result.dart';
import 'package:get/get.dart';

import '../core/logging/app_logger.dart';
import '../l10n/app_l10n.dart';

/// Owns one chat channel view: message list + send/edit/delete actions, and
/// the live updates that keep it current.
///
/// Live updates come from Discourse's MessageBus (DiscourseChatProxy
/// .watchChannel): new messages, edits, deletions and reactions arrive as
/// they happen, from a long-poll that costs about one request per 25 s when
/// the channel is quiet. This replaced re-fetching 50 messages every 4 s —
/// 15 requests a minute against the User API Key's 20/minute and 2,880/day,
/// shared with the rest of the app — which also never showed other people's
/// edits, deletions or reactions. A key the forum refuses message-bus access
/// falls back to fetching every [fallbackPollInterval].
///
/// Live updates run while the view is active ([start]/[stop]) and the app is
/// in the foreground; returning to the foreground re-syncs first, so nothing
/// published in between is missed.
class ChatChannelController extends GetxController
    with WidgetsBindingObserver {
  ChatChannelController({
    required this.channelId,
    this.threadId,
    this.targetMessageId,
    this.fallbackPollInterval = const Duration(seconds: 30),
  });

  final int channelId;

  /// A thread of the channel, shown on its own: its original message and
  /// replies, live from the thread's MessageBus channel, read and sent
  /// there. Null for the channel itself.
  final int? threadId;

  /// Open on this message (from a notification): the first load fetches the
  /// messages around it rather than the newest.
  final int? targetMessageId;
  final Duration fallbackPollInterval;

  // ---- observable state ------------------------------------------------

  final messages = <FCChatMessage>[].obs;
  final channel = Rxn<FCChatChannel>();
  final isLoadingInitial = false.obs;
  final isLoadingOlder = false.obs;
  final isSending = false.obs;
  final lastError = ''.obs;

  /// True when the first load failed and nothing is on screen: the view
  /// shows the error with Retry instead of an empty channel.
  final loadFailed = false.obs;

  // ---- internal --------------------------------------------------------

  Timer? _pollTimer;
  int _highWatermark = 0;
  bool _disposed = false;
  bool _bootstrapped = false;
  bool _tickInFlight = false;

  /// Stops the MessageBus subscription, while one is active.
  void Function()? _unwatch;

  /// Whether the view wants live updates ([start]) — the app coming back to
  /// the foreground resumes them only then.
  bool _wanted = false;

  bool _foreground = true;

  /// Pending "mark read" for messages that arrived on screen.
  Timer? _markReadTimer;

  /// When "mark read" last went out; see [_scheduleMarkRead].
  DateTime? _lastMarkRead;

  /// The id last reported read, so an unchanged position is not re-sent.
  int _reportedReadId = 0;

  /// False once a request for older messages came back empty: the start of
  /// the channel's history is on screen.
  final hasMoreOlder = true.obs;

  /// The first message the reader had not read when the channel opened
  /// (someone else's, after `last_read_message_id`), where the view draws
  /// its "last visit" line and opens. Null when nothing was unread.
  final firstUnreadId = Rxn<int>();

  /// True while the newest messages are not loaded: the channel opened at
  /// an unread line or a notified message further back. Scrolling down
  /// loads them ([loadNewer]); the jump button loads the newest ([jumpToLatest]).
  final hasMoreNewer = false.obs;
  final isLoadingNewer = false.obs;

  /// Messages published while [hasMoreNewer] (not added, to leave no gap),
  /// for the jump button's count.
  final pendingNewer = 0.obs;

  /// The newest message id known to exist, loaded or not.
  int _newestKnownId = 0;

  /// The newest message the reader has seen on screen ([noteSeen]): "mark
  /// read" goes up to here, not to whatever happened to be loaded.
  int _seenMax = 0;
  bool _positionDecided = false;

  int? get _myUserId {
    final proxy = SiteProxyService.getChatProxy();
    return proxy is DiscourseChatProxy ? int.tryParse(proxy.siteContext.currentUserId ?? '') : null;
  }

  // ---- lifecycle -------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  @override
  void onClose() {
    _disposed = true;
    _stopLive();
    _flushMarkRead();
    _bootstrapRetry?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed) return;
    switch (state) {
      case AppLifecycleState.resumed:
        if (_foreground) return;
        _foreground = true;
        // Only a channel on screen resumes, and it re-syncs first: the
        // subscription was dropped in the background.
        if (_wanted) {
          unawaited(_resync().then((_) {
            if (_bootstrapped) _startLive();
          }));
        }
      case AppLifecycleState.paused ||
            AppLifecycleState.hidden ||
            AppLifecycleState.detached:
        _foreground = false;
        _stopLive();
      case AppLifecycleState.inactive:
        // Brief (the notification shade, a system dialog): keep listening.
        break;
    }
  }

  Future<void> _bootstrap() async {
    isLoadingInitial.value = true;
    try {
      final proxy = SiteProxyService.getChatProxy();
      final channelFuture = proxy.getChannelAsync(channelId);
      final messagesFuture = targetMessageId != null && !_bootstrapped
          ? _page(target: targetMessageId, direction: '')
          : _page();
      final t = threadId;
      if (t != null && proxy is DiscourseChatProxy) {
        final loaded = await proxy.getThreadAsync(channelId, t);
        if (loaded != null) {
          thread.value = loaded;
          _threadBusLastId = loaded.busLastId;
        }
      }
      final channelResult = await channelFuture;
      final messagesResult = await messagesFuture;
      final ch = channelResult.channel;
      final firstBatch = messagesResult.messages;
      if (ch != null) channel.value = ch;
      if (firstBatch.isNotEmpty) {
        // Discourse returns newest-first; flip to oldest-first for the
        // bottom-anchored ListView convention. Merged by id, not assigned:
        // anything already on screen (a re-sync after time away) stays.
        final byId = {
          for (final m in messages) m.id: m,
          for (final m in firstBatch) m.id: m,
        };
        final sorted = byId.values.toList()
          ..sort((a, b) => a.id.compareTo(b.id));
        messages.assignAll(sorted);
        _highWatermark = sorted.last.id;
      }
      if (!_positionDecided && channelResult.result && messagesResult.result) {
        _positionDecided = true;
        await _decideStartingPoint(proxy, ch);
      }
      _bootstrapped = channelResult.result && messagesResult.result;
      loadFailed.value = !_bootstrapped && messages.isEmpty;
      if (_bootstrapped) {
        // Live updates start from the position the channel fetch recorded,
        // so nothing published after these messages loaded is missed.
        if (_wanted && _foreground) _startLive();
      } else {
        lastError.value = (channelResult.result
                ? messagesResult.resultText
                : channelResult.resultText) ??
            '';
        _retryBootstrapLater();
      }
    } catch (e) {
      AppLogger.error('ChatChannelController bootstrap error: $e');
      lastError.value = e.toString();
      loadFailed.value = messages.isEmpty;
      _retryBootstrapLater();
    } finally {
      isLoadingInitial.value = false;
    }
  }

  /// Where the conversation opens. With unread messages it opens at the
  /// first one, under a "last visit" line, as Discourse does; when that is
  /// further back than the newest page, the messages around it load instead
  /// and the newest wait below ([hasMoreNewer]). It used to open at the
  /// bottom, past everything unread.
  Future<void> _decideStartingPoint(dynamic proxy, FCChatChannel? ch) async {
    // A thread opens at its newest reply.
    if (threadId != null) return;
    final details = proxy is DiscourseChatProxy
        ? DiscourseChatChannelDetails.of(proxy.siteContext.site.url, channelId)
        : null;
    _newestKnownId = [
      _newestKnownId,
      details?.lastMessageId ?? 0,
      if (messages.isNotEmpty) messages.last.id,
    ].reduce((a, b) => a > b ? a : b);
    final lastRead = ch?.lastReadMessageId;
    if (targetMessageId == null && lastRead != null && (ch?.unreadCount ?? 0) > 0) {
      if (messages.isNotEmpty && lastRead < messages.first.id) {
        final around = await SiteProxyService.getChatProxy()
            .getMessagesAsync(channelId, pageSize: 50, targetMessageId: lastRead, direction: '');
        if (around.result && around.messages.isNotEmpty) {
          messages.assignAll(around.messages.toList()..sort((a, b) => a.id.compareTo(b.id)));
          _highWatermark = messages.last.id;
        }
      }
      final me = _myUserId;
      for (final m in messages) {
        if (m.id > lastRead && m.authorId != me) {
          firstUnreadId.value = m.id;
          break;
        }
      }
    }
    hasMoreNewer.value = messages.isNotEmpty && messages.last.id < _newestKnownId;
  }

  /// The reader has seen [messageId] on screen.
  void noteSeen(int messageId) {
    if (messageId <= _seenMax) return;
    _seenMax = messageId;
    _scheduleMarkRead();
  }

  /// The next page after the newest loaded message, while scrolling down
  /// from an unread line or a notified message.
  Future<void> loadNewer({int pageSize = 50}) async {
    if (isLoadingNewer.value || !hasMoreNewer.value || messages.isEmpty) return;
    isLoadingNewer.value = true;
    try {
      final result = await _page(target: messages.last.id, direction: 'future', pageSize: pageSize);
      if (!result.result) return;
      final existing = {for (final m in messages) m.id};
      final newer = result.messages.where((m) => !existing.contains(m.id)).toList()
        ..sort((a, b) => a.id.compareTo(b.id));
      messages.addAll(newer);
      if (messages.isNotEmpty && messages.last.id > _highWatermark) _highWatermark = messages.last.id;
      if (newer.isEmpty || messages.last.id >= _newestKnownId) {
        hasMoreNewer.value = false;
        pendingNewer.value = 0;
      }
    } catch (e) {
      AppLogger.warning('ChatChannelController loadNewer error: $e');
    } finally {
      isLoadingNewer.value = false;
    }
  }

  /// The newest page, replacing what is loaded (no gap to fill): the jump
  /// button when the newest messages are not loaded.
  Future<void> jumpToLatest() async {
    if (!hasMoreNewer.value) return;
    isLoadingNewer.value = true;
    try {
      final result = await _page();
      if (!result.result || result.messages.isEmpty) return;
      messages.assignAll(result.messages.toList()..sort((a, b) => a.id.compareTo(b.id)));
      _highWatermark = messages.last.id;
      hasMoreNewer.value = false;
      hasMoreOlder.value = true;
      pendingNewer.value = 0;
    } finally {
      isLoadingNewer.value = false;
    }
  }

  // ---- live updates -----------------------------------------------------

  /// Retry a failed first load now (the view's Retry button).
  Future<void> retry() {
    _bootstrapRetry?.cancel();
    return _bootstrap();
  }

  /// The view is showing this channel: keep it current. Before the first
  /// load has succeeded, live updates wait for it (see [_bootstrap]).
  void start() {
    _wanted = true;
    if (_foreground && _bootstrapped) _startLive();
  }

  Timer? _bootstrapRetry;

  /// A failed first load is retried while the channel is on screen, instead
  /// of leaving an empty list for good.
  void _retryBootstrapLater() {
    _bootstrapRetry?.cancel();
    _bootstrapRetry = Timer(const Duration(seconds: 15), () {
      if (!_disposed && _wanted && _foreground && !_bootstrapped) {
        unawaited(_bootstrap());
      }
    });
  }

  /// The view is not showing it: stop spending requests on it.
  void stop() {
    _flushMarkRead();
    _wanted = false;
    _stopLive();
  }

  void _startLive() {
    _stopLive();
    if (_disposed || !_wanted || !_foreground) return;
    final proxy = SiteProxyService.getChatProxy();
    if (proxy is DiscourseChatProxy) {
      final thread = threadId;
      _unwatch = thread == null
          ? proxy.watchChannel(channelId, _onEvent)
          : proxy.watchThread(channelId, thread, _onEvent, lastId: _threadBusLastId ?? -1);
      if (_unwatch != null) return;
    }
    // No MessageBus for this key: fetch now and then.
    _pollTimer = Timer.periodic(fallbackPollInterval, (_) => _tick());
  }

  void _stopLive() {
    _unwatch?.call();
    _unwatch = null;
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Fetch the channel (for a fresh MessageBus position) and the newest
  /// messages, after time away.
  Future<void> _resync() async {
    if (!_bootstrapped) return _bootstrap();
    final proxy = SiteProxyService.getChatProxy();
    await proxy.getChannelAsync(channelId);
    await _tick();
  }

  /// Apply one live change to what is on screen.
  void _onEvent(DiscourseChatEvent event) {
    if (_disposed) return;
    switch (event) {
      case DiscourseChatMessageChanged(:final message, :final isNew):
        final i = messages.indexWhere((m) => m.id == message.id);
        if (i >= 0) {
          // An edit's payload is serialized for an anonymous viewer, so its
          // reactions lack "reacted by me": keep the ones on screen.
          messages[i] = message.copyWith(reactions: messages[i].reactions);
        } else if (hasMoreNewer.value && isNew) {
          // The newest messages are not loaded: adding this one would leave
          // a gap. Count it for the jump button.
          if (message.id > _newestKnownId) _newestKnownId = message.id;
          if (message.authorId != _myUserId) pendingNewer.value++;
        } else if (isNew || event.kind == 'restore') {
          _insertSorted(message);
          if (message.id > _highWatermark) _highWatermark = message.id;
          if (message.id > _newestKnownId) _newestKnownId = message.id;
        }
      case DiscourseChatMessagesDeleted(:final messageIds):
        messages.removeWhere((m) => messageIds.contains(m.id));
      case DiscourseChatReaction():
        _applyReactionEvent(event);
      case DiscourseChatThreadUpdated():
        // The summary under the original message: redraw it.
        messages.refresh();
    }
  }

  void _insertSorted(FCChatMessage message) {
    final at = messages.indexWhere((m) => m.id > message.id);
    if (at < 0) {
      messages.add(message);
    } else {
      messages.insert(at, message);
    }
  }

  /// Someone's reaction, published live. The viewer's own arrives here too,
  /// after [toggleReaction] already showed it, so it only applies if the chip
  /// does not already say so.
  void _applyReactionEvent(DiscourseChatReaction e) {
    final index = messages.indexWhere((m) => m.id == e.messageId);
    if (index < 0) return;
    final message = messages[index];
    final proxy = SiteProxyService.getChatProxy();
    final me =
        proxy is DiscourseChatProxy ? proxy.siteContext.currentUsername : null;
    final mine = me != null && me == e.username;
    final current = List<FCChatMessageReaction>.of(message.reactions);
    final i = current.indexWhere((r) => r.emoji == e.emoji);
    final existing = i >= 0 ? current[i] : null;
    if (mine && (existing?.reacted ?? false) == e.added) return;
    if (!mine && e.added && (existing?.usernames.contains(e.username) ?? false)) {
      return;
    }
    if (e.added) {
      final chip = FCChatMessageReaction(
        emoji: e.emoji,
        count: (existing?.count ?? 0) + 1,
        reacted: mine || (existing?.reacted ?? false),
        usernames: [...?existing?.usernames, e.username],
      );
      if (i >= 0) {
        current[i] = chip;
      } else {
        current.add(chip);
      }
    } else {
      if (existing == null) return;
      if (existing.count <= 1) {
        current.removeAt(i);
      } else {
        current[i] = FCChatMessageReaction(
          emoji: e.emoji,
          count: existing.count - 1,
          reacted: mine ? false : existing.reacted,
          usernames:
              existing.usernames.where((u) => u != e.username).toList(),
        );
      }
    }
    messages[index] = message.copyWith(reactions: current);
  }

  /// Messages arriving on screen are read: tell Discourse, at most once per
  /// [_markReadEvery]. Measured on a local forum, a burst of ten messages
  /// with a 3 s debounce still sent "read" after every poll batch — five
  /// PUTs in 30 s against the key's 20 a minute. Leaving the channel
  /// ([stop]) sends whatever is still pending, so badges end up right.
  static const _markReadEvery = Duration(seconds: 30);

  void _scheduleMarkRead() {
    if (!_foreground || !_wanted || _markReadTimer != null) return;
    final last = _lastMarkRead;
    final wait = last == null
        ? const Duration(seconds: 2)
        : _markReadEvery - DateTime.now().difference(last);
    _markReadTimer = Timer(wait.isNegative ? Duration.zero : wait, () {
      _markReadTimer = null;
      if (!_disposed) unawaited(markRead());
    });
  }

  /// Send a pending "mark read" now (leaving the channel).
  void _flushMarkRead() {
    if (_markReadTimer == null) return;
    _markReadTimer!.cancel();
    _markReadTimer = null;
    unawaited(markRead());
  }

  Future<void> _tick() async {
    if (_disposed || _tickInFlight || hasMoreNewer.value) return;
    _tickInFlight = true;
    try {
      // The newest page, merged: messages already on screen take the
      // server's version (edits, reactions — this is an authenticated
      // fetch, so "reacted by me" is right), new ones are added, and ones
      // missing from the page's range were deleted.
      final result = await _page();
      if (!result.result || result.messages.isEmpty) return;
      final page = {for (final m in result.messages) m.id: m};
      final oldest = page.keys.reduce((a, b) => a < b ? a : b);
      final merged = <FCChatMessage>[
        for (final m in messages)
          if (m.id < oldest) m else if (page[m.id] != null) page.remove(m.id)!,
        ...page.values,
      ]..sort((a, b) => a.id.compareTo(b.id));
      messages.assignAll(merged);
      if (merged.last.id > _highWatermark) _highWatermark = merged.last.id;
    } catch (e) {
      AppLogger.warning('ChatChannelController poll error: $e');
    } finally {
      _tickInFlight = false;
    }
  }

  // ---- actions ---------------------------------------------------------

  /// Sends [text] with any files already uploaded from the composer
  /// ([uploadIds]); either may be empty, not both.
  Future<bool> send(String text,
      {List<int> uploadIds = const [], FCChatMessage? inReplyTo, int? threadId}) async {
    if (text.trim().isEmpty && uploadIds.isEmpty) return false;
    isSending.value = true;
    try {
      final proxy = SiteProxyService.getChatProxy();
      final result = proxy is DiscourseChatProxy
          ? await proxy.sendMessageAsync(channelId, text,
              uploadIds: uploadIds, inReplyTo: inReplyTo, threadId: threadId ?? this.threadId)
          : await proxy.sendMessageAsync(channelId, text);
      if (!result.result || result.message == null) {
        lastError.value = result.resultText?.isNotEmpty == true
            ? result.resultText!
            : appL10n().chatSendFailed;
        return false;
      }
      final m = result.message!;
      // Optimistic append; the next poll reconciles if the server
      // returns a slightly different shape.
      if (hasMoreNewer.value) await jumpToLatest();
      if (!messages.any((x) => x.id == m.id)) {
        messages.add(m);
        if (m.id > _highWatermark) _highWatermark = m.id;
      }
      noteSeen(m.id);
      return true;
    } catch (e) {
      lastError.value = e.toString();
      return false;
    } finally {
      isSending.value = false;
    }
  }

  Future<bool> edit(int messageId, String text) async {
    if (text.trim().isEmpty) return false;
    isSending.value = true;
    try {
      final result = await SiteProxyService.getChatProxy()
          .editMessageAsync(channelId, messageId, text);
      if (!result.result) {
        lastError.value = result.resultText?.isNotEmpty == true
            ? result.resultText!
            : appL10n().chatEditFailed;
        return false;
      }
      // Show the new text now. The bubble draws `cooked` first, and the old
      // copy kept the previous cooked HTML, so the edit never appeared; this
      // one is the text as plain paragraphs until the server's rendering
      // arrives (the live `edit`/`processed` event, or the next fetch).
      // copyWith keeps the reactions, which a rebuilt message dropped.
      final idx = messages.indexWhere((m) => m.id == messageId);
      if (idx >= 0) {
        messages[idx] = messages[idx].copyWith(
          message: text,
          cooked: _plainCooked(text),
          edited: true,
        );
      }
      return true;
    } catch (e) {
      lastError.value = e.toString();
      return false;
    } finally {
      isSending.value = false;
    }
  }

  /// [text] as HTML paragraphs, escaped — a stand-in for the server's
  /// rendering.
  static String _plainCooked(String text) => text
      .split(RegExp(r'\n{2,}'))
      .map((p) =>
          '<p>${const HtmlEscape().convert(p).replaceAll('\n', '<br>')}</p>')
      .join();

  Future<bool> deleteMessage(int messageId) async {
    isSending.value = true;
    try {
      final result = await SiteProxyService.getChatProxy()
          .deleteMessageAsync(channelId, messageId);
      if (!result.result) {
        lastError.value = result.resultText?.isNotEmpty == true
            ? result.resultText!
            : appL10n().chatDeleteFailed;
        return false;
      }
      messages.removeWhere((m) => m.id == messageId);
      return true;
    } catch (e) {
      lastError.value = e.toString();
      return false;
    } finally {
      isSending.value = false;
    }
  }

  /// Adds/removes an emoji reaction on [messageId]. [emoji] is the
  /// Discourse emoji name without colons (e.g. `heart`, `+1`).
  ///
  /// Returns false (and sets [lastError]) on failure so the chip
  /// widget can revert its optimistic state. The server does not echo
  /// the new reaction state, so on success the change is applied
  /// locally to the message's own `reactions` list (the next poll's
  /// re-parse replaces it with the authoritative state); on failure
  /// the list is left untouched → revert. Either way [messages] is
  /// poked with `refresh()` so bubbles rebuild.
  Future<bool> toggleReaction(int messageId, String emoji,
      {required bool add}) async {
    final proxy = SiteProxyService.getChatProxy();
    if (proxy is! DiscourseChatProxy) {
      lastError.value = appL10n().chatReactionsUnsupported;
      return false;
    }
    try {
      final result = await proxy.toggleChatMessageReactionAsync(
        channelId,
        messageId,
        emoji,
        add: add,
      );
      if (!result.result) {
        lastError.value = result.resultText?.isNotEmpty == true
            ? result.resultText!
            : appL10n().chatReactionFailed;
        return false;
      }
      _applyLocalReaction(messageId, emoji, add: add);
      return true;
    } catch (e) {
      lastError.value = e.toString();
      return false;
    } finally {
      messages.refresh();
    }
  }

  /// Client-side optimistic update after a successful reaction toggle:
  /// bump/decrement the emoji's chip on the message's `reactions` list
  /// (replacing the list — it may be the unmodifiable default).
  void _applyLocalReaction(int messageId, String emoji,
      {required bool add}) {
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index < 0) return;
    final message = messages[index];
    final current = List<FCChatMessageReaction>.of(message.reactions);
    final i = current.indexWhere((r) => r.emoji == emoji);
    if (add) {
      if (i >= 0) {
        final r = current[i];
        if (r.reacted) return; // already counted
        current[i] = FCChatMessageReaction(
          emoji: emoji,
          count: r.count + 1,
          reacted: true,
          usernames: r.usernames,
        );
      } else {
        current.add(FCChatMessageReaction(
          emoji: emoji,
          count: 1,
          reacted: true,
        ));
      }
    } else {
      if (i < 0) return;
      final r = current[i];
      if (r.count <= 1) {
        current.removeAt(i);
      } else {
        current[i] = FCChatMessageReaction(
          emoji: emoji,
          count: r.count - 1,
          reacted: false,
          usernames: r.usernames,
        );
      }
    }
    message.reactions = current;
  }

  Future<void> loadOlder({int pageSize = 50}) async {
    if (isLoadingOlder.value || messages.isEmpty || !hasMoreOlder.value) {
      return;
    }
    isLoadingOlder.value = true;
    try {
      final result = await _page(target: messages.first.id, direction: 'past', pageSize: pageSize);
      if (!result.result) return;
      if (result.messages.isEmpty) {
        // The start of the history. It used to be asked for again on every
        // scroll that ended near the top.
        hasMoreOlder.value = false;
        return;
      }
      final existing = {for (final m in messages) m.id};
      final older =
          result.messages.where((m) => !existing.contains(m.id)).toList()
            ..sort((a, b) => a.id.compareTo(b.id));
      if (older.isEmpty) return;
      messages.insertAll(0, older);
    } catch (e) {
      AppLogger.warning('ChatChannelController loadOlder error: $e');
    } finally {
      isLoadingOlder.value = false;
    }
  }

  /// Tells Discourse the reader has read up to the newest message they
  /// have seen ([noteSeen]). It used to report the newest message loaded as
  /// soon as the channel opened, so a long unread stretch counted as read
  /// before anyone scrolled to it.
  Future<void> markRead() async {
    final upTo = _seenMax;
    if (upTo == 0 || upTo <= _reportedReadId) return;
    _lastMarkRead = DateTime.now();
    _reportedReadId = upTo;
    final proxy = SiteProxyService.getChatProxy();
    final thread = threadId;
    if (thread != null) {
      if (proxy is DiscourseChatProxy) await proxy.markThreadReadAsync(channelId, thread, messageId: upTo);
      return;
    }
    await proxy.markChannelReadAsync(channelId, messageId: upTo);
  }

  /// Where the thread's MessageBus channel was when it loaded.
  int? _threadBusLastId;

  /// The thread itself (title, original message), in a thread.
  final thread = Rxn<DiscourseChatThread>();

  /// A page of the channel's messages, or of the thread's: the newest, or
  /// [direction] of [target] (around it when [direction] is empty).
  Future<FCChatMessageListResult> _page({int? target, String direction = 'past', int pageSize = 50}) {
    final proxy = SiteProxyService.getChatProxy();
    final t = threadId;
    if (t != null && proxy is DiscourseChatProxy) {
      return proxy.getThreadMessagesAsync(channelId, t,
          pageSize: pageSize, targetMessageId: target, direction: direction);
    }
    return proxy.getMessagesAsync(channelId, pageSize: pageSize, targetMessageId: target, direction: direction);
  }
}
