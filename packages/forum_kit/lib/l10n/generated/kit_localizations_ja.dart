// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'kit_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class KitLocalizationsJa extends KitLocalizations {
  KitLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get discardFailedCloseQuestion => 'このまま閉じますか？以前に保存した下書きは「下書き」に残ります。';

  @override
  String get keepEditing => '編集を続ける';

  @override
  String get closeAnyway => 'このまま閉じる';

  @override
  String get okButton => 'OK';

  @override
  String get copied => 'コピーしました';

  @override
  String get cancel => 'キャンセル';

  @override
  String get tryAgain => '再試行';

  @override
  String get latest => '最新';

  @override
  String get language => '言語';

  @override
  String get all => 'すべて';

  @override
  String get reason => '理由';

  @override
  String get pleaseSpecifyReason => '理由を指定してください';

  @override
  String get selectDate => '日付を選択';

  @override
  String get search => '検索';

  @override
  String get messages => 'メッセージ';

  @override
  String get add => '追加';

  @override
  String get delete => '削除';

  @override
  String get temporary => '一時的';

  @override
  String error(String error) {
    return 'エラー: $error';
  }

  @override
  String get none => 'なし';

  @override
  String get italic => '斜体';

  @override
  String get link => 'リンク';

  @override
  String get image => '画像';

  @override
  String get quote => '引用';

  @override
  String get code => 'コード';

  @override
  String participants(int count) {
    return '参加者 ($count)';
  }

  @override
  String get refresh => '更新';

  @override
  String get share => '共有';

  @override
  String get reply => '返信';

  @override
  String get dark => 'ダーク';

  @override
  String get notifications => '通知';

  @override
  String get edit => '編集';

  @override
  String get remove => '削除';

  @override
  String get message => 'メッセージ';

  @override
  String couldNotOpenLink(String error) {
    return 'リンクを開けませんでした: $error';
  }

  @override
  String timeGapDaysLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 日後',
    );
    return '$_temp0';
  }

  @override
  String timeGapMonthsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count か月後',
    );
    return '$_temp0';
  }

  @override
  String timeGapYearsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 年後',
    );
    return '$_temp0';
  }

  @override
  String get apply => '適用';

  @override
  String get bookmarks => 'ブックマーク';

  @override
  String get copy => 'コピー';

  @override
  String get discard => '破棄';

  @override
  String get firstPostsOnly => '最初の投稿のみ';

  @override
  String get relevance => '関連度';

  @override
  String get reset => 'リセット';

  @override
  String get titleOnly => 'タイトルのみ';

  @override
  String get solved => '解決済み';

  @override
  String get open => '開く';

  @override
  String participantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '参加者 $count 人',
    );
    return '$_temp0';
  }

  @override
  String get postNeedsApprovalTitle => '承認待ちの投稿';

  @override
  String get postNeedsApprovalBody =>
      'あなたの新しい投稿を受領しましたが、表示するにはモデレーターの承認が必要です。しばらくお待ちください。';

  @override
  String get tapToOpen => 'タップして開く';

  @override
  String get imageNotAvailable => '画像を表示できません';

  @override
  String get searchFilters => '検索フィルター';

  @override
  String get tags => 'タグ';

  @override
  String get discardPostQuestion => '投稿を破棄しますか？';

  @override
  String get discardChangesQuestion => '変更を破棄しますか？';

  @override
  String get discardChanges => '変更を破棄';

  @override
  String get saveDraft => '下書きを保存';

  @override
  String topicMapViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '閲覧',
    );
    return '$_temp0';
  }

  @override
  String topicMapLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'いいね',
    );
    return '$_temp0';
  }

  @override
  String topicMapLinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'リンク',
    );
    return '$_temp0';
  }

  @override
  String topicMapUsers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ユーザー',
    );
    return '$_temp0';
  }

  @override
  String get day => '日';

  @override
  String get month => '月';

  @override
  String get chooseEmoji => '絵文字を選択';

  @override
  String get searchEmoji => '絵文字を検索';

  @override
  String get suspendUser => 'ユーザーを凍結';

  @override
  String get suspendUntil => '次の期間までユーザーを凍結する';

  @override
  String get suspendForever => '永久に凍結する';

  @override
  String get suspendReasonNotListening => 'スタッフのフィードバックを聞き入れないため';

  @override
  String get suspendReasonStaffTime => 'スタッフの時間を不当に消耗したため';

  @override
  String get suspendReasonCombative => '好戦的過ぎるため';

  @override
  String get suspendReasonWrongPlace => '場所が誤っているため';

  @override
  String get suspendReasonNoPurpose => 'コミュニティー内で異議を唱える以外に建設的な目的がないため';

  @override
  String get suspendReasonCustom => 'カスタム…';

  @override
  String get suspendReasonQuestion =>
      'なぜ凍結していますか？このテキストはユーザーがログインしようとするときに表示されます。簡潔に説明してください。';

  @override
  String get closedLabel => 'クローズ';

  @override
  String get pleaseSelectSuspensionEndDate => '凍結の終了日時を選択してください';

  @override
  String get dismissAllNotifications => 'すべて閉じる';

  @override
  String get searchFilterStatusSection => 'ステータス';

  @override
  String get searchFilterMyActivitySection => '自分のアクティビティ';

  @override
  String get searchFilterMatchTypeSection => '一致の種類';

  @override
  String get searchTagsFilterHelper => 'スペースまたはカンマで区切ります。すべてのタグが必要です。';

  @override
  String get searchSortBy => '並べ替え';

  @override
  String get searchStatusOpen => 'オープン';

  @override
  String get searchStatusArchived => 'アーカイブ済み';

  @override
  String get searchStatusNoReplies => '返信なし';

  @override
  String get searchStatusPublicOnly => '公開のみ';

  @override
  String get searchStatusUnsolved => '未解決';

  @override
  String get searchInBookmarked => 'ブックマーク済み';

  @override
  String get searchInMyMessages => 'メッセージ内';

  @override
  String get searchInLiked => '「いいね！」した項目';

  @override
  String get searchInPosted => '投稿したもの';

  @override
  String get searchInWatching => 'ウォッチ中';

  @override
  String get searchInTracking => '追跡中';

  @override
  String get searchInSeen => '既読';

  @override
  String get searchInUnseen => '未読';

  @override
  String get searchSortLatestPost => '最新の投稿';

  @override
  String get searchSortMostLiked => '「いいね！」の多い項目';

  @override
  String get searchSortMostViewed => '最も閲覧されている項目';

  @override
  String get searchSortLatestTopic => '最新のトピック';

  @override
  String get searchFieldHint => '検索…';

  @override
  String get postLikeAction => '投稿に「いいね！」する';

  @override
  String get postUnlikeAction => '「いいね！」を取り消す';

  @override
  String get somethingWentWrongTryAgain => '問題が発生しました。もう一度お試しください。';
}
