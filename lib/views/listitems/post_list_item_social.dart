import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post.dart';
import 'package:forumcopilot_sdk/models/entities/fc_like.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import '../../utils/accessibility_helpers.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:forumcopilot_flutter/views/widgets/post_action_button.dart';
import 'package:forumcopilot_flutter/views/widgets/user_avatar.dart';
import 'package:forumcopilot_flutter/views/user_profile_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/design_tokens.dart';

class PostListItemSocial extends StatelessWidget {
  final FCPost post;
  final bool isLiked;
  final int likeCount;
  final bool isLoggedIn;
  final VoidCallback? onLike;
  /// Optional long-press on the like button. Used on Discourse to open
  /// the discourse-reactions picker so the user can pick any emoji
  /// instead of just like.
  final VoidCallback? onLongPressLike;
  final VoidCallback? onShowLikes;
  final bool isBookmarked;
  final VoidCallback? onBookmark;

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
    this.isLoggedIn = false,
    this.onLike,
    this.onLongPressLike,
    this.onShowLikes,
    this.isBookmarked = false,
    this.onBookmark,
    this.onToggleAcceptAnswer,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // if (post.likesInfo.isNotEmpty) ...[
        //   const SizedBox(height: 12),
        //   Row(
        //     children: [
        //       Icon(Icons.favorite_border, size: 18, color: colorScheme.primary),
        //       const SizedBox(width: 6),
        //       Text('Likes: ', style: textTheme.bodySmall),
        //       ...post.likesInfo.take(4).map((l) => Padding(
        //             padding: const EdgeInsets.symmetric(horizontal: 2.0),
        //             child: Chip(
        //               label: Text(l.username, style: textTheme.bodySmall),
        //               visualDensity: VisualDensity.compact,
        //             ),
        //           )),
        //       if (post.likesInfo.length > 4)
        //         Text(
        //           ' + {post.likesInfo.length - 4} more people',
        //           style: textTheme.bodySmall,
        //         ),
        //     ],
        //   ),
        // ],
        // if (post.thanksInfo.isNotEmpty) ...[
        //   const SizedBox(height: 12),
        //   Row(
        //     children: [
        //       Icon(Icons.thumb_up_alt_outlined, size: 18, color: colorScheme.primary),
        //       const SizedBox(width: 6),
        //       Text('Thanks: ', style: textTheme.bodySmall),
        //       ...post.thanksInfo.take(4).map((t) => Padding(
        //             padding: const EdgeInsets.symmetric(horizontal: 2.0),
        //             child: Chip(
        //               label: Text(t.username, style: textTheme.bodySmall),
        //               visualDensity: VisualDensity.compact,
        //             ),
        //           )),
        //       if (post.thanksInfo.length > 4)
        //         Text(
        //           ' + {post.thanksInfo.length - 4} more people',
        //           style: textTheme.bodySmall,
        //         ),
        //     ],
        //   ),
        // ],
        // Like avatars row (if there are likes)
        if (likeCount > 0) ...[
          SizedBox(height: DesignTokens.spacingXL),
          LayoutBuilder(
            builder: (context, constraints) {
              final likeText = likeCount == 1 ? '1 Like' : '$likeCount Likes';
              
              return Semantics(
                label: likeText,
                hint: 'Show likes',
                button: true,
                enabled: onShowLikes != null,
                child: GestureDetector(
                  onTap: onShowLikes,
                  child: Container(
                  margin: EdgeInsets.only(top: DesignTokens.spacingS),
                  padding: DesignTokens.paddingS,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withValues(alpha: DesignTokens.opacityLow),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: DesignTokens.opacityLow),
                      width: DesignTokens.borderWidthThin,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        likeText,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: DesignTokens.lineHeightTight,
                        ),
                      ),
                      SizedBox(width: DesignTokens.spacingS),
                      Flexible(
                        child: LayoutBuilder(
                          builder: (context, avatarConstraints) {
                            return _buildLikesAvatars(
                              context,
                              post.likesInfo,
                              likeCount,
                              onShowLikes,
                              colorScheme,
                              avatarConstraints.maxWidth,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              );
            },
          ),
        ],
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
            if (isLoggedIn && post.canLike) ...[
              if (trailing != null) SizedBox(width: DesignTokens.spacingXL),
              PostActionButton(
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
            ],
            if (isLoggedIn && onBookmark != null) ...[
              SizedBox(width: DesignTokens.spacingXL),
              PostActionButton(
                icon: Icons.bookmark_border,
                activeIcon: Icons.bookmark,
                active: isBookmarked,
                onTap: onBookmark,
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

  Widget _buildLikesAvatars(
    BuildContext context,
    List<FCLike> likesInfo,
    int likeCount,
    VoidCallback? onShowLikes,
    ColorScheme colorScheme,
    double availableWidth,
  ) {
    if (likesInfo.isEmpty || likeCount == 0) {
      return const SizedBox.shrink();
    }

    final avatarRadius = 12.0; // Smaller avatars for overlapping display
    final avatarSize = avatarRadius * 2;
    final overlapOffset = avatarSize * 0.5; // 50% overlap - each avatar overlaps half of the previous one

    // Calculate how many avatars can fit
    // Each avatar after the first takes overlapOffset (12px) additional width
    // Formula: width = avatarSize + (n - 1) * overlapOffset
    // So: n = ((width - avatarSize) / overlapOffset) + 1
    // Ensure we have at least enough space for one avatar
    final int maxAvatarsToShow;
    if (availableWidth < avatarSize) {
      maxAvatarsToShow = 1; // Show at least one avatar even if space is tight
    } else {
      maxAvatarsToShow = math.max(1, ((availableWidth - avatarSize) / overlapOffset).floor() + 1);
    }
    
    // Show as many avatars as can fit, but limit to available likesInfo
    final int avatarsToShow = math.min(maxAvatarsToShow, likesInfo.length);

    return SizedBox(
      width: avatarSize + (avatarsToShow - 1) * overlapOffset,
      height: avatarSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Show avatars
          ...List.generate(avatarsToShow, (index) {
            final like = likesInfo[index];
            return Positioned(
              left: index * overlapOffset,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: UserAvatar(
                  username: like.username,
                  iconUrl: like.avatarUrl.isNotEmpty ? like.avatarUrl : null,
                  radius: avatarRadius,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  static Widget _buildReactionIcon(BuildContext context, FCLike like) {
    final avatarSize = DesignTokens.avatarRadiusM * 2; // Same size as avatar
    final colorScheme = Theme.of(context).colorScheme;
    
    Widget? content;
    
    // If emoji is available, display it
    if (like.reactionEmoji != null && like.reactionEmoji!.isNotEmpty) {
      content = Text(
        like.reactionEmoji!,
        style: TextStyle(fontSize: avatarSize * 0.6), // Emoji size relative to circle
      );
    }
    // If icon URL is available, display it
    else if (like.reactionIconUrl != null && like.reactionIconUrl!.isNotEmpty) {
      content = ClipOval(
        child: CachedNetworkImage(
          imageUrl: like.reactionIconUrl!,
          width: avatarSize * 0.7,
          height: avatarSize * 0.7,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => SizedBox(width: avatarSize * 0.7, height: avatarSize * 0.7),
        ),
      );
    }
    // Backward compatibility: if no reaction info, return empty widget
    if (content == null) {
      return const SizedBox.shrink();
    }
    
    // Wrap content in grey circle
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.surfaceVariant,
      ),
      alignment: Alignment.center,
      child: content,
    );
  }

  static void showLikesBottomSheet(BuildContext context, FCPost post, SiteContext siteContext) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusL)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: DesignTokens.spacingL, horizontal: DesignTokens.spacingL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite, color: Theme.of(context).colorScheme.error),
                      SizedBox(width: DesignTokens.spacingS),
                      Expanded(
                        child: Text(AppLocalizations.of(context)?.reactedBy ?? 'Reacted by', style: Theme.of(context).textTheme.titleMedium),
                      ),
                      Semantics(
                        label: 'Close',
                        button: true,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          alignment: Alignment.centerRight,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: DesignTokens.spacingL),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: post.likesInfo.length,
                      itemBuilder: (context, index) {
                        final like = post.likesInfo[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
                          child: Semantics(
                            label: 'View profile of ${like.username}',
                            button: true,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context); // Close bottom sheet
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserProfilePage(
                                      siteContext: siteContext,
                                      userId: like.userId,
                                      userName: like.username,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                              children: [
                                UserAvatar(
                                  username: like.username,
                                  iconUrl: like.avatarUrl,
                                  radius: DesignTokens.avatarRadiusM,
                                ),
                                SizedBox(width: DesignTokens.spacingM),
                                Expanded(
                                  child: Text(like.username, style: Theme.of(context).textTheme.bodyLarge),
                                ),
                                SizedBox(width: DesignTokens.spacingS),
                                _buildReactionIcon(context, like),
                              ],
                            ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

}
