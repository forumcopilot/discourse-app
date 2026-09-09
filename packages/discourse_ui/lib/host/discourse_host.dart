import 'package:flutter/foundation.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

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
}
