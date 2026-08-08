import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post.dart';
import '../../utils/accessibility_helpers.dart';
import 'package:discourse_ui/views/widgets/post_action_button.dart';
import '../../theme/design_tokens.dart';

/// Action row under a post: reply / like / bookmark / accept-answer.
///
/// There is deliberately **no** "N Likes + avatars" row here anymore.
/// A like is just the heart reaction on Discourse, so the reactor
/// count and actor list live on `ReactionChipsRow` (rendered above by
/// `PostListItem`) — rendering both duplicated the same server data,
/// and the avatar stack was drawn from placeholder `likesInfo` entries
/// that had no username, avatar or user id.
class PostListItemSocial extends StatelessWidget {
  final FCPost post;
  final bool isLiked;
  final int likeCount;

  /// Seconds until this post's like budget frees up, or 0 when it is
  /// available. Discourse caps post actions at 4/minute per post, counting
  /// likes and unlikes together, so a live-looking heart during the cooldown
  /// only invites taps that cannot succeed.
  final int likeCooldownSeconds;
  final bool isLoggedIn;
  final VoidCallback? onLike;
  /// Optional long-press on the like button. Used on Discourse to open
  /// the discourse-reactions picker so the user can pick any emoji
  /// instead of just like.
  final VoidCallback? onLongPressLike;
  final bool isBookmarked;
  final VoidCallback? onBookmark;

  /// Optional long-press on the bookmark button. Used on Discourse to
  /// open the "Bookmark with reminder" sheet; plain tap still toggles
  /// the bookmark.
  final VoidCallback? onLongPressBookmark;

  /// Phase 5.31 — Discourse-solved plugin. When the viewer can
  /// accept this post as the topic's answer (`post.canAcceptAnswer`)
  /// a green check button appears in the action row. Tapping flips
  /// the topic-wide accepted-answer state via
  /// `IFCPostProxy.acceptAnswerAsync`/`unacceptAnswerAsync`. The
  /// active state (post.isSolution) renders the filled check.
  final VoidCallback? onToggleAcceptAnswer;
  final Widget? trailing;

  const PostListItemSocial({
    super.key,
    required this.post,
    required this.isLiked,
    required this.likeCount,
    this.likeCooldownSeconds = 0,
    this.isLoggedIn = false,
    this.onLike,
    this.onLongPressLike,
    this.isBookmarked = false,
    this.onBookmark,
    this.onLongPressBookmark,
    this.onToggleAcceptAnswer,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // The heart is the zero-state affordance only — see the class doc.
    final showLike = isLoggedIn && post.canLike && post.reactions.isEmpty;
    final showBookmark = isLoggedIn && onBookmark != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Like/Thank button row
        SizedBox(height: DesignTokens.spacingM),
        Row(
          children: [
            // Reply button (trailing widget)
            if (trailing != null) trailing!,
            // Phase 5.29 — Like / Bookmark both use the shared
            // PostActionButton recipe (48x48 target, iconSizeMedium,
            // opacityMediumLow inactive). Spacing between buttons is
            // a uniform `spacingXL` (24px).
            // Zero-state affordance only: once the post has any
            // reaction the chips row carries both the toggle (tap a
            // chip) and the picker (trailing "+" chip), so the heart
            // would be a second control for the same thing.
            if (showLike) ...[
              if (trailing != null) SizedBox(width: DesignTokens.spacingXL),
              Opacity(
                opacity: likeCooldownSeconds > 0 ? 0.5 : 1.0,
                child: PostActionButton(
                  icon: Icons.favorite_border,
                  activeIcon: Icons.favorite,
                  active: isLiked,
                  activeColor: colorScheme.error,
                  onTap: onLike,
                  // Long-press opens the reaction picker when wired
                  // (discourse-reactions plugin); plain tap still
                  // toggles like.
                  onLongPress: onLongPressLike,
                  semanticLabel: AccessibilityHelpers.getLikeButtonLabel(
                      context, isLiked, likeCount),
                ),
              ),
              if (likeCooldownSeconds > 0) ...[
                SizedBox(width: DesignTokens.spacingXS),
                Text(
                  '${likeCooldownSeconds}s',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
            if (showBookmark) ...[
              // Only pad when something precedes this button, otherwise
              // hiding the heart leaves a dangling left gap.
              if (trailing != null || showLike)
                SizedBox(width: DesignTokens.spacingXL),
              PostActionButton(
                icon: Icons.bookmark_border,
                activeIcon: Icons.bookmark,
                active: isBookmarked,
                onTap: onBookmark,
                // Long-press opens the bookmark-reminder sheet when
                // wired (Discourse); plain tap still toggles.
                onLongPress: onLongPressBookmark,
                semanticLabel: isBookmarked
                    ? 'Remove bookmark'
                    : 'Bookmark post',
              ),
            ],
            // Phase 5.31 — Accept answer (discourse-solved). Two
            // independent gating conditions: the viewer can accept
            // (canAcceptAnswer, set by the proxy from topic-level
            // `can_accept_answer`) OR the post is already the answer
            // (so the topic OP can unmark it). When neither is true
            // the button is hidden.
            if (isLoggedIn &&
                onToggleAcceptAnswer != null &&
                (post.canAcceptAnswer || post.isSolution)) ...[
              if (trailing != null || showLike || showBookmark)
                SizedBox(width: DesignTokens.spacingXL),
              PostActionButton(
                icon: Icons.check_circle_outline,
                activeIcon: Icons.check_circle,
                active: post.isSolution,
                activeColor: colorScheme.tertiary,
                onTap: onToggleAcceptAnswer,
                semanticLabel: post.isSolution
                    ? 'Unmark as accepted answer'
                    : 'Mark as accepted answer',
              ),
            ],
          ],
        ),
      ],
    );
  }


}
