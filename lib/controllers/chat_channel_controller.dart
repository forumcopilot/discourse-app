import 'dart:async';

import 'package:discourse_core/discourse_core.dart'
    show DiscourseChatChannel, DiscourseChatMessage, DiscourseChatProxy;
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../core/logging/app_logger.dart';

/// Owns one Discourse Chat channel view: message list + send/edit/
/// delete actions + the polling loop that keeps messages fresh.
///
/// Lifecycle:
///   - Polling starts when [start] is called (typically when the
///     channel page becomes visible).
///   - Polling pauses on app background (WidgetsBindingObserver).
///   - Polling stops + dispose runs when the controller is removed.
///
/// Discourse Chat has no native long-poll; the web client uses
/// MessageBus + websockets. This controller polls every [pollInterval]
/// using `pollNewerAsync(channelId, lastMessageId)`. A future revision
/// can subscribe to `/chat/:channel_id` via MessageBus for real-time
/// updates. Polling cadence is intentionally on the slow side (default
/// 4s) to keep battery + network friendly; bump it down for testing.
class ChatChannelController extends GetxController
    with WidgetsBindingObserver {
  ChatChannelController({
    required this.channelId,
    this.pollInterval = const Duration(seconds: 4),
  });

  final int channelId;
  final Duration pollInterval;

  // ---- observable state ------------------------------------------------

  /// Messages, oldest first.
  final messages = <DiscourseChatMessage>[].obs;

  /// Channel metadata (name, status, unread count, etc.).
  final channel = Rxn<DiscourseChatChannel>();

  final isLoadingInitial = false.obs;
  final isLoadingOlder = false.obs;
  final isSending = false.obs;

  /// Last error message surfaced to the UI (transient — caller clears
  /// after showing).
  final lastError = ''.obs;

  // ---- internal --------------------------------------------------------

  Timer? _pollTimer;
  int _highWatermark = 0;
  bool _disposed = false;

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
    _stopPolling();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed) return;
    if (state == AppLifecycleState.resumed) {
      _startPolling();
    } else {
      _stopPolling();
    }
  }

  Future<void> _bootstrap() async {
    isLoadingInitial.value = true;
    try {
      final proxy = DiscourseChatProxy.forCurrentSite();
      if (proxy == null) {
        lastError.value = 'Chat is not enabled on this forum.';
        return;
      }
      // Channel metadata + first slice in parallel.
      final results = await Future.wait([
        proxy.getChannelAsync(channelId),
        proxy.getMessagesAsync(channelId, pageSize: 50),
      ]);
      final ch = results[0] as DiscourseChatChannel?;
      final firstBatch = results[1] as List<DiscourseChatMessage>;
      if (ch != null) channel.value = ch;
      if (firstBatch.isNotEmpty) {
        // Discourse returns newest-first; flip to oldest-first for the
        // bottom-anchored ListView convention.
        final sorted = firstBatch.toList()
          ..sort((a, b) => a.id.compareTo(b.id));
        messages.assignAll(sorted);
        _highWatermark = sorted.last.id;
      }
      // Mark the channel read up to the latest message we just loaded.
      if (_highWatermark > 0) {
        unawaited(proxy.markChannelReadAsync(channelId, messageId: _highWatermark));
      }
    } catch (e) {
      AppLogger.error('ChatChannelController bootstrap error: $e');
      lastError.value = e.toString();
    } finally {
      isLoadingInitial.value = false;
    }
  }

  // ---- public polling control -----------------------------------------

  /// Resume polling — call when the channel view becomes visible.
  void start() => _startPolling();

  /// Pause polling — call when the channel view becomes hidden.
  void stop() => _stopPolling();

  // ---- polling ---------------------------------------------------------

  void _startPolling() {
    _stopPolling();
    if (_disposed) return;
    _pollTimer = Timer.periodic(pollInterval, (_) => _tick());
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _tick() async {
    if (_disposed || _highWatermark == 0) return;
    try {
      final proxy = DiscourseChatProxy.forCurrentSite();
      if (proxy == null) return;
      final newer = await proxy.pollNewerAsync(
        channelId,
        lastMessageId: _highWatermark,
      );
      if (newer.isEmpty) return;
      // Drop anything we already have; keep new messages sorted by id.
      final existing = {for (final m in messages) m.id};
      final fresh = newer.where((m) => !existing.contains(m.id)).toList()
        ..sort((a, b) => a.id.compareTo(b.id));
      if (fresh.isEmpty) return;
      messages.addAll(fresh);
      _highWatermark = fresh.last.id;
      // Don't mark-read on every poll — only when the user is actually
      // looking at the channel. The view marks read in its onResumed
      // hook.
    } catch (e) {
      AppLogger.warning('ChatChannelController poll error: $e');
      // Don't surface transient errors — next tick may recover.
    }
  }

  // ---- actions ---------------------------------------------------------

  Future<bool> send(String text) async {
    if (text.trim().isEmpty) return false;
    isSending.value = true;
    try {
      final proxy = DiscourseChatProxy.forCurrentSite();
      if (proxy == null) {
        lastError.value = 'Chat is not enabled on this forum.';
        return false;
      }
      final m = await proxy.sendMessageAsync(channelId, text);
      if (m == null) {
        lastError.value = 'Failed to send message.';
        return false;
      }
      // Optimistic append; the next poll will reconcile if the server
      // returns a slightly different shape.
      if (!messages.any((x) => x.id == m.id)) {
        messages.add(m);
        if (m.id > _highWatermark) _highWatermark = m.id;
      }
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
      final proxy = DiscourseChatProxy.forCurrentSite();
      if (proxy == null) return false;
      final ok = await proxy.editMessageAsync(channelId, messageId, text);
      if (!ok) {
        lastError.value = 'Failed to edit message.';
        return false;
      }
      // Optimistic update — replace the message body locally.
      final idx = messages.indexWhere((m) => m.id == messageId);
      if (idx >= 0) {
        messages[idx] = messages[idx].copyWith(message: text, edited: true);
      }
      return true;
    } catch (e) {
      lastError.value = e.toString();
      return false;
    } finally {
      isSending.value = false;
    }
  }

  Future<bool> deleteMessage(int messageId) async {
    isSending.value = true;
    try {
      final proxy = DiscourseChatProxy.forCurrentSite();
      if (proxy == null) return false;
      final ok = await proxy.deleteMessageAsync(channelId, messageId);
      if (!ok) {
        lastError.value = 'Failed to delete message.';
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

  Future<void> loadOlder({int pageSize = 50}) async {
    if (isLoadingOlder.value || messages.isEmpty) return;
    isLoadingOlder.value = true;
    try {
      final proxy = DiscourseChatProxy.forCurrentSite();
      if (proxy == null) return;
      final batch = await proxy.getMessagesAsync(
        channelId,
        pageSize: pageSize,
        targetMessageId: messages.first.id,
        direction: 'older',
      );
      if (batch.isEmpty) return;
      final existing = {for (final m in messages) m.id};
      final older = batch.where((m) => !existing.contains(m.id)).toList()
        ..sort((a, b) => a.id.compareTo(b.id));
      if (older.isEmpty) return;
      messages.insertAll(0, older);
    } catch (e) {
      AppLogger.warning('ChatChannelController loadOlder error: $e');
    } finally {
      isLoadingOlder.value = false;
    }
  }

  Future<void> markRead() async {
    if (_highWatermark == 0) return;
    final proxy = DiscourseChatProxy.forCurrentSite();
    if (proxy == null) return;
    await proxy.markChannelReadAsync(channelId, messageId: _highWatermark);
  }
}
