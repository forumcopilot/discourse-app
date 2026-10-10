import 'package:flutter/material.dart';
import 'package:forum_kit/views/widgets/user_row.dart';

import 'trust_level_chip.dart';

/// One user in a list, as Discourse shows them: forum_kit's [UserRow] with the
/// user's trust level after the name.
///
/// `/directory_items.json` carries trust level and stats while
/// `/u/search/users.json` returns only id/username/name/avatar; both render
/// this row, without the fields their source lacks, rather than fetching them
/// with one profile request per row (the fan-out that trips Discourse's rate
/// limiter).
class UserListRow extends StatelessWidget {
  final String username;
  final String? subtitle;
  final String? avatarUrl;

  /// Discourse trust level (0–4). Omitted when the source does not report it.
  final int? trustLevel;

  final String? statLabel;
  final IconData? statIcon;
  final IconData? leadingIcon;
  final VoidCallback? onTap;
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
  Widget build(BuildContext context) => UserRow(
        username: username,
        subtitle: subtitle,
        avatarUrl: avatarUrl,
        nameBadge: trustLevel == null ? null : TrustLevelChip(level: trustLevel!),
        statLabel: statLabel,
        statIcon: statIcon,
        leadingIcon: leadingIcon,
        onTap: onTap,
        trailing: trailing,
      );
}
