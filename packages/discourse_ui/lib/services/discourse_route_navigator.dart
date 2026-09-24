import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:get/get.dart';

import '../controllers/site_controller.dart';
import '../core/logging/app_logger.dart';
import '../l10n/generated/app_localizations.dart';
import '../utils/snackbar_helper.dart';
import '../views/lists/posts_list.dart';
import '../views/post_page.dart';
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
      case NotificationRouteKind.notificationsTab:
        if (Get.isRegistered<DiscourseSiteController>()) {
          Get.find<DiscourseSiteController>()
              .requestHomeTab(SiteHomeTab.notifications);
        }
    }
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

  /// Open a topic, replacing the one on screen rather than stacking onto it.
  static void _openTopic(
    SiteContext siteContext, {
    required String topicId,
    required PostsListMode mode,
    String? anchorPostId,
    int? gotoPage,
    int? gotoPostNumber,
  }) {
    postPageBuilder() => PostPage(
          siteContext: siteContext,
          topicId: topicId,
          title: '', // PostPage loads the real title with the thread.
          mode: mode,
          anchorPostId: anchorPostId,
          gotoPage: gotoPage,
          gotoPostNumber: gotoPostNumber,
        );
    if (Get.currentRoute == '/PostPage') {
      Get.off(postPageBuilder);
    } else {
      Get.to(postPageBuilder);
    }
  }
}
