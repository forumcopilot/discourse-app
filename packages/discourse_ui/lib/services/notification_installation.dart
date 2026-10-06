import 'package:discourse_notifications/discourse_notifications.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' show PlatformDispatcher;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../config/app_forum_config.dart';
import '../core/logging/app_logger.dart';
import 'notification_key_service.dart';
import 'notification_grant_cleanup.dart';
import 'notification_permission.dart';

/// This phone, as the notifications backend knows it: one installation for
/// every forum the user has granted, so a rotated FCM token or a changed
/// notification permission reaches all of them in one call.
///
/// Identity is an id and a secret generated here on first use and kept in
/// SharedPreferences (both go with an uninstall, so a reinstall is a new
/// installation). Every backend call carries them as
/// `Authorization: Bearer <id>:<secret>`; the backend files the secret's hash
/// on first sight and requires it afterwards. That is what stops someone who
/// learns a grant's client_id — which the forum stores too — from pointing
/// this user's notifications at their own phone.
///
/// Nothing is reported until the phone has made a grant ([markRegistered]):
/// a user who never turned notifications on has no business in the backend's
/// tables, token included.
class NotificationInstallation {
  NotificationInstallation._();

  static const String _idKey = 'notifications_install_id';
  static const String _secretKey = 'notifications_install_secret';
  static const String _registeredKey = 'notifications_install_registered';
  static const String _lastReportKey = 'notifications_install_last_report';

  static const String _path = '/installation';

  static Future<({String id, String secret})>? _credentials;

  /// The id and secret, generated on first use.
  static Future<({String id, String secret})> credentials() =>
      _credentials ??= _loadOrCreate();

  static Future<({String id, String secret})> _loadOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_idKey);
    var secret = prefs.getString(_secretKey);
    if (id == null || id.isEmpty || secret == null || secret.isEmpty) {
      final random = Random.secure();
      id = List.generate(16, (_) => random.nextInt(256))
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
      secret = base64Url
          .encode(List.generate(32, (_) => random.nextInt(256)))
          .replaceAll('=', '');
      await prefs.setString(_idKey, id);
      await prefs.setString(_secretKey, secret);
    }
    return (id: id, secret: secret);
  }

  /// The `Authorization` header value for backend calls.
  static Future<String> authorization() async {
    final c = await credentials();
    return 'Bearer ${c.id}:${c.secret}';
  }

  /// Whether this phone has a grant filed under its installation, so there is
  /// something for [report] to keep current.
  static Future<bool> isRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_registeredKey) ?? false;
  }

  static Future<void> markRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_registeredKey, true);
  }

  /// Tell the backend where this phone can be reached: its FCM token, whether
  /// the OS lets the app show notifications, app version and locale.
  ///
  /// Cheap to call often — at launch, on token rotation, on every resume
  /// (the permission may have been changed in the system settings): it only
  /// sends when something changed since the last successful report, unless
  /// [force]. Never throws; false when nothing was confirmed.
  ///
  /// [token] overrides the token read from FirebaseMessaging (a rotation
  /// callback already has it); with [force] it reports even before the first
  /// grant, which is how the grant page files the phone just before
  /// registering the key under it.
  static Future<bool> report({String? token, bool force = false}) async {
    if (!AppForumConfig.isNotificationsGrantEnabled) return false;
    await NotificationGrantCleanup.instance.retryPending();
    if (!force && !await isRegistered()) return false;

    try {
      final effectiveToken = token ?? await _currentToken();
      final permitted = await NotificationPermission.status() ==
          NotificationPermissionState.granted;
      final body = reportBody(
        guardedAndroidDelivery: DiscourseNotifications.ready,
        deviceToken: effectiveToken,
        devicePlatform: NotificationKeyService.devicePlatform,
        notificationsPermitted: permitted,
        appVersion: await _appVersion(),
        locale: PlatformDispatcher.instance.locale.toLanguageTag(),
      );

      final encoded = jsonEncode(body);
      final prefs = await SharedPreferences.getInstance();
      if (!force && prefs.getString(_lastReportKey) == encoded) return true;

      final ok = await NotificationKeyService.send('PUT', _path, body);
      if (ok) await prefs.setString(_lastReportKey, encoded);
      return ok;
    } catch (e) {
      AppLogger.debug('NotificationInstallation: report failed: $e');
      return false;
    }
  }

  /// Body of `PUT /installation`. Pure, so the contract is testable. A null
  /// token is left out rather than sent: "not known yet" must not erase the
  /// token the backend already has.
  @visibleForTesting
  static Map<String, dynamic> reportBody({
    bool guardedAndroidDelivery = false,
    String? deviceToken,
    required String devicePlatform,
    required bool notificationsPermitted,
    String? appVersion,
    String? locale,
  }) {
    return <String, dynamic>{
      if (deviceToken != null && deviceToken.isNotEmpty)
        'device_token': deviceToken,
      'device_platform': devicePlatform,
      if (devicePlatform == 'android' && guardedAndroidDelivery)
        'notification_delivery': DiscourseNotifications.deliveryMode,
      'notifications_permitted': notificationsPermitted,
      if (appVersion != null && appVersion.isNotEmpty) 'app_version': appVersion,
      if (locale != null && locale.isNotEmpty) 'locale': locale,
    };
  }

  static Future<String?> _currentToken() async {
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      return null;
    }
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      AppLogger.debug('NotificationInstallation: no FCM token: $e');
      return null;
    }
  }

  static Future<String?> _appVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return '${info.version}+${info.buildNumber}';
    } catch (_) {
      return null;
    }
  }

  @visibleForTesting
  static void resetForTesting() => _credentials = null;
}
