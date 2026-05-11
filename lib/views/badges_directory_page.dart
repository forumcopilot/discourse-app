import 'package:discourse_core/discourse_core.dart';
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';

import '../theme/design_tokens.dart';

/// Phase 5.18c-3 — Badges directory, third drawer destination under
/// **Community**. Lists every visible badge on the forum, grouped
/// by tier (Gold / Silver / Bronze) and ranked by grant count within
/// each tier.
///
/// Tapping a badge opens a bottom sheet with the description + grant
/// count. We chose a sheet over a full detail page because the
/// per-badge "who has this" listing (`/user_badges.json?badge_id=...`)
/// is a meaningful additional API call that we'd rather defer until
/// a user actually wants it — and Discourse web doesn't show that
/// list inline either, just on a dedicated badge page.
class BadgesDirectoryPage extends StatefulWidget {
  final SiteContext siteContext;

  const BadgesDirectoryPage({super.key, required this.siteContext});

  @override
  State<BadgesDirectoryPage> createState() => _BadgesDirectoryPageState();
}

class _BadgesDirectoryPageState extends State<BadgesDirectoryPage> {
  List<DiscourseBadge> _badges = const [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final proxy = SiteProxyFactory.getUserProxy();
      if (proxy is! DiscourseUserProxy) {
        setState(() {
          _loading = false;
          _error = 'Badges require a Discourse forum.';
        });
        return;
      }
      final badges = await proxy.getAllBadgesAsync();
      if (!mounted) return;
      setState(() {
        _badges = badges;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 3,
        shadowColor: colorScheme.shadow.withOpacity(0.3),
        surfaceTintColor: colorScheme.surfaceTint,
        title: Text(
          'Badges',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (_loading && _badges.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_badges.isEmpty && _error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events_outlined,
                  size: 48, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: DesignTokens.spacingM),
              Text(
                _error!,
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    if (_badges.isEmpty) {
      return Center(
        child: Text(
          'No badges on this forum.',
          style: textTheme.bodyMedium
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      );
    }
    // Group by tier — gold/silver/bronze sections. Within each
    // section badges stay in the rank order returned by the proxy
    // (grant_count desc).
    final gold = _badges
        .where((b) => b.tier == DiscourseBadgeTier.gold)
        .toList(growable: false);
    final silver = _badges
        .where((b) => b.tier == DiscourseBadgeTier.silver)
        .toList(growable: false);
    final bronze = _badges
        .where((b) => b.tier == DiscourseBadgeTier.bronze)
        .toList(growable: false);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        children: [
          if (gold.isNotEmpty) _BadgeSection(label: 'Gold', badges: gold),
          if (silver.isNotEmpty)
            _BadgeSection(label: 'Silver', badges: silver),
          if (bronze.isNotEmpty)
            _BadgeSection(label: 'Bronze', badges: bronze),
        ],
      ),
    );
  }
}

class _BadgeSection extends StatelessWidget {
  final String label;
  final List<DiscourseBadge> badges;

  const _BadgeSection({required this.label, required this.badges});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            DesignTokens.spacingL,
            DesignTokens.spacingL,
            DesignTokens.spacingL,
            DesignTokens.spacingS,
          ),
          child: Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...badges.map((b) => _BadgeRow(badge: b)),
        const SizedBox(height: DesignTokens.spacingS),
      ],
    );
  }
}

class _BadgeRow extends StatelessWidget {
  final DiscourseBadge badge;
  const _BadgeRow({required this.badge});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      onTap: () => _showDetail(context),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: _tierColor(badge.tier),
        backgroundImage: (badge.imageUrl != null && badge.imageUrl!.isNotEmpty)
            ? NetworkImage(badge.imageUrl!)
            : null,
        child: (badge.imageUrl == null || badge.imageUrl!.isEmpty)
            ? const Icon(Icons.emoji_events_outlined,
                color: Colors.white, size: 18)
            : null,
      ),
      title: Text(
        badge.name,
        style: textTheme.titleSmall?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: badge.description != null && badge.description!.isNotEmpty
          ? Text(
              badge.description!,
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline,
              size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            _formatCount(badge.grantCount),
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final colorScheme = Theme.of(sheetContext).colorScheme;
        final textTheme = Theme.of(sheetContext).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.spacingL,
              0,
              DesignTokens.spacingL,
              DesignTokens.spacingL,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: _tierColor(badge.tier),
                      backgroundImage: (badge.imageUrl != null &&
                              badge.imageUrl!.isNotEmpty)
                          ? NetworkImage(badge.imageUrl!)
                          : null,
                      child: (badge.imageUrl == null ||
                              badge.imageUrl!.isEmpty)
                          ? const Icon(Icons.emoji_events_outlined,
                              color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: DesignTokens.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            badge.name,
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${badge.grantCount} granted',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (badge.description != null &&
                    badge.description!.isNotEmpty) ...[
                  const SizedBox(height: DesignTokens.spacingL),
                  Text(
                    badge.description!,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  static Color _tierColor(DiscourseBadgeTier tier) {
    // Bronze / Silver / Gold using Discourse-web's badge palette.
    switch (tier) {
      case DiscourseBadgeTier.gold:
        return const Color(0xFFE5A839); // Discourse gold
      case DiscourseBadgeTier.silver:
        return const Color(0xFFB0B0B0);
      case DiscourseBadgeTier.bronze:
        return const Color(0xFFCD7F32);
    }
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}
