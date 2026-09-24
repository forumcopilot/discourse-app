import 'dart:async';

import 'package:discourse_core/discourse_core.dart'
    show DiscourseChatProxy, DiscourseChatable, DiscourseSiteContextExtension;
import 'package:flutter/material.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_channel.dart';

import '../../theme/design_tokens.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/not_signed_in_view.dart';
import '../widgets/user_list_row.dart';
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

/// Top-level Chat surface: lists the user's joined channels and opens
/// the selected one in a full-page route.
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
  String? _error;

  /// Discourse keeps channels and direct messages apart (Channels / DMs);
  /// this list mixed them, sorted unread-first.
  bool _showDms = false;

  // Track login state so the channel list reloads after an in-session
  // login/logout (same pattern as NotificationListTab). Without this
  // the page keeps the guest-time "You need to be logged in" error
  // until the app is restarted — it lives inside SiteHomePage's
  // IndexedStack, so initState only ever runs once.
  bool _wasLoggedIn = false;
  String? _lastLoadedUsername;
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
    widget.siteContext.isLoggedInNotifier.removeListener(_authStateListener);
    super.dispose();
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
      final result =
          await SiteProxyService.getChatProxy().getMyChannelsAsync();
      if (!mounted) return;
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
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _channels = const [];
        _loading = false;
        _error = '$e';
      });
    }
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
      builder: (_) => const _NewDmSheet(),
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
    final fab = widget.siteContext.isLoggedIn &&
            widget.siteContext.chatCanDirectMessage
        // Labelled like Messages' "New Message" button beside it; the words
        // are Discourse's sidebar link ("Start new DM").
        ? FloatingActionButton.extended(
            onPressed: _startNewDm,
            icon: const Icon(Icons.add_comment_outlined),
            label: Text(AppLocalizations.of(context)!.chatStartNewDm),
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

  Widget _buildBody() {
    final colorScheme = Theme.of(context).colorScheme;
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

    // Discourse's order: channels by name, DMs by latest message.
    final all = channels ?? const <FCChatChannel>[];
    // Which halves exist, as on Discourse: no Channels when the forum turned
    // public channels off, and no DMs for someone who may not start one and
    // has none to read (`userCanAccessDirectMessages`). With only one, there
    // is nothing to switch.
    final canDm = widget.siteContext.chatCanDirectMessage;
    final hasChannels = widget.siteContext.chatPublicChannelsEnabled;
    final hasDms = canDm || all.any((c) => c.chatableType == 'DirectMessage');
    final showDms = hasChannels && hasDms ? _showDms : !hasChannels;
    final shown = all
        .where((c) => (c.chatableType == 'DirectMessage') == showDms)
        .toList()
      ..sort(showDms
          ? (a, b) => (b.lastMessageAt ?? DateTime(0))
              .compareTo(a.lastMessageAt ?? DateTime(0))
          : (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    int unreadIn(bool dms) => all
        .where((c) => (c.chatableType == 'DirectMessage') == dms)
        .fold(0, (n, c) => n + c.unreadCount);

    final switcher = Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spacingL,
        DesignTokens.spacingS,
        DesignTokens.spacingL,
        DesignTokens.spacingXS,
      ),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<bool>(
          segments: [
            ButtonSegment(
              value: false,
              icon: const Icon(Icons.tag),
              label: Badge(
                isLabelVisible: unreadIn(false) > 0,
                smallSize: 8,
                child: Text(l10n.chatChannels),
              ),
            ),
            ButtonSegment(
              value: true,
              icon: const Icon(Icons.person_outline),
              label: Badge(
                isLabelVisible: unreadIn(true) > 0,
                smallSize: 8,
                child: Text(l10n.chatDms),
              ),
            ),
          ],
          selected: {showDms},
          showSelectedIcon: false,
          onSelectionChanged: (sel) => setState(() => _showDms = sel.first),
        ),
      ),
    );

    final header = hasChannels && hasDms
        ? switcher
        : const SizedBox(height: DesignTokens.spacingS);

    if (shown.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          header,
          const SizedBox(height: DesignTokens.spacingXL),
          EmptyStateView(
            icon: showDms ? Icons.person_outline : Icons.tag,
            message: showDms ? l10n.chatNoDms : l10n.chatNoChannels,
          ),
          if (showDms && canDm)
            Center(
              child: FilledButton.tonal(
                onPressed: _startNewDm,
                child: Text(l10n.chatNoDmsCta),
              ),
            ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: shown.length + 1,
      separatorBuilder: (_, i) => i == 0
          ? const SizedBox.shrink()
          : Divider(
              height: 1,
              color: colorScheme.outlineVariant
                  .withValues(alpha: DesignTokens.opacityDivider),
            ),
      itemBuilder: (_, i) {
        if (i == 0) return header;
        final ch = shown[i - 1];
        return _ChannelTile(channel: ch, onTap: () => _open(ch));
      },
    );
  }
}

