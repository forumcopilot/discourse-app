import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';
import '../../theme/forum_colors.dart';
import '../../utils/emoji_shortcodes.dart';
import '../../utils/number_utils.dart';
import '../../utils/time_utils.dart';
import 'category_badge.dart';
import 'topic_taxonomy_chips.dart';
import 'user_avatar.dart';
import '../../l10n/kit_strings.dart';

/// The person a row names, when naming one says something.
///
/// Two different people can earn the line, which is why [label] exists.
/// On Likes it is the post's author and the bare name is right — the row
/// *is* their post. On Solved the post is the profile owner's answer and
/// the person is whoever accepted it, so an unlabelled name would read as
/// a byline and credit the wrong person; there the label says "Accepted
/// by".
class ActivityAttribution {
  const ActivityAttribution({
    required this.username,
    this.avatarUrl,
    this.label,
  });

  final String username;
  final String? avatarUrl;

  /// Prefix shown before the name, e.g. "Accepted by". Null for a plain
  /// byline.
  final String? label;
}

/// `/user_actions.json` filter ids the feeds use.
class ActivityFilters {
  ActivityFilters._();
  static const int likes = 1;
  static const int topics = 4;
  static const int replies = 5;
  static const int solved = 15;
}

/// What a `/user_actions.json` row records, for [ActivityRow.kind]: the
/// feed says most of it; on a mixed feed (web's "All": topics and replies)
/// the post number tells a topic's opening post from a reply.
String activityKindLabel(AppLocalizations l10n,
    {required int filter, int? postNumber}) {
  switch (filter) {
    case ActivityFilters.likes:
      return l10n.activityLiked;
    case ActivityFilters.solved:
      return l10n.activitySolution;
    case ActivityFilters.topics:
      return l10n.activityStartedTopic;
    default:
      return (postNumber ?? 0) <= 1
          ? l10n.activityStartedTopic
          : l10n.activityReplied;
  }
}

/// One row of an activity feed — My posts and the profile's Activity — in
/// the topic page's language: what happened and when on a short line,
/// the topic, where it lives, then the post's own words as a quote.
///
/// * The line on top is [kind] ("Replied", "Started a topic", "Liked",
///   "Solution") with the post's number and its time. The time and "#45"
///   used to trail at the bottom, under the excerpt, where a reader
///   scanning for "what did I do today" had to hunt for them.
/// * The excerpt is quoted (a rule down its left edge, as reply previews
///   are), so it reads as the words that were written rather than as a
///   second description of the topic. When somebody else wrote them — a
///   post you liked — their face and name head the quote.
/// * Counts appear only where the feed has them: a topic list row has
///   replies, views and likes; `/user_actions.json` has none, and a zero
///   or a stand-in would say something false.
///
/// Attribution is a property of the individual row, not of the tab:
/// `/user_actions.json` returns the *post author* in `username`, which is
/// the profile owner on Replies, Topics and Solved (naming them down every
/// row repeated the same face) and somebody else on Likes, where naming
/// them is the point. An [ActivityAttribution] with a label ("Accepted by")
/// names someone who acted on the post rather than wrote it, and joins the
/// top line instead of heading the quote.
class ActivityRow extends StatelessWidget {
  const ActivityRow({
    super.key,
    required this.title,
    required this.onTap,
    this.kind,
    this.excerpt,
    this.attribution,
    this.time,
    this.replyCount,
    this.viewCount,
    this.likeCount,
    this.postNumber,
    this.siteContext,
    this.categoryId,
    this.tags = const [],
    this.solved = false,
  });

  final String title;
  final VoidCallback onTap;

  /// What the row records, e.g. "Replied". Leads the top line.
  final String? kind;
  final String? excerpt;

  /// Who wrote the quoted post when it is not the feed's owner, or (with a
  /// label) who acted on it.
  final ActivityAttribution? attribution;

  final DateTime? time;
  final int? replyCount;
  final int? viewCount;
  final int? likeCount;

  /// The post's position in its topic (`post_number`), shown as "#45".
  /// Post 1 is the topic's opening post, which the kind already says.
  final int? postNumber;

  /// The topic's category and tags, badged under the title as on every
  /// topic row. The badge takes the name and colour from /site.json.
  final SiteContext? siteContext;
  final String? categoryId;
  final List<String> tags;

  /// The topic has an accepted answer (discourse-solved).
  final bool solved;

  static final _epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final excerptText =
        excerpt == null ? null : withEmojiShortcodes(excerpt!.trim());
    final muted = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    final actor = attribution?.label != null ? attribution : null;
    final author = attribution?.label == null ? attribution : null;
    final hasTime = time != null && time!.toUtc() != _epoch;

