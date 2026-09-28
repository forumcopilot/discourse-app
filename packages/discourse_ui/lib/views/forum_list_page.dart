import 'package:discourse_core/discourse_core.dart' show DiscourseSiteContextExtension;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../l10n/generated/app_localizations.dart';
import '../utils/app_navigation.dart';
import 'chat_messages_tab.dart';
import 'private_messaging/tabs/private_message_list_tab.dart';
import 'site_home_tab.dart';
import 'tabs/forum_list_tab.dart';
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
    final (String title, Widget list) = switch (tab) {
      SiteHomeTab.topics => (
          siteContext.site.name,
          TopicListTab(siteContext: siteContext, isActive: true),
        ),
      SiteHomeTab.categories => (
          l10n.forums,
          ForumListTab(siteContext: siteContext, isActive: true),
        ),
      // Chat and messages share the home's slot where chat is on.
      SiteHomeTab.inbox when siteContext.chatEnabled => (
          l10n.chat,
          ChatMessagesTab(siteContext: siteContext, isActive: true),
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
