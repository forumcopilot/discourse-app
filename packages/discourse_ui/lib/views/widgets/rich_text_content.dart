import 'dart:math' as math;

import 'package:discourse_core/discourse_core.dart' show DiscourseSiteCapabilities;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import 'brand_image.dart';
import 'broken_image_widget.dart';
import 'code_block.dart';
import 'discourse_blocks.dart';
import 'embed_cards.dart';
import 'onebox_card.dart';
import 'post_body_extensions.dart';
import 'post_content_callbacks.dart' show PostContentCallbacks;
import 'post_table.dart';
import 'twitter_card.dart';
import '../../core/cache/lru_cache.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';
import '../../utils/embed_links.dart';
import '../../utils/emoji_shortcodes.dart';
import '../../utils/file_utils.dart';
import '../../utils/html_colors.dart';
import '../../utils/url_utils.dart';
import '../../services/discourse_link_handler.dart';
import 'category_badge.dart';

/// Renders post content. The data we get from Discourse's `/t/{id}.json`
/// post stream is the `cooked` HTML field — i.e. server-rendered Markdown
/// + Discourse extensions (emoji, mentions, quotes, oneboxes, …) already
/// expanded to HTML.
///
/// This widget accepts the same constructor shape the inherited XF code
/// has been calling so the swap is a drop-in replacement. Link and image
/// taps route through the provided [PostContentCallbacks] when available
/// (mention → user profile, same-forum topic/post URL → in-app post page,
/// image → viewer), falling back to an external launch otherwise.
class RichTextContent extends StatelessWidget {
  final SiteContext siteContext;
  final String content;
  final PostContentCallbacks? callbacks;

  /// The live poll a `div.poll[data-poll-name]` stands for, drawn in its
  /// place. Null leaves the cooked markup (no poll data here).
  final Widget? Function(String pollName)? pollBuilder;

  /// The post on the web, for what the app cannot draw itself (a Mermaid
  /// diagram offers to open it there).
  final String? webUrl;

  /// Body text size: 16, Discourse's size on phones, for posts, messages
  /// and chat alike. A preview's excerpt passes its smaller card size.
  final double? baseFontSize;

  /// Body text colour, for text on a coloured surface (your own chat
  /// message on primaryContainer); the theme's onSurface otherwise.
  final Color? textColor;

  const RichTextContent({
    super.key,
    required this.siteContext,
    required this.content,
    this.callbacks,
    this.pollBuilder,
    this.webUrl,
    this.baseFontSize,
    this.textColor,
  });

