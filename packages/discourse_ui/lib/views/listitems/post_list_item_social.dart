import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post_reaction.dart';
import 'package:discourse_ui/views/widgets/post_action_button.dart';
import '../../theme/design_tokens.dart';
import '../../utils/post_reactions.dart';
import '../widgets/reaction_glyph.dart';
import '../../theme/forum_colors.dart';
import '../../l10n/generated/app_localizations.dart';

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
/// Reactions are two controls side by side, as on Discourse web: the
/// **summary** (the emoji people used and how many people reacted; a tap
/// lists who) and the **react button** (always there for a reader who may
/// react; it shows the reader's own reaction, likes on a tap and opens the
/// picker on a long press). They used to be one control that replaced the
/// heart as soon as anyone reacted, so a reader lost the obvious way to
/// react, saw who reacted only on a long press, and could tell their own
/// reaction only by the colour of the count.
///
/// There is deliberately **no** "N Likes + avatars" row: a like is the
/// main reaction on Discourse, so the summary counts it.
class PostListItemSocial extends StatelessWidget {
  final FCPost post;

  /// Every reaction on the post, the reader's own marked
  /// ([FCPostReaction.viewerReacted]).
  final List<FCPostReaction> reactions;

  /// Resolves custom-emoji images.
  final SiteContext? reactionSiteContext;

  /// The forum's main reaction, the one a like stands for (`heart` unless
  /// the forum chose another): drawn as the heart button.
  final String mainReaction;

  /// Whether the reader may add a reaction now (Discourse's `can_act` for
  /// a like). False on their own post and, server-side, once they have
  /// acted, which is why a reader's existing reaction is judged by its own
  /// `canUndo` instead.
  final bool canAct;

  /// Whether the forum offers more than the like, so a long press on the
  /// react button has a picker to open.
  final bool hasMoreReactions;

  /// Seconds until this post's like budget frees up, or 0 when it is
  /// available. Discourse caps post actions at 4/minute per post, counting
  /// likes and unlikes together, so a live-looking heart during the cooldown
  /// only invites taps that cannot succeed.
  final int likeCooldownSeconds;
  final bool isLoggedIn;

  /// Tap on the react button: like, remove the reader's reaction, or (once
  /// it can no longer be changed) say so. The caller decides which.
  final VoidCallback? onReact;

  /// Long press on the react button: the picker.
  final VoidCallback? onMoreReactions;

  /// Tap or long press on the summary: who reacted.
  final VoidCallback? onShowReactors;

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

  PostListItemSocial({
    super.key,
    required this.post,
    this.reactions = const [],
    this.reactionSiteContext,
    this.mainReaction = 'heart',
    bool? canAct,
    this.hasMoreReactions = true,
    this.likeCooldownSeconds = 0,
    this.isLoggedIn = false,
    this.onReact,
    this.onMoreReactions,
    this.onShowReactors,
    this.isBookmarked = false,
    this.onBookmark,
    this.onLongPressBookmark,
    this.leading,
    this.trailing,
  }) : canAct = canAct ?? post.canLike;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mine = viewerReactionOf(reactions);
    final total = reactionTotal(reactions);
    // Shown to a reader who may react, and to one who already has (to see
    // and undo it). Not on the reader's own post, nor to a guest.
    final showReactButton = isLoggedIn && (mine != null || canAct);
    final showBookmark = isLoggedIn && onBookmark != null;

    // Dimmed, with a countdown, while the post's like budget is spent.
    Widget cooling(Widget child) {
      if (likeCooldownSeconds <= 0) return child;
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
      if (total > 0)
        _ReactionSummary(
          reactions: reactions,
          total: total,
          mainReaction: mainReaction,
          siteContext: reactionSiteContext,
          onTap: onShowReactors,
        ),
      if (showReactButton)
        cooling(_ReactButton(
          mine: mine,
          mainReaction: mainReaction,
          siteContext: reactionSiteContext,
          hasMoreReactions: hasMoreReactions,
          onTap: onReact,
          onLongPress: onMoreReactions,
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
          semanticLabel: isBookmarked
              ? AppLocalizations.of(context)!.removeBookmark
              : AppLocalizations.of(context)!.postBookmarkAction,
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
            // The summary and the react button read as one pair.
            if (i > 0 && !(i == 1 && total > 0 && showReactButton))
              SizedBox(width: DesignTokens.spacingXS),
            actions[i],
          ],
        ],
      ),
    );
  }
}

