// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'thread_prefix.dart';

class DiscourseThreadPrefixMapper extends ClassMapperBase<DiscourseThreadPrefix> {
  DiscourseThreadPrefixMapper._();

  static DiscourseThreadPrefixMapper? _instance;
  static DiscourseThreadPrefixMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DiscourseThreadPrefixMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DiscourseThreadPrefix';

  static int _$prefixId(DiscourseThreadPrefix v) => v.prefixId;
  static const Field<DiscourseThreadPrefix, int> _f$prefixId =
      Field('prefixId', _$prefixId);
  static String? _$title(DiscourseThreadPrefix v) => v.title;
  static const Field<DiscourseThreadPrefix, String> _f$title =
      Field('title', _$title, opt: true);
  static String? _$description(DiscourseThreadPrefix v) => v.description;
  static const Field<DiscourseThreadPrefix, String> _f$description =
      Field('description', _$description, opt: true);
  static String? _$usageHelp(DiscourseThreadPrefix v) => v.usageHelp;
  static const Field<DiscourseThreadPrefix, String> _f$usageHelp =
      Field('usageHelp', _$usageHelp, opt: true);
  static bool? _$isUsable(DiscourseThreadPrefix v) => v.isUsable;
  static const Field<DiscourseThreadPrefix, bool> _f$isUsable =
      Field('isUsable', _$isUsable, opt: true);
  static int? _$prefixGroupId(DiscourseThreadPrefix v) => v.prefixGroupId;
  static const Field<DiscourseThreadPrefix, int> _f$prefixGroupId =
      Field('prefixGroupId', _$prefixGroupId, opt: true);
  static int? _$displayOrder(DiscourseThreadPrefix v) => v.displayOrder;
  static const Field<DiscourseThreadPrefix, int> _f$displayOrder =
      Field('displayOrder', _$displayOrder, opt: true);
  static int? _$materializedOrder(DiscourseThreadPrefix v) => v.materializedOrder;
  static const Field<DiscourseThreadPrefix, int> _f$materializedOrder =
      Field('materializedOrder', _$materializedOrder, opt: true);

  @override
  final MappableFields<DiscourseThreadPrefix> fields = const {
    #prefixId: _f$prefixId,
    #title: _f$title,
    #description: _f$description,
    #usageHelp: _f$usageHelp,
    #isUsable: _f$isUsable,
    #prefixGroupId: _f$prefixGroupId,
    #displayOrder: _f$displayOrder,
    #materializedOrder: _f$materializedOrder,
  };

  static DiscourseThreadPrefix _instantiate(DecodingData data) {
    return DiscourseThreadPrefix(
        prefixId: data.dec(_f$prefixId),
        title: data.dec(_f$title),
        description: data.dec(_f$description),
        usageHelp: data.dec(_f$usageHelp),
        isUsable: data.dec(_f$isUsable),
        prefixGroupId: data.dec(_f$prefixGroupId),
        displayOrder: data.dec(_f$displayOrder),
        materializedOrder: data.dec(_f$materializedOrder));
  }

  @override
  final Function instantiate = _instantiate;

  static DiscourseThreadPrefix fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DiscourseThreadPrefix>(map);
  }

  static DiscourseThreadPrefix fromJson(String json) {
    return ensureInitialized().decodeJson<DiscourseThreadPrefix>(json);
  }
}

mixin DiscourseThreadPrefixMappable {
  String toJson() {
    return DiscourseThreadPrefixMapper.ensureInitialized()
        .encodeJson<DiscourseThreadPrefix>(this as DiscourseThreadPrefix);
  }

  Map<String, dynamic> toMap() {
    return DiscourseThreadPrefixMapper.ensureInitialized()
        .encodeMap<DiscourseThreadPrefix>(this as DiscourseThreadPrefix);
  }

  DiscourseThreadPrefixCopyWith<DiscourseThreadPrefix, DiscourseThreadPrefix,
      DiscourseThreadPrefix> get copyWith => _DiscourseThreadPrefixCopyWithImpl<
          DiscourseThreadPrefix, DiscourseThreadPrefix>(
      this as DiscourseThreadPrefix, $identity, $identity);
  @override
  String toString() {
    return DiscourseThreadPrefixMapper.ensureInitialized()
        .stringifyValue(this as DiscourseThreadPrefix);
  }

  @override
  bool operator ==(Object other) {
    return DiscourseThreadPrefixMapper.ensureInitialized()
        .equalsValue(this as DiscourseThreadPrefix, other);
  }

  @override
  int get hashCode {
    return DiscourseThreadPrefixMapper.ensureInitialized()
        .hashValue(this as DiscourseThreadPrefix);
  }
}

extension DiscourseThreadPrefixValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DiscourseThreadPrefix, $Out> {
  DiscourseThreadPrefixCopyWith<$R, DiscourseThreadPrefix, $Out>
      get $asDiscourseThreadPrefix => $base.as(
          (v, t, t2) => _DiscourseThreadPrefixCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DiscourseThreadPrefixCopyWith<$R, $In extends DiscourseThreadPrefix,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {int? prefixId,
      String? title,
      String? description,
      String? usageHelp,
      bool? isUsable,
      int? prefixGroupId,
      int? displayOrder,
      int? materializedOrder});
  DiscourseThreadPrefixCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _DiscourseThreadPrefixCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DiscourseThreadPrefix, $Out>
    implements DiscourseThreadPrefixCopyWith<$R, DiscourseThreadPrefix, $Out> {
  _DiscourseThreadPrefixCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DiscourseThreadPrefix> $mapper =
      DiscourseThreadPrefixMapper.ensureInitialized();
  @override
  $R call(
          {int? prefixId,
          Object? title = $none,
          Object? description = $none,
          Object? usageHelp = $none,
          Object? isUsable = $none,
          Object? prefixGroupId = $none,
          Object? displayOrder = $none,
          Object? materializedOrder = $none}) =>
      $apply(FieldCopyWithData({
        if (prefixId != null) #prefixId: prefixId,
        if (title != $none) #title: title,
        if (description != $none) #description: description,
        if (usageHelp != $none) #usageHelp: usageHelp,
        if (isUsable != $none) #isUsable: isUsable,
        if (prefixGroupId != $none) #prefixGroupId: prefixGroupId,
        if (displayOrder != $none) #displayOrder: displayOrder,
        if (materializedOrder != $none) #materializedOrder: materializedOrder
      }));
  @override
  DiscourseThreadPrefix $make(CopyWithData data) => DiscourseThreadPrefix(
      prefixId: data.get(#prefixId, or: $value.prefixId),
      title: data.get(#title, or: $value.title),
      description: data.get(#description, or: $value.description),
      usageHelp: data.get(#usageHelp, or: $value.usageHelp),
      isUsable: data.get(#isUsable, or: $value.isUsable),
      prefixGroupId: data.get(#prefixGroupId, or: $value.prefixGroupId),
      displayOrder: data.get(#displayOrder, or: $value.displayOrder),
      materializedOrder:
          data.get(#materializedOrder, or: $value.materializedOrder));

  @override
  DiscourseThreadPrefixCopyWith<$R2, DiscourseThreadPrefix, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _DiscourseThreadPrefixCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
