import 'package:flutter/material.dart';
import 'package:discourse_core/discourse_core.dart'
    show
        DiscourseMediaOptimizationContext,
        DiscourseUploadKind,
        discourseUploadKind,
        discourseUploadMarkdown;
import '../../utils/discourse_markup.dart';
import '../../utils/emoji_shortcodes.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_attachment.dart';
import 'package:image_picker/image_picker.dart';
import 'package:discourse_ui/views/user_search_page.dart';
import 'package:discourse_ui/utils/file_picker_utils.dart';
import 'package:discourse_ui/utils/attachment_constraints_utils.dart';
import 'package:discourse_ui/utils/attachment_validation_utils.dart';
import 'package:discourse_ui/views/widgets/cached_redirect_image.dart';
import 'dart:io';
import 'package:discourse_ui/utils/file_utils.dart';
import '../../theme/design_tokens.dart';
import '../../settings_context.dart';
import '../../utils/image_optimize.dart';
import '../../utils/image_shrink.dart';
import 'oversized_image_sheet.dart';
import 'package:forumcopilot_sdk/models/entities/fc_attachment_data.dart';
import 'category_badge.dart';
import 'upload_tile.dart';
import '../../utils/error_message.dart';
import '../../utils/snackbar_helper.dart';
import 'package:discourse_ui/utils/app_navigation.dart';
import 'package:discourse_ui/views/widgets/discard_changes_scope.dart';

class MessageComposePage extends StatefulWidget {
  final SiteContext siteContext;
  final String title;
  final bool showTitleField;
  final bool requireTitle; // New parameter to control title requirement
  final String? initialContent;
  final Future<bool> Function(String title, String content) onSubmit;
  // Returns attachment ID on success, null on failure
  // If null, attachment upload buttons will be hidden
  final Future<String?> Function(XFile file)? onFileUpload;
  /// The fields' hints; null for the generic "Write your title/content".
  final String? titleHint;
  final String? contentHint;
  final bool showAppBar;
  final bool autoFocusContent;
  final String? forumName;

  /// The category's id, when known, so the header shows its badge — its
  /// colour and emoji — rather than a generic chip.
  final String? forumId;
  final String? topicTitle;
  final void Function(Exception error)? onError;
  final TextEditingController? titleController;
  final TextEditingController? contentController;
  final dynamic Function(bool success)? onSuccess; // Optional callback to return custom value

  // Existing attachments (from API)
  final List<FCAttachment>? existingAttachments;
  final Future<bool> Function(String attachmentId)? onRemoveExistingAttachment;

  // Callback when a newly uploaded attachment is removed (by attachment ID)
  // Returns Future to allow async operations (like API calls)
  final Future<void> Function(String attachmentId)? onRemoveAttachment;

  // Icon to display in the submit button (defaults to send icon)
  final IconData? submitIcon;

  /// The submit button's label: "Create Topic", "Reply", … Defaults to
  /// Save for a [submitIcon] of save, else Send.
  final String? submitLabel;

  /// The body field's label: "Content" unless the page names it (New
  /// Message says "Message").
  final String? contentLabel;

  // Show signature toggle for new topic editor
  final bool showSignatureToggle;

  // Optional widget slot rendered above the title field. Discourse uses
  // this for the tag-input row.
  final Widget? extraHeader;

  // Discourse whisper support (staff-only reply mode). When
  // [showWhisperToggle] is true a visibility toggle appears in the
  // bottom toolbar and a "Whisper" chip is shown next to the send
  // button while active. The composer only tracks the flag — the parent
  // (ReplyPage) decides how to submit via [onWhisperChanged].
  final bool showWhisperToggle;
  final ValueChanged<bool>? onWhisperChanged;

  /// Whether closing now would lose something the writer has not kept, so
  /// closing asks first ([DiscardChangesScope]). A composer with a server
  /// draft passes its draft controller's `changedSinceOpened`; without one,
  /// any change from what the composer opened with counts.
  final bool Function()? hasChanges;

  /// Keeps the writing as a draft, then closes: offered as Save draft.
  final Future<void> Function()? onSaveDraft;

  /// Throws the writing away (the server draft too) before closing.
  final Future<void> Function()? onDiscard;

  /// An edit of an existing post: closing asks about "your changes".
  final bool isEdit;

  /// The page that takes the composer's place once it has sent: the new
  /// topic, the new message. It opens where the composer was, in one
  /// transition, and Back from it goes to the page the composer was opened
  /// from. The composer used to close and the page open after it, two
  /// transitions at once. Null (or a null answer) closes the composer.
  final Widget? Function()? pageAfterSubmit;

  const MessageComposePage({
    super.key,
    required this.siteContext,
    required this.title,
    required this.onSubmit,
    this.onFileUpload,
    this.showTitleField = false,
    this.requireTitle = true, // Default to true to maintain existing behavior
    this.initialContent,
    this.titleHint,
    this.contentHint,
    this.showAppBar = true,
    this.autoFocusContent = true,
    this.forumName,
    this.forumId,
    this.topicTitle,
    this.onError,
    this.titleController,
    this.contentController,
    this.onSuccess,
    this.existingAttachments,
    this.onRemoveExistingAttachment,
    this.onRemoveAttachment,
    this.submitIcon,
    this.submitLabel,
    this.contentLabel,
    this.showSignatureToggle = false,
    this.extraHeader,
    this.showWhisperToggle = false,
    this.onWhisperChanged,
    this.hasChanges,
    this.onSaveDraft,
    this.onDiscard,
    this.isEdit = false,
    this.pageAfterSubmit,
  });

  @override
  State<MessageComposePage> createState() => _MessageComposePageState();
}

