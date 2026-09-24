import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// Discourse's "Post Needs Approval" notice, for a post the forum queued for
/// a moderator (the create call answered `action: enqueued`). The composer
/// used to close as if the post had been published, and it never appeared.
Future<void> showPostNeedsApproval(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.postNeedsApprovalTitle),
      content: Text(l10n.postNeedsApprovalBody),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.okButton),
        ),
      ],
    ),
  );
}
