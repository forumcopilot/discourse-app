import 'package:discourse_core/discourse_core.dart'
    show DiscourseMessageGroup, DiscoursePrivateConversationProxy;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/models/results/fc_private_conversation_result.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../utils/avatar_cache_utils.dart';
import '../../utils/error_message.dart';
import '../user_profile_page.dart';
import '../user_search_page.dart';
import '../widgets/sheet_title.dart';
import '../widgets/user_avatar.dart';

/// Who is on a private message — its groups first, as Discourse lists them,
/// then its people — with Invite when the viewer may add someone.
class MessageParticipantsSheet {
  MessageParticipantsSheet._();

  static void show(
    BuildContext context,
    List<FCParticipant> participants,
    SiteContext siteContext, {
    bool canInvite = false,
    String? conversationId,
    VoidCallback? onInviteSuccess,
    List<DiscourseMessageGroup> groups = const [],
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheet) {
        final l10n = AppLocalizations.of(sheet)!;
        final colorScheme = Theme.of(sheet).colorScheme;
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetTitle(
                l10n.participantsLabel,
                trailing: canInvite && conversationId != null
                    ? TextButton.icon(
                        icon: const Icon(Icons.person_add_outlined),
                        label: Text(l10n.invite),
                        onPressed: () => _invite(sheet, participants,
                            siteContext, conversationId, onInviteSuccess),
                      )
                    : null,
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    for (final group in groups)
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.secondaryContainer,
                          child: Icon(Icons.groups_rounded,
                              color: colorScheme.onSecondaryContainer),
                        ),
                        title: Text(group.label),
                        subtitle: group.label != group.name
                            ? Text('@${group.name}')
                            : null,
                      ),
                    for (final p in participants)
                      ListTile(
                        leading: UserAvatar(
                          username: p.username,
                          iconUrl: p.iconUrl,
                          radius: 20,
                          cacheKey: (p.iconUrl ?? '').isNotEmpty
                              ? AvatarCacheUtils.generateAvatarCacheKey(
                                  userId: p.userId,
                                  username: p.username,
                                  avatarUrl: p.iconUrl!,
                                )
                              : null,
                        ),
                        title: Text(p.username),
                        onTap: () {
                          Navigator.pop(sheet);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserProfilePage(
                                siteContext: siteContext,
                                userId: p.userId,
                                userName: p.username,
                                profilePictureUrl: p.iconUrl,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _invite(
    BuildContext context,
    List<FCParticipant> participants,
    SiteContext siteContext,
    String conversationId,
    VoidCallback? onInviteSuccess,
  ) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => UserSearchPage(
          siteContext: siteContext,
          selectedUsers: participants.map((p) => p.username).toList(),
          onUserSelected: (_, __) {},
        ),
      ),
    );
    final username = result?['username'] as String?;
    if (username == null || !context.mounted) return;
    // A group from the search is invited as a group; Discourse's user invite
    // cannot resolve a group name.
    final isGroup = result?['isGroup'] == true;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final proxy = SiteProxyFactory.getPrivateConversationProxy();
      final r = isGroup && proxy is DiscoursePrivateConversationProxy
          ? await proxy.inviteGroupAsync(conversationId, username)
          : await proxy.inviteParticipantAsync([username], conversationId, null);
      if (!context.mounted) return;
      Navigator.pop(context); // the progress dialog
      if (r.result) {
        Navigator.pop(context); // the sheet
        messenger.showSnackBar(SnackBar(
          content: Text(isGroup
              ? l10n.groupHasBeenInvited(username)
              : l10n.usernameHasBeenInvited(username)),
        ));
        onInviteSuccess?.call();
      } else {
        messenger.showSnackBar(SnackBar(
          content: Text(r.resultText ?? l10n.errorInvitingUser('')),
          backgroundColor: colorScheme.error,
        ));
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // the progress dialog
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.errorInvitingUser(describeError(e))),
        backgroundColor: colorScheme.error,
      ));
    }
  }
}
