import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/models/results/fc_private_conversation_result.dart';
import 'package:discourse_ui/views/widgets/user_avatar.dart';
import '../../../../utils/time_utils.dart';
import '../../../../theme/design_tokens.dart';
import '../../../widgets/unread_badge.dart';

class ConversationListItem extends StatelessWidget {
  final FCConversationSummary conversation;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ConversationListItem({
    Key? key,
    required this.conversation,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Get the last reply person's profile picture and username
    String displayUsername = 'Unknown';
    String? displayAvatar;

    // Use the last user who posted in the conversation
    if (conversation.participants != null && conversation.participants!.isNotEmpty) {
      if (conversation.last_user_id != null) {
        try {
          final lastParticipant = conversation.participants!.firstWhere(
            (p) => p.userId == conversation.last_user_id,
          );
          displayUsername = lastParticipant.username;
          displayAvatar = lastParticipant.iconUrl;
        } catch (e) {
          // If last_user_id not found in participants, use first participant
          final firstParticipant = conversation.participants!.first;
          displayUsername = firstParticipant.username;
          displayAvatar = firstParticipant.iconUrl;
        }
      } else {
        // No last_user_id, use first participant
        final firstParticipant = conversation.participants!.first;
        displayUsername = firstParticipant.username;
        displayAvatar = firstParticipant.iconUrl;
      }
    }

    final hasNewPosts = conversation.new_post ?? false;
    final replyCount = int.parse(conversation.reply_count ?? '0');
    final totalMessages = replyCount + 1; // replies + first message
    final lastTime = DateTime.tryParse(
          conversation.last_conv_time ?? conversation.lastReplyTime ?? '',
        ) ??
        DateTime.now();

    final unreadCount = conversation.unreadMessageCount ?? 0;
    final metaColor = colorScheme.onSurfaceVariant;
    final metaStyle = textTheme.bodySmall?.copyWith(color: metaColor);
    Widget meta(IconData icon, String text) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: DesignTokens.iconSizeS, color: metaColor),
            const SizedBox(width: DesignTokens.spacingXS),
            Text(text, style: metaStyle),
          ],
        );

    // Like an inbox: the subject is the headline, with who wrote last and
    // how many are in it underneath, and the time and unread badge at the
    // end. It opened with the last poster's name in the same 16sp as the
    // subject, and took ~140dp a row.
    return Material(
      color: colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.spacingL,
                DesignTokens.spacingM,
                DesignTokens.spacingL,
                DesignTokens.spacingM,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(
                    username: displayUsername,
                    iconUrl: displayAvatar,
                    radius: DesignTokens.avatarRadiusM,
                  ),
                  const SizedBox(width: DesignTokens.spacingL),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversation.conv_subject ?? 'No subject',
                          style: textTheme.titleMedium?.copyWith(
                            color: hasNewPosts
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                            fontWeight: hasNewPosts
                                ? DesignTokens.fontWeightMedium
                                : DesignTokens.fontWeightNormal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: DesignTokens.spacingXS),
                        Wrap(
                          spacing: DesignTokens.spacingM,
                          runSpacing: DesignTokens.spacingXS,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              displayUsername.isNotEmpty
                                  ? displayUsername
                                  : 'Unknown',
                              style: metaStyle,
                            ),
                            if ((conversation.participant_count ?? 0) > 0)
                              meta(Icons.people_outline,
                                  '${conversation.participant_count}'),
                            if (totalMessages > 0)
                              meta(Icons.mail_outline, '$totalMessages'),
                            if (conversation.isClosed == true)
                              Icon(Icons.lock_outlined,
                                  size: DesignTokens.iconSizeS,
                                  color: metaColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spacingS),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(formatSmartDateTime(lastTime, context),
                          style: metaStyle),
                      if (hasNewPosts) ...[
                        const SizedBox(height: DesignTokens.spacingS),
                        UnreadBadge(count: unreadCount),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              indent: 72,
              color: colorScheme.outlineVariant,
            ),
          ],
        ),
      ),
    );
  }
}
