import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:get/get.dart';
import 'package:discourse_ui/utils/error_dialog.dart';
import 'package:discourse_ui/controllers/topic_controller.dart';
import '../../l10n/generated/app_localizations.dart';

class ForumActions {
  // Track if markAllAsRead is currently in progress to prevent concurrent calls
  // Static to prevent concurrent calls across all instances
  static bool _isMarkingAsRead = false;

  Future<void> markAllAsRead(BuildContext context, String forumId) async {
    // Prevent concurrent calls
    if (_isMarkingAsRead) {
      return;
    }

    _isMarkingAsRead = true;
    try {
      final forumProxy = SiteProxyFactory.getForumProxy();
      final result = await forumProxy.markAllAsRead(forumId);

      // Check if context is still valid before using it
      if (!context.mounted) {
        return;
      }

      if (result.result) {
        // Mark all as read was successful - reset the Unread page topic list
        if (Get.isRegistered<DiscourseUnreadTopicController>()) {
          final unreadController = Get.find<DiscourseUnreadTopicController>();
          await unreadController.resetAndReload();
        }

        // Double-check context is still valid before showing snackbar
        if (context.mounted) {
          try {
            final theme = Theme.of(context);
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.allForumTopicsHaveBeenMarkedAs,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onInverseSurface,
                  ),
                ),
                backgroundColor: theme.colorScheme.inverseSurface,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(8),
                duration: const Duration(seconds: 2),
              ),
            );
          } catch (e) {
            // Context became invalid between mounted check and usage
            // Silently ignore - the operation succeeded, just can't show UI feedback
          }
        }
      } else {
        showErrorDialog('Failed to mark all as read: ${result.resultText}');
      }
    } catch (e) {
      showErrorDialog('Failed to mark all as read: ' + e.toString());
    } finally {
      _isMarkingAsRead = false;
    }
  }

}
