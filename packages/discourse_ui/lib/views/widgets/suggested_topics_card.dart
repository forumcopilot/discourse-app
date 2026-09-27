import 'package:discourse_core/discourse_core.dart'
    show DiscoursePostProxy, DiscourseSuggestedTopic, DiscourseMessageDetails;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';

import '../../core/logging/app_logger.dart';
import '../../theme/design_tokens.dart';
import '../../utils/time_utils.dart';
import '../lists/posts_list.dart';
import '../post_page.dart';
import 'user_avatar.dart';
import 'unread_badge.dart';
import '../../l10n/generated/app_localizations.dart';

/// "Suggested Topics" footer card, rendered at the bottom of every
/// topic page on Discourse. Mirrors the web client's footer block so
/// users have the same browsing affordances on mobile.
class SuggestedTopicsCard extends StatefulWidget {
  final SiteContext siteContext;
  final String topicId;

  const SuggestedTopicsCard({
    super.key,
    required this.siteContext,
    required this.topicId,
  });

  @override
  State<SuggestedTopicsCard> createState() => _SuggestedTopicsCardState();
}

class _SuggestedTopicsCardState extends State<SuggestedTopicsCard> {
  List<DiscourseSuggestedTopic>? _topics;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant SuggestedTopicsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topicId != widget.topicId) {
      _load();
    }
  }

  Future<void> _load() async {
    final proxy = SiteProxyFactory.getPostProxy();
    if (proxy is! DiscoursePostProxy) {
      setState(() {
        _topics = const [];
        _isLoading = false;
      });
      return;
    }
    setState(() => _isLoading = true);
    try {
      final result = await proxy.getSuggestedTopicsAsync(widget.topicId);
      if (!mounted) return;
      setState(() {
        _topics = result;
        _isLoading = false;
      });
    } catch (e, st) {
      AppLogger.error('SuggestedTopicsCard load failed',
          error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _topics = const [];
        _isLoading = false;
      });
    }
  }

  void _open(DiscourseSuggestedTopic t) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostPage(
          siteContext: widget.siteContext,
          topicId: t.id.toString(),
          title: t.title,
          mode: PostsListMode.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final topics = _topics;

    if (_isLoading && topics == null) {
      return Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingL),
        child: Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          ),
        ),
      );
    }
    if (topics == null || topics.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: DesignTokens.spacingL),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: DesignTokens.opacityMediumLow),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.spacingL,
              DesignTokens.spacingL,
              DesignTokens.spacingL,
              DesignTokens.spacingS,
            ),
            child: Text(
              // A message's suggestions are other messages (Discourse's
              // suggested_topics.pm_title).
              DiscourseMessageDetails.isMessage(widget.topicId)
                  ? AppLocalizations.of(context)!.suggestedMessages
                  : AppLocalizations.of(context)!.suggestedTopics,
              // A page section heading, like the profile's sections.
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          for (var i = 0; i < topics.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: 72,
                color: colorScheme.outlineVariant,
              ),
            _SuggestedTopicTile(
              siteContext: widget.siteContext,
              topic: topics[i],
              onTap: () => _open(topics[i]),
            ),
          ],
          const SizedBox(height: DesignTokens.spacingL),
        ],
      ),
    );
  }
}

class _SuggestedTopicTile extends StatelessWidget {
  final SiteContext siteContext;
  final DiscourseSuggestedTopic topic;
  final VoidCallback onTap;

  const _SuggestedTopicTile({
    required this.siteContext,
    required this.topic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final lastActivity = topic.lastActivity;
    final username = topic.lastPosterUsername;
    final avatarUrl = topic.avatarUrl(siteContext.site.url);
    final replyCount = (topic.postsCount ?? 1) - 1;

    final unread = topic.hasUnread || topic.isNew;
    final metaStyle =
        textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant);

    // The topic list's row, without the category line (suggested topics
    // arrive without one): same avatar, headline and meta sizes, so a
    // topic looks the same wherever it's listed. It was 28dp / 14sp / 11sp.
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DesignTokens.spacingL,
          DesignTokens.spacingM,
          DesignTokens.spacingL,
          DesignTokens.spacingM,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Suggested topics can arrive without a poster; a topic glyph
            // in the avatar's place keeps the rows aligned (an avatar with
            // no name drew a "?").
            if (username != null && username.isNotEmpty)
              UserAvatar(
                username: username,
                iconUrl: avatarUrl,
                radius: DesignTokens.avatarRadiusM,
              )
            else
              CircleAvatar(
                radius: DesignTokens.avatarRadiusM,
                backgroundColor: colorScheme.surfaceContainerHighest,
                child: Icon(Icons.forum_outlined,
                    color: colorScheme.onSurfaceVariant),
              ),
            const SizedBox(width: DesignTokens.spacingL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    style: textTheme.titleMedium?.copyWith(
                      color: unread
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                      fontWeight: unread
                          ? DesignTokens.fontWeightMedium
                          : DesignTokens.fontWeightNormal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: DesignTokens.spacingXS),
                  Row(
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        size: DesignTokens.iconSizeS,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: DesignTokens.spacingXS),
                      Text('$replyCount', style: metaStyle),
                      if (lastActivity != null) ...[
                        const SizedBox(width: DesignTokens.spacingM),
                        Text(formatTimeAgo(lastActivity, context),
                            style: metaStyle),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (topic.isNew)
              Padding(
                padding: const EdgeInsets.only(
                    left: DesignTokens.spacingS, top: 6),
                child: Badge(
                  label: Text(AppLocalizations.of(context)!.newLabel),
                  backgroundColor: colorScheme.primary,
                  textColor: colorScheme.onPrimary,
                ),
              )
            else if (topic.hasUnread)
              const Padding(
                padding: EdgeInsets.only(left: DesignTokens.spacingS, top: 8),
                child: UnreadBadge(),
              ),
          ],
        ),
      ),
    );
  }
}
