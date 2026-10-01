// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get loginTitle => '登录';

  @override
  String get usePasskey => 'Use Passkey';

  @override
  String get passkeyContinuePrompt => 'Use your passkey to continue';

  @override
  String get continueButton => '继续';

  @override
  String get errorTitle => '错误';

  @override
  String get okButton => '确定';

  @override
  String get retryButton => '重试';

  @override
  String get copyToClipboard => '复制到剪贴板';

  @override
  String get copied => '已复制';

  @override
  String get errorMessageCopiedToClipboard => '错误消息已复制到剪贴板';

  @override
  String get dismiss => '关闭';

  @override
  String get cancel => '取消';

  @override
  String get tryAgain => '重试';

  @override
  String get anErrorOccurred => '发生错误';

  @override
  String get accountPendingApproval => '您的账户正在等待批准。您可以浏览论坛，但在版主批准您的账户之前无法发帖。';

  @override
  String get checkEmailToConfirm => '请检查您的电子邮件以确认您的账户。点击我们发送给您的电子邮件中的确认链接。';

  @override
  String get checkNewEmailToConfirm =>
      '请检查您的新电子邮件地址以确认更改。在您确认新电子邮件之前，旧电子邮件将保持活动状态。';

  @override
  String get emailAddressInvalid => '您的电子邮件地址似乎无效或正在退回邮件。请在账户设置中更新您的电子邮件地址。';

  @override
  String get accountDisabled => '您的账户已被禁用。请联系管理员寻求帮助。';

  @override
  String get accountRegistrationRejected => '您的账户注册已被拒绝。请联系管理员了解更多信息。';

  @override
  String get welcomeToForumCopilot => '欢迎使用 Forum Copilot！';

  @override
  String get successfullyLoggedOut => '您已成功退出登录';

  @override
  String get accountStatusRequiresAttention => '您的账户状态需要注意。如有疑问，请联系管理员。';

  @override
  String get updateEmail => '更新电子邮件';

  @override
  String get resend => '重新发送';

  @override
  String get noLatestTopics => '无最新话题';

  @override
  String get noRecentTopicsToDisplay => '没有要显示的最新话题。稍后再来查看新讨论。';

  @override
  String get signInToViewLatestTopics => '登录以查看最新话题';

  @override
  String get youNeedToBeSignedInToViewLatestTopics => '您需要登录才能查看最新话题';

  @override
  String get thereAreNoUnreadTopics => '没有未读话题。稍后再来查看新讨论。';

  @override
  String get youAreAllCaughtUp => '您已全部查看完毕！';

  @override
  String get signInToViewUnreadTopics => '登录以查看未读话题';

  @override
  String get youNeedToBeSignedInToViewUnreadTopics => '您需要登录才能查看未读话题';

  @override
  String get latest => '最新';

  @override
  String get unread => '未读';

  @override
  String get failedToConnectToSite => '无法连接到网站。网站可能已关闭或无法访问。';

  @override
  String get connectionFailed => '连接失败';

  @override
  String failedToConnectToSiteName(String siteName) {
    return '无法连接到 $siteName';
  }

  @override
  String get loading => '加载中...';

  @override
  String get newConversation => '新消息';

  @override
  String get language => '语言';

  @override
  String get all => '全部';

  @override
  String get topicsOnly => '仅话题';

  @override
  String get titlesOnly => '仅标题';

  @override
  String failedToShareTopic(String error) {
    return '分享话题失败: $error';
  }

  @override
  String get youCannotReplyToThisThread => '您无法回复此话题';

  @override
  String get pleaseWaitForThreadToLoad => '请等待话题加载';

  @override
  String get reason => '原因';

  @override
  String get participantsLabel => '参与者';

  @override
  String usernameHasBeenInvited(String username) {
    return '已邀请 $username 加入消息';
  }

  @override
  String errorInvitingUser(String error) {
    return '邀请用户时出错: $error';
  }

  @override
  String get newTopic => '新话题';

  @override
  String get pleaseSpecifyReason => '请说明原因';

  @override
  String get selectDate => '选择日期';

  @override
  String get moreOptions => '更多选项';

  @override
  String get topicClosed => '话题已关闭';

  @override
  String get topicOpened => '话题已打开';

  @override
  String get noConversations => '您没有任何消息';

  @override
  String get noConversationsMessage => '您还没有消息。写一条新消息开始吧。';

  @override
  String get imageSavedToGallery => '图片已保存到相册！';

  @override
  String failedToSaveImage(String error) {
    return '保存图片失败: $error';
  }

  @override
  String get userProfile => '用户资料';

  @override
  String get deletePost => '删除帖子';

  @override
  String get loginRequired => '需要登录';

  @override
  String get sendMessage => '私信';

  @override
  String get likesReceived => '收到的赞';

  @override
  String get showMore => '显示更多';

  @override
  String get failedToSaveConversation => '无法保存消息';

  @override
  String get members => '成员';

  @override
  String membersCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString 成员';
  }

  @override
  String get noSubject => '无主题';

  @override
  String get search => '搜索';

  @override
  String get logout => '退出登录';

  @override
  String get areYouSureYouWantToLogout => '您确定要退出登录吗？';

  @override
  String get signIn => '登录';

  @override
  String get notificationTest => '通知测试';

  @override
  String get forum => '类别';

  @override
  String get profile => '资料';

  @override
  String get messages => '消息';

  @override
  String get add => '添加';

  @override
  String get retry => '重试';

  @override
  String get delete => '删除';

  @override
  String get deleteMessage => '删除消息';

  @override
  String get deletingPost => '正在删除帖子...';

  @override
  String failedToUnlikePost(String error) {
    return '取消点赞帖子失败: $error';
  }

  @override
  String failedToLikePost(String error) {
    return '点赞帖子失败: $error';
  }

  @override
  String get signInToViewMessages => '请登录以查看消息';

  @override
  String get youNeedToBeSignedInToViewConversations => '登录后才能查看您的消息。';

  @override
  String failedToLeaveConversation(String error) {
    return '无法离开消息：$error';
  }

  @override
  String errorLoadingMoreConversations(String error) {
    return '加载更多消息出错：$error';
  }

  @override
  String get searchFailed => '搜索失败';

  @override
  String get userInformationNotAvailable => '用户信息不可用';

  @override
  String get birthday => '生日';

  @override
  String get posts => '帖子';

  @override
  String get following => '关注中';

  @override
  String get followers => '粉丝';

  @override
  String get about => '关于';

  @override
  String get location => '位置';

  @override
  String get website => '网站';

  @override
  String get next => '下一步';

  @override
  String get temporary => '临时';

  @override
  String get back => '返回';

  @override
  String get confirm => '确认';

  @override
  String error(String error) {
    return '错误: $error';
  }

  @override
  String get removeAttachment => '删除附件';

  @override
  String get areYouSureYouWantToRemoveThisAttachment => '您确定要删除此附件吗？';

  @override
  String get none => '无';

  @override
  String get attachFile => '附加文件';

  @override
  String get uploadImage => '上传图片';

  @override
  String get formatting => '格式';

  @override
  String get bold => '粗体';

  @override
  String get italic => '斜体';

  @override
  String get underline => '下划线';

  @override
  String get strikethrough => '删除线';

  @override
  String get link => '链接';

  @override
  String get image => '图片';

  @override
  String get video => '视频';

  @override
  String get quote => '引用';

  @override
  String get code => '代码';

  @override
  String get spoiler => '剧透';

  @override
  String get bulletList => '项目符号列表';

  @override
  String get numberedList => '编号列表';

  @override
  String get listItem => '列表项';

  @override
  String participants(int count) {
    return '参与者 ($count)';
  }

  @override
  String get markAsUnread => '标记为未读';

  @override
  String get invite => '邀请';

  @override
  String get enterKeywordsToSearchTopics => '输入关键词以搜索话题...';

  @override
  String get refresh => '刷新';

  @override
  String get share => '分享';

  @override
  String get viewOnWeb => '在网页中查看';

  @override
  String get reply => '回复';

  @override
  String get vote => '投票';

  @override
  String votesCount(int count) {
    return '$count 票';
  }

  @override
  String get pollClosed => '投票已结束';

  @override
  String pollEndsOn(String date) {
    return '截止于 $date';
  }

  @override
  String get voteToSeeResults => '投票后查看结果';

  @override
  String get viewFullPoll => '查看完整投票';

  @override
  String pollOptionsCount(int count) {
    return '$count 个选项';
  }

  @override
  String get reactedBy => '已反应';

  @override
  String get enterKeywordsToFindTopicsAndPosts => '输入关键词以查找话题和帖子';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get appearance => '外观';

  @override
  String get appearanceSystem => '跟随系统';

  @override
  String version(String version, String buildNumber) {
    return '版本 $version ($buildNumber)';
  }

  @override
  String get unableToLoadProfile => '无法加载个人资料';

  @override
  String get banned => '已封禁';

  @override
  String get deleteTopic => '删除话题';

  @override
  String get home => '首页';

  @override
  String get notifications => '通知';

  @override
  String get forums => '类别';

  @override
  String get content => '内容';

  @override
  String get pleaseEnterTitle => '请输入标题';

  @override
  String get pleaseEnterContent => '请输入内容';

  @override
  String get uploading => '上传中...';

  @override
  String get uploaded => '已上传';

  @override
  String get mentionUser => '提及用户';

  @override
  String get writeYourMessage => '编写您的消息...';

  @override
  String get writeYourReply => '编写您的回复...';

  @override
  String get conversationMarkedAsUnread => '消息已标记为未读';

  @override
  String get conversationClosed => '消息已关闭';

  @override
  String get conversationOpened => '消息已打开';

  @override
  String failedToLoadQuote(String error) {
    return '加载引用失败: \n$error';
  }

  @override
  String failedToMarkConversationAsUnread(String error) {
    return '无法将消息标记为未读：$error';
  }

  @override
  String failedToCloseConversation(String error) {
    return '无法关闭消息：$error';
  }

  @override
  String failedToOpenConversation(String error) {
    return '无法打开消息：$error';
  }

  @override
  String get goToTop => '返回顶部';

  @override
  String get goToBottom => '跳到底部';

  @override
  String get pleaseLoginToAccessContent => '请登录以访问此内容并与帖子互动。';

  @override
  String get searchUsers => '搜索用户...';

  @override
  String get enterConversationTitle => '输入消息标题';

  @override
  String enterCode(int count) {
    return '输入$count位代码';
  }

  @override
  String get edit => '编辑';

  @override
  String get remove => '删除';

  @override
  String get subject => '主题';

  @override
  String get message => '消息';

  @override
  String get titleCannotBeEmpty => '标题不能为空';

  @override
  String get conversationUpdatedSuccessfully => '消息已更新';

  @override
  String get goBack => '返回';

  @override
  String get like => '点赞';

  @override
  String get download => '下载';

  @override
  String downloading(String filename) {
    return '正在下载$filename...';
  }

  @override
  String openingShareSheet(String filename) {
    return '正在为$filename打开分享表';
  }

  @override
  String errorDownloading(String filename, String error) {
    return '下载$filename时出错: $error';
  }

  @override
  String couldNotOpenLink(String error) {
    return '无法打开链接: $error';
  }

  @override
  String get translating => '翻译中...';

  @override
  String get translated => '已翻译';

  @override
  String get translatedContent => '翻译内容';

  @override
  String get twoFactorAuthentication => '双重身份验证';

  @override
  String get authenticationCodeLabel => '验证码';

  @override
  String get pleaseEnterYourAuthenticationCode => '请输入验证码';

  @override
  String codeMustBeDigits(int count) {
    return '验证码必须为 $count 位数字';
  }

  @override
  String get codeMustContainOnlyNumbers => '验证码只能包含数字';

  @override
  String get verifyButton => '验证';

  @override
  String get attachments => '附件';

  @override
  String get replyOptions => '回复选项';

  @override
  String get replyWithQuote => '引用回复';

  @override
  String fileSavedToDownloads(String filename) {
    return '文件已保存到下载：$filename';
  }

  @override
  String fileSavedToDocuments(String filename) {
    return '文件已保存到文档：$filename';
  }

  @override
  String topicLastReplyBy(String username, String time) {
    return '$username 回复于 $time';
  }

  @override
  String inReplyToUser(String username) {
    return '回复 $username';
  }

  @override
  String inReplyToPost(int number) {
    return '回复帖子 #$number';
  }

  @override
  String timeGapDaysLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天后',
    );
    return '$_temp0';
  }

  @override
  String timeGapMonthsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个月后',
    );
    return '$_temp0';
  }

  @override
  String timeGapYearsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 年后',
    );
    return '$_temp0';
  }

  @override
  String get profileViews => '浏览量';

  @override
  String get badges => '徽章';

  @override
  String get chatWithUser => '聊天';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条回复',
    );
    return '$_temp0';
  }

  @override
  String get chat => '聊天';

  @override
  String moreBadges(Object count) {
    return '还有 $count 个';
  }

  @override
  String get allNotificationsMarkedAsRead => '所有通知已标记为已读';

  @override
  String get apply => '应用';

  @override
  String get bookmarks => '书签';

  @override
  String reviewableBy(String username) {
    return '由 $username 发布';
  }

  @override
  String get changeEmail => '更改邮箱';

  @override
  String get changePassword => '更改密码';

  @override
  String get checkingStatus => '正在检查状态…';

  @override
  String get clearReminder => '清除提醒';

  @override
  String get copy => '复制';

  @override
  String get copyLink => '复制链接';

  @override
  String couldNotEnableNotifications(String error) {
    return '无法启用通知：$error';
  }

  @override
  String get couldNotFindBookmark => '找不到此书签';

  @override
  String couldNotOpenEmail(String email) {
    return '无法打开邮箱：$email';
  }

  @override
  String couldNotStartSignIn(String error) {
    return '无法开始登录：$error';
  }

  @override
  String get customDateAndTime => '自定义日期和时间';

  @override
  String get deleteAccount => '删除账户';

  @override
  String get deleteMessageQuestion => '删除消息？';

  @override
  String get discard => '放弃';

  @override
  String get doNotDisturb => '请勿打扰';

  @override
  String get editHistory => '编辑历史';

  @override
  String get editProfile => '编辑资料';

  @override
  String get editReminder => '编辑提醒';

  @override
  String emailCopiedToClipboard(String email) {
    return '邮箱已复制到剪贴板：$email';
  }

  @override
  String get pushEnabledForThisLogin => '已为此次登录启用';

  @override
  String get failedToLoadMoreTopics => '无法加载更多话题。滚动以重试。';

  @override
  String get failedToUpdateNotificationLevel => '无法更新通知级别';

  @override
  String get firstPostsOnly => '仅首帖';

  @override
  String get ignoredUsers => '已忽略的用户';

  @override
  String get inTwoHours => '两小时后';

  @override
  String get inviteByEmail => '通过邮件邀请';

  @override
  String get inviteLinkCopied => '邀请链接已复制';

  @override
  String inviteSentTo(String email) {
    return '邀请已发送至 $email';
  }

  @override
  String get leave => '退出';

  @override
  String get leaveGroup => '退出群组';

  @override
  String get leaveGroupQuestion => '退出群组？';

  @override
  String get linkCopied => '链接已复制';

  @override
  String get loadMore => '加载更多';

  @override
  String get manageAccountOnWeb => '在网页上管理账户';

  @override
  String get merge => '合并';

  @override
  String get mergeIntoTopic => '合并到话题';

  @override
  String get newInviteLink => '新邀请链接';

  @override
  String get nextWeek => '下周';

  @override
  String get pushNotAvailableInThisBuild => '此版本不可用';

  @override
  String get notNow => '暂不';

  @override
  String tagNotificationLevelUpdated(String tag) {
    return '已更新“$tag”的通知级别';
  }

  @override
  String doNotDisturbOnUntil(String until) {
    return '开启至 $until';
  }

  @override
  String get pleaseLogInToBookmark => '请登录后添加书签';

  @override
  String get pleaseLogInToFollowUsers => '请登录后关注用户';

  @override
  String get pleaseLogInToMarkAnswers => '请登录后标记答案';

  @override
  String get pleaseLogInToReact => '请登录后添加反应';

  @override
  String get pleaseLogInToVote => '请登录后投票';

  @override
  String get pushNotifications => '推送通知';

  @override
  String get relevance => '相关性';

  @override
  String get reminderTimeMustBeInFuture => '提醒时间必须在将来';

  @override
  String get removeBookmark => '移除书签';

  @override
  String get removeVote => '撤销投票';

  @override
  String get renameTopic => '重命名话题';

  @override
  String reportedBy(String username) {
    return '由 $username 举报';
  }

  @override
  String get requestToJoin => '申请加入';

  @override
  String requestToJoinGroup(String group) {
    return '申请加入 $group';
  }

  @override
  String get reset => '重置';

  @override
  String get resizeAndUpload => '缩小并上传';

  @override
  String get checkConnectionAndRetry => '请检查网络连接，然后重试。';

  @override
  String get reviewQueue => '审核队列';

  @override
  String get revoke => '撤销';

  @override
  String get revokeInviteQuestion => '撤销邀请？';

  @override
  String get save => '保存';

  @override
  String get sendInvite => '发送邀请';

  @override
  String get sendRequest => '发送申请';

  @override
  String get settings => '设置';

  @override
  String get showVoters => '显示投票者';

  @override
  String get signOut => '退出登录';

  @override
  String get signInCancelledNoPayload => '登录已取消 — 未收到响应';

  @override
  String signInFailed(String error) {
    return '登录失败：$error';
  }

  @override
  String get startChat => '开始聊天';

  @override
  String stoppedIgnoringUser(String username) {
    return '已取消忽略 @$username';
  }

  @override
  String get titleOnly => '仅标题';

  @override
  String get tomorrow => '明天';

  @override
  String get turnOff => '关闭';

  @override
  String get turnOnNotifications => '开启通知';

  @override
  String get whisper => '悄悄话';

  @override
  String likeAgainInSeconds(Object seconds) {
    return '$seconds 秒后可再次点赞';
  }

  @override
  String get loginInfo => '登录信息';

  @override
  String get loginFailed => '登录失败';

  @override
  String get moveToCategory => '移动到类别';

  @override
  String get undeleteTopic => '取消删除话题';

  @override
  String get send => '发送';

  @override
  String get changeEmailExplanation => '我们会向新邮箱发送确认链接。点击后更改即生效。';

  @override
  String get changeEmailSecurityNote =>
      '为了安全，Discourse 可能要求你通过邮件中的链接确认。如果没有收到，请检查垃圾邮件文件夹。';

  @override
  String get noMessagesYetSayHi => '还没有消息 — 打个招呼吧。';

  @override
  String get edited => '已编辑';

  @override
  String get approvedButRelayUnreachable => '已批准，但无法连接通知服务器以完成设置。请稍后在“设置”中重试。';

  @override
  String get notificationsAreTurnedOffForThisApp => '此应用的通知已关闭';

  @override
  String get pleaseLoginToCreateANewTopic => '请登录后创建新话题';

  @override
  String get pleaseLoginToSubscribeToForums => '请登录后订阅论坛';

  @override
  String leaveGroupWarning(Object group) {
    return '你将不再是 $group 的成员。你可以随时重新加入。';
  }

  @override
  String get groupMembersPrivate => '此群组的成员列表不公开。';

  @override
  String get unignore => '取消忽略';

  @override
  String get inviteLinkCreated => '邀请链接已创建';

  @override
  String expiresOn(Object date) {
    return '$date 过期';
  }

  @override
  String get solution => '解决方案';

  @override
  String get deleted => '已删除';

  @override
  String get pleaseLoginToViewUserProfiles => '请登录后查看用户资料。';

  @override
  String get solved => '已解决';

  @override
  String get hot => '热门';

  @override
  String get pinned => '置顶';

  @override
  String get locked => '已锁定';

  @override
  String get poll => '投票';

  @override
  String get noDiscussionsYet => '还没有讨论。';

  @override
  String get jumpToPost => '跳转到帖子';

  @override
  String get jump => '跳转';

  @override
  String get endOfTheDiscussion => '讨论结束';

  @override
  String get reviewQueueStaffOnly => '只有管理人员和审核员可以查看审核队列。';

  @override
  String get nothingToReview => '没有待审核内容';

  @override
  String refreshFailed(Object error) {
    return '刷新失败：$error';
  }

  @override
  String get refreshing => '正在刷新...';

  @override
  String get title => '标题';

  @override
  String editedAt(Object time) {
    return '编辑于 $time';
  }

  @override
  String editReason(Object reason) {
    return '原因：$reason';
  }

  @override
  String get thisDiffIsTooLargeToDisplay => '差异过大，无法显示。';

  @override
  String get noContentChangesInThisRevision => '此版本没有内容更改。';

  @override
  String revisionOf(Object currentVersion, Object versionCount) {
    return '第 $currentVersion 版，共 $versionCount 版';
  }

  @override
  String get editConversation => '编辑标题';

  @override
  String get closeConversation => '关闭消息';

  @override
  String get openConversation => '打开消息';

  @override
  String get leaveConversation2 => '离开消息';

  @override
  String get closeConversation2 => '关闭消息';

  @override
  String get closeConversationConfirmation => '关闭此消息？关闭后将不再接受新回复。';

  @override
  String get close => '关闭';

  @override
  String get openConversation2 => '打开消息';

  @override
  String get openConversationConfirmation => '打开此消息？打开后将重新接受新回复。';

  @override
  String get open => '打开';

  @override
  String get leaveConversation3 => '离开消息';

  @override
  String get leaveConversationConfirmation => '确定要从此消息中移除自己吗？您将无法再看到或回复它。';

  @override
  String get editConversation2 => '编辑标题';

  @override
  String get failedToLoadMessage2 => '无法加载消息';

  @override
  String get cannotEditThisConversation => '您无法编辑此消息';

  @override
  String get options => '选项';

  @override
  String get conversationOpen => '允许回复';

  @override
  String get messageTitleHint => '用一句话概括讨论内容…';

  @override
  String get messageOpenForReplies => '接受新回复';

  @override
  String get messageClosedForReplies => '已关闭：不接受新回复';

  @override
  String get messageSentWithoutId => '消息已发送，但论坛未返回该消息。请查看您的消息。';

  @override
  String get messageCouldNotBeSent => '无法发送消息。';

  @override
  String get messageIdMissing => '无法打开此消息：缺少 ID。';

  @override
  String get pleaseAddARecipient => '请至少添加一位收件人';

  @override
  String get archiveMessage => '归档';

  @override
  String get moveToInbox => '移至收件箱';

  @override
  String get messageInbox => '收件箱';

  @override
  String get messageArchive => '归档';

  @override
  String get messageListUnread => '未读';

  @override
  String get messageListNew => '新';

  @override
  String get messageListSent => '已发送';

  @override
  String removeFromMessageConfirm(String name) {
    return '真的要将 $name 从此消息中移除吗？';
  }

  @override
  String uploadingFilename(String filename) {
    return '正在上传：$filename…';
  }

  @override
  String get messageArchived => '消息已归档';

  @override
  String get messageMovedToInbox => '已移至收件箱';

  @override
  String failedToArchiveMessage(Object error) {
    return '无法归档消息：$error';
  }

  @override
  String failedToMoveMessageToInbox(Object error) {
    return '无法将消息移至收件箱：$error';
  }

  @override
  String get noArchivedMessages => '您没有已归档的消息';

  @override
  String get noArchivedMessagesHint => '在消息的 ⋮ 菜单中选择归档，即可存放在这里。';

  @override
  String groupHasBeenInvited(String group) {
    return '已邀请 $group 加入消息';
  }

  @override
  String participantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 位参与者',
    );
    return '$_temp0';
  }

  @override
  String get chatChannels => '频道';

  @override
  String get chatDms => '直接消息';

  @override
  String get chatNoChannels => '您还没有加入任何频道！';

  @override
  String get chatNoDms => '您还没有加入任何直接消息！';

  @override
  String get chatNoDmsCta => '开始一个对话';

  @override
  String chatPlaceholderChannel(String channel) {
    return '在 $channel 中聊天';
  }

  @override
  String chatPlaceholderUsers(String names) {
    return '与 $names 聊天';
  }

  @override
  String get chatPlaceholderSelf => '做些记录';

  @override
  String get chatPlaceholderArchived => '频道已归档，您现在无法发送新消息。';

  @override
  String get chatPlaceholderClosed => '频道已关闭，您现在无法发送新消息。';

  @override
  String get chatPlaceholderReadOnly => '频道为只读，您现在无法发送新消息。';

  @override
  String get chatPlaceholderSilenced => '您目前无法发送消息。';

  @override
  String get chatDeleteConfirm => '确定要删除此消息吗？';

  @override
  String get chatStartNewDm => '开始新的 DM';

  @override
  String get chatCreatePersonal => '创建个人聊天';

  @override
  String get chatCreateGroup => '创建群组聊天';

  @override
  String get chatCannotCreate => '抱歉，您无法发送直接消息。';

  @override
  String get chatDisabledUser => '已禁用聊天';

  @override
  String get chatSearchPlaceholder => '@ 某人';

  @override
  String get chatAddMorePlaceholder => '…添加更多成员';

  @override
  String chatUserNotFound(String name) {
    return '未找到 @$name';
  }

  @override
  String get chatCouldNotStartDm => '无法开始聊天。';

  @override
  String get chatSignInTitle => '登录后才能使用聊天';

  @override
  String get chatSignInMessage => '登录后才能查看和加入聊天频道。';

  @override
  String get chatDirectMessage => '直接消息';

  @override
  String get chatNotAvailable => '此论坛不提供聊天。';

  @override
  String get chatAttachFile => '附加文件';

  @override
  String get chatRemoveUpload => '移除文件';

  @override
  String get takePhoto => '拍照';

  @override
  String get postNeedsApprovalTitle => '帖子需要审批';

  @override
  String get postNeedsApprovalBody => '我们已收到您的帖子，不过需要由版主批准才能显示。请耐心等待。';

  @override
  String maximumAttachmentsAllowed(Object count) {
    return '最多允许 $count 个附件';
  }

  @override
  String get noImagesFoundToDisplay => '没有可显示的图片。';

  @override
  String get searchForTopics => '搜索话题';

  @override
  String get noTopicsFound => '未找到话题';

  @override
  String get trySearchingWithDifferentKeywords => '请尝试其他关键词';

  @override
  String get noPostsFound => '未找到帖子';

  @override
  String get perTopicNotificationLevelsNote =>
      '按类别和按话题的通知级别在相应页面直接设置 — 点击任意话题或类别上的铃铛图标。';

  @override
  String get pushNotActiveForThisLogin => '此次登录未启用 — 请退出并重新登录以授权推送通知';

  @override
  String get pauseNotificationsFor => '暂停通知…';

  @override
  String get doNotDisturbExplanation => '暂停通知一段时间 — Discourse 会保留它们直到时段结束';

  @override
  String get manageAccountSubtitle => '资料、邮箱、密码、安全、高级设置';

  @override
  String get changePasswordSubtitle => '向当前邮箱发送密码重置邮件';

  @override
  String get ignoredUsersSubtitle => '查看和管理其帖子对你隐藏的用户';

  @override
  String get deleteAccountExplanation => '如果论坛允许，您可以删除您的账户及帖子；否则可以请论坛管理人员为您删除。';

  @override
  String get verificationEmailSent => '验证邮件已发送 — 请点击链接确认新地址。';

  @override
  String get passwordResetExplanation =>
      '我们会向你发送密码重置链接。点击链接设置新密码 — 更改在论坛中完成，而非本应用。';

  @override
  String get sendResetEmail => '发送重置邮件';

  @override
  String get deleteAccountDialogBody =>
      '你的账户由论坛管理。请直接联系论坛管理团队申请删除账户。“继续”将在浏览器中打开论坛，以便使用站点自身的联系/管理团队消息流程。';

  @override
  String get initializingForum => '正在初始化论坛…';

  @override
  String get errorLoadingNotifications => '加载通知出错';

  @override
  String get noNewNotificationsExplanation =>
      '您将直接在此面板上收到与您相关的活动通知，包括对您的话题和帖子的回复，以及当有人提及 (@) 您或引用您以及回复您关注的话题时。当您有一段时间没有登录时，通知还将发送到您的电子邮件。';

  @override
  String noTagsMatch(Object filter) {
    return '没有与“$filter”匹配的标签。';
  }

  @override
  String noTopicsTagged(Object tag) {
    return '没有带“$tag”标签的话题';
  }

  @override
  String get searchUser => '搜索用户';

  @override
  String get tapToOpen => '点击打开';

  @override
  String get imageNotAvailable => '图片不可用';

  @override
  String postsCount(Object count) {
    return '$count 篇帖子';
  }

  @override
  String get permissionDeniedToSaveImage => '没有保存图片的权限';

  @override
  String get postNotFound => '未找到帖子。';

  @override
  String get failedToUploadFilePleaseTryAgain => '文件上传失败。请重试。';

  @override
  String failedToUploadFile2(Object errorMessage) {
    return '文件上传失败：$errorMessage';
  }

  @override
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return '仅允许再添加 $remainingSlots 个附件。将处理前 $remainingSlots2 张图片。';
  }

  @override
  String failedToRemoveAttachment2(Object error) {
    return '移除附件失败：$error';
  }

  @override
  String sentFromMobileApp(Object siteName) {
    return '来自 $siteName 移动应用';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading => '请等待附件上传完成';

  @override
  String get imageIsTooLargeToUpload => '图片过大，无法上传';

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName 大小为 $fileBytes。此论坛最多允许 $maxBytes。';
  }

  @override
  String get resizeToFitExplanation => '可以将其缩小到刚好符合限制，保留原格式和尽可能多的细节。';

  @override
  String get failedToPostReplyPleaseTryAgain => '回复发布失败。请重试。';

  @override
  String get failedToUpdatePostPleaseTryAgain => '帖子更新失败。请重试。';

  @override
  String get postDeletedSuccessfully => '帖子已删除';

  @override
  String failedToDeletePost(Object error) {
    return '删除帖子失败：$error';
  }

  @override
  String get editHistoryNotAvailable => '此帖子没有可用的编辑历史';

  @override
  String get react => '添加反应';

  @override
  String get reactionsAreNotEnabledOnThisForum => '此论坛未启用反应功能。';

  @override
  String get noReactionsYet => '还没有反应';

  @override
  String get searchFilters => '搜索筛选';

  @override
  String get suggestedTopics => '推荐话题';

  @override
  String get suggestedMessages => '建议的消息';

  @override
  String get voteRemoved => '已撤销投票';

  @override
  String get voters => '投票者';

  @override
  String get noVotesYet => '还没有投票。';

  @override
  String get trustLevels => '信任等级';

  @override
  String get trustLevelsExplanation => '成员通过阅读和参与获得信任。每个等级都会解锁新的权限。';

  @override
  String get activity => '动态';

  @override
  String get dontUpload => '不上传';

  @override
  String get dontAskAgainAlwaysResize => '不再询问 — 始终缩小以适应';

  @override
  String get couldNotLoadCategories => '无法加载类别。';

  @override
  String get tags => '标签';

  @override
  String get community => '社区';

  @override
  String get users => '用户';

  @override
  String get groups => '群组';

  @override
  String get invites => '邀请';

  @override
  String get account => '账户';

  @override
  String get drafts => '草稿';

  @override
  String get termsOfService => '服务条款';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get notSignedIn => '未登录';

  @override
  String get deviceWillNotShowAlertsUntilAllowedInSettings =>
      '在“设置”中允许通知之前，设备不会显示提醒。';

  @override
  String get openSettings => '打开设置';

  @override
  String get notificationsThisDeviceSection => '此设备';

  @override
  String notificationsThisDeviceCaption(Object forumName) {
    return '来自 $forumName 的推送仅发送到此设备，不影响你的其他设备和网页版。';
  }

  @override
  String notificationsAccountSection(Object forumName) {
    return '你在 $forumName 的账户';
  }

  @override
  String get notificationsAccountCaption => '这些设置在所有地方生效：网页、邮件以及你的所有设备。';

  @override
  String pushOnThisDeviceSubtitle(Object forumName) {
    return '已开启：$forumName 的新通知会推送到此设备。';
  }

  @override
  String pushOffThisDeviceSubtitle(Object forumName) {
    return '此设备上已关闭。要开启，需在 $forumName 上批准一次。';
  }

  @override
  String get stopPushOnThisDevice => '停止此设备上的推送';

  @override
  String stopPushTitle(Object forumName) {
    return '停止此设备上来自 $forumName 的推送？';
  }

  @override
  String get stopPushOnlyThisDevice => '只有此设备停止接收，你的其他设备不受影响。';

  @override
  String get stopPushNothingElseChanges => '你的通知仍会显示在应用和网页上，论坛的邮件也不会改变。';

  @override
  String stopPushPermissionDeleted(Object forumName) {
    return '你在 $forumName 上授予的权限将被删除。要重新开启推送，需要在论坛上再次批准。';
  }

  @override
  String get stopPushQuietHint => '只是想安静一会儿？在上方关闭不需要的类型，或使用个人资料中的“请勿打扰”。';

  @override
  String get stopPush => '停止推送';

  @override
  String get turnOn => '开启';

  @override
  String get couldNotTurnOffNotifications => '无法停止推送。请稍后再试。';

  @override
  String actionCodeTopicCreated(String when) {
    return '$when创建了此话题';
  }

  @override
  String actionCodePublicTopic(String when) {
    return '$when将此话题设为公开';
  }

  @override
  String actionCodeOpenTopic(String when) {
    return '$when将此转换为话题';
  }

  @override
  String actionCodePrivateTopic(String when) {
    return '$when将此话题转换为个人消息';
  }

  @override
  String actionCodeSplitTopic(String when) {
    return '$when拆分了此话题';
  }

  @override
  String actionCodeInvitedUser(String who, String when) {
    return '$when邀请了 $who';
  }

  @override
  String actionCodeInvitedGroup(String who, String when) {
    return '$when邀请了 $who';
  }

  @override
  String actionCodeUserLeft(String who, String when) {
    return '$who 在 $when将自己从此消息中移除';
  }

  @override
  String actionCodeRemovedUser(String who, String when) {
    return '$when移除了 $who';
  }

  @override
  String actionCodeRemovedGroup(String who, String when) {
    return '$when移除了 $who';
  }

  @override
  String actionCodeAutobumped(String when) {
    return '$when自动顶帖';
  }

  @override
  String actionCodeTagsChanged(String when) {
    return '标签 $when更新';
  }

  @override
  String actionCodeCategoryChanged(String when) {
    return '类别 $when更新';
  }

  @override
  String get actionCodeForwarded => '转发了上述电子邮件';

  @override
  String actionCodeAutoclosedEnabled(String when) {
    return '$when关闭';
  }

  @override
  String actionCodeAutoclosedDisabled(String when) {
    return '$when打开';
  }

  @override
  String actionCodeClosedEnabled(String when) {
    return '$when关闭';
  }

  @override
  String actionCodeClosedDisabled(String when) {
    return '$when打开';
  }

  @override
  String actionCodeArchivedEnabled(String when) {
    return '$when归档';
  }

  @override
  String actionCodeArchivedDisabled(String when) {
    return '$when取消归档';
  }

  @override
  String actionCodePinnedEnabled(String when) {
    return '$when置顶';
  }

  @override
  String actionCodePinnedDisabled(String when) {
    return '$when取消置顶';
  }

  @override
  String actionCodePinnedGloballyEnabled(String when) {
    return '$when全站置顶';
  }

  @override
  String actionCodePinnedGloballyDisabled(String when) {
    return '$when取消置顶';
  }

  @override
  String actionCodeVisibleEnabled(String when) {
    return '$when公开';
  }

  @override
  String actionCodeVisibleDisabled(String when) {
    return '$when取消公开';
  }

  @override
  String actionCodeBannerEnabled(String when) {
    return '$when将此设置为横幅。在用户忽略前，它将显示在每个页面的顶部。';
  }

  @override
  String actionCodeBannerDisabled(String when) {
    return '$when移除了此横幅。它将不再显示在每个页面的顶部。';
  }

  @override
  String actionCodeAssigned(String who, String when) {
    return '于 $when指定给 $who';
  }

  @override
  String actionCodeUnassigned(String who, String when) {
    return '于 $when取消指定 $who';
  }

  @override
  String actionCodeReassigned(String who, String when) {
    return '于 $when重新指定 $who';
  }

  @override
  String localDateToday(String time) {
    return '今天 $time';
  }

  @override
  String localDateTomorrow(String time) {
    return '明天 $time';
  }

  @override
  String localDateYesterday(String time) {
    return '昨天 $time';
  }

  @override
  String get eventExpired => '已过期';

  @override
  String get eventEveryDay => '每天';

  @override
  String get eventEveryWeekday => '每个工作日';

  @override
  String get eventEveryWeek => '每周的这个工作日';

  @override
  String get eventEveryTwoWeeks => '每两周的这个工作日';

  @override
  String get eventEveryFourWeeks => '每四周的这个工作日';

  @override
  String get eventEveryMonth => '每个月的这个工作日';

  @override
  String get errorNoConnection => '无法连接到论坛。请检查网络连接后重试。';

  @override
  String get errorTimedOut => '论坛响应超时，请重试。';

  @override
  String get errorPaywalled => '此内容仅限论坛付费会员查看。';

  @override
  String get errorBlocked => '论坛的防火墙拦截了本应用。请稍后重试，或在浏览器中打开论坛。';

  @override
  String get errorNotAllowed => '你无权访问此内容。登录后或许可以查看。';

  @override
  String get errorNotFound => '该内容不存在或已被删除。';

  @override
  String get errorRateLimited => '操作过于频繁，请稍候再试。';

  @override
  String get errorForumDown => '论坛暂时没有响应，请稍后再试。';

  @override
  String get deleteSpammer => '删除垃圾信息发布者';

  @override
  String get yesDeleteSpammer => '是，删除垃圾信息发布者';

  @override
  String get deleteSpammerConfirm =>
      '您将删除此用户的帖子和话题，移除他们的帐户，禁止其 IP 地址再次注册，同时将其电子邮件地址加入永久屏蔽名单。确定此用户是垃圾信息发布者吗？';

  @override
  String get userWasDeleted => '该用户已被删除。';

  @override
  String get deleteMyAccount => '删除我的帐户';

  @override
  String get deleteAccountConfirm => '确定要永久删除您的帐户吗？此操作无法撤消！';

  @override
  String get deletedYourself => '您的帐户已被成功删除。';

  @override
  String get deleteYourselfNotAllowed => '如果您希望删除您的帐户，请联系管理人员。';

  @override
  String get createTopic => '创建话题';

  @override
  String get discardPostQuestion => '是否要放弃您的帖子？';

  @override
  String get discardChangesQuestion => '您确定要放弃所做的更改吗？';

  @override
  String get discardChanges => '舍弃更改';

  @override
  String get saveDraft => '保存草稿';

  @override
  String get notificationSettings => '通知设置';

  @override
  String get topicIsNew => '新话题';

  @override
  String get noNewTopicsSinceLastVisit => '自你上次访问以来没有新话题。';

  @override
  String get messageIsNew => '新消息';

  @override
  String topicUnreadReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条未读回复',
    );
    return '$_temp0';
  }

  @override
  String filterNewWithCount(int count) {
    return '新 ($count)';
  }

  @override
  String filterUnreadWithCount(int count) {
    return '未读 ($count)';
  }

  @override
  String categoryNewTopics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 新',
    );
    return '$_temp0';
  }

  @override
  String categoryUnreadTopics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 未读',
    );
    return '$_temp0';
  }

  @override
  String get dismissNew => '忽略新话题';

  @override
  String get dismissUnread => '忽略未读话题';

  @override
  String get dismissNewTitle => '忽略新话题？';

  @override
  String get dismissNewMessage => '它们将不再显示为新话题。';

  @override
  String get dismissUnreadTitle => '忽略所有未读话题？';

  @override
  String get dismissUnreadMessage => '它们的新回复将被标记为已读。';

  @override
  String get dismissUnreadStopTracking => '停止跟踪这些话题，以便它们不再显示为我的未读话题';

  @override
  String get dismissNewAndUnread => '忽略新话题和未读话题';

  @override
  String dismissNewAndUnreadMessage(String category) {
    return '$category 中的话题将不再显示为新话题或未读话题。';
  }

  @override
  String get dismissedTopics => '已忽略';

  @override
  String topicMapViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '浏览',
    );
    return '$_temp0';
  }

  @override
  String topicMapLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '赞',
    );
    return '$_temp0';
  }

  @override
  String topicMapLinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '链接',
    );
    return '$_temp0';
  }

  @override
  String topicMapUsers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '用户',
    );
    return '$_temp0';
  }

  @override
  String get markAsSolution => '标记为解决方案';

  @override
  String get unmarkAsSolution => '取消标记为解决方案';

  @override
  String searchForumName(String forum) {
    return '搜索 $forum';
  }

  @override
  String countActiveThisMonth(String formatted) {
    return '本月活跃 $formatted';
  }

  @override
  String countMembers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted 位成员',
    );
    return '$_temp0';
  }

  @override
  String countTopics(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted 个话题',
    );
    return '$_temp0';
  }

  @override
  String categoryNewThisWeek(int count) {
    return '本周新增 $count';
  }

  @override
  String get categoriesView => '类别';

  @override
  String get allCategories => '所有类别';

  @override
  String get allTags => '所有标签';

  @override
  String get myPosts => '我的帖子';

  @override
  String get drawerIntroduction => '此论坛的类别、标签和您的账户都在这个菜单里。随时点按菜单按钮即可再次打开。';

  @override
  String trustLevelN(int level) {
    return '信任等级 $level';
  }

  @override
  String get filterNew => '新';

  @override
  String get filterTop => '热门';

  @override
  String get levelWatching => '关注';

  @override
  String get levelWatchingFirstPost => '关注第一个帖子';

  @override
  String get levelTracking => '跟踪';

  @override
  String get levelNormal => '常规';

  @override
  String get levelMuted => '免打扰';

  @override
  String get chooseCategory => '选择类别';

  @override
  String get signInToPostAndGetNotifications => '登录后即可发帖和接收通知';

  @override
  String forumBlocksNotificationServer(Object forumName) {
    return '$forumName 屏蔽了我们的通知服务器，因此通知可能无法送达。你可以在设置中关闭通知。';
  }

  @override
  String get relatedTopics => '相关话题';

  @override
  String get relatedMessages => '相关消息';

  @override
  String moreInCategory(String category) {
    return '$category 中的更多话题';
  }

  @override
  String get latestTopics => '最新话题';

  @override
  String get pushGroupMessages => '消息和聊天';

  @override
  String get pushGroupMessagesHint => '私信、群组收件箱和聊天';

  @override
  String get pushGroupReplies => '回复和提及';

  @override
  String get pushGroupRepliesHint => '回复、提及、引用和关注的话题';

  @override
  String get pushGroupReactions => '点赞和回应';

  @override
  String get pushGroupReactionsHint => '对你帖子的点赞和回应';

  @override
  String get pushGroupOther => '其他所有';

  @override
  String get pushGroupOtherHint => '徽章、提醒、被采纳的回答等';

  @override
  String get pushChannelOther => '其他通知';

  @override
  String get couldNotChangePushSetting => '无法更改此设置，请稍后再试。';

  @override
  String neverMissAReplyOn(Object forumName) {
    return '不错过 $forumName 上的任何回复';
  }

  @override
  String get notificationsPitch =>
      '回复、提及、私信和聊天直达锁屏，通常在 10 分钟内送达。你可以随时在设置中选择接收哪些。';

  @override
  String get notificationsStepAllow => '允许此手机接收通知';

  @override
  String get notificationsStepAllowed => '此手机已允许通知';

  @override
  String notificationsStepApprove(Object forumName) {
    return '在 $forumName 上批准';
  }

  @override
  String get notificationsReadOnlyNote => '只读：无法发帖、回复或阅读你的私信';

  @override
  String get notificationPreviewReply => 'Jane 回复了你：欢迎加入！很高兴你找到了我们。';

  @override
  String get notificationPreviewMessage => 'Sam 给你发了消息：周五你来吗？';

  @override
  String get notificationPreviewNow => '刚刚';

  @override
  String get notificationPreviewEarlier => '5 分钟前';

  @override
  String get activityReplied => '回复了';

  @override
  String get activityStartedTopic => '发起了话题';

  @override
  String get activityLiked => '赞了';

  @override
  String get activitySolution => '解决方案';

  @override
  String get activityAcceptedBy => '采纳者';

  @override
  String get activityAwaitingApproval => '等待审核';

  @override
  String get activityFilterTopics => '话题';

  @override
  String get activityFilterReplies => '回复';

  @override
  String get activityFilterLikes => '赞';

  @override
  String get activityFilterPending => '待审核';

  @override
  String get sectionToday => '今天';

  @override
  String get sectionThisWeek => '本周';

  @override
  String get sectionEarlier => '更早';

  @override
  String draftsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 份草稿待完成',
    );
    return '$_temp0';
  }

  @override
  String get resumeDrafts => '继续';

  @override
  String get myPostsEmpty => '还没有帖子';

  @override
  String get myPostsEmptyHint => '你发起的话题和写的回复会显示在这里。';

  @override
  String get activityEmptyTopics => '还没有话题';

  @override
  String get activityEmptyReplies => '还没有回复';

  @override
  String get activityEmptyLikes => '还没有点过赞';

  @override
  String get activityEmptySolved => '还没有解决方案';

  @override
  String get viewProfile => '查看个人资料';

  @override
  String get yourStuff => '我的内容';

  @override
  String get accountAndPrivacy => '账户和隐私';

  @override
  String profileStatPosts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '帖子',
    );
    return '$_temp0';
  }

  @override
  String profileStatLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '赞',
    );
    return '$_temp0';
  }

  @override
  String profileStatDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '天',
    );
    return '$_temp0';
  }

  @override
  String get profileStatSolved => '已解决';

  @override
  String joinForum(String forum) {
    return '加入 $forum';
  }

  @override
  String get guestBenefitPost => '回复和发起话题';

  @override
  String get guestBenefitNotify => '有人回复时收到通知';

  @override
  String get guestBenefitSave => '收藏帖子，保存草稿';

  @override
  String get guestBenefitChat => '聊天和发送消息';

  @override
  String get createAccount => '创建账户';

  @override
  String get aboutThisForum => '关于此论坛';

  @override
  String get drawerMore => '更多';

  @override
  String get goToYourProfile => '前往你的个人资料';

  @override
  String profileJoined(String date) {
    return '$date 加入';
  }

  @override
  String profileSeen(String when) {
    return '$when 访问';
  }

  @override
  String profileLocalTime(String time) {
    return '当地时间 $time';
  }

  @override
  String get profileTabSummary => '摘要';

  @override
  String get summaryTopReplies => '热门回复';

  @override
  String get summaryTopTopics => '热门话题';

  @override
  String get summaryMostLikedBy => '最常点赞者';

  @override
  String get summaryMostLiked => '最常赞的人';

  @override
  String get summaryMostRepliedTo => '最常回复的人';

  @override
  String get summaryTopLinks => '热门链接';

  @override
  String get summaryTopCategories => '常去的类别';

  @override
  String get featuredTopic => '精选话题';

  @override
  String get profileDetails => '详细信息';

  @override
  String get followUser => '关注';

  @override
  String get unfollowUser => '取消关注';

  @override
  String get profileSuspended => '已停用';

  @override
  String get searchBookmarks => '搜索你的书签';

  @override
  String get bookmarksFilterReminders => '提醒';

  @override
  String get bookmarkWholeTopic => '整个话题';

  @override
  String bookmarkSaved(String when) {
    return '$when保存';
  }

  @override
  String bookmarkPostNumber(int number) {
    return '帖子 #$number';
  }

  @override
  String reminderToday(String time) {
    return '今天 $time';
  }

  @override
  String reminderTomorrow(String time) {
    return '明天 $time';
  }

  @override
  String reminderDue(String when) {
    return '到期 · $when';
  }

  @override
  String get addBookmarkLabel => '添加标签';

  @override
  String get editBookmarkLabel => '编辑标签';

  @override
  String get bookmarkLabelHint => '这是用来做什么的？';

  @override
  String get pinBookmark => '置顶';

  @override
  String get unpinBookmark => '取消置顶';

  @override
  String get bookmarkRemoved => '已删除书签';

  @override
  String get undo => '撤销';

  @override
  String get bookmarksNoMatch => '没有匹配的书签';

  @override
  String get addReminder => '添加提醒';

  @override
  String get bookmarksEmpty => '还没有书签';

  @override
  String get bookmarksEmptyHint => '从帖子的操作中添加书签，它会在这里等你。';

  @override
  String get draftKindNewTopic => '新话题';

  @override
  String draftMessageTo(String names) {
    return '发给 $names 的消息';
  }

  @override
  String get untitledTopic => '无标题话题';

  @override
  String get draftDiscarded => '已丢弃草稿';

  @override
  String get draftsEmpty => '还没有草稿';

  @override
  String get draftsEmptyHint => '草稿会在你输入时自动保存。开始写回复或话题，它会在这里等你。';

  @override
  String get privacySection => '隐私';

  @override
  String get changeEmailSubtitle => '我们会向新地址发送验证链接';

  @override
  String get aboutMe => '关于我';

  @override
  String get aboutMeHelper => '显示在你的个人资料顶部';

  @override
  String get aboutMeMarkdownHint => '支持 Markdown：**粗体**、链接、:emoji:';

  @override
  String get addCover => '添加封面';

  @override
  String get changeCover => '更换封面';

  @override
  String get birthdayHint => '论坛会和你一起庆祝。不会保存年份。';

  @override
  String get birthdayRemoved => '已移除生日';

  @override
  String get birthdaySaved => '已保存生日';

  @override
  String get cardBackground => '卡片背景';

  @override
  String get cardBackgroundExplanation => '有人点按你的头像时，显示在你的用户卡片后面';

  @override
  String get cardBackgroundRemoved => '已移除卡片背景';

  @override
  String get cardBackgroundSheetHint => '显示在你的用户卡片后面。宽幅照片效果最佳。';

  @override
  String get changeProfilePicture => '更换头像';

  @override
  String get changeUsername => '更改用户名';

  @override
  String changeUsernameExplanation(String username) {
    return '帖子中对 @$username 的提及和引用会改为新名称。指向你个人资料的旧链接将失效。';
  }

  @override
  String get chooseFromLibrary => '从相册选择';

  @override
  String get coverPhoto => '封面照片';

  @override
  String get coverPhotoSheetHint => '显示在你的个人资料顶部、头像后面。宽幅照片效果最佳，约 3:1。';

  @override
  String get coverRemoved => '已移除封面';

  @override
  String get day => '日';

  @override
  String get month => '月';

  @override
  String get displayName => '显示名称';

  @override
  String displayNameHelper(String username) {
    return '与你的帖子一起显示。你的用户名仍为 @$username。';
  }

  @override
  String get emailPasswordInAccount => '邮箱、密码和登录';

  @override
  String get featureATopic => '设置精选话题';

  @override
  String get featureATopicHint => '将你的一个话题置顶在个人资料顶部。';

  @override
  String get featuredTopicChanged => '已更改精选话题';

  @override
  String get featuredTopicNone => '无。将你的一个话题置顶到个人资料。';

  @override
  String get featuredTopicRemoved => '已移除精选话题';

  @override
  String get featuredTopicRules => '消息和私密类别中的话题无法设为精选。';

  @override
  String get fieldManagedBySignIn => '此论坛通过自己的登录系统管理此项。请在那里更改。';

  @override
  String get flair => '徽记';

  @override
  String flairChangedTo(String group) {
    return '徽记已更改为 $group';
  }

  @override
  String get flairRemoved => '已移除徽记';

  @override
  String get flairSheetHint => '显示在你头像上的小标志，来自你所在的群组。';

  @override
  String forumPictureN(int number) {
    return '论坛图片 $number';
  }

  @override
  String forumQuestionNeedsAnswer(String question) {
    return '$question 需要回答';
  }

  @override
  String get forumQuestionRequired => '此论坛要求所有人回答';

  @override
  String get forumQuestionSetByStaff => '由论坛管理人员设置';

  @override
  String get forumQuestionsIntro => '来自此论坛的问题。* 表示必填。';

  @override
  String get forumQuestionsNoneAnswered => '尚未回答';

  @override
  String get fromThisForum => '来自此论坛';

  @override
  String get hideMyProfile => '隐藏我的公开个人资料';

  @override
  String get hideMyProfileExplanation => '其他人只能看到你的名称、头像和帖子';

  @override
  String get letterAvatar => '首字母';

  @override
  String get moreAboutYou => '更多关于你';

  @override
  String namesAndMore(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项',
    );
    return '$names及另外 $_temp0';
  }

  @override
  String get newUsername => '新用户名';

  @override
  String get noFlair => '不显示徽记';

  @override
  String noGravatarFound(String service) {
    return '$service 没有与你的邮箱地址关联的图片';
  }

  @override
  String get noTitle => '不显示头衔';

  @override
  String get noTopicsMatch => '没有匹配的话题';

  @override
  String get noTopicsToFeature => '你还没有发起任何话题';

  @override
  String get notSet => '未设置';

  @override
  String get orUse => '或使用';

  @override
  String get pictureManagedBySignIn => '此论坛通过自己的登录系统设置你的头像';

  @override
  String get primaryGroup => '主要群组';

  @override
  String primaryGroupChangedTo(String group) {
    return '主要群组已更改为 $group';
  }

  @override
  String get primaryGroupRemoved => '已移除主要群组';

  @override
  String get primaryGroupSheetHint => '你的主要群组，显示在你的用户卡片上。';

  @override
  String get profileLoadFailed => '无法加载你的个人资料';

  @override
  String get profileNowHidden => '你的个人资料已隐藏';

  @override
  String get profileNowPublic => '你的个人资料已公开';

  @override
  String get profilePicture => '头像';

  @override
  String get profilePictureChanged => '已更换头像';

  @override
  String get profileSaveFailed => '无法保存。请重试。';

  @override
  String get profileSectionNameAndAbout => '名称和简介';

  @override
  String get profileSectionNextToName => '名称旁边';

  @override
  String get profileSectionOnProfile => '个人资料中';

  @override
  String get profileSectionPrivacyAndTime => '隐私和时间';

  @override
  String get removeCardBackground => '移除卡片背景';

  @override
  String get removeCover => '移除封面';

  @override
  String get removeFeaturedTopic => '移除精选话题';

  @override
  String get searchTimezones => '搜索时区';

  @override
  String get searchYourTopics => '搜索你的话题';

  @override
  String get seeProfileAsOthersDo => '以他人视角查看个人资料';

  @override
  String get timezone => '时区';

  @override
  String timezoneChangedTo(String zone) {
    return '时区已更改为 $zone';
  }

  @override
  String timezoneWithTime(String zone, String time) {
    return '$zone · 现在 $time';
  }

  @override
  String timezonesMatchingPhone(String offset) {
    return '与此手机时钟一致（$offset）';
  }

  @override
  String titleChangedTo(String title) {
    return '头衔已更改为 $title';
  }

  @override
  String get titleFromBadge => '徽章';

  @override
  String titleFromBadgeEarned(String date) {
    return '徽章 · 获得于 $date';
  }

  @override
  String titleFromGroup(String group) {
    return '$group 群组';
  }

  @override
  String get titleGrantedByStaff => '由论坛管理人员授予';

  @override
  String get titleRemoved => '已移除头衔';

  @override
  String get titleSheetHint => '显示在你的个人资料和帖子中的名称后面。';

  @override
  String get username => '用户名';

  @override
  String get usernameAvailable => '可用';

  @override
  String usernameChanged(String username) {
    return '你的用户名现在是 @$username';
  }

  @override
  String get usernameLockedExplanation => '此论坛只允许成员在加入后不久更改用户名。版主可以帮你更改。';

  @override
  String get yourPhoto => '你的照片';

  @override
  String get chooseEmoji => '选择表情符号';

  @override
  String get clearStatus => '清除状态';

  @override
  String get clearText => '清除';

  @override
  String get inOneHour => '一小时后';

  @override
  String get never => '从不';

  @override
  String get pauseNotifications => '暂停通知';

  @override
  String get pauseNotificationsUntilStatusClears => '直到状态被清除';

  @override
  String get pickATime => '选择时间';

  @override
  String get removeStatusAfter => '移除状态';

  @override
  String get searchEmoji => '搜索表情符号';

  @override
  String get setStatus => '设置状态';

  @override
  String get setAStatus => '设置状态';

  @override
  String get statusUpdated => '状态已更新';

  @override
  String get whatAreYouDoing => '你在做什么？';

  @override
  String cardPosted(String when) {
    return '$when发帖';
  }

  @override
  String get change => '更改';

  @override
  String get copyProfileLink => '复制个人资料链接';

  @override
  String get ignore => '忽略';

  @override
  String memberOfGroup(String group) {
    return '$group 成员';
  }

  @override
  String get mute => '静音';

  @override
  String get unmute => '取消静音';

  @override
  String openProfileOf(String username) {
    return '打开 @$username 的个人资料';
  }

  @override
  String profileIsPrivate(String username) {
    return '$username 的个人资料不公开。';
  }

  @override
  String showOnlyTheirPostsHere(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条',
    );
    return '只显示 $name 在此话题中的帖子（$_temp0）';
  }

  @override
  String showOnlyYourPostsHere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条',
    );
    return '只显示你在此话题中的帖子（$_temp0）';
  }

  @override
  String userIgnoredFor4Months(String username) {
    return '将忽略 @$username 4 个月';
  }

  @override
  String userMuted(String username) {
    return '已静音 @$username';
  }

  @override
  String userUnmuted(String username) {
    return '已取消静音 @$username';
  }

  @override
  String get youParenthetical => '（你）';

  @override
  String get topicStatusClosedHelp => '此话题已被关闭；不再接受新回复';

  @override
  String get topicStatusArchivedHelp => '此话题已被归档；已被冻结，无法更改';

  @override
  String get topicStatusClosedArchivedHelp => '此话题已被关闭并存档；不再接受新回复且无法更改';

  @override
  String get topicStatusPinnedTitle => '已置顶';

  @override
  String get topicStatusPinnedHelp => '此话题已对您置顶；它将显示在所属类别的顶部';

  @override
  String get topicStatusPinnedGloballyTitle => '已全站置顶';

  @override
  String get topicStatusPinnedGloballyHelp => '此话题已被全站置顶；它将显示在最新话题列表及其所属类别的顶部';

  @override
  String get topicStatusUnpinnedTitle => '已取消置顶';

  @override
  String get topicStatusUnpinnedHelp => '此话题已对您取消置顶；它将以常规顺序显示';

  @override
  String get topicStatusUnlistedHelp => '此话题已被取消公开；它不会显示在话题列表中，只能通过直接链接访问。';

  @override
  String get topicStatusWarningHelp => '这是一个官方警告。';

  @override
  String get notificationReasonWatchingTag => '由于您正在关注此话题的一个标签，您将收到通知。';

  @override
  String get notificationReasonWatchingCategory => '由于您正在关注此类别，您将收到通知。';

  @override
  String get notificationReasonWatchingAuto => '由于您已开始自动关注此话题，您将收到通知。';

  @override
  String get notificationReasonWatching => '由于您正在关注此话题，您将收到通知。';

  @override
  String get notificationReasonWatchingCreated => '由于您创建了此话题，您将收到通知。';

  @override
  String get notificationReasonTrackingCategory => '由于您正在跟踪此类别，您将看到新回复的数量。';

  @override
  String get notificationReasonTrackingReplied => '由于您发表过对此话题的回复，您将看到新回复的数量。';

  @override
  String get notificationReasonTracking => '由于您正在跟踪此话题，您将看到新回复的数量。';

  @override
  String get notificationReasonTrackingRead => '由于您阅读过此话题，您将看到新回复的数量。';

  @override
  String get notificationReasonNormal => '您会在别人 @ 您或回复您时收到通知。';

  @override
  String get notificationReasonMutedCategory => '您将忽略此类别中的所有通知。';

  @override
  String get notificationReasonMuted => '您将忽略有关此话题的所有通知。';

  @override
  String get notificationLevelWatching => '关注';

  @override
  String get notificationLevelWatchingFirstPost => '关注第一个帖子';

  @override
  String get notificationLevelTracking => '跟踪';

  @override
  String get notificationLevelNormal => '常规';

  @override
  String get notificationLevelMuted => '已设为免打扰';

  @override
  String get topicWatchingDescription => '您将在此话题有新回复时收到通知，并且会显示新回复数量。';

  @override
  String get topicTrackingDescription => '将显示此话题的新回复数量。您会在别人 @ 您或回复您时收到通知。';

  @override
  String get topicNormalDescription => '您会在别人 @ 您或回复您时收到通知。';

  @override
  String get topicMutedDescription => '您永远不会收到有关此话题的任何通知，它也不会出现在最新话题中。';

  @override
  String get messageWatchingDescription => '您将在此消息有新回复时收到通知，并且会显示新回复数量。';

  @override
  String get messageTrackingDescription => '将显示此消息的新回复数量。您会在别人 @ 您或回复您时收到通知。';

  @override
  String get messageNormalDescription => '您会在别人 @ 您或回复您时收到通知。';

  @override
  String get messageMutedDescription => '您永远不会收到有关此消息的任何通知。';

  @override
  String get categoryWatchingDescription =>
      '您将自动关注此类别中的所有话题。您会收到每个话题中每个新帖子的通知，并且会显示新回复数量。';

  @override
  String get categoryWatchingFirstPostDescription =>
      '您将收到此类别中新话题的通知，但不会收到话题回复。';

  @override
  String get categoryTrackingDescription =>
      '您将自动跟踪此类别中的所有话题。您会在别人 @ 您或回复您时收到通知，并且会显示新回复数量。';

  @override
  String get categoryNormalDescription => '您会在别人 @ 您或回复您时收到通知。';

  @override
  String get categoryMutedDescription => '您不会收到有关此类别中新话题的任何通知，它们也不会出现在最新话题页面上。';

  @override
  String get tagWatchingDescription =>
      '您将自动关注带有此标签的所有话题。您会收到所有新帖子和话题的通知，话题旁还会显示未读和新帖子的数量。';

  @override
  String get tagWatchingFirstPostDescription => '您将收到此标签中新话题的通知，但不会收到话题回复。';

  @override
  String get tagTrackingDescription => '您将自动跟踪带有此标签的所有话题。未读和新帖子的数量将显示在话题旁边。';

  @override
  String get tagNormalDescription => '您会在别人 @ 您或回复您的帖子时收到通知。';

  @override
  String get tagMutedDescription => '您不会收到有关带有此标签的新话题的任何通知，它们也不会出现在您的未读标签页上。';

  @override
  String topicTimerAutoOpen(String timeLeft) {
    return '此话题将在$timeLeft自动开启。';
  }

  @override
  String topicTimerAutoClose(String timeLeft) {
    return '此话题将在$timeLeft自动关闭。';
  }

  @override
  String topicTimerAutoPublish(String categoryName, String timeLeft) {
    return '此话题将在$timeLeft发布到 #$categoryName。';
  }

  @override
  String topicTimerAutoCloseAfterLastPost(String duration) {
    return '此话题将在最后一个回复的$duration后关闭。';
  }

  @override
  String topicTimerAutoDeleteAfterLastPost(String duration) {
    return '此话题将在最后一个回复的$duration后删除。';
  }

  @override
  String topicTimerAutoDelete(String timeLeft) {
    return '此话题将在$timeLeft自动删除。';
  }

  @override
  String topicTimerAutoBump(String timeLeft) {
    return '此话题将在$timeLeft被自动顶帖。';
  }

  @override
  String topicTimerAutoDeleteReplies(String duration) {
    return '此话题的回复会在$duration后自动删除。';
  }

  @override
  String slowModeNotice(String duration) {
    return '请在此话题的两次发帖之间等待 $duration。';
  }

  @override
  String get closeTopic => '关闭话题';

  @override
  String get openTopic => '打开话题';

  @override
  String get pinTopic => '置顶话题';

  @override
  String get unpinTopic => '取消置顶话题';

  @override
  String get archiveTopic => '归档话题';

  @override
  String get unarchiveTopic => '取消归档话题';

  @override
  String get unlistTopic => '取消公开话题';

  @override
  String get listTopic => '公开话题';

  @override
  String get permanentlyDelete => '永久删除';

  @override
  String get permanentlyDeleteTopicConfirmation =>
      '此操作无法撤销。这将永久删除此话题并将其从数据库中移除。';

  @override
  String get deleteTopicConfirmYes => '是，删除此话题';

  @override
  String get deleteTopicConfirmNo => '否，保留此话题';

  @override
  String get topicPinned => '话题已置顶';

  @override
  String get topicUnpinned => '话题已取消置顶';

  @override
  String get topicArchived => '话题已归档';

  @override
  String get topicUnarchived => '话题已取消归档';

  @override
  String get topicUnlisted => '话题已取消公开';

  @override
  String get topicListed => '话题已公开';

  @override
  String get topicRecovered => '已取消删除话题';

  @override
  String topicActionFailed(String error) {
    return '无法更新话题：$error';
  }

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 分钟',
    );
    return '$_temp0';
  }

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 小时',
    );
    return '$_temp0';
  }

  @override
  String durationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天',
    );
    return '$_temp0';
  }

  @override
  String timeLeftMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 分钟后',
    );
    return '$_temp0';
  }

  @override
  String timeLeftHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 小时后',
    );
    return '$_temp0';
  }

  @override
  String timeLeftDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天后',
    );
    return '$_temp0';
  }

  @override
  String get topicStatusDeletedHelp => '此话题已删除并对其他用户隐藏';

  @override
  String get flagAction => '举报';

  @override
  String get flagPost => '举报帖子';

  @override
  String get signUp => '注册';

  @override
  String get suspendUser => '封禁用户';

  @override
  String get unsuspend => '取消封禁';

  @override
  String get suspendUntil => '将用户封禁至';

  @override
  String get suspendForever => '永久封禁';

  @override
  String failedToSuspendUser(String error) {
    return '封禁此用户时出错：$error';
  }

  @override
  String failedToUnsuspendUser(String error) {
    return '取消封禁此用户时出错：$error';
  }

  @override
  String get suspendReasonNotListening => '不听从管理人员反馈';

  @override
  String get suspendReasonStaffTime => '消耗了过多的管理人员时间';

  @override
  String get suspendReasonCombative => '好斗';

  @override
  String get suspendReasonWrongPlace => '在错误的地方';

  @override
  String get suspendReasonNoPurpose => '除了在社区内引起异议外，该用户的行动没有任何建设性的目的';

  @override
  String get suspendReasonCustom => '自定义…';

  @override
  String get suspendReasonQuestion => '您为什么封禁该用户？当用户尝试登录时将看到此文本。尽量简洁。';

  @override
  String get closedLabel => '已关闭';

  @override
  String get flaggingPost => '正在举报帖子…';

  @override
  String get pleaseSelectSuspensionEndDate => '请选择封禁结束时间';

  @override
  String get suspendingUser => '正在封禁用户…';

  @override
  String get unsuspendingUser => '正在取消封禁用户…';

  @override
  String get userSuspended => '已封禁用户';

  @override
  String get userUnsuspended => '已取消封禁用户';

  @override
  String unsuspendUserConfirmation(String username) {
    return '取消封禁 $username？该用户将能再次登录。';
  }

  @override
  String get noCategoriesToDisplay => '没有可显示的类别。';

  @override
  String get noPermissionToViewCategory => '您无权查看此类别中的话题。';

  @override
  String get featureTopicTitle => '将此话题设为精选';

  @override
  String get pinTopicMenu => '置顶话题…';

  @override
  String pinInCategoryUntil(String category) {
    return '将此话题置于$category类别顶部至';
  }

  @override
  String get pinGloballyUntil => '将此话题置于所有话题列表顶部至';

  @override
  String get pinNote => '用户可以为自己单独取消置顶话题。';

  @override
  String get pinUntil => '置顶至';

  @override
  String get pinDateRequired => '置顶此话题需要一个日期。';

  @override
  String get pinTopicGlobally => '全站置顶话题';

  @override
  String get flagThanks => '感谢您维护社区的文明！';

  @override
  String get flagReviewProcess => '版主收到举报后将尽快进行审核。';

  @override
  String get flagCant => '抱歉，您目前无法举报此帖子。';

  @override
  String get flagSendMessage => '消息';

  @override
  String get flagMessageForUser => '给用户的消息';

  @override
  String get flagMessageForModerators => '给版主的消息';

  @override
  String get flagPlaceholderNotifyUser => '具体，有建设性，并始终保持友善。';

  @override
  String get flagPlaceholderNotifyModerators => '让我们具体了解您关心的问题，并尽可能提供相关的链接和示例。';

  @override
  String get flagPlaceholderIllegal => '请向我们说明您认为此内容违法的具体原因，并尽可能提供相关链接和示例。';

  @override
  String get flagConfirmIllegal => '我上面所写的内容准确且完整。';

  @override
  String flagMessageAtLeast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '至少输入 $count 个字符',
    );
    return '$_temp0';
  }

  @override
  String get flagMessageSent => '您的消息已发送。';

  @override
  String get mergeTopicError => '将帖子移至该话题时出错。';

  @override
  String get topicTitlePlaceholder => '用一句话概括讨论内容…';

  @override
  String get topicMoved => '话题已移动';

  @override
  String get topicMerged => '话题已合并';

  @override
  String get mergeTopicExplanation => '此话题中的所有帖子都将移至你选择的话题。此操作无法在应用中撤销。';

  @override
  String get destinationTopicId => '目标话题 ID';

  @override
  String get topicAuthorUnknown => '未知';

  @override
  String get noHotTopics => '没有热门话题。';

  @override
  String get signInToViewNewTopics => '登录以查看新话题';

  @override
  String get newTopicsSignInMessage => '新话题显示自您上次访问以来创建的内容。';

  @override
  String get topPeriodAllTime => '所有时间';

  @override
  String get topPeriodYear => '年';

  @override
  String get topPeriodQuarter => '季度';

  @override
  String get topPeriodMonth => '月';

  @override
  String get topPeriodWeek => '周';

  @override
  String get topPeriodToday => '今天';

  @override
  String noTopTopicsForPeriod(String period) {
    String _temp0 = intl.Intl.selectLogic(
      period,
      {
        'all': '没有所有时间的热门话题。',
        'yearly': '今年没有热门话题。',
        'quarterly': '本季度没有热门话题。',
        'monthly': '本月没有热门话题。',
        'weekly': '本周没有热门话题。',
        'daily': '今天没有热门话题。',
        'other': '没有热门话题。',
      },
    );
    return '$_temp0';
  }

  @override
  String get connectionTimedOutSiteUnreachable => '连接超时。网站可能已关闭或无法访问。';

  @override
  String get failedToMarkNotificationsRead => '无法将通知标记为已读';

  @override
  String get forumNameFallback => '论坛';

  @override
  String get noForumDescription => '暂无描述。';

  @override
  String get dismissAllNotifications => '全部忽略';

  @override
  String get notificationPostIdMissing => '缺少帖子 ID。无法跳转到该帖子。';

  @override
  String get notificationTopicIdMissingForPost => '缺少话题 ID。无法跳转到该帖子。';

  @override
  String get notificationTopicIdMissing => '缺少话题 ID。无法打开该话题。';

  @override
  String get notificationUsernameMissing => '缺少用户名。无法打开用户资料。';

  @override
  String get notificationChannelIdMissing => '缺少频道 ID。无法打开聊天。';

  @override
  String get notificationGroupNameMissingForInbox => '缺少群组名称。无法打开收件箱。';

  @override
  String get notificationGroupNameMissing => '缺少群组名称。无法打开该群组。';

  @override
  String get notificationNoActionUrl => '此通知类型没有可用的操作 URL。';

  @override
  String get notificationBadgeUnavailable => '徽章详情不可用。';

  @override
  String get notificationBadgeLoadFailed => '无法加载此徽章。';

  @override
  String get personalMessageTitleFallback => '个人消息';

  @override
  String get topicTitleFallback => '话题';

  @override
  String get signInToViewNotifications => '登录以查看通知';

  @override
  String get youNeedToBeSignedInToViewNotifications => '您需要登录才能查看通知。';

  @override
  String get noUnreadNotifications => '没有未读通知';

  @override
  String get noNotificationsYet => '还没有通知';

  @override
  String get newNotificationFallbackBody => '新通知';

  @override
  String get unableToOpenNotification => '无法打开通知';

  @override
  String get notificationMissingSiteInfo => '缺少站点信息（site_id）。';

  @override
  String get notificationInvalidSiteInfo => '站点信息无效（site_id）。';

  @override
  String get notificationMissingPostInfo => '缺少帖子信息（content_id）。';

  @override
  String get notificationMissingMessageInfo => '缺少消息信息（conversation_id）。';

  @override
  String get notificationMissingUserInfo => '缺少用户信息（sender_id）。';

  @override
  String get notificationUnsupportedType => '不支持的通知类型。';

  @override
  String get notificationForumNotFound => '找不到此站点的论坛。';

  @override
  String get notificationForumOpenFailed => '无法初始化论坛。';

  @override
  String get notificationMissingTopicInfo => '缺少话题信息（topic_id）。';

  @override
  String get failedToLoadTags => '无法加载标签。';

  @override
  String get searchTagsHint => '搜索标签…';

  @override
  String get tagsSortedByCountTooltip => '按话题数排序 — 点按切换为 A→Z';

  @override
  String get tagsSortedAlphabeticallyTooltip => '按字母顺序排序 — 点按切换为按热度排序';

  @override
  String get noTagsYet => '此论坛还没有标签。';

  @override
  String get tagNotificationLevelTooltip => '通知级别';

  @override
  String get tagTopicsLoadFailed => '加载失败';

  @override
  String searchFailedWithError(String error) {
    return '搜索失败：$error';
  }

  @override
  String get searchFiltersButtonTooltip => '筛选';

  @override
  String get searchFilterStatusSection => '状态';

  @override
  String get searchFilterMyActivitySection => '我的活动';

  @override
  String get searchFilterMatchTypeSection => '匹配类型';

  @override
  String get searchTagsFilterHelper => '用空格或逗号分隔。须包含每个标签。';

  @override
  String get searchSortBy => '排序依据';

  @override
  String get searchStatusOpen => '开放';

  @override
  String get searchStatusArchived => '已归档';

  @override
  String get searchStatusNoReplies => '无回复';

  @override
  String get searchStatusPublicOnly => '仅公开';

  @override
  String get searchStatusUnsolved => '未解决';

  @override
  String get searchInBookmarked => '我已加入书签';

  @override
  String get searchInMyMessages => '在我的消息中';

  @override
  String get searchInLiked => '我赞过';

  @override
  String get searchInPosted => '我发过帖';

  @override
  String get searchInWatching => '我正在关注';

  @override
  String get searchInTracking => '我正在跟踪';

  @override
  String get searchInSeen => '我读过';

  @override
  String get searchInUnseen => '我还没读过';

  @override
  String get searchSortLatestPost => '最新帖子';

  @override
  String get searchSortMostLiked => '赞最多';

  @override
  String get searchSortMostViewed => '浏览最多';

  @override
  String get searchSortLatestTopic => '最新话题';

  @override
  String get searchFieldHint => '搜索…';

  @override
  String get bookmarksUnavailable => '书签不可用';

  @override
  String get failedToLoadBookmarks => '无法加载书签';

  @override
  String get failedToRemoveBookmark => '无法移除书签';

  @override
  String get failedToUpdateBookmark => '无法更新书签';

  @override
  String get bookmarkWithReminder => '带提醒的书签';

  @override
  String get noReminder => '无提醒';

  @override
  String get failedToLoadDrafts => '无法加载草稿。';

  @override
  String get failedToDiscardDraft => '无法丢弃草稿';

  @override
  String get messagesLoadFailed => '无法加载消息';

  @override
  String get moreMessagesLoadFailed => '无法加载更多消息';

  @override
  String get messageUnknownUser => '未知';

  @override
  String get unknownErrorFallback => '未知错误';

  @override
  String get chatComposerDefaultHint => '输入消息…';

  @override
  String chatChannelNumbered(Object id) {
    return '频道 $id';
  }

  @override
  String get chatSendFailed => '消息发送失败。';

  @override
  String get chatEditFailed => '消息编辑失败。';

  @override
  String get chatDeleteFailed => '消息删除失败。';

  @override
  String get chatReactionsUnsupported => '此处不支持回应。';

  @override
  String get chatReactionFailed => '回应更新失败。';

  @override
  String get attachmentDefaultName => '附件';

  @override
  String get fileTypeAudio => '音频';

  @override
  String get fileTypeText => '文本';

  @override
  String get fileTypeArchive => '压缩包';

  @override
  String get fileTypeFile => '文件';

  @override
  String downloadFailedHttpStatus(String status) {
    return '文件下载失败：HTTP $status';
  }

  @override
  String get downloadedFileEmpty => '下载的文件为空';

  @override
  String downloadFileFailed(String error) {
    return '文件下载失败：$error';
  }

  @override
  String attachmentTypeNotAllowed(String extension, String allowed) {
    return '不允许 .$extension 文件类型。允许的类型：$allowed';
  }

  @override
  String attachmentFileTooLarge(String size, String max) {
    return '文件大小（$size）超过上限 $max';
  }

  @override
  String get attachmentValidationFailed => '文件验证失败';

  @override
  String get uploadMissingReference => '上传成功，但服务器未返回该文件的引用。';

  @override
  String get imageFileNotFound => '未找到图片文件';

  @override
  String get failedToLoadVideo => '无法加载视频';

  @override
  String get userInfoLoadFailed => '无法加载用户信息。';

  @override
  String userInfoLoadFailedWithError(String error) {
    return '无法加载用户信息：$error';
  }

  @override
  String get profileMenuIgnoreUser => '忽略用户';

  @override
  String get profileMenuUnignoreUser => '取消忽略用户';

  @override
  String get ignoreStateUpdateFailed => '无法更新忽略状态';

  @override
  String profileNowIgnoringUser(String username) {
    return '你正在忽略 @$username。其帖子将被隐藏。';
  }

  @override
  String get profileIgnoreToggleFailed => '切换忽略失败。';

  @override
  String get profileStatsLoadFailed => '无法加载统计数据。';

  @override
  String get profileFollowFailed => '关注失败';

  @override
  String get profileUnfollowFailed => '取消关注失败';

  @override
  String get profileChatOpenFailed => '无法与此用户开始聊天。';

  @override
  String summaryLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个赞',
    );
    return '$_temp0';
  }

  @override
  String summaryLinkClicks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次点击',
    );
    return '$_temp0';
  }

  @override
  String get directoryPeriodAllTime => '所有时间';

  @override
  String get directoryPeriodYear => '年';

  @override
  String get directoryPeriodQuarter => '季度';

  @override
  String get directoryPeriodMonth => '月';

  @override
  String get directoryPeriodWeek => '周';

  @override
  String get directoryPeriodToday => '今天';

  @override
  String get directoryOrderReceived => '已收到';

  @override
  String get directoryOrderReplies => '回复';

  @override
  String get directoryOrderTopics => '话题';

  @override
  String get directoryOrderVisits => '访问天数';

  @override
  String get directoryLoadFailed => '无法加载用户列表。';

  @override
  String get directoryNoUsersMatch => '没有与该名称匹配的用户。';

  @override
  String get directoryNoUsersForPeriod => '此时间段内没有找到用户。';

  @override
  String get userSearchNoResults => '未找到用户';

  @override
  String get userSearchTryDifferentUsername => '请尝试使用其他用户名搜索';

  @override
  String get userSearchPromptTitle => '搜索用户';

  @override
  String get userSearchPromptHint => '输入用户名以查找并邀请用户';

  @override
  String get ignoredUsersUnignoreFailed => '取消忽略失败。';

  @override
  String get ignoredUsersEmpty => '你没有忽略任何人。';

  @override
  String get ignoredUsersEmptyHint => '打开用户的个人资料，在菜单中选择“忽略用户”，即可隐藏其帖子和通知。';

  @override
  String get badgesLoadFailed => '无法加载徽章。';

  @override
  String get badgesEmpty => '此论坛没有徽章。';

  @override
  String get badgeTierGold => '金牌';

  @override
  String get badgeTierSilver => '银牌';

  @override
  String get badgeTierBronze => '铜牌';

  @override
  String badgeEarnedAgo(String time) {
    return '$time获得';
  }

  @override
  String badgeEarnedByUsers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted 位用户已获得',
    );
    return '$_temp0';
  }

  @override
  String get trustLevelNameNewUser => '新用户';

  @override
  String get trustLevelNameBasic => '基本用户';

  @override
  String get trustLevelNameMember => '成员';

  @override
  String get trustLevelNameRegular => '活跃用户';

  @override
  String get trustLevelNameLeader => '领导者';

  @override
  String get trustLevelSummary0 => '刚刚加入。可以阅读和发帖，但链接、图片和消息受限。';

  @override
  String get trustLevelSummary1 => '解锁核心发帖功能：图片和附件、更多链接、举报帖子。';

  @override
  String get trustLevelSummary2 => '可以发送邀请、忽略用户，并能在更长时间内编辑自己的帖子。';

  @override
  String get trustLevelSummary3 => '可以更改话题的类别和标题、创建标签，其垃圾信息举报的权重更高。';

  @override
  String get trustLevelSummary4 => '由管理人员授予。可以编辑任何帖子，并置顶、关闭、拆分或合并话题。';

  @override
  String trustLevelRowTitle(int level, String name) {
    return 'TL$level · $name';
  }

  @override
  String get profileNoUserSpecified => '未指定用户';

  @override
  String get userTopicsLoadFailed => '无法加载话题';

  @override
  String get userTopicsEmpty => '尚未创建任何话题。';

  @override
  String get userRecentPostsLoadFailed => '无法加载最近的帖子';

  @override
  String get activityUnknownTopic => '未知话题';

  @override
  String groupJoinedSnack(String group) {
    return '你已加入 $group';
  }

  @override
  String get groupJoinFailed => '加入群组失败';

  @override
  String groupLeftSnack(String group) {
    return '你已退出 $group';
  }

  @override
  String get groupLeaveFailed => '退出群组失败';

  @override
  String get groupMembershipRequestHint => '你为什么想加入？群组所有者会在你的申请中看到这段说明。';

  @override
  String get groupMembershipReasonRequired => '申请加入需要填写理由';

  @override
  String get groupMembershipRequestSent => '申请已发送，需要群组所有者批准';

  @override
  String get groupMembershipRequestFailed => '发送加入申请失败';

  @override
  String get groupMemberBadge => '成员';

  @override
  String get groupRequestPending => '申请待处理';

  @override
  String get groupJoining => '正在加入…';

  @override
  String get groupJoinButton => '加入群组';

  @override
  String get groupsLoadFailed => '无法加载群组。';

  @override
  String get groupBuiltIn => '内置群组';

  @override
  String invitesPendingWithCount(int count) {
    return '待处理 ($count)';
  }

  @override
  String invitesExpiredWithCount(int count) {
    return '已过期 ($count)';
  }

  @override
  String invitesRedeemedWithCount(int count) {
    return '已确认 ($count)';
  }

  @override
  String get invitesLoadFailed => '无法加载邀请。';

  @override
  String get inviteLinkCreateFailed => '无法创建邀请链接';

  @override
  String get inviteEmailAddressLabel => '电子邮件地址';

  @override
  String get inviteEmailInvalid => '请输入有效的电子邮件地址';

  @override
  String get inviteMessageOptionalLabel => '消息（可选）';

  @override
  String get inviteSendFailed => '无法发送邀请';

  @override
  String get revokeInviteLinkWarning => '该邀请链接将失效。';

  @override
  String revokeInviteEmailWarning(String email) {
    return '发送给 $email 的邀请将失效。';
  }

  @override
  String get inviteRevokeFailed => '无法撤销邀请';

  @override
  String get inviteNoPermission => '你没有邀请的权限';

  @override
  String get invitesEmptyPending => '没有待处理的邀请';

  @override
  String get invitesEmptyExpired => '没有已过期的邀请';

  @override
  String get invitesEmptyRedeemed => '没有已确认的邀请';

  @override
  String get invitesEmptyPendingHint => '创建邀请链接，邀请大家来论坛。';

  @override
  String get inviteLinkFallbackTitle => '邀请链接';

  @override
  String inviteRedeemedOn(String date) {
    return '$date 已确认';
  }

  @override
  String inviteRedemptions(int count, int max) {
    return '已确认 $count/$max';
  }

  @override
  String get inviteEmailSent => '邮件已发送';

  @override
  String get inviteEmailNotSent => '邮件未发送';

  @override
  String inviteExpiredOn(String date) {
    return '已于 $date 过期';
  }

  @override
  String get inviteRevokeTooltip => '撤销邀请';

  @override
  String get reviewStatusPending => '待处理';

  @override
  String get reviewStatusApproved => '已批准';

  @override
  String get reviewStatusRejected => '已拒绝';

  @override
  String get reviewStatusAll => '一切';

  @override
  String get reviewStatusIgnored => '举报已忽略';

  @override
  String get reviewStatusDeleted => '话题或帖子已删除';

  @override
  String get reviewQueueUnavailable => '此论坛不提供审核队列。';

  @override
  String get reviewQueueLoadFailed => '无法加载审核队列';

  @override
  String get reviewableChangedByOther => '此项目已被其他版主更改。正在刷新…';

  @override
  String get reviewActionFailed => '无法执行操作';

  @override
  String reviewActionDone(String action) {
    return '$action：已完成';
  }

  @override
  String get reviewRejectReasonHint => '为什么要拒绝？';

  @override
  String get reviewTypeFlaggedPost => '被举报的帖子';

  @override
  String get reviewTypeQueuedPost => '已加入队列的帖子';

  @override
  String get reviewTypeQueuedTopic => '已加入队列的话题';

  @override
  String get reviewTypeUser => '用户';

  @override
  String get reviewTypePost => '帖子';

  @override
  String get reviewTypeChatMessage => '被举报的聊天消息';

  @override
  String get reviewModeratorAccessRequired => '需要版主权限';

  @override
  String reviewableScore(String score) {
    return '分数 $score';
  }

  @override
  String get postRepliesLoadFailed => '无法加载回复。';

  @override
  String get postMakeWiki => '设为 Wiki';

  @override
  String get postRemoveWiki => '移除 Wiki';

  @override
  String get postBookmarkRemoveFailed => '移除书签失败';

  @override
  String get postBookmarkFailed => '将帖子加入书签失败';

  @override
  String get postBookmarkReminderUpdateFailed => '更新提醒失败';

  @override
  String get postBookmarkReminderSet => '提醒已设置';

  @override
  String get postBookmarkReminderCleared => '提醒已清除';

  @override
  String get solutionMarkFailed => '标记为解决方案失败';

  @override
  String get solutionUnmarkFailed => '取消标记解决方案失败';

  @override
  String get postUnknownDate => '日期未知';

  @override
  String get postBookmarkAction => '将帖子加入书签';

  @override
  String postReactionsSemanticsReacted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '你已做出反应。$count 个反应。点按可更改，长按可查看谁做出了反应。',
    );
    return '$_temp0';
  }

  @override
  String postReactionsSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个反应。点按可做出反应，长按可查看谁做出了反应。',
    );
    return '$_temp0';
  }

  @override
  String get postLikeAction => '点赞帖子';

  @override
  String get postUnlikeAction => '取消点赞';

  @override
  String get postVoteRemoveFailed => '无法撤销投票（可能已超过撤销时限）';

  @override
  String get postVoteCastFailed => '投票失败';

  @override
  String get postUpvote => '投赞成票';

  @override
  String get postDownvote => '投反对票';

  @override
  String get pollVoteFailed => '投票失败。请重试。';

  @override
  String get pollRemoveVoteFailed => '无法撤销你的投票。请重试。';

  @override
  String get pollVotersLoadFailed => '无法加载投票者。';

  @override
  String get pollVotersNotVisible => '此投票的投票者不可见。';

  @override
  String solutionSolvedByInPost(String name, int postNumber) {
    return '由 $name 在帖子 #$postNumber 中解决';
  }

  @override
  String solutionMarkedBy(String name) {
    return '由 $name 标记';
  }

  @override
  String reactAgainInSeconds(int seconds) {
    return '$seconds 秒后可再次对此帖子做出反应';
  }

  @override
  String get reactionUpdateFailed => '无法更新反应。';

  @override
  String get reactionsNotSupported => '此论坛不支持反应。';

  @override
  String get reactionsLoadFailed => '无法加载反应。';

  @override
  String viewProfileOfUser(String username) {
    return '查看 $username 的个人资料';
  }

  @override
  String get failedToSavePost => '保存帖子失败';

  @override
  String failedToSavePostWithError(String error) {
    return '保存帖子失败：$error';
  }

  @override
  String get failedToRemoveAttachmentCheckPermissions => '删除附件失败。请检查您的权限。';

  @override
  String get editPostTitle => '编辑帖子';

  @override
  String get editYourPostHint => '编辑您的帖子...';

  @override
  String get failedToPostReply => '回复发布失败';

  @override
  String failedToPostReplyWithError(String error) {
    return '回复发布失败：$error';
  }

  @override
  String get failedToCreateTopic => '创建话题失败';

  @override
  String get writeYourTopicTitle => '编写您的话题标题...';

  @override
  String get writeYourTopicContent => '编写您的话题内容...';

  @override
  String get composerTitleHint => '编写您的标题...';

  @override
  String get composerContentHint => '编写您的内容...';

  @override
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit) {
    return '$fileName：文件过大（$size），且无法缩小。上限为 $limit。';
  }

  @override
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit) {
    return '$fileName 已缩小至 $size$dimensions，以符合 $limit 的上限。';
  }

  @override
  String get composerAttachFileHint => '为此帖子附加文件';

  @override
  String get composerUploadImageHint => '为此帖子上传图片';

  @override
  String get composerFormattingHint => '打开格式选项';

  @override
  String get whisperStaffOnly => '密语（仅限管理人员）';

  @override
  String get whisperOnStaffOnly => '密语已开启（仅限管理人员）';

  @override
  String get tagInputMaxReached => '已达到标签上限';

  @override
  String get tagInputAddTag => '添加标签…';

  @override
  String get tagInputAddAnother => '+ 标签';

  @override
  String get editHistoryUnavailable => '此论坛不提供编辑历史。';

  @override
  String get editHistoryLoadFailed => '加载编辑历史失败。';

  @override
  String get previousRevision => '上一个修订';

  @override
  String get nextRevision => '下一个修订';

  @override
  String get notificationPrefsLoadFailed => '无法加载通知偏好设置。';

  @override
  String get notificationPrefsSaveFailed => '无法保存 — 请检查网络连接';

  @override
  String get signInToManageNotificationPrefs => '登录以管理你的通知偏好设置。';

  @override
  String get emailWhenAwayTitle => '离开时发送邮件';

  @override
  String get emailLevelDescription =>
      '当我被引用、回复、我的用户名被提及 (@) 或当我关注的类别、标签或话题有新的活动时给我发送电子邮件';

  @override
  String get notificationPrefAlways => '始终';

  @override
  String get notificationPrefOnlyWhenAway => '只在离开时';

  @override
  String get notificationPrefNever => '从不';

  @override
  String get emailForMessagesTitle => '消息邮件通知';

  @override
  String get emailMessagesLevelDescription => '当我收到个人消息时给我发电子邮件';

  @override
  String get activitySummaryTitle => '活动总结';

  @override
  String get activitySummaryDescription => '当我不访问这里时，向我发送热门话题和回复的电子邮件总结';

  @override
  String get activitySummaryFrequencyTitle => '活动总结频率';

  @override
  String get activitySummaryDaily => '每天';

  @override
  String get activitySummaryWeekly => '每周';

  @override
  String get activitySummaryMonthly => '每月';

  @override
  String get mailingListModeTitle => '邮寄名单模式';

  @override
  String get mailingListModeDescription =>
      '每个帖子都通过电子邮件发给我（会停用活动总结）。不建议在高流量论坛上使用。';

  @override
  String get likeNotificationFrequencyTitle => '被赞时通知';

  @override
  String get likeNotificationFirstTimeAndDaily => '每日帖子第一次被赞';

  @override
  String get likeNotificationFirstTime => '帖子第一次被赞';

  @override
  String get whenPostingTitle => '发帖时';

  @override
  String get whenPostingDescription => '回复话题后如何处理该话题';

  @override
  String get whenPostingWatchTopic => '关注话题';

  @override
  String get whenPostingTrackTopic => '跟踪话题';

  @override
  String get whenPostingDoNothing => '不进行操作';

  @override
  String get pauseNotificationsUntilTomorrow => '直到明天';

  @override
  String get couldNotEnableDoNotDisturb => '无法开启请勿打扰';

  @override
  String get couldNotTurnOffDoNotDisturb => '无法关闭请勿打扰';

  @override
  String get passwordResetEmailSent => '已发送密码重置邮件。';

  @override
  String get couldNotSendResetEmail => '无法发送重置邮件';

  @override
  String get accountRequestFailed => '请求失败。';

  @override
  String get forumUrlUnavailable => '论坛网址不可用。';

  @override
  String get couldNotOpenPreferencesPage => '无法打开偏好设置页面。';

  @override
  String get couldNotOpenForumUrl => '无法打开论坛网址。';

  @override
  String get couldNotRequestEmailChange => '无法请求更改邮箱';

  @override
  String get newEmailLabel => '新电子邮件地址';

  @override
  String get enterAnEmailAddress => '请输入电子邮件地址';

  @override
  String get emailLooksInvalid => '这看起来不像电子邮件地址';

  @override
  String get emailNoSpaces => '电子邮件地址中不能有空格';

  @override
  String get allowNotificationsSheetTitle => '允许通知';

  @override
  String get notificationsGrantNoPayload => '授权未返回任何响应。';

  @override
  String get thisForumFallback => '此论坛';

  @override
  String signInToDomain(String domain) {
    return '登录 $domain';
  }

  @override
  String get loginResultTitle => '登录结果';

  @override
  String get invalidAuthenticationCode => '验证码无效';

  @override
  String get tfaVerificationError => '验证时出错。请重试。';

  @override
  String get passwordFieldLabel => '密码';

  @override
  String get somethingWentWrongTryAgain => '出了点问题。请重试。';

  @override
  String get unexpectedErrorTryAgain => '发生意外错误。请重试。';

  @override
  String get errorNoInternetConnection => '没有网络连接。请检查网络设置。';

  @override
  String get errorRequestTimedOut => '请求超时。请重试。';

  @override
  String get errorServerTryLater => '服务器出错。请稍后再试。';

  @override
  String get errorInvalidCredentials => '用户名或密码无效。';

  @override
  String get errorSessionExpired => '你的会话已过期。请重新登录。';

  @override
  String get errorAccountSuspended => '你的账户已被封禁。请联系论坛管理团队。';

  @override
  String get errorForumNotFound => '未找到论坛。';

  @override
  String get errorForumAccessDenied => '你没有访问此论坛的权限。';

  @override
  String get errorForumUnavailable => '论坛暂时不可用。请稍后再试。';

  @override
  String get errorDataNotFound => '未找到请求的数据。';

  @override
  String get errorDataCorrupted => '数据似乎已损坏。请刷新页面。';

  @override
  String get errorCacheLoadFailed => '无法加载缓存数据。请重试。';

  @override
  String errorInvalidField(String field) {
    return '提供的$field无效。';
  }

  @override
  String errorFieldRequired(String field) {
    return '$field为必填项。';
  }

  @override
  String errorPermissionDeniedFor(String action) {
    return '你没有权限：$action。';
  }

  @override
  String errorFeatureNotAvailable(String feature) {
    return '此论坛不支持$feature。';
  }

  @override
  String get errorStorageFull => '存储空间已满。请释放一些空间。';

  @override
  String get errorStorageAccessDenied => '存储访问被拒绝。请检查应用权限。';

  @override
  String get errorNetworkTryAgain => '发生网络错误。请重试。';

  @override
  String get errorAuthenticationTryAgain => '身份验证失败。请重试。';

  @override
  String get errorForumTryAgain => '论坛出错。请重试。';

  @override
  String get connectionErrorTitle => '连接错误';

  @override
  String get authenticationErrorTitle => '身份验证错误';

  @override
  String get forumErrorTitle => '论坛错误';

  @override
  String get permissionErrorTitle => '权限错误';

  @override
  String errorRemovingFromMessage(String name) {
    return '无法将 $name 从此消息中移除。';
  }
}
