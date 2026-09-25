import 'package:discourse_appearance/discourse_appearance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../core/logging/app_logger.dart';

/// Writes one cookie into the platform web view store.
typedef ColorModeCookieWriter = Future<void> Function(
    Uri origin, String value, DateTime expires);

/// Keeps everything Flutter doesn't draw on the app's light/dark choice.
///
/// `MaterialApp.themeMode` recolours Flutter's own widgets only. Two more
/// layers need telling:
///
/// * **Discourse pages in web views** (sign-in grant, link categories,
///   the Cloudflare challenge in front of the forum). Discourse picks its
///   light or dark stylesheet server-side from the `forced_color_mode`
///   cookie (`ApplicationHelper#forced_light_mode?` / `forced_dark_mode?`
///   in the Discourse source), so the page renders in the right mode on
///   first paint. `auto` defers to `prefers-color-scheme`, which also
///   overrides a mode the user saved on the web.
/// * **Everything else native** — other sites' `prefers-color-scheme`,
///   share sheets, pickers — via [DiscourseAppearance].
///
/// The cookie is only written for forum origins registered through
/// [registerForum]: other sites get the mode through the native layer,
/// not a cookie they never set.
class AppearanceSync {
  AppearanceSync._();

  /// The cookie Discourse's interface colour selector uses
  /// (`frontend/discourse/app/services/interface-color.js`).
  static const cookieName = 'forced_color_mode';

  static ThemeMode _mode = ThemeMode.system;
  static final Set<String> _forumOrigins = {};
  static Future<void> _pending = Future.value();

  @visibleForTesting
  static ColorModeCookieWriter writeCookie = _writePlatformCookie;

  @visibleForTesting
  static Future<void> Function(ThemeMode) applyNative =
      DiscourseAppearance.apply;

  /// The cookie value for [mode].
  static String cookieValue(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'auto',
      };

  /// Applies [mode] to the native layer and to every registered forum.
  static Future<void> apply(ThemeMode mode) {
    _mode = mode;
    return _enqueue(() async {
      await applyNative(mode);
      for (final origin in _forumOrigins) {
        await _write(origin);
      }
    });
  }

  /// Registers the forum at [baseUrl] and writes its cookie for the
  /// current mode. Call as soon as the forum is known, before any web
  /// view (including the SDK's Cloudflare challenge) can load it.
  static Future<void> registerForum(String baseUrl) {
    final origin = _originOf(baseUrl);
    if (origin == null || !_forumOrigins.add(origin)) return _pending;
    return _enqueue(() => _write(origin));
  }

  /// Completes once the cookie for [url]'s origin is in place, if that
  /// origin is a registered forum. Await before loading [url].
  static Future<void> prepare(String url) {
    final origin = _originOf(url);
    if (origin == null || !_forumOrigins.contains(origin)) return _pending;
    return _enqueue(() => _write(origin));
  }

  @visibleForTesting
  static void reset() {
    _mode = ThemeMode.system;
    _forumOrigins.clear();
    _pending = Future.value();
    writeCookie = _writePlatformCookie;
    applyNative = DiscourseAppearance.apply;
  }

  // Serialised so a quick Light → Dark tap can't land the writes out of
  // order. A failed job is logged, never left in the chain: an errored
  // _pending would skip every write queued after it.
  static Future<void> _enqueue(Future<void> Function() job) =>
      _pending = _pending.then((_) => job()).catchError((Object e) {
        AppLogger.debug('AppearanceSync: $e');
      });

  static Future<void> _write(String origin) async {
    try {
      await writeCookie(Uri.parse(origin), cookieValue(_mode),
          DateTime.now().add(const Duration(days: 365)));
    } catch (e) {
      // No web view cookie store on this platform (web, Linux, tests).
      AppLogger.debug('AppearanceSync: cookie not written for $origin: $e');
    }
  }

  static String? _originOf(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
    return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
  }

  static Future<void> _writePlatformCookie(
      Uri origin, String value, DateTime expires) async {
    if (kIsWeb) return;
    await CookieManager.instance().setCookie(
      url: WebUri.uri(origin),
      name: cookieName,
      value: value,
      path: '/',
      expiresDate: expires.millisecondsSinceEpoch,
    );
  }
}
