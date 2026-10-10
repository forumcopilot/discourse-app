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
import '../l10n/generated/app_localizations.dart';
import '../l10n/kit_strings.dart';

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

  /// Optional override for hosts and tests; defaults to this forum's proxy.
  final DiscourseInviteProxy? proxy;

  const InvitesPage({super.key, required this.siteContext, this.proxy});

  @override
  State<InvitesPage> createState() => _InvitesPageState();
}

class _InvitesPageState extends State<InvitesPage> {
  static const _filters = ['pending', 'expired', 'redeemed'];

  /// A filter chip's label with its count, in Discourse's words.
  String _filterLabel(AppLocalizations l10n, String filter) {
    final count = _countFor(filter);
    switch (filter) {
      case 'expired':
        return l10n.invitesExpiredWithCount(count);
      case 'redeemed':
        return l10n.invitesRedeemedWithCount(count);
      default:
        return l10n.invitesPendingWithCount(count);
    }
  }

  /// The empty list's message for a filter.
  String _emptyMessage(AppLocalizations l10n, String filter) {
    switch (filter) {
      case 'expired':
        return l10n.invitesEmptyExpired;
      case 'redeemed':
        return l10n.invitesEmptyRedeemed;
      default:
        return l10n.invitesEmptyPending;
    }
  }

  String _filter = 'pending';
  List<DiscourseInvite>? _invites;
  int _pendingCount = 0;
  int _expiredCount = 0;
  int _redeemedCount = 0;
  bool _loading = true;
  bool _creating = false;
  int? _nextOffset;
  // Refreshes and filter changes invalidate older in-flight pages.
  int _generation = 0;
  String? _error;

  /// Set when the server answered with a 403-flavored refusal — the
  /// user isn't in `invite_allowed_groups`. Carries the server text.
  String? _forbiddenText;

  DiscourseInviteProxy get _proxy =>
      widget.proxy ?? DiscourseInviteProxy(widget.siteContext);

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

