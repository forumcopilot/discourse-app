import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';
import '../../utils/accessibility_helpers.dart';

/// Phase 5.29 — shared action-button widget for the bottom row of a
/// post (Like / Bookmark / Reply, plus any future ones).
///
/// **Style guide** for post-level action buttons. Every button in
/// the trailing row should use this widget so they share:
///
/// * **Touch target**: 48×48 minimum (wraps
///   `AccessibilityHelpers.accessibleIconButton` which centres the
///   icon inside a Container of that minimum size). Critical for
///   reachability on mobile.
/// * **Icon size**: `DesignTokens.iconSizeMedium` (22px) for every
///   button. Anything bigger fights with the header avatar; anything
///   smaller feels accidental.
/// * **Active color**: caller-supplied semantic role
///   — `colorScheme.error` for Like (heart fills red), `primary` for
///   Bookmark and Reply. The active icon shape can also differ
///   (`Icons.favorite` vs `Icons.favorite_border`).
/// * **Inactive color**: `onSurfaceVariant` at
///   `DesignTokens.opacityMediumLow` (0.5). The same value across
///   light + dark themes — the 0.4 / 0.5 dark-vs-light branching
///   the legacy code did was vestigial; `onSurfaceVariant` already
///   adapts per theme, so a single opacity reads cleanly in both.
/// * **Long-press**: optional, used by Like to open the reaction
///   picker. The press swallows the long-press up the tree so the
///   parent's row-long-press doesn't fire.
/// * **Semantics**: forwarded to `accessibleIconButton`, so screen
///   readers get a meaningful label / selection state.
///
/// **Spacing between buttons** is the caller's responsibility — the
/// established pattern is `SizedBox(width: DesignTokens.spacingXL)`
/// (24px) between adjacent buttons in the trailing row.
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
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconData = (active && activeIcon != null) ? activeIcon! : icon;
    final color = active
        ? (activeColor ?? colorScheme.primary)
        : colorScheme.onSurfaceVariant
            .withOpacity(DesignTokens.opacityMediumLow);

    final button = AccessibilityHelpers.accessibleIconButton(
      icon: Icon(
        iconData,
        color: color,
        size: DesignTokens.iconSizeMedium,
      ),
      onTap: onTap,
      label: semanticLabel,
      hint: semanticHint,
      isSelected: active,
      context: context,
    );

    if (onLongPress != null) {
      return GestureDetector(
        // Behavior translucent so the gesture detector still fills
        // the 48x48 target supplied by `accessibleIconButton` and
        // hits empty space too — without it the long-press only
        // works on the icon pixel itself.
        behavior: HitTestBehavior.translucent,
        onLongPress: onLongPress,
        child: button,
      );
    }
    return button;
  }
}
