// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'forum.dart';

class DiscourseForumMapper extends ClassMapperBase<DiscourseForum> {
  DiscourseForumMapper._();

  static DiscourseForumMapper? _instance;
  static DiscourseForumMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DiscourseForumMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DiscourseForum';

  static String? _$forumTypeId(DiscourseForum v) => v.forumTypeId;
  static const Field<DiscourseForum, String> _f$forumTypeId =
      Field('forumTypeId', _$forumTypeId, opt: true);
  static bool? _$allowPosting(DiscourseForum v) => v.allowPosting;
  static const Field<DiscourseForum, bool> _f$allowPosting =
      Field('allowPosting', _$allowPosting, opt: true);
  static bool? _$requirePrefix(DiscourseForum v) => v.requirePrefix;
  static const Field<DiscourseForum, bool> _f$requirePrefix =
      Field('requirePrefix', _$requirePrefix, opt: true);
  static int? _$minTags(DiscourseForum v) => v.minTags;
  static const Field<DiscourseForum, int> _f$minTags =
      Field('minTags', _$minTags, opt: true);

  @override
  final MappableFields<DiscourseForum> fields = const {
    #forumTypeId: _f$forumTypeId,
    #allowPosting: _f$allowPosting,
    #requirePrefix: _f$requirePrefix,
    #minTags: _f$minTags,
  };

  static DiscourseForum _instantiate(DecodingData data) {
    return DiscourseForum(
        forumTypeId: data.dec(_f$forumTypeId),
        allowPosting: data.dec(_f$allowPosting),
        requirePrefix: data.dec(_f$requirePrefix),
        minTags: data.dec(_f$minTags));
  }

  @override
  final Function instantiate = _instantiate;

  static DiscourseForum fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DiscourseForum>(map);
  }

  static DiscourseForum fromJson(String json) {
    return ensureInitialized().decodeJson<DiscourseForum>(json);
  }
}

mixin DiscourseForumMappable {
  String toJson() {
    return DiscourseForumMapper.ensureInitialized()
        .encodeJson<DiscourseForum>(this as DiscourseForum);
  }

  Map<String, dynamic> toMap() {
    return DiscourseForumMapper.ensureInitialized()
        .encodeMap<DiscourseForum>(this as DiscourseForum);
  }

  DiscourseForumCopyWith<DiscourseForum, DiscourseForum, DiscourseForum> get copyWith =>
      _DiscourseForumCopyWithImpl<DiscourseForum, DiscourseForum>(
          this as DiscourseForum, $identity, $identity);
  @override
  String toString() {
    return DiscourseForumMapper.ensureInitialized()
        .stringifyValue(this as DiscourseForum);
  }

  @override
  bool operator ==(Object other) {
    return DiscourseForumMapper.ensureInitialized()
        .equalsValue(this as DiscourseForum, other);
  }

  @override
  int get hashCode {
    return DiscourseForumMapper.ensureInitialized()
        .hashValue(this as DiscourseForum);
  }
}

extension DiscourseForumValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DiscourseForum, $Out> {
  DiscourseForumCopyWith<$R, DiscourseForum, $Out> get $asDiscourseForum =>
      $base.as((v, t, t2) => _DiscourseForumCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DiscourseForumCopyWith<$R, $In extends DiscourseForum, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {String? forumTypeId,
      bool? allowPosting,
      bool? requirePrefix,
      int? minTags});
  DiscourseForumCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DiscourseForumCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DiscourseForum, $Out>
    implements DiscourseForumCopyWith<$R, DiscourseForum, $Out> {
  _DiscourseForumCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DiscourseForum> $mapper =
      DiscourseForumMapper.ensureInitialized();
  @override
  $R call(
          {Object? forumTypeId = $none,
          Object? allowPosting = $none,
          Object? requirePrefix = $none,
          Object? minTags = $none}) =>
      $apply(FieldCopyWithData({
        if (forumTypeId != $none) #forumTypeId: forumTypeId,
        if (allowPosting != $none) #allowPosting: allowPosting,
        if (requirePrefix != $none) #requirePrefix: requirePrefix,
        if (minTags != $none) #minTags: minTags
      }));
  @override
  DiscourseForum $make(CopyWithData data) => DiscourseForum(
      forumTypeId: data.get(#forumTypeId, or: $value.forumTypeId),
      allowPosting: data.get(#allowPosting, or: $value.allowPosting),
      requirePrefix: data.get(#requirePrefix, or: $value.requirePrefix),
      minTags: data.get(#minTags, or: $value.minTags));

  @override
  DiscourseForumCopyWith<$R2, DiscourseForum, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _DiscourseForumCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
