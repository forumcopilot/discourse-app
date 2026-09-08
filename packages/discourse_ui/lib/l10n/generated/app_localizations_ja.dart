// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get loginTitle => 'ログイン';

  @override
  String get usePasskey => 'Use Passkey';

  @override
  String get passkeyContinuePrompt => 'Use your passkey to continue';

  @override
  String get continueButton => '続ける';

  @override
  String get errorTitle => 'エラー';

  @override
  String get okButton => 'OK';

  @override
  String get retryButton => '再試行';

  @override
  String get copyToClipboard => 'クリップボードにコピー';

  @override
  String get copied => 'コピーしました';

  @override
  String get errorMessageCopiedToClipboard => 'エラーメッセージをクリップボードにコピーしました';

  @override
  String get dismiss => '閉じる';

  @override
  String get cancel => 'キャンセル';

  @override
  String get tryAgain => '再試行';

  @override
  String get anErrorOccurred => 'エラーが発生しました';

  @override
  String get accountPendingApproval =>
      'アカウントは承認待ちです。フォーラムを閲覧できますが、モデレーターがアカウントを承認するまで投稿できません。';

  @override
  String get checkEmailToConfirm =>
      'アカウントを確認するためにメールを確認してください。送信したメールの確認リンクをクリックしてください。';

  @override
  String get checkNewEmailToConfirm =>
      '変更を確認するために新しいメールアドレスを確認してください。新しいメールを確認するまで、古いメールは有効のままです。';

  @override
  String get emailAddressInvalid =>
      'メールアドレスが無効であるか、メールが拒否されているようです。アカウント設定でメールアドレスを更新してください。';

  @override
  String get accountDisabled => 'アカウントが無効になっています。サポートについては管理者にお問い合わせください。';

  @override
  String get accountRegistrationRejected =>
      'アカウント登録が拒否されました。詳細については管理者にお問い合わせください。';

  @override
  String get welcomeToForumCopilot => 'Forum Copilotへようこそ！';

  @override
  String get successfullyLoggedOut => '正常にログアウトしました';

  @override
  String get accountStatusRequiresAttention =>
      'アカウントの状態に注意が必要です。ご質問がある場合は管理者にお問い合わせください。';

  @override
  String get updateEmail => 'メールを更新';

  @override
  String get resend => '再送信';

  @override
  String get noLatestTopics => '最新トピックなし';

  @override
  String get noRecentTopicsToDisplay =>
      '表示する最新トピックがありません。後で新しいディスカッションを確認してください。';

  @override
  String get signInToViewLatestTopics => '最新トピックを表示するにはログインしてください';

  @override
  String get youNeedToBeSignedInToViewLatestTopics =>
      '最新トピックを表示するにはログインする必要があります';

  @override
  String get thereAreNoUnreadTopics => '未読トピックがありません。後で新しいディスカッションを確認してください。';

  @override
  String get youAreAllCaughtUp => 'すべて確認済みです！';

  @override
  String get signInToViewUnreadTopics => '未読トピックを表示するにはログインしてください';

  @override
  String get youNeedToBeSignedInToViewUnreadTopics =>
      '未読トピックを表示するにはログインする必要があります';

  @override
  String get latest => '最新';

  @override
  String get unread => '未読';

  @override
  String get failedToConnectToSite =>
      'サイトに接続できませんでした。サイトがダウンしているか、アクセスできない可能性があります。';

  @override
  String get connectionFailed => '接続失敗';

  @override
  String failedToConnectToSiteName(String siteName) {
    return '$siteName に接続できませんでした';
  }

  @override
  String get loading => '読み込み中...';

  @override
  String get newConversation => '新しい会話';

  @override
  String get language => '言語';

  @override
  String get all => 'すべて';

  @override
  String get topicsOnly => 'トピックのみ';

  @override
  String get titlesOnly => 'タイトルのみ';

  @override
  String failedToShareTopic(String error) {
    return 'トピックの共有に失敗しました: $error';
  }

  @override
  String get pleaseLoginToSubscribe => 'このスレッドを null するにはログインしてください';

  @override
  String get subscribe => '購読';

  @override
  String get failedToSubscribeToThread => 'スレッドの null に失敗しました';

  @override
  String get youCannotReplyToThisThread => 'このスレッドに返信できません';

  @override
  String get pleaseWaitForThreadToLoad => 'スレッドの読み込みを待ってください';

  @override
  String get softDelete => 'ソフト削除';

  @override
  String get postCanBeRestoredLater => '投稿は後で復元できます';

  @override
  String get hardDelete => '完全削除';

  @override
  String get postWillBePermanentlyDeleted => '投稿は完全に削除されます';

  @override
  String get reasonForDeletion => '削除理由';

  @override
  String get enterReasonForDeletingPost => 'この投稿を削除する理由を入力してください';

  @override
  String get pleaseEnterReasonForDeletion => '削除理由を入力してください';

  @override
  String get reportPost => '投稿を報告';

  @override
  String get pleaseProvideReasonForReporting => 'この投稿を報告する理由を入力してください。';

  @override
  String get reason => '理由';

  @override
  String get enterReasonForReportingPost => 'この投稿を報告する理由を入力してください';

  @override
  String get pleaseEnterReason => '理由を入力してください';

  @override
  String get submitReport => '報告を送信';

  @override
  String get selectedActions => '選択されたアクション:';

  @override
  String get thisActionCannotBeUndone => 'このアクションは元に戻せません。';

  @override
  String get participantsLabel => '参加者';

  @override
  String usernameHasBeenInvited(String username) {
    return '$username が会話に招待されました';
  }

  @override
  String errorInvitingUser(String error) {
    return 'ユーザーの招待エラー: $error';
  }

  @override
  String get newTopic => '新しいトピック';

  @override
  String get markRead => '既読にする';

  @override
  String get spamOrAdvertising => 'スパムまたは広告';

  @override
  String get otherPleaseSpecify => 'その他（指定してください）';

  @override
  String get pleaseSpecifyReason => '理由を指定してください';

  @override
  String get banUser => 'ユーザーを禁止';

  @override
  String get unbanUser => 'ユーザーの禁止を解除';

  @override
  String pleaseSelectReasonForBanningUser(String username) {
    return '$username を禁止する理由を選択してください';
  }

  @override
  String get violationOfCommunityGuidelines => 'コミュニティガイドライン違反';

  @override
  String get harassmentOrAbusiveBehavior => '嫌がらせまたは虐待的行為';

  @override
  String get postingInappropriateContent => '不適切なコンテンツの投稿';

  @override
  String get accountCompromiseOrSecurityIssue => 'アカウントの侵害またはセキュリティ問題';

  @override
  String get enterReasonForBanningUser => 'このユーザーを禁止する理由を入力してください';

  @override
  String get banUntil => '禁止期限';

  @override
  String get selectDate => '日付を選択';

  @override
  String get moreOptions => 'その他のオプション';

  @override
  String get topicClosed => 'トピックが閉じられました';

  @override
  String get topicOpened => 'トピックが開かれました';

  @override
  String get topicStickied => 'トピックが固定されました';

  @override
  String get topicUnstickied => 'トピックの固定が解除されました';

  @override
  String cannotEditMessage(String error) {
    return 'このメッセージを編集できません: $error';
  }

  @override
  String get confirmSpamClean => 'スパムクリーンを確認';

  @override
  String get handleThreads => 'スレッドを処理';

  @override
  String get deleteMessages => 'メッセージを削除';

  @override
  String get deleteConversations => '会話を削除';

  @override
  String get noConversations => '会話なし';

  @override
  String get noConversationsMessage => 'まだ会話がありません。新しい会話を開始してメッセージングを始めましょう。';

  @override
  String get imageSavedToGallery => '画像がギャラリーに保存されました！';

  @override
  String failedToSaveImage(String error) {
    return '画像の保存に失敗しました: $error';
  }

  @override
  String get userProfile => 'ユーザープロフィール';

  @override
  String get deletePost => '投稿を削除';

  @override
  String get loginRequired => 'ログインが必要です';

  @override
  String get spamCleaner => 'スパムクリーナー';

  @override
  String get sendMessage => 'メッセージを送信';

  @override
  String get memberSince => 'メンバー登録日';

  @override
  String get lastActivity => '最終アクティビティ';

  @override
  String get likesReceived => '受け取ったいいね';

  @override
  String get likesGiven => '与えたいいね';

  @override
  String get showMore => 'もっと見る';

  @override
  String get cleanSpam => 'スパムをクリーンアップ';

  @override
  String get failedToSaveConversation => '会話の保存に失敗しました';

  @override
  String get members => 'メンバー';

  @override
  String membersCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString メンバー';
  }

  @override
  String get noSubject => '件名なし';

  @override
  String get search => '検索';

  @override
  String get logout => 'ログアウト';

  @override
  String get areYouSureYouWantToLogout => 'ログアウトしてもよろしいですか？';

  @override
  String get register => '登録';

  @override
  String get signIn => 'ログイン';

  @override
  String get markForumRead => 'フォーラムを既読にする';

  @override
  String get notificationTest => '通知テスト';

  @override
  String get forum => 'フォーラム';

  @override
  String get profile => 'プロフィール';

  @override
  String get messages => 'メッセージ';

  @override
  String get add => '追加';

  @override
  String get retry => '再試行';

  @override
  String get delete => '削除';

  @override
  String get deleteMessage => 'メッセージを削除';

  @override
  String get deletingPost => '投稿を削除中...';

  @override
  String failedToUnlikePost(String error) {
    return '投稿のいいねを解除できませんでした: $error';
  }

  @override
  String failedToLikePost(String error) {
    return '投稿にいいねできませんでした: $error';
  }

  @override
  String get signInToViewMessages => 'メッセージを表示するにはログインしてください';

  @override
  String get youNeedToBeSignedInToViewConversations =>
      '会話を表示するにはログインする必要があります。';

  @override
  String errorLoadingConversations(String error) {
    return '会話の読み込みエラー: $error';
  }

  @override
  String failedToLeaveConversation(String error) {
    return '会話を退出できませんでした: $error';
  }

  @override
  String errorLoadingMoreConversations(String error) {
    return '追加の会話の読み込みエラー: $error';
  }

  @override
  String get searchFailed => '検索に失敗しました';

  @override
  String get userInformationNotAvailable => 'ユーザー情報が利用できません';

  @override
  String get birthday => '誕生日';

  @override
  String get posts => '投稿';

  @override
  String get following => 'フォロー中';

  @override
  String get followers => 'フォロワー';

  @override
  String get about => 'について';

  @override
  String get location => '場所';

  @override
  String get website => 'ウェブサイト';

  @override
  String get next => '次へ';

  @override
  String get permanent => '永続的';

  @override
  String get temporary => '一時的';

  @override
  String setBanDurationFor(String username) {
    return '$usernameの禁止期間を設定';
  }

  @override
  String get pleaseSelectEndDateForTemporaryBan => '一時的な禁止の終了日を選択してください';

  @override
  String get back => '戻る';

  @override
  String get unban => '禁止を解除';

  @override
  String get confirm => '確認';

  @override
  String spamClean(String username) {
    return '$usernameのスパムをクリーン';
  }

  @override
  String get selectActionsToPerform => '実行するアクションを選択:';

  @override
  String get moveOrDeleteThreadsBasedOnAdminSettings =>
      '管理者設定に基づいてスレッドを移動または削除';

  @override
  String get messageUpdatedSuccessfully => 'メッセージが正常に更新されました';

  @override
  String error(String error) {
    return 'エラー: $error';
  }

  @override
  String failedToRemoveAttachment(String error) {
    return '添付ファイルの削除に失敗しました: $error';
  }

  @override
  String failedToLoadMessage(String error) {
    return 'メッセージの読み込みに失敗しました: $error';
  }

  @override
  String get editMessage => 'メッセージを編集';

  @override
  String get removeAttachment => '添付ファイルを削除';

  @override
  String get areYouSureYouWantToRemoveThisAttachment =>
      'この添付ファイルを削除してもよろしいですか？';

  @override
  String get none => 'なし';

  @override
  String get attachFile => 'ファイルを添付';

  @override
  String get uploadImage => '画像をアップロード';

  @override
  String get formatting => '書式設定';

  @override
  String get bold => '太字';

  @override
  String get italic => '斜体';

  @override
  String get underline => '下線';

  @override
  String get strikethrough => '取り消し線';

  @override
  String get link => 'リンク';

  @override
  String get image => '画像';

  @override
  String get video => '動画';

  @override
  String get quote => '引用';

  @override
  String get code => 'コード';

  @override
  String get spoiler => 'ネタバレ';

  @override
  String get bulletList => '箇条書きリスト';

  @override
  String get numberedList => '番号付きリスト';

  @override
  String get listItem => 'リスト項目';

  @override
  String participants(int count) {
    return '参加者 ($count)';
  }

  @override
  String get markAsUnread => '未読としてマーク';

  @override
  String get invite => '招待';

  @override
  String get enterKeywordsToSearchTopics => 'トピックを検索するキーワードを入力...';

  @override
  String get undelete => '復元';

  @override
  String get refresh => '更新';

  @override
  String get share => '共有';

  @override
  String get viewOnWeb => 'Webで表示';

  @override
  String get unlock => 'ロック解除';

  @override
  String get lock => 'ロック';

  @override
  String get stick => '固定';

  @override
  String get unstick => '固定解除';

  @override
  String get reply => '返信';

  @override
  String get vote => '投票';

  @override
  String votesCount(int count) {
    return '$count票';
  }

  @override
  String get pollClosed => '投票は終了しました';

  @override
  String pollEndsOn(String date) {
    return '$dateに終了';
  }

  @override
  String get voteToSeeResults => '投票して結果を見る';

  @override
  String get viewFullPoll => '投票を表示';

  @override
  String pollOptionsCount(int count) {
    return '$count件の選択肢';
  }

  @override
  String get reactedBy => 'リアクションした人';

  @override
  String get enterKeywordsToFindTopicsAndPosts => 'キーワードを入力してトピックと投稿を検索';

  @override
  String get light => 'ライト';

  @override
  String get dark => 'ダーク';

  @override
  String version(String version, String buildNumber) {
    return 'バージョン $version ($buildNumber)';
  }

  @override
  String get unableToLoadProfile => 'プロフィールを読み込めません';

  @override
  String get banned => '禁止';

  @override
  String get reportSubmittedSuccessfully => '報告が正常に送信されました';

  @override
  String get deleteTopic => 'トピックを削除';

  @override
  String get topicCanBeRestoredLater => 'トピックは後で復元できます';

  @override
  String get topicWillBePermanentlyDeleted => 'トピックは完全に削除されます';

  @override
  String get enterReasonForDeletingTopic => 'このトピックを削除する理由を入力してください';

  @override
  String get pleaseSelectEndDate => '終了日を選択してください';

  @override
  String get userBannedSuccessfully => 'ユーザーが正常に禁止されました';

  @override
  String get failedToBanUser => 'ユーザーの禁止に失敗しました';

  @override
  String get userUnbannedSuccessfully => 'ユーザーの禁止が正常に解除されました';

  @override
  String get failedToUnbanUser => 'ユーザーの禁止解除に失敗しました';

  @override
  String get spamCleanUser => 'ユーザーのスパムをクリーンアップ';

  @override
  String get deletePrivateConversations => 'プライベート会話を削除';

  @override
  String get banTheUserAccount => 'ユーザーアカウントを禁止';

  @override
  String get handledThreads => '処理されたスレッド';

  @override
  String get deletedMessages => '削除されたメッセージ';

  @override
  String get deletedConversations => '削除された会話';

  @override
  String get bannedUser => '禁止されたユーザー';

  @override
  String successfullyCleanedSpam(String username, String actions) {
    return '$usernameのスパムが正常にクリーンアップされました。アクション: $actions';
  }

  @override
  String get home => 'ホーム';

  @override
  String get notifications => '通知';

  @override
  String get forums => 'フォーラム';

  @override
  String get markAllForumsAsRead => 'すべてのフォーラムを既読にしますか？';

  @override
  String get markAllForumsAsReadMessage =>
      'これにより、すべてのフォーラムとトピックが既読としてマークされます。この操作は元に戻せません。';

  @override
  String get markAsRead => '既読にする';

  @override
  String get content => 'コンテンツ';

  @override
  String get insertImage => '画像を挿入';

  @override
  String get howWouldYouLikeToInsertImage => 'この画像をどのように挿入しますか？';

  @override
  String get thumbnail => 'サムネイル';

  @override
  String get fullSize => 'フルサイズ';

  @override
  String get pleaseEnterTitle => 'タイトルを入力してください';

  @override
  String get pleaseEnterContent => 'コンテンツを入力してください';

  @override
  String get uploading => 'アップロード中...';

  @override
  String get uploaded => 'アップロード済み';

  @override
  String get mentionUser => 'ユーザーをメンション';

  @override
  String get submittingReport => 'レポート送信中...';

  @override
  String get banningUser => 'ユーザーを禁止中...';

  @override
  String get unbanningUser => 'ユーザーの禁止解除中...';

  @override
  String get cleaningSpam => 'スパムをクリーンアップ中...';

  @override
  String get writeYourMessage => 'メッセージを書く...';

  @override
  String get writeYourReply => '返信を書く...';

  @override
  String get conversationCreatedSuccessfully => '会話が正常に作成されました';

  @override
  String get conversationMarkedAsUnread => '会話が未読としてマークされました';

  @override
  String get conversationClosed => '会話が閉じられました';

  @override
  String get conversationOpened => '会話が開かれました';

  @override
  String get pleaseLoginToLikeMessages => 'メッセージにいいねするにはログインしてください';

  @override
  String get loadEarlierMessages => '以前のメッセージを読み込む';

  @override
  String failedToLoadQuote(String error) {
    return '引用の読み込みに失敗しました: \n$error';
  }

  @override
  String failedToSendReply(String error) {
    return '返信の送信に失敗しました: $error';
  }

  @override
  String failedToMarkConversationAsUnread(String error) {
    return '会話を未読としてマークできませんでした: $error';
  }

  @override
  String failedToCloseConversation(String error) {
    return '会話を閉じることができませんでした: $error';
  }

  @override
  String failedToOpenConversation(String error) {
    return '会話を開くことができませんでした: $error';
  }

  @override
  String failedToJumpToMessage(String error) {
    return 'メッセージにジャンプできませんでした: $error';
  }

  @override
  String get goToTop => 'トップへ';

  @override
  String get goToBottom => 'ボトムへ';

  @override
  String get pleaseLoginToAccessContent =>
      'このコンテンツにアクセスして投稿とやり取りするには、ログインしてください。';

  @override
  String get searchUsers => 'ユーザーを検索...';

  @override
  String get enterConversationTitle => '会話のタイトルを入力';

  @override
  String enterCode(int count) {
    return '$count桁のコードを入力';
  }

  @override
  String get edit => '編集';

  @override
  String get report => '報告';

  @override
  String get remove => '削除';

  @override
  String get subject => '件名';

  @override
  String get message => 'メッセージ';

  @override
  String get titleCannotBeEmpty => 'タイトルを入力してください';

  @override
  String get conversationUpdatedSuccessfully => '会話が正常に更新されました';

  @override
  String get goBack => '戻る';

  @override
  String failedToLoadPost(String error) {
    return '投稿の読み込みに失敗しました: \n$error';
  }

  @override
  String failedToLikeOrUnlikeMessage(String action, String error) {
    return 'メッセージの$actionに失敗しました: $error';
  }

  @override
  String get like => 'いいね';

  @override
  String get unlike => 'いいねを取り消す';

  @override
  String downloading(String filename) {
    return '$filenameをダウンロード中...';
  }

  @override
  String openingShareSheet(String filename) {
    return '$filenameの共有シートを開いています';
  }

  @override
  String errorDownloading(String filename, String error) {
    return '$filenameのダウンロードエラー: $error';
  }

  @override
  String get failedToNavigateToForum => 'フォーラムへの移動に失敗しました';

  @override
  String forumNotFoundById(String forumId) {
    return 'フォーラムが見つかりません: $forumId';
  }

  @override
  String couldNotOpenLink(String error) {
    return 'リンクを開けませんでした: $error';
  }

  @override
  String get translating => '翻訳中...';

  @override
  String get translated => '翻訳済み';

  @override
  String get translatedContent => '翻訳されたコンテンツ';

  @override
  String get twoFactorAuthentication => '2 要素認証';

  @override
  String get authenticationCodeLabel => '認証コード';

  @override
  String get pleaseEnterYourAuthenticationCode => '認証コードを入力してください';

  @override
  String codeMustBeDigits(int count) {
    return 'コードは $count 桁で入力してください';
  }

  @override
  String get codeMustContainOnlyNumbers => 'コードは数字のみを含めてください';

  @override
  String get verifyButton => '確認';

  @override
  String get attachments => '添付ファイル';

  @override
  String get replyOptions => '返信オプション';

  @override
  String get replyWithQuote => '引用して返信';

  @override
  String fileSavedToDownloads(String filename) {
    return 'ファイルをダウンロードに保存しました: $filename';
  }

  @override
  String fileSavedToDocuments(String filename) {
    return 'ファイルをドキュメントに保存しました: $filename';
  }

  @override
  String topicLastReplyBy(String username, String time) {
    return '$username が $time に返信';
  }

  @override
  String inReplyToUser(String username) {
    return '$username への返信';
  }

  @override
  String inReplyToPost(int number) {
    return '投稿 #$number への返信';
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
  String get profileViews => '閲覧数';

  @override
  String get badges => 'バッジ';

  @override
  String get chatWithUser => 'チャット';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件の返信',
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
  String get lastSeen => '最終アクセス';

  @override
  String get chat => 'チャット';

  @override
  String comingSoon(String label) {
    return '$label — 近日公開';
  }

  @override
  String moreBadges(Object count) {
    return '他 $count 件';
  }

  @override
  String get allNotificationsMarkedAsRead => 'すべての通知を既読にしました';

  @override
  String get apply => '適用';

  @override
  String get bookmarks => 'ブックマーク';

  @override
  String reviewableBy(String username) {
    return '$username による';
  }

  @override
  String get changeEmail => 'メールアドレスを変更';

  @override
  String get changePassword => 'パスワードを変更';

  @override
  String get checkingStatus => '状態を確認しています…';

  @override
  String get clearReminder => 'リマインダーを解除';

  @override
  String get copy => 'コピー';

  @override
  String get copyLink => 'リンクをコピー';

  @override
  String couldNotEnableNotifications(String error) {
    return '通知を有効にできませんでした: $error';
  }

  @override
  String get couldNotFindBookmark => 'このブックマークが見つかりません';

  @override
  String couldNotOpenEmail(String email) {
    return 'メールを開けませんでした: $email';
  }

  @override
  String couldNotStartSignIn(String error) {
    return 'サインインを開始できませんでした: $error';
  }

  @override
  String get customDateAndTime => '日時を指定';

  @override
  String get deleteAccount => 'アカウントを削除';

  @override
  String get deleteMessageQuestion => 'メッセージを削除しますか？';

  @override
  String get discard => '破棄';

  @override
  String get discardDraftQuestion => '下書きを破棄しますか？';

  @override
  String get doNotDisturb => 'おやすみモード';

  @override
  String get editHistory => '編集履歴';

  @override
  String get editProfile => 'プロフィールを編集';

  @override
  String get editReminder => 'リマインダーを編集';

  @override
  String emailCopiedToClipboard(String email) {
    return 'メールアドレスをコピーしました: $email';
  }

  @override
  String get pushEnabledForThisLogin => 'このログインで有効';

  @override
  String get failedToLoadMoreTopics => 'トピックをさらに読み込めませんでした。スクロールして再試行してください。';

  @override
  String get failedToUpdateNotificationLevel => '通知レベルを更新できませんでした';

  @override
  String get firstPostsOnly => '最初の投稿のみ';

  @override
  String get ignoredUsers => '無視中のユーザー';

  @override
  String get inTwoHours => '2時間後';

  @override
  String get inviteByEmail => 'メールで招待';

  @override
  String get inviteLinkCopied => '招待リンクをコピーしました';

  @override
  String inviteSentTo(String email) {
    return '$email に招待を送信しました';
  }

  @override
  String get leave => '退出';

  @override
  String get leaveGroup => 'グループを退出';

  @override
  String get leaveGroupQuestion => 'グループを退出しますか？';

  @override
  String get linkCopied => 'リンクをコピーしました';

  @override
  String get loadMore => 'さらに読み込む';

  @override
  String get manageAccountOnWeb => 'ウェブでアカウントを管理';

  @override
  String get merge => '統合';

  @override
  String get mergeIntoTopic => 'トピックに統合';

  @override
  String get newInviteLink => '新しい招待リンク';

  @override
  String get nextWeek => '来週';

  @override
  String get pushNotAvailableInThisBuild => 'このビルドでは利用できません';

  @override
  String get notNow => 'あとで';

  @override
  String tagNotificationLevelUpdated(String tag) {
    return '「$tag」の通知レベルを更新しました';
  }

  @override
  String doNotDisturbOnUntil(String until) {
    return '$until までオン';
  }

  @override
  String get pleaseLogInToBookmark => 'ブックマークするにはログインしてください';

  @override
  String get pleaseLogInToFollowUsers => 'フォローするにはログインしてください';

  @override
  String get pleaseLogInToMarkAnswers => '回答をマークするにはログインしてください';

  @override
  String get pleaseLogInToReact => 'リアクションするにはログインしてください';

  @override
  String get pleaseLogInToVote => '投票するにはログインしてください';

  @override
  String get pushNotifications => 'プッシュ通知';

  @override
  String get relevance => '関連度';

  @override
  String get reminderTimeMustBeInFuture => 'リマインダーの時刻は未来の時刻を指定してください';

  @override
  String get removeBookmark => 'ブックマークを解除';

  @override
  String get removeVote => '投票を取り消す';

  @override
  String get renameTopic => 'トピック名を変更';

  @override
  String reportedBy(String username) {
    return '$username が報告';
  }

  @override
  String get requestToJoin => '参加をリクエスト';

  @override
  String requestToJoinGroup(String group) {
    return '$group への参加をリクエスト';
  }

  @override
  String get reset => 'リセット';

  @override
  String get resizeAndUpload => '縮小してアップロード';

  @override
  String get retryConnection => '再接続';

  @override
  String get reviewQueue => 'レビューキュー';

  @override
  String get revoke => '取り消す';

  @override
  String get revokeInviteQuestion => '招待を取り消しますか？';

  @override
  String get save => '保存';

  @override
  String get sendInvite => '招待を送信';

  @override
  String get sendRequest => 'リクエストを送信';

  @override
  String get settings => '設定';

  @override
  String get showVoters => '投票者を表示';

  @override
  String get signOut => 'サインアウト';

  @override
  String get signOutQuestion => 'サインアウトしますか？';

  @override
  String get signInCancelledNoPayload => 'サインインがキャンセルされました — 応答がありません';

  @override
  String signInFailed(String error) {
    return 'サインインに失敗しました: $error';
  }

  @override
  String get startChat => 'チャットを開始';

  @override
  String stoppedIgnoringUser(String username) {
    return '@$username の無視を解除しました';
  }

  @override
  String get submit => '送信';

  @override
  String get discardDraftWarning => '保存した下書きは完全に削除されます。';

  @override
  String get deleteChatMessageWarning => 'このメッセージは全員から削除されます。';

  @override
  String get titleOnly => 'タイトルのみ';

  @override
  String get tomorrow => '明日';

  @override
  String get turnOff => 'オフにする';

  @override
  String get turnOnNotifications => '通知をオンにする';

  @override
  String get whisper => 'ウィスパー';

  @override
  String likeAgainInSeconds(Object seconds) {
    return '$seconds秒後にもう一度いいねできます';
  }

  @override
  String get loginInfo => 'ログイン情報';

  @override
  String get loginFailed => 'ログインに失敗しました';

  @override
  String get moveToCategory => 'カテゴリに移動';

  @override
  String get undeleteTopic => 'トピックを復元';

  @override
  String get undeleteTopicConfirmation => 'このトピックを復元しますか？他のユーザーに再び表示されます。';

  @override
  String get send => '送信';

  @override
  String get changeEmailExplanation =>
      '新しいメールアドレスに確認リンクを送ります。リンクをクリックすると変更が反映されます。';

  @override
  String get changeEmailSecurityNote =>
      'セキュリティのため、Discourse からメール内のリンクで確認を求められることがあります。届かない場合は迷惑メールフォルダを確認してください。';

  @override
  String get newDirectMessage => '新しいダイレクトメッセージ';

  @override
  String get noMessagesYetSayHi => 'まだメッセージはありません — 挨拶してみましょう。';

  @override
  String get edited => '編集済み';

  @override
  String get editProfileManagedOnWebNote =>
      '表示名、メール、パスワードなどのアカウント設定は「アカウント → ウェブでアカウントを管理」から変更します。アバターは写真のカメラアイコンをタップして変更できます。';

  @override
  String get approvedButRelayUnreachable =>
      '承認されましたが、設定を完了するための ForumCopilot に接続できませんでした。後で設定から再試行してください。';

  @override
  String get notificationsAreTurnedOffForThisApp => 'このアプリの通知はオフになっています';

  @override
  String forumWillAskToApproveNotifications(Object forumName) {
    return '次に、$forumName が「通知」の承認を求めます。';
  }

  @override
  String get approveNotificationsExplanation =>
      '承認すると、通知を確認してこのデバイスに送信できるようになります。この権限では投稿、返信、メッセージの閲覧はできません。';

  @override
  String get forumOwnerPushNote => 'このフォーラムの管理者がアプリの通知を設定すれば、この手順は不要になります。';

  @override
  String get pleaseLoginToCreateANewTopic => '新しいトピックを作成するにはログインしてください';

  @override
  String get pleaseLoginToSubscribeToForums => 'フォーラムを購読するにはログインしてください';

  @override
  String leaveGroupWarning(Object group) {
    return '$group のメンバーではなくなります。いつでも再参加できます。';
  }

  @override
  String get groupMembersPrivate => 'このグループのメンバー一覧は非公開です。';

  @override
  String get unignore => '無視を解除';

  @override
  String get inviteLinkCreated => '招待リンクを作成しました';

  @override
  String expiresOn(Object date) {
    return '$date に期限切れ';
  }

  @override
  String get protected => '保護中';

  @override
  String get solution => '解決策';

  @override
  String get deleted => '削除済み';

  @override
  String get pleaseLoginToViewUserProfiles => 'ユーザープロフィールを見るにはログインしてください。';

  @override
  String get announcement => 'お知らせ';

  @override
  String get solved => '解決済み';

  @override
  String get hot => '注目';

  @override
  String get pinned => '固定';

  @override
  String get subscribedLabel => '購読中';

  @override
  String get locked => 'ロック中';

  @override
  String get poll => '投票';

  @override
  String errorLoadingContent(Object error) {
    return 'コンテンツの読み込みエラー: $error';
  }

  @override
  String get noPermissionToViewSubforum => 'このサブフォーラムのトピックを閲覧する権限がありません。';

  @override
  String get noDiscussionsYet => 'まだ議論はありません。';

  @override
  String get jumpToPost => '投稿へ移動';

  @override
  String get jump => '移動';

  @override
  String get endOfTheDiscussion => '議論の終わり';

  @override
  String get reviewQueueStaffOnly => 'レビューキューはスタッフとレビュアーのみ閲覧できます。';

  @override
  String get nothingToReview => 'レビュー対象はありません';

  @override
  String refreshFailed(Object error) {
    return '更新に失敗しました: $error';
  }

  @override
  String get topicDeletedBanner => 'このトピックは削除され、他のユーザーには表示されません';

  @override
  String get topicClosedBanner => 'このトピックはクローズされ、返信できません';

  @override
  String get topicPinnedBanner => 'このトピックはフォーラムの先頭に固定されています';

  @override
  String get youAreSubscribedToThisTopic => 'このトピックを購読しています';

  @override
  String get refreshing => '更新中...';

  @override
  String get title => 'タイトル';

  @override
  String editedAt(Object time) {
    return '$time に編集';
  }

  @override
  String editReason(Object reason) {
    return '理由: $reason';
  }

  @override
  String get thisDiffIsTooLargeToDisplay => 'この差分は大きすぎて表示できません。';

  @override
  String get noContentChangesInThisRevision => 'この版に内容の変更はありません。';

  @override
  String revisionOf(Object currentVersion, Object versionCount) {
    return '版 $currentVersion / $versionCount';
  }

  @override
  String get editConversation => '会話を編集';

  @override
  String get closeConversation => '会話をクローズ';

  @override
  String get openConversation => '会話を再開';

  @override
  String get leaveConversation2 => '会話から退出';

  @override
  String get reportConversation2 => '会話を報告';

  @override
  String get closeConversation2 => '会話をクローズ';

  @override
  String get closeConversationConfirmation => 'この会話をクローズしますか？新しい返信ができなくなります。';

  @override
  String get close => '閉じる';

  @override
  String get openConversation2 => '会話を再開';

  @override
  String get openConversationConfirmation => 'この会話を再開しますか？新しい返信ができるようになります。';

  @override
  String get open => '開く';

  @override
  String get leaveConversation3 => '会話から退出';

  @override
  String get leaveConversationConfirmation => 'この会話から退出しますか？受信トレイに表示されなくなります。';

  @override
  String errorLoadingConversation(Object error) {
    return '会話の読み込みエラー: $error';
  }

  @override
  String get conversationNotFound => '会話が見つかりません';

  @override
  String get conversationClosedBanner => 'この会話はクローズされ、返信できません';

  @override
  String get noMessagesFound => 'メッセージが見つかりません';

  @override
  String get endOfConversation => '会話の終わり';

  @override
  String get jumpToMessage => 'メッセージへ移動';

  @override
  String get editConversation2 => '会話を編集';

  @override
  String get failedToLoadMessage2 => 'メッセージを読み込めませんでした';

  @override
  String get cannotEditThisConversation => 'この会話は編集できません';

  @override
  String get options => 'オプション';

  @override
  String get conversationOpen => '会話をオープンにする';

  @override
  String failedToCreateConversation(Object error) {
    return '会話を作成できませんでした: $error';
  }

  @override
  String maximumAttachmentsAllowed(Object count) {
    return '添付ファイルは最大 $count 件までです';
  }

  @override
  String get noImagesFoundToDisplay => '表示できる画像がありません。';

  @override
  String get pleaseLoginToViewThisAttachment => 'この添付ファイルを見るにはログインしてください';

  @override
  String get searchForTopics => 'トピックを検索';

  @override
  String get noTopicsFound => 'トピックが見つかりません';

  @override
  String get trySearchingWithDifferentKeywords => '別のキーワードで検索してみてください';

  @override
  String get noPostsFound => '投稿が見つかりません';

  @override
  String get perTopicNotificationLevelsNote =>
      'カテゴリ別・トピック別の通知レベルは各画面で設定します — トピックやカテゴリのベルアイコンをタップしてください。';

  @override
  String get pushNotActiveForThisLogin =>
      'このログインでは無効です — ログアウトして再ログインするとプッシュ通知を許可できます';

  @override
  String get pauseNotificationsFor => '通知を一時停止する期間…';

  @override
  String get doNotDisturbExplanation =>
      '通知をしばらく停止します — 期間が終わるまで Discourse が保留します';

  @override
  String get emailSettingsSubtitle => 'メールの頻度、いいねの集約、ダイジェストの予定';

  @override
  String get manageAccountSubtitle => 'プロフィール、メール、パスワード、セキュリティ、詳細設定';

  @override
  String get changePasswordSubtitle => '現在のメールアドレスにパスワード再設定メールを送ります';

  @override
  String get ignoredUsersSubtitle => '投稿が非表示になっているユーザーを確認・管理';

  @override
  String get deleteAccountExplanation =>
      'アカウントの削除はフォーラム側で行います。「続行」でサイトを開き、スタッフに連絡してください — Discourse フォーラムは各自のポリシーで削除を処理します。';

  @override
  String get verificationEmailSent =>
      '確認メールを送信しました — リンクをクリックして新しいアドレスを確認してください。';

  @override
  String get passwordResetExplanation =>
      'パスワード再設定リンクをメールで送ります。リンクから新しいパスワードを設定してください — 変更はこのアプリではなくフォーラム側で行われます。';

  @override
  String get sendResetEmail => '再設定メールを送信';

  @override
  String get deleteAccountDialogBody =>
      'アカウントはフォーラムが管理しています。削除はフォーラムのスタッフに直接依頼してください。「続行」でブラウザにフォーラムを開き、サイトの連絡・スタッフメッセージ機能を利用できます。';

  @override
  String get initializingForum => 'フォーラムを初期化しています…';

  @override
  String get unableToLoadForums => 'フォーラムを読み込めません';

  @override
  String get noForumsToDisplayExplanation =>
      '表示するフォーラムがありません。権限またはフォーラムの構成が原因の可能性があります。';

  @override
  String get subscribedForums => '購読中のフォーラム';

  @override
  String get errorLoadingNotifications => '通知の読み込みエラー';

  @override
  String get pullDownToRefresh => '下に引いて更新';

  @override
  String get noNewNotificationsExplanation =>
      '新しい通知はありません。フォロー中のトピックの更新は後で確認してください。';

  @override
  String noTagsMatch(Object filter) {
    return '「$filter」に一致するタグはありません。';
  }

  @override
  String noTopicsTagged(Object tag) {
    return '「$tag」タグのトピックはありません';
  }

  @override
  String failedToBanUser2(Object error) {
    return 'ユーザーを利用停止にできませんでした: $error';
  }

  @override
  String unbanUserConfirmation(Object username) {
    return '$username の利用停止を解除しますか？';
  }

  @override
  String failedToUnbanUser2(Object error) {
    return '利用停止を解除できませんでした: $error';
  }

  @override
  String get deletePostsProfilePostsAndComments => '投稿、プロフィール投稿、コメントを削除';

  @override
  String spamCleanConfirmation(Object username) {
    return '$username のスパムを一掃しますか？';
  }

  @override
  String failedToCleanSpam(Object error) {
    return 'スパムを一掃できませんでした: $error';
  }

  @override
  String get searchUser => 'ユーザーを検索';

  @override
  String get tapToOpen => 'タップして開く';

  @override
  String get imageNotAvailable => '画像を表示できません';

  @override
  String get allForumTopicsHaveBeenMarkedAs => 'フォーラムの全トピックを既読にしました';

  @override
  String postsCount(Object count) {
    return '$count 件の投稿';
  }

  @override
  String get permissionDeniedToSaveImage => '画像を保存する権限がありません';

  @override
  String get postNotFound => '投稿が見つかりません。';

  @override
  String get failedToUploadFilePleaseTryAgain =>
      'ファイルをアップロードできませんでした。もう一度お試しください。';

  @override
  String failedToUploadFile2(Object errorMessage) {
    return 'ファイルをアップロードできませんでした: $errorMessage';
  }

  @override
  String get failedToPickFile => 'ファイルを選択できませんでした';

  @override
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return 'あと $remainingSlots 件のみ添付できます。最初の $remainingSlots2 枚を処理します。';
  }

  @override
  String get attachmentLimitReachedSkippingRemainingImages =>
      '添付ファイルの上限に達しました。残りの画像はスキップします。';

  @override
  String failedToUploadImagePleaseTryAgain(Object fileName) {
    return '$fileName: 画像をアップロードできませんでした。もう一度お試しください。';
  }

  @override
  String failedToUploadImage2(Object errorMessage, Object fileName) {
    return '$fileName: 画像をアップロードできませんでした: $errorMessage';
  }

  @override
  String get failedToPickImage => '画像を選択できませんでした';

  @override
  String failedToRemoveAttachment2(Object error) {
    return '添付ファイルを削除できませんでした: $error';
  }

  @override
  String sentFromMobileApp(Object siteName) {
    return '$siteName モバイルアプリから送信';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      '添付ファイルのアップロード完了までお待ちください';

  @override
  String get imageIsTooLargeToUpload => '画像が大きすぎてアップロードできません';

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName は $fileBytes です。このフォーラムの上限は $maxBytes です。';
  }

  @override
  String get resizeToFitExplanation =>
      '形式を保ったまま、上限内に収まるぎりぎりまで縮小し、できるだけ画質を維持します。';

  @override
  String get failedToPostReplyPleaseTryAgain => '返信を投稿できませんでした。もう一度お試しください。';

  @override
  String get pleaseWaitForTheThreadToLoad => 'トピックの読み込みが終わるまでお待ちください';

  @override
  String get failedToUpdatePostPleaseTryAgain => '投稿を更新できませんでした。もう一度お試しください。';

  @override
  String get postDeletedSuccessfully => '投稿を削除しました';

  @override
  String failedToDeletePost(Object error) {
    return '投稿を削除できませんでした: $error';
  }

  @override
  String failedToSubmitReport2(Object error) {
    return '報告を送信できませんでした: $error';
  }

  @override
  String get editHistoryNotAvailable => 'この投稿の編集履歴は利用できません';

  @override
  String get noPermissionToUploadAvatar => 'アバターをアップロードする権限がありません';

  @override
  String get avatarUploadedSuccessfully => 'アバターをアップロードしました';

  @override
  String failedToPickImage2(Object error) {
    return '画像を選択できませんでした: $error';
  }

  @override
  String get react => 'リアクション';

  @override
  String get reactionsAreNotEnabledOnThisForum => 'このフォーラムではリアクションが有効になっていません。';

  @override
  String get noReactionsYet => 'まだリアクションはありません';

  @override
  String get searchFilters => '検索フィルター';

  @override
  String signOutWarning(Object siteName) {
    return '$siteName からサインアウトします。いつでも再度サインインできます。';
  }

  @override
  String get suggestedTopics => 'おすすめのトピック';

  @override
  String get newLabel => '新着';

  @override
  String get voteRemoved => '投票を取り消しました';

  @override
  String get voters => '投票者';

  @override
  String get noVotesYet => 'まだ投票はありません。';

  @override
  String get trustLevels => '信頼レベル';

  @override
  String get trustLevelsExplanation =>
      'メンバーは閲覧と参加によって信頼を積み上げます。レベルが上がるごとに新しい機能が使えるようになります。';

  @override
  String get activity => 'アクティビティ';

  @override
  String get dontUpload => 'アップロードしない';

  @override
  String get dontAskAgainAlwaysResize => '今後表示しない — 常に縮小して合わせる';

  @override
  String get couldNotLoadCategories => 'カテゴリを読み込めませんでした。';
}
