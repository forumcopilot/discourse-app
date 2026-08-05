import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Shared helper for the project's three canonical snackbar styles —
/// error / info / success. Use these instead of building `SnackBar`
/// instances inline so the floating behaviour, margins, and theme
/// colours stay consistent across every screen.
///
/// All variants:
///   * `behavior: SnackBarBehavior.floating`
///   * `margin: EdgeInsets.all(DesignTokens.spacingS)`
///   * `bodyMedium` text style with role-appropriate `onX` colour
///
/// The optional [action] / [duration] arguments cover the few cases
/// where call-sites want to attach an "Undo" / "Retry" button or
/// extend the visibility window beyond the default 4s.
class SnackbarHelper {
  SnackbarHelper._();

  /// Surface a recoverable failure. Uses `colorScheme.errorContainer`
  /// — the same Material 3 role the inline error snackbars currently
  /// use throughout the attachment + compose flows.
  static void showError(
    BuildContext context,
    String message, {
    SnackBarAction? action,
    Duration? duration,
  }) =>
      _show(
        context,
        message,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
        action: action,
        duration: duration,
      );

  /// Surface a neutral informational message. Uses
  /// `colorScheme.surfaceVariant` to sit unobtrusively above the
  /// surface without competing with primary content.
  static void showInfo(
    BuildContext context,
    String message, {
    SnackBarAction? action,
    Duration? duration,
  }) =>
      _show(
        context,
        message,
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        action: action,
        duration: duration,
      );

  /// Surface a positive confirmation (e.g. "Saved", "Posted"). Uses
  /// `colorScheme.tertiaryContainer` so success reads visually
  /// distinct from both errors (errorContainer) and neutral info
  /// (surfaceVariant) on Material 3 themes.
  static void showSuccess(
    BuildContext context,
    String message, {
    SnackBarAction? action,
    Duration? duration,
  }) =>
      _show(
        context,
        message,
        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
        action: action,
        duration: duration,
      );

  static void _show(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required Color foregroundColor,
    SnackBarAction? action,
    Duration? duration,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: foregroundColor),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(DesignTokens.spacingS),
        action: action,
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }
}
