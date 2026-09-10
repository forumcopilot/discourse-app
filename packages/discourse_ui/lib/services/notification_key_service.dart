import 'dart:convert';
import 'dart:io';

import 'package:forumcopilot_sdk/network/fc_web_call.dart';
import 'package:forumcopilot_sdk/network/fc_web_call_info.dart';

import '../config/app_forum_config.dart';
import '../core/logging/app_logger.dart';

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
/// Contract, served under the base URL:
///
///   POST   /discourse/notification-key         [registerBody]  → 200/201
///   POST   /discourse/notification-key/device  [deviceBody]    → 200
///   DELETE /discourse/notification-key         [revokeBody]    → 200
class NotificationKeyService {
  NotificationKeyService._();

  static const String _keyPath = '/discourse/notification-key';
  static const String _devicePath = '/discourse/notification-key/device';

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
  }) {
    return <String, dynamic>{
      'site_url': normalizeSiteUrl(siteUrl),
      if (siteId != null) 'site_id': siteId,
      'client_id': clientId,
      'user_api_key': userApiKey,
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

  /// Store a freshly granted key. The backend probes the forum with it before
  /// storing, so a 400 means the forum rejected the key, not the request.
  static Future<bool> register({
    required String siteUrl,
    int? siteId,
    required String clientId,
    required String userApiKey,
    int? discourseUserId,
    String? discourseUsername,
    String? deviceToken,
    String? devicePlatform,
  }) {
    return _send(
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
      ),
    );
  }

  /// Point a stored grant at this device's current FCM token.
  ///
  /// Separate from [register], and called repeatedly: FCM is often still
  /// initializing when the user approves the grant, and rotates tokens
  /// afterwards. A token captured once at grant time goes stale and push
  /// stops with nothing to show for it.
  static Future<bool> updateDevice({
    required String siteUrl,
    int? siteId,
    required String clientId,
    required String deviceToken,
    String? devicePlatform,
  }) {
    return _send(
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
    return _send(
      'DELETE',
      _keyPath,
      revokeBody(siteUrl: siteUrl, siteId: siteId, clientId: clientId),
    );
  }

  static Future<bool> _send(
    String method,
    String path,
    Map<String, dynamic> body,
  ) async {
    final base = _baseUrl;
    if (base == null) {
      AppLogger.debug(
          'NotificationKeyService: no notifications backend configured — '
          'skipping $method $path');
      return false;
    }

    try {
      // Never log the body — it carries the key.
      final response = await FCWebCall.makeHttpCall(
        '$base$path',
        method,
        jsonEncode(body),
        'application/json',
        FCWebCallInfo(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      AppLogger.debug('NotificationKeyService: $method $path rejected '
          '${response.statusCode}: ${response.body}');
      return false;
    } catch (e) {
      AppLogger.debug('NotificationKeyService: $method $path failed: $e');
      return false;
    }
  }
}
