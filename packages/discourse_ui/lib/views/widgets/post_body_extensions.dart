import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;

import '../../theme/design_tokens.dart';
import 'broken_image_widget.dart';

/// The one gap between consecutive blocks of a post body — paragraphs,
/// lists, quotes, code, tables, previews, polls, images, details. Blocks
/// take it below themselves and nothing above, so any two blocks are this
/// far apart whatever they are.
const double kPostBlockGap = DesignTokens.spacingM;

/// [child], a block drawn by an extension, with the bottom margin its
/// element was left with once flutter_html collapsed margins: the block gap
/// before the next block, none when the block ends its post, quote or
/// paragraph (whose own margin then applies once).
///
/// flutter_html only draws the margins of the boxes it builds itself, so an
/// extension's widget has to draw its own.
Widget withBlockGap(ExtensionContext context, Widget child) {
  final gap = context.styledElement?.style.margin?.bottom?.value ?? 0;
  if (gap <= 0) return child;
  return Padding(padding: EdgeInsets.only(bottom: gap), child: child);
}

/// Keeps the block gap *between* blocks: the first block in a post body,
/// quote, details, event or table cell starts flush with its box and the
/// last one ends flush, all the way down (a list's last item, a quote's
/// last paragraph). Otherwise flutter_html collapsed the last paragraph's
/// 12dp into the body and every post, message and preview ended in a blank
/// band, and quotes sat 8dp from their top edge but 20dp from the bottom.
class PostBlockRhythmExtension extends HtmlExtension {
  const PostBlockRhythmExtension();

  @override
  Set<String> get supportedTags => const {};

  @override
  bool matches(ExtensionContext context) {
    // Only trims margins; the element is prepared and built as usual.
    if (context.currentStep != CurrentStep.preProcessing) return false;
    switch (context.elementName) {
      case 'body':
      case 'blockquote':
      case 'details':
      case 'td':
      case 'th':
        return true;
      case 'aside':
        return context.classes.contains('quote');
      case 'div':
        return context.classes.contains('discourse-post-event');
    }
    return false;
  }

  @override
  void beforeProcessing(ExtensionContext context) {
    final element = context.styledElement;
    if (element == null) return;
    for (var e = _edge(element, last: false); e != null; e = _edge(e, last: false)) {
      e.style.margin = (e.style.margin ?? const Margins()).copyWith(top: Margin.zero());
      if ((e.style.padding?.top?.value ?? 0) > 0) break;
    }
    for (var e = _edge(element, last: true); e != null; e = _edge(e, last: true)) {
      e.style.margin = (e.style.margin ?? const Margins()).copyWith(bottom: Margin.zero());
      if ((e.style.padding?.bottom?.value ?? 0) > 0) break;
    }
  }

  /// The first (or last) child that can carry a block margin, skipping the
  /// whitespace between blocks and hidden elements; null when text is at
  /// the edge.
  static StyledElement? _edge(StyledElement parent, {required bool last}) {
    for (final c in last ? parent.children.reversed : parent.children) {
      if (c is TextContentElement) {
        if ((c.text ?? '').trim().isEmpty) continue;
        return null;
      }
      if (c is EmptyContentElement || c.style.display == Display.none) continue;
      return c;
    }
    return null;
  }
}

/// The one container every card-like block in a post uses — link previews,
/// embeds, tweets, polls, events, details, file rows: radius 12, padding 12,
/// a 1dp outlineVariant border on surfaceContainerLow. With [onTap] the
/// whole card is the target, its ripple clipped to the card.
class EmbeddedCard extends StatelessWidget {
  const EmbeddedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(DesignTokens.spacingM),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  static const double radius = DesignTokens.radiusM;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = Padding(padding: padding, child: child);
    return Material(
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: DesignTokens.borderWidthThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}

/// One row for a file or an embedded page — a cooked attachment, an
/// upload, a Spotify track: a 48dp leading tile, the name over its details,
/// and any actions, 12 apart inside 12 of padding.
class FileRow extends StatelessWidget {
  const FileRow({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing = const [],
    this.padding = const EdgeInsets.all(DesignTokens.spacingM),
  });

  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final List<Widget> trailing;
  final EdgeInsetsGeometry padding;

  /// The name: a card title.
  static TextStyle? titleStyle(BuildContext context) => Theme.of(context)
      .textTheme
      .titleMedium
      ?.copyWith(color: Theme.of(context).colorScheme.onSurface);

  /// The type, size or site under the name.
  static TextStyle? subtitleStyle(BuildContext context) => Theme.of(context)
      .textTheme
      .bodySmall
      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          SizedBox(width: 48, height: 48, child: leading),
          const SizedBox(width: DesignTokens.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle.merge(style: titleStyle(context), child: title),
                if (subtitle != null) ...[
                  const SizedBox(height: DesignTokens.spacingXS / 2),
                  DefaultTextStyle.merge(style: subtitleStyle(context), child: subtitle!),
                ],
              ],
            ),
          ),
          ...trailing,
        ],
      ),
    );
  }
}

