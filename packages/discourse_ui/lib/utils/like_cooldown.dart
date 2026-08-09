import 'dart:convert';

import 'package:forumcopilot_sdk/context/site_context.dart';

/// Per-post cooldown after Discourse rejects a like/reaction as too frequent.
///
/// Discourse allows **4 post actions per minute on a given post**, and the
/// like and the unlike path share that counter
/// (`PostAction.limit_action!` in app/models/post_action.rb and
/// `PostActionDestroyer`). Toggling a reaction a few times therefore hits a
/// 429 quickly, which the app used to surface only as a failure snackbar
/// after the fact — so the button stayed live and every further tap spent a
/// request that could not succeed.
///
/// Keyed by post id because the server limit is: the user can keep liking
/// *other* posts while one is cooling down.
///
/// Both like surfaces share this: the plain heart (`POST`/`DELETE
/// /post_actions`) and, on forums running discourse-reactions, the emoji
/// chip (`PUT /discourse-reactions/.../toggle.json`). They are different
/// routes but one server-side budget.
class LikeCooldown {
  LikeCooldown._();

  static final Map<String, DateTime> _until = <String, DateTime>{};

  /// Longest cooldown we will display. The limiter's window is a minute; a
  /// wildly larger value means we misread the payload, and pinning a button
  /// for that long would be worse than letting the tap fail honestly.
  static const Duration _maxCooldown = Duration(minutes: 5);

  /// Records a cooldown for [postId] if the last response was a 429.
  ///
  /// Reads the wait from the response the proxy layer stashed on
  /// [SiteContext] — `extras.wait_seconds` in the JSON body, falling back to
  /// the `Retry-After` header. Returns the recorded duration, or null when
  /// the failure was not a rate limit.
  static Duration? noteFromLastResponse(SiteContext context, String postId) {
    final result = context.lastCallResponse;
    if (result == null || result.statusCode != 429) return null;

    var seconds = _waitSecondsFromBody(result.body);
    if (seconds == null) {
      final header =
          result.headers['retry-after'] ?? result.headers['Retry-After'];
      seconds = header == null ? null : int.tryParse(header.trim());
    }
    if (seconds == null || seconds <= 0) return null;

    final wait = Duration(seconds: seconds);
    if (wait > _maxCooldown) return null;
    _until[postId] = DateTime.now().add(wait);
    return wait;
  }

  static int? _waitSecondsFromBody(String body) {
    if (body.isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final extras = decoded['extras'];
        if (extras is Map) {
          final wait = extras['wait_seconds'];
          if (wait is num) return wait.ceil();
          if (wait is String) return int.tryParse(wait);
        }
      }
    } catch (_) {
      // A middleware 429 is text/plain — the header covers that case.
    }
    return null;
  }

  /// Time left before [postId] may be liked again; zero when it is free.
  static Duration remaining(String postId) {
    final until = _until[postId];
    if (until == null) return Duration.zero;
    final left = until.difference(DateTime.now());
    if (left <= Duration.zero) {
      _until.remove(postId);
      return Duration.zero;
    }
    return left;
  }

  static bool isCoolingDown(String postId) =>
      remaining(postId) > Duration.zero;

  /// Whole seconds left, rounded up — what the countdown shows.
  static int secondsLeft(String postId) {
    final left = remaining(postId);
    if (left <= Duration.zero) return 0;
    return (left.inMilliseconds / 1000).ceil();
  }

  /// Clears everything. Call on logout — cooldowns are per user.
  static void clear() => _until.clear();
}
