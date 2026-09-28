import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:discourse_ui/services/forum_media.dart';
import 'package:flutter_test/flutter_test.dart';

/// The signed-in user's API key reaches the forum's own uploads and nothing
/// else: not another site's pictures, not a CDN, not the S3 address a
/// secure upload redirects to.
const _forum = 'https://forum.example.com';
const _key = {'User-Api-Key': 'secret-key', 'User-Api-Client-Id': 'client-1'};
const _auth = ForumMediaAuth(siteUrl: _forum, credentials: _key);

/// Answers each request from [routes] by URL (query ignored) and remembers
/// what was asked, with which headers.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.routes);

  final ResponseBody Function(RequestOptions request) routes;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return routes(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _redirect(String to) => ResponseBody.fromString('', 302, headers: {
      HttpHeaders.locationHeader: [to],
    });

ResponseBody _ok(String body) => ResponseBody.fromBytes(Uint8List.fromList(body.codeUnits), 200);

ResponseBody _status(int code) => ResponseBody.fromString('', code);

bool _keyed(RequestOptions r) => r.headers.containsKey('User-Api-Key');

_FakeAdapter _install(ResponseBody Function(RequestOptions r) routes) {
  final adapter = _FakeAdapter(routes);
  ForumMedia.debugDio = Dio()..httpClientAdapter = adapter;
  return adapter;
}

void main() {
  tearDown(() => ForumMedia.debugDio = null);

  group('ForumMediaAuth.headersFor — the one gate for the key', () {
    test("the forum's uploads get the key", () {
      for (final url in [
        '$_forum/uploads/default/original/1X/abc.pdf',
        '$_forum/uploads/short-url/abc.pdf',
        '$_forum/secure-uploads/original/1X/abc.png',
        '$_forum/secure-media-uploads/original/1X/abc.png',
        'https://FORUM.example.com:443/uploads/default/original/1X/abc.pdf',
      ]) {
        expect(_auth.headersFor(url), _key, reason: url);
      }
    });

    test('a third-party URL gets no headers', () {
      for (final url in [
        'https://images.example.org/uploads/cat.png',
        'https://my-bucket.s3.amazonaws.com/original/1X/abc.png?X-Amz-Signature=x',
        'https://cdn.forum.example.com/uploads/default/original/1X/abc.png',
        'https://forum.example.com.evil.com/uploads/abc.png',
        'https://forum.example.com@evil.com/uploads/abc.png',
        'http://forum.example.com/uploads/abc.png',
        'https://forum.example.com:8443/uploads/abc.png',
        'uploads/abc.png',
        'not a url',
      ]) {
        expect(_auth.headersFor(url), isEmpty, reason: url);
      }
    });

    test("the forum's other pages spend no key: avatars, emoji, topics", () {
      for (final url in [
        '$_forum/user_avatar/forum.example.com/sam/48/1_2.png',
        '$_forum/images/emoji/twitter/wave.png',
        '$_forum/t/some-topic/12',
        '$_forum/uploadsfoo/x.png',
      ]) {
        expect(_auth.headersFor(url), isEmpty, reason: url);
      }
    });

    test('a subfolder forum: only its own uploads', () {
      const sub = ForumMediaAuth(siteUrl: 'https://example.com/forum/', credentials: _key);
      expect(sub.headersFor('https://example.com/forum/uploads/default/original/1X/a.pdf'), _key);
      expect(sub.headersFor('https://example.com/uploads/default/original/1X/a.pdf'), isEmpty);
      expect(sub.headersFor('https://example.com/other/uploads/a.pdf'), isEmpty);
    });

    test('a guest has no key to send', () {
      const guest = ForumMediaAuth(siteUrl: _forum);
      expect(guest.headersFor('$_forum/secure-uploads/original/1X/abc.png'), isEmpty);
      expect(guest.mustAuthenticate('$_forum/secure-uploads/original/1X/abc.png'), isFalse);
    });

    test('only secure uploads are asked for with the key up front', () {
      expect(_auth.mustAuthenticate('$_forum/secure-uploads/original/1X/abc.png'), isTrue);
      expect(_auth.mustAuthenticate('$_forum/uploads/default/original/1X/abc.png'), isFalse);
      expect(_auth.mustAuthenticate('https://s3.example.com/secure-uploads/abc.png'), isFalse);
    });
  });

  group('ForumMedia follows redirects itself', () {
    test("a secure upload's redirect to S3 does not carry the key", () async {
      const s3 = 'https://bucket.s3.amazonaws.com/original/1X/abc.png?X-Amz-Signature=sig';
      final adapter = _install((r) => r.uri.host == 'forum.example.com' ? _redirect(s3) : _ok('png'));

      final response = await ForumMedia.getBytes(_auth, '$_forum/secure-uploads/original/1X/abc.png');

      expect(response.statusCode, 200);
      expect(adapter.requests.map((r) => r.uri.host), ['forum.example.com', 'bucket.s3.amazonaws.com']);
      expect(_keyed(adapter.requests.first), isTrue, reason: 'the forum decides who may see it');
      expect(_keyed(adapter.requests.last), isFalse, reason: 'S3 must never see the key');
      expect(adapter.requests.every((r) => r.followRedirects == false), isTrue);
    });

    test('a file the forum refuses a guest is asked for again with the key', () async {
      // prevent_anons_from_downloading_files: Discourse answers a guest 404.
      final adapter = _install((r) => _keyed(r) ? _ok('%PDF') : _status(404));

      final file = await ForumMedia.download(_auth, '$_forum/uploads/short-url/abc.pdf', 'spec.pdf');

      expect(await file.readAsString(), '%PDF');
      expect(file.path, endsWith('/spec.pdf'));
      expect(adapter.requests.map(_keyed), [false, true]);
      await file.parent.delete(recursive: true);
    });

    test('a public file is fetched without the key', () async {
      final adapter = _install((r) => _ok('hello'));

      final file = await ForumMedia.download(_auth, '$_forum/uploads/default/original/1X/a.txt', 'a.txt');

      expect(await file.readAsString(), 'hello');
      expect(adapter.requests.map(_keyed), [false]);
      await file.parent.delete(recursive: true);
    });

    test("a short URL's redirect to a CDN leaves the key behind", () async {
      final adapter = _install((r) {
        if (r.uri.host == 'cdn.example.net') return _ok('%PDF');
        return _keyed(r) ? _redirect('https://cdn.example.net/original/1X/abc.pdf') : _status(404);
      });

      final file = await ForumMedia.download(_auth, '$_forum/uploads/short-url/abc.pdf', 'spec.pdf');

      expect(await file.readAsString(), '%PDF');
      expect(adapter.requests.map((r) => '${r.uri.host} ${_keyed(r)}'),
          ['forum.example.com false', 'forum.example.com true', 'cdn.example.net false']);
      await file.parent.delete(recursive: true);
    });

    test('a download the forum will not hand over fails', () async {
      _install((r) => _status(403));

      await expectLater(
        ForumMedia.download(_auth, '$_forum/uploads/short-url/abc.pdf', 'spec.pdf'),
        throwsA(isA<Exception>()),
      );
    });

    test('a video is played from the signed address, with no key and no request to S3', () async {
      const s3 = 'https://bucket.s3.amazonaws.com/original/1X/v.mp4?X-Amz-Signature=sig';
      final adapter = _install((r) => _redirect(s3));

      final media = await ForumMedia.resolvePlayable(_auth, '$_forum/secure-uploads/original/1X/v.mp4');

      expect(media.url.toString(), s3);
      expect(media.headers, isEmpty);
      expect(adapter.requests.map((r) => '${r.method} ${r.uri.host}'), ['HEAD forum.example.com']);
    });

    test('a video a guest may not fetch plays with the key; a public one without', () async {
      var protectedFile = true;
      _install((r) => protectedFile && !_keyed(r) ? _status(404) : _status(200));

      final protected = await ForumMedia.resolvePlayable(_auth, '$_forum/uploads/default/original/1X/v.mp4');
      expect(protected.headers, _key);

      protectedFile = false;
      final public = await ForumMedia.resolvePlayable(_auth, '$_forum/uploads/default/original/1X/v.mp4');
      expect(public.headers, isEmpty);
    });

    test('another site, or a guest, plays as given without asking anything', () async {
      final adapter = _install((r) => _status(200));

      await ForumMedia.resolvePlayable(_auth, 'https://videos.example.org/v.mp4');
      await ForumMedia.resolvePlayable(
          const ForumMediaAuth(siteUrl: _forum), '$_forum/uploads/default/original/1X/v.mp4');

      expect(adapter.requests, isEmpty);
    });
  });

  test('a file name is made safe for any platform', () {
    expect(ForumMedia.safeFileName('../../etc/passwd'), '.._.._etc_passwd');
    expect(ForumMedia.safeFileName('a:b*c?.pdf'), 'a_b_c_.pdf');
    expect(ForumMedia.safeFileName(''), 'download');
    expect(ForumMedia.safeFileName('..'), 'download');
  });
}
