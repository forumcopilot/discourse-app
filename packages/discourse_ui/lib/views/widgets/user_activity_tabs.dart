import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../theme/design_tokens.dart';
import 'filter_chip_bar.dart';
import 'profile_section.dart';
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

/// The profile's activity feeds. Web offers ten; these are the ones a
/// *viewer* can actually read — `/user_actions.json` answers 403 to
/// anyone but the user themself for WasLiked, Response, Mention, Quote
/// and Edit, so offering them would be a tab that only ever errors.
///
/// Read, Reactions and Votes are absent for a different reason: they are
/// not user_actions feeds at all (separate routes, and two of them are
/// plugin-specific).
enum _ActivityTab {
  replies('Replies', Icons.reply_rounded, 5, 'No replies yet'),
  topics('Topics', Icons.topic_outlined, 4, 'No topics yet'),
  likes('Likes', Icons.favorite_border, 1, 'No likes given yet'),
  solved('Solved', Icons.check_circle_outline, 15, 'No solutions yet');

  const _ActivityTab(this.label, this.icon, this.filter, this.emptyLabel);

  final String label;
  final IconData icon;

  /// The `/user_actions.json` filter id.
  final int filter;
  final String emptyLabel;
}

class _UserActivityTabsState extends State<UserActivityTabs> {
  _ActivityTab _selected = _ActivityTab.replies;

  @override
  Widget build(BuildContext context) {
    // Every other block on this page announces itself — "Top Replies",
    // "Top Topics", "Most Liked By". Without a heading the chips read as
    // controls belonging to the section above them rather than as the
    // start of the feed below. Web solves this by making Activity its own
    // tab; on one scrolling page a section heading is the equivalent.
    return ProfileSection(
      title: 'Activity',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        _buildSelector(context),
        const SizedBox(height: DesignTokens.spacingS),
        if (_selected == _ActivityTab.topics)
          UserCreatedTopics(
            // Key tied to the tab so flipping back-and-forth doesn't
            // reuse the previously-disposed state. Combined with
            // `(userName,userId)` so a user-switch also forces a refetch.
            key: ValueKey('topics:${widget.userName}:${widget.userId}'),
            siteContext: widget.siteContext,
            userId: widget.userId,
            userName: widget.userName,
          )
        else
          UserRepliedPosts(
            // Replies keeps the parent's key so pull-to-refresh still
            // reaches it; the other feeds key off the tab so switching
            // refetches instead of showing the previous feed's items.
            key: _selected == _ActivityTab.replies
                ? widget.repliesKey
                : ValueKey(
                    'actions:${_selected.filter}:${widget.userName}'),
            siteContext: widget.siteContext,
            userId: widget.userId,
            userName: widget.userName,
            actionFilter: _selected.filter,
            emptyLabel: _selected.emptyLabel,
          ),
        ],
      ),
    );
  }

  Widget _buildSelector(BuildContext context) {
    final tabs = _ActivityTab.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterChipBar(
          options: [
            for (final t in tabs)
              FilterChipOption(label: t.label, icon: t.icon),
          ],
          selectedIndex: tabs.indexOf(_selected),
          onSelected: (i) => setState(() => _selected = tabs[i]),
          padding: EdgeInsets.fromLTRB(
            DesignTokens.spacingL,
            DesignTokens.spacingS,
            DesignTokens.spacingL,
            0,
          ),
        ),
      ],
    );
  }
}
