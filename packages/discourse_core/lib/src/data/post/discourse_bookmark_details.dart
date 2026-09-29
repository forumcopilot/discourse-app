/// Where a bookmarked post's topic lives: its category and tags, which the
/// bookmark list sends for every row (UserPostTopicBookmarkBaseSerializer,
/// with TopicTagsMixin) and the bookmarks screen used to ignore.
///
/// A side table rather than fields on `FCBookmark`, because that type is
/// shared SDK surface — see `DiscourseAcceptedAnswers`. Recorded by the
/// bookmark proxy as it maps a list; keyed by forum as well as bookmark id.
class DiscourseBookmarkDetails {
  const DiscourseBookmarkDetails({this.categoryId, this.tags = const []});

  final int? categoryId;
  final List<String> tags;

  static final Map<String, DiscourseBookmarkDetails> _byBookmark = {};

  static String _key(String forumUrl, int bookmarkId) => '$forumUrl#$bookmarkId';

  static void store(
          String forumUrl, int bookmarkId, DiscourseBookmarkDetails details) =>
      _byBookmark[_key(forumUrl, bookmarkId)] = details;

  static DiscourseBookmarkDetails? forBookmark(String forumUrl, int bookmarkId) =>
      _byBookmark[_key(forumUrl, bookmarkId)];

  /// Only for tests and sign-out.
  static void clear() => _byBookmark.clear();
}
