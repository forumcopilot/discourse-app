import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart' as forumcopilot_sdk;
import 'package:discourse_core/discourse_core.dart' show DiscoursePostProxy;
import 'package:discourse_ui/views/widgets/message_compose_page.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../theme/design_tokens.dart';
import '../utils/discourse_draft_controller.dart';
import '../services/attachment_upload_service.dart';

class ReplyPage extends StatefulWidget {
  final SiteContext siteContext;
  final String threadId;
  final String? forumId;
  final String? quotePostId;
  final String? quoteText;
  final String? quoteAuthor;
  final String topicTitle;
  final String? postId;
  final bool isQuote;

  const ReplyPage({
    super.key,
    required this.siteContext,
    required this.threadId,
    required this.topicTitle,
    this.forumId,
    this.quotePostId,
    this.quoteText,
    this.quoteAuthor,
    this.postId,
    this.isQuote = false,
  });

  @override
  State<ReplyPage> createState() => _ReplyPageState();
}

class _ReplyPageState extends State<ReplyPage> {

  final List<String> _attachmentIds = [];
  String? _groupId;
  String? _createdPostId; // Store the created post ID
  Future<forumcopilot_sdk.FCQuotePostResult>? _quoteFuture;

  /// Guards against inserting the same quote twice — `initialContent` and
  /// the future's callback can both fire.
  bool _quoteApplied = false;

  /// Discourse staff whisper mode — when on, the reply is submitted via
  /// `replyWhisperAsync` (visible to staff + whisper-allowed groups only).
  bool _isWhisper = false;

  /// Whether the signed-in user is Discourse staff (admin or moderator).
  /// `DiscourseLoginService` maps `current_user.admin`/`moderator` onto
  /// `FCUser.userType` / `canModerate` at login. The whisper toggle is
  /// only shown to staff; the server still enforces
  /// `guardian.can_create_whisper?` and rejects anyone else with a clean
  /// message.
  bool get _isStaff {
    final user = widget.siteContext.loginDataOutput?.user;
    if (user == null) return false;
    return user.canModerate ||
        user.userType == 'admin' ||
        user.userType == 'moderator';
  }

  // Server-side draft persistence. Discourse keys reply drafts as
  // `topic_<topicId>` — same key the web composer uses, so drafts written
  // here are visible/recoverable on the web side too.
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final DiscourseDraftController _draftController;

  @override
  void initState() {
    super.initState();
    // Cache the future so it's only called once
    if (widget.isQuote && widget.postId != null) {
      _quoteFuture = SiteProxyFactory.getPostProxy().getQuotePostAsync(widget.postId!);
      // Apply the quote to the field ourselves rather than leaving it to
      // `initialContent`. Both the quote fetch and the draft restore are
      // async, and the draft only seeds an *empty* field — so whichever
      // lost the race was silently dropped. In practice the draft won, and
      // asking to quote a post produced last week's draft instead.
      //
      // Web inserts a quote *into* the open composer rather than replacing
      // it, so the quote goes on top and any draft text stays below it.
      _quoteFuture!.then((result) {
        if (!mounted || _quoteApplied) return;
        final quote = result.quoteContent;
        if (quote == null || quote.trim().isEmpty) return;
        _quoteApplied = true;
        final existing = _contentController.text;
        // The compose page may already have seeded it from initialContent.
        if (existing.contains(quote.trim())) return;
        final merged = existing.isEmpty ? quote : '$quote$existing';
        _contentController.value = TextEditingValue(
          text: merged,
          selection: TextSelection.collapsed(offset: quote.length),
        );
      });
    }
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    final initialContent = _getInitialContent();
    if (initialContent != null) {
      _contentController.text = initialContent;
    }
    _draftController = DiscourseDraftController(
      draftKey: 'topic_${widget.threadId}',
      titleController: _titleController,
      contentController: _contentController,
      extraData: const {'action': 'reply'},
    );
    _draftController.initialize();
  }

