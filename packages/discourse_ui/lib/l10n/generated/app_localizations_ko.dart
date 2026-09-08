// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

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
  String get newConversation => '새 대화';

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
  String get pleaseLoginToSubscribe => '이 스레드를 null하려면 로그인하세요';

  @override
  String get subscribe => '구독';

  @override
  String get failedToSubscribeToThread => '스레드 null 실패';

  @override
  String get youCannotReplyToThisThread => '이 스레드에 답변할 수 없습니다';

  @override
  String get pleaseWaitForThreadToLoad => '스레드가 로드될 때까지 기다려주세요';

  @override
  String get softDelete => '소프트 삭제';

  @override
  String get postCanBeRestoredLater => '게시물은 나중에 복원할 수 있습니다';

  @override
  String get hardDelete => '완전 삭제';

  @override
  String get postWillBePermanentlyDeleted => '게시물이 영구적으로 삭제됩니다';

  @override
  String get reasonForDeletion => '삭제 이유';

  @override
  String get enterReasonForDeletingPost => '이 게시물을 삭제하는 사유를 입력하세요';

  @override
  String get pleaseEnterReasonForDeletion => '삭제 이유를 입력하세요';

  @override
  String get reportPost => '게시물 신고';

  @override
  String get pleaseProvideReasonForReporting => '이 게시물을 신고하는 사유를 제공하세요.';

  @override
  String get reason => '사유';

  @override
  String get enterReasonForReportingPost => '이 게시물을 신고하는 사유를 입력하세요';

  @override
  String get pleaseEnterReason => '사유를 입력하세요';

  @override
  String get submitReport => '신고 제출';

  @override
  String get selectedActions => '선택한 작업:';

  @override
  String get thisActionCannotBeUndone => '이 작업은 취소할 수 없습니다.';

  @override
  String get participantsLabel => '참가자';

  @override
  String usernameHasBeenInvited(String username) {
    return '$username님이 대화에 초대되었습니다';
  }

  @override
  String errorInvitingUser(String error) {
    return '사용자 초대 오류: $error';
  }

  @override
  String get newTopic => '새 주제';

  @override
  String get markRead => '읽음으로 표시';

  @override
  String get spamOrAdvertising => '스팸 또는 광고';

  @override
  String get otherPleaseSpecify => '기타 (지정해주세요)';

  @override
  String get pleaseSpecifyReason => '사유를 지정하세요';

  @override
  String get banUser => '사용자 차단';

  @override
  String get unbanUser => '사용자 차단 해제';

  @override
  String pleaseSelectReasonForBanningUser(String username) {
    return '$username님을 차단하는 사유를 선택하세요';
  }

  @override
  String get violationOfCommunityGuidelines => '커뮤니티 가이드라인 위반';

  @override
  String get harassmentOrAbusiveBehavior => '괴롭힘 또는 학대 행위';

  @override
  String get postingInappropriateContent => '부적절한 콘텐츠 게시';

  @override
  String get accountCompromiseOrSecurityIssue => '계정 손상 또는 보안 문제';

  @override
  String get enterReasonForBanningUser => '이 사용자를 차단하는 사유를 입력하세요';

  @override
  String get banUntil => '차단 기간';

  @override
  String get selectDate => '날짜 선택';

  @override
  String get moreOptions => '더 많은 옵션';

  @override
  String get topicClosed => '주제 닫힘';

  @override
  String get topicOpened => '주제 열림';

  @override
  String get topicStickied => '주제 고정됨';

  @override
  String get topicUnstickied => '주제 고정 해제됨';

  @override
  String cannotEditMessage(String error) {
    return '이 메시지를 편집할 수 없습니다: $error';
  }

  @override
  String get confirmSpamClean => '스팸 정리 확인';

  @override
  String get handleThreads => '스레드 관리';

  @override
  String get deleteMessages => '메시지 삭제';

  @override
  String get deleteConversations => '대화 삭제';

  @override
  String get noConversations => '대화 없음';

  @override
  String get noConversationsMessage => '아직 대화가 없습니다. 새 대화를 시작하여 메시징을 시작하세요.';

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
  String get spamCleaner => '스팸 정리';

  @override
  String get sendMessage => '메시지 보내기';

  @override
  String get memberSince => '회원 가입일';

  @override
  String get lastActivity => '마지막 활동';

  @override
  String get likesReceived => '받은 좋아요';

  @override
  String get likesGiven => '준 좋아요';

  @override
  String get showMore => '더 보기';

  @override
  String get cleanSpam => '스팸 정리';

  @override
  String get failedToSaveConversation => '대화 저장 실패';

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
  String get register => '등록';

  @override
  String get signIn => '로그인';

  @override
  String get markForumRead => '포럼을 읽음으로 표시';

  @override
  String get notificationTest => '알림 테스트';

  @override
  String get forum => '포럼';

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
  String get youNeedToBeSignedInToViewConversations => '대화를 보려면 로그인해야 합니다.';

  @override
  String errorLoadingConversations(String error) {
    return '대화 로드 오류: $error';
  }

  @override
  String failedToLeaveConversation(String error) {
    return '대화 나가기 실패: $error';
  }

  @override
  String errorLoadingMoreConversations(String error) {
    return '추가 대화 로드 오류: $error';
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
  String get permanent => '영구';

  @override
  String get temporary => '임시';

  @override
  String setBanDurationFor(String username) {
    return '$username의 차단 기간 설정';
  }

  @override
  String get pleaseSelectEndDateForTemporaryBan => '임시 차단의 종료일을 선택하세요';

  @override
  String get back => '뒤로';

  @override
  String get unban => '차단 해제';

  @override
  String get confirm => '확인';

  @override
  String spamClean(String username) {
    return '$username의 스팸 정리';
  }

  @override
  String get selectActionsToPerform => '수행할 작업 선택:';

  @override
  String get moveOrDeleteThreadsBasedOnAdminSettings =>
      '관리자 설정에 따라 스레드를 이동하거나 삭제';

  @override
  String get messageUpdatedSuccessfully => '메시지가 성공적으로 업데이트되었습니다';

  @override
  String error(String error) {
    return '오류: $error';
  }

  @override
  String failedToRemoveAttachment(String error) {
    return '첨부 파일 제거 실패: $error';
  }

  @override
  String failedToLoadMessage(String error) {
    return '메시지 로드 실패: $error';
  }

  @override
  String get editMessage => '메시지 편집';

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
  String get undelete => '복원';

  @override
  String get refresh => '새로고침';

  @override
  String get share => '공유';

  @override
  String get viewOnWeb => '웹에서 보기';

  @override
  String get unlock => '잠금 해제';

  @override
  String get lock => '잠금';

  @override
  String get stick => '고정';

  @override
  String get unstick => '고정 해제';

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
  String version(String version, String buildNumber) {
    return '버전 $version ($buildNumber)';
  }

  @override
  String get unableToLoadProfile => '프로필을 불러올 수 없습니다';

  @override
  String get banned => '차단됨';

  @override
  String get reportSubmittedSuccessfully => '신고가 성공적으로 제출되었습니다';

  @override
  String get deleteTopic => '주제 삭제';

  @override
  String get topicCanBeRestoredLater => '주제는 나중에 복원할 수 있습니다';

  @override
  String get topicWillBePermanentlyDeleted => '주제가 영구적으로 삭제됩니다';

  @override
  String get enterReasonForDeletingTopic => '이 주제를 삭제하는 이유를 입력하세요';

  @override
  String get pleaseSelectEndDate => '종료일을 선택하세요';

  @override
  String get userBannedSuccessfully => '사용자가 성공적으로 차단되었습니다';

  @override
  String get failedToBanUser => '사용자 차단 실패';

  @override
  String get userUnbannedSuccessfully => '사용자 차단 해제 성공';

  @override
  String get failedToUnbanUser => '사용자 차단 해제 실패';

  @override
  String get spamCleanUser => '사용자 스팸 정리';

  @override
  String get deletePrivateConversations => '비공개 대화 삭제';

  @override
  String get banTheUserAccount => '사용자 계정 차단';

  @override
  String get handledThreads => '처리된 스레드';

  @override
  String get deletedMessages => '삭제된 메시지';

  @override
  String get deletedConversations => '삭제된 대화';

  @override
  String get bannedUser => '차단된 사용자';

  @override
  String successfullyCleanedSpam(String username, String actions) {
    return '$username의 스팸이 성공적으로 정리되었습니다. 작업: $actions';
  }

  @override
  String get home => '홈';

  @override
  String get notifications => '알림';

  @override
  String get forums => '포럼';

  @override
  String get markAllForumsAsRead => '모든 포럼을 읽음으로 표시하시겠습니까?';

  @override
  String get markAllForumsAsReadMessage =>
      '모든 포럼과 주제가 읽음으로 표시됩니다. 이 작업은 취소할 수 없습니다.';

  @override
  String get markAsRead => '읽음으로 표시';

  @override
  String get content => '내용';

  @override
  String get insertImage => '이미지 삽입';

  @override
  String get howWouldYouLikeToInsertImage => '이 이미지를 어떻게 삽입하시겠습니까?';

  @override
  String get thumbnail => '썸네일';

  @override
  String get fullSize => '전체 크기';

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
  String get submittingReport => '신고 제출 중...';

  @override
  String get banningUser => '사용자 차단 중...';

  @override
  String get unbanningUser => '사용자 차단 해제 중...';

  @override
  String get cleaningSpam => '스팸 정리 중...';

  @override
  String get writeYourMessage => '메시지 작성...';

  @override
  String get writeYourReply => '답장 작성...';

  @override
  String get conversationCreatedSuccessfully => '대화가 성공적으로 생성되었습니다';

  @override
  String get conversationMarkedAsUnread => '대화가 읽지 않음으로 표시되었습니다';

  @override
  String get conversationClosed => '대화가 닫혔습니다';

  @override
  String get conversationOpened => '대화가 열렸습니다';

  @override
  String get pleaseLoginToLikeMessages => '메시지에 좋아요를 누르려면 로그인하세요';

  @override
  String get loadEarlierMessages => '이전 메시지 불러오기';

  @override
  String failedToLoadQuote(String error) {
    return '인용문을 불러오지 못했습니다: \n$error';
  }

  @override
  String failedToSendReply(String error) {
    return '답장 전송에 실패했습니다: $error';
  }

  @override
  String failedToMarkConversationAsUnread(String error) {
    return '대화를 읽지 않음으로 표시하지 못했습니다: $error';
  }

  @override
  String failedToCloseConversation(String error) {
    return '대화를 닫지 못했습니다: $error';
  }

  @override
  String failedToOpenConversation(String error) {
    return '대화를 열지 못했습니다: $error';
  }

  @override
  String failedToJumpToMessage(String error) {
    return '메시지로 이동하지 못했습니다: $error';
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
  String get enterConversationTitle => '대화 제목 입력';

  @override
  String enterCode(int count) {
    return '$count자리 코드 입력';
  }

  @override
  String get edit => '편집';

  @override
  String get report => '신고';

  @override
  String get remove => '제거';

  @override
  String get subject => '제목';

  @override
  String get message => '메시지';

  @override
  String get titleCannotBeEmpty => '제목을 입력하세요';

  @override
  String get conversationUpdatedSuccessfully => '대화가 성공적으로 업데이트되었습니다';

  @override
  String get goBack => '돌아가기';

  @override
  String failedToLoadPost(String error) {
    return '게시물을 불러오지 못했습니다: \n$error';
  }

  @override
  String failedToLikeOrUnlikeMessage(String action, String error) {
    return '메시지 $action 실패: $error';
  }

  @override
  String get like => '좋아요';

  @override
  String get unlike => '좋아요 취소';

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
  String get failedToNavigateToForum => '포럼으로 이동 실패';

  @override
  String forumNotFoundById(String forumId) {
    return '포럼을 찾을 수 없습니다: $forumId';
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
  String nVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count표',
    );
    return '$_temp0';
  }

  @override
  String get lastSeen => '마지막 접속';

  @override
  String get chat => '채팅';

  @override
  String comingSoon(String label) {
    return '$label — 곧 제공';
  }

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
  String get discardDraftQuestion => '임시 저장을 버릴까요?';

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
  String get retryConnection => '다시 연결';

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
  String get signOutQuestion => '로그아웃할까요?';

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
  String get submit => '제출';

  @override
  String get discardDraftWarning => '저장된 임시 글이 영구히 삭제됩니다.';

  @override
  String get deleteChatMessageWarning => '모든 사람에게서 메시지가 삭제됩니다.';

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
  String get undeleteTopic => '주제 복원';

  @override
  String get undeleteTopicConfirmation => '이 주제를 복원할까요? 다른 사용자에게 다시 표시됩니다.';

  @override
  String get send => '보내기';

  @override
  String get changeEmailExplanation =>
      '새 이메일로 확인 링크를 보냅니다. 링크를 클릭하면 변경이 적용됩니다.';

  @override
  String get changeEmailSecurityNote =>
      '보안을 위해 Discourse가 이메일의 링크로 확인을 요구할 수 있습니다. 보이지 않으면 스팸 폴더를 확인하세요.';

  @override
  String get newDirectMessage => '새 다이렉트 메시지';

  @override
  String get noMessagesYetSayHi => '아직 메시지가 없습니다 — 인사해 보세요.';

  @override
  String get edited => '수정됨';

  @override
  String get editProfileManagedOnWebNote =>
      '표시 이름, 이메일, 비밀번호 및 기타 계정 설정은 계정 → 웹에서 계정 관리에서 변경합니다. 아바타는 사진의 카메라 배지를 탭하여 변경할 수 있습니다.';

  @override
  String get approvedButRelayUnreachable =>
      '승인되었지만 설정을 마치기 위한 ForumCopilot에 연결할 수 없었습니다. 나중에 설정에서 다시 시도하세요.';

  @override
  String get notificationsAreTurnedOffForThisApp => '이 앱의 알림이 꺼져 있습니다';

  @override
  String forumWillAskToApproveNotifications(Object forumName) {
    return '다음으로 $forumName에서 \"알림\" 승인을 요청합니다.';
  }

  @override
  String get approveNotificationsExplanation =>
      '승인하면 알림을 확인하여 이 기기로 보낼 수 있습니다. 이 권한으로는 게시, 답글, 메시지 읽기를 할 수 없습니다.';

  @override
  String get forumOwnerPushNote => '이 포럼 운영자가 앱 알림을 설정하면 이 단계는 필요 없습니다.';

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
  String get protected => '보호됨';

  @override
  String get solution => '해결책';

  @override
  String get deleted => '삭제됨';

  @override
  String get pleaseLoginToViewUserProfiles => '사용자 프로필을 보려면 로그인하세요.';

  @override
  String get announcement => '공지';

  @override
  String get solved => '해결됨';

  @override
  String get hot => '인기';

  @override
  String get pinned => '고정됨';

  @override
  String get subscribedLabel => '구독 중';

  @override
  String get locked => '잠김';

  @override
  String get poll => '투표';

  @override
  String errorLoadingContent(Object error) {
    return '콘텐츠 불러오기 오류: $error';
  }

  @override
  String get noPermissionToViewSubforum => '이 하위 포럼의 주제를 볼 권한이 없습니다.';

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
  String get topicDeletedBanner => '이 주제는 삭제되어 다른 사용자에게 보이지 않습니다';

  @override
  String get topicClosedBanner => '이 주제는 닫혀 더 이상 답글을 받지 않습니다';

  @override
  String get topicPinnedBanner => '이 주제는 포럼 상단에 고정되어 있습니다';

  @override
  String get youAreSubscribedToThisTopic => '이 주제를 구독 중입니다';

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
  String get editConversation => '대화 편집';

  @override
  String get closeConversation => '대화 닫기';

  @override
  String get openConversation => '대화 열기';

  @override
  String get leaveConversation2 => '대화 나가기';

  @override
  String get reportConversation2 => '대화 신고';

  @override
  String get closeConversation2 => '대화 닫기';

  @override
  String get closeConversationConfirmation => '이 대화를 닫을까요? 새 답글을 작성할 수 없게 됩니다.';

  @override
  String get close => '닫기';

  @override
  String get openConversation2 => '대화 열기';

  @override
  String get openConversationConfirmation => '이 대화를 열까요? 새 답글을 작성할 수 있게 됩니다.';

  @override
  String get open => '열기';

  @override
  String get leaveConversation3 => '대화 나가기';

  @override
  String get leaveConversationConfirmation => '이 대화에서 나갈까요? 받은편지함에서 숨겨집니다.';

  @override
  String errorLoadingConversation(Object error) {
    return '대화 불러오기 오류: $error';
  }

  @override
  String get conversationNotFound => '대화를 찾을 수 없습니다';

  @override
  String get conversationClosedBanner => '이 대화는 닫혀 더 이상 답글을 받지 않습니다';

  @override
  String get noMessagesFound => '메시지가 없습니다';

  @override
  String get endOfConversation => '대화 끝';

  @override
  String get jumpToMessage => '메시지로 이동';

  @override
  String get editConversation2 => '대화 편집';

  @override
  String get failedToLoadMessage2 => '메시지를 불러오지 못했습니다';

  @override
  String get cannotEditThisConversation => '이 대화는 편집할 수 없습니다';

  @override
  String get options => '옵션';

  @override
  String get conversationOpen => '대화 열림';

  @override
  String failedToCreateConversation(Object error) {
    return '대화를 만들 수 없습니다: $error';
  }

  @override
  String maximumAttachmentsAllowed(Object count) {
    return '최대 $count개의 첨부 파일만 허용됩니다';
  }

  @override
  String get noImagesFoundToDisplay => '표시할 이미지가 없습니다.';

  @override
  String get pleaseLoginToViewThisAttachment => '이 첨부 파일을 보려면 로그인하세요';

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
  String get emailSettingsSubtitle => '이메일 빈도, 좋아요 모아보기, 다이제스트 일정';

  @override
  String get manageAccountSubtitle => '프로필, 이메일, 비밀번호, 보안, 고급 설정';

  @override
  String get changePasswordSubtitle => '현재 주소로 비밀번호 재설정 이메일을 보냅니다';

  @override
  String get ignoredUsersSubtitle => '게시물이 숨겨진 사용자를 보고 관리';

  @override
  String get deleteAccountExplanation =>
      '계정 삭제는 포럼에서 처리합니다. 계속을 눌러 사이트를 열고 스태프에게 문의하세요 — Discourse 포럼은 자체 정책에 따라 삭제를 처리합니다.';

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
  String get unableToLoadForums => '포럼을 불러올 수 없습니다';

  @override
  String get noForumsToDisplayExplanation =>
      '표시할 포럼이 없습니다. 권한이나 포럼 구조 때문일 수 있습니다.';

  @override
  String get subscribedForums => '구독한 포럼';

  @override
  String get errorLoadingNotifications => '알림 불러오기 오류';

  @override
  String get pullDownToRefresh => '아래로 당겨 새로고침';

  @override
  String get noNewNotificationsExplanation =>
      '새 알림이 없습니다. 팔로우 중인 주제의 업데이트는 나중에 확인하세요.';

  @override
  String noTagsMatch(Object filter) {
    return '\"$filter\"과(와) 일치하는 태그가 없습니다.';
  }

  @override
  String noTopicsTagged(Object tag) {
    return '\"$tag\" 태그가 있는 주제가 없습니다';
  }

  @override
  String failedToBanUser2(Object error) {
    return '사용자를 차단하지 못했습니다: $error';
  }

  @override
  String unbanUserConfirmation(Object username) {
    return '$username 차단을 해제할까요?';
  }

  @override
  String failedToUnbanUser2(Object error) {
    return '차단을 해제하지 못했습니다: $error';
  }

  @override
  String get deletePostsProfilePostsAndComments => '게시물, 프로필 게시물, 댓글 삭제';

  @override
  String spamCleanConfirmation(Object username) {
    return '$username의 스팸을 정리할까요?';
  }

  @override
  String failedToCleanSpam(Object error) {
    return '스팸 정리 실패: $error';
  }

  @override
  String get searchUser => '사용자 검색';

  @override
  String get tapToOpen => '탭하여 열기';

  @override
  String get imageNotAvailable => '이미지를 사용할 수 없습니다';

  @override
  String get allForumTopicsHaveBeenMarkedAs => '모든 포럼 주제를 읽음으로 표시했습니다';

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
  String get failedToPickFile => '파일을 선택하지 못했습니다';

  @override
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return '$remainingSlots개의 첨부 파일만 더 추가할 수 있습니다. 처음 $remainingSlots2개의 이미지를 처리합니다.';
  }

  @override
  String get attachmentLimitReachedSkippingRemainingImages =>
      '첨부 파일 한도에 도달했습니다. 나머지 이미지는 건너뜁니다.';

  @override
  String failedToUploadImagePleaseTryAgain(Object fileName) {
    return '$fileName: 이미지를 업로드하지 못했습니다. 다시 시도하세요.';
  }

  @override
  String failedToUploadImage2(Object errorMessage, Object fileName) {
    return '$fileName: 이미지 업로드 실패: $errorMessage';
  }

  @override
  String get failedToPickImage => '이미지를 선택하지 못했습니다';

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
  String get pleaseWaitForTheThreadToLoad => '주제가 로드될 때까지 기다려 주세요';

  @override
  String get failedToUpdatePostPleaseTryAgain => '게시물을 수정하지 못했습니다. 다시 시도하세요.';

  @override
  String get postDeletedSuccessfully => '게시물을 삭제했습니다';

  @override
  String failedToDeletePost(Object error) {
    return '게시물 삭제 실패: $error';
  }

  @override
  String failedToSubmitReport2(Object error) {
    return '신고 제출 실패: $error';
  }

  @override
  String get editHistoryNotAvailable => '이 게시물의 편집 기록을 볼 수 없습니다';

  @override
  String get noPermissionToUploadAvatar => '아바타를 업로드할 권한이 없습니다';

  @override
  String get avatarUploadedSuccessfully => '아바타를 업로드했습니다';

  @override
  String failedToPickImage2(Object error) {
    return '이미지 선택 실패: $error';
  }

  @override
  String get react => '반응';

  @override
  String get reactionsAreNotEnabledOnThisForum => '이 포럼에서는 반응 기능이 꺼져 있습니다.';

  @override
  String get noReactionsYet => '아직 반응이 없습니다';

  @override
  String get searchFilters => '검색 필터';

  @override
  String signOutWarning(Object siteName) {
    return '$siteName에서 로그아웃됩니다. 언제든지 다시 로그인할 수 있습니다.';
  }

  @override
  String get suggestedTopics => '추천 주제';

  @override
  String get newLabel => '신규';

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
}
