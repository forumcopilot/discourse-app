import 'dart:convert';

import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/network/fc_call_result.dart';

import 'network/discourse_client.dart';

/// Common base for every `Discourse*Proxy`.
///
/// Phase 1+ proxies talk to Discourse over plain REST — call [apiGet] /
/// [apiPost] / [apiPut] / [apiDelete] and parse the JSON response into the
/// matching `FC*Result` type yourself.
///
/// There is no plugin-call escape hatch: the XenForo-era
/// `callPluginApi`/`callPluginApiTyped` pair (which only ever threw) was
/// removed once the last Phase 0 stub was rewritten. Discourse v1 talks
/// stock REST, full stop.
abstract class BaseDiscourseProxy {
  final SiteContext siteContext;
  final DiscourseClient _client;

  BaseDiscourseProxy(this.siteContext, {DiscourseClient? client})
      : _client = client ?? DiscourseClient();

  // ===== REST primitives =====

  Future<Map<String, dynamic>> apiGet(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final result = await _client.get(siteContext, path, query: query);
    return _decode(result, method: 'GET', path: path);
  }

  Future<Map<String, dynamic>> apiPost(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    final result =
        await _client.post(siteContext, path, query: query, body: body);
    return _decode(result, method: 'POST', path: path);
  }

  Future<Map<String, dynamic>> apiPut(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    final result =
        await _client.put(siteContext, path, query: query, body: body);
    return _decode(result, method: 'PUT', path: path);
  }

  Future<Map<String, dynamic>> apiDelete(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    final result =
        await _client.delete(siteContext, path, query: query, body: body);
    return _decode(result, method: 'DELETE', path: path);
  }

  Map<String, dynamic> _decode(
    FCCallResult result, {
    required String method,
    required String path,
  }) {
    siteContext.setLastCallResponse(result);

    if (result.statusCode < 200 || result.statusCode >= 300) {
      throw DiscourseApiException(
        statusCode: result.statusCode,
        method: method,
        path: path,
        body: result.body,
      );
    }
    final body = result.body;
    if (body.isEmpty) return const {};
    final dynamic decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      // 2xx with a non-JSON body (e.g. an HTML page from a proxy/CDN).
      // Surface as DiscourseApiException so the proxies' existing
      // `on DiscourseApiException` handlers catch it instead of a raw
      // FormatException escaping to the generic catch-all.
      final snippet = body.length > 200 ? '${body.substring(0, 200)}…' : body;
      throw DiscourseApiException(
        statusCode: result.statusCode,
        method: method,
        path: path,
        body: jsonEncode({
          'errors': ['Server returned a non-JSON response: $snippet'],
        }),
      );
    }
    if (decoded is Map<String, dynamic>) return decoded;
    // Non-object top level — i.e. the endpoint returned a bare JSON ARRAY
    // (Discourse does this for e.g. /tag_groups filter lists). Every
    // proxy signature returns a Map, so wrap it under `_value` rather
    // than lose it.
    return {'_value': decoded};
  }

  // ===== Convenience accessors =====

  bool get isAuthenticated => siteContext.isLoggedIn;
  String? get currentUserId => siteContext.currentUserId;
  String? get currentUsername => siteContext.currentUsername;

  // ===== Attachment markdown helpers (Phase 5.19) =====

  /// Append Discourse-flavoured Markdown image / file references for
  /// each uploaded attachment onto a post's `raw` body.
  ///
  /// `attachmentRefs` should be a list of Discourse `short_url` strings
  /// (`upload://abc12345.png`) — that's what `DiscourseAttachmentProxy`
  /// stashes into `FCAttachmentUploadResult.groupId` after a successful
  /// upload. The composer pages reinterpret the SDK's legacy
  /// `attachmentIds` parameter as a list of these short_urls (XF used
  /// numeric IDs there; Discourse needs the short_url to build the
  /// markdown reference).
  ///
  /// For images (extension `.png` / `.jpg` / `.jpeg` / `.gif` / `.webp`
  /// / `.heic` / `.bmp` / `.svg`) we emit `![image](upload://...)`
  /// which Discourse renders inline. For anything else we emit
  /// `[file|attachment](upload://...)` which renders as a download
  /// chip — Discourse's standard non-image attachment syntax.
  ///
  /// Separator: two newlines between the existing body and the
  /// attachments block, single newlines between each ref. Matches
  /// what Discourse web inserts when you drop a file into the
  /// composer.
  String appendAttachmentMarkdown(
    String raw,
    List<String>? attachmentRefs,
  ) {
    if (attachmentRefs == null || attachmentRefs.isEmpty) return raw;
    // Filter to Discourse short_url refs only. The XF-shaped SDK
    // passes numeric attachment IDs through this same slot — the
    // edit flow seeds `_attachmentIds` from the existing post's
    // `FCAttachment.id` (a numeric id), which on Discourse isn't a
    // valid post reference. Those numeric IDs would otherwise emit
    // broken Markdown like `[file|attachment](42)`. Existing
    // attachments are already in the post raw via Markdown, so
    // they don't need to be re-appended anyway; the safe move is
    // to skip anything that isn't a Discourse upload short_url.
    final pending = attachmentRefs
        .where((url) =>
            url.isNotEmpty &&
            url.startsWith('upload://') &&
            // Dedup against refs the user already placed inline (the
            // message composer's tap-to-insert puts `![image](upload://...)`
            // at the cursor; we don't want to duplicate them at the
            // bottom on send).
            !raw.contains(url))
        .toList();
    if (pending.isEmpty) return raw;
    final block = pending.map(_markdownForUpload).join('\n');
    final trimmed = raw.trimRight();
    if (trimmed.isEmpty) return block;
    return '$trimmed\n\n$block';
  }

  String _markdownForUpload(String shortUrl) {
    final lower = shortUrl.toLowerCase();
    const imageExts = [
      '.png', '.jpg', '.jpeg', '.gif', '.webp', '.heic', '.bmp', '.svg',
    ];
    final isImage = imageExts.any(lower.endsWith);
    return isImage
        ? '![image]($shortUrl)'
        : '[file|attachment]($shortUrl)';
  }

}

