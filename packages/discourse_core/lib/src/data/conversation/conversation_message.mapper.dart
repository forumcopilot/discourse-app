// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'conversation_message.dart';

class DiscourseConversationMessageMapper
    extends ClassMapperBase<DiscourseConversationMessage> {
  DiscourseConversationMessageMapper._();

  static DiscourseConversationMessageMapper? _instance;
  static DiscourseConversationMessageMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = DiscourseConversationMessageMapper._());
      DiscourseConversationMapper.ensureInitialized();
      DiscourseAttachmentMapper.ensureInitialized();
      DiscourseUserMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DiscourseConversationMessage';

  static String? _$username(DiscourseConversationMessage v) => v.username;
  static const Field<DiscourseConversationMessage, String> _f$username =
      Field('username', _$username, opt: true);
  static bool? _$isUnread(DiscourseConversationMessage v) => v.isUnread;
  static const Field<DiscourseConversationMessage, bool> _f$isUnread =
      Field('isUnread', _$isUnread, opt: true);
  static String? _$messageParsed(DiscourseConversationMessage v) =>
      v.messageParsed;
  static const Field<DiscourseConversationMessage, String> _f$messageParsed =
      Field('messageParsed', _$messageParsed, opt: true);
  static bool? _$canEdit(DiscourseConversationMessage v) => v.canEdit;
  static const Field<DiscourseConversationMessage, bool> _f$canEdit =
      Field('canEdit', _$canEdit, opt: true);
  static bool? _$canReact(DiscourseConversationMessage v) => v.canReact;
  static const Field<DiscourseConversationMessage, bool> _f$canReact =
      Field('canReact', _$canReact, opt: true);
  static String? _$viewUrl(DiscourseConversationMessage v) => v.viewUrl;
  static const Field<DiscourseConversationMessage, String> _f$viewUrl =
      Field('viewUrl', _$viewUrl, opt: true);
  static DiscourseConversation? _$conversation(DiscourseConversationMessage v) =>
      v.conversation;
  static const Field<DiscourseConversationMessage, DiscourseConversation>
      _f$conversation = Field('conversation', _$conversation, opt: true);
  static List<DiscourseAttachment>? _$attachments(DiscourseConversationMessage v) =>
      v.attachments;
  static const Field<DiscourseConversationMessage, List<DiscourseAttachment>>
      _f$attachments = Field('attachments', _$attachments, opt: true);
  static bool? _$isReactedTo(DiscourseConversationMessage v) => v.isReactedTo;
  static const Field<DiscourseConversationMessage, bool> _f$isReactedTo =
      Field('isReactedTo', _$isReactedTo, opt: true);
  static int? _$visitorReactionId(DiscourseConversationMessage v) =>
      v.visitorReactionId;
  static const Field<DiscourseConversationMessage, int> _f$visitorReactionId =
      Field('visitorReactionId', _$visitorReactionId, opt: true);
  static int _$messageId(DiscourseConversationMessage v) => v.messageId;
  static const Field<DiscourseConversationMessage, int> _f$messageId =
      Field('messageId', _$messageId);
  static int? _$conversationId(DiscourseConversationMessage v) =>
      v.conversationId;
  static const Field<DiscourseConversationMessage, int> _f$conversationId =
      Field('conversationId', _$conversationId, opt: true);
  static int? _$messageDate(DiscourseConversationMessage v) => v.messageDate;
  static const Field<DiscourseConversationMessage, int> _f$messageDate =
      Field('messageDate', _$messageDate, opt: true);
  static int? _$userId(DiscourseConversationMessage v) => v.userId;
  static const Field<DiscourseConversationMessage, int> _f$userId =
      Field('userId', _$userId, opt: true);
  static String? _$message(DiscourseConversationMessage v) => v.message;
  static const Field<DiscourseConversationMessage, String> _f$message =
      Field('message', _$message, opt: true);
  static int? _$attachCount(DiscourseConversationMessage v) => v.attachCount;
  static const Field<DiscourseConversationMessage, int> _f$attachCount =
      Field('attachCount', _$attachCount, opt: true);
  static int? _$reactionScore(DiscourseConversationMessage v) => v.reactionScore;
  static const Field<DiscourseConversationMessage, int> _f$reactionScore =
      Field('reactionScore', _$reactionScore, opt: true);
  static DiscourseUser? _$user(DiscourseConversationMessage v) => v.user;
  static const Field<DiscourseConversationMessage, DiscourseUser> _f$user =
      Field('user', _$user, opt: true);

  @override
  final MappableFields<DiscourseConversationMessage> fields = const {
    #username: _f$username,
    #isUnread: _f$isUnread,
    #messageParsed: _f$messageParsed,
    #canEdit: _f$canEdit,
    #canReact: _f$canReact,
    #viewUrl: _f$viewUrl,
    #conversation: _f$conversation,
    #attachments: _f$attachments,
    #isReactedTo: _f$isReactedTo,
    #visitorReactionId: _f$visitorReactionId,
    #messageId: _f$messageId,
    #conversationId: _f$conversationId,
    #messageDate: _f$messageDate,
    #userId: _f$userId,
    #message: _f$message,
    #attachCount: _f$attachCount,
    #reactionScore: _f$reactionScore,
    #user: _f$user,
  };

  static DiscourseConversationMessage _instantiate(DecodingData data) {
    return DiscourseConversationMessage(
        username: data.dec(_f$username),
        isUnread: data.dec(_f$isUnread),
        messageParsed: data.dec(_f$messageParsed),
        canEdit: data.dec(_f$canEdit),
        canReact: data.dec(_f$canReact),
        viewUrl: data.dec(_f$viewUrl),
        conversation: data.dec(_f$conversation),
        attachments: data.dec(_f$attachments),
        isReactedTo: data.dec(_f$isReactedTo),
        visitorReactionId: data.dec(_f$visitorReactionId),
        messageId: data.dec(_f$messageId),
        conversationId: data.dec(_f$conversationId),
        messageDate: data.dec(_f$messageDate),
        userId: data.dec(_f$userId),
        message: data.dec(_f$message),
        attachCount: data.dec(_f$attachCount),
        reactionScore: data.dec(_f$reactionScore),
        user: data.dec(_f$user));
  }

  @override
  final Function instantiate = _instantiate;

  static DiscourseConversationMessage fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DiscourseConversationMessage>(map);
  }

  static DiscourseConversationMessage fromJson(String json) {
    return ensureInitialized().decodeJson<DiscourseConversationMessage>(json);
  }
}

