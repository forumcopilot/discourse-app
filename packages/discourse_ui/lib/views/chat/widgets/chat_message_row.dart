import 'package:discourse_core/discourse_core.dart'
    show DiscourseChatMessageExtras, DiscourseChatReplyTo, DiscourseChatUploads, stripHtmlToText;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_message.dart';
import 'package:intl/intl.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/design_tokens.dart';
import '../../../utils/emoji_shortcodes.dart';
import '../../profile/user_card_sheet.dart';
import '../../widgets/post_body_extensions.dart' show kPostBlockGap;
import '../../widgets/rich_text_content.dart';
import '../../widgets/user_avatar.dart';
import 'chat_reaction_chips.dart';
import 'chat_uploads.dart';

/// How long after a person's message their next one still belongs to the
/// same run, without its own avatar and name: Discourse's 5 minutes.
const Duration kChatGroupWindow = Duration(minutes: 5);

/// Whether [message] continues [previous]'s run: same person, within
/// [kChatGroupWindow], the same day, and not a reply to anything but the
/// message just before it (Discourse's grouping rule).
bool chatMessageContinuesRun(FCChatMessage? previous, FCChatMessage message,
    {DiscourseChatReplyTo? replyTo}) {
  if (previous == null || previous.deleted) return false;
  if (previous.authorId != message.authorId) return false;
  final a = previous.createdAt.toLocal();
  final b = message.createdAt.toLocal();
  if (a.year != b.year || a.month != b.month || a.day != b.day) return false;
  if (b.difference(a) > kChatGroupWindow) return false;
  if (replyTo != null && replyTo.messageId != previous.id) return false;
  return true;
}

/// One chat message, laid out as Discourse's chat on a phone: no bubbles,
/// an avatar column, and the name and time only on the first message of a
/// person's run ([showHeader]). It replaced a bubble per message, each with
/// its own avatar, name and "3 days ago", left or right — three short lines
/// from one person were three boxes.
///
/// A reply shows what it answers above it ([onReplyTap] jumps there);
/// [footer] carries what follows the message (a thread's summary).
class ChatMessageRow extends StatelessWidget {
  const ChatMessageRow({
    super.key,
    required this.message,
    required this.siteContext,
    required this.showHeader,
    this.highlighted = false,
    this.onLongPress,
    this.onToggleReaction,
    this.onReplyTap,
    this.footer,
    this.showReplyTo = true,
  });

  final FCChatMessage message;
  final SiteContext siteContext;
  final bool showHeader;
  final bool highlighted;
  final VoidCallback? onLongPress;
  final Future<bool> Function(String emoji, {required bool add})? onToggleReaction;
  final void Function(int messageId)? onReplyTap;
  final Widget? footer;

  /// Show what a reply answers above it (not inside a thread, nor for a
  /// reply to the message just above).
  final bool showReplyTo;

  static const double avatarSize = 40;

  void _openProfile(BuildContext context, String username) {
    if (username.isEmpty) return;
    showUserCard(context, siteContext: siteContext, username: username);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final site = siteContext.site.url;
    final extras = DiscourseChatMessageExtras.of(site, message.id);
    final uploads = DiscourseChatUploads.forMessage(site, message.id);
    final hasText = message.cooked.trim().isNotEmpty || message.message.trim().isNotEmpty;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final use24 = MediaQuery.maybeAlwaysUse24HourFormatOf(context) ?? false;
    final time = (use24 ? DateFormat.Hm(locale) : DateFormat.jm(locale)).format(message.createdAt.toLocal());
    final muted = colorScheme.onSurfaceVariant;

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: GestureDetector(
            onTap: () => _openProfile(context, message.authorUsername),
            child: Text(
              message.authorUsername,
              style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (extras?.authorTitle != null) ...[
          const SizedBox(width: DesignTokens.spacingS),
          Flexible(
            child: Text(extras!.authorTitle!,
                style: textTheme.bodySmall?.copyWith(color: muted), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
        const SizedBox(width: DesignTokens.spacingS),
        Text(time, style: textTheme.bodySmall?.copyWith(color: muted)),
        if (message.edited) ...[
          const SizedBox(width: DesignTokens.spacingXS),
          Text('· ${l10n.edited}', style: textTheme.bodySmall?.copyWith(color: muted)),
        ],
        if (extras?.pinned == true) ...[
          const SizedBox(width: DesignTokens.spacingXS),
          Icon(Icons.push_pin_outlined, size: 14, color: muted),
        ],
        if (extras?.bookmarkId != null) ...[
          const SizedBox(width: DesignTokens.spacingXS),
          Icon(Icons.bookmark, size: 14, color: colorScheme.primary),
        ],
      ],
    );

    final reply = extras?.replyTo;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showHeader) header,
        if (reply != null && showReplyTo) _ReplyPreview(reply: reply, onTap: onReplyTap),
        if (hasText)
          RichTextContent(
            siteContext: siteContext,
            textColor: colorScheme.onSurface,
            content: message.cooked.isNotEmpty ? message.cooked : message.message,
          ),
        // Images and files travel in the message's `uploads`, not its cooked
        // HTML; a message may be files alone.
        if (uploads.isNotEmpty) ...[
          if (hasText) const SizedBox(height: kPostBlockGap / 2),
          ChatUploads(uploads: uploads, siteContext: siteContext, messageId: message.id),
        ],
        if (message.edited && !showHeader)
          Text(l10n.edited, style: textTheme.bodySmall?.copyWith(color: muted)),
        if (message.reactions.isNotEmpty)
          ChatReactionChips(
            reactions: message.reactions,
            onToggle: onToggleReaction,
            siteContext: siteContext,
          ),
        if (footer != null) footer!,
      ],
    );

    return Material(
      color: highlighted ? colorScheme.primaryContainer.withValues(alpha: 0.5) : Colors.transparent,
      child: InkWell(
        onLongPress: onLongPress,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            DesignTokens.spacingL,
            showHeader ? DesignTokens.spacingS + 2 : 1,
            DesignTokens.spacingL,
            1,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: avatarSize,
                child: showHeader
                    ? UserAvatar(
                        username: message.authorUsername,
                        iconUrl: message.authorAvatarUrl?.isEmpty ?? true ? null : message.authorAvatarUrl,
                        radius: avatarSize / 2,
                        onTap: () => _openProfile(context, message.authorUsername),
                      )
                    : null,
              ),
              const SizedBox(width: DesignTokens.spacingM),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

/// The message a reply answers, above the reply: a reply arrow, the
/// author's small avatar and the start of their message. A tap goes to it.
class _ReplyPreview extends StatelessWidget {
  const _ReplyPreview({required this.reply, this.onTap});

  final DiscourseChatReplyTo reply;
  final void Function(int messageId)? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final user = reply.user;
    final excerpt = withEmojiShortcodes(stripHtmlToText(reply.excerpt ?? '')).trim();
    return Semantics(
      label: '${l10n.chatInReplyTo} ${user?.username ?? ''}: $excerpt',
      button: onTap != null,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(reply.messageId),
        borderRadius: BorderRadius.circular(DesignTokens.radiusS),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Icon(Icons.reply, size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: DesignTokens.spacingXS),
              if (user != null) ...[
                UserAvatar(username: user.username, iconUrl: user.avatarUrl, radius: 9),
                const SizedBox(width: DesignTokens.spacingXS),
              ],
              Expanded(
                child: Text(
                  excerpt,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
