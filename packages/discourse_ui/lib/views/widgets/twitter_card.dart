import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/twitter_cache.dart';
import '../../theme/design_tokens.dart';
import 'post_body_extensions.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';

class TwitterCard extends StatefulWidget {
  final String url;

  const TwitterCard({
    super.key,
    required this.url,
  });

  @override
  State<TwitterCard> createState() => _TwitterCardState();
}

class _TwitterCardState extends State<TwitterCard> with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  bool _shouldShow = true;
  bool _showAsLink = false;
  TwitterPreviewData? _twitterData;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchTweetData();
  }

  @override
  void didUpdateWidget(TwitterCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only refetch if the URL actually changed
    if (oldWidget.url != widget.url && !_isLoading) {
      _fetchTweetData();
    }
  }

  Future<void> _fetchTweetData() async {
    try {
      AppLogger.debug('TwitterCard: Initializing for URL: ${widget.url}');

      // Use the cached Twitter preview system
      final twitterData = await TwitterCache.fetchTwitterPreview(widget.url);

      if (twitterData != null) {
        AppLogger.debug('TwitterCard: Retrieved cached data: authorName=${twitterData.authorName}, handle=${twitterData.authorHandle}');

        if (mounted) {
          setState(() {
            _twitterData = twitterData;
            _isLoading = false;
            _shouldShow = true;
            _showAsLink = false;
          });
        }
      } else {
        AppLogger.debug('TwitterCard: No Twitter data available, showing as link');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _showAsLink = true;
          });
        }
      }
    } catch (e) {
      AppLogger.debug('TwitterCard: Error fetching tweet data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showAsLink = true;
        });
      }
    }
  }

  Future<void> _launchUrl() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    if (!_shouldShow) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: DesignTokens.spacingXS),
        child: Center(
          child: SizedBox(
            width: DesignTokens.iconSizeS,
            height: DesignTokens.iconSizeS,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
            ),
          ),
        ),
      );
    }

    // Show as simple link if API failed or URL doesn't match pattern: a
    // link-coloured line, like any post link, in a 48dp target.
    if (_showAsLink) {
      return InkWell(
        onTap: _launchUrl,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: 1,
            child: Text(
              widget.url,
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.primary),
            ),
          ),
        ),
      );
    }

    // The tweet as the link preview draws one (OneboxCard): the card recipe,
    // the name as the card's title over the handle, the text as its excerpt.
    final muted = colorScheme.onSurfaceVariant;
    return EmbeddedCard(
      onTap: _launchUrl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _twitterData?.authorName ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
          ),
          if (_twitterData?.authorHandle != null)
            Text(
              '@${_twitterData!.authorHandle}',
              style: textTheme.bodySmall?.copyWith(color: muted),
            ),
          // Tweet text
          if (_twitterData?.tweetText != null && _twitterData!.tweetText!.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.spacingS),
            Text(
              _twitterData!.tweetText!,
              style: textTheme.bodyMedium?.copyWith(color: muted),
            ),
          ],
        ],
      ),
    );
  }
}
