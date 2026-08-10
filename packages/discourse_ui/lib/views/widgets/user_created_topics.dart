import 'package:flutter/material.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';
import 'package:discourse_ui/views/post_page.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/models/results/fc_user_result.dart';

import '../../theme/design_tokens.dart';
import 'activity_row.dart';
import 'empty_state_view.dart';
import 'profile_section.dart';

/// Phase 5.24 — sibling of `UserRepliedPosts` that lists topics
/// **created** by the given user, backed by
/// `DiscourseUserProxy.getUserTopicAsync` (which hits
/// `/user_actions.json?filter=4`).
///
/// Lives alongside the existing replies feed on user-profile pages.
/// The parent (`UserProfilePage` or `ProfileTab`) owns the
/// "Replies / Topics" toggle and conditionally renders this widget
/// instead of `UserRepliedPosts` when the Topics tab is active —
/// keeps both widgets stateless w.r.t. the toggle and lets each
/// fetch only when surfaced.
class UserCreatedTopics extends StatefulWidget {
  final SiteContext siteContext;
  final String? userId;
  final String? userName;

  const UserCreatedTopics({
    super.key,
    required this.siteContext,
    this.userId,
    this.userName,
  });

  @override
  State<UserCreatedTopics> createState() => _UserCreatedTopicsState();
}

class _UserCreatedTopicsState extends State<UserCreatedTopics> {
  List<FCUserTopic>? _topics;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(UserCreatedTopics oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userName != widget.userName ||
        oldWidget.userId != widget.userId) {
      _fetch();
    }
  }

  Future<void> _fetch() async {
    if (widget.userName == null && widget.userId == null) {
      setState(() {
        _error = 'No user specified';
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final proxy = SiteProxyFactory.getUserProxy();
      final result = await proxy.getUserTopicAsync(
        widget.userName,
        widget.userId,
      );
      if (!mounted) return;
      setState(() {
        _topics = result.list;
        _loading = false;
        if (!result.result &&
            (result.resultText?.isNotEmpty ?? false)) {
          _error = result.resultText;
        }
      });
    } catch (e, stack) {
      AppLogger.debug('UserCreatedTopics fetch error: $e');
      AppLogger.debug('Stack: $stack');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load topics';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _topics == null) {
      return const Padding(
        padding: EdgeInsets.all(DesignTokens.spacingXL),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null && (_topics == null || _topics!.isEmpty)) {
      return EmptyStateView(
        icon: Icons.topic_outlined,
        message: _error!,
      );
    }
    final topics = _topics ?? const [];
    if (topics.isEmpty) {
      return const EmptyStateView(
        icon: Icons.topic_outlined,
        message: 'No topics started yet.',
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: topics.length,
      separatorBuilder: (_, __) => const ProfileRowDivider(),
      itemBuilder: (_, i) => ActivityRow(
        title: topics[i].topicTitle,
        excerpt: topics[i].shortContent,
        time: topics[i].postTime,
        replyCount: topics[i].replyCount,
        viewCount: topics[i].viewCount,
        onTap: () => _open(topics[i]),
      ),
    );
  }

  void _open(FCUserTopic topic) {
    if (topic.topicId.isEmpty || topic.topicTitle.isEmpty) {
      AppLogger.debug(
          'UserCreatedTopics: missing topic id/title, skipping nav');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostPage(
          siteContext: widget.siteContext,
          topicId: topic.topicId,
          title: topic.topicTitle,
          forumId: topic.forumId.isNotEmpty ? topic.forumId : null,
        ),
      ),
    );
  }
}
