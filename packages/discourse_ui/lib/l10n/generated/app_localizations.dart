import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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

  /// An account-specific screen no longer belongs to the current sign-in; disable its stale controls.
  ///
  /// In en, this message translates to:
  /// **'Your sign-in changed. Reopen this screen to continue.'**
  String get accountSessionChanged;

  /// A draft operation belongs to an earlier sign-in; preserve the editor text and explain how to recover it.
  ///
  /// In en, this message translates to:
  /// **'Your sign-in changed. Copy your text before reopening the composer to work with drafts.'**
  String get draftSessionChanged;

  /// An attachment upload overlapped a logout or credential change; its result cannot be used in the current session.
  ///
  /// In en, this message translates to:
  /// **'Your sign-in changed during the upload. Reopen this screen before trying again.'**
  String get uploadSessionChanged;

  /// A successful post HTTP response lacked a usable ID; keep the editor and caution against duplicate submissions.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm that this was sent. Your text has been kept. Check the forum before trying again.'**
  String get submissionUnconfirmed;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @usePasskey.
  ///
  /// In en, this message translates to:
  /// **'Use Passkey'**
  String get usePasskey;

  /// No description provided for @passkeyContinuePrompt.
  ///
  /// In en, this message translates to:
  /// **'Use your passkey to continue'**
  String get passkeyContinuePrompt;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @okButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @copyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to Clipboard'**
  String get copyToClipboard;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @errorMessageCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Error message copied to clipboard'**
  String get errorMessageCopiedToClipboard;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

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

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @accountPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Your account is pending approval. You can browse the forum but cannot post until a moderator approves your account.'**
  String get accountPendingApproval;

  /// No description provided for @checkEmailToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Please check your email to confirm your account. Click the confirmation link in the email we sent you.'**
  String get checkEmailToConfirm;

  /// No description provided for @checkNewEmailToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Please check your new email address to confirm the change. Your old email will remain active until you confirm the new one.'**
  String get checkNewEmailToConfirm;

  /// No description provided for @emailAddressInvalid.
  ///
  /// In en, this message translates to:
  /// **'Your email address appears to be invalid or is bouncing emails. Please update your email address in account settings.'**
  String get emailAddressInvalid;

  /// No description provided for @accountDisabled.
  ///
  /// In en, this message translates to:
  /// **'Your account has been disabled. Please contact an administrator for assistance.'**
  String get accountDisabled;

  /// No description provided for @accountRegistrationRejected.
  ///
  /// In en, this message translates to:
  /// **'Your account registration was rejected. Please contact an administrator for more information.'**
  String get accountRegistrationRejected;

  /// No description provided for @welcomeToForumCopilot.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Forum Copilot!'**
  String get welcomeToForumCopilot;

  /// No description provided for @successfullyLoggedOut.
  ///
  /// In en, this message translates to:
  /// **'You have been successfully logged out'**
  String get successfullyLoggedOut;

  /// No description provided for @accountStatusRequiresAttention.
  ///
  /// In en, this message translates to:
  /// **'Your account status requires attention. Please contact an administrator if you have questions.'**
  String get accountStatusRequiresAttention;

  /// No description provided for @updateEmail.
  ///
  /// In en, this message translates to:
  /// **'Update Email'**
  String get updateEmail;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @noLatestTopics.
  ///
  /// In en, this message translates to:
  /// **'No Latest Topics'**
  String get noLatestTopics;

  /// No description provided for @noRecentTopicsToDisplay.
  ///
  /// In en, this message translates to:
  /// **'There are no recent topics to display. Check back later for new discussions.'**
  String get noRecentTopicsToDisplay;

  /// No description provided for @signInToViewLatestTopics.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view latest topics'**
  String get signInToViewLatestTopics;

  /// No description provided for @youNeedToBeSignedInToViewLatestTopics.
  ///
  /// In en, this message translates to:
  /// **'You need to be signed in to view latest topics.'**
  String get youNeedToBeSignedInToViewLatestTopics;

  /// No description provided for @thereAreNoUnreadTopics.
  ///
  /// In en, this message translates to:
  /// **'There are no unread topics. Check back later for new discussions.'**
  String get thereAreNoUnreadTopics;

  /// No description provided for @youAreAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get youAreAllCaughtUp;

  /// No description provided for @signInToViewUnreadTopics.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view unread topics'**
  String get signInToViewUnreadTopics;

  /// No description provided for @youNeedToBeSignedInToViewUnreadTopics.
  ///
  /// In en, this message translates to:
  /// **'You need to be signed in to view your unread topics.'**
  String get youNeedToBeSignedInToViewUnreadTopics;

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @failedToConnectToSite.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to site. The site may be down or unreachable.'**
  String get failedToConnectToSite;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection Failed'**
  String get connectionFailed;

  /// Error message when failed to connect to a site
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to {siteName}'**
  String failedToConnectToSiteName(String siteName);

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @newConversation.
  ///
  /// In en, this message translates to:
  /// **'New Message'**
  String get newConversation;

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

  /// No description provided for @topicsOnly.
  ///
  /// In en, this message translates to:
  /// **'Topics Only'**
  String get topicsOnly;

  /// No description provided for @titlesOnly.
  ///
  /// In en, this message translates to:
  /// **'Titles Only'**
  String get titlesOnly;

  /// Error message when sharing topic fails
  ///
  /// In en, this message translates to:
  /// **'Failed to share topic: {error}'**
  String failedToShareTopic(String error);

  /// No description provided for @youCannotReplyToThisThread.
  ///
  /// In en, this message translates to:
  /// **'You cannot reply to this topic'**
  String get youCannotReplyToThisThread;

  /// No description provided for @pleaseWaitForThreadToLoad.
  ///
  /// In en, this message translates to:
  /// **'Please wait for the topic to load'**
  String get pleaseWaitForThreadToLoad;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// Label for participants (without count)
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participantsLabel;

  /// Message when user is invited to conversation
  ///
  /// In en, this message translates to:
  /// **'{username} has been invited to the message'**
  String usernameHasBeenInvited(String username);

  /// Error message when inviting user fails
  ///
  /// In en, this message translates to:
  /// **'Error inviting user: {error}'**
  String errorInvitingUser(String error);

  /// No description provided for @newTopic.
  ///
  /// In en, this message translates to:
  /// **'New Topic'**
  String get newTopic;

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

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @topicClosed.
  ///
  /// In en, this message translates to:
  /// **'Topic closed'**
  String get topicClosed;

  /// No description provided for @topicOpened.
  ///
  /// In en, this message translates to:
  /// **'Topic opened'**
  String get topicOpened;

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any messages'**
  String get noConversations;

  /// No description provided for @noConversationsMessage.
  ///
  /// In en, this message translates to:
  /// **'You have no messages yet. Start a new message to begin.'**
  String get noConversationsMessage;

  /// No description provided for @imageSavedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Image saved to gallery!'**
  String get imageSavedToGallery;

  /// Error message when saving image fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save image: {error}'**
  String failedToSaveImage(String error);

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  /// No description provided for @deletePost.
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get deletePost;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get loginRequired;

  /// Button to send a message to a user
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get sendMessage;

  /// No description provided for @likesReceived.
  ///
  /// In en, this message translates to:
  /// **'Likes Received'**
  String get likesReceived;

  /// Button to show more content
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// Error message when saving conversation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save message'**
  String get failedToSaveConversation;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// Number of members with label
  ///
  /// In en, this message translates to:
  /// **'{count} Members'**
  String membersCount(int count);

  /// No description provided for @noSubject.
  ///
  /// In en, this message translates to:
  /// **'No subject'**
  String get noSubject;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @areYouSureYouWantToLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureYouWantToLogout;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @notificationTest.
  ///
  /// In en, this message translates to:
  /// **'Notification Test'**
  String get notificationTest;

  /// No description provided for @forum.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get forum;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

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

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete Message'**
  String get deleteMessage;

  /// No description provided for @deletingPost.
  ///
  /// In en, this message translates to:
  /// **'Deleting post...'**
  String get deletingPost;

  /// Error message when unliking post fails
  ///
  /// In en, this message translates to:
  /// **'Failed to unlike post: {error}'**
  String failedToUnlikePost(String error);

  /// Error message when liking post fails
  ///
  /// In en, this message translates to:
  /// **'Failed to like post: {error}'**
  String failedToLikePost(String error);

  /// Message asking user to sign in to view messages
  ///
  /// In en, this message translates to:
  /// **'Sign in to view messages'**
  String get signInToViewMessages;

  /// No description provided for @youNeedToBeSignedInToViewConversations.
  ///
  /// In en, this message translates to:
  /// **'You need to be signed in to view your messages.'**
  String get youNeedToBeSignedInToViewConversations;

  /// Error message when leaving conversation fails
  ///
  /// In en, this message translates to:
  /// **'Could not leave the message: {error}'**
  String failedToLeaveConversation(String error);

  /// Error message when loading more conversations fails
  ///
  /// In en, this message translates to:
  /// **'Error loading more messages: {error}'**
  String errorLoadingMoreConversations(String error);

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed'**
  String get searchFailed;

  /// No description provided for @userInformationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'User information not available'**
  String get userInformationNotAvailable;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @posts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get posts;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @temporary.
  ///
  /// In en, this message translates to:
  /// **'Temporary'**
  String get temporary;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(String error);

  /// No description provided for @removeAttachment.
  ///
  /// In en, this message translates to:
  /// **'Remove Attachment'**
  String get removeAttachment;

  /// No description provided for @areYouSureYouWantToRemoveThisAttachment.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this attachment?'**
  String get areYouSureYouWantToRemoveThisAttachment;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// Accessibility label for attach file button
  ///
  /// In en, this message translates to:
  /// **'Attach file'**
  String get attachFile;

  /// Accessibility label for upload image button
  ///
  /// In en, this message translates to:
  /// **'Upload image'**
  String get uploadImage;

  /// No description provided for @formatting.
  ///
  /// In en, this message translates to:
  /// **'Formatting'**
  String get formatting;

  /// No description provided for @bold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get bold;

  /// No description provided for @italic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get italic;

  /// No description provided for @underline.
  ///
  /// In en, this message translates to:
  /// **'Underline'**
  String get underline;

  /// No description provided for @strikethrough.
  ///
  /// In en, this message translates to:
  /// **'Strikethrough'**
  String get strikethrough;

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

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

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

  /// No description provided for @spoiler.
  ///
  /// In en, this message translates to:
  /// **'Spoiler'**
  String get spoiler;

  /// No description provided for @bulletList.
  ///
  /// In en, this message translates to:
  /// **'Bullet List'**
  String get bulletList;

  /// No description provided for @numberedList.
  ///
  /// In en, this message translates to:
  /// **'Numbered List'**
  String get numberedList;

  /// No description provided for @listItem.
  ///
  /// In en, this message translates to:
  /// **'List Item'**
  String get listItem;

  /// Participants count with label
  ///
  /// In en, this message translates to:
  /// **'Participants ({count})'**
  String participants(int count);

  /// No description provided for @markAsUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark unread'**
  String get markAsUnread;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @enterKeywordsToSearchTopics.
  ///
  /// In en, this message translates to:
  /// **'Enter keywords to search topics...'**
  String get enterKeywordsToSearchTopics;

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

  /// Menu item to view content on web browser
  ///
  /// In en, this message translates to:
  /// **'View on Web'**
  String get viewOnWeb;

  /// Button to reply to a post or message
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// Button to submit poll vote
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get vote;

  /// Poll footer showing total vote count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} vote} other{{count} votes}}'**
  String votesCount(int count);

  /// Poll footer when poll is closed
  ///
  /// In en, this message translates to:
  /// **'Poll closed'**
  String get pollClosed;

  /// Poll footer showing close date
  ///
  /// In en, this message translates to:
  /// **'Ends {date}'**
  String pollEndsOn(String date);

  /// Hint when results are hidden until user votes
  ///
  /// In en, this message translates to:
  /// **'Vote to see results'**
  String get voteToSeeResults;

  /// Mini poll bar: tap to scroll to first post and see full poll
  ///
  /// In en, this message translates to:
  /// **'View full poll'**
  String get viewFullPoll;

  /// Mini poll bar subtitle when no votes yet
  ///
  /// In en, this message translates to:
  /// **'{count} options'**
  String pollOptionsCount(int count);

  /// Label showing who reacted to a post or message
  ///
  /// In en, this message translates to:
  /// **'Reacted by'**
  String get reactedBy;

  /// Hint text for searching topics and posts
  ///
  /// In en, this message translates to:
  /// **'Enter keywords to find topics and posts'**
  String get enterKeywordsToFindTopicsAndPosts;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Drawer row and sheet title for choosing light, dark or the device's setting
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Appearance option that follows the device's light/dark setting
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get appearanceSystem;

  /// App version display
  ///
  /// In en, this message translates to:
  /// **'version {version} ({buildNumber})'**
  String version(String version, String buildNumber);

  /// Error message when profile cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Unable to Load Profile'**
  String get unableToLoadProfile;

  /// Badge text for banned users
  ///
  /// In en, this message translates to:
  /// **'BANNED'**
  String get banned;

  /// Title for delete topic dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Topic'**
  String get deleteTopic;

  /// Home tab title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Notifications tab title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Categories tab title (Discourse-native term; the ARB key keeps the legacy 'forums' name for compatibility)
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get forums;

  /// Content label for message compose
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// Validation message when title is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get pleaseEnterTitle;

  /// Validation message when content is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter some content'**
  String get pleaseEnterContent;

  /// Status message when uploading file
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// Status message when file is uploaded
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// Tooltip for mention user button
  ///
  /// In en, this message translates to:
  /// **'Mention User'**
  String get mentionUser;

  /// Hint text for writing message
  ///
  /// In en, this message translates to:
  /// **'Write your message...'**
  String get writeYourMessage;

  /// Hint text for writing reply
  ///
  /// In en, this message translates to:
  /// **'Write your reply...'**
  String get writeYourReply;

  /// Success message when marking conversation as unread
  ///
  /// In en, this message translates to:
  /// **'Message marked as unread'**
  String get conversationMarkedAsUnread;

  /// Success message when closing conversation
  ///
  /// In en, this message translates to:
  /// **'Message closed'**
  String get conversationClosed;

  /// Success message when opening conversation
  ///
  /// In en, this message translates to:
  /// **'Message opened'**
  String get conversationOpened;

  /// Error message when loading quote fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load quote: \n{error}'**
  String failedToLoadQuote(String error);

  /// Error message when marking conversation as unread fails
  ///
  /// In en, this message translates to:
  /// **'Failed to mark message as unread: {error}'**
  String failedToMarkConversationAsUnread(String error);

  /// Error message when closing conversation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to close message: {error}'**
  String failedToCloseConversation(String error);

  /// Error message when opening conversation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to open message: {error}'**
  String failedToOpenConversation(String error);

  /// Tooltip for go to top button
  ///
  /// In en, this message translates to:
  /// **'Go to top'**
  String get goToTop;

  /// Tooltip for go to bottom button
  ///
  /// In en, this message translates to:
  /// **'Go to bottom'**
  String get goToBottom;

  /// Message asking user to login to access content
  ///
  /// In en, this message translates to:
  /// **'Please login to access this content and interact with posts.'**
  String get pleaseLoginToAccessContent;

  /// Hint text for searching users
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get searchUsers;

  /// Hint text for conversation title field
  ///
  /// In en, this message translates to:
  /// **'Enter message title'**
  String get enterConversationTitle;

  /// Hint text for code input field
  ///
  /// In en, this message translates to:
  /// **'Enter {count}-digit code'**
  String enterCode(int count);

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

  /// Label for subject field
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// Label for message field
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// Validation message when title is empty
  ///
  /// In en, this message translates to:
  /// **'Title cannot be empty'**
  String get titleCannotBeEmpty;

  /// Success message when conversation is updated
  ///
  /// In en, this message translates to:
  /// **'Message updated'**
  String get conversationUpdatedSuccessfully;

  /// Button text to go back
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// Action verb: like
  ///
  /// In en, this message translates to:
  /// **'like'**
  String get like;

  /// Button tooltip: download a file from a post or chat message and open it (Discourse lightbox.download)
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// Status message when downloading file
  ///
  /// In en, this message translates to:
  /// **'Downloading {filename}...'**
  String downloading(String filename);

  /// Status message when opening share sheet
  ///
  /// In en, this message translates to:
  /// **'Opening share sheet for {filename}'**
  String openingShareSheet(String filename);

  /// Error message when downloading file fails
  ///
  /// In en, this message translates to:
  /// **'Error downloading {filename}: {error}'**
  String errorDownloading(String filename, String error);

  /// Error message when opening link fails
  ///
  /// In en, this message translates to:
  /// **'Could not open link: {error}'**
  String couldNotOpenLink(String error);

  /// Loading indicator while translating
  ///
  /// In en, this message translates to:
  /// **'Translating...'**
  String get translating;

  /// Badge shown on translated content
  ///
  /// In en, this message translates to:
  /// **'Translated'**
  String get translated;

  /// Label for translated content
  ///
  /// In en, this message translates to:
  /// **'Translated content'**
  String get translatedContent;

  /// Title for the two-factor auth dialog
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuthentication;

  /// Label for the auth code input field
  ///
  /// In en, this message translates to:
  /// **'Authentication Code'**
  String get authenticationCodeLabel;

  /// Validation message when auth code is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your authentication code'**
  String get pleaseEnterYourAuthenticationCode;

  /// Validation message when code does not match required digits
  ///
  /// In en, this message translates to:
  /// **'Code must be {count} digits'**
  String codeMustBeDigits(int count);

  /// Validation message when code has non-digit characters
  ///
  /// In en, this message translates to:
  /// **'Code must contain only numbers'**
  String get codeMustContainOnlyNumbers;

  /// Verify action label on the TFA dialog
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButton;

  /// Attachments label
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// Title for the reply options menu
  ///
  /// In en, this message translates to:
  /// **'Reply Options'**
  String get replyOptions;

  /// Reply-with-quote action label
  ///
  /// In en, this message translates to:
  /// **'Reply with Quote'**
  String get replyWithQuote;

  /// Success message when file is saved to Downloads
  ///
  /// In en, this message translates to:
  /// **'File saved to Downloads: {filename}'**
  String fileSavedToDownloads(String filename);

  /// Success message when file is saved to Documents
  ///
  /// In en, this message translates to:
  /// **'File saved to Documents: {filename}'**
  String fileSavedToDocuments(String filename);

  /// Last-reply attribution on a topic row, e.g. 'alice replied 3 hours ago'
  ///
  /// In en, this message translates to:
  /// **'{username} replied {time}'**
  String topicLastReplyBy(String username, String time);

  /// Threading indicator above a post that replies to another post
  ///
  /// In en, this message translates to:
  /// **'in reply to {username}'**
  String inReplyToUser(String username);

  /// Threading indicator when the replied-to author is not named
  ///
  /// In en, this message translates to:
  /// **'in reply to post #{number}'**
  String inReplyToPost(int number);

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

  /// Profile header stat: how many times the profile was viewed
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get profileViews;

  /// Profile header stat: number of badges held
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges;

  /// Button opening a chat with the profile owner
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatWithUser;

  /// Disclosure under a post listing its direct replies
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reply} other{{count} replies}}'**
  String nReplies(int count);

  /// UI text: Chat
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// UI text: +{count} more
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String moreBadges(Object count);

  /// UI text: All notifications marked as read
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allNotificationsMarkedAsRead;

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

  /// UI text: By {username}
  ///
  /// In en, this message translates to:
  /// **'By {username}'**
  String reviewableBy(String username);

  /// UI text: Change email
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmail;

  /// UI text: Change password
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// UI text: Checking status…
  ///
  /// In en, this message translates to:
  /// **'Checking status…'**
  String get checkingStatus;

  /// UI text: Clear reminder
  ///
  /// In en, this message translates to:
  /// **'Clear reminder'**
  String get clearReminder;

  /// UI text: Copy
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// UI text: Copy link
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// UI text: Could not enable notifications: {error}
  ///
  /// In en, this message translates to:
  /// **'Could not enable notifications: {error}'**
  String couldNotEnableNotifications(String error);

  /// UI text: Could not find this bookmark
  ///
  /// In en, this message translates to:
  /// **'Could not find this bookmark'**
  String get couldNotFindBookmark;

  /// UI text: Could not open email: {email}
  ///
  /// In en, this message translates to:
  /// **'Could not open email: {email}'**
  String couldNotOpenEmail(String email);

  /// UI text: Could not start sign-in: {error}
  ///
  /// In en, this message translates to:
  /// **'Could not start sign-in: {error}'**
  String couldNotStartSignIn(String error);

  /// UI text: Custom date & time
  ///
  /// In en, this message translates to:
  /// **'Custom date & time'**
  String get customDateAndTime;

  /// UI text: Delete account
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// UI text: Delete message?
  ///
  /// In en, this message translates to:
  /// **'Delete message?'**
  String get deleteMessageQuestion;

  /// UI text: Discard
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// UI text: Do not disturb
  ///
  /// In en, this message translates to:
  /// **'Do not disturb'**
  String get doNotDisturb;

  /// UI text: Edit history
  ///
  /// In en, this message translates to:
  /// **'Edit history'**
  String get editHistory;

  /// UI text: Edit profile
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// UI text: Edit reminder
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get editReminder;

  /// UI text: Email copied to clipboard: {email}
  ///
  /// In en, this message translates to:
  /// **'Email copied to clipboard: {email}'**
  String emailCopiedToClipboard(String email);

  /// UI text: Enabled for this login
  ///
  /// In en, this message translates to:
  /// **'Enabled for this login'**
  String get pushEnabledForThisLogin;

  /// UI text: Failed to load more topics. Scroll to retry.
  ///
  /// In en, this message translates to:
  /// **'Failed to load more topics. Scroll to retry.'**
  String get failedToLoadMoreTopics;

  /// UI text: Failed to update notification level
  ///
  /// In en, this message translates to:
  /// **'Failed to update notification level'**
  String get failedToUpdateNotificationLevel;

  /// UI text: First posts only
  ///
  /// In en, this message translates to:
  /// **'First posts only'**
  String get firstPostsOnly;

  /// UI text: Ignored users
  ///
  /// In en, this message translates to:
  /// **'Ignored users'**
  String get ignoredUsers;

  /// UI text: In two hours
  ///
  /// In en, this message translates to:
  /// **'In two hours'**
  String get inTwoHours;

  /// UI text: Invite by email
  ///
  /// In en, this message translates to:
  /// **'Invite by email'**
  String get inviteByEmail;

  /// UI text: Invite link copied
  ///
  /// In en, this message translates to:
  /// **'Invite link copied'**
  String get inviteLinkCopied;

  /// UI text: Invite sent to {email}
  ///
  /// In en, this message translates to:
  /// **'Invite sent to {email}'**
  String inviteSentTo(String email);

  /// UI text: Leave
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// UI text: Leave group
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get leaveGroup;

  /// UI text: Leave group?
  ///
  /// In en, this message translates to:
  /// **'Leave group?'**
  String get leaveGroupQuestion;

  /// UI text: Link copied
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// UI text: Load more
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// UI text: Manage account on web
  ///
  /// In en, this message translates to:
  /// **'Manage account on web'**
  String get manageAccountOnWeb;

  /// UI text: Merge
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get merge;

  /// UI text: Merge into topic
  ///
  /// In en, this message translates to:
  /// **'Merge into topic'**
  String get mergeIntoTopic;

  /// UI text: New invite link
  ///
  /// In en, this message translates to:
  /// **'New invite link'**
  String get newInviteLink;

  /// UI text: Next week
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get nextWeek;

  /// UI text: Not available in this build
  ///
  /// In en, this message translates to:
  /// **'Not available in this build'**
  String get pushNotAvailableInThisBuild;

  /// UI text: Not now
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// UI text: Notification level for "{tag}" updated
  ///
  /// In en, this message translates to:
  /// **'Notification level for \"{tag}\" updated'**
  String tagNotificationLevelUpdated(String tag);

  /// UI text: On until {until}
  ///
  /// In en, this message translates to:
  /// **'On until {until}'**
  String doNotDisturbOnUntil(String until);

  /// UI text: Please log in to bookmark
  ///
  /// In en, this message translates to:
  /// **'Please log in to bookmark'**
  String get pleaseLogInToBookmark;

  /// UI text: Please log in to follow users
  ///
  /// In en, this message translates to:
  /// **'Please log in to follow users'**
  String get pleaseLogInToFollowUsers;

  /// UI text: Please log in to mark answers
  ///
  /// In en, this message translates to:
  /// **'Please log in to mark answers'**
  String get pleaseLogInToMarkAnswers;

  /// UI text: Please log in to react
  ///
  /// In en, this message translates to:
  /// **'Please log in to react'**
  String get pleaseLogInToReact;

  /// UI text: Please log in to vote
  ///
  /// In en, this message translates to:
  /// **'Please log in to vote'**
  String get pleaseLogInToVote;

  /// UI text: Push notifications
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// UI text: Relevance
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get relevance;

  /// UI text: Reminder time must be in the future
  ///
  /// In en, this message translates to:
  /// **'Reminder time must be in the future'**
  String get reminderTimeMustBeInFuture;

  /// UI text: Remove bookmark
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get removeBookmark;

  /// UI text: Remove vote
  ///
  /// In en, this message translates to:
  /// **'Remove vote'**
  String get removeVote;

  /// UI text: Rename topic
  ///
  /// In en, this message translates to:
  /// **'Rename topic'**
  String get renameTopic;

  /// UI text: Reported by {username}
  ///
  /// In en, this message translates to:
  /// **'Reported by {username}'**
  String reportedBy(String username);

  /// UI text: Request to join
  ///
  /// In en, this message translates to:
  /// **'Request to join'**
  String get requestToJoin;

  /// UI text: Request to join {group}
  ///
  /// In en, this message translates to:
  /// **'Request to join {group}'**
  String requestToJoinGroup(String group);

  /// UI text: Reset
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// UI text: Resize and upload
  ///
  /// In en, this message translates to:
  /// **'Resize and upload'**
  String get resizeAndUpload;

  /// Shown when a forum being opened did not answer at all (offline, or no response in time), under the failed-to-connect heading and above the Retry button.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get checkConnectionAndRetry;

  /// UI text: Review queue
  ///
  /// In en, this message translates to:
  /// **'Review queue'**
  String get reviewQueue;

  /// UI text: Revoke
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get revoke;

  /// UI text: Revoke invite?
  ///
  /// In en, this message translates to:
  /// **'Revoke invite?'**
  String get revokeInviteQuestion;

  /// UI text: Save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// UI text: Send invite
  ///
  /// In en, this message translates to:
  /// **'Send invite'**
  String get sendInvite;

  /// UI text: Send request
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendRequest;

  /// UI text: Settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// UI text: Show voters
  ///
  /// In en, this message translates to:
  /// **'Show voters'**
  String get showVoters;

  /// UI text: Sign out
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// UI text: Sign-in cancelled — no payload returned
  ///
  /// In en, this message translates to:
  /// **'Sign-in cancelled — no payload returned'**
  String get signInCancelledNoPayload;

  /// UI text: Sign-in failed: {error}
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed: {error}'**
  String signInFailed(String error);

  /// UI text: Start chat
  ///
  /// In en, this message translates to:
  /// **'Start chat'**
  String get startChat;

  /// UI text: Stopped ignoring @{username}
  ///
  /// In en, this message translates to:
  /// **'Stopped ignoring @{username}'**
  String stoppedIgnoringUser(String username);

  /// UI text: Title only
  ///
  /// In en, this message translates to:
  /// **'Title only'**
  String get titleOnly;

  /// UI text: Tomorrow
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// UI text: Turn off
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get turnOff;

  /// UI text: Turn on notifications
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications'**
  String get turnOnNotifications;

  /// UI text: Whisper
  ///
  /// In en, this message translates to:
  /// **'Whisper'**
  String get whisper;

  /// UI text: You can like this post again in {seconds}s
  ///
  /// In en, this message translates to:
  /// **'You can like this post again in {seconds}s'**
  String likeAgainInSeconds(Object seconds);

  /// UI text: Login Info
  ///
  /// In en, this message translates to:
  /// **'Login Info'**
  String get loginInfo;

  /// UI text: Login Failed
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// UI text: Move to category
  ///
  /// In en, this message translates to:
  /// **'Move to category'**
  String get moveToCategory;

  /// UI text: Undelete Topic
  ///
  /// In en, this message translates to:
  /// **'Un-Delete Topic'**
  String get undeleteTopic;

  /// UI text: Send
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// UI text: We’ll send a confirmation link to your new email. The change
  ///
  /// In en, this message translates to:
  /// **'We’ll send a confirmation link to your new email. The change takes effect when you click it.'**
  String get changeEmailExplanation;

  /// UI text: For added security, Discourse may require you to confirm via
  ///
  /// In en, this message translates to:
  /// **'For added security, Discourse may require you to confirm via the link in the email. Check your spam folder if you don’t see it.'**
  String get changeEmailSecurityNote;

  /// UI text: No messages yet — say hi.
  ///
  /// In en, this message translates to:
  /// **'No messages yet — say hi.'**
  String get noMessagesYetSayHi;

  /// UI text: edited
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get edited;

  /// UI text: push approved but relay unreachable
  ///
  /// In en, this message translates to:
  /// **'Approved, but we could not reach the notifications server to finish setting up. Try again later from Settings.'**
  String get approvedButRelayUnreachable;

  /// UI text: Notifications are turned off for this app
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for this app'**
  String get notificationsAreTurnedOffForThisApp;

  /// UI text: Please login to create a new topic
  ///
  /// In en, this message translates to:
  /// **'Please login to create a new topic'**
  String get pleaseLoginToCreateANewTopic;

  /// UI text: Please login to subscribe to forums
  ///
  /// In en, this message translates to:
  /// **'Please login to subscribe to forums'**
  String get pleaseLoginToSubscribeToForums;

  /// UI text: You will no longer be a member of {displayName}. You can rej
  ///
  /// In en, this message translates to:
  /// **'You will no longer be a member of {group}. You can rejoin at any time.'**
  String leaveGroupWarning(Object group);

  /// UI text: The member list of this group is private.
  ///
  /// In en, this message translates to:
  /// **'The member list of this group is private.'**
  String get groupMembersPrivate;

  /// UI text: Unignore
  ///
  /// In en, this message translates to:
  /// **'Unignore'**
  String get unignore;

  /// UI text: Invite link created
  ///
  /// In en, this message translates to:
  /// **'Invite link created'**
  String get inviteLinkCreated;

  /// UI text: Expires {toLocal}
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String expiresOn(Object date);

  /// UI text: Solution
  ///
  /// In en, this message translates to:
  /// **'Solution'**
  String get solution;

  /// UI text: DELETED
  ///
  /// In en, this message translates to:
  /// **'DELETED'**
  String get deleted;

  /// UI text: Please login to view user profiles.
  ///
  /// In en, this message translates to:
  /// **'Please login to view user profiles.'**
  String get pleaseLoginToViewUserProfiles;

  /// UI text: Solved
  ///
  /// In en, this message translates to:
  /// **'Solved'**
  String get solved;

  /// UI text: Hot
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get hot;

  /// UI text: Pinned
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinned;

  /// UI text: Locked
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// UI text: Poll
  ///
  /// In en, this message translates to:
  /// **'Poll'**
  String get poll;

  /// UI text: No discussions yet.
  ///
  /// In en, this message translates to:
  /// **'No discussions yet.'**
  String get noDiscussionsYet;

  /// UI text: Jump to Post
  ///
  /// In en, this message translates to:
  /// **'Jump to Post'**
  String get jumpToPost;

  /// UI text: Jump
  ///
  /// In en, this message translates to:
  /// **'Jump'**
  String get jump;

  /// UI text: End of the discussion
  ///
  /// In en, this message translates to:
  /// **'End of the discussion'**
  String get endOfTheDiscussion;

  /// UI text: Only staff and reviewers can see the review queue.
  ///
  /// In en, this message translates to:
  /// **'Only staff and reviewers can see the review queue.'**
  String get reviewQueueStaffOnly;

  /// UI text: Nothing to review
  ///
  /// In en, this message translates to:
  /// **'Nothing to review'**
  String get nothingToReview;

  /// UI text: Refresh failed: {e}
  ///
  /// In en, this message translates to:
  /// **'Refresh failed: {error}'**
  String refreshFailed(Object error);

  /// UI text: Refreshing...
  ///
  /// In en, this message translates to:
  /// **'Refreshing...'**
  String get refreshing;

  /// UI text: Title
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// UI text: Edited {createdAtcontext}
  ///
  /// In en, this message translates to:
  /// **'Edited {time}'**
  String editedAt(Object time);

  /// UI text: Reason: {trim}
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String editReason(Object reason);

  /// UI text: This diff is too large to display.
  ///
  /// In en, this message translates to:
  /// **'This diff is too large to display.'**
  String get thisDiffIsTooLargeToDisplay;

  /// UI text: No content changes in this revision.
  ///
  /// In en, this message translates to:
  /// **'No content changes in this revision.'**
  String get noContentChangesInThisRevision;

  /// UI text: Revision {currentVersion} of {versionCount}
  ///
  /// In en, this message translates to:
  /// **'Revision {currentVersion} of {versionCount}'**
  String revisionOf(Object currentVersion, Object versionCount);

  /// UI text: Edit title
  ///
  /// In en, this message translates to:
  /// **'Edit title'**
  String get editConversation;

  /// UI text: Close message
  ///
  /// In en, this message translates to:
  /// **'Close message'**
  String get closeConversation;

  /// UI text: Open message
  ///
  /// In en, this message translates to:
  /// **'Open message'**
  String get openConversation;

  /// UI text: Leave message
  ///
  /// In en, this message translates to:
  /// **'Leave message'**
  String get leaveConversation2;

  /// UI text: Close message
  ///
  /// In en, this message translates to:
  /// **'Close message'**
  String get closeConversation2;

  /// UI text: Close this message? It will no longer accept new replies.
  ///
  /// In en, this message translates to:
  /// **'Close this message? It will no longer accept new replies.'**
  String get closeConversationConfirmation;

  /// UI text: Close
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// UI text: Open message
  ///
  /// In en, this message translates to:
  /// **'Open message'**
  String get openConversation2;

  /// UI text: Open this message? It will accept new replies again.
  ///
  /// In en, this message translates to:
  /// **'Open this message? It will accept new replies again.'**
  String get openConversationConfirmation;

  /// UI text: Open
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// UI text: Leave message
  ///
  /// In en, this message translates to:
  /// **'Leave message'**
  String get leaveConversation3;

  /// UI text: Are you sure you want to remove yourself from this message? You will no longer be able to see or reply to it.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove yourself from this message? You will no longer be able to see or reply to it.'**
  String get leaveConversationConfirmation;

  /// UI text: Edit title
  ///
  /// In en, this message translates to:
  /// **'Edit title'**
  String get editConversation2;

  /// UI text: Failed to load message
  ///
  /// In en, this message translates to:
  /// **'Failed to load message'**
  String get failedToLoadMessage2;

  /// UI text: You can't edit this message
  ///
  /// In en, this message translates to:
  /// **'You can\'t edit this message'**
  String get cannotEditThisConversation;

  /// UI text: Options
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// UI text: Open for replies
  ///
  /// In en, this message translates to:
  /// **'Open for replies'**
  String get conversationOpen;

  /// UI text: What is this discussion about in one brief sentence?
  ///
  /// In en, this message translates to:
  /// **'What is this discussion about in one brief sentence?'**
  String get messageTitleHint;

  /// UI text: Accepting new replies
  ///
  /// In en, this message translates to:
  /// **'Accepting new replies'**
  String get messageOpenForReplies;

  /// UI text: Closed: no new replies
  ///
  /// In en, this message translates to:
  /// **'Closed: no new replies'**
  String get messageClosedForReplies;

  /// UI text: The message was sent, but the forum didn't return it. Check your messages.
  ///
  /// In en, this message translates to:
  /// **'The message was sent, but the forum didn\'t return it. Check your messages.'**
  String get messageSentWithoutId;

  /// UI text: The message could not be sent.
  ///
  /// In en, this message translates to:
  /// **'The message could not be sent.'**
  String get messageCouldNotBeSent;

  /// UI text: This message can't be opened: its ID is missing.
  ///
  /// In en, this message translates to:
  /// **'This message can\'t be opened: its ID is missing.'**
  String get messageIdMissing;

  /// UI text: Please add at least one recipient
  ///
  /// In en, this message translates to:
  /// **'Please add at least one recipient'**
  String get pleaseAddARecipient;

  /// UI text: Archive
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveMessage;

  /// UI text: Move to Inbox
  ///
  /// In en, this message translates to:
  /// **'Move to Inbox'**
  String get moveToInbox;

  /// UI text: Inbox
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get messageInbox;

  /// UI text: Archive
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get messageArchive;

  /// Messages list: the viewer's unread messages (Discourse user.messages.unread)
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get messageListUnread;

  /// Messages list: new messages (Discourse user.messages.new)
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get messageListNew;

  /// Messages list: messages the viewer sent (Discourse user.messages.sent)
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get messageListSent;

  /// Confirming taking a person or group off a private message (Discourse private_message_info.remove_allowed_user)
  ///
  /// In en, this message translates to:
  /// **'Do you really want to remove {name} from this message?'**
  String removeFromMessageConfirm(String name);

  /// Placeholder put in the post text where an upload will go while it uploads (Discourse uploading_filename)
  ///
  /// In en, this message translates to:
  /// **'Uploading: {filename}…'**
  String uploadingFilename(String filename);

  /// UI text: Message archived
  ///
  /// In en, this message translates to:
  /// **'Message archived'**
  String get messageArchived;

  /// UI text: Moved to Inbox
  ///
  /// In en, this message translates to:
  /// **'Moved to Inbox'**
  String get messageMovedToInbox;

  /// UI text: Could not archive the message: {error}
  ///
  /// In en, this message translates to:
  /// **'Could not archive the message: {error}'**
  String failedToArchiveMessage(Object error);

  /// UI text: Could not move the message to Inbox: {error}
  ///
  /// In en, this message translates to:
  /// **'Could not move the message to Inbox: {error}'**
  String failedToMoveMessageToInbox(Object error);

  /// UI text: You don't have any archived messages
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any archived messages'**
  String get noArchivedMessages;

  /// UI text: Archive a message from its ⋮ menu to file it here.
  ///
  /// In en, this message translates to:
  /// **'Archive a message from its ⋮ menu to file it here.'**
  String get noArchivedMessagesHint;

  /// UI text: {group} has been invited to the message
  ///
  /// In en, this message translates to:
  /// **'{group} has been invited to the message'**
  String groupHasBeenInvited(String group);

  /// UI text: N participants
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 participant} other{{count} participants}}'**
  String participantCount(int count);

  /// UI text (Discourse chat): Channels
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get chatChannels;

  /// UI text (Discourse chat): DMs
  ///
  /// In en, this message translates to:
  /// **'DMs'**
  String get chatDms;

  /// UI text (Discourse chat): You have not joined any channels yet!
  ///
  /// In en, this message translates to:
  /// **'You have not joined any channels yet!'**
  String get chatNoChannels;

  /// UI text (Discourse chat): You have not joined any direct messages yet!
  ///
  /// In en, this message translates to:
  /// **'You have not joined any direct messages yet!'**
  String get chatNoDms;

  /// UI text (Discourse chat): Start a conversation
  ///
  /// In en, this message translates to:
  /// **'Start a conversation'**
  String get chatNoDmsCta;

  /// UI text (Discourse chat): Chat in {channel}
  ///
  /// In en, this message translates to:
  /// **'Chat in {channel}'**
  String chatPlaceholderChannel(String channel);

  /// UI text (Discourse chat): Chat with {names}
  ///
  /// In en, this message translates to:
  /// **'Chat with {names}'**
  String chatPlaceholderUsers(String names);

  /// UI text (Discourse chat): Jot something down
  ///
  /// In en, this message translates to:
  /// **'Jot something down'**
  String get chatPlaceholderSelf;

  /// UI text (Discourse chat): Channel is archived, you cannot send new messages right now.
  ///
  /// In en, this message translates to:
  /// **'Channel is archived, you cannot send new messages right now.'**
  String get chatPlaceholderArchived;

  /// UI text (Discourse chat): Channel is closed, you cannot send new messages right now.
  ///
  /// In en, this message translates to:
  /// **'Channel is closed, you cannot send new messages right now.'**
  String get chatPlaceholderClosed;

  /// UI text (Discourse chat): Channel is read only, you cannot send new messages right now.
  ///
  /// In en, this message translates to:
  /// **'Channel is read only, you cannot send new messages right now.'**
  String get chatPlaceholderReadOnly;

  /// UI text (Discourse chat): You cannot send messages at this time.
  ///
  /// In en, this message translates to:
  /// **'You cannot send messages at this time.'**
  String get chatPlaceholderSilenced;

  /// UI text (Discourse chat): Are you sure you want to delete this message?
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this message?'**
  String get chatDeleteConfirm;

  /// UI text (Discourse chat): Start new DM
  ///
  /// In en, this message translates to:
  /// **'Start new DM'**
  String get chatStartNewDm;

  /// UI text (Discourse chat): Create a personal chat
  ///
  /// In en, this message translates to:
  /// **'Create a personal chat'**
  String get chatCreatePersonal;

  /// UI text (Discourse chat): Create group chat
  ///
  /// In en, this message translates to:
  /// **'Create group chat'**
  String get chatCreateGroup;

  /// UI text (Discourse chat): Sorry, you cannot send direct messages.
  ///
  /// In en, this message translates to:
  /// **'Sorry, you cannot send direct messages.'**
  String get chatCannotCreate;

  /// UI text (Discourse chat): has disabled chat
  ///
  /// In en, this message translates to:
  /// **'has disabled chat'**
  String get chatDisabledUser;

  /// UI text (Discourse chat): @somebody
  ///
  /// In en, this message translates to:
  /// **'@somebody'**
  String get chatSearchPlaceholder;

  /// UI text (Discourse chat): ...add more members
  ///
  /// In en, this message translates to:
  /// **'...add more members'**
  String get chatAddMorePlaceholder;

  /// UI text (Discourse chat): @{name} not found
  ///
  /// In en, this message translates to:
  /// **'@{name} not found'**
  String chatUserNotFound(String name);

  /// UI text (Discourse chat): Could not start the chat.
  ///
  /// In en, this message translates to:
  /// **'Could not start the chat.'**
  String get chatCouldNotStartDm;

  /// UI text (Discourse chat): Sign in to use chat
  ///
  /// In en, this message translates to:
  /// **'Sign in to use chat'**
  String get chatSignInTitle;

  /// UI text (Discourse chat): You need to be signed in to view and join chat channels.
  ///
  /// In en, this message translates to:
  /// **'You need to be signed in to view and join chat channels.'**
  String get chatSignInMessage;

  /// UI text (Discourse chat): Direct message
  ///
  /// In en, this message translates to:
  /// **'Direct message'**
  String get chatDirectMessage;

  /// UI text (Discourse chat): Chat is not available on this forum.
  ///
  /// In en, this message translates to:
  /// **'Chat is not available on this forum.'**
  String get chatNotAvailable;

  /// Chat composer button that attaches images or files (Discourse chat.upload).
  ///
  /// In en, this message translates to:
  /// **'Attach a file'**
  String get chatAttachFile;

  /// Removes a picked file from the chat composer before sending (Discourse chat.remove_upload).
  ///
  /// In en, this message translates to:
  /// **'Remove file'**
  String get chatRemoveUpload;

  /// Opens the camera to take a photo to attach.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

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

  /// UI text: Maximum of {count} attachment(s) allowed
  ///
  /// In en, this message translates to:
  /// **'Maximum of {count} attachment(s) allowed'**
  String maximumAttachmentsAllowed(Object count);

  /// UI text: No images found to display.
  ///
  /// In en, this message translates to:
  /// **'No images found to display.'**
  String get noImagesFoundToDisplay;

  /// UI text: Search for topics
  ///
  /// In en, this message translates to:
  /// **'Search for topics'**
  String get searchForTopics;

  /// UI text: No topics found
  ///
  /// In en, this message translates to:
  /// **'No topics found'**
  String get noTopicsFound;

  /// UI text: Try searching with different keywords
  ///
  /// In en, this message translates to:
  /// **'Try searching with different keywords'**
  String get trySearchingWithDifferentKeywords;

  /// UI text: No posts found
  ///
  /// In en, this message translates to:
  /// **'No posts found'**
  String get noPostsFound;

  /// UI text: Per-category and per-topic notification levels are set from
  ///
  /// In en, this message translates to:
  /// **'Per-category and per-topic notification levels are set from those screens directly — tap the bell icon on any topic or category to override.'**
  String get perTopicNotificationLevelsNote;

  /// UI text: Not active for this login — log out and log back in to autho
  ///
  /// In en, this message translates to:
  /// **'Not active for this login — log out and log back in to authorize push notifications'**
  String get pushNotActiveForThisLogin;

  /// UI text: Pause notifications for…
  ///
  /// In en, this message translates to:
  /// **'Pause notifications for…'**
  String get pauseNotificationsFor;

  /// UI text: Pause notifications for a while — Discourse holds them until
  ///
  /// In en, this message translates to:
  /// **'Pause notifications for a while — Discourse holds them until the window ends'**
  String get doNotDisturbExplanation;

  /// UI text: Profile, email, password, security, advanced settings
  ///
  /// In en, this message translates to:
  /// **'Profile, email, password, security, advanced settings'**
  String get manageAccountSubtitle;

  /// UI text: Trigger a password-reset email to your current address
  ///
  /// In en, this message translates to:
  /// **'Trigger a password-reset email to your current address'**
  String get changePasswordSubtitle;

  /// UI text: See and manage users whose posts are hidden from you
  ///
  /// In en, this message translates to:
  /// **'See and manage users whose posts are hidden from you'**
  String get ignoredUsersSubtitle;

  /// UI text: Removing your account is handled on the forum. Continue to o
  ///
  /// In en, this message translates to:
  /// **'Delete your account and your posts, if the forum allows it. Otherwise its staff can remove it for you.'**
  String get deleteAccountExplanation;

  /// UI text: Verification email sent — click the link to confirm your new
  ///
  /// In en, this message translates to:
  /// **'Verification email sent — click the link to confirm your new address.'**
  String get verificationEmailSent;

  /// UI text: We’ll email you a password-reset link. Click it to choose a
  ///
  /// In en, this message translates to:
  /// **'We’ll email you a password-reset link. Click it to choose a new password — the change is handled on the forum, not in this app.'**
  String get passwordResetExplanation;

  /// UI text: Send reset email
  ///
  /// In en, this message translates to:
  /// **'Send reset email'**
  String get sendResetEmail;

  /// UI text: Your account is managed by the forum. Please contact the for
  ///
  /// In en, this message translates to:
  /// **'Your account is managed by the forum. Please contact the forum staff directly to request account removal. Continue will open the forum in your browser so you can use the site’s own contact / staff message flow.'**
  String get deleteAccountDialogBody;

  /// UI text: Initializing forum…
  ///
  /// In en, this message translates to:
  /// **'Initializing forum…'**
  String get initializingForum;

  /// UI text: Error loading notifications
  ///
  /// In en, this message translates to:
  /// **'Error loading notifications'**
  String get errorLoadingNotifications;

  /// UI text: You have no new notifications. Check back later for updates
  ///
  /// In en, this message translates to:
  /// **'You will be notified in this panel about activity directly relevant to you, including replies to your topics and posts, when someone @mentions you or quotes you, and replies to topics you are watching. Notifications will also be sent to your email when you haven’t logged in for a while.'**
  String get noNewNotificationsExplanation;

  /// UI text: No tags match "{text}".
  ///
  /// In en, this message translates to:
  /// **'No tags match \"{filter}\".'**
  String noTagsMatch(Object filter);

  /// UI text: No topics tagged "{tag}"
  ///
  /// In en, this message translates to:
  /// **'No topics tagged \"{tag}\"'**
  String noTopicsTagged(Object tag);

  /// UI text: Search User
  ///
  /// In en, this message translates to:
  /// **'Search User'**
  String get searchUser;

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

  /// UI text: {total_posts0} Posts
  ///
  /// In en, this message translates to:
  /// **'{count} Posts'**
  String postsCount(Object count);

  /// UI text: Permission denied to save image
  ///
  /// In en, this message translates to:
  /// **'Permission denied to save image'**
  String get permissionDeniedToSaveImage;

  /// UI text: Post not found.
  ///
  /// In en, this message translates to:
  /// **'Post not found.'**
  String get postNotFound;

  /// UI text: Failed to upload file. Please try again.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload file. Please try again.'**
  String get failedToUploadFilePleaseTryAgain;

  /// UI text: Failed to upload file: {errorMessage}
  ///
  /// In en, this message translates to:
  /// **'Failed to upload file: {errorMessage}'**
  String failedToUploadFile2(Object errorMessage);

  /// UI text: Only {remainingSlots} more attachment(s) allowed. Processing
  ///
  /// In en, this message translates to:
  /// **'Only {remainingSlots} more attachment(s) allowed. Processing first {remainingSlots2} image(s).'**
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2);

  /// UI text: Failed to remove attachment: {toString}
  ///
  /// In en, this message translates to:
  /// **'Failed to remove attachment: {error}'**
  String failedToRemoveAttachment2(Object error);

  /// UI text: Sent from {name} mobile app
  ///
  /// In en, this message translates to:
  /// **'Sent from {siteName} mobile app'**
  String sentFromMobileApp(Object siteName);

  /// UI text: Please wait for attachments to finish uploading
  ///
  /// In en, this message translates to:
  /// **'Please wait for attachments to finish uploading'**
  String get pleaseWaitForAttachmentsToFinishUploading;

  /// UI text: Image is too large to upload
  ///
  /// In en, this message translates to:
  /// **'Image is too large to upload'**
  String get imageIsTooLargeToUpload;

  /// UI text: {fileName} is {fileBytes}. This forum allows up to {maxBytes
  ///
  /// In en, this message translates to:
  /// **'{fileName} is {fileBytes}. This forum allows up to {maxBytes}.'**
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes);

  /// UI text: It can be scaled down just enough to fit, keeping its format
  ///
  /// In en, this message translates to:
  /// **'It can be scaled down just enough to fit, keeping its format and as much detail as the limit allows.'**
  String get resizeToFitExplanation;

  /// UI text: Failed to post reply. Please try again.
  ///
  /// In en, this message translates to:
  /// **'Failed to post reply. Please try again.'**
  String get failedToPostReplyPleaseTryAgain;

  /// UI text: Failed to update post. Please try again.
  ///
  /// In en, this message translates to:
  /// **'Failed to update post. Please try again.'**
  String get failedToUpdatePostPleaseTryAgain;

  /// UI text: Post deleted successfully
  ///
  /// In en, this message translates to:
  /// **'Post deleted successfully'**
  String get postDeletedSuccessfully;

  /// UI text: Failed to delete post: {toString}
  ///
  /// In en, this message translates to:
  /// **'Failed to delete post: {error}'**
  String failedToDeletePost(Object error);

  /// UI text: Edit history is not available for this post
  ///
  /// In en, this message translates to:
  /// **'Edit history is not available for this post'**
  String get editHistoryNotAvailable;

  /// UI text: React
  ///
  /// In en, this message translates to:
  /// **'React'**
  String get react;

  /// UI text: Reactions are not enabled on this forum.
  ///
  /// In en, this message translates to:
  /// **'Reactions are not enabled on this forum.'**
  String get reactionsAreNotEnabledOnThisForum;

  /// UI text: No reactions yet
  ///
  /// In en, this message translates to:
  /// **'No reactions yet'**
  String get noReactionsYet;

  /// UI text: Search filters
  ///
  /// In en, this message translates to:
  /// **'Search filters'**
  String get searchFilters;

  /// UI text: Suggested Topics
  ///
  /// In en, this message translates to:
  /// **'Suggested Topics'**
  String get suggestedTopics;

  /// Heading over the messages Discourse suggests at the end of a private message (its suggested_topics.pm_title)
  ///
  /// In en, this message translates to:
  /// **'Suggested Messages'**
  String get suggestedMessages;

  /// UI text: Vote removed
  ///
  /// In en, this message translates to:
  /// **'Vote removed'**
  String get voteRemoved;

  /// UI text: Voters
  ///
  /// In en, this message translates to:
  /// **'Voters'**
  String get voters;

  /// UI text: No votes yet.
  ///
  /// In en, this message translates to:
  /// **'No votes yet.'**
  String get noVotesYet;

  /// UI text: Trust levels
  ///
  /// In en, this message translates to:
  /// **'Trust levels'**
  String get trustLevels;

  /// UI text: Members earn trust by reading and participating. Each level
  ///
  /// In en, this message translates to:
  /// **'Members earn trust by reading and participating. Each level unlocks new abilities.'**
  String get trustLevelsExplanation;

  /// UI text: Activity
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// Decline uploading an oversized image
  ///
  /// In en, this message translates to:
  /// **'Don\'t upload'**
  String get dontUpload;

  /// Checkbox on the oversized image sheet
  ///
  /// In en, this message translates to:
  /// **'Don\'t ask again — always resize to fit'**
  String get dontAskAgainAlwaysResize;

  /// Snackbar when the category list fails to load
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load categories.'**
  String get couldNotLoadCategories;

  /// Drawer: Tags
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// Drawer: Community
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// Drawer: Users
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// Drawer: Groups
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// Drawer: Invites
  ///
  /// In en, this message translates to:
  /// **'Invites'**
  String get invites;

  /// Drawer: Account
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Drawer: Drafts
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get drafts;

  /// Drawer: Terms of Service
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Drawer: Privacy Policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Drawer header
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get notSignedIn;

  /// Grant page banner, shown when the OS notification permission was refused
  ///
  /// In en, this message translates to:
  /// **'Your device will not show alerts until you allow notifications in Settings.'**
  String get deviceWillNotShowAlertsUntilAllowedInSettings;

  /// Button: open the app's page in the system settings
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// Notification settings section header: the app's push from this forum to this device
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get notificationsThisDeviceSection;

  /// Line under the 'On this device' header saying the push settings affect only this device
  ///
  /// In en, this message translates to:
  /// **'Push from {forumName} to this device only. Your other devices and the web aren\'t affected.'**
  String notificationsThisDeviceCaption(Object forumName);

  /// Notification settings section header: the reader's settings on the forum (email, activity)
  ///
  /// In en, this message translates to:
  /// **'Your {forumName} account'**
  String notificationsAccountSection(Object forumName);

  /// Line under the account header saying these settings apply on the web, by email and on every device
  ///
  /// In en, this message translates to:
  /// **'These apply everywhere: on the web, by email and on all your devices.'**
  String get notificationsAccountCaption;

  /// Push notifications row subtitle while push from this forum is on for this device
  ///
  /// In en, this message translates to:
  /// **'On: new notifications from {forumName} are pushed to this device.'**
  String pushOnThisDeviceSubtitle(Object forumName);

  /// Push notifications row subtitle while it is off; turning it on means approving once on the forum
  ///
  /// In en, this message translates to:
  /// **'Off on this device. To turn it on, you approve it once on {forumName}.'**
  String pushOffThisDeviceSubtitle(Object forumName);

  /// Row (destructive): stop push from this forum on this device and delete the permission
  ///
  /// In en, this message translates to:
  /// **'Stop push on this device'**
  String get stopPushOnThisDevice;

  /// Title of the dialog confirming 'Stop push on this device'
  ///
  /// In en, this message translates to:
  /// **'Stop push from {forumName} on this device?'**
  String stopPushTitle(Object forumName);

  /// Stop push dialog: only this device is affected
  ///
  /// In en, this message translates to:
  /// **'Only this device stops. Your other devices keep theirs.'**
  String get stopPushOnlyThisDevice;

  /// Stop push dialog: notifications in the app, on the web and by email are unchanged
  ///
  /// In en, this message translates to:
  /// **'Your notifications still show in the app and on the web, and the forum\'s emails don\'t change.'**
  String get stopPushNothingElseChanges;

  /// Stop push dialog: the permission granted on the forum is deleted; turning push back on needs approving there again
  ///
  /// In en, this message translates to:
  /// **'The permission you gave on {forumName} is deleted. To turn push back on, you\'ll approve it there again.'**
  String stopPushPermissionDeleted(Object forumName);

  /// Stop push dialog footnote: the per-type switches and Do not disturb (on the Profile tab) are for quiet time
  ///
  /// In en, this message translates to:
  /// **'Want quiet for a while instead? Turn off the kinds you don\'t need above, or use Do not disturb on your profile.'**
  String get stopPushQuietHint;

  /// Button (destructive) in the stop push dialog
  ///
  /// In en, this message translates to:
  /// **'Stop push'**
  String get stopPush;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get turnOn;

  /// Snackbar when the notifications backend rejected the revoke
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t stop push. Try again later.'**
  String get couldNotTurnOffNotifications;

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.topic_created). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Created this topic {when}'**
  String actionCodeTopicCreated(String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.public_topic). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Made this topic public {when}'**
  String actionCodePublicTopic(String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.open_topic). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Converted this to a topic {when}'**
  String actionCodeOpenTopic(String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.private_topic). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Made this topic a personal message {when}'**
  String actionCodePrivateTopic(String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.split_topic). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Split this topic {when}'**
  String actionCodeSplitTopic(String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.invited_user). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Invited {who} {when}'**
  String actionCodeInvitedUser(String who, String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.invited_group). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Invited {who} {when}'**
  String actionCodeInvitedGroup(String who, String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.user_left). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'{who} removed themselves from this message {when}'**
  String actionCodeUserLeft(String who, String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.removed_user). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Removed {who} {when}'**
  String actionCodeRemovedUser(String who, String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.removed_group). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Removed {who} {when}'**
  String actionCodeRemovedGroup(String who, String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.autobumped). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Automatically bumped {when}'**
  String actionCodeAutobumped(String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.tags_changed). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Tags updated {when}'**
  String actionCodeTagsChanged(String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.category_changed). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Category updated {when}'**
  String actionCodeCategoryChanged(String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.forwarded). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Forwarded the above email'**
  String get actionCodeForwarded;

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.autoclosed.enabled). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Closed {when}'**
  String actionCodeAutoclosedEnabled(String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.autoclosed.disabled). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Opened {when}'**
  String actionCodeAutoclosedDisabled(String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.closed.enabled). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Closed {when}'**
  String actionCodeClosedEnabled(String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.closed.disabled). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Opened {when}'**
  String actionCodeClosedDisabled(String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.archived.enabled). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Archived {when}'**
  String actionCodeArchivedEnabled(String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.archived.disabled). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Unarchived {when}'**
  String actionCodeArchivedDisabled(String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.pinned.enabled). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Pinned {when}'**
  String actionCodePinnedEnabled(String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.pinned.disabled). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Unpinned {when}'**
  String actionCodePinnedDisabled(String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.pinned_globally.enabled). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Pinned globally {when}'**
  String actionCodePinnedGloballyEnabled(String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.pinned_globally.disabled). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Unpinned {when}'**
  String actionCodePinnedGloballyDisabled(String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.visible.enabled). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Listed {when}'**
  String actionCodeVisibleEnabled(String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.visible.disabled). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Unlisted {when}'**
  String actionCodeVisibleDisabled(String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.banner.enabled). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Made this a banner {when}. It will appear at the top of every page until it is dismissed by the user.'**
  String actionCodeBannerEnabled(String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.banner.disabled). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Removed this banner {when}. It will no longer appear at the top of every page.'**
  String actionCodeBannerDisabled(String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.assigned). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Assigned {who} {when}'**
  String actionCodeAssigned(String who, String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.unassigned). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Unassigned {who} {when}'**
  String actionCodeUnassigned(String who, String when);

  /// One-line notice for a post that records a topic action, as Discourse words it (action_codes.reassigned). {when} is a relative date; {who} a username.
  ///
  /// In en, this message translates to:
  /// **'Reassigned {who} {when}'**
  String actionCodeReassigned(String who, String when);

  /// A date shown in the reader's time zone, relative to today (discourse-local-dates relative_dates.today). {time} is the time.
  ///
  /// In en, this message translates to:
  /// **'Today {time}'**
  String localDateToday(String time);

  /// A date shown in the reader's time zone, relative to today (discourse-local-dates relative_dates.tomorrow). {time} is the time.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow {time}'**
  String localDateTomorrow(String time);

  /// A date shown in the reader's time zone, relative to today (discourse-local-dates relative_dates.yesterday). {time} is the time.
  ///
  /// In en, this message translates to:
  /// **'Yesterday {time}'**
  String localDateYesterday(String time);

  /// Calendar event card label (discourse-calendar expired).
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get eventExpired;

  /// Calendar event card label (discourse-calendar every_day).
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get eventEveryDay;

  /// Calendar event card label (discourse-calendar every_weekday).
  ///
  /// In en, this message translates to:
  /// **'Every weekday'**
  String get eventEveryWeekday;

  /// Calendar event card label (discourse-calendar every_week).
  ///
  /// In en, this message translates to:
  /// **'Every week at this weekday'**
  String get eventEveryWeek;

  /// Calendar event card label (discourse-calendar every_two_weeks).
  ///
  /// In en, this message translates to:
  /// **'Every two weeks at this weekday'**
  String get eventEveryTwoWeeks;

  /// Calendar event card label (discourse-calendar every_four_weeks).
  ///
  /// In en, this message translates to:
  /// **'Every four weeks at this weekday'**
  String get eventEveryFourWeeks;

  /// Calendar event card label (discourse-calendar every_month).
  ///
  /// In en, this message translates to:
  /// **'Every month at this weekday'**
  String get eventEveryMonth;

  /// Error: no response from the forum (offline, DNS, refused).
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the forum. Check your connection and try again.'**
  String get errorNoConnection;

  /// Error: the forum did not answer in time.
  ///
  /// In en, this message translates to:
  /// **'The forum took too long to answer. Please try again.'**
  String get errorTimedOut;

  /// Error: HTTP 402, content reserved for paying members.
  ///
  /// In en, this message translates to:
  /// **'This is only for the forum\'s paying members.'**
  String get errorPaywalled;

  /// Error: a firewall/bot check answered instead of the forum.
  ///
  /// In en, this message translates to:
  /// **'The forum\'s firewall blocked the app. Try again later, or open the forum in a browser.'**
  String get errorBlocked;

  /// Error: 401/403 from the forum itself.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have access to this. Signing in may help.'**
  String get errorNotAllowed;

  /// Error: 404/410.
  ///
  /// In en, this message translates to:
  /// **'This doesn\'t exist, or it was removed.'**
  String get errorNotFound;

  /// Error: 429 rate limit.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing that too often. Please wait a moment and try again.'**
  String get errorRateLimited;

  /// Error: 5xx, the forum is down or failing.
  ///
  /// In en, this message translates to:
  /// **'The forum isn\'t responding right now. Please try again later.'**
  String get errorForumDown;

  /// Staff action on a profile: delete the account and posts, block its email, IP and links (Discourse's Delete Spammer)
  ///
  /// In en, this message translates to:
  /// **'Delete spammer'**
  String get deleteSpammer;

  /// No description provided for @yesDeleteSpammer.
  ///
  /// In en, this message translates to:
  /// **'Yes, delete spammer'**
  String get yesDeleteSpammer;

  /// Confirmation before Delete spammer (Discourse flagging.delete_confirm_MF, without the counts)
  ///
  /// In en, this message translates to:
  /// **'You are about to delete this user\'s posts and topics, remove their account, block signups from their IP address, and add their email address to a permanent block list. Are you sure this user is really a spammer?'**
  String get deleteSpammerConfirm;

  /// No description provided for @userWasDeleted.
  ///
  /// In en, this message translates to:
  /// **'The user was deleted.'**
  String get userWasDeleted;

  /// Confirms deleting your own account (Discourse user.delete_account)
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteMyAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete your account? This action cannot be undone!'**
  String get deleteAccountConfirm;

  /// No description provided for @deletedYourself.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted successfully.'**
  String get deletedYourself;

  /// When the forum refuses to let you delete your own account (Discourse user.delete_yourself_not_allowed)
  ///
  /// In en, this message translates to:
  /// **'Please contact a staff member if you wish your account to be deleted.'**
  String get deleteYourselfNotAllowed;

  /// The composer's submit button for a new topic (Discourse's own wording).
  ///
  /// In en, this message translates to:
  /// **'Create Topic'**
  String get createTopic;

  /// Asked when a composer with unsaved writing is closed (Discourse post.cancel_composer.confirm).
  ///
  /// In en, this message translates to:
  /// **'Do you want to discard your post?'**
  String get discardPostQuestion;

  /// Asked when an edit with unsaved changes is closed (Discourse post.cancel_composer.confirm_edit).
  ///
  /// In en, this message translates to:
  /// **'Do you want to discard your changes?'**
  String get discardChangesQuestion;

  /// Button that throws away unsaved edits (Discourse post.cancel_composer.discard_edit).
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get discardChanges;

  /// Button that closes a composer and keeps what was written as a draft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get saveDraft;

  /// The drawer row and page for choosing notifications: named apart from the Notifications tab, which lists them.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationSettings;

  /// Read aloud for a topic row's dot: never opened, created recently (Discourse's New).
  ///
  /// In en, this message translates to:
  /// **'New topic'**
  String get topicIsNew;

  /// No description provided for @noNewTopicsSinceLastVisit.
  ///
  /// In en, this message translates to:
  /// **'No new topics since your last visit.'**
  String get noNewTopicsSinceLastVisit;

  /// Read aloud for a message row's dot: never opened.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get messageIsNew;

  /// Read aloud for a topic row's count badge: replies after where the reader stopped, in a topic they track.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unread reply} other{{count} unread replies}}'**
  String topicUnreadReplies(int count);

  /// The New list's chip with its count of new topics (Discourse web: filters.new.title_with_count).
  ///
  /// In en, this message translates to:
  /// **'New ({count})'**
  String filterNewWithCount(int count);

  /// The Unread list's chip with its count of unread topics (Discourse web: filters.unread.title_with_count).
  ///
  /// In en, this message translates to:
  /// **'Unread ({count})'**
  String filterUnreadWithCount(int count);

  /// A category row's count of new topics in it and its subcategories (Discourse web: filters.new.lower_title_with_count).
  ///
  /// In en, this message translates to:
  /// **'{count} new'**
  String categoryNewTopics(int count);

  /// A category row's count of unread topics in it and its subcategories (Discourse web: filters.unread.lower_title_with_count).
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String categoryUnreadTopics(int count);

  /// Button on the New list: stop showing these topics as new (Discourse web: Dismiss New).
  ///
  /// In en, this message translates to:
  /// **'Dismiss new'**
  String get dismissNew;

  /// Button on the Unread list: mark the new replies in these topics read.
  ///
  /// In en, this message translates to:
  /// **'Dismiss unread'**
  String get dismissUnread;

  /// No description provided for @dismissNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Dismiss new topics?'**
  String get dismissNewTitle;

  /// No description provided for @dismissNewMessage.
  ///
  /// In en, this message translates to:
  /// **'They will no longer show as new.'**
  String get dismissNewMessage;

  /// No description provided for @dismissUnreadTitle.
  ///
  /// In en, this message translates to:
  /// **'Dismiss all unread?'**
  String get dismissUnreadTitle;

  /// No description provided for @dismissUnreadMessage.
  ///
  /// In en, this message translates to:
  /// **'Their new replies will be marked as read.'**
  String get dismissUnreadMessage;

  /// Checkbox in the Dismiss unread dialog (Discourse web: topics.bulk.also_dismiss_topics).
  ///
  /// In en, this message translates to:
  /// **'Stop tracking these topics so they never show up as unread for me again'**
  String get dismissUnreadStopTracking;

  /// A category's menu item: its new topics and unread replies, all at once.
  ///
  /// In en, this message translates to:
  /// **'Dismiss new and unread'**
  String get dismissNewAndUnread;

  /// No description provided for @dismissNewAndUnreadMessage.
  ///
  /// In en, this message translates to:
  /// **'Topics in {category} will no longer show as new or unread.'**
  String dismissNewAndUnreadMessage(String category);

  /// Snackbar after dismissing new topics or unread replies.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get dismissedTopics;

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

  /// Post menu item (discourse-solved): mark this reply as the topic's solution. Shown only to the topic's owner and staff
  ///
  /// In en, this message translates to:
  /// **'Mark as solution'**
  String get markAsSolution;

  /// Post menu item (discourse-solved): stop treating this reply as the topic's solution
  ///
  /// In en, this message translates to:
  /// **'Unmark as solution'**
  String get unmarkAsSolution;

  /// Search field in a forum's header, named after the forum
  ///
  /// In en, this message translates to:
  /// **'Search {forum}'**
  String searchForumName(String forum);

  /// Forum header stat: members active in the past 30 days, compact number (e.g. 1.9K)
  ///
  /// In en, this message translates to:
  /// **'{formatted} active this month'**
  String countActiveThisMonth(String formatted);

  /// Member count with a compact number (e.g. 56.8K members)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{formatted} member} other{{formatted} members}}'**
  String countMembers(int count, String formatted);

  /// Topic count with a compact number (e.g. 18.5K topics)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{formatted} topic} other{{formatted} topics}}'**
  String countTopics(int count, String formatted);

  /// Category card: topics started in the past week
  ///
  /// In en, this message translates to:
  /// **'{count} new this week'**
  String categoryNewThisWeek(int count);

  /// The Categories view among a forum's Home views (Latest, New, Top, Categories)
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesView;

  /// Drawer link to the full list of categories
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// Drawer link to the full list of tags
  ///
  /// In en, this message translates to:
  /// **'All tags'**
  String get allTags;

  /// Drawer link to the signed-in user's own posts (Discourse sidebar: My posts)
  ///
  /// In en, this message translates to:
  /// **'My posts'**
  String get myPosts;

  /// Shown once at the top of a forum's drawer (the menu), the one time it opens by itself in a multi-forum app, beside a menu icon
  ///
  /// In en, this message translates to:
  /// **'This forum\'s categories, tags and your account are all in this menu. Open it again any time with the menu button.'**
  String get drawerIntroduction;

  /// The signed-in user's Discourse trust level, in the drawer's account card
  ///
  /// In en, this message translates to:
  /// **'Trust level {level}'**
  String trustLevelN(int level);

  /// Home view: topics new since your last visit (Discourse: New)
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get filterNew;

  /// Home view: the most active topics of a period (Discourse: Top)
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get filterTop;

  /// Notification level: notified of every new post
  ///
  /// In en, this message translates to:
  /// **'Watching'**
  String get levelWatching;

  /// Notification level: notified of each new topic's first post
  ///
  /// In en, this message translates to:
  /// **'Watching first post'**
  String get levelWatchingFirstPost;

  /// Notification level: counts unread, notified when mentioned
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get levelTracking;

  /// Notification level: notified only when mentioned or replied to
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get levelNormal;

  /// Notification level: never notified, hidden from lists
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get levelMuted;

  /// Title of the sheet that picks a category for a new topic
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get chooseCategory;

  /// Drawer account card for a signed-out reader
  ///
  /// In en, this message translates to:
  /// **'Sign in to post and get notifications'**
  String get signInToPostAndGetNotifications;

  /// Snackbar after granting notifications when the forum's firewall (e.g. Cloudflare) refuses the notifications server
  ///
  /// In en, this message translates to:
  /// **'{forumName} blocks our notification server, so notifications may not arrive. You can turn them off in Settings.'**
  String forumBlocksNotificationServer(Object forumName);

  /// Heading (or tab) under a topic's last post listing related topics (discourse-ai), as Discourse web words it
  ///
  /// In en, this message translates to:
  /// **'Related Topics'**
  String get relatedTopics;

  /// Heading (or tab) under a private message listing related messages
  ///
  /// In en, this message translates to:
  /// **'Related Messages'**
  String get relatedMessages;

  /// Button under a topic's suggested topics opening the topic's category
  ///
  /// In en, this message translates to:
  /// **'More in {category}'**
  String moreInCategory(String category);

  /// Button under a topic's suggested topics opening the forum's latest topics
  ///
  /// In en, this message translates to:
  /// **'Latest topics'**
  String get latestTopics;

  /// Push notification group (a per-type switch in Settings → Notifications, and an Android notification channel)
  ///
  /// In en, this message translates to:
  /// **'Messages and chat'**
  String get pushGroupMessages;

  /// Push notification group (a per-type switch in Settings → Notifications, and an Android notification channel)
  ///
  /// In en, this message translates to:
  /// **'Personal messages, group inboxes and chat'**
  String get pushGroupMessagesHint;

  /// Push notification group (a per-type switch in Settings → Notifications, and an Android notification channel)
  ///
  /// In en, this message translates to:
  /// **'Replies and mentions'**
  String get pushGroupReplies;

  /// Push notification group (a per-type switch in Settings → Notifications, and an Android notification channel)
  ///
  /// In en, this message translates to:
  /// **'Replies, mentions, quotes and topics you watch'**
  String get pushGroupRepliesHint;

  /// Push notification group (a per-type switch in Settings → Notifications, and an Android notification channel)
  ///
  /// In en, this message translates to:
  /// **'Likes and reactions'**
  String get pushGroupReactions;

  /// Push notification group (a per-type switch in Settings → Notifications, and an Android notification channel)
  ///
  /// In en, this message translates to:
  /// **'Likes and reactions to your posts'**
  String get pushGroupReactionsHint;

  /// Push notification group (a per-type switch in Settings → Notifications, and an Android notification channel)
  ///
  /// In en, this message translates to:
  /// **'Everything else'**
  String get pushGroupOther;

  /// Push notification group (a per-type switch in Settings → Notifications, and an Android notification channel)
  ///
  /// In en, this message translates to:
  /// **'Badges, reminders, accepted answers and more'**
  String get pushGroupOtherHint;

  /// Push notification group (a per-type switch in Settings → Notifications, and an Android notification channel)
  ///
  /// In en, this message translates to:
  /// **'Other notifications'**
  String get pushChannelOther;

  /// Snackbar when a per-type push switch could not be saved on the notifications backend
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t change this setting. Try again later.'**
  String get couldNotChangePushSetting;

  /// Enable-notifications page
  ///
  /// In en, this message translates to:
  /// **'Never miss a reply on {forumName}'**
  String neverMissAReplyOn(Object forumName);

  /// Enable-notifications page
  ///
  /// In en, this message translates to:
  /// **'Replies, mentions, messages and chat on your lock screen, usually within 10 minutes. You can choose which, any time, in Settings.'**
  String get notificationsPitch;

  /// Enable-notifications page
  ///
  /// In en, this message translates to:
  /// **'Allow notifications on this phone'**
  String get notificationsStepAllow;

  /// Enable-notifications page
  ///
  /// In en, this message translates to:
  /// **'Notifications are allowed on this phone'**
  String get notificationsStepAllowed;

  /// Enable-notifications page
  ///
  /// In en, this message translates to:
  /// **'Approve on {forumName}'**
  String notificationsStepApprove(Object forumName);

  /// Enable-notifications page
  ///
  /// In en, this message translates to:
  /// **'Read-only: it can\'t post, reply or read your messages'**
  String get notificationsReadOnlyNote;

  /// Enable-notifications page (a sample notification shown as a preview)
  ///
  /// In en, this message translates to:
  /// **'Jane replied to you: Welcome aboard! Glad you found us.'**
  String get notificationPreviewReply;

  /// Enable-notifications page (a sample notification shown as a preview)
  ///
  /// In en, this message translates to:
  /// **'Sam sent you a message: Are you coming on Friday?'**
  String get notificationPreviewMessage;

  /// Enable-notifications page (a sample notification shown as a preview)
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get notificationPreviewNow;

  /// Enable-notifications page (a sample notification shown as a preview)
  ///
  /// In en, this message translates to:
  /// **'5m ago'**
  String get notificationPreviewEarlier;

  /// Top line of an activity row: the user replied in this topic
  ///
  /// In en, this message translates to:
  /// **'Replied'**
  String get activityReplied;

  /// Top line of an activity row: the user started this topic
  ///
  /// In en, this message translates to:
  /// **'Started a topic'**
  String get activityStartedTopic;

  /// Top line of an activity row: the user liked this post
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get activityLiked;

  /// Top line of an activity row: this post is an accepted solution (discourse-solved)
  ///
  /// In en, this message translates to:
  /// **'Solution'**
  String get activitySolution;

  /// Prefix before the username of whoever accepted a solution, e.g. 'accepted by alice'
  ///
  /// In en, this message translates to:
  /// **'accepted by'**
  String get activityAcceptedBy;

  /// Top line of an activity row: the post is waiting for a moderator
  ///
  /// In en, this message translates to:
  /// **'Awaiting approval'**
  String get activityAwaitingApproval;

  /// Activity filter chip: topics the user started
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get activityFilterTopics;

  /// Activity filter chip: the user's replies
  ///
  /// In en, this message translates to:
  /// **'Replies'**
  String get activityFilterReplies;

  /// Activity filter chip: posts the user liked
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get activityFilterLikes;

  /// Activity filter chip: the user's posts awaiting approval
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get activityFilterPending;

  /// Section heading in a list grouped by time
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get sectionToday;

  /// Section heading in a list grouped by time: the last seven days before today
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get sectionThisWeek;

  /// Section heading in a list grouped by time: older than a week
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get sectionEarlier;

  /// Banner at the top of My posts when the user has saved drafts
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 draft waiting} other{{count} drafts waiting}}'**
  String draftsWaiting(int count);

  /// Button on the drafts banner opening the drafts list
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeDrafts;

  /// My posts, nothing written yet
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get myPostsEmpty;

  /// My posts empty state hint
  ///
  /// In en, this message translates to:
  /// **'Topics you start and replies you write will show up here.'**
  String get myPostsEmptyHint;

  /// Empty activity filter: topics
  ///
  /// In en, this message translates to:
  /// **'No topics yet'**
  String get activityEmptyTopics;

  /// Empty activity filter: replies
  ///
  /// In en, this message translates to:
  /// **'No replies yet'**
  String get activityEmptyReplies;

  /// Empty activity filter: likes given
  ///
  /// In en, this message translates to:
  /// **'No likes given yet'**
  String get activityEmptyLikes;

  /// Empty activity filter: solutions
  ///
  /// In en, this message translates to:
  /// **'No solutions yet'**
  String get activityEmptySolved;

  /// Profile tab button: open your public profile as others see it
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfile;

  /// Profile tab section heading: your posts, drafts, bookmarks, badges, invites
  ///
  /// In en, this message translates to:
  /// **'Your stuff'**
  String get yourStuff;

  /// Profile tab row opening email, password, ignored users and account deletion
  ///
  /// In en, this message translates to:
  /// **'Account and privacy'**
  String get accountAndPrivacy;

  /// Label under your post count on the Profile tab; the number is shown above it
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{post} other{posts}}'**
  String profileStatPosts(int count);

  /// Label under the likes you have received on the Profile tab
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{like} other{likes}}'**
  String profileStatLikes(int count);

  /// Label under the days you have visited on the Profile tab
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{day} other{days}}'**
  String profileStatDays(int count);

  /// Label under the number of your accepted solutions on the Profile tab
  ///
  /// In en, this message translates to:
  /// **'solved'**
  String get profileStatSolved;

  /// Heading on the Profile tab for a guest
  ///
  /// In en, this message translates to:
  /// **'Join {forum}'**
  String joinForum(String forum);

  /// What signing in lets a guest do
  ///
  /// In en, this message translates to:
  /// **'Reply and start topics'**
  String get guestBenefitPost;

  /// What signing in lets a guest do
  ///
  /// In en, this message translates to:
  /// **'Get notified when people reply'**
  String get guestBenefitNotify;

  /// What signing in lets a guest do
  ///
  /// In en, this message translates to:
  /// **'Bookmark posts and keep drafts'**
  String get guestBenefitSave;

  /// What signing in lets a guest do (forums with chat)
  ///
  /// In en, this message translates to:
  /// **'Chat and send messages'**
  String get guestBenefitChat;

  /// Button opening sign-up
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// Row opening the forum's About page
  ///
  /// In en, this message translates to:
  /// **'About this forum'**
  String get aboutThisForum;

  /// Drawer row folding the less used community links (users, groups, badges, about)
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get drawerMore;

  /// Subtitle on the drawer's account card
  ///
  /// In en, this message translates to:
  /// **'Go to your profile'**
  String get goToYourProfile;

  /// When the person joined, e.g. 'Joined Mar 2024'
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String profileJoined(String date);

  /// When the person was last seen, e.g. 'Seen 2 hours ago'
  ///
  /// In en, this message translates to:
  /// **'Seen {when}'**
  String profileSeen(String when);

  /// The person's local time on their profile, e.g. '21:40 local time'
  ///
  /// In en, this message translates to:
  /// **'{time} local time'**
  String profileLocalTime(String time);

  /// Profile tab: the person's summary
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get profileTabSummary;

  /// Summary section
  ///
  /// In en, this message translates to:
  /// **'Top replies'**
  String get summaryTopReplies;

  /// Summary section
  ///
  /// In en, this message translates to:
  /// **'Top topics'**
  String get summaryTopTopics;

  /// Summary section: people who liked this person's posts most
  ///
  /// In en, this message translates to:
  /// **'Most liked by'**
  String get summaryMostLikedBy;

  /// Summary section: people whose posts this person liked most
  ///
  /// In en, this message translates to:
  /// **'Most liked'**
  String get summaryMostLiked;

  /// Summary section
  ///
  /// In en, this message translates to:
  /// **'Most replied to'**
  String get summaryMostRepliedTo;

  /// Summary section
  ///
  /// In en, this message translates to:
  /// **'Top links'**
  String get summaryTopLinks;

  /// Summary section: categories the person posts in most
  ///
  /// In en, this message translates to:
  /// **'Top categories'**
  String get summaryTopCategories;

  /// The topic a person features on their profile
  ///
  /// In en, this message translates to:
  /// **'Featured topic'**
  String get featuredTopic;

  /// Profile section with trust level, groups, views and custom fields
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get profileDetails;

  /// Button to follow a person
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get followUser;

  /// Button to stop following a person
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollowUser;

  /// Chip on the profile of a suspended person
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get profileSuspended;

  /// Search field on the bookmarks screen
  ///
  /// In en, this message translates to:
  /// **'Search your bookmarks'**
  String get searchBookmarks;

  /// Bookmarks filter chip: those with a reminder
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get bookmarksFilterReminders;

  /// A bookmark of a whole topic rather than one post
  ///
  /// In en, this message translates to:
  /// **'Whole topic'**
  String get bookmarkWholeTopic;

  /// When the bookmark was made, e.g. 'saved 3 days ago'
  ///
  /// In en, this message translates to:
  /// **'saved {when}'**
  String bookmarkSaved(String when);

  /// Which post a bookmark points at, e.g. 'post #12'
  ///
  /// In en, this message translates to:
  /// **'post #{number}'**
  String bookmarkPostNumber(int number);

  /// Reminder chip, e.g. 'Today, 8:00 PM'
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String reminderToday(String time);

  /// Reminder chip, e.g. 'Tomorrow, 8:00 AM'
  ///
  /// In en, this message translates to:
  /// **'Tomorrow, {time}'**
  String reminderTomorrow(String time);

  /// Reminder chip for a reminder that has fired, e.g. 'Due · Mon 9:00 AM'
  ///
  /// In en, this message translates to:
  /// **'Due · {when}'**
  String reminderDue(String when);

  /// Menu item: give a bookmark a label (its name)
  ///
  /// In en, this message translates to:
  /// **'Add label'**
  String get addBookmarkLabel;

  /// Menu item: change a bookmark's label
  ///
  /// In en, this message translates to:
  /// **'Edit label'**
  String get editBookmarkLabel;

  /// Hint in the bookmark label field
  ///
  /// In en, this message translates to:
  /// **'What is this for?'**
  String get bookmarkLabelHint;

  /// Menu item: pin a bookmark to the top of the list
  ///
  /// In en, this message translates to:
  /// **'Pin to top'**
  String get pinBookmark;

  /// Menu item: unpin a bookmark
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpinBookmark;

  /// Snackbar after removing a bookmark, with Undo
  ///
  /// In en, this message translates to:
  /// **'Bookmark removed'**
  String get bookmarkRemoved;

  /// Snackbar action undoing the last change
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Search or filter found nothing
  ///
  /// In en, this message translates to:
  /// **'No bookmarks match'**
  String get bookmarksNoMatch;

  /// Menu item: add a reminder to a bookmark
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get addReminder;

  /// Bookmarks screen, none yet
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet'**
  String get bookmarksEmpty;

  /// Bookmarks empty state hint
  ///
  /// In en, this message translates to:
  /// **'Bookmark a post from its actions and it will be waiting for you here.'**
  String get bookmarksEmptyHint;

  /// Top line of a draft row: it will start a topic
  ///
  /// In en, this message translates to:
  /// **'New topic'**
  String get draftKindNewTopic;

  /// Top line of a message draft, e.g. 'Message to alice, bob'
  ///
  /// In en, this message translates to:
  /// **'Message to {names}'**
  String draftMessageTo(String names);

  /// A draft topic with no title yet
  ///
  /// In en, this message translates to:
  /// **'Untitled topic'**
  String get untitledTopic;

  /// Snackbar after discarding a draft, with Undo
  ///
  /// In en, this message translates to:
  /// **'Draft discarded'**
  String get draftDiscarded;

  /// Drafts screen, none yet
  ///
  /// In en, this message translates to:
  /// **'No drafts yet'**
  String get draftsEmpty;

  /// Drafts empty state hint
  ///
  /// In en, this message translates to:
  /// **'Drafts save themselves as you type. Start a reply or a topic and it will wait for you here.'**
  String get draftsEmptyHint;

  /// Account and privacy page: heading over ignored users
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacySection;

  /// Account and privacy page: under Change email
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a verification link to the new address'**
  String get changeEmailSubtitle;

  /// Edit profile: the bio row and its editor's title
  ///
  /// In en, this message translates to:
  /// **'About me'**
  String get aboutMe;

  /// About me editor: under the field
  ///
  /// In en, this message translates to:
  /// **'Shown at the top of your profile'**
  String get aboutMeHelper;

  /// About me editor: beside the formatting buttons
  ///
  /// In en, this message translates to:
  /// **'Markdown works: **bold**, links, :emoji:'**
  String get aboutMeMarkdownHint;

  /// Edit profile: button on an empty cover
  ///
  /// In en, this message translates to:
  /// **'Add cover'**
  String get addCover;

  /// Edit profile: button on the cover photo
  ///
  /// In en, this message translates to:
  /// **'Change cover'**
  String get changeCover;

  /// Birthday dialog: explanation
  ///
  /// In en, this message translates to:
  /// **'The forum celebrates it with you. No year is kept.'**
  String get birthdayHint;

  /// Snackbar after removing the birthday
  ///
  /// In en, this message translates to:
  /// **'Birthday removed'**
  String get birthdayRemoved;

  /// Snackbar after setting the birthday
  ///
  /// In en, this message translates to:
  /// **'Birthday saved'**
  String get birthdaySaved;

  /// Edit profile: the user card's background image
  ///
  /// In en, this message translates to:
  /// **'Card background'**
  String get cardBackground;

  /// Edit profile: under Card background
  ///
  /// In en, this message translates to:
  /// **'Behind your user card when people tap your picture'**
  String get cardBackgroundExplanation;

  /// Snackbar after removing the card background, with Undo
  ///
  /// In en, this message translates to:
  /// **'Card background removed'**
  String get cardBackgroundRemoved;

  /// Card background sheet: explanation
  ///
  /// In en, this message translates to:
  /// **'Shown behind your user card. Wide photos work best.'**
  String get cardBackgroundSheetHint;

  /// Tooltip of the camera button on your picture
  ///
  /// In en, this message translates to:
  /// **'Change profile picture'**
  String get changeProfilePicture;

  /// Change username dialog title and its confirm button
  ///
  /// In en, this message translates to:
  /// **'Change username'**
  String get changeUsername;

  /// Change username dialog: what changing it does
  ///
  /// In en, this message translates to:
  /// **'Mentions and quotes of @{username} in posts switch to the new name. Old links to your profile stop working.'**
  String changeUsernameExplanation(String username);

  /// Photo sheets: pick a photo from the phone's library
  ///
  /// In en, this message translates to:
  /// **'Choose from library'**
  String get chooseFromLibrary;

  /// Cover photo sheet title
  ///
  /// In en, this message translates to:
  /// **'Cover photo'**
  String get coverPhoto;

  /// Cover photo sheet: explanation
  ///
  /// In en, this message translates to:
  /// **'Shown across the top of your profile, behind your picture. Wide photos work best, about 3 to 1.'**
  String get coverPhotoSheetHint;

  /// Snackbar after removing the cover, with Undo
  ///
  /// In en, this message translates to:
  /// **'Cover removed'**
  String get coverRemoved;

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

  /// Edit profile: the person's name (not their username)
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// Display name dialog: helper under the field
  ///
  /// In en, this message translates to:
  /// **'Shown with your posts. Your username stays @{username}.'**
  String displayNameHelper(String username);

  /// Edit profile: link at the bottom to Account and privacy
  ///
  /// In en, this message translates to:
  /// **'Email, password and sign-in'**
  String get emailPasswordInAccount;

  /// Featured topic sheet title
  ///
  /// In en, this message translates to:
  /// **'Feature a topic'**
  String get featureATopic;

  /// Featured topic sheet: explanation
  ///
  /// In en, this message translates to:
  /// **'Pin one of your topics to the top of your profile.'**
  String get featureATopicHint;

  /// Snackbar after featuring a topic, with Undo
  ///
  /// In en, this message translates to:
  /// **'Featured topic changed'**
  String get featuredTopicChanged;

  /// Edit profile: featured topic row when none is set
  ///
  /// In en, this message translates to:
  /// **'None. Pin one of your topics to your profile.'**
  String get featuredTopicNone;

  /// Snackbar after removing the featured topic, with Undo
  ///
  /// In en, this message translates to:
  /// **'Featured topic removed'**
  String get featuredTopicRemoved;

  /// Featured topic sheet: footnote
  ///
  /// In en, this message translates to:
  /// **'Messages and topics in private categories can\'t be featured.'**
  String get featuredTopicRules;

  /// Snackbar when tapping a locked profile row
  ///
  /// In en, this message translates to:
  /// **'This forum manages it through its own sign-in. Change it there.'**
  String get fieldManagedBySignIn;

  /// Edit profile: the group badge shown on the person's picture
  ///
  /// In en, this message translates to:
  /// **'Flair'**
  String get flair;

  /// Snackbar after choosing a flair, with Undo
  ///
  /// In en, this message translates to:
  /// **'Flair changed to {group}'**
  String flairChangedTo(String group);

  /// Snackbar after removing the flair, with Undo
  ///
  /// In en, this message translates to:
  /// **'Flair removed'**
  String get flairRemoved;

  /// Flair sheet: explanation
  ///
  /// In en, this message translates to:
  /// **'A small badge on your picture, from a group you\'re in.'**
  String get flairSheetHint;

  /// Accessibility label of one of the forum's own profile pictures
  ///
  /// In en, this message translates to:
  /// **'Forum picture {number}'**
  String forumPictureN(int number);

  /// Edit profile: More about you row when a required question is unanswered
  ///
  /// In en, this message translates to:
  /// **'{question} needs an answer'**
  String forumQuestionNeedsAnswer(String question);

  /// More about you: error under an unanswered required question
  ///
  /// In en, this message translates to:
  /// **'This forum asks everyone to answer'**
  String get forumQuestionRequired;

  /// More about you: helper under a question only staff can change
  ///
  /// In en, this message translates to:
  /// **'Set by the forum\'s staff'**
  String get forumQuestionSetByStaff;

  /// More about you page: intro
  ///
  /// In en, this message translates to:
  /// **'Questions from this forum. * means required.'**
  String get forumQuestionsIntro;

  /// Edit profile: More about you row when nothing is answered
  ///
  /// In en, this message translates to:
  /// **'Not answered yet'**
  String get forumQuestionsNoneAnswered;

  /// Profile picture sheet: heading over the forum's own pictures
  ///
  /// In en, this message translates to:
  /// **'From this forum'**
  String get fromThisForum;

  /// Edit profile: switch
  ///
  /// In en, this message translates to:
  /// **'Hide my public profile'**
  String get hideMyProfile;

  /// Edit profile: under Hide my public profile
  ///
  /// In en, this message translates to:
  /// **'Others see only your name, picture and posts'**
  String get hideMyProfileExplanation;

  /// Profile picture sheet: the forum's letter avatar
  ///
  /// In en, this message translates to:
  /// **'Letter'**
  String get letterAvatar;

  /// Edit profile: the forum's own profile questions, and that page's title
  ///
  /// In en, this message translates to:
  /// **'More about you'**
  String get moreAboutYou;

  /// Edit profile: a list cut short, e.g. 'Pronouns, Company, Tool and 3 more'
  ///
  /// In en, this message translates to:
  /// **'{names} and {count, plural, =1{1 more} other{{count} more}}'**
  String namesAndMore(String names, int count);

  /// Change username dialog: field label
  ///
  /// In en, this message translates to:
  /// **'New username'**
  String get newUsername;

  /// Flair sheet: wear none
  ///
  /// In en, this message translates to:
  /// **'No flair'**
  String get noFlair;

  /// Profile picture sheet: Gravatar chosen but none exists
  ///
  /// In en, this message translates to:
  /// **'{service} has no picture for your email address'**
  String noGravatarFound(String service);

  /// Title sheet: wear none
  ///
  /// In en, this message translates to:
  /// **'No title'**
  String get noTitle;

  /// Featured topic sheet: search found nothing
  ///
  /// In en, this message translates to:
  /// **'None of your topics match'**
  String get noTopicsMatch;

  /// Featured topic sheet: no topics
  ///
  /// In en, this message translates to:
  /// **'You haven\'t started any topics yet'**
  String get noTopicsToFeature;

  /// Edit profile: a value that is empty
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// Profile picture sheet: heading over the letter avatar, Gravatar and earlier photo
  ///
  /// In en, this message translates to:
  /// **'Or use'**
  String get orUse;

  /// Profile picture: locked by the forum's sign-in
  ///
  /// In en, this message translates to:
  /// **'This forum sets your picture through its own sign-in'**
  String get pictureManagedBySignIn;

  /// Edit profile: the person's main group
  ///
  /// In en, this message translates to:
  /// **'Primary group'**
  String get primaryGroup;

  /// Snackbar after choosing a primary group, with Undo
  ///
  /// In en, this message translates to:
  /// **'Primary group changed to {group}'**
  String primaryGroupChangedTo(String group);

  /// Snackbar after removing the primary group, with Undo
  ///
  /// In en, this message translates to:
  /// **'Primary group removed'**
  String get primaryGroupRemoved;

  /// Primary group sheet: explanation
  ///
  /// In en, this message translates to:
  /// **'Your main group, shown on your user card.'**
  String get primaryGroupSheetHint;

  /// Edit profile: loading failed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your profile'**
  String get profileLoadFailed;

  /// Snackbar after hiding the profile, with Undo
  ///
  /// In en, this message translates to:
  /// **'Your profile is hidden'**
  String get profileNowHidden;

  /// Snackbar after showing the profile, with Undo
  ///
  /// In en, this message translates to:
  /// **'Your profile is public'**
  String get profileNowPublic;

  /// Profile picture sheet title
  ///
  /// In en, this message translates to:
  /// **'Profile picture'**
  String get profilePicture;

  /// Snackbar after changing the profile picture
  ///
  /// In en, this message translates to:
  /// **'Profile picture changed'**
  String get profilePictureChanged;

  /// Edit profile: a save failed with no message from the forum
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Try again.'**
  String get profileSaveFailed;

  /// Edit profile: section heading
  ///
  /// In en, this message translates to:
  /// **'Name and about'**
  String get profileSectionNameAndAbout;

  /// Edit profile: section heading over title, flair and primary group
  ///
  /// In en, this message translates to:
  /// **'Next to your name'**
  String get profileSectionNextToName;

  /// Edit profile: section heading over featured topic and the forum's questions
  ///
  /// In en, this message translates to:
  /// **'On your profile'**
  String get profileSectionOnProfile;

  /// Edit profile: section heading
  ///
  /// In en, this message translates to:
  /// **'Privacy and time'**
  String get profileSectionPrivacyAndTime;

  /// Card background sheet: remove
  ///
  /// In en, this message translates to:
  /// **'Remove card background'**
  String get removeCardBackground;

  /// Cover photo sheet: remove
  ///
  /// In en, this message translates to:
  /// **'Remove cover'**
  String get removeCover;

  /// Featured topic sheet: clear
  ///
  /// In en, this message translates to:
  /// **'Remove featured topic'**
  String get removeFeaturedTopic;

  /// Time zone sheet: search field
  ///
  /// In en, this message translates to:
  /// **'Search time zones'**
  String get searchTimezones;

  /// Featured topic sheet: search field
  ///
  /// In en, this message translates to:
  /// **'Search your topics'**
  String get searchYourTopics;

  /// Edit profile: app bar button
  ///
  /// In en, this message translates to:
  /// **'See your profile as others do'**
  String get seeProfileAsOthersDo;

  /// Edit profile: the person's time zone, and its sheet's title
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get timezone;

  /// Snackbar after choosing a time zone, with Undo
  ///
  /// In en, this message translates to:
  /// **'Time zone changed to {zone}'**
  String timezoneChangedTo(String zone);

  /// Edit profile: the time zone and the time there now
  ///
  /// In en, this message translates to:
  /// **'{zone} · {time} now'**
  String timezoneWithTime(String zone, String time);

  /// Time zone sheet: heading over the zones at the phone's UTC offset
  ///
  /// In en, this message translates to:
  /// **'Matches this phone\'s clock ({offset})'**
  String timezonesMatchingPhone(String offset);

  /// Snackbar after choosing a title, with Undo
  ///
  /// In en, this message translates to:
  /// **'Title changed to {title}'**
  String titleChangedTo(String title);

  /// Title sheet: the title comes from a badge
  ///
  /// In en, this message translates to:
  /// **'Badge'**
  String get titleFromBadge;

  /// Title sheet: the title comes from a badge earned then
  ///
  /// In en, this message translates to:
  /// **'Badge · earned {date}'**
  String titleFromBadgeEarned(String date);

  /// Title sheet: the title comes from this group
  ///
  /// In en, this message translates to:
  /// **'{group} group'**
  String titleFromGroup(String group);

  /// Title sheet: the current title was set by staff
  ///
  /// In en, this message translates to:
  /// **'Given by the forum\'s staff'**
  String get titleGrantedByStaff;

  /// Snackbar after removing the title, with Undo
  ///
  /// In en, this message translates to:
  /// **'Title removed'**
  String get titleRemoved;

  /// Title sheet: explanation
  ///
  /// In en, this message translates to:
  /// **'Shown after your name on your profile and posts.'**
  String get titleSheetHint;

  /// Edit profile: the person's @username
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Change username dialog: the name is free
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get usernameAvailable;

  /// Snackbar after changing the username
  ///
  /// In en, this message translates to:
  /// **'Your username is now @{username}'**
  String usernameChanged(String username);

  /// Snackbar when tapping a locked username
  ///
  /// In en, this message translates to:
  /// **'This forum lets members change their username only shortly after joining. A moderator can change it for you.'**
  String get usernameLockedExplanation;

  /// Profile picture sheet: the photo uploaded earlier
  ///
  /// In en, this message translates to:
  /// **'Your photo'**
  String get yourPhoto;

  /// Status sheet: the emoji button, and the emoji picker's title
  ///
  /// In en, this message translates to:
  /// **'Choose emoji'**
  String get chooseEmoji;

  /// Status sheet: remove the status now
  ///
  /// In en, this message translates to:
  /// **'Clear status'**
  String get clearStatus;

  /// Tooltip of a button that empties a text field
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearText;

  /// Status sheet: the status clears in an hour
  ///
  /// In en, this message translates to:
  /// **'In one hour'**
  String get inOneHour;

  /// Status sheet: the status never clears on its own
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// Status sheet: switch, as Discourse's own status dialog has it
  ///
  /// In en, this message translates to:
  /// **'Pause notifications'**
  String get pauseNotifications;

  /// Status sheet: under Pause notifications
  ///
  /// In en, this message translates to:
  /// **'Until your status clears'**
  String get pauseNotificationsUntilStatusClears;

  /// Status sheet: choose when the status clears
  ///
  /// In en, this message translates to:
  /// **'Pick a time'**
  String get pickATime;

  /// Status sheet: heading over when the status clears
  ///
  /// In en, this message translates to:
  /// **'Remove status'**
  String get removeStatusAfter;

  /// Emoji picker: search field
  ///
  /// In en, this message translates to:
  /// **'Search emoji'**
  String get searchEmoji;

  /// Status sheet title
  ///
  /// In en, this message translates to:
  /// **'Set status'**
  String get setStatus;

  /// Profile tab and your profile: when you have no status
  ///
  /// In en, this message translates to:
  /// **'Set a status'**
  String get setAStatus;

  /// Snackbar after setting or clearing the status
  ///
  /// In en, this message translates to:
  /// **'Status updated'**
  String get statusUpdated;

  /// Status sheet: the status text field, as Discourse words it
  ///
  /// In en, this message translates to:
  /// **'What are you doing?'**
  String get whatAreYouDoing;

  /// User card: when they last posted, e.g. 'Posted 2 hours ago'
  ///
  /// In en, this message translates to:
  /// **'Posted {when}'**
  String cardPosted(String when);

  /// User card: change your own card background
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// User card menu
  ///
  /// In en, this message translates to:
  /// **'Copy link to profile'**
  String get copyProfileLink;

  /// User card menu: hide this person's posts and notifications
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get ignore;

  /// User card of a private profile: their primary group
  ///
  /// In en, this message translates to:
  /// **'Member of {group}'**
  String memberOfGroup(String group);

  /// User card menu: stop notifications from this person
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// User card menu
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// Accessibility label of the picture on a user card
  ///
  /// In en, this message translates to:
  /// **'Open @{username}\'s profile'**
  String openProfileOf(String username);

  /// User card of someone who hides their profile
  ///
  /// In en, this message translates to:
  /// **'{username} keeps their profile private.'**
  String profileIsPrivate(String username);

  /// User card opened from a topic
  ///
  /// In en, this message translates to:
  /// **'Show only {name}\'s {count, plural, =1{post} other{{count} posts}} in this topic'**
  String showOnlyTheirPostsHere(String name, int count);

  /// Your own user card opened from a topic
  ///
  /// In en, this message translates to:
  /// **'Show only your {count, plural, =1{post} other{{count} posts}} in this topic'**
  String showOnlyYourPostsHere(int count);

  /// Snackbar after ignoring someone from their card
  ///
  /// In en, this message translates to:
  /// **'Ignoring @{username} for 4 months'**
  String userIgnoredFor4Months(String username);

  /// Snackbar after muting someone
  ///
  /// In en, this message translates to:
  /// **'Muted @{username}'**
  String userMuted(String username);

  /// Snackbar after unmuting someone
  ///
  /// In en, this message translates to:
  /// **'Unmuted @{username}'**
  String userUnmuted(String username);

  /// User card: after your own name
  ///
  /// In en, this message translates to:
  /// **'(you)'**
  String get youParenthetical;

  /// Discourse topic_statuses.*: the help text of a status icon before the topic title, and the reason line beside the footer Pinned button
  ///
  /// In en, this message translates to:
  /// **'This topic is closed; it no longer accepts new replies'**
  String get topicStatusClosedHelp;

  /// Discourse topic_statuses.*: the help text of a status icon before the topic title, and the reason line beside the footer Pinned button
  ///
  /// In en, this message translates to:
  /// **'This topic is archived; it is frozen and cannot be changed'**
  String get topicStatusArchivedHelp;

  /// Discourse topic_statuses.*: the help text of a status icon before the topic title, and the reason line beside the footer Pinned button
  ///
  /// In en, this message translates to:
  /// **'This topic is closed and archived; it no longer accepts new replies and cannot be changed'**
  String get topicStatusClosedArchivedHelp;

  /// Discourse topic_statuses.*: the help text of a status icon before the topic title, and the reason line beside the footer Pinned button
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get topicStatusPinnedTitle;

  /// Discourse topic_statuses.*: the help text of a status icon before the topic title, and the reason line beside the footer Pinned button
  ///
  /// In en, this message translates to:
  /// **'This topic is pinned for you; it will display at the top of its category'**
  String get topicStatusPinnedHelp;

  /// Discourse topic_statuses.*: the help text of a status icon before the topic title, and the reason line beside the footer Pinned button
  ///
  /// In en, this message translates to:
  /// **'Pinned Globally'**
  String get topicStatusPinnedGloballyTitle;

  /// Discourse topic_statuses.*: the help text of a status icon before the topic title, and the reason line beside the footer Pinned button
  ///
  /// In en, this message translates to:
  /// **'This topic is pinned globally; it will display at the top of latest and its category'**
  String get topicStatusPinnedGloballyHelp;

  /// Discourse topic_statuses.*: the help text of a status icon before the topic title, and the reason line beside the footer Pinned button
  ///
  /// In en, this message translates to:
  /// **'Unpinned'**
  String get topicStatusUnpinnedTitle;

  /// Discourse topic_statuses.*: the help text of a status icon before the topic title, and the reason line beside the footer Pinned button
  ///
  /// In en, this message translates to:
  /// **'This topic is unpinned for you; it will display in regular order'**
  String get topicStatusUnpinnedHelp;

  /// Discourse topic_statuses.*: the help text of a status icon before the topic title, and the reason line beside the footer Pinned button
  ///
  /// In en, this message translates to:
  /// **'This topic is unlisted; it will not be displayed in topic lists, and can only be accessed via a direct link.'**
  String get topicStatusUnlistedHelp;

  /// Discourse topic_statuses.*: the help text of a status icon before the topic title, and the reason line beside the footer Pinned button
  ///
  /// In en, this message translates to:
  /// **'This is an official warning.'**
  String get topicStatusWarningHelp;

  /// Discourse topic.notifications.reasons.*: why the reader gets notifications about this topic, under the footer notification button
  ///
  /// In en, this message translates to:
  /// **'You will receive notifications because you are watching a tag on this topic.'**
  String get notificationReasonWatchingTag;

  /// Discourse topic.notifications.reasons.*: why the reader gets notifications about this topic, under the footer notification button
  ///
  /// In en, this message translates to:
  /// **'You will receive notifications because you are watching this category.'**
  String get notificationReasonWatchingCategory;

  /// Discourse topic.notifications.reasons.*: why the reader gets notifications about this topic, under the footer notification button
  ///
  /// In en, this message translates to:
  /// **'You will receive notifications because you started watching this topic automatically.'**
  String get notificationReasonWatchingAuto;

  /// Discourse topic.notifications.reasons.*: why the reader gets notifications about this topic, under the footer notification button
  ///
  /// In en, this message translates to:
  /// **'You will receive notifications because you are watching this topic.'**
  String get notificationReasonWatching;

  /// Discourse topic.notifications.reasons.*: why the reader gets notifications about this topic, under the footer notification button
  ///
  /// In en, this message translates to:
  /// **'You will receive notifications because you created this topic.'**
  String get notificationReasonWatchingCreated;

  /// Discourse topic.notifications.reasons.*: why the reader gets notifications about this topic, under the footer notification button
  ///
  /// In en, this message translates to:
  /// **'You will see a count of new replies because you are tracking this category.'**
  String get notificationReasonTrackingCategory;

  /// Discourse topic.notifications.reasons.*: why the reader gets notifications about this topic, under the footer notification button
  ///
  /// In en, this message translates to:
  /// **'You will see a count of new replies because you posted a reply to this topic.'**
  String get notificationReasonTrackingReplied;

  /// Discourse topic.notifications.reasons.*: why the reader gets notifications about this topic, under the footer notification button
  ///
  /// In en, this message translates to:
  /// **'You will see a count of new replies because you are tracking this topic.'**
  String get notificationReasonTracking;

  /// Discourse topic.notifications.reasons.*: why the reader gets notifications about this topic, under the footer notification button
  ///
  /// In en, this message translates to:
  /// **'You will see a count of new replies because you read this topic.'**
  String get notificationReasonTrackingRead;

  /// Discourse topic.notifications.reasons.*: why the reader gets notifications about this topic, under the footer notification button
  ///
  /// In en, this message translates to:
  /// **'You will be notified if someone mentions your @name or replies to you.'**
  String get notificationReasonNormal;

  /// Discourse topic.notifications.reasons.*: why the reader gets notifications about this topic, under the footer notification button
  ///
  /// In en, this message translates to:
  /// **'You are ignoring all notifications in this category.'**
  String get notificationReasonMutedCategory;

  /// Discourse topic.notifications.reasons.*: why the reader gets notifications about this topic, under the footer notification button
  ///
  /// In en, this message translates to:
  /// **'You are ignoring all notifications on this topic.'**
  String get notificationReasonMuted;

  /// Discourse notification level name
  ///
  /// In en, this message translates to:
  /// **'Watching'**
  String get notificationLevelWatching;

  /// Discourse notification level name
  ///
  /// In en, this message translates to:
  /// **'Watching First Post'**
  String get notificationLevelWatchingFirstPost;

  /// Discourse notification level name
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get notificationLevelTracking;

  /// Discourse notification level name
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get notificationLevelNormal;

  /// Discourse notification level name
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get notificationLevelMuted;

  /// Discourse notification level description in the level picker
  ///
  /// In en, this message translates to:
  /// **'You will be notified of every new reply in this topic, and a count of new replies will be shown.'**
  String get topicWatchingDescription;

  /// Discourse notification level description in the level picker
  ///
  /// In en, this message translates to:
  /// **'A count of new replies will be shown for this topic. You will be notified if someone mentions your @name or replies to you.'**
  String get topicTrackingDescription;

  /// Discourse notification level description in the level picker
  ///
  /// In en, this message translates to:
  /// **'You will be notified if someone mentions your @name or replies to you.'**
  String get topicNormalDescription;

  /// Discourse notification level description in the level picker
  ///
  /// In en, this message translates to:
  /// **'You will never be notified of anything about this topic, and it will not appear in latest.'**
  String get topicMutedDescription;

  /// Discourse notification level description in the level picker
  ///
  /// In en, this message translates to:
  /// **'You will be notified of every new reply in this message, and a count of new replies will be shown.'**
  String get messageWatchingDescription;

  /// Discourse notification level description in the level picker
  ///
  /// In en, this message translates to:
  /// **'A count of new replies will be shown for this message. You will be notified if someone mentions your @name or replies to you.'**
  String get messageTrackingDescription;

  /// Discourse notification level description in the level picker
  ///
  /// In en, this message translates to:
  /// **'You will be notified if someone mentions your @name or replies to you.'**
  String get messageNormalDescription;

  /// Discourse notification level description in the level picker
  ///
  /// In en, this message translates to:
  /// **'You will never be notified of anything about this message.'**
  String get messageMutedDescription;

  /// Discourse notification level description in the level picker
  ///
  /// In en, this message translates to:
  /// **'You will automatically watch all topics in this category. You will be notified of every new post in every topic, and a count of new replies will be shown.'**
  String get categoryWatchingDescription;

  /// Discourse notification level description in the level picker
  ///
  /// In en, this message translates to:
  /// **'You will be notified of new topics in this category but not replies to the topics.'**
  String get categoryWatchingFirstPostDescription;

  /// Discourse notification level description in the level picker
  ///
  /// In en, this message translates to:
  /// **'You will automatically track all topics in this category. You will be notified if someone mentions your @name or replies to you, and a count of new replies will be shown.'**
  String get categoryTrackingDescription;

  /// Discourse notification level description in the level picker
  ///
  /// In en, this message translates to:
  /// **'You will be notified if someone mentions your @name or replies to you.'**
  String get categoryNormalDescription;

  /// Discourse notification level description in the level picker
  ///
  /// In en, this message translates to:
  /// **'You will never be notified of anything about new topics in this category, and they will not appear in latest.'**
  String get categoryMutedDescription;

  /// Discourse notification level description in the level picker
  ///
  /// In en, this message translates to:
  /// **'You will automatically watch all topics with this tag. You will be notified of all new posts and topics, plus the count of unread and new posts will also appear next to the topic.'**
  String get tagWatchingDescription;

  /// Discourse notification level description in the level picker
  ///
  /// In en, this message translates to:
  /// **'You will be notified of new topics in this tag but not replies to the topics.'**
  String get tagWatchingFirstPostDescription;

  /// Discourse notification level description in the level picker
  ///
  /// In en, this message translates to:
  /// **'You will automatically track all topics with this tag. A count of unread and new posts will appear next to the topic.'**
  String get tagTrackingDescription;

  /// Discourse notification level description in the level picker
  ///
  /// In en, this message translates to:
  /// **'You will be notified if someone mentions your @name or replies to your post.'**
  String get tagNormalDescription;

  /// Discourse notification level description in the level picker
  ///
  /// In en, this message translates to:
  /// **'You will not be notified of anything about new topics with this tag, and they will not appear on your unread tab.'**
  String get tagMutedDescription;

  /// Discourse topic.status_update_notice.*: the topic timer notice under the last post. {timeLeft} is a relative time such as "in 3 days"; {duration} a length such as "3 days"
  ///
  /// In en, this message translates to:
  /// **'This topic will automatically open {timeLeft}.'**
  String topicTimerAutoOpen(String timeLeft);

  /// Discourse topic.status_update_notice.*: the topic timer notice under the last post. {timeLeft} is a relative time such as "in 3 days"; {duration} a length such as "3 days"
  ///
  /// In en, this message translates to:
  /// **'This topic will automatically close {timeLeft}.'**
  String topicTimerAutoClose(String timeLeft);

  /// Discourse topic.status_update_notice.*: the topic timer notice under the last post. {timeLeft} is a relative time such as "in 3 days"; {duration} a length such as "3 days"
  ///
  /// In en, this message translates to:
  /// **'This topic will be published to #{categoryName} {timeLeft}.'**
  String topicTimerAutoPublish(String categoryName, String timeLeft);

  /// Discourse topic.status_update_notice.*: the topic timer notice under the last post. {timeLeft} is a relative time such as "in 3 days"; {duration} a length such as "3 days"
  ///
  /// In en, this message translates to:
  /// **'This topic will close {duration} after the last reply.'**
  String topicTimerAutoCloseAfterLastPost(String duration);

  /// Discourse topic.status_update_notice.*: the topic timer notice under the last post. {timeLeft} is a relative time such as "in 3 days"; {duration} a length such as "3 days"
  ///
  /// In en, this message translates to:
  /// **'This topic will be deleted {duration} after the last reply.'**
  String topicTimerAutoDeleteAfterLastPost(String duration);

  /// Discourse topic.status_update_notice.*: the topic timer notice under the last post. {timeLeft} is a relative time such as "in 3 days"; {duration} a length such as "3 days"
  ///
  /// In en, this message translates to:
  /// **'This topic will be automatically deleted {timeLeft}.'**
  String topicTimerAutoDelete(String timeLeft);

  /// Discourse topic.status_update_notice.*: the topic timer notice under the last post. {timeLeft} is a relative time such as "in 3 days"; {duration} a length such as "3 days"
  ///
  /// In en, this message translates to:
  /// **'This topic will be automatically bumped {timeLeft}.'**
  String topicTimerAutoBump(String timeLeft);

  /// Discourse topic.status_update_notice.*: the topic timer notice under the last post. {timeLeft} is a relative time such as "in 3 days"; {duration} a length such as "3 days"
  ///
  /// In en, this message translates to:
  /// **'Replies on this topic are automatically deleted after {duration}.'**
  String topicTimerAutoDeleteReplies(String duration);

  /// Discourse topic.slow_mode_notice.duration, under the last post of a topic in slow mode
  ///
  /// In en, this message translates to:
  /// **'Please wait {duration} between your posts in this topic.'**
  String slowModeNotice(String duration);

  /// Discourse wording for a topic action or its confirmation (topic.actions, topic.feature, post.controls), or the snackbar after it
  ///
  /// In en, this message translates to:
  /// **'Close Topic'**
  String get closeTopic;

  /// Discourse wording for a topic action or its confirmation (topic.actions, topic.feature, post.controls), or the snackbar after it
  ///
  /// In en, this message translates to:
  /// **'Open Topic'**
  String get openTopic;

  /// Discourse wording for a topic action or its confirmation (topic.actions, topic.feature, post.controls), or the snackbar after it
  ///
  /// In en, this message translates to:
  /// **'Pin Topic'**
  String get pinTopic;

  /// Discourse wording for a topic action or its confirmation (topic.actions, topic.feature, post.controls), or the snackbar after it
  ///
  /// In en, this message translates to:
  /// **'Un-Pin Topic'**
  String get unpinTopic;

  /// Discourse wording for a topic action or its confirmation (topic.actions, topic.feature, post.controls), or the snackbar after it
  ///
  /// In en, this message translates to:
  /// **'Archive Topic'**
  String get archiveTopic;

  /// Discourse wording for a topic action or its confirmation (topic.actions, topic.feature, post.controls), or the snackbar after it
  ///
  /// In en, this message translates to:
  /// **'Unarchive Topic'**
  String get unarchiveTopic;

  /// Discourse wording for a topic action or its confirmation (topic.actions, topic.feature, post.controls), or the snackbar after it
  ///
  /// In en, this message translates to:
  /// **'Unlist Topic'**
  String get unlistTopic;

  /// Discourse wording for a topic action or its confirmation (topic.actions, topic.feature, post.controls), or the snackbar after it
  ///
  /// In en, this message translates to:
  /// **'List Topic'**
  String get listTopic;

  /// Discourse wording for a topic action or its confirmation (topic.actions, topic.feature, post.controls), or the snackbar after it
  ///
  /// In en, this message translates to:
  /// **'Permanently delete'**
  String get permanentlyDelete;

  /// Discourse wording for a topic action or its confirmation (topic.actions, topic.feature, post.controls), or the snackbar after it
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. This will permanently delete this topic and remove it from the database.'**
  String get permanentlyDeleteTopicConfirmation;

  /// Discourse wording for a topic action or its confirmation (topic.actions, topic.feature, post.controls), or the snackbar after it
  ///
  /// In en, this message translates to:
  /// **'Yes, delete this topic'**
  String get deleteTopicConfirmYes;

  /// Discourse wording for a topic action or its confirmation (topic.actions, topic.feature, post.controls), or the snackbar after it
  ///
  /// In en, this message translates to:
  /// **'No, keep this topic'**
  String get deleteTopicConfirmNo;

  /// Discourse wording for a topic action or its confirmation (topic.actions, topic.feature, post.controls), or the snackbar after it
  ///
  /// In en, this message translates to:
  /// **'Topic pinned'**
  String get topicPinned;

  /// Discourse wording for a topic action or its confirmation (topic.actions, topic.feature, post.controls), or the snackbar after it
  ///
  /// In en, this message translates to:
  /// **'Topic unpinned'**
  String get topicUnpinned;

  /// Discourse wording for a topic action or its confirmation (topic.actions, topic.feature, post.controls), or the snackbar after it
  ///
  /// In en, this message translates to:
  /// **'Topic archived'**
  String get topicArchived;

  /// Discourse wording for a topic action or its confirmation (topic.actions, topic.feature, post.controls), or the snackbar after it
  ///
  /// In en, this message translates to:
  /// **'Topic unarchived'**
  String get topicUnarchived;

  /// Discourse wording for a topic action or its confirmation (topic.actions, topic.feature, post.controls), or the snackbar after it
  ///
  /// In en, this message translates to:
  /// **'Topic unlisted'**
  String get topicUnlisted;

  /// Discourse wording for a topic action or its confirmation (topic.actions, topic.feature, post.controls), or the snackbar after it
  ///
  /// In en, this message translates to:
  /// **'Topic listed'**
  String get topicListed;

  /// Discourse wording for a topic action or its confirmation (topic.actions, topic.feature, post.controls), or the snackbar after it
  ///
  /// In en, this message translates to:
  /// **'Topic un-deleted'**
  String get topicRecovered;

  /// Discourse wording for a topic action or its confirmation (topic.actions, topic.feature, post.controls), or the snackbar after it
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update the topic: {error}'**
  String topicActionFailed(String error);

  /// A length of time, e.g. "3 days"
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String durationMinutes(int count);

  /// A length of time, e.g. "3 days"
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour} other{{count} hours}}'**
  String durationHours(int count);

  /// A length of time, e.g. "3 days"
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String durationDays(int count);

  /// A time from now, e.g. "in 3 days", for the topic timer notices
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{in 1 minute} other{in {count} minutes}}'**
  String timeLeftMinutes(int count);

  /// A time from now, e.g. "in 3 days", for the topic timer notices
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{in 1 hour} other{in {count} hours}}'**
  String timeLeftHours(int count);

  /// A time from now, e.g. "in 3 days", for the topic timer notices
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{in 1 day} other{in {count} days}}'**
  String timeLeftDays(int count);

  /// Help text of the deleted-topic icon before the title (staff only see deleted topics)
  ///
  /// In en, this message translates to:
  /// **'This topic is deleted and hidden from other users'**
  String get topicStatusDeletedHelp;

  /// Discourse post.controls.flag_action: the post menu item that opens the flag dialog
  ///
  /// In en, this message translates to:
  /// **'Flag'**
  String get flagAction;

  /// Discourse flagging.action: title of the flag dialog
  ///
  /// In en, this message translates to:
  /// **'Flag Post'**
  String get flagPost;

  /// Discourse sign_up: the button that opens the forum sign-up page
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Staff suspending a user from their profile, in Discourse's admin wording (admin.user.suspend*)
  ///
  /// In en, this message translates to:
  /// **'Suspend User'**
  String get suspendUser;

  /// Staff suspending a user from their profile, in Discourse's admin wording (admin.user.suspend*)
  ///
  /// In en, this message translates to:
  /// **'Unsuspend'**
  String get unsuspend;

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
  /// **'Something went wrong suspending this user: {error}'**
  String failedToSuspendUser(String error);

  /// Staff suspending a user from their profile, in Discourse's admin wording (admin.user.suspend*)
  ///
  /// In en, this message translates to:
  /// **'Something went wrong unsuspending this user: {error}'**
  String failedToUnsuspendUser(String error);

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

  /// Snackbar while a flag is being sent
  ///
  /// In en, this message translates to:
  /// **'Flagging post…'**
  String get flaggingPost;

  /// Staff suspending a user from their profile, in Discourse's admin wording (admin.user.suspend*)
  ///
  /// In en, this message translates to:
  /// **'Choose when the suspension ends'**
  String get pleaseSelectSuspensionEndDate;

  /// Staff suspending a user from their profile, in Discourse's admin wording (admin.user.suspend*)
  ///
  /// In en, this message translates to:
  /// **'Suspending user…'**
  String get suspendingUser;

  /// Staff suspending a user from their profile, in Discourse's admin wording (admin.user.suspend*)
  ///
  /// In en, this message translates to:
  /// **'Unsuspending user…'**
  String get unsuspendingUser;

  /// Staff suspending a user from their profile, in Discourse's admin wording (admin.user.suspend*)
  ///
  /// In en, this message translates to:
  /// **'User suspended'**
  String get userSuspended;

  /// Staff suspending a user from their profile, in Discourse's admin wording (admin.user.suspend*)
  ///
  /// In en, this message translates to:
  /// **'User unsuspended'**
  String get userUnsuspended;

  /// Staff suspending a user from their profile, in Discourse's admin wording (admin.user.suspend*)
  ///
  /// In en, this message translates to:
  /// **'Unsuspend {username}? They will be able to log in again.'**
  String unsuspendUserConfirmation(String username);

  /// Empty state of the Categories view
  ///
  /// In en, this message translates to:
  /// **'There are no categories to display.'**
  String get noCategoriesToDisplay;

  /// Notice on a category whose topics the reader may not see
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to view topics in this category.'**
  String get noPermissionToViewCategory;

  /// Title of the staff sheet that pins a topic (Discourse topic.feature_topic.title)
  ///
  /// In en, this message translates to:
  /// **'Feature this topic'**
  String get featureTopicTitle;

  /// Topic ⋮ menu item that opens the pin sheet (Discourse topic.actions.pin)
  ///
  /// In en, this message translates to:
  /// **'Pin Topic…'**
  String get pinTopicMenu;

  /// Pin sheet: pin in the topic's category, followed by a date
  ///
  /// In en, this message translates to:
  /// **'Make this topic appear at the top of the {category} category until'**
  String pinInCategoryUntil(String category);

  /// Pin sheet: pin at the top of every topic list, followed by a date
  ///
  /// In en, this message translates to:
  /// **'Make this topic appear at the top of all topic lists until'**
  String get pinGloballyUntil;

  /// Pin sheet note
  ///
  /// In en, this message translates to:
  /// **'Users can unpin the topic individually for themselves.'**
  String get pinNote;

  /// Pin sheet: the end-date field's label
  ///
  /// In en, this message translates to:
  /// **'Pin until'**
  String get pinUntil;

  /// Pin sheet: shown when no end date is chosen
  ///
  /// In en, this message translates to:
  /// **'A date is required to pin this topic.'**
  String get pinDateRequired;

  /// Pin sheet button
  ///
  /// In en, this message translates to:
  /// **'Pin Topic Globally'**
  String get pinTopicGlobally;

  /// Snackbar after a flag is filed
  ///
  /// In en, this message translates to:
  /// **'Thanks for keeping our community civil!'**
  String get flagThanks;

  /// Flag dialog intro
  ///
  /// In en, this message translates to:
  /// **'All flags are received by moderators and will be reviewed as soon as possible.'**
  String get flagReviewProcess;

  /// Flag dialog: flagging is not possible now
  ///
  /// In en, this message translates to:
  /// **'Sorry, you can\'t flag this post at this time.'**
  String get flagCant;

  /// Flag dialog button when the choice messages the author
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get flagSendMessage;

  /// Flag dialog: label of the message to the post's author
  ///
  /// In en, this message translates to:
  /// **'Message for the user'**
  String get flagMessageForUser;

  /// Flag dialog: label of the message to staff
  ///
  /// In en, this message translates to:
  /// **'Message for the moderators'**
  String get flagMessageForModerators;

  /// Flag dialog: hint for the message to the author
  ///
  /// In en, this message translates to:
  /// **'Be specific, be constructive, and always be kind.'**
  String get flagPlaceholderNotifyUser;

  /// Flag dialog: hint for the message to staff
  ///
  /// In en, this message translates to:
  /// **'Let us know specifically what you are concerned about, and provide relevant links and examples where possible.'**
  String get flagPlaceholderNotifyModerators;

  /// Flag dialog: hint for an illegal-content flag
  ///
  /// In en, this message translates to:
  /// **'Let us know specifically why you believe this content is illegal, and provide relevant links and examples where possible.'**
  String get flagPlaceholderIllegal;

  /// Flag dialog: checkbox required for an illegal-content flag
  ///
  /// In en, this message translates to:
  /// **'What I’ve written above is accurate and complete.'**
  String get flagConfirmIllegal;

  /// Flag dialog: the message is too short
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{enter at least {count} character} other{enter at least {count} characters}}'**
  String flagMessageAtLeast(int count);

  /// Snackbar after the message to the post's author is sent
  ///
  /// In en, this message translates to:
  /// **'Your message has been sent.'**
  String get flagMessageSent;

  /// Snackbar when merging a topic fails (Discourse topic.merge_topic.error)
  ///
  /// In en, this message translates to:
  /// **'There was an error moving posts into that topic.'**
  String get mergeTopicError;

  /// Hint in the rename-topic field (Discourse composer.title_placeholder)
  ///
  /// In en, this message translates to:
  /// **'What is this discussion about in one brief sentence?'**
  String get topicTitlePlaceholder;

  /// Snackbar after staff move a topic to another category
  ///
  /// In en, this message translates to:
  /// **'Topic moved'**
  String get topicMoved;

  /// Snackbar after staff merge a topic into another
  ///
  /// In en, this message translates to:
  /// **'Topic merged'**
  String get topicMerged;

  /// Merge-into-topic dialog text
  ///
  /// In en, this message translates to:
  /// **'Every post in this topic moves into the topic you choose. This can\'t be undone in the app.'**
  String get mergeTopicExplanation;

  /// Merge-into-topic dialog: the target topic id field
  ///
  /// In en, this message translates to:
  /// **'Destination topic ID'**
  String get destinationTopicId;

  /// Topic list row: author name when the forum did not send one
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get topicAuthorUnknown;

  /// Home, Hot view: empty state (Discourse js.topics.none.hot)
  ///
  /// In en, this message translates to:
  /// **'There are no hot topics.'**
  String get noHotTopics;

  /// Home, New view, signed out: heading
  ///
  /// In en, this message translates to:
  /// **'Sign in to view new topics'**
  String get signInToViewNewTopics;

  /// Home, New view, signed out: explanation under the heading
  ///
  /// In en, this message translates to:
  /// **'New topics show what was created since your last visit.'**
  String get newTopicsSignInMessage;

  /// Home, Top view: period chip (Discourse js.filters.top.all_time)
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get topPeriodAllTime;

  /// Home, Top view: period chip (Discourse js.filters.top.this_year)
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get topPeriodYear;

  /// Home, Top view: period chip (Discourse js.filters.top.this_quarter)
  ///
  /// In en, this message translates to:
  /// **'Quarter'**
  String get topPeriodQuarter;

  /// Home, Top view: period chip (Discourse js.filters.top.this_month)
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get topPeriodMonth;

  /// Home, Top view: period chip (Discourse js.filters.top.this_week)
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get topPeriodWeek;

  /// Home, Top view: period chip (Discourse js.filters.top.today)
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get topPeriodToday;

  /// Home, Top view: empty state for the chosen period. period is the API name of the period chip: all, yearly, quarterly, monthly, weekly or daily (Discourse js.topics.none.top for other)
  ///
  /// In en, this message translates to:
  /// **'{period, select, all{No top topics of all time.} yearly{No top topics this year.} quarterly{No top topics this quarter.} monthly{No top topics this month.} weekly{No top topics this week.} daily{No top topics today.} other{There are no top topics.}}'**
  String noTopTopicsForPeriod(String period);

  /// Forum home: error when re-checking an already opened forum timed out
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. The site may be down or unreachable.'**
  String get connectionTimedOutSiteUnreachable;

  /// Notifications tab: snackbar when Dismiss all fails and the forum gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to mark notifications as read'**
  String get failedToMarkNotificationsRead;

  /// Forum header / app bar: the forum's name before it is known (the whole site, not a category)
  ///
  /// In en, this message translates to:
  /// **'Forum'**
  String get forumNameFallback;

  /// Forum header: shown when the forum has no description
  ///
  /// In en, this message translates to:
  /// **'No description available.'**
  String get noForumDescription;

  /// Notifications tab app bar: tooltip of the button that marks every notification read (Discourse js.user.dismiss_notifications)
  ///
  /// In en, this message translates to:
  /// **'Dismiss all'**
  String get dismissAllNotifications;

  /// Notifications tab: error dialog when a tapped notification names no post
  ///
  /// In en, this message translates to:
  /// **'Post ID is missing. Cannot navigate to the post.'**
  String get notificationPostIdMissing;

  /// Notifications tab: error dialog when a post notification names no topic
  ///
  /// In en, this message translates to:
  /// **'Topic ID is missing. Cannot navigate to the post.'**
  String get notificationTopicIdMissingForPost;

  /// Notifications tab: error dialog when a topic notification names no topic
  ///
  /// In en, this message translates to:
  /// **'Topic ID is missing. Cannot open the topic.'**
  String get notificationTopicIdMissing;

  /// Notifications tab: error dialog when a user notification names no user
  ///
  /// In en, this message translates to:
  /// **'Username is missing. Cannot open user profile.'**
  String get notificationUsernameMissing;

  /// Notifications tab: error dialog when a chat notification names no channel
  ///
  /// In en, this message translates to:
  /// **'Channel ID is missing. Cannot open the chat.'**
  String get notificationChannelIdMissing;

  /// Notifications tab: error dialog when a group message notification names no group
  ///
  /// In en, this message translates to:
  /// **'Group name is missing. Cannot open the inbox.'**
  String get notificationGroupNameMissingForInbox;

  /// Notifications tab: error dialog when a group notification names no group
  ///
  /// In en, this message translates to:
  /// **'Group name is missing. Cannot open the group.'**
  String get notificationGroupNameMissing;

  /// Notifications tab: error dialog for a notification the app cannot open
  ///
  /// In en, this message translates to:
  /// **'No action URL available for this notification type.'**
  String get notificationNoActionUrl;

  /// Notifications tab: error dialog when a badge notification cannot be resolved
  ///
  /// In en, this message translates to:
  /// **'Badge details are unavailable.'**
  String get notificationBadgeUnavailable;

  /// Notifications tab: error dialog when the earned badge could not be loaded
  ///
  /// In en, this message translates to:
  /// **'Could not load this badge.'**
  String get notificationBadgeLoadFailed;

  /// Title of a personal message opened from a notification that does not name its subject
  ///
  /// In en, this message translates to:
  /// **'Personal message'**
  String get personalMessageTitleFallback;

  /// Title of a topic opened from a notification that does not name it (Discourse js.topic.title)
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get topicTitleFallback;

  /// Notifications tab, signed out: heading
  ///
  /// In en, this message translates to:
  /// **'Sign in to view notifications'**
  String get signInToViewNotifications;

  /// Notifications tab, signed out: explanation under the heading
  ///
  /// In en, this message translates to:
  /// **'You need to be signed in to view your notifications.'**
  String get youNeedToBeSignedInToViewNotifications;

  /// Notifications tab, Unread filter: empty state
  ///
  /// In en, this message translates to:
  /// **'No unread notifications'**
  String get noUnreadNotifications;

  /// Notifications tab, All filter: empty state
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// Phone notification: body text when the push carried none
  ///
  /// In en, this message translates to:
  /// **'New notification'**
  String get newNotificationFallbackBody;

  /// Dialog title when a tapped phone notification cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Unable to open notification'**
  String get unableToOpenNotification;

  /// Dialog under 'Unable to open notification': the push named no site
  ///
  /// In en, this message translates to:
  /// **'Missing site information (site_id).'**
  String get notificationMissingSiteInfo;

  /// Dialog under 'Unable to open notification': the push's site could not be read
  ///
  /// In en, this message translates to:
  /// **'Invalid site information (site_id).'**
  String get notificationInvalidSiteInfo;

  /// Dialog under 'Unable to open notification': the push named no post
  ///
  /// In en, this message translates to:
  /// **'Missing post information (content_id).'**
  String get notificationMissingPostInfo;

  /// Dialog under 'Unable to open notification': the push named no personal message
  ///
  /// In en, this message translates to:
  /// **'Missing message information (conversation_id).'**
  String get notificationMissingMessageInfo;

  /// Dialog under 'Unable to open notification': the push named no user
  ///
  /// In en, this message translates to:
  /// **'Missing user information (sender_id).'**
  String get notificationMissingUserInfo;

  /// Dialog under 'Unable to open notification': a kind of push the app does not know
  ///
  /// In en, this message translates to:
  /// **'Unsupported notification type.'**
  String get notificationUnsupportedType;

  /// Dialog under 'Unable to open notification': the push's forum is not one the app has
  ///
  /// In en, this message translates to:
  /// **'Forum not found for this site.'**
  String get notificationForumNotFound;

  /// Dialog under 'Unable to open notification': the forum could not be opened
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize the forum.'**
  String get notificationForumOpenFailed;

  /// Dialog under 'Unable to open notification': the push named no topic
  ///
  /// In en, this message translates to:
  /// **'Missing topic information (topic_id).'**
  String get notificationMissingTopicInfo;

  /// Tags page: error when the tag list fails and the forum gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to load tags.'**
  String get failedToLoadTags;

  /// Tags page: placeholder of the filter field
  ///
  /// In en, this message translates to:
  /// **'Search tags…'**
  String get searchTagsHint;

  /// Tags page: tooltip of the sort button while sorted by topic count
  ///
  /// In en, this message translates to:
  /// **'Sorted by topic count — tap to switch to A→Z'**
  String get tagsSortedByCountTooltip;

  /// Tags page: tooltip of the sort button while sorted A→Z
  ///
  /// In en, this message translates to:
  /// **'Sorted alphabetically — tap to switch to popularity'**
  String get tagsSortedAlphabeticallyTooltip;

  /// Tags page: empty state when the forum has no tags
  ///
  /// In en, this message translates to:
  /// **'No tags yet on this forum.'**
  String get noTagsYet;

  /// Tags page and a tag's topic list: tooltip of the bell that sets the tag's notification level
  ///
  /// In en, this message translates to:
  /// **'Notification level'**
  String get tagNotificationLevelTooltip;

  /// A tag's topic list: error when it fails to load and the forum gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get tagTopicsLoadFailed;

  /// Search page: snackbar when a search fails, with the reason
  ///
  /// In en, this message translates to:
  /// **'Search failed: {error}'**
  String searchFailedWithError(String error);

  /// Search page app bar: tooltip of the button that opens the search filters
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get searchFiltersButtonTooltip;

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

  /// Bookmarks page: error when the forum's bookmarks cannot be reached at all
  ///
  /// In en, this message translates to:
  /// **'Bookmarks are unavailable'**
  String get bookmarksUnavailable;

  /// Bookmarks page: error when the list fails and the forum gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to load bookmarks'**
  String get failedToLoadBookmarks;

  /// Bookmarks page: snackbar when removing a bookmark fails
  ///
  /// In en, this message translates to:
  /// **'Failed to remove bookmark'**
  String get failedToRemoveBookmark;

  /// Bookmarks page: snackbar when changing a bookmark's label, reminder or pin fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update bookmark'**
  String get failedToUpdateBookmark;

  /// Bookmark reminder sheet: default title
  ///
  /// In en, this message translates to:
  /// **'Bookmark with reminder'**
  String get bookmarkWithReminder;

  /// Bookmark reminder sheet: option to bookmark without a reminder (Discourse keyboard_shortcuts_help.bookmarks.none)
  ///
  /// In en, this message translates to:
  /// **'No reminder'**
  String get noReminder;

  /// Drafts page: error when the list fails and the forum gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to load drafts.'**
  String get failedToLoadDrafts;

  /// Drafts page: snackbar when discarding a draft fails
  ///
  /// In en, this message translates to:
  /// **'Failed to discard draft'**
  String get failedToDiscardDraft;

  /// Message list (Inbox, Sent, Archive…): shown when the forum could not return the list and gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to load messages'**
  String get messagesLoadFailed;

  /// Message list: shown when the next page of messages could not be loaded and the forum gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to load more messages'**
  String get moreMessagesLoadFailed;

  /// Message list row: stands in for the name of who wrote last when the forum did not say
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get messageUnknownUser;

  /// Error detail when the forum or the system gave no reason (edit message page, saving an image). Discourse login.error
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownErrorFallback;

  /// Chat composer placeholder when the channel gives none
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get chatComposerDefaultHint;

  /// Chat channel title when the channel has no name, after a '#': '#channel 12'
  ///
  /// In en, this message translates to:
  /// **'channel {id}'**
  String chatChannelNumbered(Object id);

  /// Chat: a message could not be sent and the forum gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to send message.'**
  String get chatSendFailed;

  /// Chat: an edit to a message could not be saved and the forum gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to edit message.'**
  String get chatEditFailed;

  /// Chat: a message could not be deleted and the forum gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to delete message.'**
  String get chatDeleteFailed;

  /// Chat: shown when reacting to a message is not possible on this forum
  ///
  /// In en, this message translates to:
  /// **'Reactions are not supported here.'**
  String get chatReactionsUnsupported;

  /// Chat: adding or removing a reaction failed and the forum gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to update reaction.'**
  String get chatReactionFailed;

  /// Name shown for a file in a post or chat message that has no name of its own
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get attachmentDefaultName;

  /// File type label under an attached file's name (shown in capitals): an audio file
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get fileTypeAudio;

  /// File type label under an attached file's name (shown in capitals): a plain text file
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get fileTypeText;

  /// File type label under an attached file's name (shown in capitals): a compressed archive (zip, rar, 7z…)
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get fileTypeArchive;

  /// File type label under an attached file's name (shown in capitals) when the type is unknown
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get fileTypeFile;

  /// Why downloading an attached file failed: the server answered with an HTTP error code
  ///
  /// In en, this message translates to:
  /// **'Failed to download file: HTTP {status}'**
  String downloadFailedHttpStatus(String status);

  /// Why downloading an attached file failed: the server sent nothing
  ///
  /// In en, this message translates to:
  /// **'Downloaded file is empty'**
  String get downloadedFileEmpty;

  /// Why downloading an attached file failed, with the system's reason
  ///
  /// In en, this message translates to:
  /// **'Failed to download file: {error}'**
  String downloadFileFailed(String error);

  /// Composer: a picked file's extension is not one the forum allows; {allowed} is the forum's list, e.g. 'jpg, png, pdf'
  ///
  /// In en, this message translates to:
  /// **'File type .{extension} is not allowed. Allowed types: {allowed}'**
  String attachmentTypeNotAllowed(String extension, String allowed);

  /// Composer: a picked file (not an image, which can be resized) is larger than the forum allows; sizes like '12.3 MB'
  ///
  /// In en, this message translates to:
  /// **'File size ({size}) exceeds maximum of {max}'**
  String attachmentFileTooLarge(String size, String max);

  /// Composer: a picked file was refused before upload, with no more specific reason
  ///
  /// In en, this message translates to:
  /// **'File validation failed'**
  String get attachmentValidationFailed;

  /// Composer: the forum accepted an upload but did not say how to refer to it in the post, so it cannot be added
  ///
  /// In en, this message translates to:
  /// **'Upload succeeded but the server returned no reference for the file.'**
  String get uploadMissingReference;

  /// Full-screen image viewer: saving failed because the image is no longer in the cache (after 'Failed to save image:')
  ///
  /// In en, this message translates to:
  /// **'Image file not found'**
  String get imageFileNotFound;

  /// Full-screen video player: the video could not be played and the player gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to load video'**
  String get failedToLoadVideo;

  /// User profile page: shown when the user's profile could not be loaded and there is no more specific error
  ///
  /// In en, this message translates to:
  /// **'Failed to load user info.'**
  String get userInfoLoadFailed;

  /// User profile page: error dialog when the user's profile could not be loaded
  ///
  /// In en, this message translates to:
  /// **'Failed to load user info: {error}'**
  String userInfoLoadFailedWithError(String error);

  /// User profile page overflow menu: ignore this user (Discourse's Ignore User)
  ///
  /// In en, this message translates to:
  /// **'Ignore user'**
  String get profileMenuIgnoreUser;

  /// User profile page overflow menu: stop ignoring this user
  ///
  /// In en, this message translates to:
  /// **'Unignore user'**
  String get profileMenuUnignoreUser;

  /// Snackbar when ignoring or unignoring a user failed (profile page, ignored users page)
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update ignore state'**
  String get ignoreStateUpdateFailed;

  /// Snackbar after ignoring a user from their profile
  ///
  /// In en, this message translates to:
  /// **'You\'re ignoring @{username}. Their posts will be hidden.'**
  String profileNowIgnoringUser(String username);

  /// Snackbar fallback when ignoring/unignoring a user from their profile threw an error
  ///
  /// In en, this message translates to:
  /// **'Ignore toggle failed.'**
  String get profileIgnoreToggleFailed;

  /// Profile: the user's summary/stats could not be loaded
  ///
  /// In en, this message translates to:
  /// **'Could not load stats.'**
  String get profileStatsLoadFailed;

  /// Profile: snackbar when following a user failed
  ///
  /// In en, this message translates to:
  /// **'Failed to follow'**
  String get profileFollowFailed;

  /// Profile: snackbar when unfollowing a user failed
  ///
  /// In en, this message translates to:
  /// **'Failed to unfollow'**
  String get profileUnfollowFailed;

  /// Profile: snackbar when opening a chat (direct message channel) with the user failed
  ///
  /// In en, this message translates to:
  /// **'Could not open a chat with this user.'**
  String get profileChatOpenFailed;

  /// Profile summary: number of likes on a topic/reply row, or between the user and another person ('Most liked by')
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 like} other{{count} likes}}'**
  String summaryLikeCount(int count);

  /// Profile summary 'Top links': how many times a link was clicked (Discourse topic_map.clicks)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 click} other{{count} clicks}}'**
  String summaryLinkClicks(int count);

  /// Users directory period chip (Discourse filters.top.all_time)
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get directoryPeriodAllTime;

  /// Users directory period chip (Discourse filters.top.this_year)
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get directoryPeriodYear;

  /// Users directory period chip (Discourse filters.top.this_quarter)
  ///
  /// In en, this message translates to:
  /// **'Quarter'**
  String get directoryPeriodQuarter;

  /// Users directory period chip (Discourse filters.top.this_month)
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get directoryPeriodMonth;

  /// Users directory period chip (Discourse filters.top.this_week)
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get directoryPeriodWeek;

  /// Users directory period chip (Discourse filters.top.today)
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get directoryPeriodToday;

  /// Users directory sort chip, next to a heart icon: likes received (Discourse directory.likes_received)
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get directoryOrderReceived;

  /// Users directory sort chip: replies posted (Discourse directory.post_count)
  ///
  /// In en, this message translates to:
  /// **'Replies'**
  String get directoryOrderReplies;

  /// Users directory sort chip: topics created (Discourse directory.topic_count)
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get directoryOrderTopics;

  /// Users directory sort chip: days visited (Discourse directory.days_visited)
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get directoryOrderVisits;

  /// Users directory: the list could not be loaded
  ///
  /// In en, this message translates to:
  /// **'Failed to load directory.'**
  String get directoryLoadFailed;

  /// Users directory: a name search found nobody
  ///
  /// In en, this message translates to:
  /// **'No users match that name.'**
  String get directoryNoUsersMatch;

  /// Users directory: nobody in the chosen period
  ///
  /// In en, this message translates to:
  /// **'No users found for this period.'**
  String get directoryNoUsersForPeriod;

  /// User picker search: nothing found
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get userSearchNoResults;

  /// User picker search: hint under "No users found"
  ///
  /// In en, this message translates to:
  /// **'Try searching with a different username'**
  String get userSearchTryDifferentUsername;

  /// User picker: empty state before anything is searched
  ///
  /// In en, this message translates to:
  /// **'Search for users'**
  String get userSearchPromptTitle;

  /// User picker: hint under "Search for users"
  ///
  /// In en, this message translates to:
  /// **'Enter a username to find and invite users'**
  String get userSearchPromptHint;

  /// Ignored users page: snackbar fallback when unignoring threw an error
  ///
  /// In en, this message translates to:
  /// **'Unignore failed.'**
  String get ignoredUsersUnignoreFailed;

  /// Ignored users page: empty state
  ///
  /// In en, this message translates to:
  /// **'You\'re not ignoring anyone.'**
  String get ignoredUsersEmpty;

  /// Ignored users page: hint under the empty state; the quoted menu item is profileMenuIgnoreUser
  ///
  /// In en, this message translates to:
  /// **'Open a user profile and use \"Ignore user\" in the overflow menu to hide their posts and notifications.'**
  String get ignoredUsersEmptyHint;

  /// Badges page: the list could not be loaded
  ///
  /// In en, this message translates to:
  /// **'Failed to load badges.'**
  String get badgesLoadFailed;

  /// Badges page: the forum has no badges
  ///
  /// In en, this message translates to:
  /// **'No badges on this forum.'**
  String get badgesEmpty;

  /// Badge tier (section header on the badges page, label in the badge sheet)
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get badgeTierGold;

  /// Badge tier (section header on the badges page, label in the badge sheet)
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get badgeTierSilver;

  /// Badge tier (section header on the badges page, label in the badge sheet)
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get badgeTierBronze;

  /// Badge sheet: when the user earned the badge; {time} is a relative time such as '3 days ago'
  ///
  /// In en, this message translates to:
  /// **'Earned {time}'**
  String badgeEarnedAgo(String time);

  /// Badge sheet: how many users on the forum have the badge; {formatted} is the compact count (e.g. 1.2k)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Earned by {formatted} user} other{Earned by {formatted} users}}'**
  String badgeEarnedByUsers(int count, String formatted);

  /// Trust level 0 name (Discourse trust_levels.names.newuser)
  ///
  /// In en, this message translates to:
  /// **'New user'**
  String get trustLevelNameNewUser;

  /// Trust level 1 name (Discourse trust_levels.names.basic)
  ///
  /// In en, this message translates to:
  /// **'Basic user'**
  String get trustLevelNameBasic;

  /// Trust level 2 name (Discourse trust_levels.names.member)
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get trustLevelNameMember;

  /// Trust level 3 name (Discourse trust_levels.names.regular)
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get trustLevelNameRegular;

  /// Trust level 4 name (Discourse trust_levels.names.leader)
  ///
  /// In en, this message translates to:
  /// **'Leader'**
  String get trustLevelNameLeader;

  /// Trust levels sheet: what trust level 0 (new user) means
  ///
  /// In en, this message translates to:
  /// **'Just joined. Can read and post, with limits on links, images and messages.'**
  String get trustLevelSummary0;

  /// Trust levels sheet: what trust level 1 (basic user) means
  ///
  /// In en, this message translates to:
  /// **'Unlocks core posting features: images and attachments, more links, flagging posts.'**
  String get trustLevelSummary1;

  /// Trust levels sheet: what trust level 2 (member) means
  ///
  /// In en, this message translates to:
  /// **'Can send invites, ignore users, and edit their own posts for longer.'**
  String get trustLevelSummary2;

  /// Trust levels sheet: what trust level 3 (regular) means
  ///
  /// In en, this message translates to:
  /// **'Can recategorize and rename topics, create tags, and their spam flags carry more weight.'**
  String get trustLevelSummary3;

  /// Trust levels sheet: what trust level 4 (leader) means
  ///
  /// In en, this message translates to:
  /// **'Granted by staff. Can edit any post and pin, close, split or merge topics.'**
  String get trustLevelSummary4;

  /// Trust levels sheet row title: abbreviated level and its name, e.g. 'TL2 · Member' (TL = trust level; Discourse de uses VS, es NC)
  ///
  /// In en, this message translates to:
  /// **'TL{level} · {name}'**
  String trustLevelRowTitle(int level, String name);

  /// Profile activity list: shown when the list was opened without a user
  ///
  /// In en, this message translates to:
  /// **'No user specified'**
  String get profileNoUserSpecified;

  /// Profile: the user's topics could not be loaded
  ///
  /// In en, this message translates to:
  /// **'Failed to load topics'**
  String get userTopicsLoadFailed;

  /// Profile: the user has not started any topics
  ///
  /// In en, this message translates to:
  /// **'No topics started yet.'**
  String get userTopicsEmpty;

  /// Profile: the user's recent posts could not be loaded
  ///
  /// In en, this message translates to:
  /// **'Failed to load recent posts'**
  String get userRecentPostsLoadFailed;

  /// Profile activity row: title when the post's topic has no title
  ///
  /// In en, this message translates to:
  /// **'Unknown Topic'**
  String get activityUnknownTopic;

  /// Group page: snackbar after joining the group
  ///
  /// In en, this message translates to:
  /// **'You joined {group}'**
  String groupJoinedSnack(String group);

  /// Group page: joining the group failed
  ///
  /// In en, this message translates to:
  /// **'Failed to join group'**
  String get groupJoinFailed;

  /// Group page: snackbar after leaving the group
  ///
  /// In en, this message translates to:
  /// **'You left {group}'**
  String groupLeftSnack(String group);

  /// Group page: leaving the group failed
  ///
  /// In en, this message translates to:
  /// **'Failed to leave group'**
  String get groupLeaveFailed;

  /// Group page, request-to-join dialog: hint in the reason field
  ///
  /// In en, this message translates to:
  /// **'Why do you want to join? Group owners see this with your request.'**
  String get groupMembershipRequestHint;

  /// Group page: the request-to-join reason was left empty
  ///
  /// In en, this message translates to:
  /// **'A reason is required to request membership'**
  String get groupMembershipReasonRequired;

  /// Group page: snackbar after sending a request to join
  ///
  /// In en, this message translates to:
  /// **'Request sent — a group owner has to approve it'**
  String get groupMembershipRequestSent;

  /// Group page: sending the request to join failed
  ///
  /// In en, this message translates to:
  /// **'Failed to send membership request'**
  String get groupMembershipRequestFailed;

  /// Group page: chip shown when you are a member of the group and cannot leave it (Discourse groups.index.is_group_user)
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get groupMemberBadge;

  /// Group page: chip shown after you asked to join the group
  ///
  /// In en, this message translates to:
  /// **'Request pending'**
  String get groupRequestPending;

  /// Group page: the join button while joining
  ///
  /// In en, this message translates to:
  /// **'Joining…'**
  String get groupJoining;

  /// Group page: button to join a group anyone may join
  ///
  /// In en, this message translates to:
  /// **'Join group'**
  String get groupJoinButton;

  /// Groups page: the list could not be loaded
  ///
  /// In en, this message translates to:
  /// **'Failed to load groups.'**
  String get groupsLoadFailed;

  /// Groups page: subtitle of an automatic group (admins, staff, trust level groups)
  ///
  /// In en, this message translates to:
  /// **'Built-in group'**
  String get groupBuiltIn;

  /// Invites page filter chip (Discourse user.invited.pending_tab_with_count)
  ///
  /// In en, this message translates to:
  /// **'Pending ({count})'**
  String invitesPendingWithCount(int count);

  /// Invites page filter chip (Discourse user.invited.expired_tab_with_count)
  ///
  /// In en, this message translates to:
  /// **'Expired ({count})'**
  String invitesExpiredWithCount(int count);

  /// Invites page filter chip (Discourse user.invited.redeemed_tab_with_count)
  ///
  /// In en, this message translates to:
  /// **'Redeemed ({count})'**
  String invitesRedeemedWithCount(int count);

  /// Invites page: the list could not be loaded
  ///
  /// In en, this message translates to:
  /// **'Failed to load invites.'**
  String get invitesLoadFailed;

  /// Invites page: creating an invite link failed
  ///
  /// In en, this message translates to:
  /// **'Failed to create invite link'**
  String get inviteLinkCreateFailed;

  /// Invite by email dialog: email field label
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get inviteEmailAddressLabel;

  /// Invite by email dialog: the email field is empty or not an address
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get inviteEmailInvalid;

  /// Invite by email dialog: optional personal note field label
  ///
  /// In en, this message translates to:
  /// **'Message (optional)'**
  String get inviteMessageOptionalLabel;

  /// Invites page: sending an email invite failed
  ///
  /// In en, this message translates to:
  /// **'Failed to send invite'**
  String get inviteSendFailed;

  /// Revoke invite dialog body for a link invite
  ///
  /// In en, this message translates to:
  /// **'The invite link will stop working.'**
  String get revokeInviteLinkWarning;

  /// Revoke invite dialog body for an email invite
  ///
  /// In en, this message translates to:
  /// **'The invite to {email} will stop working.'**
  String revokeInviteEmailWarning(String email);

  /// Invites page: revoking an invite failed
  ///
  /// In en, this message translates to:
  /// **'Failed to revoke invite'**
  String get inviteRevokeFailed;

  /// Invites page: the user may not create invites
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to invite'**
  String get inviteNoPermission;

  /// Invites page: no pending invites
  ///
  /// In en, this message translates to:
  /// **'No pending invites'**
  String get invitesEmptyPending;

  /// Invites page: no expired invites
  ///
  /// In en, this message translates to:
  /// **'No expired invites'**
  String get invitesEmptyExpired;

  /// Invites page: no redeemed invites
  ///
  /// In en, this message translates to:
  /// **'No redeemed invites'**
  String get invitesEmptyRedeemed;

  /// Invites page: hint under "No pending invites"
  ///
  /// In en, this message translates to:
  /// **'Create an invite link to bring people to the forum.'**
  String get invitesEmptyPendingHint;

  /// Invites page: row title of a link invite whose URL is missing (Discourse user.invited.invite_link.title)
  ///
  /// In en, this message translates to:
  /// **'Invite link'**
  String get inviteLinkFallbackTitle;

  /// Invites page row: when the invite was redeemed; {date} is a date
  ///
  /// In en, this message translates to:
  /// **'Redeemed {date}'**
  String inviteRedeemedOn(String date);

  /// Invites page row: how many times a link invite was used out of its maximum
  ///
  /// In en, this message translates to:
  /// **'Redeemed {count} of {max}'**
  String inviteRedemptions(int count, int max);

  /// Invites page row: the email invite was sent
  ///
  /// In en, this message translates to:
  /// **'Email sent'**
  String get inviteEmailSent;

  /// Invites page row: the email invite was saved but not emailed
  ///
  /// In en, this message translates to:
  /// **'Email not sent'**
  String get inviteEmailNotSent;

  /// Invites page row: when the invite expired; {date} is a date
  ///
  /// In en, this message translates to:
  /// **'Expired {date}'**
  String inviteExpiredOn(String date);

  /// Invites page row: tooltip of the revoke (delete) button
  ///
  /// In en, this message translates to:
  /// **'Revoke invite'**
  String get inviteRevokeTooltip;

  /// Review queue status (filter chip and card badge; Discourse review.statuses.pending)
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get reviewStatusPending;

  /// Review queue status (filter chip and card badge; Discourse review.statuses.approved)
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get reviewStatusApproved;

  /// Review queue status (filter chip and card badge; Discourse review.statuses.rejected)
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get reviewStatusRejected;

  /// Review queue status filter chip: every status (Discourse review.statuses.all)
  ///
  /// In en, this message translates to:
  /// **'Everything'**
  String get reviewStatusAll;

  /// Review queue card badge (Discourse review.statuses.ignored)
  ///
  /// In en, this message translates to:
  /// **'Flag ignored'**
  String get reviewStatusIgnored;

  /// Review queue card badge (Discourse review.statuses.deleted)
  ///
  /// In en, this message translates to:
  /// **'Topic or post deleted'**
  String get reviewStatusDeleted;

  /// Review queue: the forum connection has no review queue
  ///
  /// In en, this message translates to:
  /// **'Review queue is not available on this forum.'**
  String get reviewQueueUnavailable;

  /// Review queue: the list could not be loaded
  ///
  /// In en, this message translates to:
  /// **'Failed to load review queue'**
  String get reviewQueueLoadFailed;

  /// Review queue: another moderator acted on the item first; the list reloads
  ///
  /// In en, this message translates to:
  /// **'This item was changed by another moderator. Refreshing…'**
  String get reviewableChangedByOther;

  /// Review queue: an approve/reject/… action failed
  ///
  /// In en, this message translates to:
  /// **'Failed to perform action'**
  String get reviewActionFailed;

  /// Review queue: snackbar after an action, when the server sent no message of its own; {action} is the action's label (e.g. 'Keep post')
  ///
  /// In en, this message translates to:
  /// **'{action} — done'**
  String reviewActionDone(String action);

  /// Review queue, reject dialog: hint in the reason field
  ///
  /// In en, this message translates to:
  /// **'Why is this being rejected?'**
  String get reviewRejectReasonHint;

  /// Review queue card title (Discourse review.types.reviewable_flagged_post)
  ///
  /// In en, this message translates to:
  /// **'Flagged Post'**
  String get reviewTypeFlaggedPost;

  /// Review queue card title (Discourse review.types.reviewable_queued_post)
  ///
  /// In en, this message translates to:
  /// **'Queued Post'**
  String get reviewTypeQueuedPost;

  /// Review queue card title (Discourse review.types.reviewable_queued_topic)
  ///
  /// In en, this message translates to:
  /// **'Queued Topic'**
  String get reviewTypeQueuedTopic;

  /// Review queue card title (Discourse review.types.reviewable_user)
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get reviewTypeUser;

  /// Review queue card title (Discourse review.types.reviewable_post)
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get reviewTypePost;

  /// Review queue card title (Discourse chat plugin review.types.reviewable_chat_message)
  ///
  /// In en, this message translates to:
  /// **'Flagged chat message'**
  String get reviewTypeChatMessage;

  /// Review queue: the viewer is not staff
  ///
  /// In en, this message translates to:
  /// **'Moderator access required'**
  String get reviewModeratorAccessRequired;

  /// Review queue card: the item's score (Discourse review.scores.score); {score} is a number like 12.5
  ///
  /// In en, this message translates to:
  /// **'Score {score}'**
  String reviewableScore(String score);

  /// Under a post, when its list of direct replies fails to load
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load replies.'**
  String get postRepliesLoadFailed;

  /// Post menu item that turns the post into a wiki (Discourse's "Make Wiki")
  ///
  /// In en, this message translates to:
  /// **'Make wiki'**
  String get postMakeWiki;

  /// Post menu item that turns a wiki post back into a normal post (Discourse's "Remove Wiki")
  ///
  /// In en, this message translates to:
  /// **'Remove wiki'**
  String get postRemoveWiki;

  /// Snackbar when removing the bookmark from a post fails and the server gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to remove bookmark'**
  String get postBookmarkRemoveFailed;

  /// Snackbar when bookmarking a post fails and the server gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to bookmark post'**
  String get postBookmarkFailed;

  /// Snackbar when changing a post bookmark's reminder fails and the server gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to update reminder'**
  String get postBookmarkReminderUpdateFailed;

  /// Snackbar after setting a reminder on a post's bookmark (Discourse's "Reminder set!")
  ///
  /// In en, this message translates to:
  /// **'Reminder set'**
  String get postBookmarkReminderSet;

  /// Snackbar after clearing the reminder on a post's bookmark (Discourse's "Reminder cleared")
  ///
  /// In en, this message translates to:
  /// **'Reminder cleared'**
  String get postBookmarkReminderCleared;

  /// Snackbar when marking a reply as the solution (discourse-solved) fails and the server gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to mark answer'**
  String get solutionMarkFailed;

  /// Snackbar when unmarking the solution (discourse-solved) fails and the server gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to unmark answer'**
  String get solutionUnmarkFailed;

  /// In a post's header, in place of its date when the post has none
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get postUnknownDate;

  /// Screen-reader label of a post's bookmark button when the post is not bookmarked
  ///
  /// In en, this message translates to:
  /// **'Bookmark post'**
  String get postBookmarkAction;

  /// Screen-reader label of a post's react button when the reader has liked the post
  ///
  /// In en, this message translates to:
  /// **'You liked this. Tap to remove your like.'**
  String get reactionButtonRemoveLike;

  /// Screen-reader label of a post's react button when the reader reacted with an emoji other than the like; reaction is the emoji's name, e.g. 'rocket'
  ///
  /// In en, this message translates to:
  /// **'Your reaction: {reaction}. Tap to remove it.'**
  String reactionButtonRemove(String reaction);

  /// Screen-reader label of a post's react button once the reader's reaction can no longer be changed (Discourse allows changes for a few minutes); reaction is the emoji's name
  ///
  /// In en, this message translates to:
  /// **'Your reaction: {reaction}. It can no longer be changed.'**
  String reactionButtonLocked(String reaction);

  /// Screen-reader hint on a post's react button: a long press opens the reaction picker
  ///
  /// In en, this message translates to:
  /// **'Long press for more reactions'**
  String get reactionHoldHint;

  /// Screen-reader label of a post's reactions summary (the emoji and count beside the react button); count is the number of people who reacted
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reaction. Tap to see who reacted.} other{{count} reactions. Tap to see who reacted.}}'**
  String reactionSummarySemantics(int count);

  /// Message shown when the reader tries to change a reaction after Discourse's undo window has closed
  ///
  /// In en, this message translates to:
  /// **'You can no longer change your reaction to this post.'**
  String get reactionLockedMessage;

  /// One-time tip shown after the reader's first like, on forums with more reactions than the like
  ///
  /// In en, this message translates to:
  /// **'Tip: long-press the heart for more reactions.'**
  String get reactionHoldTip;

  /// Title of the sheet listing who reacted to a post; count is the number of people
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reaction} other{{count} reactions}}'**
  String reactionsTitle(int count);

  /// Filter chip in the who-reacted sheet that shows everyone, followed by the total count
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get reactionsAll;

  /// Tag on the reader's own row in the who-reacted sheet
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get reactionYou;

  /// Button in the who-reacted sheet that opens the reaction picker when the reader has already reacted
  ///
  /// In en, this message translates to:
  /// **'Change your reaction'**
  String get changeYourReaction;

  /// Note in the reaction picker when the reader has reacted: tapping the same emoji removes it
  ///
  /// In en, this message translates to:
  /// **'Tap your reaction again to remove it.'**
  String get reactionTapAgainToRemove;

  /// Screen-reader label of a per-emoji filter chip in the who-reacted sheet; reaction is the emoji's name, count the people who used it
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{reaction}, 1 person} other{{reaction}, {count} people}}'**
  String reactionFilterSemantics(String reaction, int count);

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

  /// Snackbar when taking back an up/down vote on a post (discourse-post-voting) fails and the server gave no reason
  ///
  /// In en, this message translates to:
  /// **'Could not remove vote (past undo window?)'**
  String get postVoteRemoveFailed;

  /// Snackbar when an up/down vote on a post (discourse-post-voting) fails and the server gave no reason
  ///
  /// In en, this message translates to:
  /// **'Could not cast vote'**
  String get postVoteCastFailed;

  /// Tooltip of the up arrow beside a post in a post-voting topic (discourse-post-voting's "Upvote")
  ///
  /// In en, this message translates to:
  /// **'Upvote'**
  String get postUpvote;

  /// Tooltip of the down arrow beside a post in a post-voting topic (discourse-post-voting's "Downvote")
  ///
  /// In en, this message translates to:
  /// **'Downvote'**
  String get postDownvote;

  /// Error when voting in a post's poll fails
  ///
  /// In en, this message translates to:
  /// **'Vote failed. Please try again.'**
  String get pollVoteFailed;

  /// Error when taking back one's vote in a poll fails
  ///
  /// In en, this message translates to:
  /// **'Could not remove your vote. Please try again.'**
  String get pollRemoveVoteFailed;

  /// Error when the list of a poll's voters cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not load voters.'**
  String get pollVotersLoadFailed;

  /// In the poll voters sheet, when the forum will not say who voted (a private poll)
  ///
  /// In en, this message translates to:
  /// **'Voters are not visible for this poll.'**
  String get pollVotersNotVisible;

  /// Byline of the solution card under a solved topic's first post: who wrote the accepted answer and its post number
  ///
  /// In en, this message translates to:
  /// **'Solved by {name} in post #{postNumber}'**
  String solutionSolvedByInPost(String name, int postNumber);

  /// Appended to the solution card's byline: who marked the answer as the solution
  ///
  /// In en, this message translates to:
  /// **'marked by {name}'**
  String solutionMarkedBy(String name);

  /// In the reaction picker, when the post's reaction limit is used up for now
  ///
  /// In en, this message translates to:
  /// **'You can react to this post again in {seconds}s'**
  String reactAgainInSeconds(int seconds);

  /// In the reaction picker, when adding or changing a reaction fails and the server gave no reason
  ///
  /// In en, this message translates to:
  /// **'Could not update reaction.'**
  String get reactionUpdateFailed;

  /// In the who-reacted sheet, when the forum has no way to list reactions
  ///
  /// In en, this message translates to:
  /// **'Reactions are not supported on this forum.'**
  String get reactionsNotSupported;

  /// In the who-reacted sheet, when the list fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load reactions.'**
  String get reactionsLoadFailed;

  /// Screen-reader label of a user row in the who-reacted sheet
  ///
  /// In en, this message translates to:
  /// **'View profile of {username}'**
  String viewProfileOfUser(String username);

  /// Error when saving an edited post fails and the server gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to save post'**
  String get failedToSavePost;

  /// Error when saving an edited post fails, with the underlying error
  ///
  /// In en, this message translates to:
  /// **'Failed to save post: {error}'**
  String failedToSavePostWithError(String error);

  /// Error when removing an existing attachment while editing a post fails and the server gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to remove attachment. Please check your permissions.'**
  String get failedToRemoveAttachmentCheckPermissions;

  /// Title of the page for editing a post (Discourse's "Edit Post")
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get editPostTitle;

  /// Hint in the text field when editing a post
  ///
  /// In en, this message translates to:
  /// **'Edit your post...'**
  String get editYourPostHint;

  /// Error when posting a reply fails and the server gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to post reply'**
  String get failedToPostReply;

  /// Error when posting a reply fails, with the underlying error
  ///
  /// In en, this message translates to:
  /// **'Failed to post reply: {error}'**
  String failedToPostReplyWithError(String error);

  /// Error when creating a topic fails and the server gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to create topic'**
  String get failedToCreateTopic;

  /// Hint in the title field of the new-topic composer
  ///
  /// In en, this message translates to:
  /// **'Write your topic title...'**
  String get writeYourTopicTitle;

  /// Hint in the text field of the new-topic composer
  ///
  /// In en, this message translates to:
  /// **'Write your topic content...'**
  String get writeYourTopicContent;

  /// Default hint in a composer's title field, when the page gives none of its own
  ///
  /// In en, this message translates to:
  /// **'Write your title...'**
  String get composerTitleHint;

  /// Default hint in a composer's text field, when the page gives none of its own
  ///
  /// In en, this message translates to:
  /// **'Write your content...'**
  String get composerContentHint;

  /// Composer error when a picked image is over the forum's upload limit and shrinking it failed; size and limit are formatted file sizes
  ///
  /// In en, this message translates to:
  /// **'{fileName}: too large ({size}) and could not be resized. Limit is {limit}.'**
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit);

  /// Composer notice after an oversized image was shrunk to fit the forum's upload limit; size and limit are formatted file sizes; dimensions is empty or ' (1200×800 → 900×600)' with a leading space
  ///
  /// In en, this message translates to:
  /// **'{fileName} resized to {size}{dimensions} to fit the {limit} limit.'**
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit);

  /// Screen-reader hint of the composer's attach-file button
  ///
  /// In en, this message translates to:
  /// **'Attach a file to this post'**
  String get composerAttachFileHint;

  /// Screen-reader hint of the composer's upload-image button
  ///
  /// In en, this message translates to:
  /// **'Upload an image to this post'**
  String get composerUploadImageHint;

  /// Screen-reader hint of the composer's formatting menu button
  ///
  /// In en, this message translates to:
  /// **'Open formatting options'**
  String get composerFormattingHint;

  /// Tooltip of the reply composer's whisper toggle (staff only), when off
  ///
  /// In en, this message translates to:
  /// **'Whisper (staff only)'**
  String get whisperStaffOnly;

  /// Tooltip of the reply composer's whisper toggle (staff only), when on
  ///
  /// In en, this message translates to:
  /// **'Whisper on (staff only)'**
  String get whisperOnStaffOnly;

  /// Hint in the new-topic tag field once the topic has as many tags as the forum allows
  ///
  /// In en, this message translates to:
  /// **'Max tags reached'**
  String get tagInputMaxReached;

  /// Hint in the new-topic tag field before any tag is added
  ///
  /// In en, this message translates to:
  /// **'Add a tag…'**
  String get tagInputAddTag;

  /// Short hint in the new-topic tag field once it has a tag: add another
  ///
  /// In en, this message translates to:
  /// **'+ tag'**
  String get tagInputAddAnother;

  /// Edit history page, when the forum offers no post revisions
  ///
  /// In en, this message translates to:
  /// **'Edit history is not available on this forum.'**
  String get editHistoryUnavailable;

  /// Edit history page, when a revision fails to load and the server gave no reason
  ///
  /// In en, this message translates to:
  /// **'Failed to load edit history.'**
  String get editHistoryLoadFailed;

  /// Tooltip of the edit history page's back arrow (Discourse's "Previous revision")
  ///
  /// In en, this message translates to:
  /// **'Previous revision'**
  String get previousRevision;

  /// Tooltip of the edit history page's forward arrow (Discourse's "Next revision")
  ///
  /// In en, this message translates to:
  /// **'Next revision'**
  String get nextRevision;

  /// Notification settings page: loading the forum's notification preferences failed
  ///
  /// In en, this message translates to:
  /// **'Failed to load notification preferences.'**
  String get notificationPrefsLoadFailed;

  /// Notification settings page: snackbar when a changed preference could not be saved (the change is undone)
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save — check your connection'**
  String get notificationPrefsSaveFailed;

  /// Notification settings page: empty state for a signed-out reader
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your notification preferences.'**
  String get signInToManageNotificationPrefs;

  /// Notification settings page: row for Discourse's email_level preference (when to email about replies, mentions and watched activity)
  ///
  /// In en, this message translates to:
  /// **'Email when away'**
  String get emailWhenAwayTitle;

  /// Notification settings page: explanation of the email_level preference, shown in its picker (Discourse user.email_level.title)
  ///
  /// In en, this message translates to:
  /// **'Email me when I am quoted, replied to, my @username is mentioned, or when there is new activity in my watched categories, tags or topics'**
  String get emailLevelDescription;

  /// Notification settings page: option 'Always' for email and like notification preferences (Discourse like_notification_frequency.always)
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get notificationPrefAlways;

  /// Notification settings page: email option 'only when away' (Discourse user.email_level.only_when_away)
  ///
  /// In en, this message translates to:
  /// **'Only when away'**
  String get notificationPrefOnlyWhenAway;

  /// Notification settings page: option 'Never' for email and like notification preferences (Discourse like_notification_frequency.never)
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get notificationPrefNever;

  /// Notification settings page: row for Discourse's email_messages_level preference (emails about personal messages)
  ///
  /// In en, this message translates to:
  /// **'Email for messages'**
  String get emailForMessagesTitle;

  /// Notification settings page: explanation of email_messages_level, shown in its picker (Discourse user.email_messages_level)
  ///
  /// In en, this message translates to:
  /// **'Email me when I am sent a personal message'**
  String get emailMessagesLevelDescription;

  /// Notification settings page: switch for Discourse's email digest (Discourse user.email_activity_summary)
  ///
  /// In en, this message translates to:
  /// **'Activity summary'**
  String get activitySummaryTitle;

  /// Notification settings page: what the activity summary switch does (Discourse user.email_digests.title)
  ///
  /// In en, this message translates to:
  /// **'When I don’t visit here, send me an email summary of popular topics and replies'**
  String get activitySummaryDescription;

  /// Notification settings page: row choosing how often the activity summary email is sent
  ///
  /// In en, this message translates to:
  /// **'Activity summary frequency'**
  String get activitySummaryFrequencyTitle;

  /// Notification settings page: activity summary frequency option (Discourse user.email_digests.daily)
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get activitySummaryDaily;

  /// Notification settings page: activity summary frequency option (Discourse user.email_digests.weekly)
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get activitySummaryWeekly;

  /// Notification settings page: activity summary frequency option (Discourse user.email_digests.every_month)
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get activitySummaryMonthly;

  /// Notification settings page: switch for Discourse's mailing list mode (Discourse user.mailing_list_mode.label)
  ///
  /// In en, this message translates to:
  /// **'Mailing list mode'**
  String get mailingListModeTitle;

  /// Notification settings page: what mailing list mode does
  ///
  /// In en, this message translates to:
  /// **'Email me every post (disables the activity summary). Not recommended on high-traffic forums.'**
  String get mailingListModeDescription;

  /// Notification settings page: row for when to be notified about likes (Discourse user.like_notification_frequency.title)
  ///
  /// In en, this message translates to:
  /// **'Notify when liked'**
  String get likeNotificationFrequencyTitle;

  /// Notification settings page: like notification option (Discourse user.like_notification_frequency.first_time_and_daily)
  ///
  /// In en, this message translates to:
  /// **'First time a post is liked and daily'**
  String get likeNotificationFirstTimeAndDaily;

  /// Notification settings page: like notification option (Discourse user.like_notification_frequency.first_time)
  ///
  /// In en, this message translates to:
  /// **'First time a post is liked'**
  String get likeNotificationFirstTime;

  /// Notification settings page: row for what happens to a topic you reply to (Discourse user.notification_level_when_replying.label)
  ///
  /// In en, this message translates to:
  /// **'When posting'**
  String get whenPostingTitle;

  /// Notification settings page: explanation of the 'When posting' preference, shown in its picker
  ///
  /// In en, this message translates to:
  /// **'What happens to a topic you reply to'**
  String get whenPostingDescription;

  /// Notification settings page: 'When posting' option (Discourse user.notification_level_when_replying.watch_topic)
  ///
  /// In en, this message translates to:
  /// **'Watch topic'**
  String get whenPostingWatchTopic;

  /// Notification settings page: 'When posting' option (Discourse user.notification_level_when_replying.track_topic)
  ///
  /// In en, this message translates to:
  /// **'Track topic'**
  String get whenPostingTrackTopic;

  /// Notification settings page: 'When posting' option (Discourse user.notification_level_when_replying.do_nothing)
  ///
  /// In en, this message translates to:
  /// **'Do nothing'**
  String get whenPostingDoNothing;

  /// Do not disturb duration picker: pause until tomorrow (Discourse pause_notifications.options.tomorrow)
  ///
  /// In en, this message translates to:
  /// **'Until tomorrow'**
  String get pauseNotificationsUntilTomorrow;

  /// Snackbar when turning on Do not disturb failed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t enable do not disturb'**
  String get couldNotEnableDoNotDisturb;

  /// Snackbar when turning off Do not disturb failed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t turn off do not disturb'**
  String get couldNotTurnOffDoNotDisturb;

  /// Account and privacy page: snackbar after the password-reset email was requested
  ///
  /// In en, this message translates to:
  /// **'Password-reset email sent.'**
  String get passwordResetEmailSent;

  /// Account and privacy page: snackbar when the password-reset email could not be requested
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send reset email'**
  String get couldNotSendResetEmail;

  /// Account and privacy / Change email: snackbar when a request failed with nothing more specific to say
  ///
  /// In en, this message translates to:
  /// **'Request failed.'**
  String get accountRequestFailed;

  /// Account and privacy page: the forum's web address is unknown, so it cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Forum URL is unavailable.'**
  String get forumUrlUnavailable;

  /// Account and privacy page: the forum's preferences page could not be opened in the browser
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the preferences page.'**
  String get couldNotOpenPreferencesPage;

  /// Account and privacy page: the forum could not be opened in the browser
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the forum URL.'**
  String get couldNotOpenForumUrl;

  /// Change email page: snackbar when the forum did not accept the change request
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t request email change'**
  String get couldNotRequestEmailChange;

  /// Change email page: label of the new address field
  ///
  /// In en, this message translates to:
  /// **'New email'**
  String get newEmailLabel;

  /// Change email page: validation error when the field is empty
  ///
  /// In en, this message translates to:
  /// **'Enter an email address'**
  String get enterAnEmailAddress;

  /// Change email page: validation error for an address without @ or a dot
  ///
  /// In en, this message translates to:
  /// **'That doesn’t look like an email'**
  String get emailLooksInvalid;

  /// Change email page: validation error for an address containing a space
  ///
  /// In en, this message translates to:
  /// **'No spaces in emails'**
  String get emailNoSpaces;

  /// Enable notifications page: title of the forum's approval page opened to grant notifications
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get allowNotificationsSheetTitle;

  /// Enable notifications page: the forum's approval page came back without the key (shown after 'Could not enable notifications:')
  ///
  /// In en, this message translates to:
  /// **'No payload returned from the grant.'**
  String get notificationsGrantNoPayload;

  /// Stands in for the forum's name when the forum has none
  ///
  /// In en, this message translates to:
  /// **'this forum'**
  String get thisForumFallback;

  /// Title of the forum's sign-in page, e.g. 'Sign in to meta.discourse.org'
  ///
  /// In en, this message translates to:
  /// **'Sign in to {domain}'**
  String signInToDomain(String domain);

  /// Title of the snackbar reporting a failed sign-in
  ///
  /// In en, this message translates to:
  /// **'Login result'**
  String get loginResultTitle;

  /// Two-factor dialog: the code entered was not accepted
  ///
  /// In en, this message translates to:
  /// **'Invalid authentication code'**
  String get invalidAuthenticationCode;

  /// Two-factor dialog: checking the code failed for another reason
  ///
  /// In en, this message translates to:
  /// **'An error occurred during verification. Please try again.'**
  String get tfaVerificationError;

  /// Name of the password field, used in 'Password is required.' (Discourse user.password.title)
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordFieldLabel;

  /// Generic error message when an error has no readable text of its own
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrongTryAgain;

  /// Error dialog: message for an unexpected error
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unexpectedErrorTryAgain;

  /// Error dialog: the device is offline
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network settings.'**
  String get errorNoInternetConnection;

  /// Error dialog: a request took too long
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get errorRequestTimedOut;

  /// Error dialog: the server failed without a message of its own
  ///
  /// In en, this message translates to:
  /// **'Server error occurred. Please try again later.'**
  String get errorServerTryLater;

  /// Error dialog: sign-in rejected the username or password
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password.'**
  String get errorInvalidCredentials;

  /// Error dialog: the reader's session has expired
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get errorSessionExpired;

  /// Error dialog: the forum has suspended the reader's account
  ///
  /// In en, this message translates to:
  /// **'Your account has been suspended. Please contact the forum\'s staff.'**
  String get errorAccountSuspended;

  /// Error dialog: the forum could not be found
  ///
  /// In en, this message translates to:
  /// **'Forum not found.'**
  String get errorForumNotFound;

  /// Error dialog: the reader may not access the forum
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to access this forum.'**
  String get errorForumAccessDenied;

  /// Error dialog: the forum is unavailable
  ///
  /// In en, this message translates to:
  /// **'Forum is currently unavailable. Please try again later.'**
  String get errorForumUnavailable;

  /// Error dialog: requested data was not found
  ///
  /// In en, this message translates to:
  /// **'Requested data not found.'**
  String get errorDataNotFound;

  /// Error dialog: data looks corrupted
  ///
  /// In en, this message translates to:
  /// **'Data appears to be corrupted. Please refresh the page.'**
  String get errorDataCorrupted;

  /// Error dialog: cached data could not be read
  ///
  /// In en, this message translates to:
  /// **'Failed to load cached data. Please try again.'**
  String get errorCacheLoadFailed;

  /// Error dialog: a value was invalid; {field} names it
  ///
  /// In en, this message translates to:
  /// **'Invalid {field} provided.'**
  String errorInvalidField(String field);

  /// Error dialog: a required value is missing, e.g. 'Password is required.'
  ///
  /// In en, this message translates to:
  /// **'{field} is required.'**
  String errorFieldRequired(String field);

  /// Error dialog: the reader may not do {action}
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to {action}.'**
  String errorPermissionDeniedFor(String action);

  /// Error dialog: a feature, e.g. Passkeys, is not available on this forum
  ///
  /// In en, this message translates to:
  /// **'{feature} is not available on this forum.'**
  String errorFeatureNotAvailable(String feature);

  /// Error dialog: the device's storage is full
  ///
  /// In en, this message translates to:
  /// **'Storage is full. Please free up some space.'**
  String get errorStorageFull;

  /// Error dialog: the app may not use the device's storage
  ///
  /// In en, this message translates to:
  /// **'Storage access denied. Please check app permissions.'**
  String get errorStorageAccessDenied;

  /// Error dialog: a network error without more detail
  ///
  /// In en, this message translates to:
  /// **'Network error occurred. Please try again.'**
  String get errorNetworkTryAgain;

  /// Error dialog: signing in failed without more detail
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get errorAuthenticationTryAgain;

  /// Error dialog: the forum reported an error without more detail
  ///
  /// In en, this message translates to:
  /// **'Forum error occurred. Please try again.'**
  String get errorForumTryAgain;

  /// Error dialog title for a connection problem
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get connectionErrorTitle;

  /// Error dialog title for a sign-in problem
  ///
  /// In en, this message translates to:
  /// **'Authentication Error'**
  String get authenticationErrorTitle;

  /// Error dialog title for an error the forum reported
  ///
  /// In en, this message translates to:
  /// **'Forum Error'**
  String get forumErrorTitle;

  /// Error dialog title for a missing permission
  ///
  /// In en, this message translates to:
  /// **'Permission Error'**
  String get permissionErrorTitle;

  /// Snackbar when taking a person or group off a personal message fails and Discourse gave no reason
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t remove {name} from this message.'**
  String errorRemovingFromMessage(String name);

  /// Button on the chat list that starts a direct message or group chat (Discourse's wording)
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get chatNewMessage;

  /// Heading over the reader's starred chat channels
  ///
  /// In en, this message translates to:
  /// **'Starred'**
  String get chatStarred;

  /// Button that opens the list of all public chat channels to join
  ///
  /// In en, this message translates to:
  /// **'Browse channels'**
  String get chatBrowseChannels;

  /// Row at the end of the reader's channels that opens all public channels
  ///
  /// In en, this message translates to:
  /// **'Browse all channels'**
  String get chatBrowseAllChannels;

  /// Filter chip in Browse channels: every channel
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get chatFilterAll;

  /// Filter chip in Browse channels: open channels
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get chatFilterOpen;

  /// Filter chip in Browse channels: closed channels
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get chatFilterClosed;

  /// Filter chip in Browse channels: archived channels
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get chatFilterArchived;

  /// Hint in the search field of Browse channels
  ///
  /// In en, this message translates to:
  /// **'Search channel by name'**
  String get chatBrowseSearch;

  /// Button that joins a public chat channel
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get chatJoin;

  /// Label on a channel the reader has joined
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get chatJoined;

  /// Button that leaves a chat channel
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get chatLeave;

  /// How many people are in a chat channel
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} member} other{{count} members}}'**
  String chatMembersCount(int count);

  /// When a chat's last message was yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get chatYesterday;

  /// Browse channels found nothing for the search or filter
  ///
  /// In en, this message translates to:
  /// **'No channels found'**
  String get chatNoChannelsFound;

  /// Swipe action on a direct message in the chat list: hide it until someone writes again
  ///
  /// In en, this message translates to:
  /// **'Close this personal chat'**
  String get chatCloseDm;

  /// Date line in a chat conversation over today's messages
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get chatToday;

  /// Line in a chat conversation where the reader's unread messages begin (Discourse's wording)
  ///
  /// In en, this message translates to:
  /// **'last visit'**
  String get chatLastVisit;

  /// Button that jumps to the newest chat messages, with how many arrived while the reader was scrolled up
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} new message} other{{count} new messages}}'**
  String chatNewMessagesCount(int count);

  /// Screen-reader label of the button that jumps to the newest chat messages
  ///
  /// In en, this message translates to:
  /// **'Scroll to bottom'**
  String get chatScrollToBottom;

  /// Screen-reader label before the message a chat reply answers
  ///
  /// In en, this message translates to:
  /// **'In reply to'**
  String get chatInReplyTo;

  /// Action on a chat message: copy its text
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get chatCopyText;

  /// Confirmation after copying a chat message's text
  ///
  /// In en, this message translates to:
  /// **'Text copied to clipboard'**
  String get chatTextCopied;

  /// Action on a chat message: bookmark it
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get chatBookmark;

  /// Action on a chat message: pin it in the channel
  ///
  /// In en, this message translates to:
  /// **'Pin message'**
  String get chatPinMessage;

  /// Action on a pinned chat message: unpin it
  ///
  /// In en, this message translates to:
  /// **'Unpin message'**
  String get chatUnpinMessage;

  /// Action on someone's chat message: flag it for the moderators
  ///
  /// In en, this message translates to:
  /// **'Flag'**
  String get chatFlag;

  /// Button that opens the full emoji picker to react to a chat message
  ///
  /// In en, this message translates to:
  /// **'React with emoji'**
  String get chatReactWithEmoji;

  /// Banner over the chat composer while writing a reply; username is the author of the message replied to
  ///
  /// In en, this message translates to:
  /// **'Replying to {username}'**
  String chatReplyingTo(String username);

  /// Banner over the chat composer while editing one of the reader's messages
  ///
  /// In en, this message translates to:
  /// **'Editing message'**
  String get chatEditingMessage;

  /// Under a chat conversation: one person is typing
  ///
  /// In en, this message translates to:
  /// **'{username} is typing'**
  String chatTypingOne(String username);

  /// Under a chat conversation: several people are typing (all but the last, comma-separated, then the last)
  ///
  /// In en, this message translates to:
  /// **'{commaSeparatedUsernames} and {lastUsername} are typing'**
  String chatTypingTwo(String commaSeparatedUsernames, String lastUsername);

  /// Under a chat conversation: many people are typing; the first few by name, then how many others
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{commaSeparatedUsernames} and {count} other are typing} other{{commaSeparatedUsernames} and {count} others are typing}}'**
  String chatTypingMany(String commaSeparatedUsernames, int count);

  /// Action on a chat message in a channel with threads: open (or start) its thread
  ///
  /// In en, this message translates to:
  /// **'Open Thread'**
  String get chatOpenThread;

  /// Heading of a chat channel's member list
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get chatMembers;

  /// Button that adds people to a group chat
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get chatAddMember;

  /// Hint in the search field over a chat channel's members
  ///
  /// In en, this message translates to:
  /// **'Find members'**
  String get chatFindMembers;

  /// Action that removes someone from a chat channel
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get chatRemoveMember;

  /// Chat notification level: never
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get chatNotifyNever;

  /// Chat notification level: only for mentions
  ///
  /// In en, this message translates to:
  /// **'Only for mentions'**
  String get chatNotifyMention;

  /// Chat notification level: for all activity
  ///
  /// In en, this message translates to:
  /// **'For all activity'**
  String get chatNotifyAlways;

  /// Label of a chat channel's notification level setting
  ///
  /// In en, this message translates to:
  /// **'Send push notifications'**
  String get chatNotificationLevel;

  /// Switch that mutes a chat channel
  ///
  /// In en, this message translates to:
  /// **'Mute channel'**
  String get chatMuteChannel;

  /// Switch that stars a chat channel, listing it first
  ///
  /// In en, this message translates to:
  /// **'Star channel'**
  String get chatStarChannel;

  /// Button that leaves a chat channel or group chat
  ///
  /// In en, this message translates to:
  /// **'Leave channel'**
  String get chatLeaveChannel;

  /// Title of chat search
  ///
  /// In en, this message translates to:
  /// **'Search chat'**
  String get chatSearchTitle;

  /// Chat search found nothing
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get chatSearchNoResults;

  /// The reader's chat threads, as a switch beside Channels and DMs
  ///
  /// In en, this message translates to:
  /// **'My Threads'**
  String get chatMyThreads;

  /// How many replies a chat thread has
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} reply} other{{count} replies}}'**
  String chatThreadReplies(int count);

  /// The reader takes part in no chat threads
  ///
  /// In en, this message translates to:
  /// **'You are not participating in any threads in this channel.'**
  String get chatNoThreads;

  /// Field for an optional name when starting a group chat
  ///
  /// In en, this message translates to:
  /// **'Group chat name (optional)'**
  String get chatGroupName;

  /// How many people are picked for a new group chat, out of the forum's limit
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count}/{max} member} other{{count}/{max} members}}'**
  String chatMembersCounter(int count, int max);

  /// A new group chat has as many people as the forum allows
  ///
  /// In en, this message translates to:
  /// **'Maximum number of members reached'**
  String get chatTooManyMembers;

  /// Title of a chat thread's screen
  ///
  /// In en, this message translates to:
  /// **'Thread'**
  String get chatThread;

  /// Title of a chat channel's info and settings screen
  ///
  /// In en, this message translates to:
  /// **'Channel settings'**
  String get chatChannelSettings;

  /// Hint in the chat search field
  ///
  /// In en, this message translates to:
  /// **'Search messages'**
  String get chatSearchMessagesHint;

  /// Empty My Threads list (Discourse chat.empty_state.my_threads)
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any threads yet. Threads you participate in will be displayed here.'**
  String get chatMyThreadsEmpty;

  /// Confirmation before leaving a group chat (Discourse chat.channel_settings.leave_groupchat_info)
  ///
  /// In en, this message translates to:
  /// **'By leaving this group chat, you will no longer have access to it and won’t receive notifications related to it. To rejoin, you will need to be re-invited by a member of the group chat.'**
  String get chatLeaveGroupInfo;

  /// Composer hint inside a chat thread (Discourse chat.placeholder_thread)
  ///
  /// In en, this message translates to:
  /// **'Chat in thread'**
  String get chatPlaceholderThread;

  /// Before the time of a thread's latest reply, under its original message (Discourse chat.thread.last_reply)
  ///
  /// In en, this message translates to:
  /// **'last reply'**
  String get chatLastReply;

  /// The Unread messages filter with its count (Discourse user.messages.unread_with_count)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Unread ({count})} other{Unread ({count})}}'**
  String messageListUnreadCount(int count);

  /// The New messages filter with its count (Discourse user.messages.new_with_count)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{New ({count})} other{New ({count})}}'**
  String messageListNewCount(int count);

  /// The reader's own messages, as opposed to a group's inbox (Discourse user.messages.personal)
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get messagePersonal;

  /// Banner over the message list when messages arrived or changed; tap to show them (Discourse topic_count_latest, as the web's messages page)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{See {count} new or updated topic} other{See {count} new or updated topics}}'**
  String messageListIncoming(int count);

  /// Composer hint in a group chat (Discourse chat.placeholder_group)
  ///
  /// In en, this message translates to:
  /// **'Chat in group'**
  String get chatPlaceholderGroup;

  /// No description provided for @notificationAccountMismatch.
  ///
  /// In en, this message translates to:
  /// **'This notification cannot be opened with the current account. Open Notifications to see updates for this account.'**
  String get notificationAccountMismatch;

  /// No description provided for @chatJoinedChannels.
  ///
  /// In en, this message translates to:
  /// **'Joined channels'**
  String get chatJoinedChannels;

  /// No description provided for @chatAvailableChannels.
  ///
  /// In en, this message translates to:
  /// **'Available channels'**
  String get chatAvailableChannels;

  /// No description provided for @chatAvailableChannelsDescription.
  ///
  /// In en, this message translates to:
  /// **'Channels you can view or join.'**
  String get chatAvailableChannelsDescription;

  /// No description provided for @chatAllChannelsJoined.
  ///
  /// In en, this message translates to:
  /// **'You have joined all available channels.'**
  String get chatAllChannelsJoined;

  /// No description provided for @chatViewChannel.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get chatViewChannel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
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
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nl':
      return AppLocalizationsNl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
