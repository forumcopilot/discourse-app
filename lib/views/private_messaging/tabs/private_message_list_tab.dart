import 'package:flutter/material.dart';
import 'package:forumcopilot_flutter/views/widgets/resettable_widget.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_flutter/views/widgets/not_signed_in_view.dart';
import 'package:forumcopilot_flutter/core/logging/app_logger.dart';
import '../conversation/list/conversation_list.dart';

/// Lists the user's private conversations. Discourse PMs are always
/// modeled as multi-participant conversations, so this widget always
/// renders [ConversationList] — there is no XF-style Inbox/Sent split.
class PrivateMessageListTab extends StatefulWidget {
  final SiteContext siteContext;
  final bool isActive;
  const PrivateMessageListTab(
      {super.key, required this.isActive, required this.siteContext});
  @override
  PrivateMessageListTabState createState() => PrivateMessageListTabState();
}

class PrivateMessageListTabState extends FCStatefulWidget<PrivateMessageListTab>
    with FCTabStatefulWidget<PrivateMessageListTab>, TickerProviderStateMixin {
  final GlobalKey<ConversationListState> _conversationKey =
      GlobalKey<ConversationListState>();

  bool? _lastLoggedIsLoggedIn;

  @override
  void resetTab() {
    _conversationKey.currentState?.resetAndLoadConversations();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.siteContext.isLoggedInNotifier,
      builder: (context, isLoggedIn, child) {
        if (_lastLoggedIsLoggedIn != isLoggedIn) {
          AppLogger.debug('🔄 [PRIVATE_MESSAGE_LIST_TAB] ValueListenableBuilder rebuild');
          AppLogger.debug('   - isLoggedIn: $isLoggedIn');
          _lastLoggedIsLoggedIn = isLoggedIn;
        }

        if (!isLoggedIn) {
          return NotSignedInView(
            siteContext: widget.siteContext,
            title: 'Sign in to view messages',
            message: 'You need to be signed in to view your private messages.',
            icon: Icons.mail_outline_rounded,
          );
        }

        return ConversationList(
          key: _conversationKey,
          siteContext: widget.siteContext,
        );
      },
    );
  }
}
