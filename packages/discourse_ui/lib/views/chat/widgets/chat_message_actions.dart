import 'package:discourse_core/discourse_core.dart' show stripHtmlToText;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_message.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/design_tokens.dart';
import '../../../utils/emoji_shortcodes.dart';
import '../../widgets/reaction_glyph.dart';
import 'chat_reaction_chips.dart' show kChatDefaultReactions;

/// What the reader chose in a chat message's long-press sheet.
sealed class ChatMessageChoice {
  const ChatMessageChoice();
}

class ChatReact extends ChatMessageChoice {
  const ChatReact(this.emoji);
  final String emoji;
}

class ChatMoreReactions extends ChatMessageChoice {
  const ChatMoreReactions();
}

enum ChatMessageAction { reply, thread, copyText, copyLink, edit, bookmark, pin, flag, delete }

class ChatMessageActionChoice extends ChatMessageChoice {
  const ChatMessageActionChoice(this.action);
  final ChatMessageAction action;
}

/// What the reader may do with a message, as the server allows it.
class ChatMessagePermissions {
  const ChatMessagePermissions({
    this.react = false,
    this.reply = false,
    this.thread = false,
    this.edit = false,
    this.delete = false,
    this.pin = false,
    this.flag = false,
    this.bookmark = false,
    this.pinned = false,
    this.bookmarked = false,
  });

  final bool react;
  final bool reply;
  final bool thread;
  final bool edit;
  final bool delete;
  final bool pin;
  final bool flag;
  final bool bookmark;
  final bool pinned;
  final bool bookmarked;
}

/// A chat message's long-press sheet, as Discourse's on a phone: the message,
/// a row of quick reactions with the full picker, bookmark and reply, then
/// the rest. It offered seven fixed reactions, Edit and Delete.
Future<ChatMessageChoice?> showChatMessageActions(
  BuildContext context, {
  required FCChatMessage message,
  required SiteContext siteContext,
  required ChatMessagePermissions can,
}) {
  // ignore: discarded_futures
  HapticFeedback.mediumImpact();
  return showModalBottomSheet<ChatMessageChoice>(
    context: context,
    showDragHandle: true,
    builder: (sheet) {
      final l10n = AppLocalizations.of(sheet)!;
      final colorScheme = Theme.of(sheet).colorScheme;
      final textTheme = Theme.of(sheet).textTheme;
      void pick(ChatMessageChoice c) => Navigator.pop(sheet, c);
      Widget tile(IconData icon, String label, ChatMessageAction action, {bool danger = false}) => ListTile(
            leading: Icon(icon, color: danger ? colorScheme.error : null),
            title: Text(label, style: danger ? TextStyle(color: colorScheme.error) : null),
            onTap: () => pick(ChatMessageActionChoice(action)),
          );
      final excerpt = withEmojiShortcodes(stripHtmlToText(message.cooked.isNotEmpty ? message.cooked : message.message)).trim();
      Widget quick({required Widget child, required String tooltip, required VoidCallback onTap}) => Tooltip(
            message: tooltip,
            child: Material(
              color: colorScheme.surfaceContainerHighest,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: SizedBox(width: 48, height: 48, child: Center(child: child)),
              ),
            ),
          );
      return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (excerpt.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(DesignTokens.spacingL, 0, DesignTokens.spacingL, DesignTokens.spacingM),
                  padding: const EdgeInsets.all(DesignTokens.spacingM),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                  ),
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(text: '${message.authorUsername}  ', style: const TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(text: excerpt),
                    ]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium,
                  ),
                ),
              if (can.react || can.bookmark || can.reply)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (can.react) ...[
                        for (final emoji in kChatDefaultReactions.take(3))
                          quick(
                            tooltip: ':$emoji:',
                            onTap: () => pick(ChatReact(emoji)),
                            child: ReactionGlyph(reactionId: emoji, size: 24, siteContext: siteContext),
                          ),
                        quick(
                          tooltip: l10n.chatReactWithEmoji,
                          onTap: () => pick(const ChatMoreReactions()),
                          child: const Icon(Icons.add_reaction_outlined),
                        ),
                      ],
                      if (can.bookmark)
                        quick(
                          tooltip: can.bookmarked ? l10n.removeBookmark : l10n.chatBookmark,
                          onTap: () => pick(const ChatMessageActionChoice(ChatMessageAction.bookmark)),
                          child: Icon(can.bookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: can.bookmarked ? colorScheme.primary : null),
                        ),
                      if (can.reply)
                        quick(
                          tooltip: l10n.reply,
                          onTap: () => pick(const ChatMessageActionChoice(ChatMessageAction.reply)),
                          child: const Icon(Icons.reply),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: DesignTokens.spacingS),
              const Divider(height: 1),
              if (can.thread) tile(Icons.forum_outlined, l10n.chatOpenThread, ChatMessageAction.thread),
              tile(Icons.copy, l10n.chatCopyText, ChatMessageAction.copyText),
              tile(Icons.link, l10n.copyLink, ChatMessageAction.copyLink),
              if (can.edit) tile(Icons.edit_outlined, l10n.edit, ChatMessageAction.edit),
              if (can.pin)
                tile(can.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                    can.pinned ? l10n.chatUnpinMessage : l10n.chatPinMessage, ChatMessageAction.pin),
              if (can.flag) tile(Icons.flag_outlined, l10n.chatFlag, ChatMessageAction.flag),
              if (can.delete) tile(Icons.delete_outline, l10n.delete, ChatMessageAction.delete, danger: true),
              const SizedBox(height: DesignTokens.spacingS),
            ],
          ),
        ),
      );
    },
  );
}
