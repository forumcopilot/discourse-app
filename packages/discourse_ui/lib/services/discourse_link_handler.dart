import 'package:discourse_core/discourse_core.dart'
    show DiscourseLink, DiscourseLinkKind, DiscourseSiteCapabilities;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';
import '../controllers/site_controller.dart';
import '../core/logging/app_logger.dart';
import '../utils/url_utils.dart';
import '../views/badges_directory_page.dart';
import '../views/bookmarks_page.dart';
import '../views/chat/chat_channel_view.dart';
import '../views/forum_topics_page.dart';
import '../views/group_detail_page.dart';
import '../views/groups_list_page.dart';
import '../views/login_page.dart';
import '../views/search_page.dart';
import '../views/site_home_tab.dart';
import '../views/tag_topics_page.dart';
import '../views/tags_page.dart';
import '../views/user_profile_page.dart';
import '../views/users_directory_page.dart';
import '../views/widgets/badge_detail_sheet.dart';
import 'discourse_route_navigator.dart';
import 'notification_route.dart';
import 'site_proxy_service.dart';
import '../views/widgets/category_badge.dart';

/// What a tapped link leads to.
enum LinkDestinationKind {
  /// Nothing: an in-page anchor, which Discourse puts beside every heading.
  none,

  /// Another post of the topic already on screen ([LinkDestination.postNumber]).
  jumpInTopic,

  /// A topic or post ([LinkDestination.route]).
  topic,
  category,
  tag,
  tags,
  user,
  users,
  group,
  groups,
  badge,
  badges,

  /// A chat channel, at a message when the link names one.
  chatChannel,
  search,
  bookmarks,

  /// A tab of the forum's home ([LinkDestination.homeTab]).
  home,

  /// The mail app.
  email,

  /// The browser ([LinkDestination.url]): another site, or a page of this
  /// forum the app has no screen for.
  browser,
}

/// Where a link tapped in a forum's content should take the reader —
/// decided from the link and what the app already knows about the forum,
/// without a navigator, so the rules can be tested.
class LinkDestination {
  const LinkDestination(
    this.kind, {
    this.url,
    this.route,
    this.postNumber,
    this.categoryId,
    this.categoryName,
    this.tagName,
    this.username,
    this.groupName,
    this.badgeId,
    this.chatChannelId,
    this.chatMessageId,
    this.searchQuery,
    this.homeTab,
  });

  final LinkDestinationKind kind;
  final String? url;
  final DiscourseNotificationRoute? route;
  final int? postNumber;
  final String? categoryId;
  final String? categoryName;
  final String? tagName;
  final String? username;
  final String? groupName;
  final int? badgeId;
  final int? chatChannelId;
  final int? chatMessageId;
  final String? searchQuery;
  final SiteHomeTab? homeTab;

  @override
  String toString() => 'LinkDestination($kind, url=$url, route=$route, '
      'post#=$postNumber, category=$categoryId "$categoryName", tag=$tagName, '
      'user=$username, group=$groupName, badge=$badgeId, '
      'chat=$chatChannelId/$chatMessageId, q=$searchQuery, tab=$homeTab)';
}

/// Opens links tapped in a forum's content — posts, messages, chat, link
/// previews — on the app's own screens when they lead somewhere in the same
/// forum, the way the forum's website keeps them in the page
/// (`DiscourseURL.routeTo`), and in the browser otherwise.
class DiscourseLinkHandler {
  DiscourseLinkHandler._();

  /// Decides where [href] leads. [currentTopicId] is the topic on screen,
  /// if any: a link to another post of it moves within the topic, as the
  /// web does, rather than opening the topic again.
  static LinkDestination destinationFor(
    SiteContext siteContext,
    String href, {
    String? currentTopicId,
  }) {
    final text = href.trim().replaceAll('"', '');
    if (text.isEmpty || text.startsWith('#')) {
      return const LinkDestination(LinkDestinationKind.none);
    }
    if (text.toLowerCase().startsWith('mailto:') || _isEmail(text)) {
      return LinkDestination(LinkDestinationKind.email, url: text);
    }
    final forumUrl = siteContext.site.url;
    final link = DiscourseLink.inForum(forumUrl, text);
    if (link == null) {
      return LinkDestination(LinkDestinationKind.browser, url: text);
    }
    final browser = LinkDestination(LinkDestinationKind.browser, url: link.url);
    LinkDestination home(SiteHomeTab tab) =>
        LinkDestination(LinkDestinationKind.home, homeTab: tab);
    final caps = DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl);
    final me = siteContext.isLoggedIn ? siteContext.currentUsername : null;

