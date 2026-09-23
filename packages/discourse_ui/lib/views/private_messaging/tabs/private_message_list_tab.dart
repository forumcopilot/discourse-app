import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'package:discourse_ui/views/widgets/resettable_widget.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:discourse_ui/views/widgets/not_signed_in_view.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';
import '../conversation/list/conversation_list.dart';
import '../../../theme/design_tokens.dart';

/// Lists the user's messages: the inbox (received and sent, merged), or the
/// archive, as Discourse web's Inbox and Archive. Archiving is how a
/// Discourse user files a message away — there is no delete.
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

  final GlobalKey<ConversationListState> _archiveKey =
      GlobalKey<ConversationListState>();

  bool? _lastLoggedIsLoggedIn;

  bool _showArchive = false;

  @override
  void resetTab() {
    (_showArchive ? _archiveKey : _conversationKey)
        .currentState
        ?.resetAndLoadConversations();
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
            title: AppLocalizations.of(context)!.signInToViewMessages,
            message: AppLocalizations.of(context)!.youNeedToBeSignedInToViewConversations,
            icon: Icons.mail_outline_rounded,
          );
        }

        final l10n = AppLocalizations.of(context)!;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.spacingL,
                DesignTokens.spacingS,
                DesignTokens.spacingL,
                0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: false,
                      icon: const Icon(Icons.inbox_outlined),
                      label: Text(l10n.messageInbox),
                    ),
                    ButtonSegment(
                      value: true,
                      icon: const Icon(Icons.archive_outlined),
                      label: Text(l10n.messageArchive),
                    ),
                  ],
                  selected: {_showArchive},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) {
                    setState(() => _showArchive = selection.first);
                    if (_showArchive) {
                      // First visit: start the archive's load directly.
                      WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _archiveKey.currentState?.loadIfNeeded());
                    }
                  },
                ),
              ),
            ),
            Expanded(
              // Both lists stay alive (IndexedStack), so switching back does
              // not refetch or lose the scroll position.
              child: IndexedStack(
                index: _showArchive ? 1 : 0,
                children: [
                  ConversationList(
                    key: _conversationKey,
                    siteContext: widget.siteContext,
                  ),
                  ConversationList(
                    key: _archiveKey,
                    siteContext: widget.siteContext,
                    archived: true,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
