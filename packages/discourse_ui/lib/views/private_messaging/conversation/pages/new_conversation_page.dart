import 'package:flutter/material.dart';
import '../../../../utils/discourse_markup.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:image_picker/image_picker.dart';
import 'package:discourse_ui/utils/file_picker_utils.dart';
import 'package:discourse_ui/utils/attachment_constraints_utils.dart';
import 'package:discourse_ui/utils/attachment_validation_utils.dart';
import 'package:discourse_ui/views/user_search_page.dart';
import 'package:discourse_ui/views/widgets/user_avatar.dart';
import 'conversation_page.dart';
import '../../../../theme/design_tokens.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../../../utils/file_utils.dart';
import '../../../../services/attachment_upload_service.dart';

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

  @override
  State<NewConversationPage> createState() => _NewConversationPageState();
}

class _NewConversationPageState extends State<NewConversationPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final List<String> _toRecipients = [];
  final Map<String, String?> _recipientIcons = {}; // Store icon URLs for recipients
  final List<XFile> _attachments = [];
  final List<String> _attachmentIds = [];
  final Map<String, bool> _uploadingFiles = {}; // Track which files are currently uploading (key: file path)
  String? _groupId;
  bool _isSubmitting = false;
  final FocusNode _messageFocusNode = FocusNode();
  String? _createdConversationId; // Store created conversation ID
  String? _createdConversationTitle; // Store created conversation title
  bool _canUpload = false; // Whether user can upload attachments
  bool _isMessageFieldFocused = false; // Track if message field has focus

  @override
  void initState() {
    super.initState();
    if (widget.initialRecipient != null) {
      _toRecipients.add(widget.initialRecipient!);
      if (widget.initialRecipientIconUrl != null) {
        _recipientIcons[widget.initialRecipient!] = widget.initialRecipientIconUrl;
      }
    }
    _fetchCanUpload();
    // Listen to focus changes
    _messageFocusNode.addListener(() {
      setState(() {
        _isMessageFieldFocused = _messageFocusNode.hasFocus;
      });
    });
  }

  Future<void> _fetchCanUpload() async {
    try {
      final conversationProxy = SiteProxyFactory.getPrivateConversationProxy();
      // Fetch minimal data (startNum=0, lastNum=0) to get the canUpload flag
      final conversationsData = await conversationProxy.getConversationsAsync(0, 0);
      debugPrint('🔍 [NEW_CONVERSATION] Fetched canUpload: ${conversationsData.canUpload}');
      if (mounted) {
        setState(() {
          _canUpload = conversationsData.canUpload;
          debugPrint('🔍 [NEW_CONVERSATION] Updated _canUpload to: $_canUpload');
        });
      }
    } catch (e) {
      debugPrint('❌ [NEW_CONVERSATION] Error fetching canUpload: $e');
      // Default to false on error
      if (mounted) {
        setState(() {
          _canUpload = false;
          debugPrint('🔍 [NEW_CONVERSATION] Set _canUpload to false due to error');
        });
      }
    }
  }

  Future<bool> _handleSubmit(String title, String content) async {
    try {
      if (_toRecipients.isEmpty) {
        throw Exception('Please add at least one recipient');
      }
      if (title.trim().isEmpty) {
        throw Exception('Please enter a subject');
      }
      if (content.trim().isEmpty) {
        throw Exception('Please enter a message');
      }

      final conversationProxy = SiteProxyFactory.getPrivateConversationProxy();

      // Create new conversation
      print('🐛 [NewConversationPage] Creating conversation with recipients: $_toRecipients, title: $title');
      print('🐛 [NewConversationPage] Attachment IDs: $_attachmentIds, groupId: $_groupId');
      final result = await conversationProxy.newConversationAsync(
        _toRecipients,
        title,
        content,
        attachmentIds: _attachmentIds.isNotEmpty ? _attachmentIds : null,
        groupId: _groupId,
      );

      print('🐛 [NewConversationPage] Conversation creation result: result=${result.result}, resultText=${result.resultText}, convId=${result.convId}');

      if (result.result) {
        if (result.convId.isEmpty) {
          print('⚠️  [NewConversationPage] WARNING: Conversation creation succeeded but convId is empty!');
          throw Exception('Conversation created but no conversation ID returned');
        }
        print('✅ [NewConversationPage] Conversation created successfully with ID: ${result.convId}');
        // Store the conversation ID for navigation
        _createdConversationId = result.convId;
        _createdConversationTitle = title;
        return true;
      } else {
        // Server returned result=false with a message - throw it directly without wrapping
        // This allows the error handler to show the server's message cleanly
        print('❌ [NewConversationPage] Conversation creation failed: ${result.resultText}');
        final errorMessage = result.resultText?.trim();
        if (errorMessage != null && errorMessage.isNotEmpty) {
          throw Exception(errorMessage);
        } else {
          throw Exception('Failed to create conversation');
        }
      }
    } catch (e) {
      // Only wrap if it's not already a clean server error message
      final message = e.toString();
      if (message.startsWith('Exception: ') && !message.contains('Failed to create conversation') && !message.contains('Conversation created but no conversation ID returned')) {
        // This is already a clean server message, re-throw as-is
        if (mounted) {
          // Extract the clean message from the exception
          String errorMessage = message;
          if (errorMessage.startsWith('Exception: ')) {
            errorMessage = errorMessage.substring(11);
          }
          // Capture ScaffoldMessengerState to ensure dismiss button works correctly
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final colorScheme = Theme.of(context).colorScheme;
          final textTheme = Theme.of(context).textTheme;
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: colorScheme.onErrorContainer,
                  ),
                  SizedBox(width: DesignTokens.spacingM),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: colorScheme.errorContainer,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusS),
              ),
              margin: DesignTokens.paddingS,
              padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingL - DesignTokens.spacingXS),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: AppLocalizations.of(context)?.dismiss ?? 'Dismiss',
                textColor: colorScheme.onErrorContainer,
                onPressed: () {
                  scaffoldMessenger.hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
        return false;
      } else {
        // Wrap other exceptions
        if (mounted) {
          // Capture ScaffoldMessengerState to ensure dismiss button works correctly
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final colorScheme = Theme.of(context).colorScheme;
          final textTheme = Theme.of(context).textTheme;
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: colorScheme.onErrorContainer,
                  ),
                  SizedBox(width: DesignTokens.spacingM),
                  Expanded(
                    child: Text(
                      'Failed to create conversation: ${e.toString()}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: colorScheme.errorContainer,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusS),
              ),
              margin: DesignTokens.paddingS,
              padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingL - DesignTokens.spacingXS),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: AppLocalizations.of(context)?.dismiss ?? 'Dismiss',
                textColor: colorScheme.onErrorContainer,
                onPressed: () {
                  scaffoldMessenger.hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
        return false;
      }
    }
  }

  Widget _buildRecipientChip(String username, List<String> recipients, Function(String) onRemove) {
    return Padding(
      padding: EdgeInsets.only(right: DesignTokens.spacingS),
      child: Chip(
        avatar: UserAvatar(
          username: username,
          iconUrl: _recipientIcons[username],
          radius: DesignTokens.radiusM,
        ),
        label: Text(username),
        deleteIcon: Icon(
          Icons.close,
          size: DesignTokens.iconSizeSMedium,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onDeleted: () => onRemove(username),
      ),
    );
  }

  Widget _buildRecipientField(List<String> recipients, Function(String) onAdd, Function(String) onRemove) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participants',
          style: textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: DesignTokens.fontWeightMedium,
          ),
        ),
        SizedBox(height: DesignTokens.spacingS),
        Wrap(
          spacing: DesignTokens.spacingXS,
          runSpacing: DesignTokens.spacingXS,
          children: [
            ...recipients.map((username) => _buildRecipientChip(username, recipients, onRemove)),
            ActionChip(
              avatar: Icon(
                Icons.add,
                size: DesignTokens.iconSizeSMedium,
                color: colorScheme.primary,
              ),
              label: Text(
                'Add',
                style: TextStyle(
                  color: colorScheme.primary,
                ),
              ),
              backgroundColor: colorScheme.primaryContainer.withValues(alpha: DesignTokens.opacityLow),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserSearchPage(
                      siteContext: widget.siteContext,
                      onUserSelected: (username, iconUrl) {
                        // This callback is no longer used since we're returning data instead
                      },
                      selectedUsers: [..._toRecipients],
                    ),
                  ),
                );

                // Handle the returned user data
                if (result != null && result is Map<String, dynamic>) {
                  final username = result['username'] as String;
                  final iconUrl = result['iconUrl'] as String?;

                  if (!recipients.contains(username)) {
                    onAdd(username);
                    _recipientIcons[username] = iconUrl;
                  }
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Message',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: DesignTokens.fontWeightSemiBold,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 3,
        shadowColor: colorScheme.shadow.withValues(alpha: DesignTokens.opacityLow),
        surfaceTintColor: colorScheme.surfaceTint,
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isSubmitting
                ? SizedBox(
                    width: DesignTokens.iconSizeL,
                    height: DesignTokens.iconSizeL,
                    child: CircularProgressIndicator(
                      strokeWidth: DesignTokens.borderWidthMedium,
                      color: colorScheme.onSurface,
                    ),
                  )
                : Icon(Icons.send_rounded, color: colorScheme.onSurface),
            onPressed: _isSubmitting
                ? null
                : () async {
                    setState(() {
                      _isSubmitting = true;
                    });
                    try {
                      // Get the title and content from the MessageComposePage
                      final title = _titleController.text;
                      final content = _messageController.text;

                      final success = await _handleSubmit(title, content);
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)?.conversationCreatedSuccessfully ?? 'Message created successfully'),
                            backgroundColor: colorScheme.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );

                        // Dismiss keyboard before navigating
                        FocusScope.of(context).unfocus();
                        // Navigate to the newly created conversation instead of just popping
                        if (_createdConversationId != null && _createdConversationId!.isNotEmpty) {
                          print('🐛 [NewConversationPage] Navigating to newly created conversation: $_createdConversationId');
                          // Pop the new conversation page first
                          Navigator.of(context).pop();
                          // Then navigate to the conversation page
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ConversationPage(
                                siteContext: widget.siteContext,
                                conversationId: _createdConversationId!,
                                subject: _createdConversationTitle ?? title,
                              ),
                            ),
                          );
                        } else {
                          // Fallback: just pop if conversation ID is missing
                          Navigator.of(context).pop(true);
                        }
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isSubmitting = false;
                        });
                      }
                    }
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: DesignTokens.paddingL,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRecipientField(
                        _toRecipients,
                        (username) => setState(() => _toRecipients.add(username)),
                        (username) => setState(() {
                          _toRecipients.remove(username);
                          _recipientIcons.remove(username);
                        }),
                      ),
                      SizedBox(height: DesignTokens.spacingL),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subject',
                            style: textTheme.titleSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: DesignTokens.fontWeightMedium,
                            ),
                          ),
                          SizedBox(height: DesignTokens.spacingS),
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: 'Enter subject',
                              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                              filled: true,
                              fillColor: colorScheme.surfaceVariant.withValues(alpha: DesignTokens.opacityLow),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: DesignTokens.borderWidthMedium,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                                borderSide: BorderSide(
                                  color: colorScheme.error,
                                  width: DesignTokens.borderWidthMedium,
                                ),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                        ],
                      ),
                      SizedBox(height: DesignTokens.spacingL),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Message',
                            style: textTheme.titleSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: DesignTokens.fontWeightMedium,
                            ),
                          ),
                          SizedBox(height: DesignTokens.spacingS),
                          TextField(
                            controller: _messageController,
                            focusNode: _messageFocusNode,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)?.writeYourMessage ?? 'Write your message...',
                              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                              filled: true,
                              fillColor: colorScheme.surfaceVariant.withValues(alpha: DesignTokens.opacityLow),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: DesignTokens.borderWidthMedium,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                                borderSide: BorderSide(
                                  color: colorScheme.error,
                                  width: DesignTokens.borderWidthMedium,
                                ),
                              ),
                            ),
                            minLines: 5,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                          ),
                        ],
                      ),
                      if (_attachments.isNotEmpty) ...[
                        SizedBox(height: DesignTokens.spacingL),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.attach_file, size: DesignTokens.iconSizeM, color: colorScheme.onSurfaceVariant),
                                SizedBox(width: DesignTokens.spacingS),
                                Text(
                                  'Attachments',
                                  style: textTheme.titleSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: DesignTokens.fontWeightMedium,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: DesignTokens.spacingS),
                            Container(
                              padding: DesignTokens.paddingS,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceVariant.withValues(alpha: DesignTokens.opacityLow),
                                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ..._attachments.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final attachment = entry.value;
                                    // Try to find matching attachment ID (they should be in sync)
                                    final attachmentId = index < _attachmentIds.length ? _attachmentIds[index] : null;
                                    final isUploading = _uploadingFiles[attachment.path] ?? false;
                                    final isImage = isImageFile(attachment.name);
                                    return Column(
                                      children: [
                                        ListTile(
                                          leading: isImage
                                              ? Stack(
                                                  children: [
                                                    Container(
                                                      width: 48,
                                                      height: 48,
                                                      decoration: BoxDecoration(
                                                        color: colorScheme.surfaceVariant.withValues(alpha: DesignTokens.opacityLow),
                                                        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                                                        child: Image.file(
                                                          File(attachment.path),
                                                          width: 48,
                                                          height: 48,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stackTrace) {
                                                            return Icon(
                                                              getFileIcon(attachment.name),
                                                              size: 24,
                                                              color: colorScheme.onSurfaceVariant,
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    if (attachmentId != null)
                                                      Positioned(
                                                        top: 0,
                                                        right: 0,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color: colorScheme.surface,
                                                            shape: BoxShape.circle,
                                                          ),
                                                          child: Icon(
                                                            Icons.check_circle,
                                                            color: colorScheme.primary,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                )
                                              : Container(
                                                  width: 48,
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    color: getFileTypeColor(attachment.name),
                                                    borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Center(
                                                        child: Icon(
                                                          getFileIcon(attachment.name),
                                                          size: 24,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      if (attachmentId != null)
                                                        Positioned(
                                                          top: 0,
                                                          right: 0,
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              color: colorScheme.surface,
                                                              shape: BoxShape.circle,
                                                            ),
                                                            child: Icon(
                                                              Icons.check_circle,
                                                              color: colorScheme.primary,
                                                              size: 20,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                          title: Text(attachment.name),
                                          subtitle: isUploading
                                              ? Text(AppLocalizations.of(context)?.uploading ?? 'Uploading...', style: textTheme.bodySmall?.copyWith(color: colorScheme.primary))
                                              : attachmentId != null
                                                  ? Text(AppLocalizations.of(context)?.uploaded ?? 'Uploaded', style: textTheme.bodySmall?.copyWith(color: colorScheme.primary))
                                                  : null,
                                          trailing: IconButton(
                                            icon: Icon(Icons.close),
                                            onPressed: isUploading
                                                ? null
                                                : () => setState(() {
                                                      _attachments.removeAt(index);
                                                      _uploadingFiles.remove(attachment.path);
                                                      if (index < _attachmentIds.length) {
                                                        _attachmentIds.removeAt(index);
                                                      }
                                                    }),
                                          ),
                                        ),
                                        if (isUploading)
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingM),
                                            child: LinearProgressIndicator(
                                              minHeight: 2,
                                              backgroundColor: colorScheme.surfaceVariant,
                                              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                                            ),
                                          ),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      // Discourse-only options
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildBottomToolbar(),
        ],
      ),
    );
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

    // Keep _attachmentIds index-aligned with _attachments: the UI pairs
    // them up by position for thumbnails.
    setState(() {
      final i = _attachments.indexWhere((f) => f.path == file.path);
      if (i != -1) {
        while (_attachmentIds.length <= i) {
          _attachmentIds.add('');
        }
        _attachmentIds[i] = outcome.shortUrl!;
      }
      _uploadingFiles.remove(file.path);
    });
    return outcome.shortUrl;
  }

  void _handleFileAttachment() async {
    final XFile? file = await FilePickerUtils.pickFile();
    if (file != null) {
      // Hide keyboard when file is selected to focus on upload progress
      FocusScope.of(context).unfocus();
      
      // Add file to list immediately so user can see it
      setState(() {
        _attachments.add(file);
      });
      // Start upload in background
      _handleFileUpload(file);
    }
  }

  void _handleImageAttachment() async {
    // Get constraints and check count limit before showing picker
    final siteContext = getCurrentSiteContext();
    final constraints = getAttachmentConstraintsFromSiteContext(siteContext);

    if (!canAddMoreAttachments(_attachments.length, constraints)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Maximum of ${constraints!.count} attachment(s) allowed',
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
      return;
    }

    final XFile? image = await FilePickerUtils.pickImage();
    if (image != null) {
      // Hide keyboard when image is selected to focus on upload progress
      FocusScope.of(context).unfocus();
      
      // Add file to list immediately so user can see it
      setState(() {
        _attachments.add(image);
      });
      // Start upload in background
      _handleFileUpload(image);
    }
  }

  /// Inserts the markup for a formatting-toolbar action at the cursor.
  ///
  /// This used to emit raw `[TAG]…[/TAG]` XenForo BBCode. Discourse only
  /// parses a subset of BBCode, so `[LIST]`, `[*]`, `[VIDEO]`, `[LEFT]`
  /// and `[CENTER]` were being posted into PMs as literal bracketed text.
  /// Shares the mapping with the main composer via [DiscourseMarkup].
  void _insertMarkup(String tag) {
    // Ensure the message field has focus before modifying
    if (!_messageFocusNode.hasFocus) {
      _messageFocusNode.requestFocus();
    }
    _messageController.value =
        DiscourseMarkup.apply(_messageController.value, tag);
    _messageFocusNode.requestFocus();
  }

  void _handleMention() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserSearchPage(
          siteContext: widget.siteContext,
          onUserSelected: (username, iconUrl) {
            final currentText = _messageController.text;
            final currentSelection = _messageController.selection;
            final beforeCursor = currentText.substring(0, currentSelection.start);
            final afterCursor = currentText.substring(currentSelection.end);
            final newText = '$beforeCursor@$username $afterCursor';
            _messageController.text = newText;
            _messageController.selection = TextSelection.fromPosition(
              TextPosition(offset: (beforeCursor.length + username.length + 2).toInt()), // +2 for @ and space
            );
            // Ensure the message field is focused after inserting the username
            _messageFocusNode.requestFocus();
          },
          selectedUsers: const [],
        ),
      ),
    );
  }

  Widget _buildBottomToolbar() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Debug: Log the current state
    debugPrint(
        '🔍 [NEW_CONVERSATION] _buildBottomToolbar: siteType=${widget.siteContext.siteType}, _canUpload=$_canUpload, willShowButtons=$_canUpload');

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: DesignTokens.opacityLow * 0.33),
            offset: const Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingS, vertical: DesignTokens.spacingXS),
          child: Row(
            children: [
              // File attachment button
              if (_canUpload)
                IconButton(
                  icon: Icon(
                    Icons.attach_file,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  tooltip: 'Attach File',
                  onPressed: _handleFileAttachment,
                ),
              // Image upload button
              if (_canUpload)
                IconButton(
                  icon: Icon(
                    Icons.image,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  tooltip: 'Upload Image',
                  onPressed: _handleImageAttachment,
                ),
              // Formatting button
              PopupMenuButton<String>(
                enabled: _isMessageFieldFocused,
                // See MessageComposePage: this opens the formatting menu,
                // so it takes the formatting glyph rather than a bold one.
                icon: Icon(Icons.text_format, color: _isMessageFieldFocused ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant.withValues(alpha: 0.38)),
                tooltip: 'Formatting',
                onSelected: _insertMarkup,
                itemBuilder: (context) => [
                  // Text formatting
                  PopupMenuItem(
                    value: 'B',
                    child: Row(
                      children: [
                        Icon(Icons.format_bold, size: 20, color: colorScheme.onSurface),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)?.bold ?? 'Bold', style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'I',
                    child: Row(
                      children: [
                        Icon(Icons.format_italic, size: 20, color: colorScheme.onSurface),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)?.italic ?? 'Italic', style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'U',
                    child: Row(
                      children: [
                        Icon(Icons.format_underline, size: 20, color: colorScheme.onSurface),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)?.underline ?? 'Underline', style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'S',
                    child: Row(
                      children: [
                        Icon(Icons.strikethrough_s, size: 20, color: colorScheme.onSurface),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)?.strikethrough ?? 'Strikethrough', style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  // Links and Media
                  PopupMenuItem(
                    value: 'URL',
                    child: Row(
                      children: [
                        Icon(Icons.link, size: 20, color: colorScheme.onSurface),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)?.link ?? 'Link', style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'IMG',
                    child: Row(
                      children: [
                        Icon(Icons.image, size: 20, color: colorScheme.onSurface),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)?.image ?? 'Image', style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'VIDEO',
                    child: Row(
                      children: [
                        Icon(Icons.videocam, size: 20, color: colorScheme.onSurface),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)?.video ?? 'Video', style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  // Content blocks
                  PopupMenuItem(
                    value: 'QUOTE',
                    child: Row(
                      children: [
                        Icon(Icons.format_quote, size: 20, color: colorScheme.onSurface),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)?.quote ?? 'Quote', style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'CODE',
                    child: Row(
                      children: [
                        Icon(Icons.code, size: 20, color: colorScheme.onSurface),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)?.code ?? 'Code', style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'SPOILER',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_off, size: 20, color: colorScheme.onSurface),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)?.spoiler ?? 'Spoiler', style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  // Lists
                  PopupMenuItem(
                    value: 'LIST',
                    child: Row(
                      children: [
                        Icon(Icons.format_list_bulleted, size: 20, color: colorScheme.onSurface),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)?.bulletList ?? 'Bullet List', style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'LIST=1',
                    child: Row(
                      children: [
                        Icon(Icons.format_list_numbered, size: 20, color: colorScheme.onSurface),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)?.numberedList ?? 'Numbered List', style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: '*',
                    child: Row(
                      children: [
                        Icon(Icons.subdirectory_arrow_right, size: 20, color: colorScheme.onSurface),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)?.listItem ?? 'List Item', style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  // Alignment actions removed: Discourse has no
                  // [left]/[center]/[right] markup, so these posted
                  // literal bracketed text into the message.
                ],
              ),
              // Mention button
              IconButton(
                icon: Icon(Icons.alternate_email, color: _isMessageFieldFocused ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant.withValues(alpha: 0.38)),
                tooltip: 'Mention User',
                onPressed: _isMessageFieldFocused ? _handleMention : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }
}
