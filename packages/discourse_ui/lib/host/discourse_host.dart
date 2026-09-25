import 'package:flutter/foundation.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

import '../services/notification_route.dart';

/// What a multi-forum host app (ForumCopilot, ABDA) can plug into the
/// module. Everything here is optional: the single-forum template sets
/// nothing and behaves exactly as before.
///
/// Static on purpose. The module is mounted per forum by pushing
/// `SingleForumBootstrapPage(site:)`, and these hooks describe the host,
/// not a forum, so they are set once at startup.
class DiscourseHost {
  DiscourseHost._();

  /// Called from the drawer's "Switch forum" entry. When null the entry is
  /// not shown. A host typically pops back to its forum chooser.
  static VoidCallback? switchForum;

  /// Resolves the forum a push notification belongs to. Receives the
  /// notification's `site_id` (the host directory's id, if any) and the raw
  /// payload so a host without directory ids can match on a URL. Return
  /// null to fall back to the module's own single-forum resolution.
  static Future<Site?> Function(int siteId, Map<String, dynamic> data)?
      resolveForum;

  /// Opens [forum] the way the host opens any of its forums — typically
  /// back to its chooser, then `SingleForumBootstrapPage(site: forum,
  /// route: route)` — and takes the reader to [route] inside it (null: the
  /// forum's home). A push notification for a forum other than the one on
  /// screen goes through this when it is set; without it the module
  /// replaces the whole navigation stack with its own single-forum
  /// bootstrap page, which in a multi-forum host is the configured
  /// template forum rather than the host's chooser.
  static Future<void> Function(Site forum, DiscourseNotificationRoute? route)?
      openForum;

  /// Whether the forum drawer offers the Appearance (System / Light / Dark)
  /// row. It is an app setting, not a forum one, so a host with a screen
  /// outside the forums turns this off and puts it there instead:
  ///
  /// * a host whose `MaterialApp` reads `AppTheme.themeMode` (ABDA) embeds
  ///   `AppearanceChoices` in its own settings screen;
  /// * a host with its own theme setting (ForumCopilot) calls
  ///   `AppearanceSync.apply(mode)` when that setting changes, so forum
  ///   pages in web views and native UI still follow it.
  static bool showAppearanceSetting = true;
}
