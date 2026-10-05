// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get accountSessionChanged =>
      'Your sign-in changed. Reopen this screen to continue.';

  @override
  String get draftSessionChanged =>
      'Your sign-in changed. Copy your text before reopening the composer to work with drafts.';

  @override
  String get uploadSessionChanged =>
      'Your sign-in changed during the upload. Reopen this screen before trying again.';

  @override
  String get submissionUnconfirmed =>
      'We couldn\'t confirm that this was sent. Your text has been kept. Check the forum before trying again.';

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
  String get youCannotReplyToThisThread => 'You cannot reply to this topic';

  @override
  String get pleaseWaitForThreadToLoad => 'Please wait for the topic to load';

  @override
  String get reason => 'Reason';

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
  String get pleaseSpecifyReason => 'Please specify the reason';

  @override
  String get selectDate => 'Select date';

  @override
  String get moreOptions => 'More options';

  @override
  String get topicClosed => 'Topic closed';

  @override
  String get topicOpened => 'Topic opened';

  @override
  String get noConversations => 'You don\'t have any messages';

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
  String get sendMessage => 'Message';

  @override
  String get likesReceived => 'Likes Received';

  @override
  String get showMore => 'Show More';

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
  String get signIn => 'Sign in';

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
  String failedToLeaveConversation(String error) {
    return 'Could not leave the message: $error';
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
  String get temporary => 'Temporary';

  @override
  String get back => 'Back';

  @override
  String get confirm => 'Confirm';

  @override
  String error(String error) {
    return 'Error: $error';
  }

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
  String get markAsUnread => 'Mark unread';

  @override
  String get invite => 'Invite';

  @override
  String get enterKeywordsToSearchTopics =>
      'Enter keywords to search topics...';

  @override
  String get refresh => 'Refresh';

  @override
  String get share => 'Share';

  @override
  String get viewOnWeb => 'View on Web';

  @override
  String get reply => 'Reply';

  @override
  String get vote => 'Vote';

  @override
  String votesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes',
      one: '$count vote',
    );
    return '$_temp0';
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
  String get appearance => 'Appearance';

  @override
  String get appearanceSystem => 'System default';

  @override
  String version(String version, String buildNumber) {
    return 'version $version ($buildNumber)';
  }

  @override
  String get unableToLoadProfile => 'Unable to Load Profile';

  @override
  String get banned => 'BANNED';

  @override
  String get deleteTopic => 'Delete Topic';

  @override
  String get home => 'Home';

  @override
  String get notifications => 'Notifications';

  @override
  String get forums => 'Categories';

  @override
  String get content => 'Content';

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
  String get writeYourMessage => 'Write your message...';

  @override
  String get writeYourReply => 'Write your reply...';

  @override
  String get conversationMarkedAsUnread => 'Message marked as unread';

  @override
  String get conversationClosed => 'Message closed';

  @override
  String get conversationOpened => 'Message opened';

  @override
  String failedToLoadQuote(String error) {
    return 'Failed to load quote: \n$error';
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
  String get remove => 'Remove';

  @override
  String get subject => 'Subject';

  @override
  String get message => 'Message';

  @override
  String get titleCannotBeEmpty => 'Title cannot be empty';

  @override
  String get conversationUpdatedSuccessfully => 'Message updated';

  @override
  String get goBack => 'Go Back';

  @override
  String get like => 'like';

  @override
  String get download => 'Download';

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
  String get chat => 'Chat';

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
  String get checkConnectionAndRetry =>
      'Check your internet connection and try again.';

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
  String get undeleteTopic => 'Un-Delete Topic';

  @override
  String get send => 'Send';

  @override
  String get changeEmailExplanation =>
      'We’ll send a confirmation link to your new email. The change takes effect when you click it.';

  @override
  String get changeEmailSecurityNote =>
      'For added security, Discourse may require you to confirm via the link in the email. Check your spam folder if you don’t see it.';

  @override
  String get noMessagesYetSayHi => 'No messages yet — say hi.';

  @override
  String get edited => 'edited';

  @override
  String get approvedButRelayUnreachable =>
      'Approved, but we could not reach the notifications server to finish setting up. Try again later from Settings.';

  @override
  String get notificationsAreTurnedOffForThisApp =>
      'Notifications are turned off for this app';

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
  String get solution => 'Solution';

  @override
  String get deleted => 'DELETED';

  @override
  String get pleaseLoginToViewUserProfiles =>
      'Please login to view user profiles.';

  @override
  String get solved => 'Solved';

  @override
  String get hot => 'Hot';

  @override
  String get pinned => 'Pinned';

  @override
  String get locked => 'Locked';

  @override
  String get poll => 'Poll';

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
  String get editConversation => 'Edit title';

  @override
  String get closeConversation => 'Close message';

  @override
  String get openConversation => 'Open message';

  @override
  String get leaveConversation2 => 'Leave message';

  @override
  String get closeConversation2 => 'Close message';

  @override
  String get closeConversationConfirmation =>
      'Close this message? It will no longer accept new replies.';

  @override
  String get close => 'Close';

  @override
  String get openConversation2 => 'Open message';

  @override
  String get openConversationConfirmation =>
      'Open this message? It will accept new replies again.';

  @override
  String get open => 'Open';

  @override
  String get leaveConversation3 => 'Leave message';

  @override
  String get leaveConversationConfirmation =>
      'Are you sure you want to remove yourself from this message? You will no longer be able to see or reply to it.';

  @override
  String get editConversation2 => 'Edit title';

  @override
  String get failedToLoadMessage2 => 'Failed to load message';

  @override
  String get cannotEditThisConversation => 'You can\'t edit this message';

  @override
  String get options => 'Options';

  @override
  String get conversationOpen => 'Open for replies';

  @override
  String get messageTitleHint =>
      'What is this discussion about in one brief sentence?';

  @override
  String get messageOpenForReplies => 'Accepting new replies';

  @override
  String get messageClosedForReplies => 'Closed: no new replies';

  @override
  String get messageSentWithoutId =>
      'The message was sent, but the forum didn\'t return it. Check your messages.';

  @override
  String get messageCouldNotBeSent => 'The message could not be sent.';

  @override
  String get messageIdMissing =>
      'This message can\'t be opened: its ID is missing.';

  @override
  String get pleaseAddARecipient => 'Please add at least one recipient';

  @override
  String get archiveMessage => 'Archive';

  @override
  String get moveToInbox => 'Move to Inbox';

  @override
  String get messageInbox => 'Inbox';

  @override
  String get messageArchive => 'Archive';

  @override
  String get messageListUnread => 'Unread';

  @override
  String get messageListNew => 'New';

  @override
  String get messageListSent => 'Sent';

  @override
  String removeFromMessageConfirm(String name) {
    return 'Do you really want to remove $name from this message?';
  }

  @override
  String uploadingFilename(String filename) {
    return 'Uploading: $filename…';
  }

  @override
  String get messageArchived => 'Message archived';

  @override
  String get messageMovedToInbox => 'Moved to Inbox';

  @override
  String failedToArchiveMessage(Object error) {
    return 'Could not archive the message: $error';
  }

  @override
  String failedToMoveMessageToInbox(Object error) {
    return 'Could not move the message to Inbox: $error';
  }

  @override
  String get noArchivedMessages => 'You don\'t have any archived messages';

  @override
  String get noArchivedMessagesHint =>
      'Archive a message from its ⋮ menu to file it here.';

  @override
  String groupHasBeenInvited(String group) {
    return '$group has been invited to the message';
  }

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
  String get chatChannels => 'Channels';

  @override
  String get chatDms => 'DMs';

  @override
  String get chatNoChannels => 'You have not joined any channels yet!';

  @override
  String get chatNoDms => 'You have not joined any direct messages yet!';

  @override
  String get chatNoDmsCta => 'Start a conversation';

  @override
  String chatPlaceholderChannel(String channel) {
    return 'Chat in $channel';
  }

  @override
  String chatPlaceholderUsers(String names) {
    return 'Chat with $names';
  }

  @override
  String get chatPlaceholderSelf => 'Jot something down';

  @override
  String get chatPlaceholderArchived =>
      'Channel is archived, you cannot send new messages right now.';

  @override
  String get chatPlaceholderClosed =>
      'Channel is closed, you cannot send new messages right now.';

  @override
  String get chatPlaceholderReadOnly =>
      'Channel is read only, you cannot send new messages right now.';

  @override
  String get chatPlaceholderSilenced =>
      'You cannot send messages at this time.';

  @override
  String get chatDeleteConfirm =>
      'Are you sure you want to delete this message?';

  @override
  String get chatStartNewDm => 'Start new DM';

  @override
  String get chatCreatePersonal => 'Create a personal chat';

  @override
  String get chatCreateGroup => 'Create group chat';

  @override
  String get chatCannotCreate => 'Sorry, you cannot send direct messages.';

  @override
  String get chatDisabledUser => 'has disabled chat';

  @override
  String get chatSearchPlaceholder => '@somebody';

  @override
  String get chatAddMorePlaceholder => '...add more members';

  @override
  String chatUserNotFound(String name) {
    return '@$name not found';
  }

  @override
  String get chatCouldNotStartDm => 'Could not start the chat.';

  @override
  String get chatSignInTitle => 'Sign in to use chat';

  @override
  String get chatSignInMessage =>
      'You need to be signed in to view and join chat channels.';

  @override
  String get chatDirectMessage => 'Direct message';

  @override
  String get chatNotAvailable => 'Chat is not available on this forum.';

  @override
  String get chatAttachFile => 'Attach a file';

  @override
  String get chatRemoveUpload => 'Remove file';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get postNeedsApprovalTitle => 'Post Needs Approval';

  @override
  String get postNeedsApprovalBody =>
      'We\'ve received your new post but it needs to be approved by a moderator before it will appear. Please be patient.';

  @override
  String maximumAttachmentsAllowed(Object count) {
    return 'Maximum of $count attachment(s) allowed';
  }

  @override
  String get noImagesFoundToDisplay => 'No images found to display.';

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
      'Delete your account and your posts, if the forum allows it. Otherwise its staff can remove it for you.';

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
  String get errorLoadingNotifications => 'Error loading notifications';

  @override
  String get noNewNotificationsExplanation =>
      'You will be notified in this panel about activity directly relevant to you, including replies to your topics and posts, when someone @mentions you or quotes you, and replies to topics you are watching. Notifications will also be sent to your email when you haven’t logged in for a while.';

  @override
  String noTagsMatch(Object filter) {
    return 'No tags match \"$filter\".';
  }

  @override
  String noTopicsTagged(Object tag) {
    return 'No topics tagged \"$tag\"';
  }

  @override
  String get searchUser => 'Search User';

  @override
  String get tapToOpen => 'Tap to open';

  @override
  String get imageNotAvailable => 'Image not available';

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
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return 'Only $remainingSlots more attachment(s) allowed. Processing first $remainingSlots2 image(s).';
  }

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
  String get failedToUpdatePostPleaseTryAgain =>
      'Failed to update post. Please try again.';

  @override
  String get postDeletedSuccessfully => 'Post deleted successfully';

  @override
  String failedToDeletePost(Object error) {
    return 'Failed to delete post: $error';
  }

  @override
  String get editHistoryNotAvailable =>
      'Edit history is not available for this post';

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
  String get suggestedTopics => 'Suggested Topics';

  @override
  String get suggestedMessages => 'Suggested Messages';

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
  String get notSignedIn => 'Not signed in';

  @override
  String get deviceWillNotShowAlertsUntilAllowedInSettings =>
      'Your device will not show alerts until you allow notifications in Settings.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get notificationsThisDeviceSection => 'On this device';

  @override
  String notificationsThisDeviceCaption(Object forumName) {
    return 'Push from $forumName to this device only. Your other devices and the web aren\'t affected.';
  }

  @override
  String notificationsAccountSection(Object forumName) {
    return 'Your $forumName account';
  }

  @override
  String get notificationsAccountCaption =>
      'These apply everywhere: on the web, by email and on all your devices.';

  @override
  String pushOnThisDeviceSubtitle(Object forumName) {
    return 'On: new notifications from $forumName are pushed to this device.';
  }

  @override
  String pushOffThisDeviceSubtitle(Object forumName) {
    return 'Off on this device. To turn it on, you approve it once on $forumName.';
  }

  @override
  String get stopPushOnThisDevice => 'Stop push on this device';

  @override
  String stopPushTitle(Object forumName) {
    return 'Stop push from $forumName on this device?';
  }

  @override
  String get stopPushOnlyThisDevice =>
      'Only this device stops. Your other devices keep theirs.';

  @override
  String get stopPushNothingElseChanges =>
      'Your notifications still show in the app and on the web, and the forum\'s emails don\'t change.';

  @override
  String stopPushPermissionDeleted(Object forumName) {
    return 'The permission you gave on $forumName is deleted. To turn push back on, you\'ll approve it there again.';
  }

  @override
  String get stopPushQuietHint =>
      'Want quiet for a while instead? Turn off the kinds you don\'t need above, or use Do not disturb on your profile.';

  @override
  String get stopPush => 'Stop push';

  @override
  String get turnOn => 'Turn on';

  @override
  String get couldNotTurnOffNotifications =>
      'Couldn\'t stop push. Try again later.';

  @override
  String actionCodeTopicCreated(String when) {
    return 'Created this topic $when';
  }

  @override
  String actionCodePublicTopic(String when) {
    return 'Made this topic public $when';
  }

  @override
  String actionCodeOpenTopic(String when) {
    return 'Converted this to a topic $when';
  }

  @override
  String actionCodePrivateTopic(String when) {
    return 'Made this topic a personal message $when';
  }

  @override
  String actionCodeSplitTopic(String when) {
    return 'Split this topic $when';
  }

  @override
  String actionCodeInvitedUser(String who, String when) {
    return 'Invited $who $when';
  }

  @override
  String actionCodeInvitedGroup(String who, String when) {
    return 'Invited $who $when';
  }

  @override
  String actionCodeUserLeft(String who, String when) {
    return '$who removed themselves from this message $when';
  }

  @override
  String actionCodeRemovedUser(String who, String when) {
    return 'Removed $who $when';
  }

  @override
  String actionCodeRemovedGroup(String who, String when) {
    return 'Removed $who $when';
  }

  @override
  String actionCodeAutobumped(String when) {
    return 'Automatically bumped $when';
  }

  @override
  String actionCodeTagsChanged(String when) {
    return 'Tags updated $when';
  }

  @override
  String actionCodeCategoryChanged(String when) {
    return 'Category updated $when';
  }

  @override
  String get actionCodeForwarded => 'Forwarded the above email';

  @override
  String actionCodeAutoclosedEnabled(String when) {
    return 'Closed $when';
  }

  @override
  String actionCodeAutoclosedDisabled(String when) {
    return 'Opened $when';
  }

  @override
  String actionCodeClosedEnabled(String when) {
    return 'Closed $when';
  }

  @override
  String actionCodeClosedDisabled(String when) {
    return 'Opened $when';
  }

  @override
  String actionCodeArchivedEnabled(String when) {
    return 'Archived $when';
  }

  @override
  String actionCodeArchivedDisabled(String when) {
    return 'Unarchived $when';
  }

  @override
  String actionCodePinnedEnabled(String when) {
    return 'Pinned $when';
  }

  @override
  String actionCodePinnedDisabled(String when) {
    return 'Unpinned $when';
  }

  @override
  String actionCodePinnedGloballyEnabled(String when) {
    return 'Pinned globally $when';
  }

  @override
  String actionCodePinnedGloballyDisabled(String when) {
    return 'Unpinned $when';
  }

  @override
  String actionCodeVisibleEnabled(String when) {
    return 'Listed $when';
  }

  @override
  String actionCodeVisibleDisabled(String when) {
    return 'Unlisted $when';
  }

  @override
  String actionCodeBannerEnabled(String when) {
    return 'Made this a banner $when. It will appear at the top of every page until it is dismissed by the user.';
  }

  @override
  String actionCodeBannerDisabled(String when) {
    return 'Removed this banner $when. It will no longer appear at the top of every page.';
  }

  @override
  String actionCodeAssigned(String who, String when) {
    return 'Assigned $who $when';
  }

  @override
  String actionCodeUnassigned(String who, String when) {
    return 'Unassigned $who $when';
  }

  @override
  String actionCodeReassigned(String who, String when) {
    return 'Reassigned $who $when';
  }

  @override
  String localDateToday(String time) {
    return 'Today $time';
  }

  @override
  String localDateTomorrow(String time) {
    return 'Tomorrow $time';
  }

  @override
  String localDateYesterday(String time) {
    return 'Yesterday $time';
  }

  @override
  String get eventExpired => 'Expired';

  @override
  String get eventEveryDay => 'Every day';

  @override
  String get eventEveryWeekday => 'Every weekday';

  @override
  String get eventEveryWeek => 'Every week at this weekday';

  @override
  String get eventEveryTwoWeeks => 'Every two weeks at this weekday';

  @override
  String get eventEveryFourWeeks => 'Every four weeks at this weekday';

  @override
  String get eventEveryMonth => 'Every month at this weekday';

  @override
  String get errorNoConnection =>
      'Couldn\'t reach the forum. Check your connection and try again.';

  @override
  String get errorTimedOut =>
      'The forum took too long to answer. Please try again.';

  @override
  String get errorPaywalled => 'This is only for the forum\'s paying members.';

  @override
  String get errorBlocked =>
      'The forum\'s firewall blocked the app. Try again later, or open the forum in a browser.';

  @override
  String get errorNotAllowed =>
      'You don\'t have access to this. Signing in may help.';

  @override
  String get errorNotFound => 'This doesn\'t exist, or it was removed.';

  @override
  String get errorRateLimited =>
      'You\'re doing that too often. Please wait a moment and try again.';

  @override
  String get errorForumDown =>
      'The forum isn\'t responding right now. Please try again later.';

  @override
  String get deleteSpammer => 'Delete spammer';

  @override
  String get yesDeleteSpammer => 'Yes, delete spammer';

  @override
  String get deleteSpammerConfirm =>
      'You are about to delete this user\'s posts and topics, remove their account, block signups from their IP address, and add their email address to a permanent block list. Are you sure this user is really a spammer?';

  @override
  String get userWasDeleted => 'The user was deleted.';

  @override
  String get deleteMyAccount => 'Delete My Account';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to permanently delete your account? This action cannot be undone!';

  @override
  String get deletedYourself => 'Your account has been deleted successfully.';

  @override
  String get deleteYourselfNotAllowed =>
      'Please contact a staff member if you wish your account to be deleted.';

  @override
  String get createTopic => 'Create Topic';

  @override
  String get discardPostQuestion => 'Do you want to discard your post?';

  @override
  String get discardChangesQuestion => 'Do you want to discard your changes?';

  @override
  String get discardChanges => 'Discard changes';

  @override
  String get saveDraft => 'Save draft';

  @override
  String get notificationSettings => 'Notification settings';

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
  String get markAsSolution => 'Mark as solution';

  @override
  String get unmarkAsSolution => 'Unmark as solution';

  @override
  String searchForumName(String forum) {
    return 'Search $forum';
  }

  @override
  String countActiveThisMonth(String formatted) {
    return '$formatted active this month';
  }

  @override
  String countMembers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted members',
      one: '$formatted member',
    );
    return '$_temp0';
  }

  @override
  String countTopics(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted topics',
      one: '$formatted topic',
    );
    return '$_temp0';
  }

  @override
  String categoryNewThisWeek(int count) {
    return '$count new this week';
  }

  @override
  String get categoriesView => 'Categories';

  @override
  String get allCategories => 'All categories';

  @override
  String get allTags => 'All tags';

  @override
  String get myPosts => 'My posts';

  @override
  String get drawerIntroduction =>
      'This forum\'s categories, tags and your account are all in this menu. Open it again any time with the menu button.';

  @override
  String trustLevelN(int level) {
    return 'Trust level $level';
  }

  @override
  String get filterNew => 'New';

  @override
  String get filterTop => 'Top';

  @override
  String get levelWatching => 'Watching';

  @override
  String get levelWatchingFirstPost => 'Watching first post';

  @override
  String get levelTracking => 'Tracking';

  @override
  String get levelNormal => 'Normal';

  @override
  String get levelMuted => 'Muted';

  @override
  String get chooseCategory => 'Choose a category';

  @override
  String get signInToPostAndGetNotifications =>
      'Sign in to post and get notifications';

  @override
  String forumBlocksNotificationServer(Object forumName) {
    return '$forumName blocks our notification server, so notifications may not arrive. You can turn them off in Settings.';
  }

  @override
  String get relatedTopics => 'Related Topics';

  @override
  String get relatedMessages => 'Related Messages';

  @override
  String moreInCategory(String category) {
    return 'More in $category';
  }

  @override
  String get latestTopics => 'Latest topics';

  @override
  String get pushGroupMessages => 'Messages and chat';

  @override
  String get pushGroupMessagesHint =>
      'Personal messages, group inboxes and chat';

  @override
  String get pushGroupReplies => 'Replies and mentions';

  @override
  String get pushGroupRepliesHint =>
      'Replies, mentions, quotes and topics you watch';

  @override
  String get pushGroupReactions => 'Likes and reactions';

  @override
  String get pushGroupReactionsHint => 'Likes and reactions to your posts';

  @override
  String get pushGroupOther => 'Everything else';

  @override
  String get pushGroupOtherHint =>
      'Badges, reminders, accepted answers and more';

  @override
  String get pushChannelOther => 'Other notifications';

  @override
  String get couldNotChangePushSetting =>
      'Couldn\'t change this setting. Try again later.';

  @override
  String neverMissAReplyOn(Object forumName) {
    return 'Never miss a reply on $forumName';
  }

  @override
  String get notificationsPitch =>
      'Replies, mentions, messages and chat on your lock screen, usually within 10 minutes. You can choose which, any time, in Settings.';

  @override
  String get notificationsStepAllow => 'Allow notifications on this phone';

  @override
  String get notificationsStepAllowed =>
      'Notifications are allowed on this phone';

  @override
  String notificationsStepApprove(Object forumName) {
    return 'Approve on $forumName';
  }

  @override
  String get notificationsReadOnlyNote =>
      'Read-only: it can\'t post, reply or read your messages';

  @override
  String get notificationPreviewReply =>
      'Jane replied to you: Welcome aboard! Glad you found us.';

  @override
  String get notificationPreviewMessage =>
      'Sam sent you a message: Are you coming on Friday?';

  @override
  String get notificationPreviewNow => 'now';

  @override
  String get notificationPreviewEarlier => '5m ago';

  @override
  String get activityReplied => 'Replied';

  @override
  String get activityStartedTopic => 'Started a topic';

  @override
  String get activityLiked => 'Liked';

  @override
  String get activitySolution => 'Solution';

  @override
  String get activityAcceptedBy => 'accepted by';

  @override
  String get activityAwaitingApproval => 'Awaiting approval';

  @override
  String get activityFilterTopics => 'Topics';

  @override
  String get activityFilterReplies => 'Replies';

  @override
  String get activityFilterLikes => 'Likes';

  @override
  String get activityFilterPending => 'Pending';

  @override
  String get sectionToday => 'Today';

  @override
  String get sectionThisWeek => 'This week';

  @override
  String get sectionEarlier => 'Earlier';

  @override
  String draftsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count drafts waiting',
      one: '1 draft waiting',
    );
    return '$_temp0';
  }

  @override
  String get resumeDrafts => 'Resume';

  @override
  String get myPostsEmpty => 'No posts yet';

  @override
  String get myPostsEmptyHint =>
      'Topics you start and replies you write will show up here.';

  @override
  String get activityEmptyTopics => 'No topics yet';

  @override
  String get activityEmptyReplies => 'No replies yet';

  @override
  String get activityEmptyLikes => 'No likes given yet';

  @override
  String get activityEmptySolved => 'No solutions yet';

  @override
  String get viewProfile => 'View profile';

  @override
  String get yourStuff => 'Your stuff';

  @override
  String get accountAndPrivacy => 'Account and privacy';

  @override
  String profileStatPosts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'posts',
      one: 'post',
    );
    return '$_temp0';
  }

  @override
  String profileStatLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'likes',
      one: 'like',
    );
    return '$_temp0';
  }

  @override
  String profileStatDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$_temp0';
  }

  @override
  String get profileStatSolved => 'solved';

  @override
  String joinForum(String forum) {
    return 'Join $forum';
  }

  @override
  String get guestBenefitPost => 'Reply and start topics';

  @override
  String get guestBenefitNotify => 'Get notified when people reply';

  @override
  String get guestBenefitSave => 'Bookmark posts and keep drafts';

  @override
  String get guestBenefitChat => 'Chat and send messages';

  @override
  String get createAccount => 'Create account';

  @override
  String get aboutThisForum => 'About this forum';

  @override
  String get drawerMore => 'More';

  @override
  String get goToYourProfile => 'Go to your profile';

  @override
  String profileJoined(String date) {
    return 'Joined $date';
  }

  @override
  String profileSeen(String when) {
    return 'Seen $when';
  }

  @override
  String profileLocalTime(String time) {
    return '$time local time';
  }

  @override
  String get profileTabSummary => 'Summary';

  @override
  String get summaryTopReplies => 'Top replies';

  @override
  String get summaryTopTopics => 'Top topics';

  @override
  String get summaryMostLikedBy => 'Most liked by';

  @override
  String get summaryMostLiked => 'Most liked';

  @override
  String get summaryMostRepliedTo => 'Most replied to';

  @override
  String get summaryTopLinks => 'Top links';

  @override
  String get summaryTopCategories => 'Top categories';

  @override
  String get featuredTopic => 'Featured topic';

  @override
  String get profileDetails => 'Details';

  @override
  String get followUser => 'Follow';

  @override
  String get unfollowUser => 'Unfollow';

  @override
  String get profileSuspended => 'Suspended';

  @override
  String get searchBookmarks => 'Search your bookmarks';

  @override
  String get bookmarksFilterReminders => 'Reminders';

  @override
  String get bookmarkWholeTopic => 'Whole topic';

  @override
  String bookmarkSaved(String when) {
    return 'saved $when';
  }

  @override
  String bookmarkPostNumber(int number) {
    return 'post #$number';
  }

  @override
  String reminderToday(String time) {
    return 'Today, $time';
  }

  @override
  String reminderTomorrow(String time) {
    return 'Tomorrow, $time';
  }

  @override
  String reminderDue(String when) {
    return 'Due · $when';
  }

  @override
  String get addBookmarkLabel => 'Add label';

  @override
  String get editBookmarkLabel => 'Edit label';

  @override
  String get bookmarkLabelHint => 'What is this for?';

  @override
  String get pinBookmark => 'Pin to top';

  @override
  String get unpinBookmark => 'Unpin';

  @override
  String get bookmarkRemoved => 'Bookmark removed';

  @override
  String get undo => 'Undo';

  @override
  String get bookmarksNoMatch => 'No bookmarks match';

  @override
  String get addReminder => 'Add reminder';

  @override
  String get bookmarksEmpty => 'No bookmarks yet';

  @override
  String get bookmarksEmptyHint =>
      'Bookmark a post from its actions and it will be waiting for you here.';

  @override
  String get draftKindNewTopic => 'New topic';

  @override
  String draftMessageTo(String names) {
    return 'Message to $names';
  }

  @override
  String get untitledTopic => 'Untitled topic';

  @override
  String get draftDiscarded => 'Draft discarded';

  @override
  String get draftsEmpty => 'No drafts yet';

  @override
  String get draftsEmptyHint =>
      'Drafts save themselves as you type. Start a reply or a topic and it will wait for you here.';

  @override
  String get privacySection => 'Privacy';

  @override
  String get changeEmailSubtitle =>
      'We\'ll send a verification link to the new address';

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
      'Behind your user card when people tap your picture';

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

  @override
  String get chooseEmoji => 'Choose emoji';

  @override
  String get clearStatus => 'Clear status';

  @override
  String get clearText => 'Clear';

  @override
  String get inOneHour => 'In one hour';

  @override
  String get never => 'Never';

  @override
  String get pauseNotifications => 'Pause notifications';

  @override
  String get pauseNotificationsUntilStatusClears => 'Until your status clears';

  @override
  String get pickATime => 'Pick a time';

  @override
  String get removeStatusAfter => 'Remove status';

  @override
  String get searchEmoji => 'Search emoji';

  @override
  String get setStatus => 'Set status';

  @override
  String get setAStatus => 'Set a status';

  @override
  String get statusUpdated => 'Status updated';

  @override
  String get whatAreYouDoing => 'What are you doing?';

  @override
  String cardPosted(String when) {
    return 'Posted $when';
  }

  @override
  String get change => 'Change';

  @override
  String get copyProfileLink => 'Copy link to profile';

  @override
  String get ignore => 'Ignore';

  @override
  String memberOfGroup(String group) {
    return 'Member of $group';
  }

  @override
  String get mute => 'Mute';

  @override
  String get unmute => 'Unmute';

  @override
  String openProfileOf(String username) {
    return 'Open @$username\'s profile';
  }

  @override
  String profileIsPrivate(String username) {
    return '$username keeps their profile private.';
  }

  @override
  String showOnlyTheirPostsHere(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts',
      one: 'post',
    );
    return 'Show only $name\'s $_temp0 in this topic';
  }

  @override
  String showOnlyYourPostsHere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts',
      one: 'post',
    );
    return 'Show only your $_temp0 in this topic';
  }

  @override
  String userIgnoredFor4Months(String username) {
    return 'Ignoring @$username for 4 months';
  }

  @override
  String userMuted(String username) {
    return 'Muted @$username';
  }

  @override
  String userUnmuted(String username) {
    return 'Unmuted @$username';
  }

  @override
  String get youParenthetical => '(you)';

  @override
  String get topicStatusClosedHelp =>
      'This topic is closed; it no longer accepts new replies';

  @override
  String get topicStatusArchivedHelp =>
      'This topic is archived; it is frozen and cannot be changed';

  @override
  String get topicStatusClosedArchivedHelp =>
      'This topic is closed and archived; it no longer accepts new replies and cannot be changed';

  @override
  String get topicStatusPinnedTitle => 'Pinned';

  @override
  String get topicStatusPinnedHelp =>
      'This topic is pinned for you; it will display at the top of its category';

  @override
  String get topicStatusPinnedGloballyTitle => 'Pinned Globally';

  @override
  String get topicStatusPinnedGloballyHelp =>
      'This topic is pinned globally; it will display at the top of latest and its category';

  @override
  String get topicStatusUnpinnedTitle => 'Unpinned';

  @override
  String get topicStatusUnpinnedHelp =>
      'This topic is unpinned for you; it will display in regular order';

  @override
  String get topicStatusUnlistedHelp =>
      'This topic is unlisted; it will not be displayed in topic lists, and can only be accessed via a direct link.';

  @override
  String get topicStatusWarningHelp => 'This is an official warning.';

  @override
  String get notificationReasonWatchingTag =>
      'You will receive notifications because you are watching a tag on this topic.';

  @override
  String get notificationReasonWatchingCategory =>
      'You will receive notifications because you are watching this category.';

  @override
  String get notificationReasonWatchingAuto =>
      'You will receive notifications because you started watching this topic automatically.';

  @override
  String get notificationReasonWatching =>
      'You will receive notifications because you are watching this topic.';

  @override
  String get notificationReasonWatchingCreated =>
      'You will receive notifications because you created this topic.';

  @override
  String get notificationReasonTrackingCategory =>
      'You will see a count of new replies because you are tracking this category.';

  @override
  String get notificationReasonTrackingReplied =>
      'You will see a count of new replies because you posted a reply to this topic.';

  @override
  String get notificationReasonTracking =>
      'You will see a count of new replies because you are tracking this topic.';

  @override
  String get notificationReasonTrackingRead =>
      'You will see a count of new replies because you read this topic.';

  @override
  String get notificationReasonNormal =>
      'You will be notified if someone mentions your @name or replies to you.';

  @override
  String get notificationReasonMutedCategory =>
      'You are ignoring all notifications in this category.';

  @override
  String get notificationReasonMuted =>
      'You are ignoring all notifications on this topic.';

  @override
  String get notificationLevelWatching => 'Watching';

  @override
  String get notificationLevelWatchingFirstPost => 'Watching First Post';

  @override
  String get notificationLevelTracking => 'Tracking';

  @override
  String get notificationLevelNormal => 'Normal';

  @override
  String get notificationLevelMuted => 'Muted';

  @override
  String get topicWatchingDescription =>
      'You will be notified of every new reply in this topic, and a count of new replies will be shown.';

  @override
  String get topicTrackingDescription =>
      'A count of new replies will be shown for this topic. You will be notified if someone mentions your @name or replies to you.';

  @override
  String get topicNormalDescription =>
      'You will be notified if someone mentions your @name or replies to you.';

  @override
  String get topicMutedDescription =>
      'You will never be notified of anything about this topic, and it will not appear in latest.';

  @override
  String get messageWatchingDescription =>
      'You will be notified of every new reply in this message, and a count of new replies will be shown.';

  @override
  String get messageTrackingDescription =>
      'A count of new replies will be shown for this message. You will be notified if someone mentions your @name or replies to you.';

  @override
  String get messageNormalDescription =>
      'You will be notified if someone mentions your @name or replies to you.';

  @override
  String get messageMutedDescription =>
      'You will never be notified of anything about this message.';

  @override
  String get categoryWatchingDescription =>
      'You will automatically watch all topics in this category. You will be notified of every new post in every topic, and a count of new replies will be shown.';

  @override
  String get categoryWatchingFirstPostDescription =>
      'You will be notified of new topics in this category but not replies to the topics.';

  @override
  String get categoryTrackingDescription =>
      'You will automatically track all topics in this category. You will be notified if someone mentions your @name or replies to you, and a count of new replies will be shown.';

  @override
  String get categoryNormalDescription =>
      'You will be notified if someone mentions your @name or replies to you.';

  @override
  String get categoryMutedDescription =>
      'You will never be notified of anything about new topics in this category, and they will not appear in latest.';

  @override
  String get tagWatchingDescription =>
      'You will automatically watch all topics with this tag. You will be notified of all new posts and topics, plus the count of unread and new posts will also appear next to the topic.';

  @override
  String get tagWatchingFirstPostDescription =>
      'You will be notified of new topics in this tag but not replies to the topics.';

  @override
  String get tagTrackingDescription =>
      'You will automatically track all topics with this tag. A count of unread and new posts will appear next to the topic.';

  @override
  String get tagNormalDescription =>
      'You will be notified if someone mentions your @name or replies to your post.';

  @override
  String get tagMutedDescription =>
      'You will not be notified of anything about new topics with this tag, and they will not appear on your unread tab.';

  @override
  String topicTimerAutoOpen(String timeLeft) {
    return 'This topic will automatically open $timeLeft.';
  }

  @override
  String topicTimerAutoClose(String timeLeft) {
    return 'This topic will automatically close $timeLeft.';
  }

  @override
  String topicTimerAutoPublish(String categoryName, String timeLeft) {
    return 'This topic will be published to #$categoryName $timeLeft.';
  }

  @override
  String topicTimerAutoCloseAfterLastPost(String duration) {
    return 'This topic will close $duration after the last reply.';
  }

  @override
  String topicTimerAutoDeleteAfterLastPost(String duration) {
    return 'This topic will be deleted $duration after the last reply.';
  }

  @override
  String topicTimerAutoDelete(String timeLeft) {
    return 'This topic will be automatically deleted $timeLeft.';
  }

  @override
  String topicTimerAutoBump(String timeLeft) {
    return 'This topic will be automatically bumped $timeLeft.';
  }

  @override
  String topicTimerAutoDeleteReplies(String duration) {
    return 'Replies on this topic are automatically deleted after $duration.';
  }

  @override
  String slowModeNotice(String duration) {
    return 'Please wait $duration between your posts in this topic.';
  }

  @override
  String get closeTopic => 'Close Topic';

  @override
  String get openTopic => 'Open Topic';

  @override
  String get pinTopic => 'Pin Topic';

  @override
  String get unpinTopic => 'Un-Pin Topic';

  @override
  String get archiveTopic => 'Archive Topic';

  @override
  String get unarchiveTopic => 'Unarchive Topic';

  @override
  String get unlistTopic => 'Unlist Topic';

  @override
  String get listTopic => 'List Topic';

  @override
  String get permanentlyDelete => 'Permanently delete';

  @override
  String get permanentlyDeleteTopicConfirmation =>
      'This action cannot be undone. This will permanently delete this topic and remove it from the database.';

  @override
  String get deleteTopicConfirmYes => 'Yes, delete this topic';

  @override
  String get deleteTopicConfirmNo => 'No, keep this topic';

  @override
  String get topicPinned => 'Topic pinned';

  @override
  String get topicUnpinned => 'Topic unpinned';

  @override
  String get topicArchived => 'Topic archived';

  @override
  String get topicUnarchived => 'Topic unarchived';

  @override
  String get topicUnlisted => 'Topic unlisted';

  @override
  String get topicListed => 'Topic listed';

  @override
  String get topicRecovered => 'Topic un-deleted';

  @override
  String topicActionFailed(String error) {
    return 'Couldn\'t update the topic: $error';
  }

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String durationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String timeLeftMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count minutes',
      one: 'in 1 minute',
    );
    return '$_temp0';
  }

  @override
  String timeLeftHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count hours',
      one: 'in 1 hour',
    );
    return '$_temp0';
  }

  @override
  String timeLeftDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count days',
      one: 'in 1 day',
    );
    return '$_temp0';
  }

  @override
  String get topicStatusDeletedHelp =>
      'This topic is deleted and hidden from other users';

  @override
  String get flagAction => 'Flag';

  @override
  String get flagPost => 'Flag Post';

  @override
  String get signUp => 'Sign Up';

  @override
  String get suspendUser => 'Suspend User';

  @override
  String get unsuspend => 'Unsuspend';

  @override
  String get suspendUntil => 'Suspend user until';

  @override
  String get suspendForever => 'Suspend forever';

  @override
  String failedToSuspendUser(String error) {
    return 'Something went wrong suspending this user: $error';
  }

  @override
  String failedToUnsuspendUser(String error) {
    return 'Something went wrong unsuspending this user: $error';
  }

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
  String get flaggingPost => 'Flagging post…';

  @override
  String get pleaseSelectSuspensionEndDate => 'Choose when the suspension ends';

  @override
  String get suspendingUser => 'Suspending user…';

  @override
  String get unsuspendingUser => 'Unsuspending user…';

  @override
  String get userSuspended => 'User suspended';

  @override
  String get userUnsuspended => 'User unsuspended';

  @override
  String unsuspendUserConfirmation(String username) {
    return 'Unsuspend $username? They will be able to log in again.';
  }

  @override
  String get noCategoriesToDisplay => 'There are no categories to display.';

  @override
  String get noPermissionToViewCategory =>
      'You do not have permission to view topics in this category.';

  @override
  String get featureTopicTitle => 'Feature this topic';

  @override
  String get pinTopicMenu => 'Pin Topic…';

  @override
  String pinInCategoryUntil(String category) {
    return 'Make this topic appear at the top of the $category category until';
  }

  @override
  String get pinGloballyUntil =>
      'Make this topic appear at the top of all topic lists until';

  @override
  String get pinNote =>
      'Users can unpin the topic individually for themselves.';

  @override
  String get pinUntil => 'Pin until';

  @override
  String get pinDateRequired => 'A date is required to pin this topic.';

  @override
  String get pinTopicGlobally => 'Pin Topic Globally';

  @override
  String get flagThanks => 'Thanks for keeping our community civil!';

  @override
  String get flagReviewProcess =>
      'All flags are received by moderators and will be reviewed as soon as possible.';

  @override
  String get flagCant => 'Sorry, you can\'t flag this post at this time.';

  @override
  String get flagSendMessage => 'Message';

  @override
  String get flagMessageForUser => 'Message for the user';

  @override
  String get flagMessageForModerators => 'Message for the moderators';

  @override
  String get flagPlaceholderNotifyUser =>
      'Be specific, be constructive, and always be kind.';

  @override
  String get flagPlaceholderNotifyModerators =>
      'Let us know specifically what you are concerned about, and provide relevant links and examples where possible.';

  @override
  String get flagPlaceholderIllegal =>
      'Let us know specifically why you believe this content is illegal, and provide relevant links and examples where possible.';

  @override
  String get flagConfirmIllegal =>
      'What I’ve written above is accurate and complete.';

  @override
  String flagMessageAtLeast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'enter at least $count characters',
      one: 'enter at least $count character',
    );
    return '$_temp0';
  }

  @override
  String get flagMessageSent => 'Your message has been sent.';

  @override
  String get mergeTopicError =>
      'There was an error moving posts into that topic.';

  @override
  String get topicTitlePlaceholder =>
      'What is this discussion about in one brief sentence?';

  @override
  String get topicMoved => 'Topic moved';

  @override
  String get topicMerged => 'Topic merged';

  @override
  String get mergeTopicExplanation =>
      'Every post in this topic moves into the topic you choose. This can\'t be undone in the app.';

  @override
  String get destinationTopicId => 'Destination topic ID';

  @override
  String get topicAuthorUnknown => 'Unknown';

  @override
  String get noHotTopics => 'There are no hot topics.';

  @override
  String get signInToViewNewTopics => 'Sign in to view new topics';

  @override
  String get newTopicsSignInMessage =>
      'New topics show what was created since your last visit.';

  @override
  String get topPeriodAllTime => 'All time';

  @override
  String get topPeriodYear => 'Year';

  @override
  String get topPeriodQuarter => 'Quarter';

  @override
  String get topPeriodMonth => 'Month';

  @override
  String get topPeriodWeek => 'Week';

  @override
  String get topPeriodToday => 'Today';

  @override
  String noTopTopicsForPeriod(String period) {
    String _temp0 = intl.Intl.selectLogic(
      period,
      {
        'all': 'No top topics of all time.',
        'yearly': 'No top topics this year.',
        'quarterly': 'No top topics this quarter.',
        'monthly': 'No top topics this month.',
        'weekly': 'No top topics this week.',
        'daily': 'No top topics today.',
        'other': 'There are no top topics.',
      },
    );
    return '$_temp0';
  }

  @override
  String get connectionTimedOutSiteUnreachable =>
      'Connection timed out. The site may be down or unreachable.';

  @override
  String get failedToMarkNotificationsRead =>
      'Failed to mark notifications as read';

  @override
  String get forumNameFallback => 'Forum';

  @override
  String get noForumDescription => 'No description available.';

  @override
  String get dismissAllNotifications => 'Dismiss all';

  @override
  String get notificationPostIdMissing =>
      'Post ID is missing. Cannot navigate to the post.';

  @override
  String get notificationTopicIdMissingForPost =>
      'Topic ID is missing. Cannot navigate to the post.';

  @override
  String get notificationTopicIdMissing =>
      'Topic ID is missing. Cannot open the topic.';

  @override
  String get notificationUsernameMissing =>
      'Username is missing. Cannot open user profile.';

  @override
  String get notificationChannelIdMissing =>
      'Channel ID is missing. Cannot open the chat.';

  @override
  String get notificationGroupNameMissingForInbox =>
      'Group name is missing. Cannot open the inbox.';

  @override
  String get notificationGroupNameMissing =>
      'Group name is missing. Cannot open the group.';

  @override
  String get notificationNoActionUrl =>
      'No action URL available for this notification type.';

  @override
  String get notificationBadgeUnavailable => 'Badge details are unavailable.';

  @override
  String get notificationBadgeLoadFailed => 'Could not load this badge.';

  @override
  String get personalMessageTitleFallback => 'Personal message';

  @override
  String get topicTitleFallback => 'Topic';

  @override
  String get signInToViewNotifications => 'Sign in to view notifications';

  @override
  String get youNeedToBeSignedInToViewNotifications =>
      'You need to be signed in to view your notifications.';

  @override
  String get noUnreadNotifications => 'No unread notifications';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get newNotificationFallbackBody => 'New notification';

  @override
  String get unableToOpenNotification => 'Unable to open notification';

  @override
  String get notificationMissingSiteInfo =>
      'Missing site information (site_id).';

  @override
  String get notificationInvalidSiteInfo =>
      'Invalid site information (site_id).';

  @override
  String get notificationMissingPostInfo =>
      'Missing post information (content_id).';

  @override
  String get notificationMissingMessageInfo =>
      'Missing message information (conversation_id).';

  @override
  String get notificationMissingUserInfo =>
      'Missing user information (sender_id).';

  @override
  String get notificationUnsupportedType => 'Unsupported notification type.';

  @override
  String get notificationForumNotFound => 'Forum not found for this site.';

  @override
  String get notificationForumOpenFailed => 'Failed to initialize the forum.';

  @override
  String get notificationMissingTopicInfo =>
      'Missing topic information (topic_id).';

  @override
  String get failedToLoadTags => 'Failed to load tags.';

  @override
  String get searchTagsHint => 'Search tags…';

  @override
  String get tagsSortedByCountTooltip =>
      'Sorted by topic count — tap to switch to A→Z';

  @override
  String get tagsSortedAlphabeticallyTooltip =>
      'Sorted alphabetically — tap to switch to popularity';

  @override
  String get noTagsYet => 'No tags yet on this forum.';

  @override
  String get tagNotificationLevelTooltip => 'Notification level';

  @override
  String get tagTopicsLoadFailed => 'Failed to load';

  @override
  String searchFailedWithError(String error) {
    return 'Search failed: $error';
  }

  @override
  String get searchFiltersButtonTooltip => 'Filters';

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
  String get bookmarksUnavailable => 'Bookmarks are unavailable';

  @override
  String get failedToLoadBookmarks => 'Failed to load bookmarks';

  @override
  String get failedToRemoveBookmark => 'Failed to remove bookmark';

  @override
  String get failedToUpdateBookmark => 'Failed to update bookmark';

  @override
  String get bookmarkWithReminder => 'Bookmark with reminder';

  @override
  String get noReminder => 'No reminder';

  @override
  String get failedToLoadDrafts => 'Failed to load drafts.';

  @override
  String get failedToDiscardDraft => 'Failed to discard draft';

  @override
  String get messagesLoadFailed => 'Failed to load messages';

  @override
  String get moreMessagesLoadFailed => 'Failed to load more messages';

  @override
  String get messageUnknownUser => 'Unknown';

  @override
  String get unknownErrorFallback => 'Unknown error';

  @override
  String get chatComposerDefaultHint => 'Type a message…';

  @override
  String chatChannelNumbered(Object id) {
    return 'channel $id';
  }

  @override
  String get chatSendFailed => 'Failed to send message.';

  @override
  String get chatEditFailed => 'Failed to edit message.';

  @override
  String get chatDeleteFailed => 'Failed to delete message.';

  @override
  String get chatReactionsUnsupported => 'Reactions are not supported here.';

  @override
  String get chatReactionFailed => 'Failed to update reaction.';

  @override
  String get attachmentDefaultName => 'Attachment';

  @override
  String get fileTypeAudio => 'Audio';

  @override
  String get fileTypeText => 'Text';

  @override
  String get fileTypeArchive => 'Archive';

  @override
  String get fileTypeFile => 'File';

  @override
  String downloadFailedHttpStatus(String status) {
    return 'Failed to download file: HTTP $status';
  }

  @override
  String get downloadedFileEmpty => 'Downloaded file is empty';

  @override
  String downloadFileFailed(String error) {
    return 'Failed to download file: $error';
  }

  @override
  String attachmentTypeNotAllowed(String extension, String allowed) {
    return 'File type .$extension is not allowed. Allowed types: $allowed';
  }

  @override
  String attachmentFileTooLarge(String size, String max) {
    return 'File size ($size) exceeds maximum of $max';
  }

  @override
  String get attachmentValidationFailed => 'File validation failed';

  @override
  String get uploadMissingReference =>
      'Upload succeeded but the server returned no reference for the file.';

  @override
  String get imageFileNotFound => 'Image file not found';

  @override
  String get failedToLoadVideo => 'Failed to load video';

  @override
  String get userInfoLoadFailed => 'Failed to load user info.';

  @override
  String userInfoLoadFailedWithError(String error) {
    return 'Failed to load user info: $error';
  }

  @override
  String get profileMenuIgnoreUser => 'Ignore user';

  @override
  String get profileMenuUnignoreUser => 'Unignore user';

  @override
  String get ignoreStateUpdateFailed => 'Couldn\'t update ignore state';

  @override
  String profileNowIgnoringUser(String username) {
    return 'You\'re ignoring @$username. Their posts will be hidden.';
  }

  @override
  String get profileIgnoreToggleFailed => 'Ignore toggle failed.';

  @override
  String get profileStatsLoadFailed => 'Could not load stats.';

  @override
  String get profileFollowFailed => 'Failed to follow';

  @override
  String get profileUnfollowFailed => 'Failed to unfollow';

  @override
  String get profileChatOpenFailed => 'Could not open a chat with this user.';

  @override
  String summaryLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count likes',
      one: '1 like',
    );
    return '$_temp0';
  }

  @override
  String summaryLinkClicks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clicks',
      one: '1 click',
    );
    return '$_temp0';
  }

  @override
  String get directoryPeriodAllTime => 'All time';

  @override
  String get directoryPeriodYear => 'Year';

  @override
  String get directoryPeriodQuarter => 'Quarter';

  @override
  String get directoryPeriodMonth => 'Month';

  @override
  String get directoryPeriodWeek => 'Week';

  @override
  String get directoryPeriodToday => 'Today';

  @override
  String get directoryOrderReceived => 'Received';

  @override
  String get directoryOrderReplies => 'Replies';

  @override
  String get directoryOrderTopics => 'Topics';

  @override
  String get directoryOrderVisits => 'Visits';

  @override
  String get directoryLoadFailed => 'Failed to load directory.';

  @override
  String get directoryNoUsersMatch => 'No users match that name.';

  @override
  String get directoryNoUsersForPeriod => 'No users found for this period.';

  @override
  String get userSearchNoResults => 'No users found';

  @override
  String get userSearchTryDifferentUsername =>
      'Try searching with a different username';

  @override
  String get userSearchPromptTitle => 'Search for users';

  @override
  String get userSearchPromptHint =>
      'Enter a username to find and invite users';

  @override
  String get ignoredUsersUnignoreFailed => 'Unignore failed.';

  @override
  String get ignoredUsersEmpty => 'You\'re not ignoring anyone.';

  @override
  String get ignoredUsersEmptyHint =>
      'Open a user profile and use \"Ignore user\" in the overflow menu to hide their posts and notifications.';

  @override
  String get badgesLoadFailed => 'Failed to load badges.';

  @override
  String get badgesEmpty => 'No badges on this forum.';

  @override
  String get badgeTierGold => 'Gold';

  @override
  String get badgeTierSilver => 'Silver';

  @override
  String get badgeTierBronze => 'Bronze';

  @override
  String badgeEarnedAgo(String time) {
    return 'Earned $time';
  }

  @override
  String badgeEarnedByUsers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Earned by $formatted users',
      one: 'Earned by $formatted user',
    );
    return '$_temp0';
  }

  @override
  String get trustLevelNameNewUser => 'New user';

  @override
  String get trustLevelNameBasic => 'Basic user';

  @override
  String get trustLevelNameMember => 'Member';

  @override
  String get trustLevelNameRegular => 'Regular';

  @override
  String get trustLevelNameLeader => 'Leader';

  @override
  String get trustLevelSummary0 =>
      'Just joined. Can read and post, with limits on links, images and messages.';

  @override
  String get trustLevelSummary1 =>
      'Unlocks core posting features: images and attachments, more links, flagging posts.';

  @override
  String get trustLevelSummary2 =>
      'Can send invites, ignore users, and edit their own posts for longer.';

  @override
  String get trustLevelSummary3 =>
      'Can recategorize and rename topics, create tags, and their spam flags carry more weight.';

  @override
  String get trustLevelSummary4 =>
      'Granted by staff. Can edit any post and pin, close, split or merge topics.';

  @override
  String trustLevelRowTitle(int level, String name) {
    return 'TL$level · $name';
  }

  @override
  String get profileNoUserSpecified => 'No user specified';

  @override
  String get userTopicsLoadFailed => 'Failed to load topics';

  @override
  String get userTopicsEmpty => 'No topics started yet.';

  @override
  String get userRecentPostsLoadFailed => 'Failed to load recent posts';

  @override
  String get activityUnknownTopic => 'Unknown Topic';

  @override
  String groupJoinedSnack(String group) {
    return 'You joined $group';
  }

  @override
  String get groupJoinFailed => 'Failed to join group';

  @override
  String groupLeftSnack(String group) {
    return 'You left $group';
  }

  @override
  String get groupLeaveFailed => 'Failed to leave group';

  @override
  String get groupMembershipRequestHint =>
      'Why do you want to join? Group owners see this with your request.';

  @override
  String get groupMembershipReasonRequired =>
      'A reason is required to request membership';

  @override
  String get groupMembershipRequestSent =>
      'Request sent — a group owner has to approve it';

  @override
  String get groupMembershipRequestFailed =>
      'Failed to send membership request';

  @override
  String get groupMemberBadge => 'Member';

  @override
  String get groupRequestPending => 'Request pending';

  @override
  String get groupJoining => 'Joining…';

  @override
  String get groupJoinButton => 'Join group';

  @override
  String get groupsLoadFailed => 'Failed to load groups.';

  @override
  String get groupBuiltIn => 'Built-in group';

  @override
  String invitesPendingWithCount(int count) {
    return 'Pending ($count)';
  }

  @override
  String invitesExpiredWithCount(int count) {
    return 'Expired ($count)';
  }

  @override
  String invitesRedeemedWithCount(int count) {
    return 'Redeemed ($count)';
  }

  @override
  String get invitesLoadFailed => 'Failed to load invites.';

  @override
  String get inviteLinkCreateFailed => 'Failed to create invite link';

  @override
  String get inviteEmailAddressLabel => 'Email address';

  @override
  String get inviteEmailInvalid => 'Enter a valid email address';

  @override
  String get inviteMessageOptionalLabel => 'Message (optional)';

  @override
  String get inviteSendFailed => 'Failed to send invite';

  @override
  String get revokeInviteLinkWarning => 'The invite link will stop working.';

  @override
  String revokeInviteEmailWarning(String email) {
    return 'The invite to $email will stop working.';
  }

  @override
  String get inviteRevokeFailed => 'Failed to revoke invite';

  @override
  String get inviteNoPermission => 'You don\'t have permission to invite';

  @override
  String get invitesEmptyPending => 'No pending invites';

  @override
  String get invitesEmptyExpired => 'No expired invites';

  @override
  String get invitesEmptyRedeemed => 'No redeemed invites';

  @override
  String get invitesEmptyPendingHint =>
      'Create an invite link to bring people to the forum.';

  @override
  String get inviteLinkFallbackTitle => 'Invite link';

  @override
  String inviteRedeemedOn(String date) {
    return 'Redeemed $date';
  }

  @override
  String inviteRedemptions(int count, int max) {
    return 'Redeemed $count of $max';
  }

  @override
  String get inviteEmailSent => 'Email sent';

  @override
  String get inviteEmailNotSent => 'Email not sent';

  @override
  String inviteExpiredOn(String date) {
    return 'Expired $date';
  }

  @override
  String get inviteRevokeTooltip => 'Revoke invite';

  @override
  String get reviewStatusPending => 'Pending';

  @override
  String get reviewStatusApproved => 'Approved';

  @override
  String get reviewStatusRejected => 'Rejected';

  @override
  String get reviewStatusAll => 'Everything';

  @override
  String get reviewStatusIgnored => 'Flag ignored';

  @override
  String get reviewStatusDeleted => 'Topic or post deleted';

  @override
  String get reviewQueueUnavailable =>
      'Review queue is not available on this forum.';

  @override
  String get reviewQueueLoadFailed => 'Failed to load review queue';

  @override
  String get reviewableChangedByOther =>
      'This item was changed by another moderator. Refreshing…';

  @override
  String get reviewActionFailed => 'Failed to perform action';

  @override
  String reviewActionDone(String action) {
    return '$action — done';
  }

  @override
  String get reviewRejectReasonHint => 'Why is this being rejected?';

  @override
  String get reviewTypeFlaggedPost => 'Flagged Post';

  @override
  String get reviewTypeQueuedPost => 'Queued Post';

  @override
  String get reviewTypeQueuedTopic => 'Queued Topic';

  @override
  String get reviewTypeUser => 'User';

  @override
  String get reviewTypePost => 'Post';

  @override
  String get reviewTypeChatMessage => 'Flagged chat message';

  @override
  String get reviewModeratorAccessRequired => 'Moderator access required';

  @override
  String reviewableScore(String score) {
    return 'Score $score';
  }

  @override
  String get postRepliesLoadFailed => 'Couldn\'t load replies.';

  @override
  String get postMakeWiki => 'Make wiki';

  @override
  String get postRemoveWiki => 'Remove wiki';

  @override
  String get postBookmarkRemoveFailed => 'Failed to remove bookmark';

  @override
  String get postBookmarkFailed => 'Failed to bookmark post';

  @override
  String get postBookmarkReminderUpdateFailed => 'Failed to update reminder';

  @override
  String get postBookmarkReminderSet => 'Reminder set';

  @override
  String get postBookmarkReminderCleared => 'Reminder cleared';

  @override
  String get solutionMarkFailed => 'Failed to mark answer';

  @override
  String get solutionUnmarkFailed => 'Failed to unmark answer';

  @override
  String get postUnknownDate => 'Unknown date';

  @override
  String get postBookmarkAction => 'Bookmark post';

  @override
  String get reactionButtonRemoveLike =>
      'You liked this. Tap to remove your like.';

  @override
  String reactionButtonRemove(String reaction) {
    return 'Your reaction: $reaction. Tap to remove it.';
  }

  @override
  String reactionButtonLocked(String reaction) {
    return 'Your reaction: $reaction. It can no longer be changed.';
  }

  @override
  String get reactionHoldHint => 'Long press for more reactions';

  @override
  String reactionSummarySemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reactions. Tap to see who reacted.',
      one: '1 reaction. Tap to see who reacted.',
    );
    return '$_temp0';
  }

  @override
  String get reactionLockedMessage =>
      'You can no longer change your reaction to this post.';

  @override
  String get reactionHoldTip => 'Tip: long-press the heart for more reactions.';

  @override
  String reactionsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reactions',
      one: '1 reaction',
    );
    return '$_temp0';
  }

  @override
  String get reactionsAll => 'All';

  @override
  String get reactionYou => 'You';

  @override
  String get changeYourReaction => 'Change your reaction';

  @override
  String get reactionTapAgainToRemove =>
      'Tap your reaction again to remove it.';

  @override
  String reactionFilterSemantics(String reaction, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$reaction, $count people',
      one: '$reaction, 1 person',
    );
    return '$_temp0';
  }

  @override
  String get postLikeAction => 'Like post';

  @override
  String get postUnlikeAction => 'Unlike post';

  @override
  String get postVoteRemoveFailed =>
      'Could not remove vote (past undo window?)';

  @override
  String get postVoteCastFailed => 'Could not cast vote';

  @override
  String get postUpvote => 'Upvote';

  @override
  String get postDownvote => 'Downvote';

  @override
  String get pollVoteFailed => 'Vote failed. Please try again.';

  @override
  String get pollRemoveVoteFailed =>
      'Could not remove your vote. Please try again.';

  @override
  String get pollVotersLoadFailed => 'Could not load voters.';

  @override
  String get pollVotersNotVisible => 'Voters are not visible for this poll.';

  @override
  String solutionSolvedByInPost(String name, int postNumber) {
    return 'Solved by $name in post #$postNumber';
  }

  @override
  String solutionMarkedBy(String name) {
    return 'marked by $name';
  }

  @override
  String reactAgainInSeconds(int seconds) {
    return 'You can react to this post again in ${seconds}s';
  }

  @override
  String get reactionUpdateFailed => 'Could not update reaction.';

  @override
  String get reactionsNotSupported =>
      'Reactions are not supported on this forum.';

  @override
  String get reactionsLoadFailed => 'Could not load reactions.';

  @override
  String viewProfileOfUser(String username) {
    return 'View profile of $username';
  }

  @override
  String get failedToSavePost => 'Failed to save post';

  @override
  String failedToSavePostWithError(String error) {
    return 'Failed to save post: $error';
  }

  @override
  String get failedToRemoveAttachmentCheckPermissions =>
      'Failed to remove attachment. Please check your permissions.';

  @override
  String get editPostTitle => 'Edit Post';

  @override
  String get editYourPostHint => 'Edit your post...';

  @override
  String get failedToPostReply => 'Failed to post reply';

  @override
  String failedToPostReplyWithError(String error) {
    return 'Failed to post reply: $error';
  }

  @override
  String get failedToCreateTopic => 'Failed to create topic';

  @override
  String get writeYourTopicTitle => 'Write your topic title...';

  @override
  String get writeYourTopicContent => 'Write your topic content...';

  @override
  String get composerTitleHint => 'Write your title...';

  @override
  String get composerContentHint => 'Write your content...';

  @override
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit) {
    return '$fileName: too large ($size) and could not be resized. Limit is $limit.';
  }

  @override
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit) {
    return '$fileName resized to $size$dimensions to fit the $limit limit.';
  }

  @override
  String get composerAttachFileHint => 'Attach a file to this post';

  @override
  String get composerUploadImageHint => 'Upload an image to this post';

  @override
  String get composerFormattingHint => 'Open formatting options';

  @override
  String get whisperStaffOnly => 'Whisper (staff only)';

  @override
  String get whisperOnStaffOnly => 'Whisper on (staff only)';

  @override
  String get tagInputMaxReached => 'Max tags reached';

  @override
  String get tagInputAddTag => 'Add a tag…';

  @override
  String get tagInputAddAnother => '+ tag';

  @override
  String get editHistoryUnavailable =>
      'Edit history is not available on this forum.';

  @override
  String get editHistoryLoadFailed => 'Failed to load edit history.';

  @override
  String get previousRevision => 'Previous revision';

  @override
  String get nextRevision => 'Next revision';

  @override
  String get notificationPrefsLoadFailed =>
      'Failed to load notification preferences.';

  @override
  String get notificationPrefsSaveFailed =>
      'Couldn\'t save — check your connection';

  @override
  String get signInToManageNotificationPrefs =>
      'Sign in to manage your notification preferences.';

  @override
  String get emailWhenAwayTitle => 'Email when away';

  @override
  String get emailLevelDescription =>
      'Email me when I am quoted, replied to, my @username is mentioned, or when there is new activity in my watched categories, tags or topics';

  @override
  String get notificationPrefAlways => 'Always';

  @override
  String get notificationPrefOnlyWhenAway => 'Only when away';

  @override
  String get notificationPrefNever => 'Never';

  @override
  String get emailForMessagesTitle => 'Email for messages';

  @override
  String get emailMessagesLevelDescription =>
      'Email me when I am sent a personal message';

  @override
  String get activitySummaryTitle => 'Activity summary';

  @override
  String get activitySummaryDescription =>
      'When I don’t visit here, send me an email summary of popular topics and replies';

  @override
  String get activitySummaryFrequencyTitle => 'Activity summary frequency';

  @override
  String get activitySummaryDaily => 'Daily';

  @override
  String get activitySummaryWeekly => 'Weekly';

  @override
  String get activitySummaryMonthly => 'Monthly';

  @override
  String get mailingListModeTitle => 'Mailing list mode';

  @override
  String get mailingListModeDescription =>
      'Email me every post (disables the activity summary). Not recommended on high-traffic forums.';

  @override
  String get likeNotificationFrequencyTitle => 'Notify when liked';

  @override
  String get likeNotificationFirstTimeAndDaily =>
      'First time a post is liked and daily';

  @override
  String get likeNotificationFirstTime => 'First time a post is liked';

  @override
  String get whenPostingTitle => 'When posting';

  @override
  String get whenPostingDescription => 'What happens to a topic you reply to';

  @override
  String get whenPostingWatchTopic => 'Watch topic';

  @override
  String get whenPostingTrackTopic => 'Track topic';

  @override
  String get whenPostingDoNothing => 'Do nothing';

  @override
  String get pauseNotificationsUntilTomorrow => 'Until tomorrow';

  @override
  String get couldNotEnableDoNotDisturb => 'Couldn\'t enable do not disturb';

  @override
  String get couldNotTurnOffDoNotDisturb => 'Couldn\'t turn off do not disturb';

  @override
  String get passwordResetEmailSent => 'Password-reset email sent.';

  @override
  String get couldNotSendResetEmail => 'Couldn\'t send reset email';

  @override
  String get accountRequestFailed => 'Request failed.';

  @override
  String get forumUrlUnavailable => 'Forum URL is unavailable.';

  @override
  String get couldNotOpenPreferencesPage =>
      'Couldn\'t open the preferences page.';

  @override
  String get couldNotOpenForumUrl => 'Couldn\'t open the forum URL.';

  @override
  String get couldNotRequestEmailChange => 'Couldn\'t request email change';

  @override
  String get newEmailLabel => 'New email';

  @override
  String get enterAnEmailAddress => 'Enter an email address';

  @override
  String get emailLooksInvalid => 'That doesn’t look like an email';

  @override
  String get emailNoSpaces => 'No spaces in emails';

  @override
  String get allowNotificationsSheetTitle => 'Allow notifications';

  @override
  String get notificationsGrantNoPayload =>
      'No payload returned from the grant.';

  @override
  String get thisForumFallback => 'this forum';

  @override
  String signInToDomain(String domain) {
    return 'Sign in to $domain';
  }

  @override
  String get loginResultTitle => 'Login result';

  @override
  String get invalidAuthenticationCode => 'Invalid authentication code';

  @override
  String get tfaVerificationError =>
      'An error occurred during verification. Please try again.';

  @override
  String get passwordFieldLabel => 'Password';

  @override
  String get somethingWentWrongTryAgain =>
      'Something went wrong. Please try again.';

  @override
  String get unexpectedErrorTryAgain =>
      'An unexpected error occurred. Please try again.';

  @override
  String get errorNoInternetConnection =>
      'No internet connection. Please check your network settings.';

  @override
  String get errorRequestTimedOut => 'Request timed out. Please try again.';

  @override
  String get errorServerTryLater =>
      'Server error occurred. Please try again later.';

  @override
  String get errorInvalidCredentials => 'Invalid username or password.';

  @override
  String get errorSessionExpired =>
      'Your session has expired. Please log in again.';

  @override
  String get errorAccountSuspended =>
      'Your account has been suspended. Please contact the forum\'s staff.';

  @override
  String get errorForumNotFound => 'Forum not found.';

  @override
  String get errorForumAccessDenied =>
      'You do not have permission to access this forum.';

  @override
  String get errorForumUnavailable =>
      'Forum is currently unavailable. Please try again later.';

  @override
  String get errorDataNotFound => 'Requested data not found.';

  @override
  String get errorDataCorrupted =>
      'Data appears to be corrupted. Please refresh the page.';

  @override
  String get errorCacheLoadFailed =>
      'Failed to load cached data. Please try again.';

  @override
  String errorInvalidField(String field) {
    return 'Invalid $field provided.';
  }

  @override
  String errorFieldRequired(String field) {
    return '$field is required.';
  }

  @override
  String errorPermissionDeniedFor(String action) {
    return 'You do not have permission to $action.';
  }

  @override
  String errorFeatureNotAvailable(String feature) {
    return '$feature is not available on this forum.';
  }

  @override
  String get errorStorageFull => 'Storage is full. Please free up some space.';

  @override
  String get errorStorageAccessDenied =>
      'Storage access denied. Please check app permissions.';

  @override
  String get errorNetworkTryAgain =>
      'Network error occurred. Please try again.';

  @override
  String get errorAuthenticationTryAgain =>
      'Authentication failed. Please try again.';

  @override
  String get errorForumTryAgain => 'Forum error occurred. Please try again.';

  @override
  String get connectionErrorTitle => 'Connection Error';

  @override
  String get authenticationErrorTitle => 'Authentication Error';

  @override
  String get forumErrorTitle => 'Forum Error';

  @override
  String get permissionErrorTitle => 'Permission Error';

  @override
  String errorRemovingFromMessage(String name) {
    return 'Couldn\'t remove $name from this message.';
  }

  @override
  String get chatNewMessage => 'New message';

  @override
  String get chatStarred => 'Starred';

  @override
  String get chatBrowseChannels => 'Browse channels';

  @override
  String get chatBrowseAllChannels => 'Browse all channels';

  @override
  String get chatFilterAll => 'All';

  @override
  String get chatFilterOpen => 'Open';

  @override
  String get chatFilterClosed => 'Closed';

  @override
  String get chatFilterArchived => 'Archived';

  @override
  String get chatBrowseSearch => 'Search channel by name';

  @override
  String get chatJoin => 'Join';

  @override
  String get chatJoined => 'Joined';

  @override
  String get chatLeave => 'Leave';

  @override
  String chatMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '$count member',
    );
    return '$_temp0';
  }

  @override
  String get chatYesterday => 'Yesterday';

  @override
  String get chatNoChannelsFound => 'No channels found';

  @override
  String get chatCloseDm => 'Close this personal chat';

  @override
  String get chatToday => 'Today';

  @override
  String get chatLastVisit => 'last visit';

  @override
  String chatNewMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new messages',
      one: '$count new message',
    );
    return '$_temp0';
  }

  @override
  String get chatScrollToBottom => 'Scroll to bottom';

  @override
  String get chatInReplyTo => 'In reply to';

  @override
  String get chatCopyText => 'Copy text';

  @override
  String get chatTextCopied => 'Text copied to clipboard';

  @override
  String get chatBookmark => 'Bookmark';

  @override
  String get chatPinMessage => 'Pin message';

  @override
  String get chatUnpinMessage => 'Unpin message';

  @override
  String get chatFlag => 'Flag';

  @override
  String get chatReactWithEmoji => 'React with emoji';

  @override
  String chatReplyingTo(String username) {
    return 'Replying to $username';
  }

  @override
  String get chatEditingMessage => 'Editing message';

  @override
  String chatTypingOne(String username) {
    return '$username is typing';
  }

  @override
  String chatTypingTwo(String commaSeparatedUsernames, String lastUsername) {
    return '$commaSeparatedUsernames and $lastUsername are typing';
  }

  @override
  String chatTypingMany(String commaSeparatedUsernames, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$commaSeparatedUsernames and $count others are typing',
      one: '$commaSeparatedUsernames and $count other are typing',
    );
    return '$_temp0';
  }

  @override
  String get chatOpenThread => 'Open Thread';

  @override
  String get chatMembers => 'Members';

  @override
  String get chatAddMember => 'Add Member';

  @override
  String get chatFindMembers => 'Find members';

  @override
  String get chatRemoveMember => 'Remove';

  @override
  String get chatNotifyNever => 'Never';

  @override
  String get chatNotifyMention => 'Only for mentions';

  @override
  String get chatNotifyAlways => 'For all activity';

  @override
  String get chatNotificationLevel => 'Send push notifications';

  @override
  String get chatMuteChannel => 'Mute channel';

  @override
  String get chatStarChannel => 'Star channel';

  @override
  String get chatLeaveChannel => 'Leave channel';

  @override
  String get chatSearchTitle => 'Search chat';

  @override
  String get chatSearchNoResults => 'No results found';

  @override
  String get chatMyThreads => 'My Threads';

  @override
  String chatThreadReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count replies',
      one: '$count reply',
    );
    return '$_temp0';
  }

  @override
  String get chatNoThreads =>
      'You are not participating in any threads in this channel.';

  @override
  String get chatGroupName => 'Group chat name (optional)';

  @override
  String chatMembersCounter(int count, int max) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count/$max members',
      one: '$count/$max member',
    );
    return '$_temp0';
  }

  @override
  String get chatTooManyMembers => 'Maximum number of members reached';

  @override
  String get chatThread => 'Thread';

  @override
  String get chatChannelSettings => 'Channel settings';

  @override
  String get chatSearchMessagesHint => 'Search messages';

  @override
  String get chatMyThreadsEmpty =>
      'You don\'t have any threads yet. Threads you participate in will be displayed here.';

  @override
  String get chatLeaveGroupInfo =>
      'By leaving this group chat, you will no longer have access to it and won’t receive notifications related to it. To rejoin, you will need to be re-invited by a member of the group chat.';

  @override
  String get chatPlaceholderThread => 'Chat in thread';

  @override
  String get chatLastReply => 'last reply';

  @override
  String messageListUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Unread ($count)',
      one: 'Unread ($count)',
    );
    return '$_temp0';
  }

  @override
  String messageListNewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'New ($count)',
      one: 'New ($count)',
    );
    return '$_temp0';
  }

  @override
  String get messagePersonal => 'Personal';

  @override
  String messageListIncoming(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'See $count new or updated topics',
      one: 'See $count new or updated topic',
    );
    return '$_temp0';
  }

  @override
  String get chatPlaceholderGroup => 'Chat in group';

  @override
  String get notificationAccountMismatch =>
      'This notification cannot be opened with the current account. Open Notifications to see updates for this account.';

  @override
  String get chatJoinedChannels => 'Joined channels';

  @override
  String get chatAvailableChannels => 'Available channels';

  @override
  String get chatAvailableChannelsDescription =>
      'Channels you can view or join.';

  @override
  String get chatAllChannelsJoined => 'You have joined all available channels.';

  @override
  String get chatViewChannel => 'View';
}
