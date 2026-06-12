import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

/// Phase 5.18d — shared AppBar for the directory / detail pages that
/// don't have their own per-screen actions (Tags, Users, Groups,
/// Group detail, Badges, Drafts, Chat tab, etc.). Was previously
/// duplicated in 7+ files with the same recipe; this extraction
/// makes a future visual tweak (e.g. flatter shadow, different
/// surface tint) a one-line change.
///
/// Matches the `TopicsTabAppBar` / `ForumsTabAppBar` cadence:
///   • surface bg + elevation 3 + `opacityLow` shadow + surface
///     tint (so light/dark theme transitions stay smooth)
///   • title in `titleLarge` on `onSurface`, medium weight, left-
///     aligned (matches Discourse web's mobile header alignment)
///   • `automaticallyImplyLeading: true` so the drawer hamburger
///     shows when hosted inside a Scaffold with a drawer, and a
///     back button shows when pushed as a route.
class SimpleListAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// The screen title (e.g. 'Tags', 'Users', 'Drafts').
  final String title;

  /// Optional trailing actions — kept as a flexible slot so screens
  /// that need a refresh button or filter icon don't have to clone
  /// the whole AppBar.
  final List<Widget>? actions;

  const SimpleListAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: DesignTokens.elevationHigh - 1, // matches existing 3.0
      shadowColor: colorScheme.shadow.withValues(alpha: DesignTokens.opacityLow),
      surfaceTintColor: colorScheme.surfaceTint,
      title: Text(
        title,
        style: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: DesignTokens.fontWeightMedium,
          fontSize: DesignTokens.fontSizeL,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: false,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
