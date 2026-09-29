import 'package:flutter/foundation.dart' show visibleForTesting;

/// How long the writer had the composer open, and how much of that they spent
/// typing — what Discourse's web composer sends with every new post as
/// `composer_open_duration_msecs` and `typing_duration_msecs`
/// (frontend models/composer.js).
///
/// Discourse reads them in its first-post checks (NewPostManager.is_fast_typer?):
/// a trust-level-0 user's first post typed in less than `fast_typing_threshold`
/// (3 s by default) is held for review and the user silenced — "New user typed
/// too fast". A User API Key post gets those checks (only admin API keys skip
/// them), and a missing value reads as 0 ms, so before this every new user's
/// first post from the app was held on every forum with default settings.
///
/// Typing time is counted the web composer's way: 100 ms for each 100 ms in
/// which the text changed (its `typing()` is throttled to 100 ms), so a paste
/// counts once and time spent reading does not count at all.
///
/// One composer is open at a time; each takes a session from [open], which
/// [typed] and [close] name, so a composer closing late cannot clear the
/// next one's timing. [BaseDiscourseProxy.apiPost] adds the fields to every
/// `POST /posts.json` while a session is open ([applyTo]).
class DiscourseComposerTiming {
  DiscourseComposerTiming._();
  static final DiscourseComposerTiming instance = DiscourseComposerTiming._();

  static const String typingKey = 'typing_duration_msecs';
  static const String openKey = 'composer_open_duration_msecs';

  @visibleForTesting
  DateTime Function() clock = DateTime.now;

  int _session = 0;
  int? _openSession;
  DateTime? _openedAt;
  DateTime? _lastTick;
  int _typingMs = 0;

  /// A composer opened. Returns its session.
  int open() {
    _session++;
    _openSession = _session;
    _openedAt = clock();
    _lastTick = null;
    _typingMs = 0;
    return _session;
  }

  /// The writer changed the text in composer [session].
  void typed(int session) {
    if (session != _openSession) return;
    final now = clock();
    final last = _lastTick;
    if (last == null || now.difference(last).inMilliseconds >= 100) {
      _typingMs += 100;
      _lastTick = now;
    }
  }

  /// Composer [session] closed; nothing is sent for it any more.
  void close(int session) {
    if (session != _openSession) return;
    _openSession = null;
    _openedAt = null;
    _lastTick = null;
    _typingMs = 0;
  }

  /// The two fields for the open composer, or null when none is open. Not
  /// consumed: a post that fails and is sent again carries them again.
  Map<String, int>? get current {
    final opened = _openedAt;
    if (_openSession == null || opened == null) return null;
    return {
      typingKey: _typingMs,
      openKey: clock().difference(opened).inMilliseconds,
    };
  }

  /// [body] with the timing added when [path] creates a post and the body
  /// does not already say — what [BaseDiscourseProxy.apiPost] sends.
  Object? applyTo(String path, Object? body) {
    if (path != '/posts.json' || body is! Map<String, dynamic>) return body;
    final timing = current;
    if (timing == null) return body;
    return <String, dynamic>{...timing, ...body};
  }
}
