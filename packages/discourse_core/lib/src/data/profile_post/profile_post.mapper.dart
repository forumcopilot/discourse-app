// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'profile_post.dart';

class DiscourseProfilePostMapper extends ClassMapperBase<DiscourseProfilePost> {
  DiscourseProfilePostMapper._();

  static DiscourseProfilePostMapper? _instance;
  static DiscourseProfilePostMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DiscourseProfilePostMapper._());
      DiscourseUserMapper.ensureInitialized();
      DiscourseAttachmentMapper.ensureInitialized();
      DiscourseProfilePostCommentMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DiscourseProfilePost';

  static String? _$username(DiscourseProfilePost v) => v.username;
  static const Field<DiscourseProfilePost, String> _f$username =
      Field('username', _$username, opt: true);
  static String? _$messageParsed(DiscourseProfilePost v) => v.messageParsed;
  static const Field<DiscourseProfilePost, String> _f$messageParsed =
      Field('messageParsed', _$messageParsed, opt: true);
  static bool? _$canEdit(DiscourseProfilePost v) => v.canEdit;
  static const Field<DiscourseProfilePost, bool> _f$canEdit =
      Field('canEdit', _$canEdit, opt: true);
  static bool? _$canSoftDelete(DiscourseProfilePost v) => v.canSoftDelete;
  static const Field<DiscourseProfilePost, bool> _f$canSoftDelete =
      Field('canSoftDelete', _$canSoftDelete, opt: true);
  static bool? _$canHardDelete(DiscourseProfilePost v) => v.canHardDelete;
  static const Field<DiscourseProfilePost, bool> _f$canHardDelete =
      Field('canHardDelete', _$canHardDelete, opt: true);
  static bool? _$canReact(DiscourseProfilePost v) => v.canReact;
  static const Field<DiscourseProfilePost, bool> _f$canReact =
      Field('canReact', _$canReact, opt: true);
  static bool? _$canViewAttachments(DiscourseProfilePost v) =>
      v.canViewAttachments;
  static const Field<DiscourseProfilePost, bool> _f$canViewAttachments =
      Field('canViewAttachments', _$canViewAttachments, opt: true);
  static String? _$viewUrl(DiscourseProfilePost v) => v.viewUrl;
  static const Field<DiscourseProfilePost, String> _f$viewUrl =
      Field('viewUrl', _$viewUrl, opt: true);
  static DiscourseUser? _$profileUser(DiscourseProfilePost v) => v.profileUser;
  static const Field<DiscourseProfilePost, DiscourseUser> _f$profileUser =
      Field('profileUser', _$profileUser, opt: true);
  static List<DiscourseAttachment>? _$attachments(DiscourseProfilePost v) =>
      v.attachments;
  static const Field<DiscourseProfilePost, List<DiscourseAttachment>>
      _f$attachments = Field('attachments', _$attachments, opt: true);
  static List<DiscourseProfilePostComment>? _$latestComments(
          DiscourseProfilePost v) =>
      v.latestComments;
  static const Field<DiscourseProfilePost, List<DiscourseProfilePostComment>>
      _f$latestComments = Field('latestComments', _$latestComments, opt: true);
  static bool? _$isReactedTo(DiscourseProfilePost v) => v.isReactedTo;
  static const Field<DiscourseProfilePost, bool> _f$isReactedTo =
      Field('isReactedTo', _$isReactedTo, opt: true);
  static int? _$visitorReactionId(DiscourseProfilePost v) => v.visitorReactionId;
  static const Field<DiscourseProfilePost, int> _f$visitorReactionId =
      Field('visitorReactionId', _$visitorReactionId, opt: true);
  static int _$profilePostId(DiscourseProfilePost v) => v.profilePostId;
  static const Field<DiscourseProfilePost, int> _f$profilePostId =
      Field('profilePostId', _$profilePostId);
  static int? _$profileUserId(DiscourseProfilePost v) => v.profileUserId;
  static const Field<DiscourseProfilePost, int> _f$profileUserId =
      Field('profileUserId', _$profileUserId, opt: true);
  static int? _$userId(DiscourseProfilePost v) => v.userId;
  static const Field<DiscourseProfilePost, int> _f$userId =
      Field('userId', _$userId, opt: true);
  static int? _$postDate(DiscourseProfilePost v) => v.postDate;
  static const Field<DiscourseProfilePost, int> _f$postDate =
      Field('postDate', _$postDate, opt: true);
  static String? _$message(DiscourseProfilePost v) => v.message;
  static const Field<DiscourseProfilePost, String> _f$message =
      Field('message', _$message, opt: true);
  static String? _$messageState(DiscourseProfilePost v) => v.messageState;
  static const Field<DiscourseProfilePost, String> _f$messageState =
      Field('messageState', _$messageState, opt: true);
  static String? _$warningMessage(DiscourseProfilePost v) => v.warningMessage;
  static const Field<DiscourseProfilePost, String> _f$warningMessage =
      Field('warningMessage', _$warningMessage, opt: true);
  static int? _$commentCount(DiscourseProfilePost v) => v.commentCount;
  static const Field<DiscourseProfilePost, int> _f$commentCount =
      Field('commentCount', _$commentCount, opt: true);
  static int? _$firstCommentDate(DiscourseProfilePost v) => v.firstCommentDate;
  static const Field<DiscourseProfilePost, int> _f$firstCommentDate =
      Field('firstCommentDate', _$firstCommentDate, opt: true);
  static int? _$lastCommentDate(DiscourseProfilePost v) => v.lastCommentDate;
  static const Field<DiscourseProfilePost, int> _f$lastCommentDate =
      Field('lastCommentDate', _$lastCommentDate, opt: true);
  static int? _$reactionScore(DiscourseProfilePost v) => v.reactionScore;
  static const Field<DiscourseProfilePost, int> _f$reactionScore =
      Field('reactionScore', _$reactionScore, opt: true);
  static DiscourseUser? _$user(DiscourseProfilePost v) => v.user;
  static const Field<DiscourseProfilePost, DiscourseUser> _f$user =
      Field('user', _$user, opt: true);

  @override
  final MappableFields<DiscourseProfilePost> fields = const {
    #username: _f$username,
    #messageParsed: _f$messageParsed,
    #canEdit: _f$canEdit,
    #canSoftDelete: _f$canSoftDelete,
    #canHardDelete: _f$canHardDelete,
    #canReact: _f$canReact,
    #canViewAttachments: _f$canViewAttachments,
    #viewUrl: _f$viewUrl,
    #profileUser: _f$profileUser,
    #attachments: _f$attachments,
    #latestComments: _f$latestComments,
    #isReactedTo: _f$isReactedTo,
    #visitorReactionId: _f$visitorReactionId,
    #profilePostId: _f$profilePostId,
    #profileUserId: _f$profileUserId,
    #userId: _f$userId,
    #postDate: _f$postDate,
    #message: _f$message,
    #messageState: _f$messageState,
    #warningMessage: _f$warningMessage,
    #commentCount: _f$commentCount,
    #firstCommentDate: _f$firstCommentDate,
    #lastCommentDate: _f$lastCommentDate,
    #reactionScore: _f$reactionScore,
    #user: _f$user,
  };

  static DiscourseProfilePost _instantiate(DecodingData data) {
    return DiscourseProfilePost(
        username: data.dec(_f$username),
        messageParsed: data.dec(_f$messageParsed),
        canEdit: data.dec(_f$canEdit),
        canSoftDelete: data.dec(_f$canSoftDelete),
        canHardDelete: data.dec(_f$canHardDelete),
        canReact: data.dec(_f$canReact),
        canViewAttachments: data.dec(_f$canViewAttachments),
        viewUrl: data.dec(_f$viewUrl),
        profileUser: data.dec(_f$profileUser),
        attachments: data.dec(_f$attachments),
        latestComments: data.dec(_f$latestComments),
        isReactedTo: data.dec(_f$isReactedTo),
        visitorReactionId: data.dec(_f$visitorReactionId),
        profilePostId: data.dec(_f$profilePostId),
        profileUserId: data.dec(_f$profileUserId),
        userId: data.dec(_f$userId),
        postDate: data.dec(_f$postDate),
        message: data.dec(_f$message),
        messageState: data.dec(_f$messageState),
        warningMessage: data.dec(_f$warningMessage),
        commentCount: data.dec(_f$commentCount),
        firstCommentDate: data.dec(_f$firstCommentDate),
        lastCommentDate: data.dec(_f$lastCommentDate),
        reactionScore: data.dec(_f$reactionScore),
        user: data.dec(_f$user));
  }

  @override
  final Function instantiate = _instantiate;

  static DiscourseProfilePost fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DiscourseProfilePost>(map);
  }

  static DiscourseProfilePost fromJson(String json) {
    return ensureInitialized().decodeJson<DiscourseProfilePost>(json);
  }
}

