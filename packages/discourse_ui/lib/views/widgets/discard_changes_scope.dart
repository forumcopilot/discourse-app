import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../utils/error_message.dart';
import '../../utils/snackbar_helper.dart';

/// Asks before a form with unsaved changes is closed, whichever way: its ✕,
/// Back, Android's back gesture. The composers and edit forms used to close
/// on any of them without a word, and what had been typed was lost (or, in
/// a composer, kept as a draft the writer did not know about).
///
/// The question is Discourse's own (`post.cancel_composer`): "Do you want to
/// discard your post?" for new writing, "Do you want to discard your
/// changes?" for an edit, with Discard and Cancel. A form with a server
/// draft also offers Save draft, which keeps it and closes.
///
/// A form without changes closes at once, and keeps Android's predictive
/// back animation; so does one whose changes are all saved. While [busy]
/// (sending), it does not close at all.
class DiscardChangesScope extends StatefulWidget {
  const DiscardChangesScope({
    super.key,
    required this.listenable,
    required this.hasChanges,
    required this.child,
    this.isEdit = false,
    this.busy = false,
    this.onSaveDraft,
    this.onDiscard,
  });

  /// What the answer of [hasChanges] follows: the form's text controllers.
  final Listenable listenable;

  /// Whether closing now would lose something.
  final bool Function() hasChanges;

  /// An edit of something that exists, rather than new writing.
  final bool isEdit;

  /// Set while the form is sending: Back does nothing until it answers.
  final bool busy;

  /// Keeps what was written for later, before closing. Offered as Save
  /// draft only when given.
  final Future<void> Function()? onSaveDraft;

  /// Throws away what was written (a server draft, say), before closing.
  final Future<void> Function()? onDiscard;

  final Widget child;

  @override
  State<DiscardChangesScope> createState() => _DiscardChangesScopeState();
}

enum _Choice { discard, saveDraft }

class _DiscardChangesScopeState extends State<DiscardChangesScope> {
  bool _asking = false;
  bool _closing = false;

  Future<void> _ask() async {
    if (_asking || widget.busy) return;
    _asking = true;
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final choice = await showDialog<_Choice>(
      context: context,
      builder: (dialog) => AlertDialog(
        // When the three choices do not fit side by side they stack, with
        // the action at the top and Cancel at the bottom, as Material 3
        // stacks a dialog's buttons.
        actionsOverflowDirection: VerticalDirection.up,
        content: Text(widget.isEdit
            ? l10n.discardChangesQuestion
            : l10n.discardPostQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: Text(l10n.cancel),
          ),
          if (widget.onSaveDraft != null)
            TextButton(
              onPressed: () => Navigator.pop(dialog, _Choice.saveDraft),
              child: Text(l10n.saveDraft),
            ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialog, _Choice.discard),
            child: Text(widget.isEdit ? l10n.discardChanges : l10n.discard),
          ),
        ],
      ),
    );
    if (choice == null || !mounted) {
      _asking = false;
      return;
    }
    setState(() => _closing = true);
    try {
      switch (choice) {
        case _Choice.saveDraft:
          await widget.onSaveDraft?.call();
        case _Choice.discard:
          await widget.onDiscard?.call();
      }
    } catch (error) {
      if (mounted) {
        SnackbarHelper.showError(
            context, describeError(error, context: context));
      }
      return;
    } finally {
      _asking = false;
      if (mounted) setState(() => _closing = false);
    }
    if (!mounted) return;
    final route = ModalRoute.of(context);
    // Navigator.pop closes the form regardless of the scope below.
    if (route != null && route.isCurrent) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.listenable,
      builder: (context, child) => PopScope(
        canPop: !_closing && !widget.busy && !widget.hasChanges(),
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _ask();
        },
        child: AbsorbPointer(absorbing: _closing, child: child!),
      ),
      child: widget.child,
    );
  }
}
