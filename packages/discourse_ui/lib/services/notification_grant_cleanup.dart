import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_forum_config.dart';
import 'notification_key_service.dart';

/// Durable revocation outbox. Each entry names the retired grant's client ID,
/// never the current account's ID. New grants use a new ID, so a late retry
/// cannot remove a replacement grant. No Discourse key is stored here.
class NotificationGrantCleanup with WidgetsBindingObserver {
  NotificationGrantCleanup._();
  static final instance = NotificationGrantCleanup._();
  static const _prefix = 'notifications_pending_revoke:';
  Future<void>? _draining;
  Timer? _timer;
  bool _started = false;

  static Future<void> enqueue(String siteUrl, String clientId) async {
    final encoded = base64Url.encode(utf8.encode(jsonEncode([
      AppForumConfig.notificationsApiBaseUrl,
      siteUrl,
      clientId,
    ])));
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setBool('$_prefix$encoded', true)) {
      throw StateError('Could not persist notification cleanup');
    }
  }

  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _resume();
  }

  void _resume() {
    unawaited(retryPending());
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      unawaited(retryPending());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _timer?.cancel();
    if (state == AppLifecycleState.resumed) _resume();
  }

  Future<void> retryPending() => _draining ??= _drain().whenComplete(() {
        _draining = null;
      });

  Future<void> _drain() async {
    if (!AppForumConfig.isNotificationsGrantEnabled) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final key in prefs.getKeys().where((k) => k.startsWith(_prefix))) {
        final parts = jsonDecode(
                utf8.decode(base64Url.decode(key.substring(_prefix.length))))
            as List<dynamic>;
        // A development backend must never consume a production outbox.
        if (parts[0] != AppForumConfig.notificationsApiBaseUrl) continue;
        final ok = await NotificationKeyService.revoke(
          siteUrl: parts[1] as String,
          clientId: parts[2] as String,
        );
        if (ok) await prefs.remove(key);
      }
    } catch (_) {
      // Keep the entry on storage/network failure; resume/launch retries it.
    }
  }
}
