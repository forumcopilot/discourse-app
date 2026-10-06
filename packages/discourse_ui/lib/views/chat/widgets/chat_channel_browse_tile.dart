import 'package:discourse_core/discourse_core.dart'
    show DiscourseChatChannelDetails;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_channel.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/design_tokens.dart';
import 'chat_channel_avatar.dart';

/// Whether the reader can join [channel], as the web decides
/// (chat-channel-preview-card: `isOpen && canJoin`; the browse card's
/// `isJoinable` is `isOpen && !isArchived`). A read-only, closed or
/// archived channel is not joined: Discourse lists only open channels in
/// the reader's chats (`/chat/api/me/channels`), so it would vanish from
/// both lists at once.
bool chatChannelJoinable(FCChatChannel channel) =>
    channel.isOpen && channel.canJoin;

/// A channel to browse, as the web's channel card: its picture, name,
/// description, member count and status, with Join, or Leave for one the
/// reader follows. A tap opens it.
class ChatChannelBrowseTile extends StatelessWidget {
  const ChatChannelBrowseTile({
    super.key,
    required this.channel,
    required this.siteContext,
    required this.onOpen,
    this.onJoin,
    this.onLeave,
    this.busy = false,
  });

  final FCChatChannel channel;
  final SiteContext siteContext;
  final VoidCallback onOpen;

  /// Offered when the reader does not follow [channel] and may join it.
  final VoidCallback? onJoin;

  /// Offered when the reader follows [channel], whatever its status, so a
  /// channel closed or archived since can still be left.
  final VoidCallback? onLeave;

  /// A join or leave is on its way.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final details =
        DiscourseChatChannelDetails.of(siteContext.site.url, channel.id);
    final members = details?.membershipsCount ?? 0;
    final Widget? action;
    if (busy) {
      action = const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2));
    } else if (channel.isFollowing && onLeave != null) {
      action = OutlinedButton(onPressed: onLeave, child: Text(l10n.chatLeave));
    } else if (!channel.isFollowing &&
        onJoin != null &&
        chatChannelJoinable(channel)) {
      action =
          FilledButton.tonal(onPressed: onJoin, child: Text(l10n.chatJoin));
    } else {
      action = null;
    }
    final status = channel.isOpen
        ? null
        : channel.isArchived
            ? l10n.chatFilterArchived
            : channel.isClosed
                ? l10n.chatFilterClosed
                : l10n.chatPlaceholderReadOnly;
    return LayoutBuilder(builder: (context, constraints) {
      // Large text on a phone: the button goes under the name, not beside.
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final stacked = action != null && constraints.maxWidth / scale < 320;
      return ListTile(
        key: ValueKey('available-channel-${channel.id}'),
        onTap: onOpen,
        leading: ChatChannelAvatar(
            channel: channel, details: details, siteContext: siteContext),
        title:
            Text(channel.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (channel.description?.isNotEmpty == true)
                Text(channel.description!,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              // As the web's card: no count for a channel nobody is in.
              if (members > 0) Text(l10n.chatMembersCount(members)),
              if (status != null) Text(status),
              if (stacked)
                Padding(
                  padding: const EdgeInsets.only(top: DesignTokens.spacingS),
                  child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: action),
                ),
            ]),
        trailing: stacked ? null : action,
      );
    });
  }
}
