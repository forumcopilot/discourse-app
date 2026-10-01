import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import '../../services/discourse_link_handler.dart';
import '../../services/forum_media.dart';
import '../../utils/emoji_shortcodes.dart';
import 'forum_image.dart';
import 'rich_text_content.dart' show kEmojiGlyphScale, resolveForumUrl;

/// A short piece of cooked HTML read as a label: a poll's options and its
/// title, which Discourse serves as the inner HTML of the cooked
/// `<li data-poll-option-id>` and `.poll-title`, not as plain text —
/// `Door Lock <img class="emoji" alt=":red_apple:" …>`. Drawn with [Text],
/// those showed their markup.
///
/// Inline markup only, read as post text reads it: an emoji is its system
/// glyph (a forum's own emoji, its picture), bold, italic, struck-through
/// and code keep their look, and a link, mention or hashtag its accent
/// colour — and, with [openLinks], its tap. A picture reads as its `alt`,
/// and blocks run on as one line. It is a [Text.rich], so [style],
/// [maxLines] and [overflow] work as on any label.
class CookedInlineText extends StatefulWidget {
  const CookedInlineText(
    this.html, {
    super.key,
    this.siteContext,
    this.style,
    this.maxLines,
    this.overflow,
    this.openLinks = false,
  });

  final String html;

  /// The forum the HTML came from: resolves a forum emoji's relative
  /// address and fetches it, and opens links. Without it a forum emoji
  /// with a relative address reads as its `:name:`.
  final SiteContext? siteContext;

  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  /// Whether a tap on a link opens it (in the app for the forum's own
  /// pages). Off where the whole label is a control or a heading.
  final bool openLinks;

  @override
  State<CookedInlineText> createState() => _CookedInlineTextState();
}

class _CookedInlineTextState extends State<CookedInlineText> {
  final List<TapGestureRecognizer> _recognizers = [];
  dom.DocumentFragment? _fragment;

  /// Plain text — no tag, no entity — is drawn as it is, unparsed.
  bool get _isPlain => !widget.html.contains('<') && !widget.html.contains('&');

  @override
  void initState() {
    super.initState();
    _parse();
  }

  @override
  void didUpdateWidget(CookedInlineText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.html != widget.html) _parse();
  }

  void _parse() => _fragment = _isPlain ? null : html_parser.parseFragment(widget.html);

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final fragment = _fragment;
    if (fragment == null) {
      return Text(widget.html.trim(), style: widget.style, maxLines: widget.maxLines, overflow: widget.overflow);
    }
    final base = DefaultTextStyle.of(context).style.merge(widget.style);
    final spans = _InlineSpanBuilder(
      base: base,
      colorScheme: Theme.of(context).colorScheme,
      siteContext: widget.siteContext,
      onLink: widget.openLinks && widget.siteContext != null
          ? (href) {
              final recognizer = TapGestureRecognizer()
                ..onTap = () {
                  // ignore: discarded_futures
                  DiscourseLinkHandler.open(context, widget.siteContext!, resolveForumUrl(widget.siteContext!, href));
                };
              _recognizers.add(recognizer);
              return recognizer;
            }
          : null,
    ).build(fragment);
    return Text.rich(
      TextSpan(children: spans),
      style: widget.style,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}

/// Walks a cooked fragment into spans, collapsing whitespace as HTML does:
/// runs of it are one space, and none at the start, the end or either side
/// of a line break.
class _InlineSpanBuilder {
  _InlineSpanBuilder({
    required this.base,
    required this.colorScheme,
    required this.siteContext,
    required this.onLink,
  });

  final TextStyle base;
  final ColorScheme colorScheme;
  final SiteContext? siteContext;
  final GestureRecognizer Function(String href)? onLink;

  final List<InlineSpan> _spans = [];
  bool _atLineStart = true;
  bool _pendingSpace = false;

  static final RegExp _whitespace = RegExp(r'\s+');

  static const _skipped = {'script', 'style', 'svg', 'template'};
  static const _blocks = {
    'p', 'div', 'li', 'ul', 'ol', 'table', 'tr', 'td', 'th', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
    'pre', 'blockquote', 'aside', 'details', 'summary', 'figure', 'figcaption', 'hr',
  };

  List<InlineSpan> build(dom.Node root) {
    for (final node in root.nodes) {
      _walk(node, null, null);
    }
    return _spans;
  }

