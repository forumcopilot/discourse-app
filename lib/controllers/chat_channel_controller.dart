import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forumcopilot_flutter/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_channel.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_message.dart';
import 'package:get/get.dart';

import '../core/logging/app_logger.dart';

/// Owns one chat channel view: message list + send/edit/delete actions
/// + the polling loop that keeps messages fresh.
///
/// Phase 5.39 — routes through `IFCChatProxy` (no more `DiscourseChatProxy`
/// casts). Lifecycle is unchanged:
///   - Polling starts on [start] / resumes on app foreground.
///   - Polling pauses on background and stops on dispose.
///
/// Discourse Chat has no native long-poll; the web client uses
/// MessageBus + websockets. This controller polls every [pollInterval].
class ChatChannelController extends GetxController
    with WidgetsBindingObserver {
  ChatChannelController({
    required this.channelId,
    this.pollInterval = const Duration(seconds: 4),
  });

  final int channelId;
  final Duration pollInterval;

  // ---- observable state ------------------------------------------------

  final messages = <FCChatMessage>[].obs;
  final channel = Rxn<FCChatChannel>();
  final isLoadingInitial = false.obs;
  final isLoadingOlder = false.obs;
  final isSending = false.obs;
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
      final proxy = SiteProxyService.getChatProxy();
      final channelFuture = proxy.getChannelAsync(channelId);
      final messagesFuture = proxy.getMessagesAsync(channelId, pageSize: 50);
      final channelResult = await channelFuture;
      final messagesResult = await messagesFuture;
      final ch = channelResult.channel;
      final firstBatch = messagesResult.messages;
      if (ch != null) channel.value = ch;
      if (firstBatch.isNotEmpty) {
        // Discourse returns newest-first; flip to oldest-first for the
        // bottom-anchored ListView convention.
        final sorted = firstBatch.toList()
          ..sort((a, b) => a.id.compareTo(b.id));
        messages.assignAll(sorted);
        _highWatermark = sorted.last.id;
      }
      if (_highWatermark > 0) {
        unawaited(proxy.markChannelReadAsync(channelId,
            messageId: _highWatermark));
      }
    } catch (e) {
      AppLogger.error('ChatChannelController bootstrap error: $e');
      lastError.value = e.toString();
    } finally {
      isLoadingInitial.value = false;
    }
  }

  // ---- public polling control -----------------------------------------

  void start() => _startPolling();
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
      final proxy = SiteProxyService.getChatProxy();
      final result = await proxy.pollNewerAsync(
        channelId,
        lastMessageId: _highWatermark,
      );
      if (!result.result || result.messages.isEmpty) return;
      // Drop anything we already have; keep new messages sorted by id.
      final existing = {for (final m in messages) m.id};
      final fresh =
          result.messages.where((m) => !existing.contains(m.id)).toList()
            ..sort((a, b) => a.id.compareTo(b.id));
      if (fresh.isEmpty) return;
      messages.addAll(fresh);
      _highWatermark = fresh.last.id;
      // Don't mark-read on every poll — only when the user is actually
      // looking at the channel. The view marks read in its onResumed
      // hook.
    } catch (e) {
      AppLogger.warning('ChatChannelController poll error: $e');
    }
  }

  // ---- actions ---------------------------------------------------------

  Future<bool> send(String text) async {
    if (text.trim().isEmpty) return false;
    isSending.value = true;
    try {
      final result =
          await SiteProxyService.getChatProxy().sendMessageAsync(channelId, text);
      if (!result.result || result.message == null) {
        lastError.value = result.resultText?.isNotEmpty == true
            ? result.resultText!
            : 'Failed to send message.';
        return false;
      }
      final m = result.message!;
      // Optimistic append; the next poll reconciles if the server
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
      final result = await SiteProxyService.getChatProxy()
          .editMessageAsync(channelId, messageId, text);
      if (!result.result) {
        lastError.value = result.resultText?.isNotEmpty == true
            ? result.resultText!
            : 'Failed to edit message.';
        return false;
      }
      // Optimistic update — replace the message body locally.
      final idx = messages.indexWhere((m) => m.id == messageId);
      if (idx >= 0) {
        final old = messages[idx];
        messages[idx] = FCChatMessage(
          id: old.id,
          channelId: old.channelId,
          threadId: old.threadId,
          message: text,
          cooked: old.cooked,
          excerpt: old.excerpt,
          authorId: old.authorId,
          authorUsername: old.authorUsername,
          authorName: old.authorName,
          authorAvatarUrl: old.authorAvatarUrl,
          createdAt: old.createdAt,
          edited: true,
          deleted: old.deleted,
          streaming: old.streaming,
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

  Future<bool> deleteMessage(int messageId) async {
    isSending.value = true;
    try {
      final result = await SiteProxyService.getChatProxy()
          .deleteMessageAsync(channelId, messageId);
      if (!result.result) {
        lastError.value = result.resultText?.isNotEmpty == true
            ? result.resultText!
            : 'Failed to delete message.';
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
      final result = await SiteProxyService.getChatProxy().getMessagesAsync(
        channelId,
        pageSize: pageSize,
        targetMessageId: messages.first.id,
        direction: 'past',
      );
      if (!result.result || result.messages.isEmpty) return;
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

  Future<void> markRead() async {
    if (_highWatermark == 0) return;
    await SiteProxyService.getChatProxy()
        .markChannelReadAsync(channelId, messageId: _highWatermark);
  }
}
