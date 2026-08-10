import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';
import '../../utils/time_utils.dart';
import 'user_avatar.dart';

/// Who wrote the post a row points at — rendered only when that is someone
/// other than the profile being viewed.
class ActivityAttribution {
  const ActivityAttribution({required this.username, this.avatarUrl});

  final String username;
  final String? avatarUrl;
}

/// One row in the profile's Activity feed, for every tab.
///
/// The four tabs used to be served by two different widgets: Topics got a
/// compact title/excerpt/metadata row, while Replies, Likes and Solved got
/// a row roughly twice as tall, led by an avatar-and-username header.
///
/// That header is the reason they are unified here rather than merely
/// restyled. `/user_actions.json` returns the *post author* in `username`,
/// and who that is depends entirely on the filter: for Replies, Topics and
/// Solved it is the profile owner, so the header repeated the same name and
/// face down every row of their own profile; for Likes it is somebody else,
/// and naming them is the entire content of the row — "you liked *their*
/// post". So attribution is not a per-tab style choice, it is a property of
/// the individual row: show it when the author differs from the profile
/// owner, and never otherwise.
class ActivityRow extends StatelessWidget {
  const ActivityRow({
    super.key,
    required this.title,
    required this.onTap,
    this.excerpt,
    this.attribution,
    this.time,
    this.replyCount,
    this.viewCount,
    this.postNumber,
  });

  final String title;
  final VoidCallback onTap;
  final String? excerpt;

  /// Non-null only when the post's author is not the profile owner.
  final ActivityAttribution? attribution;

  final DateTime? time;
  final int? replyCount;
  final int? viewCount;

  /// The post's position in its topic (`post_number`). Shown as "#45",
  /// never behind a comment icon — it was previously rendered with
  /// `Icons.comment_outlined`, which read as a reply count. The action
  /// feeds carry no reply count at all (`reply_count` is null on every
  /// row), so there was nothing true for that icon to show.
  final int? postNumber;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final excerptText = excerpt?.trim();

    return Material(
      color: colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingL,
            vertical: DesignTokens.spacingM,
          ),
          // `stretch`, not `start`: under a parent Column that centres its
          // children (which is the default), a `start` column shrinks to its
          // widest child and the whole row drifts inward by half the
          // leftover width — so rows indented by different amounts depending
          // on how long their excerpt happened to be.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (attribution != null) ...[
                Row(
                  children: [
                    UserAvatar(
                      username: attribution!.username,
                      iconUrl: attribution!.avatarUrl?.isNotEmpty == true
                          ? attribution!.avatarUrl
                          : null,
                      radius: DesignTokens.avatarRadiusXS,
                    ),
                    SizedBox(width: DesignTokens.spacingS),
                    Expanded(
                      child: Text(
                        attribution!.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: DesignTokens.fontWeightSemiBold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: DesignTokens.spacingS),
              ],
              Text(
                title,
                textAlign: TextAlign.start,
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: DesignTokens.fontWeightSemiBold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (excerptText != null && excerptText.isNotEmpty) ...[
                SizedBox(height: DesignTokens.spacingXS),
                Text(
                  excerptText,
                  textAlign: TextAlign.start,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: DesignTokens.spacingS),
              _MetaRow(
                time: time,
                replyCount: replyCount,
                viewCount: viewCount,
                postNumber: postNumber,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The muted line under every row. Identical across tabs so the feeds read
/// as one component; each item drops out when its feed has no value for it
/// rather than showing a zero or a stand-in.
class _MetaRow extends StatelessWidget {
  const _MetaRow({
    this.time,
    this.replyCount,
    this.viewCount,
    this.postNumber,
  });

  final DateTime? time;
  final int? replyCount;
  final int? viewCount;
  final int? postNumber;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final style = textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    Widget item(IconData icon, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: DesignTokens.iconSizeS,
                color: colorScheme.onSurfaceVariant),
            SizedBox(width: DesignTokens.spacingXS),
            Text(label, style: style),
          ],
        );

    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    return Wrap(
      spacing: DesignTokens.spacingM,
      runSpacing: DesignTokens.spacingXS,
      children: [
        if (time != null && time!.toUtc() != epoch.toUtc())
          item(Icons.schedule, formatSmartDateTime(time!, context)),
        if (replyCount != null && replyCount! > 0)
          item(Icons.comment_outlined, replyCount!.toString()),
        if (viewCount != null && viewCount! > 0)
          item(Icons.visibility_outlined, viewCount!.toString()),
        // Post 1 is the topic's opening post; "#1" tells the reader
        // nothing they cannot see from the row being a topic.
        if (postNumber != null && postNumber! > 1)
          Text('#${postNumber!}', style: style),
      ],
    );
  }
}
