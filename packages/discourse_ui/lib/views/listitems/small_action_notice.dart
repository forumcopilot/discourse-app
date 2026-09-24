import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';
import '../../utils/time_utils.dart';
import '../widgets/post_content_callbacks.dart';
import '../widgets/rich_text_content.dart';
import '../widgets/user_avatar.dart';

/// A post that records an action — the topic was closed, pinned, split,
/// someone was invited — as the web shows it: one line with the action's
/// icon, who did it and when ("🔒 Closed 3 days ago"), plus the note the
/// moderator added, if any. The app drew these as full posts with an
/// author and an empty body (4,076 posts on 643 forums in the audit).
///
/// The wording is Discourse's own (`action_codes`, core and
/// discourse-assign), in the reader's language.
class SmallActionNotice extends StatelessWidget {
  const SmallActionNotice({
    super.key,
    required this.post,
    required this.siteContext,
    this.callbacks,
    this.onAvatarTap,
  });

  final FCPost post;
  final SiteContext siteContext;
  final PostContentCallbacks? callbacks;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final code = post.actionCode!;
    final when = post.timestamp == null ? '' : formatSmartDateTime(post.timestamp!, context);
    final who = post.actionCodeWho == null ? '' : '@${post.actionCodeWho}';
    final l10n = AppLocalizations.of(context);
    final text = (l10n == null ? null : actionCodeText(l10n, code, when: when, who: who)) ?? when;
    final note = post.content.trim();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingL,
        vertical: DesignTokens.spacingM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(actionCodeIcon(code), size: 22, color: colorScheme.outline),
              const SizedBox(width: DesignTokens.spacingM),
              UserAvatar(
                username: post.authorName,
                iconUrl: post.authorIconUrl,
                radius: 12,
                onTap: onAvatarTap,
              ),
              const SizedBox(width: DesignTokens.spacingS),
              Expanded(
                child: Text(
                  text,
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          if (note.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: DesignTokens.spacingS),
              child: RichTextContent(
                siteContext: siteContext,
                content: note,
                callbacks: callbacks,
              ),
            ),
        ],
      ),
    );
  }
}

/// Discourse's wording for [code], or null for a code the app has no words
/// for (a plugin's own), which then shows just the date.
String? actionCodeText(AppLocalizations l, String code,
    {required String when, required String who}) {
  switch (code) {
    case 'topic_created':
      return l.actionCodeTopicCreated(when);
    case 'public_topic':
      return l.actionCodePublicTopic(when);
    case 'open_topic':
      return l.actionCodeOpenTopic(when);
    case 'private_topic':
      return l.actionCodePrivateTopic(when);
    case 'split_topic':
      return l.actionCodeSplitTopic(when);
    case 'invited_user':
      return l.actionCodeInvitedUser(who, when);
    case 'invited_group':
      return l.actionCodeInvitedGroup(who, when);
    case 'user_left':
      return l.actionCodeUserLeft(who, when);
    case 'removed_user':
      return l.actionCodeRemovedUser(who, when);
    case 'removed_group':
      return l.actionCodeRemovedGroup(who, when);
    case 'autobumped':
      return l.actionCodeAutobumped(when);
    case 'tags_changed':
      return l.actionCodeTagsChanged(when);
    case 'category_changed':
      return l.actionCodeCategoryChanged(when);
    case 'forwarded':
      return l.actionCodeForwarded;
    case 'autoclosed.enabled':
      return l.actionCodeAutoclosedEnabled(when);
    case 'autoclosed.disabled':
      return l.actionCodeAutoclosedDisabled(when);
    case 'closed.enabled':
      return l.actionCodeClosedEnabled(when);
    case 'closed.disabled':
      return l.actionCodeClosedDisabled(when);
    case 'archived.enabled':
      return l.actionCodeArchivedEnabled(when);
    case 'archived.disabled':
      return l.actionCodeArchivedDisabled(when);
    case 'pinned.enabled':
      return l.actionCodePinnedEnabled(when);
    case 'pinned.disabled':
      return l.actionCodePinnedDisabled(when);
    case 'pinned_globally.enabled':
      return l.actionCodePinnedGloballyEnabled(when);
    case 'pinned_globally.disabled':
      return l.actionCodePinnedGloballyDisabled(when);
    case 'visible.enabled':
      return l.actionCodeVisibleEnabled(when);
    case 'visible.disabled':
      return l.actionCodeVisibleDisabled(when);
    case 'banner.enabled':
      return l.actionCodeBannerEnabled(when);
    case 'banner.disabled':
      return l.actionCodeBannerDisabled(when);
    // discourse-assign; its "…to post" variants carry a link the notice
    // does not need.
    case 'assigned':
    case 'assigned_group':
    case 'assigned_to_post':
    case 'assigned_group_to_post':
      return l.actionCodeAssigned(who, when);
    case 'unassigned':
    case 'unassigned_group':
    case 'unassigned_from_post':
    case 'unassigned_group_from_post':
      return l.actionCodeUnassigned(who, when);
    case 'reassigned':
    case 'reassigned_group':
      return l.actionCodeReassigned(who, when);
  }
  return null;
}

/// The icon the web shows beside each action.
IconData actionCodeIcon(String code) {
  switch (code) {
    case 'closed.enabled':
    case 'autoclosed.enabled':
      return Icons.lock_outline;
    case 'closed.disabled':
    case 'autoclosed.disabled':
      return Icons.lock_open_outlined;
    case 'archived.enabled':
      return Icons.archive_outlined;
    case 'archived.disabled':
      return Icons.unarchive_outlined;
    case 'pinned.enabled':
    case 'pinned_globally.enabled':
    case 'pinned.disabled':
    case 'pinned_globally.disabled':
      return Icons.push_pin_outlined;
    case 'visible.enabled':
      return Icons.visibility_outlined;
    case 'visible.disabled':
      return Icons.visibility_off_outlined;
    case 'split_topic':
      return Icons.call_split;
    case 'invited_user':
    case 'invited_group':
    case 'assigned':
    case 'assigned_group':
    case 'assigned_to_post':
    case 'assigned_group_to_post':
      return Icons.person_add_alt;
    case 'user_left':
    case 'removed_user':
    case 'removed_group':
    case 'unassigned':
    case 'unassigned_group':
    case 'unassigned_from_post':
    case 'unassigned_group_from_post':
      return Icons.person_remove_alt_1_outlined;
    case 'reassigned':
    case 'reassigned_group':
      return Icons.swap_horiz;
    case 'public_topic':
    case 'open_topic':
    case 'topic_created':
      return Icons.chat_bubble_outline;
    case 'private_topic':
      return Icons.mail_outline;
    case 'autobumped':
      return Icons.arrow_upward;
    case 'tags_changed':
      return Icons.sell_outlined;
    case 'category_changed':
      return Icons.edit_outlined;
    case 'banner.enabled':
    case 'banner.disabled':
      return Icons.campaign_outlined;
    case 'forwarded':
      return Icons.forward_to_inbox_outlined;
  }
  return Icons.info_outline;
}
