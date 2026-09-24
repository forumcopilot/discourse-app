import 'package:html/dom.dart' as dom;
import 'package:flutter/foundation.dart' show compute;
import 'package:html/parser.dart' as html_parser;

import '../core/cache/lru_cache.dart';

import 'html_colors.dart';

/// A post's `cooked` HTML prepared for rendering, and the images and links
/// in it.
///
/// Discourse cooks Markdown to HTML on the server and hands us the result
/// in the post stream's `cooked` field. Everything worth extracting is
/// already marked up semantically — oneboxes carry `data-onebox-src`,
/// lazy videos carry `data-video-id`, lightboxed uploads wrap the
/// full-size href in `a.lightbox`. Reading those attributes is both
/// cheaper and more accurate than pattern-matching the markup as text,
/// which is what the inherited XenForo `BBCodeProcessor` did: its
/// `findPlainUrls` scanned the raw HTML with a bare `https?://\S+` regex,
/// so favicons, onebox thumbnails and avatar `src`s all came back as
/// "links in this post" and each got its own preview card.
///
/// Embeds are left in place: RichTextContent recognises Discourse's embed
/// markup (lazy videos, iframes, tweet oneboxes) and draws native
/// previews exactly where the web shows the player.
///
/// The anchor-collection rules below deliberately mirror
/// `PrettyText.extract_links` in the Discourse source
/// (`lib/pretty_text.rb`) — same selectors, same exclusions — so the app
/// agrees with the server about what counts as a link in a post.
class CookedContent {
  /// The cooked HTML, ready to hand to `RichTextContent`, minus what the
  /// web hides with CSS. Embeds (videos, tweets, iframes) stay where the
  /// author put them: RichTextContent draws each as a native preview.
  final String html;

  /// External links worth a preview. Excludes links Discourse already
  /// onebox'd — the server-rendered `aside.onebox` stays in [html] and is
  /// the better preview, since it costs no extra fetch and reflects what
  /// the forum itself decided to show.
  final List<String> linkUrls;

  /// Content images in document order, absolute, full-size where the
  /// lightbox gives us the original. Feeds the full-screen image viewer.
  /// Excludes emoji, avatars, site icons and onebox thumbnails.
  final List<String> imageUrls;

  const CookedContent({
    required this.html,
    required this.linkUrls,
    required this.imageUrls,
  });

  static const CookedContent empty = CookedContent(
    html: '',
    linkUrls: <String>[],
    imageUrls: <String>[],
  );

  /// Parses [cooked] and extracts the embedded media.
  ///
  /// [forumBaseUrl] resolves the relative URLs Discourse emits for local
  /// uploads (`/uploads/...`); pass the site's base URL.
  /// Parsed results by cooked HTML. A post's row is rebuilt from scratch
  /// every time it scrolls back into view, and the parse below is a full
  /// DOM build plus six selector sweeps; keyed by the string itself so an
  /// edited post (new cooked HTML) simply misses. Bounded, most recent
  /// kept — a long thread is a few hundred posts.
  static final LRUCache<String, CookedContent> _cache = LRUCache(maxSize: 400);

  /// Parses a page of posts on a worker isolate and files the results,
  /// so the frame that first shows each post finds its parse ready. If
  /// the frame comes first it simply parses on the spot as before.
  static Future<void> warm(List<String> cookedHtml, {required String forumBaseUrl}) async {
    final pending = cookedHtml
        .where((c) => !_cache.containsKey('$forumBaseUrl\u0000$c'))
        .toList();
    if (pending.isEmpty) return;
    try {
      final parsed = await compute(_parseBatch, (pending, forumBaseUrl));
      for (var i = 0; i < pending.length; i++) {
        _cache.put('$forumBaseUrl\u0000${pending[i]}', parsed[i]);
      }
    } catch (_) {
      // Best effort: the on-demand path still works.
    }
  }

  static List<CookedContent> _parseBatch((List<String>, String) args) {
    final (cooked, base) = args;
    return [for (final c in cooked) _parse(c, forumBaseUrl: base)];
  }

  static CookedContent parse(String cooked, {required String forumBaseUrl}) {
    final key = '$forumBaseUrl\u0000$cooked';
    final hit = _cache.get(key);
    if (hit != null) return hit;
    final parsed = _parse(cooked, forumBaseUrl: forumBaseUrl);
    _cache.put(key, parsed);
    return parsed;
  }

