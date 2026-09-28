import 'package:discourse_core/discourse_core.dart'
    show DiscourseTopicProxy, DiscourseTopicTracking;
import 'package:forumcopilot_sdk/context/site_context.dart';

/// Keeps the viewer's New and Unread counts loaded: the report web
/// preloads on every page (`/u/{username}/topic-tracking-state.json`),
/// fetched when a list appears or is pulled to refresh.
class TopicTrackingService {
  TopicTrackingService._();

  static final Map<DiscourseTopicTracking, Future<void>> _loading = {};

  /// Loads the report for [context]'s forum unless the last one is younger
  /// than [maxAge]. Pull-to-refresh passes [Duration.zero]. Callers on the
  /// same forum share a load in flight. Does nothing for a guest.
  static Future<void> refresh(
    SiteContext context, {
    Duration maxAge = const Duration(seconds: 30),
  }) {
    if (!context.isLoggedIn) return Future.value();
    final tracking = DiscourseTopicTracking.forSite(context);
    final loadedAt = tracking.reportLoadedAt;
    if (loadedAt != null && DateTime.now().difference(loadedAt) < maxAge) {
      return Future.value();
    }
    return _loading[tracking] ??= DiscourseTopicProxy(context)
        .loadTopicTrackingStateAsync()
        .then<void>((_) {})
        .whenComplete(() => _loading.remove(tracking));
  }
}