mixin DiscourseConversationMessageMappable {
  String toJson() {
    return DiscourseConversationMessageMapper.ensureInitialized()
        .encodeJson<DiscourseConversationMessage>(
            this as DiscourseConversationMessage);
  }

  Map<String, dynamic> toMap() {
    return DiscourseConversationMessageMapper.ensureInitialized()
        .encodeMap<DiscourseConversationMessage>(
            this as DiscourseConversationMessage);
  }

  DiscourseConversationMessageCopyWith<DiscourseConversationMessage,
          DiscourseConversationMessage, DiscourseConversationMessage>
      get copyWith => _DiscourseConversationMessageCopyWithImpl<
              DiscourseConversationMessage, DiscourseConversationMessage>(
          this as DiscourseConversationMessage, $identity, $identity);
  @override
  String toString() {
    return DiscourseConversationMessageMapper.ensureInitialized()
        .stringifyValue(this as DiscourseConversationMessage);
  }

  @override
  bool operator ==(Object other) {
    return DiscourseConversationMessageMapper.ensureInitialized()
        .equalsValue(this as DiscourseConversationMessage, other);
  }

  @override
  int get hashCode {
    return DiscourseConversationMessageMapper.ensureInitialized()
        .hashValue(this as DiscourseConversationMessage);
  }
}

