import 'package:discourse_core/discourse_core.dart' show DiscourseValidReactions;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post_reaction.dart';

import '../../theme/design_tokens.dart';
import '../../utils/post_reactions.dart';
import 'reaction_glyph.dart';
import 'sheet_title.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:discourse_ui/utils/app_navigation.dart';

/// Bottom-sheet picker for the `discourse-reactions` plugin: the forum's
/// enabled reactions, the main one (the like) first.
///
/// Each emoji shows how many people used it on this post, so matching a
/// popular reaction is one tap; the reader's own is marked and the note
/// says that tapping it again removes it. Once Discourse no longer lets the
/// reader change their reaction (its undo window), every choice is disabled
/// and the note says so, rather than offering choices the server refuses.
///
/// The sheet only chooses: [show] returns the chosen reaction id (the
/// reader's own to remove it), or null when dismissed. The caller applies
/// it, drawing the change at once.
class ReactionPickerSheet extends StatefulWidget {
  /// The post's reactions, for the counts and the reader's own.
  final List<FCPostReaction> reactions;

  /// Whether the reader's reaction can no longer be changed.
  final bool locked;

  /// The forum: its reaction set and custom-emoji images.
  final SiteContext? siteContext;

  const ReactionPickerSheet({
    super.key,
    this.reactions = const [],
    this.locked = false,
    this.siteContext,
  });

  static Future<String?> show({
    required BuildContext context,
    List<FCPostReaction> reactions = const [],
    bool locked = false,
    SiteContext? siteContext,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => ReactionPickerSheet(
        siteContext: siteContext,
        reactions: reactions,
        locked: locked,
      ),
    );
  }

  @override
  State<ReactionPickerSheet> createState() => _ReactionPickerSheetState();
}

class _ReactionPickerSheetState extends State<ReactionPickerSheet> {
  List<String>? _available;

  @override
  void initState() {
    super.initState();
    // The forum's set is usually known from the topic that is open, so the
    // sheet opens with its choices, without a spinner.
    final site = widget.siteContext;
    _available = site == null ? null : DiscourseValidReactions.forSite(site.site.url);
    if (_available == null) _load();
  }

  Future<void> _load() async {
    final result = await SiteProxyService.getPostProxy().getAvailableReactionsAsync();
    if (!mounted) return;
    setState(() => _available = result.reactions);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mine = viewerReactionOf(widget.reactions);
    final counts = {for (final r in widget.reactions) r.id: r.count};
    final available = _available;
    // The reader's reaction stays removable even if the forum has since
    // stopped offering it.
    final choices = available == null
        ? null
        : [...available, if (mine != null && !available.contains(mine.id)) mine.id];
    final note = widget.locked
        ? l10n.reactionLockedMessage
        : (mine != null ? l10n.reactionTapAgainToRemove : null);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: DesignTokens.spacingM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetTitle(l10n.react),
            if (note != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DesignTokens.spacingL, 0, DesignTokens.spacingL, DesignTokens.spacingS),
                child: Text(
                  note,
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
            if (choices == null)
              const Padding(
                padding: EdgeInsets.all(DesignTokens.spacingL),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (choices.isEmpty)
              Padding(
                padding: const EdgeInsets.all(DesignTokens.spacingL),
                child: Text(
                  l10n.reactionsAreNotEnabledOnThisForum,
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingL,
                  vertical: DesignTokens.spacingS,
                ),
                child: Wrap(
                  spacing: DesignTokens.spacingM,
                  runSpacing: DesignTokens.spacingM,
                  children: [
                    for (final r in choices)
                      _ReactionTile(
                        reaction: r,
                        count: counts[r] ?? 0,
                        siteContext: widget.siteContext,
                        selected: r == mine?.id,
                        onTap: widget.locked ? null : () => context.popOwnRoute(r),
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
  final int count;
  final SiteContext? siteContext;
  final bool selected;
  final VoidCallback? onTap;

  const _ReactionTile({
    required this.reaction,
    required this.count,
    required this.siteContext,
    required this.selected,
    required this.onTap,
  });

  static const double size = 56;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final name = reactionDisplayName(reaction);
    final tile = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? colorScheme.primary
              : colorScheme.outlineVariant.withValues(alpha: DesignTokens.opacityMediumLow),
          width: selected ? 2 : 0.5,
        ),
      ),
      child: ReactionGlyph(reactionId: reaction, size: 26, siteContext: siteContext),
    );
    return Semantics(
      label: count > 0 ? l10n.reactionFilterSemantics(name, count) : name,
      button: true,
      selected: selected,
      enabled: onTap != null,
      excludeSemantics: true,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size + 8,
            height: size + 8,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                tile,
                if (count > 0)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 22),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: selected ? colorScheme.primary : colorScheme.surface,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Text(
                        '$count',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: selected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
