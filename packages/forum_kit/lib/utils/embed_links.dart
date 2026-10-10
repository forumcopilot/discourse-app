import 'package:flutter/material.dart';

/// What an embed is, which decides how its preview card looks: a video
/// gets a thumbnail with a play button, the rest a row naming the site.
enum EmbedKind { video, audio, post, map, page }

/// A site whose players Discourse embeds in posts.
class EmbedProvider {
  const EmbedProvider(this.name, this.kind, this.icon, {this.brand});

  final String name;
  final EmbedKind kind;
  final IconData icon;

  /// The site's colour, for the badge behind [icon]; null uses the theme's
  /// on-surface colour (a black brand would vanish in the dark theme).
  final Color? brand;
}

/// An embed in a post, reduced to what its preview card needs.
///
/// On the web, Discourse embeds a site by putting that site's player in the
/// post: an `<iframe>`, or a `.lazy-video-container` for YouTube, Vimeo and
/// TikTok that becomes an iframe when tapped. The app does not run those
/// third-party players inside a post. It shows a native preview instead —
/// thumbnail and title where the post carries them — and opens the site
/// (or its app, e.g. YouTube) on tap.
class EmbedLink {
  const EmbedLink({
    required this.provider,
    required this.url,
    this.title,
    this.thumbnailUrl,
    this.youtubeId,
    this.portrait = false,
  });

  final EmbedProvider provider;

  /// The page to open: the video or post itself, not the player.
  final String url;
  final String? title;
  final String? thumbnailUrl;

  /// Set for YouTube, so a card missing its title can look it up on
  /// forumcopilot.com as the ForumCopilot app does.
  final String? youtubeId;

  /// TikTok and YouTube Shorts are tall.
  final bool portrait;

  EmbedLink copyWith({String? title, String? thumbnailUrl}) => EmbedLink(
        provider: provider,
        url: url,
        title: title ?? this.title,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        youtubeId: youtubeId,
        portrait: portrait,
      );

  // ---------------------------------------------------------------------
  // Providers
  // ---------------------------------------------------------------------

  static const youtube = EmbedProvider('YouTube', EmbedKind.video,
      Icons.play_arrow_rounded, brand: Color(0xFFFF0000));
  static const vimeo = EmbedProvider('Vimeo', EmbedKind.video,
      Icons.play_arrow_rounded, brand: Color(0xFF1AB7EA));
  static const tiktok = EmbedProvider('TikTok', EmbedKind.video,
      Icons.music_note_rounded, brand: Color(0xFFFE2C55));
  static const dailymotion = EmbedProvider('Dailymotion', EmbedKind.video,
      Icons.play_arrow_rounded, brand: Color(0xFF0066DC));
  static const twitch = EmbedProvider('Twitch', EmbedKind.video,
      Icons.play_arrow_rounded, brand: Color(0xFF9146FF));
  static const loom = EmbedProvider('Loom', EmbedKind.video,
      Icons.play_arrow_rounded, brand: Color(0xFF625DF5));
  static const wistia = EmbedProvider('Wistia', EmbedKind.video,
      Icons.play_arrow_rounded, brand: Color(0xFF2949E5));
  static const bilibili = EmbedProvider('Bilibili', EmbedKind.video,
      Icons.play_arrow_rounded, brand: Color(0xFF00A1D6));
  static const vidyard = EmbedProvider('Vidyard', EmbedKind.video,
      Icons.play_arrow_rounded, brand: Color(0xFF3AB36B));
  static const facebookVideo = EmbedProvider('Facebook', EmbedKind.video,
      Icons.play_arrow_rounded, brand: Color(0xFF1877F2));

  static const facebook = EmbedProvider('Facebook', EmbedKind.post,
      Icons.facebook, brand: Color(0xFF1877F2));
  static const instagram = EmbedProvider('Instagram', EmbedKind.post,
      Icons.photo_camera_outlined, brand: Color(0xFFE1306C));
  static const reddit = EmbedProvider('Reddit', EmbedKind.post,
      Icons.forum_outlined, brand: Color(0xFFFF4500));
  static const x = EmbedProvider('X', EmbedKind.post, Icons.tag);
  static const threads = EmbedProvider('Threads', EmbedKind.post,
      Icons.alternate_email);
  static const linkedin = EmbedProvider('LinkedIn', EmbedKind.post,
      Icons.work_outline, brand: Color(0xFF0A66C2));

