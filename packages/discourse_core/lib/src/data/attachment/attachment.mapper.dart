// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'attachment.dart';

class DiscourseAttachmentMapper extends ClassMapperBase<DiscourseAttachment> {
  DiscourseAttachmentMapper._();

  static DiscourseAttachmentMapper? _instance;
  static DiscourseAttachmentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DiscourseAttachmentMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DiscourseAttachment';

  static int _$attachmentId(DiscourseAttachment v) => v.attachmentId;
  static const Field<DiscourseAttachment, int> _f$attachmentId =
      Field('attachmentId', _$attachmentId);
  static String _$filename(DiscourseAttachment v) => v.filename;
  static const Field<DiscourseAttachment, String> _f$filename =
      Field('filename', _$filename);
  static int _$fileSize(DiscourseAttachment v) => v.fileSize;
  static const Field<DiscourseAttachment, int> _f$fileSize =
      Field('fileSize', _$fileSize);
  static int? _$height(DiscourseAttachment v) => v.height;
  static const Field<DiscourseAttachment, int> _f$height =
      Field('height', _$height, opt: true);
  static int? _$width(DiscourseAttachment v) => v.width;
  static const Field<DiscourseAttachment, int> _f$width =
      Field('width', _$width, opt: true);
  static String? _$thumbnailUrl(DiscourseAttachment v) => v.thumbnailUrl;
  static const Field<DiscourseAttachment, String> _f$thumbnailUrl =
      Field('thumbnailUrl', _$thumbnailUrl, opt: true);
  static String? _$directUrl(DiscourseAttachment v) => v.directUrl;
  static const Field<DiscourseAttachment, String> _f$directUrl =
      Field('directUrl', _$directUrl, opt: true);
  static bool? _$isVideo(DiscourseAttachment v) => v.isVideo;
  static const Field<DiscourseAttachment, bool> _f$isVideo =
      Field('isVideo', _$isVideo, opt: true);
  static bool? _$isAudio(DiscourseAttachment v) => v.isAudio;
  static const Field<DiscourseAttachment, bool> _f$isAudio =
      Field('isAudio', _$isAudio, opt: true);
  static String? _$contentType(DiscourseAttachment v) => v.contentType;
  static const Field<DiscourseAttachment, String> _f$contentType =
      Field('contentType', _$contentType, opt: true);
  static int? _$contentId(DiscourseAttachment v) => v.contentId;
  static const Field<DiscourseAttachment, int> _f$contentId =
      Field('contentId', _$contentId, opt: true);
  static int? _$attachDate(DiscourseAttachment v) => v.attachDate;
  static const Field<DiscourseAttachment, int> _f$attachDate =
      Field('attachDate', _$attachDate, opt: true);
  static int? _$viewCount(DiscourseAttachment v) => v.viewCount;
  static const Field<DiscourseAttachment, int> _f$viewCount =
      Field('viewCount', _$viewCount, opt: true);

  @override
  final MappableFields<DiscourseAttachment> fields = const {
    #attachmentId: _f$attachmentId,
    #filename: _f$filename,
    #fileSize: _f$fileSize,
    #height: _f$height,
    #width: _f$width,
    #thumbnailUrl: _f$thumbnailUrl,
    #directUrl: _f$directUrl,
    #isVideo: _f$isVideo,
    #isAudio: _f$isAudio,
    #contentType: _f$contentType,
    #contentId: _f$contentId,
    #attachDate: _f$attachDate,
    #viewCount: _f$viewCount,
  };

  static DiscourseAttachment _instantiate(DecodingData data) {
    return DiscourseAttachment(
        attachmentId: data.dec(_f$attachmentId),
        filename: data.dec(_f$filename),
        fileSize: data.dec(_f$fileSize),
        height: data.dec(_f$height),
        width: data.dec(_f$width),
        thumbnailUrl: data.dec(_f$thumbnailUrl),
        directUrl: data.dec(_f$directUrl),
        isVideo: data.dec(_f$isVideo),
        isAudio: data.dec(_f$isAudio),
        contentType: data.dec(_f$contentType),
        contentId: data.dec(_f$contentId),
        attachDate: data.dec(_f$attachDate),
        viewCount: data.dec(_f$viewCount));
  }

  @override
  final Function instantiate = _instantiate;

  static DiscourseAttachment fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DiscourseAttachment>(map);
  }

  static DiscourseAttachment fromJson(String json) {
    return ensureInitialized().decodeJson<DiscourseAttachment>(json);
  }
}

