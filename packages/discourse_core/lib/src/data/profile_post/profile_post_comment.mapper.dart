// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'profile_post_comment.dart';

class DiscourseProfilePostCommentMapper
    extends ClassMapperBase<DiscourseProfilePostComment> {
  DiscourseProfilePostCommentMapper._();

  static DiscourseProfilePostCommentMapper? _instance;
  static DiscourseProfilePostCommentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = DiscourseProfilePostCommentMapper._());
      DiscourseUserMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DiscourseProfilePostComment';

  static String? _$username(DiscourseProfilePostComment v) => v.username;
  static const Field<DiscourseProfilePostComment, String> _f$username =
      Field('username', _$username, opt: true);
  static String? _$messageParsed(DiscourseProfilePostComment v) =>
      v.messageParsed;
  static const Field<DiscourseProfilePostComment, String> _f$messageParsed =
      Field('messageParsed', _$messageParsed, opt: true);
  static bool? _$canEdit(DiscourseProfilePostComment v) => v.canEdit;
  static const Field<DiscourseProfilePostComment, bool> _f$canEdit =
      Field('canEdit', _$canEdit, opt: true);
  static bool? _$canSoftDelete(DiscourseProfilePostComment v) => v.canSoftDelete;
  static const Field<DiscourseProfilePostComment, bool> _f$canSoftDelete =
      Field('canSoftDelete', _$canSoftDelete, opt: true);
  static bool? _$canHardDelete(DiscourseProfilePostComment v) => v.canHardDelete;
  static const Field<DiscourseProfilePostComment, bool> _f$canHardDelete =
      Field('canHardDelete', _$canHardDelete, opt: true);
  static bool? _$canReact(DiscourseProfilePostComment v) => v.canReact;
  static const Field<DiscourseProfilePostComment, bool> _f$canReact =
      Field('canReact', _$canReact, opt: true);
  static String? _$viewUrl(DiscourseProfilePostComment v) => v.viewUrl;
  static const Field<DiscourseProfilePostComment, String> _f$viewUrl =
      Field('viewUrl', _$viewUrl, opt: true);
  static bool? _$isReactedTo(DiscourseProfilePostComment v) => v.isReactedTo;
  static const Field<DiscourseProfilePostComment, bool> _f$isReactedTo =
      Field('isReactedTo', _$isReactedTo, opt: true);
  static int? _$visitorReactionId(DiscourseProfilePostComment v) =>
      v.visitorReactionId;
  static const Field<DiscourseProfilePostComment, int> _f$visitorReactionId =
      Field('visitorReactionId', _$visitorReactionId, opt: true);
  static int _$commentId(DiscourseProfilePostComment v) => v.commentId;
  static const Field<DiscourseProfilePostComment, int> _f$commentId =
      Field('commentId', _$commentId);
  static int? _$profilePostId(DiscourseProfilePostComment v) => v.profilePostId;
  static const Field<DiscourseProfilePostComment, int> _f$profilePostId =
      Field('profilePostId', _$profilePostId, opt: true);
  static int? _$userId(DiscourseProfilePostComment v) => v.userId;
  static const Field<DiscourseProfilePostComment, int> _f$userId =
      Field('userId', _$userId, opt: true);
  static int? _$commentDate(DiscourseProfilePostComment v) => v.commentDate;
  static const Field<DiscourseProfilePostComment, int> _f$commentDate =
      Field('commentDate', _$commentDate, opt: true);
  static String? _$message(DiscourseProfilePostComment v) => v.message;
  static const Field<DiscourseProfilePostComment, String> _f$message =
      Field('message', _$message, opt: true);
  static String? _$messageState(DiscourseProfilePostComment v) => v.messageState;
  static const Field<DiscourseProfilePostComment, String> _f$messageState =
      Field('messageState', _$messageState, opt: true);
  static String? _$warningMessage(DiscourseProfilePostComment v) =>
      v.warningMessage;
  static const Field<DiscourseProfilePostComment, String> _f$warningMessage =
      Field('warningMessage', _$warningMessage, opt: true);
  static int? _$reactionScore(DiscourseProfilePostComment v) => v.reactionScore;
  static const Field<DiscourseProfilePostComment, int> _f$reactionScore =
      Field('reactionScore', _$reactionScore, opt: true);
  static DiscourseUser? _$user(DiscourseProfilePostComment v) => v.user;
  static const Field<DiscourseProfilePostComment, DiscourseUser> _f$user =
      Field('user', _$user, opt: true);

  @override
  final MappableFields<DiscourseProfilePostComment> fields = const {
    #username: _f$username,
    #messageParsed: _f$messageParsed,
    #canEdit: _f$canEdit,
    #canSoftDelete: _f$canSoftDelete,
    #canHardDelete: _f$canHardDelete,
    #canReact: _f$canReact,
    #viewUrl: _f$viewUrl,
    #isReactedTo: _f$isReactedTo,
    #visitorReactionId: _f$visitorReactionId,
    #commentId: _f$commentId,
    #profilePostId: _f$profilePostId,
    #userId: _f$userId,
    #commentDate: _f$commentDate,
    #message: _f$message,
    #messageState: _f$messageState,
    #warningMessage: _f$warningMessage,
    #reactionScore: _f$reactionScore,
    #user: _f$user,
  };

  static DiscourseProfilePostComment _instantiate(DecodingData data) {
    return DiscourseProfilePostComment(
        username: data.dec(_f$username),
        messageParsed: data.dec(_f$messageParsed),
        canEdit: data.dec(_f$canEdit),
        canSoftDelete: data.dec(_f$canSoftDelete),
        canHardDelete: data.dec(_f$canHardDelete),
        canReact: data.dec(_f$canReact),
        viewUrl: data.dec(_f$viewUrl),
        isReactedTo: data.dec(_f$isReactedTo),
        visitorReactionId: data.dec(_f$visitorReactionId),
        commentId: data.dec(_f$commentId),
        profilePostId: data.dec(_f$profilePostId),
        userId: data.dec(_f$userId),
        commentDate: data.dec(_f$commentDate),
        message: data.dec(_f$message),
        messageState: data.dec(_f$messageState),
        warningMessage: data.dec(_f$warningMessage),
        reactionScore: data.dec(_f$reactionScore),
        user: data.dec(_f$user));
  }

  @override
  final Function instantiate = _instantiate;

  static DiscourseProfilePostComment fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DiscourseProfilePostComment>(map);
  }

  static DiscourseProfilePostComment fromJson(String json) {
    return ensureInitialized().decodeJson<DiscourseProfilePostComment>(json);
  }
}

