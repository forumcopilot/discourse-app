import 'package:forumcopilot_sdk/models/domain/site.dart';

import '../config/app_forum_config.dart';
import '../core/logging/app_logger.dart';
import '../host/discourse_host.dart';

/// Forum selection shared by foreground delivery and notification navigation.
class NotificationForum {
  NotificationForum._();

  /// Credentials belong to a full forum base URL. Neither a directory ID nor
  /// a hostname alone establishes that an open session belongs to this forum.
  static bool matches(Site? a, Site? b) {
    if (a == null || b == null) return false;
    final left = _identity(a.pluginUrl);
    final right = _identity(b.pluginUrl);
    return left != null && left == right;
  }

  static (String, String, int, String)? _identity(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      return null;
    }
    return (
      uri.scheme,
      uri.host,
      uri.port,
      uri.path.replaceAll(RegExp(r'/+$'), ''),
    );
  }

  static Future<Site?> resolve(int siteId, Map<String, dynamic> data) async {
    final hostResolver = DiscourseHost.resolveForum;
    if (hostResolver != null) {
      try {
        return await hostResolver(siteId, data);
      } catch (_) {
        AppLogger.warning('Notification forum could not be resolved by host');
        return null;
      }
    }
    // Only the standalone template has a configured single-forum fallback.
    try {
      return AppForumConfig.buildSite();
    } catch (_) {
      AppLogger.warning('Notification forum is not configured');
      return null;
    }
  }
}
