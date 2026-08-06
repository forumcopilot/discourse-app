import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscourseInvite, DiscourseInviteProxy;
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/design_tokens.dart';
import 'widgets/empty_state_view.dart';
import 'widgets/simple_list_app_bar.dart';
import '../utils/error_message.dart';

/// Invites screen — Discourse-native shareable invite links and email
/// invites (`DiscourseInviteProxy`, no XenForo-shaped SDK counterpart).
///
/// Lists the current user's invites behind Pending / Expired / Redeemed
/// filter chips (counts come from the server response), lets them mint a
/// new shareable link (FAB) or send an email invite (app-bar action),
/// and revoke invites the server says they may delete.
///
/// Whether the user may invite at all is decided server-side
/// (`invite_allowed_groups`); there is no capability flag on the client,
/// so a 403-flavored failure is surfaced as a friendly "no permission"
/// state instead of an error.
class InvitesPage extends StatefulWidget {
  final SiteContext siteContext;

  const InvitesPage({super.key, required this.siteContext});

  @override
  State<InvitesPage> createState() => _InvitesPageState();
}

class _InvitesPageState extends State<InvitesPage> {
  static const _filters = [
    (value: 'pending', label: 'Pending'),
    (value: 'expired', label: 'Expired'),
    (value: 'redeemed', label: 'Redeemed'),
  ];

  String _filter = 'pending';
  List<DiscourseInvite>? _invites;
  int _pendingCount = 0;
  int _expiredCount = 0;
  int _redeemedCount = 0;
  bool _loading = true;
  bool _creating = false;
  String? _error;

  /// Set when the server answered with a 403-flavored refusal — the
  /// user isn't in `invite_allowed_groups`. Carries the server text.
  String? _forbiddenText;

