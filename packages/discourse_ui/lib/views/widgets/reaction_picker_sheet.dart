import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post_reaction.dart';

import '../../utils/like_cooldown.dart';
import '../../theme/design_tokens.dart';
import 'reaction_glyph.dart';

/// Bottom-sheet picker for the `discourse-reactions` plugin. Loads the
/// forum's enabled emoji set from `/discourse-reactions/custom-reactions`
/// and lets the user toggle one on a post.
///
/// Use [show] to open it as a modal sheet; the result is the post's new
/// reaction list, or null if the user cancelled or the toggle failed.
class ReactionPickerSheet extends StatefulWidget {
  final String postId;
  final String? currentReactionId;

  /// Resolves custom-emoji images in [ReactionGlyph]. Optional so callers
  /// without a context still get unicode reactions.
  final SiteContext? siteContext;

  const ReactionPickerSheet({
    super.key,
    required this.postId,
    this.currentReactionId,
    this.siteContext,
  });

  static Future<List<FCPostReaction>?> show({
    required BuildContext context,
    required String postId,
    String? currentReactionId,
    SiteContext? siteContext,
  }) {
    return showModalBottomSheet<List<FCPostReaction>>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return ReactionPickerSheet(
          siteContext: siteContext,
          postId: postId,
          currentReactionId: currentReactionId,
        );
      },
    );
  }

  @override
  State<ReactionPickerSheet> createState() => _ReactionPickerSheetState();
}

class _ReactionPickerSheetState extends State<ReactionPickerSheet> {
  List<String>? _available;
  bool _loading = true;
  String? _toggling;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result =
        await SiteProxyService.getPostProxy().getAvailableReactionsAsync();
    if (!mounted) return;
    setState(() {
      _available = result.reactions;
      _loading = false;
    });
  }

  String? _error;

  Future<void> _toggle(String reaction) async {
    setState(() {
      _toggling = reaction;
      _error = null;
    });
    final result = await SiteProxyService.getPostProxy()
        .toggleReactionAsync(widget.postId, reaction);
    if (!mounted) return;
    if (result.result) {
      Navigator.of(context).pop(result.reactions);
    } else {
      // The per-post budget (4 actions/minute, likes and unlikes sharing
      // the counter) is now spent through this sheet, so this is where the
      // cooldown has to be recorded — it used to be captured by the chips
      // row, which no longer exists.
      final cooldown = widget.siteContext == null
          ? null
          : LikeCooldown.noteFromLastResponse(
              widget.siteContext!, widget.postId);
      // Inline, not a snackbar: this sheet covers the bottom of the
      // screen, so a snackbar raised from here paints behind it and the
      // user sees the sheet simply not respond.
      setState(() {
        _toggling = null;
        _error = cooldown != null
            ? 'You can react to this post again in '
                '${LikeCooldown.secondsLeft(widget.postId)}s'
            : (result.resultText?.isNotEmpty == true
                ? result.resultText!
                : 'Could not update reaction.');
      });
    }
  }

  /// Convert a Discourse reaction shortcode (e.g. "heart", "+1") to its
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final available = _available;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: DesignTokens.spacingM,
            horizontal: DesignTokens.spacingS),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.spacingM,
                DesignTokens.spacingS,
                DesignTokens.spacingM,
                DesignTokens.spacingS,
              ),
              child: Text(
                'React',
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: DesignTokens.spacingS),
            if (_loading && available == null)
              const Padding(
                padding: EdgeInsets.all(DesignTokens.spacingL),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (available == null || available.isEmpty)
              Padding(
                padding: const EdgeInsets.all(DesignTokens.spacingL),
                child: Text(
                  'Reactions are not enabled on this forum.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingM,
                  vertical: DesignTokens.spacingS,
                ),
                child: Wrap(
                  spacing: DesignTokens.spacingS,
                  runSpacing: DesignTokens.spacingS,
                  children: [
                    for (final r in available)
                      _ReactionTile(
                        reaction: r,
                        siteContext: widget.siteContext,
                        selected: r == widget.currentReactionId,
                        busy: _toggling == r,
                        onTap: _toggling == null ? () => _toggle(r) : null,
                      ),
                  ],
                ),
              ),
            if (_error != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingM,
                  vertical: DesignTokens.spacingS,
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        size: DesignTokens.iconSizeS,
                        color: colorScheme.error),
                    const SizedBox(width: DesignTokens.spacingS),
                    Expanded(
                      child: Text(
                        _error!,
                        style: textTheme.bodySmall
                            ?.copyWith(color: colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: DesignTokens.spacingS),
          ],
        ),
      ),
    );
  }
}

class _ReactionTile extends StatelessWidget {
  final String reaction;
  final SiteContext? siteContext;
  final bool selected;
  final bool busy;
  final VoidCallback? onTap;

  const _ReactionTile({
    required this.reaction,
    required this.siteContext,
    required this.selected,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: DesignTokens.opacityMediumLow),
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: busy
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              )
            : ReactionGlyph(
                reactionId: reaction,
                size: 26,
                siteContext: siteContext,
              ),
      ),
    );
  }
}
