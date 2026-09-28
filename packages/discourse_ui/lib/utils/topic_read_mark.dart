import 'package:discourse_core/discourse_core.dart' show DiscourseTopicTracking;
import 'package:flutter/widgets.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

/// How a list row shows how far the viewer has read a topic, by Discourse's
/// web rules (see `DiscourseTopicReadState`):
///
///  * the title steps back only when the topic is [isRead] — read to the
///    end. A topic never opened, or with replies since, keeps full strength
///    whether or not it earns a badge;
///  * a dot when it [isNew]; a count of [unreadCount] replies when it is
///    tracked and has posts after the reader's place.
///
/// Rows used to grey every topic without a badge, so on an established
/// forum almost every row looked read, including ones never opened.
@immutable
class TopicReadMark {
  const TopicReadMark({
    required this.isRead,
    required this.isNew,
    required this.unreadCount,
  });

  final bool isRead;
  final bool isNew;
  final int unreadCount;

  /// The mark for [topicId] on [context]'s forum, from the read state the
  /// app holds for it, falling back to the list's own flags when it holds
  /// none (a guest has none, so nothing is claimed read).
  static TopicReadMark of(
    SiteContext context, {
    required String topicId,
    required bool hasNewPosts,
    required int unreadCount,
  }) {
    if (context.isLoggedIn) {
      final s = DiscourseTopicTracking.forSite(context).stateOf(topicId);
      if (s != null) {
        return TopicReadMark(
            isRead: s.isRead, isNew: s.isNew, unreadCount: s.unreadCount);
      }
    }
    return TopicReadMark(
      isRead: false,
      isNew: hasNewPosts && unreadCount <= 0,
      unreadCount: hasNewPosts ? unreadCount : 0,
    );
  }
}

/// Rebuilds [builder] whenever the read state of [context]'s forum
/// changes — the reader comes back from a topic, a dismissal lands, or the
/// forum says a topic was read elsewhere.
class TopicReadMarkBuilder extends StatelessWidget {
  const TopicReadMarkBuilder({
    super.key,
    required this.siteContext,
    required this.topicId,
    required this.hasNewPosts,
    required this.unreadCount,
    required this.builder,
  });

  final SiteContext siteContext;
  final String topicId;
  final bool hasNewPosts;
  final int unreadCount;
  final Widget Function(BuildContext context, TopicReadMark mark) builder;

  @override
  Widget build(BuildContext context) {
    TopicReadMark mark() => TopicReadMark.of(siteContext,
        topicId: topicId, hasNewPosts: hasNewPosts, unreadCount: unreadCount);
    if (!siteContext.isLoggedIn) return builder(context, mark());
    return ListenableBuilder(
      listenable: DiscourseTopicTracking.forSite(siteContext),
      builder: (context, _) => builder(context, mark()),
    );
  }
}
