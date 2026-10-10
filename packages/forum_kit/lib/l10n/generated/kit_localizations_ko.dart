// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'kit_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class KitLocalizationsKo extends KitLocalizations {
  KitLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get discardFailedCloseQuestion =>
      '그래도 닫을까요? 이전에 저장한 글은 임시 저장에 남아 있습니다.';

  @override
  String get keepEditing => '계속 작성';

  @override
  String get closeAnyway => '그래도 닫기';

  @override
  String get okButton => '확인';

  @override
  String get copied => '복사됨';

  @override
  String get cancel => '취소';

  @override
  String get tryAgain => '다시 시도';

  @override
  String get latest => '최신';

  @override
  String get language => '언어';

  @override
  String get all => '전체';

  @override
  String get reason => '사유';

  @override
  String get pleaseSpecifyReason => '사유를 지정하세요';

  @override
  String get selectDate => '날짜 선택';

  @override
  String get search => '검색';

  @override
  String get messages => '메시지';

  @override
  String get add => '추가';

  @override
  String get delete => '삭제';

  @override
  String get temporary => '임시';

  @override
  String error(String error) {
    return '오류: $error';
  }

  @override
  String get none => '없음';

  @override
  String get italic => '기울임꼴';

  @override
  String get link => '링크';

  @override
  String get image => '이미지';

  @override
  String get quote => '인용';

  @override
  String get code => '코드';

  @override
  String participants(int count) {
    return '참가자 ($count)';
  }

  @override
  String get refresh => '새로고침';

  @override
  String get share => '공유';

  @override
  String get reply => '답장';

  @override
  String get dark => '다크';

  @override
  String get notifications => '알림';

  @override
  String get edit => '편집';

  @override
  String get remove => '제거';

  @override
  String get message => '메시지';

  @override
  String couldNotOpenLink(String error) {
    return '링크를 열 수 없습니다: $error';
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
  String get apply => '적용';

  @override
  String get bookmarks => '북마크';

  @override
  String get copy => '복사';

  @override
  String get discard => '버리기';

  @override
  String get firstPostsOnly => '첫 게시물만';

  @override
  String get relevance => '관련성';

  @override
  String get reset => '초기화';

  @override
  String get titleOnly => '제목만';

  @override
  String get solved => '해결됨';

  @override
  String get open => '열기';

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
  String get postNeedsApprovalTitle => '승인이 필요한 게시물';

  @override
  String get postNeedsApprovalBody =>
      '새 게시물이 있습니다. 그러나 이 게시물이 보여지려면 운영자의 승인이 필요합니다. 잠시 기다려 주세요.';

  @override
  String get tapToOpen => '탭하여 열기';

  @override
  String get imageNotAvailable => '이미지를 사용할 수 없습니다';

  @override
  String get searchFilters => '검색 필터';

  @override
  String get tags => '태그';

  @override
  String get discardPostQuestion => '게시물을 버리시겠습니까?';

  @override
  String get discardChangesQuestion => '변경 사항을 버리시겠습니까?';

  @override
  String get discardChanges => '변경 사항 버리기';

  @override
  String get saveDraft => '임시 저장';

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
  String get day => '일';

  @override
  String get month => '월';

  @override
  String get chooseEmoji => '이모지 선택';

  @override
  String get searchEmoji => '이모지 검색';

  @override
  String get suspendUser => '사용자 정지';

  @override
  String get suspendUntil => '사용자 정지 기간';

  @override
  String get suspendForever => '영구 정지';

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
  String get pleaseSelectSuspensionEndDate => '정지가 끝나는 날짜를 선택하세요';

  @override
  String get dismissAllNotifications => '모두 해제';

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
  String get postLikeAction => '게시물에 좋아요 표시';

  @override
  String get postUnlikeAction => '좋아요 취소';

  @override
  String get somethingWentWrongTryAgain => '문제가 발생했습니다. 다시 시도하세요.';
}