  static const soundcloud = EmbedProvider('SoundCloud', EmbedKind.audio,
      Icons.graphic_eq, brand: Color(0xFFFF5500));
  static const spotify = EmbedProvider('Spotify', EmbedKind.audio,
      Icons.graphic_eq, brand: Color(0xFF1DB954));
  static const bandcamp = EmbedProvider('Bandcamp', EmbedKind.audio,
      Icons.album_outlined, brand: Color(0xFF1DA0C3));
  static const mixcloud = EmbedProvider('Mixcloud', EmbedKind.audio,
      Icons.graphic_eq, brand: Color(0xFF5000FF));
  static const appleMusic = EmbedProvider('Apple Music', EmbedKind.audio,
      Icons.music_note_rounded, brand: Color(0xFFFA243C));
  static const applePodcasts = EmbedProvider('Apple Podcasts', EmbedKind.audio,
      Icons.podcasts, brand: Color(0xFF9933CC));

  static const googleMaps = EmbedProvider('Google Maps', EmbedKind.map,
      Icons.map_outlined, brand: Color(0xFF34A853));

  /// Hosts whose players are neither video nor audio, with the name their
  /// card shows. Anything unknown shows its host name.
  static const Map<String, (String, IconData, Color?)> _pages = {
    'docs.google.com': ('Google Docs', Icons.description_outlined, Color(0xFF4285F4)),
    'drive.google.com': ('Google Drive', Icons.folder_outlined, Color(0xFF4285F4)),
    'calendar.google.com': ('Google Calendar', Icons.event_outlined, Color(0xFF4285F4)),
    'store.steampowered.com': ('Steam', Icons.sports_esports_outlined, Color(0xFF2A475E)),
    'codepen.io': ('CodePen', Icons.code, null),
    'jsfiddle.net': ('JSFiddle', Icons.code, Color(0xFF0084FF)),
    'replit.com': ('Replit', Icons.code, Color(0xFFF26207)),
    'sketchfab.com': ('Sketchfab', Icons.view_in_ar_outlined, Color(0xFF1CAAD9)),
    'trello.com': ('Trello', Icons.view_kanban_outlined, Color(0xFF0079BF)),
    'typeform.com': ('Typeform', Icons.assignment_outlined, null),
    'canva.com': ('Canva', Icons.palette_outlined, Color(0xFF00C4CC)),
    'figma.com': ('Figma', Icons.design_services_outlined, Color(0xFFA259FF)),
    'desmos.com': ('Desmos', Icons.functions, Color(0xFF2F72DC)),
    'lichess.org': ('Lichess', Icons.grid_on, null),
    'chess.com': ('Chess.com', Icons.grid_on, Color(0xFF81B64C)),
    'coda.io': ('Coda', Icons.article_outlined, Color(0xFFF46A54)),
    'slideshare.net': ('SlideShare', Icons.slideshow_outlined, Color(0xFF0077B5)),
  };

  // ---------------------------------------------------------------------
  // Recognition
  // ---------------------------------------------------------------------

  /// A `.lazy-video-container`, as discourse-lazy-videos cooks it:
  /// `data-provider-name`, `data-video-id`, `data-video-title`,
  /// `data-video-start-time`, `data-video-list-id`, a link to the video and
  /// the thumbnail the forum stored.
  static EmbedLink? fromLazyVideo(
    Map<Object, String> attributes, {
    String? href,
    String? thumbnailUrl,
  }) {
    final provider = (attributes['data-provider-name'] ?? '').toLowerCase();
    final id = (attributes['data-video-id'] ?? '').trim();
    final title = _nonEmpty(attributes['data-video-title']);
    switch (provider) {
      case 'youtube':
        if (id.isEmpty && href == null) return null;
        final start = _nonEmpty(attributes['data-video-start-time']);
        final list = _nonEmpty(attributes['data-video-list-id']);
        final url = href ??
            Uri.https('www.youtube.com', '/watch', {
              'v': id,
              if (start != null) 't': start,
              if (list != null) 'list': list,
            }).toString();
        return EmbedLink(
          provider: youtube,
          url: url,
          title: title,
          thumbnailUrl: thumbnailUrl ?? (id.isEmpty ? null : youtubeThumbnail(id)),
          youtubeId: id.isEmpty ? youtubeIdOf(url) : id,
          portrait: url.contains('/shorts/'),
        );
      case 'vimeo':
        return EmbedLink(
          provider: vimeo,
          url: href ?? 'https://vimeo.com/${id.split('?').first}',
          title: title,
          thumbnailUrl: thumbnailUrl,
        );
      case 'tiktok':
        return EmbedLink(
          provider: tiktok,
          url: href ?? 'https://www.tiktok.com/embed/v2/$id',
          title: title,
          thumbnailUrl: thumbnailUrl,
          portrait: true,
        );
    }
    if (href != null) return fromUrl(href, title: title, thumbnailUrl: thumbnailUrl);
    return null;
  }