  /// Extracts the username from a Discourse profile href
  /// (`/u/{username}` or `/users/{username}`), otherwise null.
  static String? _usernameFromHref(String url) {
    try {
      final path = Uri.parse(url.trim()).path;
      return RegExp(r'^/u(?:sers)?/([^/?#]+)/?$').firstMatch(path)?.group(1);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // 16 with 1.5 line spacing, as Discourse sets post text; the app used
    // Material's 14/1.4, which made long posts read noticeably denser.
    final body = (textTheme.bodyMedium ?? const TextStyle())
        .copyWith(fontSize: baseFontSize ?? 16);
    final bodyColor = textColor ?? body.color ?? colorScheme.onSurface;
    // One monospace size for code blocks and inline code, on every surface.
    final codeStyle = body.copyWith(
      fontFamily: 'monospace',
      fontSize: _codeFontSize,
      height: 1.4,
      color: bodyColor,
    );
    final mutedColor = colorScheme.onSurfaceVariant;
    final accent = colorScheme.primary;

    final html = _readableAuthorColours(
        _foldAttachmentSize(content), colorScheme.surface);

    // Embed previews open the video or post itself — for YouTube, TikTok
    // and the like, in their app — through the same path as a link tap.
    void openEmbed(String url) {
      final resolved = _resolveUrl(url);
      if (callbacks?.onUrlTap != null) {
        callbacks!.onUrlTap!(resolved);
        return;
      }
      // ignore: discarded_futures
      DiscourseLinkHandler.open(context, siteContext, resolved);
    }

    return PostBodyFallback(
      html: html,
      style: body.copyWith(color: bodyColor, height: 1.5),
      child: Html(
      data: html,
      onLinkTap: (url, attributes, _) {
        if (url == null || url.isEmpty) return;
        // Discourse puts an in-page anchor beside every heading
        // (`<a class="anchor" href="#p-123-heading">`); resolved against the
        // forum it read as a link to the forum's home.
        if (url.startsWith('#')) return;
        final resolved = _resolveUrl(url);
        final classes =
            (attributes['class'] ?? '').split(RegExp(r'\s+'));
        // Discourse cooked mentions:
        // <a class="mention" href="/u/{username}">@user</a>
        if (classes.contains('mention') &&
            callbacks?.onMentionTap != null) {
          final username = _usernameFromHref(url);
          if (username != null && username.isNotEmpty) {
            callbacks!.onMentionTap!(username);
            return;
          }
        }
        // Discourse lightboxed images: the wrapping anchor points at the
        // full-size upload — open it in the in-app viewer.
        if (classes.contains('lightbox') && callbacks?.onImageTap != null) {
          callbacks!.onImageTap!(resolved, context, resolved);
          return;
        }
        // Everything else goes through the URL callback when the host
        // wants a say (a post moves within its own topic), and otherwise
        // to the link handler: in-app for this forum's pages, the browser
        // for the rest. Chat, the accepted answer and edit history rely on
        // the default; they used to send every link to the browser.
        if (callbacks?.onUrlTap != null) {
          callbacks!.onUrlTap!(resolved);
          return;
        }
        // ignore: discarded_futures
        DiscourseLinkHandler.open(context, siteContext, resolved);
      },
      style: _stylesFor(colorScheme, body, bodyColor, mutedColor, accent),
      // Resolve relative URLs (img src, a href) to absolute against the
      // forum base. For Discourse emoji (`<img class="emoji" alt=":wave:">`)
      // we look up the alt-shortcode in the Unicode emoji table and render
      // the system glyph instead of fetching the PNG — looks native to
      // the OS, works offline, no network round-trips. Falls back to the
      // PNG for forum-custom emoji that aren't in standard Unicode.
      extensions: [
        const PostBlockRhythmExtension(),
        const QuoteExtension(),
        PostTableExtension(colorScheme: colorScheme),
        MentionExtension(onTap: (href, isGroup) {
          if (!isGroup && callbacks?.onMentionTap != null) {
            final username = _usernameFromHref(href);
            if (username != null && username.isNotEmpty) {
              callbacks!.onMentionTap!(username);
              return;
            }
          }
          openEmbed(href);
        }),
        const DetailsExtension(),
        _CategoryHashtagMarkExtension(siteContext),
        ImageGridExtension(
          resolve: _resolveUrl,
          onImageTap: callbacks?.onImageTap == null
              ? null
              : (full, imageContext) => callbacks!.onImageTap!(full, imageContext, full),
        ),
        _EmbedExtension(resolve: _resolveUrl, onOpen: openEmbed),
        DiscourseBlocksExtension(onOpen: openEmbed, pollBuilder: pollBuilder),
        // Link previews: a native card; what is inside the preview's body is
        // rendered by a nested RichTextContent, so it keeps every rule here,
        // at the size and colour the card gives its excerpt.
        OneboxExtension(
          resolve: _resolveUrl,
          onOpen: openEmbed,
          renderHtml: (html, {fontSize, color}) => RichTextContent(
            siteContext: siteContext,
            content: html,
            callbacks: callbacks,
            webUrl: webUrl,
            baseFontSize: fontSize ?? baseFontSize,
            textColor: color ?? textColor,
          ),
        ),
        // Discourse renders a non-image upload as
        // `<a class="attachment">name</a> (117 Bytes)`, and styles it with
        // a download glyph via CSS ::before — which flutter_html cannot
        // express, so it came out as a bare blue link indistinguishable
        // from any other. Draw the chip web draws instead.
        _AttachmentLinkExtension(
          onShare: (href) {
            // ignore: discarded_futures
            UrlUtils.shareUrl(_resolveUrl(href));
          },
          onTap: (href) {
            final resolved = _resolveUrl(href);
            if (callbacks?.onUrlTap != null) {
              callbacks!.onUrlTap!(resolved);
              return;
            }
            // ignore: discarded_futures
            DiscourseLinkHandler.open(context, siteContext, resolved);
          },
          colorScheme: colorScheme,
        ),
        // Code blocks scroll sideways; they must never wrap. flutter_html
        // wraps by default, which broke shared code rather than merely
        // squashing it: a Python post rendered
        //   arr = [i for i in nums if i !=
        //   0]
        // — the continuation lands at column 0, so indentation-sensitive
        // code reads as a different program. Discourse web scrolls the
        // block horizontally; so do we.
        TagExtension(
          tagsToExtend: {'pre'},
          builder: (extensionContext) {
            // Older GitHub code previews put each line in an `ol.lines li`.
            final lines = extensionContext.element?.querySelectorAll('ol.lines > li') ?? const [];
            final code = lines.isNotEmpty
                ? lines.map((li) => li.text).join('\n')
                : extensionContext.element?.text ?? '';
            if (code.isEmpty) return const SizedBox.shrink();
            final language = RegExp(r'(?:^|\s)lang-([\w+#-]+)')
                .firstMatch(extensionContext.element?.querySelector('code')?.className ?? '')
                ?.group(1);
            final codeBlock = CodeBlock(
              // Trailing newlines are common in cooked <pre> and would
              // otherwise leave a blank band inside the block.
              code: code.replaceAll(RegExp(r'\n+$'), ''),
              language: extensionContext.attributes['data-code-wrap'] == 'mermaid' ? null : language,
              textStyle: codeStyle,
            );
            // A Mermaid diagram is drawn by JavaScript on the web; the app
            // shows its source, says what it is, and offers the web.
            if (extensionContext.attributes['data-code-wrap'] != 'mermaid') {
              return withBlockGap(extensionContext, codeBlock);
            }
            return withBlockGap(
              extensionContext,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_tree_outlined, size: DesignTokens.iconSizeSMedium, color: mutedColor),
                      const SizedBox(width: DesignTokens.spacingS),
                      Text('Mermaid',
                          style: body.copyWith(color: mutedColor, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      if (webUrl != null)
                        Builder(
                          builder: (context) => TextButton.icon(
                            onPressed: () => openEmbed(webUrl!),
                            icon: const Icon(Icons.open_in_new, size: DesignTokens.iconSizeSMedium),
                            label: Text(AppLocalizations.of(context)?.viewOnWeb ?? 'View on Web'),
                          ),
                        ),
                    ],
                  ),
                  codeBlock,
                ],
              ),
            );
          },
        ),
        TagExtension(
          tagsToExtend: {'img'},
          builder: (extensionContext) {
            final src = extensionContext.attributes['src'];
            final alt = extensionContext.attributes['alt'] ?? '';
            final classes = (extensionContext.attributes['class'] ?? '');
            final isEmoji = classes.contains('emoji');
            final onlyEmoji = classes.split(RegExp(r'\s+')).contains('only-emoji');

            if (isEmoji) {
              // alt is `:name:` or `:name:tN:` for a skin-toned emoji.
              final m = _emojiAlt.firstMatch(alt.trim());
              if (m != null) {
                final unicode =
                    discourseEmojiChar(m.group(1)!, tone: m.group(2));
                if (unicode != null) {
                  return Text(
                    unicode,
                    style: body.copyWith(
                      // Bump emoji slightly so they sit nicely with text; a
                      // post of nothing but emoji shows them large, as the
                      // web does (`img.emoji.only-emoji`, 32px) — the same
                      // size as an image emoji there.
                      fontSize: onlyEmoji ? _onlyEmojiSize : (body.fontSize ?? 14) * 1.15,
                      height: 1.0,
                    ),
                  );
                }
              }
              // Fall through to the image renderer (forum-custom emoji,
              // shortcodes our table doesn't know).
            }

            if (src == null || src.isEmpty) return const SizedBox.shrink();
            final resolved = _resolveUrl(src);
            final w = onlyEmoji
                ? _onlyEmojiSize
                : double.tryParse(extensionContext.attributes['width'] ?? '') ??
                    (isEmoji ? 20 : null);
            final h = onlyEmoji
                ? _onlyEmojiSize
                : double.tryParse(extensionContext.attributes['height'] ?? '') ??
                    (isEmoji ? 20 : null);
            // A onebox's avatar (a tweet's author, a GitHub user) is a small
            // square beside the text on the web; at its own 400×400 it
            // would fill the post.
            if (classes.split(RegExp(r'\s+')).contains('onebox-avatar')) {
              return _NoBaseline(child: ClipRRect(
                borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                child: Image.network(
                  resolved,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) => const SizedBox(width: 48, height: 48),
                ),
              ));
            }
            // Image.network cannot decode SVG (uploads, badges, GitHub's
            // favicon) and showed the alt text instead. BrandImage draws it
            // with flutter_svg from the disk cache, falling back the same way
            // when the file is missing or not SVG.
            final isSvg = BrandImage.isSvg(resolved);
            // An emoji that fails reads as its `:name:`; a picture gets the
            // same broken-image box as everywhere else.
            Widget fallback(BuildContext _) => isEmoji
                ? Text(alt, style: TextStyle(color: mutedColor))
                : BrokenImagePlaceholder(alt: alt);
            Widget picture({double? width, double? height}) => isSvg
                ? BrandImage(
                    resolved,
                    width: width,
                    height: height,
                    fit: BoxFit.contain,
                    fallback: fallback,
                  )
                : Image.network(
                    resolved,
                    width: width,
                    height: height,
                    fit: BoxFit.contain,
                    errorBuilder: (context, _, __) => fallback(context),
                  );
            // An upload wider than the column keeps its proportions. Given
            // both attributes, RenderImage clamps the width to the column
            // but keeps the height, and the picture ends up centred in a
            // box that is too tall — a blank band above and below every
            // large image. AspectRatio sizes the box from the width it
            // actually gets.
            final Widget image = (!isEmoji && w != null && h != null && w > 0 && h > 0)
                ? ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: w),
                    child: AspectRatio(aspectRatio: w / h, child: picture()),
                  )
                : picture(width: w, height: h);
            // A person's avatar (a quote's author) is round, as everywhere
            // else in the app, and is not a picture to open.
            if (classes.split(RegExp(r'\s+')).contains('avatar')) {
              return _NoBaseline(
                child: Padding(
                  padding: const EdgeInsets.only(right: DesignTokens.spacingXS),
                  child: ClipOval(child: image),
                ),
              );
            }
            // Route content-image taps to the in-app viewer (emoji stay
            // plain inline glyphs/images).
            final onImageTap = callbacks?.onImageTap;
            if (isEmoji || onImageTap == null) return _NoBaseline(child: image);
            return _NoBaseline(
              child: Builder(
                builder: (imageContext) => GestureDetector(
                  onTap: () => onImageTap(resolved, imageContext, resolved),
                  child: image,
                ),
              ),
            );
          },
        ),
        // Web draws <hr> as a thin rule in the border colour. flutter_html's
        // default is a black Border.all box with auto margins, which in a
        // post left a heavy rule and ~280dp of blank space under it. Like any
        // block it has the block gap below it (the one above is the previous
        // block's), and it is centred in its line, which is taller than both.
        TagExtension.inline(
          tagsToExtend: {'hr'},
          builder: (extensionContext) => WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: withBlockGap(
              extensionContext,
              SizedBox(
                width: double.infinity,
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: colorScheme.outlineVariant,
                ),
              ),
            ),
          ),
        ),
        // Inline code as a small rounded chip, in the one code size. Code in
        // a link stays text (see the `code` style), so the link still taps.
        MatcherExtension.inline(
          matcher: (c) =>
              c.elementName == 'code' && !_hasAncestor(c.node, const {'pre', 'a'}),
          builder: (c) {
            final style = c.styledElement?.style.generateTextStyle() ?? codeStyle;
            return WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingXS),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
                ),
                child: Text(
                  c.element?.text ?? '',
                  style: style.copyWith(height: 1.4, backgroundColor: Colors.transparent),
                ),
              ),
            );
          },
        ),
        // A followed link's click count, as the web's small grey badge.
        MatcherExtension.inline(
          matcher: (c) => c.elementName == 'span' && c.classes.contains('link-clicks'),
          builder: (c) => WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              margin: const EdgeInsets.only(left: DesignTokens.spacingXS),
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingXS),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
              ),
              child: Text(
                c.element?.text ?? '',
                style: textTheme.labelMedium?.copyWith(color: mutedColor),
              ),
            ),
          ),
        ),
        // discourse-checklist cooks `[x]` / `[ ]` into an empty
        // span.chcklst-box whose glyph is CSS; without one, checked and
        // unchecked items read the same.
        MatcherExtension.inline(
          matcher: (c) => c.classes.contains('chcklst-box'),
          builder: (c) {
            final checked = c.classes.contains('checked');
            return WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  checked ? Icons.check_box : Icons.check_box_outline_blank,
                  size: (body.fontSize ?? 14) * 1.25,
                  color: checked ? accent : mutedColor,
                ),
              ),
            );
          },
        ),
      ],
      ),
    );
  }

  String _resolveUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('//')) return 'https:$url';
    // Join safely: a trailing-slash base must not produce double slashes.
    var base = siteContext.site.url;
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    if (url.startsWith('/')) {
      // Discourse writes a subfolder install's own paths with the
      // subfolder in them (`/forum/t/…`, `/forum/uploads/…`); joined to the
      // base they came out as /forum/forum/….
      final forum = Uri.tryParse(base);
      final basePath = forum?.path ?? '';
      if (forum != null &&
          forum.hasAuthority &&
          basePath.isNotEmpty &&
          (url == basePath || url.startsWith('$basePath/'))) {
        return '${forum.origin}$url';
      }
      return '$base$url';
    }
    return '$base/$url';
  }
}

