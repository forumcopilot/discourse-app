// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'kit_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class KitLocalizationsZh extends KitLocalizations {
  KitLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get okButton => '确定';

  @override
  String get copied => '已复制';

  @override
  String get cancel => '取消';

  @override
  String get tryAgain => '重试';

  @override
  String get latest => '最新';

  @override
  String get language => '语言';

  @override
  String get all => '全部';

  @override
  String get reason => '原因';

  @override
  String get pleaseSpecifyReason => '请说明原因';

  @override
  String get selectDate => '选择日期';

  @override
  String get search => '搜索';

  @override
  String get messages => '消息';

  @override
  String get add => '添加';

  @override
  String get delete => '删除';

  @override
  String get temporary => '临时';

  @override
  String error(String error) {
    return '错误: $error';
  }

  @override
  String get none => '无';

  @override
  String get italic => '斜体';

  @override
  String get link => '链接';

  @override
  String get image => '图片';

  @override
  String get quote => '引用';

  @override
  String get code => '代码';

  @override
  String participants(int count) {
    return '参与者 ($count)';
  }

  @override
  String get refresh => '刷新';

  @override
  String get share => '分享';

  @override
  String get reply => '回复';

  @override
  String get dark => '深色';

  @override
  String get notifications => '通知';

  @override
  String get edit => '编辑';

  @override
  String get remove => '删除';

  @override
  String get message => '消息';

  @override
  String couldNotOpenLink(String error) {
    return '无法打开链接: $error';
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
  String get apply => '应用';

  @override
  String get bookmarks => '书签';

  @override
  String get copy => '复制';

  @override
  String get firstPostsOnly => '仅首帖';

  @override
  String get relevance => '相关性';

  @override
  String get reset => '重置';

  @override
  String get titleOnly => '仅标题';

  @override
  String get solved => '已解决';

  @override
  String get open => '打开';

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
  String get postNeedsApprovalTitle => '帖子需要审批';

  @override
  String get postNeedsApprovalBody => '我们已收到您的帖子，不过需要由版主批准才能显示。请耐心等待。';

  @override
  String get tapToOpen => '点击打开';

  @override
  String get imageNotAvailable => '图片不可用';

  @override
  String get searchFilters => '搜索筛选';

  @override
  String get tags => '标签';

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
  String get day => '日';

  @override
  String get month => '月';

  @override
  String get suspendUser => '封禁用户';

  @override
  String get suspendUntil => '将用户封禁至';

  @override
  String get suspendForever => '永久封禁';

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
  String get pleaseSelectSuspensionEndDate => '请选择封禁结束时间';

  @override
  String get dismissAllNotifications => '全部忽略';

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
  String get postLikeAction => '点赞帖子';

  @override
  String get postUnlikeAction => '取消点赞';
}
