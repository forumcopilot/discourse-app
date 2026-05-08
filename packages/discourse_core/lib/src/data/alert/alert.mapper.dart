// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'alert.dart';

class DiscourseAlertMapper extends ClassMapperBase<DiscourseAlert> {
  DiscourseAlertMapper._();

  static DiscourseAlertMapper? _instance;
  static DiscourseAlertMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DiscourseAlertMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DiscourseAlert';

  static String _$id(DiscourseAlert v) => v.id;
  static const Field<DiscourseAlert, String> _f$id = Field('id', _$id);
  static String _$alertType(DiscourseAlert v) => v.alertType;
  static const Field<DiscourseAlert, String> _f$alertType =
      Field('alertType', _$alertType);
  static String _$contentType(DiscourseAlert v) => v.contentType;
  static const Field<DiscourseAlert, String> _f$contentType =
      Field('contentType', _$contentType);
  static String _$contentId(DiscourseAlert v) => v.contentId;
  static const Field<DiscourseAlert, String> _f$contentId =
      Field('contentId', _$contentId);
  static String _$userId(DiscourseAlert v) => v.userId;
  static const Field<DiscourseAlert, String> _f$userId =
      Field('userId', _$userId);
  static String _$userName(DiscourseAlert v) => v.userName;
  static const Field<DiscourseAlert, String> _f$userName =
      Field('userName', _$userName);
  static String _$action(DiscourseAlert v) => v.action;
  static const Field<DiscourseAlert, String> _f$action =
      Field('action', _$action);
  static String _$message(DiscourseAlert v) => v.message;
  static const Field<DiscourseAlert, String> _f$message =
      Field('message', _$message);
  static DateTime _$alertDate(DiscourseAlert v) => v.alertDate;
  static const Field<DiscourseAlert, DateTime> _f$alertDate =
      Field('alertDate', _$alertDate);
  static bool _$isRead(DiscourseAlert v) => v.isRead;
  static const Field<DiscourseAlert, bool> _f$isRead = Field('isRead', _$isRead);
  static bool _$isDismissed(DiscourseAlert v) => v.isDismissed;
  static const Field<DiscourseAlert, bool> _f$isDismissed =
      Field('isDismissed', _$isDismissed);
  static Map<String, dynamic> _$extraData(DiscourseAlert v) => v.extraData;
  static const Field<DiscourseAlert, Map<String, dynamic>> _f$extraData =
      Field('extraData', _$extraData);

  @override
  final MappableFields<DiscourseAlert> fields = const {
    #id: _f$id,
    #alertType: _f$alertType,
    #contentType: _f$contentType,
    #contentId: _f$contentId,
    #userId: _f$userId,
    #userName: _f$userName,
    #action: _f$action,
    #message: _f$message,
    #alertDate: _f$alertDate,
    #isRead: _f$isRead,
    #isDismissed: _f$isDismissed,
    #extraData: _f$extraData,
  };

  static DiscourseAlert _instantiate(DecodingData data) {
    return DiscourseAlert(
        id: data.dec(_f$id),
        alertType: data.dec(_f$alertType),
        contentType: data.dec(_f$contentType),
        contentId: data.dec(_f$contentId),
        userId: data.dec(_f$userId),
        userName: data.dec(_f$userName),
        action: data.dec(_f$action),
        message: data.dec(_f$message),
        alertDate: data.dec(_f$alertDate),
        isRead: data.dec(_f$isRead),
        isDismissed: data.dec(_f$isDismissed),
        extraData: data.dec(_f$extraData));
  }

  @override
  final Function instantiate = _instantiate;

  static DiscourseAlert fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DiscourseAlert>(map);
  }

  static DiscourseAlert fromJson(String json) {
    return ensureInitialized().decodeJson<DiscourseAlert>(json);
  }
}

mixin DiscourseAlertMappable {
  String toJson() {
    return DiscourseAlertMapper.ensureInitialized()
        .encodeJson<DiscourseAlert>(this as DiscourseAlert);
  }

  Map<String, dynamic> toMap() {
    return DiscourseAlertMapper.ensureInitialized()
        .encodeMap<DiscourseAlert>(this as DiscourseAlert);
  }

  DiscourseAlertCopyWith<DiscourseAlert, DiscourseAlert, DiscourseAlert> get copyWith =>
      _DiscourseAlertCopyWithImpl<DiscourseAlert, DiscourseAlert>(
          this as DiscourseAlert, $identity, $identity);
  @override
  String toString() {
    return DiscourseAlertMapper.ensureInitialized()
        .stringifyValue(this as DiscourseAlert);
  }

  @override
  bool operator ==(Object other) {
    return DiscourseAlertMapper.ensureInitialized()
        .equalsValue(this as DiscourseAlert, other);
  }

  @override
  int get hashCode {
    return DiscourseAlertMapper.ensureInitialized()
        .hashValue(this as DiscourseAlert);
  }
}

extension DiscourseAlertValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DiscourseAlert, $Out> {
  DiscourseAlertCopyWith<$R, DiscourseAlert, $Out> get $asDiscourseAlert =>
      $base.as((v, t, t2) => _DiscourseAlertCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DiscourseAlertCopyWith<$R, $In extends DiscourseAlert, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>
      get extraData;
  $R call(
      {String? id,
      String? alertType,
      String? contentType,
      String? contentId,
      String? userId,
      String? userName,
      String? action,
      String? message,
      DateTime? alertDate,
      bool? isRead,
      bool? isDismissed,
      Map<String, dynamic>? extraData});
  DiscourseAlertCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DiscourseAlertCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DiscourseAlert, $Out>
    implements DiscourseAlertCopyWith<$R, DiscourseAlert, $Out> {
  _DiscourseAlertCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DiscourseAlert> $mapper =
      DiscourseAlertMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>
      get extraData => MapCopyWith($value.extraData,
          (v, t) => ObjectCopyWith(v, $identity, t), (v) => call(extraData: v));
  @override
  $R call(
          {String? id,
          String? alertType,
          String? contentType,
          String? contentId,
          String? userId,
          String? userName,
          String? action,
          String? message,
          DateTime? alertDate,
          bool? isRead,
          bool? isDismissed,
          Map<String, dynamic>? extraData}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (alertType != null) #alertType: alertType,
        if (contentType != null) #contentType: contentType,
        if (contentId != null) #contentId: contentId,
        if (userId != null) #userId: userId,
        if (userName != null) #userName: userName,
        if (action != null) #action: action,
        if (message != null) #message: message,
        if (alertDate != null) #alertDate: alertDate,
        if (isRead != null) #isRead: isRead,
        if (isDismissed != null) #isDismissed: isDismissed,
        if (extraData != null) #extraData: extraData
      }));
  @override
  DiscourseAlert $make(CopyWithData data) => DiscourseAlert(
      id: data.get(#id, or: $value.id),
      alertType: data.get(#alertType, or: $value.alertType),
      contentType: data.get(#contentType, or: $value.contentType),
      contentId: data.get(#contentId, or: $value.contentId),
      userId: data.get(#userId, or: $value.userId),
      userName: data.get(#userName, or: $value.userName),
      action: data.get(#action, or: $value.action),
      message: data.get(#message, or: $value.message),
      alertDate: data.get(#alertDate, or: $value.alertDate),
      isRead: data.get(#isRead, or: $value.isRead),
      isDismissed: data.get(#isDismissed, or: $value.isDismissed),
      extraData: data.get(#extraData, or: $value.extraData));

  @override
  DiscourseAlertCopyWith<$R2, DiscourseAlert, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _DiscourseAlertCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