/// Code's one size, block and inline, in posts, messages and chat.
const double _codeFontSize = 14;

/// A post of nothing but emoji: glyph and image emoji alike, as the web's
/// `img.emoji.only-emoji`.
const double _onlyEmojiSize = 32;

/// Whether [node] sits inside any of [tags].
bool _hasAncestor(dom.Node node, Set<String> tags) {
  for (var p = node.parent; p != null; p = p.parent) {
    if (tags.contains(p.localName)) return true;
  }
  return false;
}

/// Author colours (`<font color>`, normalised to `#rrggbb` by CookedContent)
/// adjusted to stay readable on [surface]: black text turns light grey in
/// the dark theme, a pale cyan darkens on the light one. Hue is kept, and
/// colours that already contrast are left alone. Keyed by theme so a
/// light/dark switch re-renders with the other set.
final LRUCache<String, String> _themedHtmlCache = LRUCache(maxSize: 200);
final RegExp _authorColour = RegExp(r'(?<=\s)color="(#[0-9a-f]{6})"');

String _readableAuthorColours(String html, Color surface) {
  if (!html.contains('color="#')) return html;
  final key = '${surface.toARGB32()}\u0000$html';
  final hit = _themedHtmlCache.get(key);
  if (hit != null) return hit;
  final themed = html.replaceAllMapped(_authorColour, (m) {
    final adjusted = readableOn(colorFromHex(m.group(1)!), surface);
    return 'color="${colorToHex(adjusted)}"';
  });
  _themedHtmlCache.put(key, themed);
  return themed;
}

