import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';
import '../../utils/local_dates.dart';
import '../../utils/post_events.dart';

/// Discourse plugin markup that the web turns into something else with
/// JavaScript and CSS, drawn natively:
///
///  * `.spoiler` (spoiler-alert) — blurred until tapped; the app printed it
///    in clear;
///  * `span.discourse-local-date` — in the reader's time zone; the app
///    printed the UTC fallback meant for email;
///  * `div.discourse-post-event` (discourse-calendar) — an event card; the
///    app showed only the description, without date, time or place;
///  * `span.math` / `div.math` (discourse-math) — typeset; the app printed
///    the TeX source;
///  * `div.poll[data-poll-name]` — the post's live poll, in place, via
///    [pollBuilder]; the app drew the first post's poll above the text and
///    left the cooked option list, with a vote count frozen at cook time,
///    where the author put it.
class DiscourseBlocksExtension extends HtmlExtension {
  const DiscourseBlocksExtension({
    required this.onOpen,
    this.pollBuilder,
  });

  final void Function(String url) onOpen;

  /// The live poll named `data-poll-name`, or null to leave the cooked
  /// markup (a context with no poll data, e.g. a revision diff).
  final Widget? Function(String pollName)? pollBuilder;

  @override
  Set<String> get supportedTags => const {};

  @override
  bool matches(ExtensionContext context) {
    final c = context.classes;
    switch (context.elementName) {
      case 'span':
        return c.contains('spoiler') ||
            c.contains('spoiled') ||
            c.contains('discourse-local-date') ||
            c.contains('math');
      case 'div':
        return c.contains('spoiler') ||
            c.contains('spoiled') ||
            c.contains('discourse-post-event') ||
            c.contains('math') ||
            (c.contains('poll') && pollBuilder != null && context.attributes['data-poll-name'] != null);
    }
    return false;
  }

  @override
  InlineSpan build(ExtensionContext context) {
    final c = context.classes;
    final block = context.elementName == 'div';
    final buildContext = context.buildContext!;

    if (c.contains('discourse-local-date')) {
      return _localDate(context, buildContext);
    }
    if (c.contains('math')) {
      final style = context.styledElement?.style.generateTextStyle() ??
          DefaultTextStyle.of(buildContext).style;
      final tex = (context.element?.text ?? '').trim();
      final math = Math.tex(
        tex,
        mathStyle: block ? MathStyle.display : MathStyle.text,
        textStyle: style,
        onErrorFallback: (_) =>
            Text(tex, style: style.copyWith(fontFamily: 'monospace')),
      );
      if (!block) {
        // A formula wider than the line scrolls sideways instead of
        // overflowing it; a narrow one keeps its own width.
        return WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: math),
        );
      }
      return WidgetSpan(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
            child: math,
          ),
        ),
      );
    }
    if (c.contains('discourse-post-event')) {
      final event = PostEvent.fromAttributes(context.attributes);
      if (event == null) return TextSpan(children: context.inlineSpanChildren);
      return WidgetSpan(
        child: SizedBox(
          width: double.infinity,
          child: PostEventCard(
            event: event,
            description: context.inlineSpanChildren ?? const [],
            onOpen: onOpen,
          ),
        ),
      );
    }
    if (c.contains('poll')) {
      final poll = pollBuilder?.call(context.attributes['data-poll-name']!);
      if (poll == null) return TextSpan(children: context.inlineSpanChildren);
      return WidgetSpan(child: SizedBox(width: double.infinity, child: poll));
    }
    // Spoiler.
    final content = block
        ? CssBoxWidget.withInlineSpanChildren(
            children: context.inlineSpanChildren ?? const [],
            style: context.style ?? Style(),
          )
        : Text.rich(TextSpan(children: context.inlineSpanChildren));
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: block
          ? SizedBox(width: double.infinity, child: SpoilerBox(child: content))
          : SpoilerBox(child: content),
    );
  }

  InlineSpan _localDate(ExtensionContext context, BuildContext buildContext) {
    final l10n = AppLocalizations.of(buildContext);
    final element = context.element;
    Map<Object, String>? rangeFrom;
    if (context.attributes['data-range'] == 'to') {
      var prev = element?.previousElementSibling;
      while (prev != null && !prev.classes.contains('discourse-local-date')) {
        prev = prev.previousElementSibling;
      }
      if (prev != null && prev.attributes['data-range'] == 'from') {
        rangeFrom = prev.attributes;
      }
    }
    String? formatted;
    try {
      formatted = formatLocalDate(
        context.attributes,
        now: DateTime.now(),
        locale: Localizations.localeOf(buildContext).toString(),
        use24Hour: MediaQuery.maybeAlwaysUse24HourFormatOf(buildContext) ?? false,
        rangeFrom: rangeFrom,
        words: RelativeDayWords(
          today: (t) => l10n?.localDateToday(t) ?? 'Today $t',
          tomorrow: (t) => l10n?.localDateTomorrow(t) ?? 'Tomorrow $t',
          yesterday: (t) => l10n?.localDateYesterday(t) ?? 'Yesterday $t',
        ),
      );
    } catch (_) {
      formatted = null;
    }
    if (formatted == null) return TextSpan(children: context.inlineSpanChildren);
    final style = context.styledElement?.style.generateTextStyle();
    final size = style?.fontSize ?? 14;
    return TextSpan(
      style: style,
      children: [
        // The web marks a converted date with a globe.
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Icon(Icons.public,
                size: size, color: Theme.of(buildContext).colorScheme.onSurfaceVariant),
          ),
        ),
        TextSpan(text: formatted),
      ],
    );
  }
}

