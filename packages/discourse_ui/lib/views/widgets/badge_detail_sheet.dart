import 'package:flutter/material.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/models/entities/fc_badge.dart';

import '../../theme/design_tokens.dart';
import '../../utils/time_utils.dart';
import 'remote_circle_avatar.dart';

/// Opens the shared badge-detail bottom sheet for [badge].
///
/// Used by every badge surface (profile badges row, "+N more" sheet,
/// badges directory) so a badge tap behaves identically everywhere.
/// The sheet renders immediately from whatever [badge] carries and
/// enriches itself from the session-cached `/badges.json` catalog
/// (description fallback + forum-wide "Earned by N users" count).
Future<void> showBadgeDetailSheet(BuildContext context, FCBadge badge) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) => BadgeDetailSheet(badge: badge),
  );
}

/// Bottom-sheet body showing a single badge: tier-colored icon, name,
/// tier label, description, forum-wide grant count, and — for the
/// viewed user's earned instance — when (and how many times) it was
/// earned.
///
/// Degrades gracefully: when the catalog fetch fails and the badge
/// itself has no description, the sheet still shows icon + name.
class BadgeDetailSheet extends StatefulWidget {
  final FCBadge badge;

  const BadgeDetailSheet({super.key, required this.badge});

  /// Session cache of the `/badges.json` catalog, keyed by badge id.
  /// Populated on first successful fetch; failures are not cached so
  /// a later sheet open can retry.
  static Map<int, FCBadge>? _catalogCache;

  /// Bronze / Silver / Gold using Discourse-web's badge palette.
  /// Shared with the badges directory rows.
  static Color tierColor(FCBadgeTier tier) {
    switch (tier) {
      case FCBadgeTier.gold:
        return const Color(0xFFE5A839); // Discourse gold
      case FCBadgeTier.silver:
        return const Color(0xFFB0B0B0);
      case FCBadgeTier.bronze:
        return const Color(0xFFCD7F32);
    }
  }

  @override
  State<BadgeDetailSheet> createState() => _BadgeDetailSheetState();
}

class _BadgeDetailSheetState extends State<BadgeDetailSheet> {
  FCBadge? _catalogEntry;

  @override
  void initState() {
    super.initState();
    _loadCatalogEntry();
  }

  Future<void> _loadCatalogEntry() async {
    var catalog = BadgeDetailSheet._catalogCache;
    if (catalog == null) {
      try {
        final result =
            await SiteProxyService.getUserProxy().getAllBadgesAsync();
        if (result.result) {
          catalog = {for (final b in result.badges) b.id: b};
          BadgeDetailSheet._catalogCache = catalog;
        }
      } catch (_) {
        // Leave the cache empty — the sheet renders from the badge alone.
      }
    }
    if (!mounted || catalog == null) return;
    setState(() => _catalogEntry = catalog![widget.badge.id]);
  }

  static String _tierLabel(FCBadgeTier tier) {
    switch (tier) {
      case FCBadgeTier.gold:
        return 'Gold';
      case FCBadgeTier.silver:
        return 'Silver';
      case FCBadgeTier.bronze:
        return 'Bronze';
    }
  }

  static String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final badge = widget.badge;

    // Description: prefer what the badge instance carries, fall back to
    // the catalog definition. (Discourse's `long_description` is not
    // serialized on either endpoint, so `description` is all we have —
    // for system badges it already explains how the badge is granted,
    // e.g. "Granted the first time you...".)
    final description = (badge.description?.isNotEmpty == true)
        ? badge.description
        : _catalogEntry?.description;

    // Forum-wide grant count. Catalog rows carry it directly
    // (granted == false); earned instances get it from the catalog
    // lookup, since their own grantCount is the user's stack count.
    final totalGrants =
        badge.granted ? _catalogEntry?.grantCount : badge.grantCount;

    final earnedBits = <String>[
      if (badge.grantedAt != null)
        'Earned ${formatTimeAgo(badge.grantedAt!, context)}',
      if (badge.granted && badge.grantCount > 1) '×${badge.grantCount}',
    ];

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
                RemoteCircleAvatar(
                  radius: DesignTokens.avatarRadiusL,
                  backgroundColor: BadgeDetailSheet.tierColor(badge.tier),
                  imageUrl: badge.imageUrl,
                  fallback: const Icon(Icons.emoji_events_outlined,
                      color: Colors.white),
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
                          fontWeight: DesignTokens.fontWeightSemiBold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        totalGrants != null
                            ? '${_tierLabel(badge.tier)} · '
                                'Earned by ${_formatCount(totalGrants)} '
                                '${totalGrants == 1 ? 'user' : 'users'}'
                            : _tierLabel(badge.tier),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: DesignTokens.spacingL),
              Text(
                description,
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
            if (earnedBits.isNotEmpty) ...[
              const SizedBox(height: DesignTokens.spacingM),
              Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      size: DesignTokens.iconSizeS,
                      color: colorScheme.primary),
                  const SizedBox(width: DesignTokens.spacingXS),
                  Text(
                    earnedBits.join(' · '),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: DesignTokens.fontWeightSemiBold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
