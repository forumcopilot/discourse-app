import 'package:discourse_core/discourse_core.dart'
    show DiscourseMessageGroup, DiscourseMessageList, DiscoursePrivateConversationProxy;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'package:discourse_ui/views/widgets/resettable_widget.dart';
import 'package:discourse_ui/views/widgets/not_signed_in_view.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';
import '../../widgets/filter_chip_bar.dart';
import '../../search_page.dart';
import '../conversation/list/conversation_list.dart';

/// Lists the user's messages as Discourse web does: Inbox (received and sent,
/// merged), Unread, New, Sent and Archive, then an inbox for each group whose
/// messages the user can read. Archiving is how a Discourse user files a
/// message away.
class PrivateMessageListTab extends StatefulWidget {
  final SiteContext siteContext;
  final bool isActive;

  /// A group whose inbox to show first, once the reader's groups have
  /// loaded (a group message summary notification names one).
  final String? initialGroup;

  const PrivateMessageListTab(
      {super.key,
      required this.isActive,
      required this.siteContext,
      this.initialGroup});
  @override
  PrivateMessageListTabState createState() => PrivateMessageListTabState();
}

class PrivateMessageListTabState extends FCStatefulWidget<PrivateMessageListTab>
    with FCTabStatefulWidget<PrivateMessageListTab>, TickerProviderStateMixin {
  static const _lists = [
    DiscourseMessageList.inbox,
    DiscourseMessageList.unread,
    DiscourseMessageList.newMessages,
    DiscourseMessageList.sent,
    DiscourseMessageList.archive,
  ];

  /// Group inboxes, once known.
  List<DiscourseMessageGroup> _groups = const [];

  List<DiscourseMessageList> get _allLists => [
        ..._lists,
        for (final g in _groups) DiscourseMessageList.group(g.name),
      ];

  final Map<String, GlobalKey<ConversationListState>> _keys = {};
  GlobalKey<ConversationListState> _keyFor(DiscourseMessageList list) =>
      _keys.putIfAbsent(list.id, () => GlobalKey<ConversationListState>());

  int _selected = 0;

  /// Lists a message has moved into or out of since they were last shown
  /// (archived, moved to the inbox, left, read, marked unread). Every list
  /// stays alive between switches, so the one shown next reloads rather than
  /// showing where the message used to be.
  final Set<String> _stale = {};

  bool? _lastLoggedIsLoggedIn;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    if (!widget.siteContext.isLoggedIn) return;
    final proxy = SiteProxyFactory.getPrivateConversationProxy();
    if (proxy is! DiscoursePrivateConversationProxy) return;
    final groups = await proxy.getMessageGroupsAsync();
    if (mounted && groups.isNotEmpty) setState(() => _groups = groups);
    final wanted = widget.initialGroup?.toLowerCase();
    if (!mounted || wanted == null) return;
    final index =
        _allLists.indexWhere((l) => l.group?.toLowerCase() == wanted);
    if (index >= 0) _select(index);
  }

  @override
  void resetTab() {
    _keyFor(_allLists[_selected]).currentState?.resetAndLoadConversations();
  }

  void _select(int index) {
    final list = _allLists[index];
    final stale = _stale.remove(list.id);
    setState(() => _selected = index);
    // Offstage lists do not load themselves: start the first visit here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = _keyFor(list).currentState;
      stale ? state?.loadConversations() : state?.loadIfNeeded();
    });
  }

  String _label(DiscourseMessageList list, AppLocalizations l10n) {
    if (list == DiscourseMessageList.inbox) return l10n.messageInbox;
    if (list == DiscourseMessageList.unread) return l10n.messageListUnread;
    if (list == DiscourseMessageList.newMessages) return l10n.messageListNew;
    if (list == DiscourseMessageList.sent) return l10n.messageListSent;
    if (list == DiscourseMessageList.archive) return l10n.messageArchive;
    return _groups
            .where((g) => g.name == list.group)
            .firstOrNull
            ?.label ??
        list.group ??
        '';
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
        final lists = _allLists;
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: FilterChipBar(
                    options: [
                      // Labels only, as the topic filters on Home.
                      for (final list in lists)
                        FilterChipOption(label: _label(list, l10n)),
                    ],
                    selectedIndex: _selected,
                    onSelected: _select,
                  ),
                ),
                // Search within messages (Discourse's `in:messages`), as the
                // web's search does from the messages page.
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: l10n.search,
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => SearchPage(
                      siteContext: widget.siteContext,
                      prefill: 'in:messages ',
                    ),
                  )),
                ),
              ],
            ),
            Expanded(
              child: IndexedStack(
                index: _selected,
                children: [
                  for (final list in lists)
                    ConversationList(
                      key: _keyFor(list),
                      siteContext: widget.siteContext,
                      list: list,
                      // A message read, filed or left from this list
                      // changes the others.
                      onMessagesChanged: () => _stale.addAll(
                          lists.map((l) => l.id).where((id) => id != list.id)),
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
