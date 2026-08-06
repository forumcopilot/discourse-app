import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post.dart';
import 'package:forumcopilot_sdk/models/results/fc_private_conversation_result.dart';
import 'package:get/get.dart';
import 'package:discourse_ui/controllers/post_controller.dart';
import 'package:discourse_core/discourse_core.dart' show DiscoursePostProxy;
import 'package:discourse_ui/views/reply_page.dart';
import 'package:discourse_ui/views/edit_post_page.dart';
import 'package:discourse_ui/views/login_page.dart';
import 'package:discourse_ui/views/post_page.dart';
import 'package:discourse_ui/views/post_revision_page.dart';
import 'package:discourse_ui/views/lists/posts_list.dart';
// AuthController functionality now in SiteContext
import 'package:forumcopilot_sdk/context/site_context.dart';
import '../../theme/design_tokens.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';

class PostActionsHandler {
  final SiteContext siteContext;
  final PostController _postsController;
  VoidCallback? _defaultRefreshCallback;
  final String? fallbackForumId;

  /// Ids of posts/messages with a like/unlike request in flight — guards
  /// against a double-tap racing two requests (same pattern as
  /// `_handleBookmarkAction` in post_list_item.dart).
  final Set<String> _likeInFlight = {};

  PostActionsHandler(this._postsController, this.siteContext, {this.fallbackForumId});

  /// Set the default refresh callback for this handler
  void setDefaultRefreshCallback(VoidCallback? callback) {
    _defaultRefreshCallback = callback;
  }

