// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'thread_field.dart';

class DiscourseThreadFieldMapper extends ClassMapperBase<DiscourseThreadField> {
  DiscourseThreadFieldMapper._();

  static DiscourseThreadFieldMapper? _instance;
  static DiscourseThreadFieldMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DiscourseThreadFieldMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DiscourseThreadField';

  static String _$fieldId(DiscourseThreadField v) => v.fieldId;
  static const Field<DiscourseThreadField, String> _f$fieldId =
      Field('fieldId', _$fieldId);
  static String? _$title(DiscourseThreadField v) => v.title;
  static const Field<DiscourseThreadField, String> _f$title =
      Field('title', _$title, opt: true);
  static String? _$description(DiscourseThreadField v) => v.description;
  static const Field<DiscourseThreadField, String> _f$description =
      Field('description', _$description, opt: true);
  static int? _$displayOrder(DiscourseThreadField v) => v.displayOrder;
  static const Field<DiscourseThreadField, int> _f$displayOrder =
      Field('displayOrder', _$displayOrder, opt: true);
  static String? _$fieldType(DiscourseThreadField v) => v.fieldType;
  static const Field<DiscourseThreadField, String> _f$fieldType =
      Field('fieldType', _$fieldType, opt: true);
  static Map<String, dynamic>? _$fieldChoices(DiscourseThreadField v) =>
      v.fieldChoices;
  static const Field<DiscourseThreadField, Map<String, dynamic>> _f$fieldChoices =
      Field('fieldChoices', _$fieldChoices, opt: true);
  static String? _$matchType(DiscourseThreadField v) => v.matchType;
  static const Field<DiscourseThreadField, String> _f$matchType =
      Field('matchType', _$matchType, opt: true);
  static List<dynamic>? _$matchParams(DiscourseThreadField v) => v.matchParams;
  static const Field<DiscourseThreadField, List<dynamic>> _f$matchParams =
      Field('matchParams', _$matchParams, opt: true);
  static int? _$maxLength(DiscourseThreadField v) => v.maxLength;
  static const Field<DiscourseThreadField, int> _f$maxLength =
      Field('maxLength', _$maxLength, opt: true);
  static bool? _$required(DiscourseThreadField v) => v.required;
  static const Field<DiscourseThreadField, bool> _f$required =
      Field('required', _$required, opt: true);
  static String? _$displayGroup(DiscourseThreadField v) => v.displayGroup;
  static const Field<DiscourseThreadField, String> _f$displayGroup =
      Field('displayGroup', _$displayGroup, opt: true);

  @override
  final MappableFields<DiscourseThreadField> fields = const {
    #fieldId: _f$fieldId,
    #title: _f$title,
    #description: _f$description,
    #displayOrder: _f$displayOrder,
    #fieldType: _f$fieldType,
    #fieldChoices: _f$fieldChoices,
    #matchType: _f$matchType,
    #matchParams: _f$matchParams,
    #maxLength: _f$maxLength,
    #required: _f$required,
    #displayGroup: _f$displayGroup,
  };

  static DiscourseThreadField _instantiate(DecodingData data) {
    return DiscourseThreadField(
        fieldId: data.dec(_f$fieldId),
        title: data.dec(_f$title),
        description: data.dec(_f$description),
        displayOrder: data.dec(_f$displayOrder),
        fieldType: data.dec(_f$fieldType),
        fieldChoices: data.dec(_f$fieldChoices),
        matchType: data.dec(_f$matchType),
        matchParams: data.dec(_f$matchParams),
        maxLength: data.dec(_f$maxLength),
        required: data.dec(_f$required),
        displayGroup: data.dec(_f$displayGroup));
  }

  @override
  final Function instantiate = _instantiate;

  static DiscourseThreadField fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DiscourseThreadField>(map);
  }

  static DiscourseThreadField fromJson(String json) {
    return ensureInitialized().decodeJson<DiscourseThreadField>(json);
  }
}

