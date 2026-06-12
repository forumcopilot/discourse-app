import 'package:flutter/material.dart';
import 'package:forumcopilot_flutter/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/models/entities/fc_badge.dart';

import '../../theme/design_tokens.dart';

/// Horizontal scrolling row of Discourse badge chips, sized to slot
/// under the trust-level chip on the user profile page.
class UserBadgesRow extends StatefulWidget {
  final String username;
  final int maxToShow;

  const UserBadgesRow({
    super.key,
    required this.username,
    this.maxToShow = 12,
  });

  @override
  State<UserBadgesRow> createState() => _UserBadgesRowState();
}

class _UserBadgesRowState extends State<UserBadgesRow> {
  List<FCBadge>? _badges;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant UserBadgesRow oldWidget) {
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
    final textTheme = Theme.of(context).textTheme;
    final badges = _badges;

    if (_loading && badges == null) {
      // Avoid flashing height during initial load.
      return const SizedBox.shrink();
    }
    if (badges == null || badges.isEmpty) return const SizedBox.shrink();

    final visible = badges.take(widget.maxToShow).toList();
    final remaining = badges.length - visible.length;

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingL),
        itemCount: visible.length + (remaining > 0 ? 1 : 0),
        separatorBuilder: (_, __) =>
            const SizedBox(width: DesignTokens.spacingS),
        itemBuilder: (context, index) {
          if (index == visible.length && remaining > 0) {
            return ActionChip(
              label: Text('+$remaining more'),
              onPressed: () => _showAll(context),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }
          final b = visible[index];
          final bg = _bgFor(b.tier, colorScheme);
          final fg = _fgFor(b.tier);
          return Tooltip(
            message: b.description ?? b.name,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingS, vertical: 4),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: fg.withValues(alpha: 0.4), width: 0.6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.workspace_premium,
                    size: 14,
                    color: fg,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    b.name,
                    style: textTheme.labelSmall?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (b.grantCount > 1) ...[
                    const SizedBox(width: 3),
                    Text(
                      '×${b.grantCount}',
                      style: textTheme.labelSmall?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
