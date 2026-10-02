
import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_message.dart';
import '../../widgets/emoji_picker_sheet.dart';
import '../../widgets/upload_tile.dart';
import '../../widgets/user_avatar.dart';
import '../../../utils/emoji_shortcodes.dart';

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
///
/// As Discourse's: a banner while replying or editing ([replyTo],
/// [editing], cancelled by [onCancelContext]); an emoji button; suggestions
/// for `@` people and `#` channels, categories and tags ([suggest]); the
/// draft the channel was left with ([initialText]) and every change
/// reported ([onTextChanged]) so it can be kept and others see "typing".
class ChatSuggestion {
  const ChatSuggestion({required this.insert, required this.title, this.subtitle, this.avatarUrl, this.icon});

  /// What replaces the `@…` or `#…` being typed (without the trailing space).
  final String insert;
  final String title;
  final String? subtitle;
  final String? avatarUrl;
  final IconData? icon;
}

class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.onSend,
    this.onUpload,
    this.enabled = true,
    this.hintText,
    this.replyTo,
    this.editing,
    this.onCancelContext,
    this.initialText,
    this.onTextChanged,
    this.suggest,
  });

  /// The message being replied to, shown in a banner.
  final FCChatMessage? replyTo;

  /// The reader's message being edited: its text fills the field.
  final FCChatMessage? editing;
  final VoidCallback? onCancelContext;

  /// Text to start with (the channel's draft).
  final String? initialText;
  final ValueChanged<String>? onTextChanged;

  /// Suggestions for [trigger] (`@` or `#`) and what follows it.
  final Future<List<ChatSuggestion>> Function(String trigger, String term)? suggest;

  /// Sends [text] with the ids of the files uploaded for it.
  final Future<bool> Function(String text, List<int> uploadIds) onSend;

  /// Uploads one picked file; returns its upload id, or null when it was not
  /// uploaded (the caller says why). [alreadyAttached] counts the files
  /// already in the composer. Null hides the attach button: the forum does
  /// not allow files in chat, or nothing can be sent here.
  final Future<int?> Function(XFile file, int alreadyAttached)? onUpload;

  final bool enabled;

  /// The field's placeholder; a generic "Type a message…" when null.
  final String? hintText;

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

  List<ChatSuggestion> _suggestions = const [];
  Timer? _suggestTimer;
  String _lastText = '';

  /// The `@` or `#` word being typed before the cursor.
  static final RegExp _token = RegExp(r'(^|\s)([@#])([\w.\-]*)$');

  @override
  void initState() {
    super.initState();
    final initial = widget.editing?.message ?? widget.initialText;
    if (initial != null && initial.isNotEmpty) {
      _controller.text = initial;
      _hasText = initial.trim().isNotEmpty;
    }
    _lastText = _controller.text;
    _controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant ChatComposer old) {
    super.didUpdateWidget(old);
    final editing = widget.editing;
    if (editing != null && editing.id != old.editing?.id) {
      _controller.text = editing.message;
      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
      _focus.requestFocus();
    } else if (editing == null && old.editing != null) {
      _controller.clear();
    }
    if (widget.replyTo != null && widget.replyTo?.id != old.replyTo?.id) _focus.requestFocus();
  }

  void _onChanged() {
    final text = _controller.text;
    final has = text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
    if (text == _lastText) return;
    _lastText = text;
    widget.onTextChanged?.call(text);
    _scheduleSuggestions();
  }

  void _scheduleSuggestions() {
    _suggestTimer?.cancel();
    final suggest = widget.suggest;
    final sel = _controller.selection;
    if (suggest == null || !sel.isValid || !sel.isCollapsed) return _clearSuggestions();
    final before = _controller.text.substring(0, sel.baseOffset);
    final m = _token.firstMatch(before);
    if (m == null) return _clearSuggestions();
    final trigger = m.group(2)!;
    final term = m.group(3)!;
    _suggestTimer = Timer(const Duration(milliseconds: 200), () async {
      final found = await suggest(trigger, term);
      if (!mounted) return;
      setState(() => _suggestions = found.take(5).toList());
    });
  }

  void _clearSuggestions() {
    if (_suggestions.isNotEmpty) setState(() => _suggestions = const []);
  }

  void _applySuggestion(ChatSuggestion s) {
    final sel = _controller.selection;
    final text = _controller.text;
    final before = text.substring(0, sel.baseOffset);
    final m = _token.firstMatch(before);
    if (m == null) return;
    final start = m.start + m.group(1)!.length;
    final replaced = '${text.substring(0, start)}${s.insert} ';
    _controller.value = TextEditingValue(
      text: replaced + text.substring(sel.baseOffset),
      selection: TextSelection.collapsed(offset: replaced.length),
    );
    setState(() => _suggestions = const []);
  }

  Future<void> _pickEmoji() async {
    final name = await showEmojiPickerSheet(context);
    if (name == null || !mounted) return;
    final insert = discourseEmojiChar(name) ?? ':$name:';
    final sel = _controller.selection;
    final text = _controller.text;
    final at = sel.isValid ? sel.baseOffset : text.length;
    final next = text.substring(0, at) + insert + text.substring(sel.isValid ? sel.extentOffset : text.length);
    _controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: at + insert.length),
    );
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _suggestTimer?.cancel();
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

  Widget _buildContextBanner(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final editing = widget.editing;
    final reply = widget.replyTo;
    final label = editing != null ? l10n.chatEditingMessage : l10n.chatReplyingTo(reply!.authorUsername);
    final excerpt = editing != null ? null : (reply!.excerpt ?? reply.message);
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacingS),
      child: Row(
        children: [
          Icon(editing != null ? Icons.edit_outlined : Icons.reply, size: 18, color: colorScheme.primary),
          const SizedBox(width: DesignTokens.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: textTheme.labelLarge?.copyWith(color: colorScheme.primary)),
                if (excerpt != null && excerpt.trim().isNotEmpty)
                  Text(excerpt.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            tooltip: l10n.cancel,
            onPressed: widget.onCancelContext,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacingS),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final s in _suggestions)
            ListTile(
              dense: true,
              leading: s.icon != null
                  ? Icon(s.icon)
                  : UserAvatar(username: s.title, iconUrl: s.avatarUrl, radius: 14),
              title: Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: s.subtitle == null || s.subtitle!.isEmpty
                  ? null
                  : Text(s.subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () => _applySuggestion(s),
            ),
        ],
      ),
    );
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
            if (_suggestions.isNotEmpty) _buildSuggestions(context),
            if (widget.replyTo != null || widget.editing != null) _buildContextBanner(context),
            if (_files.isNotEmpty)
              // The post composer's tiles: a thumbnail or the file's kind,
              // and a remove badge with a 48dp target (it was 28).
              SizedBox(
                height: UploadTile.extent + DesignTokens.spacingS,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(bottom: DesignTokens.spacingS),
                  itemCount: _files.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 2),
                  itemBuilder: (_, i) => UploadTile(
                    key: ObjectKey(_files[i]),
                    fileName: _files[i].file.name,
                    path: _files[i].file.path,
                    uploading: _files[i].uploadId == null,
                    removeTooltip:
                        AppLocalizations.of(context)!.chatRemoveUpload,
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
                    // 16sp like every other composer (it was 14).
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      suffixIcon: widget.enabled
                          ? IconButton(
                              icon: const Icon(Icons.emoji_emotions_outlined),
                              tooltip: AppLocalizations.of(context)!.chooseEmoji,
                              onPressed: _sending ? null : _pickEmoji,
                            )
                          : null,
                      hintText: widget.hintText ??
                          AppLocalizations.of(context)!.chatComposerDefaultHint,
                      hintStyle: theme.textTheme.bodyLarge
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
        // The chat's most-used control: a full 48dp (it was 44).
        child: SizedBox(
          width: kMinInteractiveDimension,
          height: kMinInteractiveDimension,
          child: Center(
            child: sending
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                  )
                : Icon(Icons.send_rounded, color: fg),
          ),
        ),
      ),
    );
  }
}
