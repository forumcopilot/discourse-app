import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post_reaction.dart';
import '../../utils/accessibility_helpers.dart';
import 'package:discourse_ui/views/widgets/post_action_button.dart';
import '../../theme/design_tokens.dart';
import '../widgets/reaction_glyph.dart';
import '../../theme/forum_colors.dart';

/// Action row under a post, laid out as Discourse web's post menu: the
/// "N replies" disclosure ([leading]) on the left, the actions packed on
/// the right with Reply ([trailing]) last.
///
/// Right-aligned rather than left: that is where web puts them, where a
/// right thumb rests, and packing them as one group reads as a toolbar
/// where 24dp gaps between 48dp targets read as scattered icons.
///
/// Marking the solution (discourse-solved) is not here: it lives in the
/// post's ⋮ menu for the readers the server lets accept, and the solved
/// post says so with its "Solution" label above the body. As a button in
/// this row it showed on the accepted post for every signed-in reader,
/// looking like a control, and only refused on tap.
///
/// There is deliberately **no** "N Likes + avatars" row here anymore.
/// A like is just the heart reaction on Discourse, so the reactor
/// count and actor list live on the reaction cluster — rendering both
/// duplicated the same server data, and the avatar stack was drawn from
/// placeholder `likesInfo` entries that had no username, avatar or user
/// id.
class PostListItemSocial extends StatelessWidget {
  final FCPost post;
  final bool isLiked;
  final int likeCount;

  /// Every reaction on the post, so the react control can show the same
  /// combined cluster the web page does (`❤️😮 5`) instead of a separate
  /// chips row stacked above the action row.
  final List<FCPostReaction> reactions;

  /// Resolves custom-emoji images for the cluster.
  final SiteContext? reactionSiteContext;

  /// Seconds until this post's like budget frees up, or 0 when it is
  /// available. Discourse caps post actions at 4/minute per post, counting
  /// likes and unlikes together, so a live-looking heart during the cooldown
  /// only invites taps that cannot succeed.
  final int likeCooldownSeconds;
  final bool isLoggedIn;
  final VoidCallback? onLike;

  /// Who reacted: long-press on the cluster, and its tap for a reader who
  /// may not react.
  final VoidCallback? onShowReactors;
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

  /// Start of the row: the "N replies" disclosure, when the post has
  /// replies worth disclosing. Squeezed (never the actions) when the row
  /// runs out of width.
  final Widget? leading;

  /// End of the row: the Reply button.
  final Widget? trailing;

  const PostListItemSocial({
    super.key,
    required this.post,
    required this.isLiked,
    required this.likeCount,
    this.reactions = const [],
    this.reactionSiteContext,
    this.likeCooldownSeconds = 0,
    this.isLoggedIn = false,
    this.onLike,
    this.onShowReactors,
    this.onLongPressLike,
    this.isBookmarked = false,
    this.onBookmark,
    this.onLongPressBookmark,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Whether the viewer may react — not whether reactions are shown.
    // Discourse leaves `can_act` off your own post, off a guest's view and
    // off a plain like past its undo window, and web still shows all of
    // those readers the post's reactions; gating the cluster on it hid
    // every reaction on your own posts.
    final canReact = isLoggedIn && post.canLike;
    final showBookmark = isLoggedIn && onBookmark != null;

    // Dimmed, with a countdown, while the post's like budget is spent.
    Widget cooling(Widget child) {
      if (!canReact || likeCooldownSeconds <= 0) return child;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(opacity: 0.5, child: child),
          SizedBox(width: DesignTokens.spacingXS),
          Text(
            '${likeCooldownSeconds}s',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    final actions = <Widget>[
      if (reactions.isNotEmpty)
        cooling(_ReactionClusterButton(
          reactions: reactions,
          siteContext: reactionSiteContext,
          // The picker for a reader who may react; for anyone else, who
          // reacted — what a tap on web's count shows.
          onTap: canReact ? onLike : onShowReactors,
          onLongPress: onShowReactors,
        ))
      else if (canReact)
        // The zero-state affordance: nothing to show yet, so a heart.
        cooling(PostActionButton(
          icon: Icons.favorite_border,
          activeIcon: Icons.favorite,
          active: isLiked,
          activeColor: ForumColors.of(context).love,
          onTap: onLike,
          onLongPress: onLongPressLike,
          semanticLabel:
              AccessibilityHelpers.getLikeButtonLabel(context, isLiked, likeCount),
        )),
      if (showBookmark)
        PostActionButton(
          icon: Icons.bookmark_border,
          activeIcon: Icons.bookmark,
          active: isBookmarked,
          onTap: onBookmark,
          // Long-press opens the bookmark-reminder sheet when
          // wired (Discourse); plain tap still toggles.
          onLongPress: onLongPressBookmark,
          semanticLabel: isBookmarked ? 'Remove bookmark' : 'Bookmark post',
        ),
      if (trailing != null) trailing!,
    ];

    // Nothing to show (a guest on an unreacted post): keep the body's
    // breathing room above the divider, without an empty 48dp row.
    if (leading == null && actions.isEmpty) {
      return SizedBox(height: DesignTokens.spacingM);
    }

    return Padding(
      padding: EdgeInsets.only(top: DesignTokens.spacingS),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: leading ?? const SizedBox.shrink(),
            ),
          ),
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) SizedBox(width: DesignTokens.spacingXS),
            actions[i],
          ],
        ],
      ),
    );
  }
}


/// The react button when the viewer HAS reacted: their reaction's glyph
/// on the same footprint as the other action buttons.
/// The react control once a post HAS reactions: the distinct emoji in a
/// row followed by the total, the way Discourse web renders it.
///
/// This replaces a separate chips row that sat on its own line above the
/// action row. Same information, one line, and the control lives where
/// every other post action already is.
class _ReactionClusterButton extends StatelessWidget {
  final List<FCPostReaction> reactions;
  final SiteContext? siteContext;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _ReactionClusterButton({
    required this.reactions,
    required this.siteContext,
    required this.onTap,
    required this.onLongPress,
  });

  /// Cap the glyphs so a heavily-reacted post cannot push the rest of the
  /// action row off screen; the total still counts every reaction.
  static const int _maxGlyphs = 3;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final total = reactions.fold<int>(0, (sum, r) => sum + r.count);
    final viewerReacted = reactions.any((r) => r.viewerReacted);
    final shown = reactions.take(_maxGlyphs).toList();

    return Semantics(
      label: viewerReacted
          ? 'You reacted. $total reactions. Tap to change, long press to see who.'
          : '$total reactions. Tap to react, long press to see who.',
      button: true,
      selected: viewerReacted,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        // The like control on any post that has reactions, so it takes the
        // same 48dp as the action buttons beside it (it was ~26dp).
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
            minWidth: kMinInteractiveDimension,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingS),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final r in shown) ...[
                  ReactionGlyph(
                    reactionId: r.id,
                    size: PostActionButton.iconSizeOf(
                        context, DesignTokens.iconSizeM),
                    siteContext: siteContext,
                  ),
                  const SizedBox(width: 2),
                ],
                const SizedBox(width: DesignTokens.spacingXS),
                Text(
                  '$total',
                  // The viewer's own participation is the one thing a bare
                  // count cannot convey, so carry it in the colour.
                  style: textTheme.labelLarge?.copyWith(
                    color: viewerReacted
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
