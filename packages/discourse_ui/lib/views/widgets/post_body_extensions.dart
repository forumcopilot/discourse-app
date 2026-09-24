import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;

import '../../theme/design_tokens.dart';

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
            borderRadius: BorderRadius.circular(size * 0.6),
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

/// `<details>` as discourse-details draws it: ▶ and the summary on a light
/// background, ▼ and the contents below once opened. flutter_html used a
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
        child: DetailsBlock(
          summary: summarySpan,
          content: rest,
          initiallyOpen: context.attributes.containsKey('open'),
          boxed: context.classes.contains('details__boxed'),
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
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacingS),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            expanded: _open,
            child: InkWell(
              onTap: () => setState(() => _open = !_open),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6, top: 2),
                      child: Text(_open ? '▼' : '▶',
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                    ),
                    Expanded(
                      child: summary == null
                          ? const SizedBox.shrink()
                          : DefaultTextStyle.merge(
                              style: TextStyle(
                                  fontWeight: widget.boxed ? FontWeight.bold : null),
                              child: Text.rich(TextSpan(children: [summary])),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_open && widget.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
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
        child: ImageGrid(
          items: items,
          carousel: context.attributes['data-mode'] == 'carousel',
          onImageTap: onImageTap,
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

  static const double gap = 6;

  Widget _tile(BuildContext context, GridImage item, {double? height}) {
    final picture = ClipRRect(
      borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
      child: Image.network(
        item.src,
        fit: BoxFit.cover,
        height: height,
        errorBuilder: (c, _, __) => ColoredBox(
          color: Theme.of(c).colorScheme.surfaceContainerHighest,
          child: const SizedBox.expand(),
        ),
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
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
        child: SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: gap),
            itemBuilder: (c, i) => _tile(c, items[i], height: 240),
          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
      child: Row(
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
      ),
    );
  }
}
