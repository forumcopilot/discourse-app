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
/// The legacy [callPluginApi] / [callPluginApiTyped] entry points throw at
/// runtime; they remain on the class only so Phase 0 stub proxies (sed-renamed
/// XenForo code) still compile while we replace them one at a time.
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
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    // A few endpoints (e.g. /categories.json's `category_list`) return objects
    // at the top level. List-returning endpoints are rare; wrap them so the
    // caller still gets a Map to drill into.
    return {'_value': decoded};
  }

  // ===== Pagination / filter helpers (used by SDK-shaped proxies) =====

  Map<String, String> buildPaginationParams({
    int? page,
    int? perPage,
    int? startNum,
    int? lastNum,
  }) {
    final params = <String, String>{};
    if (page != null) {
      params['page'] = page.toString();
    } else if (startNum != null && lastNum != null) {
      final perPageValue = perPage ?? 20;
      final startPage = (startNum / perPageValue).floor() + 1;
      params['page'] = startPage.toString();
    }
    if (perPage != null) {
      params['per_page'] = perPage.toString();
    }
    return params;
  }

  Map<String, String> buildFilterParams({
    String? order,
    String? direction,
    bool? unread,
    String? threadType,
    int? prefixId,
    int? starterId,
    int? lastDays,
  }) {
    final params = <String, String>{};
    if (order != null) params['order'] = order;
    if (direction != null) params['direction'] = direction;
    if (unread != null) params['unread'] = unread.toString();
    if (threadType != null) params['thread_type'] = threadType;
    if (prefixId != null) params['prefix_id'] = prefixId.toString();
    if (starterId != null) params['starter_id'] = starterId.toString();
    if (lastDays != null) params['last_days'] = lastDays.toString();
    return params;
  }

  // ===== Convenience accessors =====

  bool get isAuthenticated => siteContext.isLoggedIn;
  String? get currentUserId => siteContext.currentUserId;
  String? get currentUsername => siteContext.currentUsername;

  // ===== Legacy plugin-call (deprecated, throws) =====

  /// Throws. Phase 0 stub proxies still call this; replace each with
  /// [apiGet]/[apiPost]/etc. against the appropriate Discourse endpoint as
  /// part of the per-proxy Phase 1+ work.
  @Deprecated(
    'Discourse has no plugin endpoint in v1. Use apiGet/apiPost/apiPut/apiDelete instead.',
  )
  Future<Map<String, dynamic>> callPluginApi(
      String method, Map<String, dynamic> params) {
    throw UnimplementedError(
      'callPluginApi is not implemented on Discourse — replace this proxy '
      "method with apiGet/apiPost. method='$method'",
    );
  }

  @Deprecated('See callPluginApi.')
  Future<T> callPluginApiTyped<T>(
    String method,
    Map<String, dynamic> params,
    T Function(Map<String, dynamic> json) parse,
  ) async {
    final response = await callPluginApi(method, params);
    return parse(response);
  }
}

/// Thrown by [BaseDiscourseProxy] when Discourse returns a non-2xx response.
/// Catch and translate to an `FC*Result(result: false, resultText: ...)` in
/// each proxy. Use [userMessage] when surfacing to the UI — that pulls just
/// the human-readable bit out of Discourse's `{ "errors": [...] }` envelope
/// instead of the framing wrapper.
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
    if (statusCode >= 500) return 'Server error (HTTP $statusCode)';
    return 'HTTP $statusCode';
  }

  @override
  String toString() =>
      'DiscourseApiException($method $path → $statusCode): $body';
}
