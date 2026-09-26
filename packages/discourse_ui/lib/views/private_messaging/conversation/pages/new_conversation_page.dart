import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:image_picker/image_picker.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';
import 'package:discourse_ui/views/user_search_page.dart';
import 'package:discourse_ui/views/widgets/message_compose_page.dart';
import 'package:discourse_ui/views/widgets/user_avatar.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../services/attachment_upload_service.dart';
import '../../../../theme/design_tokens.dart';
import 'conversation_page.dart';

/// New Message: the shared composer ([MessageComposePage]) with the
/// recipients above the title.
///
/// It used to be a separate copy of the composer that had drifted from it
/// (its own toolbar, attachment list and error handling). What is still its
/// own is only what a message needs: the recipients, the upload type and
/// where it lands once sent — use [open], which then opens the new message.
class NewConversationPage extends StatefulWidget {
  final SiteContext siteContext;
  final String? initialRecipient;
  final String? initialRecipientIconUrl;

  const NewConversationPage({
    super.key,
    required this.siteContext,
    this.initialRecipient,
    this.initialRecipientIconUrl,
  });

  /// Opens New Message and, once it is sent, the new message — as New Topic
  /// opens the new topic. Done here rather than inside the composer: the
  /// composer pops itself on success, which would pop any route it pushed.
  ///
  /// Returns whether a message was sent (the new message is then on top).
  static Future<bool> open(
    BuildContext context, {
    required SiteContext siteContext,
    String? initialRecipient,
    String? initialRecipientIconUrl,
  }) async {
    final created =
        await Navigator.of(context).push<({String id, String title})?>(
      MaterialPageRoute(
        builder: (_) => NewConversationPage(
          siteContext: siteContext,
          initialRecipient: initialRecipient,
          initialRecipientIconUrl: initialRecipientIconUrl,
        ),
      ),
    );
    if (created == null) return false;
    if (context.mounted) {
      unawaited(Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ConversationPage(
            siteContext: siteContext,
            conversationId: created.id,
            subject: created.title,
          ),
        ),
      ));
    }
    return true;
  }

  @override
  State<NewConversationPage> createState() => _NewConversationPageState();
}

class _NewConversationPageState extends State<NewConversationPage> {
  final List<String> _recipients = [];
  final Map<String, String?> _recipientIcons = {};
  final List<String> _attachmentIds = [];
  bool _canUpload = false;

  /// Set once the message is sent; the composer pops with it.
  ({String id, String title})? _created;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRecipient;
    if (initial != null) {
      _recipients.add(initial);
      _recipientIcons[initial] = widget.initialRecipientIconUrl;
    }
    _fetchCanUpload();
  }

  /// Whether this user may attach files to a message; the message list
  /// carries it.
  Future<void> _fetchCanUpload() async {
    try {
      final data = await SiteProxyFactory.getPrivateConversationProxy()
          .getConversationsAsync(0, 0);
      if (mounted) setState(() => _canUpload = data.canUpload);
    } catch (e, st) {
      AppLogger.error('New message: could not read canUpload',
          error: e, stackTrace: st);
    }
  }

  /// Sends the message. Throws with a readable message on failure; the
  /// composer shows it and keeps what was typed.
  Future<bool> _submit(String title, String content) async {
    final l10n = AppLocalizations.of(context)!;
    if (_recipients.isEmpty) throw Exception(l10n.pleaseAddARecipient);
    if (title.trim().isEmpty) throw Exception(l10n.pleaseEnterTitle);
    if (content.trim().isEmpty) throw Exception(l10n.pleaseEnterContent);

    final result =
        await SiteProxyFactory.getPrivateConversationProxy().newConversationAsync(
      _recipients,
      title,
      content,
      attachmentIds: _attachmentIds.isNotEmpty ? _attachmentIds : null,
    );
    if (!result.result) {
      final message = result.resultText?.trim();
      throw Exception(message != null && message.isNotEmpty
          ? message
          : l10n.messageCouldNotBeSent);
    }
    if (result.convId.isEmpty) throw Exception(l10n.messageSentWithoutId);
    _created = (id: result.convId, title: title);
    return true;
  }

  /// Uploads one picked file and returns Discourse's `upload://` ref, which
  /// the message's raw text gets on send.
  Future<String?> _upload(XFile file) async {
    final outcome = await AttachmentUploadService.upload(
      context: context,
      file: file,
      uploadType: 'pm',
      targetId: '',
      groupId: '',
      currentAttachmentCount: _attachmentIds.length,
    );
    if (outcome.cancelled) return null;
    if (!outcome.succeeded) {
      if (mounted && outcome.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(outcome.errorMessage!)),
        );
      }
      return null;
    }
    setState(() => _attachmentIds.add(outcome.shortUrl!));
    return outcome.shortUrl;
  }

  Future<void> _addRecipient() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserSearchPage(
          siteContext: widget.siteContext,
          onUserSelected: (_, __) {},
          selectedUsers: [..._recipients],
        ),
      ),
    );
    if (result is! Map<String, dynamic>) return;
    final username = result['username'] as String;
    if (_recipients.contains(username)) return;
    setState(() {
      _recipients.add(username);
      _recipientIcons[username] = result['iconUrl'] as String?;
    });
  }

  /// An outlined field with its label in it, like the title and message
  /// under it, holding the recipients as input chips.
  Widget _recipientField() {
    final l10n = AppLocalizations.of(context)!;
    return InputDecorator(
      decoration: InputDecoration(labelText: l10n.participantsLabel),
      child: Wrap(
        spacing: DesignTokens.spacingS,
        runSpacing: DesignTokens.spacingS,
        children: [
          for (final username in _recipients)
            InputChip(
              avatar: UserAvatar(
                username: username,
                iconUrl: _recipientIcons[username],
                radius: DesignTokens.radiusM,
              ),
              label: Text(username),
              onDeleted: () => setState(() {
                _recipients.remove(username);
                _recipientIcons.remove(username);
              }),
            ),
          ActionChip(
            avatar: const Icon(Icons.add),
            label: Text(l10n.add),
            onPressed: _addRecipient,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MessageComposePage(
      siteContext: widget.siteContext,
      title: l10n.newConversation,
      submitLabel: l10n.send,
      showTitleField: true,
      titleHint: l10n.messageTitleHint,
      contentLabel: l10n.message,
      contentHint: l10n.writeYourMessage,
      extraHeader: _recipientField(),
      onSubmit: _submit,
      onSuccess: (_) => _created,
      onFileUpload: _canUpload ? _upload : null,
      onRemoveAttachment: (id) async =>
          setState(() => _attachmentIds.remove(id)),
    );
  }
}
