import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';
import 'trust_level_chip.dart';
import 'remote_circle_avatar.dart';

/// One user in a list — the directory, search results, or a recipient picker.
///
/// These screens each had their own row, so the user directory showed trust
/// levels and avatars while search results and the message/chat recipient
/// pickers showed a plainer XenForo-style row. Same person, three appearances.
///
/// Degrades by field rather than by caller: [trustLevel] and [statLabel] are
/// optional, so a source that cannot supply them renders the same row without
/// them. That matters because `/directory_items.json` carries trust level and
/// stats while `/u/search/users.json` returns only id/username/name/avatar —
/// fetching the missing pieces per result would mean one profile request per
/// row, which is exactly the fan-out that trips Discourse's rate limiter.
class UserListRow extends StatelessWidget {
  final String username;

  /// Human name or group label shown beneath the handle, when the source has one.
  final String? subtitle;

  final String? avatarUrl;

  /// Discourse trust level (0–4). Omitted when the source does not report it.
  final int? trustLevel;

  /// Trailing stat, e.g. "1.2k" likes. Needs [statIcon] to render.
  final String? statLabel;
  final IconData? statIcon;

  /// Shown instead of an avatar image — used for groups, which have no avatar.
  final IconData? leadingIcon;

  final VoidCallback? onTap;

  /// Trailing control for pickers (a checkbox, an add button).
  final Widget? trailing;

  const UserListRow({
    super.key,
    required this.username,
    this.subtitle,
    this.avatarUrl,
    this.trustLevel,
    this.statLabel,
    this.statIcon,
    this.leadingIcon,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    Widget? trailingWidget = trailing;
    if (trailingWidget == null && statLabel != null && statIcon != null) {
      trailingWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statIcon,
              size: DesignTokens.iconSizeXS, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: DesignTokens.spacingXS),
          Text(
            statLabel!,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: DesignTokens.fontWeightSemiBold,
            ),
          ),
        ],
      );
    }

    return ListTile(
      onTap: onTap,
      leading: RemoteCircleAvatar(
        radius: DesignTokens.avatarRadiusM,
        backgroundColor: colorScheme.surfaceContainerHighest,
        imageUrl: hasAvatar ? avatarUrl : null,
        fallback: Icon(leadingIcon ?? Icons.person,
            color: colorScheme.onSurfaceVariant),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              username,
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: DesignTokens.fontWeightSemiBold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trustLevel != null) ...[
            const SizedBox(width: DesignTokens.spacingS),
            TrustLevelChip(level: trustLevel!),
          ],
        ],
      ),
      subtitle: subtitle != null && subtitle!.isNotEmpty
          ? Text(
              subtitle!,
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: trailingWidget,
    );
  }
}
