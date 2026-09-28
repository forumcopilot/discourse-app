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
import '../../utils/app_navigation.dart';

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
    bool canRemove = false,
  }) {
    // Anyone but yourself (that is Leave, in the message's menu), when the
    // viewer may take people off (`can_remove_allowed_users`), as the web's
    // "×" beside each name.
    final me = siteContext.currentUsername;
    bool removable(String username) =>
        canRemove && conversationId != null && username != me;
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
                        trailing: canRemove && conversationId != null
                            ? IconButton(
                                icon: const Icon(Icons.group_remove_outlined),
                                tooltip: l10n.remove,
                                onPressed: () => _remove(sheet, conversationId,
                                    group.name, group.label,
                                    isGroup: true, onRemoved: onInviteSuccess),
                              )
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
                        trailing: removable(p.username)
                            ? IconButton(
                                icon: const Icon(Icons.person_remove_outlined),
                                tooltip: l10n.remove,
                                onPressed: () => _remove(sheet,
                                    conversationId!, p.username, p.username,
                                    isGroup: false, onRemoved: onInviteSuccess),
                              )
                            : null,
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

  /// Takes [name] (a user or a group) off the message after asking, then
  /// closes the sheet and reloads the message.
  static Future<void> _remove(
    BuildContext sheet,
    String conversationId,
    String name,
    String label, {
    required bool isGroup,
    VoidCallback? onRemoved,
  }) async {
    final l10n = AppLocalizations.of(sheet)!;
    final confirmed = await showDialog<bool>(
      context: sheet,
      builder: (dialog) => AlertDialog(
        content: Text(l10n.removeFromMessageConfirm(label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
    if (confirmed != true || !sheet.mounted) return;
    final proxy = SiteProxyFactory.getPrivateConversationProxy();
    if (proxy is! DiscoursePrivateConversationProxy) return;
    final messenger = ScaffoldMessenger.of(sheet);
    final errorColor = Theme.of(sheet).colorScheme.error;
    final r = isGroup
        ? await proxy.removeGroupAsync(conversationId, name)
        : await proxy.removeParticipantAsync(conversationId, name);
    if (!sheet.mounted) return;
    if (!r.result) {
      messenger.showSnackBar(SnackBar(
        content: Text(r.resultText?.isNotEmpty == true
            ? r.resultText!
            : l10n.errorInvitingUser('')),
        backgroundColor: errorColor,
      ));
      return;
    }
    sheet.popOwnRoute();
    onRemoved?.call();
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

    // The spinner stays until the invite answers: Back does not dismiss it.
    // It could, and the two pops that follow then closed the sheet and the
    // message under it. Each pop below now closes only its own route.
    final navigator = Navigator.of(context);
    final progress = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
    void closeProgress() {
      if (progress.isActive) navigator.removeRoute(progress);
    }

    navigator.push(progress);
    try {
      final proxy = SiteProxyFactory.getPrivateConversationProxy();
      final r = isGroup && proxy is DiscoursePrivateConversationProxy
          ? await proxy.inviteGroupAsync(conversationId, username)
          : await proxy.inviteParticipantAsync([username], conversationId, null);
      closeProgress();
      if (!context.mounted) return;
      if (r.result) {
        context.popOwnRoute(); // the sheet
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
      closeProgress();
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.errorInvitingUser(describeError(e))),
        backgroundColor: colorScheme.error,
      ));
    }
  }
}