/// What people reacted with and how many: up to three emoji (most used
/// first) and the number of people, as the web's counter. With nothing but
/// likes it is the bare number, so "12 ♡" reads like any like count. A tap
/// lists who reacted.
class _ReactionSummary extends StatelessWidget {
  final List<FCPostReaction> reactions;
  final int total;
  final String mainReaction;
  final SiteContext? siteContext;
  final VoidCallback? onTap;

  const _ReactionSummary({
    required this.reactions,
    required this.total,
    required this.mainReaction,
    required this.siteContext,
    required this.onTap,
  });

  /// Cap the glyphs so a heavily-reacted post cannot push the rest of the
  /// action row off screen; the count still counts everyone. The web
  /// shows three as well.
  static const int maxGlyphs = 3;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onlyLikes = reactions.every((r) => r.id == mainReaction);
    final shown = onlyLikes ? const <FCPostReaction>[] : reactions.take(maxGlyphs).toList();
    final glyphSize = PostActionButton.iconSizeOf(context, DesignTokens.iconSizeM);

    return Semantics(
      label: AppLocalizations.of(context)!.reactionSummarySemantics(total),
      button: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        onLongPress: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXL),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
            minWidth: kMinInteractiveDimension,
          ),
          // Packed against the react button it counts for: a bare "2" sat
          // centred in its 48dp target, adrift from the heart.
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
                start: DesignTokens.spacingS, end: DesignTokens.spacingXS),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (final r in shown) ...[
                  ReactionGlyph(reactionId: r.id, size: glyphSize, siteContext: siteContext),
                  const SizedBox(width: 2),
                ],
                if (shown.isNotEmpty) const SizedBox(width: DesignTokens.spacingXS),
                Text(
                  '$total',
                  style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The react button. An outline heart before the reader reacts; their own
/// reaction after: a filled heart for a like, or their emoji on a tinted
/// chip. Dimmed once Discourse no longer lets them change it (its undo
/// window, 10 minutes by default); a tap then explains instead of failing.
class _ReactButton extends StatelessWidget {
  final FCPostReaction? mine;
  final String mainReaction;
  final SiteContext? siteContext;
  final bool hasMoreReactions;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _ReactButton({
    required this.mine,
    required this.mainReaction,
    required this.siteContext,
    required this.hasMoreReactions,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final mine = this.mine;
    final locked = mine != null && !mine.canUndo;
    final pickerHint = hasMoreReactions && !locked ? l10n.reactionHoldHint : null;
    final longPress = hasMoreReactions && !locked ? onLongPress : null;

    if (mine == null || mine.id == mainReaction) {
      final liked = mine != null;
      final button = PostActionButton(
        icon: Icons.favorite_border,
        activeIcon: Icons.favorite,
        active: liked,
        activeColor: ForumColors.of(context).love,
        onTap: onTap,
        onLongPress: longPress,
        semanticLabel: !liked
            ? l10n.postLikeAction
            : locked
                ? l10n.reactionButtonLocked(reactionDisplayName(mine.id))
                : l10n.reactionButtonRemoveLike,
        semanticHint: pickerHint,
      );
      return locked ? Opacity(opacity: 0.55, child: button) : button;
    }

    final chip = Semantics(
      label: locked
          ? l10n.reactionButtonLocked(reactionDisplayName(mine.id))
          : l10n.reactionButtonRemove(reactionDisplayName(mine.id)),
      hint: pickerHint,
      button: true,
      selected: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        onLongPress: longPress,
        customBorder: const StadiumBorder(),
        child: SizedBox(
          width: kMinInteractiveDimension,
          height: kMinInteractiveDimension,
          child: Center(
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: colorScheme.primaryContainer,
                shape: StadiumBorder(
                  side: BorderSide(color: colorScheme.primary, width: 1.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spacingXS + 2),
                child: ReactionGlyph(
                  reactionId: mine.id,
                  size: PostActionButton.iconSizeOf(context, DesignTokens.iconSizeM),
                  siteContext: siteContext,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return locked ? Opacity(opacity: 0.55, child: chip) : chip;
  }
}
