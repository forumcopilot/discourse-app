import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../l10n/generated/app_localizations.dart';
import 'appbars/messages_tab_app_bar.dart';
import 'private_messaging/conversation/pages/new_conversation_page.dart';
import 'private_messaging/tabs/private_message_list_tab.dart';

/// Standalone wrapper around the PrivateMessageListTab so we can open
/// it as a full-page route from the Profile tab (Phase 5.17d moved
/// Messages off the primary bottom nav into Profile → Messages).
///
/// The body is the existing tab widget — same controllers, same fetch
/// logic — just hosted under our own Scaffold. The new-conversation
/// FAB lives on this page rather than the previous bottom-nav one.
///
/// That FAB was described here but never actually added, which left private
/// messages unreachable to compose on any forum with chat installed: chat and
/// messages share one bottom-nav slot (`_isChatEnabled ? _chatTab : _messagesTab`
/// in SiteHomePage), so when chat wins, SiteHomePage's FAB condition
/// `isOnMessagesTab` can never be true — `_getTabIndex` returns -1 for a tab that
/// is not in the list. This page then became the only route to Messages, and it
/// had no compose affordance at all, while its own empty state read
/// "Start a new conversation to begin messaging".
class MessagesPage extends StatefulWidget {
  final SiteContext siteContext;

  const MessagesPage({super.key, required this.siteContext});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  /// Lets us refresh the list after a message is sent, the same way
  /// SiteHomePage does with its own `_pmListKey`.
  final GlobalKey<PrivateMessageListTabState> _pmListKey =
      GlobalKey<PrivateMessageListTabState>();

  Future<void> _onNewConversationPressed() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewConversationPage(siteContext: widget.siteContext),
      ),
    );
    if (result == true) {
      _pmListKey.currentState?.resetTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = widget.siteContext.isLoggedIn;
    // Same permission the bottom-nav FAB used: Discourse refuses the compose
    // outright below the trust level its `personal_message_enabled_groups`
    // setting requires, so offering the button would only produce an error.
    final canSendPM =
        isLoggedIn && (widget.siteContext.loginDataOutput?.user?.canSendPM ?? false);

    return Scaffold(
      appBar: MessagesTabAppBar(
        siteContext: widget.siteContext,
        isLoggedIn: isLoggedIn,
      ),
      body: PrivateMessageListTab(
        key: _pmListKey,
        isActive: true,
        siteContext: widget.siteContext,
      ),
      floatingActionButton: canSendPM
          ? FloatingActionButton.extended(
              onPressed: _onNewConversationPressed,
              icon: const Icon(Icons.post_add_rounded),
              label: Text(AppLocalizations.of(context)!.newConversation),
            )
          : null,
    );
  }
}
