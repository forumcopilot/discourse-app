import 'dart:async';

import 'package:discourse_core/discourse_core.dart'
    show DiscourseMessageGroup, DiscourseMessageList, DiscourseMessageTracking, DiscoursePrivateConversationProxy;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'package:discourse_ui/views/widgets/resettable_widget.dart';
import 'package:discourse_ui/views/widgets/not_signed_in_view.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';
import '../../../theme/design_tokens.dart';
import '../../widgets/filter_chip_bar.dart';
import '../../search_page.dart';
import '../conversation/list/conversation_list.dart';

/// Lists the user's messages as Discourse web does: Inbox (received and sent,
/// merged), Unread, New, Sent and Archive, with the number new and unread
/// beside New and Unread; and, for each group whose messages the user can
/// read, that group's inbox with its own Unread, New and Archive, picked
/// from the inbox menu. Archiving is how a Discourse user files a message
/// away. Messages that arrive or change while a list is open are announced
/// over it, as on the web, rather than moving the list under the reader.
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
  static const _personal = [
    DiscourseMessageList.inbox,
    DiscourseMessageList.unread,
    DiscourseMessageList.newMessages,
    DiscourseMessageList.sent,
    DiscourseMessageList.archive,
  ];

  /// Group inboxes, once known.
  List<DiscourseMessageGroup> _groups = const [];

  /// The inbox shown: null for the reader's own, else a group's name.
  String? _inbox;

  /// The filter picked in each inbox.
  final Map<String?, int> _filterIn = {};

  /// A group's inbox and its filters, as the web's group messages.
  List<DiscourseMessageList> _listsFor(String? group) => group == null
      ? _personal
      : [
          DiscourseMessageList.group(group),
          DiscourseMessageList.group(group, filter: 'unread'),
          DiscourseMessageList.group(group, filter: 'new'),
          DiscourseMessageList.group(group, filter: 'archive'),
        ];

  List<DiscourseMessageList> get _allLists => [
        ..._personal,
        for (final g in _groups) ..._listsFor(g.name),
      ];

  DiscourseMessageList get _current {
    final lists = _listsFor(_inbox);
    return lists[(_filterIn[_inbox] ?? 0).clamp(0, lists.length - 1)];
  }

  final Map<String, GlobalKey<ConversationListState>> _keys = {};
  GlobalKey<ConversationListState> _keyFor(DiscourseMessageList list) =>
      _keys.putIfAbsent(list.id, () => GlobalKey<ConversationListState>());

  /// Lists a message has moved into or out of since they were last shown
  /// (archived, moved to the inbox, left, read, marked unread). Every list
  /// stays alive between switches, so the one shown next reloads rather than
  /// showing where the message used to be.
  final Set<String> _stale = {};

  /// Messages that arrived or changed for the list on screen since it
  /// loaded: the banner's count.
  final Set<int> _incoming = {};

  void Function()? _stopWatching;

  bool? _lastLoggedIsLoggedIn;

  DiscourseMessageTracking get _tracking => DiscourseMessageTracking.forSite(widget.siteContext.site.url);

  Set<int> get _myGroupIds => {for (final g in _groups) if (g.id != null) g.id!};

  int? _groupId(String? name) => _groups.where((g) => g.name == name).firstOrNull?.id;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  @override
  void dispose() {
    _stopWatching?.call();
    super.dispose();
  }

  Future<void> _loadGroups({bool openInitialGroup = true}) async {
    if (!widget.siteContext.isLoggedIn) return;
    final proxy = SiteProxyFactory.getPrivateConversationProxy();
    if (proxy is! DiscoursePrivateConversationProxy) return;
    final groups = await proxy.getMessageGroupsAsync();
    if (mounted && groups.isNotEmpty) setState(() => _groups = groups);
    if (!mounted) return;
    unawaited(_startTracking(proxy));
    if (!openInitialGroup) return;
    final wanted = widget.initialGroup?.toLowerCase();
    if (wanted == null) return;
    final group = _groups.where((g) => g.name.toLowerCase() == wanted).firstOrNull;
    if (group != null) _selectInbox(group.name);
  }

  /// The New and Unread counts, kept live.
  Future<void> _startTracking(DiscoursePrivateConversationProxy proxy) async {
    await proxy.loadMessageTrackingAsync();
    if (!mounted) return;
    _stopWatching?.call();
    _stopWatching = proxy.watchMessageTracking([..._myGroupIds], _onIncoming);
  }

  /// A message arrived or changed: announced over the list it belongs in,
  /// as the web's messages page does.
  void _onIncoming(Map<String, dynamic> message, String type) {
    if (!mounted) return;
    final list = _current;
    final filter = list.filter;
    final wanted = switch (type) {
      'new_topic' => filter == 'inbox' || filter == 'new',
      'unread' => filter == 'inbox' || filter == 'unread',
      'group_archive' => list.group != null && (filter == 'inbox' || filter == 'archive'),
      _ => false,
    };
    final id = (message['topic_id'] as num?)?.toInt();
    if (!wanted || id == null) return;
    if (!_tracking.belongsTo(message, groupId: _groupId(list.group), myGroupIds: _myGroupIds)) return;
    setState(() => _incoming.add(id));
  }

  void _showIncoming() {
    setState(_incoming.clear);
    _keyFor(_current).currentState?.loadConversations();
  }

  @override
  void resetTab() {
    _keyFor(_current).currentState?.resetAndLoadConversations();
    // A new subscription, not just new counts: after signing in again on
    // this context the old one belongs to the previous session and drops
    // every message, and a tab built while signed out never had one.
    _stopWatching?.call();
    _stopWatching = null;
    unawaited(_loadGroups(openInitialGroup: false));
  }

  void _show(DiscourseMessageList list) {
    final stale = _stale.remove(list.id);
    _incoming.clear();
    // Offstage lists do not load themselves: start the first visit here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = _keyFor(list).currentState;
      stale ? state?.loadConversations() : state?.loadIfNeeded();
    });
  }

  void _select(int index) {
    setState(() => _filterIn[_inbox] = index);
    _show(_current);
  }

  void _selectInbox(String? group) {
    setState(() => _inbox = group);
    _show(_current);
  }

  String _label(DiscourseMessageList list, AppLocalizations l10n) {
    final tracking = _tracking;
    int count(bool unread) => tracking.isLoaded
        ? tracking.count(unread: unread, groupId: _groupId(list.group), myGroupIds: _myGroupIds)
        : 0;
    switch (list.filter) {
      case 'unread':
        final n = count(true);
        return n > 0 ? l10n.messageListUnreadCount(n) : l10n.messageListUnread;
      case 'new':
        final n = count(false);
        return n > 0 ? l10n.messageListNewCount(n) : l10n.messageListNew;
      case 'sent':
        return l10n.messageListSent;
      case 'archive':
        return l10n.messageArchive;
    }
    return l10n.messageInbox;
  }

  /// New and unread in an inbox, for the inbox menu.
  int _waiting(String? group) {
    final tracking = _tracking;
    if (!tracking.isLoaded) return 0;
    final id = group == null ? null : _groupId(group);
    if (group != null && id == null) return 0;
    return tracking.count(unread: true, groupId: id, myGroupIds: _myGroupIds) +
        tracking.count(unread: false, groupId: id, myGroupIds: _myGroupIds);
  }

  String _inboxLabel(String? group, AppLocalizations l10n) => group == null
      ? l10n.messagePersonal
      : (_groups.where((g) => g.name == group).firstOrNull?.label ?? group);

  Widget _inboxPicker(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final elsewhere = [null, for (final g in _groups) g.name].where((g) => g != _inbox).any((g) => _waiting(g) > 0);
    return PopupMenuButton<String>(
      tooltip: l10n.messageInbox,
      initialValue: _inbox ?? '',
      onSelected: (v) => _selectInbox(v.isEmpty ? null : v),
      itemBuilder: (context) => [
        for (final group in [null, for (final g in _groups) g.name])
          PopupMenuItem<String>(
            value: group ?? '',
            child: Row(
              children: [
                Icon(group == null ? Icons.person_outline : Icons.group_outlined, size: 20),
                const SizedBox(width: DesignTokens.spacingM),
                Expanded(child: Text(_inboxLabel(group, l10n))),
                if (_waiting(group) > 0) ...[
                  const SizedBox(width: DesignTokens.spacingS),
                  Badge(label: Text('${_waiting(group)}')),
                ],
              ],
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: DesignTokens.spacingL),
        child: Container(
          height: 32,
          padding: const EdgeInsetsDirectional.only(start: DesignTokens.spacingS, end: DesignTokens.spacingXS),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline),
            borderRadius: BorderRadius.circular(DesignTokens.radiusS),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Badge(
                isLabelVisible: elsewhere,
                smallSize: 8,
                child: Icon(_inbox == null ? Icons.person_outline : Icons.group_outlined,
                    size: 18, color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(width: DesignTokens.spacingXS),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(_inboxLabel(_inbox, l10n),
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelLarge),
              ),
              Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
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
        final all = _allLists;
        final current = _current;
        final filters = _listsFor(_inbox);
        final colorScheme = Theme.of(context).colorScheme;
        return Column(
          children: [
            ValueListenableBuilder<int>(
              valueListenable: _tracking.revision,
              builder: (context, _, __) => Row(
                children: [
                  if (_groups.isNotEmpty) _inboxPicker(l10n),
                  Expanded(
                    child: FilterChipBar(
                      padding: _groups.isEmpty
                          ? null
                          : const EdgeInsets.symmetric(horizontal: DesignTokens.spacingS, vertical: DesignTokens.spacingS),
                      options: [
                        // Labels only, as the topic filters on Home.
                        for (final list in filters) FilterChipOption(label: _label(list, l10n)),
                      ],
                      selectedIndex: filters.indexWhere((l) => l.id == current.id),
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
            ),
            if (_incoming.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    DesignTokens.spacingL, 0, DesignTokens.spacingL, DesignTokens.spacingS),
                child: Material(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                    onTap: _showIncoming,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingM),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_upward, size: 18, color: colorScheme.onSecondaryContainer),
                          const SizedBox(width: DesignTokens.spacingS),
                          Expanded(
                            child: Text(l10n.messageListIncoming(_incoming.length),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(color: colorScheme.onSecondaryContainer)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: IndexedStack(
                index: all.indexWhere((l) => l.id == current.id),
                children: [
                  // A hidden list's spinner (it loads when first shown) must
                  // not tick: IndexedStack keeps hidden children animating,
                  // and the tab redrew every frame while it was open.
                  for (final list in all)
                    TickerMode(
                      enabled: list.id == current.id,
                      child: ConversationList(
                      key: _keyFor(list),
                      siteContext: widget.siteContext,
                      list: list,
                      // A message read, filed or left from this list
                      // changes the others.
                      onMessagesChanged: () {
                        _stale.addAll(all.map((l) => l.id).where((id) => id != list.id));
                        // Without MessageBus the counts are fetched again.
                        final proxy = SiteProxyFactory.getPrivateConversationProxy();
                        if (_stopWatching == null && proxy is DiscoursePrivateConversationProxy) {
                          unawaited(proxy.loadMessageTrackingAsync());
                        }
                      },
                      ),
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
