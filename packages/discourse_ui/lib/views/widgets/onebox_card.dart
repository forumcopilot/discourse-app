import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;

import '../../theme/design_tokens.dart';
import 'brand_image.dart';
import 'post_body_extensions.dart';

/// A Discourse link preview (`aside.onebox`) as the web draws it: a bordered
/// card with the site's icon and name, the title in the link colour, the
/// excerpt, and a small thumbnail beside the text.
///
/// flutter_html drew the onebox's raw markup instead — favicons at full size,
/// thumbnails across the whole column, the title as an underlined link, no
/// card (11,479 posts on 825 forums in the audit). The header, title and
/// thumbnail are read from the cooked markup and laid out natively; the rest
/// of the body (excerpt, GitHub's "opened … by …" line, a file's code, a
/// tweet's photos) is still rendered as HTML through [renderHtml], so links,
/// local dates, code blocks and videos inside keep working.
///
/// [renderHtml] draws markup at the given text size and colour (the card's
/// excerpt and metadata roles), or the caller's when not given.
typedef OneboxHtmlRenderer = Widget Function(String html, {double? fontSize, Color? color});

class OneboxExtension extends HtmlExtension {
  const OneboxExtension({
    required this.renderHtml,
    required this.resolve,
    required this.onOpen,
  });

  final OneboxHtmlRenderer renderHtml;
  final String Function(String url) resolve;
  final void Function(String url) onOpen;

  @override
  Set<String> get supportedTags => const {};

  @override
  bool matches(ExtensionContext context) =>
      context.elementName == 'aside' && context.classes.contains('onebox');

  @override
  InlineSpan build(ExtensionContext context) {
    final element = context.element;
    final data = element == null ? null : OneboxData.fromElement(element, resolve: resolve);
    if (data == null) return TextSpan(children: context.inlineSpanChildren);
    return WidgetSpan(
      child: SizedBox(
        width: double.infinity,
        child: withBlockGap(
          context,
          OneboxCard(data: data, renderHtml: renderHtml, onOpen: onOpen),
        ),
      ),
    );
  }
}

enum OneboxKind { generic, githubIssue, githubPullRequest, githubCommit, pdf, tweet }

/// What a onebox's cooked markup says, split into the parts the card lays
/// out itself and the remainder it renders as HTML.
class OneboxData {
  OneboxData({
    required this.kind,
    required this.url,
    required this.restHtml,
    this.siteName,
    this.siteIconUrl,
    this.title,
    this.titleUrl,
    this.thumbnailUrl,
    this.thumbnailRatio,
    this.metadataHtml,
    this.handle,
    this.date,
    this.dateUrl,
    this.likes,
    this.retweets,
  });

  final OneboxKind kind;
  final String? url;
  final String? siteName;
  final String? siteIconUrl;
  final String? title;
  final String? titleUrl;

  /// The small picture beside the text (for a tweet, the author's avatar).
  final String? thumbnailUrl;
  final double? thumbnailRatio;

  /// The body without the parts drawn natively; empty when nothing is left.
  final String restHtml;
  final String? metadataHtml;

  // Tweets.
  final String? handle;
  final String? date;
  final String? dateUrl;
  final String? likes;
  final String? retweets;

