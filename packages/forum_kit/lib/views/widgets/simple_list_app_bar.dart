import 'package:flutter/material.dart';

/// Phase 5.18d — shared AppBar for the directory / detail pages that
/// don't have their own per-screen actions (Tags, Users, Groups,
/// Group detail, Badges, Drafts, Chat tab, etc.). Was previously
/// duplicated in 7+ files with the same recipe; this extraction
/// makes a future visual tweak (e.g. flatter shadow, different
/// surface tint) a one-line change.
///
/// Like every app bar in the app it takes its look from the theme's
/// `AppBarTheme`: a Material 3 small top app bar, title in `titleLarge`
/// aligned to the start, flat until content scrolls under it.
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
    return AppBar(
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