/// A post body's text, kept at hand in case flutter_html cannot build it.
///
/// When flutter_html throws while building a post (it did on an invalid
/// `<font color>`), Flutter puts an error box in its place — grey in
/// release and, inside a scrolling thread, unbounded: 100,000dp tall. With
/// this above the Html widget, the error box is replaced by the post's
/// plain text instead, so an unexpected construct degrades to something
/// readable.
class PostBodyFallback extends InheritedWidget {
  const PostBodyFallback({super.key, required this.html, this.style, required super.child});

  final String html;

  /// The body text's style, so the fallback reads at the post's size;
  /// bodyLarge when not given.
  final TextStyle? style;

  static PostBodyFallback? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PostBodyFallback>();

  String get plainText => _plainTextOf(html);

  @override
  bool updateShouldNotify(PostBodyFallback oldWidget) => oldWidget.html != html;
}

/// Wraps whatever ErrorWidget.builder is installed (Flutter's default unless
/// the host set its own). Only errors that took down a whole post body — no
/// flutter_html box between the failure and [PostBodyFallback] — become the
/// post's plain text; a failure deeper inside keeps the previous error
/// widget, bounded in height so it can never swallow a thread.
///
/// Called once from the app's error-handling setup; returns a callback that
/// restores the previous builder (tests use it).
VoidCallback installPostBodyErrorFallback() {
  final previous = ErrorWidget.builder;
  ErrorWidget.builder =
      (details) => _PostBodyErrorView(details: details, previous: previous);
  return () => ErrorWidget.builder = previous;
}

