// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'post.dart';

class DiscoursePostMapper extends ClassMapperBase<DiscoursePost> {
  DiscoursePostMapper._();

  static DiscoursePostMapper? _instance;
  static DiscoursePostMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DiscoursePostMapper._());
      DiscourseThreadMapper.ensureInitialized();
      DiscourseAttachmentMapper.ensureInitialized();
      DiscourseUserMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DiscoursePost';

  static String? _$username(DiscoursePost v) => v.username;
  static const Field<DiscoursePost, String> _f$username =
      Field('username', _$username, opt: true);
  static bool? _$isFirstPost(DiscoursePost v) => v.isFirstPost;
  static const Field<DiscoursePost, bool> _f$isFirstPost =
      Field('isFirstPost', _$isFirstPost, opt: true);
  static bool? _$isLastPost(DiscoursePost v) => v.isLastPost;
  static const Field<DiscoursePost, bool> _f$isLastPost =
      Field('isLastPost', _$isLastPost, opt: true);
  static bool? _$isUnread(DiscoursePost v) => v.isUnread;
  static const Field<DiscoursePost, bool> _f$isUnread =
      Field('isUnread', _$isUnread, opt: true);
  static String? _$messageParsed(DiscoursePost v) => v.messageParsed;
  static const Field<DiscoursePost, String> _f$messageParsed =
      Field('messageParsed', _$messageParsed, opt: true);
  static bool? _$canEdit(DiscoursePost v) => v.canEdit;
  static const Field<DiscoursePost, bool> _f$canEdit =
      Field('canEdit', _$canEdit, opt: true);
  static bool? _$canSoftDelete(DiscoursePost v) => v.canSoftDelete;
  static const Field<DiscoursePost, bool> _f$canSoftDelete =
      Field('canSoftDelete', _$canSoftDelete, opt: true);
  static bool? _$canHardDelete(DiscoursePost v) => v.canHardDelete;
  static const Field<DiscoursePost, bool> _f$canHardDelete =
      Field('canHardDelete', _$canHardDelete, opt: true);
  static bool? _$canReact(DiscoursePost v) => v.canReact;
  static const Field<DiscoursePost, bool> _f$canReact =
      Field('canReact', _$canReact, opt: true);
  static bool? _$canViewAttachments(DiscoursePost v) => v.canViewAttachments;
  static const Field<DiscoursePost, bool> _f$canViewAttachments =
      Field('canViewAttachments', _$canViewAttachments, opt: true);
  static String? _$viewUrl(DiscoursePost v) => v.viewUrl;
  static const Field<DiscoursePost, String> _f$viewUrl =
      Field('viewUrl', _$viewUrl, opt: true);
  static DiscourseThread? _$thread(DiscoursePost v) => v.thread;
  static const Field<DiscoursePost, DiscourseThread> _f$thread =
      Field('thread', _$thread, opt: true);
  static List<DiscourseAttachment>? _$attachments(DiscoursePost v) => v.attachments;
  static const Field<DiscoursePost, List<DiscourseAttachment>> _f$attachments =
      Field('attachments', _$attachments, opt: true);
  static bool? _$isReactedTo(DiscoursePost v) => v.isReactedTo;
  static const Field<DiscoursePost, bool> _f$isReactedTo =
      Field('isReactedTo', _$isReactedTo, opt: true);
  static int? _$visitorReactionId(DiscoursePost v) => v.visitorReactionId;
  static const Field<DiscoursePost, int> _f$visitorReactionId =
      Field('visitorReactionId', _$visitorReactionId, opt: true);
  static int? _$voteScore(DiscoursePost v) => v.voteScore;
  static const Field<DiscoursePost, int> _f$voteScore =
      Field('voteScore', _$voteScore, opt: true);
  static bool? _$canContentVote(DiscoursePost v) => v.canContentVote;
  static const Field<DiscoursePost, bool> _f$canContentVote =
      Field('canContentVote', _$canContentVote, opt: true);
  static List<String>? _$allowedContentVoteTypes(DiscoursePost v) =>
      v.allowedContentVoteTypes;
  static const Field<DiscoursePost, List<String>> _f$allowedContentVoteTypes =
      Field('allowedContentVoteTypes', _$allowedContentVoteTypes, opt: true);
  static bool? _$isContentVoted(DiscoursePost v) => v.isContentVoted;
  static const Field<DiscoursePost, bool> _f$isContentVoted =
      Field('isContentVoted', _$isContentVoted, opt: true);
  static String? _$visitorContentVote(DiscoursePost v) => v.visitorContentVote;
  static const Field<DiscoursePost, String> _f$visitorContentVote =
      Field('visitorContentVote', _$visitorContentVote, opt: true);
  static int _$postId(DiscoursePost v) => v.postId;
  static const Field<DiscoursePost, int> _f$postId = Field('postId', _$postId);
  static int? _$threadId(DiscoursePost v) => v.threadId;
  static const Field<DiscoursePost, int> _f$threadId =
      Field('threadId', _$threadId, opt: true);
  static int? _$userId(DiscoursePost v) => v.userId;
  static const Field<DiscoursePost, int> _f$userId =
      Field('userId', _$userId, opt: true);
  static int? _$postDate(DiscoursePost v) => v.postDate;
  static const Field<DiscoursePost, int> _f$postDate =
      Field('postDate', _$postDate, opt: true);
  static String? _$message(DiscoursePost v) => v.message;
  static const Field<DiscoursePost, String> _f$message =
      Field('message', _$message, opt: true);
  static String? _$messageState(DiscoursePost v) => v.messageState;
  static const Field<DiscoursePost, String> _f$messageState =
      Field('messageState', _$messageState, opt: true);
  static int? _$attachCount(DiscoursePost v) => v.attachCount;
  static const Field<DiscoursePost, int> _f$attachCount =
      Field('attachCount', _$attachCount, opt: true);
  static String? _$warningMessage(DiscoursePost v) => v.warningMessage;
  static const Field<DiscoursePost, String> _f$warningMessage =
      Field('warningMessage', _$warningMessage, opt: true);
  static int? _$position(DiscoursePost v) => v.position;
  static const Field<DiscoursePost, int> _f$position =
      Field('position', _$position, opt: true);
  static int? _$lastEditDate(DiscoursePost v) => v.lastEditDate;
  static const Field<DiscoursePost, int> _f$lastEditDate =
      Field('lastEditDate', _$lastEditDate, opt: true);
  static int? _$reactionScore(DiscoursePost v) => v.reactionScore;
  static const Field<DiscoursePost, int> _f$reactionScore =
      Field('reactionScore', _$reactionScore, opt: true);
  static DiscourseUser? _$user(DiscoursePost v) => v.user;
  static const Field<DiscoursePost, DiscourseUser> _f$user =
      Field('user', _$user, opt: true);

  @override
  final MappableFields<DiscoursePost> fields = const {
    #username: _f$username,
    #isFirstPost: _f$isFirstPost,
    #isLastPost: _f$isLastPost,
    #isUnread: _f$isUnread,
    #messageParsed: _f$messageParsed,
    #canEdit: _f$canEdit,
    #canSoftDelete: _f$canSoftDelete,
    #canHardDelete: _f$canHardDelete,
    #canReact: _f$canReact,
    #canViewAttachments: _f$canViewAttachments,
    #viewUrl: _f$viewUrl,
    #thread: _f$thread,
    #attachments: _f$attachments,
    #isReactedTo: _f$isReactedTo,
    #visitorReactionId: _f$visitorReactionId,
    #voteScore: _f$voteScore,
    #canContentVote: _f$canContentVote,
    #allowedContentVoteTypes: _f$allowedContentVoteTypes,
    #isContentVoted: _f$isContentVoted,
    #visitorContentVote: _f$visitorContentVote,
    #postId: _f$postId,
    #threadId: _f$threadId,
    #userId: _f$userId,
    #postDate: _f$postDate,
    #message: _f$message,
    #messageState: _f$messageState,
    #attachCount: _f$attachCount,
    #warningMessage: _f$warningMessage,
    #position: _f$position,
    #lastEditDate: _f$lastEditDate,
    #reactionScore: _f$reactionScore,
    #user: _f$user,
  };

  static DiscoursePost _instantiate(DecodingData data) {
    return DiscoursePost(
        username: data.dec(_f$username),
        isFirstPost: data.dec(_f$isFirstPost),
        isLastPost: data.dec(_f$isLastPost),
        isUnread: data.dec(_f$isUnread),
        messageParsed: data.dec(_f$messageParsed),
        canEdit: data.dec(_f$canEdit),
        canSoftDelete: data.dec(_f$canSoftDelete),
        canHardDelete: data.dec(_f$canHardDelete),
        canReact: data.dec(_f$canReact),
        canViewAttachments: data.dec(_f$canViewAttachments),
        viewUrl: data.dec(_f$viewUrl),
        thread: data.dec(_f$thread),
        attachments: data.dec(_f$attachments),
        isReactedTo: data.dec(_f$isReactedTo),
        visitorReactionId: data.dec(_f$visitorReactionId),
        voteScore: data.dec(_f$voteScore),
        canContentVote: data.dec(_f$canContentVote),
        allowedContentVoteTypes: data.dec(_f$allowedContentVoteTypes),
        isContentVoted: data.dec(_f$isContentVoted),
        visitorContentVote: data.dec(_f$visitorContentVote),
        postId: data.dec(_f$postId),
        threadId: data.dec(_f$threadId),
        userId: data.dec(_f$userId),
        postDate: data.dec(_f$postDate),
        message: data.dec(_f$message),
        messageState: data.dec(_f$messageState),
        attachCount: data.dec(_f$attachCount),
        warningMessage: data.dec(_f$warningMessage),
        position: data.dec(_f$position),
        lastEditDate: data.dec(_f$lastEditDate),
        reactionScore: data.dec(_f$reactionScore),
        user: data.dec(_f$user));
  }

  @override
  final Function instantiate = _instantiate;

  static DiscoursePost fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DiscoursePost>(map);
  }

  static DiscoursePost fromJson(String json) {
    return ensureInitialized().decodeJson<DiscoursePost>(json);
  }
}

