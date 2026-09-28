import 'dart:io';

import 'package:dio/dio.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscourseApiException, DiscourseSiteContextExtension;
import 'package:flutter/foundation.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/services/fc_http_overrides.dart';

/// Who may see the signed-in user's API key when the app fetches a post's
/// pictures, videos and files: the forum's own uploads, and nothing else.
///
/// Media is fetched outside DiscourseClient — by the image widgets, the
/// video player, a file download — and went without the key, so a forum
/// with secure uploads showed broken pictures, and a file in a private
/// message (or on a forum with `prevent_anons_from_downloading_files`)
/// downloaded as a 404.
///
/// The key goes only to the forum's origin — the scheme, host and port of
/// its site URL — and only to its upload paths (`/uploads/`,
/// `/secure-uploads/`, `/secure-media-uploads/`, under a subfolder when the
/// forum has one). Never to an image host, a CDN or S3: a secure upload
/// redirects to a signed S3 address, and that request must go without it.
/// The upload paths are the only ones that need it, and every request that
/// carries the key counts against Discourse's per-key limit
/// (`max_user_api_reqs_per_minute`, 20 by default) — avatars and emoji must
/// not spend it.
@immutable
class ForumMediaAuth {
  const ForumMediaAuth({required this.siteUrl, this.credentials = const {}});

  /// The signed-in user of [site]; no credentials for a guest.
  factory ForumMediaAuth.of(SiteContext site) => ForumMediaAuth(
        siteUrl: site.site.url,
        credentials: site.userApiAuthHeaders(),
      );

  /// The forum's address, as the app was configured with it.
  final String siteUrl;

  /// `User-Api-Key` and `User-Api-Client-Id`, or none.
  final Map<String, String> credentials;

  static const List<String> _uploadPaths = [
    '/uploads/',
    '/secure-uploads/',
    '/secure-media-uploads/',
  ];

  static const List<String> _securePaths = [
    '/secure-uploads/',
    '/secure-media-uploads/',
  ];

  /// The headers a request for [url] may carry: the credentials for one of
  /// the forum's own uploads, nothing for any other address.
  Map<String, String> headersFor(String url) {
    if (credentials.isEmpty) return const {};
    final path = _pathOnForum(url);
    if (path == null || !_uploadPaths.any(path.startsWith)) return const {};
    return credentials;
  }

  /// Whether [url] is a secure upload, which Discourse only ever serves to a
  /// signed-in user allowed to see it — so the key goes with the first
  /// request. Other uploads are public unless the forum says otherwise, and
  /// are asked for without it first (see [ForumMedia]).
  bool mustAuthenticate(String url) {
    if (credentials.isEmpty) return false;
    final path = _pathOnForum(url);
    return path != null && _securePaths.any(path.startsWith);
  }

  /// [url]'s path below the forum's base path when [url] is on the forum's
  /// origin, else null. Same scheme, host and port: a look-alike host
  /// (`forum.example.com.evil.com`, `forum.example.com@evil.com`) is another
  /// origin.
  String? _pathOnForum(String url) {
    final target = Uri.tryParse(url.trim());
    final site = Uri.tryParse(siteUrl.trim());
    if (target == null || site == null) return null;
    if (!target.hasAuthority || !site.hasAuthority) return null;
    if (target.scheme != 'http' && target.scheme != 'https') return null;
    if (target.scheme != site.scheme ||
        target.host != site.host ||
        target.port != site.port) {
      return null;
    }
    var base = site.path;
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    final path = target.path;
    if (base.isEmpty) return path;
    return path.startsWith('$base/') ? path.substring(base.length) : null;
  }

  @override
  bool operator ==(Object other) =>
      other is ForumMediaAuth &&
      other.siteUrl == siteUrl &&
      mapEquals(other.credentials, credentials);

  @override
  int get hashCode => Object.hash(
        siteUrl,
        Object.hashAllUnordered(credentials.keys),
        Object.hashAllUnordered(credentials.values),
      );
}

/// A video or audio address ready for a player, with the headers to play it
/// with.
@immutable
class PlayableMedia {
  const PlayableMedia(this.url, [this.headers = const {}]);

  final Uri url;
  final Map<String, String> headers;
}

/// Fetches the forum's media with [ForumMediaAuth]'s rules.
///
/// Redirects are followed here, one hop at a time, rather than by the HTTP
/// client: dart:io copies custom headers onto every redirect, wherever it
/// leads, so a secure upload's redirect to S3 would have carried the key
/// there. Each hop is judged on its own address.
///
/// On each hop to the forum's uploads: a secure upload is asked for with the
/// key; any other upload without it first, and again with it only when the
/// forum refuses (403, or the 404 Discourse answers a guest with when
/// `prevent_anons_from_downloading_files` is on). On a forum that serves
/// its files publicly the key is never sent.
class ForumMedia {
  ForumMedia._();

  /// Tests put a Dio with a fake adapter here.
  @visibleForTesting
  static Dio? debugDio;

  static const int _maxRedirects = 5;

  static Future<Dio> _dio() async {
    final override = debugDio;
    if (override != null) return override;
    await FCDioClient.instance.initialize();
    return FCDioClient.instance.dio;
  }