class _PostBodyErrorView extends StatelessWidget {
  const _PostBodyErrorView({required this.details, required this.previous});

  final FlutterErrorDetails details;
  final ErrorWidgetBuilder previous;

  @override
  Widget build(BuildContext context) {
    final fallback = PostBodyFallback.maybeOf(context);
    final insideRenderedHtml =
        context.findAncestorWidgetOfExactType<CssBoxWidget>() != null;
    if (fallback != null && !insideRenderedHtml) {
      return Text(fallback.plainText,
          style: fallback.style ?? Theme.of(context).textTheme.bodyLarge);
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 200),
      child: previous(details),
    );
  }
}

const _plainTextBlocks = {
  'p', 'div', 'li', 'ul', 'ol', 'table', 'tr', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
  'pre', 'blockquote', 'aside', 'header', 'article', 'section', 'details',
  'summary', 'figure', 'figcaption', 'hr', 'dl', 'dt', 'dd',
};

String _plainTextOf(String html) {
  final sb = StringBuffer();
  void walk(dom.Node node) {
    if (node is dom.Text) {
      sb.write(node.text);
      return;
    }
    if (node is dom.Element) {
      final tag = node.localName;
      if (tag == 'br') {
        sb.write('\n');
        return;
      }
      if (tag == 'script' || tag == 'style') return;
      final block = _plainTextBlocks.contains(tag);
      if (block) sb.write('\n');
      node.nodes.forEach(walk);
      if (block) sb.write('\n');
      return;
    }
    node.nodes.forEach(walk);
  }

  walk(html_parser.parseFragment(html));
  return sb
      .toString()
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .replaceAll(RegExp(r' *\n[\s]*\n+ *'), '\n\n')
      .trim();
}

/// Folds Discourse's trailing size text into the anchor.
///
/// Cooked output is `<a class="attachment">notes.txt</a> (117 Bytes)` —
/// the size is a sibling text node, so an extension replacing only the
/// anchor would leave "(117 Bytes)" stranded beside the card. Moving it
/// onto the element lets the card show name and size together, the way
/// the composer's own attachment row does.
/// The `alt` Discourse puts on an inline emoji image: `:name:`, or
/// `:name:tN:` when a skin tone was applied.
final RegExp _emojiAlt =
    RegExp(r'^:([a-z0-9_+-]+)(?::t([1-6]))?:$', caseSensitive: false);

final RegExp _attachmentSizePattern = RegExp(
  r'(<a\s+class="attachment"[^>]*>.*?</a>)\s*\(([^)]{1,20})\)',
  caseSensitive: false,
  dotAll: true,
);

String _foldAttachmentSize(String html) {
  if (!html.contains('class="attachment"')) return html;
  return html.replaceAllMapped(
    _attachmentSizePattern,
    (m) {
      final anchor = m.group(1)!;
      final size = m.group(2)!;
      return anchor.replaceFirst('<a ', '<a data-size="$size" ');
    },
  );
}

/// Discourse's embeds, drawn as native previews where the web shows the
/// player (see [EmbedLink]):
///
///  * `div.lazy-video-container` — YouTube, Vimeo and TikTok, with the
///    title and thumbnail the forum stored — and the older `div.lazyYT`;
///  * `<iframe>` — any other site's player: a video preview for video
///    sites, a row naming the site for the rest;
///  * `<video>` and `div.video-placeholder-container` — uploads, played in
///    the app's video viewer — and `<audio>`, played in place;
///  * `a.onebox` — a video or tweet URL alone on its line that the forum
///    did not turn into an embed.
///
/// flutter_html renders none of these by itself: videos showed as a bare
/// thumbnail, iframes and audio as nothing.
class _EmbedExtension extends HtmlExtension {
  const _EmbedExtension({required this.resolve, required this.onOpen});

  final String Function(String url) resolve;
  final void Function(String url) onOpen;

