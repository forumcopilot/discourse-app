import 'dart:async';

import 'package:discourse_core/discourse_core.dart'
    show
        DiscourseChatChannelDetails,
        DiscourseChatListChanged,
        DiscourseChatListEvent,
        DiscourseChatListNewMessage,
        DiscourseChatListTracking,
        DiscourseChatProxy,
        DiscourseChatSettings,
        DiscourseChatThread,
        DiscourseSiteContextExtension,
        stripHtmlToText;
import 'package:flutter/material.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_channel.dart';

import '../../services/chat_unread.dart';
import '../../theme/design_tokens.dart';
import '../../utils/chat_time.dart';
import '../../utils/emoji_shortcodes.dart';
import '../../utils/snackbar_helper.dart';
import 'chat_browse_channels_page.dart';
import 'chat_people_sheet.dart';
import 'chat_search_page.dart';
import 'widgets/chat_channel_avatar.dart';
import 'widgets/chat_available_channels.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/not_signed_in_view.dart';
import '../widgets/resettable_widget.dart';
import '../widgets/user_avatar.dart';
import 'chat_channel_view.dart';
import '../../l10n/generated/app_localizations.dart';

/// DM channel titles come back from the serializer already filled with
/// the other members' usernames (channel_serializer.rb:
/// `object.name || object.title(scope.user)`), so they are normally
/// non-empty. Guard anyway — `FCChatChannel` carries no member list to
/// fall back on client-side.
String _channelDisplayTitle(BuildContext context, FCChatChannel ch) {
  if (ch.title.isNotEmpty) return ch.title;
  return ch.chatableType == 'DirectMessage'
      ? AppLocalizations.of(context)!.chatDirectMessage
      : '#${ch.id}';
}

/// The halves of the chat list, as Discourse's chat footer on a phone.
enum _ChatHalf { channels, dms, threads }

/// Top-level Chat surface: joined channels above permission-filtered
/// discovery, with direct messages and threads in separate tabs.
///
/// Discourse Chat users typically belong to a handful of category-
/// linked public channels plus DMs. We render both groups in one list
/// (public channels first), each with unread + mention badges.
class ChatChannelListPage extends StatefulWidget {
  final SiteContext siteContext;

  /// When true, render the channel list as a tab body (no Scaffold /
  /// AppBar of our own — the parent provides them). Used by Phase
  /// 5.18a's bottom-nav Chat slot, where `SiteHomePage` owns the
  /// Scaffold + drawer + AppBar and embeds us via IndexedStack.
  ///
  /// Default (false) is the legacy push-as-route mode: we wrap the
  /// list in our own Scaffold + AppBar.
  final bool embedded;

  const ChatChannelListPage({
    super.key,
    required this.siteContext,
    this.embedded = false,
  });

  @override
  State<ChatChannelListPage> createState() => ChatChannelListPageState();
}

