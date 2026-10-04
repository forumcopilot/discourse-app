// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get uploadSessionChanged =>
      '업로드 중에 로그인 상태가 변경되었습니다. 이 화면을 다시 연 후 다시 시도해 주세요.';

  @override
  String get submissionUnconfirmed =>
      '전송 여부를 확인하지 못했습니다. 작성한 내용은 유지되었습니다. 다시 시도하기 전에 포럼을 확인해 주세요.';

  @override
  String get loginTitle => '로그인';

  @override
  String get usePasskey => 'Use Passkey';

  @override
  String get passkeyContinuePrompt => 'Use your passkey to continue';

  @override
  String get continueButton => '계속';

  @override
  String get errorTitle => '오류';

  @override
  String get okButton => '확인';

  @override
  String get retryButton => '다시 시도';

  @override
  String get copyToClipboard => '클립보드에 복사';

  @override
  String get copied => '복사됨';

  @override
  String get errorMessageCopiedToClipboard => '오류 메시지가 클립보드에 복사되었습니다';

  @override
  String get dismiss => '닫기';

  @override
  String get cancel => '취소';

  @override
  String get tryAgain => '다시 시도';

  @override
  String get anErrorOccurred => '오류가 발생했습니다';

  @override
  String get accountPendingApproval =>
      '계정이 승인 대기 중입니다. 포럼을 둘러볼 수 있지만 관리자가 계정을 승인할 때까지 게시할 수 없습니다.';

  @override
  String get checkEmailToConfirm =>
      '계정을 인증하려면 이메일을 확인하세요. 보낸 이메일의 인증 링크를 클릭하세요.';

  @override
  String get checkNewEmailToConfirm =>
      '변경 사항을 확인하려면 새 이메일 주소를 확인하세요. 새 이메일을 확인할 때까지 기존 이메일이 활성 상태로 유지됩니다.';

  @override
  String get emailAddressInvalid =>
      '이메일 주소가 유효하지 않거나 이메일을 거부하는 것 같습니다. 계정 설정에서 이메일 주소를 업데이트하세요.';

  @override
  String get accountDisabled => '계정이 비활성화되었습니다. 도움을 받으려면 관리자에게 문의하세요.';

  @override
  String get accountRegistrationRejected =>
      '계정 등록이 거부되었습니다. 자세한 내용은 관리자에게 문의하세요.';

  @override
  String get welcomeToForumCopilot => 'Forum Copilot에 오신 것을 환영합니다!';

  @override
  String get successfullyLoggedOut => '성공적으로 로그아웃되었습니다';

  @override
  String get accountStatusRequiresAttention =>
      '계정 상태에 주의가 필요합니다. 질문이 있으시면 관리자에게 문의하세요.';

  @override
  String get updateEmail => '이메일 업데이트';

  @override
  String get resend => '다시 보내기';

  @override
  String get noLatestTopics => '최신 주제 없음';

  @override
  String get noRecentTopicsToDisplay => '표시할 최신 주제가 없습니다. 나중에 새로운 토론을 확인하세요.';

  @override
  String get signInToViewLatestTopics => '최신 주제를 보려면 로그인하세요';

  @override
  String get youNeedToBeSignedInToViewLatestTopics => '최신 주제를 보려면 로그인해야 합니다';

  @override
  String get thereAreNoUnreadTopics => '읽지 않은 주제가 없습니다. 나중에 새로운 토론을 확인하세요.';

  @override
  String get youAreAllCaughtUp => '모두 확인하셨습니다!';

  @override
  String get signInToViewUnreadTopics => '읽지 않은 주제를 보려면 로그인하세요';

  @override
  String get youNeedToBeSignedInToViewUnreadTopics => '읽지 않은 주제를 보려면 로그인해야 합니다';

  @override
  String get latest => '최신';

  @override
  String get unread => '읽지 않음';

  @override
  String get failedToConnectToSite =>
      '사이트에 연결하지 못했습니다. 사이트가 다운되었거나 접근할 수 없을 수 있습니다.';

  @override
  String get connectionFailed => '연결 실패';

  @override
  String failedToConnectToSiteName(String siteName) {
    return '$siteName에 연결하지 못했습니다';
  }

  @override
  String get loading => '로드 중...';

  @override
  String get newConversation => '새 메시지';

  @override
  String get language => '언어';

  @override
  String get all => '전체';

  @override
  String get topicsOnly => '주제만';

  @override
  String get titlesOnly => '제목만';

  @override
  String failedToShareTopic(String error) {
    return '주제 공유 실패: $error';
  }

  @override
  String get youCannotReplyToThisThread => '이 글에 댓글을 달 수 없습니다';

  @override
  String get pleaseWaitForThreadToLoad => '글을 불러올 때까지 기다려 주세요';

  @override
  String get reason => '사유';

  @override
  String get participantsLabel => '참가자';

  @override
  String usernameHasBeenInvited(String username) {
    return '$username님을 메시지에 초대했습니다';
  }

  @override
  String errorInvitingUser(String error) {
    return '사용자 초대 오류: $error';
  }

  @override
  String get newTopic => '새 주제';

  @override
  String get pleaseSpecifyReason => '사유를 지정하세요';

  @override
  String get selectDate => '날짜 선택';

  @override
  String get moreOptions => '더 많은 옵션';

  @override
  String get topicClosed => '주제 닫힘';

  @override
  String get topicOpened => '주제 열림';

  @override
  String get noConversations => '메시지가 없습니다';

  @override
  String get noConversationsMessage => '아직 메시지가 없습니다. 새 메시지를 작성해 시작하세요.';

  @override
  String get imageSavedToGallery => '이미지가 갤러리에 저장되었습니다!';

  @override
  String failedToSaveImage(String error) {
    return '이미지 저장 실패: $error';
  }

  @override
  String get userProfile => '사용자 프로필';

  @override
  String get deletePost => '게시물 삭제';

  @override
  String get loginRequired => '로그인 필요';

  @override
  String get sendMessage => '메시지';

  @override
  String get likesReceived => '받은 좋아요';

  @override
  String get showMore => '더 보기';

  @override
  String get failedToSaveConversation => '메시지를 저장하지 못했습니다';

  @override
  String get members => '회원';

  @override
  String membersCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString명';
  }

  @override
  String get noSubject => '제목 없음';

  @override
  String get search => '검색';

  @override
  String get logout => '로그아웃';

  @override
  String get areYouSureYouWantToLogout => '로그아웃하시겠습니까?';

  @override
  String get signIn => '로그인';

  @override
  String get notificationTest => '알림 테스트';

  @override
  String get forum => '카테고리';

  @override
  String get profile => '프로필';

  @override
  String get messages => '메시지';

  @override
  String get add => '추가';

  @override
  String get retry => '다시 시도';

  @override
  String get delete => '삭제';

  @override
  String get deleteMessage => '메시지 삭제';

  @override
  String get deletingPost => '게시물 삭제 중...';

  @override
  String failedToUnlikePost(String error) {
    return '게시물 좋아요 취소 실패: $error';
  }

  @override
  String failedToLikePost(String error) {
    return '게시물 좋아요 실패: $error';
  }

  @override
  String get signInToViewMessages => '메시지를 보려면 로그인하세요';

  @override
  String get youNeedToBeSignedInToViewConversations => '메시지를 보려면 로그인해야 합니다.';

  @override
  String failedToLeaveConversation(String error) {
    return '메시지에서 나가지 못했습니다: $error';
  }

  @override
  String errorLoadingMoreConversations(String error) {
    return '메시지를 더 불러오는 중 오류: $error';
  }

  @override
  String get searchFailed => '검색 실패';

  @override
  String get userInformationNotAvailable => '사용자 정보를 사용할 수 없습니다';

  @override
  String get birthday => '생일';

  @override
  String get posts => '게시물';

  @override
  String get following => '팔로잉';

  @override
  String get followers => '팔로워';

  @override
  String get about => '소개';

  @override
  String get location => '위치';

  @override
  String get website => '웹사이트';

  @override
  String get next => '다음';

  @override
  String get temporary => '임시';

  @override
  String get back => '뒤로';

  @override
  String get confirm => '확인';

  @override
  String error(String error) {
    return '오류: $error';
  }

  @override
  String get removeAttachment => '첨부 파일 제거';

  @override
  String get areYouSureYouWantToRemoveThisAttachment => '이 첨부 파일을 제거하시겠습니까?';

  @override
  String get none => '없음';

  @override
  String get attachFile => '파일 첨부';

  @override
  String get uploadImage => '이미지 업로드';

  @override
  String get formatting => '서식';

  @override
  String get bold => '굵게';

  @override
  String get italic => '기울임꼴';

  @override
  String get underline => '밑줄';

  @override
  String get strikethrough => '취소선';

  @override
  String get link => '링크';

  @override
  String get image => '이미지';

  @override
  String get video => '동영상';

  @override
  String get quote => '인용';

  @override
  String get code => '코드';

  @override
  String get spoiler => '스포일러';

  @override
  String get bulletList => '글머리 기호 목록';

  @override
  String get numberedList => '번호 매기기 목록';

  @override
  String get listItem => '목록 항목';

  @override
  String participants(int count) {
    return '참가자 ($count)';
  }

  @override
  String get markAsUnread => '읽지 않음으로 표시';

  @override
  String get invite => '초대';

  @override
  String get enterKeywordsToSearchTopics => '주제를 검색할 키워드 입력...';

  @override
  String get refresh => '새로고침';

  @override
  String get share => '공유';

  @override
  String get viewOnWeb => '웹에서 보기';

  @override
  String get reply => '답장';

  @override
  String get vote => '투표';

  @override
  String votesCount(int count) {
    return '$count표';
  }

  @override
  String get pollClosed => '투표 종료';

  @override
  String pollEndsOn(String date) {
    return '$date에 종료';
  }

  @override
  String get voteToSeeResults => '결과를 보려면 투표하세요';

  @override
  String get viewFullPoll => '전체 투표 보기';

  @override
  String pollOptionsCount(int count) {
    return '$count개 옵션';
  }

  @override
  String get reactedBy => '반응한 사람';

  @override
  String get enterKeywordsToFindTopicsAndPosts => '키워드를 입력하여 주제와 게시물 찾기';

  @override
  String get light => '라이트';

  @override
  String get dark => '다크';

  @override
  String get appearance => '테마';

  @override
  String get appearanceSystem => '시스템 기본값';

  @override
  String version(String version, String buildNumber) {
    return '버전 $version ($buildNumber)';
  }

  @override
  String get unableToLoadProfile => '프로필을 불러올 수 없습니다';

  @override
  String get banned => '차단됨';

  @override
  String get deleteTopic => '글 삭제';

  @override
  String get home => '홈';

  @override
  String get notifications => '알림';

  @override
  String get forums => '카테고리';

  @override
  String get content => '내용';

  @override
  String get pleaseEnterTitle => '제목을 입력하세요';

  @override
  String get pleaseEnterContent => '내용을 입력하세요';

  @override
  String get uploading => '업로드 중...';

  @override
  String get uploaded => '업로드됨';

  @override
  String get mentionUser => '사용자 멘션';

  @override
  String get writeYourMessage => '메시지 작성...';

  @override
  String get writeYourReply => '답장 작성...';

  @override
  String get conversationMarkedAsUnread => '메시지를 읽지 않음으로 표시했습니다';

  @override
  String get conversationClosed => '메시지를 잠갔습니다';

  @override
  String get conversationOpened => '메시지를 열었습니다';

  @override
  String failedToLoadQuote(String error) {
    return '인용문을 불러오지 못했습니다: \n$error';
  }

  @override
  String failedToMarkConversationAsUnread(String error) {
    return '메시지를 읽지 않음으로 표시하지 못했습니다: $error';
  }

  @override
  String failedToCloseConversation(String error) {
    return '메시지를 잠그지 못했습니다: $error';
  }

  @override
  String failedToOpenConversation(String error) {
    return '메시지를 열지 못했습니다: $error';
  }

  @override
  String get goToTop => '맨 위로';

  @override
  String get goToBottom => '맨 아래로';

  @override
  String get pleaseLoginToAccessContent => '이 콘텐츠에 액세스하고 게시물과 상호 작용하려면 로그인하세요.';

  @override
  String get searchUsers => '사용자 검색...';

  @override
  String get enterConversationTitle => '메시지 제목 입력';

  @override
  String enterCode(int count) {
    return '$count자리 코드 입력';
  }

  @override
  String get edit => '편집';

  @override
  String get remove => '제거';

  @override
  String get subject => '제목';

  @override
  String get message => '메시지';

  @override
  String get titleCannotBeEmpty => '제목을 입력하세요';

  @override
  String get conversationUpdatedSuccessfully => '메시지를 수정했습니다';

  @override
  String get goBack => '돌아가기';

  @override
  String get like => '좋아요';

  @override
  String get download => '다운로드';

  @override
  String downloading(String filename) {
    return '$filename 다운로드 중...';
  }

  @override
  String openingShareSheet(String filename) {
    return '$filename 공유 시트 열기';
  }

  @override
  String errorDownloading(String filename, String error) {
    return '$filename 다운로드 오류: $error';
  }

  @override
  String couldNotOpenLink(String error) {
    return '링크를 열 수 없습니다: $error';
  }

  @override
  String get translating => '번역 중...';

  @override
  String get translated => '번역됨';

  @override
  String get translatedContent => '번역된 내용';

  @override
  String get twoFactorAuthentication => '2단계 인증';

  @override
  String get authenticationCodeLabel => '인증 코드';

  @override
  String get pleaseEnterYourAuthenticationCode => '인증 코드를 입력하세요';

  @override
  String codeMustBeDigits(int count) {
    return '코드는 $count자리여야 합니다';
  }

  @override
  String get codeMustContainOnlyNumbers => '코드는 숫자만 포함해야 합니다';

  @override
  String get verifyButton => '확인';

  @override
  String get attachments => '첨부파일';

  @override
  String get replyOptions => '답글 옵션';

  @override
  String get replyWithQuote => '인용하여 답글';

  @override
  String fileSavedToDownloads(String filename) {
    return '파일이 다운로드에 저장되었습니다: $filename';
  }

  @override
  String fileSavedToDocuments(String filename) {
    return '파일이 문서에 저장되었습니다: $filename';
  }

  @override
  String topicLastReplyBy(String username, String time) {
    return '$username님이 $time에 답글';
  }

  @override
  String inReplyToUser(String username) {
    return '$username님에 대한 답글';
  }

  @override
  String inReplyToPost(int number) {
    return '게시물 #$number에 대한 답글';
  }

  @override
  String timeGapDaysLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count일 후',
    );
    return '$_temp0';
  }

  @override
  String timeGapMonthsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개월 후',
    );
    return '$_temp0';
  }

  @override
  String timeGapYearsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count년 후',
    );
    return '$_temp0';
  }

  @override
  String get profileViews => '조회수';

  @override
  String get badges => '배지';

  @override
  String get chatWithUser => '채팅';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '답글 $count개',
    );
    return '$_temp0';
  }

  @override
  String get chat => '채팅';

  @override
  String moreBadges(Object count) {
    return '+$count개 더';
  }

  @override
  String get allNotificationsMarkedAsRead => '모든 알림을 읽음으로 표시했습니다';

  @override
  String get apply => '적용';

  @override
  String get bookmarks => '북마크';

  @override
  String reviewableBy(String username) {
    return '$username 작성';
  }

  @override
  String get changeEmail => '이메일 변경';

  @override
  String get changePassword => '비밀번호 변경';

  @override
  String get checkingStatus => '상태 확인 중…';

  @override
  String get clearReminder => '알림 지우기';

  @override
  String get copy => '복사';

  @override
  String get copyLink => '링크 복사';

  @override
  String couldNotEnableNotifications(String error) {
    return '알림을 켤 수 없습니다: $error';
  }

  @override
  String get couldNotFindBookmark => '이 북마크를 찾을 수 없습니다';

  @override
  String couldNotOpenEmail(String email) {
    return '이메일을 열 수 없습니다: $email';
  }

  @override
  String couldNotStartSignIn(String error) {
    return '로그인을 시작할 수 없습니다: $error';
  }

  @override
  String get customDateAndTime => '날짜와 시간 지정';

  @override
  String get deleteAccount => '계정 삭제';

  @override
  String get deleteMessageQuestion => '메시지를 삭제할까요?';

  @override
  String get discard => '버리기';

  @override
  String get doNotDisturb => '방해 금지';

  @override
  String get editHistory => '편집 기록';

  @override
  String get editProfile => '프로필 편집';

  @override
  String get editReminder => '알림 편집';

  @override
  String emailCopiedToClipboard(String email) {
    return '이메일을 클립보드에 복사했습니다: $email';
  }

  @override
  String get pushEnabledForThisLogin => '이 로그인에서 사용 중';

  @override
  String get failedToLoadMoreTopics => '더 많은 주제를 불러오지 못했습니다. 스크롤하여 다시 시도하세요.';

  @override
  String get failedToUpdateNotificationLevel => '알림 수준을 변경하지 못했습니다';

  @override
  String get firstPostsOnly => '첫 게시물만';

  @override
  String get ignoredUsers => '무시한 사용자';

  @override
  String get inTwoHours => '두 시간 후';

  @override
  String get inviteByEmail => '이메일로 초대';

  @override
  String get inviteLinkCopied => '초대 링크를 복사했습니다';

  @override
  String inviteSentTo(String email) {
    return '$email(으)로 초대를 보냈습니다';
  }

  @override
  String get leave => '나가기';

  @override
  String get leaveGroup => '그룹 나가기';

  @override
  String get leaveGroupQuestion => '그룹에서 나갈까요?';

  @override
  String get linkCopied => '링크를 복사했습니다';

  @override
  String get loadMore => '더 불러오기';

  @override
  String get manageAccountOnWeb => '웹에서 계정 관리';

  @override
  String get merge => '병합';

  @override
  String get mergeIntoTopic => '주제에 병합';

  @override
  String get newInviteLink => '새 초대 링크';

  @override
  String get nextWeek => '다음 주';

  @override
  String get pushNotAvailableInThisBuild => '이 빌드에서는 사용할 수 없습니다';

  @override
  String get notNow => '나중에';

  @override
  String tagNotificationLevelUpdated(String tag) {
    return '\"$tag\" 알림 수준을 변경했습니다';
  }

  @override
  String doNotDisturbOnUntil(String until) {
    return '$until까지 켜짐';
  }

  @override
  String get pleaseLogInToBookmark => '북마크하려면 로그인하세요';

  @override
  String get pleaseLogInToFollowUsers => '사용자를 팔로우하려면 로그인하세요';

  @override
  String get pleaseLogInToMarkAnswers => '답변을 표시하려면 로그인하세요';

  @override
  String get pleaseLogInToReact => '반응하려면 로그인하세요';

  @override
  String get pleaseLogInToVote => '투표하려면 로그인하세요';

  @override
  String get pushNotifications => '푸시 알림';

  @override
  String get relevance => '관련성';

  @override
  String get reminderTimeMustBeInFuture => '알림 시간은 미래여야 합니다';

  @override
  String get removeBookmark => '북마크 삭제';

  @override
  String get removeVote => '투표 취소';

  @override
  String get renameTopic => '주제 이름 변경';

  @override
  String reportedBy(String username) {
    return '$username 신고';
  }

  @override
  String get requestToJoin => '가입 요청';

  @override
  String requestToJoinGroup(String group) {
    return '$group 가입 요청';
  }

  @override
  String get reset => '초기화';

  @override
  String get resizeAndUpload => '크기 조정 후 업로드';

  @override
  String get checkConnectionAndRetry => '인터넷 연결을 확인한 후 다시 시도하세요.';

  @override
  String get reviewQueue => '검토 대기열';

  @override
  String get revoke => '취소';

  @override
  String get revokeInviteQuestion => '초대를 취소할까요?';

  @override
  String get save => '저장';

  @override
  String get sendInvite => '초대 보내기';

  @override
  String get sendRequest => '요청 보내기';

  @override
  String get settings => '설정';

  @override
  String get showVoters => '투표자 보기';

  @override
  String get signOut => '로그아웃';

  @override
  String get signInCancelledNoPayload => '로그인이 취소되었습니다 — 응답이 없습니다';

  @override
  String signInFailed(String error) {
    return '로그인 실패: $error';
  }

  @override
  String get startChat => '채팅 시작';

  @override
  String stoppedIgnoringUser(String username) {
    return '@$username 무시를 해제했습니다';
  }

  @override
  String get titleOnly => '제목만';

  @override
  String get tomorrow => '내일';

  @override
  String get turnOff => '끄기';

  @override
  String get turnOnNotifications => '알림 켜기';

  @override
  String get whisper => '귓속말';

  @override
  String likeAgainInSeconds(Object seconds) {
    return '$seconds초 후에 다시 좋아요를 누를 수 있습니다';
  }

  @override
  String get loginInfo => '로그인 정보';

  @override
  String get loginFailed => '로그인 실패';

  @override
  String get moveToCategory => '카테고리로 이동';

  @override
  String get undeleteTopic => '주제 삭제 취소';

  @override
  String get send => '보내기';

  @override
  String get changeEmailExplanation =>
      '새 이메일로 확인 링크를 보냅니다. 링크를 클릭하면 변경이 적용됩니다.';

  @override
  String get changeEmailSecurityNote =>
      '보안을 위해 Discourse가 이메일의 링크로 확인을 요구할 수 있습니다. 보이지 않으면 스팸 폴더를 확인하세요.';

  @override
  String get noMessagesYetSayHi => '아직 메시지가 없습니다 — 인사해 보세요.';

  @override
  String get edited => '수정됨';

  @override
  String get approvedButRelayUnreachable =>
      '승인되었지만 설정을 완료하기 위한 알림 서버에 연결할 수 없습니다. 나중에 설정에서 다시 시도해 주세요.';

  @override
  String get notificationsAreTurnedOffForThisApp => '이 앱의 알림이 꺼져 있습니다';

  @override
  String get pleaseLoginToCreateANewTopic => '새 주제를 만들려면 로그인하세요';

  @override
  String get pleaseLoginToSubscribeToForums => '포럼을 구독하려면 로그인하세요';

  @override
  String leaveGroupWarning(Object group) {
    return '더 이상 $group의 구성원이 아니게 됩니다. 언제든지 다시 가입할 수 있습니다.';
  }

  @override
  String get groupMembersPrivate => '이 그룹의 구성원 목록은 비공개입니다.';

  @override
  String get unignore => '무시 해제';

  @override
  String get inviteLinkCreated => '초대 링크를 만들었습니다';

  @override
  String expiresOn(Object date) {
    return '$date 만료';
  }

  @override
  String get solution => '해결책';

  @override
  String get deleted => '삭제됨';

  @override
  String get pleaseLoginToViewUserProfiles => '사용자 프로필을 보려면 로그인하세요.';

  @override
  String get solved => '해결됨';

  @override
  String get hot => '인기';

  @override
  String get pinned => '고정됨';

  @override
  String get locked => '잠김';

  @override
  String get poll => '투표';

  @override
  String get noDiscussionsYet => '아직 토론이 없습니다.';

  @override
  String get jumpToPost => '게시물로 이동';

  @override
  String get jump => '이동';

  @override
  String get endOfTheDiscussion => '토론 끝';

  @override
  String get reviewQueueStaffOnly => '검토 대기열은 스태프와 검토자만 볼 수 있습니다.';

  @override
  String get nothingToReview => '검토할 항목이 없습니다';

  @override
  String refreshFailed(Object error) {
    return '새로고침 실패: $error';
  }

  @override
  String get refreshing => '새로고침 중...';

  @override
  String get title => '제목';

  @override
  String editedAt(Object time) {
    return '$time 수정';
  }

  @override
  String editReason(Object reason) {
    return '사유: $reason';
  }

  @override
  String get thisDiffIsTooLargeToDisplay => '이 변경 내용은 너무 커서 표시할 수 없습니다.';

  @override
  String get noContentChangesInThisRevision => '이 수정본에는 내용 변경이 없습니다.';

  @override
  String revisionOf(Object currentVersion, Object versionCount) {
    return '수정본 $currentVersion/$versionCount';
  }

  @override
  String get editConversation => '제목 수정';

  @override
  String get closeConversation => '메시지 잠금';

  @override
  String get openConversation => '메시지 열기';

  @override
  String get leaveConversation2 => '메시지에서 나가기';

  @override
  String get closeConversation2 => '메시지 잠금';

  @override
  String get closeConversationConfirmation =>
      '이 메시지를 잠글까요? 더 이상 새 답글을 받을 수 없습니다.';

  @override
  String get close => '닫기';

  @override
  String get openConversation2 => '메시지 열기';

  @override
  String get openConversationConfirmation => '이 메시지를 열까요? 다시 새 답글을 받을 수 있습니다.';

  @override
  String get open => '열기';

  @override
  String get leaveConversation3 => '메시지에서 나가기';

  @override
  String get leaveConversationConfirmation =>
      '이 메시지에서 자신을 제거할까요? 더 이상 보거나 답글을 달 수 없습니다.';

  @override
  String get editConversation2 => '제목 수정';

  @override
  String get failedToLoadMessage2 => '메시지를 불러오지 못했습니다';

  @override
  String get cannotEditThisConversation => '이 메시지를 수정할 수 없습니다';

  @override
  String get options => '옵션';

  @override
  String get conversationOpen => '답글 허용';

  @override
  String get messageTitleHint => '토론 주제를 한 문장으로 적으세요';

  @override
  String get messageOpenForReplies => '새 답글을 받을 수 있습니다';

  @override
  String get messageClosedForReplies => '잠김: 새 답글을 받지 않습니다';

  @override
  String get messageSentWithoutId => '메시지를 보냈지만 포럼이 반환하지 않았습니다. 메시지함을 확인하세요.';

  @override
  String get messageCouldNotBeSent => '메시지를 보내지 못했습니다.';

  @override
  String get messageIdMissing => '이 메시지를 열 수 없습니다: ID가 없습니다.';

  @override
  String get pleaseAddARecipient => '받는 사람을 한 명 이상 추가하세요';

  @override
  String get archiveMessage => '보관';

  @override
  String get moveToInbox => '받은 편지함으로 이동';

  @override
  String get messageInbox => '받은 편지함';

  @override
  String get messageArchive => '보관';

  @override
  String get messageListUnread => '읽지 않음';

  @override
  String get messageListNew => '새글';

  @override
  String get messageListSent => '전송됨';

  @override
  String removeFromMessageConfirm(String name) {
    return '$name 님을 메시지에서 제거할까요?';
  }

  @override
  String uploadingFilename(String filename) {
    return '업로드 중: $filename…';
  }

  @override
  String get messageArchived => '메시지를 보관했습니다';

  @override
  String get messageMovedToInbox => '받은 편지함으로 이동했습니다';

  @override
  String failedToArchiveMessage(Object error) {
    return '메시지를 보관하지 못했습니다: $error';
  }

  @override
  String failedToMoveMessageToInbox(Object error) {
    return '메시지를 받은 편지함으로 이동하지 못했습니다: $error';
  }

  @override
  String get noArchivedMessages => '보관한 메시지가 없습니다';

  @override
  String get noArchivedMessagesHint => '메시지의 ⋮ 메뉴에서 보관하면 여기에 모입니다.';

  @override
  String groupHasBeenInvited(String group) {
    return '$group 그룹을 메시지에 초대했습니다';
  }

  @override
  String participantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '참여자 $count명',
    );
    return '$_temp0';
  }

  @override
  String get chatChannels => '채널';

  @override
  String get chatDms => 'DM';

  @override
  String get chatNoChannels => '아직 참여한 채널이 없습니다!';

  @override
  String get chatNoDms => '아직 개인 메시지가 없습니다!';

  @override
  String get chatNoDmsCta => '대화 시작하기';

  @override
  String chatPlaceholderChannel(String channel) {
    return '$channel에서 채팅';
  }

  @override
  String chatPlaceholderUsers(String names) {
    return '$names과 채팅';
  }

  @override
  String get chatPlaceholderSelf => '메모하기';

  @override
  String get chatPlaceholderArchived => '채널이 보관되어 메시지를 보낼 수 없습니다.';

  @override
  String get chatPlaceholderClosed => '채널이 닫혀 있어 지금은 메시지를 보낼 수 없습니다.';

  @override
  String get chatPlaceholderReadOnly => '채널이 읽기 전용이므로 메시지를 보낼 수 없습니다.';

  @override
  String get chatPlaceholderSilenced => '지금은 메시지를 보낼 수 없습니다.';

  @override
  String get chatDeleteConfirm => '이 메시지를 삭제할까요?';

  @override
  String get chatStartNewDm => '새로운 채팅 시작';

  @override
  String get chatCreatePersonal => '개인 채팅 만들기';

  @override
  String get chatCreateGroup => '그룹 채팅 만들기';

  @override
  String get chatCannotCreate => '죄송합니다. 다이렉트 메시지를 보낼 수 없습니다.';

  @override
  String get chatDisabledUser => '채팅 비활성화됨';

  @override
  String get chatSearchPlaceholder => '@누군가';

  @override
  String get chatAddMorePlaceholder => '...사용자 추가';

  @override
  String chatUserNotFound(String name) {
    return '@$name을(를) 찾을 수 없습니다';
  }

  @override
  String get chatCouldNotStartDm => '채팅을 시작하지 못했습니다.';

  @override
  String get chatSignInTitle => '채팅을 사용하려면 로그인하세요';

  @override
  String get chatSignInMessage => '채팅 채널을 보고 참여하려면 로그인해야 합니다.';

  @override
  String get chatDirectMessage => '다이렉트 메시지';

  @override
  String get chatNotAvailable => '이 포럼에서는 채팅을 사용할 수 없습니다.';

  @override
  String get chatAttachFile => '파일 첨부';

  @override
  String get chatRemoveUpload => '파일 제거';

  @override
  String get takePhoto => '사진 촬영';

  @override
  String get postNeedsApprovalTitle => '승인이 필요한 게시물';

  @override
  String get postNeedsApprovalBody =>
      '새 게시물이 있습니다. 그러나 이 게시물이 보여지려면 운영자의 승인이 필요합니다. 잠시 기다려 주세요.';

  @override
  String maximumAttachmentsAllowed(Object count) {
    return '최대 $count개의 첨부 파일만 허용됩니다';
  }

  @override
  String get noImagesFoundToDisplay => '표시할 이미지가 없습니다.';

  @override
  String get searchForTopics => '주제 검색';

  @override
  String get noTopicsFound => '주제를 찾을 수 없습니다';

  @override
  String get trySearchingWithDifferentKeywords => '다른 키워드로 검색해 보세요';

  @override
  String get noPostsFound => '게시물을 찾을 수 없습니다';

  @override
  String get perTopicNotificationLevelsNote =>
      '카테고리별·주제별 알림 수준은 해당 화면에서 직접 설정합니다 — 주제나 카테고리의 종 아이콘을 탭하세요.';

  @override
  String get pushNotActiveForThisLogin =>
      '이 로그인에서는 비활성 — 로그아웃 후 다시 로그인하여 푸시 알림을 허용하세요';

  @override
  String get pauseNotificationsFor => '알림 일시 중지 기간…';

  @override
  String get doNotDisturbExplanation =>
      '알림을 잠시 멈춥니다 — 기간이 끝날 때까지 Discourse가 보관합니다';

  @override
  String get manageAccountSubtitle => '프로필, 이메일, 비밀번호, 보안, 고급 설정';

  @override
  String get changePasswordSubtitle => '현재 주소로 비밀번호 재설정 이메일을 보냅니다';

  @override
  String get ignoredUsersSubtitle => '게시물이 숨겨진 사용자를 보고 관리';

  @override
  String get deleteAccountExplanation =>
      '포럼이 허용하면 계정과 게시물을 삭제할 수 있습니다. 허용하지 않으면 운영진이 대신 삭제해 드릴 수 있습니다.';

  @override
  String get verificationEmailSent => '확인 이메일을 보냈습니다 — 링크를 클릭하여 새 주소를 확인하세요.';

  @override
  String get passwordResetExplanation =>
      '비밀번호 재설정 링크를 이메일로 보냅니다. 링크를 클릭해 새 비밀번호를 정하세요 — 변경은 이 앱이 아니라 포럼에서 처리됩니다.';

  @override
  String get sendResetEmail => '재설정 이메일 보내기';

  @override
  String get deleteAccountDialogBody =>
      '계정은 포럼에서 관리합니다. 계정 삭제는 포럼 스태프에게 직접 요청하세요. 계속을 누르면 브라우저에서 포럼이 열려 사이트의 문의/스태프 메시지 기능을 사용할 수 있습니다.';

  @override
  String get initializingForum => '포럼 초기화 중…';

  @override
  String get errorLoadingNotifications => '알림 불러오기 오류';

  @override
  String get noNewNotificationsExplanation =>
      '이 패널에서는 나와 직접적으로 관련된 활동에 대한 알림을 받습니다. 예를 들면 내 글 및 게시물에 대한 댓글, 누군가 나를 @언급 또는 인용할 때, 내가 구독하는 글에 댓글을 달 때입니다. 한동안 로그인하지 않은 경우에도 이메일로 알림이 전송됩니다.';

  @override
  String noTagsMatch(Object filter) {
    return '\"$filter\"과(와) 일치하는 태그가 없습니다.';
  }

  @override
  String noTopicsTagged(Object tag) {
    return '\"$tag\" 태그가 있는 주제가 없습니다';
  }

  @override
  String get searchUser => '사용자 검색';

  @override
  String get tapToOpen => '탭하여 열기';

  @override
  String get imageNotAvailable => '이미지를 사용할 수 없습니다';

  @override
  String postsCount(Object count) {
    return '게시물 $count개';
  }

  @override
  String get permissionDeniedToSaveImage => '이미지를 저장할 권한이 없습니다';

  @override
  String get postNotFound => '게시물을 찾을 수 없습니다.';

  @override
  String get failedToUploadFilePleaseTryAgain => '파일을 업로드하지 못했습니다. 다시 시도하세요.';

  @override
  String failedToUploadFile2(Object errorMessage) {
    return '파일 업로드 실패: $errorMessage';
  }

  @override
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return '$remainingSlots개의 첨부 파일만 더 추가할 수 있습니다. 처음 $remainingSlots2개의 이미지를 처리합니다.';
  }

  @override
  String failedToRemoveAttachment2(Object error) {
    return '첨부 파일을 제거하지 못했습니다: $error';
  }

  @override
  String sentFromMobileApp(Object siteName) {
    return '$siteName 모바일 앱에서 보냄';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      '첨부 파일 업로드가 끝날 때까지 기다려 주세요';

  @override
  String get imageIsTooLargeToUpload => '이미지가 너무 커서 업로드할 수 없습니다';

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName의 크기는 $fileBytes입니다. 이 포럼은 최대 $maxBytes까지 허용합니다.';
  }

  @override
  String get resizeToFitExplanation =>
      '형식을 유지한 채 제한에 맞을 만큼만 축소하며 가능한 한 세부 묘사를 보존합니다.';

  @override
  String get failedToPostReplyPleaseTryAgain => '답글을 게시하지 못했습니다. 다시 시도하세요.';

  @override
  String get failedToUpdatePostPleaseTryAgain => '게시물을 수정하지 못했습니다. 다시 시도하세요.';

  @override
  String get postDeletedSuccessfully => '게시물을 삭제했습니다';

  @override
  String failedToDeletePost(Object error) {
    return '게시물 삭제 실패: $error';
  }

  @override
  String get editHistoryNotAvailable => '이 게시물의 편집 기록을 볼 수 없습니다';

  @override
  String get react => '반응';

  @override
  String get reactionsAreNotEnabledOnThisForum => '이 포럼에서는 반응 기능이 꺼져 있습니다.';

  @override
  String get noReactionsYet => '아직 반응이 없습니다';

  @override
  String get searchFilters => '검색 필터';

  @override
  String get suggestedTopics => '추천 주제';

  @override
  String get suggestedMessages => '제안된 메시지';

  @override
  String get voteRemoved => '투표를 취소했습니다';

  @override
  String get voters => '투표자';

  @override
  String get noVotesYet => '아직 투표가 없습니다.';

  @override
  String get trustLevels => '신뢰 등급';

  @override
  String get trustLevelsExplanation =>
      '구성원은 읽고 참여하며 신뢰를 쌓습니다. 등급마다 새로운 기능이 열립니다.';

  @override
  String get activity => '활동';

  @override
  String get dontUpload => '업로드 안 함';

  @override
  String get dontAskAgainAlwaysResize => '다시 묻지 않기 — 항상 크기에 맞게 조정';

  @override
  String get couldNotLoadCategories => '카테고리를 불러오지 못했습니다.';

  @override
  String get tags => '태그';

  @override
  String get community => '커뮤니티';

  @override
  String get users => '사용자';

  @override
  String get groups => '그룹';

  @override
  String get invites => '초대';

  @override
  String get account => '계정';

  @override
  String get drafts => '임시 저장';

  @override
  String get termsOfService => '서비스 약관';

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get notSignedIn => '로그인하지 않음';

  @override
  String get deviceWillNotShowAlertsUntilAllowedInSettings =>
      '설정에서 알림을 허용할 때까지 이 기기에는 알림이 표시되지 않습니다.';

  @override
  String get openSettings => '설정 열기';

  @override
  String get notificationsThisDeviceSection => '이 기기';

  @override
  String notificationsThisDeviceCaption(Object forumName) {
    return '$forumName의 푸시는 이 기기에만 해당됩니다. 다른 기기와 웹에는 영향이 없습니다.';
  }

  @override
  String notificationsAccountSection(Object forumName) {
    return '$forumName 계정';
  }

  @override
  String get notificationsAccountCaption => '웹, 이메일, 모든 기기에 공통으로 적용됩니다.';

  @override
  String pushOnThisDeviceSubtitle(Object forumName) {
    return '켜짐: $forumName의 새 알림이 이 기기로 푸시됩니다.';
  }

  @override
  String pushOffThisDeviceSubtitle(Object forumName) {
    return '이 기기에서 꺼져 있습니다. 켜려면 $forumName에서 한 번 승인하세요.';
  }

  @override
  String get stopPushOnThisDevice => '이 기기에서 푸시 중지';

  @override
  String stopPushTitle(Object forumName) {
    return '이 기기에서 $forumName 푸시를 중지할까요?';
  }

  @override
  String get stopPushOnlyThisDevice => '이 기기에서만 중지됩니다. 다른 기기는 계속 받습니다.';

  @override
  String get stopPushNothingElseChanges =>
      '알림은 앱과 웹에서 계속 볼 수 있으며, 포럼 이메일도 바뀌지 않습니다.';

  @override
  String stopPushPermissionDeleted(Object forumName) {
    return '$forumName에서 허용한 권한이 삭제됩니다. 푸시를 다시 켜려면 포럼에서 다시 승인해야 합니다.';
  }

  @override
  String get stopPushQuietHint =>
      '잠시 조용히 하고 싶다면 위에서 필요 없는 종류를 끄거나 프로필의 방해 금지를 사용하세요.';

  @override
  String get stopPush => '푸시 중지';

  @override
  String get turnOn => '켜기';

  @override
  String get couldNotTurnOffNotifications => '푸시를 중지할 수 없습니다. 나중에 다시 시도해 주세요.';

  @override
  String actionCodeTopicCreated(String when) {
    return '$when에 이 글을 작성함';
  }

  @override
  String actionCodePublicTopic(String when) {
    return '이 글을 $when에 공개';
  }

  @override
  String actionCodeOpenTopic(String when) {
    return '$when에 글로 변경됨';
  }

  @override
  String actionCodePrivateTopic(String when) {
    return '$when에 이 글을 개인 메시지로 변경';
  }

  @override
  String actionCodeSplitTopic(String when) {
    return '이 글을 $when에 분리';
  }

  @override
  String actionCodeInvitedUser(String who, String when) {
    return '$when에 $who님이 초대됨';
  }

  @override
  String actionCodeInvitedGroup(String who, String when) {
    return '$when에 $who님이 초대됨';
  }

  @override
  String actionCodeUserLeft(String who, String when) {
    return '$who 님이 $when에 이 메시지에서 자신을 제거함';
  }

  @override
  String actionCodeRemovedUser(String who, String when) {
    return '$when에 $who님이 삭제됨';
  }

  @override
  String actionCodeRemovedGroup(String who, String when) {
    return '$when에 $who님이 삭제됨';
  }

  @override
  String actionCodeAutobumped(String when) {
    return '$when에 자동으로 끌어 올려짐';
  }

  @override
  String actionCodeTagsChanged(String when) {
    return '$when에 태그 업데이트됨';
  }

  @override
  String actionCodeCategoryChanged(String when) {
    return '$when에 카테고리 업데이트됨';
  }

  @override
  String get actionCodeForwarded => '위의 이메일을 전달했습니다.';

  @override
  String actionCodeAutoclosedEnabled(String when) {
    return '$when에 닫힘';
  }

  @override
  String actionCodeAutoclosedDisabled(String when) {
    return '$when에 열림';
  }

  @override
  String actionCodeClosedEnabled(String when) {
    return '$when에 닫힘';
  }

  @override
  String actionCodeClosedDisabled(String when) {
    return '$when에 열림';
  }

  @override
  String actionCodeArchivedEnabled(String when) {
    return '$when에 보관됨';
  }

  @override
  String actionCodeArchivedDisabled(String when) {
    return '$when에 보관 취소됨';
  }

  @override
  String actionCodePinnedEnabled(String when) {
    return '$when에 고정됨';
  }

  @override
  String actionCodePinnedDisabled(String when) {
    return '$when에 고정 해제됨';
  }

  @override
  String actionCodePinnedGloballyEnabled(String when) {
    return '$when에 전체적으로 고정됨';
  }

  @override
  String actionCodePinnedGloballyDisabled(String when) {
    return '$when에 고정 해제됨';
  }

  @override
  String actionCodeVisibleEnabled(String when) {
    return '$when에 목록에 게시';
  }

  @override
  String actionCodeVisibleDisabled(String when) {
    return '$when에 목록에서 감춤';
  }

  @override
  String actionCodeBannerEnabled(String when) {
    return '$when에 배너를 만들었습니다. 사용자가 닫을 때까지 모든 페이지의 상단에 표시됩니다.';
  }

  @override
  String actionCodeBannerDisabled(String when) {
    return '$when에 이 배너를 제거했습니다. 더 이상 모든 페이지의 상단에 표시되지 않습니다.';
  }

  @override
  String actionCodeAssigned(String who, String when) {
    return '할당 된 $who $when';
  }

  @override
  String actionCodeUnassigned(String who, String when) {
    return '할당되지 않은 $who $when';
  }

  @override
  String actionCodeReassigned(String who, String when) {
    return '$when에 $who 님에게 재할당함';
  }

  @override
  String localDateToday(String time) {
    return '오늘 $time';
  }

  @override
  String localDateTomorrow(String time) {
    return '내일 $time';
  }

  @override
  String localDateYesterday(String time) {
    return '어제 $time';
  }

  @override
  String get eventExpired => '만료됨';

  @override
  String get eventEveryDay => '매일';

  @override
  String get eventEveryWeekday => '매 평일';

  @override
  String get eventEveryWeek => '매주 이 요일';

  @override
  String get eventEveryTwoWeeks => '2주마다 이 요일';

  @override
  String get eventEveryFourWeeks => '4주마다 이 요일';

  @override
  String get eventEveryMonth => '매월 이 요일';

  @override
  String get errorNoConnection => '포럼에 연결할 수 없습니다. 연결을 확인하고 다시 시도하세요.';

  @override
  String get errorTimedOut => '포럼 응답이 너무 오래 걸립니다. 다시 시도하세요.';

  @override
  String get errorPaywalled => '포럼 유료 회원만 볼 수 있습니다.';

  @override
  String get errorBlocked => '포럼의 방화벽이 앱을 차단했습니다. 나중에 다시 시도하거나 브라우저에서 포럼을 여세요.';

  @override
  String get errorNotAllowed => '이 항목에 접근할 권한이 없습니다. 로그인하면 볼 수 있을 수도 있습니다.';

  @override
  String get errorNotFound => '존재하지 않거나 삭제되었습니다.';

  @override
  String get errorRateLimited => '너무 자주 시도하고 있습니다. 잠시 후 다시 시도하세요.';

  @override
  String get errorForumDown => '포럼이 지금 응답하지 않습니다. 나중에 다시 시도하세요.';

  @override
  String get deleteSpammer => '스팸 사용자 삭제';

  @override
  String get yesDeleteSpammer => '예, 스팸 사용자를 삭제합니다';

  @override
  String get deleteSpammerConfirm =>
      '이 사용자의 게시물 및 주제를 삭제하고, 사용자의 계정을 제거하고, 해당 IP 주소의 가입을 차단하고, 해당 이메일 주소를 영구 차단 목록에 추가하려 합니다. 이 사용자가 정말 스팸 사용자인가요?';

  @override
  String get userWasDeleted => '사용자가 삭제되었습니다.';

  @override
  String get deleteMyAccount => '내 계정 삭제';

  @override
  String get deleteAccountConfirm => '계정을 영구적으로 삭제할까요? 이 작업은 취소할 수 없습니다!';

  @override
  String get deletedYourself => '계정이 삭제되었습니다.';

  @override
  String get deleteYourselfNotAllowed => '계정 삭제를 원하시면 운영진에게 문의하세요.';

  @override
  String get createTopic => '글 작성하기';

  @override
  String get discardPostQuestion => '게시물을 버리시겠습니까?';

  @override
  String get discardChangesQuestion => '변경 사항을 버리시겠습니까?';

  @override
  String get discardChanges => '변경 사항 버리기';

  @override
  String get saveDraft => '임시 저장';

  @override
  String get notificationSettings => '알림 설정';

  @override
  String get topicIsNew => '새 글';

  @override
  String get noNewTopicsSinceLastVisit => '마지막 방문 이후 새 글이 없습니다.';

  @override
  String get messageIsNew => '새 메시지';

  @override
  String topicUnreadReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '읽지 않은 댓글 $count개',
    );
    return '$_temp0';
  }

  @override
  String filterNewWithCount(int count) {
    return '새 글 ($count)';
  }

  @override
  String filterUnreadWithCount(int count) {
    return '읽지 않음 ($count)';
  }

  @override
  String categoryNewTopics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '새 글 $count',
    );
    return '$_temp0';
  }

  @override
  String categoryUnreadTopics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '읽지 않음 $count',
    );
    return '$_temp0';
  }

  @override
  String get dismissNew => '새 글 읽음으로 표시';

  @override
  String get dismissUnread => '읽지 않은 항목 읽음으로 표시';

  @override
  String get dismissNewTitle => '새 글을 읽음으로 표시할까요?';

  @override
  String get dismissNewMessage => '더 이상 새 글로 표시되지 않습니다.';

  @override
  String get dismissUnreadTitle => '읽지 않은 항목을 모두 읽음으로 표시할까요?';

  @override
  String get dismissUnreadMessage => '새 댓글이 읽음으로 표시됩니다.';

  @override
  String get dismissUnreadStopTracking => '이 글을 더 이상 추적하지 않고 읽지 않은 글에서 표시하지 않음';

  @override
  String get dismissNewAndUnread => '새 글과 읽지 않은 글 읽음으로 표시';

  @override
  String dismissNewAndUnreadMessage(String category) {
    return '$category의 글이 더 이상 새 글이나 읽지 않은 글로 표시되지 않습니다.';
  }

  @override
  String get dismissedTopics => '읽음으로 표시함';

  @override
  String topicMapViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '조회',
    );
    return '$_temp0';
  }

  @override
  String topicMapLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '좋아요',
    );
    return '$_temp0';
  }

  @override
  String topicMapLinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '링크',
    );
    return '$_temp0';
  }

  @override
  String topicMapUsers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '사용자',
    );
    return '$_temp0';
  }

  @override
  String get markAsSolution => '해결책으로 표시';

  @override
  String get unmarkAsSolution => '해결책 표시 해제';

  @override
  String searchForumName(String forum) {
    return '$forum 검색';
  }

  @override
  String countActiveThisMonth(String formatted) {
    return '이번 달 활동 $formatted명';
  }

  @override
  String countMembers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '회원 $formatted명',
    );
    return '$_temp0';
  }

  @override
  String countTopics(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '주제 $formatted개',
    );
    return '$_temp0';
  }

  @override
  String categoryNewThisWeek(int count) {
    return '이번 주 새 글 $count개';
  }

  @override
  String get categoriesView => '카테고리';

  @override
  String get allCategories => '모든 카테고리';

  @override
  String get allTags => '모든 태그';

  @override
  String get myPosts => '내 게시물';

  @override
  String get drawerIntroduction =>
      '이 포럼의 카테고리, 태그, 계정은 모두 이 메뉴에 있습니다. 메뉴 버튼으로 언제든지 다시 열 수 있습니다.';

  @override
  String trustLevelN(int level) {
    return '신뢰 수준 $level';
  }

  @override
  String get filterNew => '새 글';

  @override
  String get filterTop => '인기';

  @override
  String get levelWatching => '지켜보기';

  @override
  String get levelWatchingFirstPost => '첫 게시물 지켜보기';

  @override
  String get levelTracking => '추적';

  @override
  String get levelNormal => '일반';

  @override
  String get levelMuted => '알림 끔';

  @override
  String get chooseCategory => '카테고리 선택';

  @override
  String get signInToPostAndGetNotifications => '로그인하여 글을 쓰고 알림을 받으세요';

  @override
  String forumBlocksNotificationServer(Object forumName) {
    return '$forumName에서 알림 서버를 차단하고 있어 알림이 도착하지 않을 수 있습니다. 설정에서 끌 수 있습니다.';
  }

  @override
  String get relatedTopics => '관련 주제';

  @override
  String get relatedMessages => '관련 메시지';

  @override
  String moreInCategory(String category) {
    return '$category의 다른 주제';
  }

  @override
  String get latestTopics => '최신 주제';

  @override
  String get pushGroupMessages => '메시지와 채팅';

  @override
  String get pushGroupMessagesHint => '개인 메시지, 그룹 받은편지함, 채팅';

  @override
  String get pushGroupReplies => '답글과 멘션';

  @override
  String get pushGroupRepliesHint => '답글, 멘션, 인용, 관심 주제';

  @override
  String get pushGroupReactions => '좋아요와 반응';

  @override
  String get pushGroupReactionsHint => '내 게시물에 대한 좋아요와 반응';

  @override
  String get pushGroupOther => '그 밖의 모든 것';

  @override
  String get pushGroupOtherHint => '배지, 리마인더, 채택된 답변 등';

  @override
  String get pushChannelOther => '기타 알림';

  @override
  String get couldNotChangePushSetting => '이 설정을 변경하지 못했습니다. 나중에 다시 시도하세요.';

  @override
  String neverMissAReplyOn(Object forumName) {
    return '$forumName의 답글을 놓치지 마세요';
  }

  @override
  String get notificationsPitch =>
      '답글, 멘션, 메시지, 채팅을 잠금 화면에서 받아보세요. 보통 10분 이내에 도착합니다. 받을 항목은 설정에서 언제든 고를 수 있습니다.';

  @override
  String get notificationsStepAllow => '이 휴대폰에서 알림 허용';

  @override
  String get notificationsStepAllowed => '이 휴대폰에서 알림이 허용되어 있습니다';

  @override
  String notificationsStepApprove(Object forumName) {
    return '$forumName에서 승인';
  }

  @override
  String get notificationsReadOnlyNote => '읽기 전용: 글쓰기, 답글, 메시지 읽기는 할 수 없습니다';

  @override
  String get notificationPreviewReply =>
      'Jane님이 답글을 남겼습니다: 환영해요! 찾아와 주셔서 반가워요.';

  @override
  String get notificationPreviewMessage => 'Sam님이 메시지를 보냈습니다: 금요일에 오시나요?';

  @override
  String get notificationPreviewNow => '지금';

  @override
  String get notificationPreviewEarlier => '5분 전';

  @override
  String get activityReplied => '답글';

  @override
  String get activityStartedTopic => '주제 작성';

  @override
  String get activityLiked => '좋아요';

  @override
  String get activitySolution => '해결책';

  @override
  String get activityAcceptedBy => '승인:';

  @override
  String get activityAwaitingApproval => '승인 대기 중';

  @override
  String get activityFilterTopics => '주제';

  @override
  String get activityFilterReplies => '답글';

  @override
  String get activityFilterLikes => '좋아요';

  @override
  String get activityFilterPending => '대기 중';

  @override
  String get sectionToday => '오늘';

  @override
  String get sectionThisWeek => '이번 주';

  @override
  String get sectionEarlier => '이전';

  @override
  String draftsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '임시 저장 $count개',
    );
    return '$_temp0';
  }

  @override
  String get resumeDrafts => '이어 쓰기';

  @override
  String get myPostsEmpty => '아직 게시물이 없습니다';

  @override
  String get myPostsEmptyHint => '작성한 주제와 답글이 여기에 표시됩니다.';

  @override
  String get activityEmptyTopics => '아직 주제가 없습니다';

  @override
  String get activityEmptyReplies => '아직 답글이 없습니다';

  @override
  String get activityEmptyLikes => '아직 누른 좋아요가 없습니다';

  @override
  String get activityEmptySolved => '아직 해결책이 없습니다';

  @override
  String get viewProfile => '프로필 보기';

  @override
  String get yourStuff => '내 항목';

  @override
  String get accountAndPrivacy => '계정 및 개인정보';

  @override
  String profileStatPosts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '게시물',
    );
    return '$_temp0';
  }

  @override
  String profileStatLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '좋아요',
    );
    return '$_temp0';
  }

  @override
  String profileStatDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '일',
    );
    return '$_temp0';
  }

  @override
  String get profileStatSolved => '해결';

  @override
  String joinForum(String forum) {
    return '$forum 가입하기';
  }

  @override
  String get guestBenefitPost => '답글과 새 주제 작성';

  @override
  String get guestBenefitNotify => '답글이 달리면 알림 받기';

  @override
  String get guestBenefitSave => '게시물 북마크와 임시 저장';

  @override
  String get guestBenefitChat => '채팅과 메시지';

  @override
  String get createAccount => '계정 만들기';

  @override
  String get aboutThisForum => '이 포럼 소개';

  @override
  String get drawerMore => '더 보기';

  @override
  String get goToYourProfile => '내 프로필로 이동';

  @override
  String profileJoined(String date) {
    return '$date 가입';
  }

  @override
  String profileSeen(String when) {
    return '$when 접속';
  }

  @override
  String profileLocalTime(String time) {
    return '현지 시간 $time';
  }

  @override
  String get profileTabSummary => '요약';

  @override
  String get summaryTopReplies => '인기 답글';

  @override
  String get summaryTopTopics => '인기 주제';

  @override
  String get summaryMostLikedBy => '좋아요를 가장 많이 준 사람';

  @override
  String get summaryMostLiked => '가장 많이 좋아요한 사람';

  @override
  String get summaryMostRepliedTo => '가장 많이 답글한 사람';

  @override
  String get summaryTopLinks => '인기 링크';

  @override
  String get summaryTopCategories => '주요 카테고리';

  @override
  String get featuredTopic => '추천 주제';

  @override
  String get profileDetails => '세부 정보';

  @override
  String get followUser => '팔로우';

  @override
  String get unfollowUser => '언팔로우';

  @override
  String get profileSuspended => '정지됨';

  @override
  String get searchBookmarks => '북마크 검색';

  @override
  String get bookmarksFilterReminders => '알림';

  @override
  String get bookmarkWholeTopic => '주제 전체';

  @override
  String bookmarkSaved(String when) {
    return '$when 저장';
  }

  @override
  String bookmarkPostNumber(int number) {
    return '게시물 #$number';
  }

  @override
  String reminderToday(String time) {
    return '오늘 $time';
  }

  @override
  String reminderTomorrow(String time) {
    return '내일 $time';
  }

  @override
  String reminderDue(String when) {
    return '기한 · $when';
  }

  @override
  String get addBookmarkLabel => '라벨 추가';

  @override
  String get editBookmarkLabel => '라벨 편집';

  @override
  String get bookmarkLabelHint => '무엇을 위한 건가요?';

  @override
  String get pinBookmark => '맨 위에 고정';

  @override
  String get unpinBookmark => '고정 해제';

  @override
  String get bookmarkRemoved => '북마크를 삭제했습니다';

  @override
  String get undo => '실행 취소';

  @override
  String get bookmarksNoMatch => '일치하는 북마크가 없습니다';

  @override
  String get addReminder => '알림 추가';

  @override
  String get bookmarksEmpty => '아직 북마크가 없습니다';

  @override
  String get bookmarksEmptyHint => '게시물의 작업에서 북마크하면 여기에서 기다립니다.';

  @override
  String get draftKindNewTopic => '새 주제';

  @override
  String draftMessageTo(String names) {
    return '$names에게 보내는 메시지';
  }

  @override
  String get untitledTopic => '제목 없는 주제';

  @override
  String get draftDiscarded => '임시 저장을 삭제했습니다';

  @override
  String get draftsEmpty => '아직 임시 저장이 없습니다';

  @override
  String get draftsEmptyHint => '입력하는 동안 자동으로 저장됩니다. 답글이나 주제를 시작하면 여기에서 기다립니다.';

  @override
  String get privacySection => '개인정보';

  @override
  String get changeEmailSubtitle => '새 주소로 인증 링크를 보내드립니다';

  @override
  String get aboutMe => '자기소개';

  @override
  String get aboutMeHelper => '프로필 상단에 표시됩니다';

  @override
  String get aboutMeMarkdownHint => 'Markdown 사용 가능: **굵게**, 링크, :emoji:';

  @override
  String get addCover => '커버 추가';

  @override
  String get changeCover => '커버 변경';

  @override
  String get birthdayHint => '포럼이 함께 축하해 드립니다. 연도는 저장되지 않습니다.';

  @override
  String get birthdayRemoved => '생일을 삭제했습니다';

  @override
  String get birthdaySaved => '생일을 저장했습니다';

  @override
  String get cardBackground => '카드 배경';

  @override
  String get cardBackgroundExplanation => '다른 사람이 내 사진을 탭하면 사용자 카드 뒤에 표시됩니다';

  @override
  String get cardBackgroundRemoved => '카드 배경을 삭제했습니다';

  @override
  String get cardBackgroundSheetHint =>
      '사용자 카드 뒤에 표시됩니다. 가로로 넓은 사진이 가장 잘 어울립니다.';

  @override
  String get changeProfilePicture => '프로필 사진 변경';

  @override
  String get changeUsername => '사용자 이름 변경';

  @override
  String changeUsernameExplanation(String username) {
    return '게시물 속 @$username 멘션과 인용이 새 이름으로 바뀝니다. 프로필로 연결되는 이전 링크는 더 이상 작동하지 않습니다.';
  }

  @override
  String get chooseFromLibrary => '앨범에서 선택';

  @override
  String get coverPhoto => '커버 사진';

  @override
  String get coverPhotoSheetHint =>
      '프로필 상단, 프로필 사진 뒤에 표시됩니다. 약 3:1 비율의 가로로 넓은 사진이 가장 잘 어울립니다.';

  @override
  String get coverRemoved => '커버를 삭제했습니다';

  @override
  String get day => '일';

  @override
  String get month => '월';

  @override
  String get displayName => '표시 이름';

  @override
  String displayNameHelper(String username) {
    return '게시물과 함께 표시됩니다. 사용자 이름은 @$username(으)로 유지됩니다.';
  }

  @override
  String get emailPasswordInAccount => '이메일, 비밀번호 및 로그인';

  @override
  String get featureATopic => '추천 주제 선택';

  @override
  String get featureATopicHint => '내 주제 하나를 프로필 상단에 고정합니다.';

  @override
  String get featuredTopicChanged => '추천 주제를 변경했습니다';

  @override
  String get featuredTopicNone => '없음. 내 주제 하나를 프로필에 고정하세요.';

  @override
  String get featuredTopicRemoved => '추천 주제를 삭제했습니다';

  @override
  String get featuredTopicRules => '메시지와 비공개 카테고리의 주제는 추천할 수 없습니다.';

  @override
  String get fieldManagedBySignIn => '이 포럼은 자체 로그인으로 이 항목을 관리합니다. 그곳에서 변경하세요.';

  @override
  String get flair => '플레어';

  @override
  String flairChangedTo(String group) {
    return '플레어를 $group(으)로 변경했습니다';
  }

  @override
  String get flairRemoved => '플레어를 삭제했습니다';

  @override
  String get flairSheetHint => '내가 속한 그룹의 작은 아이콘이 프로필 사진에 표시됩니다.';

  @override
  String forumPictureN(int number) {
    return '포럼 이미지 $number';
  }

  @override
  String forumQuestionNeedsAnswer(String question) {
    return '$question: 답변 필요';
  }

  @override
  String get forumQuestionRequired => '이 포럼은 모든 회원에게 답변을 요청합니다';

  @override
  String get forumQuestionSetByStaff => '포럼 운영진이 설정합니다';

  @override
  String get forumQuestionsIntro => '이 포럼의 질문입니다. *는 필수 항목입니다.';

  @override
  String get forumQuestionsNoneAnswered => '아직 답변하지 않음';

  @override
  String get fromThisForum => '이 포럼에서 제공';

  @override
  String get hideMyProfile => '공개 프로필 숨기기';

  @override
  String get hideMyProfileExplanation => '다른 사람에게는 이름, 사진, 게시물만 표시됩니다';

  @override
  String get letterAvatar => '이니셜';

  @override
  String get moreAboutYou => '추가 정보';

  @override
  String namesAndMore(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개',
    );
    return '$names 외 $_temp0';
  }

  @override
  String get newUsername => '새 사용자 이름';

  @override
  String get noFlair => '플레어 없음';

  @override
  String noGravatarFound(String service) {
    return '$service에 내 이메일 주소의 사진이 없습니다';
  }

  @override
  String get noTitle => '칭호 없음';

  @override
  String get noTopicsMatch => '일치하는 내 주제가 없습니다';

  @override
  String get noTopicsToFeature => '아직 시작한 주제가 없습니다';

  @override
  String get notSet => '설정 안 함';

  @override
  String get orUse => '또는 다음 사용';

  @override
  String get pictureManagedBySignIn => '이 포럼은 자체 로그인으로 프로필 사진을 설정합니다';

  @override
  String get primaryGroup => '기본 그룹';

  @override
  String primaryGroupChangedTo(String group) {
    return '기본 그룹을 $group(으)로 변경했습니다';
  }

  @override
  String get primaryGroupRemoved => '기본 그룹을 삭제했습니다';

  @override
  String get primaryGroupSheetHint => '사용자 카드에 표시되는 대표 그룹입니다.';

  @override
  String get profileLoadFailed => '프로필을 불러오지 못했습니다';

  @override
  String get profileNowHidden => '프로필이 숨겨졌습니다';

  @override
  String get profileNowPublic => '프로필이 공개되었습니다';

  @override
  String get profilePicture => '프로필 사진';

  @override
  String get profilePictureChanged => '프로필 사진을 변경했습니다';

  @override
  String get profileSaveFailed => '저장하지 못했습니다. 다시 시도하세요.';

  @override
  String get profileSectionNameAndAbout => '이름 및 소개';

  @override
  String get profileSectionNextToName => '이름 옆';

  @override
  String get profileSectionOnProfile => '프로필에 표시';

  @override
  String get profileSectionPrivacyAndTime => '개인정보 및 시간';

  @override
  String get removeCardBackground => '카드 배경 삭제';

  @override
  String get removeCover => '커버 삭제';

  @override
  String get removeFeaturedTopic => '추천 주제 삭제';

  @override
  String get searchTimezones => '시간대 검색';

  @override
  String get searchYourTopics => '내 주제 검색';

  @override
  String get seeProfileAsOthersDo => '다른 사람에게 보이는 프로필 보기';

  @override
  String get timezone => '시간대';

  @override
  String timezoneChangedTo(String zone) {
    return '시간대를 $zone(으)로 변경했습니다';
  }

  @override
  String timezoneWithTime(String zone, String time) {
    return '$zone · 현재 $time';
  }

  @override
  String timezonesMatchingPhone(String offset) {
    return '이 휴대폰의 시계와 일치 ($offset)';
  }

  @override
  String titleChangedTo(String title) {
    return '칭호를 $title(으)로 변경했습니다';
  }

  @override
  String get titleFromBadge => '배지';

  @override
  String titleFromBadgeEarned(String date) {
    return '배지 · $date 획득';
  }

  @override
  String titleFromGroup(String group) {
    return '$group 그룹';
  }

  @override
  String get titleGrantedByStaff => '포럼 운영진이 부여함';

  @override
  String get titleRemoved => '칭호를 삭제했습니다';

  @override
  String get titleSheetHint => '프로필과 게시물에서 이름 뒤에 표시됩니다.';

  @override
  String get username => '사용자 이름';

  @override
  String get usernameAvailable => '사용 가능';

  @override
  String usernameChanged(String username) {
    return '사용자 이름이 @$username(으)로 변경되었습니다';
  }

  @override
  String get usernameLockedExplanation =>
      '이 포럼에서는 가입 직후 잠시 동안만 사용자 이름을 변경할 수 있습니다. 운영자에게 변경을 요청할 수 있습니다.';

  @override
  String get yourPhoto => '내 사진';

  @override
  String get chooseEmoji => '이모지 선택';

  @override
  String get clearStatus => '상태 지우기';

  @override
  String get clearText => '지우기';

  @override
  String get inOneHour => '한 시간 후';

  @override
  String get never => '안 함';

  @override
  String get pauseNotifications => '알림 일시 중지';

  @override
  String get pauseNotificationsUntilStatusClears => '상태가 삭제될 때까지';

  @override
  String get pickATime => '시간 선택';

  @override
  String get removeStatusAfter => '상태 삭제';

  @override
  String get searchEmoji => '이모지 검색';

  @override
  String get setStatus => '상태 설정';

  @override
  String get setAStatus => '상태 설정하기';

  @override
  String get statusUpdated => '상태를 업데이트했습니다';

  @override
  String get whatAreYouDoing => '무엇을 하고 있나요?';

  @override
  String cardPosted(String when) {
    return '$when 게시';
  }

  @override
  String get change => '변경';

  @override
  String get copyProfileLink => '프로필 링크 복사';

  @override
  String get ignore => '무시';

  @override
  String memberOfGroup(String group) {
    return '$group 구성원';
  }

  @override
  String get mute => '뮤트';

  @override
  String get unmute => '뮤트 해제';

  @override
  String openProfileOf(String username) {
    return '@$username님의 프로필 열기';
  }

  @override
  String profileIsPrivate(String username) {
    return '$username님은 프로필을 비공개로 설정했습니다.';
  }

  @override
  String showOnlyTheirPostsHere(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개',
    );
    return '이 주제에서 $name님의 게시물 $_temp0만 보기';
  }

  @override
  String showOnlyYourPostsHere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개',
    );
    return '이 주제에서 내 게시물 $_temp0만 보기';
  }

  @override
  String userIgnoredFor4Months(String username) {
    return '@$username님을 4개월 동안 무시합니다';
  }

  @override
  String userMuted(String username) {
    return '@$username님을 뮤트했습니다';
  }

  @override
  String userUnmuted(String username) {
    return '@$username님의 뮤트를 해제했습니다';
  }

  @override
  String get youParenthetical => '(나)';

  @override
  String get topicStatusClosedHelp => '이 글은 잠금 처리되었습니다. 더 이상 새 댓글을 올릴 수 없습니다.';

  @override
  String get topicStatusArchivedHelp => '이 주제는 보관 중입니다. 고정되어 변경이 불가합니다';

  @override
  String get topicStatusClosedArchivedHelp =>
      '이 글은 잠금 처리되어 보관 중 입니다. 더 이상 새 댓글을 작성하거나 변경이 불가합니다.';

  @override
  String get topicStatusPinnedTitle => '핀 지정됨';

  @override
  String get topicStatusPinnedHelp => '이 주제는 고정되었습니다. 카테고리의 상단에 표시됩니다.';

  @override
  String get topicStatusPinnedGloballyTitle => '전체적으로 고정됨';

  @override
  String get topicStatusPinnedGloballyHelp =>
      '이 주제는 전체적으로 고정되어 있으며 최신 항목 및 카테고리 상단에 표시됩니다.';

  @override
  String get topicStatusUnpinnedTitle => '고정 해제';

  @override
  String get topicStatusUnpinnedHelp => '이 주제가 고정 해제되었습니다. 일반적인 순서로 표시됩니다';

  @override
  String get topicStatusUnlistedHelp =>
      '이 주제는 목록에서 감춰졌습니다. 주제 목록에 표시되지 않으며 직접 링크로만 볼 수 있습니다.';

  @override
  String get topicStatusWarningHelp => '공식 경고입니다.';

  @override
  String get notificationReasonWatchingTag => '이 글에 대한 태그를 구독 중이므로 알림을 받게 됩니다.';

  @override
  String get notificationReasonWatchingCategory =>
      '이 카테고리를 구독 중이므로 알림을 받게 됩니다.';

  @override
  String get notificationReasonWatchingAuto =>
      '이 글을 자동으로 구독하기 시작했으므로 알림을 받게 됩니다.';

  @override
  String get notificationReasonWatching => '이 글을 구독 중이므로 알림을 받게 됩니다.';

  @override
  String get notificationReasonWatchingCreated => '이 글을 작성 했으므로 알림을 받게됩니다.';

  @override
  String get notificationReasonTrackingCategory =>
      '이 카테고리를 추적 중이므로 새 댓글 수가 표시됩니다.';

  @override
  String get notificationReasonTrackingReplied =>
      '이 글에 댓글을 작성했기 때문에 새 글 수가 표시됩니다.';

  @override
  String get notificationReasonTracking => '이 글을 팔로우 중이므로 새 댓글 수가 표시됩니다.';

  @override
  String get notificationReasonTrackingRead => '이 글을 읽었으므로 새 댓글 수가 표시됩니다.';

  @override
  String get notificationReasonNormal =>
      '누군가 나를 @이름 형식으로 멘션하거나 나에게 댓글을 달면 알림을 받습니다.';

  @override
  String get notificationReasonMutedCategory => '이 카테고리의 모든 알림을 무시하고 있습니다.';

  @override
  String get notificationReasonMuted => '이 글에 대한 모든 알림을 무시하고 있습니다.';

  @override
  String get notificationLevelWatching => '구독';

  @override
  String get notificationLevelWatchingFirstPost => '첫 게시물 구독';

  @override
  String get notificationLevelTracking => '추적';

  @override
  String get notificationLevelNormal => '일반';

  @override
  String get notificationLevelMuted => '뮤트';

  @override
  String get topicWatchingDescription =>
      '이 글의 모든 새 댓글에 대한 알림을 받으며 새 댓글 수가 표시됩니다.';

  @override
  String get topicTrackingDescription =>
      '이 주제의 새 댓글 수가 표시됩니다. 누군가가 @이름 형식으로 나를 멘션하거나 나에게 댓글을 달면 알림을 받게 됩니다.';

  @override
  String get topicNormalDescription =>
      '누군가 나를 @이름 형식으로 멘션하거나 나에게 댓글을 달면 알림을 받습니다.';

  @override
  String get topicMutedDescription =>
      '이 주제에 대한 어떠한 알림도 받지 않고 최신 항목에 표시되지 않습니다.';

  @override
  String get messageWatchingDescription =>
      '이 메시지의 모든 새 댓글에 대한 알림을 받으며 새 댓글 수가 표시됩니다.';

  @override
  String get messageTrackingDescription =>
      '이 메시지의 새 댓글 수가 표시됩니다. 누군가가 @이름 형식으로 나를 멘션하거나 나에게 댓글을 달면 알림을 받게 됩니다.';

  @override
  String get messageNormalDescription =>
      '누군가 나를 @이름 형식으로 멘션하거나 나에게 댓글을 달면 알림을 받습니다.';

  @override
  String get messageMutedDescription => '이 메시지에 대해 어떠한 알림도 받지 않지 않습니다.';

  @override
  String get categoryWatchingDescription =>
      '이 카테고리의 모든 주제를 자동으로 봅니다. 모든 주제의 새 게시물에 대한 알림이 전송되며 새 댓글 수도 표시됩니다.';

  @override
  String get categoryWatchingFirstPostDescription =>
      '이 카테고리의 새 주제에 대한 알림을 받지만 주제 댓글은 제외합니다.';

  @override
  String get categoryTrackingDescription =>
      '이 카테고리의 모든 주제를 자동으로 추적합니다. 누군가 나를 @이름 형식으로 멘션하거나 나에게 댓글을 달면 알림을 받으며 새 댓글 수가 표시됩니다.';

  @override
  String get categoryNormalDescription =>
      '누군가 나를 @이름 형식으로 멘션하거나 나에게 댓글을 달면 알림을 받습니다.';

  @override
  String get categoryMutedDescription =>
      '이 카테고리의 새 주제에 대한 어떠한 알림도 받지 않으며 최신 항목에 표시되지 않습니다.';

  @override
  String get tagWatchingDescription =>
      '이 태그의 모든 주제를 자동으로 봅니다. 모든 새 게시물과 주제에 대한 알림이 전송되며 읽지 않은 게시물과 새 게시물 수도 주제 옆에 표시됩니다.';

  @override
  String get tagWatchingFirstPostDescription =>
      '이 태그의 새 주제에 대한 알림을 받지만 주제 댓글은 제외합니다.';

  @override
  String get tagTrackingDescription =>
      '이 태그의 모든 주제를 자동 추적합니다. 읽지 않은 게시물과 새 게시물 수가 주제 옆에 표시됩니다.';

  @override
  String get tagNormalDescription =>
      '누군가 나를 @이름 형식으로 멘션하거나 내 게시물에 댓글을 달면 알림을 받습니다.';

  @override
  String get tagMutedDescription =>
      '이 태그가 있는 새 주제에 대한 어떠한 알림도 받지 않으며 읽지 않음 탭에 표시되지 않습니다.';

  @override
  String topicTimerAutoOpen(String timeLeft) {
    return '이 글은 $timeLeft에 자동으로 열립니다.';
  }

  @override
  String topicTimerAutoClose(String timeLeft) {
    return '이 글은 $timeLeft에 자동으로 닫힙니다.';
  }

  @override
  String topicTimerAutoPublish(String categoryName, String timeLeft) {
    return '이 글은 $timeLeft #$categoryName에 게시됩니다.';
  }

  @override
  String topicTimerAutoCloseAfterLastPost(String duration) {
    return '이 글은 마지막 댓글이 달리고 $duration 후 닫힙니다.';
  }

  @override
  String topicTimerAutoDeleteAfterLastPost(String duration) {
    return '이 글은 마지막 댓글이 달리고 $duration 후 삭제됩니다.';
  }

  @override
  String topicTimerAutoDelete(String timeLeft) {
    return '이 글은 $timeLeft에 자동으로 삭제됩니다.';
  }

  @override
  String topicTimerAutoBump(String timeLeft) {
    return '이 글은 $timeLeft에 자동으로 끌어 올림 됩니다.';
  }

  @override
  String topicTimerAutoDeleteReplies(String duration) {
    return '이 글에 대한 댓글은 $duration 후 자동으로 삭제됩니다.';
  }

  @override
  String slowModeNotice(String duration) {
    return '이 글에서는 게시물 사이에 $duration 기다려 주세요.';
  }

  @override
  String get closeTopic => '글 잠금';

  @override
  String get openTopic => '글 열기';

  @override
  String get pinTopic => '글 고정';

  @override
  String get unpinTopic => '주제 고정 해제';

  @override
  String get archiveTopic => '글 보관';

  @override
  String get unarchiveTopic => '글 보관 취소';

  @override
  String get unlistTopic => '목록에서 감추기';

  @override
  String get listTopic => '목록에 게시하기';

  @override
  String get permanentlyDelete => '영구 삭제';

  @override
  String get permanentlyDeleteTopicConfirmation =>
      '이 작업은 되돌릴 수 없습니다. 이 주제가 영구적으로 삭제되고 데이터베이스에서 제거됩니다.';

  @override
  String get deleteTopicConfirmYes => '예, 이 주제를 삭제합니다';

  @override
  String get deleteTopicConfirmNo => '아니요, 이 주제를 유지합니다';

  @override
  String get topicPinned => '글을 고정했습니다';

  @override
  String get topicUnpinned => '글 고정을 해제했습니다';

  @override
  String get topicArchived => '글을 보관했습니다';

  @override
  String get topicUnarchived => '글 보관을 취소했습니다';

  @override
  String get topicUnlisted => '글을 목록에서 감췄습니다';

  @override
  String get topicListed => '글을 목록에 게시했습니다';

  @override
  String get topicRecovered => '주제 삭제를 취소했습니다';

  @override
  String topicActionFailed(String error) {
    return '글을 업데이트할 수 없습니다: $error';
  }

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count분',
    );
    return '$_temp0';
  }

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count시간',
    );
    return '$_temp0';
  }

  @override
  String durationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count일',
    );
    return '$_temp0';
  }

  @override
  String timeLeftMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count분 후',
    );
    return '$_temp0';
  }

  @override
  String timeLeftHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count시간 후',
    );
    return '$_temp0';
  }

  @override
  String timeLeftDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count일 후',
    );
    return '$_temp0';
  }

  @override
  String get topicStatusDeletedHelp => '이 주제는 삭제되어 다른 사용자에게 보이지 않습니다';

  @override
  String get flagAction => '신고';

  @override
  String get flagPost => '게시물 신고';

  @override
  String get signUp => '회원가입';

  @override
  String get suspendUser => '사용자 정지';

  @override
  String get unsuspend => '정지 해제';

  @override
  String get suspendUntil => '사용자 정지 기간';

  @override
  String get suspendForever => '영구 정지';

  @override
  String failedToSuspendUser(String error) {
    return '이 사용자를 정지하는 중에 오류 발생: $error';
  }

  @override
  String failedToUnsuspendUser(String error) {
    return '이 사용자를 정지 해제하는 중에 오류 발생: $error';
  }

  @override
  String get suspendReasonNotListening => '운영진의 피드백을 따르지 않음';

  @override
  String get suspendReasonStaffTime => '운영진의 시간을 과도하게 빼앗음';

  @override
  String get suspendReasonCombative => '분란 조장';

  @override
  String get suspendReasonWrongPlace => '이곳과 맞지 않음';

  @override
  String get suspendReasonNoPurpose => '커뮤니티 내에서 반대하는 것 외에는 건설적인 목적이 없음';

  @override
  String get suspendReasonCustom => '직접 입력…';

  @override
  String get suspendReasonQuestion =>
      '정지 이유는 무엇인가요? 이 텍스트는 해당 사용자가 로그인할 때 보입니다. 짧게 적어주세요.';

  @override
  String get closedLabel => '잠김';

  @override
  String get flaggingPost => '게시물 신고 중…';

  @override
  String get pleaseSelectSuspensionEndDate => '정지가 끝나는 날짜를 선택하세요';

  @override
  String get suspendingUser => '사용자를 정지하는 중…';

  @override
  String get unsuspendingUser => '사용자 정지를 해제하는 중…';

  @override
  String get userSuspended => '사용자를 정지했습니다';

  @override
  String get userUnsuspended => '사용자 정지를 해제했습니다';

  @override
  String unsuspendUserConfirmation(String username) {
    return '$username 님의 정지를 해제할까요? 다시 로그인할 수 있게 됩니다.';
  }

  @override
  String get noCategoriesToDisplay => '표시할 카테고리가 없습니다.';

  @override
  String get noPermissionToViewCategory => '이 카테고리의 글을 볼 권한이 없습니다.';

  @override
  String get featureTopicTitle => '이 주제 추천';

  @override
  String get pinTopicMenu => '글 고정...';

  @override
  String pinInCategoryUntil(String category) {
    return '이 주제를 다음 기간까지 $category 카테고리 상단에 표시';
  }

  @override
  String get pinGloballyUntil => '이 주제를 다음 기간까지 모든 주제 목록의 상단에 고정';

  @override
  String get pinNote => '사용자가 개별적으로 직접 주제 고정을 취소할 수 있습니다.';

  @override
  String get pinUntil => '고정 기한';

  @override
  String get pinDateRequired => '주제를 고정하려면 날짜를 지정해야 합니다.';

  @override
  String get pinTopicGlobally => '전체적으로 주제 고정';

  @override
  String get flagThanks => '커뮤니티 질서 유지에 협조해 주셔서 감사합니다!';

  @override
  String get flagReviewProcess => '모든 신고는 운영진이 받아 가능한 한 빨리 검토합니다.';

  @override
  String get flagCant => '지금은 이 게시물을 신고할 수 없습니다';

  @override
  String get flagSendMessage => '메시지 보내기';

  @override
  String get flagMessageForUser => '사용자에게 보낼 메시지';

  @override
  String get flagMessageForModerators => '운영진에게 보낼 메시지';

  @override
  String get flagPlaceholderNotifyUser => '구체적으로 상세히 작성하고 친절한 어투를 사용하세요.';

  @override
  String get flagPlaceholderNotifyModerators =>
      '걱정하는 내용을 구체적으로 알려주시고 가능한 한 모든 관련 링크 및 예시를 제공해 주세요.';

  @override
  String get flagPlaceholderIllegal =>
      '이 콘텐츠가 불법이라고 생각하는 이유를 구체적으로 알려 주시고, 가능하면 관련 링크와 예시를 함께 제공해 주세요.';

  @override
  String get flagConfirmIllegal => '위에 작성한 내용은 정확하고 완전합니다.';

  @override
  String flagMessageAtLeast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '최소 $count자 이상 입력하세요',
    );
    return '$_temp0';
  }

  @override
  String get flagMessageSent => '메시지를 보냈습니다.';

  @override
  String get mergeTopicError => '게시물을 이 주제로 이동하는 데 문제가 발생했습니다.';

  @override
  String get topicTitlePlaceholder => '토론 주제를 한 문장으로 적으세요';

  @override
  String get topicMoved => '글을 이동했습니다';

  @override
  String get topicMerged => '글을 병합했습니다';

  @override
  String get mergeTopicExplanation =>
      '이 글의 모든 게시물이 선택한 글로 이동합니다. 앱에서는 되돌릴 수 없습니다.';

  @override
  String get destinationTopicId => '대상 글 ID';

  @override
  String get topicAuthorUnknown => '알 수 없음';

  @override
  String get noHotTopics => '인기 글이 없습니다.';

  @override
  String get signInToViewNewTopics => '새 글을 보려면 로그인하세요';

  @override
  String get newTopicsSignInMessage => '새 글에는 마지막 방문 이후 작성된 글이 표시됩니다.';

  @override
  String get topPeriodAllTime => '전체';

  @override
  String get topPeriodYear => '년';

  @override
  String get topPeriodQuarter => '분기';

  @override
  String get topPeriodMonth => '월';

  @override
  String get topPeriodWeek => '주';

  @override
  String get topPeriodToday => '오늘';

  @override
  String noTopTopicsForPeriod(String period) {
    String _temp0 = intl.Intl.selectLogic(
      period,
      {
        'all': '전체 기간의 주요 글이 없습니다.',
        'yearly': '올해의 주요 글이 없습니다.',
        'quarterly': '이번 분기의 주요 글이 없습니다.',
        'monthly': '이번 달의 주요 글이 없습니다.',
        'weekly': '이번 주의 주요 글이 없습니다.',
        'daily': '오늘의 주요 글이 없습니다.',
        'other': '주요 글이 없습니다.',
      },
    );
    return '$_temp0';
  }

  @override
  String get connectionTimedOutSiteUnreachable =>
      '연결 시간이 초과되었습니다. 사이트가 다운되었거나 접근할 수 없을 수 있습니다.';

  @override
  String get failedToMarkNotificationsRead => '알림을 읽음으로 표시하지 못했습니다';

  @override
  String get forumNameFallback => '포럼';

  @override
  String get noForumDescription => '설명이 없습니다.';

  @override
  String get dismissAllNotifications => '모두 해제';

  @override
  String get notificationPostIdMissing => '게시물 ID가 없습니다. 게시물로 이동할 수 없습니다.';

  @override
  String get notificationTopicIdMissingForPost =>
      '글 ID가 없습니다. 게시물로 이동할 수 없습니다.';

  @override
  String get notificationTopicIdMissing => '글 ID가 없습니다. 글을 열 수 없습니다.';

  @override
  String get notificationUsernameMissing => '사용자 이름이 없습니다. 프로필을 열 수 없습니다.';

  @override
  String get notificationChannelIdMissing => '채널 ID가 없습니다. 채팅을 열 수 없습니다.';

  @override
  String get notificationGroupNameMissingForInbox =>
      '그룹 이름이 없습니다. 받은 편지함을 열 수 없습니다.';

  @override
  String get notificationGroupNameMissing => '그룹 이름이 없습니다. 그룹을 열 수 없습니다.';

  @override
  String get notificationNoActionUrl => '이 알림 유형에는 사용할 수 있는 작업 URL이 없습니다.';

  @override
  String get notificationBadgeUnavailable => '배지 세부 정보를 사용할 수 없습니다.';

  @override
  String get notificationBadgeLoadFailed => '이 배지를 불러올 수 없습니다.';

  @override
  String get personalMessageTitleFallback => '개인 메시지';

  @override
  String get topicTitleFallback => '글';

  @override
  String get signInToViewNotifications => '알림을 보려면 로그인하세요';

  @override
  String get youNeedToBeSignedInToViewNotifications => '알림을 보려면 로그인해야 합니다.';

  @override
  String get noUnreadNotifications => '읽지 않은 알림이 없습니다';

  @override
  String get noNotificationsYet => '아직 알림이 없습니다';

  @override
  String get newNotificationFallbackBody => '새 알림';

  @override
  String get unableToOpenNotification => '알림을 열 수 없습니다';

  @override
  String get notificationMissingSiteInfo => '사이트 정보가 없습니다(site_id).';

  @override
  String get notificationInvalidSiteInfo => '사이트 정보가 잘못되었습니다(site_id).';

  @override
  String get notificationMissingPostInfo => '게시물 정보가 없습니다(content_id).';

  @override
  String get notificationMissingMessageInfo => '메시지 정보가 없습니다(conversation_id).';

  @override
  String get notificationMissingUserInfo => '사용자 정보가 없습니다(sender_id).';

  @override
  String get notificationUnsupportedType => '지원되지 않는 알림 유형입니다.';

  @override
  String get notificationForumNotFound => '이 사이트의 포럼을 찾을 수 없습니다.';

  @override
  String get notificationForumOpenFailed => '포럼을 초기화하지 못했습니다.';

  @override
  String get notificationMissingTopicInfo => '글 정보가 없습니다(topic_id).';

  @override
  String get failedToLoadTags => '태그를 불러오지 못했습니다.';

  @override
  String get searchTagsHint => '태그 검색…';

  @override
  String get tagsSortedByCountTooltip => '글 수 순으로 정렬됨 — 탭하여 A→Z로 전환';

  @override
  String get tagsSortedAlphabeticallyTooltip => '이름순으로 정렬됨 — 탭하여 인기순으로 전환';

  @override
  String get noTagsYet => '이 포럼에는 아직 태그가 없습니다.';

  @override
  String get tagNotificationLevelTooltip => '알림 수준';

  @override
  String get tagTopicsLoadFailed => '불러오지 못했습니다';

  @override
  String searchFailedWithError(String error) {
    return '검색 실패: $error';
  }

  @override
  String get searchFiltersButtonTooltip => '필터';

  @override
  String get searchFilterStatusSection => '상태';

  @override
  String get searchFilterMyActivitySection => '내 활동';

  @override
  String get searchFilterMatchTypeSection => '일치 유형';

  @override
  String get searchTagsFilterHelper => '공백 또는 쉼표로 구분합니다. 모든 태그가 있어야 합니다.';

  @override
  String get searchSortBy => '정렬 기준';

  @override
  String get searchStatusOpen => '열림';

  @override
  String get searchStatusArchived => '보관됨';

  @override
  String get searchStatusNoReplies => '댓글 없음';

  @override
  String get searchStatusPublicOnly => '공개만';

  @override
  String get searchStatusUnsolved => '미해결';

  @override
  String get searchInBookmarked => '내가 북마크함';

  @override
  String get searchInMyMessages => '내 메시지에서';

  @override
  String get searchInLiked => '내가 좋아요 누름';

  @override
  String get searchInPosted => '내가 게시한 위치';

  @override
  String get searchInWatching => '내가 구독 중';

  @override
  String get searchInTracking => '내가 추적 중';

  @override
  String get searchInSeen => '읽음';

  @override
  String get searchInUnseen => '읽지 않음';

  @override
  String get searchSortLatestPost => '최신 게시물';

  @override
  String get searchSortMostLiked => '가장 많은 좋아요';

  @override
  String get searchSortMostViewed => '가장 높은 조회수';

  @override
  String get searchSortLatestTopic => '최신 글';

  @override
  String get searchFieldHint => '검색…';

  @override
  String get bookmarksUnavailable => '북마크를 사용할 수 없습니다';

  @override
  String get failedToLoadBookmarks => '북마크를 불러오지 못했습니다';

  @override
  String get failedToRemoveBookmark => '북마크를 삭제하지 못했습니다';

  @override
  String get failedToUpdateBookmark => '북마크를 업데이트하지 못했습니다';

  @override
  String get bookmarkWithReminder => '미리 알림이 있는 북마크';

  @override
  String get noReminder => '미리 알림 안 함';

  @override
  String get failedToLoadDrafts => '초안을 불러오지 못했습니다.';

  @override
  String get failedToDiscardDraft => '초안을 삭제하지 못했습니다';

  @override
  String get messagesLoadFailed => '메시지를 불러오지 못했습니다';

  @override
  String get moreMessagesLoadFailed => '메시지를 더 불러오지 못했습니다';

  @override
  String get messageUnknownUser => '알 수 없음';

  @override
  String get unknownErrorFallback => '알 수 없는 오류';

  @override
  String get chatComposerDefaultHint => '메시지를 입력하세요…';

  @override
  String chatChannelNumbered(Object id) {
    return '채널 $id';
  }

  @override
  String get chatSendFailed => '메시지를 보내지 못했습니다.';

  @override
  String get chatEditFailed => '메시지를 수정하지 못했습니다.';

  @override
  String get chatDeleteFailed => '메시지를 삭제하지 못했습니다.';

  @override
  String get chatReactionsUnsupported => '여기에서는 반응을 사용할 수 없습니다.';

  @override
  String get chatReactionFailed => '반응을 업데이트하지 못했습니다.';

  @override
  String get attachmentDefaultName => '첨부파일';

  @override
  String get fileTypeAudio => '오디오';

  @override
  String get fileTypeText => '텍스트';

  @override
  String get fileTypeArchive => '압축 파일';

  @override
  String get fileTypeFile => '파일';

  @override
  String downloadFailedHttpStatus(String status) {
    return '파일 다운로드 실패: HTTP $status';
  }

  @override
  String get downloadedFileEmpty => '다운로드한 파일이 비어 있습니다';

  @override
  String downloadFileFailed(String error) {
    return '파일 다운로드 실패: $error';
  }

  @override
  String attachmentTypeNotAllowed(String extension, String allowed) {
    return '.$extension 파일 형식은 허용되지 않습니다. 허용되는 형식: $allowed';
  }

  @override
  String attachmentFileTooLarge(String size, String max) {
    return '파일 크기($size)가 최대 크기 $max를 초과합니다';
  }

  @override
  String get attachmentValidationFailed => '파일 검증에 실패했습니다';

  @override
  String get uploadMissingReference => '업로드는 완료되었지만 서버가 파일 참조를 반환하지 않았습니다.';

  @override
  String get imageFileNotFound => '이미지 파일을 찾을 수 없습니다';

  @override
  String get failedToLoadVideo => '동영상을 불러오지 못했습니다';

  @override
  String get userInfoLoadFailed => '사용자 정보를 불러오지 못했습니다.';

  @override
  String userInfoLoadFailedWithError(String error) {
    return '사용자 정보를 불러오지 못했습니다: $error';
  }

  @override
  String get profileMenuIgnoreUser => '사용자 무시';

  @override
  String get profileMenuUnignoreUser => '사용자 무시 해제';

  @override
  String get ignoreStateUpdateFailed => '무시 상태를 변경하지 못했습니다';

  @override
  String profileNowIgnoringUser(String username) {
    return '@$username님을 무시합니다. 이 사용자의 게시물이 숨겨집니다.';
  }

  @override
  String get profileIgnoreToggleFailed => '무시 전환에 실패했습니다.';

  @override
  String get profileStatsLoadFailed => '통계를 불러오지 못했습니다.';

  @override
  String get profileFollowFailed => '팔로우하지 못했습니다';

  @override
  String get profileUnfollowFailed => '언팔로우하지 못했습니다';

  @override
  String get profileChatOpenFailed => '이 사용자와 채팅을 열 수 없습니다.';

  @override
  String summaryLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '좋아요 $count개',
    );
    return '$_temp0';
  }

  @override
  String summaryLinkClicks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '클릭 수 $count회',
    );
    return '$_temp0';
  }

  @override
  String get directoryPeriodAllTime => '전체';

  @override
  String get directoryPeriodYear => '년';

  @override
  String get directoryPeriodQuarter => '분기';

  @override
  String get directoryPeriodMonth => '월';

  @override
  String get directoryPeriodWeek => '주';

  @override
  String get directoryPeriodToday => '오늘';

  @override
  String get directoryOrderReceived => '받음';

  @override
  String get directoryOrderReplies => '댓글';

  @override
  String get directoryOrderTopics => '글';

  @override
  String get directoryOrderVisits => '방문';

  @override
  String get directoryLoadFailed => '사용자 목록을 불러오지 못했습니다.';

  @override
  String get directoryNoUsersMatch => '해당 이름과 일치하는 사용자가 없습니다.';

  @override
  String get directoryNoUsersForPeriod => '이 기간에 해당하는 사용자가 없습니다.';

  @override
  String get userSearchNoResults => '사용자를 찾을 수 없습니다';

  @override
  String get userSearchTryDifferentUsername => '다른 사용자 이름으로 검색해 보세요';

  @override
  String get userSearchPromptTitle => '사용자 검색';

  @override
  String get userSearchPromptHint => '사용자 이름을 입력하여 사용자를 찾고 초대하세요';

  @override
  String get ignoredUsersUnignoreFailed => '무시를 해제하지 못했습니다.';

  @override
  String get ignoredUsersEmpty => '무시하고 있는 사용자가 없습니다.';

  @override
  String get ignoredUsersEmptyHint =>
      '사용자 프로필을 열고 메뉴에서 \"사용자 무시\"를 선택하면 해당 사용자의 게시물과 알림이 숨겨집니다.';

  @override
  String get badgesLoadFailed => '배지를 불러오지 못했습니다.';

  @override
  String get badgesEmpty => '이 포럼에는 배지가 없습니다.';

  @override
  String get badgeTierGold => '골드';

  @override
  String get badgeTierSilver => '실버';

  @override
  String get badgeTierBronze => '브론즈';

  @override
  String badgeEarnedAgo(String time) {
    return '$time 획득';
  }

  @override
  String badgeEarnedByUsers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '사용자 $formatted명이 획득',
    );
    return '$_temp0';
  }

  @override
  String get trustLevelNameNewUser => '신규 사용자';

  @override
  String get trustLevelNameBasic => '기본 사용자';

  @override
  String get trustLevelNameMember => '회원';

  @override
  String get trustLevelNameRegular => '정회원';

  @override
  String get trustLevelNameLeader => '리더';

  @override
  String get trustLevelSummary0 =>
      '방금 가입했습니다. 읽고 글을 쓸 수 있지만 링크, 이미지, 메시지에 제한이 있습니다.';

  @override
  String get trustLevelSummary1 =>
      '주요 게시 기능이 열립니다: 이미지와 첨부 파일, 더 많은 링크, 게시물 신고.';

  @override
  String get trustLevelSummary2 =>
      '초대를 보내고, 사용자를 무시하고, 자신의 게시물을 더 오래 수정할 수 있습니다.';

  @override
  String get trustLevelSummary3 =>
      '글의 카테고리와 제목을 변경하고 태그를 만들 수 있으며, 스팸 신고의 비중이 더 커집니다.';

  @override
  String get trustLevelSummary4 =>
      '운영진이 부여합니다. 모든 게시물을 수정하고 글을 고정, 종료, 분할, 병합할 수 있습니다.';

  @override
  String trustLevelRowTitle(int level, String name) {
    return 'TL$level · $name';
  }

  @override
  String get profileNoUserSpecified => '사용자가 지정되지 않았습니다';

  @override
  String get userTopicsLoadFailed => '글을 불러오지 못했습니다';

  @override
  String get userTopicsEmpty => '아직 작성한 글이 없습니다.';

  @override
  String get userRecentPostsLoadFailed => '최근 게시물을 불러오지 못했습니다';

  @override
  String get activityUnknownTopic => '알 수 없는 글';

  @override
  String groupJoinedSnack(String group) {
    return '$group에 가입했습니다';
  }

  @override
  String get groupJoinFailed => '그룹에 가입하지 못했습니다';

  @override
  String groupLeftSnack(String group) {
    return '$group에서 나갔습니다';
  }

  @override
  String get groupLeaveFailed => '그룹에서 나가지 못했습니다';

  @override
  String get groupMembershipRequestHint =>
      '가입하려는 이유는 무엇인가요? 그룹 소유자가 요청과 함께 확인합니다.';

  @override
  String get groupMembershipReasonRequired => '가입을 요청하려면 이유가 필요합니다';

  @override
  String get groupMembershipRequestSent => '요청을 보냈습니다. 그룹 소유자의 승인이 필요합니다';

  @override
  String get groupMembershipRequestFailed => '가입 요청을 보내지 못했습니다';

  @override
  String get groupMemberBadge => '회원';

  @override
  String get groupRequestPending => '요청 대기 중';

  @override
  String get groupJoining => '가입 중…';

  @override
  String get groupJoinButton => '그룹 가입';

  @override
  String get groupsLoadFailed => '그룹을 불러오지 못했습니다.';

  @override
  String get groupBuiltIn => '기본 제공 그룹';

  @override
  String invitesPendingWithCount(int count) {
    return '보류 중($count)';
  }

  @override
  String invitesExpiredWithCount(int count) {
    return '만료됨($count)';
  }

  @override
  String invitesRedeemedWithCount(int count) {
    return '사용됨($count)';
  }

  @override
  String get invitesLoadFailed => '초대를 불러오지 못했습니다.';

  @override
  String get inviteLinkCreateFailed => '초대 링크를 만들지 못했습니다';

  @override
  String get inviteEmailAddressLabel => '이메일 주소';

  @override
  String get inviteEmailInvalid => '올바른 이메일 주소를 입력하세요';

  @override
  String get inviteMessageOptionalLabel => '메시지(선택 사항)';

  @override
  String get inviteSendFailed => '초대를 보내지 못했습니다';

  @override
  String get revokeInviteLinkWarning => '초대 링크가 더 이상 작동하지 않습니다.';

  @override
  String revokeInviteEmailWarning(String email) {
    return '$email에 보낸 초대가 더 이상 작동하지 않습니다.';
  }

  @override
  String get inviteRevokeFailed => '초대를 취소하지 못했습니다';

  @override
  String get inviteNoPermission => '초대할 권한이 없습니다';

  @override
  String get invitesEmptyPending => '보류 중인 초대가 없습니다';

  @override
  String get invitesEmptyExpired => '만료된 초대가 없습니다';

  @override
  String get invitesEmptyRedeemed => '사용된 초대가 없습니다';

  @override
  String get invitesEmptyPendingHint => '초대 링크를 만들어 사람들을 포럼에 초대하세요.';

  @override
  String get inviteLinkFallbackTitle => '초대 링크';

  @override
  String inviteRedeemedOn(String date) {
    return '$date 사용됨';
  }

  @override
  String inviteRedemptions(int count, int max) {
    return '$max회 중 $count회 사용됨';
  }

  @override
  String get inviteEmailSent => '이메일 보냄';

  @override
  String get inviteEmailNotSent => '이메일 보내지 않음';

  @override
  String inviteExpiredOn(String date) {
    return '$date 만료됨';
  }

  @override
  String get inviteRevokeTooltip => '초대 취소';

  @override
  String get reviewStatusPending => '보류 중';

  @override
  String get reviewStatusApproved => '승인됨';

  @override
  String get reviewStatusRejected => '거부됨';

  @override
  String get reviewStatusAll => '모두';

  @override
  String get reviewStatusIgnored => '신고 무시됨';

  @override
  String get reviewStatusDeleted => '삭제된 글 또는 댓글';

  @override
  String get reviewQueueUnavailable => '이 포럼에서는 검토 대기열을 사용할 수 없습니다.';

  @override
  String get reviewQueueLoadFailed => '검토 대기열을 불러오지 못했습니다';

  @override
  String get reviewableChangedByOther => '다른 운영자가 이 항목을 변경했습니다. 새로 고치는 중…';

  @override
  String get reviewActionFailed => '작업을 수행하지 못했습니다';

  @override
  String reviewActionDone(String action) {
    return '$action 완료';
  }

  @override
  String get reviewRejectReasonHint => '거부하는 이유는 무엇인가요?';

  @override
  String get reviewTypeFlaggedPost => '신고된 게시물';

  @override
  String get reviewTypeQueuedPost => '대기 중인 게시물';

  @override
  String get reviewTypeQueuedTopic => '대기중인 글';

  @override
  String get reviewTypeUser => '사용자';

  @override
  String get reviewTypePost => '게시물';

  @override
  String get reviewTypeChatMessage => '신고된 채팅 메시지';

  @override
  String get reviewModeratorAccessRequired => '운영자 권한이 필요합니다';

  @override
  String reviewableScore(String score) {
    return '점수 $score';
  }

  @override
  String get postRepliesLoadFailed => '댓글을 불러오지 못했습니다.';

  @override
  String get postMakeWiki => '위키 만들기';

  @override
  String get postRemoveWiki => '위키 제거';

  @override
  String get postBookmarkRemoveFailed => '북마크를 삭제하지 못했습니다';

  @override
  String get postBookmarkFailed => '게시물을 북마크하지 못했습니다';

  @override
  String get postBookmarkReminderUpdateFailed => '알림을 수정하지 못했습니다';

  @override
  String get postBookmarkReminderSet => '알림을 설정했습니다';

  @override
  String get postBookmarkReminderCleared => '미리 알림을 해제했습니다';

  @override
  String get solutionMarkFailed => '해결책으로 표시하지 못했습니다';

  @override
  String get solutionUnmarkFailed => '해결책 표시를 해제하지 못했습니다';

  @override
  String get postUnknownDate => '날짜 알 수 없음';

  @override
  String get postBookmarkAction => '게시물 북마크';

  @override
  String get reactionButtonRemoveLike => '좋아요를 눌렀습니다. 탭하면 좋아요를 취소합니다.';

  @override
  String reactionButtonRemove(String reaction) {
    return '내 반응: $reaction. 탭하면 취소합니다.';
  }

  @override
  String reactionButtonLocked(String reaction) {
    return '내 반응: $reaction. 더 이상 바꿀 수 없습니다.';
  }

  @override
  String get reactionHoldHint => '길게 누르면 다른 반응';

  @override
  String reactionSummarySemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '반응 $count개. 탭하여 반응한 사람 보기.',
    );
    return '$_temp0';
  }

  @override
  String get reactionLockedMessage => '이 게시물에 대한 반응은 더 이상 바꿀 수 없습니다.';

  @override
  String get reactionHoldTip => '팁: 하트를 길게 누르면 다른 반응을 고를 수 있습니다.';

  @override
  String reactionsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '반응 $count개',
    );
    return '$_temp0';
  }

  @override
  String get reactionsAll => '전체';

  @override
  String get reactionYou => '나';

  @override
  String get changeYourReaction => '반응 바꾸기';

  @override
  String get reactionTapAgainToRemove => '내 반응을 다시 탭하면 취소됩니다.';

  @override
  String reactionFilterSemantics(String reaction, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$reaction, $count명',
    );
    return '$_temp0';
  }

  @override
  String get postLikeAction => '게시물에 좋아요 표시';

  @override
  String get postUnlikeAction => '좋아요 취소';

  @override
  String get postVoteRemoveFailed => '투표를 취소하지 못했습니다(취소 가능 시간이 지났을 수 있습니다)';

  @override
  String get postVoteCastFailed => '투표하지 못했습니다';

  @override
  String get postUpvote => '추천';

  @override
  String get postDownvote => '비추천';

  @override
  String get pollVoteFailed => '투표하지 못했습니다. 다시 시도하세요.';

  @override
  String get pollRemoveVoteFailed => '투표를 취소하지 못했습니다. 다시 시도하세요.';

  @override
  String get pollVotersLoadFailed => '투표자를 불러오지 못했습니다.';

  @override
  String get pollVotersNotVisible => '이 투표의 투표자는 공개되지 않습니다.';

  @override
  String solutionSolvedByInPost(String name, int postNumber) {
    return '$name님이 게시물 #$postNumber에서 해결';
  }

  @override
  String solutionMarkedBy(String name) {
    return '$name님이 표시';
  }

  @override
  String reactAgainInSeconds(int seconds) {
    return '$seconds초 후에 다시 반응할 수 있습니다';
  }

  @override
  String get reactionUpdateFailed => '반응을 업데이트하지 못했습니다.';

  @override
  String get reactionsNotSupported => '이 포럼은 반응을 지원하지 않습니다.';

  @override
  String get reactionsLoadFailed => '반응을 불러오지 못했습니다.';

  @override
  String viewProfileOfUser(String username) {
    return '$username님의 프로필 보기';
  }

  @override
  String get failedToSavePost => '게시물을 저장하지 못했습니다';

  @override
  String failedToSavePostWithError(String error) {
    return '게시물을 저장하지 못했습니다: $error';
  }

  @override
  String get failedToRemoveAttachmentCheckPermissions =>
      '첨부 파일을 삭제하지 못했습니다. 권한을 확인하세요.';

  @override
  String get editPostTitle => '게시물 편집';

  @override
  String get editYourPostHint => '게시물 편집...';

  @override
  String get failedToPostReply => '답글을 게시하지 못했습니다';

  @override
  String failedToPostReplyWithError(String error) {
    return '답글을 게시하지 못했습니다: $error';
  }

  @override
  String get failedToCreateTopic => '글을 작성하지 못했습니다';

  @override
  String get writeYourTopicTitle => '글 제목 작성...';

  @override
  String get writeYourTopicContent => '글 내용 작성...';

  @override
  String get composerTitleHint => '제목 작성...';

  @override
  String get composerContentHint => '내용 작성...';

  @override
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit) {
    return '$fileName: 너무 크며($size) 크기를 줄일 수 없습니다. 제한은 $limit입니다.';
  }

  @override
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit) {
    return '$fileName을(를) $limit 제한에 맞게 $size$dimensions(으)로 줄였습니다.';
  }

  @override
  String get composerAttachFileHint => '이 게시물에 파일 첨부';

  @override
  String get composerUploadImageHint => '이 게시물에 이미지 업로드';

  @override
  String get composerFormattingHint => '서식 옵션 열기';

  @override
  String get whisperStaffOnly => '귓속말(운영진 전용)';

  @override
  String get whisperOnStaffOnly => '귓속말 켜짐(운영진 전용)';

  @override
  String get tagInputMaxReached => '태그 최대 개수에 도달했습니다';

  @override
  String get tagInputAddTag => '태그 추가…';

  @override
  String get tagInputAddAnother => '+ 태그';

  @override
  String get editHistoryUnavailable => '이 포럼에서는 편집 기록을 사용할 수 없습니다.';

  @override
  String get editHistoryLoadFailed => '편집 기록을 불러오지 못했습니다.';

  @override
  String get previousRevision => '이전 수정 버전';

  @override
  String get nextRevision => '다음 수정 버전';

  @override
  String get notificationPrefsLoadFailed => '알림 설정을 불러오지 못했습니다.';

  @override
  String get notificationPrefsSaveFailed => '저장하지 못했습니다 — 연결을 확인하세요';

  @override
  String get signInToManageNotificationPrefs => '알림 설정을 관리하려면 로그인하세요.';

  @override
  String get emailWhenAwayTitle => '부재 시 이메일';

  @override
  String get emailLevelDescription =>
      '내가 인용되거나 댓글을 받았을 때, 내 아이디(@username)가 언급되었을 때 또는 내가 구독한 카테고리, 태그 또는 글에 새로운 활동이 있을 때 이메일 보내기';

  @override
  String get notificationPrefAlways => '항상';

  @override
  String get notificationPrefOnlyWhenAway => '접속 중이 아닐 때만';

  @override
  String get notificationPrefNever => '거부';

  @override
  String get emailForMessagesTitle => '메시지 이메일';

  @override
  String get emailMessagesLevelDescription => '개인 메시지를 받으면 이메일 보내기';

  @override
  String get activitySummaryTitle => '활동 요약';

  @override
  String get activitySummaryDescription =>
      '이곳을 방문하지 않을 경우 인기 글 및 댓글에 대한 요약 이메일 보내기';

  @override
  String get activitySummaryFrequencyTitle => '활동 요약 빈도';

  @override
  String get activitySummaryDaily => '매일';

  @override
  String get activitySummaryWeekly => '매주';

  @override
  String get activitySummaryMonthly => '매달';

  @override
  String get mailingListModeTitle => '메일링 리스트 모드';

  @override
  String get mailingListModeDescription =>
      '모든 게시물을 이메일로 받습니다(활동 요약은 꺼짐). 활동이 많은 포럼에서는 권장하지 않습니다.';

  @override
  String get likeNotificationFrequencyTitle => '좋아요 받았을 때 알림';

  @override
  String get likeNotificationFirstTimeAndDaily => '게시물이 첫 좋아요를 받았을 때부터 매일 알림';

  @override
  String get likeNotificationFirstTime => '게시물이 첫 좋아요를 받았을 때';

  @override
  String get whenPostingTitle => '글 작성 시';

  @override
  String get whenPostingDescription => '댓글을 단 글을 어떻게 할지';

  @override
  String get whenPostingWatchTopic => '글 구독';

  @override
  String get whenPostingTrackTopic => '글 팔로우';

  @override
  String get whenPostingDoNothing => '아무것도하지 않음';

  @override
  String get pauseNotificationsUntilTomorrow => '내일까지';

  @override
  String get couldNotEnableDoNotDisturb => '방해 금지를 켤 수 없습니다';

  @override
  String get couldNotTurnOffDoNotDisturb => '방해 금지를 끌 수 없습니다';

  @override
  String get passwordResetEmailSent => '비밀번호 재설정 이메일을 보냈습니다.';

  @override
  String get couldNotSendResetEmail => '재설정 이메일을 보낼 수 없습니다';

  @override
  String get accountRequestFailed => '요청에 실패했습니다.';

  @override
  String get forumUrlUnavailable => '포럼 URL을 사용할 수 없습니다.';

  @override
  String get couldNotOpenPreferencesPage => '환경설정 페이지를 열 수 없습니다.';

  @override
  String get couldNotOpenForumUrl => '포럼 URL을 열 수 없습니다.';

  @override
  String get couldNotRequestEmailChange => '이메일 변경을 요청할 수 없습니다';

  @override
  String get newEmailLabel => '새로운 이메일';

  @override
  String get enterAnEmailAddress => '이메일 주소를 입력하세요';

  @override
  String get emailLooksInvalid => '이메일 형식이 아닌 것 같습니다';

  @override
  String get emailNoSpaces => '이메일에는 공백을 넣을 수 없습니다';

  @override
  String get allowNotificationsSheetTitle => '알림 허용';

  @override
  String get notificationsGrantNoPayload => '승인에서 응답이 반환되지 않았습니다.';

  @override
  String get thisForumFallback => '이 포럼';

  @override
  String signInToDomain(String domain) {
    return '$domain에 로그인';
  }

  @override
  String get loginResultTitle => '로그인 결과';

  @override
  String get invalidAuthenticationCode => '인증 코드가 올바르지 않습니다';

  @override
  String get tfaVerificationError => '인증 중 오류가 발생했습니다. 다시 시도하세요.';

  @override
  String get passwordFieldLabel => '비밀번호';

  @override
  String get somethingWentWrongTryAgain => '문제가 발생했습니다. 다시 시도하세요.';

  @override
  String get unexpectedErrorTryAgain => '예기치 않은 오류가 발생했습니다. 다시 시도하세요.';

  @override
  String get errorNoInternetConnection => '인터넷에 연결되어 있지 않습니다. 네트워크 설정을 확인하세요.';

  @override
  String get errorRequestTimedOut => '요청 시간이 초과되었습니다. 다시 시도하세요.';

  @override
  String get errorServerTryLater => '서버 오류가 발생했습니다. 나중에 다시 시도하세요.';

  @override
  String get errorInvalidCredentials => '사용자 이름 또는 비밀번호가 올바르지 않습니다.';

  @override
  String get errorSessionExpired => '세션이 만료되었습니다. 다시 로그인하세요.';

  @override
  String get errorAccountSuspended => '계정이 정지되었습니다. 포럼 스태프에게 문의하세요.';

  @override
  String get errorForumNotFound => '포럼을 찾을 수 없습니다.';

  @override
  String get errorForumAccessDenied => '이 포럼에 접근할 권한이 없습니다.';

  @override
  String get errorForumUnavailable => '포럼을 현재 사용할 수 없습니다. 나중에 다시 시도하세요.';

  @override
  String get errorDataNotFound => '요청한 데이터를 찾을 수 없습니다.';

  @override
  String get errorDataCorrupted => '데이터가 손상된 것 같습니다. 페이지를 새로 고치세요.';

  @override
  String get errorCacheLoadFailed => '캐시된 데이터를 불러오지 못했습니다. 다시 시도하세요.';

  @override
  String errorInvalidField(String field) {
    return '$field이(가) 올바르지 않습니다.';
  }

  @override
  String errorFieldRequired(String field) {
    return '$field은(는) 필수입니다.';
  }

  @override
  String errorPermissionDeniedFor(String action) {
    return '$action 권한이 없습니다.';
  }

  @override
  String errorFeatureNotAvailable(String feature) {
    return '$feature은(는) 이 포럼에서 사용할 수 없습니다.';
  }

  @override
  String get errorStorageFull => '저장 공간이 가득 찼습니다. 공간을 확보하세요.';

  @override
  String get errorStorageAccessDenied => '저장소 접근이 거부되었습니다. 앱 권한을 확인하세요.';

  @override
  String get errorNetworkTryAgain => '네트워크 오류가 발생했습니다. 다시 시도하세요.';

  @override
  String get errorAuthenticationTryAgain => '인증에 실패했습니다. 다시 시도하세요.';

  @override
  String get errorForumTryAgain => '포럼 오류가 발생했습니다. 다시 시도하세요.';

  @override
  String get connectionErrorTitle => '연결 오류';

  @override
  String get authenticationErrorTitle => '인증 오류';

  @override
  String get forumErrorTitle => '포럼 오류';

  @override
  String get permissionErrorTitle => '권한 오류';

  @override
  String errorRemovingFromMessage(String name) {
    return '이 메시지에서 $name 님을 제거할 수 없습니다.';
  }

  @override
  String get chatNewMessage => '새로운 메시지';

  @override
  String get chatStarred => '즐겨찾기';

  @override
  String get chatBrowseChannels => '채널 찾아보기';

  @override
  String get chatBrowseAllChannels => '모든 채널 찾아보기';

  @override
  String get chatFilterAll => '전체';

  @override
  String get chatFilterOpen => '열기';

  @override
  String get chatFilterClosed => '닫힘';

  @override
  String get chatFilterArchived => '보관됨';

  @override
  String get chatBrowseSearch => '이름으로 채널 검색';

  @override
  String get chatJoin => '가입';

  @override
  String get chatJoined => '가입됨';

  @override
  String get chatLeave => '나가기';

  @override
  String chatMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '회원 $count명',
    );
    return '$_temp0';
  }

  @override
  String get chatYesterday => '어제';

  @override
  String get chatNoChannelsFound => '채널을 찾을 수 없습니다.';

  @override
  String get chatCloseDm => '이 개인 채팅 닫기';

  @override
  String get chatToday => '오늘';

  @override
  String get chatLastVisit => '마지막 방문';

  @override
  String chatNewMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '새 메시지 $count개',
    );
    return '$_temp0';
  }

  @override
  String get chatScrollToBottom => '맨 아래로 스크롤';

  @override
  String get chatInReplyTo => '답장 대상';

  @override
  String get chatCopyText => '텍스트 복사';

  @override
  String get chatTextCopied => '텍스트를 클립보드에 복사했습니다';

  @override
  String get chatBookmark => '북마크';

  @override
  String get chatPinMessage => '메시지 고정';

  @override
  String get chatUnpinMessage => '메시지 고정 해제';

  @override
  String get chatFlag => '신고';

  @override
  String get chatReactWithEmoji => '이모지로 반응하기';

  @override
  String chatReplyingTo(String username) {
    return '$username님에게 답장';
  }

  @override
  String get chatEditingMessage => '메시지 수정 중';

  @override
  String chatTypingOne(String username) {
    return '$username님이 입력 중';
  }

  @override
  String chatTypingTwo(String commaSeparatedUsernames, String lastUsername) {
    return '$commaSeparatedUsernames님과 $lastUsername님이 입력 중';
  }

  @override
  String chatTypingMany(String commaSeparatedUsernames, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$commaSeparatedUsernames님 외 $count명이 입력 중',
    );
    return '$_temp0';
  }

  @override
  String get chatOpenThread => '스레드 열기';

  @override
  String get chatMembers => '회원';

  @override
  String get chatAddMember => '멤버 추가';

  @override
  String get chatFindMembers => '회원 찾기';

  @override
  String get chatRemoveMember => '제거';

  @override
  String get chatNotifyNever => '알림 받지 않기';

  @override
  String get chatNotifyMention => '멘션된 경우에만';

  @override
  String get chatNotifyAlways => '모든 활동';

  @override
  String get chatNotificationLevel => '푸시 알림 보내기';

  @override
  String get chatMuteChannel => '채널 음소거';

  @override
  String get chatStarChannel => '채널 즐겨찾기';

  @override
  String get chatLeaveChannel => '채널 나가기';

  @override
  String get chatSearchTitle => '채팅 검색';

  @override
  String get chatSearchNoResults => '검색된 결과가 없습니다';

  @override
  String get chatMyThreads => '내 스레드';

  @override
  String chatThreadReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 댓글',
    );
    return '$_temp0';
  }

  @override
  String get chatNoThreads => '참여 중인 스레드가 없습니다.';

  @override
  String get chatGroupName => '그룹 채팅 이름(선택 사항)';

  @override
  String chatMembersCounter(int count, int max) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count/$max명',
    );
    return '$_temp0';
  }

  @override
  String get chatTooManyMembers => '최대 멤버 수에 도달했습니다';

  @override
  String get chatThread => '스레드';

  @override
  String get chatChannelSettings => '채널 설정';

  @override
  String get chatSearchMessagesHint => '메시지 검색';

  @override
  String get chatMyThreadsEmpty => '아직 스레드가 없습니다. 참여하는 스레드가 여기에 표시됩니다.';

  @override
  String get chatLeaveGroupInfo =>
      '이 그룹 채팅에서 나가면 더 이상 접근할 수 없고 관련 알림도 받지 않습니다. 다시 참여하려면 그룹 채팅 멤버의 초대를 받아야 합니다.';

  @override
  String get chatPlaceholderThread => '스레드에서 채팅';

  @override
  String get chatLastReply => '마지막 답글';

  @override
  String messageListUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '읽지 않음($count)',
    );
    return '$_temp0';
  }

  @override
  String messageListNewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '새글 ($count)',
    );
    return '$_temp0';
  }

  @override
  String get messagePersonal => '개인';

  @override
  String messageListIncoming(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개의 새글 또는 업데이트 된 글 보기',
    );
    return '$_temp0';
  }

  @override
  String get chatPlaceholderGroup => '그룹에서 채팅';

  @override
  String get notificationAccountMismatch =>
      '현재 계정으로는 이 알림을 열 수 없습니다. 알림을 열어 이 계정의 업데이트를 확인하세요.';
}
