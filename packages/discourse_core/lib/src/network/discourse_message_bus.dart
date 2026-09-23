import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart' show debugPrint, visibleForTesting;
import 'package:forumcopilot_sdk/context/site_context.dart';

import 'discourse_client.dart';

/// A MessageBus client for one forum: how Discourse pushes live updates
/// (chat messages, edits, reactions) to its own web client.
///
/// It long-polls `POST /message-bus/{clientId}/poll` with the subscribed
/// channels and their last seen ids. The server holds the request until
/// something is published (or ~25 s pass) and answers with a JSON array of
/// `{channel, message_id, data}`; `Dont-Chunk: true` asks for that plain
/// array instead of a streamed response (message_bus Rack middleware).
///
/// Budget. Every request made with a User API Key counts against that key's
/// limits — 20 a minute and 2,880 a day by default
/// (`max_user_api_reqs_per_*`, Auth::DefaultCurrentUserProvider), message-bus
/// polls included. So polls start at least [minInterval] apart: an idle
/// channel costs one request per ~25 s hold, and a busy one is capped at
/// 60 / [minInterval] a minute, leaving the rest of the key's budget for the
/// app. Chat used to re-fetch 50 messages every 4 s (15 a minute).
///
/// A newer poll with the same client id and a higher `__seq` replaces the
/// one the server is holding (MessageBus::ConnectionManager#add_client), so
/// changing the channel set simply starts the next poll.
class DiscourseMessageBus {
  DiscourseMessageBus(
    this.siteContext, {
    DiscourseClient? client,
    this.minInterval = const Duration(seconds: 6),
    Random? random,
  })  : _client = client ?? DiscourseClient(),
        clientId = _randomId(random ?? Random.secure());

  /// The bus for [context]'s forum, shared by everything that subscribes.
  static DiscourseMessageBus of(SiteContext context) =>
      _byContext[context] ??= DiscourseMessageBus(context);

  static final Expando<DiscourseMessageBus> _byContext =
      Expando('discourseMessageBus');

  final SiteContext siteContext;
  final DiscourseClient _client;

  /// Least time between the starts of two polls.
  final Duration minInterval;

  /// Identifies this app instance to the server for the life of the object.
  final String clientId;

  final Map<String, _Subscription> _subscriptions = {};
  int _seq = 0;
  bool _stopped = false;
  DateTime? _lastPollStart;
  Duration _backoff = Duration.zero;

  /// Pending start of the next poll.
  Timer? _timer;

  /// `__seq` of the newest poll sent; only its answer schedules the next.
  int _latestSeq = 0;

  /// Whether a poll is waiting on the server.
  bool get _inFlight => _inFlightSeq != null;
  int? _inFlightSeq;

  /// Set when the server refuses message-bus requests for this key (401/403:
  /// the key predates the `message_bus` scope, or the forum disallows it).
  /// Callers fall back to fetching.
  bool get isUnavailable => _unavailable;
  bool _unavailable = false;

  /// Channels currently subscribed, for tests and diagnostics.
  @visibleForTesting
  Map<String, int> get lastIds =>
      {for (final e in _subscriptions.entries) e.key: e.value.lastId};

  /// Deliver each message published to [channel] after [lastId] to
  /// [onMessage]. `-1` means "only what is published from now on". Returns a
  /// function that removes this listener.
  void Function() subscribe(
    String channel,
    void Function(Map<String, dynamic> data) onMessage, {
    int lastId = -1,
  }) {
    final isNew = !_subscriptions.containsKey(channel);
    final sub = _subscriptions.putIfAbsent(channel, () => _Subscription(lastId));
    // A newer starting point from a fresh fetch wins; an older one would
    // replay what the caller already has.
    if (lastId > sub.lastId) sub.lastId = lastId;
    sub.listeners.add(onMessage);
    _stopped = false;
    // A poll the server is holding does not include a new channel; start a
    // newer one (which replaces it) instead of waiting out the hold. Another
    // listener on a channel already polled needs no request.
    if (isNew || !_inFlight) _schedule();
    return () {
      sub.listeners.remove(onMessage);
      if (sub.listeners.isEmpty) _subscriptions.remove(channel);
    };
  }

