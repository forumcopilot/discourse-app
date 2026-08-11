import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:discourse_ui/views/widgets/message_compose_page.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/design_tokens.dart';
import '../services/attachment_upload_service.dart';

class EditPostPage extends StatefulWidget {
  final SiteContext siteContext;
  final String postId;
  final String topicTitle;
  final String? forumId; // Optional forum ID (can be passed from post data)

  const EditPostPage({
    super.key,
    required this.siteContext,
    required this.postId,
    required this.topicTitle,
    this.forumId,
  });

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final List<String> _attachmentIds = [];
  String? _groupId;
  List<FCAttachment>? _existingAttachments;
  String? _forumId; // Store forum ID from attachmentData

  // Controllers created once and reused
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _controllersInitialized = false;

  // Cache the future to prevent FutureBuilder from recreating it on every build
  late final Future<FCRawPostResult> _rawPostFuture;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty values
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    // Cache the future so it doesn't recreate on every build
    _rawPostFuture = SiteProxyFactory.getPostProxy().getRawPostAsync(widget.postId);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<bool> _handleSubmit(String title, String content) async {
    try {
      var postProxy = SiteProxyFactory.getPostProxy();

      // Handle empty title case - use topic title with "Re:" prefix if title is empty
      String finalTitle = title.trim();
      if (finalTitle.isEmpty) {
        // For replies or posts without titles, use the topic title with "Re:" prefix
        finalTitle = widget.topicTitle.startsWith('Re:') ? widget.topicTitle : 'Re: ${widget.topicTitle}';
      }

      // Send empty array instead of null to explicitly disassociate all attachments
      // If we send null, the server might associate all attachments in the groupId
      final attachmentIdsToSend = _attachmentIds.isNotEmpty ? _attachmentIds : <String>[];

      var result = await postProxy.saveRawPostAsync(
        widget.postId,
        finalTitle, // Use the processed title
        content,
        false, // Don't need HTML return
        null, // No edit reason for now
        attachmentIdsToSend, // Send empty array instead of null
        _groupId,
        null, // prefix: XenForo-only concept, unused on Discourse
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
          throw Exception('Failed to save post');
        }
      }
    } catch (e) {
      // Only wrap if it's not already a clean server error message
      // Check if the exception message doesn't start with "Failed to save post"
      final message = e.toString();
      if (message.startsWith('Exception: ') && !message.contains('Failed to save post')) {
        // This is already a clean server message, re-throw as-is
        rethrow;
      } else {
        // Wrap other exceptions
        throw Exception('Failed to save post: ${e.toString()}');
      }
    }
  }

  Future<bool> _handleRemoveExistingAttachment(String attachmentId) async {
    try {
      var attachmentProxy = SiteProxyFactory.getAttachmentProxy();
      var forumId = _forumId ?? "";

      // Use groupId from attachmentData.hash for removing existing attachments
      // The hash is required by the server API even for existing attachments during edit
      var groupId = _groupId ?? "";

      var removeResult = await attachmentProxy.removeAttachmentAsync(
        attachmentId,
        forumId,
        groupId,
        widget.postId,
      );

      if (removeResult.result) {
        setState(() {
          _attachmentIds.remove(attachmentId);
          // Also remove from existing attachments list so UI updates immediately
          if (_existingAttachments != null) {
            _existingAttachments = _existingAttachments!.where((a) => a.id != attachmentId).toList();
          }
        });
        return true;
      } else {
        // Provide a more descriptive error message
        final errorMessage = removeResult.resultText?.trim();
        if (errorMessage != null && errorMessage.isNotEmpty) {
          throw Exception(errorMessage);
        } else {
          throw Exception('Failed to remove attachment. Please check your permissions.');
        }
      }
    } catch (e) {
      rethrow;
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
      targetId: _forumId ?? '',
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
    // Fetch raw post content from API
    // Use cached future to prevent FutureBuilder from recreating MessageComposePage on every build
    return FutureBuilder<FCRawPostResult>(
      future: _rawPostFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;

        // Update controllers when data arrives (only once)
        if (!isLoading && !hasError && snapshot.data != null && !_controllersInitialized) {
          final data = snapshot.data!;
          _titleController.text = data.postTitle ?? '';
          _contentController.text = data.postContent ?? '';
          _controllersInitialized = true;
        }

        // Initialize attachment data from API response
        if (!isLoading && !hasError && snapshot.data != null) {
          final data = snapshot.data!;

          // Store forum ID immediately (synchronously) so it's available for uploads
          // Priority: 1) Top-level forumId from API, 2) widget.forumId parameter, 3) attachmentData.context.nodeId
          if (_forumId == null) {
            if (data.forumId != null && data.forumId!.isNotEmpty) {
              _forumId = data.forumId;
            } else if (widget.forumId != null && widget.forumId!.isNotEmpty) {
              _forumId = widget.forumId;
            } else if (data.attachmentData?.context?.nodeId != null) {
              _forumId = data.attachmentData!.context!.nodeId.toString();
            }
          }

          // Store groupId synchronously as well
          if (_groupId == null && data.attachmentData?.hash != null && data.attachmentData!.hash.isNotEmpty) {
            _groupId = data.attachmentData!.hash;
          }

          // Store existing attachments and initialize attachment IDs (only once, when data first arrives)
          // We initialize synchronously since we pass snapshot.data?.attachments directly to MessageComposePage
          // _existingAttachments is used for tracking removals, not for UI display
          if (_existingAttachments == null && data.attachments != null) {
            _existingAttachments = data.attachments;

            // Initialize attachment IDs from existing attachments
            if (data.attachments!.isNotEmpty) {
              _attachmentIds.clear();
              _attachmentIds.addAll(data.attachments!.map((a) => a.id).where((id) => id.isNotEmpty));
            }

            // Use groupId from first attachment if not already set from attachmentData
            if (_groupId == null && data.attachments!.isNotEmpty && data.attachments!.first.groupId != null && data.attachments!.first.groupId!.isNotEmpty) {
              _groupId = data.attachments!.first.groupId;
            }
          }
        }

        final canEditTitle = (!isLoading && !hasError) ? (snapshot.data?.canEditTitle ?? false) : false;

        // Show loading indicator first, then compose page once data is ready
        if (isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)?.failedToLoadPost(snapshot.error.toString()) ?? 'Failed to load post: \n${snapshot.error}'),
                ],
              ),
            ),
          );
        }

        // Only create compose page when data is ready
        // Use a stable key to preserve MessageComposePage state across rebuilds
        Widget compose = MessageComposePage(
          key: const ValueKey('edit_post_compose'),
          siteContext: widget.siteContext,
          title: 'Edit Post',
          showTitleField: canEditTitle, // Only show title field if user can edit it
          requireTitle: false, // Allow empty titles for post editing
          titleController: _titleController,
          contentController: _contentController,
          contentHint: 'Edit your post...',
          autoFocusContent: false, // Don't auto-focus any field when editing
          onSubmit: _handleSubmit,
          onFileUpload: (widget.siteContext.loginDataOutput?.canUploadAttachment ?? false) ? _handleFileUpload : null,
          topicTitle: widget.topicTitle,
          existingAttachments: snapshot.data?.attachments ?? _existingAttachments,
          onRemoveExistingAttachment: _handleRemoveExistingAttachment,
          submitIcon: Icons.save_rounded,
          onRemoveAttachment: (attachmentId) async {
            if (_attachmentIds.contains(attachmentId)) {
              // For newly uploaded attachments (temporary), we need to call removeAttachment API
              // to actually delete it from the server, not just remove it from the local list
              try {
                var attachmentProxy = SiteProxyFactory.getAttachmentProxy();
                var forumId = _forumId ?? "";
                var groupId = _groupId ?? ""; // groupId is required for temporary attachments

                var removeResult = await attachmentProxy.removeAttachmentAsync(
                  attachmentId,
                  forumId,
                  groupId, // Include groupId for temporary attachments
                  widget.postId,
                );

                if (removeResult.result) {
                  // Now remove from local list
                  setState(() {
                    _attachmentIds.remove(attachmentId);
                  });
                } else {
                  // Still remove from local list even if server removal failed
                  setState(() {
                    _attachmentIds.remove(attachmentId);
                  });
                }
              } catch (e) {
                // Still remove from local list even if API call failed
                setState(() {
                  _attachmentIds.remove(attachmentId);
                });
              }
            }
          },
          onSuccess: (success) => widget.postId,
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

        return compose;
      },
    );
  }
}
