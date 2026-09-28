import 'package:discourse_core/discourse_core.dart' show DiscourseSiteContextExtension;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../l10n/generated/app_localizations.dart';
import '../utils/app_navigation.dart';
import 'chat/chat_channel_list_page.dart';
import 'lists/categories_list.dart';
import 'private_messaging/tabs/private_message_list_tab.dart';
import 'site_home_tab.dart';
import 'tabs/notification_list_tab.dart';
import 'tabs/topic_list_tab.dart';
import 'user_profile_page.dart';

/// One of the forum home's lists as a page of its own: where a link to the
/// forum's topics, its categories, the inbox or the notifications leads from
/// anywhere but the home.
///
/// Such a link used to close every page back to the home and switch its
/// tab, so Back from there left the forum rather than returning to the page
/// the link was on. This opens on top instead; the home keeps its tabs.
class ForumListPage extends StatelessWidget {
  const ForumListPage({super.key, required this.siteContext, required this.tab});

  final SiteContext siteContext;
  final SiteHomeTab tab;

  /// Opens [tab]'s list over the current page.
  static Future<void> open(
      BuildContext context, SiteContext siteContext, SiteHomeTab tab) {
    if (tab == SiteHomeTab.profile) {
      return AppNavigation.push(
          context,
          UserProfilePage(
              siteContext: siteContext, userName: siteContext.currentUsername));
    }
    return AppNavigation.push(
        context, ForumListPage(siteContext: siteContext, tab: tab));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Chat's list is a page of its own, with its own bar.
    if (tab == SiteHomeTab.inbox && siteContext.chatEnabled) {
      return ChatChannelListPage(siteContext: siteContext);
    }
    final (String title, Widget list) = switch (tab) {
      // The page's bar names the forum, so no forum header under it.
      SiteHomeTab.topics => (
          siteContext.site.name,
          TopicListTab(
              siteContext: siteContext, isActive: true, showMasthead: false),
        ),
      SiteHomeTab.categories => (
          l10n.categoriesView,
          CategoriesList(siteContext: siteContext, standalone: true),
        ),
      SiteHomeTab.inbox || SiteHomeTab.messages => (
          l10n.messages,
          PrivateMessageListTab(siteContext: siteContext, isActive: true),
        ),
      SiteHomeTab.notifications || SiteHomeTab.profile => (
          l10n.notifications,
          NotificationListTab(siteContext: siteContext, isActive: true),
        ),
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: list,
    );
  }
}
