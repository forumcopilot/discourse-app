import 'package:discourse_core/discourse_core.dart'
    show DiscourseForumProxy, DiscourseTopicProxy;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../services/topic_tracking_service.dart';
import '../../theme/design_tokens.dart';
import '../../utils/error_dialog.dart';
import '../../l10n/kit_strings.dart';

/// Which of Discourse's two dismissals a list offers: web puts "Dismiss
/// New" on the New list and "Dismiss…" on Unread, and nowhere else.
enum DismissKind { newTopics, unread }

/// The dismiss action at the top of a New or Unread list, where the topics
/// it acts on are. It replaces "Mark all read" in the app bar, which sat on
/// every list whatever was showing and cleared only unread replies.
class DismissTopicsBar extends StatelessWidget {
  const DismissTopicsBar({
    super.key,
    required this.siteContext,
    required this.kind,
    this.categoryId,
    this.onDismissed,
  });

  final SiteContext siteContext;
  final DismissKind kind;

  /// Limits it to a category and its subcategories; null is the whole
  /// forum.
  final int? categoryId;

  /// After the server has dismissed them: reload the list.
  final VoidCallback? onDismissed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spacingL,
        0,
        DesignTokens.spacingS,
        0,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: TextButton.icon(
          onPressed: () => dismissTopics(context, siteContext,
              kind: kind, categoryId: categoryId, onDismissed: onDismissed),
          icon: const Icon(Icons.done_all_rounded),
          label: Text(kind == DismissKind.newTopics
              ? l10n.dismissNew
              : l10n.dismissUnread),
        ),
      ),
    );
  }
}

/// Asks, then dismisses: new topics (PUT /topics/reset-new) or unread
/// replies (PUT /topics/bulk), with web's "Stop tracking these topics"
/// choice for the latter. Nothing on the server can undo either, hence the
/// question.
Future<void> dismissTopics(
  BuildContext context,
  SiteContext siteContext, {
  required DismissKind kind,
  int? categoryId,
  VoidCallback? onDismissed,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final stopTracking = ValueNotifier(false);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(kind == DismissKind.newTopics
          ? l10n.dismissNewTitle
          : l10n.dismissUnreadTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(kind == DismissKind.newTopics
              ? l10n.dismissNewMessage
              : l10n.dismissUnreadMessage),
          if (kind == DismissKind.unread)
            ValueListenableBuilder<bool>(
              valueListenable: stopTracking,
              builder: (context, value, _) => CheckboxListTile(
                value: value,
                onChanged: (v) => stopTracking.value = v ?? false,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(l10n.dismissUnreadStopTracking),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.kit.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.dismiss),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) {
    stopTracking.dispose();
    return;
  }
  final proxy = DiscourseTopicProxy(siteContext);
  final result = kind == DismissKind.newTopics
      ? await proxy.dismissNewAsync(categoryId: categoryId)
      : await proxy.dismissUnreadAsync(
          categoryId: categoryId, stopTracking: stopTracking.value);
  stopTracking.dispose();
  if (!context.mounted) return;
  _afterDismiss(context, siteContext, result.result, result.resultText ?? '',
      onDismissed);
}

/// A category's "Dismiss new and unread": both of the above for it and its
/// subcategories, after asking (the forum proxy's markAllAsRead, which
/// makes both requests).
Future<void> dismissNewAndUnread(
  BuildContext context,
  SiteContext siteContext, {
  required String categoryId,
  required String categoryName,
  VoidCallback? onDismissed,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('${l10n.dismissNewAndUnread}?'),
      content: Text(l10n.dismissNewAndUnreadMessage(categoryName)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.kit.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.dismiss),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  final r = await DiscourseForumProxy(siteContext).markAllAsRead(categoryId);
  if (!context.mounted) return;
  _afterDismiss(
      context, siteContext, r.result, r.resultText ?? '', onDismissed);
}

void _afterDismiss(BuildContext context, SiteContext siteContext, bool ok,
    String error, VoidCallback? onDismissed) {
  if (!ok) {
    showErrorDialog(error);
    return;
  }
  onDismissed?.call();
  // The counts: the dismissed topics are already out of them, but a
  // forum-wide "Dismiss new" also moves the viewer's new-since line.
  TopicTrackingService.refresh(siteContext, maxAge: Duration.zero);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(AppLocalizations.of(context)!.dismissedTopics)),
  );
}
