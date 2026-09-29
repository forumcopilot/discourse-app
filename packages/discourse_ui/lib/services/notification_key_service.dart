import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;

import 'package:forumcopilot_sdk/network/fc_web_call.dart';
import 'package:forumcopilot_sdk/network/fc_web_call_info.dart';

import '../config/app_forum_config.dart';
import '../core/logging/app_logger.dart';
import 'notification_installation.dart';

/// What the backend said about a grant it was handed.
class NotificationKeyRegistration {
  /// The backend stored the key.
  final bool ok;

  /// False when something in front of the forum — typically a Cloudflare rule
  /// against datacenter addresses — refuses the backend. The grant is stored,
  /// but notifications may never arrive, and the user deserves to know.
  final bool reachable;

  const NotificationKeyRegistration({required this.ok, this.reachable = true});

  static const failed = NotificationKeyRegistration(ok: false);
}

/// Hands the notifications-only Discourse User API Key to the notifications
/// backend ([AppForumConfig.notificationsApiBaseUrl]), which polls the forum
/// on the user's behalf and delivers what arrives as push.
///
/// Why a backend at all: Discourse only pushes to a URL the forum OWNER has
/// added to `allowed_user_api_push_urls`. On a forum where nobody has, nothing
/// would ever reach the device. A `notifications`-scoped key granted by the
/// user needs no admin cooperation, so it works on every forum from day one.
///
/// The forum is identified by `site_url` — a host that opens forums by
/// address has no directory ids — and `site_id` rides along only when the
/// caller has one, for backends that key on it. The install is identified by
/// the key's `client_id`, which is stable per install and forum, so a re-grant
/// replaces the previous key rather than accumulating.
///
/// Every call is best-effort and answers false on any failure: the caller has
/// already completed the grant on the forum, and the poller reconciles with
/// the forum on its own.
///
/// Every call carries the phone's installation credentials
/// ([NotificationInstallation]), so a grant registered from this phone can
/// only be revoked or changed by it.
///
/// Contract, served under the base URL:
///
///   PUT    /installation                       (NotificationInstallation)
///   POST   /discourse/notification-key         [registerBody]  → 201
///   PUT    /discourse/notification-key/dnd     [dndBody]       → 200
///   DELETE /discourse/notification-key         [revokeBody]    → 200
///   POST   /discourse/notification-key/device  [deviceBody]    → 200, legacy:
///          only for grants made before installations existed
class NotificationKeyService {
  NotificationKeyService._();

  static const String _keyPath = '/discourse/notification-key';
  static const String _devicePath = '/discourse/notification-key/device';
  static const String _dndPath = '/discourse/notification-key/dnd';
  static const String _groupsPath = '/discourse/notification-key/groups';

  /// The push groups the backend knows (NotificationPayload::GROUPS in
  /// abda-push), in the order the settings list them.
  static const List<String> pushGroups = [
    'replies',
    'messages',
    'reactions',
    'other',
  ];

  /// Base URL without a trailing slash, or null when the flow is off.
  static String? get _baseUrl {
    if (!AppForumConfig.isNotificationsGrantEnabled) return null;
    return AppForumConfig.notificationsApiBaseUrl
        .trim()
        .replaceAll(RegExp(r'/+$'), '');
  }

  /// The platform name the backend files the device token under.
  static String get devicePlatform {
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    return 'android';
  }

  /// Forum identity as sent: trimmed, no trailing slash, so two spellings of
  /// the same forum land on the same row.
  static String normalizeSiteUrl(String siteUrl) =>
      siteUrl.trim().replaceAll(RegExp(r'/+$'), '');

  /// Body of the registration call. Pure, so the contract is testable.
  static Map<String, dynamic> registerBody({
    required String siteUrl,
    int? siteId,
    required String clientId,
    required String userApiKey,
    int? discourseUserId,
    String? discourseUsername,
    String? deviceToken,
    String? devicePlatform,
    String? pushUrl,
  }) {
    return <String, dynamic>{
      'site_url': normalizeSiteUrl(siteUrl),
      if (siteId != null) 'site_id': siteId,
      'client_id': clientId,
      'user_api_key': userApiKey,
      if (pushUrl != null && pushUrl.isNotEmpty) 'push_url': pushUrl,
      if (discourseUserId != null) 'discourse_user_id': discourseUserId,
      if (discourseUsername != null && discourseUsername.isNotEmpty)
        'discourse_username': discourseUsername,
      if (deviceToken != null && deviceToken.isNotEmpty)
        'device_token': deviceToken,
      if (devicePlatform != null && devicePlatform.isNotEmpty)
        'device_platform': devicePlatform,
    };
  }

  /// Body of the device-token call.
  static Map<String, dynamic> deviceBody({
    required String siteUrl,
    int? siteId,
    required String clientId,
    required String deviceToken,
    String? devicePlatform,
  }) {
    return <String, dynamic>{
      'site_url': normalizeSiteUrl(siteUrl),
      if (siteId != null) 'site_id': siteId,
      'client_id': clientId,
      'device_token': deviceToken,
      if (devicePlatform != null && devicePlatform.isNotEmpty)
        'device_platform': devicePlatform,
    };
  }

  /// Body of the Do Not Disturb call: when the forum's DND ends, in UTC, or
  /// null for "not in DND".
  static Map<String, dynamic> dndBody({
    required String siteUrl,
    required String clientId,
    DateTime? until,
  }) {
    return <String, dynamic>{
      'site_url': normalizeSiteUrl(siteUrl),
      'client_id': clientId,
      'dnd_until': until?.toUtc().toIso8601String(),
    };
  }

