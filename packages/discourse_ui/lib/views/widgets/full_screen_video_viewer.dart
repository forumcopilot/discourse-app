import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../services/forum_media.dart';

class FullScreenVideoViewer extends StatefulWidget {
  final String videoUrl;
  final String? title;

  /// The forum's media rules, for a video only a signed-in user may see.
  final ForumMediaAuth? auth;

  const FullScreenVideoViewer({
    super.key,
    required this.videoUrl,
    this.title,
    this.auth,
  });

  @override
  State<FullScreenVideoViewer> createState() => _FullScreenVideoViewerState();
}

class _FullScreenVideoViewerState extends State<FullScreenVideoViewer> {
  VideoPlayerController? _controller;
  late final Future<void> _initializeFuture;

  @override
  void initState() {
    super.initState();
    _initializeFuture = _open();
  }

  /// Finds where to play the video from — the forum's secure uploads play
  /// from their signed address, a file a guest may not fetch with the
  /// user's key (see ForumMedia.resolvePlayable) — then starts it.
  Future<void> _open() async {
    final media =
        await ForumMedia.resolvePlayable(widget.auth, widget.videoUrl);
    if (!mounted) return;
    final controller =
        VideoPlayerController.networkUrl(media.url, httpHeaders: media.headers);
    _controller = controller;
    controller.addListener(_playbackChanged);
    await controller.initialize();
    if (!mounted) return;
    await controller.play();
    if (mounted) setState(() {});
  }

  void _playbackChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_playbackChanged);
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    final controller = _controller;
    if (controller == null) return;
    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Never the address: it ends in the upload's hash.
    final title = widget.title?.isNotEmpty == true ? widget.title! : l10n.video;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          tooltip: l10n.close,
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<void>(
          future: _initializeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final controller = _controller;
            if (snapshot.hasError ||
                controller == null ||
                controller.value.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    controller?.value.errorDescription ??
                        l10n.failedToLoadVideo,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final value = controller.value;
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio:
                          value.aspectRatio == 0 ? 16 / 9 : value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      VideoProgressIndicator(
                        controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Colors.white,
                          bufferedColor: Colors.white38,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            tooltip: value.isPlaying
                                ? l10n.mediaPause
                                : l10n.mediaPlay,
                            onPressed: _togglePlayPause,
                            iconSize: 36,
                            color: Colors.white,
                            icon: Icon(
                              value.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