mixin DiscoursePostMappable {
  String toJson() {
    return DiscoursePostMapper.ensureInitialized()
        .encodeJson<DiscoursePost>(this as DiscoursePost);
  }

  Map<String, dynamic> toMap() {
    return DiscoursePostMapper.ensureInitialized()
        .encodeMap<DiscoursePost>(this as DiscoursePost);
  }

  DiscoursePostCopyWith<DiscoursePost, DiscoursePost, DiscoursePost> get copyWith =>
      _DiscoursePostCopyWithImpl<DiscoursePost, DiscoursePost>(
          this as DiscoursePost, $identity, $identity);
  @override
  String toString() {
    return DiscoursePostMapper.ensureInitialized()
        .stringifyValue(this as DiscoursePost);
  }

  @override
  bool operator ==(Object other) {
    return DiscoursePostMapper.ensureInitialized()
        .equalsValue(this as DiscoursePost, other);
  }

  @override
  int get hashCode {
    return DiscoursePostMapper.ensureInitialized().hashValue(this as DiscoursePost);
  }
}

extension DiscoursePostValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DiscoursePost, $Out> {
  DiscoursePostCopyWith<$R, DiscoursePost, $Out> get $asDiscoursePost =>
      $base.as((v, t, t2) => _DiscoursePostCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DiscoursePostCopyWith<$R, $In extends DiscoursePost, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  DiscourseThreadCopyWith<$R, DiscourseThread, DiscourseThread>? get thread;
  ListCopyWith<$R, DiscourseAttachment,
          DiscourseAttachmentCopyWith<$R, DiscourseAttachment, DiscourseAttachment>>?
      get attachments;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>?
      get allowedContentVoteTypes;
  DiscourseUserCopyWith<$R, DiscourseUser, DiscourseUser>? get user;
  $R call(
      {String? username,
      bool? isFirstPost,
      bool? isLastPost,
      bool? isUnread,
      String? messageParsed,
      bool? canEdit,
      bool? canSoftDelete,
      bool? canHardDelete,
      bool? canReact,
      bool? canViewAttachments,
      String? viewUrl,
      DiscourseThread? thread,
      List<DiscourseAttachment>? attachments,
      bool? isReactedTo,
      int? visitorReactionId,
      int? voteScore,
      bool? canContentVote,
      List<String>? allowedContentVoteTypes,
      bool? isContentVoted,
      String? visitorContentVote,
      int? postId,
      int? threadId,
      int? userId,
      int? postDate,
      String? message,
      String? messageState,
      int? attachCount,
      String? warningMessage,
      int? position,
      int? lastEditDate,
      int? reactionScore,
      DiscourseUser? user});
  DiscoursePostCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DiscoursePostCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DiscoursePost, $Out>
    implements DiscoursePostCopyWith<$R, DiscoursePost, $Out> {
  _DiscoursePostCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DiscoursePost> $mapper =
      DiscoursePostMapper.ensureInitialized();
  @override
  DiscourseThreadCopyWith<$R, DiscourseThread, DiscourseThread>? get thread =>
      $value.thread?.copyWith.$chain((v) => call(thread: v));
  @override
  ListCopyWith<$R, DiscourseAttachment,
          DiscourseAttachmentCopyWith<$R, DiscourseAttachment, DiscourseAttachment>>?
      get attachments => $value.attachments != null
          ? ListCopyWith($value.attachments!, (v, t) => v.copyWith.$chain(t),
              (v) => call(attachments: v))
          : null;
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>?
      get allowedContentVoteTypes => $value.allowedContentVoteTypes != null
          ? ListCopyWith(
              $value.allowedContentVoteTypes!,
              (v, t) => ObjectCopyWith(v, $identity, t),
              (v) => call(allowedContentVoteTypes: v))
          : null;
  @override
  DiscourseUserCopyWith<$R, DiscourseUser, DiscourseUser>? get user =>
      $value.user?.copyWith.$chain((v) => call(user: v));
  @override
  $R call(
          {Object? username = $none,
          Object? isFirstPost = $none,
          Object? isLastPost = $none,
          Object? isUnread = $none,
          Object? messageParsed = $none,
          Object? canEdit = $none,
          Object? canSoftDelete = $none,
          Object? canHardDelete = $none,
          Object? canReact = $none,
          Object? canViewAttachments = $none,
          Object? viewUrl = $none,
          Object? thread = $none,
          Object? attachments = $none,
          Object? isReactedTo = $none,
          Object? visitorReactionId = $none,
          Object? voteScore = $none,
          Object? canContentVote = $none,
          Object? allowedContentVoteTypes = $none,
          Object? isContentVoted = $none,
          Object? visitorContentVote = $none,
          int? postId,
          Object? threadId = $none,
          Object? userId = $none,
          Object? postDate = $none,
          Object? message = $none,
          Object? messageState = $none,
          Object? attachCount = $none,
          Object? warningMessage = $none,
          Object? position = $none,
          Object? lastEditDate = $none,
          Object? reactionScore = $none,
          Object? user = $none}) =>
      $apply(FieldCopyWithData({
        if (username != $none) #username: username,
        if (isFirstPost != $none) #isFirstPost: isFirstPost,
        if (isLastPost != $none) #isLastPost: isLastPost,
        if (isUnread != $none) #isUnread: isUnread,
        if (messageParsed != $none) #messageParsed: messageParsed,
        if (canEdit != $none) #canEdit: canEdit,
        if (canSoftDelete != $none) #canSoftDelete: canSoftDelete,
        if (canHardDelete != $none) #canHardDelete: canHardDelete,
        if (canReact != $none) #canReact: canReact,
        if (canViewAttachments != $none)
          #canViewAttachments: canViewAttachments,
        if (viewUrl != $none) #viewUrl: viewUrl,
        if (thread != $none) #thread: thread,
        if (attachments != $none) #attachments: attachments,
        if (isReactedTo != $none) #isReactedTo: isReactedTo,
        if (visitorReactionId != $none) #visitorReactionId: visitorReactionId,
        if (voteScore != $none) #voteScore: voteScore,
        if (canContentVote != $none) #canContentVote: canContentVote,
        if (allowedContentVoteTypes != $none)
          #allowedContentVoteTypes: allowedContentVoteTypes,
        if (isContentVoted != $none) #isContentVoted: isContentVoted,
        if (visitorContentVote != $none)
          #visitorContentVote: visitorContentVote,
        if (postId != null) #postId: postId,
        if (threadId != $none) #threadId: threadId,
        if (userId != $none) #userId: userId,
        if (postDate != $none) #postDate: postDate,
        if (message != $none) #message: message,
        if (messageState != $none) #messageState: messageState,
        if (attachCount != $none) #attachCount: attachCount,
        if (warningMessage != $none) #warningMessage: warningMessage,
        if (position != $none) #position: position,
        if (lastEditDate != $none) #lastEditDate: lastEditDate,
        if (reactionScore != $none) #reactionScore: reactionScore,
        if (user != $none) #user: user
      }));
  @override
  DiscoursePost $make(CopyWithData data) => DiscoursePost(
      username: data.get(#username, or: $value.username),
      isFirstPost: data.get(#isFirstPost, or: $value.isFirstPost),
      isLastPost: data.get(#isLastPost, or: $value.isLastPost),
      isUnread: data.get(#isUnread, or: $value.isUnread),
      messageParsed: data.get(#messageParsed, or: $value.messageParsed),
      canEdit: data.get(#canEdit, or: $value.canEdit),
      canSoftDelete: data.get(#canSoftDelete, or: $value.canSoftDelete),
      canHardDelete: data.get(#canHardDelete, or: $value.canHardDelete),
      canReact: data.get(#canReact, or: $value.canReact),
      canViewAttachments:
          data.get(#canViewAttachments, or: $value.canViewAttachments),
      viewUrl: data.get(#viewUrl, or: $value.viewUrl),
      thread: data.get(#thread, or: $value.thread),
      attachments: data.get(#attachments, or: $value.attachments),
      isReactedTo: data.get(#isReactedTo, or: $value.isReactedTo),
      visitorReactionId:
          data.get(#visitorReactionId, or: $value.visitorReactionId),
      voteScore: data.get(#voteScore, or: $value.voteScore),
      canContentVote: data.get(#canContentVote, or: $value.canContentVote),
      allowedContentVoteTypes: data.get(#allowedContentVoteTypes,
          or: $value.allowedContentVoteTypes),
      isContentVoted: data.get(#isContentVoted, or: $value.isContentVoted),
      visitorContentVote:
          data.get(#visitorContentVote, or: $value.visitorContentVote),
      postId: data.get(#postId, or: $value.postId),
      threadId: data.get(#threadId, or: $value.threadId),
      userId: data.get(#userId, or: $value.userId),
      postDate: data.get(#postDate, or: $value.postDate),
      message: data.get(#message, or: $value.message),
      messageState: data.get(#messageState, or: $value.messageState),
      attachCount: data.get(#attachCount, or: $value.attachCount),
      warningMessage: data.get(#warningMessage, or: $value.warningMessage),
      position: data.get(#position, or: $value.position),
      lastEditDate: data.get(#lastEditDate, or: $value.lastEditDate),
      reactionScore: data.get(#reactionScore, or: $value.reactionScore),
      user: data.get(#user, or: $value.user));

  @override
  DiscoursePostCopyWith<$R2, DiscoursePost, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _DiscoursePostCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
