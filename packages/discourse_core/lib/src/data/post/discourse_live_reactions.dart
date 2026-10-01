import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post_reaction.dart';

import '../../network/discourse_message_bus.dart';
import '../../proxy/post_proxy.dart';

/// A post's reactions as they changed while its topic was open.
class DiscourseReactionUpdate {
  const DiscourseReactionUpdate({
    required this.siteUrl,
    required this.postId,
    required this.reactions,
  });

  final String siteUrl;
  final String postId;
  final List<FCPostReaction> reactions;
}

/// Keeps an open topic's reaction counts current, as Discourse's web client
/// does.
///
/// discourse-reactions publishes `{post_id, reactions}` on
/// `/topic/{id}/reactions` whenever someone reacts
/// (`CustomReactionsController#publish_change_to_clients!`), and core
/// publishes `{id, type: "liked" | "unliked", user_id}` on `/topic/{id}` for
/// every like, the only signal on a forum without the plugin
/// (`PostActionCreator#notify_subscribers`). Neither carries the counts, so
/// the post's reactions are fetched again, as the web does. The viewer's
/// own change already came back with its toggle, so its echo is not
/// fetched a second time ([noteOwnChange], and the like's `user_id`), and
/// several messages about one post within [debounce] cost one fetch. Both
/// channels ride the forum's one long-poll, so watching costs no requests
/// of its own.
class DiscourseLiveReactions {
  DiscourseLiveReactions._();

  static final StreamController<DiscourseReactionUpdate> _updates =
      StreamController<DiscourseReactionUpdate>.broadcast();

  /// Every refreshed post, from every watched topic. Listeners filter by
  /// forum and post.
  static Stream<DiscourseReactionUpdate> get updates => _updates.stream;

  /// How long several messages about one post are gathered into one fetch.
  static Duration debounce = const Duration(milliseconds: 1500);

  /// How long after the viewer's own change its echo is ignored.
  static const Duration ownEcho = Duration(seconds: 10);

  static final Map<String, DateTime> _ownUntil = {};

  static String _key(String siteUrl, String postId) => '$siteUrl|$postId';

  /// The viewer just changed [postId]'s reactions and has the result.
  static void noteOwnChange(String siteUrl, String postId) {
    _ownUntil[_key(siteUrl, postId)] = DateTime.now().add(ownEcho);
  }

  /// Hands an update to listeners (also used for the viewer's own changes,
  /// so another copy of the post on screen follows).
  static void publish(DiscourseReactionUpdate update) => _updates.add(update);

  /// Watches [topicId]'s reactions until the returned function is called.
  /// [fetch] reads one post's reactions; by default through
  /// [DiscoursePostProxy.getPostReactionsAsync]. [bus] is for tests.
  static void Function() watch(
    SiteContext context,
    String topicId, {
    Future<List<FCPostReaction>?> Function(String postId)? fetch,
    @visibleForTesting DiscourseMessageBus? bus,
  }) {
    bus ??= DiscourseMessageBus.of(context);
    if (bus.isUnavailable) return () {};
    final siteUrl = context.site.url;
    final viewerId = context.loginDataOutput?.user?.id;
    final read = fetch ?? DiscoursePostProxy(context).getPostReactionsAsync;
    final pending = <String, Timer>{};
    var stopped = false;

    void refresh(String postId) async {
      pending.remove(postId);
      if (stopped) return;
      final reactions = await read(postId);
      if (stopped || reactions == null) return;
      _updates.add(DiscourseReactionUpdate(
          siteUrl: siteUrl, postId: postId, reactions: reactions));
    }

    void changed(String? postId) {
      if (postId == null || postId.isEmpty) return;
      final own = _ownUntil[_key(siteUrl, postId)];
      if (own != null) {
        if (DateTime.now().isBefore(own)) return;
        _ownUntil.remove(_key(siteUrl, postId));
      }
      pending[postId]?.cancel();
      pending[postId] = Timer(debounce, () => refresh(postId));
    }

    final unsubscribe = [
      bus.subscribe('/topic/$topicId/reactions',
          (data) => changed(data['post_id']?.toString())),
      bus.subscribe('/topic/$topicId', (data) {
        final type = data['type']?.toString();
        if (type != 'liked' && type != 'unliked') return;
        final actor = data['user_id']?.toString();
        if (viewerId != null && actor == viewerId) return;
        changed(data['id']?.toString());
      }),
    ];

    return () {
      if (stopped) return;
      stopped = true;
      for (final t in pending.values) {
        t.cancel();
      }
      pending.clear();
      for (final u in unsubscribe) {
        u();
      }
    };
  }
}
