import 'package:discourse_core/discourse_core.dart' show DiscourseAcceptedAnswer;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../theme/design_tokens.dart';
import 'rich_text_content.dart';
import 'user_avatar.dart';

/// The accepted-answer panel shown under the FIRST post of a solved topic.
///
/// Mirrors Discourse's own web behaviour — the discourse-solved plugin renders its
/// panel when `post_number === 1 && topic.accepted_answer`, so someone opening a long
/// solved topic sees the answer immediately instead of scrolling for it. The app
/// previously had the solved badge in topic lists and a banner on the answer post, but
/// nothing here, so the answer was only findable by scrolling.
///
/// Tapping anywhere on the card jumps to the answer, which is the web's primary
/// affordance (its header arrow and "Post #N" link both go there).
class SolutionSummaryCard extends StatelessWidget {
  final SiteContext siteContext;
  final DiscourseAcceptedAnswer answer;

  /// Jump to the answer post. Null disables the tap affordance — used when the
  /// destination cannot be resolved, so the card never looks tappable and then does
  /// nothing.
  final VoidCallback? onJumpToAnswer;

  const SolutionSummaryCard({
    super.key,
    required this.siteContext,
    required this.answer,
    this.onJumpToAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Green reads as "resolved" and matches the badge already used on the answer post
    // itself, so the two are recognisably the same concept.
    const accent = Colors.green;

    return Container(
      margin: EdgeInsets.only(top: DesignTokens.spacingM),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DesignTokens.radiusS),
        border: Border.all(color: accent.withValues(alpha: 0.40), width: 0.75),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onJumpToAnswer,
          borderRadius: BorderRadius.circular(DesignTokens.radiusS),
          child: Padding(
            padding: EdgeInsets.all(DesignTokens.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: DesignTokens.iconSizeM, color: accent),
                    SizedBox(width: DesignTokens.spacingS),
                    Text(
                      'Solution',
                      style: textTheme.titleSmall?.copyWith(
                        color: accent,
                        fontWeight: DesignTokens.fontWeightSemiBold,
                      ),
                    ),
                    const Spacer(),
                    if (onJumpToAnswer != null)
                      Icon(Icons.arrow_downward,
                          size: DesignTokens.iconSizeS,
                          color: colorScheme.onSurfaceVariant),
                  ],
                ),

                // Discourse omits the excerpt entirely when solved_quote_length is 0;
                // the web falls back to a title-only card, so this does too.
                if (answer.excerptHtml != null) ...[
                  SizedBox(height: DesignTokens.spacingS),
                  // RichTextContent has no line cap, and a long answer would push the
                  // rest of the topic off screen. Discourse caps the quote by
                  // solved_quote_length and offers expand/collapse; clipping to a few
                  // lines keeps the panel a summary, and the whole card taps through
                  // to the full post.
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 96),
                    child: ClipRect(
                      child: RichTextContent(
                        content: answer.excerptHtml!,
                        siteContext: siteContext,
                      ),
                    ),
                  ),
                ],

                SizedBox(height: DesignTokens.spacingS),
                Row(
                  children: [
                    UserAvatar(
                      username: answer.username,
                      iconUrl: _avatarUrl(),
                      radius: DesignTokens.iconSizeS,
                    ),
                    SizedBox(width: DesignTokens.spacingS),
                    Expanded(
                      child: Text(
                        _byline(),
                        style: textTheme.bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Discourse serves avatars as a template with a `{size}` placeholder and, in dev and
  /// on some hosts, a site-relative path. Same expansion the proxies do when they build
  /// post avatars.
  String? _avatarUrl() {
    final tpl = answer.avatarTemplate;
    if (tpl == null || tpl.isEmpty) return null;
    final filled = tpl.replaceAll('{size}', '60');
    return filled.startsWith('http') ? filled : '${siteContext.site.url}$filled';
  }

  /// "solved by X in post #N" — plus who marked it, when the forum exposes that
  /// (`show_who_marked_solved`; Discourse omits the accepter fields when it is off).
  String _byline() {
    final base =
        'Solved by ${answer.solverDisplayName} in post #${answer.postNumber}';
    final accepter = answer.accepterDisplayName;
    return accepter == null ? base : '$base  ·  marked by $accepter';
  }
}
