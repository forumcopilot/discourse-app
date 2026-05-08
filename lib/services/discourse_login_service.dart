import 'dart:convert';

import 'package:discourse_core/discourse_core.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_user.dart';
import 'package:forumcopilot_sdk/models/results/fc_user_result.dart';

import '../config/app_forum_config.dart';

/// Drives the Discourse User API Key login flow from the app side.
///
/// Step 1: [beginLogin] generates the keypair + URL for the webview.
/// Step 2: the webview ([DiscourseLoginWebViewPage]) intercepts the
///         `auth_redirect` and hands the `payload` query parameter back here.
/// Step 3: [finishLogin] decrypts the payload, calls `/session/current.json`
///         to populate the user record, builds an [FCLoginResult], and
///         stores it on the [SiteContext] so the rest of the app treats us
///         as logged in.
class DiscourseLoginService {
  /// Redirect target Discourse appends `?payload=<base64>` to. Must match
  /// what's registered in iOS `Info.plist` / Android `AndroidManifest.xml`
  /// (Phase 1.2 — for the in-app webview interception we just need the
  /// scheme/host string to match between [AppForumConfig.userApiAuthRedirect]
  /// and what we look for in `shouldOverrideUrlLoading`).
  String get authRedirect => AppForumConfig.userApiAuthRedirect;

  final SiteContext siteContext;
  final DiscourseAuthManager _authManager;
  final DiscourseClient _client;

  DiscourseLoginService(
    this.siteContext, {
    DiscourseAuthManager? authManager,
    DiscourseClient? client,
  })  : _authManager = authManager ?? DiscourseAuthManager(siteContext),
        _client = client ?? DiscourseClient();

  /// Generate the handshake URL the webview should open.
  Future<DiscourseUserApiHandshakeRequest> beginLogin() {
    return _authManager.beginHandshake(
      applicationName: AppForumConfig.userApiApplicationName,
      scopes: AppForumConfig.userApiRequestedScopes,
      authRedirect: authRedirect,
      pushUrl:
          AppForumConfig.isPushBackendEnabled ? AppForumConfig.pushApiBaseUrl : null,
    );
  }

  /// True when the given URL is the redirect we asked Discourse to send the
  /// payload back to.
  bool isAuthCallback(Uri url) {
    final expected = Uri.parse(authRedirect);
    if (url.scheme != expected.scheme) return false;
    if (expected.host.isNotEmpty && url.host != expected.host) return false;
    if (expected.path.isNotEmpty &&
        expected.path != '/' &&
        url.path != expected.path) {
      return false;
    }
    return true;
  }

  /// Extract Discourse's `payload` query parameter from a redirect URL.
  String? extractPayload(Uri url) => url.queryParameters['payload'];

  /// Decrypt the handshake payload, persist the User API Key, fetch the
  /// current user via `/session/current.json`, and update the [SiteContext]'s
  /// login state. Returns the [FCLoginResult] that was stored.
  Future<FCLoginResult> finishLogin(String payload) async {
    await _authManager.completeHandshake(payload);

    final response = await _client.get(siteContext, '/session/current.json');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'GET /session/current.json failed (${response.statusCode}): ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final cu = (data['current_user'] as Map<String, dynamic>?) ?? const {};

    final user = _userFromCurrentUser(cu);
    final result = FCLoginResult(
      result: true,
      resultText: '',
      user: user,
    );

    siteContext.setLoginData(result);
    siteContext.resetOnLogin();
    await siteContext.saveToDevice();

    return result;
  }

  /// Surface the most recently completed handshake from disk on app start —
  /// hydrates the [SiteContext] with the persisted User API Key and pulls
  /// the current user. Call once during init so subsequent screens see the
  /// app as logged in. Returns `true` when a session was restored.
  Future<bool> restorePersistedSession() async {
    await siteContext.loadUserApiCredentials();
    if (!siteContext.hasUserApiKey) return false;

    try {
      final response = await _client.get(siteContext, '/session/current.json');
      if (response.statusCode == 401 || response.statusCode == 403) {
        // Key revoked server-side. Drop locally.
        await siteContext.clearUserApiCredentials();
        return false;
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return false;
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final cu = (data['current_user'] as Map<String, dynamic>?) ?? const {};
      if (cu.isEmpty) return false;
      siteContext.setLoginData(FCLoginResult(
        result: true,
        resultText: '',
        user: _userFromCurrentUser(cu),
      ));
      return true;
    } catch (_) {
      return false;
    }
  }

  FCUser _userFromCurrentUser(Map<String, dynamic> cu) {
    String? avatarUrl;
    final avatarTemplate = cu['avatar_template'] as String?;
    if (avatarTemplate != null && avatarTemplate.isNotEmpty) {
      final filled = avatarTemplate.replaceAll('{size}', '240');
      avatarUrl =
          filled.startsWith('http') ? filled : '${siteContext.site.url}$filled';
    }
    return FCUser(
      id: (cu['id'] ?? '').toString(),
      username: (cu['username'] ?? '').toString(),
      loginName: (cu['username'] ?? '').toString(),
      iconUrl: avatarUrl,
      userType: cu['admin'] == true
          ? 'admin'
          : (cu['moderator'] == true ? 'moderator' : 'normal'),
      canModerate: cu['moderator'] == true || cu['admin'] == true,
      canPM: cu['can_send_private_messages'] == true,
      canSendPM: cu['can_send_private_messages'] == true,
      canSearch: true,
      isOnline: true,
      userState: 'valid',
      userGroups: ((cu['groups'] as List?) ?? const [])
          .whereType<Map>()
          .map((g) => (g['name'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toList(),
    );
  }
}
