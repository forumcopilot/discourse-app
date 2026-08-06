import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'post_content_callbacks.dart' show PostContentCallbacks;

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

  const RichTextContent({
    super.key,
    required this.siteContext,
    required this.content,
    this.callbacks,
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

    return Html(
      data: content,
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
      style: {
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
        'aside.quote blockquote': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
        ),
        'blockquote': Style(
          margin: Margins.symmetric(vertical: 8),
          padding: HtmlPaddings.symmetric(horizontal: 12, vertical: 8),
          backgroundColor: colorScheme.surfaceContainerHighest,
          border: Border(
            left: BorderSide(color: accent, width: 3),
          ),
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
        'img.emoji': Style(
          width: Width(20),
          height: Height(20),
          display: Display.inlineBlock,
          verticalAlign: VerticalAlign.middle,
        ),
      },
      // Resolve relative URLs (img src, a href) to absolute against the
      // forum base. For Discourse emoji (`<img class="emoji" alt=":wave:">`)
      // we look up the alt-shortcode in the Unicode emoji table and render
      // the system glyph instead of fetching the PNG — looks native to
      // the OS, works offline, no network round-trips. Falls back to the
      // PNG for forum-custom emoji that aren't in standard Unicode.
      extensions: [
        TagExtension(
          tagsToExtend: {'img'},
          builder: (extensionContext) {
            final src = extensionContext.attributes['src'];
            final alt = extensionContext.attributes['alt'] ?? '';
            final classes = (extensionContext.attributes['class'] ?? '');
            final isEmoji = classes.contains('emoji');

            if (isEmoji) {
              final shortcode = alt.replaceAll(':', '').trim();
              if (shortcode.isNotEmpty) {
                final unicode = Emoji.byShortName(shortcode)?.char;
                if (unicode != null && unicode.isNotEmpty) {
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
            final image = Image.network(
              resolved,
              width: w,
              height: h,
              errorBuilder: (_, __, ___) =>
                  Text(alt, style: TextStyle(color: mutedColor)),
            );
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
      ],
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
