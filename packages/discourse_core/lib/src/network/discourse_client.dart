import 'dart:convert';

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

    final base = Uri.parse(context.site.url);
    final url = base.replace(path: _joinPath(base.path, path));
    final encodedBody =
        body is String ? body : (body == null ? null : jsonEncode(body));

    try {
      final response = await FCHttpClient.request<String>(
        method,
        url,
        headers: headers,
        body: encodedBody,
        queryParameters: query,
        responseType: ResponseType.plain,
      );
      return _toCallResult(response);
    } on DioException catch (e) {
      return _toCallResultFromException(e);
    } catch (e) {
      return FCCallResult(
        statusCode: 0,
        body: jsonEncode({'error': e.toString()}),
        headers: const {},
        fcIsLogin: false,
      );
    }
  }

  FCCallResult _toCallResult(Response<dynamic> response) {
    final headers = <String, String>{};
    response.headers.forEach((k, v) {
      if (v.isNotEmpty) headers[k] = v.first;
    });
    final body = response.data?.toString() ?? '';
    return FCCallResult(
      statusCode: response.statusCode ?? 0,
      body: body,
      headers: headers,
      // Discourse's User API Key auth doesn't speak fc_is_login. Treat any
      // 2xx with the User-Api-Key header set as "logged in"; the proxy layer
      // owns the higher-level interpretation (e.g. 403 → key revoked).
      fcIsLogin: false,
    );
  }

  FCCallResult _toCallResultFromException(DioException e) {
    final headers = <String, String>{};
    e.response?.headers.forEach((k, v) {
      if (v.isNotEmpty) headers[k] = v.first;
    });
    String body = '';
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
