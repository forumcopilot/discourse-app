import 'package:discourse_core/discourse_core.dart' show DiscoursePostProxy;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';

import '../../core/logging/app_logger.dart';
import '../../theme/design_tokens.dart';

/// Discourse's flag options, in the order the web modal lists them.
///
/// The app previously offered a single free-text "Reason" box and always filed the
/// result as `notify_moderators` — so every report reached moderators as
/// "Something Else", and Off-Topic, Spam, Inappropriate and Notify-User were
/// unreachable. These ids were verified against a live server's `post_action_types`
/// table, not taken from documentation.
enum _FlagOption {
  notifyUser(
    DiscoursePostProxy.flagNotifyUser,
    'Message the author',
    'Send them a private message. Moderators are not involved.',
    needsMessage: true,
    isPrivateMessage: true,
  ),
  offTopic(
    DiscoursePostProxy.flagOffTopic,
    'Off-Topic',
    'This post does not belong in this topic.',
  ),
  inappropriate(
    DiscoursePostProxy.flagInappropriate,
    'Inappropriate',
    'This post is offensive, abusive, or a violation of the community guidelines.',
  ),
  spam(
    DiscoursePostProxy.flagSpam,
    'Spam',
    'This post is an advertisement, or vandalism.',
  ),
  other(
    DiscoursePostProxy.flagNotifyModerators,
    'Something Else',
    'This post needs staff attention for another reason.',
    needsMessage: true,
  );

  const _FlagOption(
    this.typeId,
    this.label,
    this.description, {
    this.needsMessage = false,
    this.isPrivateMessage = false,
  });

  final int typeId;
  final String label;
  final String description;

  /// Discourse requires a `message` for the two notify types and rejects them without
  /// one, so the text field becomes mandatory for these.
  final bool needsMessage;

  /// Goes to the author rather than the moderators — worth saying out loud, since the
  /// consequence differs from every other option here.
  final bool isPrivateMessage;
}

/// Shows Discourse's flag options and files the chosen one.
///
/// Discourse-only on purpose: flag types are Discourse's taxonomy. XenForo keeps the
/// generic free-text report dialog in [PostActionsHandler.handleReport].
///
/// Used for both regular posts and private messages — a Discourse PM message *is* a
/// post, so the same endpoint and ids apply.
Future<void> showDiscourseReportDialog(
  BuildContext context, {
  required String postId,
}) async {
  final proxy = SiteProxyFactory.getPostProxy();
  if (proxy is! DiscoursePostProxy) {
    AppLogger.debug('showDiscourseReportDialog called on a non-Discourse site');
    return;
  }

  final result = await showDialog<({_FlagOption option, String message})>(
    context: context,
    builder: (dialogContext) => _ReportDialog(),
  );
  if (result == null || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(
    const SnackBar(content: Text('Submitting report…')),
  );

  final response = await proxy.flagPostAsync(
    postId,
    result.option.typeId,
    message: result.message,
  );

  if (!context.mounted) return;
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        response.result
            ? (result.option.isPrivateMessage
                ? 'Your message has been sent.'
                : 'Thanks — moderators have been notified.')
            : ((response.resultText ?? '').isNotEmpty
                ? response.resultText!
                : 'Could not submit the report.'),
      ),
    ),
  );
}

class _ReportDialog extends StatefulWidget {
  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  _FlagOption? _selected;
  final _messageController = TextEditingController();
  bool _showMessageError = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  bool get _messageMissing =>
      (_selected?.needsMessage ?? false) && _messageController.text.trim().isEmpty;

  void _submit() {
    if (_selected == null) return;
    if (_messageMissing) {
      setState(() => _showMessageError = true);
      return;
    }
    Navigator.of(context).pop(
      (option: _selected!, message: _messageController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Report'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final option in _FlagOption.values)
              InkWell(
                onTap: () => setState(() {
                  _selected = option;
                  _showMessageError = false;
                }),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: DesignTokens.spacingXS),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Radio<_FlagOption>(
                        value: option,
                        groupValue: _selected,
                        onChanged: (v) => setState(() {
                          _selected = v;
                          _showMessageError = false;
                        }),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(option.label, style: textTheme.titleSmall),
                            Text(
                              option.description,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Only the notify types accept free text, and Discourse rejects them
            // without it — so the field appears exactly when it is required.
            if (_selected?.needsMessage ?? false) ...[
              const SizedBox(height: DesignTokens.spacingM),
              TextField(
                controller: _messageController,
                maxLines: 3,
                autofocus: true,
                onChanged: (_) {
                  if (_showMessageError) setState(() => _showMessageError = false);
                },
                decoration: InputDecoration(
                  labelText: _selected!.isPrivateMessage
                      ? 'Your message'
                      : 'Tell the moderators what is wrong',
                  border: const OutlineInputBorder(),
                  errorText: _showMessageError ? 'A message is required.' : null,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selected == null ? null : _submit,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
