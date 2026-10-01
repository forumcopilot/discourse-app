import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:discourse_ui/views/profile/user_card_sheet.dart';
import 'package:discourse_ui/views/widgets/post_actions.dart';
import 'package:discourse_ui/views/login_page.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';

class AvatarActions {
  /// A picture tapped on a post opens the person's user card, over the
  /// topic ([topicId] lets it offer their posts in it).
  void handleAvatarTap(BuildContext context, SiteContext siteContext, String userId, String userName, {PostActionsHandler? postActionsHandler, VoidCallback? onRefresh, int? topicId, String? avatarUrl}) {
    AppLogger.debug('Avatar tapped for user: $userId $userName');

    // Check if user is logged in
    if (!siteContext.isLoggedIn) {
      // Show login popup if not logged in
      if (postActionsHandler != null) {
        postActionsHandler.showPostLoginPrompt(context, onRefresh: onRefresh);
      } else {
        // Fallback to simple login prompt if no postActionsHandler provided
        _showSimpleLoginPrompt(context, siteContext);
      }
      return;
    }

    showUserCard(context,
        siteContext: siteContext,
        username: userName,
        topicId: topicId,
        avatarUrl: avatarUrl);
  }

  void _showSimpleLoginPrompt(BuildContext context, SiteContext siteContext) {

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.loginRequired,
        ),
        content: Text(
          AppLocalizations.of(context)!.pleaseLoginToViewUserProfiles,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              LoginPage.open(siteContext);
            },
            child: Text(AppLocalizations.of(context)!.loginTitle),
          ),
        ],
      ),
    );
  }
}
