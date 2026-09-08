// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Forum App';

  @override
  String get loginTitle => 'Inloggen';

  @override
  String get usernameLabel => 'Gebruikersnaam';

  @override
  String get passwordLabel => 'Wachtwoord';

  @override
  String get loginButton => 'Inloggen';

  @override
  String get signInWithPasskey => 'Sign in with Passkey';

  @override
  String get usePasskey => 'Use Passkey';

  @override
  String get passkeyContinuePrompt => 'Use your passkey to continue';

  @override
  String get forgotPassword => 'Wachtwoord vergeten?';

  @override
  String get pleaseEnterUsername => 'Voer uw gebruikersnaam in';

  @override
  String get pleaseEnterPassword => 'Voer uw wachtwoord in';

  @override
  String credentialsSentToDomain(String domain) {
    return 'Uw gebruikersnaam en wachtwoord worden naar $domain gestuurd';
  }

  @override
  String get createAccount => 'Account aanmaken';

  @override
  String get alreadyHaveAccount => 'Heeft u al een account? ';

  @override
  String get logIn => 'Inloggen';

  @override
  String get continueButton => 'Doorgaan';

  @override
  String get registrationNotAvailable => 'Registratie niet beschikbaar';

  @override
  String get registrationNotAvailableMessage =>
      'Registratie is momenteel niet beschikbaar. Het forum kan gesloten zijn of registratie kan zijn uitgeschakeld.';

  @override
  String get webRegistrationRequired => 'Webregistratie vereist';

  @override
  String get webRegistrationRequiredMessage =>
      'Dit forum vereist registratie via de webbrowser. Klik op de knop hieronder om de registratiepagina te openen.';

  @override
  String get openRegistrationPage => 'Registratiepagina openen';

  @override
  String get loadingAdditionalFields => 'Extra velden laden...';

  @override
  String get pleaseSelectDateOfBirth => 'Selecteer uw geboortedatum';

  @override
  String get pleaseEnterLocation => 'Voer uw locatie in';

  @override
  String get pleaseIndicateEmailPreference => 'Geef uw e-mailvoorkeur op';

  @override
  String get pleaseFillAllRequiredFields => 'Vul alle verplichte velden in';

  @override
  String get pleaseAcceptTermsOfService => 'Accepteer de servicevoorwaarden';

  @override
  String get pleaseAcceptPrivacyPolicy => 'Accepteer het privacybeleid';

  @override
  String get registrationError => 'Registratiefout';

  @override
  String get registrationFailed =>
      'Registratie mislukt. Controleer uw gegevens.';

  @override
  String get registrationFailedTryAgain =>
      'Registratie mislukt. Probeer het opnieuw.';

  @override
  String get registrationInfo => 'Registratiegegevens';

  @override
  String get openWebsite => 'Website openen';

  @override
  String couldNotOpenForumWebsite(String url) {
    return 'Kon de forumwebsite niet openen. Probeer: $url';
  }

  @override
  String get registrationSuccessfulEmailConfirm =>
      'Registratie geslaagd! Controleer uw e-mail om uw account te bevestigen voordat u inlogt.';

  @override
  String get registrationSuccessfulPendingApproval =>
      'Registratie geslaagd! Uw account wacht op goedkeuring. U wordt op de hoogte gesteld wanneer uw account is goedgekeurd.';

  @override
  String get registrationSuccessfulAutoLogin =>
      'Registratie geslaagd! U bent automatisch ingelogd.';

  @override
  String get welcome => 'Welkom!';

  @override
  String get registrationSuccessful => 'Registratie geslaagd';

  @override
  String get pleaseLoginWithNewAccount => 'Log in met uw nieuwe account.';

  @override
  String get forgotPasswordTitle => 'Wachtwoord vergeten';

  @override
  String get usernameOrEmailLabel => 'Gebruikersnaam of e-mail';

  @override
  String get pleaseEnterUsernameOrEmail =>
      'Voer uw gebruikersnaam of e-mail in';

  @override
  String get sendResetLink => 'Resetlink verzenden';

  @override
  String get resetLinkSent => 'Resetlink verzonden';

  @override
  String get passwordResetInstructionsSent =>
      'Instructies voor het resetten van uw wachtwoord zijn naar uw geregistreerde e-mailadres gestuurd.';

  @override
  String get resetFailed => 'Reset mislukt';

  @override
  String get unableToSendResetLink =>
      'Kon resetlink niet verzenden. Probeer het opnieuw.';

  @override
  String get errorSendingResetLink =>
      'Er is een fout opgetreden bij het verzenden van de resetlink. Controleer uw verbinding en probeer het opnieuw.';

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
  String get getHelp => 'Hulp krijgen';

  @override
  String get somethingWentWrong => 'Er is iets misgegaan';

  @override
  String get unexpectedErrorOccurred =>
      'Er is een onverwachte fout opgetreden. Probeer het opnieuw.';

  @override
  String get noInternetConnection => 'Geen internetverbinding';

  @override
  String get checkInternetConnection =>
      'Controleer uw internetverbinding en probeer het opnieuw.';

  @override
  String get authenticationRequired => 'Authenticatie vereist';

  @override
  String get pleaseLoginToContinue => 'Log in om door te gaan.';

  @override
  String get forumError => 'Forumfout';

  @override
  String get anErrorOccurred => 'Er is een fout opgetreden';

  @override
  String get accountPendingApproval =>
      'Uw account wacht op goedkeuring. U kunt het forum bekijken maar niet posten tot een moderator uw account goedkeurt.';

  @override
  String get checkEmailToConfirm =>
      'Controleer uw e-mail om uw account te bevestigen. Klik op de bevestigingslink in de e-mail die we u hebben gestuurd.';

  @override
  String get checkNewEmailToConfirm =>
      'Controleer uw nieuwe e-mailadres om de wijziging te bevestigen. Uw oude e-mail blijft actief tot u de nieuwe bevestigt.';

  @override
  String get emailAddressInvalid =>
      'Uw e-mailadres lijkt ongeldig of weigert e-mails. Werk uw e-mailadres bij in de accountinstellingen.';

  @override
  String get accountDisabled =>
      'Uw account is uitgeschakeld. Neem contact op met een beheerder voor hulp.';

  @override
  String get accountRegistrationRejected =>
      'Uw registratie is afgewezen. Neem contact op met een beheerder voor meer informatie.';

  @override
  String get welcomeToForumCopilot => 'Welkom bij Forum Copilot!';

  @override
  String get successfullyLoggedOut => 'U bent succesvol uitgelogd';

  @override
  String get accountStatusRequiresAttention =>
      'Uw accountstatus vereist aandacht. Neem contact op met een beheerder bij vragen.';

  @override
  String get updateEmail => 'E-mail bijwerken';

  @override
  String get resend => 'Opnieuw verzenden';

  @override
  String get noLatestTopics => 'Geen nieuwste onderwerpen';

  @override
  String get noRecentTopicsToDisplay =>
      'Er zijn geen recente onderwerpen om weer te geven. Kom later terug voor nieuwe discussies.';

  @override
  String get signInToViewLatestTopics =>
      'Log in om nieuwste onderwerpen te bekijken';

  @override
  String get youNeedToBeSignedInToViewLatestTopics =>
      'U moet ingelogd zijn om nieuwste onderwerpen te bekijken.';

  @override
  String get noUnreadTopics => 'Geen ongelezen onderwerpen';

  @override
  String get thereAreNoUnreadTopics =>
      'Er zijn geen ongelezen onderwerpen. Kom later terug voor nieuwe discussies.';

  @override
  String get youAreAllCaughtUp => 'U bent helemaal bij!';

  @override
  String get signInToViewUnreadTopics =>
      'Log in om ongelezen onderwerpen te bekijken';

  @override
  String get youNeedToBeSignedInToViewUnreadTopics =>
      'U moet ingelogd zijn om uw ongelezen onderwerpen te bekijken.';

  @override
  String get noSubscribedTopics => 'Geen geabonneerde onderwerpen';

  @override
  String get noSubscribedTopicsMessage =>
      'U heeft zich op geen onderwerpen geabonneerd. Tik op de ster bij een onderwerp om te abonneren en meldingen te ontvangen.';

  @override
  String get signInToViewSubscribedTopics =>
      'Log in om geabonneerde onderwerpen te bekijken';

  @override
  String get youNeedToBeSignedInToViewSubscribedTopics =>
      'U moet ingelogd zijn om uw geabonneerde onderwerpen te bekijken.';

  @override
  String get noParticipatedTopics =>
      'Geen onderwerpen waaraan u hebt deelgenomen';

  @override
  String get topicsYouParticipatedIn =>
      'Onderwerpen waaraan u hebt deelgenomen worden hier getoond.';

  @override
  String get signInToViewParticipatedTopics =>
      'Log in om onderwerpen waaraan u hebt deelgenomen te bekijken';

  @override
  String get youNeedToBeSignedInToViewParticipatedTopics =>
      'U moet ingelogd zijn om onderwerpen waaraan u hebt deelgenomen te bekijken.';

  @override
  String get latest => 'Nieuwste';

  @override
  String get unread => 'Ongelezen';

  @override
  String get subscribed => 'Geabonneerd';

  @override
  String get participated => 'Deelgenomen';

  @override
  String get connectionTimedOut =>
      'Verbinding time-out. De site kan offline of onbereikbaar zijn.';

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
  String get newConversation => 'Nieuw gesprek';

  @override
  String get newMessage => 'Nieuw bericht';

  @override
  String get appSettings => 'App-instellingen';

  @override
  String get searchSites => 'Sites zoeken';

  @override
  String get language => 'Taal';

  @override
  String get systemDefault => 'Systeemstandaard';

  @override
  String get followSystemLanguage => 'Systeemtaal volgen';

  @override
  String get all => 'Alles';

  @override
  String get topicsOnly => 'Alleen onderwerpen';

  @override
  String get titlesOnly => 'Alleen titels';

  @override
  String failedToShareTopic(String error) {
    return 'Kon onderwerp niet delen: $error';
  }

  @override
  String get pleaseLoginToSubscribe => 'Log in om null dit onderwerp';

  @override
  String get subscribe => 'Abonneren';

  @override
  String get unsubscribe => 'Afmelden';

  @override
  String get failedToSubscribeToThread => 'Kon null onderwerp niet';

  @override
  String get youCannotReplyToThisThread =>
      'U kunt niet op dit onderwerp reageren';

  @override
  String get pleaseWaitForThreadToLoad => 'Wacht tot het onderwerp is geladen';

  @override
  String get softDelete => 'Zacht verwijderen';

  @override
  String get postCanBeRestoredLater => 'Bericht kan later worden hersteld';

  @override
  String get hardDelete => 'Definitief verwijderen';

  @override
  String get postWillBePermanentlyDeleted =>
      'Bericht wordt permanent verwijderd';

  @override
  String get reasonForDeletion => 'Reden voor verwijdering';

  @override
  String get enterReasonForDeletingPost =>
      'Voer de reden voor het verwijderen van dit bericht in';

  @override
  String get pleaseEnterReasonForDeletion =>
      'Voer een reden voor verwijdering in';

  @override
  String get reportPost => 'Bericht melden';

  @override
  String get pleaseProvideReasonForReporting =>
      'Geef een reden op voor het melden van dit bericht.';

  @override
  String get reason => 'Reden';

  @override
  String get enterReasonForReportingPost =>
      'Voer de reden voor het melden van dit bericht in';

  @override
  String get pleaseEnterReason => 'Voer een reden in';

  @override
  String get submitReport => 'Melding verzenden';

  @override
  String get selectedActions => 'Geselecteerde acties:';

  @override
  String get thisActionCannotBeUndone =>
      'Deze actie kan niet ongedaan worden gemaakt.';

  @override
  String get participantsLabel => 'Deelnemers';

  @override
  String usernameHasBeenInvited(String username) {
    return '$username is uitgenodigd voor het gesprek';
  }

  @override
  String errorInvitingUser(String error) {
    return 'Fout bij uitnodigen van gebruiker: $error';
  }

  @override
  String get newTopic => 'Nieuw onderwerp';

  @override
  String get markRead => 'Als gelezen markeren';

  @override
  String get reportUser => 'Gebruiker melden';

  @override
  String get pleaseSelectReasonForReportingUser =>
      'Selecteer een reden voor het melden van deze gebruiker.';

  @override
  String get spamOrAdvertising => 'Spam of reclame';

  @override
  String get harassmentOrBullying => 'Intimidatie of pesten';

  @override
  String get inappropriateContent => 'Ongepaste inhoud';

  @override
  String get impersonationOrFakeAccount => 'Impersonatie of nepaccount';

  @override
  String get otherPleaseSpecify => 'Anders (geef op)';

  @override
  String get pleaseSpecifyReason => 'Geef de reden op';

  @override
  String get enterReasonForReportingUser =>
      'Voer de reden voor het melden van deze gebruiker in';

  @override
  String get pleaseSelectReason => 'Selecteer een reden';

  @override
  String get banUser => 'Gebruiker blokkeren';

  @override
  String get unbanUser => 'Blokkering opheffen';

  @override
  String pleaseSelectReasonForBanningUser(String username) {
    return 'Selecteer een reden voor het blokkeren van $username';
  }

  @override
  String get violationOfCommunityGuidelines =>
      'Overtreding van de communityrichtlijnen';

  @override
  String get harassmentOrAbusiveBehavior => 'Intimidatie of misbruik';

  @override
  String get postingInappropriateContent => 'Plaatsen van ongepaste inhoud';

  @override
  String get accountCompromiseOrSecurityIssue =>
      'Accountcompromittering of beveiligingsprobleem';

  @override
  String get enterReasonForBanningUser =>
      'Voer de reden voor het blokkeren van deze gebruiker in';

  @override
  String get banUntil => 'Blokkeren tot';

  @override
  String get selectDate => 'Selecteer datum';

  @override
  String get moreOptions => 'Meer opties';

  @override
  String get leaveConversation => 'Gesprek verlaten';

  @override
  String get reportConversation => 'Gesprek melden';

  @override
  String get topicClosed => 'Onderwerp gesloten';

  @override
  String get topicOpened => 'Onderwerp geopend';

  @override
  String get topicStickied => 'Onderwerp vastgezet';

  @override
  String get topicUnstickied => 'Onderwerp losgemaakt';

  @override
  String cannotEditMessage(String error) {
    return 'Dit bericht kan niet worden bewerkt: $error';
  }

  @override
  String get confirmSpamClean => 'Spam opruimen bevestigen';

  @override
  String get handleThreads => 'Onderwerpen afhandelen';

  @override
  String get deleteMessages => 'Berichten verwijderen';

  @override
  String get deleteConversations => 'Gesprekken verwijderen';

  @override
  String get myForums => 'Mijn forums';

  @override
  String get recentlyVisited => 'Recent bezocht';

  @override
  String get explore => 'Ontdekken';

  @override
  String get forumCopilot => 'Forum Copilot';

  @override
  String get noConversations => 'Geen gesprekken';

  @override
  String get noConversationsMessage =>
      'U heeft nog geen gesprekken. Start een nieuw gesprek om te beginnen.';

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
  String get spamCleaner => 'Spam opruimer';

  @override
  String get sendMessage => 'Bericht verzenden';

  @override
  String get memberSince => 'Lid sinds';

  @override
  String get lastActivity => 'Laatste activiteit';

  @override
  String get likesReceived => 'Ontvangen likes';

  @override
  String get likesGiven => 'Gegeven likes';

  @override
  String get showMore => 'Meer tonen';

  @override
  String get cleanSpam => 'Spam opruimen';

  @override
  String get failedToSaveMessage => 'Kon bericht niet opslaan';

  @override
  String get failedToSaveConversation => 'Kon gesprek niet opslaan';

  @override
  String get failedToSaveSetting => 'Kon instelling niet opslaan';

  @override
  String get failedToSavePost => 'Kon bericht niet opslaan';

  @override
  String errorLoadingSites(String error) {
    return 'Fout bij laden van sites: $error';
  }

  @override
  String connectingTo(String domainName) {
    return 'Verbinden met $domainName...';
  }

  @override
  String get members => 'Leden';

  @override
  String get allMembers => 'Alle leden';

  @override
  String get online => 'Online';

  @override
  String get noMembersFound => 'Geen leden gevonden';

  @override
  String get searchForMembers => 'Leden zoeken';

  @override
  String get enterUsernameToFindMembers =>
      'Voer een gebruikersnaam in om forumleden te vinden';

  @override
  String get noMembersOnline => 'Er zijn momenteel geen leden online';

  @override
  String get enterUsernameToSearch => 'Voer gebruikersnaam in om te zoeken...';

  @override
  String get lookupMembers => 'Leden opzoeken';

  @override
  String get addMembers => 'Leden toevoegen';

  @override
  String get membersAddedSuccessfully => 'Leden succesvol toegevoegd';

  @override
  String errorAddingMembers(String error) {
    return 'Fout bij toevoegen van leden: $error';
  }

  @override
  String get failedToLoadOnlineUsers => 'Kon online gebruikers niet laden';

  @override
  String get noUsersOnline => 'Geen gebruikers online';

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
  String get areYouSureYouWantToLogout => 'Weet u zeker dat u wilt uitloggen?';

  @override
  String get register => 'Registreren';

  @override
  String get signIn => 'Inloggen';

  @override
  String get markForumRead => 'Forum als gelezen markeren';

  @override
  String get notificationTest => 'Meldingstest';

  @override
  String get forum => 'Forum';

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
  String get areYouSureYouWantToDeleteThisMessage =>
      'Weet u zeker dat u dit bericht wilt verwijderen?';

  @override
  String failedToDeleteMessage(String error) {
    return 'Kon bericht niet verwijderen: $error';
  }

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
  String failedToThankPost(String error) {
    return 'Kon bericht niet bedanken: $error';
  }

  @override
  String get signInToViewMessages => 'Log in om berichten te bekijken';

  @override
  String get youNeedToBeSignedInToViewConversations =>
      'U moet ingelogd zijn om uw gesprekken te bekijken.';

  @override
  String errorLoadingConversations(String error) {
    return 'Fout bij laden van gesprekken: $error';
  }

  @override
  String failedToLeaveConversation(String error) {
    return 'Kon gesprek niet verlaten: $error';
  }

  @override
  String errorLoadingMoreConversations(String error) {
    return 'Fout bij laden van meer gesprekken: $error';
  }

  @override
  String errorLoadingMoreMessages(String error) {
    return 'Fout bij laden van meer berichten: $error';
  }

  @override
  String get inviteMessageOptional => 'Uitnodigingsbericht (optioneel)';

  @override
  String get iWouldLikeToAddYouToThisConversation =>
      'Ik wil u aan dit gesprek toevoegen.';

  @override
  String get searchFailed => 'Zoeken mislukt';

  @override
  String get trySearchingWithDifferentUsername =>
      'Probeer te zoeken met een andere gebruikersnaam';

  @override
  String get noSitesFound => 'Geen sites gevonden.';

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
  String get permanent => 'Permanent';

  @override
  String get temporary => 'Tijdelijk';

  @override
  String setBanDurationFor(String username) {
    return 'Stel de blokkeerduur in voor $username';
  }

  @override
  String get pleaseSelectEndDateForTemporaryBan =>
      'Selecteer een einddatum voor tijdelijke blokkering';

  @override
  String get back => 'Terug';

  @override
  String get unban => 'Blokkering opheffen';

  @override
  String get confirm => 'Bevestigen';

  @override
  String spamClean(String username) {
    return 'Spam opruimen $username';
  }

  @override
  String get selectActionsToPerform => 'Selecteer de uit te voeren acties:';

  @override
  String get moveOrDeleteThreadsBasedOnAdminSettings =>
      'Verplaats of verwijder onderwerpen op basis van beheerderinstellingen';

  @override
  String get messageUpdatedSuccessfully => 'Bericht succesvol bijgewerkt';

  @override
  String error(String error) {
    return 'Fout: $error';
  }

  @override
  String failedToRemoveAttachment(String error) {
    return 'Kon bijlage niet verwijderen: $error';
  }

  @override
  String failedToLoadMessage(String error) {
    return 'Kon bericht niet laden: $error';
  }

  @override
  String get editMessage => 'Bericht bewerken';

  @override
  String get removeAttachment => 'Bijlage verwijderen';

  @override
  String get areYouSureYouWantToRemoveThisAttachment =>
      'Weet u zeker dat u deze bijlage wilt verwijderen?';

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
  String get markAsUnread => 'Als ongelezen markeren';

  @override
  String get invite => 'Uitnodigen';

  @override
  String get welcomeBack => 'Welkom terug';

  @override
  String get signInToAccessYourProfile =>
      'Log in om uw profiel te openen en uw account te beheren';

  @override
  String get enterYourUsername => 'Voer uw gebruikersnaam in';

  @override
  String get enterYourPassword => 'Voer uw wachtwoord in';

  @override
  String get dontHaveAnAccount => 'Heeft u geen account?';

  @override
  String get enterKeywordsToSearchTopics =>
      'Voer zoekwoorden in om onderwerpen te zoeken...';

  @override
  String get pleaseFillInAllRequiredFields => 'Vul alle verplichte velden in';

  @override
  String get undelete => 'Verwijdering ongedaan maken';

  @override
  String get refresh => 'Vernieuwen';

  @override
  String get share => 'Delen';

  @override
  String get viewOnWeb => 'Bekijken op web';

  @override
  String get unlock => 'Ontgrendelen';

  @override
  String get lock => 'Vergrendelen';

  @override
  String get stick => 'Vastzetten';

  @override
  String get unstick => 'Losmaken';

  @override
  String get reply => 'Beantwoorden';

  @override
  String get vote => 'Stemmen';

  @override
  String votesCount(int count) {
    return '$count stemmen';
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
      'Voer zoekwoorden in om onderwerpen en berichten te vinden';

  @override
  String get enterKeywordsOrDomainToFindForums =>
      'Voer zoekwoorden of domein in om forums te vinden';

  @override
  String get enterKeywordsOrDomainNamesToFindForums =>
      'Voer zoekwoorden of domeinnamen in om forums te vinden';

  @override
  String get appearance => 'Weergave';

  @override
  String get followSystemTheme => 'Systeemthema volgen';

  @override
  String get light => 'Licht';

  @override
  String get dark => 'Donker';

  @override
  String version(String version, String buildNumber) {
    return 'versie $version ($buildNumber)';
  }

  @override
  String get forumSettings => 'Foruminstellingen';

  @override
  String get noSettingsAvailable => 'Geen instellingen beschikbaar';

  @override
  String get settingsCategoriesWillAppearHere =>
      'Instellingcategorieën verschijnen hier wanneer beschikbaar.';

  @override
  String get unableToLoadProfile => 'Kon profiel niet laden';

  @override
  String get banned => 'GEBLOKKEERD';

  @override
  String get reportSubmittedSuccessfully => 'Melding succesvol verzonden';

  @override
  String get failedToSubmitReport => 'Kon melding niet verzenden';

  @override
  String get searchForForums => 'Forums zoeken';

  @override
  String get searchForums => 'Forums zoeken';

  @override
  String get deleteTopic => 'Onderwerp verwijderen';

  @override
  String get topicCanBeRestoredLater => 'Onderwerp kan later worden hersteld';

  @override
  String get topicWillBePermanentlyDeleted =>
      'Onderwerp wordt permanent verwijderd';

  @override
  String get enterReasonForDeletingTopic =>
      'Voer de reden voor het verwijderen van dit onderwerp in';

  @override
  String get pleaseSelectEndDate => 'Selecteer een einddatum';

  @override
  String get userBannedSuccessfully => 'Gebruiker succesvol geblokkeerd';

  @override
  String get failedToBanUser => 'Kon gebruiker niet blokkeren';

  @override
  String get userUnbannedSuccessfully => 'Gebruiker succesvol gedeblokkeerd';

  @override
  String get failedToUnbanUser => 'Kon blokkering niet opheffen';

  @override
  String get spamCleanUser => 'Spam opruimen gebruiker';

  @override
  String get deletePrivateConversations => 'Privégesprekken verwijderen';

  @override
  String get banTheUserAccount => 'Gebruikersaccount blokkeren';

  @override
  String get handledThreads => 'Onderwerpen afgehandeld';

  @override
  String get deletedMessages => 'Berichten verwijderd';

  @override
  String get deletedConversations => 'Gesprekken verwijderd';

  @override
  String get bannedUser => 'Gebruiker geblokkeerd';

  @override
  String successfullyCleanedSpam(String username, String actions) {
    return 'Spam succesvol opgeruimd voor $username. Acties: $actions';
  }

  @override
  String errorLoadingMessage(String error) {
    return 'Fout bij laden van bericht: $error';
  }

  @override
  String get messageNotFound => 'Bericht niet gevonden';

  @override
  String get home => 'Start';

  @override
  String get notifications => 'Meldingen';

  @override
  String get forums => 'Forums';

  @override
  String get markAllForumsAsRead => 'Alle forums als gelezen markeren?';

  @override
  String get markAllForumsAsReadMessage =>
      'Dit markeert alle forums en onderwerpen als gelezen. Deze actie kan niet ongedaan worden gemaakt.';

  @override
  String get markAsRead => 'Als gelezen markeren';

  @override
  String get content => 'Inhoud';

  @override
  String get insertImage => 'Afbeelding invoegen';

  @override
  String get howWouldYouLikeToInsertImage =>
      'Hoe wilt u deze afbeelding invoegen?';

  @override
  String get thumbnail => 'Miniatuur';

  @override
  String get fullSize => 'Volledige grootte';

  @override
  String get alignLeft => 'Links uitlijnen';

  @override
  String get alignCenter => 'Centreren';

  @override
  String get alignRight => 'Rechts uitlijnen';

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
  String get loggingIn => 'Inloggen...';

  @override
  String get submittingReport => 'Melding verzenden...';

  @override
  String get banningUser => 'Gebruiker blokkeren...';

  @override
  String get unbanningUser => 'Blokkering opheffen...';

  @override
  String get cleaningSpam => 'Spam opruimen...';

  @override
  String get enterSubject => 'Voer onderwerp in';

  @override
  String get typeYourMessageHere => 'Typ hier uw bericht';

  @override
  String get writeYourMessage => 'Schrijf uw bericht...';

  @override
  String get writeYourReply => 'Schrijf uw antwoord...';

  @override
  String get messageSentSuccessfully => 'Bericht succesvol verzonden';

  @override
  String get replySentSuccessfully => 'Antwoord succesvol verzonden';

  @override
  String get conversationCreatedSuccessfully => 'Gesprek succesvol aangemaakt';

  @override
  String get conversationMarkedAsUnread => 'Gesprek als ongelezen gemarkeerd';

  @override
  String get messageMarkedAsUnread => 'Bericht als ongelezen gemarkeerd';

  @override
  String get conversationClosed => 'Gesprek gesloten';

  @override
  String get conversationOpened => 'Gesprek geopend';

  @override
  String get pleaseLoginToLikeMessages => 'Log in om berichten te liken';

  @override
  String get loadEarlierMessages => 'Eerdere berichten laden';

  @override
  String failedToLoadQuote(String error) {
    return 'Failed to load quote: \n$error';
  }

  @override
  String failedToUploadFile(String error) {
    return 'Kon bestand niet uploaden: $error';
  }

  @override
  String failedToUploadImage(String error) {
    return 'Kon afbeelding niet uploaden: $error';
  }

  @override
  String failedToSendMessage(String error) {
    return 'Kon bericht niet verzenden: $error';
  }

  @override
  String failedToSendReply(String error) {
    return 'Kon antwoord niet verzenden: $error';
  }

  @override
  String failedToMarkAsUnread(String error) {
    return 'Kon bericht niet als ongelezen markeren: $error';
  }

  @override
  String failedToMarkConversationAsUnread(String error) {
    return 'Kon gesprek niet als ongelezen markeren: $error';
  }

  @override
  String failedToCloseConversation(String error) {
    return 'Kon gesprek niet sluiten: $error';
  }

  @override
  String failedToOpenConversation(String error) {
    return 'Kon gesprek niet openen: $error';
  }

  @override
  String failedToJumpToMessage(String error) {
    return 'Kon niet naar bericht springen: $error';
  }

  @override
  String get goToTop => 'Naar boven';

  @override
  String get goToBottom => 'Naar beneden';

  @override
  String get replyAll => 'Allen beantwoorden';

  @override
  String get forward => 'Doorsturen';

  @override
  String get noForumsFound => 'Geen forums gevonden.';

  @override
  String get pleaseLoginToAccessContent =>
      'Log in om deze inhoud te bekijken en te reageren op berichten.';

  @override
  String get searchUsers => 'Gebruikers zoeken...';

  @override
  String get writeYourTitle => 'Schrijf uw titel...';

  @override
  String get writeYourContent => 'Schrijf uw inhoud...';

  @override
  String get selectAnOption => 'Selecteer een optie';

  @override
  String get enterConversationTitle => 'Voer gesprekstitel in';

  @override
  String enterCode(int count) {
    return 'Voer $count-cijferige code in';
  }

  @override
  String get edit => 'Bewerken';

  @override
  String get report => 'Melden';

  @override
  String get unfollow => 'Ontvolgen';

  @override
  String get follow => 'Volgen';

  @override
  String get goToForums => 'Naar forums';

  @override
  String get remove => 'Verwijderen';

  @override
  String get subject => 'Onderwerp';

  @override
  String get message => 'Bericht';

  @override
  String get titleCannotBeEmpty => 'Titel mag niet leeg zijn';

  @override
  String get conversationUpdatedSuccessfully => 'Gesprek succesvol bijgewerkt';

  @override
  String get goBack => 'Terug';

  @override
  String get privateMessagesNotAvailable => 'Privéberichten niet beschikbaar';

  @override
  String failedToLoadPost(String error) {
    return 'Failed to load post: \n$error';
  }

  @override
  String failedToLikeOrUnlikeMessage(String action, String error) {
    return 'Kon bericht niet $action: $error';
  }

  @override
  String get like => 'liken';

  @override
  String get unlike => 'unliken';

  @override
  String get optimizeImage => 'Afbeelding optimaliseren';

  @override
  String get optimizeAndUpload => 'Optimaliseren en uploaden';

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
  String get enterANumber => 'Voer een getal in';

  @override
  String get failedToNavigateToForum => 'Kon niet naar forum navigeren';

  @override
  String failedToNavigateToForumName(String forumName) {
    return 'Kon niet navigeren naar $forumName';
  }

  @override
  String forumNotFound(String forumName) {
    return 'Forum niet gevonden: $forumName';
  }

  @override
  String forumNotFoundById(String forumId) {
    return 'Forum niet gevonden: $forumId';
  }

  @override
  String couldNotOpenLink(String error) {
    return 'Kon link niet openen: $error';
  }

  @override
  String get likePost => 'Bericht liken';

  @override
  String get unlikePost => 'Bericht unliken';

  @override
  String get thankPost => 'Bericht bedanken';

  @override
  String get showLikes => 'Likes tonen';

  @override
  String get showThanks => 'Bedankingen tonen';

  @override
  String get quotePost => 'Bericht citeren';

  @override
  String get translate => 'Vertalen';

  @override
  String get showOriginal => 'Origineel tonen';

  @override
  String get translating => 'Vertalen...';

  @override
  String get translated => 'Vertaald';

  @override
  String get translatedContent => 'Vertaalde inhoud';

  @override
  String get selectLanguage => 'Taal selecteren';

  @override
  String get translateTo => 'Vertalen naar:';

  @override
  String get deviceLanguage => 'Apparaattaal';

  @override
  String get noPostsToTranslate => 'Geen berichten om te vertalen';

  @override
  String get translationFailed => 'Vertalen mislukt';

  @override
  String get twoFactorAuthentication => 'Tweefactorauthenticatie';

  @override
  String get authenticationCodeLabel => 'Authenticatiecode';

  @override
  String get pleaseEnterYourAuthenticationCode =>
      'Voer uw authenticatiecode in';

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
  String nVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stemmen',
      one: '1 stem',
    );
    return '$_temp0';
  }

  @override
  String get lastSeen => 'Gezien';

  @override
  String get chat => 'Chat';

  @override
  String comingSoon(String label) {
    return '$label — binnenkort';
  }

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
  String get discardDraftQuestion => 'Concept verwerpen?';

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
      'Meer onderwerpen laden mislukt. Scroll om opnieuw te proberen.';

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
  String get mergeIntoTopic => 'Samenvoegen in onderwerp';

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
  String get renameTopic => 'Onderwerp hernoemen';

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
  String get retryConnection => 'Verbinding opnieuw proberen';

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
  String get signOutQuestion => 'Afmelden?';

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
  String get submit => 'Verzenden';

  @override
  String get discardDraftWarning =>
      'Het opgeslagen concept wordt permanent verwijderd.';

  @override
  String get deleteChatMessageWarning =>
      'Het bericht wordt voor iedereen verwijderd.';

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
  String get additionalInformation => 'Aanvullende informatie';

  @override
  String dateOfBirth(Object marker) {
    return 'Geboortedatum$marker';
  }

  @override
  String minimumAgeYears(Object minimumAge) {
    return 'Minimumleeftijd: $minimumAge jaar';
  }

  @override
  String locationLabel(Object marker) {
    return 'Locatie$marker';
  }

  @override
  String get receiveSiteMailings => 'Site-mailings ontvangen';

  @override
  String get moveToCategory => 'Verplaatsen naar categorie';

  @override
  String get undeleteTopic => 'Onderwerp herstellen';

  @override
  String get undeleteTopicConfirmation =>
      'Weet je zeker dat je dit onderwerp wilt herstellen? Het wordt weer zichtbaar voor andere gebruikers.';

  @override
  String get send => 'Verzenden';

  @override
  String get changeEmailExplanation =>
      'We sturen een bevestigingslink naar je nieuwe e-mailadres. De wijziging gaat in zodra je erop klikt.';

  @override
  String get changeEmailSecurityNote =>
      'Voor extra veiligheid kan Discourse vragen om bevestiging via de link in de e-mail. Controleer je spammap als je hem niet ziet.';

  @override
  String get newDirectMessage => 'Nieuw direct bericht';

  @override
  String get noMessagesYetSayHi => 'Nog geen berichten — zeg hallo.';

  @override
  String get edited => 'bewerkt';

  @override
  String get imageExceedsUploadLimits =>
      'Deze afbeelding overschrijdt de uploadlimieten en moet worden geoptimaliseerd:';

  @override
  String get optimizationsToBeApplied => 'Toe te passen optimalisaties:';

  @override
  String reductionPercent(Object percent) {
    return 'Reductie: $percent%';
  }

  @override
  String get editProfileManagedOnWebNote =>
      'Weergavenaam, e-mail, wachtwoord en andere accountinstellingen beheer je onder Account → Account beheren op het web. Je avatar wijzig je door op het camerapictogram op je foto te tikken.';

  @override
  String get approvedButRelayUnreachable =>
      'Goedgekeurd, maar ForumCopilot was niet bereikbaar om de installatie af te ronden. Probeer het later opnieuw via Instellingen.';

  @override
  String get notificationsAreTurnedOffForThisApp =>
      'Meldingen zijn uitgeschakeld voor deze app';

  @override
  String forumWillAskToApproveNotifications(Object forumName) {
    return 'Hierna vraagt $forumName je om \"Meldingen\" goed te keuren.';
  }

  @override
  String get approveNotificationsExplanation =>
      'Door goed te keuren mogen we je meldingen ophalen en naar dit apparaat sturen. Deze toestemming kan niet posten, reageren of je berichten lezen.';

  @override
  String get forumOwnerPushNote =>
      'Als de eigenaar van dit forum meldingen voor de app instelt, is deze stap niet nodig.';

  @override
  String get pleaseLoginToCreateANewTopic =>
      'Meld je aan om een nieuw onderwerp te maken';

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
  String get protected => 'Beveiligd';

  @override
  String get solution => 'Oplossing';

  @override
  String get deleted => 'VERWIJDERD';

  @override
  String get pleaseLoginToViewUserProfiles =>
      'Meld je aan om gebruikersprofielen te bekijken.';

  @override
  String get announcement => 'Aankondiging';

  @override
  String get solved => 'Opgelost';

  @override
  String get hot => 'Populair';

  @override
  String get pinned => 'Vastgezet';

  @override
  String get subscribedLabel => 'Geabonneerd';

  @override
  String get locked => 'Vergrendeld';

  @override
  String get poll => 'Peiling';

  @override
  String errorLoadingContent(Object error) {
    return 'Fout bij laden van inhoud: $error';
  }

  @override
  String get noPermissionToViewSubforum =>
      'Je hebt geen toestemming om onderwerpen in dit subforum te bekijken.';

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
  String get topicDeletedBanner =>
      'Dit onderwerp is verwijderd en verborgen voor andere gebruikers';

  @override
  String get topicClosedBanner =>
      'Dit onderwerp is gesloten en accepteert geen reacties meer';

  @override
  String get topicPinnedBanner =>
      'Dit onderwerp is bovenaan het forum vastgezet';

  @override
  String get youAreSubscribedToThisTopic =>
      'Je bent geabonneerd op dit onderwerp';

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
  String get editConversation => 'Gesprek bewerken';

  @override
  String get closeConversation => 'Gesprek sluiten';

  @override
  String get openConversation => 'Gesprek openen';

  @override
  String get leaveConversation2 => 'Gesprek verlaten';

  @override
  String get reportConversation2 => 'Gesprek melden';

  @override
  String get closeConversation2 => 'Gesprek sluiten';

  @override
  String get closeConversationConfirmation =>
      'Weet je zeker dat je dit gesprek wilt sluiten? Er kunnen dan geen nieuwe reacties meer worden geplaatst.';

  @override
  String get close => 'Sluiten';

  @override
  String get openConversation2 => 'Gesprek openen';

  @override
  String get openConversationConfirmation =>
      'Weet je zeker dat je dit gesprek wilt openen? Er kunnen dan weer nieuwe reacties worden geplaatst.';

  @override
  String get open => 'Openen';

  @override
  String get leaveConversation3 => 'Gesprek verlaten';

  @override
  String get leaveConversationConfirmation =>
      'Weet je zeker dat je dit gesprek wilt verlaten? Het wordt verborgen in je inbox.';

  @override
  String errorLoadingConversation(Object error) {
    return 'Fout bij laden van gesprek: $error';
  }

  @override
  String get conversationNotFound => 'Gesprek niet gevonden';

  @override
  String get conversationClosedBanner =>
      'Dit gesprek is gesloten en accepteert geen reacties meer';

  @override
  String get noMessagesFound => 'Geen berichten gevonden';

  @override
  String get endOfConversation => 'Einde van het gesprek';

  @override
  String get jumpToMessage => 'Ga naar bericht';

  @override
  String get editConversation2 => 'Gesprek bewerken';

  @override
  String get failedToLoadMessage2 => 'Bericht laden mislukt';

  @override
  String get cannotEditThisConversation =>
      'Dit gesprek kan niet worden bewerkt';

  @override
  String get options => 'Opties';

  @override
  String get conversationOpen => 'Gesprek open';

  @override
  String failedToCreateConversation(Object error) {
    return 'Gesprek aanmaken mislukt: $error';
  }

  @override
  String maximumAttachmentsAllowed(Object count) {
    return 'Maximaal $count bijlage(n) toegestaan';
  }

  @override
  String get noImagesFoundToDisplay =>
      'Geen afbeeldingen gevonden om weer te geven.';

  @override
  String get pleaseLoginToViewThisAttachment =>
      'Meld je aan om deze bijlage te bekijken';

  @override
  String get searchForTopics => 'Onderwerpen zoeken';

  @override
  String get noTopicsFound => 'Geen onderwerpen gevonden';

  @override
  String get trySearchingWithDifferentKeywords => 'Probeer andere zoekwoorden';

  @override
  String get noPostsFound => 'Geen berichten gevonden';

  @override
  String get perTopicNotificationLevelsNote =>
      'Meldingsniveaus per categorie en per onderwerp stel je op die schermen zelf in — tik op het belpictogram van een onderwerp of categorie.';

  @override
  String get pushNotActiveForThisLogin =>
      'Niet actief voor deze aanmelding — meld je af en weer aan om pushmeldingen toe te staan';

  @override
  String get pauseNotificationsFor => 'Meldingen pauzeren voor…';

  @override
  String get doNotDisturbExplanation =>
      'Pauzeer meldingen een tijdje — Discourse houdt ze vast tot de periode voorbij is';

  @override
  String get emailSettingsSubtitle =>
      'E-mailfrequentie, samengevoegde likes, digestschema';

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
      'Het verwijderen van je account gebeurt op het forum. Ga verder om de site te openen en contact op te nemen met de staf — Discourse-forums verwerken verwijderingen volgens hun eigen beleid.';

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
  String get unableToLoadForums => 'Forums laden mislukt';

  @override
  String get noForumsToDisplayExplanation =>
      'Er zijn geen forums om weer te geven. Dit kan door rechten of de forumstructuur komen.';

  @override
  String get subscribedForums => 'Geabonneerde forums';

  @override
  String get errorLoadingNotifications => 'Fout bij laden van meldingen';

  @override
  String get pullDownToRefresh => 'Trek omlaag om te vernieuwen';

  @override
  String get noNewNotificationsExplanation =>
      'Je hebt geen nieuwe meldingen. Kom later terug voor updates over onderwerpen die je volgt.';

  @override
  String noTagsMatch(Object filter) {
    return 'Geen tags komen overeen met \"$filter\".';
  }

  @override
  String noTopicsTagged(Object tag) {
    return 'Geen onderwerpen met tag \"$tag\"';
  }

  @override
  String failedToBanUser2(Object error) {
    return 'Gebruiker verbannen mislukt: $error';
  }

  @override
  String unbanUserConfirmation(Object username) {
    return 'Weet je zeker dat je de verbanning van $username wilt opheffen?';
  }

  @override
  String failedToUnbanUser2(Object error) {
    return 'Verbanning opheffen mislukt: $error';
  }

  @override
  String get deletePostsProfilePostsAndComments =>
      'Berichten, profielberichten en reacties verwijderen';

  @override
  String spamCleanConfirmation(Object username) {
    return 'Weet je zeker dat je spam van $username wilt opruimen?';
  }

  @override
  String failedToCleanSpam(Object error) {
    return 'Spam opruimen mislukt: $error';
  }

  @override
  String get searchUser => 'Gebruiker zoeken';

  @override
  String get tapToOpen => 'Tik om te openen';

  @override
  String get imageNotAvailable => 'Afbeelding niet beschikbaar';

  @override
  String get allForumTopicsHaveBeenMarkedAs =>
      'Alle forumonderwerpen zijn gemarkeerd als gelezen';

  @override
  String postsCount(Object count) {
    return '$count berichten';
  }

  @override
  String get protectedForum => 'Beveiligd forum';

  @override
  String isPasswordProtected(Object forumName) {
    return '$forumName is beveiligd met een wachtwoord.';
  }

  @override
  String get enter => 'Invoeren';

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
  String get failedToPickFile => 'Bestand kiezen mislukt';

  @override
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return 'Nog maar $remainingSlots bijlage(n) toegestaan. De eerste $remainingSlots2 afbeelding(en) worden verwerkt.';
  }

  @override
  String get attachmentLimitReachedSkippingRemainingImages =>
      'Bijlagelimiet bereikt. Overige afbeeldingen worden overgeslagen.';

  @override
  String failedToUploadImagePleaseTryAgain(Object fileName) {
    return '$fileName: afbeelding uploaden mislukt. Probeer het opnieuw.';
  }

  @override
  String failedToUploadImage2(Object errorMessage, Object fileName) {
    return '$fileName: afbeelding uploaden mislukt: $errorMessage';
  }

  @override
  String get failedToPickImage => 'Afbeelding kiezen mislukt';

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
  String get pleaseWaitForTheThreadToLoad =>
      'Wacht tot het onderwerp is geladen';

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
  String failedToSubmitReport2(Object error) {
    return 'Melding verzenden mislukt: $error';
  }

  @override
  String get editHistoryNotAvailable =>
      'Bewerkingsgeschiedenis is niet beschikbaar voor dit bericht';

  @override
  String get noPermissionToUploadAvatar =>
      'Je hebt geen toestemming om avatars te uploaden';

  @override
  String get avatarUploadedSuccessfully => 'Avatar geüpload';

  @override
  String failedToPickImage2(Object error) {
    return 'Afbeelding kiezen mislukt: $error';
  }

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
  String signOutWarning(Object siteName) {
    return 'Je wordt afgemeld bij $siteName. Je kunt je op elk moment opnieuw aanmelden.';
  }

  @override
  String get suggestedTopics => 'Voorgestelde onderwerpen';

  @override
  String get newLabel => 'NIEUW';

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
}