/// Blurs its child until tapped, as spoiler-alert does on the web.
class SpoilerBox extends StatefulWidget {
  const SpoilerBox({super.key, required this.child});

  final Widget child;

  @override
  State<SpoilerBox> createState() => _SpoilerBoxState();
}

class _SpoilerBoxState extends State<SpoilerBox> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    if (_revealed) return widget.child;
    return Semantics(
      button: true,
      label: AppLocalizations.of(context)?.spoiler ?? 'Spoiler',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _revealed = true),
        child: ClipRect(
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            // Links inside stay inert until the spoiler is revealed.
            child: IgnorePointer(child: widget.child),
          ),
        ),
      ),
    );
  }
}

/// A discourse-calendar event card: a date badge, the name, when it is (in
/// the reader's time zone, the next occurrence for a repeating event),
/// where, how it repeats, and the description the author wrote under it.
/// Going/interested needs the event API and is left to the web for now.
class PostEventCard extends StatelessWidget {
  const PostEventCard({
    super.key,
    required this.event,
    required this.description,
    required this.onOpen,
  });

  final PostEvent event;
  final List<InlineSpan> description;
  final void Function(String url) onOpen;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final use24 = MediaQuery.maybeAlwaysUse24HourFormatOf(context) ?? false;
    final now = DateTime.now();
    final (startUtc, endUtc) = event.occurrenceAt(now);
    final start = startUtc.toLocal();
    final end = endUtc?.toLocal();
    final expired = event.isExpired(now);
    String time(DateTime d) => (use24 ? DateFormat.Hm(locale) : DateFormat.jm(locale)).format(d);
    String day(DateTime d) => DateFormat.MMMEd(locale).format(d);
    final sameDay = end != null &&
        end.year == start.year && end.month == start.month && end.day == start.day;
    final when = StringBuffer('${day(start)}, ${time(start)}');
    if (end != null && end.isAfter(start)) {
      when.write(' → ${sameDay ? time(end) : '${day(end)}, ${time(end)}'}');
    }
    final location = event.location;
    final locationIsUrl = location != null && RegExp(r'^https?://').hasMatch(location);
    final recurrence = switch (event.recurrence) {
      'every_day' => l10n?.eventEveryDay,
      'every_weekday' => l10n?.eventEveryWeekday,
      'every_week' => l10n?.eventEveryWeek,
      'every_two_weeks' => l10n?.eventEveryTwoWeeks,
      'every_four_weeks' => l10n?.eventEveryFourWeeks,
      'every_month' => l10n?.eventEveryMonth,
      _ => null,
    };
    final muted = colorScheme.onSurfaceVariant;

    Widget row(IconData icon, Widget child) => Padding(
          padding: const EdgeInsets.only(top: DesignTokens.spacingS),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: muted),
              const SizedBox(width: DesignTokens.spacingS),
              Expanded(child: child),
            ],
          ),
        );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
      padding: const EdgeInsets.all(DesignTokens.spacingM),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusS),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The date badge: month over day, as on the web.
              Container(
                width: 48,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat.MMM(locale).format(start).toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${start.day}',
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DesignTokens.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event.name != null)
                      Text(
                        event.name!,
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (expired)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
                        ),
                        child: Text(
                          l10n?.eventExpired ?? 'Expired',
                          style: textTheme.labelSmall?.copyWith(color: muted),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          row(Icons.schedule, Text(when.toString(),
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface))),
          if (location != null)
            row(
              locationIsUrl ? Icons.link : Icons.place_outlined,
              locationIsUrl
                  ? GestureDetector(
                      onTap: () => onOpen(location),
                      child: Text(location,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary)),
                    )
                  : Text(location,
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)),
            ),
          if (recurrence != null)
            row(Icons.repeat, Text(recurrence,
                style: textTheme.bodyMedium?.copyWith(color: muted))),
          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: DesignTokens.spacingS),
              child: Text.rich(TextSpan(children: description)),
            ),
        ],
      ),
    );
  }
}
