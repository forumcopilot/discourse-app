import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_message.dart';

import '../../../theme/design_tokens.dart';
import '../../../utils/time_utils.dart';
import '../../user_profile_page.dart';
import '../../widgets/rich_text_content.dart';
import '../../widgets/user_avatar.dart';

/// One chat message bubble — left-aligned for others, right-aligned for
/// self. Ported from the qhtt xenforoapp's Siropu bubble; the rendering
/// shape (avatar + bubble + author + timestamp + edited indicator) maps
/// 1:1 to Discourse Chat.
///
/// Renders the message's `cooked` HTML via RichTextContent so mentions,
/// emoji, oneboxes, and code blocks all look right.
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.siteContext,
    required this.isSelf,
    this.onLongPress,
  });

  final FCChatMessage message;
  final SiteContext siteContext;
  final bool isSelf;
  final VoidCallback? onLongPress;

  void _openProfile(BuildContext context) {
    if (message.authorUsername.isEmpty || message.authorId == 0) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => UserProfilePage(
        siteContext: siteContext,
        userId: message.authorId.toString(),
        userName: message.authorUsername,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final bubbleColor =
        isSelf ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest;
    final textColor = isSelf ? colorScheme.onPrimaryContainer : colorScheme.onSurface;
    final mutedTextColor = textColor.withOpacity(0.7);

    final avatarUrl = message.authorAvatarUrl;
    final avatar = UserAvatar(
      username: message.authorUsername,
      iconUrl: avatarUrl?.isEmpty ?? true ? null : avatarUrl,
      radius: 16,
      onTap: () => _openProfile(context),
    );

    final timeLabel = formatSmartDateTime(message.createdAt, context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingM,
        vertical: DesignTokens.spacingXS,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isSelf) avatar,
          if (!isSelf) const SizedBox(width: DesignTokens.spacingS),
          Flexible(
            child: GestureDetector(
              onLongPress: onLongPress,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingM,
                  vertical: DesignTokens.spacingS,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isSelf) ...[
                      Text(
                        message.authorUsername,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    // Chat cooked content is much smaller than a topic
                    // post (no images / attachments expected in v1), so
                    // we pipe it through the same flutter_html renderer
                    // for mentions + emoji + oneboxes.
                    DefaultTextStyle(
                      style: textTheme.bodyMedium
                              ?.copyWith(color: textColor) ??
                          TextStyle(color: textColor),
                      child: RichTextContent(
                        siteContext: siteContext,
                        content: message.cooked.isNotEmpty
                            ? message.cooked
                            : message.message,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacingXS),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.edited) ...[
                          Text(
                            'edited',
                            style: textTheme.labelSmall?.copyWith(
                              color: mutedTextColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(width: DesignTokens.spacingS),
                        ],
                        Text(
                          timeLabel,
                          style:
                              textTheme.labelSmall?.copyWith(color: mutedTextColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isSelf) const SizedBox(width: DesignTokens.spacingS),
          if (isSelf) avatar,
        ],
      ),
    );
  }
}