mixin DiscourseThreadFieldMappable {
  String toJson() {
    return DiscourseThreadFieldMapper.ensureInitialized()
        .encodeJson<DiscourseThreadField>(this as DiscourseThreadField);
  }

  Map<String, dynamic> toMap() {
    return DiscourseThreadFieldMapper.ensureInitialized()
        .encodeMap<DiscourseThreadField>(this as DiscourseThreadField);
  }

  DiscourseThreadFieldCopyWith<DiscourseThreadField, DiscourseThreadField,
          DiscourseThreadField>
      get copyWith => _DiscourseThreadFieldCopyWithImpl<DiscourseThreadField,
          DiscourseThreadField>(this as DiscourseThreadField, $identity, $identity);
  @override
  String toString() {
    return DiscourseThreadFieldMapper.ensureInitialized()
        .stringifyValue(this as DiscourseThreadField);
  }

  @override
  bool operator ==(Object other) {
    return DiscourseThreadFieldMapper.ensureInitialized()
        .equalsValue(this as DiscourseThreadField, other);
  }

  @override
  int get hashCode {
    return DiscourseThreadFieldMapper.ensureInitialized()
        .hashValue(this as DiscourseThreadField);
  }
}

extension DiscourseThreadFieldValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DiscourseThreadField, $Out> {
  DiscourseThreadFieldCopyWith<$R, DiscourseThreadField, $Out>
      get $asDiscourseThreadField => $base.as(
          (v, t, t2) => _DiscourseThreadFieldCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DiscourseThreadFieldCopyWith<$R, $In extends DiscourseThreadField,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get fieldChoices;
  ListCopyWith<$R, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get matchParams;
  $R call(
      {String? fieldId,
      String? title,
      String? description,
      int? displayOrder,
      String? fieldType,
      Map<String, dynamic>? fieldChoices,
      String? matchType,
      List<dynamic>? matchParams,
      int? maxLength,
      bool? required,
      String? displayGroup});
  DiscourseThreadFieldCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _DiscourseThreadFieldCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DiscourseThreadField, $Out>
    implements DiscourseThreadFieldCopyWith<$R, DiscourseThreadField, $Out> {
  _DiscourseThreadFieldCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DiscourseThreadField> $mapper =
      DiscourseThreadFieldMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get fieldChoices => $value.fieldChoices != null
          ? MapCopyWith(
              $value.fieldChoices!,
              (v, t) => ObjectCopyWith(v, $identity, t),
              (v) => call(fieldChoices: v))
          : null;
  @override
  ListCopyWith<$R, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get matchParams => $value.matchParams != null
          ? ListCopyWith(
              $value.matchParams!,
              (v, t) => ObjectCopyWith(v, $identity, t),
              (v) => call(matchParams: v))
          : null;
  @override
  $R call(
          {String? fieldId,
          Object? title = $none,
          Object? description = $none,
          Object? displayOrder = $none,
          Object? fieldType = $none,
          Object? fieldChoices = $none,
          Object? matchType = $none,
          Object? matchParams = $none,
          Object? maxLength = $none,
          Object? required = $none,
          Object? displayGroup = $none}) =>
      $apply(FieldCopyWithData({
        if (fieldId != null) #fieldId: fieldId,
        if (title != $none) #title: title,
        if (description != $none) #description: description,
        if (displayOrder != $none) #displayOrder: displayOrder,
        if (fieldType != $none) #fieldType: fieldType,
        if (fieldChoices != $none) #fieldChoices: fieldChoices,
        if (matchType != $none) #matchType: matchType,
        if (matchParams != $none) #matchParams: matchParams,
        if (maxLength != $none) #maxLength: maxLength,
        if (required != $none) #required: required,
        if (displayGroup != $none) #displayGroup: displayGroup
      }));
  @override
  DiscourseThreadField $make(CopyWithData data) => DiscourseThreadField(
      fieldId: data.get(#fieldId, or: $value.fieldId),
      title: data.get(#title, or: $value.title),
      description: data.get(#description, or: $value.description),
      displayOrder: data.get(#displayOrder, or: $value.displayOrder),
      fieldType: data.get(#fieldType, or: $value.fieldType),
      fieldChoices: data.get(#fieldChoices, or: $value.fieldChoices),
      matchType: data.get(#matchType, or: $value.matchType),
      matchParams: data.get(#matchParams, or: $value.matchParams),
      maxLength: data.get(#maxLength, or: $value.maxLength),
      required: data.get(#required, or: $value.required),
      displayGroup: data.get(#displayGroup, or: $value.displayGroup));

  @override
  DiscourseThreadFieldCopyWith<$R2, DiscourseThreadField, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _DiscourseThreadFieldCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
