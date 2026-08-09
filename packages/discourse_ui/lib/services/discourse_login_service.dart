import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:discourse_core/discourse_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/services/forumcopilot_api_service.dart';
import 'package:forumcopilot_sdk/models/entities/fc_user.dart';
import 'package:forumcopilot_sdk/models/results/fc_user_result.dart';
import 'package:forumcopilot_sdk/network/fc_call_result.dart';

import '../config/app_forum_config.dart';
import '../core/logging/app_logger.dart';

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
  ///
  /// When a push relay is configured ([AppForumConfig.pushApiBaseUrl]
  /// non-empty) the handshake additionally requests the `push` scope and
  /// registers [AppForumConfig.discoursePushUrl] as the key's `push_url` —
  /// Discourse then POSTs this user's notifications to that relay URL
  /// (tagged with our `client_id`) for forwarding to FCM/APNs. When push is
  /// not configured, scopes and params are exactly the pre-push ones.
  Future<DiscourseUserApiHandshakeRequest> beginLogin() {
    return _authManager.beginHandshake(
      applicationName: AppForumConfig.userApiApplicationName,
      scopes: AppForumConfig.userApiEffectiveScopes,
      authRedirect: authRedirect,
      pushUrl: AppForumConfig.discoursePushUrl,
    );
  }

  /// Start the SECOND handshake: a notifications-only key for our backend to
  /// poll with, so the user gets push even on forums whose owner has not set up
  /// the app's push relay.
  ///
  /// Separate from [beginLogin] in three ways that all matter:
  ///   * `notifications` scope only — four routes, no posting, no reading PMs;
  ///   * its own client id, so Discourse does not destroy the login key;
  ///   * no `push_url`, since this key is polled rather than pushed to.
  Future<DiscourseUserApiHandshakeRequest> beginNotificationsGrant() {
    return _authManager.beginHandshake(
      applicationName: AppForumConfig.userApiApplicationName,
      scopes: AppForumConfig.userApiNotificationsScopes,
      authRedirect: authRedirect,
      clientIdSuffix: AppForumConfig.userApiNotificationsClientIdSuffix,
    );
  }

  /// The client id the notifications key is stored under on our backend. Needed
  /// to revoke it at sign-out, when the key itself is already gone.
  Future<String> notificationsClientId() {
    return _authManager.clientIdFor(
      suffix: AppForumConfig.userApiNotificationsClientIdSuffix,
    );
  }

  /// Point any stored notifications grant for THIS forum at [token].
  ///
  /// Called from two places, because neither alone is sufficient: entering a
  /// forum (the token is usually ready by then, and the grant may pre-date it —
  /// the very first real grant we captured stored a null token because FCM was
  /// still initializing), and FCM token rotation (which invalidates whatever was
  /// stored). Idempotent and cheap; the server no-ops when no grant exists,
  /// which is the case for most forums a user opens.
  ///
  /// With no [token], the current one is read from FirebaseMessaging directly.
  /// That is deliberate: this package is consumed both by the single-forum
  /// template and by the multi-forum host app, and the host app has its OWN
  /// NotificationService class — so this package's NotificationService singleton
  /// is never initialized there and its `fcmToken` is always null.
  /// FirebaseMessaging is the one source of truth in both.
  Future<void> syncNotificationDeviceToken({String? token, String? platform}) async {
    final siteId = siteContext.site.id;
    if (siteId == null) return;

    try {
      final effective = token ?? await FirebaseMessaging.instance.getToken();
      if (effective == null || effective.isEmpty) return;

      final clientId = await notificationsClientId();
      await ForumCopilotApiService.updateDiscourseNotificationDevice(
        siteId: siteId,
        clientId: clientId,
        deviceToken: effective,
        devicePlatform: platform ?? (Platform.isIOS ? 'ios' : 'android'),
      );
    } catch (e) {
      AppLogger.debug(
          'DiscourseLoginService: Could not sync notification device token: $e');
    }
  }

  /// Attach this device to the stored grant as soon as an FCM token exists.
  ///
  /// A fresh sign-in fires neither of the other two sync points: [restorePersistedSession]
  /// only runs when an EXISTING session is restored on entering a forum, and the push
  /// controller's one-shot init has usually already run at launch. So without this, a
  /// user who grants notifications during their first login has a row with a null device
  /// token — the grant is real, but nothing can ever be delivered to it.
  ///
  /// Polls instead of firing once because FCM initialization commonly finishes seconds
  /// AFTER the grant is approved. Deliberately not awaited by the UI: the user should not
  /// watch a spinner while Firebase warms up.
  ///
  /// Reads FirebaseMessaging directly for the same reason [syncNotificationDeviceToken]
  /// does — this package's NotificationService singleton is never initialized in the
  /// multi-forum host app, which has its own.
  Future<void> syncNotificationDeviceTokenWhenReady({
    Duration timeout = const Duration(minutes: 2),
    Duration interval = const Duration(seconds: 2),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      String? token;
      try {
        token = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        AppLogger.debug('DiscourseLoginService: getToken failed, retrying: $e');
      }
      if (token != null && token.isNotEmpty) {
        await syncNotificationDeviceToken(token: token);
        return;
      }
      await Future<void>.delayed(interval);
    }
    AppLogger.debug(
        'DiscourseLoginService: no FCM token within $timeout — device not attached to '
        'the notifications grant. It will attach on the next forum open or token refresh.');
  }

  /// Decrypt the notifications-grant payload WITHOUT touching the session
  /// credential, and return the key for upload to our backend.
  ///
  /// `persist: false` is the important part — persisting would swap the login
  /// key for one limited to four routes and break the rest of the app.
  Future<DiscourseUserApiKey> finishNotificationsGrant(String payload) {
    return _authManager.completeHandshake(payload, persist: false);
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

    final result = _loginResultFromCurrentUser(cu);

    siteContext.setLoginData(result);
    siteContext.resetOnLogin();
    await siteContext.saveToDevice();
    // Cache the identity so future launches can restore it offline.
    await siteContext.saveLoginSnapshot(result.toJson());

    return result;
  }

  /// Surface the most recently completed handshake from disk on app start —
  /// hydrates the [SiteContext] with the persisted User API Key and pulls
  /// the current user. Call once during init so subsequent screens see the
  /// app as logged in. Returns `true` when a session was restored.
  ///
  /// Cache-first: `/session/current.json` failing **transiently** (rate
  /// limit, 5xx, server down, airplane mode, timeout) must not sign the user
  /// out — a valid User API Key plus the cached [FCLoginResult] snapshot from
  /// the last successful fetch restore the session locally, and a background
  /// revalidation retries the server later. Only a definitive 401/403 (key
  /// revoked server-side) drops credentials.
  Future<bool> restorePersistedSession() async {
    await siteContext.loadUserApiCredentials();
    if (!siteContext.hasUserApiKey) return false;

    String failureReason;
    Duration? retryHint;
    try {
      final response = await _client.get(siteContext, '/session/current.json');
      if (response.statusCode == 401 || response.statusCode == 403) {
        // Key revoked server-side. Drop locally (this also deletes the
        // cached login snapshot).
        await siteContext.clearUserApiCredentials();
        return false;
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final cu = (data['current_user'] as Map<String, dynamic>?) ?? const {};
        if (cu.isEmpty) return false;
        final result = _loginResultFromCurrentUser(cu);
        siteContext.setLoginData(result);
        // Refresh the cached identity for future offline launches.
        await siteContext.saveLoginSnapshot(result.toJson());
        return true;
      }
      // Transient failure: 429 / 5xx / statusCode 0 (DiscourseClient maps
      // network exceptions and timeouts to statusCode 0).
      failureReason = _describeTransientFailure(response);
      retryHint = _retryDelayFromResponse(response);
    } catch (e) {
      failureReason = e.toString();
    }
    return _restoreFromSnapshot(failureReason, retryHint);
  }

  /// Fall back to the cached login snapshot when the server could not be
  /// reached. Returns `true` (and schedules a background revalidation) when
  /// a usable snapshot exists; `false` otherwise (pre-fix behavior).
  Future<bool> _restoreFromSnapshot(String reason, Duration? retryHint) async {
    String? snapshotJson;
    try {
      snapshotJson = await siteContext.readLoginSnapshot();
    } catch (e) {
      AppLogger.warning(
          'DiscourseLoginService: Could not read cached login snapshot: $e');
    }
    if (snapshotJson == null || snapshotJson.isEmpty) {
      AppLogger.warning(
          'DiscourseLoginService: Session restore failed ($reason) and no '
          'cached login snapshot exists — starting signed out');
      return false;
    }

    FCLoginResult cached;
    try {
      cached = FCLoginResultMapper.fromJson(snapshotJson);
    } catch (e) {
      AppLogger.warning(
          'DiscourseLoginService: Cached login snapshot is unreadable ($e) — '
          'starting signed out');
      return false;
    }
    if (cached.user == null) return false;

    siteContext.setLoginData(cached);
    AppLogger.info(
        'DiscourseLoginService: Restored session from cache (server '
        'unreachable: $reason); will revalidate in background');
    _scheduleRevalidation(
        initialDelay: retryHint ?? const Duration(seconds: 30));
    return true;
  }

  /// True while a background revalidation loop is running. Static because
  /// the service is constructed per-call sites; a single loop is enough for
  /// this single-forum app.
  static bool _revalidationInProgress = false;

  /// Kick off a background retry of `/session/current.json` after restoring
  /// from cache. Single guarded loop: up to [_maxRevalidationAttempts]
  /// attempts with doubling backoff capped at [_maxRevalidationDelay]. Stops
  /// on success (fresh login data + snapshot refresh) or on 401/403 (key
  /// revoked: credentials + snapshot cleared and login state flipped so the
  /// UI updates).
  void _scheduleRevalidation({required Duration initialDelay}) {
    if (_revalidationInProgress) return;
    _revalidationInProgress = true;
    unawaited(_revalidationLoop(initialDelay).whenComplete(() {
      _revalidationInProgress = false;
    }));
  }

  static const int _maxRevalidationAttempts = 5;
  static const Duration _maxRevalidationDelay = Duration(minutes: 2);

  Future<void> _revalidationLoop(Duration initialDelay) async {
    var delay = _capDelay(initialDelay);
    for (var attempt = 1; attempt <= _maxRevalidationAttempts; attempt++) {
      await Future.delayed(delay);
      if (!siteContext.hasUserApiKey) return; // logged out meanwhile
      try {
        final response =
            await _client.get(siteContext, '/session/current.json');
        if (response.statusCode == 401 || response.statusCode == 403) {
          AppLogger.info(
              'DiscourseLoginService: Background revalidation found the User '
              'API Key revoked (HTTP ${response.statusCode}) — signing out');
          await siteContext.clearUserApiCredentials();
          // Flip login state so the UI (profile, badges) updates live.
          siteContext.clearLoginData();
          return;
        }
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final cu =
              (data['current_user'] as Map<String, dynamic>?) ?? const {};
          if (cu.isNotEmpty) {
            final result = _loginResultFromCurrentUser(cu);
            siteContext.setLoginData(result);
            await siteContext.saveLoginSnapshot(result.toJson());
            AppLogger.info(
                'DiscourseLoginService: Background revalidation confirmed '
                'cached session (attempt $attempt)');
          }
          return;
        }
        // Still transient — back off (honoring a fresh 429 hint) and retry.
        delay = _capDelay(_retryDelayFromResponse(response) ?? delay * 2);
      } catch (_) {
        delay = _capDelay(delay * 2);
      }
    }
    AppLogger.warning(
        'DiscourseLoginService: Background revalidation gave up after '
        '$_maxRevalidationAttempts attempts; keeping cached session');
  }

  Duration _capDelay(Duration d) =>
      d > _maxRevalidationDelay ? _maxRevalidationDelay : d;

  /// Delay hint for a 429: `Retry-After` header first, then Discourse's
  /// `extras.wait_seconds` body field. `null` for anything else.
  Duration? _retryDelayFromResponse(FCCallResult response) {
    if (response.statusCode != 429) return null;
    final headerSecs = int.tryParse(response.headers['retry-after'] ?? '');
    if (headerSecs != null && headerSecs > 0) {
      return Duration(seconds: headerSecs);
    }
    try {
      final body = jsonDecode(response.body);
      final extras = (body is Map) ? body['extras'] : null;
      final wait = (extras is Map) ? extras['wait_seconds'] : null;
      if (wait is num && wait > 0) return Duration(seconds: wait.ceil());
    } catch (_) {
      // Not JSON — no hint.
    }
    return null;
  }

  String _describeTransientFailure(FCCallResult response) {
    if (response.statusCode == 0) {
      // DiscourseClient encodes the underlying exception in the body.
      try {
        final body = jsonDecode(response.body);
        final error = (body is Map) ? body['error'] : null;
        if (error is String && error.isNotEmpty) return error;
      } catch (_) {}
      return 'network error';
    }
    return 'HTTP ${response.statusCode}';
  }

  /// Build the [FCLoginResult] stored on the [SiteContext] (and cached as
  /// the offline login snapshot) from a `/session/current.json`
  /// `current_user` map.
  FCLoginResult _loginResultFromCurrentUser(Map<String, dynamic> cu) {
    return FCLoginResult(
      result: true,
      resultText: '',
      user: _userFromCurrentUser(cu),
      canUploadAvatar: _canUploadAvatar(cu),
      // Composer/PM attachment buttons gate on these; Discourse has no
      // per-user "can upload" signal (limits are authorized_extensions /
      // max_*_size_kb, enforced pre-upload via DiscourseUploadLimits and
      // server-side) — so any logged-in user may attach.
      canUploadAttachment: true,
      canUploadConversationAttachment: true,
    );
  }

  /// `/session/current.json` exposes a real per-user avatar-upload signal:
  /// current_user_serializer.rb serializes `can_upload_avatar`
  /// (false when in anonymous mode or outside
  /// `uploaded_avatars_allowed_groups`). Map it when present; on older
  /// cores that predate the attribute stay permissive (`!= false`) and let
  /// the server 422 the rare locked-down/SSO-override case.
  bool _canUploadAvatar(Map<String, dynamic> cu) =>
      cu['can_upload_avatar'] != false;

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
