import 'package:discourse_core/discourse_core.dart'
    show DiscourseChatChannelDetails, DiscourseChatUser;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_channel.dart';

import '../../../utils/discourse_color.dart';
import '../../../utils/html_colors.dart';
import '../../widgets/reaction_glyph.dart';
import '../../widgets/user_avatar.dart';

/// The picture for a chat channel, as Discourse's chat list draws one:
/// the other person's avatar for a direct message, two members' avatars
/// overlapped for a group chat, and for a channel its emoji or a `#` on its
/// category's colour. It used to be a generic person, group or `#` icon for
/// every row, so a list of DMs was a column of identical grey circles.
class ChatChannelAvatar extends StatelessWidget {
  const ChatChannelAvatar({
    super.key,
    required this.channel,
    required this.details,
    required this.siteContext,
    this.size = 44,
  });

  final FCChatChannel channel;
  final DiscourseChatChannelDetails? details;
  final SiteContext siteContext;
  final double size;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final colorScheme = Theme.of(context).colorScheme;
    if (channel.chatableType == 'DirectMessage') {
      final members = d?.members ?? const <DiscourseChatUser>[];
      if (members.length >= 2) return _pair(context, members[0], members[1]);
      if (members.length == 1) {
        return UserAvatar(
          username: members.first.username,
          iconUrl: members.first.avatarUrl,
          radius: size / 2,
        );
      }
      return _icon(context, Icons.person_outline);
    }
    // A channel: its emoji on a tint of its category's colour, else a `#`
    // in that colour.
    final base = d?.color == null ? null : parseDiscourseHex(d!.color!);
    final surface = colorScheme.surface;
    final tint = base == null
        ? colorScheme.surfaceContainerHighest
        : Color.alphaBlend(base.withValues(alpha: 0.22), surface);
    final ink = base == null
        ? colorScheme.onSurfaceVariant
        : readableOn(base, tint, minContrast: 3);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: d?.emoji != null
          ? ReactionGlyph(
              reactionId: d!.emoji!, size: size * 0.5, siteContext: siteContext)
          : Text(
              '#',
              style: TextStyle(
                color: ink,
                fontSize: size * 0.45,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
    );
  }

  Widget _pair(BuildContext context, DiscourseChatUser a, DiscourseChatUser b) {
    final ring = Theme.of(context).colorScheme.surface;
    final small = size * 0.66;
    Widget one(DiscourseChatUser u) => Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ring, width: 2)),
          child: UserAvatar(
              username: u.username,
              iconUrl: u.avatarUrl,
              radius: small / 2 - 2),
        );
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(left: 0, top: 0, child: one(a)),
          Positioned(right: 0, bottom: 0, child: one(b)),
        ],
      ),
    );
  }

  Widget _icon(BuildContext context, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: colorScheme.surfaceContainerHighest,
      child: Icon(icon, color: colorScheme.onSurfaceVariant),
    );
  }
}