    final top = <InlineSpan>[
      if (kind != null)
        TextSpan(
          text: kind,
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: DesignTokens.fontWeightMedium,
          ),
        ),
      if (actor != null) TextSpan(text: '${actor.label} ${actor.username}'),
      if (postNumber != null && postNumber! > 1) TextSpan(text: '#$postNumber'),
      if (hasTime) TextSpan(text: formatSmartDateTime(time!, context)),
    ];
    final showTaxonomy = siteContext != null &&
        (tags.isNotEmpty ||
            ((categoryId ?? '').isNotEmpty &&
                CategoryBadge.shows(siteContext!, categoryId!)));
    final hasCounts = (replyCount ?? 0) > 0 ||
        (viewCount ?? 0) > 0 ||
        (likeCount ?? 0) > 0 ||
        solved;

    return Material(
      color: colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingL,
            vertical: DesignTokens.spacingM,
          ),
          // `stretch`, not `start`: under a parent Column that centres its
          // children (which is the default), a `start` column shrinks to its
          // widest child and the whole row drifts inward by half the
          // leftover width — so rows indented by different amounts depending
          // on how long their excerpt happened to be.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (top.isNotEmpty) ...[
                Text.rich(
                  TextSpan(children: [
                    for (var i = 0; i < top.length; i++) ...[
                      if (i > 0) const TextSpan(text: ' · '),
                      top[i],
                    ],
                  ]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: muted,
                ),
                SizedBox(height: DesignTokens.spacingXS),
              ],
              Text(
                withEmojiShortcodes(title),
                textAlign: TextAlign.start,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (showTaxonomy)
                TopicTaxonomyChips(
                  siteContext: siteContext!,
                  categoryId: categoryId ?? '',
                  tags: tags,
                  maxTags: 3,
                  padding: EdgeInsets.only(top: DesignTokens.spacingXS),
                ),
              if ((excerptText != null && excerptText.isNotEmpty) ||
                  author != null)
                QuotedExcerpt(author: author, text: excerptText),
              if (hasCounts) ...[
                SizedBox(height: DesignTokens.spacingS),
                _MetaRow(
                  replyCount: replyCount,
                  viewCount: viewCount,
                  likeCount: likeCount,
                  solved: solved,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The post's words, set off by a rule down the left as the topic page's
/// reply previews are, headed by whoever wrote them when that is news.
/// Shared by the activity rows, bookmarks and drafts.
class QuotedExcerpt extends StatelessWidget {
  const QuotedExcerpt({super.key, this.author, this.text, this.maxLines = 3});

  final ActivityAttribution? author;
  final String? text;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: EdgeInsets.only(top: DesignTokens.spacingS),
      padding: EdgeInsets.only(left: DesignTokens.spacingM),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: colorScheme.outlineVariant, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (author != null)
            Padding(
              padding: EdgeInsets.only(bottom: DesignTokens.spacingXS),
              child: Row(
                children: [
                  UserAvatar(
                    username: author!.username,
                    iconUrl: author!.avatarUrl?.isNotEmpty == true
                        ? author!.avatarUrl
                        : null,
                    radius: DesignTokens.avatarRadiusXS,
                  ),
                  SizedBox(width: DesignTokens.spacingS),
                  Expanded(
                    child: Text(
                      author!.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (text != null && text!.isNotEmpty)
            Text(
              text!,
              textAlign: TextAlign.start,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

/// A topic's counts under its row: replies, views, likes, and whether it
/// is solved. Each drops out when the feed has no value for it rather than
/// showing a zero or a stand-in.
class _MetaRow extends StatelessWidget {
  const _MetaRow({
    this.replyCount,
    this.viewCount,
    this.likeCount,
    this.solved = false,
  });

  final int? replyCount;
  final int? viewCount;
  final int? likeCount;
  final bool solved;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final style = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    Widget item(IconData icon, String label, {Color? color}) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: DesignTokens.iconSizeS,
                color: color ?? colorScheme.onSurfaceVariant),
            SizedBox(width: DesignTokens.spacingXS),
            Text(label, style: color == null ? style : style?.copyWith(color: color)),
          ],
        );

    return Wrap(
      spacing: DesignTokens.spacingM,
      runSpacing: DesignTokens.spacingXS,
      children: [
        if ((replyCount ?? 0) > 0)
          item(Icons.chat_bubble_outline, formatNumber(context, replyCount!)),
        if ((viewCount ?? 0) > 0)
          item(Icons.visibility_outlined, formatNumber(context, viewCount!)),
        if ((likeCount ?? 0) > 0)
          item(Icons.favorite_border, formatNumber(context, likeCount!)),
        if (solved)
          item(Icons.check_circle, AppLocalizations.of(context)?.kit.solved ?? 'Solved',
              color: ForumColors.of(context).success),
      ],
    );
  }
}
