import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:get/get.dart';

import '../controllers/site_controller.dart';
import '../core/logging/app_logger.dart';
import '../l10n/generated/app_localizations.dart';
import '../utils/snackbar_helper.dart';
import '../views/lists/posts_list.dart';
import '../utils/app_navigation.dart';
import '../views/chat/chat_channel_view.dart';
import '../views/forum_list_page.dart';
import '../views/group_detail_page.dart';
import '../views/post_page.dart';
import '../views/user_profile_page.dart';
import '../views/widgets/badge_detail_sheet.dart';
import 'site_proxy_service.dart';
import '../views/site_home_tab.dart';
import 'notification_route.dart';

/// Takes the reader to a [DiscourseNotificationRoute] inside a forum that is
/// already open.
///
/// One navigator for every way in: a push notification tapped, a link
/// pasted or shared into the app, a forum opened at a topic by its host
/// (`SingleForumBootstrapPage.route`). They name the same destinations, so
/// they land the same way.
class DiscourseRouteNavigator {
  DiscourseRouteNavigator._();

  /// Every destination opens over the page on screen, so Back returns to
  /// it. A notification used to replace the topic on screen, but only when
  /// that topic had been opened one particular way (from Latest, Unread or a
  /// category, not from Hot, New, Top or search), so whether Back returned to
  /// the topic being read looked random.
  static Future<void> open(
    SiteContext siteContext,
    DiscourseNotificationRoute route,
  ) async {
    switch (route.kind) {
      case NotificationRouteKind.post:
        final postId = route.postId;
        if (postId == null) return;
        final topicId = route.topicId ?? await _topicOfPost(siteContext, postId);
        if (topicId == null) return;
        AppLogger.debug('🧭 [DiscourseRouteNavigator] Topic $topicId at post $postId');
        _openTopic(siteContext,
            topicId: topicId,
            mode: PostsListMode.thread_by_post,
            anchorPostId: postId);
      case NotificationRouteKind.topicPage:
        final topicId = route.topicId;
        if (topicId == null) return;
        final postNumber = route.postNumber;
        if (postNumber != null && postNumber > 0) {
          AppLogger.debug('🧭 [DiscourseRouteNavigator] Topic $topicId at post #$postNumber');
          _openTopic(siteContext,
              topicId: topicId,
              mode: PostsListMode.goto_page,
              gotoPage: route.page ?? ((postNumber - 1) ~/ DiscourseNotificationRoute.postsPerPage) + 1,
              gotoPostNumber: postNumber);
        } else {
          // No position: where a tap on the topic in a list would go — the
          // reader's first unread post when signed in, as on the web.
          AppLogger.debug('🧭 [DiscourseRouteNavigator] Topic $topicId');
          _openTopic(siteContext,
              topicId: topicId,
              mode: siteContext.isLoggedIn
                  ? PostsListMode.first_unread
                  : PostsListMode.normal);
        }
      case NotificationRouteKind.conversation:
        final topicId = route.topicId;
        if (topicId == null) return;
        AppLogger.debug('🧭 [DiscourseRouteNavigator] Message $topicId');
        // A message is a topic: the topic page reads it, at the post the
        // notification names, else where the reader stopped.
        final postId = route.postId;
        _openTopic(siteContext,
            topicId: topicId,
            mode: postId != null && postId.isNotEmpty
                ? PostsListMode.thread_by_post
                : PostsListMode.first_unread,
            anchorPostId: postId);
      case NotificationRouteKind.chat:
        final channelId = route.chatChannelId;
        if (channelId == null) return;
        AppLogger.debug('🧭 [DiscourseRouteNavigator] Chat $channelId at ${route.chatMessageId}');
        AppNavigation.pushGlobal(ChatChannelScreen(
          siteContext: siteContext,
          channelId: channelId,
          targetMessageId: route.chatMessageId,
        ));
      case NotificationRouteKind.badge:
        final badgeId = route.badgeId;
        if (badgeId != null) await _openBadge(siteContext, badgeId);
      case NotificationRouteKind.groupInbox:
        final group = route.groupName;
        if (group == null) return;
        AppLogger.debug('🧭 [DiscourseRouteNavigator] Group inbox $group');
        AppNavigation.pushGlobal(ForumListPage(
            siteContext: siteContext,
            tab: SiteHomeTab.messages,
            messageGroup: group));
      case NotificationRouteKind.group:
        final group = route.groupName;
        if (group == null) return;
        AppNavigation.pushGlobal(
            GroupDetailPage(siteContext: siteContext, groupName: group));
      case NotificationRouteKind.profile:
        final username = route.username;
        if (username == null) return;
        AppNavigation.pushGlobal(
            UserProfilePage(siteContext: siteContext, userName: username));
      case NotificationRouteKind.notificationsTab:
        // On the forum's home, its Notifications tab; anywhere else the
        // list opens over the page on screen. Only switching the home's
        // tab looked like nothing happened from deeper in the forum, and
        // Back later landed on a tab the reader had not chosen.
        final controller = Get.isRegistered<DiscourseSiteController>()
            ? Get.find<DiscourseSiteController>()
            : null;
        final home = controller?.homeRoute;
        if (controller != null && home != null && home.isCurrent) {
          controller.requestHomeTab(SiteHomeTab.notifications);
        } else {
          AppNavigation.pushGlobal(ForumListPage(
              siteContext: siteContext, tab: SiteHomeTab.notifications));
        }
    }
  }

