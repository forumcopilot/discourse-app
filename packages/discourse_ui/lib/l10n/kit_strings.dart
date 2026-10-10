import 'package:flutter/widgets.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';

import 'generated/app_localizations.dart';

/// The strings forum_kit keeps for both apps (discourse-app and flarum-app),
/// in the language of this [AppLocalizations]: `l10n.kit.okButton`. They
/// moved out of `app_*.arb` into forum_kit's `kit_*.arb`; both catalogues
/// cover the same languages.
extension KitStrings on AppLocalizations {
  KitLocalizations get kit {
    final locale = Locale(localeName.split(RegExp('[_-]')).first);
    return lookupKitLocalizations(
        KitLocalizations.delegate.isSupported(locale) ? locale : const Locale('en'));
  }
}
