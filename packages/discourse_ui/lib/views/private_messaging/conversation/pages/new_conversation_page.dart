import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:image_picker/image_picker.dart';
import 'package:discourse_ui/views/user_search_page.dart';
import 'package:discourse_ui/views/widgets/message_compose_page.dart';
import 'package:discourse_ui/views/widgets/user_avatar.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../services/attachment_upload_service.dart';
import '../../../../theme/design_tokens.dart';
import '../../../../utils/app_navigation.dart';
import '../../../../utils/discourse_draft_controller.dart';
import '../../../../utils/post_submission.dart';
import '../../../lists/posts_list.dart' show PostsListMode;
import '../../../post_page.dart';

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

  /// The server draft to write to, and to resume from. Each new message has
  /// its own, keyed as the web keys them (`new_private_message_<time>`); the
  /// drafts list passes an existing one back.
  final String? draftKey;

  const NewConversationPage({
    super.key,
    required this.siteContext,
    this.initialRecipient,
    this.initialRecipientIconUrl,
    this.draftKey,
  });

  /// Whether [key] names a new message's draft (`new_private_message`, or
  /// `new_private_message_<time>` as the web keys them).
  static bool isDraftKey(String key) =>
      key == 'new_private_message' || key.startsWith('new_private_message_');

  /// Opens New Message, which becomes the new message once it is sent (as
  /// New Topic becomes the new topic), so Back from the message returns to
  /// the page New Message was opened from.
  ///
  /// Returns whether a message was sent (the new message is then on top).
  static Future<bool> open(
    BuildContext context, {
    required SiteContext siteContext,
    String? initialRecipient,
    String? initialRecipientIconUrl,
    String? draftKey,
  }) async {
    final created =
        await AppNavigation.pushForm<({String id, String title})?>(
      context,
      NewConversationPage(
        siteContext: siteContext,
        initialRecipient: initialRecipient,
        initialRecipientIconUrl: initialRecipientIconUrl,
        draftKey: draftKey,
      ),
    );
    return created != null;
  }

  @override
  State<NewConversationPage> createState() => _NewConversationPageState();
}

class _NewConversationPageState extends State<NewConversationPage> {
  final List<String> _recipients = [];
  bool _recipientsChanged = false;
  final Map<String, String?> _recipientIcons = {};

  /// Recipients that are groups (a message can go to a group's inbox).
  final Set<String> _groupRecipients = {};
  final List<String> _attachmentIds = [];
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late final DiscourseDraftController _draft;

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
    // Saved as the web saves a new message's draft, so either can resume
    // the other's (models/composer.js: action, archetypeId, recipients).
    _draft = DiscourseDraftController(
      draftKey: widget.draftKey ??
          'new_private_message_${DateTime.now().millisecondsSinceEpoch}',
      titleController: _titleController,
      contentController: _contentController,
      extraData: const {
        'action': 'privateMessage',
        'archetypeId': 'private_message',
      },
      extraDataBuilder: () => {'recipients': _recipients.join(',')},
    );
    _draft.initialize(onRestored: (draft) {
      final saved = draft?.data['recipients']?.toString() ?? '';
      // A late read (including a retry) must not add back a recipient the
      // writer removed, or expand the audience they have already chosen.
      if (!mounted || _recipientsChanged || saved.isEmpty) return;
      setState(() {
        for (final name in saved.split(',').map((n) => n.trim())) {
          if (name.isNotEmpty && !_recipients.contains(name)) {
            _recipients.add(name);
          }
        }
      });
      _draft.markExtraDataOpened();
    });
  }

  @override
  void dispose() {
    _draft.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _setRecipients(void Function() change) {
    _recipientsChanged = true;
    setState(change);
    _draft.touch();
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
    final id = confirmedPostId(result.convId, l10n.submissionUnconfirmed);
    _created = (id: id, title: title);
    await _draft.discard(afterSubmit: true);
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
    _setRecipients(() {
      _recipients.add(username);
      _recipientIcons[username] = result['iconUrl'] as String?;
      if (result['isGroup'] == true) _groupRecipients.add(username);
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
              avatar: _groupRecipients.contains(username)
                  ? const Icon(Icons.groups_rounded)
                  : UserAvatar(
                      username: username,
                      iconUrl: _recipientIcons[username],
                      radius: DesignTokens.radiusM,
                    ),
              label: Text(username),
              onDeleted: () => _setRecipients(() {
                _recipients.remove(username);
                _recipientIcons.remove(username);
                _groupRecipients.remove(username);
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
      titleController: _titleController,
      contentController: _contentController,
      onSubmit: _submit,
      onSuccess: (_) => _created,
      hasChanges: () => _draft.changedSinceOpened,
      onSaveDraft: _draft.flushNow,
      onDiscard: _draft.discard,
      // The sent message takes the composer's place.
      pageAfterSubmit: () {
        final created = _created;
        if (created == null) return null;
        return PostPage(
          siteContext: widget.siteContext,
          topicId: created.id,
          title: created.title,
          mode: PostsListMode.normal,
          forumId: '',
        );
      },
      onFileUpload:
          (widget.siteContext.loginDataOutput?.canUploadAttachment ?? false)
              ? _upload
              : null,
      onRemoveAttachment: (id) async =>
          setState(() => _attachmentIds.remove(id)),
    );
  }
}
