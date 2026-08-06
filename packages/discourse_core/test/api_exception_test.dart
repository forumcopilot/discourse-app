import 'dart:convert';

import 'package:discourse_core/discourse_core.dart';
import 'package:test/test.dart';

DiscourseApiException _ex(int status, String body,
        {String method = 'POST', String path = '/posts.json'}) =>
    DiscourseApiException(
        statusCode: status, method: method, path: path, body: body);

void main() {
  group('userMessage', () {
    test('prefers Discourse\'s own errors array', () {
      final e = _ex(
          422,
          jsonEncode({
            'errors': ['Title seems unclear', 'Body is too short'],
            'error_type': 'invalid_parameters',
          }));
      expect(e.userMessage, 'Title seems unclear; Body is too short');
    });

    test('reads the app-level rate limiter wait time', () {
      final e = _ex(
          429,
          jsonEncode({
            'errors': ["You've performed this action too many times."],
            'error_type': 'rate_limit',
            'extras': {'wait_seconds': 9},
          }));
      expect(e.isRateLimited, isTrue);
      expect(e.retryAfterSeconds, 9);
      // The server's own sentence wins when it sent one.
      expect(e.userMessage, contains('too many times'));
    });

    test('handles the middleware rate limiter, which answers text/plain', () {
      // lib/middleware/request_tracker.rb returns a plain-text body, so there
      // is no `errors` array to read — this used to degrade to "HTTP 429".
      final e = _ex(429,
          "Slow down, you're making too many requests.\nError code: id_10_secs_limit.");
      expect(e.retryAfterSeconds, isNull);
      expect(e.userMessage, contains('too often'));
      expect(e.userMessage, isNot(contains('429')));
    });

    test('explains a redirect instead of saying "HTTP 302"', () {
      final e = _ex(
          302,
          jsonEncode({
            'errors': [
              'This forum is served from https://try.discourse.org, but the '
                  'app is configured for https://try.discourse.com.'
            ],
            'error_type': 'redirect',
          }));
      expect(e.userMessage, contains('try.discourse.org'));
      expect(e.userMessage, isNot(equals('HTTP 302')));
    });
  });

  group('toString', () {
    test('never dumps an entire response body', () {
      // The regression: an edge server answers a POST with an HTML error
      // page, and this string was interpolated straight into a dialog.
      final html = '<html><head><title>302 Found</title></head><body>'
          '<center><h1>302 Found</h1></center>'
          '<hr><center>cloudflare</center></body></html>';
      final e = _ex(302, html, path: '/session/forgot_password.json');

      final text = e.toString();
      expect(text, contains('POST /session/forgot_password.json'));
      expect(text, contains('302'));
      // The shape is reported, never the markup.
      expect(text, isNot(contains('<html')));
      expect(text, isNot(contains('cloudflare')));
      expect(text, contains('non-JSON response'));
      // The <title> is kept because it is the one genuinely useful part.
      expect(text, contains('302 Found'));
    });

    test('collapses newlines so a log line stays one line', () {
      final e = _ex(500, 'first line\n\n  second line\n');
      expect(e.toString(), isNot(contains('\n')));
    });

    test('keeps short bodies intact for debugging', () {
      final e = _ex(404, '{"errors":["Not found"]}');
      expect(e.toString(), contains('Not found'));
    });
  });

  group('isAuthFailure', () {
    test('is true only for 401/403', () {
      expect(_ex(401, '').isAuthFailure, isTrue);
      expect(_ex(403, '').isAuthFailure, isTrue);
      expect(_ex(429, '').isAuthFailure, isFalse);
      expect(_ex(302, '').isAuthFailure, isFalse);
    });
  });
}
