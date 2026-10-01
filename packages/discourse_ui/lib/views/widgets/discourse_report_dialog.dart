import 'package:discourse_core/discourse_core.dart'
    show DiscourseFlagType, DiscoursePostProxy, DiscourseSiteCapabilities;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';

import '../../core/logging/app_logger.dart';
import '../../theme/design_tokens.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/snackbar_helper.dart';

/// Web's flag modal: the forum's own flag types, in its order and language
/// (`post_action_types` in `/site.json`), and the chosen one filed with
/// POST /post_actions.
///
/// The list used to be five options hard-coded in English, which left out
/// "Illegal" and any flag a forum adds. A flag that needs a message (to the
/// author, to staff, about illegal content) asks for one of the forum's
/// minimum length, as web does; an illegal-content flag also asks the reader
/// to confirm what they wrote.
///
/// Used for posts and private messages alike: a message is a post.
/// [authorUsername] names the author in "Send @… a message", which is left
/// out for the reader's own post ([ownPost]).
Future<void> showDiscourseReportDialog(
  BuildContext context, {
  required String postId,
  String? authorUsername,
  bool ownPost = false,
}) async {
  final proxy = SiteProxyFactory.getPostProxy();
  if (proxy is! DiscoursePostProxy) {
    AppLogger.debug('showDiscourseReportDialog called on a non-Discourse site');
    return;
  }
  final l10n = AppLocalizations.of(context)!;
  final types = (await proxy.flagTypesAsync())
      .where((t) =>
          !t.isMessageToAuthor || (!ownPost && (authorUsername ?? '').isNotEmpty))
      .toList(growable: false);
  if (!context.mounted) return;
  if (types.isEmpty) {
    SnackbarHelper.showError(context, l10n.flagCant);
    return;
  }

  final result = await showDialog<({DiscourseFlagType type, String message})>(
    context: context,
    builder: (dialogContext) => _FlagDialog(
      types: types,
      authorUsername: authorUsername ?? '',
      minMessageLength: DiscourseSiteCapabilities.forSite(
              proxy.siteContext.site.pluginUrl)
          .minPersonalMessageLength,
    ),
  );
  if (result == null || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(SnackBar(content: Text(l10n.flaggingPost)));

  final response = await proxy.flagPostAsync(
    postId,
    result.type.id,
    message: result.message,
  );

  if (!context.mounted) return;
  messenger.hideCurrentSnackBar();
  if (response.result) {
    messenger.showSnackBar(SnackBar(
      content: Text(result.type.isMessageToAuthor
          ? l10n.flagMessageSent
          : l10n.flagThanks),
    ));
  } else {
    SnackbarHelper.showError(
        context,
        (response.resultText ?? '').isNotEmpty
            ? response.resultText!
            : l10n.flagCant);
  }
}

class _FlagDialog extends StatefulWidget {
  const _FlagDialog({
    required this.types,
    required this.authorUsername,
    required this.minMessageLength,
  });

  final List<DiscourseFlagType> types;
  final String authorUsername;
  final int minMessageLength;

  @override
  State<_FlagDialog> createState() => _FlagDialogState();
}

class _FlagDialogState extends State<_FlagDialog> {
  DiscourseFlagType? _selected;
  final _messageController = TextEditingController();
  bool _showMessageError = false;
  bool _confirmedIllegal = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  bool get _needsMessage => _selected?.requireMessage ?? false;
  bool get _isIllegal => _selected?.nameKey == 'illegal';

  bool get _messageTooShort =>
      _needsMessage &&
      _messageController.text.trim().length < widget.minMessageLength;

  void _submit() {
    if (_selected == null) return;
    if (_messageTooShort) {
      setState(() => _showMessageError = true);
      return;
    }
    Navigator.of(context).pop(
      (type: _selected!, message: _needsMessage ? _messageController.text.trim() : ''),
    );
  }

  String _label(DiscourseFlagType t) =>
      t.isMessageToAuthor ? t.nameFor(widget.authorUsername) : t.name;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final selected = _selected;
    return AlertDialog(
      title: Text(l10n.flagPost),
      content: SingleChildScrollView(
        child: RadioGroup<DiscourseFlagType>(
          groupValue: selected,
          onChanged: (v) => setState(() {
            _selected = v;
            _showMessageError = false;
            _confirmedIllegal = false;
          }),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.flagReviewProcess,
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: DesignTokens.spacingS),
              // M3's radio rows: the label at bodyLarge beside the radio,
              // the description under it at bodyMedium.
              for (final type in widget.types)
                RadioListTile<DiscourseFlagType>(
                  key: ValueKey('flag-${type.nameKey}'),
                  value: type,
                  contentPadding: EdgeInsets.zero,
                  // The radio beside the label, not centred on the block:
                  // its 40dp box is placed at the tile's top, so the label
                  // moves down 8dp to share its centre line.
                  titleAlignment: ListTileTitleAlignment.top,
                  title: Padding(
                    padding: const EdgeInsets.only(top: DesignTokens.spacingS),
                    child: Text(_label(type)),
                  ),
                  subtitle:
                      type.description.isEmpty ? null : Text(type.description),
                ),

              // Only the flags Discourse refuses without a message ask for
              // one, so the field appears exactly when it is required.
              if (selected != null && _needsMessage) ...[
                const SizedBox(height: DesignTokens.spacingM),
                TextField(
                  key: const ValueKey('flag-message'),
                  controller: _messageController,
                  maxLines: 3,
                  autofocus: true,
                  onChanged: (_) {
                    if (_showMessageError) setState(() => _showMessageError = false);
                  },
                  decoration: InputDecoration(
                    labelText: selected.isMessageToAuthor
                        ? l10n.flagMessageForUser
                        : l10n.flagMessageForModerators,
                    hintText: selected.isMessageToAuthor
                        ? l10n.flagPlaceholderNotifyUser
                        : _isIllegal
                            ? l10n.flagPlaceholderIllegal
                            : l10n.flagPlaceholderNotifyModerators,
                    hintMaxLines: 4,
                    border: const OutlineInputBorder(),
                    errorText: _showMessageError
                        ? l10n.flagMessageAtLeast(widget.minMessageLength)
                        : null,
                  ),
                ),
              ],
              if (_isIllegal)
                CheckboxListTile(
                  key: const ValueKey('flag-confirm-illegal'),
                  value: _confirmedIllegal,
                  onChanged: (v) => setState(() => _confirmedIllegal = v ?? false),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(l10n.flagConfirmIllegal),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: selected == null || (_isIllegal && !_confirmedIllegal)
              ? null
              : _submit,
          child: Text(selected?.isMessageToAuthor ?? false
              ? l10n.flagSendMessage
              : l10n.flagPost),
        ),
      ],
    );
  }
}
