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
  String get newConversation => '新規メッセージ';

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
    return '$username をメッセージに招待しました';
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
  String get deleteConversations => 'メッセージを削除';

  @override
  String get noConversations => 'メッセージはありません';

  @override
  String get noConversationsMessage => 'まだメッセージはありません。新しいメッセージを書いて始めましょう。';

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
  String get sendMessage => 'メッセージ';

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
  String get failedToSaveConversation => 'メッセージを保存できませんでした';

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
  String get youNeedToBeSignedInToViewConversations => 'メッセージを見るにはサインインが必要です。';

  @override
  String errorLoadingConversations(String error) {
    return 'メッセージの読み込みエラー: $error';
  }

  @override
  String failedToLeaveConversation(String error) {
    return 'メッセージから退出できませんでした: $error';
  }

  @override
  String errorLoadingMoreConversations(String error) {
    return 'さらにメッセージを読み込む際のエラー: $error';
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
  String get markAsUnread => '未読にする';

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
  String get appearance => '外観';

  @override
  String get appearanceSystem => '端末の設定';

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
  String get deletePrivateConversations => '個人メッセージを削除';

  @override
  String get banTheUserAccount => 'ユーザーアカウントを禁止';

  @override
  String get handledThreads => '処理されたスレッド';

  @override
  String get deletedMessages => '削除されたメッセージ';

  @override
  String get deletedConversations => '削除されたメッセージ';

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
  String get conversationCreatedSuccessfully => 'メッセージを送信しました';

  @override
  String get conversationMarkedAsUnread => 'メッセージを未読にしました';

  @override
  String get conversationClosed => 'メッセージをクローズしました';

  @override
  String get conversationOpened => 'メッセージをオープンしました';

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
    return 'メッセージを未読にできませんでした: $error';
  }

  @override
  String failedToCloseConversation(String error) {
    return 'メッセージをクローズできませんでした: $error';
  }

  @override
  String failedToOpenConversation(String error) {
    return 'メッセージをオープンできませんでした: $error';
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
  String get enterConversationTitle => 'メッセージのタイトルを入力';

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
  String get conversationUpdatedSuccessfully => 'メッセージを更新しました';

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
  String get download => 'ダウンロード';

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
  String get checkConnectionAndRetry => 'インターネット接続を確認して、もう一度お試しください。';

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
      '承認されましたが、設定を完了するための通知サーバーに接続できませんでした。後で設定から再試行してください。';

  @override
  String get notificationsAreTurnedOffForThisApp => 'このアプリの通知はオフになっています';

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
  String get editConversation => 'タイトルを編集';

  @override
  String get closeConversation => 'メッセージをクローズ';

  @override
  String get openConversation => 'メッセージをオープン';

  @override
  String get leaveConversation2 => 'メッセージから退出';

  @override
  String get reportConversation2 => 'メッセージを通報';

  @override
  String get closeConversation2 => 'メッセージをクローズ';

  @override
  String get closeConversationConfirmation => 'このメッセージをクローズしますか？新たに返信できなくなります。';

  @override
  String get close => '閉じる';

  @override
  String get openConversation2 => 'メッセージをオープン';

  @override
  String get openConversationConfirmation => 'このメッセージをオープンしますか？再び返信できるようになります。';

  @override
  String get open => '開く';

  @override
  String get leaveConversation3 => 'メッセージから退出';

  @override
  String get leaveConversationConfirmation =>
      'このメッセージから自分自身を削除してもよろしいですか？このメッセージの閲覧または返信を行えなくなります。';

  @override
  String errorLoadingConversation(Object error) {
    return 'メッセージの読み込みエラー: $error';
  }

  @override
  String get conversationNotFound => 'メッセージが見つかりません';

  @override
  String get conversationClosedBanner => 'このメッセージはクローズしています。新たに返信することはできません。';

  @override
  String get noMessagesFound => 'メッセージが見つかりません';

  @override
  String get endOfConversation => '議論の終わり';

  @override
  String get jumpToMessage => 'メッセージへ移動';

  @override
  String get editConversation2 => 'タイトルを編集';

  @override
  String get failedToLoadMessage2 => 'メッセージを読み込めませんでした';

  @override
  String get cannotEditThisConversation => 'このメッセージは編集できません';

  @override
  String get options => 'オプション';

  @override
  String get conversationOpen => '返信を受け付ける';

  @override
  String get messageTitleHint => 'タイトルを入力してください';

  @override
  String get messageOpenForReplies => '新しい返信を受け付けています';

  @override
  String get messageClosedForReplies => 'クローズ: 新しい返信は受け付けません';

  @override
  String get messageSentWithoutId =>
      'メッセージは送信されましたが、フォーラムから返されませんでした。メッセージ一覧を確認してください。';

  @override
  String get messageCouldNotBeSent => 'メッセージを送信できませんでした。';

  @override
  String get messageIdMissing => 'このメッセージを開けません: ID がありません。';

  @override
  String get pleaseAddARecipient => '宛先を 1 人以上追加してください';

  @override
  String get archiveMessage => 'アーカイブ';

  @override
  String get moveToInbox => '受信トレイに移動';

  @override
  String get messageInbox => '受信トレイ';

  @override
  String get messageArchive => 'アーカイブ';

  @override
  String get messageListUnread => '未読';

  @override
  String get messageListNew => '新規';

  @override
  String get messageListSent => '送信済み';

  @override
  String removeFromMessageConfirm(String name) {
    return 'このメッセージから $name を削除してもよろしいですか？';
  }

  @override
  String uploadingFilename(String filename) {
    return 'アップロード中: $filename…';
  }

  @override
  String get messageArchived => 'メッセージをアーカイブしました';

  @override
  String get messageMovedToInbox => '受信トレイに移動しました';

  @override
  String failedToArchiveMessage(Object error) {
    return 'メッセージをアーカイブできませんでした: $error';
  }

  @override
  String failedToMoveMessageToInbox(Object error) {
    return 'メッセージを受信トレイに移動できませんでした: $error';
  }

  @override
  String get noArchivedMessages => 'アーカイブしたメッセージはありません';

  @override
  String get noArchivedMessagesHint => 'メッセージの ⋮ メニューからアーカイブすると、ここに保管されます。';

  @override
  String groupHasBeenInvited(String group) {
    return '$group をメッセージに招待しました';
  }

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
  String get chatChannels => 'チャンネル';

  @override
  String get chatDms => 'DM';

  @override
  String get chatNoChannels => 'まだチャンネルに参加していません！';

  @override
  String get chatNoDms => 'まだダイレクトメッセージに参加していません！';

  @override
  String get chatNoDmsCta => '会話を始める';

  @override
  String chatPlaceholderChannel(String channel) {
    return '$channel 内でチャット';
  }

  @override
  String chatPlaceholderUsers(String names) {
    return '$names とチャット';
  }

  @override
  String get chatPlaceholderGroup => 'グループチャット';

  @override
  String get chatPlaceholderSelf => 'メモを書き留める';

  @override
  String get chatPlaceholderArchived => 'チャンネルはアーカイブされているため、新しいメッセージを送信できません。';

  @override
  String get chatPlaceholderClosed => 'チャンネルは閉鎖されているため、新しいメッセージを送信できません。';

  @override
  String get chatPlaceholderReadOnly => 'チャンネルは読み取り専用であるため、新しいメッセージを送信できません。';

  @override
  String get chatPlaceholderSilenced => '現在、メッセージを送信できません。';

  @override
  String get chatDeleteConfirm => 'このメッセージを削除してもよろしいですか？';

  @override
  String get chatStartNewDm => '新しい DM を開始';

  @override
  String get chatCreatePersonal => 'パーソナルチャットを作成';

  @override
  String get chatCreateGroup => 'グループチャットを作成';

  @override
  String get chatCannotCreate => 'ダイレクトメッセージを送信できません。';

  @override
  String get chatDisabledUser => 'はチャットを無効にしました';

  @override
  String get chatSearchPlaceholder => '@somebody';

  @override
  String get chatAddMorePlaceholder => '...さらにメンバーを追加';

  @override
  String chatUserNotFound(String name) {
    return '@$name が見つかりません';
  }

  @override
  String get chatCouldNotStartDm => 'チャットを開始できませんでした。';

  @override
  String get chatSignInTitle => 'チャットを使うにはサインインしてください';

  @override
  String get chatSignInMessage => 'チャットチャンネルを表示して参加するにはサインインが必要です。';

  @override
  String get chatDirectMessage => 'ダイレクトメッセージ';

  @override
  String get chatNotAvailable => 'このフォーラムではチャットを利用できません。';

  @override
  String get chatAttachFile => 'ファイルを添付する';

  @override
  String get chatRemoveUpload => 'ファイルを削除する';

  @override
  String get takePhoto => '写真を撮る';

  @override
  String get postNeedsApprovalTitle => '承認待ちの投稿';

  @override
  String get postNeedsApprovalBody =>
      'あなたの新しい投稿を受領しましたが、表示するにはモデレーターの承認が必要です。しばらくお待ちください。';

  @override
  String failedToCreateConversation(Object error) {
    return 'メッセージを送信できませんでした: $error';
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
      'フォーラムが許可していれば、アカウントと投稿を削除できます。許可していない場合は、スタッフに削除を依頼できます。';

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
  String get suggestedMessages => '推奨メッセージ';

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

  @override
  String get explore => '探索';

  @override
  String get tags => 'タグ';

  @override
  String get community => 'コミュニティ';

  @override
  String get users => 'ユーザー';

  @override
  String get groups => 'グループ';

  @override
  String get invites => '招待';

  @override
  String get account => 'アカウント';

  @override
  String get drafts => '下書き';

  @override
  String get termsOfService => '利用規約';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String signedInAs(String username) {
    return '$username としてサインイン中';
  }

  @override
  String get notSignedIn => 'サインインしていません';

  @override
  String get deviceWillNotShowAlertsUntilAllowedInSettings =>
      '設定で通知を許可するまで、この端末には通知が表示されません。';

  @override
  String get openSettings => '設定を開く';

  @override
  String get notificationsOnThisDevice => 'この端末での通知';

  @override
  String get notificationsGrantOnSubtitle => 'このフォーラムの返信、メンション、メッセージがここに届きます。';

  @override
  String get notificationsGrantOffSubtitle =>
      'フォーラムで一度承認すると、返信、メンション、メッセージがここに届きます。';

  @override
  String get turnOn => 'オンにする';

  @override
  String get couldNotTurnOffNotifications => '通知をオフにできませんでした。後でもう一度お試しください。';

  @override
  String actionCodeTopicCreated(String when) {
    return 'Created this topic $when';
  }

  @override
  String actionCodePublicTopic(String when) {
    return 'トピックを公開しました: $when';
  }

  @override
  String actionCodeOpenTopic(String when) {
    return 'これをトピックに変換しました: $when';
  }

  @override
  String actionCodePrivateTopic(String when) {
    return 'このトピックを個人メッセージにしました: $when';
  }

  @override
  String actionCodeSplitTopic(String when) {
    return 'このトピックを分割しました: $when';
  }

  @override
  String actionCodeInvitedUser(String who, String when) {
    return '$who を招待しました: $when';
  }

  @override
  String actionCodeInvitedGroup(String who, String when) {
    return '$who を招待しました: $when';
  }

  @override
  String actionCodeUserLeft(String who, String when) {
    return '$who は $when にこのメッセージから退出しました';
  }

  @override
  String actionCodeRemovedUser(String who, String when) {
    return '$who を削除しました: $when';
  }

  @override
  String actionCodeRemovedGroup(String who, String when) {
    return '$who を削除しました: $when';
  }

  @override
  String actionCodeAutobumped(String when) {
    return '自動的にバンプされました: $when';
  }

  @override
  String actionCodeTagsChanged(String when) {
    return 'タグが更新されました: $when';
  }

  @override
  String actionCodeCategoryChanged(String when) {
    return 'カテゴリが更新されました: $when';
  }

  @override
  String get actionCodeForwarded => '上記のメールを転送しました';

  @override
  String actionCodeAutoclosedEnabled(String when) {
    return 'クローズされました: $when';
  }

  @override
  String actionCodeAutoclosedDisabled(String when) {
    return 'オープンされました: $when';
  }

  @override
  String actionCodeClosedEnabled(String when) {
    return 'クローズされました: $when';
  }

  @override
  String actionCodeClosedDisabled(String when) {
    return 'オープンされました: $when';
  }

  @override
  String actionCodeArchivedEnabled(String when) {
    return 'アーカイブされました: $when';
  }

  @override
  String actionCodeArchivedDisabled(String when) {
    return 'アーカイブを解除されました: $when';
  }

  @override
  String actionCodePinnedEnabled(String when) {
    return '固定しました: $when';
  }

  @override
  String actionCodePinnedDisabled(String when) {
    return '固定解除しました: $when';
  }

  @override
  String actionCodePinnedGloballyEnabled(String when) {
    return '全体に固定しました: $when';
  }

  @override
  String actionCodePinnedGloballyDisabled(String when) {
    return '固定解除しました: $when';
  }

  @override
  String actionCodeVisibleEnabled(String when) {
    return '表示: $when';
  }

  @override
  String actionCodeVisibleDisabled(String when) {
    return '非表示: $when';
  }

  @override
  String actionCodeBannerEnabled(String when) {
    return '$whenにこれをバナーにしました。ユーザーが閉じるまで各ページの上部に表示されます。';
  }

  @override
  String actionCodeBannerDisabled(String when) {
    return '$whenにこのバナーを削除しました。今後ページの上部に表示されることはありません。';
  }

  @override
  String actionCodeAssigned(String who, String when) {
    return '$who を割り当てました: $when';
  }

  @override
  String actionCodeUnassigned(String who, String when) {
    return '$who の割り当てを解除しました: $when';
  }

  @override
  String actionCodeReassigned(String who, String when) {
    return '$who を再割り当てしました: $when';
  }

  @override
  String localDateToday(String time) {
    return '今日 $time';
  }

  @override
  String localDateTomorrow(String time) {
    return '明日 $time';
  }

  @override
  String localDateYesterday(String time) {
    return '昨日 $time';
  }

  @override
  String get eventExpired => '期限切れ';

  @override
  String get eventEveryDay => '毎日';

  @override
  String get eventEveryWeekday => 'すべての平日';

  @override
  String get eventEveryWeek => '毎週この平日';

  @override
  String get eventEveryTwoWeeks => '隔週この平日';

  @override
  String get eventEveryFourWeeks => '4 週間ごとのこの平日';

  @override
  String get eventEveryMonth => '毎月この平日';

  @override
  String get errorNoConnection => 'フォーラムに接続できませんでした。接続を確認して、もう一度お試しください。';

  @override
  String get errorTimedOut => 'フォーラムの応答に時間がかかりすぎています。もう一度お試しください。';

  @override
  String get errorPaywalled => 'このコンテンツはフォーラムの有料会員限定です。';

  @override
  String get errorBlocked =>
      'フォーラムのファイアウォールによってアプリがブロックされました。しばらくしてから再度お試しいただくか、ブラウザでフォーラムを開いてください。';

  @override
  String get errorNotAllowed => 'アクセスする権限がありません。ログインすると閲覧できる場合があります。';

  @override
  String get errorNotFound => '存在しないか、削除されています。';

  @override
  String get errorRateLimited => '操作の頻度が高すぎます。しばらく待ってからもう一度お試しください。';

  @override
  String get errorForumDown => 'フォーラムが現在応答していません。しばらくしてからもう一度お試しください。';

  @override
  String get deleteSpammer => '迷惑行為者を削除';

  @override
  String get yesDeleteSpammer => 'はい、迷惑行為者を削除する';

  @override
  String get deleteSpammerConfirm =>
      'このユーザーの投稿とトピックを削除し、アカウントを削除し、IP アドレスからの登録をブロックし、メールアドレスを永久ブロックリストに追加しようとしています。このユーザーは本当に迷惑行為者ですか？';

  @override
  String get userWasDeleted => 'ユーザーが削除されました。';

  @override
  String get deleteMyAccount => 'アカウントを削除';

  @override
  String get deleteAccountConfirm => 'アカウントを永久に削除してもよろしいですか？この操作は元に戻せません！';

  @override
  String get deletedYourself => 'あなたのアカウントは正常に削除されました。';

  @override
  String get deleteYourselfNotAllowed => 'アカウントの削除を希望する場合は、スタッフメンバーに連絡をしてください。';

  @override
  String get createTopic => 'トピックを作成';

  @override
  String get discardPostQuestion => '投稿を破棄しますか？';

  @override
  String get discardChangesQuestion => '変更を破棄しますか？';

  @override
  String get discardChanges => '変更を破棄';

  @override
  String get saveDraft => '下書きを保存';

  @override
  String get notificationSettings => '通知設定';

  @override
  String get topicIsNew => 'New topic';

  @override
  String get noNewTopicsSinceLastVisit =>
      'No new topics since your last visit.';

  @override
  String get messageIsNew => 'New message';

  @override
  String topicUnreadReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread replies',
      one: '1 unread reply',
    );
    return '$_temp0';
  }

  @override
  String filterNewWithCount(int count) {
    return 'New ($count)';
  }

  @override
  String filterUnreadWithCount(int count) {
    return 'Unread ($count)';
  }

  @override
  String categoryNewTopics(int count) {
    return '$count new';
  }

  @override
  String categoryUnreadTopics(int count) {
    return '$count unread';
  }

  @override
  String get dismissNew => 'Dismiss new';

  @override
  String get dismissUnread => 'Dismiss unread';

  @override
  String get dismissNewTitle => 'Dismiss new topics?';

  @override
  String get dismissNewMessage => 'They will no longer show as new.';

  @override
  String get dismissUnreadTitle => 'Dismiss all unread?';

  @override
  String get dismissUnreadMessage =>
      'Their new replies will be marked as read.';

  @override
  String get dismissUnreadStopTracking =>
      'Stop tracking these topics so they never show up as unread for me again';

  @override
  String get dismissNewAndUnread => 'Dismiss new and unread';

  @override
  String dismissNewAndUnreadMessage(String category) {
    return 'Topics in $category will no longer show as new or unread.';
  }

  @override
  String get dismissedTopics => 'Dismissed';

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
  String get markAsSolution => '解決策としてマーク';

  @override
  String get unmarkAsSolution => '解決策のマークを解除';

  @override
  String searchForumName(String forum) {
    return '$forumを検索';
  }

  @override
  String countActiveThisMonth(String formatted) {
    return '今月のアクティブ $formatted';
  }

  @override
  String countMembers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'メンバー $formatted',
    );
    return '$_temp0';
  }

  @override
  String countTopics(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'トピック $formatted',
    );
    return '$_temp0';
  }

  @override
  String categoryNewThisWeek(int count) {
    return '今週の新着 $count';
  }

  @override
  String get categoriesView => 'カテゴリ';

  @override
  String get allCategories => 'すべてのカテゴリ';

  @override
  String get allTags => 'すべてのタグ';

  @override
  String get myPosts => '自分の投稿';

  @override
  String get drawerIntroduction =>
      'このフォーラムのカテゴリ、タグ、アカウントはすべてこのメニューにあります。メニューボタンからいつでも開けます。';

  @override
  String trustLevelN(int level) {
    return '信頼レベル $level';
  }

  @override
  String get filterNew => '新着';

  @override
  String get filterTop => 'トップ';

  @override
  String get levelWatching => 'ウォッチ中';

  @override
  String get levelWatchingFirstPost => '最初の投稿をウォッチ';

  @override
  String get levelTracking => '追跡中';

  @override
  String get levelNormal => '通常';

  @override
  String get levelMuted => 'ミュート';

  @override
  String get chooseCategory => 'カテゴリを選択';

  @override
  String get signInToPostAndGetNotifications => 'ログインして投稿や通知を利用';

  @override
  String forumBlocksNotificationServer(Object forumName) {
    return '$forumName が通知サーバーをブロックしているため、通知が届かない場合があります。設定でオフにできます。';
  }

  @override
  String get relatedTopics => '関連トピック';

  @override
  String get relatedMessages => '関連メッセージ';

  @override
  String moreInCategory(String category) {
    return '$category のトピックをもっと見る';
  }

  @override
  String get latestTopics => '最新のトピック';

  @override
  String get pushGroupMessages => 'メッセージとチャット';

  @override
  String get pushGroupMessagesHint => '個人メッセージ、グループの受信箱、チャット';

  @override
  String get pushGroupReplies => '返信とメンション';

  @override
  String get pushGroupRepliesHint => '返信、メンション、引用、ウォッチ中のトピック';

  @override
  String get pushGroupReactions => 'いいねとリアクション';

  @override
  String get pushGroupReactionsHint => 'あなたの投稿へのいいねとリアクション';

  @override
  String get pushGroupOther => 'その他すべて';

  @override
  String get pushGroupOtherHint => 'バッジ、リマインダー、採用された回答など';

  @override
  String get pushChannelOther => 'その他の通知';

  @override
  String get couldNotChangePushSetting =>
      'この設定を変更できませんでした。しばらくしてからもう一度お試しください。';

  @override
  String neverMissAReplyOn(Object forumName) {
    return '$forumName の返信を見逃さない';
  }

  @override
  String get notificationsPitch =>
      '返信、メンション、メッセージ、チャットをロック画面に。通常は 10 分以内に届きます。どれを受け取るかは設定でいつでも選べます。';

  @override
  String get notificationsStepAllow => 'この端末で通知を許可';

  @override
  String get notificationsStepAllowed => 'この端末で通知が許可されています';

  @override
  String notificationsStepApprove(Object forumName) {
    return '$forumName で承認';
  }

  @override
  String get notificationsReadOnlyNote => '読み取り専用：投稿、返信、メッセージの閲覧はできません';

  @override
  String get notificationPreviewReply => 'Jane があなたに返信しました：ようこそ！見つけてくれてうれしいです。';

  @override
  String get notificationPreviewMessage => 'Sam からメッセージ：金曜日は来ますか？';

  @override
  String get notificationPreviewNow => '今';

  @override
  String get notificationPreviewEarlier => '5分前';

  @override
  String get activityReplied => '返信';

  @override
  String get activityStartedTopic => 'トピックを作成';

  @override
  String get activityLiked => 'いいね';

  @override
  String get activitySolution => '解決策';

  @override
  String get activityAcceptedBy => '承認者:';

  @override
  String get activityAwaitingApproval => '承認待ち';

  @override
  String get activityFilterTopics => 'トピック';

  @override
  String get activityFilterReplies => '返信';

  @override
  String get activityFilterLikes => 'いいね';

  @override
  String get activityFilterPending => '保留中';

  @override
  String get sectionToday => '今日';

  @override
  String get sectionThisWeek => '今週';

  @override
  String get sectionEarlier => 'それ以前';

  @override
  String draftsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '下書きが $count 件あります',
    );
    return '$_temp0';
  }

  @override
  String get resumeDrafts => '再開';

  @override
  String get myPostsEmpty => 'まだ投稿がありません';

  @override
  String get myPostsEmptyHint => '作成したトピックや書いた返信がここに表示されます。';

  @override
  String get activityEmptyTopics => 'まだトピックがありません';

  @override
  String get activityEmptyReplies => 'まだ返信がありません';

  @override
  String get activityEmptyLikes => 'まだいいねしていません';

  @override
  String get activityEmptySolved => 'まだ解決策がありません';

  @override
  String get viewProfile => 'プロフィールを見る';

  @override
  String get yourStuff => 'あなたのもの';

  @override
  String get accountAndPrivacy => 'アカウントとプライバシー';

  @override
  String profileStatPosts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '投稿',
    );
    return '$_temp0';
  }

  @override
  String profileStatLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'いいね',
    );
    return '$_temp0';
  }

  @override
  String profileStatDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '日',
    );
    return '$_temp0';
  }

  @override
  String get profileStatSolved => '解決';

  @override
  String joinForum(String forum) {
    return '$forum に参加';
  }

  @override
  String get guestBenefitPost => '返信してトピックを作成';

  @override
  String get guestBenefitNotify => '返信があったら通知を受け取る';

  @override
  String get guestBenefitSave => '投稿をブックマークし、下書きを保存';

  @override
  String get guestBenefitChat => 'チャットとメッセージ';

  @override
  String get createAccount => 'アカウントを作成';

  @override
  String get aboutThisForum => 'このフォーラムについて';

  @override
  String get drawerMore => 'その他';

  @override
  String get goToYourProfile => 'プロフィールへ';

  @override
  String profileJoined(String date) {
    return '$date に参加';
  }

  @override
  String profileSeen(String when) {
    return '最終アクセス $when';
  }

  @override
  String profileLocalTime(String time) {
    return '現地時間 $time';
  }

  @override
  String get profileTabSummary => '概要';

  @override
  String get summaryTopReplies => '人気の返信';

  @override
  String get summaryTopTopics => '人気のトピック';

  @override
  String get summaryMostLikedBy => 'いいねをくれた人';

  @override
  String get summaryMostLiked => 'いいねした相手';

  @override
  String get summaryMostRepliedTo => 'よく返信する相手';

  @override
  String get summaryTopLinks => '人気のリンク';

  @override
  String get summaryTopCategories => 'よく投稿するカテゴリ';

  @override
  String get featuredTopic => '注目のトピック';

  @override
  String get profileDetails => '詳細';

  @override
  String get followUser => 'フォロー';

  @override
  String get unfollowUser => 'フォロー解除';

  @override
  String get profileSuspended => '停止中';

  @override
  String get searchBookmarks => 'ブックマークを検索';

  @override
  String get bookmarksFilterReminders => 'リマインダー';

  @override
  String get bookmarkWholeTopic => 'トピック全体';

  @override
  String bookmarkSaved(String when) {
    return '$whenに保存';
  }

  @override
  String bookmarkPostNumber(int number) {
    return '投稿 #$number';
  }

  @override
  String reminderToday(String time) {
    return '今日 $time';
  }

  @override
  String reminderTomorrow(String time) {
    return '明日 $time';
  }

  @override
  String reminderDue(String when) {
    return '期限 · $when';
  }

  @override
  String get addBookmarkLabel => 'ラベルを追加';

  @override
  String get editBookmarkLabel => 'ラベルを編集';

  @override
  String get bookmarkLabelHint => '何のためのものですか？';

  @override
  String get pinBookmark => '上部に固定';

  @override
  String get unpinBookmark => '固定を解除';

  @override
  String get bookmarkRemoved => 'ブックマークを削除しました';

  @override
  String get undo => '元に戻す';

  @override
  String get bookmarksNoMatch => '一致するブックマークはありません';

  @override
  String get addReminder => 'リマインダーを追加';

  @override
  String get bookmarksEmpty => 'まだブックマークはありません';

  @override
  String get bookmarksEmptyHint => '投稿の操作からブックマークすると、ここに表示されます。';

  @override
  String get draftKindNewTopic => '新しいトピック';

  @override
  String draftMessageTo(String names) {
    return '$names へのメッセージ';
  }

  @override
  String get untitledTopic => '無題のトピック';

  @override
  String get draftDiscarded => '下書きを破棄しました';

  @override
  String get draftsEmpty => 'まだ下書きはありません';

  @override
  String get draftsEmptyHint => '下書きは入力中に自動保存されます。返信やトピックを書き始めると、ここに表示されます。';

  @override
  String get privacySection => 'プライバシー';

  @override
  String get changeEmailSubtitle => '新しいアドレスに確認リンクを送信します';

  @override
  String get aboutMe => 'About me';

  @override
  String get aboutMeHelper => 'Shown at the top of your profile';

  @override
  String get aboutMeMarkdownHint => 'Markdown works: **bold**, links, :emoji:';

  @override
  String get addCover => 'Add cover';

  @override
  String get changeCover => 'Change cover';

  @override
  String get birthdayHint =>
      'The forum celebrates it with you. No year is kept.';

  @override
  String get birthdayRemoved => 'Birthday removed';

  @override
  String get birthdaySaved => 'Birthday saved';

  @override
  String get cardBackground => 'Card background';

  @override
  String get cardBackgroundExplanation =>
      'Behind your user card on the forum\'s website';

  @override
  String get cardBackgroundRemoved => 'Card background removed';

  @override
  String get cardBackgroundSheetHint =>
      'Shown behind your user card. Wide photos work best.';

  @override
  String get changeProfilePicture => 'Change profile picture';

  @override
  String get changeUsername => 'Change username';

  @override
  String changeUsernameExplanation(String username) {
    return 'Mentions and quotes of @$username in posts switch to the new name. Old links to your profile stop working.';
  }

  @override
  String get chooseFromLibrary => 'Choose from library';

  @override
  String get coverPhoto => 'Cover photo';

  @override
  String get coverPhotoSheetHint =>
      'Shown across the top of your profile, behind your picture. Wide photos work best, about 3 to 1.';

  @override
  String get coverRemoved => 'Cover removed';

  @override
  String get day => 'Day';

  @override
  String get month => 'Month';

  @override
  String get displayName => 'Display name';

  @override
  String displayNameHelper(String username) {
    return 'Shown with your posts. Your username stays @$username.';
  }

  @override
  String get emailPasswordInAccount => 'Email, password and sign-in';

  @override
  String get featureATopic => 'Feature a topic';

  @override
  String get featureATopicHint =>
      'Pin one of your topics to the top of your profile.';

  @override
  String get featuredTopicChanged => 'Featured topic changed';

  @override
  String get featuredTopicNone =>
      'None. Pin one of your topics to your profile.';

  @override
  String get featuredTopicRemoved => 'Featured topic removed';

  @override
  String get featuredTopicRules =>
      'Messages and topics in private categories can\'t be featured.';

  @override
  String get fieldManagedBySignIn =>
      'This forum manages it through its own sign-in. Change it there.';

  @override
  String get flair => 'Flair';

  @override
  String flairChangedTo(String group) {
    return 'Flair changed to $group';
  }

  @override
  String get flairRemoved => 'Flair removed';

  @override
  String get flairSheetHint =>
      'A small badge on your picture, from a group you\'re in.';

  @override
  String forumPictureN(int number) {
    return 'Forum picture $number';
  }

  @override
  String forumQuestionNeedsAnswer(String question) {
    return '$question needs an answer';
  }

  @override
  String get forumQuestionRequired => 'This forum asks everyone to answer';

  @override
  String get forumQuestionSetByStaff => 'Set by the forum\'s staff';

  @override
  String get forumQuestionsIntro =>
      'Questions from this forum. * means required.';

  @override
  String get forumQuestionsNoneAnswered => 'Not answered yet';

  @override
  String get fromThisForum => 'From this forum';

  @override
  String get hideMyProfile => 'Hide my public profile';

  @override
  String get hideMyProfileExplanation =>
      'Others see only your name, picture and posts';

  @override
  String get letterAvatar => 'Letter';

  @override
  String get moreAboutYou => 'More about you';

  @override
  String namesAndMore(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more',
      one: '1 more',
    );
    return '$names and $_temp0';
  }

  @override
  String get newUsername => 'New username';

  @override
  String get noFlair => 'No flair';

  @override
  String noGravatarFound(String service) {
    return '$service has no picture for your email address';
  }

  @override
  String get noTitle => 'No title';

  @override
  String get noTopicsMatch => 'None of your topics match';

  @override
  String get noTopicsToFeature => 'You haven\'t started any topics yet';

  @override
  String get notSet => 'Not set';

  @override
  String get orUse => 'Or use';

  @override
  String get pictureManagedBySignIn =>
      'This forum sets your picture through its own sign-in';

  @override
  String get primaryGroup => 'Primary group';

  @override
  String primaryGroupChangedTo(String group) {
    return 'Primary group changed to $group';
  }

  @override
  String get primaryGroupRemoved => 'Primary group removed';

  @override
  String get primaryGroupSheetHint =>
      'Your main group, shown on your user card.';

  @override
  String get profileLoadFailed => 'Couldn\'t load your profile';

  @override
  String get profileNowHidden => 'Your profile is hidden';

  @override
  String get profileNowPublic => 'Your profile is public';

  @override
  String get profilePicture => 'Profile picture';

  @override
  String get profilePictureChanged => 'Profile picture changed';

  @override
  String get profileSaveFailed => 'Couldn\'t save. Try again.';

  @override
  String get profileSectionNameAndAbout => 'Name and about';

  @override
  String get profileSectionNextToName => 'Next to your name';

  @override
  String get profileSectionOnProfile => 'On your profile';

  @override
  String get profileSectionPrivacyAndTime => 'Privacy and time';

  @override
  String get removeCardBackground => 'Remove card background';

  @override
  String get removeCover => 'Remove cover';

  @override
  String get removeFeaturedTopic => 'Remove featured topic';

  @override
  String get searchTimezones => 'Search time zones';

  @override
  String get searchYourTopics => 'Search your topics';

  @override
  String get seeProfileAsOthersDo => 'See your profile as others do';

  @override
  String get timezone => 'Time zone';

  @override
  String timezoneChangedTo(String zone) {
    return 'Time zone changed to $zone';
  }

  @override
  String timezoneWithTime(String zone, String time) {
    return '$zone · $time now';
  }

  @override
  String timezonesMatchingPhone(String offset) {
    return 'Matches this phone\'s clock ($offset)';
  }

  @override
  String titleChangedTo(String title) {
    return 'Title changed to $title';
  }

  @override
  String get titleFromBadge => 'Badge';

  @override
  String titleFromBadgeEarned(String date) {
    return 'Badge · earned $date';
  }

  @override
  String titleFromGroup(String group) {
    return '$group group';
  }

  @override
  String get titleGrantedByStaff => 'Given by the forum\'s staff';

  @override
  String get titleRemoved => 'Title removed';

  @override
  String get titleSheetHint =>
      'Shown after your name on your profile and posts.';

  @override
  String get username => 'Username';

  @override
  String get usernameAvailable => 'Available';

  @override
  String usernameChanged(String username) {
    return 'Your username is now @$username';
  }

  @override
  String get usernameLockedExplanation =>
      'This forum lets members change their username only shortly after joining. A moderator can change it for you.';

  @override
  String get yourPhoto => 'Your photo';
}