mixin DiscourseAttachmentMappable {
  String toJson() {
    return DiscourseAttachmentMapper.ensureInitialized()
        .encodeJson<DiscourseAttachment>(this as DiscourseAttachment);
  }

  Map<String, dynamic> toMap() {
    return DiscourseAttachmentMapper.ensureInitialized()
        .encodeMap<DiscourseAttachment>(this as DiscourseAttachment);
  }

  DiscourseAttachmentCopyWith<DiscourseAttachment, DiscourseAttachment,
          DiscourseAttachment>
      get copyWith =>
          _DiscourseAttachmentCopyWithImpl<DiscourseAttachment, DiscourseAttachment>(
              this as DiscourseAttachment, $identity, $identity);
  @override
  String toString() {
    return DiscourseAttachmentMapper.ensureInitialized()
        .stringifyValue(this as DiscourseAttachment);
  }

  @override
  bool operator ==(Object other) {
    return DiscourseAttachmentMapper.ensureInitialized()
        .equalsValue(this as DiscourseAttachment, other);
  }

  @override
  int get hashCode {
    return DiscourseAttachmentMapper.ensureInitialized()
        .hashValue(this as DiscourseAttachment);
  }
}

extension DiscourseAttachmentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DiscourseAttachment, $Out> {
  DiscourseAttachmentCopyWith<$R, DiscourseAttachment, $Out>
      get $asDiscourseAttachment => $base
          .as((v, t, t2) => _DiscourseAttachmentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DiscourseAttachmentCopyWith<$R, $In extends DiscourseAttachment,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {int? attachmentId,
      String? filename,
      int? fileSize,
      int? height,
      int? width,
      String? thumbnailUrl,
      String? directUrl,
      bool? isVideo,
      bool? isAudio,
      String? contentType,
      int? contentId,
      int? attachDate,
      int? viewCount});
  DiscourseAttachmentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _DiscourseAttachmentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DiscourseAttachment, $Out>
    implements DiscourseAttachmentCopyWith<$R, DiscourseAttachment, $Out> {
  _DiscourseAttachmentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DiscourseAttachment> $mapper =
      DiscourseAttachmentMapper.ensureInitialized();
  @override
  $R call(
          {int? attachmentId,
          String? filename,
          int? fileSize,
          Object? height = $none,
          Object? width = $none,
          Object? thumbnailUrl = $none,
          Object? directUrl = $none,
          Object? isVideo = $none,
          Object? isAudio = $none,
          Object? contentType = $none,
          Object? contentId = $none,
          Object? attachDate = $none,
          Object? viewCount = $none}) =>
      $apply(FieldCopyWithData({
        if (attachmentId != null) #attachmentId: attachmentId,
        if (filename != null) #filename: filename,
        if (fileSize != null) #fileSize: fileSize,
        if (height != $none) #height: height,
        if (width != $none) #width: width,
        if (thumbnailUrl != $none) #thumbnailUrl: thumbnailUrl,
        if (directUrl != $none) #directUrl: directUrl,
        if (isVideo != $none) #isVideo: isVideo,
        if (isAudio != $none) #isAudio: isAudio,
        if (contentType != $none) #contentType: contentType,
        if (contentId != $none) #contentId: contentId,
        if (attachDate != $none) #attachDate: attachDate,
        if (viewCount != $none) #viewCount: viewCount
      }));
  @override
  DiscourseAttachment $make(CopyWithData data) => DiscourseAttachment(
      attachmentId: data.get(#attachmentId, or: $value.attachmentId),
      filename: data.get(#filename, or: $value.filename),
      fileSize: data.get(#fileSize, or: $value.fileSize),
      height: data.get(#height, or: $value.height),
      width: data.get(#width, or: $value.width),
      thumbnailUrl: data.get(#thumbnailUrl, or: $value.thumbnailUrl),
      directUrl: data.get(#directUrl, or: $value.directUrl),
      isVideo: data.get(#isVideo, or: $value.isVideo),
      isAudio: data.get(#isAudio, or: $value.isAudio),
      contentType: data.get(#contentType, or: $value.contentType),
      contentId: data.get(#contentId, or: $value.contentId),
      attachDate: data.get(#attachDate, or: $value.attachDate),
      viewCount: data.get(#viewCount, or: $value.viewCount));

  @override
  DiscourseAttachmentCopyWith<$R2, DiscourseAttachment, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _DiscourseAttachmentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
