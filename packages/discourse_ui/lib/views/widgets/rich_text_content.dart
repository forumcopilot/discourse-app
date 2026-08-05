import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'custom_bb_stylesheet.dart' show BBCodeCallbacks;

/// Renders post content. The data we get from Discourse's `/t/{id}.json`
/// post stream is the `cooked` HTML field — i.e. server-rendered Markdown
/// + Discourse extensions (emoji, mentions, quotes, oneboxes, …) already
/// expanded to HTML.
///
/// This widget accepts the same constructor shape the inherited XF code
/// has been calling so the swap is a drop-in replacement; the
/// [BBCodeCallbacks] parameter is now ignored (kept for source compat —
/// HTML link/image taps go through the default URL launcher).
class RichTextContent extends StatelessWidget {
  final SiteContext siteContext;
  final String content;
  final BBCodeCallbacks? callbacks;

  const RichTextContent({
    super.key,
    required this.siteContext,
    required this.content,
    this.callbacks,
  });

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
      onLinkTap: (url, _, __) {
        if (url == null || url.isEmpty) return;
        final resolved = _resolveUrl(url);
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
            return Image.network(
              resolved,
              width: w,
              height: h,
              errorBuilder: (_, __, ___) =>
                  Text(alt, style: TextStyle(color: mutedColor)),
            );
          },
        ),
      ],
    );
  }

  String _resolveUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('//')) return 'https:$url';
    final base = siteContext.site.url;
    if (url.startsWith('/')) return '$base$url';
    return '$base/$url';
  }
}
