import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';
import '../../utils/accessibility_helpers.dart';

/// Phase 5.29 — shared action-button widget for the bottom row of a
/// post (Reply / Like / Bookmark / Accept).
///
/// **Style guide** for post-level action buttons. Every button in
/// the trailing row should use this widget so they share:
///
/// * **Touch target**: 48×48 minimum (wraps
///   `AccessibilityHelpers.accessibleIconButton` which centres the
///   icon inside a Container of that minimum size), growing with the
///   icon.
/// * **Icon size**: Material's 24dp ([baseIconSize]), scaled with the
///   reader's text size up to [maxIconScale] — see [iconSizeOf]. Icons
///   do not follow the text scale by themselves, so on a phone set to
///   large text the body grew to ~20pt while the row stayed at 22dp and
///   read as an afterthought.
/// * **Active color**: caller-supplied semantic role — `ForumColors.love`
///   for Like, `primary` for Bookmark, `tertiary` for Accept. The active
///   icon shape can also differ (`Icons.favorite` vs
///   `Icons.favorite_border`).
/// * **Inactive color**: `onSurfaceVariant` at full strength, as
///   Material 3 draws a standard icon button. It used to be faded to
///   50%, a hair above the 38% Material uses for *disabled*, so every
///   post's actions looked switched off. [emphasized] buttons (Reply)
///   use `onSurface`, as web draws its reply button in `primary-high`
///   against the other controls' `primary-low-mid`.
/// * **Long-press**: optional, used by Like to open the reaction
///   picker. The press swallows the long-press up the tree so the
///   parent's row-long-press doesn't fire.
/// * **Semantics**: forwarded to `accessibleIconButton`, so screen
///   readers get a meaningful label / selection state.
///
/// **Spacing between buttons** is the caller's responsibility:
/// `PostListItemSocial` packs them `DesignTokens.spacingXS` apart, as the
/// 48dp targets already hold the icons ~24dp apart.
class PostActionButton extends StatelessWidget {
  /// Icon shown when `active` is false. The outline-style variant
  /// (e.g. `Icons.favorite_border`, `Icons.bookmark_border`,
  /// `Icons.reply_rounded`).
  final IconData icon;

  /// Optional filled-style icon swap when `active` is true. When
  /// null, [icon] is used in both states (Reply doesn't have a
  /// distinct active state, for example).
  final IconData? activeIcon;

  /// Drives both the colour and the icon-shape swap. True ⇒ icon
  /// renders in [activeColor]; false ⇒ renders in the inactive
  /// muted role.
  final bool active;

  /// Semantic role for the active state. Defaults to
  /// `colorScheme.primary`. Like uses `colorScheme.error`.
  final Color? activeColor;

  /// Tap handler. Pass `null` to disable the button entirely
  /// (icon still renders but no tap is wired).
  final VoidCallback? onTap;

  /// Optional long-press handler — wired by Like to open the
  /// reaction picker via [ReactionPickerSheet].
  final VoidCallback? onLongPress;

  /// Required for screen readers. Examples: "Like post" /
  /// "Unlike post" / "Bookmark post" / "Remove bookmark".
  final String semanticLabel;

  /// Optional supplementary hint for screen readers.
  final String? semanticHint;

  /// The row's primary action (Reply): drawn in `onSurface` rather than
  /// the muted `onSurfaceVariant` while inactive.
  final bool emphasized;

  /// Material's standard icon-button glyph.
  static const double baseIconSize = DesignTokens.iconSizeL;

  /// How far the icons follow the reader's text size. Enough to keep pace
  /// with large text, short of letting four buttons crowd a narrow phone.
  static const double maxIconScale = 1.3;

  /// The action-row icon size under the ambient text scale. Shared with
  /// the reaction cluster so its glyphs keep pace with the buttons.
  static double iconSizeOf(BuildContext context,
          [double base = baseIconSize]) =>
      MediaQuery.textScalerOf(context)
          .clamp(maxScaleFactor: maxIconScale)
          .scale(base);

  const PostActionButton({
    super.key,
    required this.icon,
    this.activeIcon,
    this.active = false,
    this.activeColor,
    this.onTap,
    this.onLongPress,
    required this.semanticLabel,
    this.semanticHint,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconData = (active && activeIcon != null) ? activeIcon! : icon;
    final color = active
        ? (activeColor ?? colorScheme.primary)
        : (emphasized ? colorScheme.onSurface : colorScheme.onSurfaceVariant);

    return AccessibilityHelpers.accessibleIconButton(
      icon: Icon(
        iconData,
        color: color,
        size: iconSizeOf(context),
      ),
      onTap: onTap,
      label: semanticLabel,
      hint: semanticHint,
      isSelected: active,
      context: context,
      onLongPress: onLongPress,
    );
  }
}