mixin DiscourseProfilePostCommentMappable {
  String toJson() {
    return DiscourseProfilePostCommentMapper.ensureInitialized()
        .encodeJson<DiscourseProfilePostComment>(
            this as DiscourseProfilePostComment);
  }

  Map<String, dynamic> toMap() {
    return DiscourseProfilePostCommentMapper.ensureInitialized()
        .encodeMap<DiscourseProfilePostComment>(
            this as DiscourseProfilePostComment);
  }

  DiscourseProfilePostCommentCopyWith<DiscourseProfilePostComment,
          DiscourseProfilePostComment, DiscourseProfilePostComment>
      get copyWith => _DiscourseProfilePostCommentCopyWithImpl<
              DiscourseProfilePostComment, DiscourseProfilePostComment>(
          this as DiscourseProfilePostComment, $identity, $identity);
  @override
  String toString() {
    return DiscourseProfilePostCommentMapper.ensureInitialized()
        .stringifyValue(this as DiscourseProfilePostComment);
  }

  @override
  bool operator ==(Object other) {
    return DiscourseProfilePostCommentMapper.ensureInitialized()
        .equalsValue(this as DiscourseProfilePostComment, other);
  }

  @override
  int get hashCode {
    return DiscourseProfilePostCommentMapper.ensureInitialized()
        .hashValue(this as DiscourseProfilePostComment);
  }
}

extension DiscourseProfilePostCommentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DiscourseProfilePostComment, $Out> {
  DiscourseProfilePostCommentCopyWith<$R, DiscourseProfilePostComment, $Out>
      get $asDiscourseProfilePostComment => $base.as((v, t, t2) =>
          _DiscourseProfilePostCommentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DiscourseProfilePostCommentCopyWith<
    $R,
    $In extends DiscourseProfilePostComment,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  DiscourseUserCopyWith<$R, DiscourseUser, DiscourseUser>? get user;
  $R call(
      {String? username,
      String? messageParsed,
      bool? canEdit,
      bool? canSoftDelete,
      bool? canHardDelete,
      bool? canReact,
      String? viewUrl,
      bool? isReactedTo,
      int? visitorReactionId,
      int? commentId,
      int? profilePostId,
      int? userId,
      int? commentDate,
      String? message,
      String? messageState,
      String? warningMessage,
      int? reactionScore,
      DiscourseUser? user});
  DiscourseProfilePostCommentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _DiscourseProfilePostCommentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DiscourseProfilePostComment, $Out>
    implements
        DiscourseProfilePostCommentCopyWith<$R, DiscourseProfilePostComment, $Out> {
  _DiscourseProfilePostCommentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DiscourseProfilePostComment> $mapper =
      DiscourseProfilePostCommentMapper.ensureInitialized();
  @override
  DiscourseUserCopyWith<$R, DiscourseUser, DiscourseUser>? get user =>
      $value.user?.copyWith.$chain((v) => call(user: v));
  @override
  $R call(
          {Object? username = $none,
          Object? messageParsed = $none,
          Object? canEdit = $none,
          Object? canSoftDelete = $none,
          Object? canHardDelete = $none,
          Object? canReact = $none,
          Object? viewUrl = $none,
          Object? isReactedTo = $none,
          Object? visitorReactionId = $none,
          int? commentId,
          Object? profilePostId = $none,
          Object? userId = $none,
          Object? commentDate = $none,
          Object? message = $none,
          Object? messageState = $none,
          Object? warningMessage = $none,
          Object? reactionScore = $none,
          Object? user = $none}) =>
      $apply(FieldCopyWithData({
        if (username != $none) #username: username,
        if (messageParsed != $none) #messageParsed: messageParsed,
        if (canEdit != $none) #canEdit: canEdit,
        if (canSoftDelete != $none) #canSoftDelete: canSoftDelete,
        if (canHardDelete != $none) #canHardDelete: canHardDelete,
        if (canReact != $none) #canReact: canReact,
        if (viewUrl != $none) #viewUrl: viewUrl,
        if (isReactedTo != $none) #isReactedTo: isReactedTo,
        if (visitorReactionId != $none) #visitorReactionId: visitorReactionId,
        if (commentId != null) #commentId: commentId,
        if (profilePostId != $none) #profilePostId: profilePostId,
        if (userId != $none) #userId: userId,
        if (commentDate != $none) #commentDate: commentDate,
        if (message != $none) #message: message,
        if (messageState != $none) #messageState: messageState,
        if (warningMessage != $none) #warningMessage: warningMessage,
        if (reactionScore != $none) #reactionScore: reactionScore,
        if (user != $none) #user: user
      }));
  @override
  DiscourseProfilePostComment $make(CopyWithData data) =>
      DiscourseProfilePostComment(
          username: data.get(#username, or: $value.username),
          messageParsed: data.get(#messageParsed, or: $value.messageParsed),
          canEdit: data.get(#canEdit, or: $value.canEdit),
          canSoftDelete: data.get(#canSoftDelete, or: $value.canSoftDelete),
          canHardDelete: data.get(#canHardDelete, or: $value.canHardDelete),
          canReact: data.get(#canReact, or: $value.canReact),
          viewUrl: data.get(#viewUrl, or: $value.viewUrl),
          isReactedTo: data.get(#isReactedTo, or: $value.isReactedTo),
          visitorReactionId:
              data.get(#visitorReactionId, or: $value.visitorReactionId),
          commentId: data.get(#commentId, or: $value.commentId),
          profilePostId: data.get(#profilePostId, or: $value.profilePostId),
          userId: data.get(#userId, or: $value.userId),
          commentDate: data.get(#commentDate, or: $value.commentDate),
          message: data.get(#message, or: $value.message),
          messageState: data.get(#messageState, or: $value.messageState),
          warningMessage: data.get(#warningMessage, or: $value.warningMessage),
          reactionScore: data.get(#reactionScore, or: $value.reactionScore),
          user: data.get(#user, or: $value.user));

  @override
  DiscourseProfilePostCommentCopyWith<$R2, DiscourseProfilePostComment, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _DiscourseProfilePostCommentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