  /// A video page URL: a Discourse `a.onebox` link (a URL alone on its line
  /// that the server did not turn into an embed) or an older plugin's
  /// markup. Only video sites qualify — anything else stays a link, as on
  /// the web.
  static EmbedLink? fromUrl(String url, {String? title, String? thumbnailUrl}) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme || !uri.scheme.startsWith('http')) return null;
    final host = _host(uri);
    final ytId = youtubeIdOf(url);
    if (ytId != null) {
      return EmbedLink(
        provider: youtube,
        url: url,
        title: title,
        thumbnailUrl: thumbnailUrl ?? youtubeThumbnail(ytId),
        youtubeId: ytId,
        portrait: uri.path.startsWith('/shorts/'),
      );
    }
    if (_is(host, 'vimeo.com') && RegExp(r'^/\d+').hasMatch(uri.path)) {
      return EmbedLink(provider: vimeo, url: url, title: title, thumbnailUrl: thumbnailUrl);
    }
    if (_is(host, 'tiktok.com') && uri.path.contains('/video/')) {
      return EmbedLink(
          provider: tiktok, url: url, title: title, thumbnailUrl: thumbnailUrl, portrait: true);
    }
    final dm = _dailymotionId(uri);
    if (dm != null) {
      return EmbedLink(
        provider: dailymotion,
        url: 'https://www.dailymotion.com/video/$dm',
        title: title,
        thumbnailUrl: thumbnailUrl ?? 'https://www.dailymotion.com/thumbnail/video/$dm',
      );
    }
    if (_is(host, 'twitch.tv') && (uri.path.startsWith('/videos/') || host.startsWith('clips.'))) {
      return EmbedLink(provider: twitch, url: url, title: title, thumbnailUrl: thumbnailUrl);
    }
    if (_is(host, 'loom.com') && uri.path.startsWith('/share/')) {
      return EmbedLink(provider: loom, url: url, title: title, thumbnailUrl: thumbnailUrl);
    }
    return null;
  }

  /// An `<iframe src>` in a post: the player a site gave Discourse to embed.
  ///
  /// [innerHref] and [innerText] are the fallback link some embed codes put
  /// inside the iframe (Bandcamp does); when present it names the page
  /// better than the player URL does.
  static EmbedLink? fromIframe(
    String src, {
    String? title,
    String? innerHref,
    String? innerText,
  }) {
    var raw = src.trim();
    if (raw.startsWith('//')) raw = 'https:$raw';
    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasScheme || !uri.scheme.startsWith('http') || uri.host.isEmpty) {
      return null;
    }
    final host = _host(uri);
    final q = uri.queryParameters;
    final fallbackUrl = _nonEmpty(innerHref) ?? raw;
    final namedTitle = _iframeTitle(title) ?? _nonEmpty(innerText);

    // --- video ---
    final ytId = youtubeIdOf(raw);
    if (ytId != null || (_isYouTubeHost(host) && q['list'] != null)) {
      final url = ytId == null
          ? 'https://www.youtube.com/playlist?list=${q['list']}'
          : Uri.https('www.youtube.com', '/watch', {
              'v': ytId,
              if (q['start'] != null) 't': q['start']!,
              if (q['list'] != null) 'list': q['list']!,
            }).toString();
      return EmbedLink(
        provider: youtube,
        url: url,
        title: namedTitle,
        thumbnailUrl: ytId == null ? null : youtubeThumbnail(ytId),
        youtubeId: ytId,
      );
    }
    if (host == 'player.vimeo.com') {
      final m = RegExp(r'^/video/(\d+)').firstMatch(uri.path);
      if (m != null) {
        final hash = q['h'];
        return EmbedLink(
          provider: vimeo,
          url: 'https://vimeo.com/${m.group(1)}${hash == null ? '' : '/$hash'}',
          title: namedTitle,
        );
      }
    }
    if (_is(host, 'tiktok.com')) {
      return EmbedLink(provider: tiktok, url: raw, title: namedTitle, portrait: true);
    }
    final dm = _dailymotionId(uri);
    if (dm != null) {
      return EmbedLink(
        provider: dailymotion,
        url: 'https://www.dailymotion.com/video/$dm',
        title: namedTitle,
        thumbnailUrl: 'https://www.dailymotion.com/thumbnail/video/$dm',
      );
    }
    if (host == 'player.twitch.tv' || host == 'clips.twitch.tv') {
      final video = q['video'];
      final channel = q['channel'];
      final clip = q['clip'];
      final url = video != null
          ? 'https://www.twitch.tv/videos/${video.replaceFirst('v', '')}'
          : clip != null
              ? 'https://clips.twitch.tv/$clip'
              : channel != null
                  ? 'https://www.twitch.tv/$channel'
                  : raw;
      return EmbedLink(provider: twitch, url: url, title: namedTitle);
    }
    if (_is(host, 'loom.com')) {
      final m = RegExp(r'^/embed/([\w-]+)').firstMatch(uri.path);
      return EmbedLink(
        provider: loom,
        url: m == null ? raw : 'https://www.loom.com/share/${m.group(1)}',
        title: namedTitle,
      );
    }
    if (_is(host, 'wistia.net') || _is(host, 'wistia.com')) {
      return EmbedLink(provider: wistia, url: raw, title: namedTitle);
    }
    if (_is(host, 'bilibili.com')) {
      final bvid = q['bvid'];
      return EmbedLink(
        provider: bilibili,
        url: bvid == null ? raw : 'https://www.bilibili.com/video/$bvid',
        title: namedTitle,
      );
    }
    if (_is(host, 'vidyard.com')) {
      return EmbedLink(provider: vidyard, url: raw, title: namedTitle);
    }
    if (_is(host, 'facebook.com')) {
      final target = q['href'];
      final isVideo = uri.path.contains('video') || (target?.contains('/videos/') ?? false);
      return EmbedLink(
        provider: isVideo ? facebookVideo : facebook,
        url: target ?? raw,
        title: namedTitle,
      );
    }

    // --- posts ---
    if (_is(host, 'reddit.com')) {
      final sub = RegExp(r'^/r/([^/]+)').firstMatch(uri.path)?.group(1);
      return EmbedLink(
        provider: reddit,
        url: Uri.https('www.reddit.com', uri.path).toString(),
        title: namedTitle ?? (sub == null ? null : 'r/$sub'),
      );
    }
    if (_is(host, 'instagram.com')) {
      final path = uri.path.replaceFirst(RegExp(r'/embed/?(captioned/?)?$'), '/');
      return EmbedLink(
        provider: instagram,
        url: Uri.https('www.instagram.com', path).toString(),
        title: namedTitle,
      );
    }
    if (_is(host, 'twitter.com') || _is(host, 'x.com')) {
      final id = q['id'];
      return EmbedLink(
        provider: x,
        url: id == null ? raw : 'https://x.com/i/status/$id',
        title: namedTitle,
      );
    }
    if (_is(host, 'threads.net') || _is(host, 'threads.com')) {
      return EmbedLink(
        provider: threads,
        url: raw.replaceFirst(RegExp(r'/embed/?$'), ''),
        title: namedTitle,
      );
    }
    if (_is(host, 'linkedin.com')) {
      return EmbedLink(
        provider: linkedin,
        url: raw.replaceFirst('/embed/', '/'),
        title: namedTitle,
      );
    }

    // --- audio ---
    if (_is(host, 'soundcloud.com')) {
      return EmbedLink(provider: soundcloud, url: fallbackUrl, title: namedTitle);
    }
    if (host == 'open.spotify.com') {
      final path = uri.path.replaceFirst(RegExp(r'^/embed(-podcast)?/'), '/');
      return EmbedLink(
        provider: spotify,
        url: Uri.https('open.spotify.com', path).toString(),
        title: namedTitle,
      );
    }
    if (_is(host, 'bandcamp.com')) {
      return EmbedLink(provider: bandcamp, url: fallbackUrl, title: namedTitle);
    }
    if (_is(host, 'mixcloud.com')) {
      final feed = q['feed'];
      return EmbedLink(
        provider: mixcloud,
        url: feed != null && feed.startsWith('/')
            ? 'https://www.mixcloud.com$feed'
            : fallbackUrl,
        title: namedTitle,
      );
    }
    if (host == 'embed.music.apple.com') {
      return EmbedLink(
        provider: appleMusic,
        url: Uri.https('music.apple.com', uri.path, q.isEmpty ? null : q).toString(),
        title: namedTitle,
      );
    }
    if (host == 'embed.podcasts.apple.com') {
      return EmbedLink(
        provider: applePodcasts,
        url: Uri.https('podcasts.apple.com', uri.path, q.isEmpty ? null : q).toString(),
        title: namedTitle,
      );
    }

    // --- maps ---
    if ((_is(host, 'google.com') && uri.path.startsWith('/maps')) ||
        host == 'maps.google.com') {
      final open = Map<String, String>.of(q)..remove('output');
      return EmbedLink(
        provider: googleMaps,
        url: uri.replace(queryParameters: open.isEmpty ? null : open).toString(),
        title: namedTitle,
      );
    }

    // --- everything else ---
    for (final entry in _pages.entries) {
      if (_is(host, entry.key)) {
        final (name, icon, brand) = entry.value;
        return EmbedLink(
          provider: EmbedProvider(name, EmbedKind.page, icon, brand: brand),
          url: _steamAppPage(uri) ?? fallbackUrl,
          title: namedTitle,
        );
      }
    }
    return EmbedLink(
      provider: EmbedProvider(host, EmbedKind.page, Icons.public),
      url: fallbackUrl,
      title: namedTitle,
    );
  }

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  static final RegExp _youtubeId = RegExp(
    r'^(?:https?:)?//(?:www\.|m\.|music\.)?(?:youtube\.com/(?:watch\?(?:.*&)?v=|embed/|shorts/|live/|v/)|youtube-nocookie\.com/embed/|youtu\.be/)(?!videoseries)([A-Za-z0-9_-]{11})',
    caseSensitive: false,
  );

  /// The 11-character video id in a YouTube watch, share, Shorts or embed
  /// URL; null for anything else, including playlist-only embeds
  /// (`/embed/videoseries?list=…`, whose path is also 11 characters).
  static String? youtubeIdOf(String url) =>
      _youtubeId.firstMatch(url.trim())?.group(1);

  /// YouTube's own still for a video, which exists for every video — for
  /// embeds that did not come with a thumbnail of their own.
  static String youtubeThumbnail(String id) =>
      'https://i.ytimg.com/vi/$id/hqdefault.jpg';

  static bool _isYouTubeHost(String host) =>
      _is(host, 'youtube.com') || _is(host, 'youtube-nocookie.com') || host == 'youtu.be';

  static String? _dailymotionId(Uri uri) {
    final host = _host(uri);
    if (host == 'dai.ly') {
      final seg = uri.pathSegments.firstOrNull;
      return (seg == null || seg.isEmpty) ? null : seg;
    }
    if (!_is(host, 'dailymotion.com')) return null;
    final m = RegExp(r'^/(?:embed/)?video/([A-Za-z0-9]+)').firstMatch(uri.path);
    if (m != null) return m.group(1);
    // The newer player: geo.dailymotion.com/player/xyz.html?video=ID
    return _nonEmpty(uri.queryParameters['video']);
  }

  static final RegExp _spotifyTitle = RegExp(r'^spotify embed:\s*', caseSensitive: false);
  static final RegExp _genericTitle = RegExp(
      r'^(youtube video player|vimeo video player|embedded content|iframe)$',
      caseSensitive: false);

  /// An iframe's `title`, minus the boilerplate embed codes ship with
  /// ("YouTube video player") and Spotify's "Spotify Embed: " prefix.
  static String? _iframeTitle(String? title) {
    final t = _nonEmpty(title);
    if (t == null || _genericTitle.hasMatch(t)) return null;
    return _nonEmpty(t.replaceFirst(_spotifyTitle, ''));
  }

  static String? _steamAppPage(Uri uri) {
    if (_host(uri) != 'store.steampowered.com') return null;
    final m = RegExp(r'^/widget/(\d+)').firstMatch(uri.path);
    return m == null ? null : 'https://store.steampowered.com/app/${m.group(1)}/';
  }

  static String _host(Uri uri) {
    final h = uri.host.toLowerCase();
    return h.startsWith('www.') ? h.substring(4) : h;
  }

  /// [host] is [domain] or a subdomain of it.
  static bool _is(String host, String domain) =>
      host == domain || host.endsWith('.$domain');

  static String? _nonEmpty(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}
