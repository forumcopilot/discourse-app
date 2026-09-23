import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:html/dom.dart' as dom;

/// Renders `<table>` in a post body.
///
/// flutter_html 3 has no table support: a table and all the text in it
/// simply vanished — 98% of the text the September 2026 audit found missing
/// from posts. Discourse cooks a Markdown table as `div.md-table > table`
/// with a thead and a tbody, and also allows raw HTML tables with colspan,
/// rowspan and `style="text-align:…"` on cells
/// (discourse-markdown-it/src/features/table.js).
///
/// The layout follows the web's mobile view. The table is at least as wide
/// as the post, and its columns share that width by content, as CSS
/// automatic table layout does: a column holding a sentence wraps, one
/// holding a number stays narrow. A table that cannot fit even with every
/// column fully wrapped (many columns, a long URL) scrolls sideways inside
/// its own box, like `.md-table { overflow: auto }` on the web.
///
/// Cell contents are built by flutter_html like the rest of the post, so
/// links, mentions, inline code and emoji in a cell keep working.
class PostTableExtension extends HtmlExtension {
  const PostTableExtension({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Set<String> get supportedTags => const {
        'table', 'thead', 'tbody', 'tfoot', 'tr', 'th', 'td', 'caption',
        'colgroup', 'col',
      };

  @override
  StyledElement prepare(ExtensionContext context, List<StyledElement> children) {
    switch (context.elementName) {
      case 'table':
        final rows = <_RowElement>[];
        _PartElement? caption;
        void collect(List<StyledElement> nodes, {required bool inHead}) {
          for (final node in nodes) {
            if (node is _RowElement) {
              node.inHead = inHead;
              rows.add(node);
            } else if (node is _PartElement && node.name == 'caption') {
              caption ??= node;
            } else if (node is _PartElement) {
              collect(node.children, inHead: node.name == 'thead');
            }
          }
        }
        collect(children, inHead: false);
        return _TableElement(
          node: context.node,
          elementClasses: context.classes.toList(),
          elementId: context.id,
          rows: rows,
          caption: caption,
        );
      case 'tr':
        return _RowElement(
          node: context.node,
          elementClasses: context.classes.toList(),
          elementId: context.id,
          children: children,
        );
      case 'th':
      case 'td':
        return _CellElement(
          node: context.node,
          name: context.elementName,
          elementClasses: context.classes.toList(),
          elementId: context.id,
          children: children,
        );
      default:
        return _PartElement(
          node: context.node,
          name: context.elementName,
          elementClasses: context.classes.toList(),
          elementId: context.id,
          children: children,
        );
    }
  }

  @override
  InlineSpan build(ExtensionContext context) {
    final element = context.styledElement;
    if (element is _TableElement) {
      return WidgetSpan(
        child: _PostTable(
          table: element,
          builtChildren: context.builtChildrenMap ?? const {},
          colorScheme: colorScheme,
          // A table inside a table cell is sized by the outer grid, which
          // asks its cells for intrinsic sizes; it must not scroll on its
          // own or measure the screen (a LayoutBuilder cannot answer
          // intrinsic-size queries).
          nested: _isInsideTable(context.node),
        ),
      );
    }
    if (element is _CellElement || element is _PartElement) {
      // Cells and the caption are laid out by _PostTable from these spans.
      return TextSpan(children: context.inlineSpanChildren);
    }
    return const TextSpan();
  }

  static bool _isInsideTable(dom.Node node) {
    var parent = node.parent;
    while (parent != null) {
      if (parent.localName == 'table') return true;
      parent = parent.parent;
    }
    return false;
  }
}

/// thead / tbody / tfoot / caption / colgroup / col.
class _PartElement extends StyledElement {
  _PartElement({
    required super.node,
    required super.name,
    required super.elementClasses,
    required super.elementId,
    required super.children,
  }) : super(style: Style());
}

class _RowElement extends StyledElement {
  _RowElement({
    required super.node,
    required super.elementClasses,
    required super.elementId,
    required super.children,
  }) : super(name: 'tr', style: Style());

  bool inHead = false;

  List<_CellElement> get cells => children.whereType<_CellElement>().toList();
}

class _CellElement extends StyledElement {
  _CellElement({
    required super.node,
    required super.name,
    required super.elementClasses,
    required super.elementId,
    required super.children,
  }) : super(
          // Header cells are bold, as in a browser; their text inherits it.
          style: name == 'th' ? Style(fontWeight: FontWeight.bold) : Style(),
        );

  int get colspan => _span('colspan');
  int get rowspan => _span('rowspan');

  int _span(String attribute) =>
      (int.tryParse(attributes[attribute] ?? '') ?? 1).clamp(1, 1000);
}

/// The table. Its children, for flutter_html's purposes, are its cells and
/// caption: those are what get built into spans (and styled, with the
/// cells inheriting from the table); rows and sections only shape the grid.
class _TableElement extends StyledElement {
  _TableElement({
    required super.node,
    required super.elementClasses,
    required super.elementId,
    required this.rows,
    required this.caption,
  }) : super(
          name: 'table',
          style: Style(),
          children: [
            if (caption != null) caption,
            for (final row in rows) ...row.cells,
          ],
        );

  final List<_RowElement> rows;
  final _PartElement? caption;
}

class _PostTable extends StatefulWidget {
  const _PostTable({
    required this.table,
    required this.builtChildren,
    required this.colorScheme,
    required this.nested,
  });

  final _TableElement table;
  final Map<StyledElement, InlineSpan> builtChildren;
  final ColorScheme colorScheme;
  final bool nested;

  @override
  State<_PostTable> createState() => _PostTableState();
}

class _PostTableState extends State<_PostTable> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grid = _buildGrid(context);
    if (grid == null) return const SizedBox.shrink();
    final caption = widget.table.caption;
    final captionSpan = caption == null ? null : widget.builtChildren[caption];

    Widget table;
    if (widget.nested) {
      table = grid;
    } else {
      table = LayoutBuilder(
        builder: (context, constraints) {
          if (!constraints.hasBoundedWidth) return grid;
          return Scrollbar(
            controller: _scroll,
            // Visible only when the table is wider than the post, so a
            // reader can tell there is more to the side.
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 6),
              child: _AtLeastMinContentWidth(
                minWidth: constraints.maxWidth,
                child: grid,
              ),
            ),
          );
        },
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.nested ? 0 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (captionSpan != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text.rich(
                TextSpan(children: [captionSpan]),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          table,
        ],
      ),
    );
  }

  Widget? _buildGrid(BuildContext context) {
    final rows = widget.table.rows;
    if (rows.isEmpty) return null;
    final direction = Directionality.of(context);

    // Place cells the way a browser does: each takes the next free column
    // in its row, skipping slots still covered by a rowspan from above.
    final occupied = <int, Set<int>>{}; // row -> taken columns
    final placements = <GridPlacement>[];
    var columnCount = 0;
    final hasHead = rows.any((r) => r.inHead);

    for (var r = 0; r < rows.length; r++) {
      final row = rows[r];
      final isHeader =
          row.inHead || (!hasHead && r == 0 && row.cells.isNotEmpty && row.cells.every((c) => c.name == 'th'));
      var column = 0;
      for (final cell in row.cells) {
        final taken = occupied[r] ?? const <int>{};
        while (taken.contains(column)) {
          column++;
        }
        final colspan = cell.colspan;
        final rowspan = math.min(cell.rowspan, rows.length - r);
        for (var dr = 0; dr < rowspan; dr++) {
          final set = occupied.putIfAbsent(r + dr, () => <int>{});
          for (var dc = 0; dc < colspan; dc++) {
            set.add(column + dc);
          }
        }
        placements.add(GridPlacement(
          columnStart: column,
          columnSpan: colspan,
          rowStart: r,
          rowSpan: rowspan,
          child: _cell(cell, isHeader: isHeader, direction: direction),
        ));
        column += colspan;
        columnCount = math.max(columnCount, column);
      }
    }
    for (final taken in occupied.values) {
      if (taken.isNotEmpty) columnCount = math.max(columnCount, taken.reduce(math.max) + 1);
    }
    if (columnCount == 0) return null;

    return LayoutGrid(
      columnSizes: List.filled(columnCount, const IntrinsicContentTrackSize()),
      rowSizes: List.filled(rows.length, const IntrinsicContentTrackSize()),
      children: placements,
    );
  }

  Widget _cell(_CellElement cell,
      {required bool isHeader, required TextDirection direction}) {
    final span = widget.builtChildren[cell];
    final align = cell.style.textAlign ??
        // Discourse's stylesheet left-aligns thead cells; any other th is
        // centred, as browsers do.
        (cell.name == 'th' && !isHeader ? TextAlign.center : TextAlign.start);
    final horizontal = switch (align) {
      TextAlign.center => 0.0,
      TextAlign.right => 1.0,
      TextAlign.left => -1.0,
      TextAlign.end => direction == TextDirection.rtl ? -1.0 : 1.0,
      _ => direction == TextDirection.rtl ? 1.0 : -1.0,
    };
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: widget.colorScheme.outlineVariant,
              // The web sets the header off with a heavier rule.
              width: isHeader ? 2 : 1,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Align(
            alignment: Alignment(horizontal, 0),
            widthFactor: 1,
            heightFactor: 1,
            child: span == null
                ? const SizedBox.shrink()
                : Text.rich(TextSpan(children: [span]), textAlign: align),
          ),
        ),
      ),
    );
  }
}

