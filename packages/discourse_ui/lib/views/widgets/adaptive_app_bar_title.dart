import 'package:flutter/material.dart';

/// A top app bar title for names that are often long (topics, categories).
///
/// One line of the app bar's own `titleLarge` while it fits; otherwise two
/// lines of `titleMedium`, or one when two would not fit the toolbar at the
/// reader's text size. Measured against the width the title slot really
/// has, with the reader's text scale — the bars that used to do this by
/// hand subtracted room the slot had already given to the back button and
/// actions, and measured at 1.0x whatever the setting.
class AdaptiveAppBarTitle extends StatelessWidget {
  const AdaptiveAppBarTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: title, style: textTheme.titleLarge),
          textDirection: Directionality.of(context),
          textScaler: scaler,
          maxLines: 1,
        )..layout(maxWidth: constraints.maxWidth);
        final fitsOneLine = !painter.didExceedMaxLines;
        painter.dispose();
        if (fitsOneLine) {
          return Text(title, maxLines: 1, overflow: TextOverflow.ellipsis);
        }

        final small = textTheme.titleMedium;
        final lineHeight =
            scaler.scale(small?.fontSize ?? 16) * (small?.height ?? 1.5);
        final room = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : kToolbarHeight;
        return Text(
          title,
          style: small,
          maxLines: lineHeight * 2 <= room ? 2 : 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
