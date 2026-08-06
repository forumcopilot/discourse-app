import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

/// Phase 5.18d — shared "icon + message" column for empty / error
/// states. Was inlined in `UsersDirectoryPage`, `GroupsListPage`,
/// `BadgesDirectoryPage`, `DraftsListPage`, `NewTopicsList`,
/// `TopTopicsList` and a couple more — each with subtle differences
/// in spacing and icon sizing. Centralising it locks down the
/// recipe and makes empty states feel like the same widget across
/// the app, which they should.
///
/// Variants:
///   • [EmptyStateView] (small / centred) — drop into a `Center`
///     anywhere there's no content to show.
///   • [EmptyStateView.scrollable] — wraps the column in a
///     `ListView` so `RefreshIndicator` can still drive a pull-to-
///     refresh gesture even when the body is empty.
class EmptyStateView extends StatelessWidget {
  /// Decorative icon at the top of the column. Rendered at
  /// `iconSizeXXL` (48px) in the muted `onSurfaceVariant` tone.
  final IconData icon;

  /// Required primary message. Kept short — single sentence ideally.
  final String message;

  /// Optional secondary line (e.g. a hint about what action would
  /// populate this screen). Rendered smaller / dimmer than `message`.
  final String? hint;

  /// When true, embeds the column in a scrollable `ListView` so
  /// pull-to-refresh on an otherwise-empty screen still works.
  /// Use the named constructor for clarity in callers.
  final bool _scrollable;

  /// When true the state is a *failure*, not an absence: the icon takes the
  /// error tone and a Retry button is offered. Screens used to render both
  /// cases through the plain constructor with the same icon, so "the request
  /// failed" was indistinguishable from "you have none of these" — and there
  /// was no way to retry without leaving the screen.
  final bool _isError;

  /// Invoked by the Retry button. Only shown on the error variant.
  final VoidCallback? onRetry;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.message,
    this.hint,
  })  : _scrollable = false,
        _isError = false,
        onRetry = null;

  /// Failure state: distinct icon tone plus an optional Retry action.
  /// Pair with `describeError` so the message is human-readable.
  const EmptyStateView.error({
    super.key,
    required this.message,
    this.icon = Icons.error_outline,
    this.hint,
    this.onRetry,
    bool scrollable = false,
  })  : _scrollable = scrollable,
        _isError = true;

  /// Use this when the empty view sits inside a `RefreshIndicator`
  /// — the underlying scrollable lets the user pull-to-refresh even
  /// without any list rows.
  const EmptyStateView.scrollable({
    super.key,
    required this.icon,
    required this.message,
    this.hint,
  })  : _scrollable = true,
        _isError = false,
        onRetry = null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final column = Padding(
      padding: const EdgeInsets.all(DesignTokens.spacingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: DesignTokens.iconSizeXXL,
            color: _isError ? colorScheme.error : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: DesignTokens.spacingM),
          Text(
            message,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (hint != null) ...[
            const SizedBox(height: DesignTokens.spacingS),
            Text(
              hint!,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant
                    .withValues(alpha: DesignTokens.opacityHigh),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (_isError && onRetry != null) ...[
            const SizedBox(height: DesignTokens.spacingL),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: DesignTokens.iconSizeM),
              label: const Text('Try again'),
            ),
          ],
        ],
      ),
    );
    if (_scrollable) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // Push the column down a bit so it doesn't hug the AppBar.
          const SizedBox(height: DesignTokens.spacingXXL),
          column,
        ],
      );
    }
    return Center(child: column);
  }
}
