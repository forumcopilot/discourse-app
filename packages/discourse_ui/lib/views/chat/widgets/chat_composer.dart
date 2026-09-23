import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/design_tokens.dart';
import '../../../utils/attachment_constraints_utils.dart';
import '../../../utils/file_picker_utils.dart';
import '../../../utils/file_utils.dart';

/// Bottom-anchored message composer for the chat channel view.
///
/// Ported from the qhtt xenforoapp's Siropu chat composer — generic
/// shape, no XF specifics. Returns a Future<bool> from [onSend] so
/// the parent can swallow optimistic-add errors without the input
/// losing focus on success.
///
/// Files go up as soon as they are picked, the way Discourse's chat composer
/// does it, and the message then names them by upload id; a message may be
/// files alone.
class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.onSend,
    this.onUpload,
    this.enabled = true,
    this.hintText = 'Type a message…',
  });

  /// Sends [text] with the ids of the files uploaded for it.
  final Future<bool> Function(String text, List<int> uploadIds) onSend;

  /// Uploads one picked file; returns its upload id, or null when it was not
  /// uploaded (the caller says why). [alreadyAttached] counts the files
  /// already in the composer. Null hides the attach button: the forum does
  /// not allow files in chat, or nothing can be sent here.
  final Future<int?> Function(XFile file, int alreadyAttached)? onUpload;

  final bool enabled;
  final String hintText;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _sending = false;
  bool _hasText = false;

  /// Files picked for this message, in the order picked.
  final List<_PickedFile> _files = [];

  bool get _uploading => _files.any((f) => f.uploadId == null);

  List<int> get _uploadIds => [
        for (final f in _files)
          if (f.uploadId case final id?) id,
      ];

  /// Text, files, or both — but not while a file is still going up, since
  /// the message could only name the ones already done.
  bool get _canSend => !_uploading && (_hasText || _uploadIds.isNotEmpty);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (!_canSend || _sending) return;
    setState(() => _sending = true);
    final ok = await widget.onSend(text, _uploadIds);
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (ok) _files.clear();
    });
    if (ok) {
      _controller.clear();
      _focus.requestFocus();
    }
  }

  Future<void> _attach() async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<_Source>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (FilePickerUtils.canTakePhoto)
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(l10n.takePhoto),
                onTap: () => Navigator.pop(sheet, _Source.camera),
              ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.uploadImage),
              onTap: () => Navigator.pop(sheet, _Source.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: Text(l10n.attachFile),
              onTap: () => Navigator.pop(sheet, _Source.file),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    final List<XFile> picked;
    switch (source) {
      case _Source.camera:
        final photo = await FilePickerUtils.takePhoto();
        picked = [if (photo != null) photo];
      case _Source.gallery:
        picked = await FilePickerUtils.pickMultiImage();
      case _Source.file:
        // Only the forum's authorized extensions, when known.
        final constraints =
            getAttachmentConstraintsFromSiteContext(getCurrentSiteContext());
        final file = await FilePickerUtils.pickFile(
            allowedExtensions: constraints?.extensions);
        picked = [if (file != null) file];
    }
    if (picked.isEmpty || !mounted) return;
    final added = [for (final f in picked) _PickedFile(f)];
    setState(() => _files.addAll(added));
    // One at a time: an oversized image asks whether to resize it, and
    // several such questions at once would stack.
    for (final f in added) {
      if (!mounted) return;
      if (!_files.contains(f)) continue; // removed before its turn
      final id = await widget.onUpload!(f.file, _uploadIds.length);
      if (!mounted) return;
      setState(() {
        if (id == null) {
          _files.remove(f);
        } else {
          f.uploadId = id;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingS,
          vertical: DesignTokens.spacingS,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
              top:
                  BorderSide(color: theme.dividerColor.withValues(alpha: 0.5))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_files.isNotEmpty)
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(bottom: DesignTokens.spacingS),
                  itemCount: _files.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: DesignTokens.spacingS),
                  itemBuilder: (_, i) => _PickedFileTile(
                    file: _files[i],
                    onRemove: _sending
                        ? null
                        : () => setState(() => _files.removeAt(i)),
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (widget.onUpload != null)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    color: colorScheme.onSurfaceVariant,
                    tooltip: AppLocalizations.of(context)!.chatAttachFile,
                    onPressed: widget.enabled && !_sending ? _attach : null,
                  ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focus,
                    enabled: widget.enabled && !_sending,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: theme.textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusXL),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacingL,
                        vertical: DesignTokens.spacingM,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingXS),
                _SendButton(
                  enabled: widget.enabled && !_sending && _canSend,
                  sending: _sending,
                  onTap: _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Where the attach button's sheet takes a file from.
enum _Source { camera, gallery, file }

/// A file picked in the composer: uploading until it has an id.
class _PickedFile {
  _PickedFile(this.file) : isImage = isImageFile(file.name);

  final XFile file;
  final bool isImage;
  int? uploadId;
}

/// A picked file above the input: the image itself, or the file's name,
/// dimmed with a spinner while it uploads, with a button to drop it.
class _PickedFileTile extends StatelessWidget {
  const _PickedFileTile({required this.file, required this.onRemove});

  final _PickedFile file;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final uploading = file.uploadId == null;
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              child: file.isImage
                  ? Image.file(
                      File(file.file.path),
                      fit: BoxFit.cover,
                      cacheWidth: 192,
                      errorBuilder: (_, __, ___) =>
                          _FileName(name: file.file.name),
                    )
                  : _FileName(name: file.file.name),
            ),
          ),
          if (uploading)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          if (onRemove != null)
            Positioned(
              top: 2,
              right: 2,
              child: Tooltip(
                message: AppLocalizations.of(context)!.chatRemoveUpload,
                child: Material(
                  color: colorScheme.inverseSurface.withValues(alpha: 0.8),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onRemove,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(Icons.close,
                          size: 14, color: colorScheme.onInverseSurface),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FileName extends StatelessWidget {
  const _FileName({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingXS),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file_outlined,
                size: 20, color: theme.colorScheme.onSurfaceVariant),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.enabled,
    required this.sending,
    required this.onTap,
  });

  final bool enabled;
  final bool sending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bg =
        enabled ? colorScheme.primary : colorScheme.surfaceContainerHighest;
    final fg = enabled ? colorScheme.onPrimary : colorScheme.onSurfaceVariant;

    return Material(
      color: bg,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: sending
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                  )
                : Icon(Icons.send_rounded, size: 20, color: fg),
          ),
        ),
      ),
    );
  }
}
