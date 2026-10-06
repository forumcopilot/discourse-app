import 'package:forumcopilot_sdk/models/domain/site.dart';

import '../config/app_forum_config.dart';
import '../core/logging/app_logger.dart';
import '../host/discourse_host.dart';

/// Forum selection shared by foreground delivery and notification navigation.
class NotificationForum {
  NotificationForum._();

  /// Credentials belong to a forum's base URL. Neither a directory ID nor a
  /// hostname alone establishes that an open session belongs to this forum:
  /// the port and the subfolder must agree too ([identity]).
  static bool matches(Site? a, Site? b) {
    if (a == null || b == null) return false;
    final left = identity(a.pluginUrl);
    final right = identity(b.pluginUrl);
    return left != null && left == right;
  }

  /// A forum as the notifications backend keys it (abda-push's SiteUrl, and
  /// NotificationIdentity on Android): the host in lower case, the port
  /// unless it is the scheme's default, and the subfolder without trailing
  /// slashes, its case kept (`forum.example:8443/Sub`).
  ///
  /// Not the scheme. The backend files http:// and https:// of one host as
  /// one forum and sends back, as `site_url`, whichever was registered
  /// first, so a strict match dropped every push for a forum saved here
  /// under the other scheme, or left it unopenable.
  ///
  /// Null, matching nothing, for anything but an absolute http(s) URL with
  /// a host and no user info, query or fragment.
  static String? identity(String? value) {
    final uri = Uri.tryParse((value ?? '').trim());
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      return null;
    }
    final defaultPort = uri.scheme == 'https' ? 443 : 80;
    final port = uri.port == defaultPort ? '' : ':${uri.port}';
    return '${uri.host.toLowerCase()}$port'
        '${uri.path.replaceAll(RegExp(r'/+$'), '')}';
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
