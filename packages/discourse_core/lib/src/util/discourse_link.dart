/// What a link into a Discourse forum points at.
enum DiscourseLinkKind {
  /// The forum's home.
  forum,

  /// A topic, or a post in it by number ([DiscourseLink.topicId],
  /// [DiscourseLink.postNumber]).
  topic,

  /// A post by id, from a `/p/{post_id}` short link.
  post,

  /// A category ([DiscourseLink.categoryId], [DiscourseLink.categorySlugs]).
  category,

  /// A tag's topics ([DiscourseLink.tagName]).
  tag,

  /// The tag list.
  tags,

  /// A user's profile ([DiscourseLink.username], [DiscourseLink.userTab]).
  user,

  /// The user directory.
  users,

  /// A group ([DiscourseLink.groupName]).
  group,

  /// The group list.
  groups,

  /// A badge ([DiscourseLink.badgeId]).
  badge,

  /// The badge list.
  badges,

  /// A chat channel, at a message when the link names one
  /// ([DiscourseLink.chatChannelId], [DiscourseLink.chatMessageId]); chat
  /// itself when it names no channel.
  chat,

  /// A search ([DiscourseLink.searchQuery]).
  search,

  /// A topic list — latest, top, new, unread, hot, categories
  /// ([DiscourseLink.listName]).
  list,

  /// One of the signed-in reader's own pages, `/my/…`
  /// ([DiscourseLink.myPath]).
  my,

  /// Something the server answers rather than a page — an upload, raw
  /// markdown, JSON, an invite or sign-in flow. Discourse's own web client
  /// hands these to the browser too (`SERVER_SIDE_ONLY` in lib/url.js).
  serverSide,

