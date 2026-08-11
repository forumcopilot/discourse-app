import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/models/results/fc_private_conversation_result.dart';
import 'package:discourse_ui/views/widgets/message_compose_page.dart';
import 'package:flutter/foundation.dart';
import '../../../../services/attachment_upload_service.dart';

class ReplyConversationPage extends StatefulWidget {
  final SiteContext siteContext;
  final String conversationId;
  final String subject;
  final String? quotedMessageId;
  final bool? canUpload; // Whether user can upload attachments

  const ReplyConversationPage({
    super.key,
    required this.siteContext,
    required this.conversationId,
    required this.subject,
    this.quotedMessageId,
    this.canUpload,
  });

  @override
  State<ReplyConversationPage> createState() => _ReplyConversationPageState();
}

class _ReplyConversationPageState extends State<ReplyConversationPage> {
  final List<XFile> _attachments = [];
  final List<String> _attachmentIds = [];
  String? _groupId;
  bool _isUploading = false;
  Future<FCQuoteConversationResult>? _quoteFuture;

  @override
  void initState() {
    super.initState();
    // Cache the future so it's only called once
    if (widget.quotedMessageId != null) {
      _quoteFuture = SiteProxyFactory.getPrivateConversationProxy().getQuoteConversationAsync(
        widget.conversationId,
        widget.quotedMessageId!,
      );
    }
  }

  Future<bool> _handleSubmit(String title, String content) async {
    try {
      if (content.trim().isEmpty) {
        throw Exception('Please enter a message');
      }

      final conversationProxy = SiteProxyFactory.getPrivateConversationProxy();
      print('🐛 [ReplyConversationPage] Replying with attachment IDs: $_attachmentIds, groupId: $_groupId');
      final result = await conversationProxy.replyConversationAsync(
        widget.conversationId,
        content,
        _attachmentIds.isNotEmpty ? _attachmentIds : null,
        _groupId,
      );

      if (result.result) {
        return true;
      } else {
        // Server returned result=false with a message - throw it directly without wrapping
        // This allows the error handler to show the server's message cleanly
        final errorMessage = result.resultText?.trim();
        if (errorMessage != null && errorMessage.isNotEmpty) {
          throw Exception(errorMessage);
        } else {
          throw Exception('Failed to send reply');
        }
      }
    } catch (e) {
      // Only wrap if it's not already a clean server error message
      final message = e.toString();
      if (message.startsWith('Exception: ') && !message.contains('Failed to send reply')) {
        // This is already a clean server message, show it directly
        if (mounted) {
          String errorMessage = message;
          if (errorMessage.startsWith('Exception: ')) {
            errorMessage = errorMessage.substring(11);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
          );
        }
        return false;
      } else {
        // Wrap other exceptions
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)?.failedToSendReply(e.toString()) ?? 'Failed to send reply: ${e.toString()}'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
          );
        }
        return false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quotedMessageId != null) {
      // Fetch quote content from API (using cached future)
      return FutureBuilder<FCQuoteConversationResult>(
        future: _quoteFuture,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final hasError = snapshot.hasError;
          final hasData = snapshot.hasData && snapshot.data != null;
          // Only set quoteContent if we have data, otherwise use null to avoid overwriting user input
          final quoteContent = hasData && snapshot.data!.quoteText != null && snapshot.data!.quoteText!.isNotEmpty ? snapshot.data!.quoteText : null;

          // Create the compose widget once and reuse it across all states
          // Use a stable key based on quotedMessageId to preserve widget state (including attachments)
          Widget compose = MessageComposePage(
            key: ValueKey('reply_with_quote_${widget.quotedMessageId}'),
            siteContext: widget.siteContext,
            title: AppLocalizations.of(context)?.reply ?? 'Reply',
            onSubmit: _handleSubmit,
            onFileUpload:
                (widget.canUpload ?? false) ? _handleFileUpload : null,
            onRemoveAttachment: _handleRemoveAttachment,
            showTitleField: false,
            initialContent: quoteContent,
            contentHint: AppLocalizations.of(context)?.writeYourReply ?? 'Write your reply...',
            topicTitle: widget.subject,
            onSuccess: (success) {
              // Return true to indicate reply was successful
              return true;
            },
          );

          if (isLoading) {
            return Stack(
              children: [
                compose,
                ModalBarrier(dismissible: false, color: Colors.black.withValues(alpha: 0.2)),
                const Center(child: CircularProgressIndicator()),
              ],
            );
          } else if (hasError) {
            return Stack(
              children: [
                compose,
                ModalBarrier(dismissible: false, color: Colors.black.withValues(alpha: 0.2)),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      AppLocalizations.of(context)?.failedToLoadQuote(snapshot.error.toString()) ?? "Failed to load quote:\n${snapshot.error.toString()}",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return compose;
          }
        },
      );
    } else {
      return MessageComposePage(
        siteContext: widget.siteContext,
        title: AppLocalizations.of(context)?.reply ?? 'Reply',
        onSubmit: _handleSubmit,
        onFileUpload:
            (widget.canUpload ?? false) ? _handleFileUpload : null,
        onRemoveAttachment: _handleRemoveAttachment,
        showTitleField: false,
        contentHint: AppLocalizations.of(context)?.writeYourReply ?? 'Write your reply...',
        topicTitle: widget.subject,
        onSuccess: (success) {
          // Return true to indicate reply was successful
          return true;
        },
      );
    }
  }

  Future<void> _handleRemoveAttachment(String attachmentId) async {
    // Remove the attachment ID from the list and call API to delete from server
    if (_groupId != null && _groupId!.isNotEmpty) {
      try {
        var attachmentProxy = SiteProxyFactory.getAttachmentProxy();
        await attachmentProxy.removeAttachmentAsync(
          attachmentId,
          "", // forumId is empty for conversation replies
          _groupId!, // groupId is required for temporary attachments
          "", // postId is empty for reply drafts
        );
      } catch (e) {
        // Silently handle errors
        debugPrint('⚠️ [REPLY_CONVERSATION] Error removing attachment: $e');
      }
    }

    // Remove from local list
    if (_attachmentIds.contains(attachmentId)) {
      setState(() {
        _attachmentIds.remove(attachmentId);
        // Also remove the corresponding file from _attachments
        _attachments.removeWhere((file) {
          // We can't directly match by attachmentId, so we'll remove by index if we track it
          // For now, just remove from IDs list - the file mapping is handled by MessageComposePage
          return false;
        });
      });
      debugPrint('✅ [REPLY_CONVERSATION] Removed attachmentId: $attachmentId');
      debugPrint('✅ [REPLY_CONVERSATION] Current attachmentIds: $_attachmentIds');
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
      uploadType: 'pm',
      targetId: '',
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
  void dispose() {
    super.dispose();
  }
}
