import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'kit_localizations_de.dart';
import 'kit_localizations_en.dart';
import 'kit_localizations_es.dart';
import 'kit_localizations_fr.dart';
import 'kit_localizations_it.dart';
import 'kit_localizations_ja.dart';
import 'kit_localizations_ko.dart';
import 'kit_localizations_nl.dart';
import 'kit_localizations_pt.dart';
import 'kit_localizations_ru.dart';
import 'kit_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of KitLocalizations
/// returned by `KitLocalizations.of(context)`.
///
/// Applications need to include `KitLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/kit_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: KitLocalizations.localizationsDelegates,
///   supportedLocales: KitLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the KitLocalizations.supportedLocales
/// property.
abstract class KitLocalizations {
  KitLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static KitLocalizations? of(BuildContext context) {
    return Localizations.of<KitLocalizations>(context, KitLocalizations);
  }

  static const LocalizationsDelegate<KitLocalizations> delegate =
      _KitLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh')
  ];

  /// No description provided for @okButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// Settings section title for language selection
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @pleaseSpecifyReason.
  ///
  /// In en, this message translates to:
  /// **'Please specify the reason'**
  String get pleaseSpecifyReason;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @temporary.
  ///
  /// In en, this message translates to:
  /// **'Temporary'**
  String get temporary;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(String error);

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @italic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get italic;

  /// No description provided for @link.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get link;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @quote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get quote;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// Participants count with label
  ///
  /// In en, this message translates to:
  /// **'Participants ({count})'**
  String participants(int count);

  /// Menu item to refresh content
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Menu item to share content
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Button to reply to a post or message
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Notifications tab title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Button text to edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Button text to remove
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Label for message field
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// Error message when opening link fails
  ///
  /// In en, this message translates to:
  /// **'Could not open link: {error}'**
  String couldNotOpenLink(String error);

  /// Divider between posts far apart in time
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day later} other{{count} days later}}'**
  String timeGapDaysLater(int count);

  /// Divider between posts far apart in time
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month later} other{{count} months later}}'**
  String timeGapMonthsLater(int count);

  /// Divider between posts far apart in time
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year later} other{{count} years later}}'**
  String timeGapYearsLater(int count);

  /// UI text: Apply
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// UI text: Bookmarks
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// UI text: Copy
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// UI text: First posts only
  ///
  /// In en, this message translates to:
  /// **'First posts only'**
  String get firstPostsOnly;

  /// UI text: Relevance
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get relevance;

  /// UI text: Reset
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// UI text: Title only
  ///
  /// In en, this message translates to:
  /// **'Title only'**
  String get titleOnly;

  /// UI text: Solved
  ///
  /// In en, this message translates to:
  /// **'Solved'**
  String get solved;

  /// UI text: Open
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// UI text: N participants
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 participant} other{{count} participants}}'**
  String participantCount(int count);

  /// Title of the notice shown when a new post is held for moderator approval (Discourse review.approval.title).
  ///
  /// In en, this message translates to:
  /// **'Post Needs Approval'**
  String get postNeedsApprovalTitle;

  /// Body of that notice (Discourse review.approval.description).
  ///
  /// In en, this message translates to:
  /// **'We\'ve received your new post but it needs to be approved by a moderator before it will appear. Please be patient.'**
  String get postNeedsApprovalBody;

  /// UI text: Tap to open
  ///
  /// In en, this message translates to:
  /// **'Tap to open'**
  String get tapToOpen;

  /// UI text: Image not available
  ///
  /// In en, this message translates to:
  /// **'Image not available'**
  String get imageNotAvailable;

  /// UI text: Search filters
  ///
  /// In en, this message translates to:
  /// **'Search filters'**
  String get searchFilters;

  /// Drawer: Tags
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// Label under the view count in the summary under a topic's first post; the number is shown above it, not in the string
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{view} other{views}}'**
  String topicMapViews(int count);

  /// Label under the like count in the summary under a topic's first post; the number is shown above it
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{like} other{likes}}'**
  String topicMapLikes(int count);

  /// Label under the link count in the summary under a topic's first post; the number is shown above it
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{link} other{links}}'**
  String topicMapLinks(int count);

  /// Label under the participant count in the summary under a topic's first post; the number is shown above it
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{user} other{users}}'**
  String topicMapUsers(int count);

  /// Birthday dialog: day of the month
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// Birthday dialog: month
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// Status sheet: the emoji button, and the emoji picker's title
  ///
  /// In en, this message translates to:
  /// **'Choose emoji'**
  String get chooseEmoji;

  /// Emoji picker: search field
  ///
  /// In en, this message translates to:
  /// **'Search emoji'**
  String get searchEmoji;

  /// Staff suspending a user from their profile, in Discourse's admin wording (admin.user.suspend*)
  ///
  /// In en, this message translates to:
  /// **'Suspend User'**
  String get suspendUser;

  /// Staff suspending a user from their profile, in Discourse's admin wording (admin.user.suspend*)
  ///
  /// In en, this message translates to:
  /// **'Suspend user until'**
  String get suspendUntil;

  /// Staff suspending a user from their profile, in Discourse's admin wording (admin.user.suspend*)
  ///
  /// In en, this message translates to:
  /// **'Suspend forever'**
  String get suspendForever;

  /// Staff suspending a user from their profile, in Discourse's admin wording (admin.user.suspend*)
  ///
  /// In en, this message translates to:
  /// **'Would not listen to staff feedback'**
  String get suspendReasonNotListening;

  /// Staff suspending a user from their profile, in Discourse's admin wording (admin.user.suspend*)
  ///
  /// In en, this message translates to:
  /// **'Consumed disproportionate amounts of staff time'**
  String get suspendReasonStaffTime;

  /// Staff suspending a user from their profile, in Discourse's admin wording (admin.user.suspend*)
  ///
  /// In en, this message translates to:
  /// **'Too combative'**
  String get suspendReasonCombative;

  /// Staff suspending a user from their profile, in Discourse's admin wording (admin.user.suspend*)
  ///
  /// In en, this message translates to:
  /// **'In the wrong place'**
  String get suspendReasonWrongPlace;

  /// Staff suspending a user from their profile, in Discourse's admin wording (admin.user.suspend*)
  ///
  /// In en, this message translates to:
  /// **'No constructive purpose to their actions other than creating dissent within the community'**
  String get suspendReasonNoPurpose;

  /// Staff suspending a user from their profile, in Discourse's admin wording (admin.user.suspend*)
  ///
  /// In en, this message translates to:
  /// **'Custom…'**
  String get suspendReasonCustom;

  /// Staff suspending a user from their profile, in Discourse's admin wording (admin.user.suspend*)
  ///
  /// In en, this message translates to:
  /// **'Why are you suspending? This text will be shown to the user when they try to log in. Keep it short.'**
  String get suspendReasonQuestion;

  /// Badge on a closed topic in topic lists
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closedLabel;

  /// Staff suspending a user from their profile, in Discourse's admin wording (admin.user.suspend*)
  ///
  /// In en, this message translates to:
  /// **'Choose when the suspension ends'**
  String get pleaseSelectSuspensionEndDate;

  /// Notifications tab app bar: tooltip of the button that marks every notification read (Discourse js.user.dismiss_notifications)
  ///
  /// In en, this message translates to:
  /// **'Dismiss all'**
  String get dismissAllNotifications;

  /// Search filters sheet: heading over the topic status chips
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get searchFilterStatusSection;

  /// Search filters sheet: heading over the chips about the reader's own activity
  ///
  /// In en, this message translates to:
  /// **'My activity'**
  String get searchFilterMyActivitySection;

  /// Search filters sheet: heading over the Title only / First posts only chips
  ///
  /// In en, this message translates to:
  /// **'Match type'**
  String get searchFilterMatchTypeSection;

  /// Search filters sheet: help under the tags field
  ///
  /// In en, this message translates to:
  /// **'Space- or comma-separated. Each tag is required.'**
  String get searchTagsFilterHelper;

  /// Search filters sheet: heading over the sort chips (Discourse js.search.sort_by)
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get searchSortBy;

  /// Search filters sheet: status chip, topics that are open
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get searchStatusOpen;

  /// Search filters sheet: status chip, topics that are archived
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get searchStatusArchived;

  /// Search filters sheet: status chip, topics with zero replies
  ///
  /// In en, this message translates to:
  /// **'No replies'**
  String get searchStatusNoReplies;

  /// Search filters sheet: status chip, only public topics
  ///
  /// In en, this message translates to:
  /// **'Public only'**
  String get searchStatusPublicOnly;

  /// Search filters sheet: status chip, topics without a solution (discourse-solved topic_status_filter.unsolved)
  ///
  /// In en, this message translates to:
  /// **'Unsolved'**
  String get searchStatusUnsolved;

  /// Search filters sheet: 'My activity' chip (Discourse js.search.advanced.filters.bookmarks)
  ///
  /// In en, this message translates to:
  /// **'I bookmarked'**
  String get searchInBookmarked;

  /// Search filters sheet: 'My activity' chip (Discourse js.search.advanced.filters.private)
  ///
  /// In en, this message translates to:
  /// **'In my messages'**
  String get searchInMyMessages;

  /// Search filters sheet: 'My activity' chip (Discourse js.search.advanced.filters.likes)
  ///
  /// In en, this message translates to:
  /// **'I liked'**
  String get searchInLiked;

  /// Search filters sheet: 'My activity' chip (Discourse js.search.advanced.filters.posted)
  ///
  /// In en, this message translates to:
  /// **'I posted in'**
  String get searchInPosted;

  /// Search filters sheet: 'My activity' chip (Discourse js.search.advanced.filters.watching)
  ///
  /// In en, this message translates to:
  /// **'I\'m watching'**
  String get searchInWatching;

  /// Search filters sheet: 'My activity' chip (Discourse js.search.advanced.filters.tracking)
  ///
  /// In en, this message translates to:
  /// **'I\'m tracking'**
  String get searchInTracking;

  /// Search filters sheet: 'My activity' chip (Discourse js.search.advanced.filters.seen)
  ///
  /// In en, this message translates to:
  /// **'I read'**
  String get searchInSeen;

  /// Search filters sheet: 'My activity' chip (Discourse js.search.advanced.filters.unseen)
  ///
  /// In en, this message translates to:
  /// **'I\'ve not read'**
  String get searchInUnseen;

  /// Search filters sheet: sort chip (Discourse js.search.latest_post)
  ///
  /// In en, this message translates to:
  /// **'Latest post'**
  String get searchSortLatestPost;

  /// Search filters sheet: sort chip (Discourse js.search.most_liked)
  ///
  /// In en, this message translates to:
  /// **'Most liked'**
  String get searchSortMostLiked;

  /// Search filters sheet: sort chip (Discourse js.search.most_viewed)
  ///
  /// In en, this message translates to:
  /// **'Most viewed'**
  String get searchSortMostViewed;

  /// Search filters sheet: sort chip (Discourse js.search.latest_topic)
  ///
  /// In en, this message translates to:
  /// **'Latest topic'**
  String get searchSortLatestTopic;

  /// Default placeholder of the app's search fields (Discourse js.multi_select.search)
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchFieldHint;

  /// Screen-reader label of a post's like (heart) button when the reader has not liked it
  ///
  /// In en, this message translates to:
  /// **'Like post'**
  String get postLikeAction;

  /// Screen-reader label of a post's like (heart) button when the reader has liked it
  ///
  /// In en, this message translates to:
  /// **'Unlike post'**
  String get postUnlikeAction;
}

class _KitLocalizationsDelegate
    extends LocalizationsDelegate<KitLocalizations> {
  const _KitLocalizationsDelegate();

  @override
  Future<KitLocalizations> load(Locale locale) {
    return SynchronousFuture<KitLocalizations>(lookupKitLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'it',
        'ja',
        'ko',
        'nl',
        'pt',
        'ru',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_KitLocalizationsDelegate old) => false;
}

KitLocalizations lookupKitLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return KitLocalizationsDe();
    case 'en':
      return KitLocalizationsEn();
    case 'es':
      return KitLocalizationsEs();
    case 'fr':
      return KitLocalizationsFr();
    case 'it':
      return KitLocalizationsIt();
    case 'ja':
      return KitLocalizationsJa();
    case 'ko':
      return KitLocalizationsKo();
    case 'nl':
      return KitLocalizationsNl();
    case 'pt':
      return KitLocalizationsPt();
    case 'ru':
      return KitLocalizationsRu();
    case 'zh':
      return KitLocalizationsZh();
  }

  throw FlutterError(
      'KitLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
