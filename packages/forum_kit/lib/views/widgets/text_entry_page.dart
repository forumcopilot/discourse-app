import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

/// A full-screen dialog for writing a message that may run long (a reason,
/// a note to staff): the whole screen to write in above the keyboard, and
/// the action in the top bar, where the keyboard cannot cover it. A popup
/// left a few lines between the title and the keyboard on a phone.
///
/// Returns the trimmed text, or null when closed. [requiredMessage], when
/// given, keeps the action from sending an empty text and says why.
Future<String?> showTextEntryPage(
  BuildContext context, {
  required String title,
  required String actionLabel,
  String? hint,
  String? requiredMessage,
}) =>
    Navigator.of(context).push<String>(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _TextEntryPage(
        title: title,
        actionLabel: actionLabel,
        hint: hint,
        requiredMessage: requiredMessage,
      ),
    ));

class _TextEntryPage extends StatefulWidget {
  const _TextEntryPage({
    required this.title,
    required this.actionLabel,
    this.hint,
    this.requiredMessage,
  });

  final String title;
  final String actionLabel;
  final String? hint;
  final String? requiredMessage;

  @override
  State<_TextEntryPage> createState() => _TextEntryPageState();
}

class _TextEntryPageState extends State<_TextEntryPage> {
  final _controller = TextEditingController();
  bool _showError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty && widget.requiredMessage != null) {
      setState(() => _showError = true);
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: const CloseButton(),
          title: Text(widget.title),
          actions: [
            Padding(
              padding:
                  const EdgeInsetsDirectional.only(end: DesignTokens.spacingS),
              child: FilledButton(
                key: const ValueKey('text-entry-submit'),
                onPressed: _submit,
                child: Text(widget.actionLabel),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingL),
            child: TextField(
              key: const ValueKey('text-entry-field'),
              controller: _controller,
              autofocus: true,
              maxLines: null,
              minLines: 6,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {
                if (_showError) setState(() => _showError = false);
              },
              decoration: InputDecoration(
                hintText: widget.hint,
                hintMaxLines: 4,
                border: const OutlineInputBorder(),
                errorText: _showError ? widget.requiredMessage : null,
              ),
            ),
          ),
        ),
      );
}
