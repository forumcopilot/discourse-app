import 'package:discourse_core/discourse_core.dart'
    show DiscoursePostProxy, DiscourseReaction;
import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';

import '../../theme/design_tokens.dart';

/// Bottom-sheet picker for the `discourse-reactions` plugin. Loads the
/// forum's enabled emoji set from `/discourse-reactions/custom-reactions`
/// and lets the user toggle one on a post.
///
/// Use [show] to open it as a modal sheet; the result is the post's new
/// reaction list, or null if the user cancelled or the toggle failed.
class ReactionPickerSheet extends StatefulWidget {
  final String postId;
  final String? currentReactionId;

  const ReactionPickerSheet({
    super.key,
    required this.postId,
    this.currentReactionId,
  });

  static Future<List<DiscourseReaction>?> show({
    required BuildContext context,
    required String postId,
    String? currentReactionId,
  }) {
    return showModalBottomSheet<List<DiscourseReaction>>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return ReactionPickerSheet(
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
    final proxy = SiteProxyFactory.getPostProxy();
    if (proxy is! DiscoursePostProxy) {
      setState(() {
        _available = const [];
        _loading = false;
      });
      return;
    }
    final reactions = await proxy.getAvailableReactionsAsync();
    if (!mounted) return;
    setState(() {
      _available = reactions;
      _loading = false;
    });
  }

  Future<void> _toggle(String reaction) async {
    final proxy = SiteProxyFactory.getPostProxy();
    if (proxy is! DiscoursePostProxy) return;
    setState(() => _toggling = reaction);
    final updated =
        await proxy.toggleReactionAsync(widget.postId, reaction);
    if (!mounted) return;
    if (updated != null) {
      Navigator.of(context).pop(updated);
    } else {
      setState(() => _toggling = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Could not update reaction. The plugin may not be installed.')),
      );
    }
  }

  /// Convert a Discourse reaction shortcode (e.g. "heart", "+1") to its
  /// Unicode glyph. Falls back to the literal shortcode (wrapped in
  /// colons) when no Unicode match exists — that signals a forum-custom
  /// emoji that the picker can't render natively.
  String _glyphFor(String shortcode) {
    final clean = shortcode.replaceAll(':', '').trim();
    final emoji = Emoji.byShortName(clean);
    if (emoji != null && emoji.char.isNotEmpty) return emoji.char;
    return ':$clean:';
  }

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
                        glyph: _glyphFor(r),
                        selected: r == widget.currentReactionId,
                        busy: _toggling == r,
                        onTap: _toggling == null ? () => _toggle(r) : null,
                      ),
                  ],
                ),
              ),
            const SizedBox(height: DesignTokens.spacingS),
          ],
        ),
      ),
    );
  }
}

class _ReactionTile extends StatelessWidget {
  final String reaction;
  final String glyph;
  final bool selected;
  final bool busy;
  final VoidCallback? onTap;

  const _ReactionTile({
    required this.reaction,
    required this.glyph,
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
              : colorScheme.surfaceContainerHighest.withOpacity(0.6),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withOpacity(0.5),
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
            : Text(glyph, style: const TextStyle(fontSize: 26)),
      ),
    );
  }
}