class _ChannelTile extends StatelessWidget {
  final FCChatChannel channel;
  final VoidCallback onTap;

  const _ChannelTile({required this.channel, required this.onTap});

  IconData _iconFor() {
    switch (channel.chatableType) {
      case 'DirectMessage':
        // A group chat is titled with its members' names, comma-separated.
        return channel.title.contains(',')
            ? Icons.group_outlined
            : Icons.person_outline;
      case 'Category':
      default:
        return Icons.tag;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasUnread = channel.unreadCount > 0;
    final hasMention = channel.mentionCount > 0;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: DesignTokens.avatarRadiusM,
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: Icon(
          _iconFor(),
          color: colorScheme.onSurfaceVariant,
          size: DesignTokens.iconSizeM,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              _channelDisplayTitle(context, channel),
              style: textTheme.titleSmall?.copyWith(
                fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!channel.isOpen) ...[
            const SizedBox(width: 6),
            Icon(
              // Discourse's status icons: closed is a lock, read-only a
              // crossed-out comment, archived a box. Closed channels used to
              // get the archive icon.
              channel.isClosed
                  ? Icons.lock_outline
                  : channel.isReadOnly
                      ? Icons.comments_disabled_outlined
                      : Icons.archive_outlined,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ],
      ),
      subtitle: channel.description != null && channel.description!.isNotEmpty
          ? Text(
              channel.description!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: hasUnread || hasMention
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasMention)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '@${channel.mentionCount}',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onError,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                if (hasUnread) ...[
                  if (hasMention) const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      channel.unreadCount.toString(),
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            )
          : null,
    );
  }
}

/// "New direct message" bottom sheet: a username input with type-ahead
/// suggestions from the same `/u/search/users` typeahead the mention /
/// PM pickers use, plus plain comma-separated entry as a fallback.
/// Pops with the created (or reused — 1:1 DMs are deduped server-side)
/// [FCChatChannel]; policy failures (DMs disabled, target doesn't
/// accept DMs, …) surface inline via the result's `resultText`.
class _NewDmSheet extends StatefulWidget {
  const _NewDmSheet();

  @override
  State<_NewDmSheet> createState() => _NewDmSheetState();
}

class _NewDmSheetState extends State<_NewDmSheet> {
  final _input = TextEditingController();
  final _selected = <DiscourseChatable>[];
  List<DiscourseChatable> _suggestions = const [];
  Timer? _debounce;
  bool _searching = false;
  bool _creating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _input.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _input.dispose();
    super.dispose();
  }

  /// The fragment being typed — text after the last comma — so
  /// comma-separated raw entry keeps working alongside the type-ahead.
  String _currentTerm() {
    final raw = _input.text;
    final tail =
        raw.contains(',') ? raw.substring(raw.lastIndexOf(',') + 1) : raw;
    return tail.trim().replaceFirst(RegExp(r'^@'), '');
  }

  void _onQueryChanged() {
    // Rebuild for the create-button enablement either way.
    setState(() {});
    _debounce?.cancel();
    final term = _currentTerm();
    if (term.isEmpty) {
      setState(() => _suggestions = const []);
      return;
    }
    _debounce =
        Timer(const Duration(milliseconds: 300), () => _search(term));
  }

