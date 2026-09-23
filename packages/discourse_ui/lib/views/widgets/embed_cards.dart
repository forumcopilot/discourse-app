import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../theme/design_tokens.dart';
import '../../utils/embed_links.dart';
import '../../utils/url_utils.dart';
import '../../utils/youtube_cache.dart';
import 'full_screen_video_viewer.dart';

/// The native preview for an embed in a post (see [EmbedLink]): a video
/// shows its thumbnail with the site's play button, as Discourse's lazy
/// videos do on the web; anything else is a row naming the site. Tapping
/// opens the page — for YouTube, TikTok and the like, in their app.
class EmbedPreviewCard extends StatelessWidget {
  const EmbedPreviewCard({super.key, required this.link, required this.onOpen});

  final EmbedLink link;
  final void Function(String url) onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
      child: link.provider.kind == EmbedKind.video
          ? _VideoPreview(link: link, onOpen: onOpen)
          : _EmbedRow(link: link, onOpen: onOpen),
    );
  }
}

class _VideoPreview extends StatefulWidget {
  const _VideoPreview({required this.link, required this.onOpen});

  final EmbedLink link;
  final void Function(String url) onOpen;

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  late EmbedLink _link = widget.link;
  String? _channel;

  @override
  void initState() {
    super.initState();
    _lookUp();
  }

  @override
  void didUpdateWidget(_VideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.link.url != widget.link.url) {
      _link = widget.link;
      _channel = null;
      _lookUp();
    }
  }

  /// A YouTube embed that came without a title (a bare iframe, or a link
  /// the forum did not turn into an embed) gets one from forumcopilot.com,
  /// cached on the device, the way the ForumCopilot app fills its video
  /// cards. Embeds that carry their title cost no request.
  void _lookUp() {
    final id = _link.youtubeId;
    if (id == null || _link.title != null) return;
    final url = _link.url;
    unawaited(YouTubeCache.fetchYouTubePreview(id).then((data) {
      if (!mounted || data == null || _link.url != url) return;
      setState(() {
        _link = _link.copyWith(
          title: data.videoTitle,
          thumbnailUrl: _link.thumbnailUrl ?? data.previewImageUrl,
        );
        _channel = data.authorName;
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    final link = _link;
    final provider = link.provider;
    final thumbnail = link.thumbnailUrl;
    final title = link.title;

    Widget placeholder() => ColoredBox(
          color: Colors.black,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 72),
              child: Text(
                provider.name,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ),
        );

    final frame = ClipRRect(
      borderRadius: BorderRadius.circular(DesignTokens.radiusS),
      child: Material(
        color: Colors.black,
        child: InkWell(
          onTap: () => widget.onOpen(link.url),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (thumbnail != null)
                Image.network(
                  thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) => placeholder(),
                )
              else
                placeholder(),
              if (title != null)
                // The web's title bar: white text on a fade from black.
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 22),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x99000000), Color(0x00000000)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                          ),
                        ),
                        if (_channel != null)
                          Text(
                            _channel!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ),
              Center(child: _PlayBadge(provider: provider)),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: [provider.name, if (title != null) title].join(': '),
      excludeSemantics: true,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: ConstrainedBox(
          // Tall videos (TikTok, Shorts) stay a sensible size instead of
          // filling a whole screen with one post.
          constraints: const BoxConstraints(maxHeight: 480),
          child: AspectRatio(
            aspectRatio: link.portrait ? 9 / 16 : 16 / 9,
            child: frame,
          ),
        ),
      ),
    );
  }
}

/// The site's play button: YouTube's red one, or the site's colour.
class _PlayBadge extends StatelessWidget {
  const _PlayBadge({required this.provider});

  final EmbedProvider provider;

  @override
  Widget build(BuildContext context) {
    if (identical(provider, EmbedLink.youtube)) {
      return Container(
        width: 68,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFFF0000),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
      );
    }
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: provider.brand ?? Colors.black54,
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black38)],
      ),
      child: Icon(provider.icon, color: Colors.white, size: 34),
    );
  }
}

/// A non-video embed — a Spotify track, a Reddit post, a map — as one row:
/// the site's badge, the title when the embed named one, and the site.
class _EmbedRow extends StatelessWidget {
  const _EmbedRow({required this.link, required this.onOpen});

