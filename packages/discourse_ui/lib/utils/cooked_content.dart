import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import 'media_url_utils.dart';

/// The media Discourse embedded in a post, pulled out of the server's
/// `cooked` HTML.
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
/// The anchor-collection rules below deliberately mirror
/// `PrettyText.extract_links` in the Discourse source
/// (`lib/pretty_text.rb`) — same selectors, same exclusions — so the app
/// agrees with the server about what counts as a link in a post.
class CookedContent {
  /// The cooked HTML with natively-rendered embeds removed, ready to hand
  /// to `RichTextContent`. Nodes are stripped only when the app renders
  /// the same thing as a native card below the post (YouTube, Twitter/X),
  /// so nothing is shown twice.
  final String html;

  /// YouTube watch URLs, for `VideoCard`.
  final List<String> youtubeUrls;

  /// Twitter/X status permalinks, for `TwitterCard`.
  final List<String> twitterUrls;

  /// Everything else worth a `LinkPreviewCard`. Excludes links Discourse
  /// already onebox'd — the server-rendered `aside.onebox` stays in
  /// [html] and is the better preview, since it costs no extra fetch and
  /// reflects what the forum itself decided to show.
  final List<String> linkUrls;

  /// Content images in document order, absolute, full-size where the
  /// lightbox gives us the original. Feeds the full-screen image viewer.
  /// Excludes emoji, avatars, site icons and onebox thumbnails.
  final List<String> imageUrls;

  const CookedContent({
    required this.html,
    required this.youtubeUrls,
    required this.twitterUrls,
    required this.linkUrls,
    required this.imageUrls,
  });

  static const CookedContent empty = CookedContent(
    html: '',
    youtubeUrls: <String>[],
    twitterUrls: <String>[],
    linkUrls: <String>[],
    imageUrls: <String>[],
  );

  /// Parses [cooked] and extracts the embedded media.
  ///
  /// [forumBaseUrl] resolves the relative URLs Discourse emits for local
  /// uploads (`/uploads/...`); pass the site's base URL.
  static CookedContent parse(String cooked, {required String forumBaseUrl}) {
    if (cooked.trim().isEmpty) return empty;

    final dom.Document document = html_parser.parse(cooked);
    final dom.Element? body = document.body;
    if (body == null) return CookedContent.empty.copyWithHtml(cooked);

    final origin = _origin(forumBaseUrl);
    final youtube = <String>{};
    final twitter = <String>{};
    final links = <String>{};
    final images = <String>{};

    // ---- 1. Lazy-video containers (discourse-lazy-videos) -------------
    // <div class="youtube-onebox lazy-video-container" data-video-id="..."
    //      data-provider-name="youtube"><a href="..."><img ...></a></div>
    // flutter_html renders the inner thumbnail as a plain image with no
    // play affordance, so we drop the node and show a VideoCard.
    for (final node in body.querySelectorAll('.lazy-video-container').toList()) {
      final provider =
          (node.attributes['data-provider-name'] ?? '').toLowerCase();
      final videoId = node.attributes['data-video-id'] ?? '';
      final href = node.querySelector('a[href]')?.attributes['href'] ?? '';

      if (provider == 'youtube' && videoId.isNotEmpty) {
        youtube.add(MediaUrlUtils.youtubeWatchUrl(videoId));
        node.remove();
      } else if (href.isNotEmpty && MediaUrlUtils.isYoutubeUrl(href)) {
        youtube.add(href);
        node.remove();
      } else if (href.isNotEmpty && _isExternalHttpUrl(href, origin)) {
        // Vimeo/TikTok/etc. — VideoCard is YouTube-only, so these fall
        // through to a normal link preview. Keep the node: its thumbnail
        // is still the most useful thing we can render inline.
        links.add(href);
      }
    }

    // ---- 2. Video embeds (non-lazy oneboxes, .video-container) --------
    // flutter_html cannot render an <iframe> at all — these would show as
    // a blank gap. Pull the YouTube id out of the embed src instead.
    for (final iframe in body.querySelectorAll('iframe[src]').toList()) {
      final src = iframe.attributes['src'] ?? '';
      final videoId = _youtubeIdFromEmbedSrc(src);
      if (videoId == null) continue;
      youtube.add(MediaUrlUtils.youtubeWatchUrl(videoId));
      _removeEmbedWrapper(iframe);
    }

    // ---- 3. Oneboxes -------------------------------------------------
    // Discourse's own link extractor keys on aside.onebox[data-onebox-src]
    // (lib/pretty_text.rb), so we do too.
    for (final onebox in body.querySelectorAll('aside.onebox').toList()) {
      final src = onebox.attributes['data-onebox-src'] ??
          onebox.querySelector('header.source a[href]')?.attributes['href'] ??
          onebox.querySelector('a[href]')?.attributes['href'] ??
          '';
      if (src.isEmpty) continue;

      if (MediaUrlUtils.isYoutubeUrl(src)) {
        youtube.add(src);
        onebox.remove();
      } else if (MediaUrlUtils.isTwitterUrl(src)) {
        twitter.add(src);
        onebox.remove();
      }
      // Any other onebox stays put — the server already rendered the
      // preview, so adding a LinkPreviewCard would duplicate it.
    }

    // ---- 4. Images ---------------------------------------------------
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

    // ---- 5. Remaining anchors ----------------------------------------
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

      if (MediaUrlUtils.isYoutubeUrl(href)) {
        youtube.add(href);
      } else if (MediaUrlUtils.isTwitterUrl(href)) {
        twitter.add(href);
      } else {
        links.add(href);
      }
    }

    return CookedContent(
      html: body.innerHtml,
      youtubeUrls: youtube.toList(),
      twitterUrls: twitter.toList(),
      // A link that also produced a video/tweet card would show twice.
      linkUrls: links
          .where((u) => !youtube.contains(u) && !twitter.contains(u))
          .toList(),
      imageUrls: images.toList(),
    );
  }

  CookedContent copyWithHtml(String newHtml) => CookedContent(
        html: newHtml,
        youtubeUrls: youtubeUrls,
        twitterUrls: twitterUrls,
        linkUrls: linkUrls,
        imageUrls: imageUrls,
      );

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

  /// Removes the wrapper Discourse puts around a video embed so we don't
  /// leave an empty `.video-container` behind after taking the iframe.
  static void _removeEmbedWrapper(dom.Element iframe) {
    final parent = iframe.parent;
    if (parent != null &&
        (_classes(parent).contains('video-container') ||
            (parent.localName == 'aside' &&
                _classes(parent).contains('onebox')))) {
      parent.remove();
      return;
    }
    iframe.remove();
  }

  static String? _youtubeIdFromEmbedSrc(String src) {
    final match = RegExp(
      r'^(?:https?:)?\/\/(?:www\.)?(?:youtube\.com|youtube-nocookie\.com)\/embed\/([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    ).firstMatch(src.trim());
    return match?.group(1);
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
