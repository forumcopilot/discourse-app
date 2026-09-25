import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../settings_context.dart';
import '../../theme/design_tokens.dart';

/// The label for [mode] as the Appearance picker shows it.
String appearanceLabel(BuildContext context, ThemeMode mode) {
  final l10n = AppLocalizations.of(context)!;
  return switch (mode) {
    ThemeMode.system => l10n.appearanceSystem,
    ThemeMode.light => l10n.light,
    ThemeMode.dark => l10n.dark,
  };
}

/// System default / Light / Dark as radio rows, bound to the saved
/// setting. Picking one applies it at once — the app, native UI and forum
/// pages in web views — and remembers it.
///
/// The drawer shows it in [showAppearanceSheet]; a host app with a
/// settings screen of its own (ABDA) embeds it there instead.
class AppearanceChoices extends StatelessWidget {
  const AppearanceChoices({super.key, this.onChanged});

  /// Called after a choice has been applied.
  final ValueChanged<ThemeMode>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = SettingsContext.instance.themeMode.value;
      return RadioGroup<ThemeMode>(
        groupValue: current,
        onChanged: (mode) {
          if (mode == null) return;
          SettingsContext.instance.setThemeMode(mode);
          onChanged?.call(mode);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final mode in ThemeMode.values)
              RadioListTile<ThemeMode>(
                title: Text(appearanceLabel(context, mode)),
                value: mode,
                selected: mode == current,
              ),
          ],
        ),
      );
    });
  }
}

/// [AppearanceChoices] in a bottom sheet that closes on a pick.
Future<void> showAppearanceSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                DesignTokens.spacingL,
                0,
                DesignTokens.spacingL,
                DesignTokens.spacingS,
              ),
              child: Text(
                AppLocalizations.of(sheetContext)!.appearance,
                style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                      fontWeight: DesignTokens.fontWeightSemiBold,
                    ),
              ),
            ),
            AppearanceChoices(
              onChanged: (_) => Navigator.of(sheetContext).pop(),
            ),
            const SizedBox(height: DesignTokens.spacingS),
          ],
        ),
      );
    },
  );
}
