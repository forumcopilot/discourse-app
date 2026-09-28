import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../config/app_forum_config.dart';
import '../core/logging/app_logger.dart';
import '../views/discourse_login_webview_page.dart';

/// Where the reader approves the app on the forum: signing in (and signing
/// up), and the notifications grant. Both are Discourse's User API Key page,
/// which ends by redirecting to the app's `auth_redirect`.
///
/// On iOS, Android and macOS this opens in the system's browser sign-in
/// sheet (ASWebAuthenticationSession; Chrome's Auth Tab), as the official
/// Discourse app does, rather than in a web view inside the app. There:
///
/// * the forum's saved password and passkeys fill as they do in the
///   browser, and a new password can be saved. An app's own web view is
///   offered neither: iOS fills only for domains tied to the app, and
///   Android's password managers hold back from another site's page inside
///   an app;
/// * "Continue with Google" works. Google refuses sign-in inside an app's
///   web view (`disallowed_useragent`);
/// * a forum the reader is already signed in to in the browser only asks
///   to Authorize;
/// * an account created there comes back signed in. Discourse remembers the
///   key request (its `destination_url` cookie) and returns to it as soon
///   as the new account is ready: at once for a Google or Apple sign-up,
///   after the activation link otherwise. Register used to open the forum's
///   sign-up page in the browser, and nothing ever came back to the app.
///
/// The session shares the browser's sign-ins (not ephemeral), which is what
/// makes the above work; iOS asks once per sign-in whether the app may use
/// the forum to sign in.
///
/// Elsewhere, or when the system sheet cannot open (no browser to open it
/// in), the app's own sign-in page ([DiscourseLoginWebViewPage]).
class DiscourseAuthSession {
  DiscourseAuthSession._();

  /// Stands in for the system sheet in tests: gets the URL and the callback
  /// scheme, completes with the callback URL.
  @visibleForTesting
  static Future<String> Function(String url, String callbackScheme)?
      debugAuthenticate;

  static bool get _hasSystemSheet =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.macOS);

  /// Opens [url] and completes with the redirect to the app's
  /// `auth_redirect` ([isCallback]), or null when the reader backed out.
  /// [title] names the in-app fallback page.
  static Future<Uri?> authorize(
    BuildContext context, {
    required String url,
    required bool Function(Uri) isCallback,
    required String title,
  }) async {
    final authenticate = debugAuthenticate ??
        (_hasSystemSheet
            ? (String url, String scheme) => FlutterWebAuth2.authenticate(
                  url: url,
                  callbackUrlScheme: scheme,
                  options: const FlutterWebAuth2Options(preferEphemeral: false),
                )
            : null);
    if (authenticate != null) {
      final scheme = Uri.parse(AppForumConfig.userApiAuthRedirect).scheme;
      try {
        final result = Uri.tryParse(await authenticate(url, scheme));
        return result != null && isCallback(result) ? result : null;
      } on PlatformException catch (e) {
        if (e.code == 'CANCELED') return null;
        AppLogger.warning(
            'System sign-in sheet unavailable (${e.code}: ${e.message}); '
            'using the in-app page');
      }
      if (!context.mounted) return null;
    }
    return Navigator.of(context).push<Uri?>(
      MaterialPageRoute<Uri?>(
        builder: (_) => DiscourseLoginWebViewPage(
          url: url,
          redirectMatcher: isCallback,
          title: title,
        ),
      ),
    );
  }
}
