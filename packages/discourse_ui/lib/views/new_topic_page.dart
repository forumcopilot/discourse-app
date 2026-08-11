import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:discourse_ui/views/widgets/message_compose_page.dart';
import 'package:discourse_ui/theme/design_tokens.dart';
import 'package:discourse_ui/utils/discourse_draft_controller.dart';
import 'package:discourse_ui/views/widgets/tag_input_field.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities;
import '../services/attachment_upload_service.dart';

class NewTopicPage extends StatefulWidget {
  final SiteContext siteContext;
  final String forumId;
  final String forumName;

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

  // Server-side draft. Discourse uses 'new_topic' as a global key for the
  // current user, scoped per-category by data['categoryId']. We tag the
  // forumId here so resuming on a different category starts fresh.
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final DiscourseDraftController _draftController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _draftController = DiscourseDraftController(
      draftKey: 'new_topic',
      titleController: _titleController,
      contentController: _contentController,
      extraData: {
        'action': 'createTopic',
        if (widget.forumId.isNotEmpty) 'categoryId': widget.forumId,
      },
    );
    // Prefill the category's topic template — but never over a draft.
    // initialize() restores one asynchronously, so wait for it and fill
    // only a composer that is still empty. Getting this order wrong would
    // silently overwrite unsaved work with a blank skeleton.
    _draftController.initialize().then((_) {
      if (!mounted) return;
      if (_contentController.text.trim().isNotEmpty) return;
      final template = DiscourseSiteCapabilities.forSite(
              widget.siteContext.site.pluginUrl)
          .topicTemplateFor(widget.forumId);
      if (template == null) return;
      setState(() => _contentController.text = template);
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
      await _draftController.discard();
    }
    return ok;
  }

  Future<bool> _handleSubmit(String title, String content) async {
    try {
      final topicProxy = SiteProxyFactory.getTopicProxy();
      final result = await topicProxy.newTopic(
        widget.forumId,
        title,
        content,
        attachmentIds: _attachmentIds.isNotEmpty ? _attachmentIds : null,
        groupId: _groupId,
        tags: _tags.isNotEmpty ? _tags : null,
      );

      debugPrint('🔍 [NEW_TOPIC] Submit result:');
      debugPrint('   - result: ${result.result}');
      debugPrint('   - resultText: "${result.resultText}"');
      debugPrint('   - topicId: "${result.topicId}"');
      debugPrint('   - attachmentIds passed: $_attachmentIds');
      debugPrint('   - groupId passed: "$_groupId"');

      if (result.result) {
        widget.onTopicCreated?.call(result.topicId?.trim() ?? '', title);
        return true;
      } else {
        // Server returned result=false with a message - throw it directly without wrapping
        // This allows the error handler to show the server's message cleanly
        final errorMessage = result.resultText?.trim();
        if (errorMessage != null && errorMessage.isNotEmpty) {
          throw Exception(errorMessage);
        } else {
          throw Exception('Failed to create topic');
        }
      }
    } catch (e) {
      // Only wrap if it's not already a clean server error message
      // Check if the exception message doesn't start with "Failed to create topic"
      final message = e.toString();
      if (message.startsWith('Exception: ') && !message.contains('Failed to create topic')) {
        // This is already a clean server message, re-throw as-is
        rethrow;
      } else {
        // Wrap other exceptions
        throw Exception('Failed to create topic: ${e.toString()}');
      }
    }
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              outcome.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            margin: const EdgeInsets.all(8),
          ),
        );
      }
      return null;
    }

    setState(() => _attachmentIds.add(outcome.shortUrl!));
    return outcome.shortUrl;
  }

  @override
  Widget build(BuildContext context) {
    return MessageComposePage(
      siteContext: widget.siteContext,
      title: AppLocalizations.of(context)?.newTopic ?? 'New Topic',
      showTitleField: true,
      titleHint: 'Write your topic title...',
      contentHint: 'Write your topic content...',
      titleController: _titleController,
      contentController: _contentController,
      onSubmit: _handleSubmitWithDraftDiscard,
      // Only offer tagging when the forum says this user may tag
      // (`can_tag_topics` on /site.json). Previously the field was always
      // shown and the server refused the tags on submit — the user typed
      // them, lost them, and was told why only after the round trip.
      extraHeader: DiscourseSiteCapabilities.forSite(
                  widget.siteContext.site.pluginUrl)
              .canTagTopics
          ? TagInputField(
              initial: _tags,
              onChanged: (tags) => _tags = tags,
              allowCreate: DiscourseSiteCapabilities.forSite(
                      widget.siteContext.site.pluginUrl)
                  .canCreateTag,
            )
          : null,
      onFileUpload: (widget.siteContext.loginDataOutput?.canUploadAttachment ?? false) ? _handleFileUpload : null,
      forumName: widget.forumName,
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
      showSignatureToggle: true,
      onError: (error) {
        if (context.mounted) {
          // Extract the clean message from the exception
          String errorMessage = error.toString();
          // Remove "Exception: " prefix if present
          if (errorMessage.startsWith('Exception: ')) {
            errorMessage = errorMessage.substring(11);
          }

          // Capture ScaffoldMessengerState to ensure dismiss button works correctly
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusS),
              ),
              margin: DesignTokens.paddingS,
              padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingL - DesignTokens.spacingXS),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: AppLocalizations.of(context)?.dismiss ?? 'Dismiss',
                textColor: Theme.of(context).colorScheme.onErrorContainer,
                onPressed: () {
                  scaffoldMessenger.hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      },
    );
  }
}
