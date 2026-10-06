import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_notifications/discourse_notifications.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_forum_config.dart';
import '../core/logging/app_logger.dart';

/// Host entry point for guarded Android data messages. Hosts opt in only after
/// registering this in BOTH their foreground and background FCM handlers.
class AccountNotifications {
  static final _retired = Expando<bool>();

  static bool isRetired(SiteContext context) => _retired[context] == true;
  static Future<bool> handle(Map<String, dynamic> data) =>
      DiscourseNotifications.handle(data);

  static Future<void> initialize({
    required void Function(Map<String, dynamic>) onTap,
  }) async {
    if (!DiscourseNotifications.supported) return;
    final prefs = await SharedPreferences.getInstance();
    final accounts = <String, String>{};
    // Upgrade all saved forums, including ones not currently open. This is the
    // core's persisted login-snapshot namespace; no API keys are read here.
    for (final key in prefs.getKeys()) {
      const prefix = 'discourse:';
      const suffix = '_login_snapshot';
      if (!key.startsWith(prefix) || !key.endsWith(suffix)) continue;
      try {
        final login = FCLoginResultMapper.fromJson(prefs.getString(key)!);
        final id = login.user?.id;
        if (login.result && id != null && (int.tryParse(id) ?? 0) > 0) {
          accounts[key.substring(prefix.length, key.length - suffix.length)] =
              id;
        }
      } catch (_) {
        // An unreadable identity cannot authorize display.
      }
    }
    await DiscourseNotifications.initialize(
      icon: AppForumConfig.androidNotificationIcon,
      accounts: accounts,
      onTap: onTap,
    );
  }

  static Future<void> activate(SiteContext context, Object session,
      {bool newGrant = false}) async {
    if (!identical(session, context.configurationSession) ||
        !context.isLoggedIn) {
      return;
    }
    if (isRetired(context) && !newGrant) return;
    _retired[context] = false;
    await _setAccount(context, context.currentUserId);
  }

  /// Invalidates synchronously, before native or backend cleanup yields.
  static void markRetired(SiteContext context) => _retired[context] = true;

  static Future<void> retire(SiteContext context) {
    markRetired(context);
    return _setAccount(context, null);
  }

  /// Never throws: a forum address the native side can't read, or a plugin
  /// failure, must not break sign-in or sign-out. Such a forum's guarded
  /// pushes are not shown (they fail closed), as before.
  static Future<void> _setAccount(SiteContext context, String? userId) async {
    try {
      await DiscourseNotifications.setAccount(context.site.url, userId);
    } catch (e) {
      AppLogger.debug('AccountNotifications: setAccount failed: $e');
    }
  }
}
