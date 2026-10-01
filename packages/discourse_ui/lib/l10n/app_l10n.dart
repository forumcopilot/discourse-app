import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart' show globalNavigatorKey;

import '../settings_context.dart';
import 'generated/app_localizations.dart';

/// The app's strings where there is no [BuildContext] to look them up
/// from: controllers, services and helpers whose text ends up on screen
/// (a result message, a snackbar a caller shows). Widgets use
/// `AppLocalizations.of(context)`.
///
/// The language the app is showing: the navigator's, once it is up; else
/// the one picked in Settings, else the phone's; English when the app
/// does not speak it.
AppLocalizations appL10n() {
  final context = globalNavigatorKey.currentContext;
  if (context != null) {
    final l10n = AppLocalizations.of(context);
    if (l10n != null) return l10n;
  }
  for (final locale in [
    SettingsContext.instance.locale.value,
    PlatformDispatcher.instance.locale,
  ]) {
    if (locale == null) continue;
    try {
      return lookupAppLocalizations(locale);
    } catch (_) {
      // Not a language the app has; try the next.
    }
  }
  return lookupAppLocalizations(const Locale('en'));
}
