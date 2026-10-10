import 'package:forumcopilot_sdk/models/entities/fc_post_reaction.dart';

/// The viewer's reaction on a post, or null. Discourse allows one reaction
/// per person per post (a unique index on user and post), so there is at
/// most one.
FCPostReaction? viewerReactionOf(List<FCPostReaction> reactions) {
  for (final r in reactions) {
    if (r.viewerReacted) return r;
  }
  return null;
}

/// How many people reacted: one reaction each, so the sum of the counts.
/// The web shows `reaction_users_count`, the same number.
int reactionTotal(List<FCPostReaction> reactions) =>
    reactions.fold<int>(0, (sum, r) => sum + r.count);

/// [reactions] once the viewer has toggled [reactionId], the way the
/// server's `ReactionManager` applies it: the viewer's own reaction again
/// removes it, any other replaces it. For drawing the change at once, before
/// the server answers; its answer then replaces this.
///
/// Ordered as the server orders them: most used first, then by name.
List<FCPostReaction> toggledReactions(
  List<FCPostReaction> reactions,
  String reactionId,
) {
  final mine = viewerReactionOf(reactions);
  final out = <FCPostReaction>[
    for (final r in reactions)
      if (!r.viewerReacted)
        FCPostReaction(id: r.id, type: r.type, count: r.count)
      else if (r.count > 1)
        FCPostReaction(id: r.id, type: r.type, count: r.count - 1),
  ];
  if (mine?.id != reactionId) {
    final i = out.indexWhere((r) => r.id == reactionId);
    if (i >= 0) {
      final r = out[i];
      out[i] = FCPostReaction(
          id: r.id, type: r.type, count: r.count + 1, viewerReacted: true, canUndo: true);
    } else {
      out.add(FCPostReaction(id: reactionId, count: 1, viewerReacted: true, canUndo: true));
    }
  }
  out.sort((a, b) {
    final byCount = b.count.compareTo(a.count);
    return byCount != 0 ? byCount : a.id.compareTo(b.id);
  });
  return out;
}

/// A reaction's name for a sentence: `open_mouth` → "open mouth".
String reactionDisplayName(String reactionId) =>
    reactionId.replaceAll(':', '').replaceAll('_', ' ').trim();