  /// Loads the first page of the current filter, or with [more] the next.
  ///
  /// A first page replaces the rows only once it has arrived: a refresh
  /// (pull to refresh, Retry) keeps the list on screen meanwhile, and if
  /// it fails the rows stay and the reason shows in a snack bar. Only a
  /// filter change ([_selectFilter]) empties the list first. It used to
  /// empty it on every reload, so a refresh showed a full-screen spinner.
  Future<void> _load({bool more = false}) async {
    if (more && (_loading || _nextOffset == null)) return;
    final generation = more ? _generation : ++_generation;
    final filter = _filter;
    final offset = more ? _nextOffset! : 0;
    setState(() {
      _loading = true;
      _error = null;
    });
    String? failure;
    try {
      final result =
          await _proxy.getMyInvitesAsync(filter: filter, offset: offset);
      if (!mounted || generation != _generation) return;
      if (!result.result) {
        if (!more && _looksForbidden(result.resultText)) {
          setState(() {
            _loading = false;
            _forbiddenText = result.resultText;
          });
          return;
        }
        failure = result.resultText?.isNotEmpty == true
            ? result.resultText
            : AppLocalizations.of(context)!.invitesLoadFailed;
      } else {
        setState(() {
          _loading = false;
          _forbiddenText = null;
          if (more) {
            // The server pages by row offset, so a row added or moved up
            // on the forum meanwhile comes round again: list it once.
            final listed = {for (final i in _invites ?? const []) i.id};
            _invites = [
              ...?_invites,
              for (final i in result.invites)
                if (listed.add(i.id)) i,
            ];
          } else {
            _invites = [...result.invites];
          }
          _nextOffset = result.nextOffset;
          _pendingCount = result.pendingCount;
          _expiredCount = result.expiredCount;
          _redeemedCount = result.redeemedCount;
        });
        return;
      }
    } catch (e) {
      if (!mounted || generation != _generation) return;
      failure = describeError(e);
    }
    final keptRows = !more && (_invites?.isNotEmpty ?? false);
    setState(() {
      _loading = false;
      _invites ??= [];
      // A failed Load more says so on its own row, with Retry; a failed
      // refresh keeps the rows it would have replaced.
      if (!keptRows) _error = failure;
    });
    if (keptRows) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeError(failure, context: context))),
      );
    }
  }

  /// Shows [filter]'s invites, from the first page.
  void _selectFilter(String filter) {
    if (_filter == filter) return;
    setState(() {
      _filter = filter;
      _invites = null;
      _nextOffset = null;
      _error = null;
    });
    _load();
  }

  /// A change made here (a revoke, a new invite) moves the server's rows
  /// under a page still on its way, which would then land at the wrong
  /// offset. That page is dropped; Load more asks again from the
  /// adjusted offset.
  void _dropPageInFlight() {
    if (!_loading) return;
    _generation++;
    _loading = false;
  }

  /// Takes a revoked invite off the list where it is, as the forum's own
  /// Invites page does (user-invited/show.js destroyInvite), instead of
  /// loading the list again: that showed a full-screen spinner and came
  /// back with the first page only, however far the reader had scrolled.
  /// The server's later rows move up one, so the next page starts a row
  /// earlier.
  void _removeInvite(int id) {
    final invites = _invites;
    if (invites == null || !invites.any((i) => i.id == id)) return;
    _dropPageInFlight();
    _invites = [
      for (final i in invites)
        if (i.id != id) i,
    ];
    final next = _nextOffset;
    if (next != null) _nextOffset = next > 0 ? next - 1 : 0;
    switch (_filter) {
      case 'pending':
        if (_pendingCount > 0) _pendingCount--;
      case 'expired':
        if (_expiredCount > 0) _expiredCount--;
      case 'redeemed':
        if (_redeemedCount > 0) _redeemedCount--;
    }
  }

  /// Puts a new invite at the top of Pending, as the forum's invite dialog
  /// does (create-invite.gjs), instead of loading the list again. Pending
  /// lists the most recently updated first (`Invite.pending`), and inviting
  /// an address again renews its pending invite (`Invite.generate`), so an
  /// invite already listed moves to the top rather than counting twice.
  void _addInvite(DiscourseInvite invite) {
    final invites = _invites;
    // A new invite is pending; Redeemed rows carry another kind of id.
    final listed = _filter == 'pending' &&
        (invites?.any((i) => i.id == invite.id) ?? false);
    if (_filter == 'pending' && invites == null) {
      // The first page is still on its way: ask for it again.
      _load();
      return;
    }
    setState(() {
      if (!listed) _pendingCount++;
      if (_filter != 'pending' || invites == null) return;
      _dropPageInFlight();
      _invites = [
        invite,
        for (final i in invites)
          if (i.id != invite.id) i,
      ];
      final next = _nextOffset;
      if (!listed && next != null) _nextOffset = next + 1;
    });
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
              : AppLocalizations.of(context)!.inviteLinkCreateFailed),
        ),
      );
      return;
    }
    _addInvite(result.invite!);
    await _showInviteLinkSheet(result.invite!);
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
                  AppLocalizations.of(context)!.inviteLinkCreated,
                  style: textTheme.titleMedium,
                ),
                if (invite.expiresAt != null) ...[
                  SizedBox(height: DesignTokens.spacingXS),
                  Text(
                    AppLocalizations.of(context)!.expiresOn(
                        DateFormat.yMMMd().format(invite.expiresAt!.toLocal())),
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
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .inviteLinkCopied),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded),
                        label: Text(AppLocalizations.of(context)!.kit.copy),
                      ),
                    ),
                    SizedBox(width: DesignTokens.spacingM),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => SharePlus.instance
                            .share(ShareParams(text: invite.link)),
                        icon: const Icon(Icons.share_outlined),
                        label: Text(AppLocalizations.of(context)!.kit.share),
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
          title: Text(AppLocalizations.of(context)!.inviteByEmail),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.inviteEmailAddressLabel,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty || !v.contains('@')) {
                      return AppLocalizations.of(context)!.inviteEmailInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: DesignTokens.spacingM),
                TextFormField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!
                        .inviteMessageOptionalLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppLocalizations.of(context)!.kit.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
              child: Text(AppLocalizations.of(context)!.sendInvite),
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
              : AppLocalizations.of(context)!.inviteSendFailed),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(AppLocalizations.of(context)!.inviteSentTo(email))),
    );
    final invite = result.invite;
    if (invite != null) {
      _addInvite(invite);
    } else {
      await _load();
    }
  }

  Future<void> _delete(DiscourseInvite invite) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.revokeInviteQuestion),
        content: Text(
          invite.isLinkInvite
              ? AppLocalizations.of(context)!.revokeInviteLinkWarning
              : AppLocalizations.of(context)!
                  .revokeInviteEmailWarning(invite.email ?? ''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppLocalizations.of(context)!.kit.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(AppLocalizations.of(context)!.revoke),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final result = await _proxy.destroyInviteAsync(invite.id);
    if (!mounted) return;
    if (result.result) {
      setState(() => _removeInvite(invite.id));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.resultText?.isNotEmpty == true
              ? result.resultText!
              : AppLocalizations.of(context)!.inviteRevokeFailed),
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
        title: AppLocalizations.of(context)!.invites,
        actions: [
          if (!forbidden)
            IconButton(
              icon: const Icon(Icons.mail_outline),
              tooltip: AppLocalizations.of(context)!.inviteByEmail,
              onPressed: _showEmailInviteDialog,
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: forbidden
          ? null
          : FloatingActionButton.extended(
              heroTag: null,
              onPressed: _creating ? null : _createInviteLink,
              icon: _creating
                  ? const SizedBox(
                      width: DesignTokens.iconSizeM,
                      height: DesignTokens.iconSizeM,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_link),
              label: Text(AppLocalizations.of(context)!.newInviteLink),
            ),
    );
  }

  Widget _buildBody() {
    if (_forbiddenText != null) {
      return EmptyStateView(
        icon: Icons.lock_outline,
        message: AppLocalizations.of(context)!.inviteNoPermission,
        hint: _forbiddenText,
      );
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
    // Scrolls sideways: with their counts, the three chips are wider than
    // a phone (the last one overflowed on a Pixel 4a).
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingL,
        vertical: DesignTokens.spacingS,
      ),
      child: Row(
        children: [
          for (final f in _filters) ...[
            ChoiceChip(
              label: Text(_filterLabel(AppLocalizations.of(context)!, f)),
              selected: _filter == f,
              onSelected: (selected) {
                if (selected) _selectFilter(f);
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
        message: describeError(_error, context: context),
        onRetry: _load,
        scrollable: true,
      );
    }
    final invites = _invites ?? const <DiscourseInvite>[];
    if (_loading && invites.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (invites.isEmpty && _nextOffset == null) {
      return EmptyStateView.scrollable(
        icon: Icons.person_add_alt_outlined,
        message: _emptyMessage(AppLocalizations.of(context)!, _filter),
        hint: _filter == 'pending'
            ? AppLocalizations.of(context)!.invitesEmptyPendingHint
            : null,
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: DesignTokens.spacingXXL * 2),
      key: ValueKey(_filter),
      itemCount: invites.length + (_nextOffset != null ? 1 : 0),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index == invites.length) {
          return Padding(
            padding: DesignTokens.paddingL,
            child: Column(
              children: [
                if (_error != null)
                  Text(describeError(_error, context: context)),
                if (_loading)
                  const CircularProgressIndicator()
                else
                  TextButton(
                    onPressed: () => _load(more: true),
                    child: Text(_error == null
                        ? AppLocalizations.of(context)!.loadMore
                        : AppLocalizations.of(context)!.retry),
                  ),
              ],
            ),
          );
        }
        return _InviteRow(
          invite: invites[index],
          onCopy: invites[index].link.isNotEmpty
              ? () async {
                  await Clipboard.setData(
                    ClipboardData(text: invites[index].link),
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(AppLocalizations.of(context)!.inviteLinkCopied),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              : null,
          onDelete:
              invites[index].canDelete ? () => _delete(invites[index]) : null,
        );
      },
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
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMMMd(locale);

    final isRedeemed = invite.redeemedAt != null;
    final title = isRedeemed && invite.redeemedUsername != null
        ? '@${invite.redeemedUsername}'
        : invite.isLinkInvite
            ? (invite.link.isNotEmpty
                ? invite.link
                : l10n.inviteLinkFallbackTitle)
            : (invite.email ?? '');

    final details = <String>[];
    if (isRedeemed) {
      details.add(l10n
          .inviteRedeemedOn(dateFormat.format(invite.redeemedAt!.toLocal())));
    } else {
      if (invite.maxRedemptionsAllowed != null) {
        details.add(l10n.inviteRedemptions(
          invite.redemptionCount ?? 0,
          invite.maxRedemptionsAllowed!,
        ));
      }
      if (!invite.isLinkInvite) {
        details.add(
            invite.emailed ? l10n.inviteEmailSent : l10n.inviteEmailNotSent);
      }
      if (invite.expiresAt != null) {
        details.add(
          invite.expired
              ? l10n.inviteExpiredOn(
                  dateFormat.format(invite.expiresAt!.toLocal()))
              : l10n.expiresOn(dateFormat.format(invite.expiresAt!.toLocal())),
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
        color:
            invite.expired ? colorScheme.onSurfaceVariant : colorScheme.primary,
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
              tooltip: l10n.inviteRevokeTooltip,
              onPressed: onDelete,
            )
          : null,
    );
  }
}
