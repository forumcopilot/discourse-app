import 'package:flutter/material.dart';
import 'package:discourse_core/discourse_core.dart' show DiscourseUserProxy;
import 'package:discourse_ui/views/widgets/activity_row.dart';
import 'package:discourse_ui/views/widgets/profile_section.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:get/get.dart';
import 'package:discourse_ui/views/post_page.dart';
import 'package:discourse_ui/views/lists/posts_list.dart';
import 'package:discourse_ui/controllers/login_controller.dart';
import 'package:discourse_ui/views/login_page.dart';
import '../../theme/design_tokens.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';

class UserRepliedPosts extends StatefulWidget {
  final SiteContext siteContext;
  final String? userId;
  final String? userName;

  /// Which `/user_actions.json` feed to show — 5 (replies) by default.
  /// Every filter returns the same action shape, so this one widget backs
  /// all of the profile's activity tabs.
  final int actionFilter;

  /// Shown when the feed is empty; the wording differs per tab
  /// ("No replies yet" reads wrong under Likes).
  final String? emptyLabel;

  const UserRepliedPosts({
    super.key,
    required this.siteContext,
    this.userId,
    this.userName,
    this.actionFilter = 5,
    this.emptyLabel,
  });

  @override
  State<UserRepliedPosts> createState() => _UserRepliedPostsState();
}

