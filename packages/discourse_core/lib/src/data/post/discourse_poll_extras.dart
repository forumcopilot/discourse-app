import 'package:forumcopilot_sdk/models/entities/fc_poll.dart';

/// What Discourse says about a poll beyond [FCPoll]: its type and, for a
/// ranked-choice poll, the viewer's ballot and the outcome.
///
/// [FCPoll] has single and multiple choice only. A ranked-choice poll
/// (`type: ranked_choice`) is voted with a rank for every option, 0 meaning
/// Abstain (`DiscoursePoll::Poll.vote` rejects a ballot that leaves an
/// option out, or ranks none), and its result is an instant-runoff outcome,
/// not per-option counts: every voter has a vote row on every option, so
/// each option's `votes` is the voter count.
///
/// Kept beside the poll it was parsed with (an [Expando] on that [FCPoll]),
/// like the other Discourse side stores, so the SDK model stays as it is;
/// the poll a vote returns carries its own.
class DiscoursePollExtras {
  const DiscoursePollExtras({
    required this.type,
    this.viewerRanks = const {},
    this.outcome,
  });

  static const String rankedChoiceType = 'ranked_choice';

  /// `regular`, `multiple`, `number` or `ranked_choice`.
  final String type;

  /// The viewer's ballot in a ranked-choice poll: option digest → rank,
  /// 0 for Abstain. Empty when the viewer has not voted, and for any other
  /// type of poll.
  final Map<String, int> viewerRanks;

  /// The ranked-choice outcome (`ranked_choice_outcome`); null before the
  /// first vote and for any other type of poll. The server sends it even
  /// when the poll's results are hidden from the viewer, so whoever draws it
  /// checks [FCPoll.canViewResults] first.
  final DiscourseRankedChoiceOutcome? outcome;

  bool get isRankedChoice => type == rankedChoiceType;

  static final Expando<DiscoursePollExtras> _byPoll =
      Expando('discoursePollExtras');

  /// The extras parsed with [poll], or null for a poll that did not come
  /// from a Discourse payload.
  static DiscoursePollExtras? of(FCPoll poll) => _byPoll[poll];

  static void attach(FCPoll poll, DiscoursePollExtras extras) =>
      _byPoll[poll] = extras;

  /// A ranked-choice ballot as `polls_votes[name]` and the vote response's
  /// `vote` carry it: `[{digest, rank}]`, the rank a number or (echoed from
  /// the request's form values) a string.
  static Map<String, int> ranksFromBallot(Iterable<Object?> ballot) {
    final ranks = <String, int>{};
    for (final entry in ballot.whereType<Map>()) {
      final digest = entry['digest']?.toString() ?? '';
      final raw = entry['rank'];
      final rank = raw is num ? raw.toInt() : int.tryParse('${raw ?? ''}');
      if (digest.isNotEmpty && rank != null && rank >= 0) ranks[digest] = rank;
    }
    return ranks;
  }
}

/// `ranked_choice_outcome` (`DiscoursePoll::RankedChoice.run`): a winner by
/// majority, or the candidates still tied when the rounds ran out.
class DiscourseRankedChoiceOutcome {
  const DiscourseRankedChoiceOutcome({
    required this.tied,
    this.winnerId,
    this.tiedIds = const [],
  });

  final bool tied;

  /// The winning option's digest.
  final String? winnerId;

  /// The tied options' digests.
  final List<String> tiedIds;

  static DiscourseRankedChoiceOutcome? fromJson(Object? raw) {
    if (raw is! Map) return null;
    String? digest(Object? candidate) {
      final id = candidate is Map ? candidate['digest']?.toString() : null;
      return (id == null || id.isEmpty) ? null : id;
    }

    final tied = raw['tied'] == true;
    final winnerId = digest(raw['winning_candidate']);
    final tiedIds = ((raw['tied_candidates'] as List?) ?? const [])
        .map(digest)
        .whereType<String>()
        .toList();
    if (!tied && winnerId == null) return null;
    return DiscourseRankedChoiceOutcome(
      tied: tied,
      winnerId: tied ? null : winnerId,
      tiedIds: tied ? tiedIds : const [],
    );
  }
}