  /// A badge's sheet, found among the reader's own badges — a badge
  /// notification is always about the reader. Falls back to the
  /// notification list when the badge cannot be loaded.
  static Future<void> _openBadge(SiteContext siteContext, int badgeId) async {
    final username = siteContext.currentUsername;
    if (username != null && username.isNotEmpty) {
      try {
        final result =
            await SiteProxyService.getUserProxy().getUserBadgesAsync(username);
        final badge = result.badges.where((b) => b.id == badgeId).firstOrNull;
        final context = Get.context;
        if (badge != null && context != null && context.mounted) {
          await showBadgeDetailSheet(context, badge);
          return;
        }
      } catch (e) {
        AppLogger.debug('⚠️ [DiscourseRouteNavigator] Badge $badgeId: $e');
      }
    }
    await open(siteContext, const DiscourseNotificationRoute(
        kind: NotificationRouteKind.notificationsTab));
  }

  /// A post short link names only the post. PostPage keys its topic
  /// actions (subscribe, close, reply) on the topic id it is given, so the
  /// topic is looked up before the page opens rather than guessed.
  static Future<String?> _topicOfPost(
      SiteContext siteContext, String postId) async {
    final base = siteContext.site.url.replaceAll(RegExp(r'/+$'), '');
    final result =
        await SiteProxyFactory.getForumProxy().getIdByUrl('$base/p/$postId');
    final topicId = result.topicId;
    if (result.result && topicId != null && topicId.isNotEmpty) return topicId;
    AppLogger.debug(
        '⚠️ [DiscourseRouteNavigator] Post $postId: ${result.resultText}');
    final context = Get.context;
    if (context != null && context.mounted) {
      final l10n = AppLocalizations.of(context);
      final reason = result.resultText ?? '';
      SnackbarHelper.showError(
          context, l10n?.couldNotOpenLink(reason) ?? 'Could not open link: $reason');
    }
    return null;
  }

  /// Opens a topic over the page on screen.
  static void _openTopic(
    SiteContext siteContext, {
    required String topicId,
    required PostsListMode mode,
    String? anchorPostId,
    int? gotoPage,
    int? gotoPostNumber,
  }) {
    AppNavigation.pushGlobal(PostPage(
          siteContext: siteContext,
          topicId: topicId,
          title: '', // PostPage loads the real title with the thread.
          mode: mode,
          anchorPostId: anchorPostId,
          gotoPage: gotoPage,
          gotoPostNumber: gotoPostNumber,
        ));
  }
}