  static OneboxData? fromElement(dom.Element aside, {required String Function(String) resolve}) {
    final classes = aside.classes;
    final header = aside.querySelector('header.source');
    final headerLink = header?.querySelector('a[href]');
    final article = aside.querySelector('article.onebox-body');
    if (article == null) return null;
    final body = article.clone(true);

    String? abs(String? u) => (u == null || u.trim().isEmpty) ? null : resolve(u.trim());
    String? text(dom.Element? e) {
      final t = e?.text.replaceAll(RegExp(r'\s+'), ' ').trim();
      return (t == null || t.isEmpty) ? null : t;
    }

    final kind = classes.contains('twitterstatus')
        ? OneboxKind.tweet
        : classes.contains('githubissue')
            ? OneboxKind.githubIssue
            : classes.contains('githubpullrequest')
                ? OneboxKind.githubPullRequest
                : classes.contains('githubcommit')
                    ? OneboxKind.githubCommit
                    : classes.contains('pdf')
                        ? OneboxKind.pdf
                        : OneboxKind.generic;

    // Title: the first heading, wherever the template puts it (GitHub nests
    // it in .github-info-container).
    final heading = body.querySelector('h3, h4');
    final title = text(heading);
    final titleUrl = abs(heading?.querySelector('a[href]')?.attributes['href']);
    heading?.remove();

    // The picture beside the text.
    String? thumb;
    double? ratio;
    dom.Element? pic;
    if (kind == OneboxKind.tweet) {
      pic = body.querySelector('img.onebox-avatar');
    } else {
      for (final img in body.querySelectorAll('img')) {
        final c = img.classes;
        if (c.contains('emoji') || c.contains('onebox-avatar-inline') || c.contains('site-icon')) continue;
        if (_inside(img, 'aspect-image-full-size')) continue;
        pic = img;
        break;
      }
    }
    if (pic != null) {
      thumb = abs(pic.attributes['src']);
      final w = double.tryParse(pic.attributes['width'] ?? '');
      final h = double.tryParse(pic.attributes['height'] ?? '');
      if (w != null && h != null && w > 0 && h > 0) ratio = w / h;
      final wrapper = pic.parent;
      if (wrapper != null && wrapper.classes.contains('aspect-image')) {
        wrapper.remove();
      } else {
        pic.remove();
      }
    }

    // Parts the card draws itself.
    String? handle, date, dateUrl, likes, retweets;
    if (kind == OneboxKind.tweet) {
      final screenName = body.querySelector('.twitter-screen-name');
      handle = text(screenName);
      screenName?.remove();
      final dateBox = body.querySelector('div.date');
      final stamp = dateBox?.querySelector('a[href]');
      date = text(stamp);
      dateUrl = abs(stamp?.attributes['href']);
      likes = text(dateBox?.querySelector('.like'));
      retweets = text(dateBox?.querySelector('.retweet'));
      dateBox?.remove();
    }
    for (final e in body.querySelectorAll('.github-icon-container, .pdf-onebox-logo')) {
      final a = e.parent;
      (a != null && a.localName == 'a' && a.text.trim().isEmpty ? a : e).remove();
    }
    // Paragraphs left empty by a template (Amazon ships `<p><strong></strong></p>`).
    for (final p in body.querySelectorAll('p, div')) {
      if (p.text.trim().isEmpty && p.querySelector('img, video, audio, iframe, pre, svg') == null) {
        p.remove();
      }
    }

    final rest = body.querySelector('img, video, audio, iframe, pre') != null ||
            body.text.trim().isNotEmpty
        ? body.innerHtml.trim()
        : '';
    final metadata = aside.querySelector('.onebox-metadata');
    final siteName = text(headerLink) ?? text(header);

    return OneboxData(
      kind: kind,
      url: abs(aside.attributes['data-onebox-src']) ?? abs(headerLink?.attributes['href']) ?? titleUrl,
      siteName: siteName,
      siteIconUrl: abs(header?.querySelector('img.site-icon')?.attributes['src']),
      title: kind == OneboxKind.pdf && title != null ? _decoded(title) : title,
      titleUrl: titleUrl,
      thumbnailUrl: thumb,
      thumbnailRatio: ratio,
      restHtml: rest,
      metadataHtml: (metadata == null || metadata.text.trim().isEmpty) ? null : metadata.innerHtml,
      handle: handle,
      date: date,
      dateUrl: dateUrl,
      likes: likes,
      retweets: retweets,
    );
  }

  static bool _inside(dom.Element e, String cls) {
    var p = e.parent;
    while (p != null) {
      if (p.classes.contains(cls)) return true;
      p = p.parent;
    }
    return false;
  }

  static String _decoded(String s) {
    try {
      return Uri.decodeComponent(s);
    } catch (_) {
      return s;
    }
  }
}

class OneboxCard extends StatelessWidget {
  const OneboxCard({
    super.key,
    required this.data,
    required this.renderHtml,
    required this.onOpen,
  });

  final OneboxData data;
  final OneboxHtmlRenderer renderHtml;
  final void Function(String url) onOpen;

  /// The excerpt's size: bodyMedium, under the card's titleMedium title.
  static const double excerptSize = 14;

  /// The metadata line's size: bodySmall.
  static const double metadataSize = 12;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final target = data.titleUrl ?? data.url;
    final muted = colorScheme.onSurfaceVariant;

    final header = data.siteName == null
        ? null
        : Row(
            children: [
              if (data.siteIconUrl != null) ...[
                SizedBox(width: 16, height: 16, child: _picture(data.siteIconUrl!, BoxFit.contain)),
                const SizedBox(width: DesignTokens.spacingS),
              ],
              Expanded(
                child: Text(
                  data.siteName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(color: muted),
                ),
              ),
            ],
          );

    final title = data.title == null
        ? null
        : Text(
            data.title!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium?.copyWith(
              color: data.kind == OneboxKind.tweet ? colorScheme.onSurface : colorScheme.primary,
            ),
          );

    final rest = data.restHtml.isEmpty
        ? null
        : renderHtml(data.restHtml, fontSize: excerptSize, color: muted);

