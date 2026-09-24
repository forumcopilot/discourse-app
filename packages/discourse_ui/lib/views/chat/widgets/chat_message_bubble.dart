import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_message.dart';

import '../../../theme/design_tokens.dart';
import '../../../utils/time_utils.dart';
import '../../user_profile_page.dart';
import '../../widgets/rich_text_content.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/full_screen_image_viewer.dart';
import '../../listitems/post_list_item_attachment.dart';
import 'package:discourse_core/discourse_core.dart' show DiscourseChatUploads;
import 'package:forumcopilot_sdk/models/entities/fc_attachment.dart';
import 'chat_reaction_chips.dart';
import '../../../l10n/generated/app_localizations.dart';

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
    this.onToggleReaction,
  });

  final FCChatMessage message;
  final SiteContext siteContext;
  final bool isSelf;
  final VoidCallback? onLongPress;

  /// Toggles the current user's emoji reaction on this message; null
  /// hides the reaction chips' tap affordance (guests). Resolves false
  /// on failure so the chips can revert their optimistic state.
  final Future<bool> Function(String emoji, {required bool add})?
      onToggleReaction;

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
    final uploads =
        DiscourseChatUploads.forMessage(siteContext.site.url, message.id);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final bubbleColor =
        isSelf ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest;
    final textColor = isSelf ? colorScheme.onPrimaryContainer : colorScheme.onSurface;
    final mutedTextColor = textColor.withValues(alpha: 0.7);

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
                    // post (its files come separately, below), so we pipe
                    // it through the same flutter_html renderer for
                    // mentions + emoji + oneboxes. A message may be files
                    // alone, with no text to draw.
                    if (message.cooked.trim().isNotEmpty ||
                        message.message.trim().isNotEmpty)
                      DefaultTextStyle(
                        style: textTheme.bodyMedium
                                ?.copyWith(color: textColor) ??
                            TextStyle(color: textColor),
                        child: RichTextContent(
                          siteContext: siteContext,
                          // Chat stays at its denser size; 16 is for posts.
                          baseFontSize: 14,
                          content: message.cooked.isNotEmpty
                              ? message.cooked
                              : message.message,
                        ),
                      ),
                    // Images and files travel in the message's `uploads`,
                    // not its cooked HTML; an upload-only message used to be
                    // an empty bubble. Same widget as a topic post's.
                    if (uploads.isNotEmpty)
                      PostListItemAttachment(
                        attachments: uploads,
                        actions: _ChatUploadActions(uploads),
                        context: context,
                        isInline: true,
                      ),
                    // Reaction chips — fed straight from the message's
                    // own reactions list, refreshed whenever the poll
                    // cycle re-parses this message (the parent Obx
                    // rebuilds us on every tick via messages.refresh()).
                    ChatReactionChips(
                      reactions: message.reactions,
                      onToggle: onToggleReaction,
                    ),
                    const SizedBox(height: DesignTokens.spacingXS),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.edited) ...[
                          Text(
                            AppLocalizations.of(context)!.edited,
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

/// Opens a chat message's images full screen, as a gallery.
class _ChatUploadActions {
  _ChatUploadActions(this.uploads);

  final List<FCAttachment> uploads;

  void onShowImage(String imageUrl, BuildContext context, String heroTag) {
    final images = uploads.where((u) => u.isImage).toList();
    if (images.isEmpty) return;
    final index = images.indexWhere(
        (u) => u.url == imageUrl || u.thumbnailUrl == imageUrl || u.id == heroTag);
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => FullScreenImageViewer(
        imageUrls: [for (final u in images) u.url],
        initialIndex: index < 0 ? 0 : index,
        heroTag: heroTag,
      ),
    ));
  }

  // Chat is only reachable signed in.
  void onLoginRequired(BuildContext context) {}
}
