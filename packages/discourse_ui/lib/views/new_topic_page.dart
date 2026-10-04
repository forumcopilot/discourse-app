import 'package:flutter/material.dart';
import 'post_page.dart';
import 'widgets/post_needs_approval_dialog.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:discourse_ui/views/widgets/message_compose_page.dart';
import 'package:discourse_ui/utils/discourse_draft_controller.dart';
import 'package:discourse_ui/views/widgets/tag_input_field.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities;
import '../services/attachment_upload_service.dart';
import '../utils/snackbar_helper.dart';
import '../utils/draft_tags.dart';

class NewTopicPage extends StatefulWidget {
  final SiteContext siteContext;
  final String forumId;
  final String forumName;

  /// Pass an existing key when resuming from Drafts, including the legacy
  /// `new_topic` key. Otherwise each new composer gets its own
  /// `new_topic_<timestamp>` draft, as on the web.
  final String? draftKey;

  /// Fired the moment the server confirms the topic was created. More
  /// reliable than the pop result: it still reaches the opener when a
  /// post-creation step throws and the page is later popped without a
  /// result.
  /// Called with the new topic's id once it lands.
  ///
  /// Reports rather than navigates: this page is popped by its own submit
  /// flow, so a route pushed from here is popped straight back off. The
  /// caller opens the topic after the composer has closed.
  final void Function(String topicId, String title)? onTopicCreated;

  const NewTopicPage({
    super.key,
    required this.siteContext,
    required this.forumId,
    required this.forumName,
    this.draftKey,
    this.onTopicCreated,
  });

  @override
  State<NewTopicPage> createState() => _NewTopicPageState();
}

class _NewTopicPageState extends State<NewTopicPage> {
  final List<String> _attachmentIds = [];
  String? _groupId;

  // Discourse-native: tags attached to the new topic.
  List<String> _tags = const [];
  bool _tagsChanged = false;

  // A category is draft metadata, not part of its server identity. New
  // topics must not share a key or one category can overwrite another's work.
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final DiscourseDraftController _draftController;

