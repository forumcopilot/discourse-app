/// Pure URL predicates for classifying links found in post content.
///
/// These were previously static members of the XenForo-era
/// `BBCodeProcessor`. They have nothing to do with BBCode — they are
/// plain host/path matchers — so they live here now that the BBCode
/// pipeline is gone. See [CookedContent] for the Discourse-native
/// extraction that consumes them.
class MediaUrlUtils {
  const MediaUrlUtils._();

  static final RegExp _youtubeRegex = RegExp(
    r'^(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:watch\?v=|embed\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})(?:\S+)?$',
    caseSensitive: false,
  );

  static final RegExp _twitterRegex = RegExp(
    r'^(?:https?:\/\/)?(?:www\.)?(?:twitter\.com|x\.com)\/([a-zA-Z0-9_]+)\/status\/(\d+)(?:\S+)?$',
    caseSensitive: false,
  );

  static final RegExp _videoHostRegex = RegExp(
    r'(?:youtube\.com|youtu\.be|vimeo\.com|tiktok\.com|dailymotion\.com)',
    caseSensitive: false,
  );

  static final RegExp _videoExtRegex = RegExp(
    r'\.(mp4|webm|ogg|mov|avi|wmv|flv|mkv)$',
    caseSensitive: false,
  );

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// True for a YouTube watch/embed/short-form video link.
  static bool isYoutubeUrl(String url) => _youtubeRegex.hasMatch(url.trim());

  /// True for a Twitter/X status permalink.
  static bool isTwitterUrl(String url) => _twitterRegex.hasMatch(url.trim());

  /// True for a link to a known video host or a direct video file.
  static bool isVideoUrl(String url) =>
      _videoHostRegex.hasMatch(url) || _videoExtRegex.hasMatch(url);

  /// True when the whole string is a bare email address (not a `mailto:`
  /// URL — those are filtered by scheme).
  static bool isEmail(String input) => _emailRegex.hasMatch(input.trim());

  /// The 11-character YouTube video id, or null when [url] is not a
  /// recognised YouTube link.
  static String? youtubeVideoId(String url) =>
      _youtubeRegex.firstMatch(url.trim())?.group(1);

  /// The numeric tweet id, or null when [url] is not a Twitter/X status
  /// permalink.
  static String? tweetId(String url) =>
      _twitterRegex.firstMatch(url.trim())?.group(2);

  /// Builds the canonical watch URL for a YouTube video id. Used when the
  /// only thing the cooked HTML gives us is an embed iframe or a
  /// `data-video-id` attribute.
  static String youtubeWatchUrl(String videoId) =>
      'https://www.youtube.com/watch?v=$videoId';
}