/// Lays its child out at `max(minWidth, child's min-content width)`.
///
/// Inside a horizontal scroll view the grid would otherwise get unbounded
/// width and size every column to its longest unwrapped line. This gives it
/// the post's width to share out, or — when even fully wrapped columns
/// cannot fit — exactly the width they need, which then scrolls.
class _AtLeastMinContentWidth extends SingleChildRenderObjectWidget {
  const _AtLeastMinContentWidth({required this.minWidth, super.child});

  final double minWidth;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderAtLeastMinContentWidth(minWidth);

  @override
  void updateRenderObject(
      BuildContext context, _RenderAtLeastMinContentWidth renderObject) {
    renderObject.minWidth = minWidth;
  }
}

class _RenderAtLeastMinContentWidth extends RenderProxyBox {
  _RenderAtLeastMinContentWidth(this._minWidth);

  double _minWidth;
  set minWidth(double value) {
    if (value == _minWidth) return;
    _minWidth = value;
    markNeedsLayout();
  }

  double _widthFor(BoxConstraints constraints) {
    final content = child!.getMinIntrinsicWidth(double.infinity);
    return constraints.constrainWidth(math.max(_minWidth, content));
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    final width = _widthFor(constraints);
    child.layout(
      BoxConstraints.tightFor(width: width).enforce(constraints.loosen()),
      parentUsesSize: true,
    );
    size = constraints.constrain(child.size);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final child = this.child;
    if (child == null) return constraints.smallest;
    final width = _widthFor(constraints);
    return constraints.constrain(
        child.getDryLayout(BoxConstraints.tightFor(width: width).enforce(constraints.loosen())));
  }
}
