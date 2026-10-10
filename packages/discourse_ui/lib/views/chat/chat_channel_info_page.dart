import 'package:discourse_core/discourse_core.dart'
    show DiscourseChatChannelDetails, DiscourseChatProxy, DiscourseChatUser;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_channel.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../services/site_proxy_service.dart';
import '../../theme/design_tokens.dart';
import '../../utils/snackbar_helper.dart';
import '../profile/user_card_sheet.dart';
import '../widgets/user_avatar.dart';
import 'chat_channel_view.dart' show chatChannelTitle;
import 'chat_people_sheet.dart';
import 'widgets/chat_channel_avatar.dart';
import '../../l10n/kit_strings.dart';

/// A channel's or group chat's info and settings, opened from its header, as
/// Discourse's channel info: who is in it (and adding people to a group
/// chat, or removing them for those who may), when the reader is notified
/// (Never, Only for mentions, For all activity), mute, star, and leave.
/// The conversation had no header at all: none of this could be seen or
/// changed in the app.
///
/// Pops with true when the reader left, so the conversation closes too.
class ChatChannelInfoPage extends StatefulWidget {
  const ChatChannelInfoPage({super.key, required this.siteContext, required this.channel});

  final SiteContext siteContext;
  final FCChatChannel channel;

  @override
  State<ChatChannelInfoPage> createState() => _ChatChannelInfoPageState();
}

class _ChatChannelInfoPageState extends State<ChatChannelInfoPage> {
  List<DiscourseChatUser>? _members;
  int _total = 0;
  bool _busy = false;

  /// Whether the reader is in the channel: a channel opened from Browse is
  /// a preview, with nothing to set or leave until they join.
  late bool _member = widget.channel.isFollowing || widget.channel.chatableType == 'DirectMessage';

  DiscourseChatProxy? get _proxy {
    final p = SiteProxyService.getChatProxy();
    return p is DiscourseChatProxy ? p : null;
  }

  DiscourseChatChannelDetails? get _details =>
      DiscourseChatChannelDetails.of(widget.siteContext.site.url, widget.channel.id);