    switch (link.kind) {
      case DiscourseLinkKind.forum:
        return home(SiteHomeTab.topics);
      case DiscourseLinkKind.topic:
        if (currentTopicId != null && '${link.topicId}' == currentTopicId) {
          return LinkDestination(LinkDestinationKind.jumpInTopic,
              postNumber: link.postNumber ?? 1);
        }
        return LinkDestination(LinkDestinationKind.topic,
            route: DiscourseNotificationRoute.fromLink(link));
      case DiscourseLinkKind.post:
        return LinkDestination(LinkDestinationKind.topic,
            route: DiscourseNotificationRoute.fromLink(link));
      case DiscourseLinkKind.category:
        final id = link.categoryId ?? caps.categoryIdForSlugs(link.categorySlugs);
        if (id == null) return browser;
        return LinkDestination(LinkDestinationKind.category,
            categoryId: '$id', categoryName: caps.categoryNameFor('$id') ?? '');
      case DiscourseLinkKind.tag:
        return LinkDestination(LinkDestinationKind.tag, tagName: link.tagName);
      case DiscourseLinkKind.tags:
        return const LinkDestination(LinkDestinationKind.tags);
      case DiscourseLinkKind.user:
        return LinkDestination(LinkDestinationKind.user, username: link.username);
      case DiscourseLinkKind.users:
        return const LinkDestination(LinkDestinationKind.users);
      case DiscourseLinkKind.group:
        return LinkDestination(LinkDestinationKind.group,
            groupName: link.groupName);
      case DiscourseLinkKind.groups:
        return const LinkDestination(LinkDestinationKind.groups);
      case DiscourseLinkKind.badge:
        return LinkDestination(LinkDestinationKind.badge, badgeId: link.badgeId);
      case DiscourseLinkKind.badges:
        return const LinkDestination(LinkDestinationKind.badges);
      case DiscourseLinkKind.chat:
        final channel = link.chatChannelId;
        if (channel == null) return home(SiteHomeTab.inbox);
        return LinkDestination(LinkDestinationKind.chatChannel,
            chatChannelId: channel, chatMessageId: link.chatMessageId);
      case DiscourseLinkKind.search:
        return LinkDestination(LinkDestinationKind.search,
            searchQuery: link.searchQuery);
      case DiscourseLinkKind.list:
        return home(link.listName == 'categories'
            ? SiteHomeTab.categories
            : SiteHomeTab.topics);
      case DiscourseLinkKind.my:
        // The reader's own pages; the web sends a guest to sign in.
        if (me == null) return browser;
        final path = link.myPath ?? '';
        if (path == 'bookmarks' || path.startsWith('activity/bookmarks')) {
          return const LinkDestination(LinkDestinationKind.bookmarks);
        }
        if (path.startsWith('messages')) return home(SiteHomeTab.inbox);
        if (path.startsWith('notifications')) {
          return home(SiteHomeTab.notifications);
        }
        if (path.isEmpty ||
            path.startsWith('summary') ||
            path.startsWith('activity') ||
            path.startsWith('badges')) {
          return LinkDestination(LinkDestinationKind.user, username: me);
        }
        return browser;
      case DiscourseLinkKind.serverSide:
      case DiscourseLinkKind.page:
        return browser;
    }
  }

  /// Takes the reader to wherever [href] leads (see [destinationFor]).
  /// [onJumpToPost] moves within the topic on screen.
  static Future<void> open(
    BuildContext context,
    SiteContext siteContext,
    String href, {
    String? currentTopicId,
    void Function(int postNumber)? onJumpToPost,
  }) async {
    final to = destinationFor(siteContext, href,
        currentTopicId: onJumpToPost == null ? null : currentTopicId);
    AppLogger.debug('🔗 [DiscourseLinkHandler] $href → $to');
    void push(Widget page) => Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => page));

    switch (to.kind) {
      case LinkDestinationKind.none:
        return;
      case LinkDestinationKind.email:
      case LinkDestinationKind.browser:
        await UrlUtils.handleUrlTap(to.url!, context);
      case LinkDestinationKind.jumpInTopic:
        onJumpToPost?.call(to.postNumber!);
      case LinkDestinationKind.topic:
        await _restoreSession(context, siteContext);
        await DiscourseRouteNavigator.open(siteContext, to.route!,
            replaceTopic: false);
      case LinkDestinationKind.category:
        // With its colours from /site.json, so its header is not blank.
        push(ForumTopicsPage(
          siteContext: siteContext,
          forum: categoryForum(siteContext, to.categoryId!,
              fallbackName: to.categoryName ?? ''),
        ));
      case LinkDestinationKind.tag:
        push(TagTopicsPage(siteContext: siteContext, tag: to.tagName!));
      case LinkDestinationKind.tags:
        push(TagsPage(siteContext: siteContext));
      case LinkDestinationKind.user:
        push(UserProfilePage(siteContext: siteContext, userName: to.username));
      case LinkDestinationKind.users:
        push(UsersDirectoryPage(siteContext: siteContext));
      case LinkDestinationKind.group:
        push(GroupDetailPage(siteContext: siteContext, groupName: to.groupName!));
      case LinkDestinationKind.groups:
        push(GroupsListPage(siteContext: siteContext));
      case LinkDestinationKind.badge:
        await _openBadge(context, siteContext, to.badgeId!);
      case LinkDestinationKind.badges:
        push(BadgesDirectoryPage(siteContext: siteContext));
      case LinkDestinationKind.chatChannel:
        push(ChatChannelScreen(
          siteContext: siteContext,
          channelId: to.chatChannelId!,
          targetMessageId: to.chatMessageId,
        ));
      case LinkDestinationKind.search:
        push(SearchPage(siteContext: siteContext, initialQuery: to.searchQuery));
      case LinkDestinationKind.bookmarks:
        push(BookmarksPage(siteContext: siteContext));
      case LinkDestinationKind.home:
        _goHome(context, to.homeTab!);
    }
  }

  /// Back to the forum's home and on to [tab] — where a link to the
  /// forum itself, one of its lists, chat or the reader's inbox leads.
  static void _goHome(BuildContext context, SiteHomeTab tab) {
    if (!Get.isRegistered<DiscourseSiteController>()) return;
    final controller = Get.find<DiscourseSiteController>();
    final homeRoute = controller.homeRoute;
    if (homeRoute != null && homeRoute.isActive) {
      Navigator.of(context).popUntil((route) => route == homeRoute);
    }
    controller.requestHomeTab(tab);
  }

  /// A badge link names only the badge's id; the forum's badge list has the
  /// rest. Falls back to the list when it is not there.
  static Future<void> _openBadge(
      BuildContext context, SiteContext siteContext, int badgeId) async {
    try {
      final result = await SiteProxyService.getUserProxy().getAllBadgesAsync();
      final badge = result.badges.where((b) => b.id == badgeId).firstOrNull;
      if (!context.mounted) return;
      if (badge != null) {
        await showBadgeDetailSheet(context, badge);
        return;
      }
    } catch (e) {
      AppLogger.debug('🔗 [DiscourseLinkHandler] badge $badgeId: $e');
    }
    if (!context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => BadgesDirectoryPage(siteContext: siteContext)));
  }

  /// A signed-out reader with saved credentials is signed back in before a
  /// topic opens, as tapping a topic in a post always did; a topic still
  /// opens as a guest when that fails.
  static Future<void> _restoreSession(
      BuildContext context, SiteContext siteContext) async {
    if (siteContext.isLoggedIn) return;
    if (!Get.isRegistered<DiscourseLoginController>()) {
      Get.put(DiscourseLoginController());
    }
    final loginController = Get.find<DiscourseLoginController>();
    final result = await loginController.attemptAutomaticLogin(siteContext);
    if (!result.success &&
        result.hadCredentials &&
        Get.currentRoute != '/LoginPage') {
      await Get.to(() => LoginPage(siteContext: siteContext));
    }
  }

  static bool _isEmail(String text) =>
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(text);
}
