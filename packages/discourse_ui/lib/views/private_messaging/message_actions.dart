import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../utils/error_message.dart';
import 'conversation/pages/edit_conversation_page.dart';

/// What a private message offers beyond a topic — archive, mark unread,
/// close, leave, edit the title — for the topic page, which reads messages
/// too (a Discourse message is a topic).
///
/// Each returns whether it happened; failures are shown here. Archive, Move
/// to inbox, Mark unread and Leave take the message out of the list it was
/// opened from, so the caller closes the page with `true`, which the inbox
/// reads as "reload".
class MessageActions {
  MessageActions._();

  static void _fail(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: Theme.of(context).colorScheme.error,
    ));
  }

  static void _done(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  static Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String action,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (dialog) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialog, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialog, true),
                child: Text(action),
              ),
            ],
          ),
        ) ==
        true;
  }

  /// Archive the message, or move it back to the inbox.
  static Future<bool> setArchived(
      BuildContext context, String topicId, bool archive) async {
    final l10n = AppLocalizations.of(context)!;
    final proxy = SiteProxyFactory.getPrivateConversationProxy();
    try {
      final r = archive
          ? await proxy.archiveConversationAsync(topicId)
          : await proxy.unarchiveConversationAsync(topicId);
      if (!context.mounted) return false;
      if (!r.result) {
        _fail(
            context,
            archive
                ? l10n.failedToArchiveMessage(r.resultText ?? '')
                : l10n.failedToMoveMessageToInbox(r.resultText ?? ''));
        return false;
      }
      _done(context, archive ? l10n.messageArchived : l10n.messageMovedToInbox);
      return true;
    } catch (e) {
      if (context.mounted) {
        _fail(
            context,
            archive
                ? l10n.failedToArchiveMessage(describeError(e))
                : l10n.failedToMoveMessageToInbox(describeError(e)));
      }
      return false;
    }
  }

  /// Mark the message unread again (Discourse forgets the reader's timings).
  static Future<bool> markUnread(BuildContext context, String topicId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final r = await SiteProxyFactory.getPrivateConversationProxy()
          .markConversationUnreadAsync(topicId);
      if (!context.mounted) return false;
      if (!r.result) {
        _fail(context, l10n.failedToMarkConversationAsUnread(r.resultText ?? ''));
        return false;
      }
      _done(context, l10n.conversationMarkedAsUnread);
      return true;
    } catch (e) {
      if (context.mounted) {
        _fail(context, l10n.failedToMarkConversationAsUnread(describeError(e)));
      }
      return false;
    }
  }

  /// Close the message to replies, or open it again, after asking.
  static Future<bool> setClosed(
      BuildContext context, String topicId, bool close) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirm(
      context,
      title: close ? l10n.closeConversation2 : l10n.openConversation2,
      body: close
          ? l10n.closeConversationConfirmation
          : l10n.openConversationConfirmation,
      action: close ? l10n.close : l10n.open,
    );
    if (!confirmed || !context.mounted) return false;
    final proxy = SiteProxyFactory.getPrivateConversationProxy();
    try {
      final r = close
          ? await proxy.closeConversationAsync(topicId)
          : await proxy.uncloseConversationAsync(topicId);
      if (!context.mounted) return false;
      if (!r.result) {
        _fail(
            context,
            close
                ? l10n.failedToCloseConversation(r.resultText ?? '')
                : l10n.failedToOpenConversation(r.resultText ?? ''));
        return false;
      }
      _done(context, close ? l10n.conversationClosed : l10n.conversationOpened);
      return true;
    } catch (e) {
      if (context.mounted) {
        _fail(
            context,
            close
                ? l10n.failedToCloseConversation(describeError(e))
                : l10n.failedToOpenConversation(describeError(e)));
      }
      return false;
    }
  }

  /// Remove the viewer from the message, after asking.
  static Future<bool> leave(BuildContext context, String topicId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirm(
      context,
      title: l10n.leaveConversation3,
      body: l10n.leaveConversationConfirmation,
      action: l10n.leave,
    );
    if (!confirmed || !context.mounted) return false;
    try {
      final r = await SiteProxyFactory.getPrivateConversationProxy()
          .leaveConversationAsync(topicId, 1);
      if (!context.mounted) return false;
      if (!r.result) {
        // The screen used to close regardless, and the list then dropped a
        // message the server had refused to let the user leave.
        _fail(context, l10n.failedToLeaveConversation(r.resultText ?? ''));
        return false;
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        _fail(context, l10n.failedToLeaveConversation(describeError(e)));
      }
      return false;
    }
  }

  /// Edit the message's title (and, for those who may, close it).
  static Future<bool> editTitle(
    BuildContext context, {
    required SiteContext siteContext,
    required String topicId,
    required bool canClose,
  }) async {
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => EditConversationPage(
        siteContext: siteContext,
        conversationId: topicId,
        canClose: canClose,
      ),
    ));
    return saved == true;
  }
}
