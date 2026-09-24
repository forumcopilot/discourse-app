/// A link into a Discourse forum, read from its URL alone — no network.
///
/// The shapes are Discourse's own routes (config/routes.rb):
///
///   * `/t/{slug}/{topic_id}` and `/t/{slug}/{topic_id}/{post_number}`;
///   * `/t/{topic_id}` and `/t/{topic_id}/{post_number}` — slugless. A slug is
///     never all digits (`Slug.for` falls back to "topic"), so two numeric
///     segments are always a topic id and a post number;
///   * `/n/{slug}/{topic_id}(/{post_number})` — the nested-replies view of
///     the same topic;
///   * `/p/{post_id}(/{user_id})` — the post short link;
///   * anything else under a known top-level route (`/c/…`, `/u/…`,
///     `/latest`, …) names the forum but no topic.
///
/// A forum installed in a subfolder (`https://example.com/forum`) prefixes
/// every one of those, so whatever precedes the route segment is the
/// forum's base path. Query strings (`?u=alice`, the share credit), a
/// trailing slash and a fragment do not change where a link points, except
/// that `#post_4` names post 4 when the path does not already name a post.
class DiscourseLink {
  const DiscourseLink._({
    required this.origin,
    required this.basePath,
    this.topicId,
    this.slug,
    this.postNumber,
    this.postId,
    String? subfolderGuess,
  }) : _subfolderGuess = subfolderGuess;

  /// `scheme://host[:port]`, host lowercased, no trailing slash.
  final String origin;

  /// The forum's path under [origin] — `''` for a forum at the root,
  /// `'/forum'` for a subfolder install — when the URL reveals it, which it
  /// does whenever it holds a Discourse route. Null when the URL is a bare
  /// path Discourse does not route, and the base is a guess; see
  /// [forumUrlCandidates].
  final String? basePath;

  /// Discourse topic id, for a topic or post link.
  final int? topicId;

  /// The topic's slug, when the link carried one.
  final String? slug;

  /// 1-based position of a post within its topic (`/t/…/{post_number}`).
  final int? postNumber;

  /// A post id, from a `/p/{post_id}` short link.
  final int? postId;

  /// True when the link names a topic or a post, not just the forum.
  bool get pointsIntoForum => topicId != null || postId != null;

  /// The forum's base URL when the link reveals it.
  String? get forumUrl => basePath == null ? null : '$origin$basePath';

  /// Where the forum could be, most likely first.
  ///
  /// One entry when the link holds a Discourse route. A bare path is
  /// either a subfolder forum's home (`https://example.com/forum`) or some
  /// page on a site whose forum, if any, is at the root — so both, the
  /// subfolder first because a path is what the user gave us.
  List<String> get forumUrlCandidates {
    final known = forumUrl;
    if (known != null) return [known];
    final guess = _subfolderGuess;
    return [if (guess != null) '$origin$guess', origin];
  }

  /// The first path segment of a bare-path link, which may be a subfolder.
  final String? _subfolderGuess;

  /// Top-level route segments that say "the forum starts here". Everything
  /// Discourse serves a page for, so that the segments before one can be
  /// read as a subfolder.
  static const Set<String> _routeSegments = {
    't', 'n', 'p', 'c', 'u', 'g', 'tag', 'tags', 'groups', 'users',
    'latest', 'top', 'new', 'unread', 'hot', 'unseen', 'categories', 'posted',
    'bookmarks', 'badges', 'search', 'about', 'faq', 'guidelines', 'tos',
    'privacy', 'my', 'session', 'login', 'signup', 'chat', 'review', 'admin',
    'invites', 'filter', 'docs', 'upcoming-events', 'pub', 'new-topic',
    'new-message',
  };

  static final RegExp _digits = RegExp(r'^\d+$');
  static final RegExp _hostPattern =
      RegExp(r'^([a-z0-9-]+(\.[a-z0-9-]+)+|localhost)$');

