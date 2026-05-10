import 'package:discourse_core/discourse_core.dart'
    show DiscoursePostProxy, DiscourseSuggestedTopic;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';

import '../../core/logging/app_logger.dart';
import '../../theme/design_tokens.dart';
import '../../utils/time_utils.dart';
import '../lists/posts_list.dart';
import '../post_page.dart';
import 'user_avatar.dart';

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
            color: colorScheme.outlineVariant.withOpacity(0.5),
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
              'Suggested Topics',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
          ),
          for (var i = 0; i < topics.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withOpacity(0.4),
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

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingL,
          vertical: DesignTokens.spacingM,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (username != null && username.isNotEmpty) ...[
              UserAvatar(
                username: username,
                iconUrl: avatarUrl,
                radius: 14,
              ),
              const SizedBox(width: DesignTokens.spacingM),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (topic.isNew)
                        Container(
                          margin: const EdgeInsets.only(
                              right: DesignTokens.spacingXS),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            'NEW',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        )
                      else if (topic.hasUnread)
                        Container(
                          margin: const EdgeInsets.only(
                              right: DesignTokens.spacingXS),
                          height: 6,
                          width: 6,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          topic.title,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: topic.hasUnread || topic.isNew
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.forum_outlined,
                        size: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$replyCount',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (lastActivity != null) ...[
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(
                          formatTimeAgo(lastActivity, context),
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
