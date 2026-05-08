// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'poll.dart';

class DiscoursePollMapper extends ClassMapperBase<DiscoursePoll> {
  DiscoursePollMapper._();

  static DiscoursePollMapper? _instance;
  static DiscoursePollMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DiscoursePollMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DiscoursePoll';

  static bool? _$canVote(DiscoursePoll v) => v.canVote;
  static const Field<DiscoursePoll, bool> _f$canVote =
      Field('canVote', _$canVote, opt: true);
  static bool? _$hasVoted(DiscoursePoll v) => v.hasVoted;
  static const Field<DiscoursePoll, bool> _f$hasVoted =
      Field('hasVoted', _$hasVoted, opt: true);
  static List<Map<String, dynamic>>? _$responses(DiscoursePoll v) => v.responses;
  static const Field<DiscoursePoll, List<Map<String, dynamic>>> _f$responses =
      Field('responses', _$responses, opt: true);
  static int _$pollId(DiscoursePoll v) => v.pollId;
  static const Field<DiscoursePoll, int> _f$pollId = Field('pollId', _$pollId);
  static String? _$question(DiscoursePoll v) => v.question;
  static const Field<DiscoursePoll, String> _f$question =
      Field('question', _$question, opt: true);
  static int? _$voterCount(DiscoursePoll v) => v.voterCount;
  static const Field<DiscoursePoll, int> _f$voterCount =
      Field('voterCount', _$voterCount, opt: true);
  static bool? _$publicVotes(DiscoursePoll v) => v.publicVotes;
  static const Field<DiscoursePoll, bool> _f$publicVotes =
      Field('publicVotes', _$publicVotes, opt: true);
  static int? _$maxVotes(DiscoursePoll v) => v.maxVotes;
  static const Field<DiscoursePoll, int> _f$maxVotes =
      Field('maxVotes', _$maxVotes, opt: true);
  static int? _$closeDate(DiscoursePoll v) => v.closeDate;
  static const Field<DiscoursePoll, int> _f$closeDate =
      Field('closeDate', _$closeDate, opt: true);
  static bool? _$changeVote(DiscoursePoll v) => v.changeVote;
  static const Field<DiscoursePoll, bool> _f$changeVote =
      Field('changeVote', _$changeVote, opt: true);
  static bool? _$viewResultsUnvoted(DiscoursePoll v) => v.viewResultsUnvoted;
  static const Field<DiscoursePoll, bool> _f$viewResultsUnvoted =
      Field('viewResultsUnvoted', _$viewResultsUnvoted, opt: true);

  @override
  final MappableFields<DiscoursePoll> fields = const {
    #canVote: _f$canVote,
    #hasVoted: _f$hasVoted,
    #responses: _f$responses,
    #pollId: _f$pollId,
    #question: _f$question,
    #voterCount: _f$voterCount,
    #publicVotes: _f$publicVotes,
    #maxVotes: _f$maxVotes,
    #closeDate: _f$closeDate,
    #changeVote: _f$changeVote,
    #viewResultsUnvoted: _f$viewResultsUnvoted,
  };

  static DiscoursePoll _instantiate(DecodingData data) {
    return DiscoursePoll(
        canVote: data.dec(_f$canVote),
        hasVoted: data.dec(_f$hasVoted),
        responses: data.dec(_f$responses),
        pollId: data.dec(_f$pollId),
        question: data.dec(_f$question),
        voterCount: data.dec(_f$voterCount),
        publicVotes: data.dec(_f$publicVotes),
        maxVotes: data.dec(_f$maxVotes),
        closeDate: data.dec(_f$closeDate),
        changeVote: data.dec(_f$changeVote),
        viewResultsUnvoted: data.dec(_f$viewResultsUnvoted));
  }

  @override
  final Function instantiate = _instantiate;

  static DiscoursePoll fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DiscoursePoll>(map);
  }

  static DiscoursePoll fromJson(String json) {
    return ensureInitialized().decodeJson<DiscoursePoll>(json);
  }
}

