import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Native state is shared by the foreground engine and Firebase's background
/// engine. Checking a recipient and showing/cancelling its notification are
/// serialized on Android's main thread, including across those two engines.
class DiscourseNotifications {
  static const deliveryMode = 'account_guarded_v1';
  static const channel = MethodChannel('com.forumcopilot/notifications');
  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  static bool ready = false;

  /// Seeds only previously unknown forums. A logout tombstone always wins over
  /// an upgrade snapshot which was read before logout started.
  static Future<void> initialize({
    required String icon,
    required Map<String, String> accounts,
    required void Function(Map<String, dynamic>) onTap,
  }) async {
    if (!supported) return;
    channel.setMethodCallHandler((call) async {
      if (call.method == 'tap' && call.arguments is Map) {
        onTap(Map<String, dynamic>.from(call.arguments as Map));
      }
    });
    await channel.invokeMethod<void>('configure', {
      'icon': icon,
      'accounts': accounts,
    });
    ready = true;
    final pending = await channel.invokeMapMethod<String, dynamic>('takeTap');
    if (pending != null) onTap(pending);
  }

  static Future<void> setAccount(String forum, String? userId) async {
    if (!supported) return;
    // Older hosts without this plugin keep their existing delivery mode.
    try {
      await channel.invokeMethod<void>('setAccount', {
        'forum': forum,
        'userId': userId,
      });
    } on MissingPluginException {
      // They cannot advertise ready, so the backend retains legacy delivery.
    }
  }

  /// Returns true for our protocol even when the recipient is rejected: callers
  /// must never fall back to unguarded display for a rejected notification.
  static Future<bool> handle(Map<String, dynamic> data) async {
    if (!supported || data['delivery_mode'] != deliveryMode) return false;
    await channel.invokeMethod<bool>('show', data);
    return true;
  }
}