/// `aside.quote` and a plain `blockquote`: flutter_html draws the box from
/// the style sheet (its padding, fill and accent bar); this rounds it and
/// draws its bottom margin outside the rounded box, where CSS puts it.
class QuoteExtension extends HtmlExtension {
  const QuoteExtension();

  @override
  Set<String> get supportedTags => const {};

  @override
  bool matches(ExtensionContext context) {
    if (context.currentStep != CurrentStep.preparing &&
        context.currentStep != CurrentStep.building) {
      return false;
    }
    switch (context.elementName) {
      case 'aside':
        return context.classes.contains('quote');
      case 'blockquote':
        // A quote's own blockquote is drawn by the quote (see the
        // `aside.quote blockquote` style).
        for (var p = context.node.parent; p != null; p = p.parent) {
          if (p.localName == 'aside' && p.classes.contains('quote')) {
            return false;
          }
        }
        return true;
    }
    return false;
  }

  @override
  StyledElement prepare(ExtensionContext context, List<StyledElement> children) =>
      context.parser.prepareFromExtension(context, children, extensionsToIgnore: {this});

  @override
  InlineSpan build(ExtensionContext context) {
    final style = context.style ?? Style();
    return WidgetSpan(
      child: withBlockGap(
        context,
        ClipRRect(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          child: CssBoxWidget.withInlineSpanChildren(
            style: style.copyWith(margin: Margins.zero),
            shrinkWrap: context.parser.shrinkWrap,
            children: context.inlineSpanChildren ?? [],
          ),
        ),
      ),
    );
  }
}

/// `a.mention` / `a.mention-group` as the web's pill: a rounded tag in the
/// text colour on a light background, slightly smaller than the text.
/// flutter_html drew them as bold link-coloured text.
class MentionExtension extends HtmlExtension {
  const MentionExtension({required this.onTap});

  /// Called with the mention's href and whether it names a group.
  final void Function(String href, bool isGroup) onTap;

  @override
  Set<String> get supportedTags => const {};

  @override
  bool matches(ExtensionContext context) =>
      context.elementName == 'a' &&
      (context.classes.contains('mention') || context.classes.contains('mention-group'));

  @override
  InlineSpan build(ExtensionContext context) {
    final text = (context.element?.text ?? '').trim();
    if (text.isEmpty) return TextSpan(children: context.inlineSpanChildren);
    final href = context.attributes['href'] ?? '';
    final isGroup = context.classes.contains('mention-group');
    final style = context.styledElement?.style.generateTextStyle();
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: _MentionPill(
        text: text,
        style: style,
        onTap: href.isEmpty ? null : () => onTap(href, isGroup),
      ),
    );
  }
}

class _MentionPill extends StatelessWidget {
  const _MentionPill({required this.text, this.style, this.onTap});

  final String text;
  final TextStyle? style;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = style?.fontSize ?? 16;
    return Semantics(
      link: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          padding: EdgeInsets.symmetric(horizontal: size * 0.34, vertical: size * 0.2),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
          ),
          child: Text(
            text,
            maxLines: 1,
            style: (style ?? const TextStyle()).copyWith(
              fontSize: size * 0.93,
              fontWeight: FontWeight.normal,
              color: colorScheme.onSurface,
              decoration: TextDecoration.none,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

/// `<details>` as discourse-details draws it: a disclosure arrow and the
/// summary, the contents below once opened, in a card. flutter_html used a
/// Material ExpansionTile (chevron on the right, list-tile padding).
class DetailsExtension extends HtmlExtension {
  const DetailsExtension();

  @override
  Set<String> get supportedTags => const {'details'};

  @override
  InlineSpan build(ExtensionContext context) {
    final element = context.styledElement!;
    final built = context.builtChildrenMap ?? const {};
    StyledElement? summary;
    for (final c in element.children) {
      if (c.name == 'summary') {
        summary = c;
        break;
      }
    }
    final summarySpan = summary == null ? null : built[summary];
    final rest = [
      for (final c in element.children)
        if (c != summary && built[c] != null) built[c]!,
    ];
    return WidgetSpan(
      child: SizedBox(
        width: double.infinity,
        child: withBlockGap(
          context,
          DetailsBlock(
            summary: summarySpan,
            content: rest,
            initiallyOpen: context.attributes.containsKey('open'),
            boxed: context.classes.contains('details__boxed'),
          ),
        ),
      ),
    );
  }
}

class DetailsBlock extends StatefulWidget {
  const DetailsBlock({
    super.key,
    required this.summary,
    required this.content,
    this.initiallyOpen = false,
    this.boxed = false,
  });

  final InlineSpan? summary;
  final List<InlineSpan> content;
  final bool initiallyOpen;
  final bool boxed;

  @override
  State<DetailsBlock> createState() => _DetailsBlockState();
}

class _DetailsBlockState extends State<DetailsBlock> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final summary = widget.summary;
    return EmbeddedCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            expanded: _open,
            child: InkWell(
              onTap: () => setState(() => _open = !_open),
              // A 48dp target however short the summary.
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacingM,
                    vertical: DesignTokens.spacingM,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _open ? Icons.expand_more : Icons.chevron_right,
                        size: DesignTokens.iconSizeL,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: DesignTokens.spacingS),
                      Expanded(
                        child: summary == null
                            ? const SizedBox.shrink()
                            : DefaultTextStyle.merge(
                                style: TextStyle(
                                    fontWeight: widget.boxed ? FontWeight.w500 : null),
                                child: Text.rich(TextSpan(children: [summary])),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_open && widget.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.spacingM,
                0,
                DesignTokens.spacingM,
                DesignTokens.spacingM,
              ),
              child: Text.rich(TextSpan(children: widget.content)),
            ),
        ],
      ),
    );
  }
}