class ChatChannelListPageState extends FCStatefulWidget<ChatChannelListPage>
    with FCTabStatefulWidget<ChatChannelListPage> {
  List<FCChatChannel>? _channels;
  bool _loading = false;
  int _loadGeneration = 0;
  int _discoveryRevision = 0;
  String? _error;

  /// Discourse keeps channels and direct messages apart (Channels / DMs),
  /// with the reader's threads beside them where threads are on; this list
  /// mixed them, sorted unread-first.
  /// Null until the reader picks: then the list opens on DMs when they
  /// have direct messages but have joined no channel.
  _ChatHalf? _half;

  /// The reader's threads (My Threads), loaded when that half is picked.
  List<DiscourseChatThread>? _threads;
  bool _threadsLoading = false;
  String? _threadsError;

  // Track login state so the channel list reloads after an in-session
  // login/logout (same pattern as NotificationListTab). Without this
  // the page keeps the guest-time "You need to be logged in" error
  // until the app is restarted — it lives inside SiteHomePage's
  // IndexedStack, so initState only ever runs once.
  bool _wasLoggedIn = false;
  String? _lastLoadedUsername;

  /// Stops following the listed channels' new messages and the reader's
  /// unread counts (see DiscourseChatProxy.watchChannelList).
  void Function()? _stopWatching;
  late final VoidCallback _authStateListener;
  bool _initialLoadStarted = false;

  @override
  void initState() {
    super.initState();
    _wasLoggedIn = widget.siteContext.isLoggedIn;
    _lastLoadedUsername = widget.siteContext.loginDataOutput?.user?.username;

    _authStateListener = () {
      if (!mounted) return;
      final isLoggedIn = widget.siteContext.isLoggedIn;
      final username = widget.siteContext.loginDataOutput?.user?.username;
      if (isLoggedIn != _wasLoggedIn || username != _lastLoadedUsername) {
        _wasLoggedIn = isLoggedIn;
        _lastLoadedUsername = username;
        _channels = null;
        _load();
      }
    };
    widget.siteContext.isLoggedInNotifier.addListener(_authStateListener);
  }

  /// The first load starts here, not in initState: signed out, _load()
  /// reads AppLocalizations synchronously, and inherited widgets may not be
  /// read until initState has returned (a debug assertion). This still runs
  /// before the first build, so the first frame is the same as before.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialLoadStarted) return;
    _initialLoadStarted = true;
    _load();
  }

  @override
  void dispose() {
    _loadGeneration++;
    _stopWatching?.call();
    widget.siteContext.isLoggedInNotifier.removeListener(_authStateListener);
    super.dispose();
  }

  /// Follows the listed channels live, as the web's list does, so a new
  /// message moves its channel up with its excerpt and badge without a
  /// pull to refresh.
  void _watch() {
    _stopWatching?.call();
    _stopWatching = null;
    final proxy = SiteProxyService.getChatProxy();
    final channels = _channels;
    if (proxy is! DiscourseChatProxy || channels == null || channels.isEmpty) {
      return;
    }
    _stopWatching =
        proxy.watchChannelList([for (final c in channels) c.id], _onListEvent);
  }

  void _onListEvent(DiscourseChatListEvent event) {
    if (!mounted) return;
    switch (event) {
      case DiscourseChatListChanged():
        unawaited(_load());
      case DiscourseChatListNewMessage(
          :final channelId,
          :final fromReader,
          :final threadReply,
          :final at
        ):
        final ch = _channels?.where((c) => c.id == channelId).firstOrNull;
        if (ch == null || threadReply) return;
        setState(() {
          ch.lastMessageAt = at ?? DateTime.now();
          // A guess until the tracking state says; it usually follows at once.
          if (!fromReader) ch.unreadCount += 1;
        });
        _publishUnread();
      case DiscourseChatListTracking(
          :final channelId,
          :final unreadCount,
          :final mentionCount
        ):
        final ch = _channels?.where((c) => c.id == channelId).firstOrNull;
        if (ch == null) return;
        setState(() {
          ch.unreadCount = unreadCount;
          ch.mentionCount = mentionCount;
        });
        _publishUnread();
    }
  }

  DiscourseChatChannelDetails? _details(FCChatChannel ch) =>
      DiscourseChatChannelDetails.of(widget.siteContext.site.url, ch.id);

  bool _isMuted(FCChatChannel ch) => _details(ch)?.muted ?? false;

  /// For the Chat tab's badge: mentions in channels and unread direct
  /// messages want the reader now; anything else unread is a dot.
  void _publishUnread() {
    final channels = _channels ?? const <FCChatChannel>[];
    var urgent = 0;
    var any = false;
    for (final c in channels) {
      if (_isMuted(c)) continue;
      final dm = c.chatableType == 'DirectMessage';
      urgent += dm ? c.unreadCount : c.mentionCount;
      if (c.unreadCount > 0 || c.mentionCount > 0) any = true;
    }
    ChatUnread.set(
        widget.siteContext, ChatUnreadState(urgent: urgent, any: any));
  }

  /// Called by SiteHomePage._resetAllTabs on login/logout and site
  /// re-initialization, mirroring the other bottom-nav tabs.
  @override
  void resetTab() {
    _wasLoggedIn = widget.siteContext.isLoggedIn;
    _lastLoadedUsername = widget.siteContext.loginDataOutput?.user?.username;
    _load();
  }

  Future<void> _load() async {
    final generation = ++_loadGeneration;
    _stopWatching?.call();
    _stopWatching = null;
    // `/chat/api/me/channels` is "my channels" — it needs a session, and
    // answers 403 without one. Same gate as
    // DiscourseTopicProxy.markTopicReadAsync puts on the timings beacon:
    // don't spend a request (or a slice of the per-IP rate limit) on a
    // call whose answer is already known. The auth listener re-runs
    // _load() on sign-in, so the real fetch happens then.
    if (!widget.siteContext.isLoggedIn) {
      setState(() {
        _loading = false;
        _channels = const [];
        _error = AppLocalizations.of(context)!.chatSignInTitle;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await SiteProxyService.getChatProxy().getMyChannelsAsync();
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _loading = false;
        if (!result.result) {
          _channels = const [];
          _error = result.resultText?.isNotEmpty == true
              ? result.resultText
              : AppLocalizations.of(context)!.chatNotAvailable;
          return;
        }
        // An empty list is not an error: each tab has its own empty state.
        // ("Ask an admin to invite you" was wrong too — Discourse users
        // browse and join channels themselves.)
        _channels = result.channels;
        _discoveryRevision++;
      });
      _publishUnread();
      _watch();
      if (_half == _ChatHalf.threads) unawaited(_loadThreads());
    } catch (e) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _channels = const [];
        _loading = false;
        _error = '$e';
      });
    }
  }

  Future<void> _loadThreads() async {
    final proxy = SiteProxyService.getChatProxy();
    if (proxy is! DiscourseChatProxy) return;
    setState(() {
      _threadsLoading = true;
      _threadsError = null;
    });
    final r = await proxy.getMyThreadsAsync();
    if (!mounted) return;
    setState(() {
      _threadsLoading = false;
      if (r.result) {
        _threads = r.threads;
      } else {
        _threadsError = r.resultText.isNotEmpty
            ? r.resultText
            : AppLocalizations.of(context)!.chatNotAvailable;
      }
    });
  }

  Future<void> _openThread(DiscourseChatThread t) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ChatChannelScreen(
        siteContext: widget.siteContext,
        channelId: t.channelId,
        threadId: t.threadId,
        initialTitle: t.channelTitle == null ? '' : '#${t.channelTitle}',
      ),
    ));
    if (mounted) unawaited(_loadThreads());
  }

  void _search() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ChatSearchPage(siteContext: widget.siteContext),
    ));
  }

  Future<void> _open(FCChatChannel ch) async {
    final title = _channelDisplayTitle(context, ch);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatChannelScreen(
          siteContext: widget.siteContext,
          channelId: ch.id,
          // DM titles are usernames — the '#' prefix only fits
          // category/topic channels.
          initialTitle: ch.chatableType == 'DirectMessage' ? title : '#$title',
        ),
      ),
    );
    // Back from the channel: its messages are now read (and others may have
    // moved), so the badges shown before opening it are stale.
    if (mounted) unawaited(_load());
  }

  Future<void> _startNewDm() async {
    final channel = await showModalBottomSheet<FCChatChannel>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ChatPeopleSheet(siteContext: widget.siteContext),
    );
    if (channel == null || !mounted) return;
    // Refresh so the (possibly brand-new) channel shows up in the
    // list, then open it right away.
    unawaited(_load());
    _open(channel);
  }

  @override
  Widget build(BuildContext context) {
    // Signed-out users got whatever `/chat/api/me/channels` replied with, rendered
    // raw as the empty state — on a French forum that read "Vous devez être
    // connecté(e) pour effectuer cette opération": the server's message, in the
    // forum's locale rather than the app's, as plain text with no way to sign in.
    // Messages already had a proper NotSignedInView for exactly this; use the same
    // one so the two halves of this tab match, and skip a request that can only fail.
    if (!widget.siteContext.isLoggedIn) {
      return NotSignedInView(
        siteContext: widget.siteContext,
        title: AppLocalizations.of(context)!.chatSignInTitle,
        message: AppLocalizations.of(context)!.chatSignInMessage,
        icon: Icons.chat_bubble_outline_rounded,
      );
    }

    final body = RefreshIndicator(
      onRefresh: _load,
      child: _buildBody(),
    );
    // Only people allowed to start direct messages get the button (Discourse:
    // `userCanDirectMessage`).
    final fab =
        widget.siteContext.isLoggedIn && widget.siteContext.chatCanDirectMessage
            // Labelled like Messages' "New Message" button beside it; the words
            // are Discourse's sidebar link ("Start new DM").
            ? FloatingActionButton.extended(
                // No hero: embedded, this sits in Home's route beside Home's
                // own button, and no other page has this one.
                heroTag: null,
                onPressed: _startNewDm,
                icon: const Icon(Icons.add_comment_outlined),
                label: Text(AppLocalizations.of(context)!.chatNewMessage),
              )
            : null;
    // Embedded mode (Phase 5.18a bottom-nav Chat slot): caller owns
    // the Scaffold + AppBar. We just render the list (plus our own
    // overlaid FAB — the parent Scaffold's FAB slot belongs to the
    // page, not this tab).
    if (widget.embedded) {
      if (fab == null) return body;
      return Stack(
        children: [
          body,
          Positioned(
            right: DesignTokens.spacingM,
            bottom: DesignTokens.spacingM,
            child: fab,
          ),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 20),
            SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.chat),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context)!.refresh,
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      floatingActionButton: fab,
      body: body,
    );
  }

  Future<void> _browse() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChatBrowseChannelsPage(siteContext: widget.siteContext),
    ));
    // Joined or left something there.
    if (mounted) unawaited(_load());
  }

  /// Hides a DM until someone writes in it again, as a swipe does on the
  /// web's list.
  Future<bool> _closeDm(FCChatChannel ch) async {
    final proxy = SiteProxyService.getChatProxy();
    if (proxy is! DiscourseChatProxy) return false;
    final result = await proxy.closeDirectMessageAsync(ch.id);
    if (!mounted) return false;
    if (!result.result) {
      SnackbarHelper.showError(
          context,
          result.resultText?.isNotEmpty == true
              ? result.resultText!
              : AppLocalizations.of(context)!.chatNotAvailable);
      return false;
    }
    setState(
        () => _channels = [...?_channels]..removeWhere((c) => c.id == ch.id));
    _publishUnread();
    return true;
  }

  /// Most pressing first, as Discourse orders its chat list: channels with a
  /// mention, then unread, then by name; direct messages unread first, then
  /// by their latest message.
  List<FCChatChannel> _sorted(List<FCChatChannel> list, {required bool dms}) {
    int rank(FCChatChannel c) => dms
        ? (c.unreadCount > 0 ? 0 : 1)
        : (c.mentionCount > 0 ? 0 : (c.unreadCount > 0 ? 1 : 2));
    DateTime last(FCChatChannel c) =>
        _details(c)?.lastMessageAt ??
        c.lastMessageAt ??
        DateTime.fromMillisecondsSinceEpoch(0);
    return [...list]..sort((a, b) {
        final byRank = rank(a).compareTo(rank(b));
        if (byRank != 0) return byRank;
        return dms
            ? last(b).compareTo(last(a))
            : a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });
  }

  Widget _buildBody() {
    return ValueListenableBuilder<int>(
      valueListenable: DiscourseChatChannelDetails.revision,
      builder: (context, _, __) => _buildList(),
    );
  }

  Widget _buildList() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final channels = _channels;

    if (_loading && channels == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if ((channels == null || channels.isEmpty) && _error != null) {
      return EmptyStateView.scrollable(
        icon: Icons.chat_bubble_outline,
        message: _error!,
      );
    }

    final all = channels ?? const <FCChatChannel>[];
    // Which halves exist, as on Discourse: no Channels when the forum turned
    // public channels off, and no DMs for someone who may not start one and
    // has none to read (`userCanAccessDirectMessages`). With only one, there
    // is nothing to switch.
    final canDm = widget.siteContext.chatCanDirectMessage;
    final hasChannels = widget.siteContext.chatPublicChannelsEnabled;
    final hasDms = canDm || all.any((c) => c.chatableType == 'DirectMessage');
    final site = widget.siteContext.site.url;
    final discourse = SiteProxyService.getChatProxy() is DiscourseChatProxy;
    final threadsOn =
        discourse && DiscourseChatSettings.forSite(site).threadsEnabled;
    final searchOn =
        discourse && DiscourseChatSettings.forSite(site).searchEnabled;
    final showThreads = threadsOn && _half == _ChatHalf.threads;
    final picked = _half == null || _half == _ChatHalf.threads
        ? null
        : _half == _ChatHalf.dms;
    final showDms = hasChannels && hasDms ? (picked ?? false) : !hasChannels;
    final half = all
        .where((c) => (c.chatableType == 'DirectMessage') == showDms)
        .toList();
    final starred = _sorted(
        half.where((c) => _details(c)?.starred ?? false).toList(),
        dms: showDms);
    final rest = _sorted(
        half.where((c) => !(_details(c)?.starred ?? false)).toList(),
        dms: showDms);
    bool unreadIn(bool dms) => all
        .where(
            (c) => (c.chatableType == 'DirectMessage') == dms && !_isMuted(c))
        .any((c) => c.unreadCount > 0 || c.mentionCount > 0);

    // With three halves the icons go, so the names fit a phone.
    final three = hasChannels && hasDms && threadsOn;
    // The dot sits past the end of the name, not on its last letter (a
    // label-less badge ignores its offset, so the name is padded instead).
    Widget segmentLabel(String text, bool dot) => Badge(
          isLabelVisible: dot,
          smallSize: 8,
          child: Padding(
            padding: EdgeInsetsDirectional.only(end: dot ? 10 : 0),
            child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        );
    final segments = <ButtonSegment<_ChatHalf>>[
      if (hasChannels)
        ButtonSegment(
          value: _ChatHalf.channels,
          icon: three ? null : const Icon(Icons.tag),
          label: segmentLabel(l10n.chatChannels, unreadIn(false)),
        ),
      if (hasDms)
        ButtonSegment(
          value: _ChatHalf.dms,
          icon: three ? null : const Icon(Icons.person_outline),
          label: segmentLabel(l10n.chatDms, unreadIn(true)),
        ),
      if (threadsOn)
        ButtonSegment(
          value: _ChatHalf.threads,
          icon: three ? null : const Icon(Icons.forum_outlined),
          label: segmentLabel(l10n.chatMyThreads,
              (_threads ?? const []).any((t) => t.unreadCount > 0)),
        ),
    ];
    final selected = showThreads
        ? _ChatHalf.threads
        : (showDms ? _ChatHalf.dms : _ChatHalf.channels);

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spacingL,
        DesignTokens.spacingS,
        DesignTokens.spacingS,
        DesignTokens.spacingXS,
      ),
      child: Row(
        children: [
          Expanded(
            child: segments.length > 1
                ? SegmentedButton<_ChatHalf>(
                    segments: segments,
                    selected: {selected},
                    showSelectedIcon: false,
                    onSelectionChanged: (sel) {
                      setState(() => _half = sel.first);
                      if (sel.first == _ChatHalf.threads && _threads == null) {
                        unawaited(_loadThreads());
                      }
                    },
                  )
                : const SizedBox.shrink(),
          ),
          if (searchOn)
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: l10n.chatSearchTitle,
              onPressed: _search,
            ),
        ],
      ),
    );

    if (showThreads) {
      return _buildThreads(header);
    }

    if (half.isEmpty && showDms) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          header,
          const SizedBox(height: DesignTokens.spacingXL),
          EmptyStateView(
            icon: showDms ? Icons.person_outline : Icons.tag,
            message: showDms ? l10n.chatNoDms : l10n.chatNoChannels,
          ),
          // Never a dead end: an empty Channels half offers the channels
          // there are to join, an empty DMs half the way to start one.
          if (!showDms || canDm)
            Center(
              child: FilledButton.tonal(
                onPressed: showDms ? _startNewDm : _browse,
                child:
                    Text(showDms ? l10n.chatNoDmsCta : l10n.chatBrowseChannels),
              ),
            ),
        ],
      );
    }

    Widget sectionTitle(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(
              DesignTokens.spacingL,
              DesignTokens.spacingM,
              DesignTokens.spacingL,
              DesignTokens.spacingXS),
          child: Text(text,
              style: textTheme.titleSmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
        );

    Widget tile(FCChatChannel ch) {
      final row = _ChannelTile(
        channel: ch,
        details: _details(ch),
        siteContext: widget.siteContext,
        onTap: () => _open(ch),
      );
      if (ch.chatableType != 'DirectMessage') return row;
      return Dismissible(
        key: ValueKey('dm-${ch.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          color: colorScheme.errorContainer,
          alignment: AlignmentDirectional.centerEnd,
          padding:
              const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.close, color: colorScheme.onErrorContainer),
              const SizedBox(width: DesignTokens.spacingS),
              Text(l10n.chatCloseDm,
                  style: textTheme.labelLarge
                      ?.copyWith(color: colorScheme.onErrorContainer)),
            ],
          ),
        ),
        confirmDismiss: (_) => _closeDm(ch),
        child: row,
      );
    }

    final rows = <Widget>[
      header,
      if (!showDms) sectionTitle(l10n.chatJoinedChannels),
      if (!showDms && half.isEmpty)
        Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingL),
          child: Text(l10n.chatNoChannels,
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
        ),
      if (starred.isNotEmpty) ...[
        sectionTitle(l10n.chatStarred),
        for (final ch in starred) tile(ch),
        if (rest.isNotEmpty)
          sectionTitle(showDms ? l10n.chatDms : l10n.chatChannels),
      ],
      for (final ch in rest) tile(ch),
      if (!showDms && discourse)
        ChatAvailableChannels(
          key: ValueKey(
              '${widget.siteContext.site.url}:${widget.siteContext.currentUsername}'),
          siteContext: widget.siteContext,
          joinedIds: half.map((c) => c.id).toSet(),
          revision: _discoveryRevision,
          onOpen: _open,
          onJoined: (channel) {
            setState(() {
              channel.isFollowing = true;
              _channels = [
                ...?_channels?.where((c) => c.id != channel.id),
                channel
              ];
            });
            _publishUnread();
            _watch();
            unawaited(_load());
          },
        ),
      if (!showDms && !discourse)
        ListTile(title: Text(l10n.chatBrowseAllChannels), onTap: _browse),
      // Room for the floating button over the last row.
      const SizedBox(height: 88),
    ];
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: rows,
    );
  }

  /// My Threads: the threads the reader takes part in, newest activity
  /// first, each with its channel, replies and unread count.
  Widget _buildThreads(Widget header) {
    final l10n = AppLocalizations.of(context)!;
    final threads = _threads;
    final Widget content;
    if (threads == null && _threadsError == null) {
      content = const Padding(
        padding: EdgeInsets.all(DesignTokens.spacingXL),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (threads == null || threads.isEmpty) {
      content = Padding(
        padding: const EdgeInsets.only(top: DesignTokens.spacingXL),
        child: EmptyStateView(
            icon: Icons.forum_outlined,
            message: _threadsError ?? l10n.chatMyThreadsEmpty),
      );
    } else {
      content = Column(
        children: [
          for (final t in threads)
            _ThreadTile(thread: t, onTap: () => _openThread(t))
        ],
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        header,
        if (_threadsLoading && threads != null)
          const LinearProgressIndicator(minHeight: 2),
        content,
        const SizedBox(height: 88),
      ],
    );
  }
}

/// One of the reader's threads, as Discourse's My Threads list: who started
/// it, its title (or its first words), its channel and replies, and when
/// the last reply came, with a badge while unread.
class _ThreadTile extends StatelessWidget {
  const _ThreadTile({required this.thread, required this.onTap});

  final DiscourseChatThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final om = thread.originalMessage;
    final first = om == null
        ? ''
        : withEmojiShortcodes(
                stripHtmlToText(om.cooked.isNotEmpty ? om.cooked : om.message))
            .trim();
    final title = thread.title ?? (first.isNotEmpty ? first : l10n.chatThread);
    final unread = thread.unreadCount > 0;
    final when = thread.lastReplyAt ?? om?.createdAt;
    final last = thread.lastReplyExcerpt == null
        ? null
        : withEmojiShortcodes(stripHtmlToText(thread.lastReplyExcerpt!)).trim();
    final channel = thread.channelTitle;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(
              username: om?.authorUsername ?? '',
              iconUrl: om?.authorAvatarUrl?.isEmpty ?? true
                  ? null
                  : om?.authorAvatarUrl,
              radius: 22,
            ),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                              fontWeight:
                                  unread ? FontWeight.w700 : FontWeight.w500),
                        ),
                      ),
                      if (when != null) ...[
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(formatChatListTime(context, when),
                            style: textTheme.bodySmall?.copyWith(
                                color: unread
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (channel != null && channel.isNotEmpty) '#$channel',
                      l10n.chatThreadReplies(thread.replyCount)
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  if (last != null && last.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(children: [
                              if (thread.lastReplyUser != null)
                                TextSpan(
                                    text: '${thread.lastReplyUser!.username}: ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                              TextSpan(text: last),
                            ]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: DesignTokens.spacingS),
                          Badge(label: Text('${thread.unreadCount}')),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One chat in the list, laid out as Discourse's chat list on a phone: the
/// channel's picture, its name and when it last spoke, then its last
/// message and a badge (a number for mentions and direct messages, a dot
/// for anything else unread). Muted chats are dimmed and carry no badge.
class _ChannelTile extends StatelessWidget {
  final FCChatChannel channel;
  final DiscourseChatChannelDetails? details;
  final SiteContext siteContext;
  final VoidCallback onTap;

  const _ChannelTile({
    required this.channel,
    required this.details,
    required this.siteContext,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final muted = details?.muted ?? false;
    final dm = channel.chatableType == 'DirectMessage';
    final hasUnread =
        !muted && (channel.unreadCount > 0 || channel.mentionCount > 0);
    final count = dm ? channel.unreadCount : channel.mentionCount;
    final when = details?.lastMessageAt ?? channel.lastMessageAt;
    final rawExcerpt = details?.lastMessageExcerpt;
    final excerpt = rawExcerpt == null
        ? null
        : withEmojiShortcodes(stripHtmlToText(rawExcerpt)).trim();
    final subtitle = excerpt != null && excerpt.isNotEmpty
        ? excerpt
        : (channel.description?.isNotEmpty == true
            ? channel.description!
            : null);

    Widget? badge;
    if (hasUnread && count > 0) {
      badge = Badge(label: Text(count > 99 ? '99+' : '$count'));
    } else if (hasUnread) {
      badge = Container(
        width: 10,
        height: 10,
        decoration:
            BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
      );
    }

    final tile = InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingL,
            vertical: DesignTokens.spacingS + 2),
        child: Row(
          children: [
            ChatChannelAvatar(
                channel: channel, details: details, siteContext: siteContext),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _channelDisplayTitle(context, channel),
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : DesignTokens.fontWeightMedium,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!channel.isOpen) ...[
                        const SizedBox(width: 6),
                        Icon(
                          // Discourse's status icons: closed is a lock,
                          // read-only a crossed-out comment, archived a box.
                          channel.isClosed
                              ? Icons.lock_outline
                              : channel.isReadOnly
                                  ? Icons.comments_disabled_outlined
                                  : Icons.archive_outlined,
                          size: DesignTokens.iconSizeS,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                      if (muted) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.notifications_off_outlined,
                            size: DesignTokens.iconSizeS,
                            color: colorScheme.onSurfaceVariant),
                      ],
                      if (when != null) ...[
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(
                          formatChatListTime(context, when),
                          style: textTheme.bodySmall?.copyWith(
                            color: hasUnread
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: hasUnread
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: DesignTokens.spacingS),
                        badge,
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return muted ? Opacity(opacity: 0.6, child: tile) : tile;
  }
}