/// Thrown by [BaseDiscourseProxy] when Discourse returns a non-2xx response.
/// Catch and translate to an `FC*Result(result: false, resultText: ...)` in
/// each proxy. Use [userMessage] when surfacing to the UI — that pulls just
/// the human-readable bit out of Discourse's `{ "errors": [...] }` envelope
/// instead of the framing wrapper.
/// Renders a caught error as the `resultText` of an `FC*Result`.
///
/// `resultText` is user-facing — the UI puts it in snackbars, error states
/// and dialogs — but every proxy used to build it as `'Error: ' + e`. For a
/// [DiscourseApiException] that interpolated the whole response body, so a
/// rate-limit JSON blob or an entire CDN HTML error page ended up on screen.
/// Discourse's own sentence ("You've performed this action too many
/// times…") is right there in the payload; this surfaces that instead.
String describeApiError(Object? error) {
  if (error is DiscourseApiException) return error.userMessage;
  if (error == null) return 'Something went wrong. Please try again.';
  final text = error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
  if (text.isEmpty || text.length > 200 || text.contains('<')) {
    return 'Something went wrong. Please try again.';
  }
  return text;
}

class DiscourseApiException implements Exception {
  final int statusCode;
  final String method;
  final String path;
  final String body;

  const DiscourseApiException({
    required this.statusCode,
    required this.method,
    required this.path,
    required this.body,
  });

  /// True when Discourse rejected the request with 401/403 — the User API
  /// Key has likely been revoked or never had the requested scope. The
  /// caller should clear stored credentials and trigger a re-handshake.
  bool get isAuthFailure => statusCode == 401 || statusCode == 403;

  /// User-facing summary. Discourse's standard error envelope is
  /// `{"errors": ["..."], "error_type": "..."}` — we extract the messages.
  /// Fallback shapes: `{"error": "..."}`, `{"message": "..."}`, or a raw
  /// status-code string.
  String get userMessage {
    if (body.isNotEmpty) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map) {
          final errors = decoded['errors'];
          if (errors is List && errors.isNotEmpty) {
            return errors.map((e) => e.toString()).join('; ');
          }
          for (final key in const ['error', 'message', 'reason']) {
            final v = decoded[key];
            if (v is String && v.isNotEmpty) return v;
          }
        }
      } catch (_) {
        // not JSON — fall through.
      }
    }
    if (statusCode == 0) return 'Network error';
    if (statusCode == 401 || statusCode == 403) {
      return 'Not authorized (HTTP $statusCode)';
    }
    if (statusCode == 404) return 'Not found';
    if (statusCode == 422) return 'Request rejected (HTTP 422)';
    // Discourse's middleware rate limiter answers text/plain, so there is no
    // `errors` array to read above — only the header tells us how long.
    if (statusCode == 429) {
      final wait = retryAfterSeconds;
      return wait == null
          ? "You're doing that too often. Please wait a moment and try again."
          : "You're doing that too often. Please wait $wait "
              "second${wait == 1 ? '' : 's'} and try again.";
    }
    if (statusCode >= 500) return 'Server error (HTTP $statusCode)';
    if (statusCode >= 300 && statusCode < 400) {
      return 'The forum redirected this request (HTTP $statusCode).';
    }
    return 'HTTP $statusCode';
  }

  /// True when Discourse throttled us. Callers that can wait should retry
  /// after [retryAfterSeconds] rather than showing an error.
  bool get isRateLimited => statusCode == 429;

  /// Seconds Discourse asked us to wait, when it said. Reads the app-level
  /// limiter's `extras.wait_seconds`; the middleware limiter's `Retry-After`
  /// header is handled in `DiscourseClient`, which retries before we get here.
  int? get retryAfterSeconds {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final wait = decoded['extras'] is Map
            ? (decoded['extras'] as Map)['wait_seconds']
            : null;
        if (wait is num) return wait.ceil();
        if (wait is String) return int.tryParse(wait);
      }
    } catch (_) {
      // text/plain 429 — no structured hint available.
    }
    return null;
  }

  /// Diagnostic form, for logs. Deliberately bounded: [body] can be an
  /// entire HTML error page from a CDN or reverse proxy, and this string
  /// used to be interpolated straight into user-facing widgets. Anything
  /// shown to a user should use [userMessage] (or `describeError`) instead.
  @override
  String toString() =>
      'DiscourseApiException($method $path → $statusCode): ${_bodySnippet()}';

  /// Bounded, markup-free rendering of [body].
  ///
  /// A body that isn't JSON did not come from Discourse — it is an edge
  /// server, proxy or captive portal answering instead. The bytes are noise
  /// in a log and were actively harmful when this string reached a dialog,
  /// so we report the shape rather than the content.
  String _bodySnippet() {
    final flattened = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (flattened.isEmpty) return '<empty body>';
    final looksLikeMarkup = flattened.startsWith('<');
    if (looksLikeMarkup) {
      final title = RegExp(r'<title[^>]*>(.*?)</title>', caseSensitive: false)
          .firstMatch(flattened)
          ?.group(1)
          ?.trim();
      final label = title != null && title.isNotEmpty ? ' "$title"' : '';
      return '<non-JSON response$label, ${body.length} bytes>';
    }
    return flattened.length > 160
        ? '${flattened.substring(0, 160)}…'
        : flattened;
  }
}