  /// The topic just created, which takes the composer's place.
  ({String id, String title})? _created;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    // A template is initial content for a new topic. Applying it after a
    // draft read can replace an intentionally empty saved/edited body.
    _contentController = TextEditingController(
      text: widget.draftKey == null
          ? DiscourseSiteCapabilities.forSite(widget.siteContext.site.pluginUrl)
              .topicTemplateFor(widget.forumId)
          : null,
    );
    _draftController = DiscourseDraftController(
      draftKey: widget.draftKey ??
          'new_topic_${DateTime.now().microsecondsSinceEpoch}',
      titleController: _titleController,
      contentController: _contentController,
      extraDataBuilder: () => {
        'tags': [for (final name in _tags) {'name': name}],
      },
      extraData: {
        'action': 'createTopic',
        // A number, as Discourse's own composer stores it.
        if (widget.forumId.isNotEmpty)
          'categoryId': int.tryParse(widget.forumId) ?? widget.forumId,
      },
    );
    _draftController.initialize(onRestored: (draft) {
      if (!mounted) return;
      if (!_tagsChanged) {
        setState(() => _tags = draftTagNames(draft?.data['tags']));
        _draftController.markExtraDataOpened();
      }
    });
  }

  @override
  void dispose() {
    _draftController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Wraps the underlying submit so we can clean up the server-side draft
  /// when the new topic lands successfully.
  Future<bool> _handleSubmitWithDraftDiscard(String title, String content) async {
    final ok = await _handleSubmit(title, content);
    if (ok) {
      await _draftController.discard(afterSubmit: true);
    }
    return ok;
  }

  /// Throws with the forum's reason when it refuses the topic ("Title is
  /// too short (minimum is 15 characters)"); the composer shows it.
  Future<bool> _handleSubmit(String title, String content) async {
    final l10n = AppLocalizations.of(context)!;
    final topicProxy = SiteProxyFactory.getTopicProxy();
    final result = await topicProxy.newTopic(
      widget.forumId,
      title,
      content,
      attachmentIds: _attachmentIds.isNotEmpty ? _attachmentIds : null,
      groupId: _groupId,
      tags: _tags.isNotEmpty ? _tags : null,
    );

    if (!result.result) {
      final reason = result.resultText?.trim() ?? '';
      throw Exception(reason.isNotEmpty ? reason : l10n.failedToCreateTopic);
    }
    if (result.state == 1) {
      // Queued for a moderator: there is no topic to open yet.
      if (mounted) await showPostNeedsApproval(context);
      return true;
    }
    widget.onTopicCreated?.call(result.topicId.trim(), title);
    if (result.topicId.trim().isNotEmpty) {
      _created = (id: result.topicId.trim(), title: title);
    }
    return true;
  }

  /// Uploads one picked file and returns Discourse's `upload://` ref.
  ///
  /// The body of this method used to be a verbatim copy of the same
  /// logic in five sibling composer pages. It now lives once in
  /// AttachmentUploadService; what stays here is only what differs.
  Future<String?> _handleFileUpload(XFile file) async {
    final outcome = await AttachmentUploadService.upload(
      context: context,
      file: file,
      uploadType: 'post',
      targetId: widget.forumId,
      groupId: _groupId ?? '',
      currentAttachmentCount: _attachmentIds.length,
    );

    if (outcome.cancelled) return null;
    if (!outcome.succeeded) {
      if (mounted && outcome.errorMessage != null) {
        SnackbarHelper.showError(context, outcome.errorMessage!);
      }
      return null;
    }

    setState(() => _attachmentIds.add(outcome.shortUrl!));
    return outcome.shortUrl;
  }

  @override
  Widget build(BuildContext context) {
    return MessageComposePage(
      submitLabel: AppLocalizations.of(context)!.createTopic,
      siteContext: widget.siteContext,
      title: AppLocalizations.of(context)!.newTopic,
      showTitleField: true,
      titleHint: AppLocalizations.of(context)!.writeYourTopicTitle,
      contentHint: AppLocalizations.of(context)!.writeYourTopicContent,
      titleController: _titleController,
      contentController: _contentController,
      onSubmit: _handleSubmitWithDraftDiscard,
      hasChanges: () => _draftController.changedSinceOpened,
      onSaveDraft: _draftController.flushNow,
      onDiscard: _draftController.discard,
      // The new topic takes the composer's place, as the web opens it: Back
      // from it goes to the list New Topic was opened from. (A topic held
      // for approval has nothing to open.)
      pageAfterSubmit: () {
        final created = _created;
        if (created == null) return null;
        return PostPage(
          siteContext: widget.siteContext,
          topicId: created.id,
          // The topic's title, not the category's: the first post renders
          // whatever is passed here as its heading.
          title: created.title,
          forumId: widget.forumId,
        );
      },
      // Only offer tagging when the forum says this user may tag
      // (`can_tag_topics` on /site.json). Previously the field was always
      // shown and the server refused the tags on submit — the user typed
      // them, lost them, and was told why only after the round trip.
      extraHeader: DiscourseSiteCapabilities.forSite(
                  widget.siteContext.site.pluginUrl)
              .canTagTopics
          ? TagInputField(
              initial: _tags,
              onChanged: (tags) {
                _tags = tags;
                _tagsChanged = true;
                _draftController.touch();
              },
              allowCreate: DiscourseSiteCapabilities.forSite(
                      widget.siteContext.site.pluginUrl)
                  .canCreateTag,
            )
          : null,
      onFileUpload: (widget.siteContext.loginDataOutput?.canUploadAttachment ?? false) ? _handleFileUpload : null,
      forumName: widget.forumName,
      forumId: widget.forumId,
      onRemoveAttachment: (attachmentId) async {
        // Remove the attachment ID from the list and call API to delete from server
        // Call API to remove attachment from server
        if (_groupId != null && _groupId!.isNotEmpty && widget.forumId.isNotEmpty) {
          try {
            var attachmentProxy = SiteProxyFactory.getAttachmentProxy();
            await attachmentProxy.removeAttachmentAsync(
              attachmentId,
              widget.forumId,
              _groupId!, // groupId is required for temporary attachments
              '', // postId is empty for new topics
            );
          } catch (e) {
            // Silently handle errors
          }
        }

        // Remove from local list
        if (_attachmentIds.contains(attachmentId)) {
          setState(() {
            _attachmentIds.remove(attachmentId);
          });
        }
      },
      // No "Sent from <forum> mobile app" line: a Tapatalk-era habit with no
      // Discourse equivalent, and it was on by default, stamping every new
      // topic from the app.
      showSignatureToggle: false,
    );
  }
}
