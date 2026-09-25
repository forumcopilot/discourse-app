import 'dart:convert';

import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities;
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_forum_config.dart';
import '../core/logging/app_logger.dart';
import '../theme/app_theme.dart';
import '../theme/forum_palette.dart';

/// Puts the open forum's colours on the app.
///
/// `SingleForumBootstrapPage` calls [enter] when a forum opens and [leave]
/// when it closes; the innermost open forum's palette goes to
/// [AppTheme.palette], and none is set outside a forum (a host's forum
/// list keeps the host's colours). Forums are keyed by `site.pluginUrl`,
/// as `DiscourseSiteCapabilities` is.
///
/// Palettes are remembered on the device, so a forum opens in its own
/// colours at once instead of the app's for a moment until `/site.json`
/// answers.
class ForumTheme {
  ForumTheme._();

  static const _prefsKey = 'forum_palettes';

  /// Enough for every forum a reader of a multi-forum host keeps coming
  /// back to; older ones are dropped first.
  static const _remembered = 50;

  // Insertion-ordered: the most recently updated forum is last.
  static final Map<String, ForumPalette> _palettes = {};
  static final List<String> _open = [];
  static Future<void>? _applying;

  /// The palette the forum at [siteKey] should wear now: its own, if
  /// known and forum colours are on. `SingleForumBootstrapPage` themes
  /// itself with this directly, so it is in the forum's colours from its
  /// first frame, before the app-wide change below lands.
  static ForumPalette? paletteFor(String siteKey) =>
      AppForumConfig.useForumColors ? _palettes[siteKey] : null;

  /// Loads the remembered palettes. `SettingsContext.loadFromDevice` calls
  /// this, which both app shells await before their first frame.
  static Future<void> loadRemembered() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final json = jsonDecode(raw);
      if (json is! Map) return;
      for (final e in json.entries) {
        final palette = ForumPalette.fromJson(e.value);
        // A palette fetched this session is newer than the stored one.
        if (palette != null) _palettes.putIfAbsent(e.key.toString(), () => palette);
      }
      await _apply();
    } catch (e) {
      AppLogger.debug('ForumTheme: remembered palettes unreadable: $e');
    }
  }

  /// The forum at [siteKey] is now on screen. The app-wide change lands
  /// when the returned future completes (see [_apply]).
  static Future<void> enter(String siteKey) {
    _open.add(siteKey);
    return _apply();
  }

  /// The forum at [siteKey] has closed.
  static Future<void> leave(String siteKey) {
    final i = _open.lastIndexOf(siteKey);
    if (i >= 0) _open.removeAt(i);
    return _apply();
  }

  /// Takes [siteKey]'s palette from its parsed `/site.json`, if it has
  /// been read; otherwise the remembered one stays.
  static Future<void> updateFromCapabilities(String siteKey) async {
    final caps = DiscourseSiteCapabilities.forSite(siteKey);
    if (!caps.resolved) return;
    await update(
      siteKey,
      ForumPalette.fromHex(light: caps.lightScheme, dark: caps.darkScheme),
    );
  }

  /// Records [palette] for [siteKey], applies it if that forum is open,
  /// and remembers it.
  static Future<void> update(String siteKey, ForumPalette palette) async {
    final unchanged = _palettes[siteKey] == palette;
    _palettes.remove(siteKey);
    _palettes[siteKey] = palette;
    while (_palettes.length > _remembered) {
      _palettes.remove(_palettes.keys.first);
    }
    await _apply();
    if (unchanged) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey,
          jsonEncode(_palettes.map((k, v) => MapEntry(k, v.toJson()))));
    } catch (e) {
      AppLogger.debug('ForumTheme: palette not remembered: $e');
    }
  }

  // enter/leave run from a page's initState/dispose — mid-build, where the
  // app shell's Obx (an ancestor) must not be marked dirty. That is not
  // always inside a frame: the single-forum app's first page is built by
  // runApp's attach, outside any frame, so the scheduler phase cannot tell.
  // A microtask always runs after the synchronous build that queued it, so
  // the app-wide change waits for one; the page themes itself meanwhile.
  static Future<void> _apply() =>
      _applying ??= Future.microtask(() {
        _applying = null;
        _applyNow();
      });

  static void _applyNow() {
    AppTheme.palette.value =
        _open.isEmpty ? null : paletteFor(_open.last);
  }

  @visibleForTesting
  static void reset() {
    _palettes.clear();
    _open.clear();
    _applying = null;
    AppTheme.palette.value = null;
  }
}
