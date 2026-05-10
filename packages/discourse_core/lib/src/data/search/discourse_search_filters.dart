/// A structured representation of Discourse's `/search.json?q=` operator
/// DSL. Pass to [DiscourseSearchProxy.searchWithFiltersAsync] to layer
/// these on top of a free-text query.
///
/// All fields are optional and combine with `AND`. Empty/null fields are
/// dropped. The serialized query goes after the user's plain keywords.
class DiscourseSearchFilters {
  /// Topic status filters. Discourse supports any subset; multiple
  /// values are joined with `AND`.
  final Set<DiscourseSearchStatus> status;

  /// User-relative filters such as in:bookmarks, in:liked, in:posted.
  final Set<DiscourseSearchPersonal> personal;

  /// Restrict to a topic's first post (the original).
  final bool firstPostsOnly;

  /// Restrict to title matches.
  final bool titleOnly;

  /// Tag filter. Discourse's DSL accepts `tag:foo` (multi values join
  /// with AND when using `tags:` syntax — we use the simpler `tag:` form
  /// repeated which Discourse treats as OR-equivalent for the chip UI).
  final List<String> tags;

  /// Restrict to a category. Pass the slug (Discourse prefers slugs but
  /// also accepts numeric ids).
  final String? categorySlug;

  /// `@username` author filter.
  final String? username;

  /// Min/max replies. Maps to Discourse's `min_posts:` / `max_posts:`.
  final int? minPosts;
  final int? maxPosts;

  /// Date filters; both bounds are inclusive day boundaries in the user's
  /// local time per Discourse's convention.
  final DateTime? after;
  final DateTime? before;

  /// Sort order. Discourse defaults to relevance — pass null to keep that.
  final DiscourseSearchSort? sort;

  const DiscourseSearchFilters({
    this.status = const {},
    this.personal = const {},
    this.firstPostsOnly = false,
    this.titleOnly = false,
    this.tags = const [],
    this.categorySlug,
    this.username,
    this.minPosts,
    this.maxPosts,
    this.after,
    this.before,
    this.sort,
  });

  /// True when nothing is selected — caller can treat as plain keyword
  /// search.
  bool get isEmpty =>
      status.isEmpty &&
      personal.isEmpty &&
      !firstPostsOnly &&
      !titleOnly &&
      tags.isEmpty &&
      (categorySlug?.isEmpty ?? true) &&
      (username?.isEmpty ?? true) &&
      minPosts == null &&
      maxPosts == null &&
      after == null &&
      before == null &&
      sort == null;

  /// Serialize to the Discourse search-DSL fragment that comes after the
  /// user's free-text keywords. Returns an empty string when [isEmpty].
  String toQueryFragment() {
    final parts = <String>[];
    for (final s in status) {
      parts.add('status:${s.token}');
    }
    for (final p in personal) {
      parts.add('in:${p.token}');
    }
    if (firstPostsOnly) parts.add('in:first');
    if (titleOnly) parts.add('in:title');
    for (final tag in tags) {
      final t = tag.trim();
      if (t.isNotEmpty) parts.add('tag:$t');
    }
    if (categorySlug != null && categorySlug!.isNotEmpty) {
      parts.add('category:${categorySlug!.trim()}');
    }
    if (username != null && username!.isNotEmpty) {
      parts.add('@${username!.trim()}');
    }
    if (minPosts != null) parts.add('min_posts:${minPosts!}');
    if (maxPosts != null) parts.add('max_posts:${maxPosts!}');
    if (after != null) parts.add('after:${_isoDate(after!)}');
    if (before != null) parts.add('before:${_isoDate(before!)}');
    if (sort != null) parts.add('order:${sort!.token}');
    return parts.join(' ');
  }

  String _isoDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$y-$m-$dd';
  }

  DiscourseSearchFilters copyWith({
    Set<DiscourseSearchStatus>? status,
    Set<DiscourseSearchPersonal>? personal,
    bool? firstPostsOnly,
    bool? titleOnly,
    List<String>? tags,
    String? categorySlug,
    String? username,
    int? minPosts,
    int? maxPosts,
    DateTime? after,
    DateTime? before,
    DiscourseSearchSort? sort,
    bool clearSort = false,
  }) {
    return DiscourseSearchFilters(
      status: status ?? this.status,
      personal: personal ?? this.personal,
      firstPostsOnly: firstPostsOnly ?? this.firstPostsOnly,
      titleOnly: titleOnly ?? this.titleOnly,
      tags: tags ?? this.tags,
      categorySlug: categorySlug ?? this.categorySlug,
      username: username ?? this.username,
      minPosts: minPosts ?? this.minPosts,
      maxPosts: maxPosts ?? this.maxPosts,
      after: after ?? this.after,
      before: before ?? this.before,
      sort: clearSort ? null : (sort ?? this.sort),
    );
  }
}

/// Topic status operators. Discourse's [Solved](https://meta.discourse.org/t/discourse-solved/30155)
/// plugin contributes `solved` / `unsolved`; on stock Discourse those
/// degrade gracefully (return zero results).
enum DiscourseSearchStatus {
  open('open'),
  closed('closed'),
  archived('archived'),
  noReplies('noreplies'),
  publicOnly('public'),
  solved('solved'),
  unsolved('unsolved');

  final String token;
  const DiscourseSearchStatus(this.token);

  String get label {
    switch (this) {
      case DiscourseSearchStatus.open:
        return 'Open';
      case DiscourseSearchStatus.closed:
        return 'Closed';
      case DiscourseSearchStatus.archived:
        return 'Archived';
      case DiscourseSearchStatus.noReplies:
        return 'No replies';
      case DiscourseSearchStatus.publicOnly:
        return 'Public only';
      case DiscourseSearchStatus.solved:
        return 'Solved';
      case DiscourseSearchStatus.unsolved:
        return 'Unsolved';
    }
  }
}

/// `in:` operators that scope to the current user's relationship with a
/// topic — bookmarks, likes, watching, etc.
enum DiscourseSearchPersonal {
  bookmarks('bookmarks'),
  liked('liked'),
  posted('posted'),
  watching('watching'),
  tracking('tracking'),
  seen('seen'),
  unseen('unseen');

  final String token;
  const DiscourseSearchPersonal(this.token);

  String get label {
    switch (this) {
      case DiscourseSearchPersonal.bookmarks:
        return 'My bookmarks';
      case DiscourseSearchPersonal.liked:
        return 'I liked';
      case DiscourseSearchPersonal.posted:
        return 'I posted in';
      case DiscourseSearchPersonal.watching:
        return 'Watching';
      case DiscourseSearchPersonal.tracking:
        return 'Tracking';
      case DiscourseSearchPersonal.seen:
        return 'Seen';
      case DiscourseSearchPersonal.unseen:
        return 'Unseen';
    }
  }
}

/// Sort order for search results.
enum DiscourseSearchSort {
  latest('latest'),
  likes('likes'),
  views('views'),
  latestTopic('latest_topic');

  final String token;
  const DiscourseSearchSort(this.token);

  String get label {
    switch (this) {
      case DiscourseSearchSort.latest:
        return 'Latest post';
      case DiscourseSearchSort.likes:
        return 'Most likes';
      case DiscourseSearchSort.views:
        return 'Most views';
      case DiscourseSearchSort.latestTopic:
        return 'Latest topic';
    }
  }
}
