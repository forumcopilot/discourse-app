// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginTitle => 'Login';

  @override
  String get usePasskey => 'Use Passkey';

  @override
  String get passkeyContinuePrompt => 'Use your passkey to continue';

  @override
  String get continueButton => 'Continue';

  @override
  String get errorTitle => 'Error';

  @override
  String get okButton => 'OK';

  @override
  String get retryButton => 'Retry';

  @override
  String get copyToClipboard => 'Copy to Clipboard';

  @override
  String get copied => 'Copied';

  @override
  String get errorMessageCopiedToClipboard =>
      'Error message copied to clipboard';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get cancel => 'Cancel';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get anErrorOccurred => 'An error occurred';

  @override
  String get accountPendingApproval =>
      'Your account is pending approval. You can browse the forum but cannot post until a moderator approves your account.';

  @override
  String get checkEmailToConfirm =>
      'Please check your email to confirm your account. Click the confirmation link in the email we sent you.';

  @override
  String get checkNewEmailToConfirm =>
      'Please check your new email address to confirm the change. Your old email will remain active until you confirm the new one.';

  @override
  String get emailAddressInvalid =>
      'Your email address appears to be invalid or is bouncing emails. Please update your email address in account settings.';

  @override
  String get accountDisabled =>
      'Your account has been disabled. Please contact an administrator for assistance.';

  @override
  String get accountRegistrationRejected =>
      'Your account registration was rejected. Please contact an administrator for more information.';

  @override
  String get welcomeToForumCopilot => 'Welcome to Forum Copilot!';

  @override
  String get successfullyLoggedOut => 'You have been successfully logged out';

  @override
  String get accountStatusRequiresAttention =>
      'Your account status requires attention. Please contact an administrator if you have questions.';

  @override
  String get updateEmail => 'Update Email';

  @override
  String get resend => 'Resend';

  @override
  String get noLatestTopics => 'No Latest Topics';

  @override
  String get noRecentTopicsToDisplay =>
      'There are no recent topics to display. Check back later for new discussions.';

  @override
  String get signInToViewLatestTopics => 'Sign in to view latest topics';

  @override
  String get youNeedToBeSignedInToViewLatestTopics =>
      'You need to be signed in to view latest topics.';

  @override
  String get thereAreNoUnreadTopics =>
      'There are no unread topics. Check back later for new discussions.';

  @override
  String get youAreAllCaughtUp => 'You\'re all caught up!';

  @override
  String get signInToViewUnreadTopics => 'Sign in to view unread topics';

  @override
  String get youNeedToBeSignedInToViewUnreadTopics =>
      'You need to be signed in to view your unread topics.';

  @override
  String get latest => 'Latest';

  @override
  String get unread => 'Unread';

  @override
  String get failedToConnectToSite =>
      'Failed to connect to site. The site may be down or unreachable.';

  @override
  String get connectionFailed => 'Connection Failed';

  @override
  String failedToConnectToSiteName(String siteName) {
    return 'Failed to connect to $siteName';
  }

  @override
  String get loading => 'Loading...';

  @override
  String get newConversation => 'New Message';

  @override
  String get language => 'Language';

  @override
  String get all => 'All';

  @override
  String get topicsOnly => 'Topics Only';

  @override
  String get titlesOnly => 'Titles Only';

  @override
  String failedToShareTopic(String error) {
    return 'Failed to share topic: $error';
  }

  @override
  String get pleaseLoginToSubscribe =>
      'Please login to change notifications on this topic';

  @override
  String get subscribe => 'Notifications';

  @override
  String get failedToSubscribeToThread => 'Failed to update notifications';

  @override
  String get youCannotReplyToThisThread => 'You cannot reply to this topic';

  @override
  String get pleaseWaitForThreadToLoad => 'Please wait for the topic to load';

  @override
  String get softDelete => 'Soft Delete';

  @override
  String get postCanBeRestoredLater => 'Post can be restored later';

  @override
  String get hardDelete => 'Hard Delete';

  @override
  String get postWillBePermanentlyDeleted => 'Post will be permanently deleted';

  @override
  String get reasonForDeletion => 'Reason for deletion';

  @override
  String get enterReasonForDeletingPost =>
      'Enter the reason for deleting this post';

  @override
  String get pleaseEnterReasonForDeletion =>
      'Please enter a reason for deletion';

  @override
  String get reportPost => 'Report Post';

  @override
  String get pleaseProvideReasonForReporting =>
      'Please provide a reason for reporting this post.';

  @override
  String get reason => 'Reason';

  @override
  String get enterReasonForReportingPost =>
      'Enter the reason for reporting this post';

  @override
  String get pleaseEnterReason => 'Please enter a reason';

  @override
  String get submitReport => 'Submit Report';

  @override
  String get selectedActions => 'Selected actions:';

  @override
  String get thisActionCannotBeUndone => 'This action cannot be undone.';

  @override
  String get participantsLabel => 'Participants';

  @override
  String usernameHasBeenInvited(String username) {
    return '$username has been invited to the message';
  }

  @override
  String errorInvitingUser(String error) {
    return 'Error inviting user: $error';
  }

  @override
  String get newTopic => 'New Topic';

  @override
  String get markRead => 'Mark Read';

  @override
  String get spamOrAdvertising => 'Spam or advertising';

  @override
  String get otherPleaseSpecify => 'Other (please specify)';

  @override
  String get pleaseSpecifyReason => 'Please specify the reason';

  @override
  String get banUser => 'Ban User';

  @override
  String get unbanUser => 'Unban User';

  @override
  String pleaseSelectReasonForBanningUser(String username) {
    return 'Please select a reason for banning $username';
  }

  @override
  String get violationOfCommunityGuidelines =>
      'Violation of community guidelines';

  @override
  String get harassmentOrAbusiveBehavior => 'Harassment or abusive behavior';

  @override
  String get postingInappropriateContent => 'Posting inappropriate content';

  @override
  String get accountCompromiseOrSecurityIssue =>
      'Account compromise or security issue';

  @override
  String get enterReasonForBanningUser =>
      'Enter the reason for banning this user';

  @override
  String get banUntil => 'Ban until';

  @override
  String get selectDate => 'Select date';

  @override
  String get moreOptions => 'More options';

  @override
  String get topicClosed => 'Topic closed';

  @override
  String get topicOpened => 'Topic opened';

  @override
  String get topicStickied => 'Topic stickied';

  @override
  String get topicUnstickied => 'Topic unstickied';

  @override
  String cannotEditMessage(String error) {
    return 'Cannot edit this message: $error';
  }

  @override
  String get confirmSpamClean => 'Confirm Spam Clean';

  @override
  String get handleThreads => 'Handle topics';

  @override
  String get deleteMessages => 'Delete Messages';

  @override
  String get deleteConversations => 'Delete Messages';

  @override
  String get noConversations => 'No messages';

  @override
  String get noConversationsMessage =>
      'You have no messages yet. Start a new message to begin.';

  @override
  String get imageSavedToGallery => 'Image saved to gallery!';

  @override
  String failedToSaveImage(String error) {
    return 'Failed to save image: $error';
  }

  @override
  String get userProfile => 'User Profile';

  @override
  String get deletePost => 'Delete Post';

  @override
  String get loginRequired => 'Login Required';

  @override
  String get spamCleaner => 'Spam Cleaner';

  @override
  String get sendMessage => 'Send Message';

  @override
  String get memberSince => 'Member Since';

  @override
  String get lastActivity => 'Last Activity';

  @override
  String get likesReceived => 'Likes Received';

  @override
  String get likesGiven => 'Likes Given';

  @override
  String get showMore => 'Show More';

  @override
  String get cleanSpam => 'Clean Spam';

  @override
  String get failedToSaveConversation => 'Failed to save message';

  @override
  String get members => 'Members';

  @override
  String membersCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString Members';
  }

  @override
  String get noSubject => 'No subject';

  @override
  String get search => 'Search';

  @override
  String get logout => 'Logout';

  @override
  String get areYouSureYouWantToLogout => 'Are you sure you want to logout?';

  @override
  String get register => 'Register';

  @override
  String get signIn => 'Sign In';

  @override
  String get markForumRead => 'Mark category read';

  @override
  String get notificationTest => 'Notification Test';

  @override
  String get forum => 'Category';

  @override
  String get profile => 'Profile';

  @override
  String get messages => 'Messages';

  @override
  String get add => 'Add';

  @override
  String get retry => 'Retry';

  @override
  String get delete => 'Delete';

  @override
  String get deleteMessage => 'Delete Message';

  @override
  String get deletingPost => 'Deleting post...';

  @override
  String failedToUnlikePost(String error) {
    return 'Failed to unlike post: $error';
  }

  @override
  String failedToLikePost(String error) {
    return 'Failed to like post: $error';
  }

  @override
  String get signInToViewMessages => 'Sign in to view messages';

  @override
  String get youNeedToBeSignedInToViewConversations =>
      'You need to be signed in to view your messages.';

  @override
  String errorLoadingConversations(String error) {
    return 'Error loading messages: $error';
  }

  @override
  String failedToLeaveConversation(String error) {
    return 'Failed to leave message: $error';
  }

  @override
  String errorLoadingMoreConversations(String error) {
    return 'Error loading more messages: $error';
  }

  @override
  String get searchFailed => 'Search failed';

  @override
  String get userInformationNotAvailable => 'User information not available';

  @override
  String get birthday => 'Birthday';

  @override
  String get posts => 'Posts';

  @override
  String get following => 'Following';

  @override
  String get followers => 'Followers';

  @override
  String get about => 'About';

  @override
  String get location => 'Location';

  @override
  String get website => 'Website';

  @override
  String get next => 'Next';

  @override
  String get permanent => 'Permanent';

  @override
  String get temporary => 'Temporary';

  @override
  String setBanDurationFor(String username) {
    return 'Set the ban duration for $username';
  }

  @override
  String get pleaseSelectEndDateForTemporaryBan =>
      'Please select an end date for temporary ban';

  @override
  String get back => 'Back';

  @override
  String get unban => 'Unban';

  @override
  String get confirm => 'Confirm';

  @override
  String spamClean(String username) {
    return 'Spam Clean $username';
  }

  @override
  String get selectActionsToPerform => 'Select the actions to perform:';

  @override
  String get moveOrDeleteThreadsBasedOnAdminSettings =>
      'Move or delete topics based on admin settings';

  @override
  String get messageUpdatedSuccessfully => 'Message updated successfully';

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String failedToRemoveAttachment(String error) {
    return 'Failed to remove attachment: $error';
  }

  @override
  String failedToLoadMessage(String error) {
    return 'Failed to load message: $error';
  }

  @override
  String get editMessage => 'Edit Message';

  @override
  String get removeAttachment => 'Remove Attachment';

  @override
  String get areYouSureYouWantToRemoveThisAttachment =>
      'Are you sure you want to remove this attachment?';

  @override
  String get none => 'None';

  @override
  String get attachFile => 'Attach file';

  @override
  String get uploadImage => 'Upload image';

  @override
  String get formatting => 'Formatting';

  @override
  String get bold => 'Bold';

  @override
  String get italic => 'Italic';

  @override
  String get underline => 'Underline';

  @override
  String get strikethrough => 'Strikethrough';

  @override
  String get link => 'Link';

  @override
  String get image => 'Image';

  @override
  String get video => 'Video';

  @override
  String get quote => 'Quote';

  @override
  String get code => 'Code';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get bulletList => 'Bullet List';

  @override
  String get numberedList => 'Numbered List';

  @override
  String get listItem => 'List Item';

  @override
  String participants(int count) {
    return 'Participants ($count)';
  }

  @override
  String get markAsUnread => 'Mark as unread';

  @override
  String get invite => 'Invite';

  @override
  String get enterKeywordsToSearchTopics =>
      'Enter keywords to search topics...';

  @override
  String get undelete => 'Undelete';

  @override
  String get refresh => 'Refresh';

  @override
  String get share => 'Share';

  @override
  String get viewOnWeb => 'View on Web';

  @override
  String get unlock => 'Unlock';

  @override
  String get lock => 'Lock';

  @override
  String get stick => 'Stick';

  @override
  String get unstick => 'Unstick';

  @override
  String get reply => 'Reply';

  @override
  String get vote => 'Vote';

  @override
  String votesCount(int count) {
    return '$count votes';
  }

  @override
  String get pollClosed => 'Poll closed';

  @override
  String pollEndsOn(String date) {
    return 'Ends $date';
  }

  @override
  String get voteToSeeResults => 'Vote to see results';

  @override
  String get viewFullPoll => 'View full poll';

  @override
  String pollOptionsCount(int count) {
    return '$count options';
  }

  @override
  String get reactedBy => 'Reacted by';

  @override
  String get enterKeywordsToFindTopicsAndPosts =>
      'Enter keywords to find topics and posts';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String version(String version, String buildNumber) {
    return 'version $version ($buildNumber)';
  }

  @override
  String get unableToLoadProfile => 'Unable to Load Profile';

  @override
  String get banned => 'BANNED';

  @override
  String get reportSubmittedSuccessfully => 'Report submitted successfully';

  @override
  String get deleteTopic => 'Delete Topic';

  @override
  String get topicCanBeRestoredLater => 'Topic can be restored later';

  @override
  String get topicWillBePermanentlyDeleted =>
      'Topic will be permanently deleted';

  @override
  String get enterReasonForDeletingTopic =>
      'Enter the reason for deleting this topic';

  @override
  String get pleaseSelectEndDate => 'Please select an end date';

  @override
  String get userBannedSuccessfully => 'User banned successfully';

  @override
  String get failedToBanUser => 'Failed to ban user';

  @override
  String get userUnbannedSuccessfully => 'User unbanned successfully';

  @override
  String get failedToUnbanUser => 'Failed to unban user';

  @override
  String get spamCleanUser => 'Spam Clean User';

  @override
  String get deletePrivateConversations => 'Delete personal messages';

  @override
  String get banTheUserAccount => 'Ban the user account';

  @override
  String get handledThreads => 'Handled topics';

  @override
  String get deletedMessages => 'Deleted messages';

  @override
  String get deletedConversations => 'Deleted messages';

  @override
  String get bannedUser => 'Banned user';

  @override
  String successfullyCleanedSpam(String username, String actions) {
    return 'Successfully cleaned spam for $username. Actions: $actions';
  }

  @override
  String get home => 'Home';

  @override
  String get notifications => 'Notifications';

  @override
  String get forums => 'Categories';

  @override
  String get markAllForumsAsRead => 'Mark all categories as read?';

  @override
  String get markAllForumsAsReadMessage =>
      'This will mark all categories and topics as read. This action cannot be undone.';

  @override
  String get markAsRead => 'Mark as Read';

  @override
  String get content => 'Content';

  @override
  String get insertImage => 'Insert Image';

  @override
  String get howWouldYouLikeToInsertImage =>
      'How would you like to insert this image?';

  @override
  String get thumbnail => 'Thumbnail';

  @override
  String get fullSize => 'Full Size';

  @override
  String get pleaseEnterTitle => 'Please enter a title';

  @override
  String get pleaseEnterContent => 'Please enter some content';

  @override
  String get uploading => 'Uploading...';

  @override
  String get uploaded => 'Uploaded';

  @override
  String get mentionUser => 'Mention User';

  @override
  String get submittingReport => 'Submitting report...';

  @override
  String get banningUser => 'Banning user...';

  @override
  String get unbanningUser => 'Unbanning user...';

  @override
  String get cleaningSpam => 'Cleaning spam...';

  @override
  String get writeYourMessage => 'Write your message...';

  @override
  String get writeYourReply => 'Write your reply...';

  @override
  String get conversationCreatedSuccessfully => 'Message created successfully';

  @override
  String get conversationMarkedAsUnread => 'Message marked as unread';

  @override
  String get conversationClosed => 'Message closed';

  @override
  String get conversationOpened => 'Message opened';

  @override
  String get pleaseLoginToLikeMessages => 'Please login to like messages';

  @override
  String get loadEarlierMessages => 'Load Earlier Messages';

  @override
  String failedToLoadQuote(String error) {
    return 'Failed to load quote: \n$error';
  }

  @override
  String failedToSendReply(String error) {
    return 'Failed to send reply: $error';
  }

  @override
  String failedToMarkConversationAsUnread(String error) {
    return 'Failed to mark message as unread: $error';
  }

  @override
  String failedToCloseConversation(String error) {
    return 'Failed to close message: $error';
  }

  @override
  String failedToOpenConversation(String error) {
    return 'Failed to open message: $error';
  }

  @override
  String failedToJumpToMessage(String error) {
    return 'Failed to jump to message: $error';
  }

  @override
  String get goToTop => 'Go to top';

  @override
  String get goToBottom => 'Go to bottom';

  @override
  String get pleaseLoginToAccessContent =>
      'Please login to access this content and interact with posts.';

  @override
  String get searchUsers => 'Search users...';

  @override
  String get enterConversationTitle => 'Enter message title';

  @override
  String enterCode(int count) {
    return 'Enter $count-digit code';
  }

  @override
  String get edit => 'Edit';

  @override
  String get report => 'Report';

  @override
  String get remove => 'Remove';

  @override
  String get subject => 'Subject';

  @override
  String get message => 'Message';

  @override
  String get titleCannotBeEmpty => 'Title cannot be empty';

  @override
  String get conversationUpdatedSuccessfully => 'Message updated successfully';

  @override
  String get goBack => 'Go Back';

  @override
  String failedToLoadPost(String error) {
    return 'Failed to load post: \n$error';
  }

  @override
  String failedToLikeOrUnlikeMessage(String action, String error) {
    return 'Failed to $action message: $error';
  }

  @override
  String get like => 'like';

  @override
  String get unlike => 'unlike';

  @override
  String downloading(String filename) {
    return 'Downloading $filename...';
  }

  @override
  String openingShareSheet(String filename) {
    return 'Opening share sheet for $filename';
  }

  @override
  String errorDownloading(String filename, String error) {
    return 'Error downloading $filename: $error';
  }

  @override
  String get failedToNavigateToForum => 'Failed to navigate to category';

  @override
  String forumNotFoundById(String forumId) {
    return 'Category not found: $forumId';
  }

  @override
  String couldNotOpenLink(String error) {
    return 'Could not open link: $error';
  }

  @override
  String get translating => 'Translating...';

  @override
  String get translated => 'Translated';

  @override
  String get translatedContent => 'Translated content';

  @override
  String get twoFactorAuthentication => 'Two-Factor Authentication';

  @override
  String get authenticationCodeLabel => 'Authentication Code';

  @override
  String get pleaseEnterYourAuthenticationCode =>
      'Please enter your authentication code';

  @override
  String codeMustBeDigits(int count) {
    return 'Code must be $count digits';
  }

  @override
  String get codeMustContainOnlyNumbers => 'Code must contain only numbers';

  @override
  String get verifyButton => 'Verify';

  @override
  String get attachments => 'Attachments';

  @override
  String get replyOptions => 'Reply Options';

  @override
  String get replyWithQuote => 'Reply with Quote';

  @override
  String fileSavedToDownloads(String filename) {
    return 'File saved to Downloads: $filename';
  }

  @override
  String fileSavedToDocuments(String filename) {
    return 'File saved to Documents: $filename';
  }

  @override
  String topicLastReplyBy(String username, String time) {
    return '$username replied $time';
  }

  @override
  String inReplyToUser(String username) {
    return 'in reply to $username';
  }

  @override
  String inReplyToPost(int number) {
    return 'in reply to post #$number';
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
  String get profileViews => 'Views';

  @override
  String get badges => 'Badges';

  @override
  String get chatWithUser => 'Chat';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count replies',
      one: '1 reply',
    );
    return '$_temp0';
  }

  @override
  String nVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes',
      one: '1 vote',
    );
    return '$_temp0';
  }

  @override
  String get lastSeen => 'Seen';

  @override
  String get chat => 'Chat';

  @override
  String comingSoon(String label) {
    return '$label — coming soon';
  }

  @override
  String moreBadges(Object count) {
    return '+$count more';
  }

  @override
  String get allNotificationsMarkedAsRead => 'All notifications marked as read';

  @override
  String get apply => 'Apply';

  @override
  String get bookmarks => 'Bookmarks';

  @override
  String reviewableBy(String username) {
    return 'By $username';
  }

  @override
  String get changeEmail => 'Change email';

  @override
  String get changePassword => 'Change password';

  @override
  String get checkingStatus => 'Checking status…';

  @override
  String get clearReminder => 'Clear reminder';

  @override
  String get copy => 'Copy';

  @override
  String get copyLink => 'Copy link';

  @override
  String couldNotEnableNotifications(String error) {
    return 'Could not enable notifications: $error';
  }

  @override
  String get couldNotFindBookmark => 'Could not find this bookmark';

  @override
  String couldNotOpenEmail(String email) {
    return 'Could not open email: $email';
  }

  @override
  String couldNotStartSignIn(String error) {
    return 'Could not start sign-in: $error';
  }

  @override
  String get customDateAndTime => 'Custom date & time';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteMessageQuestion => 'Delete message?';

  @override
  String get discard => 'Discard';

  @override
  String get discardDraftQuestion => 'Discard draft?';

  @override
  String get doNotDisturb => 'Do not disturb';

  @override
  String get editHistory => 'Edit history';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get editReminder => 'Edit reminder';

  @override
  String emailCopiedToClipboard(String email) {
    return 'Email copied to clipboard: $email';
  }

  @override
  String get pushEnabledForThisLogin => 'Enabled for this login';

  @override
  String get failedToLoadMoreTopics =>
      'Failed to load more topics. Scroll to retry.';

  @override
  String get failedToUpdateNotificationLevel =>
      'Failed to update notification level';

  @override
  String get firstPostsOnly => 'First posts only';

  @override
  String get ignoredUsers => 'Ignored users';

  @override
  String get inTwoHours => 'In two hours';

  @override
  String get inviteByEmail => 'Invite by email';

  @override
  String get inviteLinkCopied => 'Invite link copied';

  @override
  String inviteSentTo(String email) {
    return 'Invite sent to $email';
  }

  @override
  String get leave => 'Leave';

  @override
  String get leaveGroup => 'Leave group';

  @override
  String get leaveGroupQuestion => 'Leave group?';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get loadMore => 'Load more';

  @override
  String get manageAccountOnWeb => 'Manage account on web';

  @override
  String get merge => 'Merge';

  @override
  String get mergeIntoTopic => 'Merge into topic';

  @override
  String get newInviteLink => 'New invite link';

  @override
  String get nextWeek => 'Next week';

  @override
  String get pushNotAvailableInThisBuild => 'Not available in this build';

  @override
  String get notNow => 'Not now';

  @override
  String tagNotificationLevelUpdated(String tag) {
    return 'Notification level for \"$tag\" updated';
  }

  @override
  String doNotDisturbOnUntil(String until) {
    return 'On until $until';
  }

  @override
  String get pleaseLogInToBookmark => 'Please log in to bookmark';

  @override
  String get pleaseLogInToFollowUsers => 'Please log in to follow users';

  @override
  String get pleaseLogInToMarkAnswers => 'Please log in to mark answers';

  @override
  String get pleaseLogInToReact => 'Please log in to react';

  @override
  String get pleaseLogInToVote => 'Please log in to vote';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get relevance => 'Relevance';

  @override
  String get reminderTimeMustBeInFuture =>
      'Reminder time must be in the future';

  @override
  String get removeBookmark => 'Remove bookmark';

  @override
  String get removeVote => 'Remove vote';

  @override
  String get renameTopic => 'Rename topic';

  @override
  String reportedBy(String username) {
    return 'Reported by $username';
  }

  @override
  String get requestToJoin => 'Request to join';

  @override
  String requestToJoinGroup(String group) {
    return 'Request to join $group';
  }

  @override
  String get reset => 'Reset';

  @override
  String get resizeAndUpload => 'Resize and upload';

  @override
  String get retryConnection => 'Retry connection';

  @override
  String get reviewQueue => 'Review queue';

  @override
  String get revoke => 'Revoke';

  @override
  String get revokeInviteQuestion => 'Revoke invite?';

  @override
  String get save => 'Save';

  @override
  String get sendInvite => 'Send invite';

  @override
  String get sendRequest => 'Send request';

  @override
  String get settings => 'Settings';

  @override
  String get showVoters => 'Show voters';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutQuestion => 'Sign out?';

  @override
  String get signInCancelledNoPayload =>
      'Sign-in cancelled — no payload returned';

  @override
  String signInFailed(String error) {
    return 'Sign-in failed: $error';
  }

  @override
  String get startChat => 'Start chat';

  @override
  String stoppedIgnoringUser(String username) {
    return 'Stopped ignoring @$username';
  }

  @override
  String get submit => 'Submit';

  @override
  String get discardDraftWarning =>
      'This will permanently remove the saved draft.';

  @override
  String get deleteChatMessageWarning =>
      'This will remove the message for everyone.';

  @override
  String get titleOnly => 'Title only';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get turnOff => 'Turn off';

  @override
  String get turnOnNotifications => 'Turn on notifications';

  @override
  String get whisper => 'Whisper';

  @override
  String likeAgainInSeconds(Object seconds) {
    return 'You can like this post again in ${seconds}s';
  }

  @override
  String get loginInfo => 'Login Info';

  @override
  String get loginFailed => 'Login Failed';

  @override
  String get moveToCategory => 'Move to category';

  @override
  String get undeleteTopic => 'Undelete Topic';

  @override
  String get undeleteTopicConfirmation =>
      'Are you sure you want to undelete this topic? It will be visible to other users again.';

  @override
  String get send => 'Send';

  @override
  String get changeEmailExplanation =>
      'We’ll send a confirmation link to your new email. The change takes effect when you click it.';

  @override
  String get changeEmailSecurityNote =>
      'For added security, Discourse may require you to confirm via the link in the email. Check your spam folder if you don’t see it.';

  @override
  String get newDirectMessage => 'New direct message';

  @override
  String get noMessagesYetSayHi => 'No messages yet — say hi.';

  @override
  String get edited => 'edited';

  @override
  String get editProfileManagedOnWebNote =>
      'Display name, email, password, and other account settings are managed under Account → Manage account on web. Your avatar can be changed by tapping the camera badge on your photo.';

  @override
  String get approvedButRelayUnreachable =>
      'Approved, but we could not reach ForumCopilot to finish setting up. Try again later from Settings.';

  @override
  String get notificationsAreTurnedOffForThisApp =>
      'Notifications are turned off for this app';

  @override
  String forumWillAskToApproveNotifications(Object forumName) {
    return 'Next, $forumName will ask you to approve “Notifications”.';
  }

  @override
  String get approveNotificationsExplanation =>
      'Approving lets us check your notifications for you and send them to this device. This permission cannot post, reply, or read your messages.';

  @override
  String get forumOwnerPushNote =>
      'If this forum’s owner sets up notifications for the app, this step won’t be needed.';

  @override
  String get pleaseLoginToCreateANewTopic =>
      'Please login to create a new topic';

  @override
  String get pleaseLoginToSubscribeToForums =>
      'Please login to subscribe to forums';

  @override
  String leaveGroupWarning(Object group) {
    return 'You will no longer be a member of $group. You can rejoin at any time.';
  }

  @override
  String get groupMembersPrivate => 'The member list of this group is private.';

  @override
  String get unignore => 'Unignore';

  @override
  String get inviteLinkCreated => 'Invite link created';

  @override
  String expiresOn(Object date) {
    return 'Expires $date';
  }

  @override
  String get protected => 'Protected';

  @override
  String get solution => 'Solution';

  @override
  String get deleted => 'DELETED';

  @override
  String get pleaseLoginToViewUserProfiles =>
      'Please login to view user profiles.';

  @override
  String get announcement => 'Announcement';

  @override
  String get solved => 'Solved';

  @override
  String get hot => 'Hot';

  @override
  String get pinned => 'Pinned';

  @override
  String get subscribedLabel => 'Subscribed';

  @override
  String get locked => 'Locked';

  @override
  String get poll => 'Poll';

  @override
  String errorLoadingContent(Object error) {
    return 'Error loading content: $error';
  }

  @override
  String get noPermissionToViewSubforum =>
      'You do not have permission to view topics in this subforum.';

  @override
  String get noDiscussionsYet => 'No discussions yet.';

  @override
  String get jumpToPost => 'Jump to Post';

  @override
  String get jump => 'Jump';

  @override
  String get endOfTheDiscussion => 'End of the discussion';

  @override
  String get reviewQueueStaffOnly =>
      'Only staff and reviewers can see the review queue.';

  @override
  String get nothingToReview => 'Nothing to review';

  @override
  String refreshFailed(Object error) {
    return 'Refresh failed: $error';
  }

  @override
  String get topicDeletedBanner =>
      'This topic is deleted and hidden from other users';

  @override
  String get topicClosedBanner =>
      'This topic is closed and no longer accepting replies';

  @override
  String get topicPinnedBanner =>
      'This topic is pinned to the top of the forum';

  @override
  String get youAreSubscribedToThisTopic => 'You are subscribed to this topic';

  @override
  String get refreshing => 'Refreshing...';

  @override
  String get title => 'Title';

  @override
  String editedAt(Object time) {
    return 'Edited $time';
  }

  @override
  String editReason(Object reason) {
    return 'Reason: $reason';
  }

  @override
  String get thisDiffIsTooLargeToDisplay =>
      'This diff is too large to display.';

  @override
  String get noContentChangesInThisRevision =>
      'No content changes in this revision.';

  @override
  String revisionOf(Object currentVersion, Object versionCount) {
    return 'Revision $currentVersion of $versionCount';
  }

  @override
  String get editConversation => 'Edit conversation';

  @override
  String get closeConversation => 'Close conversation';

  @override
  String get openConversation => 'Open conversation';

  @override
  String get leaveConversation2 => 'Leave conversation';

  @override
  String get reportConversation2 => 'Report conversation';

  @override
  String get closeConversation2 => 'Close Conversation';

  @override
  String get closeConversationConfirmation =>
      'Are you sure you want to close this conversation? This will prevent new replies from being posted.';

  @override
  String get close => 'Close';

  @override
  String get openConversation2 => 'Open Conversation';

  @override
  String get openConversationConfirmation =>
      'Are you sure you want to open this conversation? This will allow new replies to be posted.';

  @override
  String get open => 'Open';

  @override
  String get leaveConversation3 => 'Leave Conversation';

  @override
  String get leaveConversationConfirmation =>
      'Are you sure you want to leave this conversation? This will hide it from your inbox.';

  @override
  String errorLoadingConversation(Object error) {
    return 'Error loading conversation: $error';
  }

  @override
  String get conversationNotFound => 'Conversation not found';

  @override
  String get conversationClosedBanner =>
      'This conversation is closed and no longer accepting replies';

  @override
  String get noMessagesFound => 'No messages found';

  @override
  String get endOfConversation => 'End of conversation';

  @override
  String get jumpToMessage => 'Jump to Message';

  @override
  String get editConversation2 => 'Edit Conversation';

  @override
  String get failedToLoadMessage2 => 'Failed to load message';

  @override
  String get cannotEditThisConversation => 'Cannot edit this conversation';

  @override
  String get options => 'Options';

  @override
  String get conversationOpen => 'Conversation Open';

  @override
  String failedToCreateConversation(Object error) {
    return 'Failed to create conversation: $error';
  }

  @override
  String maximumAttachmentsAllowed(Object count) {
    return 'Maximum of $count attachment(s) allowed';
  }

  @override
  String get noImagesFoundToDisplay => 'No images found to display.';

  @override
  String get pleaseLoginToViewThisAttachment =>
      'Please login to view this attachment';

  @override
  String get searchForTopics => 'Search for topics';

  @override
  String get noTopicsFound => 'No topics found';

  @override
  String get trySearchingWithDifferentKeywords =>
      'Try searching with different keywords';

  @override
  String get noPostsFound => 'No posts found';

  @override
  String get perTopicNotificationLevelsNote =>
      'Per-category and per-topic notification levels are set from those screens directly — tap the bell icon on any topic or category to override.';

  @override
  String get pushNotActiveForThisLogin =>
      'Not active for this login — log out and log back in to authorize push notifications';

  @override
  String get pauseNotificationsFor => 'Pause notifications for…';

  @override
  String get doNotDisturbExplanation =>
      'Pause notifications for a while — Discourse holds them until the window ends';

  @override
  String get emailSettingsSubtitle =>
      'Email frequency, like aggregation, digest schedule';

  @override
  String get manageAccountSubtitle =>
      'Profile, email, password, security, advanced settings';

  @override
  String get changePasswordSubtitle =>
      'Trigger a password-reset email to your current address';

  @override
  String get ignoredUsersSubtitle =>
      'See and manage users whose posts are hidden from you';

  @override
  String get deleteAccountExplanation =>
      'Removing your account is handled on the forum. Continue to open the site and contact the staff team — Discourse forums process deletions per their own policy.';

  @override
  String get verificationEmailSent =>
      'Verification email sent — click the link to confirm your new address.';

  @override
  String get passwordResetExplanation =>
      'We’ll email you a password-reset link. Click it to choose a new password — the change is handled on the forum, not in this app.';

  @override
  String get sendResetEmail => 'Send reset email';

  @override
  String get deleteAccountDialogBody =>
      'Your account is managed by the forum. Please contact the forum staff directly to request account removal. Continue will open the forum in your browser so you can use the site’s own contact / staff message flow.';

  @override
  String get initializingForum => 'Initializing forum…';

  @override
  String get unableToLoadForums => 'Unable to Load Forums';

  @override
  String get noForumsToDisplayExplanation =>
      'There are no forums to display. This might be due to permissions or the forum structure.';

  @override
  String get subscribedForums => 'Subscribed Forums';

  @override
  String get errorLoadingNotifications => 'Error loading notifications';

  @override
  String get pullDownToRefresh => 'Pull down to refresh';

  @override
  String get noNewNotificationsExplanation =>
      'You have no new notifications. Check back later for updates on topics you\'re following.';

  @override
  String noTagsMatch(Object filter) {
    return 'No tags match \"$filter\".';
  }

  @override
  String noTopicsTagged(Object tag) {
    return 'No topics tagged \"$tag\"';
  }

  @override
  String failedToBanUser2(Object error) {
    return 'Failed to ban user: $error';
  }

  @override
  String unbanUserConfirmation(Object username) {
    return 'Are you sure you want to unban $username?';
  }

  @override
  String failedToUnbanUser2(Object error) {
    return 'Failed to unban user: $error';
  }

  @override
  String get deletePostsProfilePostsAndComments =>
      'Delete posts, profile posts, and comments';

  @override
  String spamCleanConfirmation(Object username) {
    return 'Are you sure you want to spam clean $username?';
  }

  @override
  String failedToCleanSpam(Object error) {
    return 'Failed to clean spam: $error';
  }

  @override
  String get searchUser => 'Search User';

  @override
  String get tapToOpen => 'Tap to open';

  @override
  String get imageNotAvailable => 'Image not available';

  @override
  String get allForumTopicsHaveBeenMarkedAs =>
      'All forum topics have been marked as read';

  @override
  String postsCount(Object count) {
    return '$count Posts';
  }

  @override
  String get permissionDeniedToSaveImage => 'Permission denied to save image';

  @override
  String get postNotFound => 'Post not found.';

  @override
  String get failedToUploadFilePleaseTryAgain =>
      'Failed to upload file. Please try again.';

  @override
  String failedToUploadFile2(Object errorMessage) {
    return 'Failed to upload file: $errorMessage';
  }

  @override
  String get failedToPickFile => 'Failed to pick file';

  @override
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return 'Only $remainingSlots more attachment(s) allowed. Processing first $remainingSlots2 image(s).';
  }

  @override
  String get attachmentLimitReachedSkippingRemainingImages =>
      'Attachment limit reached. Skipping remaining images.';

  @override
  String failedToUploadImagePleaseTryAgain(Object fileName) {
    return '$fileName: Failed to upload image. Please try again.';
  }

  @override
  String failedToUploadImage2(Object errorMessage, Object fileName) {
    return '$fileName: Failed to upload image: $errorMessage';
  }

  @override
  String get failedToPickImage => 'Failed to pick image';

  @override
  String failedToRemoveAttachment2(Object error) {
    return 'Failed to remove attachment: $error';
  }

  @override
  String sentFromMobileApp(Object siteName) {
    return 'Sent from $siteName mobile app';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      'Please wait for attachments to finish uploading';

  @override
  String get imageIsTooLargeToUpload => 'Image is too large to upload';

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName is $fileBytes. This forum allows up to $maxBytes.';
  }

  @override
  String get resizeToFitExplanation =>
      'It can be scaled down just enough to fit, keeping its format and as much detail as the limit allows.';

  @override
  String get failedToPostReplyPleaseTryAgain =>
      'Failed to post reply. Please try again.';

  @override
  String get pleaseWaitForTheThreadToLoad =>
      'Please wait for the thread to load';

  @override
  String get failedToUpdatePostPleaseTryAgain =>
      'Failed to update post. Please try again.';

  @override
  String get postDeletedSuccessfully => 'Post deleted successfully';

  @override
  String failedToDeletePost(Object error) {
    return 'Failed to delete post: $error';
  }

  @override
  String failedToSubmitReport2(Object error) {
    return 'Failed to submit report: $error';
  }

  @override
  String get editHistoryNotAvailable =>
      'Edit history is not available for this post';

  @override
  String get noPermissionToUploadAvatar =>
      'You do not have permission to upload avatars';

  @override
  String get avatarUploadedSuccessfully => 'Avatar uploaded successfully';

  @override
  String failedToPickImage2(Object error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get react => 'React';

  @override
  String get reactionsAreNotEnabledOnThisForum =>
      'Reactions are not enabled on this forum.';

  @override
  String get noReactionsYet => 'No reactions yet';

  @override
  String get searchFilters => 'Search filters';

  @override
  String signOutWarning(Object siteName) {
    return 'You will be signed out of $siteName. You can sign back in any time.';
  }

  @override
  String get suggestedTopics => 'Suggested Topics';

  @override
  String get newLabel => 'NEW';

  @override
  String get voteRemoved => 'Vote removed';

  @override
  String get voters => 'Voters';

  @override
  String get noVotesYet => 'No votes yet.';

  @override
  String get trustLevels => 'Trust levels';

  @override
  String get trustLevelsExplanation =>
      'Members earn trust by reading and participating. Each level unlocks new abilities.';

  @override
  String get activity => 'Activity';

  @override
  String get dontUpload => 'Don\'t upload';

  @override
  String get dontAskAgainAlwaysResize =>
      'Don\'t ask again — always resize to fit';

  @override
  String get couldNotLoadCategories => 'Couldn\'t load categories.';

  @override
  String get switchForum => 'Switch forum';

  @override
  String get explore => 'Explore';

  @override
  String get tags => 'Tags';

  @override
  String get community => 'Community';

  @override
  String get users => 'Users';

  @override
  String get groups => 'Groups';

  @override
  String get invites => 'Invites';

  @override
  String get account => 'Account';

  @override
  String get drafts => 'Drafts';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String signedInAs(String username) {
    return 'Signed in as $username';
  }

  @override
  String get notSignedIn => 'Not signed in';
}
