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
  String get newConversation => 'Neue Nachricht';

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
  String get youCannotReplyToThisThread =>
      'Sie können nicht auf diesen Thread antworten';

  @override
  String get pleaseWaitForThreadToLoad =>
      'Bitte warten Sie, bis der Thread geladen ist';

  @override
  String get postCanBeRestoredLater =>
      'Beitrag kann später wiederhergestellt werden';

  @override
  String get postWillBePermanentlyDeleted => 'Beitrag wird endgültig gelöscht';

  @override
  String get enterReasonForDeletingPost =>
      'Geben Sie den Grund für die Löschung dieses Beitrags ein';

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
    return '$username wurde zur Nachricht eingeladen';
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
  String get pleaseSpecifyReason => 'Bitte geben Sie den Grund an';

  @override
  String get selectDate => 'Datum auswählen';

  @override
  String get moreOptions => 'Weitere Optionen';

  @override
  String get topicClosed => 'Thema geschlossen';

  @override
  String get topicOpened => 'Thema geöffnet';

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
  String get deleteConversations => 'Nachrichten löschen';

  @override
  String get noConversations => 'Du hast keine Nachrichten';

  @override
  String get noConversationsMessage =>
      'Du hast noch keine Nachrichten. Schreib eine neue Nachricht, um loszulegen.';

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
  String get sendMessage => 'Nachricht';

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
      'Nachricht konnte nicht gespeichert werden';

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
      'Du musst angemeldet sein, um deine Nachrichten zu sehen.';

  @override
  String errorLoadingConversations(String error) {
    return 'Fehler beim Laden der Nachrichten: $error';
  }

  @override
  String failedToLeaveConversation(String error) {
    return 'Nachricht konnte nicht verlassen werden: $error';
  }

  @override
  String errorLoadingMoreConversations(String error) {
    return 'Fehler beim Laden weiterer Nachrichten: $error';
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
  String get temporary => 'Temporär';

  @override
  String get back => 'Zurück';

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
  String get refresh => 'Aktualisieren';

  @override
  String get share => 'Teilen';

  @override
  String get viewOnWeb => 'Im Web anzeigen';

  @override
  String get reply => 'Antworten';

  @override
  String get vote => 'Abstimmen';

  @override
  String votesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stimmen',
      one: '$count Stimme',
    );
    return '$_temp0';
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
  String get appearance => 'Darstellung';

  @override
  String get appearanceSystem => 'Systemstandard';

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
  String get pleaseSelectEndDate => 'Bitte wählen Sie ein Enddatum';

  @override
  String get spamCleanUser => 'Spam des Benutzers bereinigen';

  @override
  String get deletePrivateConversations => 'Persönliche Nachrichten löschen';

  @override
  String get banTheUserAccount => 'Benutzerkonto sperren';

  @override
  String get handledThreads => 'Behandelte Themen';

  @override
  String get deletedMessages => 'Gelöschte Nachrichten';

  @override
  String get deletedConversations => 'Gelöschte Nachrichten';

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
  String get cleaningSpam => 'Spam bereinigen...';

  @override
  String get writeYourMessage => 'Schreiben Sie Ihre Nachricht...';

  @override
  String get writeYourReply => 'Schreiben Sie Ihre Antwort...';

  @override
  String get conversationCreatedSuccessfully => 'Nachricht gesendet';

  @override
  String get conversationMarkedAsUnread => 'Nachricht als ungelesen markiert';

  @override
  String get conversationClosed => 'Nachricht geschlossen';

  @override
  String get conversationOpened => 'Nachricht geöffnet';

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
    return 'Nachricht konnte nicht als ungelesen markiert werden: $error';
  }

  @override
  String failedToCloseConversation(String error) {
    return 'Nachricht konnte nicht geschlossen werden: $error';
  }

  @override
  String failedToOpenConversation(String error) {
    return 'Nachricht konnte nicht geöffnet werden: $error';
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
  String get enterConversationTitle => 'Titel der Nachricht eingeben';

  @override
  String enterCode(int count) {
    return 'Geben Sie den $count-stelligen Code ein';
  }

  @override
  String get edit => 'Bearbeiten';

  @override
  String get remove => 'Entfernen';

  @override
  String get subject => 'Betreff';

  @override
  String get message => 'Nachricht';

  @override
  String get titleCannotBeEmpty => 'Der Titel darf nicht leer sein';

  @override
  String get conversationUpdatedSuccessfully => 'Nachricht aktualisiert';

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
  String get download => 'Herunterladen';

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
  String get checkConnectionAndRetry =>
      'Überprüfen Sie Ihre Internetverbindung und versuchen Sie es erneut.';

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
  String get undeleteTopic => 'Löschen rückgängig machen';

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
      'Genehmigt, aber der Benachrichtigungsserver war nicht erreichbar, um die Einrichtung abzuschließen. Versuche es später in den Einstellungen erneut.';

  @override
  String get notificationsAreTurnedOffForThisApp =>
      'Benachrichtigungen sind für diese App deaktiviert';

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
  String get solved => 'Gelöst';

  @override
  String get hot => 'Beliebt';

  @override
  String get pinned => 'Angeheftet';

  @override
  String get locked => 'Gesperrt';

  @override
  String get poll => 'Umfrage';

  @override
  String errorLoadingContent(Object error) {
    return 'Fehler beim Laden des Inhalts: $error';
  }

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
  String get editConversation => 'Titel bearbeiten';

  @override
  String get closeConversation => 'Nachricht schließen';

  @override
  String get openConversation => 'Nachricht öffnen';

  @override
  String get leaveConversation2 => 'Nachricht verlassen';

  @override
  String get reportConversation2 => 'Nachricht melden';

  @override
  String get closeConversation2 => 'Nachricht schließen';

  @override
  String get closeConversationConfirmation =>
      'Diese Nachricht schließen? Danach sind keine neuen Antworten mehr möglich.';

  @override
  String get close => 'Schließen';

  @override
  String get openConversation2 => 'Nachricht öffnen';

  @override
  String get openConversationConfirmation =>
      'Diese Nachricht öffnen? Danach sind wieder neue Antworten möglich.';

  @override
  String get open => 'Öffnen';

  @override
  String get leaveConversation3 => 'Nachricht verlassen';

  @override
  String get leaveConversationConfirmation =>
      'Bist du sicher, dass du dich aus dieser Nachricht entfernen möchtest? Dann wirst du sie nicht mehr sehen oder darauf antworten können.';

  @override
  String errorLoadingConversation(Object error) {
    return 'Fehler beim Laden der Nachricht: $error';
  }

  @override
  String get conversationNotFound => 'Nachricht nicht gefunden';

  @override
  String get conversationClosedBanner =>
      'Diese Nachricht ist geschlossen. Das Antworten ist nicht mehr möglich.';

  @override
  String get noMessagesFound => 'Keine Nachrichten gefunden';

  @override
  String get endOfConversation => 'Ende der Diskussion';

  @override
  String get jumpToMessage => 'Zu Nachricht springen';

  @override
  String get editConversation2 => 'Titel bearbeiten';

  @override
  String get failedToLoadMessage2 => 'Nachricht konnte nicht geladen werden';

  @override
  String get cannotEditThisConversation =>
      'Du kannst diese Nachricht nicht bearbeiten';

  @override
  String get options => 'Optionen';

  @override
  String get conversationOpen => 'Offen für Antworten';

  @override
  String get messageTitleHint =>
      'Um was geht es in dieser Diskussion? Schreib einen kurzen Satz.';

  @override
  String get messageOpenForReplies => 'Neue Antworten sind möglich';

  @override
  String get messageClosedForReplies => 'Geschlossen: keine neuen Antworten';

  @override
  String get messageSentWithoutId =>
      'Die Nachricht wurde gesendet, aber das Forum hat sie nicht zurückgegeben. Sieh in deinen Nachrichten nach.';

  @override
  String get messageCouldNotBeSent =>
      'Die Nachricht konnte nicht gesendet werden.';

  @override
  String get messageIdMissing =>
      'Diese Nachricht kann nicht geöffnet werden: Ihre ID fehlt.';

  @override
  String get pleaseAddARecipient => 'Füge mindestens einen Empfänger hinzu';

  @override
  String get archiveMessage => 'Archivieren';

  @override
  String get moveToInbox => 'In Posteingang verschieben';

  @override
  String get messageInbox => 'Posteingang';

  @override
  String get messageArchive => 'Archiv';

  @override
  String get messageListUnread => 'Ungelesen';

  @override
  String get messageListNew => 'Neu';

  @override
  String get messageListSent => 'Gesendet';

  @override
  String removeFromMessageConfirm(String name) {
    return 'Willst du $name wirklich aus dieser Nachricht entfernen?';
  }

  @override
  String uploadingFilename(String filename) {
    return 'Wird hochgeladen: $filename …';
  }

  @override
  String get messageArchived => 'Nachricht archiviert';

  @override
  String get messageMovedToInbox => 'In den Posteingang verschoben';

  @override
  String failedToArchiveMessage(Object error) {
    return 'Nachricht konnte nicht archiviert werden: $error';
  }

  @override
  String failedToMoveMessageToInbox(Object error) {
    return 'Nachricht konnte nicht in den Posteingang verschoben werden: $error';
  }

  @override
  String get noArchivedMessages => 'Du hast keine archivierten Nachrichten';

  @override
  String get noArchivedMessagesHint =>
      'Archiviere eine Nachricht über ihr ⋮-Menü, um sie hier abzulegen.';

  @override
  String groupHasBeenInvited(String group) {
    return '$group wurde zur Nachricht eingeladen';
  }

  @override
  String participantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Teilnehmer',
      one: '1 Teilnehmer',
    );
    return '$_temp0';
  }

  @override
  String get chatChannels => 'Kanäle';

  @override
  String get chatDms => 'DN';

  @override
  String get chatNoChannels => 'Du bist noch keinem Kanal beigetreten!';

  @override
  String get chatNoDms =>
      'Du bist noch keiner Unterhaltung per Direktnachricht beigetreten!';

  @override
  String get chatNoDmsCta => 'Eine Unterhaltung starten';

  @override
  String chatPlaceholderChannel(String channel) {
    return 'Chat in $channel';
  }

  @override
  String chatPlaceholderUsers(String names) {
    return 'Chat mit $names';
  }

  @override
  String get chatPlaceholderGroup => 'In der Gruppe chatten';

  @override
  String get chatPlaceholderSelf => 'Etwas notieren';

  @override
  String get chatPlaceholderArchived =>
      'Der Kanal ist archiviert, du kannst im Moment keine neuen Nachrichten senden.';

  @override
  String get chatPlaceholderClosed =>
      'Der Kanal ist geschlossen, du kannst im Moment keine neuen Nachrichten senden.';

  @override
  String get chatPlaceholderReadOnly =>
      'Der Kanal ist schreibgeschützt, du kannst im Moment keine neuen Nachrichten senden.';

  @override
  String get chatPlaceholderSilenced =>
      'Du kannst derzeit keine Nachrichten senden.';

  @override
  String get chatDeleteConfirm =>
      'Bist du sicher, dass du diese Nachricht löschen willst?';

  @override
  String get chatStartNewDm => 'Neue DN starten';

  @override
  String get chatCreatePersonal => 'Persönlichen Chat erstellen';

  @override
  String get chatCreateGroup => 'Gruppenchat erstellen';

  @override
  String get chatCannotCreate =>
      'Du kannst leider keine Direktnachrichten senden.';

  @override
  String get chatDisabledUser => 'hat den Chat deaktiviert';

  @override
  String get chatSearchPlaceholder => '@jemand';

  @override
  String get chatAddMorePlaceholder => '… weitere Mitglieder hinzufügen';

  @override
  String chatUserNotFound(String name) {
    return '@$name nicht gefunden';
  }

  @override
  String get chatCouldNotStartDm => 'Der Chat konnte nicht gestartet werden.';

  @override
  String get chatSignInTitle => 'Melde dich an, um den Chat zu nutzen';

  @override
  String get chatSignInMessage =>
      'Du musst angemeldet sein, um Chat-Kanäle zu sehen und ihnen beizutreten.';

  @override
  String get chatDirectMessage => 'Direktnachricht';

  @override
  String get chatNotAvailable => 'Chat ist in diesem Forum nicht verfügbar.';

  @override
  String get chatAttachFile => 'Datei anhängen';

  @override
  String get chatRemoveUpload => 'Datei löschen';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get postNeedsApprovalTitle => 'Beitrag muss genehmigt werden';

  @override
  String get postNeedsApprovalBody =>
      'Wir haben deinen neuen Beitrag erhalten. Dieser muss jedoch von einem Moderator genehmigt werden, bevor er angezeigt wird. Bitte habe etwas Geduld.';

  @override
  String failedToCreateConversation(Object error) {
    return 'Nachricht konnte nicht gesendet werden: $error';
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
      'Lösche dein Konto und deine Beiträge, sofern das Forum es erlaubt. Andernfalls kann das Team es für dich entfernen.';

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
  String get subscribedForums => 'Abonnierte Foren';

  @override
  String get errorLoadingNotifications =>
      'Fehler beim Laden der Benachrichtigungen';

  @override
  String get pullDownToRefresh => 'Zum Aktualisieren nach unten ziehen';

  @override
  String get noNewNotificationsExplanation =>
      'Du wirst in diesem Panel über für dich direkt relevante Aktivitäten benachrichtigt, einschließlich Antworten auf deine Themen und Beiträge, wenn dich jemand mit @ erwähnt oder zitiert und wenn jemand auf Themen antwortet, die du beobachtest. Benachrichtigungen werden auch an deine E-Mail-Adresse gesendet, wenn du dich eine Weile nicht eingeloggt hast.';

  @override
  String noTagsMatch(Object filter) {
    return 'Keine Schlagwörter passen zu „$filter“.';
  }

  @override
  String noTopicsTagged(Object tag) {
    return 'Keine Themen mit Schlagwort „$tag“';
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
  String get suggestedMessages => 'Vorgeschlagene Nachrichten';

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
  String get explore => 'Entdecken';

  @override
  String get tags => 'Schlagwörter';

  @override
  String get community => 'Community';

  @override
  String get users => 'Benutzer';

  @override
  String get groups => 'Gruppen';

  @override
  String get invites => 'Einladungen';

  @override
  String get account => 'Konto';

  @override
  String get drafts => 'Entwürfe';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String signedInAs(String username) {
    return 'Angemeldet als $username';
  }

  @override
  String get notSignedIn => 'Nicht angemeldet';

  @override
  String get deviceWillNotShowAlertsUntilAllowedInSettings =>
      'Dein Gerät zeigt keine Hinweise an, bis du Benachrichtigungen in den Einstellungen erlaubst.';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get notificationsOnThisDevice => 'Benachrichtigungen auf diesem Gerät';

  @override
  String get notificationsGrantOnSubtitle =>
      'Antworten, Erwähnungen und Nachrichten aus diesem Forum werden hierher zugestellt.';

  @override
  String get notificationsGrantOffSubtitle =>
      'Einmal im Forum bestätigen, um Antworten, Erwähnungen und Nachrichten hier zu erhalten.';

  @override
  String get turnOn => 'Einschalten';

  @override
  String get couldNotTurnOffNotifications =>
      'Benachrichtigungen konnten nicht ausgeschaltet werden. Versuche es später erneut.';

  @override
  String actionCodeTopicCreated(String when) {
    return 'Created this topic $when';
  }

  @override
  String actionCodePublicTopic(String when) {
    return 'Hat dieses Thema öffentlich gemacht, $when';
  }

  @override
  String actionCodeOpenTopic(String when) {
    return 'Hat dies in ein Thema umgewandelt, $when';
  }

  @override
  String actionCodePrivateTopic(String when) {
    return 'Hat dieses Thema in eine Nachricht umgewandelt, $when';
  }

  @override
  String actionCodeSplitTopic(String when) {
    return 'Hat dieses Thema aufgeteilt, $when';
  }

  @override
  String actionCodeInvitedUser(String who, String when) {
    return 'Hat $who eingeladen, $when';
  }

  @override
  String actionCodeInvitedGroup(String who, String when) {
    return 'Hat $who eingeladen, $when';
  }

  @override
  String actionCodeUserLeft(String who, String when) {
    return '$who hat sich selbst von dieser Nachricht entfernt, $when';
  }

  @override
  String actionCodeRemovedUser(String who, String when) {
    return 'Hat $who entfernt, $when';
  }

  @override
  String actionCodeRemovedGroup(String who, String when) {
    return 'Hat $who entfernt, $when';
  }

  @override
  String actionCodeAutobumped(String when) {
    return 'Thema wurde automatisch nach oben geschoben, $when';
  }

  @override
  String actionCodeTagsChanged(String when) {
    return 'Schlagwörter aktualisiert $when';
  }

  @override
  String actionCodeCategoryChanged(String when) {
    return 'Kategorie aktualisiert $when';
  }

  @override
  String get actionCodeForwarded => 'Hat die obige E-Mail weitergeleitet';

  @override
  String actionCodeAutoclosedEnabled(String when) {
    return 'Geschlossen, $when';
  }

  @override
  String actionCodeAutoclosedDisabled(String when) {
    return 'Geöffnet, $when';
  }

  @override
  String actionCodeClosedEnabled(String when) {
    return 'Geschlossen, $when';
  }

  @override
  String actionCodeClosedDisabled(String when) {
    return 'Geöffnet, $when';
  }

  @override
  String actionCodeArchivedEnabled(String when) {
    return 'Archiviert, $when';
  }

  @override
  String actionCodeArchivedDisabled(String when) {
    return 'Aus dem Archiv geholt, $when';
  }

  @override
  String actionCodePinnedEnabled(String when) {
    return 'Angeheftet, $when';
  }

  @override
  String actionCodePinnedDisabled(String when) {
    return 'Losgelöst, $when';
  }

  @override
  String actionCodePinnedGloballyEnabled(String when) {
    return 'Global angeheftet, $when';
  }

  @override
  String actionCodePinnedGloballyDisabled(String when) {
    return 'Losgelöst, $when';
  }

  @override
  String actionCodeVisibleEnabled(String when) {
    return 'Sichtbar gemacht, $when';
  }

  @override
  String actionCodeVisibleDisabled(String when) {
    return 'Unsichtbar gemacht, $when';
  }

  @override
  String actionCodeBannerEnabled(String when) {
    return 'Hat dieses Banner erstellt, $when. Es wird oberhalb jeder Seite angezeigt, bis es vom Benutzer weggeklickt wird.';
  }

  @override
  String actionCodeBannerDisabled(String when) {
    return 'Hat dieses Banner entfernt, $when. Es wird nicht mehr oberhalb jeder Seite angezeigt.';
  }

  @override
  String actionCodeAssigned(String who, String when) {
    return '$who zugeordnet $when';
  }

  @override
  String actionCodeUnassigned(String who, String when) {
    return 'Zuordnung von $who aufgehoben $when';
  }

  @override
  String actionCodeReassigned(String who, String when) {
    return '$who $when erneut zugeordnet';
  }

  @override
  String localDateToday(String time) {
    return 'Heute $time';
  }

  @override
  String localDateTomorrow(String time) {
    return 'Morgen $time';
  }

  @override
  String localDateYesterday(String time) {
    return 'Gestern $time';
  }

  @override
  String get eventExpired => 'Abgelaufen';

  @override
  String get eventEveryDay => 'Täglich';

  @override
  String get eventEveryWeekday => 'Jeden Wochentag';

  @override
  String get eventEveryWeek => 'Jede Woche an diesem Wochentag';

  @override
  String get eventEveryTwoWeeks => 'Alle zwei Wochen an diesem Wochentag';

  @override
  String get eventEveryFourWeeks => 'Alle vier Wochen an diesem Wochentag';

  @override
  String get eventEveryMonth => 'Jeden Monat an diesem Wochentag';

  @override
  String get errorNoConnection =>
      'Das Forum ist nicht erreichbar. Prüfen Sie Ihre Verbindung und versuchen Sie es erneut.';

  @override
  String get errorTimedOut =>
      'Das Forum hat zu lange nicht geantwortet. Bitte versuchen Sie es erneut.';

  @override
  String get errorPaywalled =>
      'Dies ist nur für zahlende Mitglieder des Forums verfügbar.';

  @override
  String get errorBlocked =>
      'Die Firewall des Forums hat die App blockiert. Versuchen Sie es später erneut oder öffnen Sie das Forum im Browser.';

  @override
  String get errorNotAllowed =>
      'Sie haben keinen Zugriff darauf. Eine Anmeldung könnte helfen.';

  @override
  String get errorNotFound => 'Das existiert nicht oder wurde entfernt.';

  @override
  String get errorRateLimited =>
      'Sie tun das zu oft. Bitte warten Sie einen Moment und versuchen Sie es erneut.';

  @override
  String get errorForumDown =>
      'Das Forum antwortet gerade nicht. Bitte versuchen Sie es später erneut.';

  @override
  String get deleteSpammer => 'Spammer löschen';

  @override
  String get yesDeleteSpammer => 'Ja, lösche den Spammer';

  @override
  String get deleteSpammerConfirm =>
      'Du wirst die Beiträge und Themen dieses Benutzers löschen, sein Konto entfernen, seine IP-Adresse für Neuanmeldungen sperren und seine E-Mail-Adresse auf eine permanente Sperrliste setzen. Bist du dir sicher, dass dieser Benutzer wirklich ein Spammer ist?';

  @override
  String get userWasDeleted => 'Der Benutzer wurde gelöscht.';

  @override
  String get deleteMyAccount => 'Lösche mein Benutzerkonto';

  @override
  String get deleteAccountConfirm =>
      'Möchtest du wirklich dein Benutzerkonto permanent löschen? Diese Aktion kann nicht rückgängig gemacht werden!';

  @override
  String get deletedYourself =>
      'Dein Benutzerkonto wurde erfolgreich gelöscht.';

  @override
  String get deleteYourselfNotAllowed =>
      'Bitte kontaktiere ein Team-Mitglied, wenn du möchtest, dass dein Konto gelöscht wird.';

  @override
  String get createTopic => 'Thema erstellen';

  @override
  String get discardPostQuestion => 'Willst du deinen Beitrag verwerfen?';

  @override
  String get discardChangesQuestion =>
      'Möchtest du deine Änderungen verwerfen?';

  @override
  String get discardChanges => 'Änderungen verwerfen';

  @override
  String get saveDraft => 'Entwurf speichern';

  @override
  String get notificationSettings => 'Benachrichtigungseinstellungen';

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
      other: 'Aufrufe',
      one: 'Aufruf',
    );
    return '$_temp0';
  }

  @override
  String topicMapLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Likes',
      one: 'Like',
    );
    return '$_temp0';
  }

  @override
  String topicMapLinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Links',
      one: 'Link',
    );
    return '$_temp0';
  }

  @override
  String topicMapUsers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Benutzer',
    );
    return '$_temp0';
  }

  @override
  String get markAsSolution => 'Als Lösung markieren';

  @override
  String get unmarkAsSolution => 'Lösungsmarkierung entfernen';

  @override
  String searchForumName(String forum) {
    return '$forum durchsuchen';
  }

  @override
  String countActiveThisMonth(String formatted) {
    return '$formatted aktiv in diesem Monat';
  }

  @override
  String countMembers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted Mitglieder',
      one: '$formatted Mitglied',
    );
    return '$_temp0';
  }

  @override
  String countTopics(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted Themen',
      one: '$formatted Thema',
    );
    return '$_temp0';
  }

  @override
  String categoryNewThisWeek(int count) {
    return '$count neu diese Woche';
  }

  @override
  String get categoriesView => 'Kategorien';

  @override
  String get allCategories => 'Alle Kategorien';

  @override
  String get allTags => 'Alle Schlagwörter';

  @override
  String get myPosts => 'Meine Beiträge';

  @override
  String get drawerIntroduction =>
      'Die Kategorien, Schlagwörter und dein Konto in diesem Forum findest du alle in diesem Menü. Öffne es jederzeit wieder mit der Menü-Schaltfläche.';

  @override
  String trustLevelN(int level) {
    return 'Vertrauensstufe $level';
  }

  @override
  String get filterNew => 'Neu';

  @override
  String get filterTop => 'Top';

  @override
  String get levelWatching => 'Beobachten';

  @override
  String get levelWatchingFirstPost => 'Ersten Beitrag beobachten';

  @override
  String get levelTracking => 'Verfolgen';

  @override
  String get levelNormal => 'Normal';

  @override
  String get levelMuted => 'Stummgeschaltet';

  @override
  String get chooseCategory => 'Kategorie auswählen';

  @override
  String get signInToPostAndGetNotifications =>
      'Anmelden, um zu schreiben und Benachrichtigungen zu erhalten';

  @override
  String forumBlocksNotificationServer(Object forumName) {
    return '$forumName blockiert unseren Benachrichtigungsserver, daher kommen Benachrichtigungen möglicherweise nicht an. Du kannst sie in den Einstellungen ausschalten.';
  }

  @override
  String get relatedTopics => 'Ähnliche Themen';

  @override
  String get relatedMessages => 'Ähnliche Nachrichten';

  @override
  String moreInCategory(String category) {
    return 'Mehr in $category';
  }

  @override
  String get latestTopics => 'Neueste Themen';

  @override
  String get pushGroupMessages => 'Nachrichten und Chat';

  @override
  String get pushGroupMessagesHint =>
      'Persönliche Nachrichten, Gruppenpostfächer und Chat';

  @override
  String get pushGroupReplies => 'Antworten und Erwähnungen';

  @override
  String get pushGroupRepliesHint =>
      'Antworten, Erwähnungen, Zitate und beobachtete Themen';

  @override
  String get pushGroupReactions => 'Likes und Reaktionen';

  @override
  String get pushGroupReactionsHint =>
      'Likes und Reaktionen auf deine Beiträge';

  @override
  String get pushGroupOther => 'Alles andere';

  @override
  String get pushGroupOtherHint =>
      'Abzeichen, Erinnerungen, akzeptierte Antworten und mehr';

  @override
  String get pushChannelOther => 'Weitere Benachrichtigungen';

  @override
  String get couldNotChangePushSetting =>
      'Diese Einstellung konnte nicht geändert werden. Versuche es später erneut.';

  @override
  String neverMissAReplyOn(Object forumName) {
    return 'Verpasse keine Antwort auf $forumName';
  }

  @override
  String get notificationsPitch =>
      'Antworten, Erwähnungen, Nachrichten und Chat auf deinem Sperrbildschirm, meist innerhalb von 10 Minuten. Welche, kannst du jederzeit in den Einstellungen wählen.';

  @override
  String get notificationsStepAllow =>
      'Benachrichtigungen auf diesem Telefon erlauben';

  @override
  String get notificationsStepAllowed =>
      'Benachrichtigungen sind auf diesem Telefon erlaubt';

  @override
  String notificationsStepApprove(Object forumName) {
    return 'Auf $forumName genehmigen';
  }

  @override
  String get notificationsReadOnlyNote =>
      'Nur lesend: kann nicht posten, antworten oder deine Nachrichten lesen';

  @override
  String get notificationPreviewReply =>
      'Jane hat dir geantwortet: Willkommen an Bord! Schön, dass du uns gefunden hast.';

  @override
  String get notificationPreviewMessage =>
      'Sam hat dir eine Nachricht geschickt: Kommst du am Freitag?';

  @override
  String get notificationPreviewNow => 'jetzt';

  @override
  String get notificationPreviewEarlier => 'vor 5 Min.';

  @override
  String get activityReplied => 'Geantwortet';

  @override
  String get activityStartedTopic => 'Thema erstellt';

  @override
  String get activityLiked => 'Gefällt mir';

  @override
  String get activitySolution => 'Lösung';

  @override
  String get activityAcceptedBy => 'akzeptiert von';

  @override
  String get activityAwaitingApproval => 'Wartet auf Freigabe';

  @override
  String get activityFilterTopics => 'Themen';

  @override
  String get activityFilterReplies => 'Antworten';

  @override
  String get activityFilterLikes => 'Likes';

  @override
  String get activityFilterPending => 'Ausstehend';

  @override
  String get sectionToday => 'Heute';

  @override
  String get sectionThisWeek => 'Diese Woche';

  @override
  String get sectionEarlier => 'Früher';

  @override
  String draftsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Entwürfe warten',
      one: '1 Entwurf wartet',
    );
    return '$_temp0';
  }

  @override
  String get resumeDrafts => 'Fortsetzen';

  @override
  String get myPostsEmpty => 'Noch keine Beiträge';

  @override
  String get myPostsEmptyHint =>
      'Themen, die du erstellst, und Antworten, die du schreibst, erscheinen hier.';

  @override
  String get activityEmptyTopics => 'Noch keine Themen';

  @override
  String get activityEmptyReplies => 'Noch keine Antworten';

  @override
  String get activityEmptyLikes => 'Noch keine Likes vergeben';

  @override
  String get activityEmptySolved => 'Noch keine Lösungen';

  @override
  String get viewProfile => 'Profil ansehen';

  @override
  String get yourStuff => 'Deine Sachen';

  @override
  String get accountAndPrivacy => 'Konto und Privatsphäre';

  @override
  String profileStatPosts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Beiträge',
      one: 'Beitrag',
    );
    return '$_temp0';
  }

  @override
  String profileStatLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Likes',
      one: 'Like',
    );
    return '$_temp0';
  }

  @override
  String profileStatDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tage',
      one: 'Tag',
    );
    return '$_temp0';
  }

  @override
  String get profileStatSolved => 'gelöst';

  @override
  String joinForum(String forum) {
    return '$forum beitreten';
  }

  @override
  String get guestBenefitPost => 'Antworten und Themen starten';

  @override
  String get guestBenefitNotify =>
      'Benachrichtigt werden, wenn jemand antwortet';

  @override
  String get guestBenefitSave => 'Beiträge merken und Entwürfe behalten';

  @override
  String get guestBenefitChat => 'Chatten und Nachrichten senden';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get aboutThisForum => 'Über dieses Forum';

  @override
  String get drawerMore => 'Mehr';

  @override
  String get goToYourProfile => 'Zu deinem Profil';

  @override
  String profileJoined(String date) {
    return 'Dabei seit $date';
  }

  @override
  String profileSeen(String when) {
    return 'Gesehen $when';
  }

  @override
  String profileLocalTime(String time) {
    return '$time Ortszeit';
  }

  @override
  String get profileTabSummary => 'Übersicht';

  @override
  String get summaryTopReplies => 'Top-Antworten';

  @override
  String get summaryTopTopics => 'Top-Themen';

  @override
  String get summaryMostLikedBy => 'Am meisten geliked von';

  @override
  String get summaryMostLiked => 'Am meisten geliked';

  @override
  String get summaryMostRepliedTo => 'Am meisten geantwortet';

  @override
  String get summaryTopLinks => 'Top-Links';

  @override
  String get summaryTopCategories => 'Top-Kategorien';

  @override
  String get featuredTopic => 'Hervorgehobenes Thema';

  @override
  String get profileDetails => 'Details';

  @override
  String get followUser => 'Folgen';

  @override
  String get unfollowUser => 'Nicht mehr folgen';

  @override
  String get profileSuspended => 'Gesperrt';

  @override
  String get searchBookmarks => 'Lesezeichen durchsuchen';

  @override
  String get bookmarksFilterReminders => 'Erinnerungen';

  @override
  String get bookmarkWholeTopic => 'Ganzes Thema';

  @override
  String bookmarkSaved(String when) {
    return 'gespeichert $when';
  }

  @override
  String bookmarkPostNumber(int number) {
    return 'Beitrag #$number';
  }

  @override
  String reminderToday(String time) {
    return 'Heute, $time';
  }

  @override
  String reminderTomorrow(String time) {
    return 'Morgen, $time';
  }

  @override
  String reminderDue(String when) {
    return 'Fällig · $when';
  }

  @override
  String get addBookmarkLabel => 'Notiz hinzufügen';

  @override
  String get editBookmarkLabel => 'Notiz bearbeiten';

  @override
  String get bookmarkLabelHint => 'Wofür ist das?';

  @override
  String get pinBookmark => 'Oben anheften';

  @override
  String get unpinBookmark => 'Lösen';

  @override
  String get bookmarkRemoved => 'Lesezeichen entfernt';

  @override
  String get undo => 'Rückgängig';

  @override
  String get bookmarksNoMatch => 'Keine passenden Lesezeichen';

  @override
  String get addReminder => 'Erinnerung hinzufügen';

  @override
  String get bookmarksEmpty => 'Noch keine Lesezeichen';

  @override
  String get bookmarksEmptyHint =>
      'Setze bei einem Beitrag ein Lesezeichen, dann wartet er hier auf dich.';

  @override
  String get draftKindNewTopic => 'Neues Thema';

  @override
  String draftMessageTo(String names) {
    return 'Nachricht an $names';
  }

  @override
  String get untitledTopic => 'Thema ohne Titel';

  @override
  String get draftDiscarded => 'Entwurf verworfen';

  @override
  String get draftsEmpty => 'Noch keine Entwürfe';

  @override
  String get draftsEmptyHint =>
      'Entwürfe speichern sich beim Tippen. Beginne eine Antwort oder ein Thema, dann wartet es hier auf dich.';

  @override
  String get privacySection => 'Privatsphäre';

  @override
  String get changeEmailSubtitle =>
      'Wir senden einen Bestätigungslink an die neue Adresse';

  @override
  String get aboutMe => 'Über mich';

  @override
  String get aboutMeHelper => 'Wird oben in deinem Profil angezeigt';

  @override
  String get aboutMeMarkdownHint =>
      'Markdown funktioniert: **fett**, Links, :emoji:';

  @override
  String get addCover => 'Titelbild hinzufügen';

  @override
  String get changeCover => 'Titelbild ändern';

  @override
  String get birthdayHint =>
      'Das Forum feiert ihn mit dir. Das Jahr wird nicht gespeichert.';

  @override
  String get birthdayRemoved => 'Geburtstag entfernt';

  @override
  String get birthdaySaved => 'Geburtstag gespeichert';

  @override
  String get cardBackground => 'Kartenhintergrund';

  @override
  String get cardBackgroundExplanation =>
      'Hinter deiner Benutzerkarte, wenn jemand auf dein Bild tippt';

  @override
  String get cardBackgroundRemoved => 'Kartenhintergrund entfernt';

  @override
  String get cardBackgroundSheetHint =>
      'Wird hinter deiner Benutzerkarte angezeigt. Breite Fotos eignen sich am besten.';

  @override
  String get changeProfilePicture => 'Profilbild ändern';

  @override
  String get changeUsername => 'Benutzernamen ändern';

  @override
  String changeUsernameExplanation(String username) {
    return 'Erwähnungen und Zitate von @$username in Beiträgen wechseln zum neuen Namen. Alte Links zu deinem Profil funktionieren nicht mehr.';
  }

  @override
  String get chooseFromLibrary => 'Aus der Mediathek wählen';

  @override
  String get coverPhoto => 'Titelbild';

  @override
  String get coverPhotoSheetHint =>
      'Wird oben in deinem Profil hinter deinem Bild angezeigt. Breite Fotos eignen sich am besten, etwa 3:1.';

  @override
  String get coverRemoved => 'Titelbild entfernt';

  @override
  String get day => 'Tag';

  @override
  String get month => 'Monat';

  @override
  String get displayName => 'Anzeigename';

  @override
  String displayNameHelper(String username) {
    return 'Wird bei deinen Beiträgen angezeigt. Dein Benutzername bleibt @$username.';
  }

  @override
  String get emailPasswordInAccount => 'E-Mail, Passwort und Anmeldung';

  @override
  String get featureATopic => 'Thema hervorheben';

  @override
  String get featureATopicHint =>
      'Hefte eines deiner Themen oben an dein Profil.';

  @override
  String get featuredTopicChanged => 'Hervorgehobenes Thema geändert';

  @override
  String get featuredTopicNone =>
      'Keines. Hefte eines deiner Themen an dein Profil.';

  @override
  String get featuredTopicRemoved => 'Hervorgehobenes Thema entfernt';

  @override
  String get featuredTopicRules =>
      'Nachrichten und Themen in privaten Kategorien können nicht hervorgehoben werden.';

  @override
  String get fieldManagedBySignIn =>
      'Dieses Forum verwaltet das über seine eigene Anmeldung. Ändere es dort.';

  @override
  String get flair => 'Flair';

  @override
  String flairChangedTo(String group) {
    return 'Flair zu $group geändert';
  }

  @override
  String get flairRemoved => 'Flair entfernt';

  @override
  String get flairSheetHint =>
      'Ein kleines Symbol auf deinem Bild, von einer Gruppe, in der du bist.';

  @override
  String forumPictureN(int number) {
    return 'Forumbild $number';
  }

  @override
  String forumQuestionNeedsAnswer(String question) {
    return '$question braucht eine Antwort';
  }

  @override
  String get forumQuestionRequired =>
      'Dieses Forum bittet alle um eine Antwort';

  @override
  String get forumQuestionSetByStaff => 'Vom Forum-Team festgelegt';

  @override
  String get forumQuestionsIntro =>
      'Fragen dieses Forums. * bedeutet Pflichtangabe.';

  @override
  String get forumQuestionsNoneAnswered => 'Noch nicht beantwortet';

  @override
  String get fromThisForum => 'Von diesem Forum';

  @override
  String get hideMyProfile => 'Mein öffentliches Profil verbergen';

  @override
  String get hideMyProfileExplanation =>
      'Andere sehen nur deinen Namen, dein Bild und deine Beiträge';

  @override
  String get letterAvatar => 'Buchstabe';

  @override
  String get moreAboutYou => 'Mehr über dich';

  @override
  String namesAndMore(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weitere',
      one: '1 weiteres',
    );
    return '$names und $_temp0';
  }

  @override
  String get newUsername => 'Neuer Benutzername';

  @override
  String get noFlair => 'Kein Flair';

  @override
  String noGravatarFound(String service) {
    return '$service hat kein Bild für deine E-Mail-Adresse';
  }

  @override
  String get noTitle => 'Kein Titel';

  @override
  String get noTopicsMatch => 'Keines deiner Themen passt';

  @override
  String get noTopicsToFeature => 'Du hast noch keine Themen erstellt';

  @override
  String get notSet => 'Nicht festgelegt';

  @override
  String get orUse => 'Oder verwende';

  @override
  String get pictureManagedBySignIn =>
      'Dieses Forum legt dein Bild über seine eigene Anmeldung fest';

  @override
  String get primaryGroup => 'Primäre Gruppe';

  @override
  String primaryGroupChangedTo(String group) {
    return 'Primäre Gruppe zu $group geändert';
  }

  @override
  String get primaryGroupRemoved => 'Primäre Gruppe entfernt';

  @override
  String get primaryGroupSheetHint =>
      'Deine Hauptgruppe, angezeigt auf deiner Benutzerkarte.';

  @override
  String get profileLoadFailed => 'Dein Profil konnte nicht geladen werden';

  @override
  String get profileNowHidden => 'Dein Profil ist verborgen';

  @override
  String get profileNowPublic => 'Dein Profil ist öffentlich';

  @override
  String get profilePicture => 'Profilbild';

  @override
  String get profilePictureChanged => 'Profilbild geändert';

  @override
  String get profileSaveFailed =>
      'Speichern fehlgeschlagen. Versuche es erneut.';

  @override
  String get profileSectionNameAndAbout => 'Name und Über mich';

  @override
  String get profileSectionNextToName => 'Neben deinem Namen';

  @override
  String get profileSectionOnProfile => 'In deinem Profil';

  @override
  String get profileSectionPrivacyAndTime => 'Privatsphäre und Zeit';

  @override
  String get removeCardBackground => 'Kartenhintergrund entfernen';

  @override
  String get removeCover => 'Titelbild entfernen';

  @override
  String get removeFeaturedTopic => 'Hervorgehobenes Thema entfernen';

  @override
  String get searchTimezones => 'Zeitzonen suchen';

  @override
  String get searchYourTopics => 'Deine Themen durchsuchen';

  @override
  String get seeProfileAsOthersDo => 'Profil aus Sicht anderer ansehen';

  @override
  String get timezone => 'Zeitzone';

  @override
  String timezoneChangedTo(String zone) {
    return 'Zeitzone zu $zone geändert';
  }

  @override
  String timezoneWithTime(String zone, String time) {
    return '$zone · jetzt $time';
  }

  @override
  String timezonesMatchingPhone(String offset) {
    return 'Passt zur Uhr dieses Telefons ($offset)';
  }

  @override
  String titleChangedTo(String title) {
    return 'Titel zu $title geändert';
  }

  @override
  String get titleFromBadge => 'Abzeichen';

  @override
  String titleFromBadgeEarned(String date) {
    return 'Abzeichen · erhalten am $date';
  }

  @override
  String titleFromGroup(String group) {
    return 'Gruppe $group';
  }

  @override
  String get titleGrantedByStaff => 'Vom Forum-Team vergeben';

  @override
  String get titleRemoved => 'Titel entfernt';

  @override
  String get titleSheetHint =>
      'Wird nach deinem Namen in deinem Profil und bei deinen Beiträgen angezeigt.';

  @override
  String get username => 'Benutzername';

  @override
  String get usernameAvailable => 'Verfügbar';

  @override
  String usernameChanged(String username) {
    return 'Dein Benutzername ist jetzt @$username';
  }

  @override
  String get usernameLockedExplanation =>
      'In diesem Forum können Mitglieder ihren Benutzernamen nur kurz nach der Registrierung ändern. Ein Moderator kann ihn für dich ändern.';

  @override
  String get yourPhoto => 'Dein Foto';

  @override
  String get chooseEmoji => 'Emoji auswählen';

  @override
  String get clearStatus => 'Status löschen';

  @override
  String get clearText => 'Leeren';

  @override
  String get inOneHour => 'In einer Stunde';

  @override
  String get never => 'Nie';

  @override
  String get pauseNotifications => 'Benachrichtigungen pausieren';

  @override
  String get pauseNotificationsUntilStatusClears =>
      'Bis dein Status entfernt wird';

  @override
  String get pickATime => 'Zeit wählen';

  @override
  String get removeStatusAfter => 'Status entfernen';

  @override
  String get searchEmoji => 'Emoji suchen';

  @override
  String get setStatus => 'Status festlegen';

  @override
  String get setAStatus => 'Status festlegen';

  @override
  String get statusUpdated => 'Status aktualisiert';

  @override
  String get whatAreYouDoing => 'Was machst du gerade?';

  @override
  String cardPosted(String when) {
    return 'Letzter Beitrag $when';
  }

  @override
  String get change => 'Ändern';

  @override
  String get copyProfileLink => 'Link zum Profil kopieren';

  @override
  String get ignore => 'Ignorieren';

  @override
  String memberOfGroup(String group) {
    return 'Mitglied von $group';
  }

  @override
  String get mute => 'Stummschalten';

  @override
  String get unmute => 'Stummschaltung aufheben';

  @override
  String openProfileOf(String username) {
    return 'Profil von @$username öffnen';
  }

  @override
  String profileIsPrivate(String username) {
    return 'Das Profil von $username ist privat.';
  }

  @override
  String showOnlyTheirPostsHere(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'die $count Beiträge',
      one: 'den Beitrag',
    );
    return 'In diesem Thema nur $_temp0 von $name anzeigen';
  }

  @override
  String showOnlyYourPostsHere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'deine $count Beiträge',
      one: 'deinen Beitrag',
    );
    return 'In diesem Thema nur $_temp0 anzeigen';
  }

  @override
  String userIgnoredFor4Months(String username) {
    return '@$username wird 4 Monate lang ignoriert';
  }

  @override
  String userMuted(String username) {
    return '@$username stummgeschaltet';
  }

  @override
  String userUnmuted(String username) {
    return 'Stummschaltung für @$username aufgehoben';
  }

  @override
  String get youParenthetical => '(du)';

  @override
  String get topicStatusClosedHelp =>
      'Dieses Thema ist geschlossen. Das Antworten ist nicht mehr möglich.';

  @override
  String get topicStatusArchivedHelp =>
      'Dieses Thema ist archiviert; es ist eingefroren und kann nicht mehr geändert werden';

  @override
  String get topicStatusClosedArchivedHelp =>
      'Dieses Thema ist geschlossen. Das Antworten oder das Bearbeiten ist nicht mehr möglich.';

  @override
  String get topicStatusPinnedTitle => 'Angeheftet';

  @override
  String get topicStatusPinnedHelp =>
      'Dieses Thema ist für dich angeheftet; es wird immer am Anfang seiner Kategorie auftauchen';

  @override
  String get topicStatusPinnedGloballyTitle => 'Global angeheftet';

  @override
  String get topicStatusPinnedGloballyHelp =>
      'Dieses Thema ist global angeheftet; es wird immer am Anfang der Liste der aktuellen Themen und in seiner Kategorie auftauchen';

  @override
  String get topicStatusUnpinnedTitle => 'Losgelöst';

  @override
  String get topicStatusUnpinnedHelp =>
      'Dieses Thema ist für dich losgelöst; es wird in der normalen Reihenfolge angezeigt';

  @override
  String get topicStatusUnlistedHelp =>
      'Dieses Thema ist unsichtbar. Es wird in keiner Themenliste angezeigt und kann nur mit einem direkten Link betrachtet werden.';

  @override
  String get topicStatusWarningHelp => 'Dies ist eine offizielle Warnung.';

  @override
  String get notificationReasonWatchingTag =>
      'Du wirst Benachrichtigungen erhalten, weil du ein Schlagwort an diesem Thema beobachtest.';

  @override
  String get notificationReasonWatchingCategory =>
      'Du wirst Benachrichtigungen erhalten, weil du diese Kategorie beobachtest.';

  @override
  String get notificationReasonWatchingAuto =>
      'Du wirst Benachrichtigungen erhalten, weil dieses Thema automatisch von dir beobachtet wird.';

  @override
  String get notificationReasonWatching =>
      'Du wirst Benachrichtigungen erhalten, weil du dieses Thema beobachtest.';

  @override
  String get notificationReasonWatchingCreated =>
      'Du wirst Benachrichtigungen erhalten, weil du dieses Thema erstellt hast.';

  @override
  String get notificationReasonTrackingCategory =>
      'Du wirst die Anzahl neuer Antworten sehen, weil du diese Kategorie verfolgst.';

  @override
  String get notificationReasonTrackingReplied =>
      'Du wirst die Anzahl neuer Antworten sehen, weil du einen Beitrag in diesem Thema geschrieben hast.';

  @override
  String get notificationReasonTracking =>
      'Du wirst die Anzahl neuer Antworten sehen, weil du dieses Thema verfolgst.';

  @override
  String get notificationReasonTrackingRead =>
      'Du wirst die Anzahl neuer Antworten sehen, weil du dieses Thema gelesen hast.';

  @override
  String get notificationReasonNormal =>
      'Du wirst benachrichtigt, wenn jemand deinen Namen mit @ erwähnt oder auf deinen Beitrag antwortet.';

  @override
  String get notificationReasonMutedCategory =>
      'Du ignorierst alle Benachrichtigungen dieser Kategorie.';

  @override
  String get notificationReasonMuted =>
      'Du ignorierst alle Benachrichtigungen dieses Themas.';

  @override
  String get notificationLevelWatching => 'Beobachten';

  @override
  String get notificationLevelWatchingFirstPost => 'Ersten Beitrag beobachten';

  @override
  String get notificationLevelTracking => 'Verfolgen';

  @override
  String get notificationLevelNormal => 'Normal';

  @override
  String get notificationLevelMuted => 'Stummgeschaltet';

  @override
  String get topicWatchingDescription =>
      'Du wirst über jeden neuen Beitrag in diesem Thema benachrichtigt und die Anzahl der neuen Antworten wird angezeigt.';

  @override
  String get topicTrackingDescription =>
      'Die Anzahl der neuen Antworten wird bei diesem Thema angezeigt. Du wirst benachrichtigt, wenn jemand deinen Namen mit @ erwähnt oder auf deinen Beitrag antwortet.';

  @override
  String get topicNormalDescription =>
      'Du wirst benachrichtigt, wenn jemand deinen Namen mit @ erwähnt oder auf deinen Beitrag antwortet.';

  @override
  String get topicMutedDescription =>
      'Du erhältst keine Benachrichtigungen über neue Aktivitäten in diesem Thema und es wird auch nicht mehr in der Liste der aktuellen Themen erscheinen.';

  @override
  String get messageWatchingDescription =>
      'Du wirst über jeden neuen Beitrag in dieser Unterhaltung benachrichtigt und die Anzahl der neuen Beiträge wird angezeigt.';

  @override
  String get messageTrackingDescription =>
      'Die Anzahl der neuen Antworten wird bei dieser Unterhaltung angezeigt. Du wirst benachrichtigt, wenn jemand deinen Namen mit @ erwähnt oder auf deinen Beitrag antwortet.';

  @override
  String get messageNormalDescription =>
      'Du wirst benachrichtigt, wenn jemand deinen Namen mit @ erwähnt oder auf deinen Beitrag antwortet.';

  @override
  String get messageMutedDescription =>
      'Du erhältst keine Benachrichtigungen im Zusammenhang mit dieser Unterhaltung.';

  @override
  String get categoryWatchingDescription =>
      'Du wirst automatisch alle Themen in dieser Kategorie beobachten. Du wirst über alle neuen Beiträge in allen Themen benachrichtigt und die Anzahl der neuen Antworten wird angezeigt.';

  @override
  String get categoryWatchingFirstPostDescription =>
      'Du wirst über neue Themen in dieser Kategorie benachrichtigt, aber nicht über Antworten auf diese Themen.';

  @override
  String get categoryTrackingDescription =>
      'Du wirst automatisch alle Themen in dieser Kategorie verfolgen. Du wirst benachrichtigt, wenn jemand deinen Namen mit @ erwähnt oder dir antwortet, und die Anzahl der neuen Antworten wird angezeigt.';

  @override
  String get categoryNormalDescription =>
      'Du wirst benachrichtigt, wenn jemand deinen Namen mit @ erwähnt oder auf deinen Beitrag antwortet.';

  @override
  String get categoryMutedDescription =>
      'Du erhältst nie mehr Benachrichtigungen über neue Themen in dieser Kategorie und die Themen werden auch nicht in der Liste der aktuellen Themen erscheinen.';

  @override
  String get tagWatchingDescription =>
      'Du wirst automatisch alle Themen mit diesem Schlagwort beobachten. Du wirst über alle neuen Beiträge und Themen benachrichtigt werden. Außerdem wird die Anzahl der ungelesenen und neuen Beiträge neben dem Thema erscheinen.';

  @override
  String get tagWatchingFirstPostDescription =>
      'Du wirst über neue Themen mit diesem Schlagwort benachrichtigt, aber nicht über Antworten auf diese Themen.';

  @override
  String get tagTrackingDescription =>
      'Du wirst automatisch alle Themen mit diesem Schlagwort verfolgen. Die Anzahl der ungelesenen und neuen Beiträge wird neben dem Thema erscheinen.';

  @override
  String get tagNormalDescription =>
      'Du wirst benachrichtigt, wenn jemand deinen Namen mit @ erwähnt oder auf deinen Beitrag antwortet.';

  @override
  String get tagMutedDescription =>
      'Du wirst nicht über neue Themen mit diesem Schlagwort benachrichtigt und sie werden nicht unter „Ungelesen“ auftauchen.';

  @override
  String topicTimerAutoOpen(String timeLeft) {
    return 'Dieses Thema wird $timeLeft automatisch geöffnet.';
  }

  @override
  String topicTimerAutoClose(String timeLeft) {
    return 'Dieses Thema wird $timeLeft automatisch geschlossen.';
  }

  @override
  String topicTimerAutoPublish(String categoryName, String timeLeft) {
    return 'Dieses Thema wird $timeLeft in #$categoryName veröffentlicht.';
  }

  @override
  String topicTimerAutoCloseAfterLastPost(String duration) {
    return 'Dieses Thema wird $duration nach der letzten Antwort geschlossen.';
  }

  @override
  String topicTimerAutoDeleteAfterLastPost(String duration) {
    return 'Dieses Thema wird $duration nach der letzten Antwort gelöscht.';
  }

  @override
  String topicTimerAutoDelete(String timeLeft) {
    return 'Dieses Thema wird $timeLeft automatisch gelöscht.';
  }

  @override
  String topicTimerAutoBump(String timeLeft) {
    return 'Dieses Thema wird $timeLeft automatisch nach oben verschoben.';
  }

  @override
  String topicTimerAutoDeleteReplies(String duration) {
    return 'Antworten zu diesem Thema werden nach $duration automatisch gelöscht.';
  }

  @override
  String slowModeNotice(String duration) {
    return 'Bitte warte zwischen dem Verfassen von Beiträgen in diesem Thema $duration.';
  }

  @override
  String get closeTopic => 'Thema schließen';

  @override
  String get openTopic => 'Thema öffnen';

  @override
  String get pinTopic => 'Thema anheften';

  @override
  String get unpinTopic => 'Thema loslösen';

  @override
  String get archiveTopic => 'Thema archivieren';

  @override
  String get unarchiveTopic => 'Thema aus Archiv holen';

  @override
  String get unlistTopic => 'Thema nicht auflisten';

  @override
  String get listTopic => 'Thema auflisten';

  @override
  String get permanentlyDelete => 'Endgültig löschen';

  @override
  String get permanentlyDeleteTopicConfirmation =>
      'Diese Aktion kann nicht rückgängig gemacht werden. Das Thema wird endgültig gelöscht und aus der Datenbank entfernt.';

  @override
  String get deleteTopicConfirmYes => 'Ja, dieses Thema löschen';

  @override
  String get deleteTopicConfirmNo => 'Nein, dieses Thema behalten';

  @override
  String get topicPinned => 'Thema angeheftet';

  @override
  String get topicUnpinned => 'Thema losgelöst';

  @override
  String get topicArchived => 'Thema archiviert';

  @override
  String get topicUnarchived => 'Thema aus dem Archiv geholt';

  @override
  String get topicUnlisted => 'Thema nicht mehr aufgelistet';

  @override
  String get topicListed => 'Thema aufgelistet';

  @override
  String get topicRecovered => 'Löschen des Themas rückgängig gemacht';

  @override
  String topicActionFailed(String error) {
    return 'Das Thema konnte nicht geändert werden: $error';
  }

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Minuten',
      one: '1 Minute',
    );
    return '$_temp0';
  }

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stunden',
      one: '1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String durationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String timeLeftMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count Minuten',
      one: 'in 1 Minute',
    );
    return '$_temp0';
  }

  @override
  String timeLeftHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count Stunden',
      one: 'in 1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String timeLeftDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count Tagen',
      one: 'in 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get topicStatusDeletedHelp =>
      'Dieses Thema ist gelöscht und für andere Benutzer nicht sichtbar';

  @override
  String get flagAction => 'Melden';

  @override
  String get flagPost => 'Beitrag melden';

  @override
  String get signUp => 'Registrieren';

  @override
  String get suspendUser => 'Benutzer sperren';

  @override
  String get unsuspend => 'Entsperren';

  @override
  String get suspendUntil => 'Benutzer sperren bis';

  @override
  String get suspendForever => 'Für immer sperren';

  @override
  String failedToSuspendUser(String error) {
    return 'Beim Sperren dieses Benutzers ist etwas schiefgegangen: $error';
  }

  @override
  String failedToUnsuspendUser(String error) {
    return 'Beim Entsperren dieses Benutzers ist etwas schiefgegangen: $error';
  }

  @override
  String get suspendReasonNotListening => 'Hat nicht auf Team-Feedback gehört';

  @override
  String get suspendReasonStaffTime =>
      'Hat überproportional viel Zeit des Teams verbraucht';

  @override
  String get suspendReasonCombative => 'Zu streitlustig';

  @override
  String get suspendReasonWrongPlace => 'An der falschen Stelle';

  @override
  String get suspendReasonNoPurpose =>
      'Kein konstruktiver Zweck der Handlungen, außer Dissens innerhalb der Gemeinschaft zu erzeugen';

  @override
  String get suspendReasonCustom => 'Benutzerdefiniert …';

  @override
  String get suspendReasonQuestion =>
      'Was ist der Grund für die Sperre? Dieser Text wird dem Benutzer angezeigt, wenn er versucht, sich anzumelden. Fasse dich kurz.';

  @override
  String get closedLabel => 'Geschlossen';

  @override
  String get flaggingPost => 'Beitrag wird gemeldet…';

  @override
  String setSuspensionFor(String username) {
    return 'Wie lange soll $username gesperrt werden?';
  }

  @override
  String get pleaseSelectSuspensionEndDate => 'Wähle, wann die Sperre endet';

  @override
  String get suspendingUser => 'Benutzer wird gesperrt…';

  @override
  String get unsuspendingUser => 'Benutzer wird entsperrt…';

  @override
  String get userSuspended => 'Benutzer gesperrt';

  @override
  String get userUnsuspended => 'Benutzer entsperrt';

  @override
  String unsuspendUserConfirmation(String username) {
    return '$username entsperren? Die Person kann sich dann wieder anmelden.';
  }

  @override
  String get noCategoriesToDisplay => 'Es gibt keine Kategorien zum Anzeigen.';

  @override
  String get noPermissionToViewCategory =>
      'Du hast keine Berechtigung, Themen in dieser Kategorie anzusehen.';
}
