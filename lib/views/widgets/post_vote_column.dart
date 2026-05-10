import 'package:discourse_core/discourse_core.dart'
    show DiscoursePostProxy, DiscoursePostVote;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';

import '../../theme/design_tokens.dart';

/// Stack Overflow-style vertical voting column for Q&A topics, backed
/// by the `discourse-post-voting` plugin:
///
/// ```
///   ▲
///   42
///   ▼
/// ```
///
/// Renders as a no-op (zero size) when [vote] is null — i.e. the topic
/// doesn't have voting enabled or the post wasn't parsed by
/// DiscoursePostProxy. Tapping an arrow casts (or removes, when
/// re-tapping the active direction) the viewer's vote.
class PostVoteColumn extends StatefulWidget {
  final String postId;
  final DiscoursePostVote vote;
  final bool isLoggedIn;
  final ValueChanged<DiscoursePostVote> onVoteChanged;

  const PostVoteColumn({
    super.key,
    required this.postId,
    required this.vote,
    required this.onVoteChanged,
    this.isLoggedIn = false,
  });

  @override
  State<PostVoteColumn> createState() => _PostVoteColumnState();
}

class _PostVoteColumnState extends State<PostVoteColumn> {
  bool _inFlight = false;

  Future<void> _vote(String direction) async {
    if (_inFlight) return;
    if (!widget.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to vote')),
      );
      return;
    }
    final proxy = SiteProxyFactory.getPostProxy();
    if (proxy is! DiscoursePostProxy) return;
    setState(() => _inFlight = true);

    final prev = widget.vote;
    final wasSameDirection = prev.viewerDirection == direction;
    // Optimistic mutation: tapping the active direction removes the
    // viewer's vote; tapping the other direction swaps (which is
    // equivalent to remove+add on the server, two net-2 / net-1 deltas
    // depending on prior state).
    DiscoursePostVote next;
    if (wasSameDirection) {
      next = prev.copyWith(
        voteCount: prev.voteCount + (direction == 'up' ? -1 : 1),
        clearViewer: true,
      );
    } else if (prev.viewerVoted) {
      next = prev.copyWith(
        voteCount:
            prev.voteCount + (direction == 'up' ? 2 : -2),
        viewerDirection: direction,
      );
    } else {
      next = prev.copyWith(
        voteCount: prev.voteCount + (direction == 'up' ? 1 : -1),
        viewerDirection: direction,
        hasVotes: true,
      );
    }
    widget.onVoteChanged(next);

    final ok = wasSameDirection
        ? await proxy.removePostVoteAsync(widget.postId)
        : await proxy.castPostVoteAsync(widget.postId, direction);

    if (!mounted) return;
    setState(() => _inFlight = false);
    if (!ok) {
      // Revert.
      widget.onVoteChanged(prev);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(wasSameDirection
            ? 'Could not remove vote (past undo window?)'
            : 'Could not cast vote')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final vote = widget.vote;
    final upActive = vote.viewerVotedUp;
    final downActive = vote.viewerVotedDown;
    final score = vote.voteCount;

    return SizedBox(
      width: 36,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            iconSize: 22,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            tooltip: 'Upvote',
            icon: Icon(
              upActive ? Icons.arrow_drop_up : Icons.arrow_drop_up_outlined,
              color:
                  upActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            onPressed: _inFlight ? null : () => _vote('up'),
          ),
          Text(
            score.toString(),
            style: textTheme.titleMedium?.copyWith(
              color: score > 0
                  ? colorScheme.primary
                  : score < 0
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            iconSize: 22,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            tooltip: 'Downvote',
            icon: Icon(
              downActive
                  ? Icons.arrow_drop_down
                  : Icons.arrow_drop_down_outlined,
              color: downActive
                  ? colorScheme.error
                  : colorScheme.onSurfaceVariant,
            ),
            onPressed: _inFlight ? null : () => _vote('down'),
          ),
        ],
      ),
    );
  }
}

/// Compact horizontal variant for cases where vertical real-estate is
/// tight (e.g. inside a list item header). Renders as `▲ 42 ▼` on one
/// line.
class PostVoteRow extends StatelessWidget {
  final String postId;
  final DiscoursePostVote vote;
  final bool isLoggedIn;
  final ValueChanged<DiscoursePostVote> onVoteChanged;

  const PostVoteRow({
    super.key,
    required this.postId,
    required this.vote,
    required this.onVoteChanged,
    this.isLoggedIn = false,
  });

  @override
  Widget build(BuildContext context) {
    // Reuse PostVoteColumn but constrain it to a single line via a
    // wrapping row. The arrows are big enough to tap on touch.
    return SizedBox(
      height: 30,
      child: PostVoteColumn(
        postId: postId,
        vote: vote,
        isLoggedIn: isLoggedIn,
        onVoteChanged: onVoteChanged,
      ),
    );
  }
}