class _MessageComposePageState extends State<MessageComposePage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();
  final _scrollController = _HoldWhilePressedScrollController();
  bool _isSubmitting = false;

  /// What the composer opened with, for [_hasChanges] when the page has no
  /// draft to ask.
  late final String _openedTitle;
  late final String _openedContent;

  bool _hasChanges() =>
      widget.hasChanges?.call() ??
      (_titleController.text != _openedTitle ||
          _contentController.text != _openedContent);
  /// The files picked for this post, uploading or uploaded, in the order
  /// picked — see [_uploadAll].
  final List<_PendingUpload> _uploads = [];
  final Set<String> _removedExistingAttachmentIds = {}; // Track removed existing attachments
  bool _isRemovingAttachment = false;
  bool _ownsTitleController = false;
  bool _ownsContentController = false;
  bool _isContentFieldFocused = false; // Track if content field has focus
  bool _includeSignature = false; // Opt-in where a page offers it
  bool _isWhisper = false; // Discourse staff whisper mode


  @override
  void initState() {
    super.initState();

    // Use external controllers if provided, otherwise create internal ones
    if (widget.titleController != null) {
      _titleController = widget.titleController!;
      _ownsTitleController = false;
    } else {
      _titleController = TextEditingController();
      _ownsTitleController = true;
    }

    if (widget.contentController != null) {
      _contentController = widget.contentController!;
      _ownsContentController = false;
    } else {
      _contentController = TextEditingController();
      _ownsContentController = true;
    }

    if (widget.initialContent != null) {
      _contentController.text = widget.initialContent!;
      _contentController.selection = TextSelection.fromPosition(
        TextPosition(offset: _contentController.text.length),
      );
    }
    _openedTitle = _titleController.text;
    _openedContent = _contentController.text;

    // Request focus after a short delay (only if auto-focus is enabled)
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      if (widget.showTitleField && widget.autoFocusContent) {
        // Only auto-focus title if autoFocusContent is true
        _titleFocusNode.requestFocus();
      } else if (widget.autoFocusContent) {
        // Auto-focus content if enabled
        _contentFocusNode.requestFocus();
      }
      // If autoFocusContent is false, don't focus anything
    });

    _contentController.addListener(_dropUploadsTakenOutOfText);

    // Listen to focus changes
    _contentFocusNode.addListener(() {
      setState(() {
        _isContentFieldFocused = _contentFocusNode.hasFocus;
      });
    });
  }

  @override
  void didUpdateWidget(MessageComposePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update content if initialContent changed from null to a value (quote loaded)
    // Only update if the composer is effectively empty or still shows the
    // previous initialContent. Never clobber other non-empty content — a
    // server-side draft may have hydrated (or the user may have typed)
    // while the quote future was still resolving, and the restored
    // draft/user input wins over the late-arriving quote.
    if (widget.initialContent != null && widget.initialContent != oldWidget.initialContent) {
      if (_contentController.text.isEmpty || _contentController.text == oldWidget.initialContent) {
        _contentController.text = widget.initialContent!;
        _contentController.selection = TextSelection.fromPosition(
          TextPosition(offset: _contentController.text.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _contentController.removeListener(_dropUploadsTakenOutOfText);
    // Only dispose controllers if we own them
    if (_ownsTitleController) {
      _titleController.dispose();
    }
    if (_ownsContentController) {
      _contentController.dispose();
    }
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Inserts the markup for a formatting-toolbar action at the cursor
  /// (wrapping the selection when there is one).
  ///
  /// The mapping lives in [DiscourseMarkup] so this composer and the
  /// new-conversation composer stay in step — see that class for why a
  /// few actions emit BBCode rather than Markdown.
  void _insertMarkup(String tag) {
    // Ensure the content field has focus before modifying
    if (!_contentFocusNode.hasFocus) {
      _contentFocusNode.requestFocus();
    }
    _contentController.value =
        DiscourseMarkup.apply(_contentController.value, tag);
    // Ensure the field maintains focus after insertion
    _contentFocusNode.requestFocus();
  }

  /// Checks if a filename has an insertable image extension
  bool _isInsertableImage(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    return ['gif', 'jpg', 'jpeg', 'jpe', 'pjpeg', 'png', 'ico', 'webp'].contains(extension);
  }

  /// Inserts an attachment reference at the current cursor position.
  ///
  /// Phase 5.19 — previously emitted XenForo `[ATTACH=full]id[/ATTACH]`
  /// BBCode, which Discourse's Markdown engine doesn't parse. Now emits
  /// Discourse Markdown referencing the upload's `short_url`
  /// (`![image](upload://abc12345.png)` for images,
  /// `[file|attachment](upload://...)` for everything else).
  ///
  /// `attachmentRef` is the Discourse `short_url` for the upload — the
  /// composer state stores these in `_fileToAttachmentId` (despite the
  /// XF-flavoured name; we reinterpret the slot for Discourse). The
  /// composer's parent page also forwards the same short_urls to the
  /// post proxy on send; the proxy's `appendAttachmentMarkdown` dedups
  /// against what's already inline so refs aren't doubled.
  ///
  /// Tapping an uploaded image inserts it straight away: Discourse
  /// Markdown has no thumbnail vs full-size distinction (the rendered
  /// size is governed by the post's site/category settings), so the
  /// composer no longer asks.
  /// Prepares a picked image for upload, asking before rewriting it.
  ///
  /// Shared by both pickers. They used to carry separate copies of this
  /// logic, so fixing the image button left the paperclip still silently
  /// transcoding — the two had already drifted once and would again.
  ///
  /// Returns the file to upload (the original when it already fits), or
  /// null when the user declined or it cannot be made to fit.
  Future<XFile?> _prepareImageForUpload(
    XFile picked,
    FCAttachmentConstraints constraints,
  ) async {
    // First as the forum's own composer would prepare it (a photo scaled to
    // 1920 px and recompressed, when the forum asks for that); only an image
    // still over the limit after that gets the resize question.
    var image = picked;
    final optimized = await optimizePhotoForForum(
        File(picked.path), widget.siteContext.mediaOptimization);
    if (optimized != null) image = XFile(optimized.path);
    final maxBytes = constraints.size;
    final pickedBytes = await File(image.path).length();
    // Anything within the limit is uploaded exactly as picked. The old
    // path re-encoded on `needsOptimization`, which also fires for "this
    // is a PNG and JPEG is allowed" — converting files that were never
    // too big, and which would have turned a GIF into a still frame.
    if (maxBytes == null || maxBytes <= 0 || pickedBytes <= maxBytes) {
      return image;
    }

    var proceed = SettingsContext.instance.alwaysResizeOversizedImages.value;
    if (!proceed && mounted) {
      final choice = await showOversizedImageSheet(
        context,
        fileName: image.name,
        fileBytes: pickedBytes,
        maxBytes: maxBytes,
      );
      proceed = choice == OversizedImageChoice.resize;
    }
    if (!proceed) return null;

    final shrunk =
        await shrinkImageToFit(File(image.path), maxBytes: maxBytes);
    if (shrunk == null) {
      if (mounted) {
        _showAttachmentError(
          AppLocalizations.of(context)!.imageTooLargeCouldNotResize(
            image.name,
            formatFileSize(pickedBytes),
            formatFileSize(maxBytes),
          ),
        );
      }
      return null;
    }
    if (mounted) {
      final from = shrunk.originalSize;
      final to = shrunk.newSize;
      final dims = (from != null && to != null)
          ? ' (${from.width}×${from.height} → ${to.width}×${to.height})'
          : '';
      _showAttachmentNotice(
        AppLocalizations.of(context)!.imageResizedToFitLimit(
          image.name,
          formatFileSize(shrunk.newBytes),
          dims,
          formatFileSize(maxBytes),
        ),
      );
    }
    return XFile(shrunk.file.path, name: image.name);
  }

  void _showAttachmentError(String message) =>
      SnackbarHelper.showError(context, message);

  /// Says what was done to a file the user picked. Resizing without
  /// telling anyone is how a 20 MB PNG became a 2.2 MB JPEG unnoticed.
  void _showAttachmentNotice(String message) =>
      SnackbarHelper.showInfo(context, message);

  void _insertAttachmentRef(String attachmentRef) {
    // Ensure content field has focus
    if (!_contentFocusNode.hasFocus) {
      _contentFocusNode.requestFocus();
    }

    final TextEditingValue value = _contentController.value;
    final int start = value.selection.start;
    final int end = value.selection.end;

    // Discourse-flavoured Markdown: image refs get rendered inline;
    // other file refs render as a download chip.
    final lower = attachmentRef.toLowerCase();
    const imageExts = [
      '.png', '.jpg', '.jpeg', '.gif', '.webp', '.heic', '.bmp', '.svg',
    ];
    final isImage = imageExts.any(lower.endsWith);
    final String markdown =
        DiscourseMarkup.attachmentRef(attachmentRef, isImage: isImage);

    String newText;
    int cursorPosition;

    if (start < 0) {
      // No valid cursor position - append to end
      newText = '${value.text}$markdown';
      cursorPosition = newText.length;
    } else {
      // Insert at cursor position (replacing selection if any)
      newText = value.text.replaceRange(start, end, markdown);
      cursorPosition = start + markdown.length;
    }

    // Update controller with new text and cursor position
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );

    // Maintain focus
    _contentFocusNode.requestFocus();
  }

  /// The paperclip: any file the forum accepts.
  void _handleFileUpload() async {
    if (widget.onFileUpload == null) return;
    final siteContext = widget.siteContext;
    final pickConstraints = getAttachmentConstraintsFromSiteContext(siteContext);
    if (!canAddMoreAttachments(_uploads.length, pickConstraints)) {
      _showNotice(AppLocalizations.of(context)!
          .maximumAttachmentsAllowed(pickConstraints!.count ?? 0));
      return;
    }
    // Restrict the picker to the forum's authorized extensions when known.
    final XFile? file = await FilePickerUtils.pickFile(
      allowedExtensions: pickConstraints?.extensions,
    );
    if (file == null || !mounted) return;
    final prepared = await _prepare(file);
    if (prepared != null && mounted) await _uploadAll([prepared]);
  }

  /// The photo button: photos and videos from the gallery, or the camera.
  void _handleImageUpload({bool fromCamera = false}) async {
    if (widget.onFileUpload == null) return;
    final constraints = getAttachmentConstraintsFromSiteContext(
        widget.siteContext,
        isImage: true);
    if (!canAddMoreAttachments(_uploads.length, constraints)) {
      _showNotice(AppLocalizations.of(context)!
          .maximumAttachmentsAllowed(constraints!.count ?? 0));
      return;
    }
    // No imageQuality: any value makes image_picker re-encode (a PNG
    // screenshot arrived lossy and renamed .jpg, and a 20 MB photo was
    // silently shrunk under a limit that could then never fire). What was
    // picked is uploaded, prepared the forum's way in [_prepare].
    var picked = fromCamera
        ? [if (await FilePickerUtils.takePhoto() case final photo?) photo]
        : await FilePickerUtils.pickMultiMedia();
    if (picked.isEmpty || !mounted) return;
    final max = constraints?.count;
    if (max != null && max > 0 && _uploads.length + picked.length > max) {
      final room = max - _uploads.length;
      _showNotice(AppLocalizations.of(context)!
          .onlyNMoreAttachmentsAllowed(room, room));
      picked = picked.take(room).toList();
    }
    final ready = <XFile>[];
    for (final file in picked) {
      final prepared = await _prepare(file);
      if (!mounted) return;
      if (prepared != null) ready.add(prepared);
    }
    if (ready.isNotEmpty) await _uploadAll(ready);
  }

  /// Checks [file] against the forum's limits for its kind (Discourse caps
  /// images at max_image_size_kb and everything else at
  /// max_attachment_size_kb) and prepares a photo the forum's way. Null when
  /// it cannot be sent; the reason has been shown.
  Future<XFile?> _prepare(XFile file) async {
    try {
      final isImage =
          discourseUploadKind(file.name) == DiscourseUploadKind.image;
      final constraints = getAttachmentConstraintsFromSiteContext(
          widget.siteContext,
          isImage: isImage);
      if (constraints == null) return file;
      final validation = await validateFile(file, constraints, isImage,
          currentAttachmentCount: _uploads.length);
      if (!validation.isValid) {
        if (mounted) {
          _showNotice(
              '${file.name}: ${validation.errorMessage ?? AppLocalizations.of(context)!.failedToUploadFilePleaseTryAgain}');
        }
        return null;
      }
      return isImage ? await _prepareImageForUpload(file, constraints) : file;
    } catch (e) {
      if (mounted) {
        _showNotice(AppLocalizations.of(context)!
            .failedToUploadFile2(describeError(e)));
      }
      return null;
    }
  }

  /// A plain notice (M3's default snackbar colours). It replaces the
  /// one showing rather than queueing behind it: tapping Send twice on an
  /// empty title used to line the same notice up twice.
  void _showNotice(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  /// Where an upload goes in the text: a line of its own at the cursor, as
  /// the web composer places it, or at the end when the field has no cursor.
  void _insertOnOwnLine(String line) {
    final value = _contentController.value;
    final body = value.text;
    final sel = value.selection;
    final start = sel.isValid ? sel.start.clamp(0, body.length) : body.length;
    final end = sel.isValid ? sel.end.clamp(start, body.length) : body.length;
    final before = body.substring(0, start);
    final after = body.substring(end);
    final inserted = '${before.isEmpty || before.endsWith('\n') ? '' : '\n'}'
        '$line${after.startsWith('\n') ? '' : '\n'}';
    _contentController.value = TextEditingValue(
      text: before + inserted + after,
      selection:
          TextSelection.collapsed(offset: before.length + inserted.length),
    );
  }

  /// Replaces the first [from] in the text with [to] — with nothing, taking
  /// its line break along. Returns whether it was there.
  bool _replaceInText(String from, String to) {
    final text = _contentController.text;
    final i = text.indexOf(from);
    if (i < 0) return false;
    var end = i + from.length;
    if (to.isEmpty && end < text.length && text[end] == '\n') end++;
    final updated = text.replaceRange(i, end, to);
    final sel = _contentController.selection;
    var offset = sel.isValid ? sel.baseOffset : updated.length;
    if (offset >= end) {
      offset += to.length - (end - i);
    } else if (offset > i) {
      offset = i + to.length;
    }
    _contentController.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: offset.clamp(0, updated.length)),
    );
    return true;
  }

  /// Web's placeholder, `[Uploading: name…]()`, unique in the text.
  String _placeholderFor(String name) {
    final l10n = AppLocalizations.of(context)!;
    var label = name;
    for (var n = 2;; n++) {
      final placeholder = '[${l10n.uploadingFilename(label)}]()';
      if (!_contentController.text.contains(placeholder) &&
          !_uploads.any((u) => u.placeholder == placeholder)) {
        return placeholder;
      }
      label = '$name ($n)';
    }
  }

  /// Puts [files] in the text and the strip at once, then uploads them one
  /// by one. Each starts as web's placeholder on its own line at the cursor
  /// and becomes the Markdown Discourse expects for its kind (an image, a
  /// video or audio that plays, a file link) when it lands; a failure takes
  /// the placeholder out again.
  ///
  /// The text is what gets posted. Uploads used to live only in a list under
  /// it and were added to the end on send: an image could not go between
  /// paragraphs, a draft lost them, and removing one from the list left its
  /// Markdown behind.
  Future<void> _uploadAll(List<XFile> files) async {
    final added = <_PendingUpload>[];
    for (final file in files) {
      // Unique against the ones already made for this batch too.
      final upload = _PendingUpload(file, _placeholderFor(file.name));
      _uploads.add(upload);
      added.add(upload);
    }
    bool isImage(_PendingUpload u) =>
        discourseUploadKind(u.file.name) == DiscourseUploadKind.image;
    final images = added.where(isImage).toList();
    // Three or more photos picked together go in a grid, as the web
    // composer puts them (enable_auto_grid_images); stacked full width they
    // made a long scroll.
    if (images.length >= 3) {
      _insertOnOwnLine(
          ['[grid]', for (final u in images) u.placeholder, '[/grid]'].join('\n'));
      for (final u in added.where((u) => !isImage(u))) {
        _insertOnOwnLine(u.placeholder);
      }
    } else {
      for (final upload in added) {
        _insertOnOwnLine(upload.placeholder);
      }
    }
    setState(() {});

    for (final upload in added) {
      if (!mounted) return;
      if (!_uploads.contains(upload)) continue; // removed while waiting
      String? ref;
      Object? error;
      try {
        ref = await widget.onFileUpload!(upload.file);
      } catch (e) {
        error = e;
      }
      if (!mounted) return;
      final uploaded = ref != null && ref.isNotEmpty;
      if (!_uploads.contains(upload)) {
        // Removed while it uploaded: let the page forget it too.
        if (uploaded) widget.onRemoveAttachment?.call(ref);
        continue;
      }
      if (!uploaded) {
        setState(() => _uploads.remove(upload));
        _replaceInText(upload.placeholder, '');
        // The page's upload handler has said why (size, type, the server's
        // message) — a second, generic message followed it. An exception is
        // ours to report.
        if (error != null) {
          _showNotice(AppLocalizations.of(context)!
              .failedToUploadFile2(describeError(error)));
        }
        continue;
      }
      final markdown = discourseUploadMarkdown(ref);
      if (!_replaceInText(upload.placeholder, markdown)) {
        // The placeholder was deleted meanwhile: the writer took it out.
        setState(() => _uploads.remove(upload));
        widget.onRemoveAttachment?.call(ref);
        continue;
      }
      setState(() {
        upload.ref = ref;
        upload.markdown = markdown;
      });
    }
    // A grid whose photos all failed would be left empty.
    if (images.length >= 3 && mounted) _replaceInText('[grid]\n[/grid]', '');
  }

  /// Takes [upload] out of the post: its tile, and its line in the text.
  Future<void> _removeUpload(_PendingUpload upload) async {
    // Out of the list first, so the text listener does not report it again.
    setState(() => _uploads.remove(upload));
    _replaceInText(upload.markdown ?? upload.placeholder, '');
    final ref = upload.ref;
    if (ref != null) {
      try {
        await widget.onRemoveAttachment?.call(ref);
      } catch (_) {}
    }
  }

  /// An uploaded file whose Markdown the writer deleted is out of the post:
  /// its tile goes, and the page forgets it, so it is not added back at the
  /// end on send.
  void _dropUploadsTakenOutOfText() {
    final text = _contentController.text;
    final gone = [
      for (final u in _uploads)
        if (u.ref != null && !text.contains(u.ref!)) u,
    ];
    if (gone.isEmpty) return;
    setState(() => _uploads.removeWhere(gone.contains));
    for (final u in gone) {
      widget.onRemoveAttachment?.call(u.ref!);
    }
  }

  Future<void> _removeExistingAttachment(String attachmentId) async {
    if (_isRemovingAttachment) return;

    // Show confirmation dialog before removing
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.removeAttachment),
          content: Text(
            AppLocalizations.of(context)!.areYouSureYouWantToRemoveThisAttachment,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        );
      },
    );

    // If user cancelled, don't proceed
    if (confirmed != true) {
      return;
    }

    setState(() => _isRemovingAttachment = true);
    try {
      if (widget.onRemoveExistingAttachment != null) {
        final success = await widget.onRemoveExistingAttachment!(attachmentId);
        if (success && mounted) {
          setState(() {
            _removedExistingAttachmentIds.add(attachmentId);
          });
        } else if (mounted) {}
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
          context,
          AppLocalizations.of(context)!
              .failedToRemoveAttachment2(describeError(e, context: context)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRemovingAttachment = false);
      }
    }
  }

  Widget _buildAttachmentsList() {
    // Get existing attachments that haven't been removed
    final existingAttachments = widget.existingAttachments?.where((a) => !_removedExistingAttachmentIds.contains(a.id)).toList() ?? [];

    // Attachments already on the post (XenForo's model; a Discourse post
    // carries its uploads in its text). New uploads are in the strip.
    if (existingAttachments.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.attach_file, size: DesignTokens.iconSizeM, color: colorScheme.onSurfaceVariant),
            SizedBox(width: DesignTokens.spacingS),
            Text(
              AppLocalizations.of(context)!.attachments,
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
            color: colorScheme.surfaceContainerHighest.withValues(alpha: DesignTokens.opacityLow),
            borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: DesignTokens.opacityLow),
              width: DesignTokens.borderWidthThin,
            ),
          ),
          child: Column(
            children: [
              // Existing attachments from API
              ...existingAttachments.map((attachment) => _buildExistingAttachmentItem(attachment)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExistingAttachmentItem(FCAttachment attachment) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final fileType = getFileType(attachment.filename);
    final fileSize = attachment.fileSizePrintable ?? formatFileSize(attachment.fileSize);
    final isImage = attachment.isImage;
    final isLoading = _isRemovingAttachment && _removedExistingAttachmentIds.contains(attachment.id);

    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacingXS),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            if (_isInsertableImage(attachment.filename)) {
              _insertAttachmentRef(attachment.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingS, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isImage && attachment.thumbnailUrl != null && attachment.thumbnailUrl!.isNotEmpty
                        ? colorScheme.surfaceContainerHighest.withValues(alpha: DesignTokens.opacityLow)
                        : getFileTypeColor(attachment.filename),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isImage && attachment.thumbnailUrl != null && attachment.thumbnailUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedRedirectImage(
                            imageUrl: attachment.thumbnailUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stackTrace) {
                              return Icon(
                                getFileIcon(attachment.filename),
                                size: 24,
                                color: Colors.white,
                              );
                            },
                          ),
                        )
                      : Icon(
                          getFileIcon(attachment.filename),
                          size: 24,
                          color: Colors.white,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attachment.filename,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '$fileType • $fileSize',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (isLoading) ...[
                            SizedBox(width: DesignTokens.spacingS),
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: isLoading ? null : () => _removeExistingAttachment(attachment.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignatureToggle() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SwitchListTile(
      title: Text(
        AppLocalizations.of(context)!.sentFromMobileApp(widget.siteContext.site.name),
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      value: _includeSignature,
      onChanged: (value) {
        setState(() {
          _includeSignature = value;
        });
      },
      activeThumbColor: colorScheme.primary,
    );
  }

  void _handleMention() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserSearchPage(
          siteContext: widget.siteContext,
          onUserSelected: (username, iconUrl) {
            final currentText = _contentController.text;
            final currentSelection = _contentController.selection;
            final beforeCursor = currentText.substring(0, currentSelection.start);
            final afterCursor = currentText.substring(currentSelection.end);
            final newText = '$beforeCursor@$username $afterCursor';
            _contentController.text = newText;
            _contentController.selection = TextSelection.fromPosition(
              TextPosition(offset: (beforeCursor.length + username.length + 2).toInt()), // +2 for @ and space
            );
            // Ensure the content field is focused after inserting the username
            _contentFocusNode.requestFocus();
          },
          selectedUsers: const [],
          forMention: true,
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (widget.showTitleField && widget.requireTitle && _titleController.text.trim().isEmpty) {
      _showNotice(AppLocalizations.of(context)!.pleaseEnterTitle);
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      _showNotice(AppLocalizations.of(context)!.pleaseEnterContent);
      return;
    }

    // Don't post while an attachment upload is still in flight — the
    // upload's short_url wouldn't be included yet and the attachment
    // would silently be dropped from the post.
    if (_uploads.any((u) => u.isUploading)) {
      _showNotice(AppLocalizations.of(context)!.pleaseWaitForAttachmentsToFinishUploading);
      return;
    }

    // The fields lock while sending, and focus used to hop from the locked
    // text to the next field that was not (Tags), keyboard and all.
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      String content = _contentController.text.trim();
      
      // Append signature if enabled
      if (widget.showSignatureToggle && _includeSignature) {
        final signature = AppLocalizations.of(context)!
            .sentFromMobileApp(widget.siteContext.site.name);
        // Add two line breaks before signature
        content = '$content\n\n$signature';
      }
      
      final success = await widget.onSubmit(
        _titleController.text.trim(),
        content,
      );

      if (mounted && success) {
        // Dismiss keyboard before navigating back
        FocusScope.of(context).unfocus();
        final result =
            widget.onSuccess != null ? widget.onSuccess!(true) : true;
        final next = widget.pageAfterSubmit?.call();
        final route = ModalRoute.of(context);
        if (next != null && route != null && route.isCurrent) {
          Navigator.of(context)
              .pushReplacement(AppNavigation.route<void>(next), result: result);
        } else {
          context.popOwnRoute(result);
        }
      }
    } catch (e) {
      if (mounted) {
        if (widget.onError != null && e is Exception) {
          widget.onError!(e);
        } else {
          // The forum's own reason ("Title is too short (minimum is 15
          // characters)"), readable rather than "Exception: …".
          SnackbarHelper.showError(context, describeError(e, context: context));
        }
      }
    } finally {
      // Only update state if it actually changed to avoid unnecessary rebuilds
      // This setState only rebuilds MessageComposePage, not parent widgets
      if (mounted && _isSubmitting) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// This post's uploads, as tiles above the toolbar: what each is, its
  /// progress, and a remove button. The text holds where each goes. (They
  /// were a titled list under the text that flashed a spinner at every
  /// change, and the only place an upload appeared at all.)
  Widget _buildUploadStrip() {
    if (_uploads.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: UploadTile.extent + DesignTokens.spacingS,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          DesignTokens.spacingL,
          0,
          DesignTokens.spacingL,
          DesignTokens.spacingS,
        ),
        itemCount: _uploads.length,
        // The badge's room is the gap.
        separatorBuilder: (_, __) => const SizedBox(width: 2),
        itemBuilder: (_, i) => UploadTile(
          key: ObjectKey(_uploads[i]),
          fileName: _uploads[i].file.name,
          path: _uploads[i].file.path,
          uploading: _uploads[i].isUploading,
          onRemove: () => _removeUpload(_uploads[i]),
        ),
      ),
    );
  }

  Widget _buildBottomToolbar() {
    final colorScheme = Theme.of(context).colorScheme;

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
              // File attachment button - only show if onFileUpload is provided
              if (widget.onFileUpload != null)
                Semantics(
                  label: AppLocalizations.of(context)!.attachFile,
                  hint: AppLocalizations.of(context)!.composerAttachFileHint,
                  button: true,
                  child: IconButton(
                    icon: Icon(
                      Icons.attach_file,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    tooltip: AppLocalizations.of(context)!.attachFile,
                    onPressed: _handleFileUpload,
                  ),
                ),
              // Image upload button - only show if onFileUpload is provided
              if (widget.onFileUpload != null)
                Semantics(
                  label: AppLocalizations.of(context)!.uploadImage,
                  hint: AppLocalizations.of(context)!.composerUploadImageHint,
                  button: true,
                  child: IconButton(
                    icon: Icon(
                      Icons.image,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    tooltip: AppLocalizations.of(context)!.uploadImage,
                    onPressed: _handleImageUpload,
                  ),
                ),
              // Camera button - same as above, straight from the camera
              if (widget.onFileUpload != null && FilePickerUtils.canTakePhoto)
                Semantics(
                  label: AppLocalizations.of(context)!.takePhoto,
                  button: true,
                  child: IconButton(
                    icon: Icon(
                      Icons.photo_camera,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    tooltip: AppLocalizations.of(context)!.takePhoto,
                    onPressed: () => _handleImageUpload(fromCamera: true),
                  ),
                ),
              // Formatting button
              Semantics(
                label: AppLocalizations.of(context)!.formatting,
                hint: AppLocalizations.of(context)!.composerFormattingHint,
                button: true,
                enabled: _isContentFieldFocused,
                child: PopupMenuButton<String>(
                  enabled: _isContentFieldFocused,
                  // `text_format`, not `format_bold`: this opens a menu of
                  // thirteen actions (bold through spoiler and lists), and a
                  // bold glyph reads as a bold *button* — so the other twelve
                  // looked absent rather than one tap away.
                  icon: Icon(Icons.text_format, color: _isContentFieldFocused ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant.withValues(alpha: 0.38)),
                  tooltip: AppLocalizations.of(context)!.formatting,
                  onSelected: _insertMarkup,
                itemBuilder: (context) => [
                  // Text formatting
                  PopupMenuItem(
                    value: 'B',
                    child: Row(
                      children: [
                        Icon(Icons.format_bold, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)!.bold),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'I',
                    child: Row(
                      children: [
                        Icon(Icons.format_italic, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)!.italic),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'U',
                    child: Row(
                      children: [
                        Icon(Icons.format_underline, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)!.underline),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'S',
                    child: Row(
                      children: [
                        Icon(Icons.strikethrough_s, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)!.strikethrough),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  // Links and Media
                  PopupMenuItem(
                    value: 'URL',
                    child: Row(
                      children: [
                        Icon(Icons.link, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)!.link),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'IMG',
                    child: Row(
                      children: [
                        Icon(Icons.image, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)!.image),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'VIDEO',
                    child: Row(
                      children: [
                        Icon(Icons.videocam, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)!.video),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  // Content blocks
                  PopupMenuItem(
                    value: 'QUOTE',
                    child: Row(
                      children: [
                        Icon(Icons.format_quote, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)!.quote),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'CODE',
                    child: Row(
                      children: [
                        Icon(Icons.code, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)!.code),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'SPOILER',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_off, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)!.spoiler),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  // Lists
                  PopupMenuItem(
                    value: 'LIST',
                    child: Row(
                      children: [
                        Icon(Icons.format_list_bulleted, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)!.bulletList),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'LIST=1',
                    child: Row(
                      children: [
                        Icon(Icons.format_list_numbered, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)!.numberedList),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: '*',
                    child: Row(
                      children: [
                        Icon(Icons.subdirectory_arrow_right, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: DesignTokens.spacingS),
                        Text(AppLocalizations.of(context)!.listItem),
                      ],
                    ),
                  ),
                  // Alignment options removed — stock Discourse has no
                  // markup for text alignment (its markdown-it only
                  // parses b/i/u/s/code/url/email/img inline BBCode),
                  // so [LEFT]/[CENTER]/[RIGHT] would post as literal text.
                ],
                ),
              ),
              // Mention button
              IconButton(
                icon: Icon(Icons.alternate_email, color: _isContentFieldFocused ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant.withValues(alpha: 0.38)),
                tooltip: AppLocalizations.of(context)!.mentionUser,
                onPressed: _isContentFieldFocused ? _handleMention : null,
              ),
              // Discourse whisper toggle (staff-only reply mode)
              if (widget.showWhisperToggle)
                IconButton(
                  icon: Icon(
                    _isWhisper ? Icons.visibility_off : Icons.visibility_off_outlined,
                    color: _isWhisper ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  ),
                  tooltip: _isWhisper
                      ? AppLocalizations.of(context)!.whisperOnStaffOnly
                      : AppLocalizations.of(context)!.whisperStaffOnly,
                  onPressed: () {
                    setState(() => _isWhisper = !_isWhisper);
                    widget.onWhisperChanged?.call(_isWhisper);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBackNavigation() {
    // Dismiss keyboard before navigating back (especially important on iOS)
    _titleFocusNode.unfocus();
    _contentFocusNode.unfocus();
    FocusScope.of(context).unfocus();
    // maybePop, so closing asks first when there is writing to lose.
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DiscardChangesScope(
      listenable: Listenable.merge([_titleController, _contentController]),
      hasChanges: _hasChanges,
      isEdit: widget.isEdit,
      busy: _isSubmitting,
      onSaveDraft: widget.onSaveDraft,
      onDiscard: widget.onDiscard,
      child: PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // Dismiss keyboard when back gesture/button is triggered
        // This handles iOS swipe-back and Android back button
        _titleFocusNode.unfocus();
        _contentFocusNode.unfocus();
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: widget.showAppBar
            ? AppBar(
                title: Text(
                  widget.title,
                ),
                // A composer is a full-screen dialog: ✕ closes it, where ←
                // would mean a step back through the forum. It had ← with no
                // label, which a screen reader announced as nothing.
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                    onPressed: _handleBackNavigation,
                  ),
                ),
                actions: [
                  // Visible whisper-mode indicator next to the send button.
                  if (widget.showWhisperToggle && _isWhisper)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: DesignTokens.spacingXS),
                        child: Chip(
                          avatar: Icon(
                            Icons.visibility_off,
                            color: colorScheme.onSecondaryContainer,
                          ),
                          label: Text(AppLocalizations.of(context)!.whisper),
                          backgroundColor: colorScheme.secondaryContainer,
                          side: BorderSide.none,
                        ),
                      ),
                    ),
                  // A labelled button, as Material 3's full-screen forms have:
                  // it was an unlabelled icon in the same colour as Back.
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        end: DesignTokens.spacingS),
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(widget.submitLabel ??
                              (widget.submitIcon == Icons.save_rounded
                                  ? AppLocalizations.of(context)!.save
                                  : AppLocalizations.of(context)!.send)),
                    ),
                  ),
                ],
              )
            : null,
        body: GestureDetector(
          onTap: () {
            // Hide keyboard when tapping outside input fields
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              Expanded(
                // Expand, so the page under a short post is the scroll
                // view's and a tap there leaves the text. Sized to the post
                // it was nobody's: a selection could not be tapped away.
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SingleChildScrollView(
                      controller: _scrollController,
                      // What the primary scroll view it was had.
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: DesignTokens.paddingL,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Which topic this reply goes to: callers always
                            // passed it, but nothing showed it.
                            if (!widget.showTitleField &&
                                (widget.topicTitle ?? '').isNotEmpty) ...[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.reply_rounded,
                                    size: DesignTokens.iconSizeM,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: DesignTokens.spacingS),
                                  Expanded(
                                    child: Text(
                                      withEmojiShortcodes(widget.topicTitle!),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: DesignTokens.spacingL),
                            ],
                            // Where the topic goes: a line with the
                            // category's badge. It was drawn as an outlined
                            // box, which looked tappable and wasn't.
                            if ((widget.forumName ?? '').isNotEmpty) ...[
                              Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.forum,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: DesignTokens.spacingS),
                                  Flexible(
                                    child: CategoryBadge(
                                      siteContext: widget.siteContext,
                                      categoryId: widget.forumId ?? '',
                                      fallbackName: widget.forumName!,
                                      large: true,
                                      tappable: false,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: DesignTokens.spacingL),
                            ],
                            // Discourse tag input slot.
                            if (widget.extraHeader != null) ...[
                              widget.extraHeader!,
                              SizedBox(height: DesignTokens.spacingL),
                            ],
                            // The theme's outlined field with its label in
                            // the field, as every other form in the app.
                            if (widget.showTitleField)
                              TextField(
                                controller: _titleController,
                                focusNode: _titleFocusNode,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.title,
                                  hintText: widget.titleHint ??
                                      AppLocalizations.of(context)!
                                          .composerTitleHint,
                                ),
                                textCapitalization: TextCapitalization.sentences,
                                enabled: !_isSubmitting,
                              ),
                            if (widget.showTitleField) SizedBox(height: DesignTokens.spacingL),
                            // The page holds still while a finger is on the
                            // text: see _HoldWhilePressedScrollController.
                            Listener(
                              onPointerDown: (_) => _scrollController.press(),
                              onPointerUp: (_) => _scrollController.lift(),
                              onPointerCancel: (_) => _scrollController.lift(),
                              child: TextField(
                                controller: _contentController,
                                focusNode: _contentFocusNode,
                                minLines: 10,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                textCapitalization: TextCapitalization.sentences,
                                decoration: InputDecoration(
                                  labelText: widget.contentLabel ??
                                      AppLocalizations.of(context)!.content,
                                  hintText: widget.contentHint ??
                                      AppLocalizations.of(context)!
                                          .composerContentHint,
                                  alignLabelWithHint: true,
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                ),
                                enabled: !_isSubmitting,
                              ),
                            ),
                            SizedBox(height: DesignTokens.spacingL),
                            _buildAttachmentsList(),
                            if (widget.showSignatureToggle) ...[
                              SizedBox(height: DesignTokens.spacingL),
                              _buildSignatureToggle(),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (_isSubmitting)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
              _buildUploadStrip(),
              _buildBottomToolbar(),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

/// The composer's scroll view, held still while a finger is on the text.
///
/// Flutter brings the keyboard up for a long-press too (Android's own text
/// fields leave it down), and the page then scrolls the selection above it
/// while the finger is still down. The finger is over other words by then,
/// and the selection ran on to them: after Back had put the keyboard away, a
/// long-press on one word selected to the end of the post. The page now
/// keeps still until the finger lifts, then brings the selection into view.
class _HoldWhilePressedScrollController extends ScrollController {
  int _fingers = 0;

  bool get _held => _fingers > 0;

  void press() => _fingers++;

  void lift() {
    if (_fingers == 0 || --_fingers > 0) return;
    for (final position in positions) {
      (position as _HoldWhilePressedScrollPosition)._afterLift();
    }
  }

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
          ScrollContext context, ScrollPosition? oldPosition) =>
      _HoldWhilePressedScrollPosition(
        this,
        physics: physics,
        context: context,
        initialPixels: initialScrollOffset,
        keepScrollOffset: keepScrollOffset,
        oldPosition: oldPosition,
        debugLabel: debugLabel,
      );
}

class _HoldWhilePressedScrollPosition extends ScrollPositionWithSingleContext {
  _HoldWhilePressedScrollPosition(
    this._controller, {
    required super.physics,
    required super.context,
    super.initialPixels,
    super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
  });

  final _HoldWhilePressedScrollController _controller;

  /// Where showing the selection asked to scroll while held, and from where.
  double? _heldTarget;
  double? _heldFrom;

  /// How the text field shows its caret or selection ([showOnScreen]);
  /// drags and flings scroll by other means and are never held.
  @override
  Future<void> moveTo(double to,
      {Duration? duration, Curve? curve, bool? clamp = true}) {
    if (_controller._held) {
      _heldTarget = to;
      _heldFrom = pixels;
      return Future<void>.value();
    }
    return super.moveTo(to, duration: duration, curve: curve, clamp: clamp);
  }

  void _afterLift() {
    final target = _heldTarget;
    _heldTarget = null;
    // Not over a scroll the reader made meanwhile.
    if (target == null || _heldFrom != pixels) return;
    animateTo(target.clamp(minScrollExtent, maxScrollExtent),
        duration: kThemeAnimationDuration, curve: Curves.easeOut);
  }
}

/// A file picked in the composer: its placeholder in the text while it
/// uploads, then its `upload://` ref and the Markdown that replaced it.
class _PendingUpload {
  _PendingUpload(this.file, this.placeholder);

  final XFile file;
  final String placeholder;
  String? ref;
  String? markdown;

  bool get isUploading => ref == null;
}
