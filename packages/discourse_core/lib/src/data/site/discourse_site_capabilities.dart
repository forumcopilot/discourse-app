import 'package:flutter/foundation.dart' show visibleForTesting;

/// What `/site.json` says this forum offers.
///
/// The app read *nothing* from `/site.json` before this — every capability
/// it publishes was hardcoded, inferred, or ignored. This is the narrow
/// slice the UI can currently act on; the rest is catalogued in
/// `docs/sdk-gap-audit-discourse.md`.
///
/// Keyed by `site.pluginUrl` and resolved once per forum per process, for
/// the same reason as the chat probe: these are properties of the forum,
/// not of a session or a context object, and re-fetching them on every
/// `getConfig` would spend rate-limit budget re-asking a settled question.
class DiscourseSiteCapabilities {
  DiscourseSiteCapabilities._();

  static final Map<String, DiscourseSiteCapabilities> _bySite = {};

  /// `top_menu_items` — the list routes this forum offers ("latest",
  /// "hot", "unread", …). Empty when unknown, which callers must treat as
  /// "don't know" rather than "offers nothing".
  List<String> topMenuItems = const [];

  /// Whether the current user may tag topics (`can_tag_topics`). The
  /// composer offers tagging without this and lets the server refuse.
  bool canTagTopics = false;

  /// The forum's uncategorized category id, or null. Rows in it should not
  /// wear a category badge — web hides it.
  int? uncategorizedCategoryId;

  /// Legal links, absolute or site-relative as the server gave them.
  String? tosUrl;
  String? privacyPolicyUrl;

  /// Every category the forum publishes, subcategories included.
  ///
  /// `/categories.json` returns only top-level categories — even with
  /// `include_subcategories=true`, which meta.discourse.org ignores — so
  /// the category tree cannot be built from it alone. `/site.json` carries
  /// all of them with `parent_category_id`, and this app already fetches
  /// it once per forum, so the children come for free.
  List<Map<String, dynamic>> categories = const [];

  /// True once a real payload has been parsed for this forum. Distinguishes
  /// "asked, offers nothing" from "never asked".
  bool resolved = false;

  static DiscourseSiteCapabilities forSite(String pluginUrl) =>
      _bySite[pluginUrl] ?? DiscourseSiteCapabilities._();

  /// True when this forum offers the given list route, e.g. `hot`.
  ///
  /// Answers false while unresolved: a tab that might not exist is worse
  /// than a tab that appears a moment later, because tapping it would 404.
  static bool offersRoute(String pluginUrl, String route) {
    final caps = _bySite[pluginUrl];
    if (caps == null || !caps.resolved) return false;
    return caps.topMenuItems.contains(route);
  }

  /// Parses a `/site.json` body. Ignores a payload that names no menu
  /// items — that is a shape we do not recognise, not a forum with no
  /// routes, and overwriting a good answer with it would be worse.
  static void store(String pluginUrl, Map<String, dynamic> site) {
    final menu = ((site['top_menu_items'] as List?) ?? const [])
        .whereType<String>()
        .toList(growable: false);
    if (menu.isEmpty) return;
    final caps = _bySite.putIfAbsent(pluginUrl, DiscourseSiteCapabilities._);
    caps.topMenuItems = menu;
    caps.canTagTopics = site['can_tag_topics'] == true;
    caps.uncategorizedCategoryId = site['uncategorized_category_id'] as int?;
    caps.categories = ((site['categories'] as List?) ?? const [])
        .whereType<Map>()
        .map((c) => c.cast<String, dynamic>())
        .toList(growable: false);
    caps.tosUrl = (site['tos_url'] as String?)?.trim();
    caps.privacyPolicyUrl = (site['privacy_policy_url'] as String?)?.trim();
    caps.resolved = true;
  }

  static bool isResolved(String pluginUrl) =>
      _bySite[pluginUrl]?.resolved ?? false;

  @visibleForTesting
  static void reset() => _bySite.clear();
}