  static CookedContent _parse(String cooked, {required String forumBaseUrl}) {
    if (cooked.trim().isEmpty) return empty;

    final dom.Document document = html_parser.parse(cooked);
    final dom.Element? body = document.body;
    if (body == null) return CookedContent.empty.copyWithHtml(cooked);

    final origin = _origin(forumBaseUrl);
    final links = <String>{};
    final images = <String>{};

    // ---- 1. What web hides with CSS -----------------------------------
    // flutter_html has no stylesheet, so markup Discourse ships for CSS to
    // hide would be printed:
    //  * `.lightbox-wrapper .meta` — the upload's file name, dimensions and
    //    size ("image1672×941 318 KB"), which web shows only as an expand
    //    icon;
    //  * `.hidden` — e.g. the full issue body a GitHub onebox carries behind
    //    its two-line excerpt (web: `display: none`);
    //  * an inline `display: none` — older YouTube oneboxes ship a hidden
    //    thumbnail next to the player, which the image renderer would show.
    for (final node in body.querySelectorAll('.lightbox-wrapper .meta, .hidden').toList()) {
      node.remove();
    }
    for (final node in body.querySelectorAll('[style]').toList()) {
      if (_hiddenInline.hasMatch(node.attributes['style'] ?? '')) node.remove();
    }

    // ---- 2. Author colours ------------------------------------------
    // `<font color>` from the BBCode `[color]` tag. flutter_html parses a
    // `#…` value as an integer and throws on anything but hex digits,
    // taking the whole post with it (`#PG985740` on community.robotime.com),
    // and knows only 16 colour names. Normalise to `#rrggbb`, or drop what a
    // browser would ignore; RichTextContent then adapts it to the theme.
    for (final el in body.querySelectorAll('[color]')) {
      final normalized = normalizeHtmlColor(el.attributes['color']);
      if (normalized == null) {
        el.attributes.remove('color');
      } else {
        el.attributes['color'] = normalized;
      }
    }

    // ---- 3. Images ---------------------------------------------------
    // Lightboxed uploads: <div class="lightbox-wrapper">
    //   <a class="lightbox" href="FULL"><img src="RESIZED"></a></div>
    // The anchor href is the original; prefer it over the <img src>.
    for (final anchor in body.querySelectorAll('a.lightbox[href]')) {
      final href = anchor.attributes['href'] ?? '';
      if (href.isNotEmpty) images.add(_absolute(href, origin));
    }
    for (final img in body.querySelectorAll('img[src]')) {
      if (_isDecorativeImage(img)) continue;
      // Already captured via its lightbox anchor.
      if (_hasAncestorMatching(img, (e) => _classes(e).contains('lightbox'))) {
        continue;
      }
      final src = img.attributes['src'] ?? '';
      if (src.isNotEmpty) images.add(_absolute(src, origin));
    }

    // ---- 4. Remaining anchors ----------------------------------------
    // Mirrors PrettyText.extract_links: skip anchors inside quotes,
    // oneboxes and elided sections, skip image-wrapping anchors, skip
    // in-page fragments.
    for (final anchor in body.querySelectorAll('a[href]')) {
      final href = (anchor.attributes['href'] ?? '').trim();
      if (href.isEmpty || href.startsWith('#')) continue;

      final classes = _classes(anchor);
      // Mentions and category/tag hashtags are in-app navigation, not
      // content links; attachment anchors belong to the attachment list;
      // lightbox anchors are images.
      if (classes.contains('mention') ||
          classes.contains('hashtag-cooked') ||
          classes.contains('attachment') ||
          classes.contains('lightbox') ||
          classes.contains('onebox')) {
        continue;
      }
      if (anchor.querySelector('img') != null) continue;
      if (_hasAncestorMatching(anchor, (e) {
        final c = _classes(e);
        return (e.localName == 'aside' &&
                (c.contains('quote') || c.contains('onebox'))) ||
            c.contains('elided') ||
            c.contains('lazy-video-container');
      })) {
        continue;
      }
      if (!_isExternalHttpUrl(href, origin)) continue;
      links.add(href);
    }

    return CookedContent(
      html: body.innerHtml,
      linkUrls: links.toList(),
      imageUrls: images.toList(),
    );
  }