    Widget? leading;
    switch (data.kind) {
      case OneboxKind.githubIssue:
      case OneboxKind.githubPullRequest:
      case OneboxKind.githubCommit:
        leading = Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            switch (data.kind) {
              OneboxKind.githubIssue => Icons.adjust,
              OneboxKind.githubPullRequest => Icons.merge_type,
              _ => Icons.commit,
            },
            size: DesignTokens.iconSizeL,
            color: muted,
          ),
        );
      case OneboxKind.pdf:
        leading = Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.error,
            borderRadius: BorderRadius.circular(DesignTokens.radiusS),
          ),
          child: Text('PDF', style: textTheme.labelSmall?.copyWith(color: colorScheme.onError)),
        );
      case OneboxKind.tweet:
        break;
      case OneboxKind.generic:
        break;
    }
    // A thumbnail brings its own gap, so one that fails to load leaves none.
    final thumbnail = data.kind == OneboxKind.generic && data.thumbnailUrl != null
        ? _Thumbnail(url: data.thumbnailUrl!, ratio: data.thumbnailRatio)
        : null;

    final content = <Widget>[
      if (header != null) ...[header, const SizedBox(height: DesignTokens.spacingS)],
      if (data.kind == OneboxKind.tweet)
        ..._tweet(context, title, rest)
      else
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null) ...[leading, const SizedBox(width: DesignTokens.spacingM)],
            if (thumbnail != null) thumbnail,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) title,
                  if (title != null && rest != null) const SizedBox(height: DesignTokens.spacingXS),
                  if (rest != null) rest,
                ],
              ),
            ),
          ],
        ),
      if (data.metadataHtml != null) ...[
        const SizedBox(height: DesignTokens.spacingS),
        renderHtml(data.metadataHtml!, fontSize: metadataSize, color: muted),
      ],
    ];

    // The one card recipe, aligned with the other blocks (the web's outer
    // ring used to inset it by 3dp).
    return EmbeddedCard(
      onTap: target == null ? null : () => onOpen(target),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: content,
      ),
    );
  }

  /// A tweet: avatar, name and handle, the text and photos, then the date
  /// with its like and retweet counts.
  List<Widget> _tweet(BuildContext context, Widget? name, Widget? rest) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final muted = colorScheme.onSurfaceVariant;
    final small = textTheme.bodySmall?.copyWith(color: muted);
    final target = data.titleUrl ?? data.url;
    final dateUrl = data.dateUrl;
    return [
      Row(
        children: [
          if (data.thumbnailUrl != null) ...[
            ClipOval(child: SizedBox(width: 40, height: 40, child: _picture(data.thumbnailUrl!, BoxFit.cover))),
            const SizedBox(width: DesignTokens.spacingS),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (name != null) name,
                if (data.handle != null) Text(data.handle!, style: small),
              ],
            ),
          ),
        ],
      ),
      if (rest != null) ...[const SizedBox(height: DesignTokens.spacingS), rest],
      if (data.date != null || data.likes != null || data.retweets != null)
        Padding(
          padding: const EdgeInsets.only(top: DesignTokens.spacingS),
          child: Wrap(
            spacing: DesignTokens.spacingM,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // The card already opens the tweet; a date pointing elsewhere
              // is its own 48dp target.
              if (data.date != null)
                dateUrl == null || dateUrl == target
                    ? Text(data.date!, style: small)
                    : InkWell(
                        onTap: () => onOpen(dateUrl),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 48),
                          child: Align(
                            widthFactor: 1,
                            child: Text(data.date!, style: small),
                          ),
                        ),
                      ),
              if (data.likes != null)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.favorite_border, size: 14, color: muted),
                  const SizedBox(width: 4),
                  Text(data.likes!, style: small),
                ]),
              if (data.retweets != null)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.repeat, size: 14, color: muted),
                  const SizedBox(width: 4),
                  Text(data.retweets!, style: small),
                ]),
            ],
          ),
        ),
    ];
  }

  static Widget _picture(String url, BoxFit fit, {VoidCallback? onError}) {
    Widget none(BuildContext _) {
      if (onError != null) WidgetsBinding.instance.addPostFrameCallback((_) => onError());
      return const SizedBox.shrink();
    }

    if (BrandImage.isSvg(url)) return BrandImage(url, fit: fit, fallback: none);
    return Image.network(url, fit: fit, errorBuilder: (c, _, __) => none(c));
  }
}

/// The small picture beside a preview's text, as the web floats it. Old
/// previews often point at pictures that no longer exist; one that fails
/// to load collapses, instead of leaving an empty box beside the title.
class _Thumbnail extends StatefulWidget {
  const _Thumbnail({required this.url, this.ratio});

  final String url;
  final double? ratio;

  @override
  State<_Thumbnail> createState() => _ThumbnailState();
}

class _ThumbnailState extends State<_Thumbnail> {
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    if (_failed) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: DesignTokens.spacingM),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 110, maxHeight: 170),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(DesignTokens.radiusS),
          child: AspectRatio(
            aspectRatio: (widget.ratio ?? 1).clamp(0.5, 2.5),
            child: OneboxCard._picture(widget.url, BoxFit.cover, onError: () {
              if (mounted && !_failed) setState(() => _failed = true);
            }),
          ),
        ),
      ),
    );
  }
}