  DiscourseInviteProxy get _proxy => DiscourseInviteProxy(widget.siteContext);

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// The proxy flattens `DiscourseApiException` into
  /// `result: false, resultText: e.userMessage`, so the 403 case is
  /// recognised by message shape rather than status code.
  bool _looksForbidden(String? text) {
    final t = (text ?? '').toLowerCase();
    return t.contains('403') ||
        t.contains('not authorized') ||
        t.contains('not permitted');
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _proxy.getMyInvitesAsync(filter: _filter);
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (!result.result) {
          _invites = const [];
          if (_looksForbidden(result.resultText)) {
            _forbiddenText = result.resultText;
          } else {
            _error = result.resultText?.isNotEmpty == true
                ? result.resultText
                : 'Failed to load invites.';
          }
          return;
        }
        _forbiddenText = null;
        _invites = result.invites;
        _pendingCount = result.pendingCount;
        _expiredCount = result.expiredCount;
        _redeemedCount = result.redeemedCount;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _invites = const [];
        _error = describeError(e);
      });
    }
  }

  Future<void> _createInviteLink() async {
    if (_creating) return;
    setState(() => _creating = true);
    final result = await _proxy.createInviteLinkAsync();
    if (!mounted) return;
    setState(() => _creating = false);
    if (!result.result || result.invite == null) {
      if (_looksForbidden(result.resultText)) {
        setState(() => _forbiddenText = result.resultText);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.resultText?.isNotEmpty == true
              ? result.resultText!
              : 'Failed to create invite link'),
        ),
      );
      return;
    }
    await _showInviteLinkSheet(result.invite!);
    await _load();
  }

  /// Bottom sheet showing a freshly minted link with Copy / Share.
  Future<void> _showInviteLinkSheet(DiscourseInvite invite) async {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              DesignTokens.spacingL,
              0,
              DesignTokens.spacingL,
              DesignTokens.spacingL,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Invite link created',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: DesignTokens.fontWeightSemiBold,
                  ),
                ),
                if (invite.expiresAt != null) ...[
                  SizedBox(height: DesignTokens.spacingXS),
                  Text(
                    'Expires ${DateFormat.yMMMd().format(invite.expiresAt!.toLocal())}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                SizedBox(height: DesignTokens.spacingM),
                Container(
                  padding: EdgeInsets.all(DesignTokens.spacingM),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                  ),
                  child: SelectableText(
                    invite.link,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(height: DesignTokens.spacingL),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: invite.link),
                          );
                          if (!sheetContext.mounted) return;
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            const SnackBar(
                              content: Text('Invite link copied'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded),
                        label: const Text('Copy'),
                      ),
                    ),
                    SizedBox(width: DesignTokens.spacingM),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Share.share(invite.link),
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Share'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Optional "Invite by email" flow (app-bar action).
  Future<void> _showEmailInviteDialog() async {
    final emailController = TextEditingController();
    final messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final send = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Invite by email'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty || !v.contains('@')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: DesignTokens.spacingM),
                TextFormField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Message (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
              child: const Text('Send invite'),
            ),
          ],
        );
      },
    );

    if (send != true || !mounted) return;
    final email = emailController.text.trim();
    final message = messageController.text.trim();
    final result = await _proxy.createEmailInviteAsync(
      email,
      customMessage: message.isNotEmpty ? message : null,
    );
    if (!mounted) return;
    if (!result.result) {
      if (_looksForbidden(result.resultText)) {
        setState(() => _forbiddenText = result.resultText);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.resultText?.isNotEmpty == true
              ? result.resultText!
              : 'Failed to send invite'),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invite sent to $email')),
    );
    await _load();
  }

  Future<void> _delete(DiscourseInvite invite) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Revoke invite?'),
        content: Text(
          invite.isLinkInvite
              ? 'The invite link will stop working.'
              : 'The invite to ${invite.email} will stop working.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final result = await _proxy.destroyInviteAsync(invite.id);
    if (!mounted) return;
    if (result.result) {
      setState(() => _invites?.removeWhere((i) => i.id == invite.id));
      await _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.resultText?.isNotEmpty == true
              ? result.resultText!
              : 'Failed to revoke invite'),
        ),
      );
    }
  }

  int _countFor(String filter) {
    switch (filter) {
      case 'pending':
        return _pendingCount;
      case 'expired':
        return _expiredCount;
      case 'redeemed':
        return _redeemedCount;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final forbidden = _forbiddenText != null;
    return Scaffold(
      appBar: SimpleListAppBar(
        title: 'Invites',
        actions: [
          if (!forbidden)
            IconButton(
              icon: const Icon(Icons.mail_outline),
              tooltip: 'Invite by email',
              onPressed: _showEmailInviteDialog,
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: forbidden
          ? null
          : FloatingActionButton.extended(
              onPressed: _creating ? null : _createInviteLink,
              icon: _creating
                  ? const SizedBox(
                      width: DesignTokens.iconSizeM,
                      height: DesignTokens.iconSizeM,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_link),
              label: const Text('New invite link'),
            ),
    );
  }

  Widget _buildBody() {
    if (_forbiddenText != null) {
      return EmptyStateView(
        icon: Icons.lock_outline,
        message: "You don't have permission to invite",
        hint: _forbiddenText,
      );
    }
    if (_loading && _invites == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        _buildFilterChips(),
        const Divider(height: 1),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: _buildList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingL,
        vertical: DesignTokens.spacingS,
      ),
      child: Row(
        children: [
          for (final f in _filters) ...[
            ChoiceChip(
              label: Text('${f.label} (${_countFor(f.value)})'),
              selected: _filter == f.value,
              onSelected: (selected) {
                if (!selected || _filter == f.value) return;
                setState(() {
                  _filter = f.value;
                  _invites = null;
                });
                _load();
              },
            ),
            if (f != _filters.last)
              const SizedBox(width: DesignTokens.spacingS),
          ],
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_error != null && (_invites?.isEmpty ?? true)) {
      return EmptyStateView.error(
        message: _error!,
        onRetry: _load,
        scrollable: true,
      );
    }
    final invites = _invites ?? const <DiscourseInvite>[];
    if (_loading && invites.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (invites.isEmpty) {
      return EmptyStateView.scrollable(
        icon: Icons.person_add_alt_outlined,
        message: 'No $_filter invites',
        hint: _filter == 'pending'
            ? 'Create an invite link to bring people to the forum.'
            : null,
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: DesignTokens.spacingXXL * 2),
      itemCount: invites.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) => _InviteRow(
        invite: invites[index],
        onCopy: invites[index].link.isNotEmpty
            ? () async {
                await Clipboard.setData(
                  ClipboardData(text: invites[index].link),
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invite link copied'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            : null,
        onDelete: invites[index].canDelete ? () => _delete(invites[index]) : null,
      ),
    );
  }
}

/// One invite row. Link invites lead with the link icon + URL, email
/// invites with the address; redeemed rows show who redeemed and when.
class _InviteRow extends StatelessWidget {
  final DiscourseInvite invite;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;

  const _InviteRow({
    required this.invite,
    this.onCopy,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMMMd(locale);

    final isRedeemed = invite.redeemedAt != null;
    final title = isRedeemed && invite.redeemedUsername != null
        ? '@${invite.redeemedUsername}'
        : invite.isLinkInvite
            ? (invite.link.isNotEmpty ? invite.link : 'Invite link')
            : (invite.email ?? '');

    final details = <String>[];
    if (isRedeemed) {
      details.add('Redeemed ${dateFormat.format(invite.redeemedAt!.toLocal())}');
    } else {
      if (invite.maxRedemptionsAllowed != null) {
        details.add(
          'Redeemed ${invite.redemptionCount ?? 0} of '
          '${invite.maxRedemptionsAllowed}',
        );
      }
      if (!invite.isLinkInvite) {
        details.add(invite.emailed ? 'Email sent' : 'Email not sent');
      }
      if (invite.expiresAt != null) {
        details.add(
          invite.expired
              ? 'Expired ${dateFormat.format(invite.expiresAt!.toLocal())}'
              : 'Expires ${dateFormat.format(invite.expiresAt!.toLocal())}',
        );
      }
    }

    return ListTile(
      leading: Icon(
        isRedeemed
            ? Icons.how_to_reg_outlined
            : invite.isLinkInvite
                ? Icons.link
                : Icons.mail_outline,
        color: invite.expired
            ? colorScheme.onSurfaceVariant
            : colorScheme.primary,
      ),
      title: Text(
        title,
        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: details.isNotEmpty
          ? Text(
              details.join(' · '),
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      onTap: onCopy,
      trailing: onDelete != null
          ? IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              tooltip: 'Revoke invite',
              onPressed: onDelete,
            )
          : null,
    );
  }
}
