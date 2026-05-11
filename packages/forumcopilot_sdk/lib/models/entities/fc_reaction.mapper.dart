// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'fc_reaction.dart';

class FCReactionMapper extends ClassMapperBase<FCReaction> {
  FCReactionMapper._();

  static FCReactionMapper? _instance;
  static FCReactionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FCReactionMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'FCReaction';

  static String _$id(FCReaction v) => v.id;
  static const Field<FCReaction, String> _f$id = Field('id', _$id);
  static String _$type(FCReaction v) => v.type;
  static const Field<FCReaction, String> _f$type = Field(
    'type',
    _$type,
    opt: true,
    def: 'emoji',
  );
  static int _$count(FCReaction v) => v.count;
  static const Field<FCReaction, int> _f$count = Field('count', _$count);
  static bool _$viewerReacted(FCReaction v) => v.viewerReacted;
  static const Field<FCReaction, bool> _f$viewerReacted = Field(
    'viewerReacted',
    _$viewerReacted,
    opt: true,
    def: false,
  );
  static bool _$canUndo(FCReaction v) => v.canUndo;
  static const Field<FCReaction, bool> _f$canUndo = Field(
    'canUndo',
    _$canUndo,
    opt: true,
    def: false,
  );

  @override
  final MappableFields<FCReaction> fields = const {
    #id: _f$id,
    #type: _f$type,
    #count: _f$count,
    #viewerReacted: _f$viewerReacted,
    #canUndo: _f$canUndo,
  };

  static FCReaction _instantiate(DecodingData data) {
    return FCReaction(
      id: data.dec(_f$id),
      type: data.dec(_f$type),
      count: data.dec(_f$count),
      viewerReacted: data.dec(_f$viewerReacted),
      canUndo: data.dec(_f$canUndo),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static FCReaction fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<FCReaction>(map);
  }

  static FCReaction fromJson(String json) {
    return ensureInitialized().decodeJson<FCReaction>(json);
  }
}

mixin FCReactionMappable {
  String toJson() {
    return FCReactionMapper.ensureInitialized()
        .encodeJson<FCReaction>(this as FCReaction);
  }

  Map<String, dynamic> toMap() {
    return FCReactionMapper.ensureInitialized()
        .encodeMap<FCReaction>(this as FCReaction);
  }

  FCReactionCopyWith<FCReaction, FCReaction, FCReaction> get copyWith =>
      _FCReactionCopyWithImpl<FCReaction, FCReaction>(
          this as FCReaction, $identity, $identity);
  @override
  String toString() {
    return FCReactionMapper.ensureInitialized()
        .stringifyValue(this as FCReaction);
  }

  @override
  bool operator ==(Object other) {
    return FCReactionMapper.ensureInitialized()
        .equalsValue(this as FCReaction, other);
  }

  @override
  int get hashCode {
    return FCReactionMapper.ensureInitialized().hashValue(this as FCReaction);
  }
}

extension FCReactionValueCopy<$R, $Out> on ObjectCopyWith<$R, FCReaction, $Out> {
  FCReactionCopyWith<$R, FCReaction, $Out> get $asFCReaction =>
      $base.as((v, t, t2) => _FCReactionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class FCReactionCopyWith<$R, $In extends FCReaction, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? type,
    int? count,
    bool? viewerReacted,
    bool? canUndo,
  });
  FCReactionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _FCReactionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, FCReaction, $Out>
    implements FCReactionCopyWith<$R, FCReaction, $Out> {
  _FCReactionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<FCReaction> $mapper =
      FCReactionMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? type,
    int? count,
    bool? viewerReacted,
    bool? canUndo,
  }) =>
      $apply(
        FieldCopyWithData({
          if (id != null) #id: id,
          if (type != null) #type: type,
          if (count != null) #count: count,
          if (viewerReacted != null) #viewerReacted: viewerReacted,
          if (canUndo != null) #canUndo: canUndo,
        }),
      );
  @override
  FCReaction $make(CopyWithData data) => FCReaction(
        id: data.get(#id, or: $value.id),
        type: data.get(#type, or: $value.type),
        count: data.get(#count, or: $value.count),
        viewerReacted: data.get(#viewerReacted, or: $value.viewerReacted),
        canUndo: data.get(#canUndo, or: $value.canUndo),
      );

  @override
  FCReactionCopyWith<$R2, FCReaction, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _FCReactionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