  void _walk(dom.Node node, TextStyle? style, GestureRecognizer? link) {
    if (node is dom.Text) {
      _text(node.text, style, link);
      return;
    }
    if (node is! dom.Element) return;
    final tag = node.localName;
    if (tag == null || _skipped.contains(tag)) return;
    switch (tag) {
      case 'br':
        _spans.add(TextSpan(text: '\n', style: style));
        _atLineStart = true;
        _pendingSpace = false;
        return;
      case 'img':
        _image(node, style, link);
        return;
    }
    final block = _blocks.contains(tag);
    if (block) _pendingSpace = true;
    final next = _styleFor(node, style);
    final href = tag == 'a' ? node.attributes['href']?.trim() : null;
    final nextLink = href != null && href.isNotEmpty && !href.startsWith('#') && onLink != null
        ? onLink!(href)
        : link;
    for (final child in node.nodes) {
      _walk(child, next, nextLink);
    }
    if (block) _pendingSpace = true;
  }

  TextStyle? _styleFor(dom.Element e, TextStyle? style) {
    final s = style ?? const TextStyle();
    switch (e.localName) {
      case 'strong':
      case 'b':
        return s.copyWith(fontWeight: FontWeight.bold);
      case 'em':
      case 'i':
        return s.copyWith(fontStyle: FontStyle.italic);
      case 's':
      case 'del':
      case 'strike':
        return s.copyWith(decoration: TextDecoration.lineThrough);
      case 'u':
      case 'ins':
        return s.copyWith(decoration: TextDecoration.underline);
      case 'code':
        // As inline code in a post: monospace, a size down, on a fill.
        return s.copyWith(
          fontFamily: 'monospace',
          fontSize: (base.fontSize ?? 14) * 0.875,
          backgroundColor: colorScheme.surfaceContainerHighest,
        );
      case 'a':
        final classes = e.classes;
        // The web marks links by colour alone; mentions and hashtags are
        // also a weight up.
        return s.copyWith(
          color: colorScheme.primary,
          fontWeight: classes.contains('mention') || classes.contains('hashtag-cooked') ? FontWeight.w500 : null,
        );
    }
    return style;
  }

  void _text(String raw, TextStyle? style, GestureRecognizer? link) {
    final text = raw.replaceAll(_whitespace, ' ');
    if (text.isEmpty) return;
    if (text.startsWith(' ')) _pendingSpace = true;
    final words = text.trim();
    if (words.isEmpty) return;
    _spans.add(TextSpan(text: '${_leadingSpace()}$words', style: style, recognizer: link));
    _atLineStart = false;
    _pendingSpace = text.endsWith(' ');
  }

  /// The space owed before the next piece: none at the start of a line.
  String _leadingSpace() => _pendingSpace && !_atLineStart ? ' ' : '';

  void _atom(InlineSpan span, TextStyle? style) {
    final space = _leadingSpace();
    if (space.isNotEmpty) _spans.add(TextSpan(text: space, style: style));
    _spans.add(span);
    _atLineStart = false;
    _pendingSpace = false;
  }

  void _image(dom.Element img, TextStyle? style, GestureRecognizer? link) {
    final alt = (img.attributes['alt'] ?? '').trim();
    final isEmoji = img.classes.contains('emoji');
    if (!isEmoji) {
      // A picture has no place in a label; its description does.
      if (alt.isNotEmpty) _text(alt, style, link);
      return;
    }
    final fontSize = (style?.fontSize ?? base.fontSize ?? 14);
    final glyph = discourseEmojiForAlt(alt);
    if (glyph != null) {
      _atom(
        TextSpan(
          text: glyph,
          style: (style ?? const TextStyle()).copyWith(fontSize: fontSize * kEmojiGlyphScale, height: 1.0),
          recognizer: link,
        ),
        style,
      );
      return;
    }
    // A forum's own emoji: its picture, the height of the text's line.
    final src = (img.attributes['src'] ?? '').trim();
    final absolute = src.startsWith('http://') || src.startsWith('https://');
    final site = siteContext;
    if (src.isEmpty || (!absolute && site == null)) {
      if (alt.isNotEmpty) _text(alt, style, link);
      return;
    }
    final url = site == null ? src : resolveForumUrl(site, src);
    final size = fontSize * 1.25;
    _atom(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Image(
          image: forumImage(url, site == null ? null : ForumMediaAuth.of(site)),
          width: size,
          height: size,
          fit: BoxFit.contain,
          semanticLabel: alt,
          errorBuilder: (context, _, __) => Text(alt, style: base.merge(style)),
        ),
      ),
      style,
    );
  }
}
