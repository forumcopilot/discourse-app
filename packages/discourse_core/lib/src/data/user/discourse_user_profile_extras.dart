/// What a Discourse profile says about a person beyond the shared user
/// model: their title, status, backgrounds, featured topic, time zone and
/// bio as the server cooked it. `/u/{username}.json` carries all of it
/// (UserCardSerializer and UserSerializer), and the profile page showed
/// none of it.
///
/// A side table rather than fields on `FCUserInfoResult`, because that type
/// is shared SDK surface — see `DiscourseAcceptedAnswers`. The user proxy
/// records an entry on every profile load; keyed by forum as well as
/// username, as a multi-forum host shows people of several forums.
class DiscourseUserProfileExtras {
  const DiscourseUserProfileExtras({
    this.title,
    this.statusEmoji,
    this.statusDescription,
    this.statusEndsAt,
    this.backgroundUrl,
    this.featuredTopicId,
    this.featuredTopicTitle,
    this.timezone,
    this.bioText,
    this.bioCooked,
    this.primaryGroupName,
    this.flairName,
    this.flairUrl,
    this.flairBgColor,
    this.flairColor,
    this.fields = const [],
  });

  /// The title the forum granted or they chose ("Community lead").
  final String? title;

  /// User status (Discourse's `enable_user_status`): an emoji name and a
  /// short line, optionally ending at [statusEndsAt].
  final String? statusEmoji;
  final String? statusDescription;
  final DateTime? statusEndsAt;

  /// Profile background, else card background; absolute.
  final String? backgroundUrl;

  final int? featuredTopicId;
  final String? featuredTopicTitle;

  /// IANA time zone name, when the forum shows local time on profiles.
  final String? timezone;

  /// The bio as plain text, from the server's cooked version.
  final String? bioText;

  final String? primaryGroupName;

  /// The bio as the server cooked it, links and emoji kept.
  final String? bioCooked;

  /// The flair they wear: the group, its icon name or image URL, and its
  /// colours (six-digit hex without '#').
  final String? flairName;
  final String? flairUrl;
  final String? flairBgColor;
  final String? flairColor;

  /// The forum's profile questions marked to show on profiles, answered.
  final List<({String name, String value})> fields;

  bool get hasFlair => flairUrl != null && flairUrl!.isNotEmpty;

  bool get hasStatus =>
      (statusDescription?.isNotEmpty ?? false) &&
      (statusEndsAt == null || statusEndsAt!.isAfter(DateTime.now()));

  static final Map<String, DiscourseUserProfileExtras> _byUser = {};

  static String _key(String forumUrl, String username) =>
      '$forumUrl#${username.toLowerCase()}';

  static void store(
          String forumUrl, String username, DiscourseUserProfileExtras extras) =>
      _byUser[_key(forumUrl, username)] = extras;

  static DiscourseUserProfileExtras? forUser(String forumUrl, String username) =>
      _byUser[_key(forumUrl, username)];

  /// Only for tests and sign-out.
  static void clear() => _byUser.clear();
}