class _UserRepliedPostsState extends State<UserRepliedPosts> {
  List<FCUserReply>? _recentPosts;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _total = 0;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _fetchRecentPosts();
  }

  @override
  void didUpdateWidget(UserRepliedPosts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId || oldWidget.userName != widget.userName) {
      _fetchRecentPosts();
    }
  }

  // Public method to check if should load more based on scroll position
  // This is called from parent scroll controllers
  void checkAndLoadMore(double scrollPosition, double maxScrollExtent) {
    if (!mounted) return;
    if (scrollPosition >= maxScrollExtent - 300 && !_isLoadingMore && _hasMorePosts && _recentPosts != null) {
      _fetchRecentPosts(loadMore: true);
    }
  }

  Future<void> _fetchRecentPosts({bool loadMore = false}) async {
    if (widget.userName == null && widget.userId == null) {
      setState(() {
        _error = 'No user specified';
        _isLoading = false;
      });
      return;
    }

    if (loadMore) {
      if (_isLoadingMore || _recentPosts == null) return;
      setState(() {
        _isLoadingMore = true;
        _error = null;
      });
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
        _recentPosts = null;
        _total = 0;
      });
    }

    try {
      final currentCount = _recentPosts?.length ?? 0;
      final startNum = loadMore ? currentCount : 0;
      final lastNum = startNum + _pageSize - 1;

      AppLogger.debug('Fetching recent posts for user: ${widget.userName ?? widget.userId}, startNum: $startNum, lastNum: $lastNum');
      final proxy = SiteProxyFactory.getUserProxy();
      // Discourse-only: user_actions filters are not on the SDK contract.
      final result = proxy is DiscourseUserProxy
          ? await proxy.getUserActionsAsync(startNum, widget.userName,
              actionFilter: widget.actionFilter)
          : await proxy.getUserReplyPostAsync(
              startNum, lastNum, null, widget.userName, widget.userId);
      AppLogger.debug('Result from getUserReplyPostAsync: total: ${result.total}, posts count: ${result.posts.length}');

      if (mounted) {
        setState(() {
          if (loadMore) {
            _recentPosts = [...(_recentPosts ?? []), ...result.posts];
          } else {
            _recentPosts = result.posts;
            _total = result.total;
          }
          _isLoading = false;
          _isLoadingMore = false;
          // Update total if we got a new value
          if (result.total > _total) {
            _total = result.total;
          }
        });
      }
    } catch (e, stack) {
      AppLogger.debug('Error in _fetchRecentPosts: ${e.toString()}');
      AppLogger.debug('Stack trace: $stack');
      if (mounted) {
        setState(() {
          _error = 'Failed to load recent posts';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  bool get _hasMorePosts {
    if (_recentPosts == null) return false;
    return _recentPosts!.length < _total;
  }

  @override
  Widget build(BuildContext context) {
    // Hide the entire section if there's an error or no posts (and not loading)
    final isEmpty =
        !_isLoading && (_recentPosts == null || _recentPosts!.isEmpty);
    if (_error != null || isEmpty) {
      // Rendering nothing was fine while Replies was the only feed — an
      // empty profile simply had no section. With tabs it is not: tapping
      // Likes or Solved and getting a blank page reads as broken rather
      // than as "none yet". Say so when the caller gave us the wording.
      final label = widget.emptyLabel;
      if (_error == null && label != null) {
        return Padding(
          padding: DesignTokens.paddingL,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // No heading of its own. This used to print "Recent Posts", which was
    // true when replies were the only feed here; it now sits under the
    // Activity chips, which already name what is being shown — and said
    // "Recent Posts" over the Likes and Solved feeds too.
    return _buildContent(context, colorScheme, textTheme);
  }

  Future<void> _navigateToPost(FCUserReply post) async {
    try {
      if (!widget.siteContext.isLoggedIn) {
        if (!Get.isRegistered<DiscourseLoginController>()) {
          Get.put(DiscourseLoginController());
        }
        final loginController = Get.find<DiscourseLoginController>();
        final loginResult = await loginController.attemptAutomaticLogin(widget.siteContext);
        if (!loginResult.success && loginResult.hadCredentials && Get.currentRoute != '/LoginPage') {
          await Get.to(() => LoginPage(siteContext: widget.siteContext));
        }
        if (!widget.siteContext.isLoggedIn) {
          AppLogger.debug('UserRepliedPosts: proceeding to thread as guest after login screen');
        }
      }
      // Validate required parameters
      if (post.topicId.isEmpty || post.topicTitle.isEmpty) {
        AppLogger.debug('Invalid post information: topic_id or topic_title is empty');
        return;
      }

      // Navigate to the specific post if post_id is available, otherwise use first_unread mode
      if (post.postId.isNotEmpty) {
        AppLogger.debug('Navigating to specific post: ${post.postId} in topic: ${post.topicId}');
        Get.to(() => PostPage(
              siteContext: widget.siteContext,
              topicId: post.topicId,
              title: post.topicTitle,
              mode: PostsListMode.thread_by_post,
              anchorPostId: post.postId,
              forumId: post.forumId.isNotEmpty ? post.forumId : null,
            ));
      } else {
        AppLogger.debug('No post_id available, navigating to latest posts in topic: ${post.topicId}');
        Get.to(() => PostPage(
              siteContext: widget.siteContext,
              topicId: post.topicId,
              title: post.topicTitle,
              mode: PostsListMode.first_unread,
              forumId: post.forumId.isNotEmpty ? post.forumId : null,
            ));
      }
    } catch (e) {
      AppLogger.debug('Error navigating to post: $e');
    }
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    if (_isLoading) {
      return const Padding(
        padding: DesignTokens.paddingXXL,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _recentPosts!.length; i++) ...[
          if (i > 0) const ProfileRowDivider(),
          _buildPostItem(context, _recentPosts![i]),
        ],
        if (_hasMorePosts)
          Padding(
            padding: DesignTokens.paddingL,
            child: _isLoadingMore ? const Center(child: CircularProgressIndicator()) : const SizedBox.shrink(),
          ),
      ],
    );
  }

  /// Whether this row's post was written by somebody other than the
  /// profile owner. True only on the Likes feed in practice: the other
  /// filters return the owner's own posts, where an avatar and name would
  /// repeat the same person down the whole page.
  bool _isOtherAuthor(FCUserReply post) {
    final author = post.authorName.trim();
    final owner = (widget.userName ?? '').trim();
    if (author.isEmpty) return false;
    if (owner.isEmpty) return true;
    return author.toLowerCase() != owner.toLowerCase();
  }

  Widget _buildPostItem(BuildContext context, FCUserReply post) {
    return ActivityRow(
      title: post.topicTitle.isNotEmpty ? post.topicTitle : 'Unknown Topic',
      excerpt: post.shortContent,
      time: post.postTime,
      // `replyNumber` is the post's position in its topic, not a count of
      // replies — /user_actions.json has no reply count to give.
      postNumber: post.replyNumber,
      attribution: _isOtherAuthor(post)
          ? ActivityAttribution(
              username: post.authorName,
              avatarUrl: post.authorIconUrl,
            )
          : null,
      onTap: () => _navigateToPost(post),
    );
  }

}
