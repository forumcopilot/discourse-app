// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'page.dart';

class DiscoursePageMapper extends ClassMapperBase<DiscoursePage> {
  DiscoursePageMapper._();

  static DiscoursePageMapper? _instance;
  static DiscoursePageMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DiscoursePageMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DiscoursePage';

  static int? _$publishDate(DiscoursePage v) => v.publishDate;
  static const Field<DiscoursePage, int> _f$publishDate =
      Field('publishDate', _$publishDate, opt: true);
  static int? _$viewCount(DiscoursePage v) => v.viewCount;
  static const Field<DiscoursePage, int> _f$viewCount =
      Field('viewCount', _$viewCount, opt: true);

  @override
  final MappableFields<DiscoursePage> fields = const {
    #publishDate: _f$publishDate,
    #viewCount: _f$viewCount,
  };

  static DiscoursePage _instantiate(DecodingData data) {
    return DiscoursePage(
        publishDate: data.dec(_f$publishDate),
        viewCount: data.dec(_f$viewCount));
  }

  @override
  final Function instantiate = _instantiate;

  static DiscoursePage fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DiscoursePage>(map);
  }

  static DiscoursePage fromJson(String json) {
    return ensureInitialized().decodeJson<DiscoursePage>(json);
  }
}

mixin DiscoursePageMappable {
  String toJson() {
    return DiscoursePageMapper.ensureInitialized()
        .encodeJson<DiscoursePage>(this as DiscoursePage);
  }

  Map<String, dynamic> toMap() {
    return DiscoursePageMapper.ensureInitialized()
        .encodeMap<DiscoursePage>(this as DiscoursePage);
  }

  DiscoursePageCopyWith<DiscoursePage, DiscoursePage, DiscoursePage> get copyWith =>
      _DiscoursePageCopyWithImpl<DiscoursePage, DiscoursePage>(
          this as DiscoursePage, $identity, $identity);
  @override
  String toString() {
    return DiscoursePageMapper.ensureInitialized()
        .stringifyValue(this as DiscoursePage);
  }

  @override
  bool operator ==(Object other) {
    return DiscoursePageMapper.ensureInitialized()
        .equalsValue(this as DiscoursePage, other);
  }

  @override
  int get hashCode {
    return DiscoursePageMapper.ensureInitialized().hashValue(this as DiscoursePage);
  }
}

extension DiscoursePageValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DiscoursePage, $Out> {
  DiscoursePageCopyWith<$R, DiscoursePage, $Out> get $asDiscoursePage =>
      $base.as((v, t, t2) => _DiscoursePageCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DiscoursePageCopyWith<$R, $In extends DiscoursePage, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? publishDate, int? viewCount});
  DiscoursePageCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DiscoursePageCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DiscoursePage, $Out>
    implements DiscoursePageCopyWith<$R, DiscoursePage, $Out> {
  _DiscoursePageCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DiscoursePage> $mapper =
      DiscoursePageMapper.ensureInitialized();
  @override
  $R call({Object? publishDate = $none, Object? viewCount = $none}) =>
      $apply(FieldCopyWithData({
        if (publishDate != $none) #publishDate: publishDate,
        if (viewCount != $none) #viewCount: viewCount
      }));
  @override
  DiscoursePage $make(CopyWithData data) => DiscoursePage(
      publishDate: data.get(#publishDate, or: $value.publishDate),
      viewCount: data.get(#viewCount, or: $value.viewCount));

  @override
  DiscoursePageCopyWith<$R2, DiscoursePage, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _DiscoursePageCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
