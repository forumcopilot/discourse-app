import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/services.dart';

/// Carries the app's light/dark choice below Flutter.
///
/// `MaterialApp.themeMode` only recolours what Flutter draws. Web views
/// (`prefers-color-scheme`), share sheets, pickers and other system UI
/// read the platform's own appearance, so an in-app "Dark" on a light
/// phone left them light. This forces that appearance to match:
///
/// * iOS — `overrideUserInterfaceStyle` on every window.
/// * macOS — `NSApp.appearance`.
/// * Android 12+ — `UiModeManager.setApplicationNightMode`, which Android
///   persists per app and which the WebView reads. Older Android has no
///   per-app switch, so there the platform keeps following the system.
///
/// Elsewhere (web, Windows, Linux, tests) it is a no-op.
class DiscourseAppearance {
  DiscourseAppearance._();

  @visibleForTesting
  static const MethodChannel channel =
      MethodChannel('com.forumcopilot/discourse_appearance');

  /// Applies [mode] to the platform. Never throws: a host without the
  /// plugin (or a platform without a handler) keeps its system appearance.
  static Future<void> apply(ThemeMode mode) async {
    try {
      await channel.invokeMethod<void>('setMode', modeName(mode));
    } on MissingPluginException {
      // No native side on this platform.
    } on PlatformException catch (e) {
      debugPrint('DiscourseAppearance.apply($mode) failed: $e');
    }
  }

  /// The wire name for [mode]: `system`, `light` or `dark`.
  static String modeName(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
}
