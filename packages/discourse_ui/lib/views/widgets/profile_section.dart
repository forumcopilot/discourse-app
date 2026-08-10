import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

/// The band that breaks one profile section off the last.
///
/// The profile is one long scroll of unrelated blocks — stats, top replies,
/// top topics, people, links, the activity feed — and it had nothing but
/// whitespace between them. Whitespace is enough when the blocks look
/// different from each other; here every block is left-aligned text on the
/// same surface, so in dark mode especially the boundary between "the last
/// row of Top Replies" and "the first row of Top Topics" was invisible.
///
/// A tinted band reads in both themes, unlike a hairline rule: it is a
/// change of surface rather than a change of contrast, so it survives the
/// low contrast ratios that dark themes are built on.
class ProfileSectionBreak extends StatelessWidget {
  const ProfileSectionBreak({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: DesignTokens.spacingS,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        border: Border.symmetric(
          horizontal: BorderSide(
            color: colorScheme.outlineVariant
                .withValues(alpha: DesignTokens.opacityDivider),
            width: DesignTokens.borderWidthThin,
          ),
        ),
      ),
    );
  }
}

/// One block of the profile page: a break, a heading, then content.
///
/// Exists because the page had grown four different answers to "what does a
/// section look like" — `titleLarge` full-bleed lists, `titleMedium` inset
/// lists, uppercase micro-labels inside a card, and a bare heading over the
/// activity chips. Same page, same kind of content, four chromes.
///
/// [contentPadding] is null for full-bleed children — lists whose rows are
/// tappable to the screen edge — and set for children that should sit in
/// the text column.
class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    required this.title,
    required this.child,
    this.contentPadding,
  });

  final String title;
  final Widget child;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionBreak(),
        Padding(
          padding: EdgeInsets.fromLTRB(
            DesignTokens.spacingL,
            DesignTokens.spacingL,
            DesignTokens.spacingL,
            DesignTokens.spacingS,
          ),
          child: Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: DesignTokens.fontWeightBold,
            ),
          ),
        ),
        if (contentPadding == null)
          child
        else
          Padding(padding: contentPadding!, child: child),
        SizedBox(height: DesignTokens.spacingS),
      ],
    );
  }
}

/// The hairline between rows *within* a section. Indented past the text
/// column so it reads as "next item", not "next section" — that job
/// belongs to [ProfileSectionBreak].
class ProfileRowDivider extends StatelessWidget {
  const ProfileRowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Divider(
      height: DesignTokens.borderWidthThin,
      thickness: DesignTokens.borderWidthThin,
      indent: DesignTokens.spacingL,
      endIndent: DesignTokens.spacingL,
      color: colorScheme.outlineVariant
          .withValues(alpha: DesignTokens.opacityDivider),
    );
  }
}