  static final RegExp _tweet = RegExp(
      r'^https?://(?:www\.|mobile\.)?(?:twitter|x)\.com/\w+/status(?:es)?/\d+',
      caseSensitive: false);

  @override
  Set<String> get supportedTags => const {'iframe', 'video', 'audio'};

  @override
  bool matches(ExtensionContext context) {
    switch (context.elementName) {
      case 'iframe':
        return (context.attributes['src'] ?? '').trim().isNotEmpty;
      case 'video':
      case 'audio':
        return _mediaSrc(context.element) != null;
      case 'div':
        final c = context.classes;
        return c.contains('lazy-video-container') ||
            c.contains('lazyYT') ||
            c.contains('video-placeholder-container');
      case 'a':
        if (!context.classes.contains('onebox')) return false;
        final href = (context.attributes['href'] ?? '').trim();
        return _tweet.hasMatch(href) || EmbedLink.fromUrl(href) != null;
    }
    return false;
  }

  @override
  InlineSpan build(ExtensionContext context) {
    final card = _card(context);
    // Markup that did not yield a card renders as it would have otherwise.
    if (card == null) return TextSpan(children: context.inlineSpanChildren);
    return WidgetSpan(
      child: SizedBox(width: double.infinity, child: withBlockGap(context, card)),
    );
  }

  Widget? _card(ExtensionContext context) {
    final element = context.element;
    if (element == null) return null;
    final a = element.attributes;
    switch (context.elementName) {
      case 'div':
        if (context.classes.contains('video-placeholder-container')) {
          final src = a['data-video-src'];
          if (src == null || src.isEmpty) return null;
          final thumb = a['data-thumbnail-src'];
          return PostVideoCard(
            src: resolve(src),
            poster: thumb == null || thumb.isEmpty ? null : resolve(thumb),
          );
        }
        if (context.classes.contains('lazyYT')) {
          // The older discourse-lazy-yt plugin. Its stored title is often
          // just " - YouTube"; then the card looks the title up instead.
          final id = a['data-youtube-id'];
          if (id == null || id.isEmpty) return null;
          final title = (a['data-youtube-title'] ?? '')
              .replaceFirst(RegExp(r'\s*-\s*YouTube\s*$'), '')
              .trim();
          final thumb = element.querySelector('img[src]')?.attributes['src'];
          final link = EmbedLink.fromUrl(
            'https://www.youtube.com/watch?v=$id',
            title: title.isEmpty ? null : title,
            thumbnailUrl: thumb == null ? null : resolve(thumb),
          );
          return link == null ? null : EmbedPreviewCard(link: link, onOpen: onOpen);
        }
        final href = element.querySelector('a[href]')?.attributes['href'];
        final thumb = element.querySelector('img[src]')?.attributes['src'];
        final link = EmbedLink.fromLazyVideo(
          a,
          href: href == null ? null : resolve(href),
          thumbnailUrl: thumb == null ? null : resolve(thumb),
        );
        return link == null ? null : EmbedPreviewCard(link: link, onOpen: onOpen);
      case 'iframe':
        // An iframe's content is its fallback markup, kept as raw text.
        final fallback = element.text;
        final innerHref = RegExp(r'href="([^"]+)"').firstMatch(fallback)?.group(1);
        final innerText = fallback.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();
        final link = EmbedLink.fromIframe(
          resolve(a['src']!.trim()),
          title: a['title'],
          innerHref: innerHref,
          innerText: innerText.isEmpty ? null : innerText,
        );
        return link == null ? null : EmbedPreviewCard(link: link, onOpen: onOpen);
      case 'video':
        final src = _mediaSrc(element)!;
        final poster = a['poster'];
        final w = double.tryParse(a['width'] ?? '');
        final h = double.tryParse(a['height'] ?? '');
        return PostVideoCard(
          src: resolve(src),
          poster: poster == null || poster.isEmpty ? null : resolve(poster),
          aspectRatio: (w != null && h != null && h > 0) ? w / h : null,
        );
      case 'audio':
        return PostAudioPlayer(src: resolve(_mediaSrc(element)!));
      case 'a':
        final href = a['href']!.trim();
        if (_tweet.hasMatch(href)) return TwitterCard(url: href);
        final link = EmbedLink.fromUrl(href);
        return link == null ? null : EmbedPreviewCard(link: link, onOpen: onOpen);
    }
    return null;
  }

  /// A `<video>`/`<audio>` source: its `src`, or its first `<source src>`.
  static String? _mediaSrc(dom.Element? element) {
    if (element == null) return null;
    final own = element.attributes['src']?.trim();
    if (own != null && own.isNotEmpty) return own;
    final source = element.querySelector('source[src]')?.attributes['src']?.trim();
    return (source == null || source.isEmpty) ? null : source;
  }
}