  /// [html] with the web's click-count badge after each link that was
  /// followed (`link_counts`; see FCPost.linkClicks): a
  /// `<span class="link-clicks">1.2k</span>` RichTextContent draws as a
  /// small pill. Mentions, hashtags, images, attachments and the links
  /// inside quotes and previews get none, as on the web.
  static String withLinkClicks(String html, Map<String, int> clicks, {required String forumBaseUrl}) {
    if (clicks.isEmpty || html.isEmpty) return html;
    final origin = _origin(forumBaseUrl);
    String norm(String u) {
      var a = _absolute(u.trim(), origin);
      while (a.endsWith('/')) {
        a = a.substring(0, a.length - 1);
      }
      return a;
    }

    final byUrl = {for (final e in clicks.entries) norm(e.key): e.value};
    final fragment = html_parser.parseFragment(html);
    var changed = false;
    for (final a in fragment.querySelectorAll('a[href]')) {
      final c = _classes(a);
      if (c.contains('mention') || c.contains('mention-group') || c.contains('hashtag-cooked') ||
          c.contains('lightbox') || c.contains('attachment') || c.contains('onebox')) {
        continue;
      }
      if (_hasAncestorMatching(a, (e) => e.localName == 'aside')) continue;
      final n = byUrl[norm(a.attributes['href']!)];
      if (n == null || n <= 0) continue;
      final badge = dom.Element.tag('span')
        ..classes.add('link-clicks')
        ..text = formatClickCount(n);
      final parent = a.parentNode;
      if (parent == null) continue;
      parent.nodes.insert(parent.nodes.indexOf(a) + 1, badge);
      changed = true;
    }
    return changed ? fragment.outerHtml : html;
  }

  /// 253 → "253", 1234 → "1.2k", 12345 → "12k", 1234567 → "1.2M" — the
  /// web's short number format.
  static String formatClickCount(int n) {
    String short(double v, String unit) {
      final s = v >= 10 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
      return '${s.endsWith('.0') ? s.substring(0, s.length - 2) : s}$unit';
    }

    if (n >= 1000000) return short(n / 1000000, 'M');
    if (n >= 1000) return short(n / 1000, 'k');
    return '$n';
  }

  CookedContent copyWithHtml(String newHtml) => CookedContent(
        html: newHtml,
        linkUrls: linkUrls,
        imageUrls: imageUrls,
      );

  static final RegExp _hiddenInline =
      RegExp(r'(^|;)\s*display\s*:\s*none\b', caseSensitive: false);

  // -------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------

  static Set<String> _classes(dom.Element element) =>
      (element.attributes['class'] ?? '')
          .split(RegExp(r'\s+'))
          .where((c) => c.isNotEmpty)
          .toSet();

  /// Emoji, avatars, favicons and onebox thumbnails are chrome, not
  /// content — they must never enter the image gallery.
  static bool _isDecorativeImage(dom.Element img) {
    final classes = _classes(img);
    if (classes.contains('emoji') ||
        classes.contains('avatar') ||
        classes.contains('site-icon') ||
        classes.contains('thumbnail')) {
      return true;
    }
    return _hasAncestorMatching(img, (e) {
      final c = _classes(e);
      return (e.localName == 'aside' && c.contains('onebox')) ||
          c.contains('lazy-video-container');
    });
  }

  static bool _hasAncestorMatching(
      dom.Element element, bool Function(dom.Element) test) {
    dom.Element? parent = element.parent;
    while (parent != null) {
      if (test(parent)) return true;
      parent = parent.parent;
    }
    return false;
  }

  /// Scheme + host + port of [baseUrl], or an empty string when it cannot
  /// be parsed (in which case same-origin filtering is simply skipped).
  static String _origin(String baseUrl) {
    final uri = Uri.tryParse(baseUrl.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return '';
    return uri.hasPort
        ? '${uri.scheme}://${uri.host}:${uri.port}'
        : '${uri.scheme}://${uri.host}';
  }

  static String _absolute(String url, String origin) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('//')) return 'https:$url';
    if (origin.isEmpty) return url;
    return url.startsWith('/') ? '$origin$url' : '$origin/$url';
  }

  /// True when [url] is an absolute http(s) link pointing somewhere other
  /// than this forum. Relative URLs are by definition same-forum, and
  /// non-http schemes (`mailto:`, `tel:`) are not previewable.
  static bool _isExternalHttpUrl(String url, String origin) {
    final trimmed = url.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return false;
    }
    if (origin.isEmpty) return true;
    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.host.isEmpty) return false;
    final originUri = Uri.parse(origin);
    return uri.host.toLowerCase() != originUri.host.toLowerCase();
  }
}