  /// Body of the revoke call. Identified by (forum, client id) rather than
  /// the key, because by sign-out the app has long discarded the key.
  static Map<String, dynamic> revokeBody({
    required String siteUrl,
    int? siteId,
    required String clientId,
  }) {
    return <String, dynamic>{
      'site_url': normalizeSiteUrl(siteUrl),
      if (siteId != null) 'site_id': siteId,
      'client_id': clientId,
    };
  }

  /// Store a freshly granted key under this phone's installation. The
  /// backend probes the forum with it before storing, so a 400 means the
  /// forum rejected the key, not the request.
  static Future<NotificationKeyRegistration> register({
    required String siteUrl,
    int? siteId,
    required String clientId,
    required String userApiKey,
    int? discourseUserId,
    String? discourseUsername,
    String? deviceToken,
    String? devicePlatform,
  }) async {
    final response = await _request(
      'POST',
      _keyPath,
      registerBody(
        siteUrl: siteUrl,
        siteId: siteId,
        clientId: clientId,
        userApiKey: userApiKey,
        discourseUserId: discourseUserId,
        discourseUsername: discourseUsername,
        deviceToken: deviceToken,
        devicePlatform: devicePlatform,
        pushUrl: AppForumConfig.notificationsPushUrl,
      ),
    );
    if (response == null) return NotificationKeyRegistration.failed;
    return registrationFromResponse(response);
  }

  /// Reads the registration answer. Pure, so the contract is testable.
  @visibleForTesting
  static NotificationKeyRegistration registrationFromResponse(
      Map<String, dynamic> response) {
    return NotificationKeyRegistration(
      ok: true,
      reachable: response['reachable'] != false,
    );
  }

  /// Tell the backend about this forum's Do Not Disturb, so it drops what
  /// arrives during it — as Discourse drops its own push — and does not
  /// poll until it ends. [until] null means DND is off.
  static Future<bool> setDoNotDisturb({
    required String siteUrl,
    required String clientId,
    DateTime? until,
  }) {
    return send('PUT', _dndPath,
        dndBody(siteUrl: siteUrl, clientId: clientId, until: until));
  }

  /// Turn push groups off (or back on) for this forum on this phone:
  /// [muted] lists the ones to skip; empty means everything on. What is
  /// muted is skipped by the backend, not saved for later.
  static Future<bool> setMutedGroups({
    required String siteUrl,
    required String clientId,
    required List<String> muted,
  }) {
    return send('PUT', _groupsPath, mutedGroupsBody(siteUrl: siteUrl, clientId: clientId, muted: muted));
  }

  /// Body of the push-groups call. Pure, so the contract is testable.
  static Map<String, dynamic> mutedGroupsBody({
    required String siteUrl,
    required String clientId,
    required List<String> muted,
  }) {
    return <String, dynamic>{
      'site_url': normalizeSiteUrl(siteUrl),
      'client_id': clientId,
      'muted_groups': [for (final g in pushGroups) if (muted.contains(g)) g],
    };
  }

  /// Legacy: point a grant made before installations existed at this
  /// device's current FCM token. Grants registered under an installation get
  /// their token from [NotificationInstallation.report] instead — one call
  /// for every forum — and the backend ignores this call for them.
  static Future<bool> updateDevice({
    required String siteUrl,
    int? siteId,
    required String clientId,
    required String deviceToken,
    String? devicePlatform,
  }) {
    return send(
      'POST',
      _devicePath,
      deviceBody(
        siteUrl: siteUrl,
        siteId: siteId,
        clientId: clientId,
        deviceToken: deviceToken,
        devicePlatform: devicePlatform,
      ),
    );
  }

  /// Stop the backend polling for this install on this forum.
  static Future<bool> revoke({
    required String siteUrl,
    int? siteId,
    required String clientId,
  }) {
    return send(
      'DELETE',
      _keyPath,
      revokeBody(siteUrl: siteUrl, siteId: siteId, clientId: clientId),
    );
  }

  /// Sent instead of the SDK's default browser user agent, which on Android
  /// claims to be Chrome 131. Our backend is an API, not a page, and a
  /// Cloudflare custom rule on betterdiscourse.app challenges outdated
  /// Chrome versions — so every Android upload met a managed challenge, the
  /// interceptor replayed the POST in a WebView without its body, and the
  /// backend answered 400 (verified on a Pixel 4a, 2026-09-22). iOS claimed
  /// Safari and passed, which is why only Android failed.
  @visibleForTesting
  static String get userAgent =>
      'DiscourseApp-Notifications/1 (${Platform.operatingSystem})';

  /// One backend call; true on 200/201. Shared with
  /// [NotificationInstallation].
  static Future<bool> send(
    String method,
    String path,
    Map<String, dynamic> body,
  ) async =>
      await _request(method, path, body) != null;

  /// The decoded JSON answer of a 200/201, or null on anything else.
  static Future<Map<String, dynamic>?> _request(
    String method,
    String path,
    Map<String, dynamic> body,
  ) async {
    final base = _baseUrl;
    if (base == null) {
      AppLogger.debug(
          'NotificationKeyService: no notifications backend configured — '
          'skipping $method $path');
      return null;
    }

    try {
      final info = FCWebCallInfo()
        ..extraHeaders['User-Agent'] = userAgent
        ..extraHeaders['Authorization'] =
            await NotificationInstallation.authorization();
      // Never log the body — it carries the key.
      final response = await FCWebCall.makeHttpCall(
        '$base$path',
        method,
        jsonEncode(body),
        'application/json',
        info,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final decoded = jsonDecode(response.body);
          return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
        } catch (_) {
          return <String, dynamic>{};
        }
      }
      AppLogger.debug('NotificationKeyService: $method $path rejected '
          '${response.statusCode}: ${response.body}');
      return null;
    } catch (e) {
      AppLogger.debug('NotificationKeyService: $method $path failed: $e');
      return null;
    }
  }
}
