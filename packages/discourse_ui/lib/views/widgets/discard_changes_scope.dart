import 'package:flutter/widgets.dart';
import 'package:forum_kit/views/widgets/discard_changes_scope.dart' as kit;

import '../../utils/error_message.dart';

/// forum_kit's [kit.DiscardChangesScope], with a failed save or discard worded
/// by [describeError], which turns Discourse's API errors into plain language.
class DiscardChangesScope extends StatelessWidget {
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

  final Listenable listenable;
  final bool Function() hasChanges;
  final bool isEdit;
  final bool busy;
  final Future<void> Function()? onSaveDraft;
  final Future<void> Function()? onDiscard;
  final Widget child;

  @override
  Widget build(BuildContext context) => kit.DiscardChangesScope(
        listenable: listenable,
        hasChanges: hasChanges,
        isEdit: isEdit,
        busy: busy,
        onSaveDraft: onSaveDraft,
        onDiscard: onDiscard,
        describeFailure: (error, context) => describeError(error, context: context),
        child: child,
      );
}
