// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Forum App';

  @override
  String get loginTitle => '登录';

  @override
  String get usernameLabel => '用户名';

  @override
  String get passwordLabel => '密码';

  @override
  String get loginButton => '登录';

  @override
  String get signInWithPasskey => 'Sign in with Passkey';

  @override
  String get usePasskey => 'Use Passkey';

  @override
  String get passkeyContinuePrompt => 'Use your passkey to continue';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get pleaseEnterUsername => '请输入您的用户名';

  @override
  String get pleaseEnterPassword => '请输入您的密码';

  @override
  String credentialsSentToDomain(String domain) {
    return '您的用户名和密码将发送到 $domain';
  }

  @override
  String get createAccount => '创建账户';

  @override
  String get alreadyHaveAccount => '已有账户？ ';

  @override
  String get logIn => '登录';

  @override
  String get continueButton => '继续';

  @override
  String get registrationNotAvailable => '注册不可用';

  @override
  String get registrationNotAvailableMessage => '目前无法注册。论坛可能已关闭或注册可能已禁用。';

  @override
  String get webRegistrationRequired => '需要网页注册';

  @override
  String get webRegistrationRequiredMessage => '此论坛需要通过网页浏览器注册。请点击下面的按钮打开注册页面。';

  @override
  String get openRegistrationPage => '打开注册页面';

  @override
  String get loadingAdditionalFields => '正在加载其他字段...';

  @override
  String get pleaseSelectDateOfBirth => '请选择您的出生日期';

  @override
  String get pleaseEnterLocation => '请输入您的位置';

  @override
  String get pleaseIndicateEmailPreference => '请指明您的电子邮件偏好';

  @override
  String get pleaseFillAllRequiredFields => '请填写所有必填字段';

  @override
  String get pleaseAcceptTermsOfService => '请接受服务条款';

  @override
  String get pleaseAcceptPrivacyPolicy => '请接受隐私政策';

  @override
  String get registrationError => '注册错误';

  @override
  String get registrationFailed => '注册失败。请检查您的信息。';

  @override
  String get registrationFailedTryAgain => '注册失败。请重试。';

  @override
  String get registrationInfo => '注册信息';

  @override
  String get openWebsite => '打开网站';

  @override
  String couldNotOpenForumWebsite(String url) {
    return '无法打开论坛网站。请尝试访问: $url';
  }

  @override
  String get registrationSuccessfulEmailConfirm => '注册成功！请在登录前检查您的电子邮件以确认您的账户。';

  @override
  String get registrationSuccessfulPendingApproval =>
      '注册成功！您的账户正在等待批准。您的账户获得批准后，您将收到通知。';

  @override
  String get registrationSuccessfulAutoLogin => '注册成功！您已自动登录。';

  @override
  String get welcome => '欢迎！';

  @override
  String get registrationSuccessful => '注册成功';

  @override
  String get pleaseLoginWithNewAccount => '请使用您的新账户登录。';

  @override
  String get forgotPasswordTitle => '忘记密码';

  @override
  String get usernameOrEmailLabel => '用户名或电子邮件';

  @override
  String get pleaseEnterUsernameOrEmail => '请输入您的用户名或电子邮件';

  @override
  String get sendResetLink => '发送重置链接';

  @override
  String get resetLinkSent => '重置链接已发送';

  @override
  String get passwordResetInstructionsSent => '密码重置说明已发送到您注册的电子邮件地址。';

  @override
  String get resetFailed => '重置失败';

  @override
  String get unableToSendResetLink => '无法发送重置链接。请重试。';

  @override
  String get errorSendingResetLink => '发送重置链接时发生错误。请检查您的连接并重试。';

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
  String get getHelp => '获取帮助';

  @override
  String get somethingWentWrong => '出现问题';

  @override
  String get unexpectedErrorOccurred => '发生意外错误。请重试。';

  @override
  String get noInternetConnection => '无互联网连接';

  @override
  String get checkInternetConnection => '请检查您的互联网连接并重试。';

  @override
  String get authenticationRequired => '需要身份验证';

  @override
  String get pleaseLoginToContinue => '请登录以继续。';

  @override
  String get forumError => '论坛错误';

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
  String get noLatestTopics => '无最新主题';

  @override
  String get noRecentTopicsToDisplay => '没有要显示的最新主题。稍后再来查看新讨论。';

  @override
  String get signInToViewLatestTopics => '登录以查看最新主题';

  @override
  String get youNeedToBeSignedInToViewLatestTopics => '您需要登录才能查看最新主题';

  @override
  String get noUnreadTopics => '无未读主题';

  @override
  String get thereAreNoUnreadTopics => '没有未读主题。稍后再来查看新讨论。';

  @override
  String get youAreAllCaughtUp => '您已全部查看完毕！';

  @override
  String get signInToViewUnreadTopics => '登录以查看未读主题';

  @override
  String get youNeedToBeSignedInToViewUnreadTopics => '您需要登录才能查看未读主题';

  @override
  String get noSubscribedTopics => '无订阅主题';

  @override
  String get noSubscribedTopicsMessage => '您没有订阅任何主题。点击主题上的星形按钮以订阅并接收新更新通知。';

  @override
  String get signInToViewSubscribedTopics => '登录以查看订阅主题';

  @override
  String get youNeedToBeSignedInToViewSubscribedTopics => '您需要登录才能查看订阅主题';

  @override
  String get noParticipatedTopics => '无参与主题';

  @override
  String get topicsYouParticipatedIn => '您参与的主题将显示在这里。';

  @override
  String get signInToViewParticipatedTopics => '登录以查看参与的主题';

  @override
  String get youNeedToBeSignedInToViewParticipatedTopics => '您需要登录才能查看您参与的主题';

  @override
  String get latest => '最新';

  @override
  String get unread => '未读';

  @override
  String get subscribed => '已订阅';

  @override
  String get participated => '已参与';

  @override
  String get connectionTimedOut => '连接超时。网站可能已关闭或无法访问。';

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
  String get newConversation => '新对话';

  @override
  String get newMessage => '新消息';

  @override
  String get appSettings => '应用设置';

  @override
  String get searchSites => '搜索网站';

  @override
  String get language => '语言';

  @override
  String get systemDefault => '系统默认';

  @override
  String get followSystemLanguage => '跟随系统语言';

  @override
  String get all => '全部';

  @override
  String get topicsOnly => '仅主题';

  @override
  String get titlesOnly => '仅标题';

  @override
  String failedToShareTopic(String error) {
    return '分享主题失败: $error';
  }

  @override
  String get pleaseLoginToSubscribe => '请登录以null此主题';

  @override
  String get subscribe => '订阅';

  @override
  String get unsubscribe => '取消订阅';

  @override
  String get failedToSubscribeToThread => '无法null主题';

  @override
  String get youCannotReplyToThisThread => '您无法回复此主题';

  @override
  String get pleaseWaitForThreadToLoad => '请等待主题加载';

  @override
  String get softDelete => '软删除';

  @override
  String get postCanBeRestoredLater => '帖子稍后可以恢复';

  @override
  String get hardDelete => '硬删除';

  @override
  String get postWillBePermanentlyDeleted => '帖子将被永久删除';

  @override
  String get reasonForDeletion => '删除原因';

  @override
  String get enterReasonForDeletingPost => '输入删除此帖子的原因';

  @override
  String get pleaseEnterReasonForDeletion => '请输入删除原因';

  @override
  String get reportPost => '举报帖子';

  @override
  String get pleaseProvideReasonForReporting => '请提供举报此帖子的原因。';

  @override
  String get reason => '原因';

  @override
  String get enterReasonForReportingPost => '输入举报此帖子的原因';

  @override
  String get pleaseEnterReason => '请输入原因';

  @override
  String get submitReport => '提交举报';

  @override
  String get selectedActions => '选定的操作:';

  @override
  String get thisActionCannotBeUndone => '此操作无法撤销。';

  @override
  String get participantsLabel => '参与者';

  @override
  String usernameHasBeenInvited(String username) {
    return '$username 已被邀请加入对话';
  }

  @override
  String errorInvitingUser(String error) {
    return '邀请用户时出错: $error';
  }

  @override
  String get newTopic => '新主题';

  @override
  String get markRead => '标记为已读';

  @override
  String get reportUser => '举报用户';

  @override
  String get pleaseSelectReasonForReportingUser => '请选择举报此用户的原因。';

  @override
  String get spamOrAdvertising => '垃圾邮件或广告';

  @override
  String get harassmentOrBullying => '骚扰或欺凌';

  @override
  String get inappropriateContent => '不当内容';

  @override
  String get impersonationOrFakeAccount => '冒充或虚假账户';

  @override
  String get otherPleaseSpecify => '其他（请说明）';

  @override
  String get pleaseSpecifyReason => '请说明原因';

  @override
  String get enterReasonForReportingUser => '输入举报此用户的原因';

  @override
  String get pleaseSelectReason => '请选择原因';

  @override
  String get banUser => '封禁用户';

  @override
  String get unbanUser => '解除封禁';

  @override
  String pleaseSelectReasonForBanningUser(String username) {
    return '请选择封禁 $username 的原因';
  }

  @override
  String get violationOfCommunityGuidelines => '违反社区准则';

  @override
  String get harassmentOrAbusiveBehavior => '骚扰或虐待行为';

  @override
  String get postingInappropriateContent => '发布不当内容';

  @override
  String get accountCompromiseOrSecurityIssue => '账户泄露或安全问题';

  @override
  String get enterReasonForBanningUser => '输入封禁此用户的原因';

  @override
  String get banUntil => '封禁至';

  @override
  String get selectDate => '选择日期';

  @override
  String get moreOptions => '更多选项';

  @override
  String get leaveConversation => '离开对话';

  @override
  String get reportConversation => '举报对话';

  @override
  String get topicClosed => '主题已关闭';

  @override
  String get topicOpened => '主题已打开';

  @override
  String get topicStickied => '主题已置顶';

  @override
  String get topicUnstickied => '主题已取消置顶';

  @override
  String cannotEditMessage(String error) {
    return '无法编辑此消息: $error';
  }

  @override
  String get confirmSpamClean => '确认清理垃圾邮件';

  @override
  String get handleThreads => '处理主题';

  @override
  String get deleteMessages => '删除消息';

  @override
  String get deleteConversations => '删除对话';

  @override
  String get myForums => '我的论坛';

  @override
  String get recentlyVisited => '最近访问';

  @override
  String get explore => '探索';

  @override
  String get forumCopilot => 'Forum Copilot';

  @override
  String get noConversations => '无对话';

  @override
  String get noConversationsMessage => '您还没有对话。开始新对话以开始发送消息。';

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
  String get spamCleaner => '垃圾清理';

  @override
  String get sendMessage => '发送消息';

  @override
  String get memberSince => '注册日期';

  @override
  String get lastActivity => '最后活动';

  @override
  String get likesReceived => '收到的赞';

  @override
  String get likesGiven => '给出的赞';

  @override
  String get showMore => '显示更多';

  @override
  String get cleanSpam => '清理垃圾信息';

  @override
  String get failedToSaveMessage => '保存消息失败';

  @override
  String get failedToSaveConversation => '保存对话失败';

  @override
  String get failedToSaveSetting => '保存设置失败';

  @override
  String get failedToSavePost => '保存帖子失败';

  @override
  String errorLoadingSites(String error) {
    return '加载网站错误: $error';
  }

  @override
  String connectingTo(String domainName) {
    return '正在连接到 $domainName...';
  }

  @override
  String get members => '成员';

  @override
  String get allMembers => '所有成员';

  @override
  String get online => '在线';

  @override
  String get noMembersFound => '未找到成员';

  @override
  String get searchForMembers => '搜索成员';

  @override
  String get enterUsernameToFindMembers => '输入用户名以查找论坛成员';

  @override
  String get noMembersOnline => '当前没有成员在线';

  @override
  String get enterUsernameToSearch => '输入用户名以搜索...';

  @override
  String get lookupMembers => '查找成员';

  @override
  String get addMembers => '添加成员';

  @override
  String get membersAddedSuccessfully => '成员已成功添加';

  @override
  String errorAddingMembers(String error) {
    return '添加成员时出错: $error';
  }

  @override
  String get failedToLoadOnlineUsers => '加载在线用户失败';

  @override
  String get noUsersOnline => '没有用户在线';

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
  String get register => '注册';

  @override
  String get signIn => '登录';

  @override
  String get markForumRead => '标记论坛为已读';

  @override
  String get notificationTest => '通知测试';

  @override
  String get forum => '论坛';

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
  String get areYouSureYouWantToDeleteThisMessage => '您确定要删除此消息吗？';

  @override
  String failedToDeleteMessage(String error) {
    return '删除消息失败: $error';
  }

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
  String failedToThankPost(String error) {
    return '感谢帖子失败: $error';
  }

  @override
  String get signInToViewMessages => '请登录以查看消息';

  @override
  String get youNeedToBeSignedInToViewConversations => '您需要登录才能查看您的对话。';

  @override
  String errorLoadingConversations(String error) {
    return '加载对话错误: $error';
  }

  @override
  String failedToLeaveConversation(String error) {
    return '离开对话失败: $error';
  }

  @override
  String errorLoadingMoreConversations(String error) {
    return '加载更多对话错误: $error';
  }

  @override
  String errorLoadingMoreMessages(String error) {
    return '加载更多消息时出错: $error';
  }

  @override
  String get inviteMessageOptional => '邀请消息（可选）';

  @override
  String get iWouldLikeToAddYouToThisConversation => '我想将您添加到此对话中。';

  @override
  String get searchFailed => '搜索失败';

  @override
  String get trySearchingWithDifferentUsername => '尝试使用不同的用户名搜索';

  @override
  String get noSitesFound => '未找到网站。';

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
  String get permanent => '永久';

  @override
  String get temporary => '临时';

  @override
  String setBanDurationFor(String username) {
    return '设置 $username 的封禁期限';
  }

  @override
  String get pleaseSelectEndDateForTemporaryBan => '请选择临时封禁的结束日期';

  @override
  String get back => '返回';

  @override
  String get unban => '解除封禁';

  @override
  String get confirm => '确认';

  @override
  String spamClean(String username) {
    return '清理 $username 的垃圾邮件';
  }

  @override
  String get selectActionsToPerform => '选择要执行的操作:';

  @override
  String get moveOrDeleteThreadsBasedOnAdminSettings => '根据管理员设置移动或删除主题';

  @override
  String get messageUpdatedSuccessfully => '消息更新成功';

  @override
  String error(String error) {
    return '错误: $error';
  }

  @override
  String failedToRemoveAttachment(String error) {
    return '删除附件失败: $error';
  }

  @override
  String failedToLoadMessage(String error) {
    return '加载消息失败: $error';
  }

  @override
  String get editMessage => '编辑消息';

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
  String get welcomeBack => '欢迎回来！';

  @override
  String get signInToAccessYourProfile => '登录以访问您的资料并管理您的账户';

  @override
  String get enterYourUsername => '输入您的用户名';

  @override
  String get enterYourPassword => '输入您的密码';

  @override
  String get dontHaveAnAccount => '没有账户？';

  @override
  String get enterKeywordsToSearchTopics => '输入关键词以搜索主题...';

  @override
  String get pleaseFillInAllRequiredFields => '请填写所有必填字段';

  @override
  String get undelete => '恢复';

  @override
  String get refresh => '刷新';

  @override
  String get share => '分享';

  @override
  String get viewOnWeb => '在网页中查看';

  @override
  String get unlock => '解锁';

  @override
  String get lock => '锁定';

  @override
  String get stick => '置顶';

  @override
  String get unstick => '取消置顶';

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
  String get enterKeywordsToFindTopicsAndPosts => '输入关键词以查找主题和帖子';

  @override
  String get enterKeywordsOrDomainToFindForums => '输入关键词或域名以查找论坛';

  @override
  String get enterKeywordsOrDomainNamesToFindForums => '输入关键词或域名以查找论坛';

  @override
  String get appearance => '外观';

  @override
  String get followSystemTheme => '跟随系统主题';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String version(String version, String buildNumber) {
    return '版本 $version ($buildNumber)';
  }

  @override
  String get forumSettings => '论坛设置';

  @override
  String get noSettingsAvailable => '没有可用设置';

  @override
  String get settingsCategoriesWillAppearHere => '设置类别在可用时将显示在此处。';

  @override
  String get unableToLoadProfile => '无法加载个人资料';

  @override
  String get banned => '已封禁';

  @override
  String get reportSubmittedSuccessfully => '举报提交成功';

  @override
  String get failedToSubmitReport => '提交举报失败';

  @override
  String get searchForForums => '搜索论坛';

  @override
  String get searchForums => '搜索论坛';

  @override
  String get deleteTopic => '删除主题';

  @override
  String get topicCanBeRestoredLater => '主题可以稍后恢复';

  @override
  String get topicWillBePermanentlyDeleted => '主题将被永久删除';

  @override
  String get enterReasonForDeletingTopic => '输入删除此主题的原因';

  @override
  String get pleaseSelectEndDate => '请选择结束日期';

  @override
  String get userBannedSuccessfully => '用户封禁成功';

  @override
  String get failedToBanUser => '封禁用户失败';

  @override
  String get userUnbannedSuccessfully => '用户解封成功';

  @override
  String get failedToUnbanUser => '解封用户失败';

  @override
  String get spamCleanUser => '清理用户垃圾信息';

  @override
  String get deletePrivateConversations => '删除私密对话';

  @override
  String get banTheUserAccount => '封禁用户账户';

  @override
  String get handledThreads => '已处理的线程';

  @override
  String get deletedMessages => '已删除的消息';

  @override
  String get deletedConversations => '已删除的对话';

  @override
  String get bannedUser => '已封禁的用户';

  @override
  String successfullyCleanedSpam(String username, String actions) {
    return '成功清理 $username 的垃圾信息。操作: $actions';
  }

  @override
  String errorLoadingMessage(String error) {
    return '加载消息时出错: $error';
  }

  @override
  String get messageNotFound => '未找到消息';

  @override
  String get home => '首页';

  @override
  String get notifications => '通知';

  @override
  String get forums => '论坛';

  @override
  String get markAllForumsAsRead => '将所有论坛标记为已读？';

  @override
  String get markAllForumsAsReadMessage => '这将把所有论坛和主题标记为已读。此操作无法撤销。';

  @override
  String get markAsRead => '标记为已读';

  @override
  String get content => '内容';

  @override
  String get insertImage => '插入图片';

  @override
  String get howWouldYouLikeToInsertImage => '您想如何插入此图片？';

  @override
  String get thumbnail => '缩略图';

  @override
  String get fullSize => '完整尺寸';

  @override
  String get alignLeft => '左对齐';

  @override
  String get alignCenter => '居中对齐';

  @override
  String get alignRight => '右对齐';

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
  String get loggingIn => '登录中...';

  @override
  String get submittingReport => '提交报告中...';

  @override
  String get banningUser => '封禁用户中...';

  @override
  String get unbanningUser => '解封用户中...';

  @override
  String get cleaningSpam => '清理垃圾信息中...';

  @override
  String get enterSubject => '输入主题';

  @override
  String get typeYourMessageHere => '在此输入您的消息';

  @override
  String get writeYourMessage => '编写您的消息...';

  @override
  String get writeYourReply => '编写您的回复...';

  @override
  String get messageSentSuccessfully => '消息发送成功';

  @override
  String get replySentSuccessfully => '回复发送成功';

  @override
  String get conversationCreatedSuccessfully => '对话创建成功';

  @override
  String get conversationMarkedAsUnread => '对话已标记为未读';

  @override
  String get messageMarkedAsUnread => '消息已标记为未读';

  @override
  String get conversationClosed => '对话已关闭';

  @override
  String get conversationOpened => '对话已打开';

  @override
  String get pleaseLoginToLikeMessages => '请登录以点赞消息';

  @override
  String get loadEarlierMessages => '加载更早的消息';

  @override
  String failedToLoadQuote(String error) {
    return '加载引用失败: \n$error';
  }

  @override
  String failedToUploadFile(String error) {
    return '上传文件失败: $error';
  }

  @override
  String failedToUploadImage(String error) {
    return '上传图片失败: $error';
  }

  @override
  String failedToSendMessage(String error) {
    return '发送消息失败: $error';
  }

  @override
  String failedToSendReply(String error) {
    return '发送回复失败: $error';
  }

  @override
  String failedToMarkAsUnread(String error) {
    return '标记消息为未读失败: $error';
  }

  @override
  String failedToMarkConversationAsUnread(String error) {
    return '标记对话为未读失败: $error';
  }

  @override
  String failedToCloseConversation(String error) {
    return '关闭对话失败: $error';
  }

  @override
  String failedToOpenConversation(String error) {
    return '打开对话失败: $error';
  }

  @override
  String failedToJumpToMessage(String error) {
    return '跳转到消息失败: $error';
  }

  @override
  String get goToTop => '返回顶部';

  @override
  String get goToBottom => '跳到底部';

  @override
  String get replyAll => '全部回复';

  @override
  String get forward => '转发';

  @override
  String get noForumsFound => '未找到论坛。';

  @override
  String get pleaseLoginToAccessContent => '请登录以访问此内容并与帖子互动。';

  @override
  String get searchUsers => '搜索用户...';

  @override
  String get writeYourTitle => '编写您的标题...';

  @override
  String get writeYourContent => '编写您的内容...';

  @override
  String get selectAnOption => '选择选项';

  @override
  String get enterConversationTitle => '输入对话标题';

  @override
  String enterCode(int count) {
    return '输入$count位代码';
  }

  @override
  String get edit => '编辑';

  @override
  String get report => '举报';

  @override
  String get unfollow => '取消关注';

  @override
  String get follow => '关注';

  @override
  String get goToForums => '前往论坛';

  @override
  String get remove => '删除';

  @override
  String get subject => '主题';

  @override
  String get message => '消息';

  @override
  String get titleCannotBeEmpty => '标题不能为空';

  @override
  String get conversationUpdatedSuccessfully => '对话更新成功';

  @override
  String get goBack => '返回';

  @override
  String get privateMessagesNotAvailable => '私信不可用';

  @override
  String failedToLoadPost(String error) {
    return '加载帖子失败: \n$error';
  }

  @override
  String failedToLikeOrUnlikeMessage(String action, String error) {
    return '对消息$action失败: $error';
  }

  @override
  String get like => '点赞';

  @override
  String get unlike => '取消点赞';

  @override
  String get optimizeImage => '优化图片';

  @override
  String get optimizeAndUpload => '优化并上传';

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
  String get enterANumber => '输入数字';

  @override
  String get failedToNavigateToForum => '导航到论坛失败';

  @override
  String failedToNavigateToForumName(String forumName) {
    return '导航到$forumName失败';
  }

  @override
  String forumNotFound(String forumName) {
    return '未找到论坛: $forumName';
  }

  @override
  String forumNotFoundById(String forumId) {
    return '未找到论坛: $forumId';
  }

  @override
  String couldNotOpenLink(String error) {
    return '无法打开链接: $error';
  }

  @override
  String get likePost => '点赞帖子';

  @override
  String get unlikePost => '取消点赞';

  @override
  String get thankPost => '感谢帖子';

  @override
  String get showLikes => '显示点赞';

  @override
  String get showThanks => '显示感谢';

  @override
  String get quotePost => '引用帖子';

  @override
  String get translate => '翻译';

  @override
  String get showOriginal => '显示原文';

  @override
  String get translating => '翻译中...';

  @override
  String get translated => '已翻译';

  @override
  String get translatedContent => '翻译内容';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get translateTo => '翻译为:';

  @override
  String get deviceLanguage => '设备语言';

  @override
  String get noPostsToTranslate => '没有可翻译的帖子';

  @override
  String get translationFailed => '翻译失败';

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
  String nVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 票',
    );
    return '$_temp0';
  }

  @override
  String get lastSeen => '最后访问';

  @override
  String get chat => '聊天';

  @override
  String comingSoon(String label) {
    return '$label — 即将推出';
  }

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
  String get discardDraftQuestion => '放弃草稿？';

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
  String get failedToLoadMoreTopics => '无法加载更多主题。滚动以重试。';

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
  String get mergeIntoTopic => '合并到主题';

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
  String get renameTopic => '重命名主题';

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
  String get retryConnection => '重试连接';

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
  String get signOutQuestion => '退出登录？';

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
  String get submit => '提交';

  @override
  String get discardDraftWarning => '已保存的草稿将被永久删除。';

  @override
  String get deleteChatMessageWarning => '此消息将对所有人删除。';

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
  String get loginInfo => 'Login Info';

  @override
  String get loginFailed => 'Login Failed';

  @override
  String get additionalInformation => 'Additional Information';

  @override
  String dateOfBirth(Object marker) {
    return 'Date of Birth$marker';
  }

  @override
  String minimumAgeYears(Object minimumAge) {
    return 'Minimum age: $minimumAge years';
  }

  @override
  String locationLabel(Object marker) {
    return 'Location$marker';
  }

  @override
  String get receiveSiteMailings => 'Receive site mailings';

  @override
  String get moveToCategory => 'Move to category';

  @override
  String get undeleteTopic => 'Undelete Topic';

  @override
  String get undeleteTopicConfirmation =>
      'Are you sure you want to undelete this topic? It will be visible to other users again.';

  @override
  String get send => 'Send';

  @override
  String get changeEmailExplanation =>
      'We’ll send a confirmation link to your new email. The change takes effect when you click it.';

  @override
  String get changeEmailSecurityNote =>
      'For added security, Discourse may require you to confirm via the link in the email. Check your spam folder if you don’t see it.';

  @override
  String get newDirectMessage => 'New direct message';

  @override
  String get noMessagesYetSayHi => 'No messages yet — say hi.';

  @override
  String get edited => 'edited';

  @override
  String get imageExceedsUploadLimits =>
      'This image exceeds the upload limits and needs to be optimized:';

  @override
  String get optimizationsToBeApplied => 'Optimizations to be applied:';

  @override
  String reductionPercent(Object percent) {
    return 'Reduction: $percent%';
  }

  @override
  String get editProfileManagedOnWebNote =>
      'Display name, email, password, and other account settings are managed under Account → Manage account on web. Your avatar can be changed by tapping the camera badge on your photo.';

  @override
  String get approvedButRelayUnreachable =>
      'Approved, but we could not reach ForumCopilot to finish setting up. Try again later from Settings.';

  @override
  String get notificationsAreTurnedOffForThisApp =>
      'Notifications are turned off for this app';

  @override
  String forumWillAskToApproveNotifications(Object forumName) {
    return 'Next, $forumName will ask you to approve “Notifications”.';
  }

  @override
  String get approveNotificationsExplanation =>
      'Approving lets us check your notifications for you and send them to this device. This permission cannot post, reply, or read your messages.';

  @override
  String get forumOwnerPushNote =>
      'If this forum’s owner sets up notifications for the app, this step won’t be needed.';

  @override
  String get pleaseLoginToCreateANewTopic =>
      'Please login to create a new topic';

  @override
  String get pleaseLoginToSubscribeToForums =>
      'Please login to subscribe to forums';

  @override
  String leaveGroupWarning(Object group) {
    return 'You will no longer be a member of $group. You can rejoin at any time.';
  }

  @override
  String get groupMembersPrivate => 'The member list of this group is private.';

  @override
  String get unignore => 'Unignore';

  @override
  String get inviteLinkCreated => 'Invite link created';

  @override
  String expiresOn(Object date) {
    return 'Expires $date';
  }

  @override
  String get protected => 'Protected';

  @override
  String get solution => 'Solution';

  @override
  String get deleted => 'DELETED';

  @override
  String get pleaseLoginToViewUserProfiles =>
      'Please login to view user profiles.';

  @override
  String get announcement => 'Announcement';

  @override
  String get solved => 'Solved';

  @override
  String get hot => 'Hot';

  @override
  String get pinned => 'Pinned';

  @override
  String get subscribedLabel => 'Subscribed';

  @override
  String get locked => 'Locked';

  @override
  String get poll => 'Poll';

  @override
  String errorLoadingContent(Object error) {
    return 'Error loading content: $error';
  }

  @override
  String get noPermissionToViewSubforum =>
      'You do not have permission to view topics in this subforum.';

  @override
  String get noDiscussionsYet => 'No discussions yet.';

  @override
  String get jumpToPost => 'Jump to Post';

  @override
  String get jump => 'Jump';

  @override
  String get endOfTheDiscussion => 'End of the discussion';

  @override
  String get reviewQueueStaffOnly =>
      'Only staff and reviewers can see the review queue.';

  @override
  String get nothingToReview => 'Nothing to review';

  @override
  String refreshFailed(Object error) {
    return 'Refresh failed: $error';
  }

  @override
  String get topicDeletedBanner =>
      'This topic is deleted and hidden from other users';

  @override
  String get topicClosedBanner =>
      'This topic is closed and no longer accepting replies';

  @override
  String get topicPinnedBanner =>
      'This topic is pinned to the top of the forum';

  @override
  String get youAreSubscribedToThisTopic => 'You are subscribed to this topic';

  @override
  String get refreshing => 'Refreshing...';

  @override
  String get title => 'Title';

  @override
  String editedAt(Object time) {
    return 'Edited $time';
  }

  @override
  String editReason(Object reason) {
    return 'Reason: $reason';
  }

  @override
  String get thisDiffIsTooLargeToDisplay =>
      'This diff is too large to display.';

  @override
  String get noContentChangesInThisRevision =>
      'No content changes in this revision.';

  @override
  String revisionOf(Object currentVersion, Object versionCount) {
    return 'Revision $currentVersion of $versionCount';
  }

  @override
  String get editConversation => 'Edit conversation';

  @override
  String get closeConversation => 'Close conversation';

  @override
  String get openConversation => 'Open conversation';

  @override
  String get leaveConversation2 => 'Leave conversation';

  @override
  String get reportConversation2 => 'Report conversation';

  @override
  String get closeConversation2 => 'Close Conversation';

  @override
  String get closeConversationConfirmation =>
      'Are you sure you want to close this conversation? This will prevent new replies from being posted.';

  @override
  String get close => 'Close';

  @override
  String get openConversation2 => 'Open Conversation';

  @override
  String get openConversationConfirmation =>
      'Are you sure you want to open this conversation? This will allow new replies to be posted.';

  @override
  String get open => 'Open';

  @override
  String get leaveConversation3 => 'Leave Conversation';

  @override
  String get leaveConversationConfirmation =>
      'Are you sure you want to leave this conversation? This will hide it from your inbox.';

  @override
  String errorLoadingConversation(Object error) {
    return 'Error loading conversation: $error';
  }

  @override
  String get conversationNotFound => 'Conversation not found';

  @override
  String get conversationClosedBanner =>
      'This conversation is closed and no longer accepting replies';

  @override
  String get noMessagesFound => 'No messages found';

  @override
  String get endOfConversation => 'End of conversation';

  @override
  String get jumpToMessage => 'Jump to Message';

  @override
  String get editConversation2 => 'Edit Conversation';

  @override
  String get failedToLoadMessage2 => 'Failed to load message';

  @override
  String get cannotEditThisConversation => 'Cannot edit this conversation';

  @override
  String get options => 'Options';

  @override
  String get conversationOpen => 'Conversation Open';

  @override
  String failedToCreateConversation(Object error) {
    return 'Failed to create conversation: $error';
  }

  @override
  String maximumAttachmentsAllowed(Object count) {
    return 'Maximum of $count attachment(s) allowed';
  }

  @override
  String get noImagesFoundToDisplay => 'No images found to display.';

  @override
  String get pleaseLoginToViewThisAttachment =>
      'Please login to view this attachment';

  @override
  String get searchForTopics => 'Search for topics';

  @override
  String get noTopicsFound => 'No topics found';

  @override
  String get trySearchingWithDifferentKeywords =>
      'Try searching with different keywords';

  @override
  String get noPostsFound => 'No posts found';

  @override
  String get perTopicNotificationLevelsNote =>
      'Per-category and per-topic notification levels are set from those screens directly — tap the bell icon on any topic or category to override.';

  @override
  String get pushNotActiveForThisLogin =>
      'Not active for this login — log out and log back in to authorize push notifications';

  @override
  String get pauseNotificationsFor => 'Pause notifications for…';

  @override
  String get doNotDisturbExplanation =>
      'Pause notifications for a while — Discourse holds them until the window ends';

  @override
  String get emailSettingsSubtitle =>
      'Email frequency, like aggregation, digest schedule';

  @override
  String get manageAccountSubtitle =>
      'Profile, email, password, security, advanced settings';

  @override
  String get changePasswordSubtitle =>
      'Trigger a password-reset email to your current address';

  @override
  String get ignoredUsersSubtitle =>
      'See and manage users whose posts are hidden from you';

  @override
  String get deleteAccountExplanation =>
      'Removing your account is handled on the forum. Continue to open the site and contact the staff team — Discourse forums process deletions per their own policy.';

  @override
  String get verificationEmailSent =>
      'Verification email sent — click the link to confirm your new address.';

  @override
  String get passwordResetExplanation =>
      'We’ll email you a password-reset link. Click it to choose a new password — the change is handled on the forum, not in this app.';

  @override
  String get sendResetEmail => 'Send reset email';

  @override
  String get deleteAccountDialogBody =>
      'Your account is managed by the forum. Please contact the forum staff directly to request account removal. Continue will open the forum in your browser so you can use the site’s own contact / staff message flow.';

  @override
  String get initializingForum => 'Initializing forum…';

  @override
  String get unableToLoadForums => 'Unable to Load Forums';

  @override
  String get noForumsToDisplayExplanation =>
      'There are no forums to display. This might be due to permissions or the forum structure.';

  @override
  String get subscribedForums => 'Subscribed Forums';

  @override
  String get errorLoadingNotifications => 'Error loading notifications';

  @override
  String get pullDownToRefresh => 'Pull down to refresh';

  @override
  String get noNewNotificationsExplanation =>
      'You have no new notifications. Check back later for updates on topics you\'re following.';

  @override
  String noTagsMatch(Object filter) {
    return 'No tags match \"$filter\".';
  }

  @override
  String noTopicsTagged(Object tag) {
    return 'No topics tagged \"$tag\"';
  }

  @override
  String failedToBanUser2(Object error) {
    return 'Failed to ban user: $error';
  }

  @override
  String unbanUserConfirmation(Object username) {
    return 'Are you sure you want to unban $username?';
  }

  @override
  String failedToUnbanUser2(Object error) {
    return 'Failed to unban user: $error';
  }

  @override
  String get deletePostsProfilePostsAndComments =>
      'Delete posts, profile posts, and comments';

  @override
  String spamCleanConfirmation(Object username) {
    return 'Are you sure you want to spam clean $username?';
  }

  @override
  String failedToCleanSpam(Object error) {
    return 'Failed to clean spam: $error';
  }

  @override
  String get searchUser => 'Search User';

  @override
  String get tapToOpen => 'Tap to open';

  @override
  String get imageNotAvailable => 'Image not available';

  @override
  String get allForumTopicsHaveBeenMarkedAs =>
      'All forum topics have been marked as read';

  @override
  String postsCount(Object count) {
    return '$count Posts';
  }

  @override
  String get protectedForum => 'Protected Forum';

  @override
  String isPasswordProtected(Object forumName) {
    return '$forumName is password protected.';
  }

  @override
  String get enter => 'Enter';

  @override
  String get permissionDeniedToSaveImage => 'Permission denied to save image';

  @override
  String get postNotFound => 'Post not found.';

  @override
  String get failedToUploadFilePleaseTryAgain =>
      'Failed to upload file. Please try again.';

  @override
  String failedToUploadFile2(Object errorMessage) {
    return 'Failed to upload file: $errorMessage';
  }

  @override
  String get failedToPickFile => 'Failed to pick file';

  @override
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return 'Only $remainingSlots more attachment(s) allowed. Processing first $remainingSlots2 image(s).';
  }

  @override
  String get attachmentLimitReachedSkippingRemainingImages =>
      'Attachment limit reached. Skipping remaining images.';

  @override
  String failedToUploadImagePleaseTryAgain(Object fileName) {
    return '$fileName: Failed to upload image. Please try again.';
  }

  @override
  String failedToUploadImage2(Object errorMessage, Object fileName) {
    return '$fileName: Failed to upload image: $errorMessage';
  }

  @override
  String get failedToPickImage => 'Failed to pick image';

  @override
  String failedToRemoveAttachment2(Object error) {
    return 'Failed to remove attachment: $error';
  }

  @override
  String sentFromMobileApp(Object siteName) {
    return 'Sent from $siteName mobile app';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      'Please wait for attachments to finish uploading';

  @override
  String get imageIsTooLargeToUpload => 'Image is too large to upload';

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName is $fileBytes. This forum allows up to $maxBytes.';
  }

  @override
  String get resizeToFitExplanation =>
      'It can be scaled down just enough to fit, keeping its format and as much detail as the limit allows.';

  @override
  String get failedToPostReplyPleaseTryAgain =>
      'Failed to post reply. Please try again.';

  @override
  String get pleaseWaitForTheThreadToLoad =>
      'Please wait for the thread to load';

  @override
  String get failedToUpdatePostPleaseTryAgain =>
      'Failed to update post. Please try again.';

  @override
  String get postDeletedSuccessfully => 'Post deleted successfully';

  @override
  String failedToDeletePost(Object error) {
    return 'Failed to delete post: $error';
  }

  @override
  String failedToSubmitReport2(Object error) {
    return 'Failed to submit report: $error';
  }

  @override
  String get editHistoryNotAvailable =>
      'Edit history is not available for this post';

  @override
  String get noPermissionToUploadAvatar =>
      'You do not have permission to upload avatars';

  @override
  String get avatarUploadedSuccessfully => 'Avatar uploaded successfully';

  @override
  String failedToPickImage2(Object error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get react => 'React';

  @override
  String get reactionsAreNotEnabledOnThisForum =>
      'Reactions are not enabled on this forum.';

  @override
  String get noReactionsYet => 'No reactions yet';

  @override
  String get searchFilters => 'Search filters';

  @override
  String signOutWarning(Object siteName) {
    return 'You will be signed out of $siteName. You can sign back in any time.';
  }

  @override
  String get suggestedTopics => 'Suggested Topics';

  @override
  String get newLabel => 'NEW';

  @override
  String get voteRemoved => 'Vote removed';

  @override
  String get voters => 'Voters';

  @override
  String get noVotesYet => 'No votes yet.';

  @override
  String get trustLevels => 'Trust levels';

  @override
  String get trustLevelsExplanation =>
      'Members earn trust by reading and participating. Each level unlocks new abilities.';

  @override
  String get activity => 'Activity';
}
