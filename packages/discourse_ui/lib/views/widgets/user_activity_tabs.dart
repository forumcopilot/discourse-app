import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../theme/design_tokens.dart';
import 'filter_chip_bar.dart';
import 'profile_section.dart';
import 'user_created_topics.dart';
import 'user_replied_posts.dart';

/// The profile's activity feeds. Web offers ten; these are the ones a
/// *viewer* can actually read — `/user_actions.json` answers 403 to
/// anyone but the user themself for WasLiked, Response, Mention, Quote
/// and Edit, so offering them would be a tab that only ever errors.
///
/// Read, Reactions and Votes are absent for a different reason: they are
/// not user_actions feeds at all (separate routes, and two of them are
/// plugin-specific).
enum ActivityTab {
  replies('Replies', Icons.reply_rounded, 5, 'No replies yet'),
  topics('Topics', Icons.topic_outlined, 4, 'No topics yet'),
  likes('Likes', Icons.favorite_border, 1, 'No likes given yet'),
  solved('Solved', Icons.check_circle_outline, 15, 'No solutions yet');

  const ActivityTab(this.label, this.icon, this.filter, this.emptyLabel);

  final String label;
  final IconData icon;

  /// The `/user_actions.json` filter id.
  final int filter;
  final String emptyLabel;
}

/// The "Activity" heading, in the shared section chrome.
///
/// Separate from the chip bar because the two are no longer neighbours in
/// the widget tree: the bar is a pinned sliver so it survives at the top
/// of the viewport, and a pinned sliver cannot carry the break-and-title
/// block above it without pinning that too.
class ActivitySectionHeading extends StatelessWidget {
  const ActivitySectionHeading({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionBreak(),
        Padding(
          padding: EdgeInsets.fromLTRB(
            DesignTokens.spacingL,
            DesignTokens.spacingL,
            DesignTokens.spacingL,
            0,
          ),
          // Every other block on this page announces itself — "Top
          // Replies", "Most Liked By". Without a heading the chips read as
          // controls belonging to the section above rather than the start
          // of the feed below.
          child: Text(
            'Activity',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: DesignTokens.fontWeightBold,
            ),
          ),
        ),
      ],
    );
  }
}

/// The tab selector, built to be pinned by [ActivityChipBarDelegate].
class ActivityChipBar extends StatelessWidget {
  const ActivityChipBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ActivityTab selected;
  final ValueChanged<ActivityTab> onSelected;

  /// Chip height plus the bar's own padding. Fixed because a pinned
  /// sliver has to declare its extent up front.
  static const double height = 64;

  @override
  Widget build(BuildContext context) {
    const tabs = ActivityTab.values;
    return Container(
      // Opaque: pinned, it scrolls *over* the feed, and a transparent bar
      // would show rows sliding underneath the chips.
      color: Theme.of(context).colorScheme.surface,
      height: height,
      alignment: Alignment.centerLeft,
      child: FilterChipBar(
        options: [
          for (final t in tabs) FilterChipOption(label: t.label, icon: t.icon),
        ],
        selectedIndex: tabs.indexOf(selected),
        onSelected: (i) => onSelected(tabs[i]),
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingL,
          vertical: DesignTokens.spacingM,
        ),
      ),
    );
  }
}

/// Pins [ActivityChipBar] to the top of the viewport.
///
/// Activity is the last section on the profile and its feed runs for
/// screens, so the chips scrolled away almost immediately and switching
/// tabs meant scrolling all the way back up to find them.
class ActivityChipBarDelegate extends SliverPersistentHeaderDelegate {
  const ActivityChipBarDelegate({
    required this.selected,
    required this.onSelected,
  });

  final ActivityTab selected;
  final ValueChanged<ActivityTab> onSelected;

  @override
  double get minExtent => ActivityChipBar.height;

  @override
  double get maxExtent => ActivityChipBar.height;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Material(
        color: Theme.of(context).colorScheme.surface,
        // A hairline once it is floating over content, so the bar has an
        // edge instead of appearing to be part of the row beneath it.
        elevation: overlapsContent ? DesignTokens.elevationLow : 0,
        child: ActivityChipBar(selected: selected, onSelected: onSelected),
      );

  @override
  bool shouldRebuild(ActivityChipBarDelegate oldDelegate) =>
      oldDelegate.selected != selected || oldDelegate.onSelected != onSelected;
}

/// The feed for the selected tab.
class ActivityFeed extends StatelessWidget {
  const ActivityFeed({
    super.key,
    required this.siteContext,
    required this.tab,
    this.userId,
    this.userName,
    this.repliesKey,
  });

  final SiteContext siteContext;
  final ActivityTab tab;
  final String? userId;
  final String? userName;

  /// When non-null, drives `UserRepliedPosts.key` so the parent can force
  /// a refresh after a pull-to-refresh on the profile page.
  final Key? repliesKey;

  @override
  Widget build(BuildContext context) {
    if (tab == ActivityTab.topics) {
      return UserCreatedTopics(
        // Key tied to the tab so flipping back-and-forth doesn't reuse
        // the previously-disposed state. Combined with `(userName,userId)`
        // so a user-switch also forces a refetch.
        key: ValueKey('topics:$userName:$userId'),
        siteContext: siteContext,
        userId: userId,
        userName: userName,
      );
    }
    return UserRepliedPosts(
      // Replies keeps the parent's key so pull-to-refresh still reaches
      // it; the other feeds key off the tab so switching refetches
      // instead of showing the previous feed's items.
      key: tab == ActivityTab.replies
          ? repliesKey
          : ValueKey('actions:${tab.filter}:$userName'),
      siteContext: siteContext,
      userId: userId,
      userName: userName,
      actionFilter: tab.filter,
      emptyLabel: tab.emptyLabel,
    );
  }
}
