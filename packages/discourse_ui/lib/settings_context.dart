import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'theme/app_theme.dart';
import 'services/appearance_sync.dart';
import 'services/forum_theme.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';
import 'dart:ui' as ui;

class SettingsContext {
  static SettingsContext? _instance;
  static SettingsContext get instance => _instance ??= SettingsContext();

  // Observable settings

  /// The Appearance choice. The same observable as [AppTheme.themeMode],
  /// which the app shell (here and in host apps) passes to
  /// `MaterialApp.themeMode` — one value, two names, so they can't drift.
  /// Change it through [setThemeMode] so it is saved and reaches the
  /// native layer and web views.
  Rx<ThemeMode> get themeMode => AppTheme.themeMode;
  final RxInt pagePerSize = 20.obs; // Default page size for paging
  final Rx<Locale?> locale = Rx<Locale?>(null); // null = use system locale

  /// "Don't ask again" for the oversized-image resize prompt. False means
  /// ask each time; true means resize and say so without interrupting.
  final RxBool alwaysResizeOversizedImages = false.obs;

  // Initialize settings from device
  Future<void> loadFromDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load theme mode
      final String? themeModeStr = prefs.getString('theme_mode');
      if (themeModeStr != null) {
        final ThemeMode loadedThemeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeModeStr,
          orElse: () => ThemeMode.system,
        );
        themeMode.value = loadedThemeMode;
      }
      // Also when nothing is saved: Android persists the per-app night
      // mode itself, and a stale one must not outlive a reinstall of prefs.
      AppearanceSync.apply(themeMode.value);
      // Before the first frame, so a forum opens in its own colours.
      await ForumTheme.loadRemembered();

      // Load page_per_size
      final int? loadedPagePerSize = prefs.getInt('page_per_size');
      if (loadedPagePerSize != null && loadedPagePerSize > 0) {
        pagePerSize.value = loadedPagePerSize;
      }

      // Load the oversized-image resize preference
      alwaysResizeOversizedImages.value =
          prefs.getBool('always_resize_oversized_images') ?? false;

      // Load locale
      final String? localeCode = prefs.getString('locale');
      if (localeCode != null && localeCode.isNotEmpty) {
        locale.value = Locale(localeCode);
        // Update GetX locale to match saved preference
        Get.updateLocale(Locale(localeCode));
      } else {
        locale.value = null; // Use system locale
        // Update GetX to use device locale
        final deviceLocale = ui.PlatformDispatcher.instance.locale;
        Get.updateLocale(deviceLocale);
      }

      AppLogger.debug('Settings loaded from device:');
      AppLogger.debug('- Theme Mode: ${themeMode.value}');
      AppLogger.debug('- Page Per Size: ${pagePerSize.value}');
      AppLogger.debug('- Locale: ${locale.value?.languageCode ?? "system"}');
    } catch (e) {
      AppLogger.debug('Error loading settings: $e');
    }
  }

  /// Switches the app to [mode] now — Flutter UI, native UI and Discourse
  /// pages in web views — and remembers it.
  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    AppearanceSync.apply(mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', mode.toString());
    } catch (e) {
      AppLogger.debug('Failed to persist theme mode: $e');
    }
  }

  // Save settings to device
  Future<void> saveToDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save theme mode
      await prefs.setString('theme_mode', themeMode.value.toString());

      // Save page_per_size
      await prefs.setInt('page_per_size', pagePerSize.value);

      // Save locale
      if (locale.value != null) {
        await prefs.setString('locale', locale.value!.languageCode);
      } else {
        await prefs.remove('locale'); // Remove to use system locale
      }

      AppLogger.debug('Settings saved to device:');
      AppLogger.debug('- Theme Mode: ${themeMode.value}');
      AppLogger.debug('- Page Per Size: ${pagePerSize.value}');
      AppLogger.debug('- Locale: ${locale.value?.languageCode ?? "system"}');
    } catch (e) {
      AppLogger.debug('Error saving settings: $e');
    }
  }

  // Reset settings to defaults
  Future<void> resetToDefaults() async {
    themeMode.value = ThemeMode.system;
    AppearanceSync.apply(ThemeMode.system);
    pagePerSize.value = 20;
    locale.value = null; // Use system locale
    await saveToDevice();
  }

  /// Persists the "don't ask again" choice from the resize prompt.
  Future<void> setAlwaysResizeOversizedImages(bool value) async {
    alwaysResizeOversizedImages.value = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('always_resize_oversized_images', value);
    } catch (e) {
      AppLogger.debug('Failed to persist resize preference: $e');
    }
  }
}
