import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../l10n/generated/app_localizations.dart';
import 'chat/chat_channel_list_page.dart';
import 'private_messaging/tabs/private_message_list_tab.dart';

/// Chat and private messages sharing one bottom-nav slot, switched by a sub-tab
/// bar at the top.
///
/// They used to compete for that slot outright — `_isChatEnabled ? _chatTab :
/// _messagesTab` — so on any forum with the chat plugin installed the Messages tab
/// simply did not exist. Messages was then reachable only via Profile → Messages,
/// and the compose FAB (gated on `isOnMessagesTab`, which could never be true once
/// the tab was absent) never appeared anywhere. Both features are first-class on
/// Discourse, so both get a home here.
///
/// Owns its own TabController so SiteHomePage keeps a single bottom-nav
/// controller. The active sub-tab is reported back via [onSubTabChanged] so the
/// host can swap its app bar and show the new-conversation FAB only over Messages.
class ChatMessagesTab extends StatefulWidget {
  final SiteContext siteContext;

  /// Whether this slot is the visible bottom-nav tab.
  final bool isActive;

  /// Key forwarded to the private message list so the host can refresh it after
  /// a message is sent.
  final Key? messageListKey;

  /// Key forwarded to the chat channel list.
  final Key? chatListKey;

  /// Fired with the newly selected sub-tab index: 0 = Chat, 1 = Messages.
  final ValueChanged<int>? onSubTabChanged;

  const ChatMessagesTab({
    super.key,
    required this.siteContext,
    required this.isActive,
    this.messageListKey,
    this.chatListKey,
    this.onSubTabChanged,
  });

  /// Sub-tab index for Messages, so callers can compare without a magic number.
  static const int messagesIndex = 1;

  @override
  State<ChatMessagesTab> createState() => _ChatMessagesTabState();
}

class _ChatMessagesTabState extends State<ChatMessagesTab>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    _controller.addListener(() {
      // indexIsChanging is true mid-swipe; report only settled changes so the
      // host does not rebuild its app bar on every animation frame.
      if (!_controller.indexIsChanging) {
        widget.onSubTabChanged?.call(_controller.index);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        TabBar(
          controller: _controller,
          tabs: [
            // 'Chat' is not localized anywhere yet — ChatTabAppBar hardcodes it
            // too, so keep the two consistent rather than inventing a key here.
            const Tab(text: 'Chat'),
            Tab(text: l10n?.messages ?? 'Messages'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: [
              ChatChannelListPage(
                key: widget.chatListKey,
                siteContext: widget.siteContext,
                // Strips the page's own Scaffold so the host's Scaffold, app bar
                // and drawer hamburger stay in charge.
                embedded: true,
              ),
              PrivateMessageListTab(
                key: widget.messageListKey,
                // Only "active" when this slot is showing AND Messages is the
                // selected sub-tab, so the list does not fetch behind Chat.
                isActive: widget.isActive &&
                    _controller.index == ChatMessagesTab.messagesIndex,
                siteContext: widget.siteContext,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