mixin DiscoursePollMappable {
  String toJson() {
    return DiscoursePollMapper.ensureInitialized()
        .encodeJson<DiscoursePoll>(this as DiscoursePoll);
  }

  Map<String, dynamic> toMap() {
    return DiscoursePollMapper.ensureInitialized()
        .encodeMap<DiscoursePoll>(this as DiscoursePoll);
  }

  DiscoursePollCopyWith<DiscoursePoll, DiscoursePoll, DiscoursePoll> get copyWith =>
      _DiscoursePollCopyWithImpl<DiscoursePoll, DiscoursePoll>(
          this as DiscoursePoll, $identity, $identity);
  @override
  String toString() {
    return DiscoursePollMapper.ensureInitialized()
        .stringifyValue(this as DiscoursePoll);
  }

  @override
  bool operator ==(Object other) {
    return DiscoursePollMapper.ensureInitialized()
        .equalsValue(this as DiscoursePoll, other);
  }

  @override
  int get hashCode {
    return DiscoursePollMapper.ensureInitialized().hashValue(this as DiscoursePoll);
  }
}

extension DiscoursePollValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DiscoursePoll, $Out> {
  DiscoursePollCopyWith<$R, DiscoursePoll, $Out> get $asDiscoursePoll =>
      $base.as((v, t, t2) => _DiscoursePollCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DiscoursePollCopyWith<$R, $In extends DiscoursePoll, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Map<String, dynamic>,
          ObjectCopyWith<$R, Map<String, dynamic>, Map<String, dynamic>>>?
      get responses;
  $R call(
      {bool? canVote,
      bool? hasVoted,
      List<Map<String, dynamic>>? responses,
      int? pollId,
      String? question,
      int? voterCount,
      bool? publicVotes,
      int? maxVotes,
      int? closeDate,
      bool? changeVote,
      bool? viewResultsUnvoted});
  DiscoursePollCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DiscoursePollCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DiscoursePoll, $Out>
    implements DiscoursePollCopyWith<$R, DiscoursePoll, $Out> {
  _DiscoursePollCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DiscoursePoll> $mapper =
      DiscoursePollMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Map<String, dynamic>,
          ObjectCopyWith<$R, Map<String, dynamic>, Map<String, dynamic>>>?
      get responses => $value.responses != null
          ? ListCopyWith(
              $value.responses!,
              (v, t) => ObjectCopyWith(v, $identity, t),
              (v) => call(responses: v))
          : null;
  @override
  $R call(
          {Object? canVote = $none,
          Object? hasVoted = $none,
          Object? responses = $none,
          int? pollId,
          Object? question = $none,
          Object? voterCount = $none,
          Object? publicVotes = $none,
          Object? maxVotes = $none,
          Object? closeDate = $none,
          Object? changeVote = $none,
          Object? viewResultsUnvoted = $none}) =>
      $apply(FieldCopyWithData({
        if (canVote != $none) #canVote: canVote,
        if (hasVoted != $none) #hasVoted: hasVoted,
        if (responses != $none) #responses: responses,
        if (pollId != null) #pollId: pollId,
        if (question != $none) #question: question,
        if (voterCount != $none) #voterCount: voterCount,
        if (publicVotes != $none) #publicVotes: publicVotes,
        if (maxVotes != $none) #maxVotes: maxVotes,
        if (closeDate != $none) #closeDate: closeDate,
        if (changeVote != $none) #changeVote: changeVote,
        if (viewResultsUnvoted != $none) #viewResultsUnvoted: viewResultsUnvoted
      }));
  @override
  DiscoursePoll $make(CopyWithData data) => DiscoursePoll(
      canVote: data.get(#canVote, or: $value.canVote),
      hasVoted: data.get(#hasVoted, or: $value.hasVoted),
      responses: data.get(#responses, or: $value.responses),
      pollId: data.get(#pollId, or: $value.pollId),
      question: data.get(#question, or: $value.question),
      voterCount: data.get(#voterCount, or: $value.voterCount),
      publicVotes: data.get(#publicVotes, or: $value.publicVotes),
      maxVotes: data.get(#maxVotes, or: $value.maxVotes),
      closeDate: data.get(#closeDate, or: $value.closeDate),
      changeVote: data.get(#changeVote, or: $value.changeVote),
      viewResultsUnvoted:
          data.get(#viewResultsUnvoted, or: $value.viewResultsUnvoted));

  @override
  DiscoursePollCopyWith<$R2, DiscoursePoll, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _DiscoursePollCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
