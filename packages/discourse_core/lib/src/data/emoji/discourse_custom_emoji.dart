import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../network/discourse_client.dart';
import '../../util/site_url.dart';

/// A forum's emoji images by name, from its `/emojis.json`.
///
/// For the emoji Unicode has no character for: a forum's own (Meta's
/// `:discourse:`) and the few Discourse names that are images only. The app
/// used to guess `/images/emoji/twitter/<name>.png`, which does not exist
/// for a custom emoji, so the reaction fell back to a heart and a post's
/// reactions could read as two hearts.
///
/// The list is about 250 KB (every emoji the forum knows), so it is fetched
/// once a session per forum, and only when a name is missing from the
/// app's own emoji table. [revision] ticks when a forum's list arrives, so
/// a glyph drawn before it can redraw.
class DiscourseCustomEmoji {
  DiscourseCustomEmoji._();

  static final Map<String, Map<String, String>> _bySite = {};
  static final Map<String, Future<void>> _loading = {};

  /// Ticks whenever a forum's list has been read.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// Replaces the request in tests: returns the decoded `/emojis.json`.
  @visibleForTesting
  static Future<Object?> Function(SiteContext context)? fetchOverride;

  static String _key(String siteUrl) {
    var key = siteUrl.trim();
    while (key.endsWith('/')) {
      key = key.substring(0, key.length - 1);
    }
    return key;
  }

  /// The image address of emoji [name] on [siteUrl]'s forum, or null when
  /// the list has not been read yet or does not have it.
  static String? urlFor(String siteUrl, String name) =>
      _bySite[_key(siteUrl)]?[name];

  /// Whether [siteUrl]'s list has been read (even if it came back empty).
  static bool isLoaded(String siteUrl) => _bySite.containsKey(_key(siteUrl));

  /// Reads [context]'s list unless it has been read already this session.
  static Future<void> ensureLoaded(SiteContext context) {
    final key = _key(context.site.url);
    if (_bySite.containsKey(key)) return Future<void>.value();
    // The callback must not return the removed future: it is this very
    // future, and whenComplete would then wait on itself forever.
    return _loading[key] ??= _load(context, key).whenComplete(() {
      _loading.remove(key);
    });
  }

  static Future<void> _load(SiteContext context, String key) async {
    Object? decoded;
    try {
      final override = fetchOverride;
      if (override != null) {
        decoded = await override(context);
      } else {
        final response = await DiscourseClient().get(context, '/emojis.json');
        if (response.statusCode == 200) decoded = jsonDecode(response.body);
      }
    } catch (_) {
      decoded = null;
    }
    final byName = <String, String>{};
    if (decoded is Map) {
      for (final group in decoded.values) {
        if (group is! List) continue;
        for (final entry in group.whereType<Map>()) {
          final name = entry['name'];
          final url = entry['url'];
          if (name is String && url is String && name.isNotEmpty && url.isNotEmpty) {
            byName[name] = absoluteSiteUrl(key, url);
          }
        }
      }
    }
    // Recorded even when empty, so a forum whose list cannot be read is
    // asked once a session rather than once per glyph.
    _bySite[key] = byName;
    revision.value++;
  }

  /// Only for tests and sign-out.
  static void clear() {
    _bySite.clear();
    _loading.clear();
  }
}