extension DiscourseConversationMessageValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DiscourseConversationMessage, $Out> {
  DiscourseConversationMessageCopyWith<$R, DiscourseConversationMessage, $Out>
      get $asDiscourseConversationMessage => $base.as((v, t, t2) =>
          _DiscourseConversationMessageCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DiscourseConversationMessageCopyWith<
    $R,
    $In extends DiscourseConversationMessage,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  DiscourseConversationCopyWith<$R, DiscourseConversation, DiscourseConversation>?
      get conversation;
  ListCopyWith<$R, DiscourseAttachment,
          DiscourseAttachmentCopyWith<$R, DiscourseAttachment, DiscourseAttachment>>?
      get attachments;
  DiscourseUserCopyWith<$R, DiscourseUser, DiscourseUser>? get user;
  $R call(
      {String? username,
      bool? isUnread,
      String? messageParsed,
      bool? canEdit,
      bool? canReact,
      String? viewUrl,
      DiscourseConversation? conversation,
      List<DiscourseAttachment>? attachments,
      bool? isReactedTo,
      int? visitorReactionId,
      int? messageId,
      int? conversationId,
      int? messageDate,
      int? userId,
      String? message,
      int? attachCount,
      int? reactionScore,
      DiscourseUser? user});
  DiscourseConversationMessageCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _DiscourseConversationMessageCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DiscourseConversationMessage, $Out>
    implements
        DiscourseConversationMessageCopyWith<$R, DiscourseConversationMessage,
            $Out> {
  _DiscourseConversationMessageCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DiscourseConversationMessage> $mapper =
      DiscourseConversationMessageMapper.ensureInitialized();
  @override
  DiscourseConversationCopyWith<$R, DiscourseConversation, DiscourseConversation>?
      get conversation =>
          $value.conversation?.copyWith.$chain((v) => call(conversation: v));
  @override
  ListCopyWith<$R, DiscourseAttachment,
          DiscourseAttachmentCopyWith<$R, DiscourseAttachment, DiscourseAttachment>>?
      get attachments => $value.attachments != null
          ? ListCopyWith($value.attachments!, (v, t) => v.copyWith.$chain(t),
              (v) => call(attachments: v))
          : null;
  @override
  DiscourseUserCopyWith<$R, DiscourseUser, DiscourseUser>? get user =>
      $value.user?.copyWith.$chain((v) => call(user: v));
  @override
  $R call(
          {Object? username = $none,
          Object? isUnread = $none,
          Object? messageParsed = $none,
          Object? canEdit = $none,
          Object? canReact = $none,
          Object? viewUrl = $none,
          Object? conversation = $none,
          Object? attachments = $none,
          Object? isReactedTo = $none,
          Object? visitorReactionId = $none,
          int? messageId,
          Object? conversationId = $none,
          Object? messageDate = $none,
          Object? userId = $none,
          Object? message = $none,
          Object? attachCount = $none,
          Object? reactionScore = $none,
          Object? user = $none}) =>
      $apply(FieldCopyWithData({
        if (username != $none) #username: username,
        if (isUnread != $none) #isUnread: isUnread,
        if (messageParsed != $none) #messageParsed: messageParsed,
        if (canEdit != $none) #canEdit: canEdit,
        if (canReact != $none) #canReact: canReact,
        if (viewUrl != $none) #viewUrl: viewUrl,
        if (conversation != $none) #conversation: conversation,
        if (attachments != $none) #attachments: attachments,
        if (isReactedTo != $none) #isReactedTo: isReactedTo,
        if (visitorReactionId != $none) #visitorReactionId: visitorReactionId,
        if (messageId != null) #messageId: messageId,
        if (conversationId != $none) #conversationId: conversationId,
        if (messageDate != $none) #messageDate: messageDate,
        if (userId != $none) #userId: userId,
        if (message != $none) #message: message,
        if (attachCount != $none) #attachCount: attachCount,
        if (reactionScore != $none) #reactionScore: reactionScore,
        if (user != $none) #user: user
      }));
  @override
  DiscourseConversationMessage $make(
          CopyWithData data) =>
      DiscourseConversationMessage(
          username: data.get(#username, or: $value.username),
          isUnread: data.get(#isUnread, or: $value.isUnread),
          messageParsed: data.get(#messageParsed, or: $value.messageParsed),
          canEdit: data.get(#canEdit, or: $value.canEdit),
          canReact: data.get(#canReact, or: $value.canReact),
          viewUrl: data.get(#viewUrl, or: $value.viewUrl),
          conversation: data.get(#conversation, or: $value.conversation),
          attachments: data.get(#attachments, or: $value.attachments),
          isReactedTo: data.get(#isReactedTo, or: $value.isReactedTo),
          visitorReactionId:
              data.get(#visitorReactionId, or: $value.visitorReactionId),
          messageId: data.get(#messageId, or: $value.messageId),
          conversationId: data.get(#conversationId, or: $value.conversationId),
          messageDate: data.get(#messageDate, or: $value.messageDate),
          userId: data.get(#userId, or: $value.userId),
          message: data.get(#message, or: $value.message),
          attachCount: data.get(#attachCount, or: $value.attachCount),
          reactionScore: data.get(#reactionScore, or: $value.reactionScore),
          user: data.get(#user, or: $value.user));

  @override
  DiscourseConversationMessageCopyWith<$R2, DiscourseConversationMessage, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _DiscourseConversationMessageCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
