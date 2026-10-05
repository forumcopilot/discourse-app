// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get accountSessionChanged =>
      'Je aanmelding is gewijzigd. Open dit scherm opnieuw om verder te gaan.';

  @override
  String get draftSessionChanged =>
      'Je aanmelding is gewijzigd. Kopieer je tekst voordat je de editor opnieuw opent om met concepten te werken.';

  @override
  String get discardFailedCloseQuestion =>
      'Toch sluiten? Een eerder opgeslagen concept blijft bij Concepten.';

  @override
  String get keepEditing => 'Verder bewerken';

  @override
  String get closeAnyway => 'Toch sluiten';

  @override
  String get uploadSessionChanged =>
      'Je aanmelding is tijdens het uploaden gewijzigd. Open dit scherm opnieuw voordat je het nogmaals probeert.';

  @override
  String get submissionUnconfirmed =>
      'We konden niet bevestigen dat dit is verzonden. Je tekst is behouden. Controleer het forum voordat je het opnieuw probeert.';

  @override
  String get loginTitle => 'Inloggen';

  @override
  String get usePasskey => 'Use Passkey';

  @override
  String get passkeyContinuePrompt => 'Use your passkey to continue';

  @override
  String get continueButton => 'Doorgaan';

  @override
  String get errorTitle => 'Fout';

  @override
  String get okButton => 'OK';

  @override
  String get retryButton => 'Opnieuw';

  @override
  String get copyToClipboard => 'Kopiëren naar klembord';

  @override
  String get copied => 'Gekopieerd';

  @override
  String get errorMessageCopiedToClipboard =>
      'Foutbericht gekopieerd naar klembord';

  @override
  String get dismiss => 'Sluiten';

  @override
  String get cancel => 'Annuleren';

  @override
  String get tryAgain => 'Opnieuw proberen';

  @override
  String get anErrorOccurred => 'Er is een fout opgetreden';

  @override
  String get accountPendingApproval =>
      'Je account wacht op goedkeuring. Je kunt het forum bekijken, maar niet posten tot een moderator je account goedkeurt.';

  @override
  String get checkEmailToConfirm =>
      'Controleer je e-mail om je account te bevestigen. Klik op de bevestigingslink in de e-mail die we je hebben gestuurd.';

  @override
  String get checkNewEmailToConfirm =>
      'Controleer je nieuwe e-mailadres om de wijziging te bevestigen. Je oude e-mail blijft actief tot je de nieuwe bevestigt.';

  @override
  String get emailAddressInvalid =>
      'Je e-mailadres lijkt ongeldig of weigert e-mails. Werk je e-mailadres bij in de accountinstellingen.';

  @override
  String get accountDisabled =>
      'Je account is uitgeschakeld. Neem contact op met een beheerder voor hulp.';

  @override
  String get accountRegistrationRejected =>
      'Je registratie is afgewezen. Neem contact op met een beheerder voor meer informatie.';

  @override
  String get welcomeToForumCopilot => 'Welkom bij Forum Copilot!';

  @override
  String get successfullyLoggedOut => 'Je bent afgemeld';

  @override
  String get accountStatusRequiresAttention =>
      'Je accountstatus vereist aandacht. Neem contact op met een beheerder als je vragen hebt.';

  @override
  String get updateEmail => 'E-mail bijwerken';

  @override
  String get resend => 'Opnieuw verzenden';

  @override
  String get noLatestTopics => 'Geen nieuwste topics';

  @override
  String get noRecentTopicsToDisplay =>
      'Er zijn geen recente topics om weer te geven. Kom later terug voor nieuwe discussies.';

  @override
  String get signInToViewLatestTopics =>
      'Log in om nieuwste topics te bekijken';

  @override
  String get youNeedToBeSignedInToViewLatestTopics =>
      'Je moet aangemeld zijn om de nieuwste topics te bekijken.';

  @override
  String get thereAreNoUnreadTopics =>
      'Er zijn geen ongelezen topics. Kom later terug voor nieuwe discussies.';

  @override
  String get youAreAllCaughtUp => 'Je bent helemaal bij!';

  @override
  String get signInToViewUnreadTopics =>
      'Log in om ongelezen topics te bekijken';

  @override
  String get youNeedToBeSignedInToViewUnreadTopics =>
      'Je moet aangemeld zijn om je ongelezen topics te bekijken.';

  @override
  String get latest => 'Nieuwste';

  @override
  String get unread => 'Ongelezen';

  @override
  String get failedToConnectToSite =>
      'Kon geen verbinding maken met de site. De site kan offline of onbereikbaar zijn.';

  @override
  String get connectionFailed => 'Verbinding mislukt';

  @override
  String failedToConnectToSiteName(String siteName) {
    return 'Kon geen verbinding maken met $siteName';
  }

  @override
  String get loading => 'Laden...';

  @override
  String get newConversation => 'Nieuw bericht';

  @override
  String get language => 'Taal';

  @override
  String get all => 'Alles';

  @override
  String get topicsOnly => 'Alleen topics';

  @override
  String get titlesOnly => 'Alleen titels';

  @override
  String failedToShareTopic(String error) {
    return 'Kon topic niet delen: $error';
  }

  @override
  String get youCannotReplyToThisThread =>
      'Je kunt niet op dit topic antwoorden';

  @override
  String get pleaseWaitForThreadToLoad => 'Wacht tot het topic is geladen';

  @override
  String get reason => 'Reden';

  @override
  String get participantsLabel => 'Deelnemers';

  @override
  String usernameHasBeenInvited(String username) {
    return '$username is uitgenodigd voor het bericht';
  }

  @override
  String errorInvitingUser(String error) {
    return 'Fout bij uitnodigen van gebruiker: $error';
  }

  @override
  String get newTopic => 'Nieuw topic';

  @override
  String get pleaseSpecifyReason => 'Geef de reden op';

  @override
  String get selectDate => 'Selecteer datum';

  @override
  String get moreOptions => 'Meer opties';

  @override
  String get topicClosed => 'Topic gesloten';

  @override
  String get topicOpened => 'Topic geopend';

  @override
  String get noConversations => 'Je hebt geen berichten';

  @override
  String get noConversationsMessage =>
      'Je hebt nog geen berichten. Schrijf een nieuw bericht om te beginnen.';

  @override
  String get imageSavedToGallery => 'Afbeelding opgeslagen in galerij!';

  @override
  String failedToSaveImage(String error) {
    return 'Kon afbeelding niet opslaan: $error';
  }

  @override
  String get userProfile => 'Gebruikersprofiel';

  @override
  String get deletePost => 'Bericht verwijderen';

  @override
  String get loginRequired => 'Inloggen vereist';

  @override
  String get sendMessage => 'Bericht';

  @override
  String get likesReceived => 'Ontvangen likes';

  @override
  String get showMore => 'Meer tonen';

  @override
  String get failedToSaveConversation => 'Bericht kon niet worden opgeslagen';

  @override
  String get members => 'Leden';

  @override
  String membersCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString leden';
  }

  @override
  String get noSubject => 'Geen onderwerp';

  @override
  String get search => 'Zoeken';

  @override
  String get logout => 'Uitloggen';

  @override
  String get areYouSureYouWantToLogout =>
      'Weet je zeker dat je je wilt afmelden?';

  @override
  String get signIn => 'Inloggen';

  @override
  String get notificationTest => 'Meldingstest';

  @override
  String get forum => 'Categorie';

  @override
  String get profile => 'Profiel';

  @override
  String get messages => 'Berichten';

  @override
  String get add => 'Toevoegen';

  @override
  String get retry => 'Opnieuw';

  @override
  String get delete => 'Verwijderen';

  @override
  String get deleteMessage => 'Bericht verwijderen';

  @override
  String get deletingPost => 'Bericht verwijderen...';

  @override
  String failedToUnlikePost(String error) {
    return 'Kon bericht niet unliken: $error';
  }

  @override
  String failedToLikePost(String error) {
    return 'Kon bericht niet liken: $error';
  }

  @override
  String get signInToViewMessages => 'Log in om berichten te bekijken';

  @override
  String get youNeedToBeSignedInToViewConversations =>
      'Je moet ingelogd zijn om je berichten te zien.';

  @override
  String failedToLeaveConversation(String error) {
    return 'Kon het bericht niet verlaten: $error';
  }

  @override
  String errorLoadingMoreConversations(String error) {
    return 'Fout bij het laden van meer berichten: $error';
  }

  @override
  String get searchFailed => 'Zoeken mislukt';

  @override
  String get userInformationNotAvailable =>
      'Gebruikersinformatie niet beschikbaar';

  @override
  String get birthday => 'Verjaardag';

  @override
  String get posts => 'Berichten';

  @override
  String get following => 'Volgend';

  @override
  String get followers => 'Volgers';

  @override
  String get about => 'Over';

  @override
  String get location => 'Locatie';

  @override
  String get website => 'Website';

  @override
  String get next => 'Volgende';

  @override
  String get temporary => 'Tijdelijk';

  @override
  String get back => 'Terug';

  @override
  String get confirm => 'Bevestigen';

  @override
  String error(String error) {
    return 'Fout: $error';
  }

  @override
  String get removeAttachment => 'Bijlage verwijderen';

  @override
  String get areYouSureYouWantToRemoveThisAttachment =>
      'Weet je zeker dat je deze bijlage wilt verwijderen?';

  @override
  String get none => 'Geen';

  @override
  String get attachFile => 'Bestand bijvoegen';

  @override
  String get uploadImage => 'Afbeelding uploaden';

  @override
  String get formatting => 'Opmaak';

  @override
  String get bold => 'Vet';

  @override
  String get italic => 'Cursief';

  @override
  String get underline => 'Onderstreept';

  @override
  String get strikethrough => 'Doorgehaald';

  @override
  String get link => 'Link';

  @override
  String get image => 'Afbeelding';

  @override
  String get video => 'Video';

  @override
  String get quote => 'Citaat';

  @override
  String get code => 'Code';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get bulletList => 'Opsomming';

  @override
  String get numberedList => 'Genummerde lijst';

  @override
  String get listItem => 'Lijstitem';

  @override
  String participants(int count) {
    return 'Deelnemers ($count)';
  }

  @override
  String get markAsUnread => 'Markeren als ongelezen';

  @override
  String get invite => 'Uitnodigen';

  @override
  String get enterKeywordsToSearchTopics =>
      'Voer zoekwoorden in om topics te zoeken...';

  @override
  String get refresh => 'Vernieuwen';

  @override
  String get share => 'Delen';

  @override
  String get viewOnWeb => 'Bekijken op web';

  @override
  String get reply => 'Beantwoorden';

  @override
  String get vote => 'Stemmen';

  @override
  String votesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stemmen',
      one: '$count stem',
    );
    return '$_temp0';
  }

  @override
  String get pollClosed => 'Peiling gesloten';

  @override
  String pollEndsOn(String date) {
    return 'Eindigt op $date';
  }

  @override
  String get voteToSeeResults => 'Stem om resultaten te zien';

  @override
  String get viewFullPoll => 'Volledige peiling bekijken';

  @override
  String pollOptionsCount(int count) {
    return '$count opties';
  }

  @override
  String get reactedBy => 'Gereageerd door';

  @override
  String get enterKeywordsToFindTopicsAndPosts =>
      'Voer zoekwoorden in om topics en berichten te vinden';

  @override
  String get light => 'Licht';

  @override
  String get dark => 'Donker';

  @override
  String get appearance => 'Weergave';

  @override
  String get appearanceSystem => 'Systeemstandaard';

  @override
  String version(String version, String buildNumber) {
    return 'versie $version ($buildNumber)';
  }

  @override
  String get unableToLoadProfile => 'Kon profiel niet laden';

  @override
  String get banned => 'GEBLOKKEERD';

  @override
  String get deleteTopic => 'Topic verwijderen';

  @override
  String get home => 'Start';

  @override
  String get notifications => 'Meldingen';

  @override
  String get forums => 'Categorieën';

  @override
  String get content => 'Inhoud';

  @override
  String get pleaseEnterTitle => 'Voer een titel in';

  @override
  String get pleaseEnterContent => 'Voer inhoud in';

  @override
  String get uploading => 'Uploaden...';

  @override
  String get uploaded => 'Geüpload';

  @override
  String get mentionUser => 'Gebruiker vermelden';

  @override
  String get writeYourMessage => 'Schrijf je bericht…';

  @override
  String get writeYourReply => 'Schrijf je antwoord…';

  @override
  String get conversationMarkedAsUnread => 'Bericht gemarkeerd als ongelezen';

  @override
  String get conversationClosed => 'Bericht gesloten';

  @override
  String get conversationOpened => 'Bericht geopend';

  @override
  String failedToLoadQuote(String error) {
    return 'Failed to load quote: \n$error';
  }

  @override
  String failedToMarkConversationAsUnread(String error) {
    return 'Kon bericht niet als ongelezen markeren: $error';
  }

  @override
  String failedToCloseConversation(String error) {
    return 'Kon bericht niet sluiten: $error';
  }

  @override
  String failedToOpenConversation(String error) {
    return 'Kon bericht niet openen: $error';
  }

  @override
  String get goToTop => 'Naar boven';

  @override
  String get goToBottom => 'Naar beneden';

  @override
  String get pleaseLoginToAccessContent =>
      'Log in om deze inhoud te bekijken en te reageren op berichten.';

  @override
  String get searchUsers => 'Gebruikers zoeken...';

  @override
  String get enterConversationTitle => 'Voer de titel van het bericht in';

  @override
  String enterCode(int count) {
    return 'Voer $count-cijferige code in';
  }

  @override
  String get edit => 'Bewerken';

  @override
  String get remove => 'Verwijderen';

  @override
  String get subject => 'Onderwerp';

  @override
  String get message => 'Bericht';

  @override
  String get titleCannotBeEmpty => 'Titel mag niet leeg zijn';

  @override
  String get conversationUpdatedSuccessfully => 'Bericht bijgewerkt';

  @override
  String get goBack => 'Terug';

  @override
  String get like => 'liken';

  @override
  String get download => 'Downloaden';

  @override
  String downloading(String filename) {
    return 'Downloaden $filename...';
  }

  @override
  String openingShareSheet(String filename) {
    return 'Deelmenu openen voor $filename';
  }

  @override
  String errorDownloading(String filename, String error) {
    return 'Fout bij downloaden $filename: $error';
  }

  @override
  String couldNotOpenLink(String error) {
    return 'Kon link niet openen: $error';
  }

  @override
  String get translating => 'Vertalen...';

  @override
  String get translated => 'Vertaald';

  @override
  String get translatedContent => 'Vertaalde inhoud';

  @override
  String get twoFactorAuthentication => 'Tweefactorauthenticatie';

  @override
  String get authenticationCodeLabel => 'Authenticatiecode';

  @override
  String get pleaseEnterYourAuthenticationCode =>
      'Voer je authenticatiecode in';

  @override
  String codeMustBeDigits(int count) {
    return 'Code moet $count cijfers bevatten';
  }

  @override
  String get codeMustContainOnlyNumbers => 'Code mag alleen cijfers bevatten';

  @override
  String get verifyButton => 'Verifiëren';

  @override
  String get attachments => 'Bijlagen';

  @override
  String get replyOptions => 'Antwoordopties';

  @override
  String get replyWithQuote => 'Antwoord met citaat';

  @override
  String fileSavedToDownloads(String filename) {
    return 'Bestand opgeslagen in Downloads: $filename';
  }

  @override
  String fileSavedToDocuments(String filename) {
    return 'Bestand opgeslagen in Documenten: $filename';
  }

  @override
  String topicLastReplyBy(String username, String time) {
    return '$username antwoordde $time';
  }

  @override
  String inReplyToUser(String username) {
    return 'als antwoord op $username';
  }

  @override
  String inReplyToPost(int number) {
    return 'als antwoord op bericht #$number';
  }

  @override
  String timeGapDaysLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dagen later',
      one: '1 dag later',
    );
    return '$_temp0';
  }

  @override
  String timeGapMonthsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count maanden later',
      one: '1 maand later',
    );
    return '$_temp0';
  }

  @override
  String timeGapYearsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jaar later',
      one: '1 jaar later',
    );
    return '$_temp0';
  }

  @override
  String get profileViews => 'Weergaven';

  @override
  String get badges => 'Badges';

  @override
  String get chatWithUser => 'Chat';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count antwoorden',
      one: '1 antwoord',
    );
    return '$_temp0';
  }

  @override
  String get chat => 'Chat';

  @override
  String moreBadges(Object count) {
    return '+$count meer';
  }

  @override
  String get allNotificationsMarkedAsRead =>
      'Alle meldingen gemarkeerd als gelezen';

  @override
  String get apply => 'Toepassen';

  @override
  String get bookmarks => 'Bladwijzers';

  @override
  String reviewableBy(String username) {
    return 'Door $username';
  }

  @override
  String get changeEmail => 'E-mailadres wijzigen';

  @override
  String get changePassword => 'Wachtwoord wijzigen';

  @override
  String get checkingStatus => 'Status controleren…';

  @override
  String get clearReminder => 'Herinnering verwijderen';

  @override
  String get copy => 'Kopiëren';

  @override
  String get copyLink => 'Link kopiëren';

  @override
  String couldNotEnableNotifications(String error) {
    return 'Meldingen konden niet worden ingeschakeld: $error';
  }

  @override
  String get couldNotFindBookmark => 'Deze bladwijzer is niet gevonden';

  @override
  String couldNotOpenEmail(String email) {
    return 'E-mail kon niet worden geopend: $email';
  }

  @override
  String couldNotStartSignIn(String error) {
    return 'Aanmelden kon niet worden gestart: $error';
  }

  @override
  String get customDateAndTime => 'Eigen datum en tijd';

  @override
  String get deleteAccount => 'Account verwijderen';

  @override
  String get deleteMessageQuestion => 'Bericht verwijderen?';

  @override
  String get discard => 'Verwerpen';

  @override
  String get doNotDisturb => 'Niet storen';

  @override
  String get editHistory => 'Bewerkingsgeschiedenis';

  @override
  String get editProfile => 'Profiel bewerken';

  @override
  String get editReminder => 'Herinnering bewerken';

  @override
  String emailCopiedToClipboard(String email) {
    return 'E-mail gekopieerd naar klembord: $email';
  }

  @override
  String get pushEnabledForThisLogin => 'Ingeschakeld voor deze aanmelding';

  @override
  String get failedToLoadMoreTopics =>
      'Meer topics laden mislukt. Scroll om opnieuw te proberen.';

  @override
  String get failedToUpdateNotificationLevel =>
      'Meldingsniveau bijwerken mislukt';

  @override
  String get firstPostsOnly => 'Alleen eerste berichten';

  @override
  String get ignoredUsers => 'Genegeerde gebruikers';

  @override
  String get inTwoHours => 'Over twee uur';

  @override
  String get inviteByEmail => 'Uitnodigen via e-mail';

  @override
  String get inviteLinkCopied => 'Uitnodigingslink gekopieerd';

  @override
  String inviteSentTo(String email) {
    return 'Uitnodiging verzonden naar $email';
  }

  @override
  String get leave => 'Verlaten';

  @override
  String get leaveGroup => 'Groep verlaten';

  @override
  String get leaveGroupQuestion => 'Groep verlaten?';

  @override
  String get linkCopied => 'Link gekopieerd';

  @override
  String get loadMore => 'Meer laden';

  @override
  String get manageAccountOnWeb => 'Account beheren op het web';

  @override
  String get merge => 'Samenvoegen';

  @override
  String get mergeIntoTopic => 'Samenvoegen in topic';

  @override
  String get newInviteLink => 'Nieuwe uitnodigingslink';

  @override
  String get nextWeek => 'Volgende week';

  @override
  String get pushNotAvailableInThisBuild => 'Niet beschikbaar in deze build';

  @override
  String get notNow => 'Niet nu';

  @override
  String tagNotificationLevelUpdated(String tag) {
    return 'Meldingsniveau voor \"$tag\" bijgewerkt';
  }

  @override
  String doNotDisturbOnUntil(String until) {
    return 'Aan tot $until';
  }

  @override
  String get pleaseLogInToBookmark => 'Meld je aan om een bladwijzer te maken';

  @override
  String get pleaseLogInToFollowUsers => 'Meld je aan om gebruikers te volgen';

  @override
  String get pleaseLogInToMarkAnswers =>
      'Meld je aan om antwoorden te markeren';

  @override
  String get pleaseLogInToReact => 'Meld je aan om te reageren';

  @override
  String get pleaseLogInToVote => 'Meld je aan om te stemmen';

  @override
  String get pushNotifications => 'Pushmeldingen';

  @override
  String get relevance => 'Relevantie';

  @override
  String get reminderTimeMustBeInFuture =>
      'De herinneringstijd moet in de toekomst liggen';

  @override
  String get removeBookmark => 'Bladwijzer verwijderen';

  @override
  String get removeVote => 'Stem verwijderen';

  @override
  String get renameTopic => 'Topic hernoemen';

  @override
  String reportedBy(String username) {
    return 'Gemeld door $username';
  }

  @override
  String get requestToJoin => 'Lidmaatschap aanvragen';

  @override
  String requestToJoinGroup(String group) {
    return 'Lidmaatschap van $group aanvragen';
  }

  @override
  String get reset => 'Herstellen';

  @override
  String get resizeAndUpload => 'Verkleinen en uploaden';

  @override
  String get checkConnectionAndRetry =>
      'Controleer je internetverbinding en probeer het opnieuw.';

  @override
  String get reviewQueue => 'Beoordelingswachtrij';

  @override
  String get revoke => 'Intrekken';

  @override
  String get revokeInviteQuestion => 'Uitnodiging intrekken?';

  @override
  String get save => 'Opslaan';

  @override
  String get sendInvite => 'Uitnodiging verzenden';

  @override
  String get sendRequest => 'Aanvraag verzenden';

  @override
  String get settings => 'Instellingen';

  @override
  String get showVoters => 'Stemmers tonen';

  @override
  String get signOut => 'Afmelden';

  @override
  String get signInCancelledNoPayload =>
      'Aanmelden geannuleerd — geen antwoord ontvangen';

  @override
  String signInFailed(String error) {
    return 'Aanmelden mislukt: $error';
  }

  @override
  String get startChat => 'Chat starten';

  @override
  String stoppedIgnoringUser(String username) {
    return 'Je negeert @$username niet meer';
  }

  @override
  String get titleOnly => 'Alleen titel';

  @override
  String get tomorrow => 'Morgen';

  @override
  String get turnOff => 'Uitschakelen';

  @override
  String get turnOnNotifications => 'Meldingen inschakelen';

  @override
  String get whisper => 'Fluisteren';

  @override
  String likeAgainInSeconds(Object seconds) {
    return 'Je kunt dit bericht over ${seconds}s opnieuw liken';
  }

  @override
  String get loginInfo => 'Aanmeldinfo';

  @override
  String get loginFailed => 'Aanmelden mislukt';

  @override
  String get moveToCategory => 'Verplaatsen naar categorie';

  @override
  String get undeleteTopic => 'Verwijdering van topic ongedaan maken';

  @override
  String get send => 'Verzenden';

  @override
  String get changeEmailExplanation =>
      'We sturen een bevestigingslink naar je nieuwe e-mailadres. De wijziging gaat in zodra je erop klikt.';

  @override
  String get changeEmailSecurityNote =>
      'Voor extra veiligheid kan Discourse vragen om bevestiging via de link in de e-mail. Controleer je spammap als je hem niet ziet.';

  @override
  String get noMessagesYetSayHi => 'Nog geen berichten — zeg hallo.';

  @override
  String get edited => 'bewerkt';

  @override
  String get approvedButRelayUnreachable =>
      'Goedgekeurd, maar de meldingsserver was niet bereikbaar om de installatie af te ronden. Probeer het later opnieuw via Instellingen.';

  @override
  String get notificationsAreTurnedOffForThisApp =>
      'Meldingen zijn uitgeschakeld voor deze app';

  @override
  String get pleaseLoginToCreateANewTopic =>
      'Meld je aan om een nieuw topic te maken';

  @override
  String get pleaseLoginToSubscribeToForums =>
      'Meld je aan om je op forums te abonneren';

  @override
  String leaveGroupWarning(Object group) {
    return 'Je bent dan geen lid meer van $group. Je kunt op elk moment opnieuw lid worden.';
  }

  @override
  String get groupMembersPrivate => 'De ledenlijst van deze groep is privé.';

  @override
  String get unignore => 'Niet meer negeren';

  @override
  String get inviteLinkCreated => 'Uitnodigingslink aangemaakt';

  @override
  String expiresOn(Object date) {
    return 'Verloopt op $date';
  }

  @override
  String get solution => 'Oplossing';

  @override
  String get deleted => 'VERWIJDERD';

  @override
  String get pleaseLoginToViewUserProfiles =>
      'Meld je aan om gebruikersprofielen te bekijken.';

  @override
  String get solved => 'Opgelost';

  @override
  String get hot => 'Populair';

  @override
  String get pinned => 'Vastgezet';

  @override
  String get locked => 'Vergrendeld';

  @override
  String get poll => 'Peiling';

  @override
  String get noDiscussionsYet => 'Nog geen discussies.';

  @override
  String get jumpToPost => 'Ga naar bericht';

  @override
  String get jump => 'Ga';

  @override
  String get endOfTheDiscussion => 'Einde van de discussie';

  @override
  String get reviewQueueStaffOnly =>
      'Alleen staf en beoordelaars kunnen de beoordelingswachtrij zien.';

  @override
  String get nothingToReview => 'Niets te beoordelen';

  @override
  String refreshFailed(Object error) {
    return 'Vernieuwen mislukt: $error';
  }

  @override
  String get refreshing => 'Vernieuwen...';

  @override
  String get title => 'Titel';

  @override
  String editedAt(Object time) {
    return 'Bewerkt $time';
  }

  @override
  String editReason(Object reason) {
    return 'Reden: $reason';
  }

  @override
  String get thisDiffIsTooLargeToDisplay =>
      'Dit verschil is te groot om weer te geven.';

  @override
  String get noContentChangesInThisRevision =>
      'Geen inhoudelijke wijzigingen in deze revisie.';

  @override
  String revisionOf(Object currentVersion, Object versionCount) {
    return 'Revisie $currentVersion van $versionCount';
  }

  @override
  String get editConversation => 'Titel bewerken';

  @override
  String get closeConversation => 'Bericht sluiten';

  @override
  String get openConversation => 'Bericht openen';

  @override
  String get leaveConversation2 => 'Bericht verlaten';

  @override
  String get closeConversation2 => 'Bericht sluiten';

  @override
  String get closeConversationConfirmation =>
      'Dit bericht sluiten? Nieuwe antwoorden zijn dan niet meer mogelijk.';

  @override
  String get close => 'Sluiten';

  @override
  String get openConversation2 => 'Bericht openen';

  @override
  String get openConversationConfirmation =>
      'Dit bericht openen? Nieuwe antwoorden zijn dan weer mogelijk.';

  @override
  String get open => 'Openen';

  @override
  String get leaveConversation3 => 'Bericht verlaten';

  @override
  String get leaveConversationConfirmation =>
      'Weet je zeker dat je jezelf uit dit bericht wilt verwijderen? Je kunt het dan niet meer zien of erop antwoorden.';

  @override
  String get editConversation2 => 'Titel bewerken';

  @override
  String get failedToLoadMessage2 => 'Bericht laden mislukt';

  @override
  String get cannotEditThisConversation => 'Je kunt dit bericht niet bewerken';

  @override
  String get options => 'Opties';

  @override
  String get conversationOpen => 'Open voor antwoorden';

  @override
  String get messageTitleHint =>
      'Waar gaat deze discussie over in één korte zin?';

  @override
  String get messageOpenForReplies => 'Nieuwe antwoorden zijn mogelijk';

  @override
  String get messageClosedForReplies => 'Gesloten: geen nieuwe antwoorden';

  @override
  String get messageSentWithoutId =>
      'Het bericht is verzonden, maar het forum gaf het niet terug. Bekijk je berichten.';

  @override
  String get messageCouldNotBeSent => 'Het bericht kon niet worden verzonden.';

  @override
  String get messageIdMissing =>
      'Dit bericht kan niet worden geopend: de ID ontbreekt.';

  @override
  String get pleaseAddARecipient => 'Voeg minstens één ontvanger toe';

  @override
  String get archiveMessage => 'Archiveren';

  @override
  String get moveToInbox => 'Verplaatsen naar inbox';

  @override
  String get messageInbox => 'Inbox';

  @override
  String get messageArchive => 'Archief';

  @override
  String get messageListUnread => 'Ongelezen';

  @override
  String get messageListNew => 'Nieuw';

  @override
  String get messageListSent => 'Verzonden';

  @override
  String removeFromMessageConfirm(String name) {
    return 'Weet je zeker dat je $name wilt verwijderen uit dit bericht?';
  }

  @override
  String uploadingFilename(String filename) {
    return 'Uploaden: $filename…';
  }

  @override
  String get messageArchived => 'Bericht gearchiveerd';

  @override
  String get messageMovedToInbox => 'Verplaatst naar inbox';

  @override
  String failedToArchiveMessage(Object error) {
    return 'Kon het bericht niet archiveren: $error';
  }

  @override
  String failedToMoveMessageToInbox(Object error) {
    return 'Kon het bericht niet naar de inbox verplaatsen: $error';
  }

  @override
  String get noArchivedMessages => 'Je hebt geen gearchiveerde berichten';

  @override
  String get noArchivedMessagesHint =>
      'Archiveer een bericht via het ⋮-menu om het hier te bewaren.';

  @override
  String groupHasBeenInvited(String group) {
    return '$group is uitgenodigd voor het bericht';
  }

  @override
  String participantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count deelnemers',
      one: '1 deelnemer',
    );
    return '$_temp0';
  }

  @override
  String get chatChannels => 'Kanalen';

  @override
  String get chatDms => 'Directe berichten';

  @override
  String get chatNoChannels => 'Je neemt nog niet deel aan kanalen!';

  @override
  String get chatNoDms => 'Je neemt nog niet deel aan directe berichten!';

  @override
  String get chatNoDmsCta => 'Gesprek starten';

  @override
  String chatPlaceholderChannel(String channel) {
    return 'Chat in $channel';
  }

  @override
  String chatPlaceholderUsers(String names) {
    return 'Chatten met $names';
  }

  @override
  String get chatPlaceholderSelf => 'Schrijf iets';

  @override
  String get chatPlaceholderArchived =>
      'Kanaal is gearchiveerd, je kunt momenteel geen nieuwe berichten sturen.';

  @override
  String get chatPlaceholderClosed =>
      'Kanaal is gesloten, je kunt momenteel geen nieuwe berichten sturen.';

  @override
  String get chatPlaceholderReadOnly =>
      'Kanaal is alleen-lezen, je kunt momenteel geen nieuwe berichten sturen.';

  @override
  String get chatPlaceholderSilenced =>
      'Je kunt op dit moment geen berichten sturen.';

  @override
  String get chatDeleteConfirm =>
      'Weet je zeker dat je dit bericht wilt verwijderen?';

  @override
  String get chatStartNewDm => 'Nieuw direct bericht';

  @override
  String get chatCreatePersonal => 'Maak een persoonlijke chat';

  @override
  String get chatCreateGroup => 'Groepschat maken';

  @override
  String get chatCannotCreate =>
      'Sorry, je kunt geen directe berichten sturen.';

  @override
  String get chatDisabledUser => 'heeft de chat uitgeschakeld';

  @override
  String get chatSearchPlaceholder => '@iemand';

  @override
  String get chatAddMorePlaceholder => '... voeg meer leden toe';

  @override
  String chatUserNotFound(String name) {
    return '@$name niet gevonden';
  }

  @override
  String get chatCouldNotStartDm => 'Kon de chat niet starten.';

  @override
  String get chatSignInTitle => 'Log in om de chat te gebruiken';

  @override
  String get chatSignInMessage =>
      'Je moet ingelogd zijn om chatkanalen te zien en eraan deel te nemen.';

  @override
  String get chatDirectMessage => 'Direct bericht';

  @override
  String get chatNotAvailable => 'Chat is niet beschikbaar op dit forum.';

  @override
  String get chatAttachFile => 'Voeg een bestand toe';

  @override
  String get chatRemoveUpload => 'Bestand verwijderen';

  @override
  String get takePhoto => 'Foto maken';

  @override
  String get postNeedsApprovalTitle => 'Bericht vereist goedkeuring';

  @override
  String get postNeedsApprovalBody =>
      'We hebben je nieuwe bericht ontvangen, maar dit moet eerst door een moderator worden goedgekeurd voordat het zichtbaar wordt. Heb geduld.';

  @override
  String maximumAttachmentsAllowed(Object count) {
    return 'Maximaal $count bijlage(n) toegestaan';
  }

  @override
  String get noImagesFoundToDisplay =>
      'Geen afbeeldingen gevonden om weer te geven.';

  @override
  String get searchForTopics => 'Topics zoeken';

  @override
  String get noTopicsFound => 'Geen topics gevonden';

  @override
  String get trySearchingWithDifferentKeywords => 'Probeer andere zoekwoorden';

  @override
  String get noPostsFound => 'Geen berichten gevonden';

  @override
  String get perTopicNotificationLevelsNote =>
      'Meldingsniveaus per categorie en per topic stel je op die schermen zelf in — tik op het belpictogram van een topic of categorie.';

  @override
  String get pushNotActiveForThisLogin =>
      'Niet actief voor deze aanmelding — meld je af en weer aan om pushmeldingen toe te staan';

  @override
  String get pauseNotificationsFor => 'Meldingen pauzeren voor…';

  @override
  String get doNotDisturbExplanation =>
      'Pauzeer meldingen een tijdje — Discourse houdt ze vast tot de periode voorbij is';

  @override
  String get manageAccountSubtitle =>
      'Profiel, e-mail, wachtwoord, beveiliging, geavanceerde instellingen';

  @override
  String get changePasswordSubtitle =>
      'Stuurt een e-mail voor wachtwoordherstel naar je huidige adres';

  @override
  String get ignoredUsersSubtitle =>
      'Bekijk en beheer gebruikers van wie de berichten voor jou verborgen zijn';

  @override
  String get deleteAccountExplanation =>
      'Verwijder je account en je berichten, als het forum dat toestaat. Anders kan de staf het voor je verwijderen.';

  @override
  String get verificationEmailSent =>
      'Verificatie-e-mail verzonden — klik op de link om je nieuwe adres te bevestigen.';

  @override
  String get passwordResetExplanation =>
      'We mailen je een link voor wachtwoordherstel. Klik erop om een nieuw wachtwoord te kiezen — de wijziging gebeurt op het forum, niet in deze app.';

  @override
  String get sendResetEmail => 'Herstel-e-mail verzenden';

  @override
  String get deleteAccountDialogBody =>
      'Je account wordt beheerd door het forum. Neem rechtstreeks contact op met de forumstaf om verwijdering aan te vragen. \"Doorgaan\" opent het forum in je browser zodat je de eigen contact-/stafberichtfunctie van de site kunt gebruiken.';

  @override
  String get initializingForum => 'Forum initialiseren…';

  @override
  String get errorLoadingNotifications => 'Fout bij laden van meldingen';

  @override
  String get noNewNotificationsExplanation =>
      'Je krijgt een bericht in dit paneel over activiteit die direct relevant voor je is, inclusief reacties op je topics en berichten, wanneer iemand je @vermeldt of citeert en reacties geeft op topics die je observeert. Er worden ook meldingen gestuurd naar je e-mail wanneer je je een tijdje niet hebt aangemeld.';

  @override
  String noTagsMatch(Object filter) {
    return 'Geen tags komen overeen met \"$filter\".';
  }

  @override
  String noTopicsTagged(Object tag) {
    return 'Geen topics met tag \"$tag\"';
  }

  @override
  String get searchUser => 'Gebruiker zoeken';

  @override
  String get tapToOpen => 'Tik om te openen';

  @override
  String get imageNotAvailable => 'Afbeelding niet beschikbaar';

  @override
  String postsCount(Object count) {
    return '$count berichten';
  }

  @override
  String get permissionDeniedToSaveImage =>
      'Geen toestemming om de afbeelding op te slaan';

  @override
  String get postNotFound => 'Bericht niet gevonden.';

  @override
  String get failedToUploadFilePleaseTryAgain =>
      'Bestand uploaden mislukt. Probeer het opnieuw.';

  @override
  String failedToUploadFile2(Object errorMessage) {
    return 'Bestand uploaden mislukt: $errorMessage';
  }

  @override
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return 'Nog maar $remainingSlots bijlage(n) toegestaan. De eerste $remainingSlots2 afbeelding(en) worden verwerkt.';
  }

  @override
  String failedToRemoveAttachment2(Object error) {
    return 'Bijlage verwijderen mislukt: $error';
  }

  @override
  String sentFromMobileApp(Object siteName) {
    return 'Verzonden vanuit de mobiele app van $siteName';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      'Wacht tot de bijlagen klaar zijn met uploaden';

  @override
  String get imageIsTooLargeToUpload => 'Afbeelding is te groot om te uploaden';

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName is $fileBytes. Dit forum staat maximaal $maxBytes toe.';
  }

  @override
  String get resizeToFitExplanation =>
      'Hij kan net genoeg worden verkleind om te passen, met behoud van formaat en zoveel detail als de limiet toelaat.';

  @override
  String get failedToPostReplyPleaseTryAgain =>
      'Reactie plaatsen mislukt. Probeer het opnieuw.';

  @override
  String get failedToUpdatePostPleaseTryAgain =>
      'Bericht bijwerken mislukt. Probeer het opnieuw.';

  @override
  String get postDeletedSuccessfully => 'Bericht verwijderd';

  @override
  String failedToDeletePost(Object error) {
    return 'Bericht verwijderen mislukt: $error';
  }

  @override
  String get editHistoryNotAvailable =>
      'Bewerkingsgeschiedenis is niet beschikbaar voor dit bericht';

  @override
  String get react => 'Reageren';

  @override
  String get reactionsAreNotEnabledOnThisForum =>
      'Reacties zijn niet ingeschakeld op dit forum.';

  @override
  String get noReactionsYet => 'Nog geen reacties';

  @override
  String get searchFilters => 'Zoekfilters';

  @override
  String get suggestedTopics => 'Voorgestelde topics';

  @override
  String get suggestedMessages => 'Voorgestelde berichten';

  @override
  String get voteRemoved => 'Stem verwijderd';

  @override
  String get voters => 'Stemmers';

  @override
  String get noVotesYet => 'Nog geen stemmen.';

  @override
  String get trustLevels => 'Vertrouwensniveaus';

  @override
  String get trustLevelsExplanation =>
      'Leden verdienen vertrouwen door te lezen en mee te doen. Elk niveau ontgrendelt nieuwe mogelijkheden.';

  @override
  String get activity => 'Activiteit';

  @override
  String get dontUpload => 'Niet uploaden';

  @override
  String get dontAskAgainAlwaysResize =>
      'Niet meer vragen — altijd passend verkleinen';

  @override
  String get couldNotLoadCategories => 'Categorieën laden mislukt.';

  @override
  String get tags => 'Tags';

  @override
  String get community => 'Community';

  @override
  String get users => 'Gebruikers';

  @override
  String get groups => 'Groepen';

  @override
  String get invites => 'Uitnodigingen';

  @override
  String get account => 'Account';

  @override
  String get drafts => 'Concepten';

  @override
  String get termsOfService => 'Servicevoorwaarden';

  @override
  String get privacyPolicy => 'Privacybeleid';

  @override
  String get notSignedIn => 'Niet aangemeld';

  @override
  String get deviceWillNotShowAlertsUntilAllowedInSettings =>
      'Je apparaat toont geen meldingen totdat je notificaties toestaat in Instellingen.';

  @override
  String get openSettings => 'Instellingen openen';

  @override
  String get notificationsThisDeviceSection => 'Op dit apparaat';

  @override
  String notificationsThisDeviceCaption(Object forumName) {
    return 'Push van $forumName alleen naar dit apparaat. Je andere apparaten en het web veranderen niet.';
  }

  @override
  String notificationsAccountSection(Object forumName) {
    return 'Je account op $forumName';
  }

  @override
  String get notificationsAccountCaption =>
      'Gelden overal: op het web, per e-mail en op al je apparaten.';

  @override
  String pushOnThisDeviceSubtitle(Object forumName) {
    return 'Aan: nieuwe meldingen van $forumName komen op dit apparaat binnen.';
  }

  @override
  String pushOffThisDeviceSubtitle(Object forumName) {
    return 'Uit op dit apparaat. Om het aan te zetten, keur je het eenmalig goed op $forumName.';
  }

  @override
  String get stopPushOnThisDevice => 'Push op dit apparaat stoppen';

  @override
  String stopPushTitle(Object forumName) {
    return 'Push van $forumName op dit apparaat stoppen?';
  }

  @override
  String get stopPushOnlyThisDevice =>
      'Alleen dit apparaat stopt. Je andere apparaten houden hun push.';

  @override
  String get stopPushNothingElseChanges =>
      'Je meldingen blijven zichtbaar in de app en op het web, en de e-mails van het forum veranderen niet.';

  @override
  String stopPushPermissionDeleted(Object forumName) {
    return 'De toestemming die je op $forumName gaf, wordt verwijderd. Om push weer aan te zetten, keur je het daar opnieuw goed.';
  }

  @override
  String get stopPushQuietHint =>
      'Wil je alleen even rust? Zet hierboven de soorten uit die je niet nodig hebt, of gebruik Niet storen in je profiel.';

  @override
  String get stopPush => 'Push stoppen';

  @override
  String get turnOn => 'Inschakelen';

  @override
  String get couldNotTurnOffNotifications =>
      'Kon push niet stoppen. Probeer het later opnieuw.';

  @override
  String actionCodeTopicCreated(String when) {
    return 'Heeft dit topic $when gemaakt';
  }

  @override
  String actionCodePublicTopic(String when) {
    return 'Heeft dit topic $when openbaar gemaakt';
  }

  @override
  String actionCodeOpenTopic(String when) {
    return 'Heeft dit $when omgezet naar een topic';
  }

  @override
  String actionCodePrivateTopic(String when) {
    return 'Heeft dit topic $when een privébericht gemaakt';
  }

  @override
  String actionCodeSplitTopic(String when) {
    return 'Heeft dit topic $when gesplitst';
  }

  @override
  String actionCodeInvitedUser(String who, String when) {
    return 'Heeft $who $when uitgenodigd';
  }

  @override
  String actionCodeInvitedGroup(String who, String when) {
    return 'Heeft $who $when uitgenodigd';
  }

  @override
  String actionCodeUserLeft(String who, String when) {
    return '$who heeft zichzelf $when uit dit bericht verwijderd';
  }

  @override
  String actionCodeRemovedUser(String who, String when) {
    return 'Heeft $who $when verwijderd';
  }

  @override
  String actionCodeRemovedGroup(String who, String when) {
    return 'Heeft $who $when verwijderd';
  }

  @override
  String actionCodeAutobumped(String when) {
    return 'Heeft $when automatisch gebumpt';
  }

  @override
  String actionCodeTagsChanged(String when) {
    return 'Tags bijgewerkt $when';
  }

  @override
  String actionCodeCategoryChanged(String when) {
    return 'Categorie bijgewerkt $when';
  }

  @override
  String get actionCodeForwarded => 'Heeft de bovenstaande e-mail doorgestuurd';

  @override
  String actionCodeAutoclosedEnabled(String when) {
    return '$when gesloten';
  }

  @override
  String actionCodeAutoclosedDisabled(String when) {
    return '$when geopend';
  }

  @override
  String actionCodeClosedEnabled(String when) {
    return '$when gesloten';
  }

  @override
  String actionCodeClosedDisabled(String when) {
    return '$when geopend';
  }

  @override
  String actionCodeArchivedEnabled(String when) {
    return '$when gearchiveerd';
  }

  @override
  String actionCodeArchivedDisabled(String when) {
    return '$when gedearchiveerd';
  }

  @override
  String actionCodePinnedEnabled(String when) {
    return '$when vastgemaakt';
  }

  @override
  String actionCodePinnedDisabled(String when) {
    return '$when losgemaakt';
  }

  @override
  String actionCodePinnedGloballyEnabled(String when) {
    return '$when globaal vastgemaakt';
  }

  @override
  String actionCodePinnedGloballyDisabled(String when) {
    return '$when Losgemaakt';
  }

  @override
  String actionCodeVisibleEnabled(String when) {
    return '$when zichtbaar gemaakt';
  }

  @override
  String actionCodeVisibleDisabled(String when) {
    return '$when onzichtbaar gemaakt';
  }

  @override
  String actionCodeBannerEnabled(String when) {
    return 'Banner gemaakt op $when. De banner wordt weergegeven bovenaan elke pagina totdat de gebruiker deze sluit.';
  }

  @override
  String actionCodeBannerDisabled(String when) {
    return 'Deze banner verwijderd op $when. De banner wordt niet meer weergegeven bovenaan elke pagina.';
  }

  @override
  String actionCodeAssigned(String who, String when) {
    return 'Heeft $who toegewezen op $when';
  }

  @override
  String actionCodeUnassigned(String who, String when) {
    return 'Heeft de toewijzing aan $who opgeheven op $when';
  }

  @override
  String actionCodeReassigned(String who, String when) {
    return 'heeft $who opnieuw toegewezen op $when';
  }

  @override
  String localDateToday(String time) {
    return 'Vandaag $time';
  }

  @override
  String localDateTomorrow(String time) {
    return 'Morgen $time';
  }

  @override
  String localDateYesterday(String time) {
    return 'Gisteren $time';
  }

  @override
  String get eventExpired => 'Verlopen';

  @override
  String get eventEveryDay => 'Elke dag';

  @override
  String get eventEveryWeekday => 'Elke weekdag';

  @override
  String get eventEveryWeek => 'Elke week op deze weekdag';

  @override
  String get eventEveryTwoWeeks => 'Elke twee weken op deze weekdag';

  @override
  String get eventEveryFourWeeks => 'Elke vier weken op deze weekdag';

  @override
  String get eventEveryMonth => 'Elke maand op deze weekdag';

  @override
  String get errorNoConnection =>
      'Het forum is niet bereikbaar. Controleer je verbinding en probeer het opnieuw.';

  @override
  String get errorTimedOut =>
      'Het forum reageerde te traag. Probeer het opnieuw.';

  @override
  String get errorPaywalled =>
      'Dit is alleen voor betalende leden van het forum.';

  @override
  String get errorBlocked =>
      'De firewall van het forum heeft de app geblokkeerd. Probeer het later opnieuw of open het forum in een browser.';

  @override
  String get errorNotAllowed =>
      'Je hebt hier geen toegang toe. Inloggen kan helpen.';

  @override
  String get errorNotFound => 'Dit bestaat niet of is verwijderd.';

  @override
  String get errorRateLimited =>
      'Je doet dat te vaak. Wacht even en probeer het opnieuw.';

  @override
  String get errorForumDown =>
      'Het forum reageert momenteel niet. Probeer het later opnieuw.';

  @override
  String get deleteSpammer => 'Spammer verwijderen';

  @override
  String get yesDeleteSpammer => 'Ja, spammer verwijderen';

  @override
  String get deleteSpammerConfirm =>
      'Je staat op het punt de berichten en topics van deze gebruiker te verwijderen, diens account te verwijderen, registraties vanaf diens IP-adres te blokkeren en diens e-mailadres toe te voegen aan een permanente blokkeerlijst. Weet je zeker dat deze gebruiker echt een spammer is?';

  @override
  String get userWasDeleted => 'De gebruiker is verwijderd.';

  @override
  String get deleteMyAccount => 'Mijn account verwijderen';

  @override
  String get deleteAccountConfirm =>
      'Weet je zeker dat je je account definitief wilt verwijderen? Deze actie kan niet ongedaan worden gemaakt!';

  @override
  String get deletedYourself => 'Je account is verwijderd.';

  @override
  String get deleteYourselfNotAllowed =>
      'Neem contact op met een medewerker als je wilt dat je account wordt verwijderd.';

  @override
  String get createTopic => 'Topic maken';

  @override
  String get discardPostQuestion => 'Wil je je bericht weggooien?';

  @override
  String get discardChangesQuestion => 'Wil je je wijzigingen negeren?';

  @override
  String get discardChanges => 'Wijzigingen negeren';

  @override
  String get saveDraft => 'Concept opslaan';

  @override
  String get notificationSettings => 'Meldingsinstellingen';

  @override
  String get topicIsNew => 'Nieuw topic';

  @override
  String get noNewTopicsSinceLastVisit =>
      'Geen nieuwe topics sinds je laatste bezoek.';

  @override
  String get messageIsNew => 'Nieuw bericht';

  @override
  String topicUnreadReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ongelezen antwoorden',
      one: '1 ongelezen antwoord',
    );
    return '$_temp0';
  }

  @override
  String filterNewWithCount(int count) {
    return 'Nieuw ($count)';
  }

  @override
  String filterUnreadWithCount(int count) {
    return 'Ongelezen ($count)';
  }

  @override
  String categoryNewTopics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nieuw',
    );
    return '$_temp0';
  }

  @override
  String categoryUnreadTopics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ongelezen',
    );
    return '$_temp0';
  }

  @override
  String get dismissNew => 'Nieuwe negeren';

  @override
  String get dismissUnread => 'Ongelezen negeren';

  @override
  String get dismissNewTitle => 'Nieuwe topics negeren?';

  @override
  String get dismissNewMessage => 'Ze worden niet meer als nieuw getoond.';

  @override
  String get dismissUnreadTitle => 'Alle ongelezen negeren?';

  @override
  String get dismissUnreadMessage =>
      'Hun nieuwe antwoorden worden als gelezen gemarkeerd.';

  @override
  String get dismissUnreadStopTracking =>
      'Volgen van deze topics stoppen, zodat ze nooit meer als ongelezen verschijnen voor mij';

  @override
  String get dismissNewAndUnread => 'Nieuwe en ongelezen negeren';

  @override
  String dismissNewAndUnreadMessage(String category) {
    return 'Topics in $category worden niet meer als nieuw of ongelezen getoond.';
  }

  @override
  String get dismissedTopics => 'Genegeerd';

  @override
  String topicMapViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'weergaven',
      one: 'weergave',
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
      other: 'gebruikers',
      one: 'gebruiker',
    );
    return '$_temp0';
  }

  @override
  String get markAsSolution => 'Markeren als oplossing';

  @override
  String get unmarkAsSolution => 'Markering als oplossing opheffen';

  @override
  String searchForumName(String forum) {
    return 'Zoeken in $forum';
  }

  @override
  String countActiveThisMonth(String formatted) {
    return '$formatted actief deze maand';
  }

  @override
  String countMembers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted leden',
      one: '$formatted lid',
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
    return '$count nieuw deze week';
  }

  @override
  String get categoriesView => 'Categorieën';

  @override
  String get allCategories => 'Alle categorieën';

  @override
  String get allTags => 'Alle tags';

  @override
  String get myPosts => 'Mijn berichten';

  @override
  String get drawerIntroduction =>
      'De categorieën, tags en je account van dit forum staan allemaal in dit menu. Open het altijd weer met de menuknop.';

  @override
  String trustLevelN(int level) {
    return 'Vertrouwensniveau $level';
  }

  @override
  String get filterNew => 'Nieuw';

  @override
  String get filterTop => 'Top';

  @override
  String get levelWatching => 'Volgen';

  @override
  String get levelWatchingFirstPost => 'Eerste bericht volgen';

  @override
  String get levelTracking => 'Volgen (beperkt)';

  @override
  String get levelNormal => 'Normaal';

  @override
  String get levelMuted => 'Genegeerd';

  @override
  String get chooseCategory => 'Kies een categorie';

  @override
  String get signInToPostAndGetNotifications =>
      'Log in om te posten en meldingen te krijgen';

  @override
  String forumBlocksNotificationServer(Object forumName) {
    return '$forumName blokkeert onze meldingsserver, dus meldingen komen mogelijk niet aan. Je kunt ze uitzetten in Instellingen.';
  }

  @override
  String get relatedTopics => 'Gerelateerde topics';

  @override
  String get relatedMessages => 'Gerelateerde berichten';

  @override
  String moreInCategory(String category) {
    return 'Meer in $category';
  }

  @override
  String get latestTopics => 'Nieuwste topics';

  @override
  String get pushGroupMessages => 'Berichten en chat';

  @override
  String get pushGroupMessagesHint =>
      'Persoonlijke berichten, groepsinboxen en chat';

  @override
  String get pushGroupReplies => 'Antwoorden en vermeldingen';

  @override
  String get pushGroupRepliesHint =>
      'Antwoorden, vermeldingen, citaten en gevolgde topics';

  @override
  String get pushGroupReactions => 'Likes en reacties';

  @override
  String get pushGroupReactionsHint => 'Likes en reacties op je berichten';

  @override
  String get pushGroupOther => 'Al het andere';

  @override
  String get pushGroupOtherHint =>
      'Badges, herinneringen, geaccepteerde antwoorden en meer';

  @override
  String get pushChannelOther => 'Overige meldingen';

  @override
  String get couldNotChangePushSetting =>
      'Deze instelling kon niet worden gewijzigd. Probeer het later opnieuw.';

  @override
  String neverMissAReplyOn(Object forumName) {
    return 'Mis geen antwoord op $forumName';
  }

  @override
  String get notificationsPitch =>
      'Antwoorden, vermeldingen, berichten en chat op je vergrendelscherm, meestal binnen 10 minuten. Welke, kies je wanneer je wilt in Instellingen.';

  @override
  String get notificationsStepAllow => 'Meldingen toestaan op deze telefoon';

  @override
  String get notificationsStepAllowed =>
      'Meldingen zijn toegestaan op deze telefoon';

  @override
  String notificationsStepApprove(Object forumName) {
    return 'Goedkeuren op $forumName';
  }

  @override
  String get notificationsReadOnlyNote =>
      'Alleen lezen: kan niet posten, antwoorden of je berichten lezen';

  @override
  String get notificationPreviewReply =>
      'Jane heeft je geantwoord: Welkom! Fijn dat je ons gevonden hebt.';

  @override
  String get notificationPreviewMessage =>
      'Sam heeft je een bericht gestuurd: Kom je vrijdag?';

  @override
  String get notificationPreviewNow => 'nu';

  @override
  String get notificationPreviewEarlier => '5 min geleden';

  @override
  String get activityReplied => 'Beantwoord';

  @override
  String get activityStartedTopic => 'Topic gestart';

  @override
  String get activityLiked => 'Geliket';

  @override
  String get activitySolution => 'Oplossing';

  @override
  String get activityAcceptedBy => 'geaccepteerd door';

  @override
  String get activityAwaitingApproval => 'Wacht op goedkeuring';

  @override
  String get activityFilterTopics => 'Topics';

  @override
  String get activityFilterReplies => 'Antwoorden';

  @override
  String get activityFilterLikes => 'Likes';

  @override
  String get activityFilterPending => 'In afwachting';

  @override
  String get sectionToday => 'Vandaag';

  @override
  String get sectionThisWeek => 'Deze week';

  @override
  String get sectionEarlier => 'Eerder';

  @override
  String draftsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count concepten wachten',
      one: '1 concept wacht',
    );
    return '$_temp0';
  }

  @override
  String get resumeDrafts => 'Hervatten';

  @override
  String get myPostsEmpty => 'Nog geen berichten';

  @override
  String get myPostsEmptyHint =>
      'Topics die je start en antwoorden die je schrijft verschijnen hier.';

  @override
  String get activityEmptyTopics => 'Nog geen topics';

  @override
  String get activityEmptyReplies => 'Nog geen antwoorden';

  @override
  String get activityEmptyLikes => 'Nog geen likes gegeven';

  @override
  String get activityEmptySolved => 'Nog geen oplossingen';

  @override
  String get viewProfile => 'Profiel bekijken';

  @override
  String get yourStuff => 'Jouw spullen';

  @override
  String get accountAndPrivacy => 'Account en privacy';

  @override
  String profileStatPosts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'berichten',
      one: 'bericht',
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
      other: 'dagen',
      one: 'dag',
    );
    return '$_temp0';
  }

  @override
  String get profileStatSolved => 'opgelost';

  @override
  String joinForum(String forum) {
    return 'Word lid van $forum';
  }

  @override
  String get guestBenefitPost => 'Antwoorden en topics starten';

  @override
  String get guestBenefitNotify => 'Een melding krijgen als iemand reageert';

  @override
  String get guestBenefitSave => 'Berichten bewaren en concepten houden';

  @override
  String get guestBenefitChat => 'Chatten en berichten sturen';

  @override
  String get createAccount => 'Account aanmaken';

  @override
  String get aboutThisForum => 'Over dit forum';

  @override
  String get drawerMore => 'Meer';

  @override
  String get goToYourProfile => 'Naar je profiel';

  @override
  String profileJoined(String date) {
    return 'Lid sinds $date';
  }

  @override
  String profileSeen(String when) {
    return 'Gezien $when';
  }

  @override
  String profileLocalTime(String time) {
    return '$time lokale tijd';
  }

  @override
  String get profileTabSummary => 'Samenvatting';

  @override
  String get summaryTopReplies => 'Topantwoorden';

  @override
  String get summaryTopTopics => 'Toptopics';

  @override
  String get summaryMostLikedBy => 'Meest geliket door';

  @override
  String get summaryMostLiked => 'Meest geliket';

  @override
  String get summaryMostRepliedTo => 'Meest beantwoord';

  @override
  String get summaryTopLinks => 'Toplinks';

  @override
  String get summaryTopCategories => 'Topcategorieën';

  @override
  String get featuredTopic => 'Uitgelicht topic';

  @override
  String get profileDetails => 'Details';

  @override
  String get followUser => 'Volgen';

  @override
  String get unfollowUser => 'Ontvolgen';

  @override
  String get profileSuspended => 'Geschorst';

  @override
  String get searchBookmarks => 'Zoek in je bladwijzers';

  @override
  String get bookmarksFilterReminders => 'Herinneringen';

  @override
  String get bookmarkWholeTopic => 'Heel topic';

  @override
  String bookmarkSaved(String when) {
    return 'opgeslagen $when';
  }

  @override
  String bookmarkPostNumber(int number) {
    return 'bericht #$number';
  }

  @override
  String reminderToday(String time) {
    return 'Vandaag, $time';
  }

  @override
  String reminderTomorrow(String time) {
    return 'Morgen, $time';
  }

  @override
  String reminderDue(String when) {
    return 'Verlopen · $when';
  }

  @override
  String get addBookmarkLabel => 'Label toevoegen';

  @override
  String get editBookmarkLabel => 'Label bewerken';

  @override
  String get bookmarkLabelHint => 'Waar is dit voor?';

  @override
  String get pinBookmark => 'Bovenaan vastzetten';

  @override
  String get unpinBookmark => 'Losmaken';

  @override
  String get bookmarkRemoved => 'Bladwijzer verwijderd';

  @override
  String get undo => 'Ongedaan maken';

  @override
  String get bookmarksNoMatch => 'Geen bladwijzers gevonden';

  @override
  String get addReminder => 'Herinnering toevoegen';

  @override
  String get bookmarksEmpty => 'Nog geen bladwijzers';

  @override
  String get bookmarksEmptyHint =>
      'Zet een bladwijzer bij een bericht via de acties en het wacht hier op je.';

  @override
  String get draftKindNewTopic => 'Nieuw topic';

  @override
  String draftMessageTo(String names) {
    return 'Bericht aan $names';
  }

  @override
  String get untitledTopic => 'Topic zonder titel';

  @override
  String get draftDiscarded => 'Concept verwijderd';

  @override
  String get draftsEmpty => 'Nog geen concepten';

  @override
  String get draftsEmptyHint =>
      'Concepten worden opgeslagen terwijl je typt. Begin een antwoord of topic en het wacht hier op je.';

  @override
  String get privacySection => 'Privacy';

  @override
  String get changeEmailSubtitle =>
      'We sturen een verificatielink naar het nieuwe adres';

  @override
  String get aboutMe => 'Over mij';

  @override
  String get aboutMeHelper => 'Bovenaan je profiel getoond';

  @override
  String get aboutMeMarkdownHint => 'Markdown werkt: **vet**, links, :emoji:';

  @override
  String get addCover => 'Omslag toevoegen';

  @override
  String get changeCover => 'Omslag wijzigen';

  @override
  String get birthdayHint =>
      'Het forum viert hem met je mee. Het jaar wordt niet bewaard.';

  @override
  String get birthdayRemoved => 'Verjaardag verwijderd';

  @override
  String get birthdaySaved => 'Verjaardag opgeslagen';

  @override
  String get cardBackground => 'Kaartachtergrond';

  @override
  String get cardBackgroundExplanation =>
      'Achter je gebruikerskaart als iemand op je foto tikt';

  @override
  String get cardBackgroundRemoved => 'Kaartachtergrond verwijderd';

  @override
  String get cardBackgroundSheetHint =>
      'Getoond achter je gebruikerskaart. Brede foto’s werken het best.';

  @override
  String get changeProfilePicture => 'Profielfoto wijzigen';

  @override
  String get changeUsername => 'Gebruikersnaam wijzigen';

  @override
  String changeUsernameExplanation(String username) {
    return 'Vermeldingen en citaten van @$username in berichten gaan over op de nieuwe naam. Oude links naar je profiel werken niet meer.';
  }

  @override
  String get chooseFromLibrary => 'Kiezen uit bibliotheek';

  @override
  String get coverPhoto => 'Omslagfoto';

  @override
  String get coverPhotoSheetHint =>
      'Getoond bovenaan je profiel, achter je foto. Brede foto’s werken het best, ongeveer 3 op 1.';

  @override
  String get coverRemoved => 'Omslag verwijderd';

  @override
  String get day => 'Dag';

  @override
  String get month => 'Maand';

  @override
  String get displayName => 'Weergavenaam';

  @override
  String displayNameHelper(String username) {
    return 'Getoond bij je berichten. Je gebruikersnaam blijft @$username.';
  }

  @override
  String get emailPasswordInAccount => 'E-mail, wachtwoord en inloggen';

  @override
  String get featureATopic => 'Een topic uitlichten';

  @override
  String get featureATopicHint =>
      'Zet een van je topics bovenaan je profiel vast.';

  @override
  String get featuredTopicChanged => 'Uitgelicht topic gewijzigd';

  @override
  String get featuredTopicNone =>
      'Geen. Zet een van je topics vast op je profiel.';

  @override
  String get featuredTopicRemoved => 'Uitgelicht topic verwijderd';

  @override
  String get featuredTopicRules =>
      'Berichten en topics in privécategorieën kunnen niet worden uitgelicht.';

  @override
  String get fieldManagedBySignIn =>
      'Dit forum beheert dit via een eigen inlogsysteem. Wijzig het daar.';

  @override
  String get flair => 'Flair';

  @override
  String flairChangedTo(String group) {
    return 'Flair gewijzigd in $group';
  }

  @override
  String get flairRemoved => 'Flair verwijderd';

  @override
  String get flairSheetHint =>
      'Een klein symbool op je foto, van een groep waarvan je lid bent.';

  @override
  String forumPictureN(int number) {
    return 'Forumafbeelding $number';
  }

  @override
  String forumQuestionNeedsAnswer(String question) {
    return '$question heeft een antwoord nodig';
  }

  @override
  String get forumQuestionRequired =>
      'Dit forum vraagt iedereen om te antwoorden';

  @override
  String get forumQuestionSetByStaff => 'Ingesteld door de staf van het forum';

  @override
  String get forumQuestionsIntro =>
      'Vragen van dit forum. * betekent verplicht.';

  @override
  String get forumQuestionsNoneAnswered => 'Nog niet beantwoord';

  @override
  String get fromThisForum => 'Van dit forum';

  @override
  String get hideMyProfile => 'Mijn openbare profiel verbergen';

  @override
  String get hideMyProfileExplanation =>
      'Anderen zien alleen je naam, foto en berichten';

  @override
  String get letterAvatar => 'Letter';

  @override
  String get moreAboutYou => 'Meer over jou';

  @override
  String namesAndMore(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'nog $count',
      one: 'nog 1',
    );
    return '$names en $_temp0';
  }

  @override
  String get newUsername => 'Nieuwe gebruikersnaam';

  @override
  String get noFlair => 'Geen flair';

  @override
  String noGravatarFound(String service) {
    return '$service heeft geen afbeelding voor je e-mailadres';
  }

  @override
  String get noTitle => 'Geen titel';

  @override
  String get noTopicsMatch => 'Geen van je topics komt overeen';

  @override
  String get noTopicsToFeature => 'Je bent nog geen topics begonnen';

  @override
  String get notSet => 'Niet ingesteld';

  @override
  String get orUse => 'Of gebruik';

  @override
  String get pictureManagedBySignIn =>
      'Dit forum stelt je foto in via een eigen inlogsysteem';

  @override
  String get primaryGroup => 'Primaire groep';

  @override
  String primaryGroupChangedTo(String group) {
    return 'Primaire groep gewijzigd in $group';
  }

  @override
  String get primaryGroupRemoved => 'Primaire groep verwijderd';

  @override
  String get primaryGroupSheetHint =>
      'Je hoofdgroep, getoond op je gebruikerskaart.';

  @override
  String get profileLoadFailed => 'Kon je profiel niet laden';

  @override
  String get profileNowHidden => 'Je profiel is verborgen';

  @override
  String get profileNowPublic => 'Je profiel is openbaar';

  @override
  String get profilePicture => 'Profielfoto';

  @override
  String get profilePictureChanged => 'Profielfoto gewijzigd';

  @override
  String get profileSaveFailed => 'Opslaan mislukt. Probeer het opnieuw.';

  @override
  String get profileSectionNameAndAbout => 'Naam en over mij';

  @override
  String get profileSectionNextToName => 'Naast je naam';

  @override
  String get profileSectionOnProfile => 'Op je profiel';

  @override
  String get profileSectionPrivacyAndTime => 'Privacy en tijd';

  @override
  String get removeCardBackground => 'Kaartachtergrond verwijderen';

  @override
  String get removeCover => 'Omslag verwijderen';

  @override
  String get removeFeaturedTopic => 'Uitgelicht topic verwijderen';

  @override
  String get searchTimezones => 'Tijdzones zoeken';

  @override
  String get searchYourTopics => 'Zoek in je topics';

  @override
  String get seeProfileAsOthersDo => 'Bekijk je profiel zoals anderen het zien';

  @override
  String get timezone => 'Tijdzone';

  @override
  String timezoneChangedTo(String zone) {
    return 'Tijdzone gewijzigd in $zone';
  }

  @override
  String timezoneWithTime(String zone, String time) {
    return '$zone · nu $time';
  }

  @override
  String timezonesMatchingPhone(String offset) {
    return 'Komt overeen met de klok van deze telefoon ($offset)';
  }

  @override
  String titleChangedTo(String title) {
    return 'Titel gewijzigd in $title';
  }

  @override
  String get titleFromBadge => 'Badge';

  @override
  String titleFromBadgeEarned(String date) {
    return 'Badge · verdiend op $date';
  }

  @override
  String titleFromGroup(String group) {
    return 'Groep $group';
  }

  @override
  String get titleGrantedByStaff => 'Toegekend door de staf van het forum';

  @override
  String get titleRemoved => 'Titel verwijderd';

  @override
  String get titleSheetHint =>
      'Getoond na je naam op je profiel en bij je berichten.';

  @override
  String get username => 'Gebruikersnaam';

  @override
  String get usernameAvailable => 'Beschikbaar';

  @override
  String usernameChanged(String username) {
    return 'Je gebruikersnaam is nu @$username';
  }

  @override
  String get usernameLockedExplanation =>
      'Op dit forum kunnen leden hun gebruikersnaam alleen kort na het aanmelden wijzigen. Een moderator kan hem voor je wijzigen.';

  @override
  String get yourPhoto => 'Je foto';

  @override
  String get chooseEmoji => 'Emoji kiezen';

  @override
  String get clearStatus => 'Status wissen';

  @override
  String get clearText => 'Wissen';

  @override
  String get inOneHour => 'Over een uur';

  @override
  String get never => 'Nooit';

  @override
  String get pauseNotifications => 'Meldingen pauzeren';

  @override
  String get pauseNotificationsUntilStatusClears => 'Tot je status verdwijnt';

  @override
  String get pickATime => 'Kies een tijd';

  @override
  String get removeStatusAfter => 'Status verwijderen';

  @override
  String get searchEmoji => 'Emoji zoeken';

  @override
  String get setStatus => 'Status instellen';

  @override
  String get setAStatus => 'Stel een status in';

  @override
  String get statusUpdated => 'Status bijgewerkt';

  @override
  String get whatAreYouDoing => 'Wat ben je aan het doen?';

  @override
  String cardPosted(String when) {
    return 'Laatste bericht $when';
  }

  @override
  String get change => 'Wijzigen';

  @override
  String get copyProfileLink => 'Link naar profiel kopiëren';

  @override
  String get ignore => 'Negeren';

  @override
  String memberOfGroup(String group) {
    return 'Lid van $group';
  }

  @override
  String get mute => 'Dempen';

  @override
  String get unmute => 'Dempen opheffen';

  @override
  String openProfileOf(String username) {
    return 'Profiel van @$username openen';
  }

  @override
  String profileIsPrivate(String username) {
    return '$username houdt het profiel privé.';
  }

  @override
  String showOnlyTheirPostsHere(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'de $count berichten',
      one: 'het bericht',
    );
    return 'Alleen $_temp0 van $name in dit topic tonen';
  }

  @override
  String showOnlyYourPostsHere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'je $count berichten',
      one: 'je bericht',
    );
    return 'Alleen $_temp0 in dit topic tonen';
  }

  @override
  String userIgnoredFor4Months(String username) {
    return 'Je negeert @$username 4 maanden lang';
  }

  @override
  String userMuted(String username) {
    return '@$username gedempt';
  }

  @override
  String userUnmuted(String username) {
    return '@$username niet meer gedempt';
  }

  @override
  String get youParenthetical => '(jij)';

  @override
  String get topicStatusClosedHelp =>
      'Dit topic is gesloten; nieuwe antwoorden zijn niet meer mogelijk';

  @override
  String get topicStatusArchivedHelp =>
      'Dit topic is gearchiveerd; het kan niet meer worden gewijzigd';

  @override
  String get topicStatusClosedArchivedHelp =>
      'Dit topic is gesloten en gearchiveerd; nieuwe antwoorden en wijzigingen zijn niet meer mogelijk';

  @override
  String get topicStatusPinnedTitle => 'Vastgemaakt';

  @override
  String get topicStatusPinnedHelp =>
      'Dit topic is voor je vastgemaakt; het wordt weergegeven bovenaan de categorie';

  @override
  String get topicStatusPinnedGloballyTitle => 'Globaal vastgemaakt';

  @override
  String get topicStatusPinnedGloballyHelp =>
      'Dit topic is globaal vastgemaakt; het wordt boven in Nieuwste en de categorie ervan weergegeven';

  @override
  String get topicStatusUnpinnedTitle => 'Losgemaakt';

  @override
  String get topicStatusUnpinnedHelp =>
      'Dit topic is voor je losgemaakt; het wordt weergegeven in de normale volgorde';

  @override
  String get topicStatusUnlistedHelp =>
      'Dit topic is niet zichtbaar; het wordt niet weergegeven in topiclijsten en is alleen toegankelijk via een rechtstreekse link.';

  @override
  String get topicStatusWarningHelp => 'Dit is een officiële waarschuwing.';

  @override
  String get notificationReasonWatchingTag =>
      'Je ontvangt meldingen omdat je een tag in dit topic observeert.';

  @override
  String get notificationReasonWatchingCategory =>
      'Je ontvangt meldingen omdat je deze categorie observeert.';

  @override
  String get notificationReasonWatchingAuto =>
      'Je ontvangt meldingen omdat je dit topic automatisch observeert.';

  @override
  String get notificationReasonWatching =>
      'Je ontvangt meldingen omdat je dit topic observeert.';

  @override
  String get notificationReasonWatchingCreated =>
      'Je ontvangt meldingen omdat je dit topic hebt gemaakt.';

  @override
  String get notificationReasonTrackingCategory =>
      'Je ziet het aantal nieuwe antwoorden omdat je deze categorie volgt.';

  @override
  String get notificationReasonTrackingReplied =>
      'Je ziet het aantal nieuwe antwoorden omdat je een antwoord in dit topic hebt geplaatst.';

  @override
  String get notificationReasonTracking =>
      'Je ziet het aantal nieuwe antwoorden omdat je dit topic volgt.';

  @override
  String get notificationReasonTrackingRead =>
      'Je ziet een aantal nieuwe antwoorden omdat je dit topic hebt gelezen.';

  @override
  String get notificationReasonNormal =>
      'Je ontvangt een melding als iemand je @naam noemt of een bericht van je beantwoordt.';

  @override
  String get notificationReasonMutedCategory =>
      'Je negeert alle meldingen in deze categorie.';

  @override
  String get notificationReasonMuted =>
      'Je negeert alle meldingen in dit topic.';

  @override
  String get notificationLevelWatching => 'Geobserveerd';

  @override
  String get notificationLevelWatchingFirstPost =>
      'Eerste bericht geobserveerd';

  @override
  String get notificationLevelTracking => 'Volgen';

  @override
  String get notificationLevelNormal => 'Normaal';

  @override
  String get notificationLevelMuted => 'Gedempt';

  @override
  String get topicWatchingDescription =>
      'Je ontvangt een melding voor elk nieuw antwoord in dit topic en het aantal nieuwe antwoorden wordt weergegeven.';

  @override
  String get topicTrackingDescription =>
      'Het aantal nieuwe antwoorden op dit topic wordt weergegeven. Je ontvangt een melding als iemand je @naam noemt of een bericht van je beantwoordt.';

  @override
  String get topicNormalDescription =>
      'Je ontvangt een melding als iemand je @naam noemt of een bericht van je beantwoordt.';

  @override
  String get topicMutedDescription =>
      'Je ontvangt geen meldingen over dit topic en het wordt niet weergegeven in Nieuwste.';

  @override
  String get messageWatchingDescription =>
      'Je ontvangt een melding voor elk nieuw antwoord op dit bericht en het aantal nieuwe antwoorden wordt weergegeven.';

  @override
  String get messageTrackingDescription =>
      'Het aantal nieuwe antwoorden op dit bericht wordt weergegeven. Je ontvangt een melding als iemand je @naam noemt of een bericht van je beantwoordt.';

  @override
  String get messageNormalDescription =>
      'Je ontvangt een melding als iemand je @naam noemt of een bericht van je beantwoordt.';

  @override
  String get messageMutedDescription =>
      'Je ontvangt geen meldingen over dit bericht.';

  @override
  String get categoryWatchingDescription =>
      'Je observeert automatisch alle nieuwe topics in deze categorieën. Je ontvangt meldingen bij elk nieuw bericht in elk topic en het aantal nieuwe antwoorden wordt weergegeven.';

  @override
  String get categoryWatchingFirstPostDescription =>
      'Je ontvangt meldingen over nieuwe topics in deze categorie, maar niet over antwoorden op de topics.';

  @override
  String get categoryTrackingDescription =>
      'Je volgt automatisch alle nieuwe topics in deze categorie. Je ontvangt een melding als iemand je @naam noemt of een bericht van je beantwoordt en het aantal nieuwe antwoorden wordt weergeven.';

  @override
  String get categoryNormalDescription =>
      'Je ontvangt een melding als iemand je @naam noemt of een bericht van je beantwoordt.';

  @override
  String get categoryMutedDescription =>
      'Je ontvangt geen meldingen over nieuwe topics in deze categorie en ze worden niet weergegeven in Nieuwste.';

  @override
  String get tagWatchingDescription =>
      'Je observeert automatisch alle nieuwe topics met deze tag. Je ontvangt meldingen bij alle nieuwe berichten en topics en het aantal ongelezen en nieuwe berichten wordt weergegeven naast het topic.';

  @override
  String get tagWatchingFirstPostDescription =>
      'Je ontvangt meldingen over nieuwe topics in deze tag, maar niet over antwoorden op de topics.';

  @override
  String get tagTrackingDescription =>
      'Je volgt automatisch alle topics met deze tag. Het aantal ongelezen en nieuwe berichten wordt weergegeven naast het topic.';

  @override
  String get tagNormalDescription =>
      'Je ontvangt een melding als iemand je @naam noemt of een bericht van je beantwoordt.';

  @override
  String get tagMutedDescription =>
      'Je ontvangt geen meldingen over nieuwe topics met deze tag en ze worden niet weergegeven op je tabblad Ongelezen.';

  @override
  String topicTimerAutoOpen(String timeLeft) {
    return 'Dit topic wordt $timeLeft automatisch geopend.';
  }

  @override
  String topicTimerAutoClose(String timeLeft) {
    return 'Dit topic wordt $timeLeft automatisch gesloten.';
  }

  @override
  String topicTimerAutoPublish(String categoryName, String timeLeft) {
    return 'Dit topic wordt $timeLeft gepubliceerd in #$categoryName.';
  }

  @override
  String topicTimerAutoCloseAfterLastPost(String duration) {
    return 'Dit topic wordt $duration na het laatste antwoord gesloten.';
  }

  @override
  String topicTimerAutoDeleteAfterLastPost(String duration) {
    return 'Dit topic wordt $duration na het laatste antwoord verwijderd.';
  }

  @override
  String topicTimerAutoDelete(String timeLeft) {
    return 'Dit topic wordt $timeLeft automatisch verwijderd.';
  }

  @override
  String topicTimerAutoBump(String timeLeft) {
    return 'Dit topic wordt $timeLeft automatisch omhoog geplaatst.';
  }

  @override
  String topicTimerAutoDeleteReplies(String duration) {
    return 'Antwoorden op dit topic worden automatisch verwijderd na $duration.';
  }

  @override
  String slowModeNotice(String duration) {
    return 'Wacht $duration tussen jouw berichten in dit topic.';
  }

  @override
  String get closeTopic => 'Topic sluiten';

  @override
  String get openTopic => 'Topic openen';

  @override
  String get pinTopic => 'Topic vastmaken';

  @override
  String get unpinTopic => 'Topic losmaken';

  @override
  String get archiveTopic => 'Topic archiveren';

  @override
  String get unarchiveTopic => 'Topic dearchiveren';

  @override
  String get unlistTopic => 'Topic onzichtbaar maken';

  @override
  String get listTopic => 'Topic zichtbaar maken';

  @override
  String get permanentlyDelete => 'Permanent verwijderen';

  @override
  String get permanentlyDeleteTopicConfirmation =>
      'Deze actie kan niet ongedaan worden gemaakt. Dit topic wordt definitief verwijderd uit de database.';

  @override
  String get deleteTopicConfirmYes => 'Ja, dit topic verwijderen';

  @override
  String get deleteTopicConfirmNo => 'Nee, dit topic behouden';

  @override
  String get topicPinned => 'Topic vastgemaakt';

  @override
  String get topicUnpinned => 'Topic losgemaakt';

  @override
  String get topicArchived => 'Topic gearchiveerd';

  @override
  String get topicUnarchived => 'Topic gedearchiveerd';

  @override
  String get topicUnlisted => 'Topic onzichtbaar gemaakt';

  @override
  String get topicListed => 'Topic zichtbaar gemaakt';

  @override
  String get topicRecovered => 'Verwijdering van topic ongedaan gemaakt';

  @override
  String topicActionFailed(String error) {
    return 'Kon het topic niet bijwerken: $error';
  }

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuten',
      one: '1 minuut',
    );
    return '$_temp0';
  }

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uur',
      one: '1 uur',
    );
    return '$_temp0';
  }

  @override
  String durationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dagen',
      one: '1 dag',
    );
    return '$_temp0';
  }

  @override
  String timeLeftMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'over $count minuten',
      one: 'over 1 minuut',
    );
    return '$_temp0';
  }

  @override
  String timeLeftHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'over $count uur',
      one: 'over 1 uur',
    );
    return '$_temp0';
  }

  @override
  String timeLeftDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'over $count dagen',
      one: 'over 1 dag',
    );
    return '$_temp0';
  }

  @override
  String get topicStatusDeletedHelp =>
      'Dit topic is verwijderd en verborgen voor andere gebruikers';

  @override
  String get flagAction => 'Markeren';

  @override
  String get flagPost => 'Bericht markeren';

  @override
  String get signUp => 'Registreren';

  @override
  String get suspendUser => 'Gebruiker schorsen';

  @override
  String get unsuspend => 'Schorsing opheffen';

  @override
  String get suspendUntil => 'Gebruiker schorsen tot';

  @override
  String get suspendForever => 'Voor altijd schorsen';

  @override
  String failedToSuspendUser(String error) {
    return 'Er is iets misgegaan bij het schorsen van deze gebruiker: $error';
  }

  @override
  String failedToUnsuspendUser(String error) {
    return 'Er is iets misgegaan bij het opheffen van de schorsing van deze gebruiker: $error';
  }

  @override
  String get suspendReasonNotListening =>
      'Wilde niet naar feedback van medewerkers luisteren';

  @override
  String get suspendReasonStaffTime =>
      'Heeft onevenredig veel tijd van medewerkers verbruikt';

  @override
  String get suspendReasonCombative => 'Te strijdlustig';

  @override
  String get suspendReasonWrongPlace => 'Op de verkeerde plek';

  @override
  String get suspendReasonNoPurpose =>
      'Geen constructief doel voor hun acties, anders dan het creëren van onenigheid binnen de community';

  @override
  String get suspendReasonCustom => 'Aangepast…';

  @override
  String get suspendReasonQuestion =>
      'Waarom schors je? Deze tekst wordt aan de gebruiker weergegeven wanneer deze zich probeert aan te melden. Houd het kort.';

  @override
  String get closedLabel => 'Gesloten';

  @override
  String get flaggingPost => 'Bericht markeren…';

  @override
  String get pleaseSelectSuspensionEndDate =>
      'Kies wanneer de schorsing eindigt';

  @override
  String get suspendingUser => 'Gebruiker schorsen…';

  @override
  String get unsuspendingUser => 'Schorsing opheffen…';

  @override
  String get userSuspended => 'Gebruiker geschorst';

  @override
  String get userUnsuspended => 'Schorsing opgeheven';

  @override
  String unsuspendUserConfirmation(String username) {
    return 'Schorsing van $username opheffen? Diegene kan dan weer inloggen.';
  }

  @override
  String get noCategoriesToDisplay =>
      'Er zijn geen categorieën om weer te geven.';

  @override
  String get noPermissionToViewCategory =>
      'Je hebt geen toestemming om topics in deze categorie te bekijken.';

  @override
  String get featureTopicTitle => 'Dit topic uitlichten';

  @override
  String get pinTopicMenu => 'Topic vastmaken...';

  @override
  String pinInCategoryUntil(String category) {
    return 'Laat dit topic bovenaan de categorie $category weergeven tot';
  }

  @override
  String get pinGloballyUntil =>
      'Laat dit topic bovenaan alle topiclijsten weergeven tot';

  @override
  String get pinNote =>
      'Gebruikers kunnen het topic individueel losmaken voor zichzelf.';

  @override
  String get pinUntil => 'Vastmaken tot';

  @override
  String get pinDateRequired =>
      'Er is een datum vereist om dit topic vast te maken.';

  @override
  String get pinTopicGlobally => 'Topic globaal vastmaken';

  @override
  String get flagThanks =>
      'Bedankt voor het beschaafd houden van onze community!';

  @override
  String get flagReviewProcess =>
      'Alle markeren worden ontvangen door moderators en zo snel mogelijk beoordeeld.';

  @override
  String get flagCant => 'Sorry, je kunt dit bericht momenteel niet markeren.';

  @override
  String get flagSendMessage => 'Bericht';

  @override
  String get flagMessageForUser => 'Bericht voor de gebruiker';

  @override
  String get flagMessageForModerators => 'Bericht voor de moderators';

  @override
  String get flagPlaceholderNotifyUser =>
      'Wees specifiek, opbouwend en altijd beleefd.';

  @override
  String get flagPlaceholderNotifyModerators =>
      'Laat ons met name weten waar je je zorgen om maakt en geef relevante links en voorbeelden waar mogelijk.';

  @override
  String get flagPlaceholderIllegal =>
      'Laat ons met name weten waarom je denkt dat deze content illegaal is en geef waar mogelijk relevante links en voorbeelden.';

  @override
  String get flagConfirmIllegal =>
      'Wat ik hierboven heb geschreven is juist en volledig.';

  @override
  String flagMessageAtLeast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'voer minimaal $count tekens in',
      one: 'voer minimaal $count teken in',
    );
    return '$_temp0';
  }

  @override
  String get flagMessageSent => 'Je bericht is verzonden.';

  @override
  String get mergeTopicError =>
      'Er is een fout opgetreden bij het verplaatsen van berichten naar dat topic.';

  @override
  String get topicTitlePlaceholder =>
      'Waar gaat deze discussie over in één korte zin?';

  @override
  String get topicMoved => 'Topic verplaatst';

  @override
  String get topicMerged => 'Topic samengevoegd';

  @override
  String get mergeTopicExplanation =>
      'Alle berichten in dit topic worden naar het gekozen topic verplaatst. Dit kan in de app niet ongedaan worden gemaakt.';

  @override
  String get destinationTopicId => 'ID van het doeltopic';

  @override
  String get topicAuthorUnknown => 'Onbekend';

  @override
  String get noHotTopics => 'Er zijn geen populaire topics.';

  @override
  String get signInToViewNewTopics =>
      'Meld je aan om nieuwe topics te bekijken';

  @override
  String get newTopicsSignInMessage =>
      'Nieuwe topics tonen wat er sinds je laatste bezoek is aangemaakt.';

  @override
  String get topPeriodAllTime => 'Altijd';

  @override
  String get topPeriodYear => 'Jaar';

  @override
  String get topPeriodQuarter => 'Kwartaal';

  @override
  String get topPeriodMonth => 'Maand';

  @override
  String get topPeriodWeek => 'Week';

  @override
  String get topPeriodToday => 'Vandaag';

  @override
  String noTopTopicsForPeriod(String period) {
    String _temp0 = intl.Intl.selectLogic(
      period,
      {
        'all': 'Geen toptopics aller tijden.',
        'yearly': 'Geen toptopics dit jaar.',
        'quarterly': 'Geen toptopics dit kwartaal.',
        'monthly': 'Geen toptopics deze maand.',
        'weekly': 'Geen toptopics deze week.',
        'daily': 'Geen toptopics vandaag.',
        'other': 'Er zijn geen toptopics.',
      },
    );
    return '$_temp0';
  }

  @override
  String get connectionTimedOutSiteUnreachable =>
      'Time-out van de verbinding. De site kan offline of onbereikbaar zijn.';

  @override
  String get failedToMarkNotificationsRead =>
      'Meldingen markeren als gelezen mislukt';

  @override
  String get forumNameFallback => 'Forum';

  @override
  String get noForumDescription => 'Geen beschrijving beschikbaar.';

  @override
  String get dismissAllNotifications => 'Alles negeren';

  @override
  String get notificationPostIdMissing =>
      'Bericht-ID ontbreekt. Kan niet naar het bericht gaan.';

  @override
  String get notificationTopicIdMissingForPost =>
      'Topic-ID ontbreekt. Kan niet naar het bericht gaan.';

  @override
  String get notificationTopicIdMissing =>
      'Topic-ID ontbreekt. Kan het topic niet openen.';

  @override
  String get notificationUsernameMissing =>
      'Gebruikersnaam ontbreekt. Kan het profiel niet openen.';

  @override
  String get notificationChannelIdMissing =>
      'Kanaal-ID ontbreekt. Kan de chat niet openen.';

  @override
  String get notificationGroupNameMissingForInbox =>
      'Groepsnaam ontbreekt. Kan de inbox niet openen.';

  @override
  String get notificationGroupNameMissing =>
      'Groepsnaam ontbreekt. Kan de groep niet openen.';

  @override
  String get notificationNoActionUrl =>
      'Geen actie-URL beschikbaar voor dit type melding.';

  @override
  String get notificationBadgeUnavailable =>
      'Badgegegevens zijn niet beschikbaar.';

  @override
  String get notificationBadgeLoadFailed => 'Kan deze badge niet laden.';

  @override
  String get personalMessageTitleFallback => 'Persoonlijk bericht';

  @override
  String get topicTitleFallback => 'Topic';

  @override
  String get signInToViewNotifications =>
      'Meld je aan om meldingen te bekijken';

  @override
  String get youNeedToBeSignedInToViewNotifications =>
      'Je moet aangemeld zijn om je meldingen te bekijken.';

  @override
  String get noUnreadNotifications => 'Geen ongelezen meldingen';

  @override
  String get noNotificationsYet => 'Nog geen meldingen';

  @override
  String get newNotificationFallbackBody => 'Nieuwe melding';

  @override
  String get unableToOpenNotification => 'Kan melding niet openen';

  @override
  String get notificationMissingSiteInfo =>
      'Site-informatie ontbreekt (site_id).';

  @override
  String get notificationInvalidSiteInfo =>
      'Ongeldige site-informatie (site_id).';

  @override
  String get notificationMissingPostInfo =>
      'Berichtinformatie ontbreekt (content_id).';

  @override
  String get notificationMissingMessageInfo =>
      'Informatie over het persoonlijke bericht ontbreekt (conversation_id).';

  @override
  String get notificationMissingUserInfo =>
      'Gebruikersinformatie ontbreekt (sender_id).';

  @override
  String get notificationUnsupportedType => 'Niet-ondersteund meldingstype.';

  @override
  String get notificationForumNotFound => 'Forum niet gevonden voor deze site.';

  @override
  String get notificationForumOpenFailed =>
      'Initialiseren van het forum mislukt.';

  @override
  String get notificationMissingTopicInfo =>
      'Topicinformatie ontbreekt (topic_id).';

  @override
  String get failedToLoadTags => 'Tags laden mislukt.';

  @override
  String get searchTagsHint => 'Tags zoeken…';

  @override
  String get tagsSortedByCountTooltip =>
      'Gesorteerd op aantal topics — tik om te wisselen naar A→Z';

  @override
  String get tagsSortedAlphabeticallyTooltip =>
      'Alfabetisch gesorteerd — tik om te wisselen naar populariteit';

  @override
  String get noTagsYet => 'Nog geen tags op dit forum.';

  @override
  String get tagNotificationLevelTooltip => 'Meldingsniveau';

  @override
  String get tagTopicsLoadFailed => 'Laden mislukt';

  @override
  String searchFailedWithError(String error) {
    return 'Zoeken mislukt: $error';
  }

  @override
  String get searchFiltersButtonTooltip => 'Filters';

  @override
  String get searchFilterStatusSection => 'Status';

  @override
  String get searchFilterMyActivitySection => 'Mijn activiteit';

  @override
  String get searchFilterMatchTypeSection => 'Soort overeenkomst';

  @override
  String get searchTagsFilterHelper =>
      'Gescheiden door spaties of komma\'s. Elke tag is vereist.';

  @override
  String get searchSortBy => 'Sorteren op';

  @override
  String get searchStatusOpen => 'Open';

  @override
  String get searchStatusArchived => 'Gearchiveerd';

  @override
  String get searchStatusNoReplies => 'Zonder antwoorden';

  @override
  String get searchStatusPublicOnly => 'Alleen openbaar';

  @override
  String get searchStatusUnsolved => 'Onopgelost';

  @override
  String get searchInBookmarked => 'Met bladwijzer';

  @override
  String get searchInMyMessages => 'In mijn berichten';

  @override
  String get searchInLiked => 'Door mij geliket';

  @override
  String get searchInPosted => 'Waarin ik iets heb geplaatst';

  @override
  String get searchInWatching => 'Die ik observeer';

  @override
  String get searchInTracking => 'Die ik volg';

  @override
  String get searchInSeen => 'Die ik heb gelezen';

  @override
  String get searchInUnseen => 'Die ik niet heb gelezen';

  @override
  String get searchSortLatestPost => 'Nieuwste bericht';

  @override
  String get searchSortMostLiked => 'Meest geliket';

  @override
  String get searchSortMostViewed => 'Meest bekeken';

  @override
  String get searchSortLatestTopic => 'Nieuwste topic';

  @override
  String get searchFieldHint => 'Zoeken…';

  @override
  String get bookmarksUnavailable => 'Bladwijzers zijn niet beschikbaar';

  @override
  String get failedToLoadBookmarks => 'Bladwijzers laden mislukt';

  @override
  String get failedToRemoveBookmark => 'Bladwijzer verwijderen mislukt';

  @override
  String get failedToUpdateBookmark => 'Bladwijzer bijwerken mislukt';

  @override
  String get bookmarkWithReminder => 'Bladwijzer met herinnering';

  @override
  String get noReminder => 'Geen herinnering';

  @override
  String get failedToLoadDrafts => 'Concepten laden mislukt.';

  @override
  String get failedToDiscardDraft => 'Concept verwijderen mislukt';

  @override
  String get messagesLoadFailed => 'Berichten laden mislukt';

  @override
  String get moreMessagesLoadFailed => 'Meer berichten laden mislukt';

  @override
  String get messageUnknownUser => 'Onbekend';

  @override
  String get unknownErrorFallback => 'Onbekende fout';

  @override
  String get chatComposerDefaultHint => 'Typ een bericht…';

  @override
  String chatChannelNumbered(Object id) {
    return 'kanaal $id';
  }

  @override
  String get chatSendFailed => 'Bericht verzenden mislukt.';

  @override
  String get chatEditFailed => 'Bericht bewerken mislukt.';

  @override
  String get chatDeleteFailed => 'Bericht verwijderen mislukt.';

  @override
  String get chatReactionsUnsupported =>
      'Reacties worden hier niet ondersteund.';

  @override
  String get chatReactionFailed => 'Reactie bijwerken mislukt.';

  @override
  String get attachmentDefaultName => 'Bijlage';

  @override
  String get fileTypeAudio => 'Audio';

  @override
  String get fileTypeText => 'Tekst';

  @override
  String get fileTypeArchive => 'Archief';

  @override
  String get fileTypeFile => 'Bestand';

  @override
  String downloadFailedHttpStatus(String status) {
    return 'Bestand downloaden mislukt: HTTP $status';
  }

  @override
  String get downloadedFileEmpty => 'Het gedownloade bestand is leeg';

  @override
  String downloadFileFailed(String error) {
    return 'Bestand downloaden mislukt: $error';
  }

  @override
  String attachmentTypeNotAllowed(String extension, String allowed) {
    return 'Bestandstype .$extension is niet toegestaan. Toegestane types: $allowed';
  }

  @override
  String attachmentFileTooLarge(String size, String max) {
    return 'Bestandsgrootte ($size) overschrijdt het maximum van $max';
  }

  @override
  String get attachmentValidationFailed => 'Bestandscontrole mislukt';

  @override
  String get uploadMissingReference =>
      'Uploaden gelukt, maar de server gaf geen verwijzing naar het bestand terug.';

  @override
  String get imageFileNotFound => 'Afbeeldingsbestand niet gevonden';

  @override
  String get failedToLoadVideo => 'Video laden mislukt';

  @override
  String get userInfoLoadFailed => 'Kon gebruikersinformatie niet laden.';

  @override
  String userInfoLoadFailedWithError(String error) {
    return 'Kon gebruikersinformatie niet laden: $error';
  }

  @override
  String get profileMenuIgnoreUser => 'Gebruiker negeren';

  @override
  String get profileMenuUnignoreUser => 'Gebruiker niet meer negeren';

  @override
  String get ignoreStateUpdateFailed => 'Kon negeerstatus niet bijwerken';

  @override
  String profileNowIgnoringUser(String username) {
    return 'Je negeert @$username. Hun berichten worden verborgen.';
  }

  @override
  String get profileIgnoreToggleFailed =>
      'Negeren in- of uitschakelen mislukt.';

  @override
  String get profileStatsLoadFailed => 'Kon statistieken niet laden.';

  @override
  String get profileFollowFailed => 'Volgen mislukt';

  @override
  String get profileUnfollowFailed => 'Ontvolgen mislukt';

  @override
  String get profileChatOpenFailed =>
      'Kon geen chat met deze gebruiker openen.';

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
      other: '$count klikken',
      one: '1 klik',
    );
    return '$_temp0';
  }

  @override
  String get directoryPeriodAllTime => 'Altijd';

  @override
  String get directoryPeriodYear => 'Jaar';

  @override
  String get directoryPeriodQuarter => 'Kwartaal';

  @override
  String get directoryPeriodMonth => 'Maand';

  @override
  String get directoryPeriodWeek => 'Week';

  @override
  String get directoryPeriodToday => 'Vandaag';

  @override
  String get directoryOrderReceived => 'Ontvangen';

  @override
  String get directoryOrderReplies => 'Antwoorden';

  @override
  String get directoryOrderTopics => 'Topics';

  @override
  String get directoryOrderVisits => 'Bezoeken';

  @override
  String get directoryLoadFailed => 'Kon de gebruikerslijst niet laden.';

  @override
  String get directoryNoUsersMatch => 'Geen gebruikers met die naam.';

  @override
  String get directoryNoUsersForPeriod =>
      'Geen gebruikers gevonden voor deze periode.';

  @override
  String get userSearchNoResults => 'Geen gebruikers gevonden';

  @override
  String get userSearchTryDifferentUsername =>
      'Probeer te zoeken met een andere gebruikersnaam';

  @override
  String get userSearchPromptTitle => 'Zoeken naar gebruikers';

  @override
  String get userSearchPromptHint =>
      'Voer een gebruikersnaam in om gebruikers te vinden en uit te nodigen';

  @override
  String get ignoredUsersUnignoreFailed => 'Niet meer negeren mislukt.';

  @override
  String get ignoredUsersEmpty => 'Je negeert niemand.';

  @override
  String get ignoredUsersEmptyHint =>
      'Open een gebruikersprofiel en kies \"Gebruiker negeren\" in het menu om hun berichten en meldingen te verbergen.';

  @override
  String get badgesLoadFailed => 'Kon badges niet laden.';

  @override
  String get badgesEmpty => 'Geen badges op dit forum.';

  @override
  String get badgeTierGold => 'Goud';

  @override
  String get badgeTierSilver => 'Zilver';

  @override
  String get badgeTierBronze => 'Brons';

  @override
  String badgeEarnedAgo(String time) {
    return 'Verdiend $time';
  }

  @override
  String badgeEarnedByUsers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Verdiend door $formatted gebruikers',
      one: 'Verdiend door $formatted gebruiker',
    );
    return '$_temp0';
  }

  @override
  String get trustLevelNameNewUser => 'Nieuwe gebruiker';

  @override
  String get trustLevelNameBasic => 'Basisgebruiker';

  @override
  String get trustLevelNameMember => 'Lid';

  @override
  String get trustLevelNameRegular => 'Vaste gebruiker';

  @override
  String get trustLevelNameLeader => 'Leider';

  @override
  String get trustLevelSummary0 =>
      'Net lid geworden. Kan lezen en berichten plaatsen, met beperkingen voor links, afbeeldingen en berichten.';

  @override
  String get trustLevelSummary1 =>
      'Ontgrendelt de belangrijkste functies: afbeeldingen en bijlagen, meer links, berichten markeren.';

  @override
  String get trustLevelSummary2 =>
      'Kan uitnodigingen versturen, gebruikers negeren en eigen berichten langer bewerken.';

  @override
  String get trustLevelSummary3 =>
      'Kan topics hercategoriseren en hernoemen, tags maken, en spammarkeringen wegen zwaarder.';

  @override
  String get trustLevelSummary4 =>
      'Toegekend door staf. Kan elk bericht bewerken en topics vastzetten, sluiten, splitsen of samenvoegen.';

  @override
  String trustLevelRowTitle(int level, String name) {
    return 'TL$level · $name';
  }

  @override
  String get profileNoUserSpecified => 'Geen gebruiker opgegeven';

  @override
  String get userTopicsLoadFailed => 'Kon topics niet laden';

  @override
  String get userTopicsEmpty => 'Nog geen topics gestart.';

  @override
  String get userRecentPostsLoadFailed => 'Kon recente berichten niet laden';

  @override
  String get activityUnknownTopic => 'Onbekend topic';

  @override
  String groupJoinedSnack(String group) {
    return 'Je bent lid geworden van $group';
  }

  @override
  String get groupJoinFailed => 'Lid worden van groep mislukt';

  @override
  String groupLeftSnack(String group) {
    return 'Je hebt $group verlaten';
  }

  @override
  String get groupLeaveFailed => 'Groep verlaten mislukt';

  @override
  String get groupMembershipRequestHint =>
      'Waarom wil je lid worden? Groepseigenaren zien dit bij je aanvraag.';

  @override
  String get groupMembershipReasonRequired =>
      'Een reden is vereist om lidmaatschap aan te vragen';

  @override
  String get groupMembershipRequestSent =>
      'Aanvraag verzonden — een groepseigenaar moet deze goedkeuren';

  @override
  String get groupMembershipRequestFailed =>
      'Lidmaatschapsaanvraag verzenden mislukt';

  @override
  String get groupMemberBadge => 'Lid';

  @override
  String get groupRequestPending => 'Aanvraag in behandeling';

  @override
  String get groupJoining => 'Lid worden…';

  @override
  String get groupJoinButton => 'Lid worden van groep';

  @override
  String get groupsLoadFailed => 'Kon groepen niet laden.';

  @override
  String get groupBuiltIn => 'Ingebouwde groep';

  @override
  String invitesPendingWithCount(int count) {
    return 'Wachtend ($count)';
  }

  @override
  String invitesExpiredWithCount(int count) {
    return 'Verlopen ($count)';
  }

  @override
  String invitesRedeemedWithCount(int count) {
    return 'Verzilverd ($count)';
  }

  @override
  String get invitesLoadFailed => 'Kon uitnodigingen niet laden.';

  @override
  String get inviteLinkCreateFailed => 'Kon uitnodigingslink niet maken';

  @override
  String get inviteEmailAddressLabel => 'E-mailadres';

  @override
  String get inviteEmailInvalid => 'Voer een geldig e-mailadres in';

  @override
  String get inviteMessageOptionalLabel => 'Bericht (optioneel)';

  @override
  String get inviteSendFailed => 'Kon uitnodiging niet versturen';

  @override
  String get revokeInviteLinkWarning =>
      'De uitnodigingslink werkt dan niet meer.';

  @override
  String revokeInviteEmailWarning(String email) {
    return 'De uitnodiging aan $email werkt dan niet meer.';
  }

  @override
  String get inviteRevokeFailed => 'Kon uitnodiging niet intrekken';

  @override
  String get inviteNoPermission => 'Je hebt geen toestemming om uit te nodigen';

  @override
  String get invitesEmptyPending => 'Geen wachtende uitnodigingen';

  @override
  String get invitesEmptyExpired => 'Geen verlopen uitnodigingen';

  @override
  String get invitesEmptyRedeemed => 'Geen verzilverde uitnodigingen';

  @override
  String get invitesEmptyPendingHint =>
      'Maak een uitnodigingslink om mensen naar het forum te halen.';

  @override
  String get inviteLinkFallbackTitle => 'Uitnodigingslink';

  @override
  String inviteRedeemedOn(String date) {
    return 'Verzilverd op $date';
  }

  @override
  String inviteRedemptions(int count, int max) {
    return '$count van $max verzilverd';
  }

  @override
  String get inviteEmailSent => 'E-mail verzonden';

  @override
  String get inviteEmailNotSent => 'E-mail niet verzonden';

  @override
  String inviteExpiredOn(String date) {
    return 'Verlopen op $date';
  }

  @override
  String get inviteRevokeTooltip => 'Uitnodiging intrekken';

  @override
  String get reviewStatusPending => 'Wachtend';

  @override
  String get reviewStatusApproved => 'Goedgekeurd';

  @override
  String get reviewStatusRejected => 'Geweigerd';

  @override
  String get reviewStatusAll => 'Alles';

  @override
  String get reviewStatusIgnored => 'Markering genegeerd';

  @override
  String get reviewStatusDeleted => 'Topic of bericht verwijderd';

  @override
  String get reviewQueueUnavailable =>
      'De beoordelingswachtrij is niet beschikbaar op dit forum.';

  @override
  String get reviewQueueLoadFailed => 'Kon beoordelingswachtrij niet laden';

  @override
  String get reviewableChangedByOther =>
      'Dit item is door een andere moderator gewijzigd. Vernieuwen…';

  @override
  String get reviewActionFailed => 'Kon actie niet uitvoeren';

  @override
  String reviewActionDone(String action) {
    return '$action — klaar';
  }

  @override
  String get reviewRejectReasonHint => 'Waarom wordt dit geweigerd?';

  @override
  String get reviewTypeFlaggedPost => 'Gemarkeerd bericht';

  @override
  String get reviewTypeQueuedPost => 'Bericht in wachtrij';

  @override
  String get reviewTypeQueuedTopic => 'Topic in wachtrij';

  @override
  String get reviewTypeUser => 'Gebruiker';

  @override
  String get reviewTypePost => 'Bericht';

  @override
  String get reviewTypeChatMessage => 'Gemarkeerd chatbericht';

  @override
  String get reviewModeratorAccessRequired => 'Moderatortoegang vereist';

  @override
  String reviewableScore(String score) {
    return 'Score $score';
  }

  @override
  String get postRepliesLoadFailed => 'Antwoorden konden niet worden geladen.';

  @override
  String get postMakeWiki => 'Wiki maken';

  @override
  String get postRemoveWiki => 'Wiki verwijderen';

  @override
  String get postBookmarkRemoveFailed => 'Bladwijzer verwijderen mislukt';

  @override
  String get postBookmarkFailed => 'Bladwijzer voor bericht maken mislukt';

  @override
  String get postBookmarkReminderUpdateFailed =>
      'Herinnering bijwerken mislukt';

  @override
  String get postBookmarkReminderSet => 'Herinnering ingesteld';

  @override
  String get postBookmarkReminderCleared => 'Herinnering gewist';

  @override
  String get solutionMarkFailed => 'Markeren als oplossing mislukt';

  @override
  String get solutionUnmarkFailed => 'Markering als oplossing opheffen mislukt';

  @override
  String get postUnknownDate => 'Onbekende datum';

  @override
  String get postBookmarkAction => 'Bladwijzer voor bericht maken';

  @override
  String get reactionButtonRemoveLike =>
      'Je hebt dit geliket. Tik om je like te verwijderen.';

  @override
  String reactionButtonRemove(String reaction) {
    return 'Jouw reactie: $reaction. Tik om die te verwijderen.';
  }

  @override
  String reactionButtonLocked(String reaction) {
    return 'Jouw reactie: $reaction. Die kan niet meer worden gewijzigd.';
  }

  @override
  String get reactionHoldHint => 'Houd ingedrukt voor meer reacties';

  @override
  String reactionSummarySemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reacties. Tik om te zien wie er reageerde.',
      one: '1 reactie. Tik om te zien wie er reageerde.',
    );
    return '$_temp0';
  }

  @override
  String get reactionLockedMessage =>
      'Je kunt je reactie op dit bericht niet meer wijzigen.';

  @override
  String get reactionHoldTip =>
      'Tip: houd het hartje ingedrukt voor meer reacties.';

  @override
  String reactionsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reacties',
      one: '1 reactie',
    );
    return '$_temp0';
  }

  @override
  String get reactionsAll => 'Alle';

  @override
  String get reactionYou => 'Jij';

  @override
  String get changeYourReaction => 'Je reactie wijzigen';

  @override
  String get reactionTapAgainToRemove =>
      'Tik nogmaals op je reactie om die te verwijderen.';

  @override
  String reactionFilterSemantics(String reaction, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$reaction, $count personen',
      one: '$reaction, 1 persoon',
    );
    return '$_temp0';
  }

  @override
  String get postLikeAction => 'Bericht liken';

  @override
  String get postUnlikeAction => 'Like ongedaan maken';

  @override
  String get postVoteRemoveFailed =>
      'Stem verwijderen mislukt (tijd om ongedaan te maken verstreken?)';

  @override
  String get postVoteCastFailed => 'Stemmen mislukt';

  @override
  String get postUpvote => 'Omhoog stemmen';

  @override
  String get postDownvote => 'Omlaag stemmen';

  @override
  String get pollVoteFailed => 'Stemmen mislukt. Probeer het opnieuw.';

  @override
  String get pollRemoveVoteFailed =>
      'Je stem kon niet worden verwijderd. Probeer het opnieuw.';

  @override
  String get pollVotersLoadFailed => 'Stemmers konden niet worden geladen.';

  @override
  String get pollVotersNotVisible =>
      'De stemmers van deze peiling zijn niet zichtbaar.';

  @override
  String solutionSolvedByInPost(String name, int postNumber) {
    return 'Opgelost door $name in bericht #$postNumber';
  }

  @override
  String solutionMarkedBy(String name) {
    return 'gemarkeerd door $name';
  }

  @override
  String reactAgainInSeconds(int seconds) {
    return 'Je kunt over ${seconds}s opnieuw op dit bericht reageren';
  }

  @override
  String get reactionUpdateFailed => 'Reactie bijwerken mislukt.';

  @override
  String get reactionsNotSupported =>
      'Reacties worden op dit forum niet ondersteund.';

  @override
  String get reactionsLoadFailed => 'Reacties konden niet worden geladen.';

  @override
  String viewProfileOfUser(String username) {
    return 'Profiel van $username bekijken';
  }

  @override
  String get failedToSavePost => 'Bericht opslaan mislukt';

  @override
  String failedToSavePostWithError(String error) {
    return 'Bericht opslaan mislukt: $error';
  }

  @override
  String get failedToRemoveAttachmentCheckPermissions =>
      'Bijlage verwijderen mislukt. Controleer je rechten.';

  @override
  String get editPostTitle => 'Bericht bewerken';

  @override
  String get editYourPostHint => 'Bewerk je bericht…';

  @override
  String get failedToPostReply => 'Reactie plaatsen mislukt';

  @override
  String failedToPostReplyWithError(String error) {
    return 'Reactie plaatsen mislukt: $error';
  }

  @override
  String get failedToCreateTopic => 'Topic aanmaken mislukt';

  @override
  String get writeYourTopicTitle => 'Schrijf de titel van je topic…';

  @override
  String get writeYourTopicContent => 'Schrijf de inhoud van je topic…';

  @override
  String get composerTitleHint => 'Schrijf je titel…';

  @override
  String get composerContentHint => 'Schrijf je inhoud…';

  @override
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit) {
    return '$fileName: te groot ($size) en kon niet worden verkleind. De limiet is $limit.';
  }

  @override
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit) {
    return '$fileName verkleind tot $size$dimensions om binnen de limiet van $limit te blijven.';
  }

  @override
  String get composerAttachFileHint => 'Een bestand aan dit bericht toevoegen';

  @override
  String get composerUploadImageHint =>
      'Een afbeelding naar dit bericht uploaden';

  @override
  String get composerFormattingHint => 'Opmaakopties openen';

  @override
  String get whisperStaffOnly => 'Fluisteren (alleen medewerkers)';

  @override
  String get whisperOnStaffOnly => 'Fluisteren aan (alleen medewerkers)';

  @override
  String get tagInputMaxReached => 'Maximaal aantal tags bereikt';

  @override
  String get tagInputAddTag => 'Tag toevoegen…';

  @override
  String get tagInputAddAnother => '+ tag';

  @override
  String get editHistoryUnavailable =>
      'Bewerkingsgeschiedenis is niet beschikbaar op dit forum.';

  @override
  String get editHistoryLoadFailed => 'Bewerkingsgeschiedenis laden mislukt.';

  @override
  String get previousRevision => 'Vorige revisie';

  @override
  String get nextRevision => 'Volgende revisie';

  @override
  String get notificationPrefsLoadFailed =>
      'Kon de meldingsvoorkeuren niet laden.';

  @override
  String get notificationPrefsSaveFailed =>
      'Opslaan mislukt — controleer je verbinding';

  @override
  String get signInToManageNotificationPrefs =>
      'Meld je aan om je meldingsvoorkeuren te beheren.';

  @override
  String get emailWhenAwayTitle => 'E-mail bij afwezigheid';

  @override
  String get emailLevelDescription =>
      'Stuur me een e-mail wanneer ik word geciteerd of beantwoord, wanneer mijn @gebruikersnaam wordt genoemd of wanneer er nieuwe activiteit is in mijn geobserveerde categorieën, tags of topics';

  @override
  String get notificationPrefAlways => 'Altijd';

  @override
  String get notificationPrefOnlyWhenAway => 'Alleen wanneer afwezig';

  @override
  String get notificationPrefNever => 'Nooit';

  @override
  String get emailForMessagesTitle => 'E-mail bij berichten';

  @override
  String get emailMessagesLevelDescription =>
      'Stuur me een e-mail als ik een persoonlijk bericht ontvang';

  @override
  String get activitySummaryTitle => 'Activiteitsamenvatting';

  @override
  String get activitySummaryDescription =>
      'Als ik hier niet kom, stuur me dan een e-mailsamenvatting van populaire topics en antwoorden';

  @override
  String get activitySummaryFrequencyTitle =>
      'Frequentie van de activiteitsamenvatting';

  @override
  String get activitySummaryDaily => 'Dagelijks';

  @override
  String get activitySummaryWeekly => 'Wekelijks';

  @override
  String get activitySummaryMonthly => 'Maandelijks';

  @override
  String get mailingListModeTitle => 'Mailinglijstmodus';

  @override
  String get mailingListModeDescription =>
      'Mail me elk bericht (schakelt de activiteitsamenvatting uit). Niet aanbevolen op drukke forums.';

  @override
  String get likeNotificationFrequencyTitle => 'Melding sturen bij like';

  @override
  String get likeNotificationFirstTimeAndDaily =>
      'Eerste keer dat een bericht wordt geliket en dagelijks';

  @override
  String get likeNotificationFirstTime =>
      'Eerste keer dat een bericht is geliket';

  @override
  String get whenPostingTitle => 'Bij het plaatsen';

  @override
  String get whenPostingDescription =>
      'Wat er gebeurt met een topic waarop je antwoordt';

  @override
  String get whenPostingWatchTopic => 'Topic observeren';

  @override
  String get whenPostingTrackTopic => 'Topic volgen';

  @override
  String get whenPostingDoNothing => 'Niets doen';

  @override
  String get pauseNotificationsUntilTomorrow => 'Tot morgen';

  @override
  String get couldNotEnableDoNotDisturb => 'Kon Niet storen niet inschakelen';

  @override
  String get couldNotTurnOffDoNotDisturb => 'Kon Niet storen niet uitschakelen';

  @override
  String get passwordResetEmailSent =>
      'E-mail om je wachtwoord opnieuw in te stellen is verzonden.';

  @override
  String get couldNotSendResetEmail => 'Kon de herstel-e-mail niet verzenden';

  @override
  String get accountRequestFailed => 'Verzoek mislukt.';

  @override
  String get forumUrlUnavailable => 'De forum-URL is niet beschikbaar.';

  @override
  String get couldNotOpenPreferencesPage =>
      'Kon de voorkeurenpagina niet openen.';

  @override
  String get couldNotOpenForumUrl => 'Kon de forum-URL niet openen.';

  @override
  String get couldNotRequestEmailChange =>
      'Kon de e-mailwijziging niet aanvragen';

  @override
  String get newEmailLabel => 'Nieuw e-mailadres';

  @override
  String get enterAnEmailAddress => 'Voer een e-mailadres in';

  @override
  String get emailLooksInvalid => 'Dat lijkt geen e-mailadres';

  @override
  String get emailNoSpaces => 'Geen spaties in e-mailadressen';

  @override
  String get allowNotificationsSheetTitle => 'Meldingen toestaan';

  @override
  String get notificationsGrantNoPayload =>
      'De toestemming gaf geen antwoord terug.';

  @override
  String get thisForumFallback => 'dit forum';

  @override
  String signInToDomain(String domain) {
    return 'Inloggen bij $domain';
  }

  @override
  String get loginResultTitle => 'Aanmeldresultaat';

  @override
  String get invalidAuthenticationCode => 'Ongeldige authenticatiecode';

  @override
  String get tfaVerificationError =>
      'Er is een fout opgetreden bij de verificatie. Probeer het opnieuw.';

  @override
  String get passwordFieldLabel => 'Wachtwoord';

  @override
  String get somethingWentWrongTryAgain =>
      'Er ging iets mis. Probeer het opnieuw.';

  @override
  String get unexpectedErrorTryAgain =>
      'Er is een onverwachte fout opgetreden. Probeer het opnieuw.';

  @override
  String get errorNoInternetConnection =>
      'Geen internetverbinding. Controleer je netwerkinstellingen.';

  @override
  String get errorRequestTimedOut =>
      'Time-out bij het verzoek. Probeer het opnieuw.';

  @override
  String get errorServerTryLater =>
      'Er is een serverfout opgetreden. Probeer het later opnieuw.';

  @override
  String get errorInvalidCredentials =>
      'Ongeldige gebruikersnaam of wachtwoord.';

  @override
  String get errorSessionExpired =>
      'Je sessie is verlopen. Meld je opnieuw aan.';

  @override
  String get errorAccountSuspended =>
      'Je account is geschorst. Neem contact op met de forumstaf.';

  @override
  String get errorForumNotFound => 'Forum niet gevonden.';

  @override
  String get errorForumAccessDenied =>
      'Je hebt geen toestemming om dit forum te openen.';

  @override
  String get errorForumUnavailable =>
      'Het forum is momenteel niet beschikbaar. Probeer het later opnieuw.';

  @override
  String get errorDataNotFound => 'Opgevraagde gegevens niet gevonden.';

  @override
  String get errorDataCorrupted =>
      'De gegevens lijken beschadigd. Vernieuw de pagina.';

  @override
  String get errorCacheLoadFailed =>
      'Kon gegevens uit de cache niet laden. Probeer het opnieuw.';

  @override
  String errorInvalidField(String field) {
    return 'Ongeldige waarde voor $field.';
  }

  @override
  String errorFieldRequired(String field) {
    return '$field is verplicht.';
  }

  @override
  String errorPermissionDeniedFor(String action) {
    return 'Je hebt geen toestemming voor: $action.';
  }

  @override
  String errorFeatureNotAvailable(String feature) {
    return '$feature is niet beschikbaar op dit forum.';
  }

  @override
  String get errorStorageFull => 'De opslag is vol. Maak wat ruimte vrij.';

  @override
  String get errorStorageAccessDenied =>
      'Toegang tot opslag geweigerd. Controleer de app-machtigingen.';

  @override
  String get errorNetworkTryAgain =>
      'Er is een netwerkfout opgetreden. Probeer het opnieuw.';

  @override
  String get errorAuthenticationTryAgain =>
      'Authenticatie mislukt. Probeer het opnieuw.';

  @override
  String get errorForumTryAgain =>
      'Er is een forumfout opgetreden. Probeer het opnieuw.';

  @override
  String get connectionErrorTitle => 'Verbindingsfout';

  @override
  String get authenticationErrorTitle => 'Authenticatiefout';

  @override
  String get forumErrorTitle => 'Forumfout';

  @override
  String get permissionErrorTitle => 'Toestemmingsfout';

  @override
  String errorRemovingFromMessage(String name) {
    return 'Kon $name niet uit dit bericht verwijderen.';
  }

  @override
  String get chatNewMessage => 'Nieuw bericht';

  @override
  String get chatStarred => 'Favorieten';

  @override
  String get chatBrowseChannels => 'Kanalen bekijken';

  @override
  String get chatBrowseAllChannels => 'Alle kanalen bekijken';

  @override
  String get chatFilterAll => 'Alles';

  @override
  String get chatFilterOpen => 'Open';

  @override
  String get chatFilterClosed => 'Gesloten';

  @override
  String get chatFilterArchived => 'Gearchiveerd';

  @override
  String get chatBrowseSearch => 'Kanaal zoeken op naam';

  @override
  String get chatJoin => 'Deelnemen';

  @override
  String get chatJoined => 'Lid';

  @override
  String get chatLeave => 'Verlaten';

  @override
  String chatMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count leden',
      one: '$count lid',
    );
    return '$_temp0';
  }

  @override
  String get chatYesterday => 'Gisteren';

  @override
  String get chatNoChannelsFound => 'Geen kanalen gevonden';

  @override
  String get chatCloseDm => 'Deze privéchat sluiten';

  @override
  String get chatToday => 'Vandaag';

  @override
  String get chatLastVisit => 'laatste bezoek';

  @override
  String chatNewMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nieuwe berichten',
      one: '$count nieuw bericht',
    );
    return '$_temp0';
  }

  @override
  String get chatScrollToBottom => 'Naar beneden scrollen';

  @override
  String get chatInReplyTo => 'In antwoord op';

  @override
  String get chatCopyText => 'Tekst kopiëren';

  @override
  String get chatTextCopied => 'Tekst gekopieerd naar klembord';

  @override
  String get chatBookmark => 'Bladwijzer maken';

  @override
  String get chatPinMessage => 'Bericht vastmaken';

  @override
  String get chatUnpinMessage => 'Bericht losmaken';

  @override
  String get chatFlag => 'Markeren';

  @override
  String get chatReactWithEmoji => 'Reageren met emoji';

  @override
  String chatReplyingTo(String username) {
    return 'Antwoord aan $username';
  }

  @override
  String get chatEditingMessage => 'Bericht bewerken';

  @override
  String chatTypingOne(String username) {
    return '$username is aan het typen';
  }

  @override
  String chatTypingTwo(String commaSeparatedUsernames, String lastUsername) {
    return '$commaSeparatedUsernames en $lastUsername zijn aan het typen';
  }

  @override
  String chatTypingMany(String commaSeparatedUsernames, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$commaSeparatedUsernames en $count anderen zijn aan het typen',
      one: '$commaSeparatedUsernames en $count ander zijn aan het typen',
    );
    return '$_temp0';
  }

  @override
  String get chatOpenThread => 'Thread openen';

  @override
  String get chatMembers => 'Leden';

  @override
  String get chatAddMember => 'Lid toevoegen';

  @override
  String get chatFindMembers => 'Leden zoeken';

  @override
  String get chatRemoveMember => 'Verwijderen';

  @override
  String get chatNotifyNever => 'Nooit';

  @override
  String get chatNotifyMention => 'Alleen voor vermeldingen';

  @override
  String get chatNotifyAlways => 'Voor alle activiteit';

  @override
  String get chatNotificationLevel => 'Pushmeldingen verzenden';

  @override
  String get chatMuteChannel => 'Kanaal dempen';

  @override
  String get chatStarChannel => 'Kanaal als favoriet markeren';

  @override
  String get chatLeaveChannel => 'Kanaal verlaten';

  @override
  String get chatSearchTitle => 'Chat doorzoeken';

  @override
  String get chatSearchNoResults => 'Geen resultaten gevonden';

  @override
  String get chatMyThreads => 'Mijn threads';

  @override
  String chatThreadReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count antwoorden',
      one: '$count antwoord',
    );
    return '$_temp0';
  }

  @override
  String get chatNoThreads =>
      'Je neemt niet deel aan discussies in dit kanaal.';

  @override
  String get chatGroupName => 'Groepschatnaam (optioneel)';

  @override
  String chatMembersCounter(int count, int max) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count/$max leden',
      one: '$count/$max lid',
    );
    return '$_temp0';
  }

  @override
  String get chatTooManyMembers => 'Maximaal aantal leden bereikt';

  @override
  String get chatThread => 'Thread';

  @override
  String get chatChannelSettings => 'Kanaalinstellingen';

  @override
  String get chatSearchMessagesHint => 'Zoeken in berichten';

  @override
  String get chatMyThreadsEmpty =>
      'Je hebt nog geen threads. Threads waaraan je deelneemt, worden hier weergegeven.';

  @override
  String get chatLeaveGroupInfo =>
      'Als je deze groepschat verlaat, heb je er geen toegang meer toe en ontvang je geen meldingen meer. Om weer deel te kunnen nemen, moet je opnieuw worden uitgenodigd door een lid van de groepschat.';

  @override
  String get chatPlaceholderThread => 'Chat in thread';

  @override
  String get chatLastReply => 'laatste antwoord';

  @override
  String messageListUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ongelezen ($count)',
      one: 'Ongelezen ($count)',
    );
    return '$_temp0';
  }

  @override
  String messageListNewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nieuw ($count)',
      one: 'Nieuw ($count)',
    );
    return '$_temp0';
  }

  @override
  String get messagePersonal => 'Persoonlijk';

  @override
  String messageListIncoming(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nieuwe of bijgewerkte topics weergeven',
      one: '$count nieuw of bijgewerkt topic weergeven',
    );
    return '$_temp0';
  }

  @override
  String get chatPlaceholderGroup => 'Chatten in groep';

  @override
  String get notificationAccountMismatch =>
      'Deze melding kan niet worden geopend met het huidige account. Open Meldingen om updates voor dit account te bekijken.';
}
