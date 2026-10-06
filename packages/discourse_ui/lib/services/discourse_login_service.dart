import 'account_notifications.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:discourse_core/discourse_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteContextExtension;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:forumcopilot_sdk/models/entities/fc_user.dart';
import 'package:forumcopilot_sdk/models/results/fc_user_result.dart';
import 'package:forumcopilot_sdk/network/fc_call_result.dart';

import '../config/app_forum_config.dart';
import '../core/logging/app_logger.dart';
import 'notification_installation.dart';
import 'notification_grant_cleanup.dart';
import 'notification_key_service.dart';

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
  ///   * the backend's `push_url` ([AppForumConfig.notificationsPushUrl]).
  ///     The key is polled; the push_url does nothing until the forum's admin
  ///     allowlists it, and then gives instant push without a re-grant — a
  ///     key's push_url cannot be added later.
  Future<DiscourseUserApiHandshakeRequest> beginNotificationsGrant() async {
    final prefs = await SharedPreferences.getInstance();
    var suffix = prefs.getString(_notificationsSuffixKey);
    if (suffix == null) {
      final random = Random.secure();
      suffix = AppForumConfig.userApiNotificationsClientIdSuffix +
          List.generate(16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
      await prefs.setString(_notificationsSuffixKey, suffix);
    }
    return _authManager.beginHandshake(
      applicationName: AppForumConfig.userApiApplicationName,
      scopes: AppForumConfig.userApiNotificationsScopes,
      authRedirect: authRedirect,
      pushUrl: AppForumConfig.notificationsPushUrl,
      clientIdSuffix: suffix,
    );
  }

  /// The client id the notifications key is stored under on our backend. Needed
  /// to revoke it at sign-out, when the key itself is already gone.
  Future<String> notificationsClientId() async {
    final prefs = await SharedPreferences.getInstance();
    return _authManager.clientIdFor(
      suffix: prefs.getString(_notificationsSuffixKey) ??
          AppForumConfig.userApiNotificationsClientIdSuffix,
    );
  }

  static const String _prefNotificationsGranted = '_notifications_key_granted';
  static const String _prefNotificationsInstallBound =
      '_notifications_key_install_bound';
  static const String _prefNotificationsDndReported =
      '_notifications_dnd_reported';
  static const String _prefNotificationsMuted = '_notifications_muted_groups';

  String get _notificationsOwnerKey =>
      '${siteContext.discourseStoragePrefix}_notifications_recipient';

  String get _notificationsSuffixKey =>
      '${siteContext.discourseStoragePrefix}_notifications_client_suffix';

  String get _notificationsGrantKey =>
      '${siteContext.discourseStoragePrefix}$_prefNotificationsGranted';
  String get _notificationsInstallBoundKey =>
      '${siteContext.discourseStoragePrefix}$_prefNotificationsInstallBound';
  String get _notificationsDndReportedKey =>
      '${siteContext.discourseStoragePrefix}$_prefNotificationsDndReported';
  String get _notificationsMutedKey =>
      '${siteContext.discourseStoragePrefix}$_prefNotificationsMuted';

  /// Whether the notifications grant for THIS forum was completed and taken
  /// by the backend. Set by [markNotificationsGranted] once the key is stored
  /// server-side — not merely approved on the forum, since a grant the backend
  /// never received delivers nothing and should be offered again.
  ///
  /// Per forum, under the same prefix as the forum's credentials, because a
  /// multi-forum host signs into many forums from one install and each one
  /// is granted separately.
  Future<bool> hasNotificationsGrant() async {
    final prefs = await SharedPreferences.getInstance();
    final owner = prefs.getString(_notificationsOwnerKey);
    return (prefs.getBool(_notificationsGrantKey) ?? false) &&
        (owner == null || owner == siteContext.currentUserId);
  }

  /// Remember the grant. [installBound]: registered under this phone's
  /// installation, so its token and Do Not Disturb go through
  /// [NotificationInstallation] and [syncDoNotDisturb] rather than the legacy
  /// per-grant device call. Grants made by earlier app versions are not.
  Future<bool> markNotificationsGranted({
    bool installBound = false,
    Object? expectedSession,
    String? expectedClientId,
  }) async {
    final session = expectedSession ?? siteContext.configurationSession;
    final prefs = await SharedPreferences.getInstance();
    final suffix = prefs.getString(_notificationsSuffixKey);
    if (expectedClientId != null &&
        expectedClientId != await notificationsClientId()) {
      return false;
    }
    bool current() => identical(session, siteContext.configurationSession) &&
        prefs.getString(_notificationsSuffixKey) == suffix;
    final owner = siteContext.currentUserId;
    final writes = <Future<bool> Function()>[
      if (owner != null) () => prefs.setString(_notificationsOwnerKey, owner),
      () => prefs.setBool(_notificationsGrantKey, true),
      () => prefs.setBool(_notificationsInstallBoundKey, installBound),
      () => prefs.remove(_notificationsDndReportedKey),
      () => prefs.remove(_notificationsMutedKey),
    ];
    for (final write in writes) {
      if (!current()) return false;
      if (!await write()) throw StateError('Could not persist notification grant');
    }
    if (suffix != null && installBound && current()) {
      await _retireLegacyGrantOnce(prefs);
    }
    if (current()) {
      await AccountNotifications.activate(siteContext, siteContext.configurationSession, newGrant: true);
    }
    return current();
  }

  String get _legacyGrantRetiredKey =>
      '${siteContext.discourseStoragePrefix}_notifications_legacy_retired';

  /// Grants made before each grant had its own client id all used one per
  /// forum (`<install>:notify`). One that outlived a sign-out (older builds
  /// forgot it locally even when the relay was unreachable) keeps polling
  /// the previous account and pushing it to this phone, next to the new
  /// grant. Once a new grant is stored, the relay knows this installation
  /// and answers OK when there is nothing to remove, so queue the old id's
  /// revoke then, once per forum. Never fails the grant.
  Future<void> _retireLegacyGrantOnce(SharedPreferences prefs) async {
    if (prefs.getBool(_legacyGrantRetiredKey) ?? false) return;
    try {
      await NotificationGrantCleanup.enqueue(
          siteContext.site.url,
          await _authManager.clientIdFor(
              suffix: AppForumConfig.userApiNotificationsClientIdSuffix));
      // Sent with the outbox's next drain (at launch, and every minute
      // while the app is open), not as a side effect of marking the grant.
      await prefs.setBool(_legacyGrantRetiredKey, true);
    } catch (e) {
      AppLogger.warning('Could not queue the legacy notifications grant: $e');
    }
  }

  /// Whether this forum's grant was registered under the phone's
  /// installation — only those can have per-type switches.
  Future<bool> isNotificationsGrantInstallBound() => _isInstallBound();

  /// The push groups turned off for this forum on this phone
  /// (NotificationKeyService.pushGroups); empty when everything is on.
  Future<Set<String>> mutedPushGroups() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_notificationsMutedKey) ?? const []).toSet();
  }

  /// Turns [group] on or off, on the backend first: the switch only moves
  /// once the backend has it. False when it could not be saved.
  Future<bool> setPushGroupMuted(String group, bool muted) async {
    final session = siteContext.configurationSession;
    final userId = siteContext.currentUserId;
    final prefs = await SharedPreferences.getInstance();
    final suffix = prefs.getString(_notificationsSuffixKey);
    final granted = prefs.getBool(_notificationsGrantKey);
    bool current() => identical(session, siteContext.configurationSession) &&
        userId == siteContext.currentUserId &&
        suffix == prefs.getString(_notificationsSuffixKey) &&
        granted == prefs.getBool(_notificationsGrantKey);
    if (!current()) return false;
    final next =
        (prefs.getStringList(_notificationsMutedKey) ?? const <String>[]).toSet();
    muted ? next.add(group) : next.remove(group);
    final clientId = await notificationsClientId();
    if (!current()) return false;
    final ok = await NotificationKeyService.setMutedGroups(
      siteUrl: siteContext.site.url,
      clientId: clientId,
      muted: next.toList(),
    );
    // The response belongs to the original grant. Its forum-scoped cache
    // may already have been reset for a replacement account or grant.
    if (!ok || !current()) return false;
    await prefs.setStringList(_notificationsMutedKey, next.toList());
    return current();
  }

  Future<bool> _isInstallBound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsInstallBoundKey) ?? false;
  }

  /// Forget the grant — at sign-out, or when the user turns notifications off
  /// — so the next sign-in offers it again.
  Future<void> clearNotificationsGrant() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsOwnerKey);
    await prefs.remove(_notificationsSuffixKey);
    await prefs.remove(_notificationsGrantKey);
    await prefs.remove(_notificationsInstallBoundKey);
    await prefs.remove(_notificationsDndReportedKey);
    await prefs.remove(_notificationsMutedKey);
  }

  /// Persist cleanup before forgetting local state. New grants then get a
  /// different client ID; retries can safely outlive logout and app restarts.
  Future<void> retireNotificationsGrant() async {
    AccountNotifications.markRetired(siteContext);
    if (AppForumConfig.isNotificationsGrantEnabled) {
      final prefs = await SharedPreferences.getInstance();
      // A started grant may have reached the relay even if its response was lost.
      if ((prefs.getBool(_notificationsGrantKey) ?? false) || prefs.containsKey(_notificationsSuffixKey)) {
        await NotificationGrantCleanup.enqueue(
            siteContext.site.url, await notificationsClientId());
      }
      await clearNotificationsGrant();
    }
    // Last: a grant completing meanwhile (markNotificationsGranted) may
    // have set this account natively again; with its client id cleared
    // above, nothing can after this.
    await AccountNotifications.retire(siteContext);
    if (AppForumConfig.isNotificationsGrantEnabled) {
      unawaited(NotificationGrantCleanup.instance.retryPending());
    }
  }

  /// Tell the notifications backend about this forum's Do Not Disturb, so
  /// nothing is pushed during it — Discourse drops its own push the same way.
  /// Called wherever the app learns the state: restoring the session (the
  /// current-user payload carries `do_not_disturb_until`) and the Do Not
  /// Disturb setting. Only sends when the state changed since the last
  /// report. Never throws.
  Future<void> syncDoNotDisturb(DateTime? until) async {
    if (!AppForumConfig.isNotificationsGrantEnabled) return;
    final session = siteContext.configurationSession;
    final userId = siteContext.currentUserId;
    try {
      final prefs = await SharedPreferences.getInstance();
      final suffix = prefs.getString(_notificationsSuffixKey);
      bool current() => identical(session, siteContext.configurationSession) &&
          userId == siteContext.currentUserId &&
          suffix == prefs.getString(_notificationsSuffixKey) &&
          (prefs.getBool(_notificationsGrantKey) ?? false);
      if (!current() ||
          !await hasNotificationsGrant() ||
          !await _isInstallBound() ||
          !current()) {
        return;
      }
      final active =
          until != null && until.isAfter(DateTime.now().toUtc()) ? until : null;
      final state = active?.toUtc().toIso8601String() ?? 'off';
      if (prefs.getString(_notificationsDndReportedKey) == state) return;

      final clientId = await notificationsClientId();
      if (!current()) return;
      final ok = await NotificationKeyService.setDoNotDisturb(
        siteUrl: siteContext.site.url,
        clientId: clientId,
        until: active,
      );
      if (ok && current()) {
        await prefs.setString(_notificationsDndReportedKey, state);
      }
    } catch (e) {
      AppLogger.debug(
          'DiscourseLoginService: Could not sync Do Not Disturb: $e');
    }
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
    if (!AppForumConfig.isNotificationsGrantEnabled) return;
    // Nothing to attach to until the grant completed on this forum — and the
    // backend would only no-op, so save it the request.
    if (!await hasNotificationsGrant()) return;

    try {
      final effective = token ?? await FirebaseMessaging.instance.getToken();
      if (effective == null || effective.isEmpty) return;

      // A grant filed under this phone's installation gets its token from the
      // installation — one call covers every forum, so a rotation reaches
      // forums the user has not opened since.
      if (await _isInstallBound()) {
        await NotificationInstallation.report(token: effective);
        return;
      }

      final clientId = await notificationsClientId();
      await NotificationKeyService.updateDevice(
        siteUrl: siteContext.site.url,
        siteId: siteContext.site.id,
        clientId: clientId,
        deviceToken: effective,
        devicePlatform: platform ?? NotificationKeyService.devicePlatform,
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
    final session = siteContext.configurationSession;

    final response = await _client.get(siteContext, '/session/current.json');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // Storing the key dropped the forum's capabilities; without a reload
      // the forum stays on defaults (no logo, colours, Home views or flag
      // types) for the rest of the session.
      await _refreshConfiguration();
      throw StateError(
        'GET /session/current.json failed (${response.statusCode}): ${response.body}',
      );
    }

    if (!identical(session, siteContext.configurationSession)) {
      throw StateError('Account changed during sign-in');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final cu = (data['current_user'] as Map<String, dynamic>?) ?? const {};

    final result = _loginResultFromCurrentUser(cu);
    if (result.user?.id != siteContext.currentUserId) {
      await retireNotificationsGrant();
    }

    _applyChatFlags(cu);

    // Permissions and visible categories change with the new API key. Load
    // them before notifying the UI that login completed.
    await _refreshConfiguration();

    if (!identical(session, siteContext.configurationSession)) {
      throw StateError('Account changed during sign-in');
    }
    siteContext.setLoginData(result);
    await AccountNotifications.activate(siteContext, siteContext.configurationSession, newGrant: true);
    siteContext.resetOnLogin();
    await siteContext.saveToDevice();
    // Cache the identity so future launches can restore it offline.
    await siteContext.saveLoginSnapshot(result.toJson());

    return result;
  }

  /// How long sign-in waits for the forum's configuration. Worth a moment
  /// (the forum opens with the new account's views and permissions), not a
  /// slow forum: only `/about.json` has a budget of its own, while
  /// `/site.json`, `/site/settings.json` and the chat probe wait out Dio's
  /// 15 s to connect and 30 s between bytes, plus any 429 cooldown, with
  /// the sign-in on a spinner all along. The same 10 s a forum gets to
  /// open; past it sign-in completes and the reads land in the background.
  @visibleForTesting
  static Duration configurationRefreshTimeout = const Duration(seconds: 10);

  /// Reload the forum's configuration for the key now in place. A
  /// configuration outage must not discard an otherwise successful
  /// authentication, so this never throws, and a slow one must not hold it
  /// up: past [configurationRefreshTimeout] it carries on without waiting,
  /// and the capabilities are stored when they arrive.
  Future<void> _refreshConfiguration() async {
    final refresh = DiscourseConfigProxy(siteContext, client: _client)
        .getConfig(siteContext.site.pluginUrl, forceRefresh: true);
    try {
      await refresh.timeout(configurationRefreshTimeout);
    } on TimeoutException {
      AppLogger.warning('Configuration still loading after '
          '$configurationRefreshTimeout; finishing sign-in without it');
      unawaited(refresh.then<void>((_) {}, onError: (Object e) {
        AppLogger.warning('Could not refresh configuration after sign-in: $e');
      }));
    } catch (e) {
      AppLogger.warning('Could not refresh configuration after sign-in: $e');
    }
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
    if (!siteContext.hasUserApiKey) {
      // No one is signed in here, yet a grant may survive (a restore from
      // backup brings preferences back but not the key): its pushes have
      // no owner on this phone.
      try {
        await retireNotificationsGrant();
      } catch (e) {
        AppLogger.debug('Could not retire an orphaned notifications grant: $e');
      }
      return false;
    }
    if (AccountNotifications.isRetired(siteContext)) return false;
    final session = siteContext.configurationSession;

    String failureReason;
    Duration? retryHint;
    try {
      final response = await _client.get(siteContext, '/session/current.json');
      if (!identical(session, siteContext.configurationSession) ||
          AccountNotifications.isRetired(siteContext)) return false;
      if (response.statusCode == 401 || response.statusCode == 403) {
        // Key revoked server-side. Drop locally (this also deletes the
        // cached login snapshot).
        await retireNotificationsGrant();
        await siteContext.clearUserApiCredentials();
        return false;
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final cu = (data['current_user'] as Map<String, dynamic>?) ?? const {};
        if (cu.isEmpty) return false;
        final result = _loginResultFromCurrentUser(cu);
        final prefs = await SharedPreferences.getInstance();
        final owner = prefs.getString(_notificationsOwnerKey);
        if (owner != null && owner != result.user?.id) {
          await retireNotificationsGrant();
        }
        _applyChatFlags(cu);
        siteContext.setLoginData(result);
        await AccountNotifications.activate(siteContext, siteContext.configurationSession);
        // Refresh the cached identity for future offline launches.
        await siteContext.saveLoginSnapshot(result.toJson());
        // The notifications backend cannot read Do Not Disturb with its
        // notifications-only key; this payload has it for free.
        unawaited(syncDoNotDisturb(
            DateTime.tryParse((cu['do_not_disturb_until'] ?? '').toString())));
        return true;
      }
      // Transient failure: 429 / 5xx / statusCode 0 (DiscourseClient maps
      // network exceptions and timeouts to statusCode 0).
      failureReason = _describeTransientFailure(response);
      retryHint = _retryDelayFromResponse(response);
    } catch (e) {
      failureReason = e.toString();
    }
    if (!identical(session, siteContext.configurationSession) ||
        AccountNotifications.isRetired(siteContext)) return false;
    return _restoreFromSnapshot(failureReason, retryHint, session);
  }

  /// Fall back to the cached login snapshot when the server could not be
  /// reached. Returns `true` (and schedules a background revalidation) when
  /// a usable snapshot exists; `false` otherwise (pre-fix behavior).
  Future<bool> _restoreFromSnapshot(String reason, Duration? retryHint, Object session) async {
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
    if (cached.user == null || !identical(session, siteContext.configurationSession) ||
        AccountNotifications.isRetired(siteContext)) return false;

    siteContext.setLoginData(cached);
    await AccountNotifications.activate(siteContext, siteContext.configurationSession);
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
    final session = siteContext.configurationSession;
    var delay = _capDelay(initialDelay);
    for (var attempt = 1; attempt <= _maxRevalidationAttempts; attempt++) {
      await Future.delayed(delay);
      if (!siteContext.hasUserApiKey || AccountNotifications.isRetired(siteContext) ||
          !identical(session, siteContext.configurationSession)) return;
      try {
        final response =
            await _client.get(siteContext, '/session/current.json');
        if (!identical(session, siteContext.configurationSession) ||
            AccountNotifications.isRetired(siteContext)) return;
        if (response.statusCode == 401 || response.statusCode == 403) {
          AppLogger.info(
              'DiscourseLoginService: Background revalidation found the User '
              'API Key revoked (HTTP ${response.statusCode}) — signing out');
          // As at launch: the separate notifications key would otherwise
          // keep being polled for an account no longer signed in here.
          await retireNotificationsGrant();
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
            _applyChatFlags(cu);
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

  /// Chat availability for the signed-in user, straight from the current-user
  /// record — what Discourse's own client reads (`chat.userCanChat`,
  /// `userCanDirectMessage`). The route probe in DiscourseConfigProxy has to
  /// infer it from a status code, and a signed-in member outside
  /// `chat_allowed_groups` gets the same 403 there as a guest on a forum
  /// with chat on. Discourse leaves each field out when it is false, so an
  /// absent `has_chat_enabled` means no chat: turned off for the forum, not
  /// allowed for this user, or turned off in their own preferences.
  void _applyChatFlags(Map<String, dynamic> cu) {
    _applyNavigation(cu);
    siteContext.setChatEnabled(cu['has_chat_enabled'] == true);
    siteContext.setChatCanDirectMessage(cu['can_direct_message'] == true ||
        cu['admin'] == true ||
        cu['moderator'] == true);
    // Unsent chat messages, kept on the server: a channel opens with what
    // the reader left in it, here or on the web.
    DiscourseChatDrafts.storeFromCurrentUser(siteContext.site.url, cu['chat_drafts']);
  }

  /// The reader's own sidebar (their categories and tags) and trust level,
  /// which the drawer shows. Read with the chat flags, from the same
  /// `current_user`, wherever the session is (re)read.
  void _applyNavigation(Map<String, dynamic> cu) {
    final ids = (cu['sidebar_category_ids'] as List?)
        ?.map((e) => e is int ? e : int.tryParse('$e'))
        .whereType<int>()
        .toList();
    // Current Discourse sends `{name, pm_only, …}`; older versions names.
    final tags = (cu['sidebar_tags'] as List?)
        ?.map((t) => t is Map ? t['name']?.toString() : t?.toString())
        .whereType<String>()
        .where((t) => t.isNotEmpty)
        .toList();
    siteContext.setSidebar(categoryIds: ids, tags: tags);
    final tl = cu['trust_level'];
    siteContext.setTrustLevel(tl is int ? tl : int.tryParse('${tl ?? ''}'));
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
