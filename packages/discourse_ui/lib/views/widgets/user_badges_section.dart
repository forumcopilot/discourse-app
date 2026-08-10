import 'package:flutter/material.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/models/entities/fc_badge.dart';

import '../../theme/design_tokens.dart';
import 'badge_detail_sheet.dart';
import 'profile_section.dart';

/// The profile's Badges section.
///
/// Was a single-line horizontal strip wedged under the username, where
/// badges scrolled sideways behind a "+N more" chip — so most of a user's
/// badges were invisible, and the ones that showed competed with the name
/// for the top of the page. As its own full-width section it can simply
/// wrap: a user with nine badges sees nine badges.
///
/// Renders nothing — no heading, no break — when the user has none, so an
/// empty section never appears on a new account's profile.
class UserBadgesSection extends StatefulWidget {
  final String username;

  /// Cap before the overflow action. Generous because wrapping costs a
  /// row, not a scroll gesture; beyond this the sheet is the better view.
  final int maxToShow;

  const UserBadgesSection({
    super.key,
    required this.username,
    this.maxToShow = 18,
  });

  @override
  State<UserBadgesSection> createState() => _UserBadgesSectionState();
}

class _UserBadgesSectionState extends State<UserBadgesSection> {
  List<FCBadge>? _badges;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant UserBadgesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.username != widget.username) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final result = await SiteProxyService.getUserProxy()
          .getUserBadgesAsync(widget.username);
      if (!mounted) return;
      setState(() {
        _badges = result.result ? result.badges : const [];
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _badges = const [];
        _loading = false;
      });
    }
  }

  Color _bgFor(FCBadgeTier tier, ColorScheme colorScheme) {
    switch (tier) {
      case FCBadgeTier.gold:
        return const Color(0xFFFFC857).withValues(alpha: 0.18);
      case FCBadgeTier.silver:
        return const Color(0xFFC0C0C0).withValues(alpha: 0.18);
      case FCBadgeTier.bronze:
        return const Color(0xFFCD7F32).withValues(alpha: 0.18);
    }
  }

  Color _fgFor(FCBadgeTier tier) {
    switch (tier) {
      case FCBadgeTier.gold:
        return const Color(0xFFB78700);
      case FCBadgeTier.silver:
        return const Color(0xFF707070);
      case FCBadgeTier.bronze:
        return const Color(0xFF8B5A2B);
    }
  }

  void _showAll(BuildContext context) {
    final badges = _badges ?? const <FCBadge>[];
    if (badges.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return _AllBadgesSheet(
              badges: badges,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final badges = _badges;

    if (_loading && badges == null) {
      // Avoid flashing height during initial load.
      return const SizedBox.shrink();
    }
    if (badges == null || badges.isEmpty) return const SizedBox.shrink();

    final visible = badges.take(widget.maxToShow).toList();
    final remaining = badges.length - visible.length;

    return ProfileSection(
      title: 'Badges',
      contentPadding:
          const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL),
      child: Wrap(
        spacing: DesignTokens.spacingS,
        runSpacing: DesignTokens.spacingS,
        children: [
          for (final b in visible)
            _BadgeChip(
              badge: b,
              background: _bgFor(b.tier, colorScheme),
              foreground: _fgFor(b.tier),
              onTap: () => showBadgeDetailSheet(context, b),
            ),
          if (remaining > 0)
            ActionChip(
              label: Text('+$remaining more'),
              onPressed: () => _showAll(context),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
        ],
      ),
    );
  }
}

/// One badge. Tier colour carries the rank, the count suffix the repeats.
class _BadgeChip extends StatelessWidget {
  const _BadgeChip({
    required this.badge,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final FCBadge badge;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Tooltip(
      message: badge.description ?? badge.name,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        child: InkWell(
          borderRadius: BorderRadius.circular(DesignTokens.radiusL),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingM,
              vertical: DesignTokens.spacingS - 2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              border: Border.all(
                  color: foreground.withValues(alpha: 0.4), width: 0.6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium,
                    size: DesignTokens.iconSizeS, color: foreground),
                const SizedBox(width: DesignTokens.spacingXS),
                Text(
                  badge.name,
                  style: textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: DesignTokens.fontWeightSemiBold,
                  ),
                ),
                if (badge.grantCount > 1) ...[
                  const SizedBox(width: 3),
                  Text(
                    '×${badge.grantCount}',
                    style: textTheme.labelMedium?.copyWith(
                      color: foreground,
                      fontWeight: DesignTokens.fontWeightNormal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AllBadgesSheet extends StatelessWidget {
  final List<FCBadge> badges;
  final ScrollController scrollController;

  const _AllBadgesSheet({
    required this.badges,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Badges',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: DesignTokens.spacingM),
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              itemCount: badges.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final b = badges[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.workspace_premium),
                  title: Text(b.name),
                  subtitle:
                      b.description != null ? Text(b.description!) : null,
                  trailing: b.grantCount > 1 ? Text('×${b.grantCount}') : null,
                  onTap: () => showBadgeDetailSheet(context, b),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