  bool get _isDm => widget.channel.chatableType == 'DirectMessage';
  int? get _me => int.tryParse(widget.siteContext.currentUserId ?? '');

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final proxy = _proxy;
    if (proxy == null) return;
    final result = await proxy.getChannelMembersAsync(widget.channel.id);
    if (!mounted) return;
    setState(() {
      _members = result.users;
      _total = result.total;
    });
  }

  void _error(String? text) =>
      SnackbarHelper.showError(context, text?.isNotEmpty == true ? text! : AppLocalizations.of(context)!.chatNotAvailable);

  Future<void> _setLevel() async {
    final l10n = AppLocalizations.of(context)!;
    final current = _details?.notificationLevel ?? 'mention';
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: RadioGroup<String>(
          groupValue: current,
          onChanged: (v) => Navigator.pop(sheet, v),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (value, label) in [
                ('never', l10n.chatNotifyNever),
                ('mention', l10n.chatNotifyMention),
                ('always', l10n.chatNotifyAlways),
              ])
                RadioListTile<String>(value: value, title: Text(label)),
            ],
          ),
        ),
      ),
    );
    if (picked == null || picked == current) return;
    final r = await _proxy?.updateChannelNotificationsAsync(widget.channel.id, level: picked);
    if (!mounted) return;
    if (r != null && !r.result) _error(r.resultText);
    setState(() {});
  }

  Future<void> _setMuted(bool muted) async {
    final r = await _proxy?.updateChannelNotificationsAsync(widget.channel.id, muted: muted);
    if (!mounted) return;
    if (r != null && !r.result) _error(r.resultText);
    setState(() {});
  }

  Future<void> _setStarred(bool starred) async {
    final r = await _proxy?.setChannelStarredAsync(widget.channel.id, starred);
    if (!mounted) return;
    if (r != null && !r.result) _error(r.resultText);
    setState(() {});
  }

  Future<void> _addMembers() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ChatPeopleSheet(
        siteContext: widget.siteContext,
        addToChannelId: widget.channel.id,
        // The limit counts everyone besides the creator.
        memberCount: (_total - 1).clamp(0, 1 << 20),
      ),
    );
    if (added == true) await _loadMembers();
  }

  Future<void> _remove(DiscourseChatUser user) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        content: Text('${l10n.chatRemoveMember} ${user.username}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l10n.kit.cancel)),
          FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(l10n.chatRemoveMember)),
        ],
      ),
    );
    if (ok != true) return;
    final r = await _proxy?.removeChannelMemberAsync(widget.channel.id, user.userId);
    if (!mounted) return;
    if (r != null && !r.result) return _error(r.resultText);
    await _loadMembers();
  }

  Future<void> _join() async {
    final proxy = _proxy;
    if (proxy == null) return;
    setState(() => _busy = true);
    final r = await proxy.joinChannelAsync(widget.channel.id);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (r.result) _member = true;
    });
    if (!r.result) return _error(r.resultText);
    await _loadMembers();
  }

  /// Leave a channel or group chat; a one-to-one DM is closed (it comes
  /// back when someone writes), as the web does.
  Future<void> _leave() async {
    final proxy = _proxy;
    if (proxy == null) return;
    final oneToOne = _isDm && !(_details?.isGroup ?? false);
    // Coming back to a group chat takes an invitation: say so first, as the
    // web does.
    if (_isDm && !oneToOne) {
      final l10n = AppLocalizations.of(context)!;
      final ok = await showDialog<bool>(
        context: context,
        builder: (d) => AlertDialog(
          content: Text(l10n.chatLeaveGroupInfo),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l10n.kit.cancel)),
            FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(l10n.chatLeave)),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }
    setState(() => _busy = true);
    final r = oneToOne
        ? await proxy.closeDirectMessageAsync(widget.channel.id)
        : await proxy.leaveChannelAsync(widget.channel.id);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!r.result) return _error(r.resultText);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ValueListenableBuilder<int>(
      valueListenable: DiscourseChatChannelDetails.revision,
      builder: (context, _, __) {
        final d = _details;
        final level = switch (d?.notificationLevel) {
          'never' => l10n.chatNotifyNever,
          'always' => l10n.chatNotifyAlways,
          _ => l10n.chatNotifyMention,
        };
        final group = _isDm && (d?.isGroup ?? false);
        final members = _members;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.chatChannelSettings)),
          body: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(DesignTokens.spacingL),
                child: Column(
                  children: [
                    ChatChannelAvatar(channel: widget.channel, details: d, siteContext: widget.siteContext, size: 72),
                    const SizedBox(height: DesignTokens.spacingM),
                    Text(chatChannelTitle(widget.channel), style: textTheme.titleLarge, textAlign: TextAlign.center),
                    if (widget.channel.description?.isNotEmpty == true) ...[
                      const SizedBox(height: DesignTokens.spacingXS),
                      Text(widget.channel.description!,
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center),
                    ],
                    if (_total > 0) ...[
                      const SizedBox(height: DesignTokens.spacingXS),
                      Text(l10n.chatMembersCount(_total),
                          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    ],
                  ],
                ),
              ),
              if (!_member && widget.channel.canJoin)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL),
                  child: FilledButton(onPressed: _busy ? null : _join, child: Text(l10n.chatJoin)),
                ),
              if (_member) ...[
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: Text(l10n.chatNotificationLevel),
                  subtitle: Text(level),
                  onTap: _setLevel,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_off_outlined),
                  title: Text(l10n.chatMuteChannel),
                  value: d?.muted ?? false,
                  onChanged: _setMuted,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.star_outline),
                  title: Text(l10n.chatStarChannel),
                  value: d?.starred ?? false,
                  onChanged: _setStarred,
                ),
              ],
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    DesignTokens.spacingL, DesignTokens.spacingS, DesignTokens.spacingL, DesignTokens.spacingXS),
                child: Text(l10n.chatMembers, style: textTheme.titleSmall?.copyWith(color: colorScheme.primary)),
              ),
              if (group)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(Icons.person_add_alt_1, color: colorScheme.onPrimaryContainer),
                  ),
                  title: Text(l10n.chatAddMember, style: TextStyle(color: colorScheme.primary)),
                  onTap: _addMembers,
                ),
              if (members == null)
                const Padding(
                  padding: EdgeInsets.all(DesignTokens.spacingL),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                for (final u in members)
                  ListTile(
                    leading: UserAvatar(username: u.username, iconUrl: u.avatarUrl, radius: 20),
                    title: Text(u.displayName),
                    subtitle: u.displayName != u.username ? Text('@${u.username}') : null,
                    onTap: () => showUserCard(context, siteContext: widget.siteContext, username: u.username),
                    trailing: (d?.canRemoveMembers ?? false) && u.userId != _me
                        ? IconButton(
                            icon: const Icon(Icons.person_remove_outlined),
                            tooltip: l10n.chatRemoveMember,
                            onPressed: () => _remove(u),
                          )
                        : null,
                  ),
              if (_member) ...[
                const Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: colorScheme.error),
                  title: Text(
                      _isDm && !group
                          ? l10n.chatCloseDm
                          : group
                              ? l10n.chatLeave
                              : l10n.chatLeaveChannel,
                      style: TextStyle(color: colorScheme.error)),
                  enabled: !_busy,
                  onTap: _leave,
                ),
              ],
              const SizedBox(height: DesignTokens.spacingXL),
            ],
          ),
        );
      },
    );
  }
}
