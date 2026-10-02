import 'dart:async';

import 'package:discourse_core/discourse_core.dart'
    show DiscourseChatProxy, DiscourseChatSettings, DiscourseChatable;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../services/site_proxy_service.dart';
import '../../theme/design_tokens.dart';
import '../widgets/user_avatar.dart';
import '../widgets/user_list_row.dart';

/// "New message" bottom sheet: people and groups from the chat plugin's
/// own search, picked as chips, plus plain comma-separated names. One person
/// opens a DM; several make a group chat, which can be named, up to the
/// forum's limit (`chat_max_direct_message_users`), as Discourse's creator.
/// Pops with the created (or reused) [FCChatChannel]; policy failures
/// (DMs disabled, someone who does not accept DMs, …) show inline.
///
/// With [addToChannelId] it adds the picked people to that group chat
/// instead, and pops with true.
class ChatPeopleSheet extends StatefulWidget {
  const ChatPeopleSheet({super.key, required this.siteContext, this.addToChannelId, this.memberCount = 0});

  final SiteContext siteContext;
  final int? addToChannelId;

  /// People already in the group chat being added to, against the limit.
  final int memberCount;

  @override
  State<ChatPeopleSheet> createState() => _ChatPeopleSheetState();
}

class _ChatPeopleSheetState extends State<ChatPeopleSheet> {
  final _name = TextEditingController();

  int get _max => DiscourseChatSettings.forSite(widget.siteContext.site.url).maxDirectMessageUsers;
  bool get _adding => widget.addToChannelId != null;
  bool get _full => widget.memberCount + _selected.length >= _max;
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
    _name.dispose();
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
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(term));
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
    if (_full) {
      setState(() => _error = AppLocalizations.of(context)!.chatTooManyMembers);
      return;
    }
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
      final users = [
        for (final c in chosen)
          if (!c.isGroup) c.name
      ];
      final groups = [
        for (final c in chosen)
          if (c.isGroup) c.name
      ];
      if (_adding) {
        final added = await proxy.addChannelMembersAsync(widget.addToChannelId!, usernames: users, groups: groups);
        if (!mounted) return;
        if (added.result) {
          Navigator.of(context).pop(true);
        } else {
          setState(() {
            _creating = false;
            _error = added.resultText?.isNotEmpty == true ? added.resultText : AppLocalizations.of(context)!.chatCouldNotStartDm;
          });
        }
        return;
      }
      final result = await proxy.createDirectMessageChannelAsync(
        users,
        groups: groups,
        // Reuse an existing group DM with the same member set instead
        // of minting a duplicate (1:1 DMs are reused automatically).
        upsert: users.length + groups.length > 1,
        name: users.length + groups.length > 1 ? _name.text : null,
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
    final canCreate =
        !_creating && (_selected.isNotEmpty || _input.text.trim().isNotEmpty);

    return Padding(
      // Under the theme's drag handle, at the app's 16dp margins.
      padding: EdgeInsets.only(
        left: DesignTokens.spacingL,
        right: DesignTokens.spacingL,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + DesignTokens.spacingL,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _adding ? AppLocalizations.of(context)!.chatAddMember : AppLocalizations.of(context)!.chatCreatePersonal,
                  style: textTheme.titleMedium,
                ),
              ),
              // How many, out of the forum's limit, once it is a group.
              if (_adding || _selected.length > 1)
                Text(
                  AppLocalizations.of(context)!.chatMembersCounter(widget.memberCount + _selected.length, _max),
                  style: textTheme.bodySmall?.copyWith(
                      color: _full ? colorScheme.error : colorScheme.onSurfaceVariant),
                ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingS),
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
          // A group chat may have a name (optional), as on the web.
          if (!_adding && _selected.length > 1) ...[
            const SizedBox(height: DesignTokens.spacingS),
            TextField(
              controller: _name,
              enabled: !_creating,
              decoration: InputDecoration(hintText: AppLocalizations.of(context)!.chatGroupName),
            ),
          ],
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
                onPressed: _creating ? null : () => Navigator.of(context).pop(),
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
                    : Text(_adding
                        ? AppLocalizations.of(context)!.chatAddMember
                        : _selected.length > 1
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
