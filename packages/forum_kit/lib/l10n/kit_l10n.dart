import 'package:flutter/widgets.dart';

import 'generated/kit_localizations.dart';

export 'generated/kit_localizations.dart';

/// The kit's strings in [context]'s language.
///
/// Uses [KitLocalizations.delegate] when the app registered it, and otherwise
/// looks the strings up directly, so an app that only registers its own
/// delegates (ABDA, discourse-app's tests) still gets them. Falls back to
/// English for a language the kit doesn't have.
KitLocalizations kitL10n(BuildContext context) {
  final registered = KitLocalizations.of(context);
  if (registered != null) return registered;
  final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
  return lookupKitLocalizations(
      KitLocalizations.delegate.isSupported(locale) ? locale : const Locale('en'));
}
