import 'dart:async';

import 'package:discourse_core/discourse_core.dart' show DiscoursePostProxy;
import 'package:flutter/widgets.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';

import '../core/logging/app_logger.dart';

/// Wraps a pair of [TextEditingController]s (title + content) and
/// transparently mirrors their contents to a Discourse server-side draft
/// at the configured `draftKey`, with debounce. Hand the controllers to
/// `MessageComposePage` and the rest just works.
///
/// Lifecycle:
///   1. `initialize()` — fetch any existing draft and prefill controllers.
///   2. While the user types, an internal listener debounces and saves.
///   3. On successful submit, call `discard()` to clean up the draft on
///      the server.
///   4. Always call `dispose()` from your widget's `dispose()`.
class DiscourseDraftController {
  final String draftKey;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final Duration debounceDuration;

  /// Optional extra fields persisted alongside the draft (e.g. categoryId,
  /// tags). The map is shallow-merged into the saved data on every save.
  final Map<String, dynamic> extraData;

  Timer? _debounce;
  bool _saving = false;
  bool _disposed = false;
  bool _loaded = false;
  String _lastSavedReply = '';
  String _lastSavedTitle = '';

  DiscourseDraftController({
    required this.draftKey,
    required this.titleController,
    required this.contentController,
    this.debounceDuration = const Duration(milliseconds: 1500),
    this.extraData = const {},
  });

  /// Hydrate the controllers from the server-side draft (if any) and
  /// start watching for user changes.
  Future<void> initialize() async {
    final proxy = SiteProxyFactory.getPostProxy();
    if (proxy is! DiscoursePostProxy) {
      _loaded = true;
      _attach();
      return;
    }
    try {
      final draft = await proxy.loadDraftAsync(draftKey);
      if (_disposed) return;
      if (draft != null) {
        final reply = draft['reply']?.toString();
        final title = draft['title']?.toString();
        // Only seed the field if it's currently empty — the caller may
        // already have populated initial text (e.g. quote prefill) and
        // we don't want to clobber that.
        if (reply != null &&
            reply.isNotEmpty &&
            contentController.text.isEmpty) {
          contentController.text = reply;
          contentController.selection = TextSelection.fromPosition(
            TextPosition(offset: reply.length),
          );
        }
        if (title != null &&
            title.isNotEmpty &&
            titleController.text.isEmpty) {
          titleController.text = title;
        }
        _lastSavedReply = reply ?? '';
        _lastSavedTitle = title ?? '';
      }
    } catch (e) {
      AppLogger.debug('DiscourseDraftController initial load failed: $e');
    }
    _loaded = true;
    _attach();
  }

  void _attach() {
    contentController.addListener(_onChanged);
    titleController.addListener(_onChanged);
  }

  void _onChanged() {
    if (!_loaded || _disposed) return;
    _debounce?.cancel();
    _debounce = Timer(debounceDuration, _flush);
  }

  Future<void> _flush() async {
    if (_disposed || _saving) return;
    final reply = contentController.text;
    final title = titleController.text;
    if (reply == _lastSavedReply && title == _lastSavedTitle) return;
    // Discourse auto-deletes drafts whose reply text is empty/whitespace,
    // so only POST when we have something worth saving.
    if (reply.trim().isEmpty && title.trim().isEmpty) return;
    final proxy = SiteProxyFactory.getPostProxy();
    if (proxy is! DiscoursePostProxy) return;
    _saving = true;
    try {
      final ok = await proxy.saveDraftAsync(
        draftKey: draftKey,
        data: {
          ...extraData,
          'reply': reply,
          if (title.isNotEmpty) 'title': title,
        },
      );
      if (ok) {
        _lastSavedReply = reply;
        _lastSavedTitle = title;
      }
    } finally {
      _saving = false;
    }
  }

  /// Force a save right now (skipping the debounce). Useful when the
  /// user backgrounds the app or the page is about to be popped.
  Future<void> flushNow() async {
    _debounce?.cancel();
    await _flush();
  }

  /// Delete the draft from the server. Call after a successful submit
  /// so the next composer open starts fresh.
  Future<void> discard() async {
    _debounce?.cancel();
    final proxy = SiteProxyFactory.getPostProxy();
    if (proxy is! DiscoursePostProxy) return;
    try {
      await proxy.deleteDraftAsync(draftKey);
    } catch (_) {
      // Best-effort; server-side drafts auto-expire.
    }
  }

  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    contentController.removeListener(_onChanged);
    titleController.removeListener(_onChanged);
  }
}
