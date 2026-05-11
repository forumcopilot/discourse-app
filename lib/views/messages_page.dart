import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import 'appbars/messages_tab_app_bar.dart';
import 'private_messaging/tabs/private_message_list_tab.dart';

/// Standalone wrapper around the PrivateMessageListTab so we can open
/// it as a full-page route from the Profile tab (Phase 5.17d moved
/// Messages off the primary bottom nav into Profile → Messages).
///
/// The body is the existing tab widget — same controllers, same fetch
/// logic — just hosted under our own Scaffold. The new-conversation
/// FAB lives on this page rather than the previous bottom-nav one.
class MessagesPage extends StatelessWidget {
  final SiteContext siteContext;

  const MessagesPage({super.key, required this.siteContext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MessagesTabAppBar(
        siteContext: siteContext,
        isLoggedIn: siteContext.isLoggedIn,
      ),
      body: PrivateMessageListTab(
        isActive: true,
        siteContext: siteContext,
      ),
    );
  }
}
