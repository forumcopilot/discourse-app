// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get loginTitle => 'Anmelden';

  @override
  String get usePasskey => 'Use Passkey';

  @override
  String get passkeyContinuePrompt => 'Use your passkey to continue';

  @override
  String get continueButton => 'Fortfahren';

  @override
  String get errorTitle => 'Fehler';

  @override
  String get okButton => 'OK';

  @override
  String get retryButton => 'Wiederholen';

  @override
  String get copyToClipboard => 'In Zwischenablage kopieren';

  @override
  String get copied => 'Kopiert';

  @override
  String get errorMessageCopiedToClipboard =>
      'Fehlermeldung in Zwischenablage kopiert';

  @override
  String get dismiss => 'Verwerfen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get tryAgain => 'Erneut Versuchen';

  @override
  String get anErrorOccurred => 'Ein Fehler ist aufgetreten';

  @override
  String get accountPendingApproval =>
      'Ihr Konto wartet auf Genehmigung. Sie können das Forum durchsuchen, aber nicht posten, bis ein Moderator Ihr Konto genehmigt.';

  @override
  String get checkEmailToConfirm =>
      'Bitte überprüfen Sie Ihre E-Mail, um Ihr Konto zu bestätigen. Klicken Sie auf den Bestätigungslink in der E-Mail, die wir Ihnen gesendet haben.';

  @override
  String get checkNewEmailToConfirm =>
      'Bitte überprüfen Sie Ihre neue E-Mail-Adresse, um die Änderung zu bestätigen. Ihre alte E-Mail bleibt aktiv, bis Sie die neue bestätigen.';

  @override
  String get emailAddressInvalid =>
      'Ihre E-Mail-Adresse scheint ungültig zu sein oder lehnt E-Mails ab. Bitte aktualisieren Sie Ihre E-Mail-Adresse in den Kontoeinstellungen.';

  @override
  String get accountDisabled =>
      'Ihr Konto wurde deaktiviert. Bitte wenden Sie sich an einen Administrator für Hilfe.';

  @override
  String get accountRegistrationRejected =>
      'Ihre Kontoregistrierung wurde abgelehnt. Bitte wenden Sie sich an einen Administrator für weitere Informationen.';

  @override
  String get welcomeToForumCopilot => 'Willkommen bei Forum Copilot!';

  @override
  String get successfullyLoggedOut => 'Sie wurden erfolgreich abgemeldet';

  @override
  String get accountStatusRequiresAttention =>
      'Der Status Ihres Kontos erfordert Aufmerksamkeit. Bitte wenden Sie sich an einen Administrator, wenn Sie Fragen haben.';

  @override
  String get updateEmail => 'E-Mail aktualisieren';

  @override
  String get resend => 'Erneut senden';

  @override
  String get noLatestTopics => 'Keine neuesten Themen';

  @override
  String get noRecentTopicsToDisplay =>
      'Es gibt keine neuesten Themen zum Anzeigen. Kommen Sie später für neue Diskussionen zurück.';

  @override
  String get signInToViewLatestTopics =>
      'Melden Sie sich an, um neueste Themen anzuzeigen';

  @override
  String get youNeedToBeSignedInToViewLatestTopics =>
      'Sie müssen angemeldet sein, um neueste Themen anzuzeigen';

  @override
  String get thereAreNoUnreadTopics =>
      'Es gibt keine ungelesenen Themen. Kommen Sie später für neue Diskussionen zurück.';

  @override
  String get youAreAllCaughtUp => 'Sie sind auf dem neuesten Stand!';

  @override
  String get signInToViewUnreadTopics =>
      'Melden Sie sich an, um ungelesene Themen anzuzeigen';

  @override
  String get youNeedToBeSignedInToViewUnreadTopics =>
      'Sie müssen angemeldet sein, um Ihre ungelesenen Themen anzuzeigen';

  @override
  String get latest => 'Neueste';

  @override
  String get unread => 'Ungelesen';

  @override
  String get failedToConnectToSite =>
      'Verbindung zur Website fehlgeschlagen. Die Website kann offline oder nicht erreichbar sein.';

  @override
  String get connectionFailed => 'Verbindungsfehler';

  @override
  String failedToConnectToSiteName(String siteName) {
    return 'Verbindung zu $siteName fehlgeschlagen';
  }

  @override
  String get loading => 'Wird geladen...';

  @override
  String get newConversation => 'Neue Unterhaltung';

  @override
  String get language => 'Sprache';

  @override
  String get all => 'Alle';

  @override
  String get topicsOnly => 'Nur Themen';

  @override
  String get titlesOnly => 'Nur Titel';

  @override
  String failedToShareTopic(String error) {
    return 'Thema konnte nicht geteilt werden: $error';
  }

  @override
  String get pleaseLoginToSubscribe =>
      'Bitte melden Sie sich an, um null diesen Thread';

  @override
  String get subscribe => 'Abonnieren';

  @override
  String get failedToSubscribeToThread => 'Thread null fehlgeschlagen';

  @override
  String get youCannotReplyToThisThread =>
      'Sie können nicht auf diesen Thread antworten';

  @override
  String get pleaseWaitForThreadToLoad =>
      'Bitte warten Sie, bis der Thread geladen ist';

  @override
  String get softDelete => 'Sanftes Löschen';

  @override
  String get postCanBeRestoredLater =>
      'Beitrag kann später wiederhergestellt werden';

  @override
  String get hardDelete => 'Endgültiges Löschen';

  @override
  String get postWillBePermanentlyDeleted => 'Beitrag wird endgültig gelöscht';

  @override
  String get reasonForDeletion => 'Grund für die Löschung';

  @override
  String get enterReasonForDeletingPost =>
      'Geben Sie den Grund für die Löschung dieses Beitrags ein';

  @override
  String get pleaseEnterReasonForDeletion =>
      'Bitte geben Sie einen Grund für die Löschung ein';

  @override
  String get reportPost => 'Beitrag melden';

  @override
  String get pleaseProvideReasonForReporting =>
      'Bitte geben Sie einen Grund für die Meldung dieses Beitrags an.';

  @override
  String get reason => 'Grund';

  @override
  String get enterReasonForReportingPost =>
      'Geben Sie den Grund für die Meldung dieses Beitrags ein';

  @override
  String get pleaseEnterReason => 'Bitte geben Sie einen Grund ein';

  @override
  String get submitReport => 'Meldung absenden';

  @override
  String get selectedActions => 'Ausgewählte Aktionen:';

  @override
  String get thisActionCannotBeUndone =>
      'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get participantsLabel => 'Teilnehmer';

  @override
  String usernameHasBeenInvited(String username) {
    return '$username wurde zur Unterhaltung eingeladen';
  }

  @override
  String errorInvitingUser(String error) {
    return 'Fehler beim Einladen des Benutzers: $error';
  }

  @override
  String get newTopic => 'Neues Thema';

  @override
  String get markRead => 'Als gelesen markieren';

  @override
  String get spamOrAdvertising => 'Spam oder Werbung';

  @override
  String get otherPleaseSpecify => 'Andere (bitte angeben)';

  @override
  String get pleaseSpecifyReason => 'Bitte geben Sie den Grund an';

  @override
  String get banUser => 'Benutzer sperren';

  @override
  String get unbanUser => 'Benutzer entsperren';

  @override
  String pleaseSelectReasonForBanningUser(String username) {
    return 'Bitte wählen Sie einen Grund für die Sperrung von $username';
  }

  @override
  String get violationOfCommunityGuidelines =>
      'Verstoß gegen die Community-Richtlinien';

  @override
  String get harassmentOrAbusiveBehavior =>
      'Belästigung oder missbräuchliches Verhalten';

  @override
  String get postingInappropriateContent =>
      'Veröffentlichung unangemessener Inhalte';

  @override
  String get accountCompromiseOrSecurityIssue =>
      'Kontokompromittierung oder Sicherheitsproblem';

  @override
  String get enterReasonForBanningUser =>
      'Geben Sie den Grund für die Sperrung dieses Benutzers ein';

  @override
  String get banUntil => 'Sperren bis';

  @override
  String get selectDate => 'Datum auswählen';

  @override
  String get moreOptions => 'Weitere Optionen';

  @override
  String get topicClosed => 'Thema geschlossen';

  @override
  String get topicOpened => 'Thema geöffnet';

  @override
  String get topicStickied => 'Thema angeheftet';

  @override
  String get topicUnstickied => 'Thema nicht mehr angeheftet';

  @override
  String cannotEditMessage(String error) {
    return 'Diese Nachricht kann nicht bearbeitet werden: $error';
  }

  @override
  String get confirmSpamClean => 'Spam-Bereinigung bestätigen';

  @override
  String get handleThreads => 'Threads verwalten';

  @override
  String get deleteMessages => 'Nachrichten löschen';

  @override
  String get deleteConversations => 'Unterhaltungen löschen';

  @override
  String get noConversations => 'Keine Unterhaltungen';

  @override
  String get noConversationsMessage =>
      'Sie haben noch keine Unterhaltungen. Starten Sie eine neue Unterhaltung, um mit dem Messaging zu beginnen.';

  @override
  String get imageSavedToGallery => 'Bild in Galerie gespeichert!';

  @override
  String failedToSaveImage(String error) {
    return 'Fehler beim Speichern des Bildes: $error';
  }

  @override
  String get userProfile => 'Benutzerprofil';

  @override
  String get deletePost => 'Beitrag Löschen';

  @override
  String get loginRequired => 'Anmeldung Erforderlich';

  @override
  String get spamCleaner => 'Spam-Bereinigung';

  @override
  String get sendMessage => 'Nachricht senden';

  @override
  String get memberSince => 'Mitglied Seit';

  @override
  String get lastActivity => 'Letzte Aktivität';

  @override
  String get likesReceived => 'Erhaltene Likes';

  @override
  String get likesGiven => 'Gegebene Likes';

  @override
  String get showMore => 'Mehr anzeigen';

  @override
  String get cleanSpam => 'Spam bereinigen';

  @override
  String get failedToSaveConversation =>
      'Speichern der Unterhaltung fehlgeschlagen';

  @override
  String get members => 'Mitglieder';

  @override
  String membersCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString Mitglieder';
  }

  @override
  String get noSubject => 'Kein Betreff';

  @override
  String get search => 'Suchen';

  @override
  String get logout => 'Abmelden';

  @override
  String get areYouSureYouWantToLogout => 'Möchten Sie sich wirklich abmelden?';

  @override
  String get register => 'Registrieren';

  @override
  String get signIn => 'Anmelden';

  @override
  String get markForumRead => 'Forum als Gelesen Markieren';

  @override
  String get notificationTest => 'Benachrichtigungstest';

  @override
  String get forum => 'Forum';

  @override
  String get profile => 'Profil';

  @override
  String get messages => 'Nachrichten';

  @override
  String get add => 'Hinzufügen';

  @override
  String get retry => 'Wiederholen';

  @override
  String get delete => 'Löschen';

  @override
  String get deleteMessage => 'Nachricht Löschen';

  @override
  String get deletingPost => 'Beitrag wird gelöscht...';

  @override
  String failedToUnlikePost(String error) {
    return 'Fehler beim Entfernen des Likes vom Beitrag: $error';
  }

  @override
  String failedToLikePost(String error) {
    return 'Fehler beim Liken des Beitrags: $error';
  }

  @override
  String get signInToViewMessages =>
      'Melden Sie sich an, um Nachrichten anzuzeigen';

  @override
  String get youNeedToBeSignedInToViewConversations =>
      'Sie müssen angemeldet sein, um Ihre Unterhaltungen anzuzeigen.';

  @override
  String errorLoadingConversations(String error) {
    return 'Fehler beim Laden der Unterhaltungen: $error';
  }

  @override
  String failedToLeaveConversation(String error) {
    return 'Fehler beim Verlassen der Unterhaltung: $error';
  }

  @override
  String errorLoadingMoreConversations(String error) {
    return 'Fehler beim Laden weiterer Unterhaltungen: $error';
  }

  @override
  String get searchFailed => 'Suche fehlgeschlagen';

  @override
  String get userInformationNotAvailable =>
      'Benutzerinformationen nicht verfügbar';

  @override
  String get birthday => 'Geburtstag';

  @override
  String get posts => 'Beiträge';

  @override
  String get following => 'Folgt';

  @override
  String get followers => 'Follower';

  @override
  String get about => 'Über';

  @override
  String get location => 'Standort';

  @override
  String get website => 'Website';

  @override
  String get next => 'Weiter';

  @override
  String get permanent => 'Permanent';

  @override
  String get temporary => 'Temporär';

  @override
  String setBanDurationFor(String username) {
    return 'Bann-Dauer für $username festlegen';
  }

  @override
  String get pleaseSelectEndDateForTemporaryBan =>
      'Bitte wählen Sie ein Enddatum für den temporären Bann';

  @override
  String get back => 'Zurück';

  @override
  String get unban => 'Entbannen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String spamClean(String username) {
    return 'Spam von $username Bereinigen';
  }

  @override
  String get selectActionsToPerform =>
      'Wählen Sie die auszuführenden Aktionen:';

  @override
  String get moveOrDeleteThreadsBasedOnAdminSettings =>
      'Threads basierend auf Admin-Einstellungen verschieben oder löschen';

  @override
  String get messageUpdatedSuccessfully => 'Nachricht erfolgreich aktualisiert';

  @override
  String error(String error) {
    return 'Fehler: $error';
  }

  @override
  String failedToRemoveAttachment(String error) {
    return 'Fehler beim Entfernen des Anhangs: $error';
  }

  @override
  String failedToLoadMessage(String error) {
    return 'Fehler beim Laden der Nachricht: $error';
  }

  @override
  String get editMessage => 'Nachricht Bearbeiten';

  @override
  String get removeAttachment => 'Anhang Entfernen';

  @override
  String get areYouSureYouWantToRemoveThisAttachment =>
      'Möchten Sie diesen Anhang wirklich entfernen?';

  @override
  String get none => 'Keine';

  @override
  String get attachFile => 'Datei Anhängen';

  @override
  String get uploadImage => 'Bild Hochladen';

  @override
  String get formatting => 'Formatierung';

  @override
  String get bold => 'Fett';

  @override
  String get italic => 'Kursiv';

  @override
  String get underline => 'Unterstrichen';

  @override
  String get strikethrough => 'Durchgestrichen';

  @override
  String get link => 'Link';

  @override
  String get image => 'Bild';

  @override
  String get video => 'Video';

  @override
  String get quote => 'Zitat';

  @override
  String get code => 'Code';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get bulletList => 'Aufzählungsliste';

  @override
  String get numberedList => 'Nummerierte Liste';

  @override
  String get listItem => 'Listenelement';

  @override
  String participants(int count) {
    return 'Teilnehmer ($count)';
  }

  @override
  String get markAsUnread => 'Als ungelesen markieren';

  @override
  String get invite => 'Einladen';

  @override
  String get enterKeywordsToSearchTopics =>
      'Geben Sie Schlüsselwörter ein, um Themen zu suchen...';

  @override
  String get undelete => 'Wiederherstellen';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get share => 'Teilen';

  @override
  String get viewOnWeb => 'Im Web anzeigen';

  @override
  String get unlock => 'Entsperren';

  @override
  String get lock => 'Sperren';

  @override
  String get stick => 'Anheften';

  @override
  String get unstick => 'Loslösen';

  @override
  String get reply => 'Antworten';

  @override
  String get vote => 'Abstimmen';

  @override
  String votesCount(int count) {
    return '$count Stimmen';
  }

  @override
  String get pollClosed => 'Umfrage geschlossen';

  @override
  String pollEndsOn(String date) {
    return 'Endet am $date';
  }

  @override
  String get voteToSeeResults => 'Abstimmen, um Ergebnisse zu sehen';

  @override
  String get viewFullPoll => 'Umfrage anzeigen';

  @override
  String pollOptionsCount(int count) {
    return '$count Optionen';
  }

  @override
  String get reactedBy => 'Reagiert von';

  @override
  String get enterKeywordsToFindTopicsAndPosts =>
      'Geben Sie Schlüsselwörter ein, um Themen und Beiträge zu finden';

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String version(String version, String buildNumber) {
    return 'Version $version ($buildNumber)';
  }

  @override
  String get unableToLoadProfile => 'Profil konnte nicht geladen werden';

  @override
  String get banned => 'GESPERRT';

  @override
  String get reportSubmittedSuccessfully => 'Meldung erfolgreich abgesendet';

  @override
  String get deleteTopic => 'Thema löschen';

  @override
  String get topicCanBeRestoredLater =>
      'Thema kann später wiederhergestellt werden';

  @override
  String get topicWillBePermanentlyDeleted => 'Thema wird endgültig gelöscht';

  @override
  String get enterReasonForDeletingTopic =>
      'Geben Sie den Grund für die Löschung dieses Themas ein';

  @override
  String get pleaseSelectEndDate => 'Bitte wählen Sie ein Enddatum';

  @override
  String get userBannedSuccessfully => 'Benutzer erfolgreich gesperrt';

  @override
  String get failedToBanUser => 'Benutzer konnte nicht gesperrt werden';

  @override
  String get userUnbannedSuccessfully => 'Benutzer erfolgreich entsperrt';

  @override
  String get failedToUnbanUser => 'Benutzer konnte nicht entsperrt werden';

  @override
  String get spamCleanUser => 'Spam des Benutzers bereinigen';

  @override
  String get deletePrivateConversations => 'Private Unterhaltungen löschen';

  @override
  String get banTheUserAccount => 'Benutzerkonto sperren';

  @override
  String get handledThreads => 'Behandelte Themen';

  @override
  String get deletedMessages => 'Gelöschte Nachrichten';

  @override
  String get deletedConversations => 'Gelöschte Unterhaltungen';

  @override
  String get bannedUser => 'Gesperrter Benutzer';

  @override
  String successfullyCleanedSpam(String username, String actions) {
    return 'Spam erfolgreich bereinigt für $username. Aktionen: $actions';
  }

  @override
  String get home => 'Startseite';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get forums => 'Foren';

  @override
  String get markAllForumsAsRead => 'Alle Foren als gelesen markieren?';

  @override
  String get markAllForumsAsReadMessage =>
      'Dies markiert alle Foren und Themen als gelesen. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get markAsRead => 'Als gelesen markieren';

  @override
  String get content => 'Inhalt';

  @override
  String get insertImage => 'Bild einfügen';

  @override
  String get howWouldYouLikeToInsertImage =>
      'Wie möchten Sie dieses Bild einfügen?';

  @override
  String get thumbnail => 'Miniaturansicht';

  @override
  String get fullSize => 'Vollständige Größe';

  @override
  String get pleaseEnterTitle => 'Bitte geben Sie einen Titel ein';

  @override
  String get pleaseEnterContent => 'Bitte geben Sie einen Inhalt ein';

  @override
  String get uploading => 'Hochladen...';

  @override
  String get uploaded => 'Hochgeladen';

  @override
  String get mentionUser => 'Benutzer erwähnen';

  @override
  String get submittingReport => 'Bericht senden...';

  @override
  String get banningUser => 'Benutzer sperren...';

  @override
  String get unbanningUser => 'Benutzersperre aufheben...';

  @override
  String get cleaningSpam => 'Spam bereinigen...';

  @override
  String get writeYourMessage => 'Schreiben Sie Ihre Nachricht...';

  @override
  String get writeYourReply => 'Schreiben Sie Ihre Antwort...';

  @override
  String get conversationCreatedSuccessfully =>
      'Unterhaltung erfolgreich erstellt';

  @override
  String get conversationMarkedAsUnread =>
      'Unterhaltung als ungelesen markiert';

  @override
  String get conversationClosed => 'Unterhaltung geschlossen';

  @override
  String get conversationOpened => 'Unterhaltung geöffnet';

  @override
  String get pleaseLoginToLikeMessages =>
      'Bitte melden Sie sich an, um Nachrichten zu mögen';

  @override
  String get loadEarlierMessages => 'Frühere Nachrichten laden';

  @override
  String failedToLoadQuote(String error) {
    return 'Zitat konnte nicht geladen werden: \n$error';
  }

  @override
  String failedToSendReply(String error) {
    return 'Antwort konnte nicht gesendet werden: $error';
  }

  @override
  String failedToMarkConversationAsUnread(String error) {
    return 'Unterhaltung konnte nicht als ungelesen markiert werden: $error';
  }

  @override
  String failedToCloseConversation(String error) {
    return 'Unterhaltung konnte nicht geschlossen werden: $error';
  }

  @override
  String failedToOpenConversation(String error) {
    return 'Unterhaltung konnte nicht geöffnet werden: $error';
  }

  @override
  String failedToJumpToMessage(String error) {
    return 'Zu Nachricht springen fehlgeschlagen: $error';
  }

  @override
  String get goToTop => 'Nach oben';

  @override
  String get goToBottom => 'Nach unten';

  @override
  String get pleaseLoginToAccessContent =>
      'Bitte melden Sie sich an, um auf diesen Inhalt zuzugreifen und mit Beiträgen zu interagieren.';

  @override
  String get searchUsers => 'Benutzer suchen...';

  @override
  String get enterConversationTitle =>
      'Geben Sie den Titel der Unterhaltung ein';

  @override
  String enterCode(int count) {
    return 'Geben Sie den $count-stelligen Code ein';
  }

  @override
  String get edit => 'Bearbeiten';

  @override
  String get report => 'Melden';

  @override
  String get remove => 'Entfernen';

  @override
  String get subject => 'Betreff';

  @override
  String get message => 'Nachricht';

  @override
  String get titleCannotBeEmpty => 'Der Titel darf nicht leer sein';

  @override
  String get conversationUpdatedSuccessfully =>
      'Unterhaltung erfolgreich aktualisiert';

  @override
  String get goBack => 'Zurück';

  @override
  String failedToLoadPost(String error) {
    return 'Beitrag konnte nicht geladen werden: \n$error';
  }

  @override
  String failedToLikeOrUnlikeMessage(String action, String error) {
    return 'Nachricht konnte nicht $action werden: $error';
  }

  @override
  String get like => 'mögen';

  @override
  String get unlike => 'nicht mehr mögen';

  @override
  String downloading(String filename) {
    return 'Lade $filename herunter...';
  }

  @override
  String openingShareSheet(String filename) {
    return 'Öffne Freigabeblatt für $filename';
  }

  @override
  String errorDownloading(String filename, String error) {
    return 'Fehler beim Herunterladen von $filename: $error';
  }

  @override
  String get failedToNavigateToForum => 'Navigation zum Forum fehlgeschlagen';

  @override
  String forumNotFoundById(String forumId) {
    return 'Forum nicht gefunden: $forumId';
  }

  @override
  String couldNotOpenLink(String error) {
    return 'Link konnte nicht geöffnet werden: $error';
  }

  @override
  String get translating => 'Übersetze...';

  @override
  String get translated => 'Übersetzt';

  @override
  String get translatedContent => 'Übersetzter Inhalt';

  @override
  String get twoFactorAuthentication => 'Zwei-Faktor-Authentifizierung';

  @override
  String get authenticationCodeLabel => 'Authentifizierungscode';

  @override
  String get pleaseEnterYourAuthenticationCode =>
      'Bitte geben Sie Ihren Authentifizierungscode ein';

  @override
  String codeMustBeDigits(int count) {
    return 'Der Code muss $count Ziffern enthalten';
  }

  @override
  String get codeMustContainOnlyNumbers => 'Der Code darf nur Zahlen enthalten';

  @override
  String get verifyButton => 'Bestätigen';

  @override
  String get attachments => 'Anhänge';

  @override
  String get replyOptions => 'Antwortoptionen';

  @override
  String get replyWithQuote => 'Mit Zitat antworten';

  @override
  String fileSavedToDownloads(String filename) {
    return 'Datei in Downloads gespeichert: $filename';
  }

  @override
  String fileSavedToDocuments(String filename) {
    return 'Datei in Dokumente gespeichert: $filename';
  }

  @override
  String topicLastReplyBy(String username, String time) {
    return '$username hat $time geantwortet';
  }

  @override
  String inReplyToUser(String username) {
    return 'als Antwort auf $username';
  }

  @override
  String inReplyToPost(int number) {
    return 'als Antwort auf Beitrag #$number';
  }

  @override
  String timeGapDaysLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage später',
      one: '1 Tag später',
    );
    return '$_temp0';
  }

  @override
  String timeGapMonthsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Monate später',
      one: '1 Monat später',
    );
    return '$_temp0';
  }

  @override
  String timeGapYearsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Jahre später',
      one: '1 Jahr später',
    );
    return '$_temp0';
  }

  @override
  String get profileViews => 'Aufrufe';

  @override
  String get badges => 'Abzeichen';

  @override
  String get chatWithUser => 'Chat';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Antworten',
      one: '1 Antwort',
    );
    return '$_temp0';
  }

  @override
  String nVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stimmen',
      one: '1 Stimme',
    );
    return '$_temp0';
  }

  @override
  String get lastSeen => 'Gesehen';

  @override
  String get chat => 'Chat';

  @override
  String comingSoon(String label) {
    return '$label — demnächst';
  }

  @override
  String moreBadges(Object count) {
    return '+$count weitere';
  }

  @override
  String get allNotificationsMarkedAsRead =>
      'Alle Benachrichtigungen als gelesen markiert';

  @override
  String get apply => 'Anwenden';

  @override
  String get bookmarks => 'Lesezeichen';

  @override
  String reviewableBy(String username) {
    return 'Von $username';
  }

  @override
  String get changeEmail => 'E-Mail ändern';

  @override
  String get changePassword => 'Passwort ändern';

  @override
  String get checkingStatus => 'Status wird geprüft…';

  @override
  String get clearReminder => 'Erinnerung entfernen';

  @override
  String get copy => 'Kopieren';

  @override
  String get copyLink => 'Link kopieren';

  @override
  String couldNotEnableNotifications(String error) {
    return 'Benachrichtigungen konnten nicht aktiviert werden: $error';
  }

  @override
  String get couldNotFindBookmark => 'Dieses Lesezeichen wurde nicht gefunden';

  @override
  String couldNotOpenEmail(String email) {
    return 'E-Mail konnte nicht geöffnet werden: $email';
  }

  @override
  String couldNotStartSignIn(String error) {
    return 'Anmeldung konnte nicht gestartet werden: $error';
  }

  @override
  String get customDateAndTime => 'Eigenes Datum und Uhrzeit';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get deleteMessageQuestion => 'Nachricht löschen?';

  @override
  String get discard => 'Verwerfen';

  @override
  String get discardDraftQuestion => 'Entwurf verwerfen?';

  @override
  String get doNotDisturb => 'Nicht stören';

  @override
  String get editHistory => 'Bearbeitungsverlauf';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get editReminder => 'Erinnerung bearbeiten';

  @override
  String emailCopiedToClipboard(String email) {
    return 'E-Mail in die Zwischenablage kopiert: $email';
  }

  @override
  String get pushEnabledForThisLogin => 'Für diese Anmeldung aktiviert';

  @override
  String get failedToLoadMoreTopics =>
      'Weitere Themen konnten nicht geladen werden. Zum Wiederholen scrollen.';

  @override
  String get failedToUpdateNotificationLevel =>
      'Benachrichtigungsstufe konnte nicht geändert werden';

  @override
  String get firstPostsOnly => 'Nur erste Beiträge';

  @override
  String get ignoredUsers => 'Ignorierte Benutzer';

  @override
  String get inTwoHours => 'In zwei Stunden';

  @override
  String get inviteByEmail => 'Per E-Mail einladen';

  @override
  String get inviteLinkCopied => 'Einladungslink kopiert';

  @override
  String inviteSentTo(String email) {
    return 'Einladung gesendet an $email';
  }

  @override
  String get leave => 'Verlassen';

  @override
  String get leaveGroup => 'Gruppe verlassen';

  @override
  String get leaveGroupQuestion => 'Gruppe verlassen?';

  @override
  String get linkCopied => 'Link kopiert';

  @override
  String get loadMore => 'Mehr laden';

  @override
  String get manageAccountOnWeb => 'Konto im Web verwalten';

  @override
  String get merge => 'Zusammenführen';

  @override
  String get mergeIntoTopic => 'In Thema verschieben';

  @override
  String get newInviteLink => 'Neuer Einladungslink';

  @override
  String get nextWeek => 'Nächste Woche';

  @override
  String get pushNotAvailableInThisBuild => 'In diesem Build nicht verfügbar';

  @override
  String get notNow => 'Nicht jetzt';

  @override
  String tagNotificationLevelUpdated(String tag) {
    return 'Benachrichtigungsstufe für „$tag“ aktualisiert';
  }

  @override
  String doNotDisturbOnUntil(String until) {
    return 'Aktiv bis $until';
  }

  @override
  String get pleaseLogInToBookmark =>
      'Bitte anmelden, um Lesezeichen zu setzen';

  @override
  String get pleaseLogInToFollowUsers =>
      'Bitte anmelden, um Benutzern zu folgen';

  @override
  String get pleaseLogInToMarkAnswers =>
      'Bitte anmelden, um Antworten zu markieren';

  @override
  String get pleaseLogInToReact => 'Bitte anmelden, um zu reagieren';

  @override
  String get pleaseLogInToVote => 'Bitte anmelden, um abzustimmen';

  @override
  String get pushNotifications => 'Push-Benachrichtigungen';

  @override
  String get relevance => 'Relevanz';

  @override
  String get reminderTimeMustBeInFuture =>
      'Die Erinnerungszeit muss in der Zukunft liegen';

  @override
  String get removeBookmark => 'Lesezeichen entfernen';

  @override
  String get removeVote => 'Stimme zurückziehen';

  @override
  String get renameTopic => 'Thema umbenennen';

  @override
  String reportedBy(String username) {
    return 'Gemeldet von $username';
  }

  @override
  String get requestToJoin => 'Beitritt anfragen';

  @override
  String requestToJoinGroup(String group) {
    return 'Beitritt zu $group anfragen';
  }

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get resizeAndUpload => 'Verkleinern und hochladen';

  @override
  String get retryConnection => 'Verbindung erneut versuchen';

  @override
  String get reviewQueue => 'Prüfwarteschlange';

  @override
  String get revoke => 'Widerrufen';

  @override
  String get revokeInviteQuestion => 'Einladung widerrufen?';

  @override
  String get save => 'Speichern';

  @override
  String get sendInvite => 'Einladung senden';

  @override
  String get sendRequest => 'Anfrage senden';

  @override
  String get settings => 'Einstellungen';

  @override
  String get showVoters => 'Abstimmende anzeigen';

  @override
  String get signOut => 'Abmelden';

  @override
  String get signOutQuestion => 'Abmelden?';

  @override
  String get signInCancelledNoPayload =>
      'Anmeldung abgebrochen — keine Antwort erhalten';

  @override
  String signInFailed(String error) {
    return 'Anmeldung fehlgeschlagen: $error';
  }

  @override
  String get startChat => 'Chat starten';

  @override
  String stoppedIgnoringUser(String username) {
    return '@$username wird nicht mehr ignoriert';
  }

  @override
  String get submit => 'Absenden';

  @override
  String get discardDraftWarning =>
      'Der gespeicherte Entwurf wird dauerhaft entfernt.';

  @override
  String get deleteChatMessageWarning =>
      'Die Nachricht wird für alle entfernt.';

  @override
  String get titleOnly => 'Nur Titel';

  @override
  String get tomorrow => 'Morgen';

  @override
  String get turnOff => 'Ausschalten';

  @override
  String get turnOnNotifications => 'Benachrichtigungen einschalten';

  @override
  String get whisper => 'Flüstern';

  @override
  String likeAgainInSeconds(Object seconds) {
    return 'Du kannst diesen Beitrag in ${seconds}s erneut liken';
  }

  @override
  String get loginInfo => 'Anmeldeinfo';

  @override
  String get loginFailed => 'Anmeldung fehlgeschlagen';

  @override
  String get moveToCategory => 'In Kategorie verschieben';

  @override
  String get undeleteTopic => 'Thema wiederherstellen';

  @override
  String get undeleteTopicConfirmation =>
      'Dieses Thema wirklich wiederherstellen? Es wird für andere Benutzer wieder sichtbar.';

  @override
  String get send => 'Senden';

  @override
  String get changeEmailExplanation =>
      'Wir senden einen Bestätigungslink an deine neue E-Mail-Adresse. Die Änderung wird wirksam, sobald du darauf klickst.';

  @override
  String get changeEmailSecurityNote =>
      'Zur Sicherheit verlangt Discourse eventuell eine Bestätigung über den Link in der E-Mail. Prüfe deinen Spam-Ordner, falls sie nicht ankommt.';

  @override
  String get newDirectMessage => 'Neue Direktnachricht';

  @override
  String get noMessagesYetSayHi => 'Noch keine Nachrichten — sag Hallo.';

  @override
  String get edited => 'bearbeitet';

  @override
  String get editProfileManagedOnWebNote =>
      'Anzeigename, E-Mail, Passwort und weitere Kontoeinstellungen werden unter Konto → Konto im Web verwalten geändert. Dein Avatar lässt sich über das Kamerasymbol auf deinem Foto ändern.';

  @override
  String get approvedButRelayUnreachable =>
      'Genehmigt, aber ForumCopilot war nicht erreichbar, um die Einrichtung abzuschließen. Versuche es später in den Einstellungen erneut.';

  @override
  String get notificationsAreTurnedOffForThisApp =>
      'Benachrichtigungen sind für diese App deaktiviert';

  @override
  String forumWillAskToApproveNotifications(Object forumName) {
    return 'Als Nächstes bittet dich $forumName, „Benachrichtigungen“ zu genehmigen.';
  }

  @override
  String get approveNotificationsExplanation =>
      'Mit der Genehmigung dürfen wir deine Benachrichtigungen für dich abrufen und an dieses Gerät senden. Diese Berechtigung kann nicht posten, antworten oder deine Nachrichten lesen.';

  @override
  String get forumOwnerPushNote =>
      'Wenn der Betreiber dieses Forums Benachrichtigungen für die App einrichtet, entfällt dieser Schritt.';

  @override
  String get pleaseLoginToCreateANewTopic =>
      'Bitte anmelden, um ein neues Thema zu erstellen';

  @override
  String get pleaseLoginToSubscribeToForums =>
      'Bitte anmelden, um Foren zu abonnieren';

  @override
  String leaveGroupWarning(Object group) {
    return 'Du bist dann kein Mitglied von $group mehr. Du kannst jederzeit wieder beitreten.';
  }

  @override
  String get groupMembersPrivate =>
      'Die Mitgliederliste dieser Gruppe ist privat.';

  @override
  String get unignore => 'Nicht mehr ignorieren';

  @override
  String get inviteLinkCreated => 'Einladungslink erstellt';

  @override
  String expiresOn(Object date) {
    return 'Läuft ab am $date';
  }

  @override
  String get protected => 'Geschützt';

  @override
  String get solution => 'Lösung';

  @override
  String get deleted => 'GELÖSCHT';

  @override
  String get pleaseLoginToViewUserProfiles =>
      'Bitte anmelden, um Benutzerprofile zu sehen.';

  @override
  String get announcement => 'Ankündigung';

  @override
  String get solved => 'Gelöst';

  @override
  String get hot => 'Beliebt';

  @override
  String get pinned => 'Angeheftet';

  @override
  String get subscribedLabel => 'Abonniert';

  @override
  String get locked => 'Gesperrt';

  @override
  String get poll => 'Umfrage';

  @override
  String errorLoadingContent(Object error) {
    return 'Fehler beim Laden des Inhalts: $error';
  }

  @override
  String get noPermissionToViewSubforum =>
      'Du hast keine Berechtigung, Themen in diesem Unterforum zu sehen.';

  @override
  String get noDiscussionsYet => 'Noch keine Diskussionen.';

  @override
  String get jumpToPost => 'Zu Beitrag springen';

  @override
  String get jump => 'Springen';

  @override
  String get endOfTheDiscussion => 'Ende der Diskussion';

  @override
  String get reviewQueueStaffOnly =>
      'Nur Team und Prüfer können die Prüfwarteschlange sehen.';

  @override
  String get nothingToReview => 'Nichts zu prüfen';

  @override
  String refreshFailed(Object error) {
    return 'Aktualisierung fehlgeschlagen: $error';
  }

  @override
  String get topicDeletedBanner =>
      'Dieses Thema ist gelöscht und für andere Benutzer nicht sichtbar';

  @override
  String get topicClosedBanner =>
      'Dieses Thema ist geschlossen und nimmt keine Antworten mehr an';

  @override
  String get topicPinnedBanner => 'Dieses Thema ist oben im Forum angeheftet';

  @override
  String get youAreSubscribedToThisTopic => 'Du hast dieses Thema abonniert';

  @override
  String get refreshing => 'Wird aktualisiert...';

  @override
  String get title => 'Titel';

  @override
  String editedAt(Object time) {
    return 'Bearbeitet $time';
  }

  @override
  String editReason(Object reason) {
    return 'Grund: $reason';
  }

  @override
  String get thisDiffIsTooLargeToDisplay =>
      'Dieser Unterschied ist zu groß zur Anzeige.';

  @override
  String get noContentChangesInThisRevision =>
      'Keine Inhaltsänderungen in dieser Version.';

  @override
  String revisionOf(Object currentVersion, Object versionCount) {
    return 'Version $currentVersion von $versionCount';
  }

  @override
  String get editConversation => 'Unterhaltung bearbeiten';

  @override
  String get closeConversation => 'Unterhaltung schließen';

  @override
  String get openConversation => 'Unterhaltung öffnen';

  @override
  String get leaveConversation2 => 'Unterhaltung verlassen';

  @override
  String get reportConversation2 => 'Unterhaltung melden';

  @override
  String get closeConversation2 => 'Unterhaltung schließen';

  @override
  String get closeConversationConfirmation =>
      'Diese Unterhaltung wirklich schließen? Es können keine neuen Antworten mehr geschrieben werden.';

  @override
  String get close => 'Schließen';

  @override
  String get openConversation2 => 'Unterhaltung öffnen';

  @override
  String get openConversationConfirmation =>
      'Diese Unterhaltung wirklich öffnen? Es können wieder neue Antworten geschrieben werden.';

  @override
  String get open => 'Öffnen';

  @override
  String get leaveConversation3 => 'Unterhaltung verlassen';

  @override
  String get leaveConversationConfirmation =>
      'Diese Unterhaltung wirklich verlassen? Sie wird aus deinem Posteingang ausgeblendet.';

  @override
  String errorLoadingConversation(Object error) {
    return 'Fehler beim Laden der Unterhaltung: $error';
  }

  @override
  String get conversationNotFound => 'Unterhaltung nicht gefunden';

  @override
  String get conversationClosedBanner =>
      'Diese Unterhaltung ist geschlossen und nimmt keine Antworten mehr an';

  @override
  String get noMessagesFound => 'Keine Nachrichten gefunden';

  @override
  String get endOfConversation => 'Ende der Unterhaltung';

  @override
  String get jumpToMessage => 'Zu Nachricht springen';

  @override
  String get editConversation2 => 'Unterhaltung bearbeiten';

  @override
  String get failedToLoadMessage2 => 'Nachricht konnte nicht geladen werden';

  @override
  String get cannotEditThisConversation =>
      'Diese Unterhaltung kann nicht bearbeitet werden';

  @override
  String get options => 'Optionen';

  @override
  String get conversationOpen => 'Unterhaltung offen';

  @override
  String failedToCreateConversation(Object error) {
    return 'Unterhaltung konnte nicht erstellt werden: $error';
  }

  @override
  String maximumAttachmentsAllowed(Object count) {
    return 'Maximal $count Anhänge erlaubt';
  }

  @override
  String get noImagesFoundToDisplay => 'Keine Bilder zum Anzeigen gefunden.';

  @override
  String get pleaseLoginToViewThisAttachment =>
      'Bitte anmelden, um diesen Anhang zu sehen';

  @override
  String get searchForTopics => 'Themen suchen';

  @override
  String get noTopicsFound => 'Keine Themen gefunden';

  @override
  String get trySearchingWithDifferentKeywords =>
      'Versuche es mit anderen Suchbegriffen';

  @override
  String get noPostsFound => 'Keine Beiträge gefunden';

  @override
  String get perTopicNotificationLevelsNote =>
      'Benachrichtigungsstufen pro Kategorie und Thema werden direkt dort festgelegt — tippe auf das Glockensymbol eines Themas oder einer Kategorie.';

  @override
  String get pushNotActiveForThisLogin =>
      'Für diese Anmeldung nicht aktiv — melde dich ab und wieder an, um Push-Benachrichtigungen zu erlauben';

  @override
  String get pauseNotificationsFor => 'Benachrichtigungen pausieren für…';

  @override
  String get doNotDisturbExplanation =>
      'Benachrichtigungen eine Weile pausieren — Discourse hält sie zurück, bis der Zeitraum endet';

  @override
  String get emailSettingsSubtitle =>
      'E-Mail-Häufigkeit, Like-Zusammenfassung, Digest-Zeitplan';

  @override
  String get manageAccountSubtitle =>
      'Profil, E-Mail, Passwort, Sicherheit, erweiterte Einstellungen';

  @override
  String get changePasswordSubtitle =>
      'Sendet eine E-Mail zum Zurücksetzen des Passworts an deine aktuelle Adresse';

  @override
  String get ignoredUsersSubtitle =>
      'Benutzer anzeigen und verwalten, deren Beiträge für dich ausgeblendet sind';

  @override
  String get deleteAccountExplanation =>
      'Das Entfernen deines Kontos erfolgt im Forum. Mit „Weiter“ öffnest du die Seite und kontaktierst das Team — Discourse-Foren bearbeiten Löschungen nach ihren eigenen Regeln.';

  @override
  String get verificationEmailSent =>
      'Bestätigungs-E-Mail gesendet — klicke auf den Link, um deine neue Adresse zu bestätigen.';

  @override
  String get passwordResetExplanation =>
      'Wir senden dir einen Link zum Zurücksetzen des Passworts. Klicke darauf, um ein neues Passwort zu wählen — die Änderung erfolgt im Forum, nicht in dieser App.';

  @override
  String get sendResetEmail => 'Reset-E-Mail senden';

  @override
  String get deleteAccountDialogBody =>
      'Dein Konto wird vom Forum verwaltet. Bitte wende dich direkt an das Forum-Team, um die Löschung zu beantragen. „Weiter“ öffnet das Forum im Browser, damit du den dortigen Kontakt- bzw. Team-Nachrichtenweg nutzen kannst.';

  @override
  String get initializingForum => 'Forum wird initialisiert…';

  @override
  String get unableToLoadForums => 'Foren konnten nicht geladen werden';

  @override
  String get noForumsToDisplayExplanation =>
      'Es gibt keine Foren zum Anzeigen. Das kann an Berechtigungen oder an der Forumsstruktur liegen.';

  @override
  String get subscribedForums => 'Abonnierte Foren';

  @override
  String get errorLoadingNotifications =>
      'Fehler beim Laden der Benachrichtigungen';

  @override
  String get pullDownToRefresh => 'Zum Aktualisieren nach unten ziehen';

  @override
  String get noNewNotificationsExplanation =>
      'Keine neuen Benachrichtigungen. Schau später wieder vorbei für Neuigkeiten zu Themen, denen du folgst.';

  @override
  String noTagsMatch(Object filter) {
    return 'Keine Schlagwörter passen zu „$filter“.';
  }

  @override
  String noTopicsTagged(Object tag) {
    return 'Keine Themen mit Schlagwort „$tag“';
  }

  @override
  String failedToBanUser2(Object error) {
    return 'Benutzer konnte nicht gesperrt werden: $error';
  }

  @override
  String unbanUserConfirmation(Object username) {
    return 'Sperre von $username wirklich aufheben?';
  }

  @override
  String failedToUnbanUser2(Object error) {
    return 'Sperre konnte nicht aufgehoben werden: $error';
  }

  @override
  String get deletePostsProfilePostsAndComments =>
      'Beiträge, Profilbeiträge und Kommentare löschen';

  @override
  String spamCleanConfirmation(Object username) {
    return '$username wirklich als Spam bereinigen?';
  }

  @override
  String failedToCleanSpam(Object error) {
    return 'Spam-Bereinigung fehlgeschlagen: $error';
  }

  @override
  String get searchUser => 'Benutzer suchen';

  @override
  String get tapToOpen => 'Zum Öffnen tippen';

  @override
  String get imageNotAvailable => 'Bild nicht verfügbar';

  @override
  String get allForumTopicsHaveBeenMarkedAs =>
      'Alle Forenthemen wurden als gelesen markiert';

  @override
  String postsCount(Object count) {
    return '$count Beiträge';
  }

  @override
  String get permissionDeniedToSaveImage =>
      'Keine Berechtigung zum Speichern des Bildes';

  @override
  String get postNotFound => 'Beitrag nicht gefunden.';

  @override
  String get failedToUploadFilePleaseTryAgain =>
      'Datei konnte nicht hochgeladen werden. Bitte erneut versuchen.';

  @override
  String failedToUploadFile2(Object errorMessage) {
    return 'Datei konnte nicht hochgeladen werden: $errorMessage';
  }

  @override
  String get failedToPickFile => 'Datei konnte nicht ausgewählt werden';

  @override
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return 'Nur noch $remainingSlots Anhänge erlaubt. Die ersten $remainingSlots2 Bilder werden verarbeitet.';
  }

  @override
  String get attachmentLimitReachedSkippingRemainingImages =>
      'Anhanglimit erreicht. Restliche Bilder werden übersprungen.';

  @override
  String failedToUploadImagePleaseTryAgain(Object fileName) {
    return '$fileName: Bild konnte nicht hochgeladen werden. Bitte erneut versuchen.';
  }

  @override
  String failedToUploadImage2(Object errorMessage, Object fileName) {
    return '$fileName: Bild konnte nicht hochgeladen werden: $errorMessage';
  }

  @override
  String get failedToPickImage => 'Bild konnte nicht ausgewählt werden';

  @override
  String failedToRemoveAttachment2(Object error) {
    return 'Anhang konnte nicht entfernt werden: $error';
  }

  @override
  String sentFromMobileApp(Object siteName) {
    return 'Gesendet aus der $siteName Mobile-App';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      'Bitte warten, bis alle Anhänge hochgeladen sind';

  @override
  String get imageIsTooLargeToUpload => 'Bild ist zu groß zum Hochladen';

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName ist $fileBytes groß. Dieses Forum erlaubt bis zu $maxBytes.';
  }

  @override
  String get resizeToFitExplanation =>
      'Es kann gerade so weit verkleinert werden, dass es passt — Format und so viel Detail wie möglich bleiben erhalten.';

  @override
  String get failedToPostReplyPleaseTryAgain =>
      'Antwort konnte nicht gesendet werden. Bitte erneut versuchen.';

  @override
  String get pleaseWaitForTheThreadToLoad =>
      'Bitte warten, bis das Thema geladen ist';

  @override
  String get failedToUpdatePostPleaseTryAgain =>
      'Beitrag konnte nicht aktualisiert werden. Bitte erneut versuchen.';

  @override
  String get postDeletedSuccessfully => 'Beitrag gelöscht';

  @override
  String failedToDeletePost(Object error) {
    return 'Beitrag konnte nicht gelöscht werden: $error';
  }

  @override
  String failedToSubmitReport2(Object error) {
    return 'Meldung konnte nicht gesendet werden: $error';
  }

  @override
  String get editHistoryNotAvailable =>
      'Für diesen Beitrag ist kein Bearbeitungsverlauf verfügbar';

  @override
  String get noPermissionToUploadAvatar =>
      'Du hast keine Berechtigung, Avatare hochzuladen';

  @override
  String get avatarUploadedSuccessfully => 'Avatar hochgeladen';

  @override
  String failedToPickImage2(Object error) {
    return 'Bild konnte nicht ausgewählt werden: $error';
  }

  @override
  String get react => 'Reagieren';

  @override
  String get reactionsAreNotEnabledOnThisForum =>
      'Reaktionen sind in diesem Forum nicht aktiviert.';

  @override
  String get noReactionsYet => 'Noch keine Reaktionen';

  @override
  String get searchFilters => 'Suchfilter';

  @override
  String signOutWarning(Object siteName) {
    return 'Du wirst von $siteName abgemeldet. Du kannst dich jederzeit wieder anmelden.';
  }

  @override
  String get suggestedTopics => 'Vorgeschlagene Themen';

  @override
  String get newLabel => 'NEU';

  @override
  String get voteRemoved => 'Stimme zurückgezogen';

  @override
  String get voters => 'Abstimmende';

  @override
  String get noVotesYet => 'Noch keine Stimmen.';

  @override
  String get trustLevels => 'Vertrauensstufen';

  @override
  String get trustLevelsExplanation =>
      'Mitglieder gewinnen Vertrauen durch Lesen und Mitmachen. Jede Stufe schaltet neue Möglichkeiten frei.';

  @override
  String get activity => 'Aktivität';

  @override
  String get dontUpload => 'Nicht hochladen';

  @override
  String get dontAskAgainAlwaysResize =>
      'Nicht mehr fragen — immer passend verkleinern';

  @override
  String get couldNotLoadCategories =>
      'Kategorien konnten nicht geladen werden.';

  @override
  String get switchForum => 'Forum wechseln';
}