/// Renders `<a class="attachment">` as the same attachment row the
/// composer shows — a file-type tile, the filename, and its size —
/// rather than a bare blue link.
///
/// Matches only that class, so ordinary links, mentions and lightbox
/// anchors keep the default handling. That is why this is a custom
/// [HtmlExtension] with its own [matches] instead of a TagExtension on
/// `a`, which would have swallowed all four.
/// The icon slot in a category hashtag. Discourse cooks `#site-feedback` as
/// a link with an empty `span.hashtag-icon-placeholder`, which the web fills
/// with the category's square or emoji; this fills it with the same
/// [CategoryMark] the category's badge uses everywhere else.
class _CategoryHashtagMarkExtension extends HtmlExtension {
  const _CategoryHashtagMarkExtension(this.siteContext);

  final SiteContext siteContext;

  @override
  Set<String> get supportedTags => {'span'};

  @override
  bool matches(ExtensionContext context) {
    if (context.elementName != 'span' ||
        !context.classes.contains('hashtag-icon-placeholder')) {
      return false;
    }
    final link = context.element?.parent;
    return link != null &&
        link.localName == 'a' &&
        link.attributes['data-type'] == 'category';
  }

  @override
  InlineSpan build(ExtensionContext context) {
    final link = context.element!.parent!;
    final caps = DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl);
    // data-id since Discourse 3.1; the slug before that.
    final slug = link.attributes['data-slug'];
    final id = link.attributes['data-id'] ??
        (slug == null ? null : caps.categoryIdForSlugs([slug])?.toString()) ??
        '';
    final style = caps.categoryStyleFor(id);
    final parentId = style?.parentId;
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.only(right: 3),
        child: CategoryMark(
          style: style,
          parent: parentId == null ? null : caps.categoryStyleFor('$parentId'),
          size: 11,
        ),
      ),
    );
  }
}

class _AttachmentLinkExtension extends HtmlExtension {
  const _AttachmentLinkExtension({
    required this.onTap,
    required this.onShare,
    required this.colorScheme,
  });

  final void Function(String href) onTap;
  final void Function(String href) onShare;
  final ColorScheme colorScheme;

  @override
  Set<String> get supportedTags => {'a'};

  @override
  bool matches(ExtensionContext context) =>
      context.elementName == 'a' && context.classes.contains('attachment');

