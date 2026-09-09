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

  /// Message asking user to login before changing topic notifications
  ///
  /// In en, this message translates to:
  /// **'Please login to change notifications on this topic'**
  String get pleaseLoginToSubscribe;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get subscribe;

  /// Error message when changing notification level fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update notifications'**
  String get failedToSubscribeToThread;

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

  /// Option for soft delete (can be restored)
  ///
  /// In en, this message translates to:
  /// **'Soft Delete'**
  String get softDelete;

  /// No description provided for @postCanBeRestoredLater.
  ///
  /// In en, this message translates to:
  /// **'Post can be restored later'**
  String get postCanBeRestoredLater;

  /// Option for hard delete (permanent)
  ///
  /// In en, this message translates to:
  /// **'Hard Delete'**
  String get hardDelete;

  /// No description provided for @postWillBePermanentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Post will be permanently deleted'**
  String get postWillBePermanentlyDeleted;

  /// Label for deletion reason field
  ///
  /// In en, this message translates to:
  /// **'Reason for deletion'**
  String get reasonForDeletion;

  /// No description provided for @enterReasonForDeletingPost.
  ///
  /// In en, this message translates to:
  /// **'Enter the reason for deleting this post'**
  String get enterReasonForDeletingPost;

  /// Validation message for deletion reason
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason for deletion'**
  String get pleaseEnterReasonForDeletion;

  /// No description provided for @reportPost.
  ///
  /// In en, this message translates to:
  /// **'Report Post'**
  String get reportPost;

  /// No description provided for @pleaseProvideReasonForReporting.
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason for reporting this post.'**
  String get pleaseProvideReasonForReporting;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @enterReasonForReportingPost.
  ///
  /// In en, this message translates to:
  /// **'Enter the reason for reporting this post'**
  String get enterReasonForReportingPost;

  /// No description provided for @pleaseEnterReason.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason'**
  String get pleaseEnterReason;

  /// Button to submit a report
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// No description provided for @selectedActions.
  ///
  /// In en, this message translates to:
  /// **'Selected actions:'**
  String get selectedActions;

  /// No description provided for @thisActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get thisActionCannotBeUndone;

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

  /// No description provided for @markRead.
  ///
  /// In en, this message translates to:
  /// **'Mark Read'**
  String get markRead;

  /// No description provided for @spamOrAdvertising.
  ///
  /// In en, this message translates to:
  /// **'Spam or advertising'**
  String get spamOrAdvertising;

  /// No description provided for @otherPleaseSpecify.
  ///
  /// In en, this message translates to:
  /// **'Other (please specify)'**
  String get otherPleaseSpecify;

  /// No description provided for @pleaseSpecifyReason.
  ///
  /// In en, this message translates to:
  /// **'Please specify the reason'**
  String get pleaseSpecifyReason;

  /// Button to ban a user
  ///
  /// In en, this message translates to:
  /// **'Ban User'**
  String get banUser;

  /// No description provided for @unbanUser.
  ///
  /// In en, this message translates to:
  /// **'Unban User'**
  String get unbanUser;

  /// Message asking to select reason for banning user
  ///
  /// In en, this message translates to:
  /// **'Please select a reason for banning {username}'**
  String pleaseSelectReasonForBanningUser(String username);

  /// No description provided for @violationOfCommunityGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Violation of community guidelines'**
  String get violationOfCommunityGuidelines;

  /// No description provided for @harassmentOrAbusiveBehavior.
  ///
  /// In en, this message translates to:
  /// **'Harassment or abusive behavior'**
  String get harassmentOrAbusiveBehavior;

  /// No description provided for @postingInappropriateContent.
  ///
  /// In en, this message translates to:
  /// **'Posting inappropriate content'**
  String get postingInappropriateContent;

  /// No description provided for @accountCompromiseOrSecurityIssue.
  ///
  /// In en, this message translates to:
  /// **'Account compromise or security issue'**
  String get accountCompromiseOrSecurityIssue;

  /// No description provided for @enterReasonForBanningUser.
  ///
  /// In en, this message translates to:
  /// **'Enter the reason for banning this user'**
  String get enterReasonForBanningUser;

  /// No description provided for @banUntil.
  ///
  /// In en, this message translates to:
  /// **'Ban until'**
  String get banUntil;

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

  /// No description provided for @topicStickied.
  ///
  /// In en, this message translates to:
  /// **'Topic stickied'**
  String get topicStickied;

  /// No description provided for @topicUnstickied.
  ///
  /// In en, this message translates to:
  /// **'Topic unstickied'**
  String get topicUnstickied;

  /// Error message when cannot edit message
  ///
  /// In en, this message translates to:
  /// **'Cannot edit this message: {error}'**
  String cannotEditMessage(String error);

  /// No description provided for @confirmSpamClean.
  ///
  /// In en, this message translates to:
  /// **'Confirm Spam Clean'**
  String get confirmSpamClean;

  /// No description provided for @handleThreads.
  ///
  /// In en, this message translates to:
  /// **'Handle topics'**
  String get handleThreads;

  /// No description provided for @deleteMessages.
  ///
  /// In en, this message translates to:
  /// **'Delete Messages'**
  String get deleteMessages;

  /// No description provided for @deleteConversations.
  ///
  /// In en, this message translates to:
  /// **'Delete Messages'**
  String get deleteConversations;

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'No messages'**
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

  /// Menu item for spam cleaner tool
  ///
  /// In en, this message translates to:
  /// **'Spam Cleaner'**
  String get spamCleaner;

  /// Button to send a message to a user
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// No description provided for @lastActivity.
  ///
  /// In en, this message translates to:
  /// **'Last Activity'**
  String get lastActivity;

  /// No description provided for @likesReceived.
  ///
  /// In en, this message translates to:
  /// **'Likes Received'**
  String get likesReceived;

  /// No description provided for @likesGiven.
  ///
  /// In en, this message translates to:
  /// **'Likes Given'**
  String get likesGiven;

  /// Button to show more content
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// Button to execute spam clean
  ///
  /// In en, this message translates to:
  /// **'Clean Spam'**
  String get cleanSpam;

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

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @markForumRead.
  ///
  /// In en, this message translates to:
  /// **'Mark category read'**
  String get markForumRead;

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

  /// Error message when loading conversations fails
  ///
  /// In en, this message translates to:
  /// **'Error loading messages: {error}'**
  String errorLoadingConversations(String error);

  /// Error message when leaving conversation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to leave message: {error}'**
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

  /// No description provided for @permanent.
  ///
  /// In en, this message translates to:
  /// **'Permanent'**
  String get permanent;

  /// No description provided for @temporary.
  ///
  /// In en, this message translates to:
  /// **'Temporary'**
  String get temporary;

  /// Message asking to set ban duration
  ///
  /// In en, this message translates to:
  /// **'Set the ban duration for {username}'**
  String setBanDurationFor(String username);

  /// No description provided for @pleaseSelectEndDateForTemporaryBan.
  ///
  /// In en, this message translates to:
  /// **'Please select an end date for temporary ban'**
  String get pleaseSelectEndDateForTemporaryBan;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @unban.
  ///
  /// In en, this message translates to:
  /// **'Unban'**
  String get unban;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Title for spam clean dialog
  ///
  /// In en, this message translates to:
  /// **'Spam Clean {username}'**
  String spamClean(String username);

  /// No description provided for @selectActionsToPerform.
  ///
  /// In en, this message translates to:
  /// **'Select the actions to perform:'**
  String get selectActionsToPerform;

  /// No description provided for @moveOrDeleteThreadsBasedOnAdminSettings.
  ///
  /// In en, this message translates to:
  /// **'Move or delete topics based on admin settings'**
  String get moveOrDeleteThreadsBasedOnAdminSettings;

  /// No description provided for @messageUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Message updated successfully'**
  String get messageUpdatedSuccessfully;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(String error);

  /// Error message when removing attachment fails
  ///
  /// In en, this message translates to:
  /// **'Failed to remove attachment: {error}'**
  String failedToRemoveAttachment(String error);

  /// Error message when loading message fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load message: {error}'**
  String failedToLoadMessage(String error);

  /// No description provided for @editMessage.
  ///
  /// In en, this message translates to:
  /// **'Edit Message'**
  String get editMessage;

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
  /// **'Mark as unread'**
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

  /// No description provided for @undelete.
  ///
  /// In en, this message translates to:
  /// **'Undelete'**
  String get undelete;

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

  /// Menu item to unlock a topic
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// Menu item to lock a topic
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get lock;

  /// Menu item to stick/pin a topic
  ///
  /// In en, this message translates to:
  /// **'Stick'**
  String get stick;

  /// Menu item to unstick/unpin a topic
  ///
  /// In en, this message translates to:
  /// **'Unstick'**
  String get unstick;

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
  /// **'{count} votes'**
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

  /// Success message after submitting a report
  ///
  /// In en, this message translates to:
  /// **'Report submitted successfully'**
  String get reportSubmittedSuccessfully;

  /// Title for delete topic dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Topic'**
  String get deleteTopic;

  /// Description for soft delete option
  ///
  /// In en, this message translates to:
  /// **'Topic can be restored later'**
  String get topicCanBeRestoredLater;

  /// Description for hard delete option
  ///
  /// In en, this message translates to:
  /// **'Topic will be permanently deleted'**
  String get topicWillBePermanentlyDeleted;

  /// Hint text for deletion reason field
  ///
  /// In en, this message translates to:
  /// **'Enter the reason for deleting this topic'**
  String get enterReasonForDeletingTopic;

  /// Error message when end date is not selected
  ///
  /// In en, this message translates to:
  /// **'Please select an end date'**
  String get pleaseSelectEndDate;

  /// Success message after banning a user
  ///
  /// In en, this message translates to:
  /// **'User banned successfully'**
  String get userBannedSuccessfully;

  /// Error message when banning user fails
  ///
  /// In en, this message translates to:
  /// **'Failed to ban user'**
  String get failedToBanUser;

  /// Success message after unbanning a user
  ///
  /// In en, this message translates to:
  /// **'User unbanned successfully'**
  String get userUnbannedSuccessfully;

  /// Error message when unbanning user fails
  ///
  /// In en, this message translates to:
  /// **'Failed to unban user'**
  String get failedToUnbanUser;

  /// Title for spam clean user dialog
  ///
  /// In en, this message translates to:
  /// **'Spam Clean User'**
  String get spamCleanUser;

  /// Option to delete private conversations in spam clean
  ///
  /// In en, this message translates to:
  /// **'Delete personal messages'**
  String get deletePrivateConversations;

  /// Option to ban user account in spam clean
  ///
  /// In en, this message translates to:
  /// **'Ban the user account'**
  String get banTheUserAccount;

  /// Action performed: handled threads
  ///
  /// In en, this message translates to:
  /// **'Handled topics'**
  String get handledThreads;

  /// Action performed: deleted messages
  ///
  /// In en, this message translates to:
  /// **'Deleted messages'**
  String get deletedMessages;

  /// Action performed: deleted conversations
  ///
  /// In en, this message translates to:
  /// **'Deleted messages'**
  String get deletedConversations;

  /// Action performed: banned user
  ///
  /// In en, this message translates to:
  /// **'Banned user'**
  String get bannedUser;

  /// Success message after spam clean
  ///
  /// In en, this message translates to:
  /// **'Successfully cleaned spam for {username}. Actions: {actions}'**
  String successfullyCleanedSpam(String username, String actions);

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

  /// Dialog title for marking all forums as read
  ///
  /// In en, this message translates to:
  /// **'Mark all categories as read?'**
  String get markAllForumsAsRead;

  /// Message explaining mark all forums as read action
  ///
  /// In en, this message translates to:
  /// **'This will mark all categories and topics as read. This action cannot be undone.'**
  String get markAllForumsAsReadMessage;

  /// Button text to mark as read
  ///
  /// In en, this message translates to:
  /// **'Mark as Read'**
  String get markAsRead;

  /// Content label for message compose
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// Dialog title for inserting image
  ///
  /// In en, this message translates to:
  /// **'Insert Image'**
  String get insertImage;

  /// Question asking how to insert image
  ///
  /// In en, this message translates to:
  /// **'How would you like to insert this image?'**
  String get howWouldYouLikeToInsertImage;

  /// Option to insert image as thumbnail
  ///
  /// In en, this message translates to:
  /// **'Thumbnail'**
  String get thumbnail;

  /// Option to insert image at full size
  ///
  /// In en, this message translates to:
  /// **'Full Size'**
  String get fullSize;

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

  /// Status message when submitting report
  ///
  /// In en, this message translates to:
  /// **'Submitting report...'**
  String get submittingReport;

  /// Status message when banning user
  ///
  /// In en, this message translates to:
  /// **'Banning user...'**
  String get banningUser;

  /// Status message when unbanning user
  ///
  /// In en, this message translates to:
  /// **'Unbanning user...'**
  String get unbanningUser;

  /// Status message when cleaning spam
  ///
  /// In en, this message translates to:
  /// **'Cleaning spam...'**
  String get cleaningSpam;

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

  /// Success message after creating conversation
  ///
  /// In en, this message translates to:
  /// **'Message created successfully'**
  String get conversationCreatedSuccessfully;

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

  /// Message asking user to login to like messages
  ///
  /// In en, this message translates to:
  /// **'Please login to like messages'**
  String get pleaseLoginToLikeMessages;

  /// Button to load earlier messages
  ///
  /// In en, this message translates to:
  /// **'Load Earlier Messages'**
  String get loadEarlierMessages;

  /// Error message when loading quote fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load quote: \n{error}'**
  String failedToLoadQuote(String error);

  /// Error message when sending reply fails
  ///
  /// In en, this message translates to:
  /// **'Failed to send reply: {error}'**
  String failedToSendReply(String error);

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

  /// Error message when jumping to message fails
  ///
  /// In en, this message translates to:
  /// **'Failed to jump to message: {error}'**
  String failedToJumpToMessage(String error);

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

  /// Button text to report
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

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
  /// **'Message updated successfully'**
  String get conversationUpdatedSuccessfully;

  /// Button text to go back
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// Error message when loading post fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load post: \n{error}'**
  String failedToLoadPost(String error);

  /// Error message when liking/unliking message fails
  ///
  /// In en, this message translates to:
  /// **'Failed to {action} message: {error}'**
  String failedToLikeOrUnlikeMessage(String action, String error);

  /// Action verb: like
  ///
  /// In en, this message translates to:
  /// **'like'**
  String get like;

  /// Action verb: unlike
  ///
  /// In en, this message translates to:
  /// **'unlike'**
  String get unlike;

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

  /// Error message when navigation to category fails
  ///
  /// In en, this message translates to:
  /// **'Failed to navigate to category'**
  String get failedToNavigateToForum;

  /// Error message when forum is not found by ID
  ///
  /// In en, this message translates to:
  /// **'Category not found: {forumId}'**
  String forumNotFoundById(String forumId);

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

  /// Vote count on a topic row
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 vote} other{{count} votes}}'**
  String nVotes(int count);

  /// Profile stat: when the user was last online
  ///
  /// In en, this message translates to:
  /// **'Seen'**
  String get lastSeen;

  /// UI text: Chat
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// UI text: {label} — coming soon
  ///
  /// In en, this message translates to:
  /// **'{label} — coming soon'**
  String comingSoon(String label);

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

  /// UI text: Discard draft?
  ///
  /// In en, this message translates to:
  /// **'Discard draft?'**
  String get discardDraftQuestion;

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

  /// UI text: Retry connection
  ///
  /// In en, this message translates to:
  /// **'Retry connection'**
  String get retryConnection;

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

  /// UI text: Sign out?
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutQuestion;

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

  /// UI text: Submit
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// UI text: This will permanently remove the saved draft.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove the saved draft.'**
  String get discardDraftWarning;

  /// UI text: This will remove the message for everyone.
  ///
  /// In en, this message translates to:
  /// **'This will remove the message for everyone.'**
  String get deleteChatMessageWarning;

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
  /// **'Undelete Topic'**
  String get undeleteTopic;

  /// UI text: Are you sure you want to undelete this topic? It will be vis
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to undelete this topic? It will be visible to other users again.'**
  String get undeleteTopicConfirmation;

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

  /// UI text: New direct message
  ///
  /// In en, this message translates to:
  /// **'New direct message'**
  String get newDirectMessage;

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

  /// UI text: Display name, email, password, and other account settings ar
  ///
  /// In en, this message translates to:
  /// **'Display name, email, password, and other account settings are managed under Account → Manage account on web. Your avatar can be changed by tapping the camera badge on your photo.'**
  String get editProfileManagedOnWebNote;

  /// UI text: push approved but relay unreachable
  ///
  /// In en, this message translates to:
  /// **'Approved, but we could not reach ForumCopilot to finish setting up. Try again later from Settings.'**
  String get approvedButRelayUnreachable;

  /// UI text: Notifications are turned off for this app
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for this app'**
  String get notificationsAreTurnedOffForThisApp;

  /// UI text: Next, {forumName} will ask you to approve “Notifications”.
  ///
  /// In en, this message translates to:
  /// **'Next, {forumName} will ask you to approve “Notifications”.'**
  String forumWillAskToApproveNotifications(Object forumName);

  /// UI text: Approving lets us check your notifications for you and send
  ///
  /// In en, this message translates to:
  /// **'Approving lets us check your notifications for you and send them to this device. This permission cannot post, reply, or read your messages.'**
  String get approveNotificationsExplanation;

  /// UI text: If this forum’s owner sets up notifications for the app, thi
  ///
  /// In en, this message translates to:
  /// **'If this forum’s owner sets up notifications for the app, this step won’t be needed.'**
  String get forumOwnerPushNote;

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

  /// UI text: Protected
  ///
  /// In en, this message translates to:
  /// **'Protected'**
  String get protected;

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

  /// UI text: Announcement
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get announcement;

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

  /// UI text: Subscribed
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get subscribedLabel;

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

  /// UI text: Error loading content: {error}
  ///
  /// In en, this message translates to:
  /// **'Error loading content: {error}'**
  String errorLoadingContent(Object error);

  /// UI text: You do not have permission to view topics in this subforum.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to view topics in this subforum.'**
  String get noPermissionToViewSubforum;

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

  /// UI text: This topic is deleted and hidden from other users
  ///
  /// In en, this message translates to:
  /// **'This topic is deleted and hidden from other users'**
  String get topicDeletedBanner;

  /// UI text: This topic is closed and no longer accepting replies
  ///
  /// In en, this message translates to:
  /// **'This topic is closed and no longer accepting replies'**
  String get topicClosedBanner;

  /// UI text: This topic is pinned to the top of the forum
  ///
  /// In en, this message translates to:
  /// **'This topic is pinned to the top of the forum'**
  String get topicPinnedBanner;

  /// UI text: You are subscribed to this topic
  ///
  /// In en, this message translates to:
  /// **'You are subscribed to this topic'**
  String get youAreSubscribedToThisTopic;

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

  /// UI text: Edit conversation
  ///
  /// In en, this message translates to:
  /// **'Edit conversation'**
  String get editConversation;

  /// UI text: Close conversation
  ///
  /// In en, this message translates to:
  /// **'Close conversation'**
  String get closeConversation;

  /// UI text: Open conversation
  ///
  /// In en, this message translates to:
  /// **'Open conversation'**
  String get openConversation;

  /// UI text: Leave conversation
  ///
  /// In en, this message translates to:
  /// **'Leave conversation'**
  String get leaveConversation2;

  /// UI text: Report conversation
  ///
  /// In en, this message translates to:
  /// **'Report conversation'**
  String get reportConversation2;

  /// UI text: Close Conversation
  ///
  /// In en, this message translates to:
  /// **'Close Conversation'**
  String get closeConversation2;

  /// UI text: Are you sure you want to close this conversation? This will
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close this conversation? This will prevent new replies from being posted.'**
  String get closeConversationConfirmation;

  /// UI text: Close
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// UI text: Open Conversation
  ///
  /// In en, this message translates to:
  /// **'Open Conversation'**
  String get openConversation2;

  /// UI text: Are you sure you want to open this conversation? This will a
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to open this conversation? This will allow new replies to be posted.'**
  String get openConversationConfirmation;

  /// UI text: Open
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// UI text: Leave Conversation
  ///
  /// In en, this message translates to:
  /// **'Leave Conversation'**
  String get leaveConversation3;

  /// UI text: Are you sure you want to leave this conversation? This will
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this conversation? This will hide it from your inbox.'**
  String get leaveConversationConfirmation;

  /// UI text: Error loading conversation: {error}
  ///
  /// In en, this message translates to:
  /// **'Error loading conversation: {error}'**
  String errorLoadingConversation(Object error);

  /// UI text: Conversation not found
  ///
  /// In en, this message translates to:
  /// **'Conversation not found'**
  String get conversationNotFound;

  /// UI text: This conversation is closed and no longer accepting replies
  ///
  /// In en, this message translates to:
  /// **'This conversation is closed and no longer accepting replies'**
  String get conversationClosedBanner;

  /// UI text: No messages found
  ///
  /// In en, this message translates to:
  /// **'No messages found'**
  String get noMessagesFound;

  /// UI text: End of conversation
  ///
  /// In en, this message translates to:
  /// **'End of conversation'**
  String get endOfConversation;

  /// UI text: Jump to Message
  ///
  /// In en, this message translates to:
  /// **'Jump to Message'**
  String get jumpToMessage;

  /// UI text: Edit Conversation
  ///
  /// In en, this message translates to:
  /// **'Edit Conversation'**
  String get editConversation2;

  /// UI text: Failed to load message
  ///
  /// In en, this message translates to:
  /// **'Failed to load message'**
  String get failedToLoadMessage2;

  /// UI text: Cannot edit this conversation
  ///
  /// In en, this message translates to:
  /// **'Cannot edit this conversation'**
  String get cannotEditThisConversation;

  /// UI text: Options
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// UI text: Conversation Open
  ///
  /// In en, this message translates to:
  /// **'Conversation Open'**
  String get conversationOpen;

  /// UI text: Failed to create conversation: {toString}
  ///
  /// In en, this message translates to:
  /// **'Failed to create conversation: {error}'**
  String failedToCreateConversation(Object error);

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

  /// UI text: Please login to view this attachment
  ///
  /// In en, this message translates to:
  /// **'Please login to view this attachment'**
  String get pleaseLoginToViewThisAttachment;

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

  /// UI text: Email frequency, like aggregation, digest schedule
  ///
  /// In en, this message translates to:
  /// **'Email frequency, like aggregation, digest schedule'**
  String get emailSettingsSubtitle;

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
  /// **'Removing your account is handled on the forum. Continue to open the site and contact the staff team — Discourse forums process deletions per their own policy.'**
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

  /// UI text: Unable to Load Forums
  ///
  /// In en, this message translates to:
  /// **'Unable to Load Forums'**
  String get unableToLoadForums;

  /// UI text: There are no forums to display. This might be due to permiss
  ///
  /// In en, this message translates to:
  /// **'There are no forums to display. This might be due to permissions or the forum structure.'**
  String get noForumsToDisplayExplanation;

  /// UI text: Subscribed Forums
  ///
  /// In en, this message translates to:
  /// **'Subscribed Forums'**
  String get subscribedForums;

  /// UI text: Error loading notifications
  ///
  /// In en, this message translates to:
  /// **'Error loading notifications'**
  String get errorLoadingNotifications;

  /// UI text: Pull down to refresh
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh'**
  String get pullDownToRefresh;

  /// UI text: You have no new notifications. Check back later for updates
  ///
  /// In en, this message translates to:
  /// **'You have no new notifications. Check back later for updates on topics you\'re following.'**
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

  /// UI text: Failed to ban user: {toString}
  ///
  /// In en, this message translates to:
  /// **'Failed to ban user: {error}'**
  String failedToBanUser2(Object error);

  /// UI text: Are you sure you want to unban {username}?
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unban {username}?'**
  String unbanUserConfirmation(Object username);

  /// UI text: Failed to unban user: {toString}
  ///
  /// In en, this message translates to:
  /// **'Failed to unban user: {error}'**
  String failedToUnbanUser2(Object error);

  /// UI text: Delete posts, profile posts, and comments
  ///
  /// In en, this message translates to:
  /// **'Delete posts, profile posts, and comments'**
  String get deletePostsProfilePostsAndComments;

  /// UI text: Are you sure you want to spam clean {username}?
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to spam clean {username}?'**
  String spamCleanConfirmation(Object username);

  /// UI text: Failed to clean spam: {toString}
  ///
  /// In en, this message translates to:
  /// **'Failed to clean spam: {error}'**
  String failedToCleanSpam(Object error);

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

  /// UI text: All forum topics have been marked as read
  ///
  /// In en, this message translates to:
  /// **'All forum topics have been marked as read'**
  String get allForumTopicsHaveBeenMarkedAs;

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

  /// UI text: Failed to pick file
  ///
  /// In en, this message translates to:
  /// **'Failed to pick file'**
  String get failedToPickFile;

  /// UI text: Only {remainingSlots} more attachment(s) allowed. Processing
  ///
  /// In en, this message translates to:
  /// **'Only {remainingSlots} more attachment(s) allowed. Processing first {remainingSlots2} image(s).'**
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2);

  /// UI text: Attachment limit reached. Skipping remaining images.
  ///
  /// In en, this message translates to:
  /// **'Attachment limit reached. Skipping remaining images.'**
  String get attachmentLimitReachedSkippingRemainingImages;

  /// UI text: {name}: Failed to upload image. Please try again.
  ///
  /// In en, this message translates to:
  /// **'{fileName}: Failed to upload image. Please try again.'**
  String failedToUploadImagePleaseTryAgain(Object fileName);

  /// UI text: {name}: Failed to upload image: {errorMessage}
  ///
  /// In en, this message translates to:
  /// **'{fileName}: Failed to upload image: {errorMessage}'**
  String failedToUploadImage2(Object errorMessage, Object fileName);

  /// UI text: Failed to pick image
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image'**
  String get failedToPickImage;

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

  /// UI text: Please wait for the thread to load
  ///
  /// In en, this message translates to:
  /// **'Please wait for the thread to load'**
  String get pleaseWaitForTheThreadToLoad;

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

  /// UI text: Failed to submit report: {toString}
  ///
  /// In en, this message translates to:
  /// **'Failed to submit report: {error}'**
  String failedToSubmitReport2(Object error);

  /// UI text: Edit history is not available for this post
  ///
  /// In en, this message translates to:
  /// **'Edit history is not available for this post'**
  String get editHistoryNotAvailable;

  /// UI text: You do not have permission to upload avatars
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to upload avatars'**
  String get noPermissionToUploadAvatar;

  /// UI text: Avatar uploaded successfully
  ///
  /// In en, this message translates to:
  /// **'Avatar uploaded successfully'**
  String get avatarUploadedSuccessfully;

  /// UI text: Failed to pick image: {e}
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String failedToPickImage2(Object error);

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

  /// UI text: You will be signed out of {name}. You can sign back in any t
  ///
  /// In en, this message translates to:
  /// **'You will be signed out of {siteName}. You can sign back in any time.'**
  String signOutWarning(Object siteName);

  /// UI text: Suggested Topics
  ///
  /// In en, this message translates to:
  /// **'Suggested Topics'**
  String get suggestedTopics;

  /// UI text: NEW
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newLabel;

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

  /// Drawer entry, shown only inside a multi-forum host app, that returns to its forum list
  ///
  /// In en, this message translates to:
  /// **'Switch forum'**
  String get switchForum;
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