/// `div.d-image-grid` (the composer's [grid] block) as the web's phone
/// layout: two masonry columns, each picture going to the shorter column,
/// or a sideways carousel for `data-mode="carousel"`. The app stacked the
/// pictures one under another at full width.
class ImageGridExtension extends HtmlExtension {
  const ImageGridExtension({required this.resolve, required this.onImageTap});

  final String Function(String url) resolve;

  /// Opens the full-size picture ([full]) in the image viewer.
  final void Function(String full, BuildContext context)? onImageTap;

  @override
  Set<String> get supportedTags => const {};

  @override
  bool matches(ExtensionContext context) =>
      context.elementName == 'div' && context.classes.contains('d-image-grid');

  @override
  InlineSpan build(ExtensionContext context) {
    final element = context.element;
    final items = element == null ? const <GridImage>[] : GridImage.collect(element, resolve);
    // One picture is not a grid; let it render as usual.
    if (items.length < 2) return TextSpan(children: context.inlineSpanChildren);
    return WidgetSpan(
      child: SizedBox(
        width: double.infinity,
        child: withBlockGap(
          context,
          ImageGrid(
            items: items,
            carousel: context.attributes['data-mode'] == 'carousel',
            onImageTap: onImageTap,
          ),
        ),
      ),
    );
  }
}

class GridImage {
  const GridImage({required this.src, required this.full, this.ratio});

  final String src;
  final String full;

  /// Width over height; 1 when the post does not say.
  final double? ratio;

  static List<GridImage> collect(dom.Element grid, String Function(String) resolve) {
    final out = <GridImage>[];
    for (final img in grid.querySelectorAll('img')) {
      if (img.classes.contains('emoji')) continue;
      final src = img.attributes['src'];
      if (src == null || src.isEmpty) continue;
      var full = src;
      var p = img.parent;
      while (p != null && p != grid) {
        if (p.localName == 'a' && p.classes.contains('lightbox')) {
          full = p.attributes['href'] ?? src;
          break;
        }
        p = p.parent;
      }
      final w = double.tryParse(img.attributes['width'] ?? '');
      final h = double.tryParse(img.attributes['height'] ?? '');
      out.add(GridImage(
        src: resolve(src),
        full: resolve(full),
        ratio: (w != null && h != null && w > 0 && h > 0) ? w / h : null,
      ));
    }
    return out;
  }
}

class ImageGrid extends StatelessWidget {
  const ImageGrid({super.key, required this.items, this.carousel = false, this.onImageTap});

  final List<GridImage> items;
  final bool carousel;
  final void Function(String full, BuildContext context)? onImageTap;

  /// The gap between pictures, here and in the upload grid under a post.
  static const double gap = DesignTokens.spacingS;

  /// The corner radius of every picture in a post.
  static const double radius = DesignTokens.radiusS;

  Widget _tile(BuildContext context, GridImage item, {double? height}) {
    final picture = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        item.src,
        fit: BoxFit.cover,
        height: height,
        errorBuilder: (c, _, __) => const BrokenImagePlaceholder(),
      ),
    );
    final framed = height != null
        ? SizedBox(height: height, width: height * (item.ratio ?? 1).clamp(0.5, 2.5), child: picture)
        : AspectRatio(aspectRatio: (item.ratio ?? 1).clamp(0.3, 3.0), child: picture);
    return GestureDetector(
      onTap: onImageTap == null ? null : () => onImageTap!(item.full, context),
      child: framed,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (carousel) {
      return SizedBox(
        height: 240,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: gap),
          itemBuilder: (c, i) => _tile(c, items[i], height: 240),
        ),
      );
    }
    // Two columns on a phone, as the web lays it out; each picture goes to
    // the shorter column so the columns end close together.
    const columns = 2;
    final lists = List.generate(columns, (_) => <GridImage>[]);
    final heights = List.filled(columns, 0.0);
    for (final item in items) {
      var shortest = 0;
      for (var j = 1; j < columns; j++) {
        if (heights[j] < heights[shortest]) shortest = j;
      }
      heights[shortest] += 1 / (item.ratio ?? 1);
      lists[shortest].add(item);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var c = 0; c < columns; c++) ...[
          if (c > 0) const SizedBox(width: gap),
          Expanded(
            child: Column(
              children: [
                for (var i = 0; i < lists[c].length; i++) ...[
                  if (i > 0) const SizedBox(height: gap),
                  _tile(context, lists[c][i]),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