  @override
  InlineSpan build(ExtensionContext context) {
    final href = context.attributes['href'] ?? '';
    final name = context.element?.text.trim() ?? '';
    final size = context.attributes['data-size'];
    final label = name.isEmpty ? 'Attachment' : name;
    final l10n = context.buildContext == null ? null : AppLocalizations.of(context.buildContext!);

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      // minWidth infinity makes the card fill the line box, so it reads as
      // a row in a list rather than a chip floating in a paragraph —
      // matching the composer's attachment list.
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Padding(
        padding: EdgeInsets.symmetric(vertical: DesignTokens.spacingXS),
        child: EmbeddedCard(
          onTap: href.isEmpty ? null : () => onTap(href),
          padding: EdgeInsets.zero,
          child: FileRow(
            // Same 48px type tile the composer draws, from the same
            // helpers, so an attachment looks identical whether you are
            // about to post it or reading it back.
            leading: DecoratedBox(
              decoration: BoxDecoration(
                color: getFileTypeColor(label),
                borderRadius: BorderRadius.circular(DesignTokens.radiusS),
              ),
              child: Icon(
                getFileIcon(getFileType(label)),
                size: DesignTokens.iconSizeL,
                color: Colors.white,
              ),
            ),
            title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text([
              getFileType(label).toUpperCase(),
              if (size != null && size.isNotEmpty) size,
            ].join(' • ')),
            trailing: [
              IconButton(
                tooltip: l10n?.share ?? 'Share',
                onPressed: href.isEmpty ? null : () => onShare(href),
                icon: Icon(Icons.share_outlined,
                    size: DesignTokens.iconSizeM,
                    color: colorScheme.onSurfaceVariant),
              ),
              IconButton(
                tooltip: 'Download',
                onPressed: href.isEmpty ? null : () => onTap(href),
                icon: Icon(Icons.download_rounded,
                    size: DesignTokens.iconSizeM,
                    color: colorScheme.primary),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

/// flutter_html style tables, one per theme.
///
/// The map is ~20 `Style` objects with their margins, paddings and
/// borders; building it inside `build()` meant every post allocated all
/// of it on every rebuild. It depends only on the theme, so it is built
/// once per distinct colour/size combination and shared.
final Map<(int, int, int, int, double), Map<String, Style>> _styleCache = {};

Map<String, Style> _stylesFor(ColorScheme colorScheme, TextStyle body,
    Color bodyColor, Color mutedColor, Color accent) {
  final key = (
    bodyColor.toARGB32(),
    mutedColor.toARGB32(),
    accent.toARGB32(),
    colorScheme.surfaceContainerHighest.toARGB32(),
    body.fontSize ?? 14,
  );
  final base = body.fontSize ?? 16;

  // Headings on the type scale — h1 headlineSmall 24/32 down to h5/h6
  // bodyLarge 16/24 — never smaller than the body text, medium weight,
  // with more room above (16, none as a first block) than below (8).
  Style heading(double size, double lineHeight, {Color? color}) => Style(
        fontSize: FontSize(math.max(size, base)),
        lineHeight: LineHeight(lineHeight / size),
        fontWeight: FontWeight.w500,
        color: color,
        margin: Margins.only(top: DesignTokens.spacingL, bottom: DesignTokens.spacingS),
      );

  // A quote is a filled block with the accent bar, padded evenly; the
  // corners are rounded by QuoteExtension.
  Style quote() => Style(
        display: Display.block,
        margin: Margins.only(bottom: kPostBlockGap),
        padding: HtmlPaddings.all(DesignTokens.spacingM),
        backgroundColor: colorScheme.surfaceContainerHighest,
        border: Border(
          left: BorderSide(color: accent, width: 3),
        ),
      );

  return _styleCache.putIfAbsent(key, () => {
    'body': Style(
      margin: Margins.zero,
      padding: HtmlPaddings.zero,
      fontSize: FontSize(base),
      color: bodyColor,
      lineHeight: const LineHeight(1.5),
    ),
    // Every block takes the one block gap below itself and none above;
    // PostBlockRhythmExtension drops it after the last block of a post,
    // quote or details.
    'p': Style(
      margin: Margins.only(bottom: kPostBlockGap),
      padding: HtmlPaddings.zero,
    ),
    // Blocks drawn natively (code, previews, embeds, tables, pictures,
    // polls, events, details, rules) take the same gap; withBlockGap draws
    // what is left of it once margins have collapsed.
    'pre, hr, table, details, iframe, video, audio, aside.onebox, a.onebox, '
        'div.lazy-video-container, div.lazyYT, div.video-placeholder-container, '
        'div.d-image-grid, div.poll, div.discourse-post-event, div.math': Style(
      margin: Margins(bottom: Margin(kPostBlockGap)),
    ),
    // The web marks links by colour alone.
    'a': Style(
      color: accent,
      textDecoration: TextDecoration.none,
    ),
    'a.mention': Style(
      color: accent,
      fontWeight: FontWeight.w500,
      textDecoration: TextDecoration.none,
    ),
    'a.hashtag-cooked': Style(
      color: accent,
      fontWeight: FontWeight.w500,
      textDecoration: TextDecoration.none,
    ),
    'aside.quote': quote(),
    // labelLarge, 14/20 medium.
    'aside.quote .title': Style(
      fontSize: FontSize(14),
      lineHeight: const LineHeight(20 / 14),
      fontWeight: FontWeight.w500,
      color: mutedColor,
      margin: Margins.only(bottom: DesignTokens.spacingXS),
    ),
    'blockquote': quote(),
    // After 'blockquote': flutter_html merges matching rules in map order,
    // so this one has to come later to win. The quote's aside already draws
    // the bar and the fill; the blockquote inside it must not draw them a
    // second time (it did — every quote had two bars and two backgrounds).
    'aside.quote blockquote': Style(
      margin: Margins.zero,
      padding: HtmlPaddings.zero,
      backgroundColor: Colors.transparent,
      border: const Border(),
    ),
    // Inline code is drawn as a rounded chip (see the `code` extension);
    // the fill here is for code inside a link, which stays text. Blocks
    // (`pre`) are CodeBlock, in the same size.
    'code': Style(
      backgroundColor: colorScheme.surfaceContainerHighest,
      fontSize: FontSize(_codeFontSize),
      fontFamily: 'monospace',
    ),
    'ul, ol': Style(
      margin: Margins.only(bottom: kPostBlockGap),
      padding: HtmlPaddings.only(left: 24),
    ),
    'li': Style(margin: Margins.only(bottom: DesignTokens.spacingXS)),
    // The list's own gap follows its last item; a list inside an item sits
    // tight in it.
    'li:last-child': Style(margin: Margins(bottom: Margin.zero())),
    'li > ul, li > ol': Style(margin: Margins.zero),
    'h1': heading(24, 32),
    'h2': heading(22, 28),
    'h3': heading(20, 28),
    'h4': heading(18, 26),
    'h5': heading(16, 24),
    'h6': heading(16, 24, color: mutedColor),
    // A cooked poll's summary line carries the vote count as of cooking;
    // where the live poll cannot be drawn, better none than a wrong one.
    'div.poll-info': Style(display: Display.none),
    'img.emoji': Style(
      width: Width(20),
      height: Height(20),
      display: Display.inlineBlock,
      verticalAlign: VerticalAlign.middle,
    ),
  });
}

/// An inline picture has no text baseline; this says so when asked "dry",
/// as it already does in real layout.
///
/// flutter_html places a linked image in a baseline-aligned placeholder.
/// A paragraph measuring its intrinsic width (a table sizing its columns)
/// asks such children for a dry baseline, which RenderImage cannot give:
/// it threw, and the table cell was never laid out.
class _NoBaseline extends SingleChildRenderObjectWidget {
  const _NoBaseline({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderNoBaseline();
}

class _RenderNoBaseline extends RenderProxyBox {
  @override
  double? computeDryBaseline(BoxConstraints constraints, TextBaseline baseline) => null;

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) => null;
}
