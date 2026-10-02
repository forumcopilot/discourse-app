import 'package:discourse_core/discourse_core.dart' show DiscourseChatThreadPreview, stripHtmlToText;
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/design_tokens.dart';
import '../../../utils/chat_time.dart';
import '../../../utils/emoji_shortcodes.dart';
import '../../widgets/user_avatar.dart';

/// A thread's summary under the message that started it, as Discourse's
/// thread indicator: who took part, how many replies, when the last one
/// came, and its first words. A tap opens the thread. Replies in a thread
/// do not show in the channel, so without this they could not be found.
class ChatThreadIndicator extends StatelessWidget {
  const ChatThreadIndicator({super.key, required this.preview, required this.onTap});

  final DiscourseChatThreadPreview preview;
  final VoidCallback onTap;

  static const int _maxAvatars = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final muted = colorScheme.onSurfaceVariant;
    final people = preview.participants.take(_maxAvatars).toList();
    final others = preview.participantCount - people.length;
    final last = preview.lastReplyAt;
    final lastUser = preview.lastReplyUser;
    final excerpt = withEmojiShortcodes(stripHtmlToText(preview.lastReplyExcerpt ?? '')).trim();
    return Padding(
      padding: const EdgeInsets.only(top: DesignTokens.spacingXS),
      child: Material(
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingM, vertical: DesignTokens.spacingS),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (people.isNotEmpty) ...[
                      SizedBox(
                        width: 18.0 + (people.length - 1) * 13,
                        height: 20,
                        child: Stack(
                          children: [
                            for (var i = 0; i < people.length; i++)
                              Positioned(
                                left: i * 13.0,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: colorScheme.surfaceContainerLow, width: 1),
                                  ),
                                  child: UserAvatar(
                                      username: people[i].username, iconUrl: people[i].avatarUrl, radius: 9),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (others > 0) ...[
                        const SizedBox(width: 2),
                        Text('+$others', style: textTheme.labelSmall?.copyWith(color: muted)),
                      ],
                      const SizedBox(width: DesignTokens.spacingS),
                    ],
                    Flexible(
                      child: Text(
                        l10n.chatThreadReplies(preview.replyCount),
                        style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (last != null) ...[
                      const SizedBox(width: DesignTokens.spacingS),
                      Flexible(
                        child: Text(
                          '${l10n.chatLastReply} ${formatChatListTime(context, last)}',
                          style: textTheme.bodySmall?.copyWith(color: muted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                if (excerpt.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(children: [
                      if (lastUser != null)
                        TextSpan(text: '${lastUser.username}: ', style: const TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(text: excerpt),
                    ]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