mixin DiscourseProfilePostMappable {
  String toJson() {
    return DiscourseProfilePostMapper.ensureInitialized()
        .encodeJson<DiscourseProfilePost>(this as DiscourseProfilePost);
  }

  Map<String, dynamic> toMap() {
    return DiscourseProfilePostMapper.ensureInitialized()
        .encodeMap<DiscourseProfilePost>(this as DiscourseProfilePost);
  }

  DiscourseProfilePostCopyWith<DiscourseProfilePost, DiscourseProfilePost,
          DiscourseProfilePost>
      get copyWith => _DiscourseProfilePostCopyWithImpl<DiscourseProfilePost,
          DiscourseProfilePost>(this as DiscourseProfilePost, $identity, $identity);
  @override
  String toString() {
    return DiscourseProfilePostMapper.ensureInitialized()
        .stringifyValue(this as DiscourseProfilePost);
  }

  @override
  bool operator ==(Object other) {
    return DiscourseProfilePostMapper.ensureInitialized()
        .equalsValue(this as DiscourseProfilePost, other);
  }

  @override
  int get hashCode {
    return DiscourseProfilePostMapper.ensureInitialized()
        .hashValue(this as DiscourseProfilePost);
  }
}

extension DiscourseProfilePostValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DiscourseProfilePost, $Out> {
  DiscourseProfilePostCopyWith<$R, DiscourseProfilePost, $Out>
      get $asDiscourseProfilePost => $base.as(
          (v, t, t2) => _DiscourseProfilePostCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DiscourseProfilePostCopyWith<$R, $In extends DiscourseProfilePost,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  DiscourseUserCopyWith<$R, DiscourseUser, DiscourseUser>? get profileUser;
  ListCopyWith<$R, DiscourseAttachment,
          DiscourseAttachmentCopyWith<$R, DiscourseAttachment, DiscourseAttachment>>?
      get attachments;
  ListCopyWith<
      $R,
      DiscourseProfilePostComment,
      DiscourseProfilePostCommentCopyWith<$R, DiscourseProfilePostComment,
          DiscourseProfilePostComment>>? get latestComments;
  DiscourseUserCopyWith<$R, DiscourseUser, DiscourseUser>? get user;
  $R call(
      {String? username,
      String? messageParsed,
      bool? canEdit,
      bool? canSoftDelete,
      bool? canHardDelete,
      bool? canReact,
      bool? canViewAttachments,
      String? viewUrl,
      DiscourseUser? profileUser,
      List<DiscourseAttachment>? attachments,
      List<DiscourseProfilePostComment>? latestComments,
      bool? isReactedTo,
      int? visitorReactionId,
      int? profilePostId,
      int? profileUserId,
      int? userId,
      int? postDate,
      String? message,
      String? messageState,
      String? warningMessage,
      int? commentCount,
      int? firstCommentDate,
      int? lastCommentDate,
      int? reactionScore,
      DiscourseUser? user});
  DiscourseProfilePostCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _DiscourseProfilePostCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DiscourseProfilePost, $Out>
    implements DiscourseProfilePostCopyWith<$R, DiscourseProfilePost, $Out> {
  _DiscourseProfilePostCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DiscourseProfilePost> $mapper =
      DiscourseProfilePostMapper.ensureInitialized();
  @override
  DiscourseUserCopyWith<$R, DiscourseUser, DiscourseUser>? get profileUser =>
      $value.profileUser?.copyWith.$chain((v) => call(profileUser: v));
  @override
  ListCopyWith<$R, DiscourseAttachment,
          DiscourseAttachmentCopyWith<$R, DiscourseAttachment, DiscourseAttachment>>?
      get attachments => $value.attachments != null
          ? ListCopyWith($value.attachments!, (v, t) => v.copyWith.$chain(t),
              (v) => call(attachments: v))
          : null;
  @override
  ListCopyWith<
      $R,
      DiscourseProfilePostComment,
      DiscourseProfilePostCommentCopyWith<$R, DiscourseProfilePostComment,
          DiscourseProfilePostComment>>? get latestComments =>
      $value.latestComments != null
          ? ListCopyWith($value.latestComments!, (v, t) => v.copyWith.$chain(t),
              (v) => call(latestComments: v))
          : null;
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
          Object? canViewAttachments = $none,
          Object? viewUrl = $none,
          Object? profileUser = $none,
          Object? attachments = $none,
          Object? latestComments = $none,
          Object? isReactedTo = $none,
          Object? visitorReactionId = $none,
          int? profilePostId,
          Object? profileUserId = $none,
          Object? userId = $none,
          Object? postDate = $none,
          Object? message = $none,
          Object? messageState = $none,
          Object? warningMessage = $none,
          Object? commentCount = $none,
          Object? firstCommentDate = $none,
          Object? lastCommentDate = $none,
          Object? reactionScore = $none,
          Object? user = $none}) =>
      $apply(FieldCopyWithData({
        if (username != $none) #username: username,
        if (messageParsed != $none) #messageParsed: messageParsed,
        if (canEdit != $none) #canEdit: canEdit,
        if (canSoftDelete != $none) #canSoftDelete: canSoftDelete,
        if (canHardDelete != $none) #canHardDelete: canHardDelete,
        if (canReact != $none) #canReact: canReact,
        if (canViewAttachments != $none)
          #canViewAttachments: canViewAttachments,
        if (viewUrl != $none) #viewUrl: viewUrl,
        if (profileUser != $none) #profileUser: profileUser,
        if (attachments != $none) #attachments: attachments,
        if (latestComments != $none) #latestComments: latestComments,
        if (isReactedTo != $none) #isReactedTo: isReactedTo,
        if (visitorReactionId != $none) #visitorReactionId: visitorReactionId,
        if (profilePostId != null) #profilePostId: profilePostId,
        if (profileUserId != $none) #profileUserId: profileUserId,
        if (userId != $none) #userId: userId,
        if (postDate != $none) #postDate: postDate,
        if (message != $none) #message: message,
        if (messageState != $none) #messageState: messageState,
        if (warningMessage != $none) #warningMessage: warningMessage,
        if (commentCount != $none) #commentCount: commentCount,
        if (firstCommentDate != $none) #firstCommentDate: firstCommentDate,
        if (lastCommentDate != $none) #lastCommentDate: lastCommentDate,
        if (reactionScore != $none) #reactionScore: reactionScore,
        if (user != $none) #user: user
      }));
  @override
  DiscourseProfilePost $make(CopyWithData data) => DiscourseProfilePost(
      username: data.get(#username, or: $value.username),
      messageParsed: data.get(#messageParsed, or: $value.messageParsed),
      canEdit: data.get(#canEdit, or: $value.canEdit),
      canSoftDelete: data.get(#canSoftDelete, or: $value.canSoftDelete),
      canHardDelete: data.get(#canHardDelete, or: $value.canHardDelete),
      canReact: data.get(#canReact, or: $value.canReact),
      canViewAttachments:
          data.get(#canViewAttachments, or: $value.canViewAttachments),
      viewUrl: data.get(#viewUrl, or: $value.viewUrl),
      profileUser: data.get(#profileUser, or: $value.profileUser),
      attachments: data.get(#attachments, or: $value.attachments),
      latestComments: data.get(#latestComments, or: $value.latestComments),
      isReactedTo: data.get(#isReactedTo, or: $value.isReactedTo),
      visitorReactionId:
          data.get(#visitorReactionId, or: $value.visitorReactionId),
      profilePostId: data.get(#profilePostId, or: $value.profilePostId),
      profileUserId: data.get(#profileUserId, or: $value.profileUserId),
      userId: data.get(#userId, or: $value.userId),
      postDate: data.get(#postDate, or: $value.postDate),
      message: data.get(#message, or: $value.message),
      messageState: data.get(#messageState, or: $value.messageState),
      warningMessage: data.get(#warningMessage, or: $value.warningMessage),
      commentCount: data.get(#commentCount, or: $value.commentCount),
      firstCommentDate:
          data.get(#firstCommentDate, or: $value.firstCommentDate),
      lastCommentDate: data.get(#lastCommentDate, or: $value.lastCommentDate),
      reactionScore: data.get(#reactionScore, or: $value.reactionScore),
      user: data.get(#user, or: $value.user));

  @override
  DiscourseProfilePostCopyWith<$R2, DiscourseProfilePost, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _DiscourseProfilePostCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