  /// Stop polling until the next [subscribe]; subscriptions are dropped.
  /// For sign-out and tests.
  void close() {
    _stopped = true;
    _subscriptions.clear();
    _timer?.cancel();
    _timer = null;
  }

  /// Arrange the next poll: now if nothing is waiting on the server, or to
  /// replace the one that is (see [subscribe]), never sooner than
  /// [minInterval] after the last start or before a backoff ends.
  void _schedule() {
    if (_timer != null || _stopped || _unavailable) return;
    if (_subscriptions.isEmpty) return;
    _timer = Timer(_nextStartDelay(), () {
      _timer = null;
      if (_stopped || _subscriptions.isEmpty || _unavailable) return;
      unawaited(_poll());
    });
  }

  Future<void> _poll() async {
    _lastPollStart = DateTime.now();
    final seq = ++_seq;
    _latestSeq = seq;
    _inFlightSeq = seq;
    final body = <String, Object>{
      for (final e in _subscriptions.entries) e.key: e.value.lastId,
      '__seq': seq,
    };
    try {
      final result = await _client.post(
        siteContext,
        '/message-bus/$clientId/poll',
        body: jsonEncode(body),
        extraHeaders: const {'Dont-Chunk': 'true'},
      );
      final code = result.statusCode;
      if (code == 200) {
        // Even a superseded poll's answer is real data.
        _deliver(result.body);
        if (seq == _latestSeq) _backoff = Duration.zero;
      } else if (code == 401 || code == 403) {
        debugPrint('[MessageBus] refused (HTTP $code) — falling back');
        _unavailable = true;
      } else if (code == 429) {
        final retry = int.tryParse(result.headers['retry-after'] ??
                result.headers['Retry-After'] ??
                '') ??
            30;
        _backoff = Duration(seconds: retry.clamp(5, 300));
      } else if (seq == _latestSeq) {
        _growBackoff();
      }
    } catch (e) {
      debugPrint('[MessageBus] poll failed: $e');
      if (seq == _latestSeq) _growBackoff();
    } finally {
      if (_inFlightSeq == seq) _inFlightSeq = null;
    }
    // Only the newest poll keeps the chain going; a replaced one just ends.
    if (seq == _latestSeq) _schedule();
  }

  Duration _nextStartDelay() {
    final last = _lastPollStart;
    final spacing = last == null
        ? Duration.zero
        : minInterval - DateTime.now().difference(last);
    return spacing > _backoff ? spacing : _backoff;
  }

  void _growBackoff() {
    final next = _backoff == Duration.zero
        ? const Duration(seconds: 5)
        : _backoff * 2;
    _backoff = next > const Duration(minutes: 2)
        ? const Duration(minutes: 2)
        : next;
  }

  void _deliver(String body) {
    if (body.trim().isEmpty) return;
    final Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      return;
    }
    if (decoded is! List) return;
    for (final raw in decoded.whereType<Map>()) {
      final channel = raw['channel']?.toString();
      if (channel == null) continue;
      if (channel == '/__status') {
        // The server's current ids for channels subscribed at -1: start
        // there, so nothing already published is replayed.
        final ids = raw['data'];
        if (ids is Map) {
          ids.forEach((k, v) {
            final sub = _subscriptions[k.toString()];
            if (sub != null && v is num && v.toInt() > sub.lastId) {
              sub.lastId = v.toInt();
            }
          });
        }
        continue;
      }
      final sub = _subscriptions[channel];
      if (sub == null) continue;
      final id = (raw['message_id'] as num?)?.toInt();
      if (id != null) {
        if (id <= sub.lastId) continue; // already delivered
        sub.lastId = id;
      }
      final data = raw['data'];
      if (data is! Map) continue;
      final payload = data.cast<String, dynamic>();
      for (final listener in List.of(sub.listeners)) {
        try {
          listener(payload);
        } catch (e) {
          debugPrint('[MessageBus] listener for $channel threw: $e');
        }
      }
    }
  }

  static String _randomId(Random random) {
    const hex = '0123456789abcdef';
    return List.generate(32, (_) => hex[random.nextInt(16)]).join();
  }
}

class _Subscription {
  _Subscription(this.lastId);

  int lastId;
  final List<void Function(Map<String, dynamic>)> listeners = [];
}

