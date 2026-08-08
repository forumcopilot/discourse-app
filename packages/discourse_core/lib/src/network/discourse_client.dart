import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

import 'package:dio/dio.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/network/fc_call_result.dart';
import 'package:forumcopilot_sdk/services/fc_http_client.dart';
import 'package:forumcopilot_sdk/services/fc_http_overrides.dart';

import '../context/discourse_site_context_extension.dart';

/// Thin HTTP wrapper around the SDK's [FCHttpClient] for talking to a
/// Discourse forum.
///
/// Auth model: User API Keys (https://meta.discourse.org/t/-/32504). When a
/// key has been provisioned via [DiscourseAuthManager] it is read off the
/// [SiteContext] and attached to every request as `User-Api-Key` /
/// `User-Api-Client-Id` headers. Anonymous calls (e.g. `/site.json` before
/// login) work without those headers.
///
/// Accept header is always `application/json` so we never have to worry about
/// the `.json` URL suffix Discourse uses for content negotiation; either form
/// works against the same controllers, and `Accept` is cleaner for the
/// non-resource endpoints (`/search`, `/user-api-key/revoke`, ...).
class DiscourseClient {
  Future<FCCallResult> get(
    SiteContext context,
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? extraHeaders,
  }) =>
      _request(context, 'GET', path, query: query, extraHeaders: extraHeaders);

  Future<FCCallResult> post(
    SiteContext context,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    Map<String, String>? extraHeaders,
  }) =>
      _request(context, 'POST', path,
          query: query, body: body, extraHeaders: extraHeaders);

  Future<FCCallResult> put(
    SiteContext context,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    Map<String, String>? extraHeaders,
  }) =>
      _request(context, 'PUT', path,
          query: query, body: body, extraHeaders: extraHeaders);

  Future<FCCallResult> delete(
    SiteContext context,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    Map<String, String>? extraHeaders,
  }) =>
      _request(context, 'DELETE', path,
          query: query, body: body, extraHeaders: extraHeaders);

  Future<FCCallResult> _request(
    SiteContext context,
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    Map<String, String>? extraHeaders,
  }) async {
    await FCDioClient.instance.initialize();

    final headers = <String, String>{
      'Accept': 'application/json',
      ...context.userApiAuthHeaders(),
      if (body != null) 'Content-Type': 'application/json',
      ...?extraHeaders,
    };

    // Some callers embed a query string in `path` ('/x.json?a=1').
    // `Uri.replace(path: ...)` percent-encodes an embedded '?' (→ '%3F'),
    // so split the suffix off and merge it into the query parameters.
    var effectivePath = path;
    var effectiveQuery = query;
    final qIndex = path.indexOf('?');
    if (qIndex >= 0) {
      effectivePath = path.substring(0, qIndex);
      final embedded = Uri.splitQueryString(path.substring(qIndex + 1));
      // Explicitly-passed query params win over path-embedded ones.
      effectiveQuery = <String, dynamic>{...embedded, ...?query};
    }

    final base = Uri.parse(context.site.url);
    final url = base.replace(path: _joinPath(base.path, effectivePath));
    final encodedBody =
        body is String ? body : (body == null ? null : jsonEncode(body));

    // Any write invalidates the read cache below — a reply, vote or edit is
    // usually followed immediately by a refetch of the thing that changed,
    // and that refetch must see the server's new state.
    if (method != 'GET' && !_isInertWrite(effectivePath)) {
      _readCache.clear();
      _inFlight.clear();
    }

    final cacheKey = method == 'GET' ? '$url|${_canonicalQuery(effectiveQuery)}' : null;
    if (cacheKey != null) {
      // Identical GET already in flight → share its result instead of
      // issuing a second one. Two widgets mounting in the same frame ask
      // for the same URL microseconds apart; the second request could only
      // ever return the same bytes.
      final pending = _inFlight[cacheKey];
      if (pending != null) {
        if (kDebugMode) debugPrint('🌐 [HTTP coalesced] $method ${url.path}');
        return pending;
      }
      final cached = _readCache[cacheKey];
      if (cached != null && !cached.isStale) {
        if (kDebugMode) debugPrint('🌐 [HTTP cache-hit] $method ${url.path}');
        return cached.result;
      }
      _readCache.remove(cacheKey);
    }

    if (cacheKey != null) {
      // Registered synchronously: nothing may suspend between the pending
      // check above and this assignment, or two same-frame callers would both
      // miss and both hit the network. The rate-limit clearance await lives
      // INSIDE the registered future for exactly that reason.
      final future = _sendAfterClearance(
        method,
        url,
        headers: headers,
        encodedBody: encodedBody,
        effectiveQuery: effectiveQuery,
      );
      _inFlight[cacheKey] = future;
      try {
        final result = await future;
        // Only successful reads are worth repeating; an error must not be
        // pinned for the next few seconds.
        if (result.statusCode >= 200 && result.statusCode < 300) {
          _readCache[cacheKey] = _CachedResponse(result, _ttlForPath(url.path));
        }
        return result;
      } finally {
        _inFlight.remove(cacheKey);
      }
    }

    return _sendAfterClearance(
      method,
      url,
      headers: headers,
      encodedBody: encodedBody,
      effectiveQuery: effectiveQuery,
    );
  }

  /// [_send], gated on any active rate-limit cooldown.
  ///
  /// A 429 anywhere puts the whole client on hold until the server's stated
  /// cooldown expires — see the handler in [_send]. Cache and in-flight hits
  /// are served before this gate, so a rate-limited app still renders what
  /// it has.
  Future<FCCallResult> _sendAfterClearance(
    String method,
    Uri url, {
    required Map<String, String> headers,
    required String? encodedBody,
    required Map<String, dynamic>? effectiveQuery,
  }) async {
    await _awaitRateLimitClearance();

    if (kDebugMode) {
      _requestCount++;
      debugPrint('🌐 [HTTP #$_requestCount] $method ${url.path}');
    }

    return _send(
      method,
      url,
      headers: headers,
      encodedBody: encodedBody,
      effectiveQuery: effectiveQuery,
    );
  }

  /// Concurrent identical GETs, keyed by URL + query.
  static final Map<String, Future<FCCallResult>> _inFlight =
      <String, Future<FCCallResult>>{};

  /// Writes that change nothing the app subsequently reads, and so must not
  /// drop the read cache.
  ///
  /// `/topics/timings` is Discourse's read-tracking beacon: the app posts it
  /// automatically on viewing a topic, and it alters only per-user read state.
  /// Because clear-on-write is indiscriminate, it was wiping the whole cache
  /// mid-navigation: the topic loaded, the beacon fired, the cache emptied,
  /// and the very next read of the same topic went back to the network.
  ///
  /// Logged-in sessions only. `DiscourseTopicProxy.markTopicReadAsync` returns
  /// early for guests, so an anonymous session never posts the beacon and this
  /// path is unreachable — which is why an anonymous A/B of a cold launch
  /// shows no change. Verified instead in
  /// `test/discourse_client_measurement_test.dart`.
  static bool _isInertWrite(String path) => path.startsWith('/topics/timings');

  /// Stable string for a query map, so the same request always produces the
  /// same cache key.
  ///
  /// This was `jsonEncode(query)`, which made two callers asking for the
  /// identical URL miss each other: one passing no query encoded to `"null"`
  /// and one passing an empty map to `"{}"`. It also preserved Dart's
  /// insertion order, so the same parameters passed in a different order
  /// keyed apart. Both are demonstrated in
  /// `test/discourse_client_measurement_test.dart`.
  ///
  /// Latent, not observed: an A/B of a real cold launch against
  /// try.discourse.org showed no difference — the bootstrap's callers happen
  /// to agree on spelling, so `/about.json` went out once and hit the cache
  /// three times either way. This guards a mismatch the current call sites
  /// don't have rather than fixing one they do; the sorted, encoded key costs
  /// nothing and stops it becoming a live bug the next time a caller passes
  /// `{}` or reorders a map.
  ///
  /// Keys and values are percent-encoded, matching what Dio puts on the wire.
  /// Without that, a VALUE containing '&' or '=' (a search term, say) aliases
  /// a structurally different query — `{q: '1&safe=2'}` and
  /// `{q: '1', safe: '2'}` are different requests but would share a key, and
  /// the second caller would be served the first one's bytes.
  static String _canonicalQuery(Map<String, dynamic>? query) {
    if (query == null || query.isEmpty) return '';
    final keys = query.keys.toList()..sort();
    return keys
        .map((k) => '${Uri.encodeQueryComponent(k)}='
            '${Uri.encodeQueryComponent('${query[k]}')}')
        .join('&');
  }

  /// Very short-lived GET results. This exists to absorb *redundant* reads —
  /// the bootstrap sequence re-verifying the site, and every tab resetting
  /// when the login state settles — not to be a real cache. A cold launch
  /// issued 15 requests for 7 distinct URLs before this; `/about.json`,
  /// `/categories.json` and `/chat/api/me/channels` were each fetched three
  /// times within 350ms. Discourse rate-limits at 50 requests / 10s per IP,
  /// so that waste is what pushes an ordinary session into a 429.
  ///
  /// Deliberately shorter than any human refresh gesture, and dropped
  /// wholesale on any write, so a user-initiated refresh always hits the
  /// network.
  static final Map<String, _CachedResponse> _readCache =
      <String, _CachedResponse>{};

  /// Clears cached reads. Call when the session changes — a different user
  /// may see entirely different content at the same URLs.
  static void invalidateReadCache() {
    _readCache.clear();
    _inFlight.clear();
  }

  /// When the server last told us to back off, and until when.
  ///
  /// Shared across every request because Discourse's limiter is per User API
  /// Key and the app has exactly one — so "this request was rate limited"
  /// really means "the app is rate limited".
  static DateTime? _rateLimitedUntil;

  /// Blocks until any server-imposed cooldown has elapsed.
  ///
  /// Capped by [_maxAutoRetryDelay] so a hostile or nonsensical `Retry-After`
  /// cannot wedge the app; past that the request goes out and is allowed to
  /// fail honestly.
  static Future<void> _awaitRateLimitClearance() async {
    final until = _rateLimitedUntil;
    if (until == null) return;

    final remaining = until.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      _rateLimitedUntil = null;
      return;
    }
    if (remaining > _maxAutoRetryDelay) {
      _rateLimitedUntil = null;
      return;
    }

    if (kDebugMode) {
      debugPrint('🌐 [HTTP holding ${remaining.inSeconds}s] rate limited');
    }
    await Future<void>.delayed(remaining);
    _rateLimitedUntil = null;
  }

  Future<FCCallResult> _send(
    String method,
    Uri url, {
    required Map<String, String> headers,
    required String? encodedBody,
    required Map<String, dynamic>? effectiveQuery,
  }) async {
    // Discourse rate-limits per IP (50 req/10s, 200 req/min by default) and
    // per action. Both limits say exactly how long to wait — the middleware
    // via `Retry-After`, the app-level limiter via `extras.wait_seconds` —
    // so a burst on a tab switch should cost a short pause, not an error
    // screen. One retry only: a second 429 means we are genuinely over
    // budget and the caller should surface it.
    var attempt = 0;
    while (true) {
      FCCallResult result;
      try {
        final response = await FCHttpClient.request<String>(
          method,
          url,
          headers: headers,
          body: encodedBody,
          queryParameters: effectiveQuery,
          responseType: ResponseType.plain,
        );
        result = _toCallResult(response, method: method, url: url);
      } on DioException catch (e) {
        result = _toCallResultFromException(e, method: method, url: url);
      } catch (e) {
        return FCCallResult(
          statusCode: 0,
          body: jsonEncode({'error': e.toString()}),
          headers: const {},
          fcIsLogin: false,
        );
      }

      if (result.statusCode != 429) return result;

      // Hold EVERY request, not just this one. The limiter is per User API Key
      // and the whole app shares one key, so a screen that fans out on mount
      // would otherwise send its remaining calls straight into the same wall
      // and turn one 429 into several. Recording the cooldown here makes the
      // next caller wait instead of spending budget it does not have.
      final wait = _retryAfter(result);
      if (wait != null) {
        final until = DateTime.now().add(wait);
        if (_rateLimitedUntil == null || until.isAfter(_rateLimitedUntil!)) {
          _rateLimitedUntil = until;
        }
      }

      if (attempt >= 1) return result;
      if (wait == null || wait > _maxAutoRetryDelay) return result;
      attempt++;
      await Future<void>.delayed(wait);
    }
  }

  /// Default lifetime for a cached GET: shorter than any human refresh gesture,
  /// so a deliberate pull-to-refresh always reaches the network.
  static const Duration _readCacheTtl = Duration(seconds: 3);

  /// Longer lifetimes for endpoints whose content does not meaningfully change
  /// within a session.
  ///
  /// Three seconds does not survive a screen transition, so returning to the
  /// forum home refetched `/categories.json` and `/latest.json` every time.
  /// Measured against try.discourse.org, an ordinary minute of browsing —
  /// open forum, read a topic, check profile, come back — cost ~17 requests
  /// against Discourse's per-User-API-Key ceiling of 20/minute
  /// (`max_user_api_reqs_per_minute`). Repeat fetches of static configuration
  /// were a large share of that.
  ///
  /// Matched on the URL path, longest prefix first. Any write still drops the
  /// whole cache, so these never mask the user's own changes.
  static const Map<String, Duration> _readCacheTtlByPath = {
    // Forum configuration. Fixed for the life of a session in practice; a
    // restart or a write picks up any change.
    '/about.json': Duration(minutes: 30),
    '/site/settings.json': Duration(minutes: 30),
    '/site/basic-info.json': Duration(minutes: 30),
    // Category tree changes rarely, and is refetched on every return to home.
    '/categories.json': Duration(minutes: 5),
  };

  /// TTL for [path], falling back to [_readCacheTtl].
  static Duration _ttlForPath(String path) {
    final exact = _readCacheTtlByPath[path];
    if (exact != null) return exact;
    return _readCacheTtl;
  }

  /// Debug-only counter so request volume is visible in logcat. Discourse
  /// rate-limits at 50 requests / 10s per IP, which is easy to trip when a
  /// screen fans out on mount.
  static int _requestCount = 0;

  /// Longest 429 cooldown we will absorb silently. Beyond this the caller
  /// gets the error so the UI can say how long to wait rather than appear
  /// to hang.
  static const Duration _maxAutoRetryDelay = Duration(seconds: 10);

  /// How long Discourse asked us to wait, from either 429 shape:
  /// the middleware's `Retry-After` header (plain-text body) or the
  /// app-level limiter's `extras.wait_seconds` (JSON body).
  static Duration? _retryAfter(FCCallResult result) {
    final header = result.headers['retry-after'] ?? result.headers['Retry-After'];
    final headerSeconds = header == null ? null : int.tryParse(header.trim());
    if (headerSeconds != null && headerSeconds >= 0) {
      return Duration(seconds: headerSeconds);
    }
    try {
      final decoded = jsonDecode(result.body);
      if (decoded is Map) {
        final extras = decoded['extras'];
        if (extras is Map) {
          final wait = extras['wait_seconds'];
          final seconds = wait is num
              ? wait.ceil()
              : (wait is String ? int.tryParse(wait) : null);
          if (seconds != null && seconds >= 0) {
            return Duration(seconds: seconds);
          }
        }
      }
    } catch (_) {
      // Middleware 429s are text/plain — the header above is the signal.
    }
    return null;
  }

  FCCallResult _toCallResult(
    Response<dynamic> response, {
    required String method,
    required Uri url,
  }) {
    final headers = <String, String>{};
    response.headers.forEach((k, v) {
      if (v.isNotEmpty) headers[k] = v.first;
    });
    final status = response.statusCode ?? 0;
    final body = status >= 300 && status < 400
        ? _redirectDiagnostic(status, headers, method: method, url: url)
        : (response.data?.toString() ?? '');
    return FCCallResult(
      statusCode: status,
      body: body,
      headers: headers,
      // `fcIsLogin` is the XenForo plugin's per-response "this call was
      // authenticated" echo. Discourse has no equivalent — a 2xx says
      // nothing about whether the User-Api-Key was honoured or the route
      // is simply public. Always false, deliberately: session state lives
      // on SiteContext (set by the handshake) and the proxy layer reads
      // the real signals (401/403 → key revoked). The old comment here
      // claimed we set it from the header, which the code never did.
      fcIsLogin: false,
    );
  }

  /// Turns a redirect into an actionable message instead of letting an edge
  /// server's HTML error page reach the user as "HTTP 302".
  ///
  /// A 3xx surfacing here means the redirect was **not** followed, which in
  /// practice only happens for requests with a body — so reads keep working
  /// (Dart follows those transparently) while every write fails. That
  /// asymmetry makes a wrong [SiteContext.site.url] look like a bug in the
  /// app rather than a misconfiguration: the fix is almost always to point
  /// `AppForumConfig.forumBaseUrl` at the origin the forum actually serves.
  String _redirectDiagnostic(
    int status,
    Map<String, String> headers, {
    required String method,
    required Uri url,
  }) {
    final location = headers['location'] ?? headers['Location'] ?? '';
    final target = location.isEmpty ? null : Uri.tryParse(location);
    final sameOrigin = target != null &&
        target.host.toLowerCase() == url.host.toLowerCase() &&
        target.scheme == url.scheme;

    final String message;
    if (target == null) {
      message = 'The forum redirected $method ${url.path} (HTTP $status) '
          'without saying where. Check that the forum URL is correct.';
    } else if (sameOrigin) {
      message = 'The forum redirected $method ${url.path} to '
          '${target.path} (HTTP $status). The request was not retried.';
    } else {
      // The common case, and the one worth spelling out: the configured
      // host is not the forum's canonical origin.
      message = 'This forum is served from ${target.origin}, but the app is '
          'configured for ${url.origin}. Reads still work because redirects '
          'are followed automatically, but posting, replying and other '
          'writes fail. Set AppForumConfig.forumBaseUrl to ${target.origin}.';
    }
    return jsonEncode({
      'errors': [message],
      'error_type': 'redirect',
      if (location.isNotEmpty) 'location': location,
    });
  }

  FCCallResult _toCallResultFromException(
    DioException e, {
    required String method,
    required Uri url,
  }) {
    final headers = <String, String>{};
    e.response?.headers.forEach((k, v) {
      if (v.isNotEmpty) headers[k] = v.first;
    });
    String body = '';
    final status = e.response?.statusCode ?? 0;
    if (status >= 300 && status < 400) {
      return FCCallResult(
        statusCode: status,
        body: _redirectDiagnostic(status, headers, method: method, url: url),
        headers: headers,
        fcIsLogin: false,
      );
    }
    final data = e.response?.data;
    if (data is String) {
      body = data;
    } else if (data != null) {
      body = data.toString();
    }
    if (body.isEmpty) {
      body = jsonEncode({
        'error': e.message ?? 'HTTP request failed',
        'type': e.type.toString(),
      });
    }
    return FCCallResult(
      statusCode: e.response?.statusCode ?? 0,
      body: body,
      headers: headers,
      fcIsLogin: false,
    );
  }

  String _joinPath(String basePath, String suffix) {
    if (basePath.isEmpty || basePath == '/') return suffix;
    final left =
        basePath.endsWith('/') ? basePath.substring(0, basePath.length - 1) : basePath;
    return suffix.startsWith('/') ? '$left$suffix' : '$left/$suffix';
  }
}


class _CachedResponse {
  final FCCallResult result;
  final DateTime storedAt;

  /// Per-entry rather than a single global constant, so configuration endpoints
  /// can outlive a screen transition while feeds stay near-live.
  final Duration ttl;

  _CachedResponse(this.result, this.ttl) : storedAt = DateTime.now();

  bool get isStale => DateTime.now().difference(storedAt) > ttl;
}