  /// [onRefresh] may be called with no args (refresh current page) or with [scrollToPostId]
  /// to refresh by loading the thread at that post and scrolling to it (used after reply to stay on same screen).
  Future<void> handleReply(BuildContext context, String postId, String topicId, String topicTitle, void Function([String? scrollToPostId]) onRefresh) async {
    AppLogger.debug('🔵 [POST_ACTIONS] handleReply called');
    AppLogger.debug('   - postId: $postId');
    AppLogger.debug('   - topicId (parameter): $topicId');
    AppLogger.debug('   - topicTitle: $topicTitle');
    AppLogger.debug('   - fallbackForumId: $fallbackForumId');
    final data = _postsController.threadDataOutput.value;
    AppLogger.debug('   - threadDataOutput exists: ${data != null}');
    if (data != null) {
      AppLogger.debug('   - threadDataOutput.topic.id: ${data.topic.id}');
      AppLogger.debug('   - threadDataOutput.topic.forumId: ${data.topic.forumId}');
    }

    // Add check for can_reply
    if (!(data?.topic.canReply ?? false)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: DesignTokens.spacingM),
              Text(
                AppLocalizations.of(context)!.youCannotReplyToThisThread,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusS),
          ),
          margin: DesignTokens.paddingS,
          padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingL - DesignTokens.spacingXS),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // Use forumId from threadDataOutput, or fallback to the provided forumId (only if not empty)
    final forumId = data?.topic.forumId ?? (fallbackForumId != null && fallbackForumId!.isNotEmpty ? fallbackForumId : null);
    if (forumId == null || forumId.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: DesignTokens.spacingM),
              Text(
                AppLocalizations.of(context)!.pleaseWaitForThreadToLoad,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusS),
          ),
          margin: DesignTokens.paddingS,
          padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingL - DesignTokens.spacingXS),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // Use actual topicId from threadDataOutput if available
    // Only use the parameter topicId as fallback if threadDataOutput is null (not in thread_by_post mode)
    // This fixes the issue when navigating from notifications where topicId is a placeholder (postId)
    String? actualTopicId;
    if (data != null) {
      // threadDataOutput exists - must use topic.id from it (don't use placeholder)
      actualTopicId = data.topic.id;
      AppLogger.debug('🔵 [POST_ACTIONS] Using actualTopicId from threadDataOutput: $actualTopicId');
      // `topic.id` is non-nullable, so only the empty case is reachable.
      if (actualTopicId.isEmpty) {
        AppLogger.debug('⚠️ [POST_ACTIONS] actualTopicId from threadDataOutput is empty - showing error');
        // Thread data exists but topic.id is not loaded yet - wait for it
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(width: DesignTokens.spacingM),
                Text(
                  AppLocalizations.of(context)!.pleaseWaitForThreadToLoad,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            ),
            margin: DesignTokens.paddingS,
            padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingL - DesignTokens.spacingXS),
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }
    } else {
      // threadDataOutput is null - use parameter topicId (normal mode, not thread_by_post)
      actualTopicId = topicId;
      if (actualTopicId.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(width: DesignTokens.spacingM),
                Text(
                  AppLocalizations.of(context)!.pleaseWaitForThreadToLoad,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            ),
            margin: DesignTokens.paddingS,
            padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingL - DesignTokens.spacingXS),
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }
    }

    AppLogger.debug('🔵 [POST_ACTIONS] Navigating to ReplyPage with:');
    AppLogger.debug('   - threadId: ${actualTopicId}');
    AppLogger.debug('   - forumId: $forumId');
    AppLogger.debug('   - topicTitle: $topicTitle');
    AppLogger.debug('   - postId: $postId');
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => ReplyPage(
          siteContext: siteContext,
          threadId: actualTopicId!,
          forumId: forumId,
          topicTitle: topicTitle,
          postId: postId,
          isQuote: false,
        ),
      ),
    );
    AppLogger.debug('🔵 [POST_ACTIONS] ReplyPage returned: $result');

    if (result != null && context.mounted) {
      // Check if result is a postId (String) or just success (bool)
      if (result is String && result.isNotEmpty) {
        // Stay on same screen: refresh and scroll to the new post (consistent with conversation reply).
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) onRefresh(result);
        });
      } else if (result == true) {
        // Fallback: if postId wasn't available, just refresh.
        // Defer to next frame to avoid setState/markNeedsBuild while widget tree is locked after pop.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) onRefresh();
        });
      } else {
        // Fallback: refresh if we got something unexpected
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) onRefresh();
        });
      }
    } else if (result == null && context.mounted) {
      // If result is null, refresh to show the new post.
      // Defer to next frame to avoid setState/markNeedsBuild while widget tree is locked after pop.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) onRefresh();
      });
    } else if (result == false && context.mounted) {
      // Show error message
      // Capture ScaffoldMessengerState to ensure dismiss button works correctly
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: DesignTokens.spacingM),
              Expanded(
                child: Text(
                  'Failed to post reply. Please try again.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusS),
          ),
          margin: DesignTokens.paddingS,
          padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingL - DesignTokens.spacingXS),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: AppLocalizations.of(context)?.dismiss ?? 'Dismiss',
            textColor: Theme.of(context).colorScheme.onErrorContainer,
            onPressed: () {
              scaffoldMessenger.hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  /// [onRefresh] may be called with no args or with [scrollToPostId] to refresh and scroll to that post (same as handleReply).
  Future<void> handleQuote(BuildContext context, String postId, String authorName, String postText, String topicId, String topicTitle, void Function([String? scrollToPostId]) onRefresh) async {
    AppLogger.debug('🔵 [POST_ACTIONS] handleQuote called');
    AppLogger.debug('   - postId: $postId');
    AppLogger.debug('   - topicId (parameter): $topicId');
    AppLogger.debug('   - topicTitle: $topicTitle');
    AppLogger.debug('   - fallbackForumId: $fallbackForumId');
    final data = _postsController.threadDataOutput.value;
    AppLogger.debug('   - threadDataOutput exists: ${data != null}');
    if (data != null) {
      AppLogger.debug('   - threadDataOutput.topic.id: ${data.topic.id}');
      AppLogger.debug('   - threadDataOutput.topic.forumId: ${data.topic.forumId}');
    }
    
    // Use forumId from threadDataOutput, or fallback to the provided forumId (only if not empty)
    final forumId = data?.topic.forumId ?? (fallbackForumId != null && fallbackForumId!.isNotEmpty ? fallbackForumId : null);
    AppLogger.debug('🔵 [POST_ACTIONS] Resolved forumId: $forumId');
    if (forumId == null || forumId.isEmpty) {
      AppLogger.debug('⚠️ [POST_ACTIONS] forumId is null or empty - showing error');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please wait for the thread to load',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
          ),
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(8),
        ),
      );
      return;
    }

    // Use actual topicId from threadDataOutput if available
    // Only use the parameter topicId as fallback if threadDataOutput is null (not in thread_by_post mode)
    String? actualTopicId;
    if (data != null) {
      // threadDataOutput exists - must use topic.id from it (don't use placeholder)
      actualTopicId = data.topic.id;
      AppLogger.debug('🔵 [POST_ACTIONS] Using actualTopicId from threadDataOutput: $actualTopicId');
      // `topic.id` is non-nullable, so only the empty case is reachable.
      if (actualTopicId.isEmpty) {
        AppLogger.debug('⚠️ [POST_ACTIONS] actualTopicId from threadDataOutput is empty - showing error');
        // Thread data exists but topic.id is not loaded yet - wait for it
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please wait for the thread to load',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
            ),
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8),
          ),
        );
        return;
      }
    } else {
      // threadDataOutput is null - use parameter topicId (normal mode, not thread_by_post)
      actualTopicId = topicId;
      AppLogger.debug('🔵 [POST_ACTIONS] Using actualTopicId from parameter (threadDataOutput is null): $actualTopicId');
      if (actualTopicId.isEmpty) {
        AppLogger.debug('⚠️ [POST_ACTIONS] actualTopicId from parameter is empty - showing error');
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please wait for the thread to load',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
            ),
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8),
          ),
        );
        return;
      }
    }

    AppLogger.debug('🔵 [POST_ACTIONS] Navigating to ReplyPage (quote) with:');
    AppLogger.debug('   - threadId: ${actualTopicId}');
    AppLogger.debug('   - forumId: $forumId');
    AppLogger.debug('   - topicTitle: $topicTitle');
    AppLogger.debug('   - postId: $postId');
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => ReplyPage(
          siteContext: siteContext,
          threadId: actualTopicId!,
          forumId: forumId,
          quotePostId: postId,
          quoteText: postText,
          quoteAuthor: authorName,
          topicTitle: topicTitle,
          postId: postId,
          isQuote: true,
        ),
      ),
    );
    AppLogger.debug('🔵 [POST_ACTIONS] ReplyPage (quote) returned: $result');

    if (result != null && context.mounted) {
      if (result is String && result.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) onRefresh(result);
        });
      } else if (result == true) {
        // Defer refresh to next frame to avoid setState/markNeedsBuild while widget tree is locked after pop.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) onRefresh();
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) onRefresh();
        });
      }
    } else if (result == null && context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) onRefresh();
      });
    }
  }

  Future<void> handleEdit(BuildContext context, String postId, String currentText, String topicTitle, String topicId, String? forumId, VoidCallback onRefresh) async {
    AppLogger.debug('Handling edit of post: $postId');
    AppLogger.debug('Current text: $currentText');

    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostPage(
          siteContext: siteContext,
          postId: postId,
          topicTitle: topicTitle,
          forumId: forumId, // Pass forum ID if available
        ),
      ),
    );

    if (result != null && context.mounted) {
      // Check if result is a postId (String) or just success (bool)
      if (result is String && result.isNotEmpty) {
        // Navigate to the edited post using thread_by_post mode
        // Add a small delay to allow the server to process the update
        // Schedule navigation after current frame and delay
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // Small delay to ensure the post update is processed on the server
          await Future.delayed(const Duration(milliseconds: 500));
          if (context.mounted) {
            // Use Navigator.pushReplacement to ensure the page is properly reloaded
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PostPage(
                  key: ValueKey('post_${topicId}_${result}'),
                  siteContext: siteContext,
                  topicId: topicId,
                  title: topicTitle,
                  mode: PostsListMode.thread_by_post,
                  anchorPostId: result,
                  forumId: forumId,
                ),
              ),
            );
          } else {
            onRefresh();
          }
        });
      } else if (result == true) {
        // Fallback: if postId wasn't available, just refresh
        onRefresh();
      } else {
        // Fallback: refresh if we got something unexpected
        onRefresh();
      }
    } else if (result == false && context.mounted) {
      // Show error message
      // Capture ScaffoldMessengerState to ensure dismiss button works correctly
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: DesignTokens.spacingM),
              Expanded(
                child: Text(
                  'Failed to update post. Please try again.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusS),
          ),
          margin: DesignTokens.paddingS,
          padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingL - DesignTokens.spacingXS),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: AppLocalizations.of(context)?.dismiss ?? 'Dismiss',
            textColor: Theme.of(context).colorScheme.onErrorContainer,
            onPressed: () {
              scaffoldMessenger.hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  Future<void> handleDelete(BuildContext context, String postId) async {
    AppLogger.debug('Handling delete of post: $postId');

    final TextEditingController reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    int deleteMode = 1; // Default to soft delete

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)?.deletePost ?? 'Delete Post'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RadioListTile<int>(
                      title: Text(AppLocalizations.of(context)!.softDelete),
                      subtitle: Text(AppLocalizations.of(context)!.postCanBeRestoredLater),
                      value: 1,
                      groupValue: deleteMode,
                      onChanged: (value) {
                        setState(() {
                          deleteMode = value!;
                        });
                      },
                    ),
                    RadioListTile<int>(
                      title: Text(AppLocalizations.of(context)!.hardDelete),
                      subtitle: Text(AppLocalizations.of(context)!.postWillBePermanentlyDeleted),
                      value: 2,
                      groupValue: deleteMode,
                      onChanged: (value) {
                        setState(() {
                          deleteMode = value!;
                        });
                      },
                    ),
                    const SizedBox(height: DesignTokens.spacingL),
                    TextFormField(
                      controller: reasonController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.reasonForDeletion,
                        hintText: AppLocalizations.of(context)!.enterReasonForDeletingPost,
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context)!.pleaseEnterReasonForDeletion;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      Navigator.of(context).pop({
                        'reason': reasonController.text.trim(),
                        'mode': deleteMode,
                      });
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  child: Text(AppLocalizations.of(context)?.deletePost ?? 'Delete Post'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && context.mounted) {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
              const SizedBox(width: DesignTokens.spacingM),
              Text(
                AppLocalizations.of(context)?.deletingPost ?? 'Deleting post...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          duration: const Duration(seconds: 30), // Longer duration for loading
        ),
      );

      try {
        final moderationProxy = SiteProxyFactory.getModerationProxy();
        await moderationProxy.deletePostAsync(
          postId,
          result['mode'] as int,
          result['reason'] as String,
        );

        if (context.mounted) {
          // Hide loading snackbar
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Text(
                    'Post deleted successfully',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        ),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.inverseSurface,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        AppLogger.debug('Error deleting post: $e');
        if (context.mounted) {
          // Capture ScaffoldMessengerState to ensure dismiss button works correctly
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          // Hide loading snackbar
          scaffoldMessenger.hideCurrentSnackBar();

          // Show error message
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Expanded(
                    child: Text(
                      'Failed to delete post: ${e.toString()}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: AppLocalizations.of(context)?.dismiss ?? 'Dismiss',
                textColor: Theme.of(context).colorScheme.onErrorContainer,
                onPressed: () {
                  scaffoldMessenger.hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> handleReport(BuildContext context, String postId) async {
    AppLogger.debug('Handling report of post: $postId');

    final TextEditingController reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.reportPost ?? 'Report Post'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.pleaseProvideReasonForReporting,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.reason,
                    hintText: AppLocalizations.of(context)!.enterReasonForReportingPost,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterReason;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(reasonController.text.trim());
                }
              },
              child: Text(AppLocalizations.of(context)!.submitReport),
            ),
          ],
        );
      },
    );

    if (result != null && context.mounted) {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
              const SizedBox(width: DesignTokens.spacingM),
              Text(
                'Submitting report...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusS),
          ),
          margin: DesignTokens.paddingS,
          padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingL - DesignTokens.spacingXS),
          duration: const Duration(seconds: 30), // Longer duration for loading
        ),
      );

      try {
        AppLogger.debug('Submitting report for post: $postId with reason: $result');
        final postProxy = SiteProxyFactory.getPostProxy();
        final reportResult = await postProxy.reportPostAsync(postId, result);

        AppLogger.debug('Report result: ${reportResult.result}, resultText: ${reportResult.resultText}');

        if (context.mounted) {
          // Hide loading snackbar
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          // Check if the report was successful
          if (reportResult.result) {
            AppLogger.debug('Report submitted successfully for post: $postId');
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                    const SizedBox(width: DesignTokens.spacingM),
                    Text(
                      'Report submitted successfully',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onInverseSurface,
                          ),
                    ),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                duration: const Duration(seconds: 4),
              ),
            );
          } else {
            // Show error message with server response
            final errorMessage = (reportResult.resultText != null && reportResult.resultText!.isNotEmpty) ? reportResult.resultText! : 'Failed to submit report';

            AppLogger.debug('Report failed for post: $postId, error: $errorMessage');
            // Capture ScaffoldMessengerState to ensure dismiss button works correctly
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: DesignTokens.spacingM),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: AppLocalizations.of(context)?.dismiss ?? 'Dismiss',
                  textColor: Theme.of(context).colorScheme.onErrorContainer,
                  onPressed: () {
                    scaffoldMessenger.hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        }
      } catch (e) {
        AppLogger.debug('Exception occurred while reporting post: $postId, error: $e');
        if (context.mounted) {
          // Capture ScaffoldMessengerState to ensure dismiss button works correctly
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          // Hide loading snackbar
          scaffoldMessenger.hideCurrentSnackBar();

          // Show error message
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Expanded(
                    child: Text(
                      'Failed to submit report: ${e.toString()}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: AppLocalizations.of(context)?.dismiss ?? 'Dismiss',
                textColor: Theme.of(context).colorScheme.onErrorContainer,
                onPressed: () {
                  scaffoldMessenger.hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      }
    }
  }

  /// Opens the Discourse edit-history viewer for [postId]. Posts that
  /// were never edited (or whose history isn't visible to the viewer)
  /// get a friendly message from the page itself, so callers can offer
  /// this action unconditionally.
  Future<void> handleViewHistory(BuildContext context, String postId) async {
    AppLogger.debug('Handling view history of post: $postId');
    final numericPostId = int.tryParse(postId);
    if (numericPostId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Edit history is not available for this post',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
          ),
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(8),
        ),
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostRevisionPage(
          siteContext: siteContext,
          postId: numericPostId,
        ),
      ),
    );
  }

  /// Toggles the Discourse **wiki** flag on a post (community-editable).
  /// Server-side permission is `guardian.ensure_can_wiki!` (author at
  /// TL3+ or staff) — non-privileged callers get the server's rejection
  /// message in the error snackbar.
  Future<void> handleToggleWiki(
      BuildContext context, String postId, bool wiki) async {
    AppLogger.debug('Handling wiki toggle of post: $postId → $wiki');
    final numericPostId = int.tryParse(postId);
    final postProxy = SiteProxyFactory.getPostProxy();
    if (numericPostId == null || postProxy is! DiscoursePostProxy) {
      return;
    }

    bool ok;
    String errText;
    try {
      final result = await postProxy.setWikiAsync(numericPostId, wiki);
      ok = result.result;
      errText = result.resultText;
    } catch (e) {
      ok = false;
      errText = e.toString();
    }

    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
              const SizedBox(width: DesignTokens.spacingM),
              Text(
                wiki ? 'Post is now a wiki' : 'Wiki removed from post',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: DesignTokens.spacingM),
              Expanded(
                child: Text(
                  errText.isNotEmpty
                      ? errText
                      : 'Failed to change wiki status',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: AppLocalizations.of(context)?.dismiss ?? 'Dismiss',
            textColor: Theme.of(context).colorScheme.onErrorContainer,
            onPressed: () {
              scaffoldMessenger.hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  // --- Like/Unlike Post ---
  Future<void> handleLike({
    required BuildContext context,
    required FCPost post,
    required SiteContext siteContext,
    required VoidCallback onRefresh,
    required ValueSetter<bool> setIsLiked,
    required ValueSetter<int> setLikeCount,
    required bool isLiked,
  }) async {
    if (!siteContext.isLoggedIn) {
      showPostLoginPrompt(context, onRefresh: onRefresh);
      return;
    }
    // In-flight guard: ignore taps while a request for this post is pending.
    if (_likeInFlight.contains(post.id)) return;
    _likeInFlight.add(post.id);
    // Optimistically update UI. `likesInfo` is no longer the source of
    // truth for the count (the proxy leaves it empty rather than
    // padding it with placeholder actors), so move `likeCount` itself
    // and mirror it onto the post so rebuilds keep the new value.
    final wasLiked = isLiked;
    final previousCount = post.likeCount;
    setIsLiked(!isLiked);
    final optimisticCount =
        wasLiked ? (previousCount > 0 ? previousCount - 1 : 0) : previousCount + 1;
    post.likeCount = optimisticCount;
    setLikeCount(optimisticCount);
    // Removed onRefresh() call - local state updates are sufficient for like actions
    bool ok;
    String? errText;
    try {
      final socialProxy = SiteProxyFactory.getSocialProxy();
      if (wasLiked) {
        // Unlike the post
        final result = await socialProxy.unlikePostAsync(post.id);
        ok = result.result;
        errText = result.resultText;
      } else {
        // Like the post
        final result = await socialProxy.likePostAsync(post.id);
        ok = result.result;
        errText = result.resultText;
      }
    } catch (e) {
      ok = false;
      errText = e.toString();
    } finally {
      _likeInFlight.remove(post.id);
    }
    if (!ok) {
      // Revert UI if the request threw OR the server said result=false
      setIsLiked(wasLiked);
      post.likeCount = previousCount;
      setLikeCount(previousCount);
      // Removed onRefresh() call - local state updates are sufficient for like actions
      if (context.mounted) {
        final reason = errText?.isNotEmpty == true ? errText! : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(wasLiked
            ? (AppLocalizations.of(context)?.failedToUnlikePost(reason) ?? 'Failed to unlike post: $reason')
            : (AppLocalizations.of(context)?.failedToLikePost(reason) ?? 'Failed to like post: $reason'))),
        );
      }
    }
  }

  // --- Like/Unlike Conversation Message ---
  Future<void> handleLikeConversationMessage({
    required BuildContext context,
    required FCConversationMessage message,
    required SiteContext siteContext,
    required VoidCallback onRefresh,
    required ValueSetter<bool> setIsLiked,
    required ValueSetter<int> setLikeCount,
    required bool isLiked,
  }) async {
    if (!siteContext.isLoggedIn) {
      showPostLoginPrompt(context, onRefresh: onRefresh);
      return;
    }
    // In-flight guard: ignore taps while a request for this message is pending.
    if (_likeInFlight.contains(message.messageId)) return;
    _likeInFlight.add(message.messageId);
    // Optimistically update UI — count-driven, same as posts.
    final wasLiked = isLiked;
    final previousCount = message.likeCount;
    setIsLiked(!isLiked);
    final optimisticCount =
        wasLiked ? (previousCount > 0 ? previousCount - 1 : 0) : previousCount + 1;
    message.likeCount = optimisticCount;
    setLikeCount(optimisticCount);
    bool ok;
    String? errText;
    try {
      final socialProxy = SiteProxyFactory.getSocialProxy();
      // Discourse PM messages are just posts under the hood, so the same
      // like/unlike endpoint handles them. (Stock Discourse PMs don't
      // support likes — this only fires on forums where the host has
      // enabled likes in PMs.)
      if (wasLiked) {
        final result = await socialProxy.unlikePostAsync(message.messageId);
        ok = result.result;
        errText = result.resultText;
      } else {
        final result = await socialProxy.likePostAsync(message.messageId);
        ok = result.result;
        errText = result.resultText;
      }
    } catch (e) {
      ok = false;
      errText = e.toString();
    } finally {
      _likeInFlight.remove(message.messageId);
    }
    if (!ok) {
      // Revert UI if the request threw OR the server said result=false
      setIsLiked(wasLiked);
      message.likeCount = previousCount;
      setLikeCount(previousCount);
      if (context.mounted) {
        final reason = errText?.isNotEmpty == true ? errText! : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(wasLiked
            ? (AppLocalizations.of(context)?.failedToUnlikePost(reason) ?? 'Failed to unlike message: $reason')
            : (AppLocalizations.of(context)?.failedToLikePost(reason) ?? 'Failed to like message: $reason'))),
        );
      }
    }
  }

  /// Shows login prompt for restricted content and handles post refresh after login
  void showPostLoginPrompt(BuildContext context, {VoidCallback? onRefresh}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Use provided callback or default callback
    final refreshCallback = onRefresh ?? _defaultRefreshCallback;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Login Required',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)?.pleaseLoginToAccessContent ?? 'Please login to access this content and interact with posts.',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Navigate to login page and wait for result
              final result = await Get.to(() => LoginPage(siteContext: siteContext));
              // If login was successful, refresh the post view
              if (result == true && refreshCallback != null) {
                // Wait for authentication state to be fully updated
                // AuthController functionality now in SiteContext
                // Wait for the auth state to be true (logged in) with timeout
                try {
                  await Future.doWhile(() async {
                    await Future.delayed(const Duration(milliseconds: 100));
                    return !siteContext.isLoggedIn;
                  }).timeout(const Duration(seconds: 5));
                } catch (e) {
                  // If timeout occurs, proceed anyway
                  AppLogger.debug('Timeout waiting for auth state update: $e');
                }
                // Add a small additional delay to ensure all UI updates are complete
                await Future.delayed(const Duration(milliseconds: 200));
                refreshCallback();
              }
            },
            child: Text(
              'Login',
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
