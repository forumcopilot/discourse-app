import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// In-app webview that hosts the Discourse User API Key authorization page.
///
/// Discourse handles the entire login + grant UI itself (passkey, 2FA, SSO,
/// CAPTCHA, etc.) — we just open the URL and watch for the redirect to
/// [redirectMatcher]. When that fires we pop with the redirect URL; the
/// caller pulls `?payload=...` off it and finishes the handshake. If the
/// user backs out without authorizing, we pop with `null`.
class DiscourseLoginWebViewPage extends StatefulWidget {
  /// The full `/user-api-key/new?...` URL produced by
  /// [DiscourseAuthManager.beginHandshake].
  final String url;

  /// Returns true when the given URL is the auth-callback redirect we
  /// configured. Pass [DiscourseLoginService.isAuthCallback].
  final bool Function(Uri) redirectMatcher;

  /// Optional title shown in the AppBar.
  final String title;

  const DiscourseLoginWebViewPage({
    super.key,
    required this.url,
    required this.redirectMatcher,
    this.title = 'Sign in',
  });

  @override
  State<DiscourseLoginWebViewPage> createState() =>
      _DiscourseLoginWebViewPageState();
}

class _DiscourseLoginWebViewPageState extends State<DiscourseLoginWebViewPage> {
  bool _completed = false;

  Future<NavigationActionPolicy> _shouldOverride(
    InAppWebViewController controller,
    NavigationAction action,
  ) async {
    final reqUrl = action.request.url;
    if (reqUrl == null) return NavigationActionPolicy.ALLOW;

    if (widget.redirectMatcher(reqUrl)) {
      if (_completed || !mounted) return NavigationActionPolicy.CANCEL;
      _completed = true;
      Navigator.of(context).pop(reqUrl);
      return NavigationActionPolicy.CANCEL;
    }
    return NavigationActionPolicy.ALLOW;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
        initialSettings: InAppWebViewSettings(
          // Cookies/session aren't shared with the system browser, so the
          // user logs in fresh inside the webview every time. That's the
          // right default for an auth flow.
          clearCache: false,
          useShouldOverrideUrlLoading: true,
          // Allow Discourse to pop OAuth provider windows (Google/etc.)
          // inside the same webview if they get configured.
          supportMultipleWindows: false,
        ),
        shouldOverrideUrlLoading: _shouldOverride,
      ),
    );
  }
}