  /// A page of the forum with no dedicated kind above: about, the
  /// guidelines, terms, the review queue, admin…
  page,
}

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
///   * `/c/{slug…}/{category_id}(/l/{filter})`, `/tag/{name}`,
///     `/tags/c/{slug…}/{id}/{name}`, `/u/{username}(/{tab})`, `/g/{name}`,
///     `/badges/{id}/{slug}`, `/chat/c/{slug}/{channel_id}(/{message_id})`,
///     `/search?q=…`, `/latest` and the other lists, `/my/…`.
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
    this.kind = DiscourseLinkKind.forum,
    this.url = '',
    this.topicId,
    this.slug,
    this.postNumber,
    this.postId,
    this.categoryId,
    this.categorySlugs = const [],
    this.tagName,
    this.username,
    this.userTab,
    this.groupName,
    this.badgeId,
    this.chatChannelId,
    this.chatMessageId,
    this.searchQuery,
    this.listName,
    this.myPath,
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

  /// What the link points at.
  final DiscourseLinkKind kind;

  /// The link as an absolute URL — what a browser would be given for the
  /// kinds the app has no screen for.
  final String url;

  /// Discourse topic id, for a topic or post link.
  final int? topicId;

  /// The topic's slug, when the link carried one.
  final String? slug;

  /// 1-based position of a post within its topic (`/t/…/{post_number}`).
  final int? postNumber;

  /// A post id, from a `/p/{post_id}` short link.
  final int? postId;

  /// A category's id. Every category link Discourse writes carries it; a
  /// hand-written `/c/{slug}` does not, and [categorySlugs] names it then.
  final int? categoryId;

  /// A category's slug path, parent first (`['hardware', 'arduino']`).
  final List<String> categorySlugs;

  /// A tag's name, decoded.
  final String? tagName;

  /// A user's username, decoded.
  final String? username;

  /// The profile page after the username — `activity`, `summary`,
  /// `messages`, `activity/likes-given` — or null for the profile itself.
  final String? userTab;

  /// A group's name.
  final String? groupName;

  /// A badge's id.
  final int? badgeId;

  /// A chat channel's id.
  final int? chatChannelId;

  /// A chat message's id within [chatChannelId].
  final int? chatMessageId;

  /// The `q` of a search link, decoded.
  final String? searchQuery;

  /// Which list a list link names: `latest`, `top`, `new`, `unread`, `hot`,
  /// `unseen`, `posted`, `read`, `filter` or `categories`.
  final String? listName;

  /// The path after `/my/` — `messages`, `activity/bookmarks`, … — or `''`.
  final String? myPath;

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

  static const Set<String> _lists = {
    'latest', 'top', 'new', 'unread', 'hot', 'unseen', 'posted', 'read',
    'filter', 'categories',
  };

  /// Paths the server answers rather than the app: files, raw markdown,
  /// sign-in and invite flows. Discourse's own `SERVER_SIDE_ONLY`
  /// (frontend lib/url.js), plus the avatar and sign-in endpoints.
  static const Set<String> _serverSide = {
    'assets', 'uploads', 'secure-media-uploads', 'secure-uploads',
    'stylesheets', 'site_customizations', 'raw', 'logs', 'pub', 'invites',
    'styleguide', 'safe-mode', 'dev-mode', 'theme-qunit', 'session', 'auth',
    'email', 'unsubscribe', 'user_avatar', 'letter_avatar_proxy',
    'letter_avatar', 'highlight-js', 'svg-sprite', 'theme-javascripts',
    'extra-locales', 'clicks', 'service-worker.js', 'manifest.webmanifest',
    'opensearch.xml', 'robots.txt', 'llms.txt', 'offline.html',
  };

  /// Top-level route segments that say "the forum starts here". Everything
  /// Discourse serves a page for, so that the segments before one can be
  /// read as a subfolder.
  static const Set<String> _routeSegments = {
    't', 'n', 'p', 'c', 'u', 'g', 'tag', 'tags', 'groups', 'users',
    ..._lists,
    'bookmarks', 'badges', 'search', 'about', 'faq', 'guidelines', 'tos',
    'privacy', 'my', 'login', 'signup', 'chat', 'review', 'admin', 'docs',
    'upcoming-events', 'new-topic', 'new-message', 'posts',
    ..._serverSide,
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
          kind: segments.isEmpty ? DiscourseLinkKind.forum : DiscourseLinkKind.page,
          url: uri.toString(),
        );
      }
      return DiscourseLink._(
        origin: origin,
        basePath: null,
        kind: DiscourseLinkKind.page,
        url: uri.toString(),
        subfolderGuess: '/${segments.first}',
      );
    }

    final basePath = routeAt == 0 ? '' : '/${segments.take(routeAt).join('/')}';
    return _classify(origin, basePath, segments.skip(routeAt).toList(), uri);
  }

  /// Reads [href], as it appears in [forumUrl]'s own content, as a link
  /// into that forum. Null when it leads anywhere else: another site,
  /// another path on the forum's host, or not the web at all (`mailto:`).
  ///
  /// Relative hrefs are resolved the way the forum writes them: Discourse
  /// puts a subfolder install's base path in its own links
  /// (`/forum/t/…`), so a rooted path already under the base is taken as
  /// it is, and one that is not is taken as relative to the base. The same
  /// forum is often linked with or without `www.` and over http or https,
  /// so neither decides.
  static DiscourseLink? inForum(String forumUrl, String href) {
    final forum = Uri.tryParse(forumUrl.trim());
    if (forum == null || forum.host.isEmpty) return null;
    final base = forum.path.replaceAll(RegExp(r'/+$'), '');
    final forumOrigin =
        '${forum.scheme}://${forum.host}${forum.hasPort ? ':${forum.port}' : ''}';

    final text = href.trim();
    if (text.isEmpty) return null;
    final Uri? uri;
    if (text.startsWith('//')) {
      uri = Uri.tryParse('${forum.scheme}:$text');
    } else if (RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*:').hasMatch(text)) {
      uri = Uri.tryParse(text);
    } else if (text.startsWith('/')) {
      final underBase =
          base.isEmpty || text == base || text.startsWith('$base/');
      uri = Uri.tryParse('$forumOrigin${underBase ? '' : base}$text');
    } else {
      uri = Uri.tryParse('$forumOrigin$base/')?.resolve(text);
    }
    if (uri == null) return null;
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') return null;
    if (uri.userInfo.isNotEmpty) return null;
    if (_bareHost(uri.host) != _bareHost(forum.host)) return null;
    if (uri.hasPort && forum.hasPort && uri.port != forum.port) return null;
    final path = uri.path;
    if (base.isNotEmpty && path != base && !path.startsWith('$base/')) {
      return null;
    }
    final segments = path
        .substring(base.length)
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList();
    final port = uri.hasPort ? ':${uri.port}' : '';
    final origin = '$scheme://${uri.host.toLowerCase()}$port';
    return _classify(origin, base, segments, uri);
  }

  static String _bareHost(String host) {
    final h = host.toLowerCase();
    return h.startsWith('www.') ? h.substring(4) : h;
  }

  /// Classifies the path after the forum's base: [segments] starts with the
  /// route (`t`, `c`, `u`, …) or is empty for the forum's home.
  static DiscourseLink _classify(
    String origin,
    String basePath,
    List<String> segments,
    Uri uri,
  ) {
    DiscourseLink link(
      DiscourseLinkKind kind, {
      int? topicId,
      String? slug,
      int? postNumber,
      int? postId,
      int? categoryId,
      List<String> categorySlugs = const [],
      String? tagName,
      String? username,
      String? userTab,
      String? groupName,
      int? badgeId,
      int? chatChannelId,
      int? chatMessageId,
      String? searchQuery,
      String? listName,
      String? myPath,
    }) =>
        DiscourseLink._(
          origin: origin,
          basePath: basePath,
          kind: kind,
          url: uri.toString(),
          topicId: topicId,
          slug: slug,
          postNumber: postNumber,
          postId: postId,
          categoryId: categoryId,
          categorySlugs: categorySlugs,
          tagName: tagName,
          username: username,
          userTab: userTab,
          groupName: groupName,
          badgeId: badgeId,
          chatChannelId: chatChannelId,
          chatMessageId: chatMessageId,
          searchQuery: searchQuery,
          listName: listName,
          myPath: myPath,
        );

    if (segments.isEmpty) return link(DiscourseLinkKind.forum);
    final route = segments.first;
    final rest = segments.skip(1).map(_decode).toList();
    final last = segments.last.toLowerCase();
    if (_serverSide.contains(route) ||
        last.endsWith('.json') ||
        last.endsWith('.rss') ||
        (route == 'posts' && rest.contains('raw'))) {
      return link(DiscourseLinkKind.serverSide);
    }

    switch (route) {
      case 't':
      case 'n':
        final topic = _topic(rest, _postFromFragment(uri.fragment));
        if (topic == null) return link(DiscourseLinkKind.page);
        return link(DiscourseLinkKind.topic,
            topicId: topic.$1, slug: topic.$2, postNumber: topic.$3);
      case 'p':
        if (rest.isEmpty || !_digits.hasMatch(rest.first)) {
          return link(DiscourseLinkKind.page);
        }
        return link(DiscourseLinkKind.post, postId: int.parse(rest.first));
      case 'c':
        var parts = rest;
        if (parts.length >= 2 && parts[parts.length - 2] == 'l') {
          parts = parts.sublist(0, parts.length - 2);
        }
        if (parts.isNotEmpty && (parts.last == 'none' || parts.last == 'all')) {
          parts = parts.sublist(0, parts.length - 1);
        }
        int? id;
        if (parts.isNotEmpty && _digits.hasMatch(parts.last)) {
          id = int.parse(parts.last);
          parts = parts.sublist(0, parts.length - 1);
        }
        if (id == null && parts.isEmpty) {
          return link(DiscourseLinkKind.list, listName: 'categories');
        }
        return link(DiscourseLinkKind.category,
            categoryId: id, categorySlugs: parts);
      case 'tag':
        if (rest.isEmpty) return link(DiscourseLinkKind.tags);
        return link(DiscourseLinkKind.tag, tagName: rest.first);
      case 'tags':
        final tag = _tagFromTagsRoute(rest);
        if (tag == null) return link(DiscourseLinkKind.tags);
        return link(DiscourseLinkKind.tag, tagName: tag);
      case 'u':
      case 'users':
        if (rest.isEmpty) return link(DiscourseLinkKind.users);
        return link(DiscourseLinkKind.user,
            username: rest.first,
            userTab: rest.length > 1 ? rest.skip(1).join('/') : null);
      case 'g':
      case 'groups':
        if (rest.isEmpty) return link(DiscourseLinkKind.groups);
        return link(DiscourseLinkKind.group, groupName: rest.first);
      case 'badges':
        if (rest.isNotEmpty && _digits.hasMatch(rest.first)) {
          return link(DiscourseLinkKind.badge, badgeId: int.parse(rest.first));
        }
        return link(DiscourseLinkKind.badges);
      case 'chat':
        // /chat/c/{slug}/{channel_id}(/{message_id}), also /chat/c/-/{id}
        // and threads (/chat/c/{slug}/{id}/t/{thread_id}), which open the
        // channel.
        if (rest.length >= 2 && rest.first == 'c') {
          final at = rest.indexWhere(_digits.hasMatch, 1);
          if (at >= 0) {
            final next = at + 1 < rest.length ? rest[at + 1] : null;
            return link(DiscourseLinkKind.chat,
                chatChannelId: int.parse(rest[at]),
                chatMessageId: next != null && _digits.hasMatch(next)
                    ? int.parse(next)
                    : null);
          }
        }
        return link(DiscourseLinkKind.chat);
      case 'search':
        final q = uri.queryParameters['q']?.trim();
        return link(DiscourseLinkKind.search,
            searchQuery: (q == null || q.isEmpty) ? null : q);
      case 'my':
        return link(DiscourseLinkKind.my, myPath: rest.join('/'));
    }
    if (_lists.contains(route)) {
      return link(DiscourseLinkKind.list, listName: route);
    }
    return link(DiscourseLinkKind.page);
  }

  /// The topic id, slug and post number of a `/t/…` or `/n/…` path, or
  /// null when it names no topic id.
  static (int, String?, int?)? _topic(List<String> rest, int? fragmentPost) {
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
    // slug to an id.
    if (topicId == null || topicId <= 0) return null;
    postNumber ??= fragmentPost;
    return (
      topicId,
      slug,
      (postNumber != null && postNumber > 0) ? postNumber : null,
    );
  }

  /// `/tags/c/{slug…}/{category_id}/{tag}`, `/tags/intersection/{a}/{b}`
  /// (the first tag), and the older `/tags/{tag}`.
  static String? _tagFromTagsRoute(List<String> rest) {
    if (rest.isEmpty) return null;
    if (rest.first == 'c') {
      final id = rest.indexWhere(_digits.hasMatch, 1);
      if (id >= 0 && id + 1 < rest.length) {
        final tag = rest[id + 1];
        return tag == 'l' ? null : tag;
      }
      return null;
    }
    if (rest.first == 'intersection') {
      return rest.length > 1 ? rest[1] : null;
    }
    if (rest.first == 'none') return null;
    return rest.first;
  }

  static String _decode(String segment) {
    try {
      return Uri.decodeComponent(segment);
    } catch (_) {
      return segment;
    }
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
  String toString() => 'DiscourseLink($kind, $origin, base=$basePath, '
      'topic=$topicId, postNumber=$postNumber, post=$postId, '
      'category=$categoryId $categorySlugs, tag=$tagName, user=$username, '
      'group=$groupName, badge=$badgeId, chat=$chatChannelId/$chatMessageId, '
      'q=$searchQuery, list=$listName, my=$myPath)';
}
