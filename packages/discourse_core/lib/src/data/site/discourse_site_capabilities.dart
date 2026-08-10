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

  /// Whether the user may create tags that do not exist yet
  /// (`can_create_tag`). Distinct from [canTagTopics]: meta lets a TL1 user
  /// apply existing tags but not invent new ones, so a composer that
  /// accepts free text there loses whatever the user typed.
  bool canCreateTag = false;

  /// The forum's uncategorized category id, or null. Rows in it should not
  /// wear a category badge — web hides it.
  int? uncategorizedCategoryId;

  /// The forum's own logos, from `/site/settings.json` (already fetched
  /// for the upload limits). Absolute URLs — Discourse resolves these for
  /// us in the `site_*_url` variants, unlike the raw `logo` settings which
  /// are protocol-relative.
  String? logoUrl;
  String? logoDarkUrl;
  String? mobileLogoUrl;
  String? mobileLogoDarkUrl;
  String? smallLogoUrl;
  String? smallLogoDarkUrl;

  /// The logo to show in a **square** slot, honouring the current theme.
  ///
  /// `logo_small` first: it is the square mark Discourse ships for exactly
  /// this, and the full logo is usually a wide wordmark — try.discourse.org
  /// serves the same wide SVG for `logo` and `mobile_logo`, so cover-fitting
  /// it into a square tile crops to the middle three letters. Falls back
  /// through small → mobile → full, dark variant first in dark mode, so a
  /// forum that set only some of the six still gets something.
  String? logoFor({required bool dark}) {
    String? first(List<String?> candidates) {
      for (final c in candidates) {
        if (c != null && c.isNotEmpty) return c;
      }
      return null;
    }

    if (dark) {
      return first([
        smallLogoDarkUrl,
        smallLogoUrl,
        mobileLogoDarkUrl,
        mobileLogoUrl,
        logoDarkUrl,
        logoUrl,
      ]);
    }
    return first([smallLogoUrl, mobileLogoUrl, logoUrl]);
  }

  /// The forum's **wide** logo — the wordmark, for a full-width slot.
  ///
  /// Deliberately separate from [logoFor], which serves square slots.
  /// Discourse ships two assets because they are two shapes: on
  /// try.discourse.org `logo` is 148×40 and `logo_small` is 103×104. Using
  /// one where the other belongs either crops the wordmark or stretches
  /// the mark.
  ///
  /// Prefers `mobile_logo`, which is the asset an admin picks specifically
  /// for narrow screens; forums that leave it unset fall back to the full
  /// logo, which is what Discourse itself does.
  String? wideLogoFor({required bool dark}) {
    String? first(List<String?> candidates) {
      for (final c in candidates) {
        if (c != null && c.isNotEmpty) return c;
      }
      return null;
    }

    if (dark) {
      return first(
          [mobileLogoDarkUrl, mobileLogoUrl, logoDarkUrl, logoUrl]);
    }
    return first([mobileLogoUrl, logoUrl]);
  }

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
    caps.canCreateTag = site['can_create_tag'] == true;
    caps.uncategorizedCategoryId = site['uncategorized_category_id'] as int?;
    caps.categories = ((site['categories'] as List?) ?? const [])
        .whereType<Map>()
        .map((c) => c.cast<String, dynamic>())
        .toList(growable: false);
    caps.tosUrl = (site['tos_url'] as String?)?.trim();
    caps.privacyPolicyUrl = (site['privacy_policy_url'] as String?)?.trim();
    caps.resolved = true;
  }

  /// A category's display name, or null when this forum's payload has
  /// not been parsed or has no such category.
  String? categoryNameFor(String categoryId) {
    if (categoryId.isEmpty) return null;
    final id = int.tryParse(categoryId);
    if (id == null) return null;
    for (final c in categories) {
      if (c['id'] == id) {
        final name = (c['name'] as String?)?.trim();
        return (name == null || name.isEmpty) ? null : name;
      }
    }
    return null;
  }

  /// The composer template a category defines, or null.
  ///
  /// Discourse lets a category ship a skeleton — a bug-report form, a
  /// theme's summary table — and web prefills the composer with it. A
  /// category that expects a structured post otherwise hands the user a
  /// blank box and rejects, or silently accepts, whatever they improvise.
  String? topicTemplateFor(String categoryId) {
    if (categoryId.isEmpty) return null;
    final id = int.tryParse(categoryId);
    if (id == null) return null;
    for (final c in categories) {
      if (c['id'] == id) {
        final tpl = (c['topic_template'] as String?)?.trim();
        return (tpl == null || tpl.isEmpty) ? null : tpl;
      }
    }
    return null;
  }

  /// Records the forum's logos. Separate from [store] because they come
  /// from `/site/settings.json`, not `/site.json`, and the two are read at
  /// different points — so this must not depend on the other having run.
  static void storeLogos(
    String pluginUrl, {
    String? logoUrl,
    String? logoDarkUrl,
    String? mobileLogoUrl,
    String? mobileLogoDarkUrl,
    String? smallLogoUrl,
    String? smallLogoDarkUrl,
  }) {
    final caps = _bySite.putIfAbsent(pluginUrl, DiscourseSiteCapabilities._);
    caps.logoUrl = logoUrl?.trim();
    caps.logoDarkUrl = logoDarkUrl?.trim();
    caps.mobileLogoUrl = mobileLogoUrl?.trim();
    caps.mobileLogoDarkUrl = mobileLogoDarkUrl?.trim();
    caps.smallLogoUrl = smallLogoUrl?.trim();
    caps.smallLogoDarkUrl = smallLogoDarkUrl?.trim();
  }

  static bool isResolved(String pluginUrl) =>
      _bySite[pluginUrl]?.resolved ?? false;

  @visibleForTesting
  static void reset() => _bySite.clear();
}
