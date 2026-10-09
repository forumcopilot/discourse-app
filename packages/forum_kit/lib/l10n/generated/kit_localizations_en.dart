// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'kit_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class KitLocalizationsEn extends KitLocalizations {
  KitLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get okButton => 'OK';

  @override
  String get copied => 'Copied';

  @override
  String get cancel => 'Cancel';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get latest => 'Latest';

  @override
  String get language => 'Language';

  @override
  String get all => 'All';

  @override
  String get reason => 'Reason';

  @override
  String get pleaseSpecifyReason => 'Please specify the reason';

  @override
  String get selectDate => 'Select date';

  @override
  String get search => 'Search';

  @override
  String get messages => 'Messages';

  @override
  String get add => 'Add';

  @override
  String get delete => 'Delete';

  @override
  String get temporary => 'Temporary';

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String get none => 'None';

  @override
  String get italic => 'Italic';

  @override
  String get link => 'Link';

  @override
  String get image => 'Image';

  @override
  String get quote => 'Quote';

  @override
  String get code => 'Code';

  @override
  String participants(int count) {
    return 'Participants ($count)';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get share => 'Share';

  @override
  String get reply => 'Reply';

  @override
  String get dark => 'Dark';

  @override
  String get notifications => 'Notifications';

  @override
  String get edit => 'Edit';

  @override
  String get remove => 'Remove';

  @override
  String get message => 'Message';

  @override
  String couldNotOpenLink(String error) {
    return 'Could not open link: $error';
  }

  @override
  String timeGapDaysLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days later',
      one: '1 day later',
    );
    return '$_temp0';
  }

  @override
  String timeGapMonthsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months later',
      one: '1 month later',
    );
    return '$_temp0';
  }

  @override
  String timeGapYearsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years later',
      one: '1 year later',
    );
    return '$_temp0';
  }

  @override
  String get apply => 'Apply';

  @override
  String get bookmarks => 'Bookmarks';

  @override
  String get copy => 'Copy';

  @override
  String get firstPostsOnly => 'First posts only';

  @override
  String get relevance => 'Relevance';

  @override
  String get reset => 'Reset';

  @override
  String get titleOnly => 'Title only';

  @override
  String get solved => 'Solved';

  @override
  String get open => 'Open';

  @override
  String participantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants',
      one: '1 participant',
    );
    return '$_temp0';
  }

  @override
  String get postNeedsApprovalTitle => 'Post Needs Approval';

  @override
  String get postNeedsApprovalBody =>
      'We\'ve received your new post but it needs to be approved by a moderator before it will appear. Please be patient.';

  @override
  String get tapToOpen => 'Tap to open';

  @override
  String get imageNotAvailable => 'Image not available';

  @override
  String get searchFilters => 'Search filters';

  @override
  String get tags => 'Tags';

  @override
  String topicMapViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'views',
      one: 'view',
    );
    return '$_temp0';
  }

  @override
  String topicMapLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'likes',
      one: 'like',
    );
    return '$_temp0';
  }

  @override
  String topicMapLinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'links',
      one: 'link',
    );
    return '$_temp0';
  }

  @override
  String topicMapUsers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'users',
      one: 'user',
    );
    return '$_temp0';
  }

  @override
  String get day => 'Day';

  @override
  String get month => 'Month';

  @override
  String get suspendUser => 'Suspend User';

  @override
  String get suspendUntil => 'Suspend user until';

  @override
  String get suspendForever => 'Suspend forever';

  @override
  String get suspendReasonNotListening => 'Would not listen to staff feedback';

  @override
  String get suspendReasonStaffTime =>
      'Consumed disproportionate amounts of staff time';

  @override
  String get suspendReasonCombative => 'Too combative';

  @override
  String get suspendReasonWrongPlace => 'In the wrong place';

  @override
  String get suspendReasonNoPurpose =>
      'No constructive purpose to their actions other than creating dissent within the community';

  @override
  String get suspendReasonCustom => 'Custom…';

  @override
  String get suspendReasonQuestion =>
      'Why are you suspending? This text will be shown to the user when they try to log in. Keep it short.';

  @override
  String get closedLabel => 'Closed';

  @override
  String get pleaseSelectSuspensionEndDate => 'Choose when the suspension ends';

  @override
  String get dismissAllNotifications => 'Dismiss all';

  @override
  String get searchFilterStatusSection => 'Status';

  @override
  String get searchFilterMyActivitySection => 'My activity';

  @override
  String get searchFilterMatchTypeSection => 'Match type';

  @override
  String get searchTagsFilterHelper =>
      'Space- or comma-separated. Each tag is required.';

  @override
  String get searchSortBy => 'Sort by';

  @override
  String get searchStatusOpen => 'Open';

  @override
  String get searchStatusArchived => 'Archived';

  @override
  String get searchStatusNoReplies => 'No replies';

  @override
  String get searchStatusPublicOnly => 'Public only';

  @override
  String get searchStatusUnsolved => 'Unsolved';

  @override
  String get searchInBookmarked => 'I bookmarked';

  @override
  String get searchInMyMessages => 'In my messages';

  @override
  String get searchInLiked => 'I liked';

  @override
  String get searchInPosted => 'I posted in';

  @override
  String get searchInWatching => 'I\'m watching';

  @override
  String get searchInTracking => 'I\'m tracking';

  @override
  String get searchInSeen => 'I read';

  @override
  String get searchInUnseen => 'I\'ve not read';

  @override
  String get searchSortLatestPost => 'Latest post';

  @override
  String get searchSortMostLiked => 'Most liked';

  @override
  String get searchSortMostViewed => 'Most viewed';

  @override
  String get searchSortLatestTopic => 'Latest topic';

  @override
  String get searchFieldHint => 'Search...';

  @override
  String get postLikeAction => 'Like post';

  @override
  String get postUnlikeAction => 'Unlike post';
}
