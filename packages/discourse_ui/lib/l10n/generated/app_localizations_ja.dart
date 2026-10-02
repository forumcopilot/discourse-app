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
  String get youCannotReplyToThisThread => 'このトピックに返信できません';

  @override
  String get pleaseWaitForThreadToLoad => 'トピックの読み込みを待ってください';

  @override
  String get reason => '理由';

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
  String get pleaseSpecifyReason => '理由を指定してください';

  @override
  String get selectDate => '日付を選択';

  @override
  String get moreOptions => 'その他のオプション';

  @override
  String get topicClosed => 'トピックが閉じられました';

  @override
  String get topicOpened => 'トピックが開かれました';

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
  String get sendMessage => 'メッセージ';

  @override
  String get likesReceived => '受け取ったいいね';

  @override
  String get showMore => 'もっと見る';

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
  String get signIn => 'ログイン';

  @override
  String get notificationTest => '通知テスト';

  @override
  String get forum => 'カテゴリ';

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
  String get temporary => '一時的';

  @override
  String get back => '戻る';

  @override
  String get confirm => '確認';

  @override
  String error(String error) {
    return 'エラー: $error';
  }

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
  String get refresh => '更新';

  @override
  String get share => '共有';

  @override
  String get viewOnWeb => 'Webで表示';

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
  String get deleteTopic => 'トピックを削除';

  @override
  String get home => 'ホーム';

  @override
  String get notifications => '通知';

  @override
  String get forums => 'カテゴリ';

  @override
  String get content => 'コンテンツ';

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
  String get writeYourMessage => 'メッセージを書く...';

  @override
  String get writeYourReply => '返信を書く...';

  @override
  String get conversationMarkedAsUnread => 'メッセージを未読にしました';

  @override
  String get conversationClosed => 'メッセージをクローズしました';

  @override
  String get conversationOpened => 'メッセージをオープンしました';

  @override
  String failedToLoadQuote(String error) {
    return '引用の読み込みに失敗しました: \n$error';
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
  String get like => 'いいね';

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
  String get chat => 'チャット';

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
  String get undeleteTopic => 'トピックの削除を取り消す';

  @override
  String get send => '送信';

  @override
  String get changeEmailExplanation =>
      '新しいメールアドレスに確認リンクを送ります。リンクをクリックすると変更が反映されます。';

  @override
  String get changeEmailSecurityNote =>
      'セキュリティのため、Discourse からメール内のリンクで確認を求められることがあります。届かない場合は迷惑メールフォルダを確認してください。';

  @override
  String get noMessagesYetSayHi => 'まだメッセージはありません — 挨拶してみましょう。';

  @override
  String get edited => '編集済み';

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
  String get solution => '解決策';

  @override
  String get deleted => '削除済み';

  @override
  String get pleaseLoginToViewUserProfiles => 'ユーザープロフィールを見るにはログインしてください。';

  @override
  String get solved => '解決済み';

  @override
  String get hot => '注目';

  @override
  String get pinned => '固定';

  @override
  String get locked => 'ロック中';

  @override
  String get poll => '投票';

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
  String maximumAttachmentsAllowed(Object count) {
    return '添付ファイルは最大 $count 件までです';
  }

  @override
  String get noImagesFoundToDisplay => '表示できる画像がありません。';

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
  String get errorLoadingNotifications => '通知の読み込みエラー';

  @override
  String get noNewNotificationsExplanation =>
      'あなたのトピックや投稿に対する返信があったとき、誰かがあなたを @メンションまたは引用したとき、あなたがウォッチ中のトピックに返信があったときなど、あなたに直接関連するアクティビティはこのパネルで通知されます。あなたがしばらくログインしていない場合は、メールにも通知が送信されます。';

  @override
  String noTagsMatch(Object filter) {
    return '「$filter」に一致するタグはありません。';
  }

  @override
  String noTopicsTagged(Object tag) {
    return '「$tag」タグのトピックはありません';
  }

  @override
  String get searchUser => 'ユーザーを検索';

  @override
  String get tapToOpen => 'タップして開く';

  @override
  String get imageNotAvailable => '画像を表示できません';

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
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return 'あと $remainingSlots 件のみ添付できます。最初の $remainingSlots2 枚を処理します。';
  }

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
  String get failedToUpdatePostPleaseTryAgain => '投稿を更新できませんでした。もう一度お試しください。';

  @override
  String get postDeletedSuccessfully => '投稿を削除しました';

  @override
  String failedToDeletePost(Object error) {
    return '投稿を削除できませんでした: $error';
  }

  @override
  String get editHistoryNotAvailable => 'この投稿の編集履歴は利用できません';

  @override
  String get react => 'リアクション';

  @override
  String get reactionsAreNotEnabledOnThisForum => 'このフォーラムではリアクションが有効になっていません。';

  @override
  String get noReactionsYet => 'まだリアクションはありません';

  @override
  String get searchFilters => '検索フィルター';

  @override
  String get suggestedTopics => 'おすすめのトピック';

  @override
  String get suggestedMessages => '推奨メッセージ';

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
  String get notSignedIn => 'サインインしていません';

  @override
  String get deviceWillNotShowAlertsUntilAllowedInSettings =>
      '設定で通知を許可するまで、この端末には通知が表示されません。';

  @override
  String get openSettings => '設定を開く';

  @override
  String get notificationsThisDeviceSection => 'この端末';

  @override
  String notificationsThisDeviceCaption(Object forumName) {
    return '$forumName からのプッシュはこの端末だけが対象です。ほかの端末やウェブには影響しません。';
  }

  @override
  String notificationsAccountSection(Object forumName) {
    return '$forumName のアカウント';
  }

  @override
  String get notificationsAccountCaption => 'ウェブ、メール、すべての端末に共通の設定です。';

  @override
  String pushOnThisDeviceSubtitle(Object forumName) {
    return 'オン：$forumName の新しい通知がこの端末に届きます。';
  }

  @override
  String pushOffThisDeviceSubtitle(Object forumName) {
    return 'この端末ではオフです。オンにするには $forumName で一度承認します。';
  }

  @override
  String get stopPushOnThisDevice => 'この端末へのプッシュを停止';

  @override
  String stopPushTitle(Object forumName) {
    return 'この端末で $forumName のプッシュを停止しますか？';
  }

  @override
  String get stopPushOnlyThisDevice => '停止するのはこの端末だけです。ほかの端末には引き続き届きます。';

  @override
  String get stopPushNothingElseChanges =>
      '通知はアプリやウェブで引き続き確認でき、フォーラムからのメールも変わりません。';

  @override
  String stopPushPermissionDeleted(Object forumName) {
    return '$forumName で許可した権限は削除されます。プッシュを再びオンにするには、フォーラムでもう一度承認が必要です。';
  }

  @override
  String get stopPushQuietHint =>
      'しばらく静かにしたいだけなら、上で不要な種類をオフにするか、プロフィールのおやすみモードを使ってください。';

  @override
  String get stopPush => 'プッシュを停止';

  @override
  String get turnOn => 'オンにする';

  @override
  String get couldNotTurnOffNotifications => 'プッシュを停止できませんでした。後でもう一度お試しください。';

  @override
  String actionCodeTopicCreated(String when) {
    return '$whenにこのトピックを作成しました';
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
  String get topicIsNew => '新しいトピック';

  @override
  String get noNewTopicsSinceLastVisit => '前回の訪問以降、新しいトピックはありません。';

  @override
  String get messageIsNew => '新しいメッセージ';

  @override
  String topicUnreadReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '未読の返信 $count 件',
    );
    return '$_temp0';
  }

  @override
  String filterNewWithCount(int count) {
    return '新規 ($count)';
  }

  @override
  String filterUnreadWithCount(int count) {
    return '未読 ($count)';
  }

  @override
  String categoryNewTopics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '新規 $count',
    );
    return '$_temp0';
  }

  @override
  String categoryUnreadTopics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '未読 $count',
    );
    return '$_temp0';
  }

  @override
  String get dismissNew => '新規を閉じる';

  @override
  String get dismissUnread => '未読を閉じる';

  @override
  String get dismissNewTitle => '新しいトピックを閉じますか？';

  @override
  String get dismissNewMessage => '新規として表示されなくなります。';

  @override
  String get dismissUnreadTitle => '未読をすべて閉じますか？';

  @override
  String get dismissUnreadMessage => '新しい返信は既読になります。';

  @override
  String get dismissUnreadStopTracking => 'これらのトピックの追跡を停止して、未読として表示されないようにする';

  @override
  String get dismissNewAndUnread => '新規と未読を閉じる';

  @override
  String dismissNewAndUnreadMessage(String category) {
    return '$category のトピックは新規・未読として表示されなくなります。';
  }

  @override
  String get dismissedTopics => '閉じました';

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
  String get aboutMe => '自己紹介';

  @override
  String get aboutMeHelper => 'プロフィールの上部に表示されます';

  @override
  String get aboutMeMarkdownHint => 'Markdown が使えます: **太字**、リンク、:emoji:';

  @override
  String get addCover => 'カバーを追加';

  @override
  String get changeCover => 'カバーを変更';

  @override
  String get birthdayHint => 'フォーラムが一緒にお祝いします。年は保存されません。';

  @override
  String get birthdayRemoved => '誕生日を削除しました';

  @override
  String get birthdaySaved => '誕生日を保存しました';

  @override
  String get cardBackground => 'カード背景';

  @override
  String get cardBackgroundExplanation => '誰かがあなたの写真をタップしたとき、ユーザーカードの背景に表示されます';

  @override
  String get cardBackgroundRemoved => 'カード背景を削除しました';

  @override
  String get cardBackgroundSheetHint => 'ユーザーカードの背景に表示されます。横長の写真が最適です。';

  @override
  String get changeProfilePicture => 'プロフィール画像を変更';

  @override
  String get changeUsername => 'ユーザー名を変更';

  @override
  String changeUsernameExplanation(String username) {
    return '投稿内の @$username へのメンションや引用は新しい名前に切り替わります。プロフィールへの古いリンクは使えなくなります。';
  }

  @override
  String get chooseFromLibrary => 'ライブラリから選択';

  @override
  String get coverPhoto => 'カバー写真';

  @override
  String get coverPhotoSheetHint =>
      'プロフィールの上部、プロフィール画像の背後に表示されます。横長の写真（3:1 程度）が最適です。';

  @override
  String get coverRemoved => 'カバーを削除しました';

  @override
  String get day => '日';

  @override
  String get month => '月';

  @override
  String get displayName => '表示名';

  @override
  String displayNameHelper(String username) {
    return '投稿と一緒に表示されます。ユーザー名は @$username のままです。';
  }

  @override
  String get emailPasswordInAccount => 'メール、パスワード、サインイン';

  @override
  String get featureATopic => '注目のトピックを選択';

  @override
  String get featureATopicHint => '自分のトピックを 1 つプロフィールの上部に固定します。';

  @override
  String get featuredTopicChanged => '注目のトピックを変更しました';

  @override
  String get featuredTopicNone => 'なし。自分のトピックをプロフィールに固定できます。';

  @override
  String get featuredTopicRemoved => '注目のトピックを解除しました';

  @override
  String get featuredTopicRules => 'メッセージと非公開カテゴリのトピックは注目のトピックにできません。';

  @override
  String get fieldManagedBySignIn => 'このフォーラムでは独自のサインインで管理されています。そちらで変更してください。';

  @override
  String get flair => 'フレア';

  @override
  String flairChangedTo(String group) {
    return 'フレアを $group に変更しました';
  }

  @override
  String get flairRemoved => 'フレアを削除しました';

  @override
  String get flairSheetHint => '参加しているグループの小さなアイコンをプロフィール画像に表示します。';

  @override
  String forumPictureN(int number) {
    return 'フォーラムの画像 $number';
  }

  @override
  String forumQuestionNeedsAnswer(String question) {
    return '$question に回答が必要です';
  }

  @override
  String get forumQuestionRequired => 'このフォーラムでは全員に回答をお願いしています';

  @override
  String get forumQuestionSetByStaff => 'フォーラムのスタッフが設定します';

  @override
  String get forumQuestionsIntro => 'このフォーラムからの質問です。* は必須です。';

  @override
  String get forumQuestionsNoneAnswered => '未回答';

  @override
  String get fromThisForum => 'このフォーラムから';

  @override
  String get hideMyProfile => '公開プロフィールを非表示にする';

  @override
  String get hideMyProfileExplanation => '他の人には名前、プロフィール画像、投稿のみが表示されます';

  @override
  String get letterAvatar => 'イニシャル';

  @override
  String get moreAboutYou => 'その他の情報';

  @override
  String namesAndMore(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件',
    );
    return '$names ほか $_temp0';
  }

  @override
  String get newUsername => '新しいユーザー名';

  @override
  String get noFlair => 'フレアなし';

  @override
  String noGravatarFound(String service) {
    return '$service にはあなたのメールアドレスの画像がありません';
  }

  @override
  String get noTitle => '称号なし';

  @override
  String get noTopicsMatch => '一致するトピックはありません';

  @override
  String get noTopicsToFeature => 'まだトピックを作成していません';

  @override
  String get notSet => '未設定';

  @override
  String get orUse => 'または次を使用';

  @override
  String get pictureManagedBySignIn => 'このフォーラムでは独自のサインインでプロフィール画像が設定されます';

  @override
  String get primaryGroup => 'プライマリグループ';

  @override
  String primaryGroupChangedTo(String group) {
    return 'プライマリグループを $group に変更しました';
  }

  @override
  String get primaryGroupRemoved => 'プライマリグループを削除しました';

  @override
  String get primaryGroupSheetHint => 'ユーザーカードに表示されるメインのグループです。';

  @override
  String get profileLoadFailed => 'プロフィールを読み込めませんでした';

  @override
  String get profileNowHidden => 'プロフィールを非公開にしました';

  @override
  String get profileNowPublic => 'プロフィールを公開しました';

  @override
  String get profilePicture => 'プロフィール画像';

  @override
  String get profilePictureChanged => 'プロフィール画像を変更しました';

  @override
  String get profileSaveFailed => '保存できませんでした。もう一度お試しください。';

  @override
  String get profileSectionNameAndAbout => '名前と自己紹介';

  @override
  String get profileSectionNextToName => '名前の横';

  @override
  String get profileSectionOnProfile => 'プロフィール';

  @override
  String get profileSectionPrivacyAndTime => 'プライバシーと時刻';

  @override
  String get removeCardBackground => 'カード背景を削除';

  @override
  String get removeCover => 'カバーを削除';

  @override
  String get removeFeaturedTopic => '注目のトピックを解除';

  @override
  String get searchTimezones => 'タイムゾーンを検索';

  @override
  String get searchYourTopics => '自分のトピックを検索';

  @override
  String get seeProfileAsOthersDo => '他の人から見たプロフィールを表示';

  @override
  String get timezone => 'タイムゾーン';

  @override
  String timezoneChangedTo(String zone) {
    return 'タイムゾーンを $zone に変更しました';
  }

  @override
  String timezoneWithTime(String zone, String time) {
    return '$zone · 現在 $time';
  }

  @override
  String timezonesMatchingPhone(String offset) {
    return 'この端末の時計と一致 ($offset)';
  }

  @override
  String titleChangedTo(String title) {
    return '称号を $title に変更しました';
  }

  @override
  String get titleFromBadge => 'バッジ';

  @override
  String titleFromBadgeEarned(String date) {
    return 'バッジ · $date に獲得';
  }

  @override
  String titleFromGroup(String group) {
    return '$group グループ';
  }

  @override
  String get titleGrantedByStaff => 'フォーラムのスタッフが付与';

  @override
  String get titleRemoved => '称号を削除しました';

  @override
  String get titleSheetHint => 'プロフィールと投稿で名前の後に表示されます。';

  @override
  String get username => 'ユーザー名';

  @override
  String get usernameAvailable => '使用できます';

  @override
  String usernameChanged(String username) {
    return 'ユーザー名が @$username になりました';
  }

  @override
  String get usernameLockedExplanation =>
      'このフォーラムでは、ユーザー名を変更できるのは参加直後の短い期間だけです。モデレーターに変更を依頼できます。';

  @override
  String get yourPhoto => '自分の写真';

  @override
  String get chooseEmoji => '絵文字を選択';

  @override
  String get clearStatus => 'ステータスを解除';

  @override
  String get clearText => 'クリア';

  @override
  String get inOneHour => '1時間後';

  @override
  String get never => '解除しない';

  @override
  String get pauseNotifications => '通知を一時停止';

  @override
  String get pauseNotificationsUntilStatusClears => 'ステータスが解除されるまで';

  @override
  String get pickATime => '時間を選択';

  @override
  String get removeStatusAfter => 'ステータスの解除';

  @override
  String get searchEmoji => '絵文字を検索';

  @override
  String get setStatus => 'ステータスを設定';

  @override
  String get setAStatus => 'ステータスを設定';

  @override
  String get statusUpdated => 'ステータスを更新しました';

  @override
  String get whatAreYouDoing => '何をしていますか？';

  @override
  String cardPosted(String when) {
    return '$whenに投稿';
  }

  @override
  String get change => '変更';

  @override
  String get copyProfileLink => 'プロフィールのリンクをコピー';

  @override
  String get ignore => '無視';

  @override
  String memberOfGroup(String group) {
    return '$group のメンバー';
  }

  @override
  String get mute => 'ミュート';

  @override
  String get unmute => 'ミュートを解除';

  @override
  String openProfileOf(String username) {
    return '@$username のプロフィールを開く';
  }

  @override
  String profileIsPrivate(String username) {
    return '$username はプロフィールを非公開にしています。';
  }

  @override
  String showOnlyTheirPostsHere(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件',
    );
    return 'このトピックで $name の投稿（$_temp0）のみを表示';
  }

  @override
  String showOnlyYourPostsHere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件',
    );
    return 'このトピックで自分の投稿（$_temp0）のみを表示';
  }

  @override
  String userIgnoredFor4Months(String username) {
    return '@$username を4か月間無視します';
  }

  @override
  String userMuted(String username) {
    return '@$username をミュートしました';
  }

  @override
  String userUnmuted(String username) {
    return '@$username のミュートを解除しました';
  }

  @override
  String get youParenthetical => '（あなた）';

  @override
  String get topicStatusClosedHelp => 'このトピックはクローズしています。新たに返信することはできません。';

  @override
  String get topicStatusArchivedHelp => 'このトピックはアーカイブされています。凍結状態のため一切の変更ができません';

  @override
  String get topicStatusClosedArchivedHelp =>
      'このトピックはクローズされ、アーカイブされています。新しい返信を受け入れず、変更することはできません';

  @override
  String get topicStatusPinnedTitle => '固定';

  @override
  String get topicStatusPinnedHelp => 'このトピックは固定されています。常にカテゴリのトップに表示されます';

  @override
  String get topicStatusPinnedGloballyTitle => '全体に固定';

  @override
  String get topicStatusPinnedGloballyHelp =>
      'このトピックは全体に固定されています。常に最新とカテゴリのトップに表示されます';

  @override
  String get topicStatusUnpinnedTitle => '固定解除';

  @override
  String get topicStatusUnpinnedHelp => 'このトピックは固定解除されています。 通常の順番で表示されます';

  @override
  String get topicStatusUnlistedHelp =>
      'このトピックは未掲載です。トピックリストには表示されません。直リンクでのみアクセス可能です。';

  @override
  String get topicStatusWarningHelp => 'これは運営スタッフからの警告です。';

  @override
  String get notificationReasonWatchingTag => 'このトピックのタグをウォッチしているため通知されます。';

  @override
  String get notificationReasonWatchingCategory => 'このカテゴリをウォッチしているため通知されます。';

  @override
  String get notificationReasonWatchingAuto => 'このトピックを自動的にウォッチし始めたため通知されます。';

  @override
  String get notificationReasonWatching => 'このトピックをウォッチしているため通知されます。';

  @override
  String get notificationReasonWatchingCreated => 'このトピックを作成したため通知されます。';

  @override
  String get notificationReasonTrackingCategory =>
      'このカテゴリを追跡しているため、新しい返信の件数が表示されます。';

  @override
  String get notificationReasonTrackingReplied =>
      'このトピックに返信したので、新しい返信の件数が表示されます。';

  @override
  String get notificationReasonTracking => 'このトピックを追跡しているので、新しい返信の件数が表示されます。';

  @override
  String get notificationReasonTrackingRead =>
      'このトピックを読んでいるため、新しい返信の件数が表示されます。';

  @override
  String get notificationReasonNormal =>
      '誰かが @ユーザー名であなたをメンションしたり、あなたに返信したりすると通知が送信されます。';

  @override
  String get notificationReasonMutedCategory => 'このカテゴリのすべての通知を無視しています。';

  @override
  String get notificationReasonMuted => 'このトピックのすべての通知を無視しています。';

  @override
  String get notificationLevelWatching => 'ウォッチ中';

  @override
  String get notificationLevelWatchingFirstPost => '最初の投稿をウォッチ中';

  @override
  String get notificationLevelTracking => '追跡中';

  @override
  String get notificationLevelNormal => '通常';

  @override
  String get notificationLevelMuted => 'ミュート';

  @override
  String get topicWatchingDescription => 'このトピックに返信があるたびに通知され、新しい返信の件数が表示されます。';

  @override
  String get topicTrackingDescription =>
      'このトピックの新しい返信の件数が表示されます。誰かが@ユーザー名であなたをメンションしたり、あなたに返信したりすると通知が送信されます。';

  @override
  String get topicNormalDescription =>
      '誰かが @ユーザー名であなたをメンションしたり、あなたに返信したりすると通知が送信されます。';

  @override
  String get topicMutedDescription => 'このトピックについて何も通知されず、最新にも表示されません。';

  @override
  String get messageWatchingDescription =>
      'このメッセージに返信があるたびに通知され、新しい返信の件数が表示されます。';

  @override
  String get messageTrackingDescription =>
      'このメッセージの新しい返信の件数が表示されます。誰かが@ユーザー名であなたをメンションしたり、あなたに返信したりすると通知が送信されます。';

  @override
  String get messageNormalDescription =>
      '誰かが @ユーザー名であなたをメンションしたり、あなたに返信したりすると通知が送信されます。';

  @override
  String get messageMutedDescription => 'このメッセージに関する通知を受け取りません。';

  @override
  String get categoryWatchingDescription =>
      'このカテゴリのすべてのトピックを自動的にウォッチします。各トピックに新しい投稿があるたびに通知され、新しい返信の数が表示されます。';

  @override
  String get categoryWatchingFirstPostDescription =>
      'このカテゴリの新しいトピックについて通知されますが、トピックへの返信は通知されません。';

  @override
  String get categoryTrackingDescription =>
      'カテゴリ内のすべてのトピックを自動的に追跡します。誰かがあなたを @name でメンションした場合やあなたに返信した場合は通知され、新しい返信の数が表示されます。';

  @override
  String get categoryNormalDescription =>
      '誰かが @ユーザー名であなたをメンションしたり、あなたに返信したりすると通知が送信されます。';

  @override
  String get categoryMutedDescription =>
      'このカテゴリの新しいトピックについて何も通知されません。また最新にも表示されません。';

  @override
  String get tagWatchingDescription =>
      'このタグのついたすべてのトピックを自動的にウォッチします。すべての新しい投稿とトピックが通知され、トピックの隣に未読と新しい投稿の件数が表示されます。';

  @override
  String get tagWatchingFirstPostDescription =>
      'このタグの新規トピックは通知されますが、トピックへの返信は通知されません。';

  @override
  String get tagTrackingDescription =>
      'このタグが付いたすべてのトピックを自動的に追跡します。トピックの隣に未読と新しい投稿の件数が表示されます。';

  @override
  String get tagNormalDescription =>
      '誰かが @ユーザー名であなたをメンションしたり、あなたの投稿に返信したりすると通知が送信されます。';

  @override
  String get tagMutedDescription =>
      'このタグのついた新しいトピックについては何も通知されず、未読タブにも表示されません。';

  @override
  String topicTimerAutoOpen(String timeLeft) {
    return 'このトピックは$timeLeftに自動的にオープンします。';
  }

  @override
  String topicTimerAutoClose(String timeLeft) {
    return 'このトピックは$timeLeftに自動的にクローズします。';
  }

  @override
  String topicTimerAutoPublish(String categoryName, String timeLeft) {
    return 'このトピックは$timeLeftに #$categoryName に公開されます。';
  }

  @override
  String topicTimerAutoCloseAfterLastPost(String duration) {
    return 'このトピックは最後の返信から$duration後にクローズされます。';
  }

  @override
  String topicTimerAutoDeleteAfterLastPost(String duration) {
    return 'このトピックは最後の返信から$duration後に削除されます。';
  }

  @override
  String topicTimerAutoDelete(String timeLeft) {
    return 'このトピックは$timeLeftに自動的に削除されます。';
  }

  @override
  String topicTimerAutoBump(String timeLeft) {
    return 'このトピックは$timeLeftに自動的にバンプされます。';
  }

  @override
  String topicTimerAutoDeleteReplies(String duration) {
    return 'このトピックへの返信は、$duration後に自動的に削除されます。';
  }

  @override
  String slowModeNotice(String duration) {
    return 'このトピックでは次の投稿まで$durationお待ちください。';
  }

  @override
  String get closeTopic => 'トピックをクローズ';

  @override
  String get openTopic => 'トピックをオープン';

  @override
  String get pinTopic => 'トピックを固定';

  @override
  String get unpinTopic => 'トピックを固定解除';

  @override
  String get archiveTopic => 'トピックをアーカイブ';

  @override
  String get unarchiveTopic => 'トピックをアーカイブ解除';

  @override
  String get unlistTopic => 'トピックを非表示';

  @override
  String get listTopic => 'トピックを表示';

  @override
  String get permanentlyDelete => '永久に削除';

  @override
  String get permanentlyDeleteTopicConfirmation =>
      'この操作は取り消せません。このトピックは完全に削除され、データベースから消去されます。';

  @override
  String get deleteTopicConfirmYes => 'はい。このトピックを削除する';

  @override
  String get deleteTopicConfirmNo => 'いいえ。このトピックを維持する';

  @override
  String get topicPinned => 'トピックを固定しました';

  @override
  String get topicUnpinned => 'トピックの固定を解除しました';

  @override
  String get topicArchived => 'トピックをアーカイブしました';

  @override
  String get topicUnarchived => 'トピックのアーカイブを解除しました';

  @override
  String get topicUnlisted => 'トピックを非表示にしました';

  @override
  String get topicListed => 'トピックを表示しました';

  @override
  String get topicRecovered => 'トピックの削除を取り消しました';

  @override
  String topicActionFailed(String error) {
    return 'トピックを更新できませんでした: $error';
  }

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count分',
    );
    return '$_temp0';
  }

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count時間',
    );
    return '$_temp0';
  }

  @override
  String durationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count日',
    );
    return '$_temp0';
  }

  @override
  String timeLeftMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count分後',
    );
    return '$_temp0';
  }

  @override
  String timeLeftHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count時間後',
    );
    return '$_temp0';
  }

  @override
  String timeLeftDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count日後',
    );
    return '$_temp0';
  }

  @override
  String get topicStatusDeletedHelp => 'このトピックは削除され、他のユーザーには表示されません';

  @override
  String get flagAction => '通報';

  @override
  String get flagPost => '投稿を通報';

  @override
  String get signUp => 'アカウントを登録';

  @override
  String get suspendUser => 'ユーザーを凍結';

  @override
  String get unsuspend => '凍結を解除';

  @override
  String get suspendUntil => '次の期間までユーザーを凍結する';

  @override
  String get suspendForever => '永久に凍結する';

  @override
  String failedToSuspendUser(String error) {
    return 'このユーザーを凍結中にエラーが発生しました: $error';
  }

  @override
  String failedToUnsuspendUser(String error) {
    return 'このユーザーの凍結を解除中にエラーが発生しました: $error';
  }

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
  String get flaggingPost => '投稿を通報しています…';

  @override
  String get pleaseSelectSuspensionEndDate => '凍結の終了日時を選択してください';

  @override
  String get suspendingUser => 'ユーザーを凍結しています…';

  @override
  String get unsuspendingUser => 'ユーザーの凍結を解除しています…';

  @override
  String get userSuspended => 'ユーザーを凍結しました';

  @override
  String get userUnsuspended => 'ユーザーの凍結を解除しました';

  @override
  String unsuspendUserConfirmation(String username) {
    return '$username の凍結を解除しますか？再びログインできるようになります。';
  }

  @override
  String get noCategoriesToDisplay => '表示するカテゴリはありません。';

  @override
  String get noPermissionToViewCategory => 'このカテゴリのトピックを表示する権限がありません。';

  @override
  String get featureTopicTitle => 'これを注目のトピックにする';

  @override
  String get pinTopicMenu => 'トピックを固定...';

  @override
  String pinInCategoryUntil(String category) {
    return 'このトピックを $category カテゴリのトップに次の期間表示する:';
  }

  @override
  String get pinGloballyUntil => 'このトピックをすべてのトピックリストのトップに表示する';

  @override
  String get pinNote => 'ユーザーはトピックごとに固定表示を解除できます。';

  @override
  String get pinUntil => '固定期限';

  @override
  String get pinDateRequired => 'このトピックを固定するには日付が必要です。';

  @override
  String get pinTopicGlobally => 'トピックを全体に固定';

  @override
  String get flagThanks => 'ご報告ありがとうございます！';

  @override
  String get flagReviewProcess => 'すべての通報はモデレーターが受け取り、できるだけ速やかにレビューされます。';

  @override
  String get flagCant => '現在、この投稿を通報することはできません。';

  @override
  String get flagSendMessage => 'メッセージ';

  @override
  String get flagMessageForUser => 'ユーザーへのメッセージ';

  @override
  String get flagMessageForModerators => 'モデレーターへのメッセージ';

  @override
  String get flagPlaceholderNotifyUser => '具体的に、建設的に、そして常に親切に説明しましょう。';

  @override
  String get flagPlaceholderNotifyModerators =>
      '具体的にどのような問題が発生しているか説明してください。可能なら、関連するリンクや例を含めてください。';

  @override
  String get flagPlaceholderIllegal =>
      '具体的になぜこのコンテンツが違法だと思うのか説明してください。可能なら、関連するリンクと例を含めてください。';

  @override
  String get flagConfirmIllegal => '上記の記述は正確かつ完全です。';

  @override
  String flagMessageAtLeast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 文字以上を入力してください',
    );
    return '$_temp0';
  }

  @override
  String get flagMessageSent => 'メッセージを送信しました。';

  @override
  String get mergeTopicError => '指定されたトピックへの投稿移動中にエラーが発生しました。';

  @override
  String get topicTitlePlaceholder => 'トピックのタイトルを入力してください';

  @override
  String get topicMoved => 'トピックを移動しました';

  @override
  String get topicMerged => 'トピックを統合しました';

  @override
  String get mergeTopicExplanation =>
      'このトピックのすべての投稿が選んだトピックに移動します。アプリでは元に戻せません。';

  @override
  String get destinationTopicId => '移動先トピックの ID';

  @override
  String get topicAuthorUnknown => '不明';

  @override
  String get noHotTopics => 'ホットなトピックはありません。';

  @override
  String get signInToViewNewTopics => '新しいトピックを表示するにはログインしてください';

  @override
  String get newTopicsSignInMessage => '新しいトピックには、前回の訪問以降に作成されたものが表示されます。';

  @override
  String get topPeriodAllTime => '全期間';

  @override
  String get topPeriodYear => '今年';

  @override
  String get topPeriodQuarter => '今季';

  @override
  String get topPeriodMonth => '今月';

  @override
  String get topPeriodWeek => '今週';

  @override
  String get topPeriodToday => '今日';

  @override
  String noTopTopicsForPeriod(String period) {
    String _temp0 = intl.Intl.selectLogic(
      period,
      {
        'all': '全期間の人気のトピックはありません。',
        'yearly': '今年の人気のトピックはありません。',
        'quarterly': '今季の人気のトピックはありません。',
        'monthly': '今月の人気のトピックはありません。',
        'weekly': '今週の人気のトピックはありません。',
        'daily': '今日の人気のトピックはありません。',
        'other': '人気のトピックはありません。',
      },
    );
    return '$_temp0';
  }

  @override
  String get connectionTimedOutSiteUnreachable =>
      '接続がタイムアウトしました。サイトがダウンしているか、アクセスできない可能性があります。';

  @override
  String get failedToMarkNotificationsRead => '通知を既読にできませんでした';

  @override
  String get forumNameFallback => 'フォーラム';

  @override
  String get noForumDescription => '説明はありません。';

  @override
  String get dismissAllNotifications => 'すべて閉じる';

  @override
  String get notificationPostIdMissing => '投稿IDがありません。投稿に移動できません。';

  @override
  String get notificationTopicIdMissingForPost => 'トピックIDがありません。投稿に移動できません。';

  @override
  String get notificationTopicIdMissing => 'トピックIDがありません。トピックを開けません。';

  @override
  String get notificationUsernameMissing => 'ユーザー名がありません。プロフィールを開けません。';

  @override
  String get notificationChannelIdMissing => 'チャンネルIDがありません。チャットを開けません。';

  @override
  String get notificationGroupNameMissingForInbox => 'グループ名がありません。受信トレイを開けません。';

  @override
  String get notificationGroupNameMissing => 'グループ名がありません。グループを開けません。';

  @override
  String get notificationNoActionUrl => 'この種類の通知にはアクションURLがありません。';

  @override
  String get notificationBadgeUnavailable => 'バッジの詳細は利用できません。';

  @override
  String get notificationBadgeLoadFailed => 'このバッジを読み込めませんでした。';

  @override
  String get personalMessageTitleFallback => '個人メッセージ';

  @override
  String get topicTitleFallback => 'トピック';

  @override
  String get signInToViewNotifications => '通知を表示するにはログインしてください';

  @override
  String get youNeedToBeSignedInToViewNotifications => '通知を見るにはログインが必要です。';

  @override
  String get noUnreadNotifications => '未読の通知はありません';

  @override
  String get noNotificationsYet => 'まだ通知はありません';

  @override
  String get newNotificationFallbackBody => '新しい通知';

  @override
  String get unableToOpenNotification => '通知を開けません';

  @override
  String get notificationMissingSiteInfo => 'サイト情報がありません（site_id）。';

  @override
  String get notificationInvalidSiteInfo => 'サイト情報が無効です（site_id）。';

  @override
  String get notificationMissingPostInfo => '投稿情報がありません（content_id）。';

  @override
  String get notificationMissingMessageInfo =>
      'メッセージ情報がありません（conversation_id）。';

  @override
  String get notificationMissingUserInfo => 'ユーザー情報がありません（sender_id）。';

  @override
  String get notificationUnsupportedType => 'サポートされていない通知の種類です。';

  @override
  String get notificationForumNotFound => 'このサイトのフォーラムが見つかりません。';

  @override
  String get notificationForumOpenFailed => 'フォーラムを初期化できませんでした。';

  @override
  String get notificationMissingTopicInfo => 'トピック情報がありません（topic_id）。';

  @override
  String get failedToLoadTags => 'タグを読み込めませんでした。';

  @override
  String get searchTagsHint => 'タグを検索…';

  @override
  String get tagsSortedByCountTooltip => 'トピック数順 — タップしてA→Z順に切り替え';

  @override
  String get tagsSortedAlphabeticallyTooltip => 'アルファベット順 — タップして人気順に切り替え';

  @override
  String get noTagsYet => 'このフォーラムにはまだタグがありません。';

  @override
  String get tagNotificationLevelTooltip => '通知レベル';

  @override
  String get tagTopicsLoadFailed => '読み込めませんでした';

  @override
  String searchFailedWithError(String error) {
    return '検索に失敗しました: $error';
  }

  @override
  String get searchFiltersButtonTooltip => 'フィルター';

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
  String get bookmarksUnavailable => 'ブックマークは利用できません';

  @override
  String get failedToLoadBookmarks => 'ブックマークを読み込めませんでした';

  @override
  String get failedToRemoveBookmark => 'ブックマークを削除できませんでした';

  @override
  String get failedToUpdateBookmark => 'ブックマークを更新できませんでした';

  @override
  String get bookmarkWithReminder => 'リマインダー付きブックマーク';

  @override
  String get noReminder => 'リマインダーなし';

  @override
  String get failedToLoadDrafts => '下書きを読み込めませんでした。';

  @override
  String get failedToDiscardDraft => '下書きを破棄できませんでした';

  @override
  String get messagesLoadFailed => 'メッセージを読み込めませんでした';

  @override
  String get moreMessagesLoadFailed => 'さらにメッセージを読み込めませんでした';

  @override
  String get messageUnknownUser => '不明';

  @override
  String get unknownErrorFallback => '不明なエラー';

  @override
  String get chatComposerDefaultHint => 'メッセージを入力…';

  @override
  String chatChannelNumbered(Object id) {
    return 'チャンネル $id';
  }

  @override
  String get chatSendFailed => 'メッセージを送信できませんでした。';

  @override
  String get chatEditFailed => 'メッセージを編集できませんでした。';

  @override
  String get chatDeleteFailed => 'メッセージを削除できませんでした。';

  @override
  String get chatReactionsUnsupported => 'ここではリアクションを使用できません。';

  @override
  String get chatReactionFailed => 'リアクションを更新できませんでした。';

  @override
  String get attachmentDefaultName => '添付ファイル';

  @override
  String get fileTypeAudio => '音声';

  @override
  String get fileTypeText => 'テキスト';

  @override
  String get fileTypeArchive => '圧縮ファイル';

  @override
  String get fileTypeFile => 'ファイル';

  @override
  String downloadFailedHttpStatus(String status) {
    return 'ファイルをダウンロードできませんでした: HTTP $status';
  }

  @override
  String get downloadedFileEmpty => 'ダウンロードしたファイルが空です';

  @override
  String downloadFileFailed(String error) {
    return 'ファイルをダウンロードできませんでした: $error';
  }

  @override
  String attachmentTypeNotAllowed(String extension, String allowed) {
    return 'ファイル形式 .$extension は許可されていません。許可されている形式: $allowed';
  }

  @override
  String attachmentFileTooLarge(String size, String max) {
    return 'ファイルサイズ ($size) が上限の $max を超えています';
  }

  @override
  String get attachmentValidationFailed => 'ファイルの検証に失敗しました';

  @override
  String get uploadMissingReference =>
      'アップロードは完了しましたが、サーバーからファイルの参照が返されませんでした。';

  @override
  String get imageFileNotFound => '画像ファイルが見つかりません';

  @override
  String get failedToLoadVideo => '動画を読み込めませんでした';

  @override
  String get userInfoLoadFailed => 'ユーザー情報を読み込めませんでした。';

  @override
  String userInfoLoadFailedWithError(String error) {
    return 'ユーザー情報を読み込めませんでした: $error';
  }

  @override
  String get profileMenuIgnoreUser => 'ユーザーを無視';

  @override
  String get profileMenuUnignoreUser => 'ユーザーの無視を解除';

  @override
  String get ignoreStateUpdateFailed => '無視の設定を更新できませんでした';

  @override
  String profileNowIgnoringUser(String username) {
    return '@$username を無視しています。この人の投稿は非表示になります。';
  }

  @override
  String get profileIgnoreToggleFailed => '無視の切り替えに失敗しました。';

  @override
  String get profileStatsLoadFailed => '統計を読み込めませんでした。';

  @override
  String get profileFollowFailed => 'フォローできませんでした';

  @override
  String get profileUnfollowFailed => 'フォローを解除できませんでした';

  @override
  String get profileChatOpenFailed => 'このユーザーとのチャットを開けませんでした。';

  @override
  String summaryLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'いいね $count 件',
    );
    return '$_temp0';
  }

  @override
  String summaryLinkClicks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count クリック',
    );
    return '$_temp0';
  }

  @override
  String get directoryPeriodAllTime => '全期間';

  @override
  String get directoryPeriodYear => '今年';

  @override
  String get directoryPeriodQuarter => '今季';

  @override
  String get directoryPeriodMonth => '今月';

  @override
  String get directoryPeriodWeek => '今週';

  @override
  String get directoryPeriodToday => '今日';

  @override
  String get directoryOrderReceived => '受け取った';

  @override
  String get directoryOrderReplies => '返信';

  @override
  String get directoryOrderTopics => 'トピック';

  @override
  String get directoryOrderVisits => 'アクセス';

  @override
  String get directoryLoadFailed => 'ユーザー一覧を読み込めませんでした。';

  @override
  String get directoryNoUsersMatch => 'その名前に一致するユーザーはいません。';

  @override
  String get directoryNoUsersForPeriod => 'この期間のユーザーは見つかりませんでした。';

  @override
  String get userSearchNoResults => 'ユーザーが見つかりません';

  @override
  String get userSearchTryDifferentUsername => '別のユーザー名で検索してみてください';

  @override
  String get userSearchPromptTitle => 'ユーザーを検索';

  @override
  String get userSearchPromptHint => 'ユーザー名を入力してユーザーを検索・招待します';

  @override
  String get ignoredUsersUnignoreFailed => '無視を解除できませんでした。';

  @override
  String get ignoredUsersEmpty => '無視しているユーザーはいません。';

  @override
  String get ignoredUsersEmptyHint =>
      'ユーザーのプロフィールを開き、メニューの「ユーザーを無視」を使うと、その人の投稿と通知が非表示になります。';

  @override
  String get badgesLoadFailed => 'バッジを読み込めませんでした。';

  @override
  String get badgesEmpty => 'このフォーラムにはバッジがありません。';

  @override
  String get badgeTierGold => 'ゴールド';

  @override
  String get badgeTierSilver => 'シルバー';

  @override
  String get badgeTierBronze => 'ブロンズ';

  @override
  String badgeEarnedAgo(String time) {
    return '$timeに獲得';
  }

  @override
  String badgeEarnedByUsers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted 人のユーザーが獲得',
    );
    return '$_temp0';
  }

  @override
  String get trustLevelNameNewUser => '新規ユーザー';

  @override
  String get trustLevelNameBasic => '基本ユーザー';

  @override
  String get trustLevelNameMember => 'メンバー';

  @override
  String get trustLevelNameRegular => 'レギュラー';

  @override
  String get trustLevelNameLeader => 'リーダー';

  @override
  String get trustLevelSummary0 => '参加したばかり。閲覧と投稿はできますが、リンク、画像、メッセージに制限があります。';

  @override
  String get trustLevelSummary1 =>
      '主要な投稿機能が使えるようになります：画像と添付ファイル、より多くのリンク、投稿の通報。';

  @override
  String get trustLevelSummary2 => '招待の送信、ユーザーの無視ができ、自分の投稿をより長く編集できます。';

  @override
  String get trustLevelSummary3 => 'トピックのカテゴリ変更や名前変更、タグの作成ができ、スパムの通報がより重視されます。';

  @override
  String get trustLevelSummary4 =>
      'スタッフが付与します。任意の投稿を編集でき、トピックの固定、クローズ、分割、統合ができます。';

  @override
  String trustLevelRowTitle(int level, String name) {
    return 'TL$level · $name';
  }

  @override
  String get profileNoUserSpecified => 'ユーザーが指定されていません';

  @override
  String get userTopicsLoadFailed => 'トピックを読み込めませんでした';

  @override
  String get userTopicsEmpty => 'まだトピックを作成していません。';

  @override
  String get userRecentPostsLoadFailed => '最近の投稿を読み込めませんでした';

  @override
  String get activityUnknownTopic => '不明なトピック';

  @override
  String groupJoinedSnack(String group) {
    return '$group に参加しました';
  }

  @override
  String get groupJoinFailed => 'グループに参加できませんでした';

  @override
  String groupLeftSnack(String group) {
    return '$group から退出しました';
  }

  @override
  String get groupLeaveFailed => 'グループから退出できませんでした';

  @override
  String get groupMembershipRequestHint =>
      '参加したい理由は何ですか？グループオーナーがリクエストと一緒に確認します。';

  @override
  String get groupMembershipReasonRequired => '参加リクエストには理由が必要です';

  @override
  String get groupMembershipRequestSent => 'リクエストを送信しました。グループオーナーの承認が必要です';

  @override
  String get groupMembershipRequestFailed => '参加リクエストを送信できませんでした';

  @override
  String get groupMemberBadge => 'メンバー';

  @override
  String get groupRequestPending => 'リクエスト保留中';

  @override
  String get groupJoining => '参加中…';

  @override
  String get groupJoinButton => 'グループに参加';

  @override
  String get groupsLoadFailed => 'グループを読み込めませんでした。';

  @override
  String get groupBuiltIn => '組み込みグループ';

  @override
  String invitesPendingWithCount(int count) {
    return '保留中 ($count)';
  }

  @override
  String invitesExpiredWithCount(int count) {
    return '期限切れ ($count)';
  }

  @override
  String invitesRedeemedWithCount(int count) {
    return '承諾済み ($count)';
  }

  @override
  String get invitesLoadFailed => '招待を読み込めませんでした。';

  @override
  String get inviteLinkCreateFailed => '招待リンクを作成できませんでした';

  @override
  String get inviteEmailAddressLabel => 'メールアドレス';

  @override
  String get inviteEmailInvalid => '有効なメールアドレスを入力してください';

  @override
  String get inviteMessageOptionalLabel => 'メッセージ（任意）';

  @override
  String get inviteSendFailed => '招待を送信できませんでした';

  @override
  String get revokeInviteLinkWarning => '招待リンクは使えなくなります。';

  @override
  String revokeInviteEmailWarning(String email) {
    return '$email への招待は使えなくなります。';
  }

  @override
  String get inviteRevokeFailed => '招待を取り消せませんでした';

  @override
  String get inviteNoPermission => '招待する権限がありません';

  @override
  String get invitesEmptyPending => '保留中の招待はありません';

  @override
  String get invitesEmptyExpired => '期限切れの招待はありません';

  @override
  String get invitesEmptyRedeemed => '承諾済みの招待はありません';

  @override
  String get invitesEmptyPendingHint => '招待リンクを作成して、フォーラムに人を招きましょう。';

  @override
  String get inviteLinkFallbackTitle => '招待リンク';

  @override
  String inviteRedeemedOn(String date) {
    return '$date に承諾';
  }

  @override
  String inviteRedemptions(int count, int max) {
    return '$max 件中 $count 件承諾済み';
  }

  @override
  String get inviteEmailSent => 'メール送信済み';

  @override
  String get inviteEmailNotSent => 'メール未送信';

  @override
  String inviteExpiredOn(String date) {
    return '$date に期限切れ';
  }

  @override
  String get inviteRevokeTooltip => '招待を取り消す';

  @override
  String get reviewStatusPending => '保留中';

  @override
  String get reviewStatusApproved => '承認済み';

  @override
  String get reviewStatusRejected => '却下';

  @override
  String get reviewStatusAll => 'すべて';

  @override
  String get reviewStatusIgnored => '通報が無視されました';

  @override
  String get reviewStatusDeleted => 'トピックまたは投稿が削除されました';

  @override
  String get reviewQueueUnavailable => 'このフォーラムではレビューキューを利用できません。';

  @override
  String get reviewQueueLoadFailed => 'レビューキューを読み込めませんでした';

  @override
  String get reviewableChangedByOther => 'この項目は別のモデレーターによって変更されました。更新しています…';

  @override
  String get reviewActionFailed => '操作を実行できませんでした';

  @override
  String reviewActionDone(String action) {
    return '$action：完了';
  }

  @override
  String get reviewRejectReasonHint => '却下する理由は何ですか？';

  @override
  String get reviewTypeFlaggedPost => '通報された投稿';

  @override
  String get reviewTypeQueuedPost => '待機中の投稿';

  @override
  String get reviewTypeQueuedTopic => '待機中のトピック';

  @override
  String get reviewTypeUser => 'ユーザー';

  @override
  String get reviewTypePost => '投稿';

  @override
  String get reviewTypeChatMessage => '通報されたチャットメッセージ';

  @override
  String get reviewModeratorAccessRequired => 'モデレーター権限が必要です';

  @override
  String reviewableScore(String score) {
    return 'スコア $score';
  }

  @override
  String get postRepliesLoadFailed => '返信を読み込めませんでした。';

  @override
  String get postMakeWiki => 'ウィキにする';

  @override
  String get postRemoveWiki => 'ウィキから削除';

  @override
  String get postBookmarkRemoveFailed => 'ブックマークを解除できませんでした';

  @override
  String get postBookmarkFailed => '投稿をブックマークできませんでした';

  @override
  String get postBookmarkReminderUpdateFailed => 'リマインダーを更新できませんでした';

  @override
  String get postBookmarkReminderSet => 'リマインダーを設定しました';

  @override
  String get postBookmarkReminderCleared => 'リマインダーをクリアしました';

  @override
  String get solutionMarkFailed => '解決策としてマークできませんでした';

  @override
  String get solutionUnmarkFailed => '解決策のマークを解除できませんでした';

  @override
  String get postUnknownDate => '日付不明';

  @override
  String get postBookmarkAction => '投稿をブックマーク';

  @override
  String get reactionButtonRemoveLike => 'いいね！済みです。タップすると取り消します。';

  @override
  String reactionButtonRemove(String reaction) {
    return 'あなたのリアクション：$reaction。タップすると取り消します。';
  }

  @override
  String reactionButtonLocked(String reaction) {
    return 'あなたのリアクション：$reaction。これ以上変更できません。';
  }

  @override
  String get reactionHoldHint => '長押しでほかのリアクション';

  @override
  String reactionSummarySemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'リアクション $count 件。タップでリアクションした人を表示。',
    );
    return '$_temp0';
  }

  @override
  String get reactionLockedMessage => 'この投稿へのリアクションはもう変更できません。';

  @override
  String get reactionHoldTip => 'ヒント：ハートを長押しするとほかのリアクションを選べます。';

  @override
  String reactionsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'リアクション $count 件',
    );
    return '$_temp0';
  }

  @override
  String get reactionsAll => 'すべて';

  @override
  String get reactionYou => 'あなた';

  @override
  String get changeYourReaction => 'リアクションを変更';

  @override
  String get reactionTapAgainToRemove => 'もう一度タップするとリアクションを取り消します。';

  @override
  String reactionFilterSemantics(String reaction, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$reaction、$count 人',
    );
    return '$_temp0';
  }

  @override
  String get postLikeAction => '投稿に「いいね！」する';

  @override
  String get postUnlikeAction => '「いいね！」を取り消す';

  @override
  String get postVoteRemoveFailed => '投票を取り消せませんでした（取り消せる時間を過ぎた可能性があります）';

  @override
  String get postVoteCastFailed => '投票できませんでした';

  @override
  String get postUpvote => '賛成票';

  @override
  String get postDownvote => '反対票';

  @override
  String get pollVoteFailed => '投票できませんでした。もう一度お試しください。';

  @override
  String get pollRemoveVoteFailed => '投票を取り消せませんでした。もう一度お試しください。';

  @override
  String get pollVotersLoadFailed => '投票者を読み込めませんでした。';

  @override
  String get pollVotersNotVisible => 'この投票の投票者は表示されません。';

  @override
  String solutionSolvedByInPost(String name, int postNumber) {
    return '$name さんが投稿 #$postNumber で解決';
  }

  @override
  String solutionMarkedBy(String name) {
    return '$name さんがマーク';
  }

  @override
  String reactAgainInSeconds(int seconds) {
    return '$seconds秒後にもう一度リアクションできます';
  }

  @override
  String get reactionUpdateFailed => 'リアクションを更新できませんでした。';

  @override
  String get reactionsNotSupported => 'このフォーラムはリアクションに対応していません。';

  @override
  String get reactionsLoadFailed => 'リアクションを読み込めませんでした。';

  @override
  String viewProfileOfUser(String username) {
    return '$username さんのプロフィールを見る';
  }

  @override
  String get failedToSavePost => '投稿を保存できませんでした';

  @override
  String failedToSavePostWithError(String error) {
    return '投稿を保存できませんでした: $error';
  }

  @override
  String get failedToRemoveAttachmentCheckPermissions =>
      '添付ファイルを削除できませんでした。権限を確認してください。';

  @override
  String get editPostTitle => '投稿を編集';

  @override
  String get editYourPostHint => '投稿を編集...';

  @override
  String get failedToPostReply => '返信を投稿できませんでした';

  @override
  String failedToPostReplyWithError(String error) {
    return '返信を投稿できませんでした: $error';
  }

  @override
  String get failedToCreateTopic => 'トピックを作成できませんでした';

  @override
  String get writeYourTopicTitle => 'トピックのタイトルを書く...';

  @override
  String get writeYourTopicContent => 'トピックの内容を書く...';

  @override
  String get composerTitleHint => 'タイトルを書く...';

  @override
  String get composerContentHint => '内容を書く...';

  @override
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit) {
    return '$fileName: サイズが大きすぎ（$size）、縮小できませんでした。上限は $limit です。';
  }

  @override
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit) {
    return '$fileName を上限 $limit に収まるよう $size$dimensions に縮小しました。';
  }

  @override
  String get composerAttachFileHint => 'この投稿にファイルを添付';

  @override
  String get composerUploadImageHint => 'この投稿に画像をアップロード';

  @override
  String get composerFormattingHint => '書式オプションを開く';

  @override
  String get whisperStaffOnly => 'ささやき（スタッフのみ）';

  @override
  String get whisperOnStaffOnly => 'ささやきオン（スタッフのみ）';

  @override
  String get tagInputMaxReached => 'タグの上限に達しました';

  @override
  String get tagInputAddTag => 'タグを追加…';

  @override
  String get tagInputAddAnother => '+ タグ';

  @override
  String get editHistoryUnavailable => 'このフォーラムでは編集履歴を利用できません。';

  @override
  String get editHistoryLoadFailed => '編集履歴を読み込めませんでした。';

  @override
  String get previousRevision => '前のリビジョン';

  @override
  String get nextRevision => '次のリビジョン';

  @override
  String get notificationPrefsLoadFailed => '通知設定を読み込めませんでした。';

  @override
  String get notificationPrefsSaveFailed => '保存できませんでした — 接続を確認してください';

  @override
  String get signInToManageNotificationPrefs => '通知設定を管理するにはログインしてください。';

  @override
  String get emailWhenAwayTitle => '不在時のメール';

  @override
  String get emailLevelDescription =>
      '引用されたとき、返信されたとき、自分の@ユーザー名がメンションされたとき、またはウォッチ中のカテゴリ、タグ、またはトピックに新しいアクティビティがあったときに、メールで通知する';

  @override
  String get notificationPrefAlways => '常時';

  @override
  String get notificationPrefOnlyWhenAway => '離れている時のみ';

  @override
  String get notificationPrefNever => '通知しない';

  @override
  String get emailForMessagesTitle => 'メッセージのメール';

  @override
  String get emailMessagesLevelDescription => '個人メッセージが届いたときにメールで通知する';

  @override
  String get activitySummaryTitle => 'アクティビティの概要';

  @override
  String get activitySummaryDescription => 'ここを訪れない場合、人気のトピックと返信の要約をメールで送信する';

  @override
  String get activitySummaryFrequencyTitle => 'アクティビティの概要の頻度';

  @override
  String get activitySummaryDaily => '毎日';

  @override
  String get activitySummaryWeekly => '毎週';

  @override
  String get activitySummaryMonthly => '毎月';

  @override
  String get mailingListModeTitle => 'メーリングリストモード';

  @override
  String get mailingListModeDescription =>
      'すべての投稿をメールで受け取ります（アクティビティの概要はオフになります）。投稿の多いフォーラムではおすすめしません。';

  @override
  String get likeNotificationFrequencyTitle => '「いいね！」された時に通知する';

  @override
  String get likeNotificationFirstTimeAndDaily => '投稿の最初の「いいね！」と毎日';

  @override
  String get likeNotificationFirstTime => '投稿の最初の「いいね！」';

  @override
  String get whenPostingTitle => '投稿時';

  @override
  String get whenPostingDescription => '返信したトピックの扱い';

  @override
  String get whenPostingWatchTopic => 'トピックをウォッチ';

  @override
  String get whenPostingTrackTopic => 'トピックを追跡';

  @override
  String get whenPostingDoNothing => '何もしない';

  @override
  String get pauseNotificationsUntilTomorrow => '明日まで';

  @override
  String get couldNotEnableDoNotDisturb => 'おやすみモードをオンにできませんでした';

  @override
  String get couldNotTurnOffDoNotDisturb => 'おやすみモードをオフにできませんでした';

  @override
  String get passwordResetEmailSent => 'パスワードリセットのメールを送信しました。';

  @override
  String get couldNotSendResetEmail => 'リセットメールを送信できませんでした';

  @override
  String get accountRequestFailed => 'リクエストに失敗しました。';

  @override
  String get forumUrlUnavailable => 'フォーラムのURLがありません。';

  @override
  String get couldNotOpenPreferencesPage => '設定ページを開けませんでした。';

  @override
  String get couldNotOpenForumUrl => 'フォーラムのURLを開けませんでした。';

  @override
  String get couldNotRequestEmailChange => 'メールアドレスの変更をリクエストできませんでした';

  @override
  String get newEmailLabel => '新しいメール';

  @override
  String get enterAnEmailAddress => 'メールアドレスを入力してください';

  @override
  String get emailLooksInvalid => 'メールアドレスの形式ではないようです';

  @override
  String get emailNoSpaces => 'メールアドレスにスペースは使えません';

  @override
  String get allowNotificationsSheetTitle => '通知を許可';

  @override
  String get notificationsGrantNoPayload => '許可から応答が返されませんでした。';

  @override
  String get thisForumFallback => 'このフォーラム';

  @override
  String signInToDomain(String domain) {
    return '$domain にログイン';
  }

  @override
  String get loginResultTitle => 'ログイン結果';

  @override
  String get invalidAuthenticationCode => '認証コードが正しくありません';

  @override
  String get tfaVerificationError => '認証中にエラーが発生しました。もう一度お試しください。';

  @override
  String get passwordFieldLabel => 'パスワード';

  @override
  String get somethingWentWrongTryAgain => '問題が発生しました。もう一度お試しください。';

  @override
  String get unexpectedErrorTryAgain => '予期しないエラーが発生しました。もう一度お試しください。';

  @override
  String get errorNoInternetConnection =>
      'インターネットに接続されていません。ネットワーク設定を確認してください。';

  @override
  String get errorRequestTimedOut => 'リクエストがタイムアウトしました。もう一度お試しください。';

  @override
  String get errorServerTryLater => 'サーバーエラーが発生しました。後でもう一度お試しください。';

  @override
  String get errorInvalidCredentials => 'ユーザー名またはパスワードが正しくありません。';

  @override
  String get errorSessionExpired => 'セッションの有効期限が切れました。もう一度ログインしてください。';

  @override
  String get errorAccountSuspended => 'アカウントは凍結されています。フォーラムのスタッフにお問い合わせください。';

  @override
  String get errorForumNotFound => 'フォーラムが見つかりません。';

  @override
  String get errorForumAccessDenied => 'このフォーラムにアクセスする権限がありません。';

  @override
  String get errorForumUnavailable => 'フォーラムは現在利用できません。後でもう一度お試しください。';

  @override
  String get errorDataNotFound => '要求されたデータが見つかりません。';

  @override
  String get errorDataCorrupted => 'データが破損しているようです。ページを更新してください。';

  @override
  String get errorCacheLoadFailed => 'キャッシュされたデータを読み込めませんでした。もう一度お試しください。';

  @override
  String errorInvalidField(String field) {
    return '$field が無効です。';
  }

  @override
  String errorFieldRequired(String field) {
    return '$field は必須です。';
  }

  @override
  String errorPermissionDeniedFor(String action) {
    return '$action の権限がありません。';
  }

  @override
  String errorFeatureNotAvailable(String feature) {
    return '$feature はこのフォーラムでは利用できません。';
  }

  @override
  String get errorStorageFull => 'ストレージがいっぱいです。空き容量を確保してください。';

  @override
  String get errorStorageAccessDenied => 'ストレージへのアクセスが拒否されました。アプリの権限を確認してください。';

  @override
  String get errorNetworkTryAgain => 'ネットワークエラーが発生しました。もう一度お試しください。';

  @override
  String get errorAuthenticationTryAgain => '認証に失敗しました。もう一度お試しください。';

  @override
  String get errorForumTryAgain => 'フォーラムでエラーが発生しました。もう一度お試しください。';

  @override
  String get connectionErrorTitle => '接続エラー';

  @override
  String get authenticationErrorTitle => '認証エラー';

  @override
  String get forumErrorTitle => 'フォーラムエラー';

  @override
  String get permissionErrorTitle => '権限エラー';

  @override
  String errorRemovingFromMessage(String name) {
    return 'このメッセージから $name を削除できませんでした。';
  }

  @override
  String get chatNewMessage => '新しいメッセージ';

  @override
  String get chatStarred => 'スター付き';

  @override
  String get chatBrowseChannels => 'チャンネルを閲覧する';

  @override
  String get chatBrowseAllChannels => 'すべてのチャンネルを閲覧する';

  @override
  String get chatFilterAll => 'すべて';

  @override
  String get chatFilterOpen => 'オープン';

  @override
  String get chatFilterClosed => '閉鎖';

  @override
  String get chatFilterArchived => 'アーカイブ済み';

  @override
  String get chatBrowseSearch => 'チャンネル名で検索';

  @override
  String get chatJoin => '参加';

  @override
  String get chatJoined => '参加中';

  @override
  String get chatLeave => '退出';

  @override
  String chatMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 人のメンバー',
    );
    return '$_temp0';
  }

  @override
  String get chatYesterday => '昨日';

  @override
  String get chatNoChannelsFound => 'チャンネルが見つかりません';

  @override
  String get chatCloseDm => 'このパーソナルチャットを閉じる';

  @override
  String get chatToday => '今日';

  @override
  String get chatLastVisit => '最後の訪問';

  @override
  String chatNewMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '新しいメッセージ $count 件',
    );
    return '$_temp0';
  }

  @override
  String get chatScrollToBottom => '一番下にスクロール';

  @override
  String get chatInReplyTo => '返信先';
}