  /// Reads [input] as a link to a Discourse forum. Returns null unless it is
  /// an http(s) URL — or a bare host, as typed in an address box — with a
  /// plausible hostname. Whether a forum actually answers there is for the
  /// caller to find out.
  static DiscourseLink? parse(String input) {
    var text = input.trim();
    if (text.isEmpty || text.contains(RegExp(r'\s'))) return null;
    if (!text.contains('://')) text = 'https://$text';
    final uri = Uri.tryParse(text);
    if (uri == null) return null;
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') return null;
    // `mailto:a@b.com` given a scheme reads as user "mailto:a" at b.com.
    if (uri.userInfo.isNotEmpty) return null;
    final host = uri.host.toLowerCase();
    if (!_hostPattern.hasMatch(host)) return null;
    final port = uri.hasPort ? ':${uri.port}' : '';
    final origin = '$scheme://$host$port';

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    final routeAt = segments.indexWhere(_routeSegments.contains);
    if (routeAt < 0) {
      // No Discourse route: a forum's home, at the root or in a subfolder.
      // A file name (`index.php`, `about.html`) is a page, not a folder.
      if (segments.isEmpty || segments.first.contains('.')) {
        return DiscourseLink._(
          origin: origin,
          basePath: segments.isEmpty ? '' : null,
        );
      }
      return DiscourseLink._(
        origin: origin,
        basePath: null,
        subfolderGuess: '/${segments.first}',
      );
    }

    final basePath = routeAt == 0 ? '' : '/${segments.take(routeAt).join('/')}';
    final route = segments[routeAt];
    final rest = segments.skip(routeAt + 1).toList();
    final fragmentPost = _postFromFragment(uri.fragment);

    if (route == 't' || route == 'n') {
      return _topic(origin, basePath, rest, fragmentPost);
    }
    if (route == 'p' && rest.isNotEmpty && _digits.hasMatch(rest.first)) {
      return DiscourseLink._(
        origin: origin,
        basePath: basePath,
        postId: int.parse(rest.first),
      );
    }
    return DiscourseLink._(origin: origin, basePath: basePath);
  }

  static DiscourseLink _topic(
    String origin,
    String basePath,
    List<String> rest,
    int? fragmentPost,
  ) {
    String? slug;
    int? topicId;
    int? postNumber;
    if (rest.isNotEmpty && _digits.hasMatch(rest.first)) {
      // /t/{topic_id}(/{post_number})
      topicId = int.parse(rest.first);
      if (rest.length > 1 && _digits.hasMatch(rest[1])) {
        postNumber = int.parse(rest[1]);
      }
    } else if (rest.length > 1 && _digits.hasMatch(rest[1])) {
      // /t/{slug}/{topic_id}(/{post_number})
      slug = rest.first;
      topicId = int.parse(rest[1]);
      if (rest.length > 2 && _digits.hasMatch(rest[2])) {
        postNumber = int.parse(rest[2]);
      }
    }
    // `/t/{slug}` alone is a real route too, but only the server can map a
    // slug to an id; such a link opens the forum.
    if (topicId == null || topicId <= 0) {
      return DiscourseLink._(origin: origin, basePath: basePath);
    }
    postNumber ??= fragmentPost;
    return DiscourseLink._(
      origin: origin,
      basePath: basePath,
      topicId: topicId,
      slug: slug,
      postNumber: (postNumber != null && postNumber > 0) ? postNumber : null,
    );
  }

  /// `#post_4`, the anchor older Discourse links and some embeds carry.
  static int? _postFromFragment(String fragment) {
    final match = RegExp(r'^post_(\d+)$').firstMatch(fragment);
    return match == null ? null : int.parse(match.group(1)!);
  }

  /// The forum's canonical web address for a topic, or a post within it —
  /// what the forum's own share button hands out.
  ///
  /// `{forum}/t/{slug}/{topic_id}`, plus `/{post_number}` past the first
  /// post: Discourse's `postUrl` (frontend lib/utilities.js) links post 1 as
  /// the topic, and writes "topic" where a slug is unknown — the server
  /// redirects any slug to the right one. The share credit (`?u=username`)
  /// is left off: it depends on site settings the API does not expose, and
  /// it would put the reader's username in every link they copy.
  static String webUrl(
    String forumUrl, {
    required String topicId,
    String? slug,
    int? postNumber,
  }) {
    final base = forumUrl.replaceAll(RegExp(r'/+$'), '');
    final trimmed = slug?.trim() ?? '';
    final s = trimmed.isEmpty ? 'topic' : trimmed;
    final n = (postNumber != null && postNumber > 1) ? '/$postNumber' : '';
    return '$base/t/$s/$topicId$n';
  }

  @override
  String toString() => 'DiscourseLink($origin, base=$basePath, topic=$topicId, '
      'slug=$slug, postNumber=$postNumber, post=$postId)';
}