  Future<void> _search(String term) async {
    setState(() => _searching = true);
    try {
      // The chat plugin's own search: it says who can actually chat, which
      // the general user search (used here before) does not.
      final proxy = SiteProxyService.getChatProxy();
      if (proxy is! DiscourseChatProxy) return;
      final found = await proxy.searchChatablesAsync(term);
      if (!mounted || term != _currentTerm()) return;
      final picked = {for (final c in _selected) _key(c)};
      setState(() {
        _suggestions = found.where((c) => !picked.contains(_key(c))).toList();
      });
    } catch (_) {
      // Suggestions are best-effort — typing a raw username still works.
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  static String _key(DiscourseChatable c) =>
      '${c.isGroup ? 'g' : 'u'}:${c.name.toLowerCase()}';

  void _pick(DiscourseChatable chatable) {
    if (!chatable.canChat) return;
    setState(() {
      _selected.add(chatable);
      // Keep any comma-separated names typed before the current
      // fragment; only the fragment was consumed by the pick.
      final raw = _input.text;
      _input.text =
          raw.contains(',') ? raw.substring(0, raw.lastIndexOf(',') + 1) : '';
      _suggestions = const [];
    });
  }

  Future<void> _create() async {
    final proxy = SiteProxyService.getChatProxy();
    if (proxy is! DiscourseChatProxy) {
      setState(() => _error = AppLocalizations.of(context)!.chatCannotCreate);
      return;
    }
    setState(() {
      _creating = true;
      _error = null;
    });

    // Names typed without picking a suggestion are resolved first, by exact
    // match against the chat search. Discourse drops a name it cannot use
    // without saying so, and a request left with nobody else in it opens a
    // DM with yourself — so an unknown name, or someone who cannot chat,
    // stops here and nothing is created.
    // Looked up before the awaits below.
    final l10n = AppLocalizations.of(context)!;
    final chosen = [..._selected];
    final seen = {for (final c in chosen) _key(c)};
    final problems = <String>[];
    for (final part in _input.text.split(RegExp(r'[,\s]+'))) {
      final name = part.trim().replaceFirst(RegExp(r'^@'), '');
      if (name.isEmpty) continue;
      if (seen.contains('u:${name.toLowerCase()}') ||
          seen.contains('g:${name.toLowerCase()}')) {
        continue;
      }
      final matches = await proxy.searchChatablesAsync(name);
      final exact = matches
          .where((c) => c.name.toLowerCase() == name.toLowerCase())
          .toList();
      final usable = exact.where((c) => c.canChat).toList();
      if (usable.isEmpty) {
        problems.add(exact.isEmpty
            ? l10n.chatUserNotFound(name)
            : '@$name ${l10n.chatDisabledUser}');
        continue;
      }
      chosen.add(usable.first);
      seen.add(_key(usable.first));
    }
    if (!mounted) return;
    if (problems.isNotEmpty || chosen.isEmpty) {
      setState(() {
        _creating = false;
        _error = chosen.isEmpty && problems.isEmpty
            ? AppLocalizations.of(context)!.pleaseAddARecipient
            : problems.join(' · ');
      });
      return;
    }

    try {
      final users = [for (final c in chosen) if (!c.isGroup) c.name];
      final groups = [for (final c in chosen) if (c.isGroup) c.name];
      final result = await proxy.createDirectMessageChannelAsync(
        users,
        groups: groups,
        // Reuse an existing group DM with the same member set instead
        // of minting a duplicate (1:1 DMs are reused automatically).
        upsert: users.length + groups.length > 1,
      );
      if (!mounted) return;
      final channel = result.channel;
      if (!result.result || channel == null) {
        setState(() {
          _creating = false;
          _error = result.resultText?.isNotEmpty == true
              ? result.resultText
              : AppLocalizations.of(context)!.chatCouldNotStartDm;
        });
        return;
      }
      Navigator.of(context).pop(channel);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _creating = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canCreate = !_creating &&
        (_selected.isNotEmpty || _input.text.trim().isNotEmpty);

    return Padding(
      padding: EdgeInsets.only(
        left: DesignTokens.spacingM,
        right: DesignTokens.spacingM,
        top: DesignTokens.spacingM,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + DesignTokens.spacingM,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)!.chatCreatePersonal,
            style:
                textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: DesignTokens.spacingM),
          if (_selected.isNotEmpty) ...[
            Wrap(
              spacing: DesignTokens.spacingXS,
              runSpacing: DesignTokens.spacingXS,
              children: [
                for (final u in _selected)
                  InputChip(
                    avatar: u.isGroup
                        ? const Icon(Icons.groups_rounded, size: 18)
                        : UserAvatar(
                            username: u.name,
                            iconUrl: u.avatarUrl,
                            radius: 12,
                          ),
                    label: Text(u.name),
                    onDeleted: _creating
                        ? null
                        : () => setState(() => _selected.remove(u)),
                  ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacingS),
          ],
          TextField(
            controller: _input,
            autofocus: true,
            enabled: !_creating,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _create(),
            decoration: InputDecoration(
              hintText: _selected.isEmpty
                  ? AppLocalizations.of(context)!.chatSearchPlaceholder
                  : AppLocalizations.of(context)!.chatAddMorePlaceholder,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              ),
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
          ),
          if (_suggestions.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.spacingXS),
              // Same row the user directory and the message recipient picker
              // use, so a person looks identical wherever you pick them.
              for (final u in _suggestions.take(5))
                Opacity(
                  // Someone who cannot chat stays visible, so the reader
                  // learns why, but cannot be picked.
                  opacity: u.canChat ? 1 : DesignTokens.opacityDisabled,
                  child: UserListRow(
                    username: u.name,
                    subtitle: u.canChat
                        ? u.label
                        : AppLocalizations.of(context)!.chatDisabledUser,
                    avatarUrl: u.avatarUrl,
                    leadingIcon: u.isGroup ? Icons.groups_rounded : null,
                    onTap: u.canChat ? () => _pick(u) : null,
                  ),
                ),
          ],
          if (_error != null) ...[
            const SizedBox(height: DesignTokens.spacingS),
            Text(
              _error!,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
            ),
          ],
          const SizedBox(height: DesignTokens.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed:
                    _creating ? null : () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              const SizedBox(width: DesignTokens.spacingS),
              FilledButton(
                onPressed: canCreate ? _create : null,
                child: _creating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    // Discourse's wording once it is a group chat.
                    : Text(_selected.length > 1
                        ? AppLocalizations.of(context)!.chatCreateGroup
                        : AppLocalizations.of(context)!.startChat),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
