import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';
import 'remote_circle_avatar.dart';

/// One user in a list — the directory, search results, or a recipient picker.
///
/// One row for every such screen, so the same person looks the same in each.
/// It degrades by field rather than by caller: [nameBadge] and [statLabel] are
/// optional, so a source that cannot supply them renders the same row without
/// them, rather than fetching the missing pieces with one request per row.
class UserRow extends StatelessWidget {
  final String username;

  /// Human name or group label shown beneath the handle, when the source has one.
  final String? subtitle;

  final String? avatarUrl;

  /// A small badge after the name, such as a platform's trust level or role.
  final Widget? nameBadge;

  /// Trailing stat, e.g. "1.2k" likes. Needs [statIcon] to render.
  final String? statLabel;
  final IconData? statIcon;

  /// Shown instead of an avatar image — used for groups, which have no avatar.
  final IconData? leadingIcon;

  final VoidCallback? onTap;

  /// Trailing control for pickers (a checkbox, an add button).
  final Widget? trailing;

  const UserRow({
    super.key,
    required this.username,
    this.subtitle,
    this.avatarUrl,
    this.nameBadge,
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
              size: DesignTokens.iconSizeS, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: DesignTokens.spacingXS),
          Text(
            statLabel!,
            style: textTheme.labelMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
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
              style: textTheme.titleMedium
                  ?.copyWith(color: colorScheme.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (nameBadge != null) ...[
            const SizedBox(width: DesignTokens.spacingS),
            nameBadge!,
          ],
        ],
      ),
      subtitle: subtitle != null && subtitle!.isNotEmpty
          ? Text(
              subtitle!,
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: trailingWidget,
    );
  }
}
