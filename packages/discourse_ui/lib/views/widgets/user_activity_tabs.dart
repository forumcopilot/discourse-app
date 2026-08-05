import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../theme/design_tokens.dart';
import 'user_created_topics.dart';
import 'user_replied_posts.dart';

/// Phase 5.24 — Replies / Topics tab strip for a user profile.
///
/// Wraps both `UserRepliedPosts` (FCUserReply, hits
/// `/user_actions.json?filter=5`) and `UserCreatedTopics` (FCUserTopic,
/// hits `filter=4`) with a ChoiceChip selector. Each child widget
/// fetches lazily on first render, so we only pay the network
/// roundtrip for the tab the user actually opens.
///
/// Sits inside the existing scrollable Column on `UserProfilePage` /
/// `ProfileTab` — uses `shrinkWrap` in the children so the outer
/// scroll keeps owning gesture, avoiding nested-scrollable
/// conflicts.
class UserActivityTabs extends StatefulWidget {
  final SiteContext siteContext;
  final String? userId;
  final String? userName;

  /// When non-null, drives `UserRepliedPosts.key` so the parent can
  /// force a refresh after a Pull-To-Refresh on the profile page.
  final Key? repliesKey;

  const UserActivityTabs({
    super.key,
    required this.siteContext,
    this.userId,
    this.userName,
    this.repliesKey,
  });

  @override
  State<UserActivityTabs> createState() => _UserActivityTabsState();
}

enum _ActivityTab { replies, topics }

class _UserActivityTabsState extends State<UserActivityTabs> {
  _ActivityTab _selected = _ActivityTab.replies;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSelector(context),
        const SizedBox(height: DesignTokens.spacingS),
        if (_selected == _ActivityTab.replies)
          UserRepliedPosts(
            key: widget.repliesKey,
            siteContext: widget.siteContext,
            userId: widget.userId,
            userName: widget.userName,
          )
        else
          UserCreatedTopics(
            // Key tied to the tab so flipping back-and-forth doesn't
            // reuse the previously-disposed Replies state. Combined
            // with `(userName,userId)` so a user-switch (rare) also
            // forces a refetch.
            key: ValueKey(
                'topics:${widget.userName}:${widget.userId}'),
            siteContext: widget.siteContext,
            userId: widget.userId,
            userName: widget.userName,
          ),
      ],
    );
  }

  Widget _buildSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spacingL,
        DesignTokens.spacingL,
        DesignTokens.spacingL,
        0,
      ),
      child: Row(
        children: [
          _TabChip(
            label: 'Replies',
            icon: Icons.reply_rounded,
            selected: _selected == _ActivityTab.replies,
            onTap: () => setState(() => _selected = _ActivityTab.replies),
          ),
          const SizedBox(width: DesignTokens.spacingS),
          _TabChip(
            label: 'Topics',
            icon: Icons.topic_outlined,
            selected: _selected == _ActivityTab.topics,
            onTap: () => setState(() => _selected = _ActivityTab.topics),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      avatar: Icon(icon, size: DesignTokens.iconSizeS),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
