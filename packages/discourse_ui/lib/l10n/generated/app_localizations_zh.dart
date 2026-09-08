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
  String get loginInfo => '登录信息';

  @override
  String get loginFailed => '登录失败';

  @override
  String get additionalInformation => '附加信息';

  @override
  String dateOfBirth(Object marker) {
    return '出生日期$marker';
  }

  @override
  String minimumAgeYears(Object minimumAge) {
    return '最低年龄：$minimumAge 岁';
  }

  @override
  String locationLabel(Object marker) {
    return '位置$marker';
  }

  @override
  String get receiveSiteMailings => '接收站点邮件';

  @override
  String get moveToCategory => '移动到分类';

  @override
  String get undeleteTopic => '恢复主题';

  @override
  String get undeleteTopicConfirmation => '确定要恢复此主题吗？它将再次对其他用户可见。';

  @override
  String get send => '发送';

  @override
  String get changeEmailExplanation => '我们会向新邮箱发送确认链接。点击后更改即生效。';

  @override
  String get changeEmailSecurityNote =>
      '为了安全，Discourse 可能要求你通过邮件中的链接确认。如果没有收到，请检查垃圾邮件文件夹。';

  @override
  String get newDirectMessage => '新私信';

  @override
  String get noMessagesYetSayHi => '还没有消息 — 打个招呼吧。';

  @override
  String get edited => '已编辑';

  @override
  String get imageExceedsUploadLimits => '此图片超出上传限制，需要优化：';

  @override
  String get optimizationsToBeApplied => '将应用的优化：';

  @override
  String reductionPercent(Object percent) {
    return '缩减：$percent%';
  }

  @override
  String get editProfileManagedOnWebNote =>
      '显示名称、邮箱、密码及其他账户设置在“账户 → 在网页上管理账户”中管理。点击照片上的相机图标可更换头像。';

  @override
  String get approvedButRelayUnreachable =>
      '已批准，但无法连接 ForumCopilot 完成设置。请稍后在设置中重试。';

  @override
  String get notificationsAreTurnedOffForThisApp => '此应用的通知已关闭';

  @override
  String forumWillAskToApproveNotifications(Object forumName) {
    return '接下来，$forumName 会请求你批准“通知”。';
  }

  @override
  String get approveNotificationsExplanation =>
      '批准后，我们可以为你查看通知并发送到此设备。该权限无法发帖、回复或读取你的消息。';

  @override
  String get forumOwnerPushNote => '如果论坛所有者为应用设置了通知，则无需此步骤。';

  @override
  String get pleaseLoginToCreateANewTopic => '请登录后创建新主题';

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
  String get protected => '受保护';

  @override
  String get solution => '解决方案';

  @override
  String get deleted => '已删除';

  @override
  String get pleaseLoginToViewUserProfiles => '请登录后查看用户资料。';

  @override
  String get announcement => '公告';

  @override
  String get solved => '已解决';

  @override
  String get hot => '热门';

  @override
  String get pinned => '置顶';

  @override
  String get subscribedLabel => '已订阅';

  @override
  String get locked => '已锁定';

  @override
  String get poll => '投票';

  @override
  String errorLoadingContent(Object error) {
    return '加载内容出错：$error';
  }

  @override
  String get noPermissionToViewSubforum => '你没有权限查看此子论坛中的主题。';

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
  String get topicDeletedBanner => '此主题已删除并对其他用户隐藏';

  @override
  String get topicClosedBanner => '此主题已关闭，不再接受回复';

  @override
  String get topicPinnedBanner => '此主题已置顶';

  @override
  String get youAreSubscribedToThisTopic => '你已订阅此主题';

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
  String get editConversation => '编辑会话';

  @override
  String get closeConversation => '关闭会话';

  @override
  String get openConversation => '打开会话';

  @override
  String get leaveConversation2 => '退出会话';

  @override
  String get reportConversation2 => '举报会话';

  @override
  String get closeConversation2 => '关闭会话';

  @override
  String get closeConversationConfirmation => '确定要关闭此会话吗？将无法发布新回复。';

  @override
  String get close => '关闭';

  @override
  String get openConversation2 => '打开会话';

  @override
  String get openConversationConfirmation => '确定要打开此会话吗？将允许发布新回复。';

  @override
  String get open => '打开';

  @override
  String get leaveConversation3 => '退出会话';

  @override
  String get leaveConversationConfirmation => '确定要退出此会话吗？它将从收件箱中隐藏。';

  @override
  String errorLoadingConversation(Object error) {
    return '加载会话出错：$error';
  }

  @override
  String get conversationNotFound => '未找到会话';

  @override
  String get conversationClosedBanner => '此会话已关闭，不再接受回复';

  @override
  String get noMessagesFound => '未找到消息';

  @override
  String get endOfConversation => '会话结束';

  @override
  String get jumpToMessage => '跳转到消息';

  @override
  String get editConversation2 => '编辑会话';

  @override
  String get failedToLoadMessage2 => '无法加载消息';

  @override
  String get cannotEditThisConversation => '无法编辑此会话';

  @override
  String get options => '选项';

  @override
  String get conversationOpen => '会话开放';

  @override
  String failedToCreateConversation(Object error) {
    return '无法创建会话：$error';
  }

  @override
  String maximumAttachmentsAllowed(Object count) {
    return '最多允许 $count 个附件';
  }

  @override
  String get noImagesFoundToDisplay => '没有可显示的图片。';

  @override
  String get pleaseLoginToViewThisAttachment => '请登录后查看此附件';

  @override
  String get searchForTopics => '搜索主题';

  @override
  String get noTopicsFound => '未找到主题';

  @override
  String get trySearchingWithDifferentKeywords => '请尝试其他关键词';

  @override
  String get noPostsFound => '未找到帖子';

  @override
  String get perTopicNotificationLevelsNote =>
      '按分类和按主题的通知级别在相应页面直接设置 — 点击任意主题或分类上的铃铛图标。';

  @override
  String get pushNotActiveForThisLogin => '此次登录未启用 — 请退出并重新登录以授权推送通知';

  @override
  String get pauseNotificationsFor => '暂停通知…';

  @override
  String get doNotDisturbExplanation => '暂停通知一段时间 — Discourse 会保留它们直到时段结束';

  @override
  String get emailSettingsSubtitle => '邮件频率、点赞汇总、摘要计划';

  @override
  String get manageAccountSubtitle => '资料、邮箱、密码、安全、高级设置';

  @override
  String get changePasswordSubtitle => '向当前邮箱发送密码重置邮件';

  @override
  String get ignoredUsersSubtitle => '查看和管理其帖子对你隐藏的用户';

  @override
  String get deleteAccountExplanation =>
      '账户删除由论坛处理。点击“继续”打开站点并联系管理团队 — Discourse 论坛按各自的政策处理删除。';

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
  String get unableToLoadForums => '无法加载论坛';

  @override
  String get noForumsToDisplayExplanation => '没有可显示的论坛。可能是权限或论坛结构所致。';

  @override
  String get subscribedForums => '已订阅的论坛';

  @override
  String get errorLoadingNotifications => '加载通知出错';

  @override
  String get pullDownToRefresh => '下拉刷新';

  @override
  String get noNewNotificationsExplanation => '没有新通知。稍后再来查看你关注主题的更新。';

  @override
  String noTagsMatch(Object filter) {
    return '没有与“$filter”匹配的标签。';
  }

  @override
  String noTopicsTagged(Object tag) {
    return '没有带“$tag”标签的主题';
  }

  @override
  String failedToBanUser2(Object error) {
    return '无法封禁用户：$error';
  }

  @override
  String unbanUserConfirmation(Object username) {
    return '确定要解封 $username 吗？';
  }

  @override
  String failedToUnbanUser2(Object error) {
    return '无法解封用户：$error';
  }

  @override
  String get deletePostsProfilePostsAndComments => '删除帖子、个人资料帖子和评论';

  @override
  String spamCleanConfirmation(Object username) {
    return '确定要清理 $username 的垃圾内容吗？';
  }

  @override
  String failedToCleanSpam(Object error) {
    return '清理垃圾内容失败：$error';
  }

  @override
  String get searchUser => '搜索用户';

  @override
  String get tapToOpen => '点击打开';

  @override
  String get imageNotAvailable => '图片不可用';

  @override
  String get allForumTopicsHaveBeenMarkedAs => '所有论坛主题已标记为已读';

  @override
  String postsCount(Object count) {
    return '$count 篇帖子';
  }

  @override
  String get protectedForum => '受保护的论坛';

  @override
  String isPasswordProtected(Object forumName) {
    return '$forumName 受密码保护。';
  }

  @override
  String get enter => '输入';

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
  String get failedToPickFile => '选择文件失败';

  @override
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return '仅允许再添加 $remainingSlots 个附件。将处理前 $remainingSlots2 张图片。';
  }

  @override
  String get attachmentLimitReachedSkippingRemainingImages => '已达到附件上限。跳过剩余图片。';

  @override
  String failedToUploadImagePleaseTryAgain(Object fileName) {
    return '$fileName：图片上传失败。请重试。';
  }

  @override
  String failedToUploadImage2(Object errorMessage, Object fileName) {
    return '$fileName：图片上传失败：$errorMessage';
  }

  @override
  String get failedToPickImage => '选择图片失败';

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
  String get pleaseWaitForTheThreadToLoad => '请等待主题加载完成';

  @override
  String get failedToUpdatePostPleaseTryAgain => '帖子更新失败。请重试。';

  @override
  String get postDeletedSuccessfully => '帖子已删除';

  @override
  String failedToDeletePost(Object error) {
    return '删除帖子失败：$error';
  }

  @override
  String failedToSubmitReport2(Object error) {
    return '提交举报失败：$error';
  }

  @override
  String get editHistoryNotAvailable => '此帖子没有可用的编辑历史';

  @override
  String get noPermissionToUploadAvatar => '你没有上传头像的权限';

  @override
  String get avatarUploadedSuccessfully => '头像已上传';

  @override
  String failedToPickImage2(Object error) {
    return '选择图片失败：$error';
  }

  @override
  String get react => '添加反应';

  @override
  String get reactionsAreNotEnabledOnThisForum => '此论坛未启用反应功能。';

  @override
  String get noReactionsYet => '还没有反应';

  @override
  String get searchFilters => '搜索筛选';

  @override
  String signOutWarning(Object siteName) {
    return '你将退出 $siteName。你可以随时重新登录。';
  }

  @override
  String get suggestedTopics => '推荐主题';

  @override
  String get newLabel => '新';

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
}
