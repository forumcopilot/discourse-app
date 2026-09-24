import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:url_launcher/url_launcher_string.dart';

import 'brand_image.dart';
import 'discourse_blocks.dart';
import 'embed_cards.dart';
import 'onebox_card.dart';
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

  const RichTextContent({
    super.key,
    required this.siteContext,
    required this.content,
    this.callbacks,
    this.pollBuilder,
    this.webUrl,
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

    final body = textTheme.bodyMedium ?? const TextStyle();
    final bodyColor = body.color ?? colorScheme.onSurface;
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
      launchUrlString(resolved, mode: LaunchMode.externalApplication);
    }

    return PostBodyFallback(
      html: html,
      child: Html(
      data: html,
      onLinkTap: (url, attributes, _) {
        if (url == null || url.isEmpty) return;
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
        // Everything else goes through the URL callback (which handles
        // same-forum topic/post links in-app and external launch itself).
        if (callbacks?.onUrlTap != null) {
          callbacks!.onUrlTap!(resolved);
          return;
        }
        // ignore: discarded_futures
        launchUrlString(resolved, mode: LaunchMode.externalApplication);
      },
      style: _stylesFor(colorScheme, body, bodyColor, mutedColor, accent),
      // Resolve relative URLs (img src, a href) to absolute against the
      // forum base. For Discourse emoji (`<img class="emoji" alt=":wave:">`)
      // we look up the alt-shortcode in the Unicode emoji table and render
      // the system glyph instead of fetching the PNG — looks native to
      // the OS, works offline, no network round-trips. Falls back to the
      // PNG for forum-custom emoji that aren't in standard Unicode.
      extensions: [
        PostTableExtension(colorScheme: colorScheme),
        _EmbedExtension(resolve: _resolveUrl, onOpen: openEmbed),
        DiscourseBlocksExtension(onOpen: openEmbed, pollBuilder: pollBuilder),
        // Link previews: a native card; what is inside the preview's body is
        // rendered by a nested RichTextContent, so it keeps every rule here.
        OneboxExtension(
          resolve: _resolveUrl,
          onOpen: openEmbed,
          renderHtml: (html) => RichTextContent(
            siteContext: siteContext,
            content: html,
            callbacks: callbacks,
            webUrl: webUrl,
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
            launchUrlString(resolved, mode: LaunchMode.externalApplication);
          },
          colorScheme: colorScheme,
          textTheme: Theme.of(context).textTheme,
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
            final codeBlock = Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                // Plain Text, not SelectableText: SelectableText claims
                // horizontal drags for text selection, which swallows the
                // scroll gesture and leaves the block clipped with no way
                // to reach the rest of the line. Scrolling matters more
                // here than selecting.
                child: Text(
                  // Trailing newlines are common in cooked <pre> and would
                  // otherwise leave a blank band inside the block.
                  code.replaceAll(RegExp(r'\n+$'), ''),
                  style: body.copyWith(
                    fontFamily: 'monospace',
                    fontSize: (body.fontSize ?? 14) * 0.92,
                    height: 1.35,
                  ),
                ),
              ),
            );
            // A Mermaid diagram is drawn by JavaScript on the web; the app
            // shows its source, says what it is, and offers the web.
            if (extensionContext.attributes['data-code-wrap'] != 'mermaid') {
              return codeBlock;
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.account_tree_outlined, size: 18, color: mutedColor),
                      const SizedBox(width: 6),
                      Text('Mermaid',
                          style: body.copyWith(color: mutedColor, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      if (webUrl != null)
                        Builder(
                          builder: (context) => TextButton.icon(
                            onPressed: () => openEmbed(webUrl!),
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: Text(AppLocalizations.of(context)?.viewOnWeb ?? 'View on Web'),
                          ),
                        ),
                    ],
                  ),
                ),
                codeBlock,
              ],
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
                      // Bump emoji slightly so they sit nicely with text.
                      fontSize: (body.fontSize ?? 14) * 1.15,
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
            final w = double.tryParse(
                    extensionContext.attributes['width'] ?? '') ??
                (isEmoji ? 20 : null);
            final h = double.tryParse(
                    extensionContext.attributes['height'] ?? '') ??
                (isEmoji ? 20 : null);
            // A onebox's avatar (a tweet's author, a GitHub user) is a small
            // square beside the text on the web; at its own 400×400 it
            // would fill the post.
            if (classes.split(RegExp(r'\s+')).contains('onebox-avatar')) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  resolved,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) => const SizedBox(width: 48, height: 48),
                ),
              );
            }
            // Image.network cannot decode SVG (uploads, badges, GitHub's
            // favicon) and showed the alt text instead. BrandImage draws it
            // with flutter_svg from the disk cache, falling back the same way
            // when the file is missing or not SVG.
            final isSvg = BrandImage.isSvg(resolved);
            Widget fallback(BuildContext _) =>
                Text(alt, style: TextStyle(color: mutedColor));
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
            // Route content-image taps to the in-app viewer (emoji stay
            // plain inline glyphs/images).
            final onImageTap = callbacks?.onImageTap;
            if (isEmoji || onImageTap == null) return image;
            return Builder(
              builder: (imageContext) => GestureDetector(
                onTap: () => onImageTap(resolved, imageContext, resolved),
                child: image,
              ),
            );
          },
        ),
        // Web draws <hr> as a thin rule in the border colour. flutter_html's
        // default is a black Border.all box with auto margins, which in a
        // post left a heavy rule and ~280dp of blank space under it.
        TagExtension(
          tagsToExtend: {'hr'},
          builder: (_) => Padding(
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
            child: SizedBox(
              width: double.infinity,
              child: Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.outlineVariant,
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
    if (url.startsWith('/')) return '$base$url';
    return '$base/$url';
  }
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
  const PostBodyFallback({super.key, required this.html, required super.child});

  final String html;

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
      return Text(fallback.plainText, style: Theme.of(context).textTheme.bodyMedium);
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
    return WidgetSpan(child: SizedBox(width: double.infinity, child: card));
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
class _AttachmentLinkExtension extends HtmlExtension {
  const _AttachmentLinkExtension({
    required this.onTap,
    required this.onShare,
    required this.colorScheme,
    required this.textTheme,
  });

  final void Function(String href) onTap;
  final void Function(String href) onShare;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

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

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      // minWidth infinity makes the card fill the line box, so it reads as
      // a row in a list rather than a chip floating in a paragraph —
      // matching the composer's attachment list.
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Padding(
        padding: EdgeInsets.symmetric(vertical: DesignTokens.spacingXS),
        child: Material(
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            side: BorderSide(
              color: colorScheme.outlineVariant
                  .withValues(alpha: DesignTokens.opacityDivider),
              width: DesignTokens.borderWidthThin,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: href.isEmpty ? null : () => onTap(href),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingS,
                vertical: 6,
              ),
              child: Row(
                children: [
                  // Same 48px type tile the composer draws, from the same
                  // helpers, so an attachment looks identical whether you
                  // are about to post it or reading it back.
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: getFileTypeColor(label),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      getFileIcon(getFileType(label)),
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurface),
                        ),
                        SizedBox(height: DesignTokens.spacingXS / 2),
                        Text(
                          [
                            getFileType(label).toUpperCase(),
                            if (size != null && size.isNotEmpty) size,
                          ].join(' • '),
                          style: textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: DesignTokens.spacingXS),
                  IconButton(
                    tooltip: 'Share',
                    visualDensity: VisualDensity.compact,
                    onPressed: href.isEmpty ? null : () => onShare(href),
                    icon: Icon(Icons.share_outlined,
                        size: DesignTokens.iconSizeM,
                        color: colorScheme.onSurfaceVariant),
                  ),
                  IconButton(
                    tooltip: 'Download',
                    visualDensity: VisualDensity.compact,
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
  return _styleCache.putIfAbsent(key, () => {
    'body': Style(
      margin: Margins.zero,
      padding: HtmlPaddings.zero,
      fontSize: FontSize(body.fontSize ?? 14),
      color: bodyColor,
      lineHeight: const LineHeight(1.4),
    ),
    'p': Style(
      margin: Margins.only(bottom: 8),
      padding: HtmlPaddings.zero,
    ),
    'a': Style(
      color: accent,
      textDecoration: TextDecoration.underline,
    ),
    'a.mention': Style(
      color: accent,
      fontWeight: FontWeight.w600,
      textDecoration: TextDecoration.none,
    ),
    'a.hashtag-cooked': Style(
      color: accent,
      fontWeight: FontWeight.w500,
      textDecoration: TextDecoration.none,
    ),
    'aside.quote': Style(
      margin: Margins.symmetric(vertical: 8),
      padding: HtmlPaddings.symmetric(horizontal: 12, vertical: 8),
      backgroundColor: colorScheme.surfaceContainerHighest,
      border: Border(
        left: BorderSide(color: accent, width: 3),
      ),
    ),
    'aside.quote .title': Style(
      fontSize: FontSize(13),
      fontWeight: FontWeight.w600,
      color: mutedColor,
      margin: Margins.only(bottom: 4),
    ),
    'blockquote': Style(
      margin: Margins.symmetric(vertical: 8),
      padding: HtmlPaddings.symmetric(horizontal: 12, vertical: 8),
      backgroundColor: colorScheme.surfaceContainerHighest,
      border: Border(
        left: BorderSide(color: accent, width: 3),
      ),
    ),
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
    'code': Style(
      backgroundColor: colorScheme.surfaceContainerHighest,
      padding: HtmlPaddings.symmetric(horizontal: 4, vertical: 2),
      fontSize: FontSize((body.fontSize ?? 14) * 0.92),
      fontFamily: 'monospace',
    ),
    'pre': Style(
      margin: Margins.symmetric(vertical: 8),
      padding: HtmlPaddings.all(12),
      backgroundColor: colorScheme.surfaceContainerHighest,
      fontSize: FontSize((body.fontSize ?? 14) * 0.92),
      fontFamily: 'monospace',
    ),
    'pre code': Style(
      backgroundColor: Colors.transparent,
      padding: HtmlPaddings.zero,
    ),
    'ul, ol': Style(
      margin: Margins.symmetric(vertical: 4),
      padding: HtmlPaddings.only(left: 24),
    ),
    'li': Style(margin: Margins.only(bottom: 2)),
    'h1': Style(
      fontSize: FontSize((body.fontSize ?? 14) * 1.7),
      fontWeight: FontWeight.bold,
      margin: Margins.only(top: 12, bottom: 6),
    ),
    'h2': Style(
      fontSize: FontSize((body.fontSize ?? 14) * 1.45),
      fontWeight: FontWeight.bold,
      margin: Margins.only(top: 10, bottom: 4),
    ),
    'h3': Style(
      fontSize: FontSize((body.fontSize ?? 14) * 1.25),
      fontWeight: FontWeight.bold,
      margin: Margins.only(top: 8, bottom: 4),
    ),
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
