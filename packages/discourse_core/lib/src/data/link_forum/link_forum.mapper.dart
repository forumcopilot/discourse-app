// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'link_forum.dart';

class DiscourseLinkForumMapper extends ClassMapperBase<DiscourseLinkForum> {
  DiscourseLinkForumMapper._();

  static DiscourseLinkForumMapper? _instance;
  static DiscourseLinkForumMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DiscourseLinkForumMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DiscourseLinkForum';

  static String? _$linkUrl(DiscourseLinkForum v) => v.linkUrl;
  static const Field<DiscourseLinkForum, String> _f$linkUrl =
      Field('linkUrl', _$linkUrl, opt: true);
  static int? _$redirectCount(DiscourseLinkForum v) => v.redirectCount;
  static const Field<DiscourseLinkForum, int> _f$redirectCount =
      Field('redirectCount', _$redirectCount, opt: true);

  @override
  final MappableFields<DiscourseLinkForum> fields = const {
    #linkUrl: _f$linkUrl,
    #redirectCount: _f$redirectCount,
  };

  static DiscourseLinkForum _instantiate(DecodingData data) {
    return DiscourseLinkForum(
        linkUrl: data.dec(_f$linkUrl),
        redirectCount: data.dec(_f$redirectCount));
  }

  @override
  final Function instantiate = _instantiate;

  static DiscourseLinkForum fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DiscourseLinkForum>(map);
  }

  static DiscourseLinkForum fromJson(String json) {
    return ensureInitialized().decodeJson<DiscourseLinkForum>(json);
  }
}

mixin DiscourseLinkForumMappable {
  String toJson() {
    return DiscourseLinkForumMapper.ensureInitialized()
        .encodeJson<DiscourseLinkForum>(this as DiscourseLinkForum);
  }

  Map<String, dynamic> toMap() {
    return DiscourseLinkForumMapper.ensureInitialized()
        .encodeMap<DiscourseLinkForum>(this as DiscourseLinkForum);
  }

  DiscourseLinkForumCopyWith<DiscourseLinkForum, DiscourseLinkForum, DiscourseLinkForum>
      get copyWith =>
          _DiscourseLinkForumCopyWithImpl<DiscourseLinkForum, DiscourseLinkForum>(
              this as DiscourseLinkForum, $identity, $identity);
  @override
  String toString() {
    return DiscourseLinkForumMapper.ensureInitialized()
        .stringifyValue(this as DiscourseLinkForum);
  }

  @override
  bool operator ==(Object other) {
    return DiscourseLinkForumMapper.ensureInitialized()
        .equalsValue(this as DiscourseLinkForum, other);
  }

  @override
  int get hashCode {
    return DiscourseLinkForumMapper.ensureInitialized()
        .hashValue(this as DiscourseLinkForum);
  }
}

extension DiscourseLinkForumValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DiscourseLinkForum, $Out> {
  DiscourseLinkForumCopyWith<$R, DiscourseLinkForum, $Out>
      get $asDiscourseLinkForum => $base
          .as((v, t, t2) => _DiscourseLinkForumCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DiscourseLinkForumCopyWith<$R, $In extends DiscourseLinkForum, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? linkUrl, int? redirectCount});
  DiscourseLinkForumCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _DiscourseLinkForumCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DiscourseLinkForum, $Out>
    implements DiscourseLinkForumCopyWith<$R, DiscourseLinkForum, $Out> {
  _DiscourseLinkForumCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DiscourseLinkForum> $mapper =
      DiscourseLinkForumMapper.ensureInitialized();
  @override
  $R call({Object? linkUrl = $none, Object? redirectCount = $none}) =>
      $apply(FieldCopyWithData({
        if (linkUrl != $none) #linkUrl: linkUrl,
        if (redirectCount != $none) #redirectCount: redirectCount
      }));
  @override
  DiscourseLinkForum $make(CopyWithData data) => DiscourseLinkForum(
      linkUrl: data.get(#linkUrl, or: $value.linkUrl),
      redirectCount: data.get(#redirectCount, or: $value.redirectCount));

  @override
  DiscourseLinkForumCopyWith<$R2, DiscourseLinkForum, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _DiscourseLinkForumCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
