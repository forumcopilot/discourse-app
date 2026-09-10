/// A tab of [SiteHomePage] that code outside it can ask it to open on.
///
/// The page decides for itself which tabs exist — notifications only appear
/// once the forum's config says the forum has them, chat only with the
/// plugin — so this names a destination rather than an index, and a request
/// for a tab this forum does not have is simply not honoured.
///
/// Requests travel through `DiscourseSiteController.requestedHomeTab`, so a
/// caller with no reference to the page (a tapped notification, say) can
/// still redirect it.
enum SiteHomeTab {
  /// The forum's topic feed — the page's own default.
  topics,

  /// The category list.
  categories,

  /// Chat where the plugin is installed, private messages otherwise.
  inbox,

  /// The notification list. Where a push notification lands when nothing in
  /// its payload names a topic to open.
  notifications,

  /// The signed-in user's profile.
  profile,
}