  /// Redirects and refusals come back as responses, so each hop is judged
  /// here instead of by the client.
  static Options _options(Map<String, String> headers, {ResponseType? responseType}) => Options(
        headers: headers,
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
        responseType: responseType,
      );

  /// Sends [send] to [url] and on through its redirects. With
  /// [stopOffForum], stops at the first address off the forum and returns
  /// its redirect (a player follows the rest on its own, and a signed S3
  /// address answers only the request it was signed for).
  static Future<({Response<T> response, Uri url, Map<String, String> headers})> _follow<T>(
    ForumMediaAuth? auth,
    String url,
    Future<Response<T>> Function(Uri url, Map<String, String> headers) send, {
    bool stopOffForum = false,
  }) async {
    var current = Uri.parse(url);
    for (var hop = 0;; hop++) {
      final key = auth?.headersFor(current.toString()) ?? const <String, String>{};
      final upFront = key.isNotEmpty && auth!.mustAuthenticate(current.toString());
      var sent = upFront ? key : const <String, String>{};
      var response = await send(current, sent);
      final refused = response.statusCode == 403 || response.statusCode == 404;
      if (!upFront && key.isNotEmpty && refused) {
        sent = key;
        response = await send(current, sent);
      }
      final status = response.statusCode ?? 0;
      final location = response.headers.value(HttpHeaders.locationHeader);
      if (status < 300 || status >= 400 || location == null || location.isEmpty || hop >= _maxRedirects) {
        return (response: response, url: current, headers: sent);
      }
      final next = current.resolve(location);
      final onForum = auth?.headersFor(next.toString()).isNotEmpty ?? false;
      if (stopOffForum && !onForum) {
        return (response: response, url: next, headers: const <String, String>{});
      }
      current = next;
    }
  }

  /// GETs [url]'s bytes. The response's status says whether it worked.
  static Future<Response<List<int>>> getBytes(
    ForumMediaAuth? auth,
    String url, {
    ProgressCallback? onReceiveProgress,
  }) async {
    final dio = await _dio();
    final result = await _follow<List<int>>(
      auth,
      url,
      (u, headers) => dio.getUri<List<int>>(
        u,
        options: _options(headers, responseType: ResponseType.bytes),
        onReceiveProgress: onReceiveProgress,
      ),
    );
    return result.response;
  }

  /// Where a player should fetch [url] from, and with which headers.
  ///
  /// Players follow redirects themselves and keep their headers on the way,
  /// so the forum's hops are walked here first (HEAD requests, no body): a
  /// secure upload plays from the signed S3 address with no key, a public
  /// file plays with none, and only a file the forum refuses a guest plays
  /// with the key. Anything else — a guest, another site — plays as given.
  static Future<PlayableMedia> resolvePlayable(ForumMediaAuth? auth, String url) async {
    final given = Uri.parse(url);
    if (auth == null || auth.headersFor(url).isEmpty) return PlayableMedia(given);
    try {
      final dio = await _dio();
      final result = await _follow<void>(
        auth,
        url,
        (u, headers) => dio.headUri<void>(u, options: _options(headers)),
        stopOffForum: true,
      );
      return PlayableMedia(result.url, result.headers);
    } catch (e) {
      debugPrint('ForumMedia.resolvePlayable: $e');
      // The player gets its own chance, as before.
      return PlayableMedia(given);
    }
  }

  /// Downloads [url] into a file named [filename] in a fresh temporary
  /// folder, reporting progress as it goes. Throws when the forum does not
  /// hand the file over.
  static Future<File> download(
    ForumMediaAuth? auth,
    String url,
    String filename, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    final dio = await _dio();
    final folder = await Directory.systemTemp.createTemp('forum_file_');
    final file = File('${folder.path}/${safeFileName(filename)}');
    try {
      final result = await _follow<dynamic>(
        auth,
        url,
        (u, headers) => dio.downloadUri(
          u,
          file.path,
          options: _options(headers),
          onReceiveProgress: onReceiveProgress,
          cancelToken: cancelToken,
        ),
      );
      final status = result.response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        // The shape describeError reads: "not found", "not allowed", …
        throw DiscourseApiException(
            statusCode: status, method: 'GET', path: result.url.path, body: '');
      }
      return file;
    } on DioException catch (e) {
      await folder.delete(recursive: true).catchError((_) => folder);
      if (CancelToken.isCancel(e)) rethrow;
      final timedOut = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout;
      throw DiscourseApiException(
        statusCode: e.response?.statusCode ?? 0,
        method: 'GET',
        path: e.requestOptions.uri.path,
        body: timedOut ? 'Timeout' : (e.message ?? ''),
      );
    } catch (_) {
      await folder.delete(recursive: true).catchError((_) => folder);
      rethrow;
    }
  }

  /// [name] as a file name any platform accepts: no path separators or
  /// control characters, never empty.
  static String safeFileName(String name) {
    final cleaned = name.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), '_').trim();
    return cleaned.isEmpty || cleaned == '.' || cleaned == '..' ? 'download' : cleaned;
  }
}
