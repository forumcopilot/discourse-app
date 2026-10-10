import 'dart:math' as math;

import 'package:discourse_core/discourse_core.dart' show DiscourseMessageDetails;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/results/fc_private_conversation_result.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';
import '../../utils/avatar_cache_utils.dart';
import '../widgets/user_avatar.dart';
import 'message_participants_sheet.dart';
import '../../l10n/kit_strings.dart';

/// Who is on a private message, under its title where a topic shows its
/// category and tags: overlapping avatars and "N participants", a 48dp
/// target that opens the participants sheet (with Invite, when allowed).
class MessageParticipantsRow extends StatelessWidget {
  const MessageParticipantsRow({
    super.key,
    required this.siteContext,
    required this.topicId,
    required this.details,
    this.onChanged,
    this.padding = EdgeInsets.zero,
  });

  final SiteContext siteContext;
  final String topicId;
  final DiscourseMessageDetails details;

  /// After someone is invited, to reload the message.
  final VoidCallback? onChanged;

  final EdgeInsets padding;

  static const double _avatarRadius = 16; // 32dp, the page's avatar size

  Widget _avatars(List<FCParticipant> people, ColorScheme colorScheme) {
    const size = _avatarRadius * 2;
    const step = size * 0.5;
    final shown = math.min(5, people.length);
    return SizedBox(
      width: size + (shown - 1) * step,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < shown; i++)
            Positioned(
              left: i * step,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.surface, width: 2),
                ),
                child: UserAvatar(
                  username: people[i].username,
                  iconUrl: people[i].iconUrl,
                  radius: _avatarRadius,
                  cacheKey: (people[i].iconUrl ?? '').isNotEmpty
                      ? AvatarCacheUtils.generateAvatarCacheKey(
                          userId: people[i].userId,
                          username: people[i].username,
                          avatarUrl: people[i].iconUrl!,
                        )
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final people = details.participants;
    final count = people.length + details.groups.length;
    if (count == 0) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: InkWell(
        onTap: () => MessageParticipantsSheet.show(
          context,
          people,
          siteContext,
          canInvite: details.canInvite,
          conversationId: topicId,
          onInviteSuccess: onChanged,
          groups: details.groups,
          canRemove: details.canRemoveParticipants,
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusS),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (people.isNotEmpty) ...[
                  _avatars(people, colorScheme),
                  const SizedBox(width: DesignTokens.spacingM),
                ],
                Flexible(
                  child: Text(
                    AppLocalizations.of(context)!.kit.participantCount(count),
                    style: textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingXS),
                Icon(
                  Icons.chevron_right,
                  size: DesignTokens.iconSizeS,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
