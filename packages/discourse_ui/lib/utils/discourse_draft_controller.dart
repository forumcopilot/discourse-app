import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscourseComposerTiming;
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/models/entities/fc_draft.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_draft_proxy.dart';

import '../core/logging/app_logger.dart';
import '../l10n/app_l10n.dart';

/// Wraps a pair of [TextEditingController]s (title + content) and
/// transparently mirrors their contents to a server-side draft at the
/// configured `draftKey`, with debounce. Hand the controllers to
/// `MessageComposePage` and the rest just works.
///
/// Phase 5.34 — now routes through `IFCDraftProxy` instead of casting
/// to `DiscoursePostProxy`. The class name keeps the `Discourse`
/// prefix because the draft-key conventions (`topic_<id>`, `new_topic`,
/// `new_private_message`) are Discourse's; on a future XF backend this
/// controller would be renamed or replaced.
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

  /// Extra fields that change while writing (a message's recipients), read
  /// at each save and merged over [extraData]. Call [touch] when they change.
  final Map<String, dynamic> Function()? extraDataBuilder;

  // Keep delayed saves on the forum that opened this composer, even if
  // another forum becomes the globally selected site before they finish.
  late final IFCDraftProxy _draftProxy = SiteProxyService.getDraftProxy();

  Timer? _debounce;
  bool _saving = false;
  bool _pendingFlush = false;
  Future<void>? _inFlightSave;
  bool _disposed = false;
  bool _loaded = false;
  int _sequence = 0;
  String _lastSavedReply = '';
  String _lastSavedTitle = '';
  String _lastSavedExtra = '';
  bool _discarded = false;

  /// This composer's typing-time session (DiscourseComposerTiming): every
  /// post composer has a draft controller, so it is the one place that sees
  /// the writer type in all of them.
  final int _timingSession = DiscourseComposerTiming.instance.open();
  String _lastTimedText = '';

  /// What the composer held once it had opened (after the draft, or a
  /// quote, went in): what [changedSinceOpened] compares with.
  String? _openedReply;
  String? _openedTitle;
  String? _openedExtra;

  DiscourseDraftController({
    required this.draftKey,
    required this.titleController,
    required this.contentController,
    this.debounceDuration = const Duration(milliseconds: 1500),
    this.extraData = const {},
    this.extraDataBuilder,
  });

  Map<String, dynamic> get _extra => {
        ...extraData,
        ...?extraDataBuilder?.call(),
      };

  /// Save soon although the text is unchanged: something in
  /// [extraDataBuilder] (e.g. the recipients) changed.
  void touch() => _onChanged();

  /// Hydrate the controllers from the server-side draft (if any) and
  /// start watching for user changes. Returns the draft that was restored,
  /// for fields beyond the title and text (e.g. a message's recipients).
  Future<FCDraft?> initialize() async {
    FCDraft? restored;
    try {
      final result = await _draftProxy.loadDraftAsync(draftKey);
      if (_disposed) return null;
      final draft = result.draft;
      if (result.result && draft != null) {
        restored = draft;
        _sequence = draft.sequence;
        final reply = draft.reply;
        final title = draft.topicTitle ?? draft.title ?? '';
        // Only seed the field if it's currently empty — the caller may
        // already have populated initial text (e.g. quote prefill) and
        // we don't want to clobber that.
        if (reply.isNotEmpty && contentController.text.isEmpty) {
          contentController.text = reply;
          contentController.selection = TextSelection.fromPosition(
            TextPosition(offset: reply.length),
          );
        }
        if (title.isNotEmpty && titleController.text.isEmpty) {
          titleController.text = title;
        }
        _lastSavedReply = reply;
        _lastSavedTitle = title;
      }
    } catch (e) {
      AppLogger.debug('DiscourseDraftController initial load failed: $e');
    }
    if (_disposed) return null;
    _lastSavedExtra = _extra.toString();
    _openedReply = contentController.text;
    _openedTitle = titleController.text;
    _openedExtra = _lastSavedExtra;
    _loaded = true;
    _attach();
    return restored;
  }

  /// Takes what the composer holds now as what it opened with, for a page
  /// that restores more of the draft itself once [initialize] has returned
  /// (New Message's recipients). Without it the restored recipients read
  /// as a change, and closing a draft left untouched asked to discard it.
  void markOpened() {
    _openedReply = contentController.text;
    _openedTitle = titleController.text;
    _openedExtra = _extra.toString();
    // They came from the draft, so they are saved already.
    _lastSavedExtra = _openedExtra!;
  }

  /// Whether the writer has changed anything since the composer opened:
  /// what closing it should ask about. Before the draft has loaded, any
  /// text counts. A composer emptied of everything has nothing left to
  /// lose (its draft is deleted as it empties), so it does not count.
  bool get changedSinceOpened {
    final reply = contentController.text;
    final title = titleController.text;
    if (reply.trim().isEmpty && title.trim().isEmpty) return false;
    final openedReply = _openedReply;
    if (openedReply == null) {
      return reply.trim().isNotEmpty || title.trim().isNotEmpty;
    }
    return reply != openedReply ||
        title != _openedTitle ||
        _extra.toString() != _openedExtra;
  }

  void _attach() {
    contentController.addListener(_onChanged);
    titleController.addListener(_onChanged);
  }

  void _onChanged() {
    // Counted before the load guard: typing while a draft loads is typing.
    // The listeners also fire on cursor moves, so only a changed text counts.
    final text = '${titleController.text}\u0000${contentController.text}';
    if (text != _lastTimedText) {
      _lastTimedText = text;
      DiscourseComposerTiming.instance.typed(_timingSession);
    }
    if (!_loaded || _disposed || _discarded) return;
    _debounce?.cancel();
    // The timer fires into the void, so swallow save failures here —
    // otherwise a failed saveDraftAsync becomes an unhandled async
    // exception in the root zone.
    _debounce = Timer(debounceDuration, () {
      _flush().catchError((Object e) {
        AppLogger.debug('DiscourseDraftController debounced flush failed: $e');
      });
    });
  }

  Future<void> _flush() async {
    if (_disposed || _discarded) return;
    if (_saving) {
      // A save is already in flight — remember to re-flush when it
      // completes so edits made meanwhile aren't dropped.
      _pendingFlush = true;
      return;
    }
    _saving = true;
    final save = _saveLoop();
    _inFlightSave = save;
    try {
      await save;
    } finally {
      _saving = false;
      _inFlightSave = null;
    }
  }

  Future<void> _saveLoop() async {
    do {
      _pendingFlush = false;
      await _saveSnapshot(
        contentController.text,
        titleController.text,
        _extra,
      );
      // Disposal captures a final snapshot; discard must never re-save it.
    } while (_pendingFlush && !_disposed && !_discarded);
  }

  Future<void> _saveSnapshot(
    String reply,
    String title,
    Map<String, dynamic> extra,
  ) async {
    final extraKey = extra.toString();
    if (reply == _lastSavedReply &&
        title == _lastSavedTitle &&
        extraKey == _lastSavedExtra) {
      return;
    }
    if (reply.trim().isEmpty && title.trim().isEmpty) {
      if (_lastSavedReply.trim().isNotEmpty ||
          _lastSavedTitle.trim().isNotEmpty) {
        await _delete();
      }
    } else {
      final result = await _draftProxy.saveDraftAsync(
        draftKey: draftKey,
        sequence: _sequence,
        data: {
          ...extra,
          'reply': reply,
          if (title.isNotEmpty) 'title': title,
        },
      );
      if (!result.result) {
        throw Exception(
            result.resultText ?? appL10n().somethingWentWrongTryAgain);
      }
      if (result.sequence != null) _sequence = result.sequence!;
    }
    _lastSavedReply = reply;
    _lastSavedTitle = title;
    _lastSavedExtra = extraKey;
  }

  /// Force a save right now (skipping the debounce). Useful when the
  /// user backgrounds the app or the page is about to be popped.
  Future<void> flushNow() async {
    _debounce?.cancel();
    // Wait out any in-flight save first so we don't silently no-op,
    // then flush whatever is still unsaved.
    final inFlight = _inFlightSave;
    if (inFlight != null) {
      try {
        await inFlight;
      } catch (_) {
        // The retry below is the recovery path.
      }
    }
    await _flush();
  }

  /// Delete the draft from the server. Call after a successful submit, or
  /// when the writer discards it, so the next composer open starts fresh.
  Future<void> discard() async {
    _discarded = true;
    _debounce?.cancel();
    // Deleting with the previous sequence while a save is in flight can
    // silently do nothing, or the save can recreate a deleted draft.
    await _waitForSave(_inFlightSave);
    try {
      await _delete();
    } catch (_) {
      // Cleanup after a successful post remains best-effort: it must not
      // turn a successful submission into a retry that posts twice.
    }
  }

  Future<void> _delete() async {
    final result =
        await _draftProxy.deleteDraftAsync(draftKey, sequence: _sequence);
    if (!result.result) {
      throw Exception(
          result.resultText ?? appL10n().somethingWentWrongTryAgain);
    }
  }

  Future<void> _waitForSave(Future<void>? save) async {
    try {
      await save;
    } catch (_) {
      // A failed earlier request must not prevent the final operation.
    }
  }

  /// Stops watching. What was typed in the last moments before the
  /// composer closed, still waiting out the debounce, is saved on the way
  /// out: it used to be dropped, so a draft reopened without its last
  /// words.
  void dispose() {
    DiscourseComposerTiming.instance.close(_timingSession);
    _debounce?.cancel();
    contentController.removeListener(_onChanged);
    titleController.removeListener(_onChanged);
    if (_loaded && !_discarded && !_disposed) {
      // Capture before the page disposes its controllers. Even an expired
      // debounce may have queued edits behind the active save. Serialize
      // this snapshot (including a cleared draft) with that save's sequence.
      final reply = contentController.text;
      final title = titleController.text;
      final extra = _extra;
      final inFlight = _inFlightSave;
      _disposed = true;
      _waitForSave(inFlight)
          .then((_) => _saveSnapshot(reply, title, extra))
          .catchError((Object e) {
        AppLogger.debug('DiscourseDraftController final save failed: $e');
      });
    }
    _disposed = true;
  }
}