  final EmbedLink link;
  final void Function(String url) onOpen;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = link.provider;
    final badge = provider.brand ?? colorScheme.onSurface;
    final onBadge = provider.brand == null ? colorScheme.surface : Colors.white;
    final title = link.title ?? provider.name;
    final subtitle = link.title != null ? provider.name : _host(link.url);

    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusS),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: DesignTokens.borderWidthThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onOpen(link.url),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingS),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: badge,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                ),
                child: Icon(provider.icon, color: onBadge, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DesignTokens.spacingXS),
              Icon(Icons.open_in_new, size: 18, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  /// The site's address, without "www." — the player's path says nothing
  /// a reader can use.
  static String _host(String url) {
    final host = Uri.tryParse(url)?.host ?? '';
    if (host.isEmpty) return url;
    return host.startsWith('www.') ? host.substring(4) : host;
  }
}

/// A video uploaded to the forum (`<video>`, or the placeholder newer
/// Discourse cooks with a thumbnail): its poster frame with a play button;
/// tapping plays it in the app's video viewer.
class PostVideoCard extends StatelessWidget {
  const PostVideoCard({
    super.key,
    required this.src,
    this.poster,
    this.aspectRatio,
  });

  final String src;
  final String? poster;
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) {
    final ratio = (aspectRatio == null || aspectRatio! <= 0)
        ? 16 / 9
        : aspectRatio!.clamp(0.4, 3.0);
    final name = Uri.tryParse(src)?.pathSegments.lastOrNull;

    // No poster: a black frame; the play button says what it is.
    Widget blank() => const ColoredBox(color: Colors.black);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
      child: Semantics(
        button: true,
        label: name ?? 'video',
        excludeSemantics: true,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 480),
            child: AspectRatio(
              aspectRatio: ratio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                child: Material(
                  color: Colors.black,
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => FullScreenVideoViewer(videoUrl: src, title: name),
                    )),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (poster != null)
                          Image.network(
                            poster!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, _, __) => blank(),
                          )
                        else
                          blank(),
                        Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_arrow_rounded,
                                color: Colors.white, size: 40),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An audio upload (`<audio controls>`): a play button, a scrubbable
/// progress bar and the time, like the browser's own control. The player
/// is only created on the first tap.
class PostAudioPlayer extends StatefulWidget {
  const PostAudioPlayer({super.key, required this.src});

  final String src;

  @override
  State<PostAudioPlayer> createState() => _PostAudioPlayerState();
}

class _PostAudioPlayerState extends State<PostAudioPlayer>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _controller;
  bool _loading = false;
  bool _failed = false;

  /// Keep playing when the post scrolls out of view.
  @override
  bool get wantKeepAlive => _controller?.value.isPlaying ?? false;

  @override
  void dispose() {
    _controller?.removeListener(_changed);
    _controller?.dispose();
    super.dispose();
  }

  void _changed() {
    if (!mounted) return;
    setState(() {});
    updateKeepAlive();
  }

  Future<void> _toggle() async {
    final existing = _controller;
    if (existing != null) {
      existing.value.isPlaying ? await existing.pause() : await existing.play();
      return;
    }
    final uri = Uri.tryParse(widget.src);
    if (uri == null) return;
    final controller = VideoPlayerController.networkUrl(uri);
    setState(() {
      _controller = controller;
      _loading = true;
    });
    try {
      await controller.initialize();
      controller.addListener(_changed);
      await controller.play();
    } catch (_) {
      _failed = true;
    }
    if (mounted) setState(() => _loading = false);
  }

  static String _time(Duration d) {
    final m = d.inMinutes;
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final controller = _controller;
    final value = controller?.value;
    final ready = controller != null && value!.isInitialized && !_failed;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingXS),
      child: Material(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            children: [
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (_failed)
                IconButton(
                  // It would not play here; the browser may manage.
                  onPressed: () => UrlUtils.openUrl(widget.src),
                  icon: Icon(Icons.open_in_new, color: colorScheme.error),
                )
              else
                IconButton(
                  onPressed: _toggle,
                  icon: Icon(
                    (value?.isPlaying ?? false)
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                ),
              Expanded(
                child: ready
                    ? VideoProgressIndicator(
                        controller,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        colors: VideoProgressColors(
                          playedColor: colorScheme.primary,
                          bufferedColor: colorScheme.primary.withValues(alpha: 0.3),
                          backgroundColor: colorScheme.outlineVariant,
                        ),
                      )
                    : Container(height: 4, color: colorScheme.outlineVariant),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  ready
                      ? '${_time(value.position)} / ${_time(value.duration)}'
                      : '0:00',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
