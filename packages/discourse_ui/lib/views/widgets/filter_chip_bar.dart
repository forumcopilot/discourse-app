import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

/// One option in a [FilterChipBar].
class FilterChipOption {
  const FilterChipOption({required this.label, this.icon});

  final String label;

  /// Optional leading glyph. The profile's tabs use one; the topic
  /// filters do not — both are fine, but within a single bar it should be
  /// all or nothing.
  final IconData? icon;
}

/// The app's horizontal filter/segment selector.
///
/// Exists because three screens had grown three different answers to the
/// same control: the Home tab used a hand-styled `FilterChip`, the profile
/// used a bare `ChoiceChip` on default theming, and the category page a
/// third variant — so the same gesture looked different depending on where
/// you were.
///
/// The Home tab's styling won, being the only one expressed in design
/// tokens rather than Material defaults. Chips scroll horizontally: a
/// forum may offer five filters, and they must not squeeze or wrap.
class FilterChipBar extends StatelessWidget {
  const FilterChipBar({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
    this.padding,
  });

  final List<FilterChipOption> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Defaults to the standard inset. Callers embedding the bar inside an
  /// already-padded region can tighten it.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingL,
            vertical: DesignTokens.spacingM,
          ),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: options.length,
          separatorBuilder: (_, __) => SizedBox(width: DesignTokens.spacingS),
          itemBuilder: (context, index) {
            final option = options[index];
            final isSelected = index == selectedIndex;
            return FilterChip(
              selected: isSelected,
              avatar: option.icon == null
                  ? null
                  : Icon(option.icon, size: DesignTokens.iconSizeS),
              label: Text(option.label),
              onSelected: (_) {
                if (isSelected) return;
                onSelected(index);
              },
              selectedColor: colorScheme.primaryContainer,
              // No checkmark. Material draws it *over* the avatar slot, so
              // a selected chip had a tick sitting on top of its own icon;
              // and the chip already turns the highlight colour, so the
              // tick was saying a second time what the fill already said.
              showCheckmark: false,
              labelStyle: textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected
                    ? DesignTokens.fontWeightSemiBold
                    : DesignTokens.fontWeightNormal,
              ),
              backgroundColor: colorScheme.surfaceVariant,
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingM,
                vertical: DesignTokens.spacingS,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              ),
            );
          },
        ),
      ),
    );
  }
}
