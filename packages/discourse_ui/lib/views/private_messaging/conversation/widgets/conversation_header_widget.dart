import 'package:discourse_core/discourse_core.dart' show DiscourseMessageGroup;
import '../../../../l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/models/results/fc_private_conversation_result.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import '../../../../theme/design_tokens.dart';
import 'package:discourse_ui/views/widgets/user_avatar.dart';
import 'package:discourse_ui/utils/avatar_cache_utils.dart';
import '../appbars/conversation_app_bar.dart';
import 'dart:math' as math;

/// The message's header: its title, then the participants (overlapping
/// avatars and a count) opening the participants sheet.
class ConversationHeaderWidget extends StatelessWidget {
  final String title;
  final List<FCParticipant>? participants;
  final int participantCount;
  final SiteContext? siteContext;
  final bool canInvite;
  final String? conversationId;
  final VoidCallback? onInviteSuccess;

  /// Groups on the message; counted with the people and listed first in
  /// the participants sheet.
  final List<DiscourseMessageGroup> groups;

  const ConversationHeaderWidget({
    super.key,
    required this.title,
    this.participants,
    this.participantCount = 0,
    this.groups = const [],
    this.siteContext,
    this.canInvite = false,
    this.conversationId,
    this.onInviteSuccess,
  });

  /// Builds overlapping avatars widget
  Widget _buildOverlappingAvatars(BuildContext context, List<FCParticipant> participants, ColorScheme colorScheme) {
    if (participants.isEmpty) {
      return const SizedBox.shrink();
    }

    // 32dp, the size of the topic page's avatars.
    const avatarRadius = 16.0;
    final avatarSize = avatarRadius * 2;
    final overlapOffset = avatarSize * 0.5; // 50% overlap
    
    // Limit to first 5 participants for better visual appearance
    final avatarsToShow = math.min(5, participants.length);
    final totalWidth = avatarSize + (avatarsToShow - 1) * overlapOffset;

    return SizedBox(
      width: totalWidth,
      height: avatarSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Show avatars
          ...List.generate(avatarsToShow, (index) {
            final participant = participants[index];
            return Positioned(
              left: index * overlapOffset,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: UserAvatar(
                  username: participant.username,
                  iconUrl: participant.iconUrl,
                  radius: avatarRadius,
                  cacheKey: participant.iconUrl != null && participant.iconUrl!.isNotEmpty
                      ? AvatarCacheUtils.generateAvatarCacheKey(
                          userId: participant.userId,
                          username: participant.username,
                          avatarUrl: participant.iconUrl!,
                        )
                      : null,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final hasAvatars = participants != null && participants!.isNotEmpty;
    final canOpenSheet = hasAvatars && siteContext != null;

    // The topic page's header: the title on the left at titleLarge, then
    // who is in it. It was centred over a tinted pattern, 16sp w600 — the
    // only header in the app drawn that way.
    final people = Row(
      children: [
        if (hasAvatars) ...[
          _buildOverlappingAvatars(context, participants!, colorScheme),
          const SizedBox(width: DesignTokens.spacingM),
        ],
        if (participantCount > 0)
          Flexible(
            child: Text(
              l10n.participantCount(participantCount),
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (canOpenSheet) ...[
          const SizedBox(width: DesignTokens.spacingXS),
          Icon(
            Icons.chevron_right,
            size: DesignTokens.iconSizeS,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DesignTokens.spacingL,
          DesignTokens.spacingL,
          DesignTokens.spacingL,
          DesignTokens.spacingS,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title.isNotEmpty)
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            if (hasAvatars || participantCount > 0)
              // A 48dp target for the participants sheet, flush with the
              // title.
              InkWell(
                onTap: canOpenSheet
                    ? () => ConversationAppBar.showParticipantsBottomSheet(
                          context,
                          participants!,
                          siteContext!,
                          canInvite: canInvite,
                          conversationId: conversationId,
                          onInviteSuccess: onInviteSuccess,
                          groups: groups,
                        )
                    : null,
                borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: 1,
                    child: people,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