  @override
  void dispose() {
    _draftController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String? _getInitialContent() {
    if (widget.quoteText != null && widget.quoteAuthor != null) {
      // Discourse-native quote block. The post number / topic id aren't
      // available on this path (the isQuote path fetches a fully-attributed
      // quote from the server instead); a plain username attribution is
      // valid Discourse markup and renders fine.
      return '[quote="${widget.quoteAuthor}"]\n${widget.quoteText}\n[/quote]\n\n';
    }
    return null;
  }

  /// Wraps the underlying submit so we can clean up the server-side draft
  /// when the post lands successfully.
  Future<bool> _handleSubmitWithDraftDiscard(String title, String content) async {
    final ok = await _handleSubmit(title, content);
    if (ok) {
      await _draftController.discard();
    }
    return ok;
  }

  Future<bool> _handleSubmit(String title, String content) async {
    try {
      AppLogger.debug('🟢 [REPLY_PAGE] _handleSubmit called');
      AppLogger.debug('   - widget.forumId: ${widget.forumId}');
      AppLogger.debug('   - widget.threadId: ${widget.threadId}');
      AppLogger.debug('   - content length: ${content.length}');
      AppLogger.debug('   - attachmentIds: $_attachmentIds');
      AppLogger.debug('   - groupId: $_groupId');
      
      var postProxy = SiteProxyFactory.getPostProxy();
      final forumIdParam = widget.forumId ?? "";
      final threadIdParam = widget.threadId;
      AppLogger.debug('🟢 [REPLY_PAGE] Calling ${_isWhisper ? 'replyWhisperAsync' : 'replyPostAsync'} with:');
      AppLogger.debug('   - forumId: "$forumIdParam" (empty: ${forumIdParam.isEmpty})');
      AppLogger.debug('   - threadId: "$threadIdParam" (empty: ${threadIdParam.isEmpty})');
      AppLogger.debug('   - subject: ""');
      AppLogger.debug('   - content length: ${content.length}');
      AppLogger.debug('   - attachmentIds: $_attachmentIds');
      AppLogger.debug('   - groupId: $_groupId');

      forumcopilot_sdk.FCReplyPostResult result;
      if (_isWhisper && postProxy is DiscoursePostProxy) {
        // Discourse staff whisper: same create path, `whisper: "true"`.
        // Non-staff get the server's `invalid_whisper_access` message
        // surfaced as result:false below.
        result = await postProxy.replyWhisperAsync(
          threadIdParam,
          content,
          attachmentIds: _attachmentIds.isNotEmpty ? _attachmentIds : null,
          returnHtml: false,
        );
      } else {
        result = await postProxy.replyPostAsync(
          forumIdParam,
          threadIdParam,
          "", // Subject is optional for replies
          content,
          _attachmentIds.isNotEmpty ? _attachmentIds : null,
          _groupId,
          false, // Don't need HTML return
        );
      }
      
      AppLogger.debug('🟢 [REPLY_PAGE] replyPostAsync returned:');
      AppLogger.debug('   - result.result: ${result.result}');
      AppLogger.debug('   - result.resultText: ${result.resultText}');
      AppLogger.debug('   - result.postId: ${result.postId}');
      AppLogger.debug('   - result.state: ${result.state}');
      
      if (result.result) {
        // Check if post needs moderation (state = 1)
        if (result.state == 1) {
          // Don't store postId if post needs moderation - it won't be visible yet
          _createdPostId = null;
          debugPrint('🔍 [REPLY] Post submitted but needs moderation, postId not stored');
        } else {
          // Store the postId synchronously for immediate use in onSuccess callback
          // Only store if postId is not null and not empty
          if (result.postId != null && result.postId!.isNotEmpty) {
            _createdPostId = result.postId;
          } else {
            _createdPostId = null;
            debugPrint('⚠️ [REPLY] Warning: postId is null or empty after successful submission');
          }
        }
        return true;
      } else {
        // Server returned result=false with a message - throw it directly without wrapping
        // This allows the onError handler to show the server's message cleanly
        final errorMessage = result.resultText?.trim();
        if (errorMessage != null && errorMessage.isNotEmpty) {
          throw Exception(errorMessage);
        } else {
          throw Exception('Failed to post reply');
        }
      }
    } catch (e) {
      AppLogger.debug('🔴 [REPLY_PAGE] Exception in _handleSubmit:');
      AppLogger.debug('   - Exception type: ${e.runtimeType}');
      AppLogger.debug('   - Exception message: ${e.toString()}');
      if (e is DioException) {
        AppLogger.debug('   - DioException details:');
        AppLogger.debug('     - statusCode: ${e.response?.statusCode}');
        AppLogger.debug('     - statusMessage: ${e.response?.statusMessage}');
        AppLogger.debug('     - response data: ${e.response?.data}');
        AppLogger.debug('     - request path: ${e.requestOptions.path}');
        AppLogger.debug('     - request data: ${e.requestOptions.data}');
      }
      // Only wrap if it's not already a clean server error message
      // Check if the exception message doesn't start with "Failed to post reply"
      final message = e.toString();
      if (message.startsWith('Exception: ') && !message.contains('Failed to post reply')) {
        // This is already a clean server message, re-throw as-is
        rethrow;
      } else {
        // Wrap other exceptions
        throw Exception('Failed to post reply: ${e.toString()}');
      }
    }
  }

  /// Uploads one picked file and returns Discourse's `upload://` ref.
  ///
  /// The 148 lines that used to live here — constraint lookup, count
  /// check, validation, image optimisation, byte read, proxy call,
  /// result unwrapping — were duplicated verbatim across six composer
  /// pages. They now live in AttachmentUploadService; this page keeps
  /// only what is actually its own: which topic the upload belongs to,
  /// and where the resulting ref is stored.
  Future<String?> _handleFileUpload(XFile file) async {
    final outcome = await AttachmentUploadService.upload(
      context: context,
      file: file,
      uploadType: 'post',
      targetId: widget.forumId ?? '',
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
    if (widget.isQuote && widget.postId != null) {
      // Fetch quote content from API (using cached future)
      return FutureBuilder<forumcopilot_sdk.FCQuotePostResult>(
        future: _quoteFuture,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final hasError = snapshot.hasError;
          final hasData = snapshot.hasData && snapshot.data != null;
          // Only set quoteContent if we have data, otherwise use null to avoid overwriting user input
          final quoteContent = hasData && snapshot.data!.quoteContent != null && snapshot.data!.quoteContent!.isNotEmpty
              ? snapshot.data!.quoteContent
              : null;
          
          // Create the compose widget once and reuse it across all states
          // Use a stable key based on postId to preserve widget state (including attachments)
          Widget compose = MessageComposePage(
            key: ValueKey('reply_with_quote_${widget.postId}'),
            siteContext: widget.siteContext,
            title: AppLocalizations.of(context)?.reply ?? 'Reply',
            showTitleField: false,
            initialContent: quoteContent,
            titleController: _titleController,
            contentController: _contentController,
            contentHint: AppLocalizations.of(context)?.writeYourReply ?? 'Write your reply...',
            onSubmit: _handleSubmitWithDraftDiscard,
            onFileUpload: (widget.siteContext.loginDataOutput?.canUploadAttachment ?? false) ? _handleFileUpload : null,
            topicTitle: widget.topicTitle,
            showWhisperToggle: _isStaff,
            onWhisperChanged: (value) => setState(() => _isWhisper = value),
            onRemoveAttachment: (attachmentId) async {
              // Remove the attachment ID from the list and call API to delete from server
              // Call API to remove attachment from server
              if (_groupId != null && _groupId!.isNotEmpty && widget.forumId != null && widget.forumId!.isNotEmpty) {
                try {
                  var attachmentProxy = SiteProxyFactory.getAttachmentProxy();
                  await attachmentProxy.removeAttachmentAsync(
                    attachmentId,
                    widget.forumId!,
                    _groupId!, // groupId is required for temporary attachments
                    '', // postId is empty for new replies
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
            onSuccess: (success) {
              return _createdPostId;
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
                Center(child: Text(AppLocalizations.of(context)?.failedToLoadQuote(snapshot.error.toString()) ?? 'Failed to load quote: \n${snapshot.error}')),
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
        showTitleField: false,
        initialContent: _getInitialContent(),
        titleController: _titleController,
        contentController: _contentController,
        contentHint: 'Write your reply...',
        onSubmit: _handleSubmitWithDraftDiscard,
        onFileUpload: (widget.siteContext.loginDataOutput?.canUploadAttachment ?? false) ? _handleFileUpload : null,
        topicTitle: widget.topicTitle,
        showWhisperToggle: _isStaff,
        onWhisperChanged: (value) => setState(() => _isWhisper = value),
        onRemoveAttachment: (attachmentId) async {
          // Remove the attachment ID from the list and call API to delete from server
          // Call API to remove attachment from server
          if (_groupId != null && _groupId!.isNotEmpty && widget.forumId != null && widget.forumId!.isNotEmpty) {
            try {
              var attachmentProxy = SiteProxyFactory.getAttachmentProxy();
              await attachmentProxy.removeAttachmentAsync(
                attachmentId,
                widget.forumId!,
                _groupId!, // groupId is required for temporary attachments
                '', // postId is empty for new replies
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
        onSuccess: (success) {
          return _createdPostId;
        },
        onError: (error) {
          if (context.mounted) {
            // Extract the clean message from the exception
            String errorMessage = error.toString();
            // Remove "Exception: " prefix if present
            if (errorMessage.startsWith('Exception: ')) {
              errorMessage = errorMessage.substring(11);
            }
            
            // Cache theme values to avoid multiple Theme.of(context) calls that could trigger rebuilds
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;
            final textTheme = theme.textTheme;
            
            // Capture ScaffoldMessengerState to ensure dismiss button works correctly
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: DesignTokens.spacingM),
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
                  label: 'Dismiss',
                  textColor: colorScheme.onErrorContainer,
                  onPressed: () {
                    scaffoldMessenger.hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
          // Note: We do NOT call Navigator.pop or trigger any parent widget operations
          // when a reply fails. Only MessageComposePage's setState will be called.
        },
      );
    }
  }
}
