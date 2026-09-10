// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get loginTitle => 'Accedi';

  @override
  String get usePasskey => 'Use Passkey';

  @override
  String get passkeyContinuePrompt => 'Use your passkey to continue';

  @override
  String get continueButton => 'Continua';

  @override
  String get errorTitle => 'Errore';

  @override
  String get okButton => 'OK';

  @override
  String get retryButton => 'Riprova';

  @override
  String get copyToClipboard => 'Copia negli appunti';

  @override
  String get copied => 'Copiato';

  @override
  String get errorMessageCopiedToClipboard =>
      'Messaggio di errore copiato negli appunti';

  @override
  String get dismiss => 'Chiudi';

  @override
  String get cancel => 'Annulla';

  @override
  String get tryAgain => 'Riprova';

  @override
  String get anErrorOccurred => 'Si è verificato un errore';

  @override
  String get accountPendingApproval =>
      'Il tuo account è in attesa di approvazione. Puoi navigare nel forum ma non puoi pubblicare finché un moderatore non approva il tuo account.';

  @override
  String get checkEmailToConfirm =>
      'Controlla la tua email per confermare il tuo account. Fai clic sul link di conferma nell\'email che ti abbiamo inviato.';

  @override
  String get checkNewEmailToConfirm =>
      'Controlla il tuo nuovo indirizzo email per confermare la modifica. La tua vecchia email rimarrà attiva finché non confermi la nuova.';

  @override
  String get emailAddressInvalid =>
      'Il tuo indirizzo email sembra essere non valido o sta rimbalzando le email. Aggiorna il tuo indirizzo email nelle impostazioni dell\'account.';

  @override
  String get accountDisabled =>
      'Il tuo account è stato disabilitato. Contatta un amministratore per assistenza.';

  @override
  String get accountRegistrationRejected =>
      'La registrazione del tuo account è stata rifiutata. Contatta un amministratore per maggiori informazioni.';

  @override
  String get welcomeToForumCopilot => 'Benvenuto in Forum Copilot!';

  @override
  String get successfullyLoggedOut => 'Hai effettuato il logout con successo';

  @override
  String get accountStatusRequiresAttention =>
      'Lo stato del tuo account richiede attenzione. Contatta un amministratore se hai domande.';

  @override
  String get updateEmail => 'Aggiorna email';

  @override
  String get resend => 'Invia di nuovo';

  @override
  String get noLatestTopics => 'Nessun argomento recente';

  @override
  String get noRecentTopicsToDisplay =>
      'Non ci sono argomenti recenti da visualizzare. Torna più tardi per nuove discussioni.';

  @override
  String get signInToViewLatestTopics =>
      'Accedi per visualizzare gli argomenti recenti';

  @override
  String get youNeedToBeSignedInToViewLatestTopics =>
      'Devi accedere per visualizzare gli argomenti recenti';

  @override
  String get thereAreNoUnreadTopics =>
      'Non ci sono argomenti non letti. Torna più tardi per nuove discussioni.';

  @override
  String get youAreAllCaughtUp => 'Sei aggiornato!';

  @override
  String get signInToViewUnreadTopics =>
      'Accedi per visualizzare gli argomenti non letti';

  @override
  String get youNeedToBeSignedInToViewUnreadTopics =>
      'Devi accedere per visualizzare i tuoi argomenti non letti';

  @override
  String get latest => 'Recenti';

  @override
  String get unread => 'Non letti';

  @override
  String get failedToConnectToSite =>
      'Impossibile connettersi al sito. Il sito potrebbe essere offline o irraggiungibile.';

  @override
  String get connectionFailed => 'Connessione fallita';

  @override
  String failedToConnectToSiteName(String siteName) {
    return 'Impossibile connettersi a $siteName';
  }

  @override
  String get loading => 'Caricamento...';

  @override
  String get newConversation => 'Nuova conversazione';

  @override
  String get language => 'Lingua';

  @override
  String get all => 'Tutti';

  @override
  String get topicsOnly => 'Solo argomenti';

  @override
  String get titlesOnly => 'Solo titoli';

  @override
  String failedToShareTopic(String error) {
    return 'Impossibile condividere l\'argomento: $error';
  }

  @override
  String get pleaseLoginToSubscribe => 'Accedi per null questo thread';

  @override
  String get subscribe => 'Iscriviti';

  @override
  String get failedToSubscribeToThread => 'Impossibile null thread';

  @override
  String get youCannotReplyToThisThread =>
      'Non puoi rispondere a questo thread';

  @override
  String get pleaseWaitForThreadToLoad => 'Attendi che il thread si carichi';

  @override
  String get softDelete => 'Eliminazione soft';

  @override
  String get postCanBeRestoredLater =>
      'Il post può essere ripristinato in seguito';

  @override
  String get hardDelete => 'Eliminazione permanente';

  @override
  String get postWillBePermanentlyDeleted =>
      'Il post verrà eliminato permanentemente';

  @override
  String get reasonForDeletion => 'Motivo dell\'eliminazione';

  @override
  String get enterReasonForDeletingPost =>
      'Inserisci il motivo per eliminare questo post';

  @override
  String get pleaseEnterReasonForDeletion =>
      'Inserisci un motivo per l\'eliminazione';

  @override
  String get reportPost => 'Segnala post';

  @override
  String get pleaseProvideReasonForReporting =>
      'Fornisci un motivo per segnalare questo post.';

  @override
  String get reason => 'Motivo';

  @override
  String get enterReasonForReportingPost =>
      'Inserisci il motivo per segnalare questo post';

  @override
  String get pleaseEnterReason => 'Inserisci un motivo';

  @override
  String get submitReport => 'Invia segnalazione';

  @override
  String get selectedActions => 'Azioni selezionate:';

  @override
  String get thisActionCannotBeUndone =>
      'Questa azione non può essere annullata.';

  @override
  String get participantsLabel => 'Partecipanti';

  @override
  String usernameHasBeenInvited(String username) {
    return '$username è stato invitato alla conversazione';
  }

  @override
  String errorInvitingUser(String error) {
    return 'Errore nell\'invitare l\'utente: $error';
  }

  @override
  String get newTopic => 'Nuovo argomento';

  @override
  String get markRead => 'Segna come letto';

  @override
  String get spamOrAdvertising => 'Spam o pubblicità';

  @override
  String get otherPleaseSpecify => 'Altro (specifica)';

  @override
  String get pleaseSpecifyReason => 'Specifica il motivo';

  @override
  String get banUser => 'Banna utente';

  @override
  String get unbanUser => 'Sbanna Utente';

  @override
  String pleaseSelectReasonForBanningUser(String username) {
    return 'Seleziona un motivo per bannare $username';
  }

  @override
  String get violationOfCommunityGuidelines =>
      'Violazione delle linee guida della comunità';

  @override
  String get harassmentOrAbusiveBehavior => 'Molestie o comportamento abusivo';

  @override
  String get postingInappropriateContent =>
      'Pubblicazione di contenuto inappropriato';

  @override
  String get accountCompromiseOrSecurityIssue =>
      'Compromissione dell\'account o problema di sicurezza';

  @override
  String get enterReasonForBanningUser =>
      'Inserisci il motivo per bannare questo utente';

  @override
  String get banUntil => 'Banna fino a';

  @override
  String get selectDate => 'Seleziona data';

  @override
  String get moreOptions => 'Altre opzioni';

  @override
  String get topicClosed => 'Argomento chiuso';

  @override
  String get topicOpened => 'Argomento aperto';

  @override
  String get topicStickied => 'Argomento in evidenza';

  @override
  String get topicUnstickied => 'Argomento rimosso da evidenza';

  @override
  String cannotEditMessage(String error) {
    return 'Impossibile modificare questo messaggio: $error';
  }

  @override
  String get confirmSpamClean => 'Conferma Pulizia Spam';

  @override
  String get handleThreads => 'Gestisci Thread';

  @override
  String get deleteMessages => 'Elimina Messaggi';

  @override
  String get deleteConversations => 'Elimina Conversazioni';

  @override
  String get noConversations => 'Nessuna conversazione';

  @override
  String get noConversationsMessage =>
      'Non hai ancora conversazioni. Avvia una nuova conversazione per iniziare a inviare messaggi.';

  @override
  String get imageSavedToGallery => 'Immagine salvata nella galleria!';

  @override
  String failedToSaveImage(String error) {
    return 'Impossibile salvare l\'immagine: $error';
  }

  @override
  String get userProfile => 'Profilo Utente';

  @override
  String get deletePost => 'Elimina Post';

  @override
  String get loginRequired => 'Accesso Richiesto';

  @override
  String get spamCleaner => 'Pulizia Spam';

  @override
  String get sendMessage => 'Invia messaggio';

  @override
  String get memberSince => 'Membro Dal';

  @override
  String get lastActivity => 'Ultima Attività';

  @override
  String get likesReceived => 'Mi Piace Ricevuti';

  @override
  String get likesGiven => 'Mi Piace Dati';

  @override
  String get showMore => 'Mostra di più';

  @override
  String get cleanSpam => 'Pulisci spam';

  @override
  String get failedToSaveConversation =>
      'Errore nel salvataggio della conversazione';

  @override
  String get members => 'Membri';

  @override
  String membersCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString Membri';
  }

  @override
  String get noSubject => 'Nessun oggetto';

  @override
  String get search => 'Cerca';

  @override
  String get logout => 'Esci';

  @override
  String get areYouSureYouWantToLogout => 'Sei sicuro di voler uscire?';

  @override
  String get register => 'Registrati';

  @override
  String get signIn => 'Accedi';

  @override
  String get markForumRead => 'Segna Forum come Letto';

  @override
  String get notificationTest => 'Test Notifiche';

  @override
  String get forum => 'Forum';

  @override
  String get profile => 'Profilo';

  @override
  String get messages => 'Messaggi';

  @override
  String get add => 'Aggiungi';

  @override
  String get retry => 'Riprova';

  @override
  String get delete => 'Elimina';

  @override
  String get deleteMessage => 'Elimina Messaggio';

  @override
  String get deletingPost => 'Eliminazione post...';

  @override
  String failedToUnlikePost(String error) {
    return 'Impossibile rimuovere il like dal post: $error';
  }

  @override
  String failedToLikePost(String error) {
    return 'Impossibile mettere like al post: $error';
  }

  @override
  String get signInToViewMessages => 'Accedi per visualizzare i messaggi';

  @override
  String get youNeedToBeSignedInToViewConversations =>
      'Devi accedere per visualizzare le tue conversazioni.';

  @override
  String errorLoadingConversations(String error) {
    return 'Errore nel caricamento delle conversazioni: $error';
  }

  @override
  String failedToLeaveConversation(String error) {
    return 'Impossibile lasciare la conversazione: $error';
  }

  @override
  String errorLoadingMoreConversations(String error) {
    return 'Errore nel caricamento di altre conversazioni: $error';
  }

  @override
  String get searchFailed => 'Ricerca fallita';

  @override
  String get userInformationNotAvailable =>
      'Informazioni utente non disponibili';

  @override
  String get birthday => 'Compleanno';

  @override
  String get posts => 'Post';

  @override
  String get following => 'Seguiti';

  @override
  String get followers => 'Follower';

  @override
  String get about => 'Informazioni';

  @override
  String get location => 'Posizione';

  @override
  String get website => 'Sito web';

  @override
  String get next => 'Avanti';

  @override
  String get permanent => 'Permanente';

  @override
  String get temporary => 'Temporaneo';

  @override
  String setBanDurationFor(String username) {
    return 'Imposta la durata del ban per $username';
  }

  @override
  String get pleaseSelectEndDateForTemporaryBan =>
      'Seleziona una data di fine per il ban temporaneo';

  @override
  String get back => 'Indietro';

  @override
  String get unban => 'Rimuovi Ban';

  @override
  String get confirm => 'Conferma';

  @override
  String spamClean(String username) {
    return 'Pulisci Spam di $username';
  }

  @override
  String get selectActionsToPerform => 'Seleziona le azioni da eseguire:';

  @override
  String get moveOrDeleteThreadsBasedOnAdminSettings =>
      'Sposta o elimina thread in base alle impostazioni dell\'amministratore';

  @override
  String get messageUpdatedSuccessfully => 'Messaggio aggiornato con successo';

  @override
  String error(String error) {
    return 'Errore: $error';
  }

  @override
  String failedToRemoveAttachment(String error) {
    return 'Impossibile rimuovere l\'allegato: $error';
  }

  @override
  String failedToLoadMessage(String error) {
    return 'Impossibile caricare il messaggio: $error';
  }

  @override
  String get editMessage => 'Modifica Messaggio';

  @override
  String get removeAttachment => 'Rimuovi Allegato';

  @override
  String get areYouSureYouWantToRemoveThisAttachment =>
      'Sei sicuro di voler rimuovere questo allegato?';

  @override
  String get none => 'Nessuno';

  @override
  String get attachFile => 'Allega File';

  @override
  String get uploadImage => 'Carica Immagine';

  @override
  String get formatting => 'Formattazione';

  @override
  String get bold => 'Grassetto';

  @override
  String get italic => 'Corsivo';

  @override
  String get underline => 'Sottolineato';

  @override
  String get strikethrough => 'Barrato';

  @override
  String get link => 'Collegamento';

  @override
  String get image => 'Immagine';

  @override
  String get video => 'Video';

  @override
  String get quote => 'Citazione';

  @override
  String get code => 'Codice';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get bulletList => 'Elenco Puntato';

  @override
  String get numberedList => 'Elenco Numerato';

  @override
  String get listItem => 'Elemento Elenco';

  @override
  String participants(int count) {
    return 'Partecipanti ($count)';
  }

  @override
  String get markAsUnread => 'Segna come non letto';

  @override
  String get invite => 'Invita';

  @override
  String get enterKeywordsToSearchTopics =>
      'Inserisci parole chiave per cercare argomenti...';

  @override
  String get undelete => 'Ripristina';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get share => 'Condividi';

  @override
  String get viewOnWeb => 'Visualizza sul Web';

  @override
  String get unlock => 'Sblocca';

  @override
  String get lock => 'Blocca';

  @override
  String get stick => 'Appunta';

  @override
  String get unstick => 'Rimuovi appuntamento';

  @override
  String get reply => 'Rispondi';

  @override
  String get vote => 'Vota';

  @override
  String votesCount(int count) {
    return '$count voti';
  }

  @override
  String get pollClosed => 'Sondaggio chiuso';

  @override
  String pollEndsOn(String date) {
    return 'Scade il $date';
  }

  @override
  String get voteToSeeResults => 'Vota per vedere i risultati';

  @override
  String get viewFullPoll => 'Sondaggio completo';

  @override
  String pollOptionsCount(int count) {
    return '$count opzioni';
  }

  @override
  String get reactedBy => 'Reagito da';

  @override
  String get enterKeywordsToFindTopicsAndPosts =>
      'Inserisci parole chiave per trovare argomenti e post';

  @override
  String get light => 'Chiaro';

  @override
  String get dark => 'Scuro';

  @override
  String version(String version, String buildNumber) {
    return 'versione $version ($buildNumber)';
  }

  @override
  String get unableToLoadProfile => 'Impossibile caricare il profilo';

  @override
  String get banned => 'BANNITO';

  @override
  String get reportSubmittedSuccessfully => 'Segnalazione inviata con successo';

  @override
  String get deleteTopic => 'Elimina argomento';

  @override
  String get topicCanBeRestoredLater =>
      'L\'argomento può essere ripristinato in seguito';

  @override
  String get topicWillBePermanentlyDeleted =>
      'L\'argomento sarà eliminato permanentemente';

  @override
  String get enterReasonForDeletingTopic =>
      'Inserisci il motivo per eliminare questo argomento';

  @override
  String get pleaseSelectEndDate => 'Seleziona una data di fine';

  @override
  String get userBannedSuccessfully => 'Utente bannato con successo';

  @override
  String get failedToBanUser => 'Impossibile bannare l\'utente';

  @override
  String get userUnbannedSuccessfully => 'Utente sbannato con successo';

  @override
  String get failedToUnbanUser => 'Impossibile sbannare l\'utente';

  @override
  String get spamCleanUser => 'Pulisci spam utente';

  @override
  String get deletePrivateConversations => 'Elimina conversazioni private';

  @override
  String get banTheUserAccount => 'Banna l\'account utente';

  @override
  String get handledThreads => 'Argomenti gestiti';

  @override
  String get deletedMessages => 'Messaggi eliminati';

  @override
  String get deletedConversations => 'Conversazioni eliminate';

  @override
  String get bannedUser => 'Utente bannato';

  @override
  String successfullyCleanedSpam(String username, String actions) {
    return 'Spam pulito con successo per $username. Azioni: $actions';
  }

  @override
  String get home => 'Home';

  @override
  String get notifications => 'Notifiche';

  @override
  String get forums => 'Forum';

  @override
  String get markAllForumsAsRead => 'Segnare tutti i forum come letti?';

  @override
  String get markAllForumsAsReadMessage =>
      'Questo segnerà tutti i forum e gli argomenti come letti. Questa azione non può essere annullata.';

  @override
  String get markAsRead => 'Segna come letto';

  @override
  String get content => 'Contenuto';

  @override
  String get insertImage => 'Inserisci immagine';

  @override
  String get howWouldYouLikeToInsertImage =>
      'Come vorresti inserire questa immagine?';

  @override
  String get thumbnail => 'Miniatura';

  @override
  String get fullSize => 'Dimensione piena';

  @override
  String get pleaseEnterTitle => 'Inserisci un titolo';

  @override
  String get pleaseEnterContent => 'Inserisci del contenuto';

  @override
  String get uploading => 'Caricamento...';

  @override
  String get uploaded => 'Caricato';

  @override
  String get mentionUser => 'Menziona utente';

  @override
  String get submittingReport => 'Invio report...';

  @override
  String get banningUser => 'Ban utente...';

  @override
  String get unbanningUser => 'Rimozione ban utente...';

  @override
  String get cleaningSpam => 'Pulizia spam...';

  @override
  String get writeYourMessage => 'Scrivi il tuo messaggio...';

  @override
  String get writeYourReply => 'Scrivi la tua risposta...';

  @override
  String get conversationCreatedSuccessfully =>
      'Conversazione creata con successo';

  @override
  String get conversationMarkedAsUnread =>
      'Conversazione segnata come non letta';

  @override
  String get conversationClosed => 'Conversazione chiusa';

  @override
  String get conversationOpened => 'Conversazione aperta';

  @override
  String get pleaseLoginToLikeMessages =>
      'Accedi per mettere mi piace ai messaggi';

  @override
  String get loadEarlierMessages => 'Carica messaggi precedenti';

  @override
  String failedToLoadQuote(String error) {
    return 'Errore nel caricamento della citazione: \n$error';
  }

  @override
  String failedToSendReply(String error) {
    return 'Errore nell\'invio della risposta: $error';
  }

  @override
  String failedToMarkConversationAsUnread(String error) {
    return 'Errore nel segnare la conversazione come non letta: $error';
  }

  @override
  String failedToCloseConversation(String error) {
    return 'Errore nella chiusura della conversazione: $error';
  }

  @override
  String failedToOpenConversation(String error) {
    return 'Errore nell\'apertura della conversazione: $error';
  }

  @override
  String failedToJumpToMessage(String error) {
    return 'Errore nel saltare al messaggio: $error';
  }

  @override
  String get goToTop => 'Vai in alto';

  @override
  String get goToBottom => 'Vai in basso';

  @override
  String get pleaseLoginToAccessContent =>
      'Accedi per accedere a questo contenuto e interagire con i post.';

  @override
  String get searchUsers => 'Cerca utenti...';

  @override
  String get enterConversationTitle =>
      'Inserisci il titolo della conversazione';

  @override
  String enterCode(int count) {
    return 'Inserisci codice a $count cifre';
  }

  @override
  String get edit => 'Modifica';

  @override
  String get report => 'Segnala';

  @override
  String get remove => 'Rimuovi';

  @override
  String get subject => 'Oggetto';

  @override
  String get message => 'Messaggio';

  @override
  String get titleCannotBeEmpty => 'Il titolo non può essere vuoto';

  @override
  String get conversationUpdatedSuccessfully =>
      'Conversazione aggiornata con successo';

  @override
  String get goBack => 'Indietro';

  @override
  String failedToLoadPost(String error) {
    return 'Errore nel caricamento del post: \n$error';
  }

  @override
  String failedToLikeOrUnlikeMessage(String action, String error) {
    return 'Errore nel $action messaggio: $error';
  }

  @override
  String get like => 'mettere mi piace a';

  @override
  String get unlike => 'togliere mi piace a';

  @override
  String downloading(String filename) {
    return 'Download di $filename...';
  }

  @override
  String openingShareSheet(String filename) {
    return 'Apertura foglio di condivisione per $filename';
  }

  @override
  String errorDownloading(String filename, String error) {
    return 'Errore nel download di $filename: $error';
  }

  @override
  String get failedToNavigateToForum => 'Errore nella navigazione al forum';

  @override
  String forumNotFoundById(String forumId) {
    return 'Forum non trovato: $forumId';
  }

  @override
  String couldNotOpenLink(String error) {
    return 'Impossibile aprire il link: $error';
  }

  @override
  String get translating => 'Traduzione in corso...';

  @override
  String get translated => 'Tradotto';

  @override
  String get translatedContent => 'Contenuto tradotto';

  @override
  String get twoFactorAuthentication => 'Autenticazione a due fattori';

  @override
  String get authenticationCodeLabel => 'Codice di autenticazione';

  @override
  String get pleaseEnterYourAuthenticationCode =>
      'Inserisci il tuo codice di autenticazione';

  @override
  String codeMustBeDigits(int count) {
    return 'Il codice deve contenere $count cifre';
  }

  @override
  String get codeMustContainOnlyNumbers =>
      'Il codice deve contenere solo numeri';

  @override
  String get verifyButton => 'Verifica';

  @override
  String get attachments => 'Allegati';

  @override
  String get replyOptions => 'Opzioni di risposta';

  @override
  String get replyWithQuote => 'Rispondi con citazione';

  @override
  String fileSavedToDownloads(String filename) {
    return 'File salvato in Download: $filename';
  }

  @override
  String fileSavedToDocuments(String filename) {
    return 'File salvato in Documenti: $filename';
  }

  @override
  String topicLastReplyBy(String username, String time) {
    return '$username ha risposto $time';
  }

  @override
  String inReplyToUser(String username) {
    return 'in risposta a $username';
  }

  @override
  String inReplyToPost(int number) {
    return 'in risposta al post #$number';
  }

  @override
  String timeGapDaysLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni dopo',
      one: '1 giorno dopo',
    );
    return '$_temp0';
  }

  @override
  String timeGapMonthsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mesi dopo',
      one: '1 mese dopo',
    );
    return '$_temp0';
  }

  @override
  String timeGapYearsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anni dopo',
      one: '1 anno dopo',
    );
    return '$_temp0';
  }

  @override
  String get profileViews => 'Visualizzazioni';

  @override
  String get badges => 'Badge';

  @override
  String get chatWithUser => 'Chat';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count risposte',
      one: '1 risposta',
    );
    return '$_temp0';
  }

  @override
  String nVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voti',
      one: '1 voto',
    );
    return '$_temp0';
  }

  @override
  String get lastSeen => 'Visto';

  @override
  String get chat => 'Chat';

  @override
  String comingSoon(String label) {
    return '$label — in arrivo';
  }

  @override
  String moreBadges(Object count) {
    return '+$count altri';
  }

  @override
  String get allNotificationsMarkedAsRead =>
      'Tutte le notifiche segnate come lette';

  @override
  String get apply => 'Applica';

  @override
  String get bookmarks => 'Segnalibri';

  @override
  String reviewableBy(String username) {
    return 'Di $username';
  }

  @override
  String get changeEmail => 'Cambia e-mail';

  @override
  String get changePassword => 'Cambia password';

  @override
  String get checkingStatus => 'Verifica dello stato…';

  @override
  String get clearReminder => 'Rimuovi promemoria';

  @override
  String get copy => 'Copia';

  @override
  String get copyLink => 'Copia link';

  @override
  String couldNotEnableNotifications(String error) {
    return 'Impossibile attivare le notifiche: $error';
  }

  @override
  String get couldNotFindBookmark => 'Segnalibro non trovato';

  @override
  String couldNotOpenEmail(String email) {
    return 'Impossibile aprire l’e-mail: $email';
  }

  @override
  String couldNotStartSignIn(String error) {
    return 'Impossibile avviare l’accesso: $error';
  }

  @override
  String get customDateAndTime => 'Data e ora personalizzate';

  @override
  String get deleteAccount => 'Elimina account';

  @override
  String get deleteMessageQuestion => 'Eliminare il messaggio?';

  @override
  String get discard => 'Scarta';

  @override
  String get discardDraftQuestion => 'Scartare la bozza?';

  @override
  String get doNotDisturb => 'Non disturbare';

  @override
  String get editHistory => 'Cronologia modifiche';

  @override
  String get editProfile => 'Modifica profilo';

  @override
  String get editReminder => 'Modifica promemoria';

  @override
  String emailCopiedToClipboard(String email) {
    return 'E-mail copiata negli appunti: $email';
  }

  @override
  String get pushEnabledForThisLogin => 'Attive per questo accesso';

  @override
  String get failedToLoadMoreTopics =>
      'Impossibile caricare altri argomenti. Scorri per riprovare.';

  @override
  String get failedToUpdateNotificationLevel =>
      'Impossibile aggiornare il livello di notifica';

  @override
  String get firstPostsOnly => 'Solo primi post';

  @override
  String get ignoredUsers => 'Utenti ignorati';

  @override
  String get inTwoHours => 'Tra due ore';

  @override
  String get inviteByEmail => 'Invita via e-mail';

  @override
  String get inviteLinkCopied => 'Link di invito copiato';

  @override
  String inviteSentTo(String email) {
    return 'Invito inviato a $email';
  }

  @override
  String get leave => 'Esci';

  @override
  String get leaveGroup => 'Esci dal gruppo';

  @override
  String get leaveGroupQuestion => 'Uscire dal gruppo?';

  @override
  String get linkCopied => 'Link copiato';

  @override
  String get loadMore => 'Carica altro';

  @override
  String get manageAccountOnWeb => 'Gestisci account sul web';

  @override
  String get merge => 'Unisci';

  @override
  String get mergeIntoTopic => 'Unisci in un argomento';

  @override
  String get newInviteLink => 'Nuovo link di invito';

  @override
  String get nextWeek => 'La prossima settimana';

  @override
  String get pushNotAvailableInThisBuild =>
      'Non disponibile in questa versione';

  @override
  String get notNow => 'Non ora';

  @override
  String tagNotificationLevelUpdated(String tag) {
    return 'Livello di notifica per \"$tag\" aggiornato';
  }

  @override
  String doNotDisturbOnUntil(String until) {
    return 'Attivo fino a $until';
  }

  @override
  String get pleaseLogInToBookmark => 'Accedi per aggiungere un segnalibro';

  @override
  String get pleaseLogInToFollowUsers => 'Accedi per seguire gli utenti';

  @override
  String get pleaseLogInToMarkAnswers =>
      'Accedi per contrassegnare le risposte';

  @override
  String get pleaseLogInToReact => 'Accedi per reagire';

  @override
  String get pleaseLogInToVote => 'Accedi per votare';

  @override
  String get pushNotifications => 'Notifiche push';

  @override
  String get relevance => 'Rilevanza';

  @override
  String get reminderTimeMustBeInFuture =>
      'L’ora del promemoria deve essere futura';

  @override
  String get removeBookmark => 'Rimuovi segnalibro';

  @override
  String get removeVote => 'Rimuovi voto';

  @override
  String get renameTopic => 'Rinomina argomento';

  @override
  String reportedBy(String username) {
    return 'Segnalato da $username';
  }

  @override
  String get requestToJoin => 'Richiedi di partecipare';

  @override
  String requestToJoinGroup(String group) {
    return 'Richiedi di partecipare a $group';
  }

  @override
  String get reset => 'Reimposta';

  @override
  String get resizeAndUpload => 'Ridimensiona e carica';

  @override
  String get retryConnection => 'Riprova la connessione';

  @override
  String get reviewQueue => 'Coda di revisione';

  @override
  String get revoke => 'Revoca';

  @override
  String get revokeInviteQuestion => 'Revocare l’invito?';

  @override
  String get save => 'Salva';

  @override
  String get sendInvite => 'Invia invito';

  @override
  String get sendRequest => 'Invia richiesta';

  @override
  String get settings => 'Impostazioni';

  @override
  String get showVoters => 'Mostra votanti';

  @override
  String get signOut => 'Esci';

  @override
  String get signOutQuestion => 'Uscire?';

  @override
  String get signInCancelledNoPayload =>
      'Accesso annullato — nessuna risposta ricevuta';

  @override
  String signInFailed(String error) {
    return 'Accesso non riuscito: $error';
  }

  @override
  String get startChat => 'Avvia chat';

  @override
  String stoppedIgnoringUser(String username) {
    return 'Hai smesso di ignorare @$username';
  }

  @override
  String get submit => 'Invia';

  @override
  String get discardDraftWarning =>
      'La bozza salvata verrà rimossa definitivamente.';

  @override
  String get deleteChatMessageWarning =>
      'Il messaggio verrà rimosso per tutti.';

  @override
  String get titleOnly => 'Solo titolo';

  @override
  String get tomorrow => 'Domani';

  @override
  String get turnOff => 'Disattiva';

  @override
  String get turnOnNotifications => 'Attiva le notifiche';

  @override
  String get whisper => 'Sussurro';

  @override
  String likeAgainInSeconds(Object seconds) {
    return 'Potrai mettere di nuovo mi piace tra ${seconds}s';
  }

  @override
  String get loginInfo => 'Info accesso';

  @override
  String get loginFailed => 'Accesso non riuscito';

  @override
  String get moveToCategory => 'Sposta in categoria';

  @override
  String get undeleteTopic => 'Ripristina argomento';

  @override
  String get undeleteTopicConfirmation =>
      'Ripristinare questo argomento? Tornerà visibile agli altri utenti.';

  @override
  String get send => 'Invia';

  @override
  String get changeEmailExplanation =>
      'Invieremo un link di conferma alla tua nuova e-mail. La modifica avrà effetto quando lo aprirai.';

  @override
  String get changeEmailSecurityNote =>
      'Per maggiore sicurezza, Discourse potrebbe chiederti di confermare tramite il link nell’e-mail. Controlla la cartella spam se non la vedi.';

  @override
  String get newDirectMessage => 'Nuovo messaggio diretto';

  @override
  String get noMessagesYetSayHi => 'Nessun messaggio ancora — saluta.';

  @override
  String get edited => 'modificato';

  @override
  String get editProfileManagedOnWebNote =>
      'Nome visualizzato, e-mail, password e altre impostazioni dell’account si gestiscono in Account → Gestisci account sul web. L’avatar si cambia toccando l’icona della fotocamera sulla foto.';

  @override
  String get approvedButRelayUnreachable =>
      'Approvato, ma non è stato possibile raggiungere il server delle notifiche per completare la configurazione. Riprova più tardi dalle Impostazioni.';

  @override
  String get notificationsAreTurnedOffForThisApp =>
      'Le notifiche sono disattivate per questa app';

  @override
  String forumWillAskToApproveNotifications(Object forumName) {
    return 'Ora $forumName ti chiederà di approvare \"Notifiche\".';
  }

  @override
  String get approveNotificationsExplanation =>
      'Approvando ci permetti di controllare le tue notifiche e inviarle a questo dispositivo. Questo permesso non può pubblicare, rispondere o leggere i tuoi messaggi.';

  @override
  String get forumOwnerPushNote =>
      'Se il gestore di questo forum configura le notifiche per l’app, questo passaggio non servirà.';

  @override
  String get pleaseLoginToCreateANewTopic =>
      'Accedi per creare un nuovo argomento';

  @override
  String get pleaseLoginToSubscribeToForums => 'Accedi per seguire i forum';

  @override
  String leaveGroupWarning(Object group) {
    return 'Non sarai più membro di $group. Puoi rientrare in qualsiasi momento.';
  }

  @override
  String get groupMembersPrivate =>
      'L’elenco dei membri di questo gruppo è privato.';

  @override
  String get unignore => 'Non ignorare più';

  @override
  String get inviteLinkCreated => 'Link di invito creato';

  @override
  String expiresOn(Object date) {
    return 'Scade il $date';
  }

  @override
  String get protected => 'Protetto';

  @override
  String get solution => 'Soluzione';

  @override
  String get deleted => 'ELIMINATO';

  @override
  String get pleaseLoginToViewUserProfiles =>
      'Accedi per vedere i profili utente.';

  @override
  String get announcement => 'Annuncio';

  @override
  String get solved => 'Risolto';

  @override
  String get hot => 'Popolare';

  @override
  String get pinned => 'In evidenza';

  @override
  String get subscribedLabel => 'Iscritto';

  @override
  String get locked => 'Bloccato';

  @override
  String get poll => 'Sondaggio';

  @override
  String errorLoadingContent(Object error) {
    return 'Errore nel caricamento del contenuto: $error';
  }

  @override
  String get noPermissionToViewSubforum =>
      'Non hai il permesso di vedere gli argomenti in questo sottoforum.';

  @override
  String get noDiscussionsYet => 'Nessuna discussione ancora.';

  @override
  String get jumpToPost => 'Vai al post';

  @override
  String get jump => 'Vai';

  @override
  String get endOfTheDiscussion => 'Fine della discussione';

  @override
  String get reviewQueueStaffOnly =>
      'Solo staff e revisori possono vedere la coda di revisione.';

  @override
  String get nothingToReview => 'Niente da revisionare';

  @override
  String refreshFailed(Object error) {
    return 'Aggiornamento non riuscito: $error';
  }

  @override
  String get topicDeletedBanner =>
      'Questo argomento è stato eliminato ed è nascosto agli altri utenti';

  @override
  String get topicClosedBanner =>
      'Questo argomento è chiuso e non accetta più risposte';

  @override
  String get topicPinnedBanner =>
      'Questo argomento è in evidenza in cima al forum';

  @override
  String get youAreSubscribedToThisTopic => 'Sei iscritto a questo argomento';

  @override
  String get refreshing => 'Aggiornamento...';

  @override
  String get title => 'Titolo';

  @override
  String editedAt(Object time) {
    return 'Modificato $time';
  }

  @override
  String editReason(Object reason) {
    return 'Motivo: $reason';
  }

  @override
  String get thisDiffIsTooLargeToDisplay =>
      'Questa differenza è troppo grande per essere mostrata.';

  @override
  String get noContentChangesInThisRevision =>
      'Nessuna modifica al contenuto in questa revisione.';

  @override
  String revisionOf(Object currentVersion, Object versionCount) {
    return 'Revisione $currentVersion di $versionCount';
  }

  @override
  String get editConversation => 'Modifica conversazione';

  @override
  String get closeConversation => 'Chiudi conversazione';

  @override
  String get openConversation => 'Apri conversazione';

  @override
  String get leaveConversation2 => 'Abbandona conversazione';

  @override
  String get reportConversation2 => 'Segnala conversazione';

  @override
  String get closeConversation2 => 'Chiudi conversazione';

  @override
  String get closeConversationConfirmation =>
      'Chiudere questa conversazione? Non sarà più possibile pubblicare nuove risposte.';

  @override
  String get close => 'Chiudi';

  @override
  String get openConversation2 => 'Apri conversazione';

  @override
  String get openConversationConfirmation =>
      'Aprire questa conversazione? Sarà possibile pubblicare nuove risposte.';

  @override
  String get open => 'Apri';

  @override
  String get leaveConversation3 => 'Abbandona conversazione';

  @override
  String get leaveConversationConfirmation =>
      'Abbandonare questa conversazione? Verrà nascosta dalla tua casella.';

  @override
  String errorLoadingConversation(Object error) {
    return 'Errore nel caricamento della conversazione: $error';
  }

  @override
  String get conversationNotFound => 'Conversazione non trovata';

  @override
  String get conversationClosedBanner =>
      'Questa conversazione è chiusa e non accetta più risposte';

  @override
  String get noMessagesFound => 'Nessun messaggio trovato';

  @override
  String get endOfConversation => 'Fine della conversazione';

  @override
  String get jumpToMessage => 'Vai al messaggio';

  @override
  String get editConversation2 => 'Modifica conversazione';

  @override
  String get failedToLoadMessage2 => 'Impossibile caricare il messaggio';

  @override
  String get cannotEditThisConversation =>
      'Impossibile modificare questa conversazione';

  @override
  String get options => 'Opzioni';

  @override
  String get conversationOpen => 'Conversazione aperta';

  @override
  String failedToCreateConversation(Object error) {
    return 'Impossibile creare la conversazione: $error';
  }

  @override
  String maximumAttachmentsAllowed(Object count) {
    return 'Massimo $count allegati consentiti';
  }

  @override
  String get noImagesFoundToDisplay => 'Nessuna immagine da mostrare.';

  @override
  String get pleaseLoginToViewThisAttachment =>
      'Accedi per vedere questo allegato';

  @override
  String get searchForTopics => 'Cerca argomenti';

  @override
  String get noTopicsFound => 'Nessun argomento trovato';

  @override
  String get trySearchingWithDifferentKeywords =>
      'Prova con parole chiave diverse';

  @override
  String get noPostsFound => 'Nessun post trovato';

  @override
  String get perTopicNotificationLevelsNote =>
      'I livelli di notifica per categoria e per argomento si impostano da quelle schermate — tocca l’icona campana su un argomento o una categoria.';

  @override
  String get pushNotActiveForThisLogin =>
      'Non attive per questo accesso — esci e rientra per autorizzare le notifiche push';

  @override
  String get pauseNotificationsFor => 'Sospendi le notifiche per…';

  @override
  String get doNotDisturbExplanation =>
      'Sospendi le notifiche per un po’ — Discourse le trattiene fino alla fine del periodo';

  @override
  String get emailSettingsSubtitle =>
      'Frequenza e-mail, aggregazione dei mi piace, pianificazione dei riepiloghi';

  @override
  String get manageAccountSubtitle =>
      'Profilo, e-mail, password, sicurezza, impostazioni avanzate';

  @override
  String get changePasswordSubtitle =>
      'Invia un’e-mail di reimpostazione password al tuo indirizzo attuale';

  @override
  String get ignoredUsersSubtitle =>
      'Vedi e gestisci gli utenti i cui post ti sono nascosti';

  @override
  String get deleteAccountExplanation =>
      'La rimozione dell’account avviene sul forum. Continua per aprire il sito e contattare lo staff — i forum Discourse gestiscono le cancellazioni secondo le proprie regole.';

  @override
  String get verificationEmailSent =>
      'E-mail di verifica inviata — clicca sul link per confermare il nuovo indirizzo.';

  @override
  String get passwordResetExplanation =>
      'Ti invieremo un link per reimpostare la password. Cliccalo per sceglierne una nuova — la modifica avviene sul forum, non in questa app.';

  @override
  String get sendResetEmail => 'Invia e-mail di reimpostazione';

  @override
  String get deleteAccountDialogBody =>
      'Il tuo account è gestito dal forum. Contatta direttamente lo staff del forum per richiedere la rimozione. \"Continua\" aprirà il forum nel browser per usare il suo flusso di contatto / messaggio allo staff.';

  @override
  String get initializingForum => 'Inizializzazione del forum…';

  @override
  String get unableToLoadForums => 'Impossibile caricare i forum';

  @override
  String get noForumsToDisplayExplanation =>
      'Non ci sono forum da mostrare. Potrebbe dipendere dai permessi o dalla struttura del forum.';

  @override
  String get subscribedForums => 'Forum seguiti';

  @override
  String get errorLoadingNotifications =>
      'Errore nel caricamento delle notifiche';

  @override
  String get pullDownToRefresh => 'Trascina verso il basso per aggiornare';

  @override
  String get noNewNotificationsExplanation =>
      'Nessuna nuova notifica. Torna più tardi per gli aggiornamenti sugli argomenti che segui.';

  @override
  String noTagsMatch(Object filter) {
    return 'Nessun tag corrisponde a \"$filter\".';
  }

  @override
  String noTopicsTagged(Object tag) {
    return 'Nessun argomento con il tag \"$tag\"';
  }

  @override
  String failedToBanUser2(Object error) {
    return 'Impossibile bannare l’utente: $error';
  }

  @override
  String unbanUserConfirmation(Object username) {
    return 'Rimuovere il ban a $username?';
  }

  @override
  String failedToUnbanUser2(Object error) {
    return 'Impossibile rimuovere il ban: $error';
  }

  @override
  String get deletePostsProfilePostsAndComments =>
      'Elimina post, post del profilo e commenti';

  @override
  String spamCleanConfirmation(Object username) {
    return 'Eseguire la pulizia spam per $username?';
  }

  @override
  String failedToCleanSpam(Object error) {
    return 'Pulizia spam non riuscita: $error';
  }

  @override
  String get searchUser => 'Cerca utente';

  @override
  String get tapToOpen => 'Tocca per aprire';

  @override
  String get imageNotAvailable => 'Immagine non disponibile';

  @override
  String get allForumTopicsHaveBeenMarkedAs =>
      'Tutti gli argomenti del forum sono stati segnati come letti';

  @override
  String postsCount(Object count) {
    return '$count post';
  }

  @override
  String get permissionDeniedToSaveImage =>
      'Permesso negato per salvare l’immagine';

  @override
  String get postNotFound => 'Post non trovato.';

  @override
  String get failedToUploadFilePleaseTryAgain =>
      'Caricamento del file non riuscito. Riprova.';

  @override
  String failedToUploadFile2(Object errorMessage) {
    return 'Caricamento del file non riuscito: $errorMessage';
  }

  @override
  String get failedToPickFile => 'Impossibile selezionare il file';

  @override
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return 'Solo altri $remainingSlots allegati consentiti. Verranno elaborate le prime $remainingSlots2 immagini.';
  }

  @override
  String get attachmentLimitReachedSkippingRemainingImages =>
      'Limite allegati raggiunto. Le immagini restanti verranno saltate.';

  @override
  String failedToUploadImagePleaseTryAgain(Object fileName) {
    return '$fileName: caricamento dell’immagine non riuscito. Riprova.';
  }

  @override
  String failedToUploadImage2(Object errorMessage, Object fileName) {
    return '$fileName: caricamento dell’immagine non riuscito: $errorMessage';
  }

  @override
  String get failedToPickImage => 'Impossibile selezionare l’immagine';

  @override
  String failedToRemoveAttachment2(Object error) {
    return 'Impossibile rimuovere l’allegato: $error';
  }

  @override
  String sentFromMobileApp(Object siteName) {
    return 'Inviato dall’app mobile di $siteName';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      'Attendi il completamento del caricamento degli allegati';

  @override
  String get imageIsTooLargeToUpload =>
      'L’immagine è troppo grande per essere caricata';

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName è di $fileBytes. Questo forum consente fino a $maxBytes.';
  }

  @override
  String get resizeToFitExplanation =>
      'Può essere ridotta quanto basta per rientrare, mantenendo il formato e tutto il dettaglio che il limite consente.';

  @override
  String get failedToPostReplyPleaseTryAgain =>
      'Pubblicazione della risposta non riuscita. Riprova.';

  @override
  String get pleaseWaitForTheThreadToLoad =>
      'Attendi il caricamento dell’argomento';

  @override
  String get failedToUpdatePostPleaseTryAgain =>
      'Aggiornamento del post non riuscito. Riprova.';

  @override
  String get postDeletedSuccessfully => 'Post eliminato';

  @override
  String failedToDeletePost(Object error) {
    return 'Eliminazione del post non riuscita: $error';
  }

  @override
  String failedToSubmitReport2(Object error) {
    return 'Invio della segnalazione non riuscito: $error';
  }

  @override
  String get editHistoryNotAvailable =>
      'La cronologia delle modifiche non è disponibile per questo post';

  @override
  String get noPermissionToUploadAvatar =>
      'Non hai il permesso di caricare avatar';

  @override
  String get avatarUploadedSuccessfully => 'Avatar caricato';

  @override
  String failedToPickImage2(Object error) {
    return 'Impossibile selezionare l’immagine: $error';
  }

  @override
  String get react => 'Reagisci';

  @override
  String get reactionsAreNotEnabledOnThisForum =>
      'Le reazioni non sono abilitate su questo forum.';

  @override
  String get noReactionsYet => 'Nessuna reazione ancora';

  @override
  String get searchFilters => 'Filtri di ricerca';

  @override
  String signOutWarning(Object siteName) {
    return 'Verrai disconnesso da $siteName. Puoi accedere di nuovo in qualsiasi momento.';
  }

  @override
  String get suggestedTopics => 'Argomenti suggeriti';

  @override
  String get newLabel => 'NUOVO';

  @override
  String get voteRemoved => 'Voto rimosso';

  @override
  String get voters => 'Votanti';

  @override
  String get noVotesYet => 'Nessun voto ancora.';

  @override
  String get trustLevels => 'Livelli di fiducia';

  @override
  String get trustLevelsExplanation =>
      'I membri guadagnano fiducia leggendo e partecipando. Ogni livello sblocca nuove funzioni.';

  @override
  String get activity => 'Attività';

  @override
  String get dontUpload => 'Non caricare';

  @override
  String get dontAskAgainAlwaysResize =>
      'Non chiedere più — ridimensiona sempre';

  @override
  String get couldNotLoadCategories => 'Impossibile caricare le categorie.';

  @override
  String get switchForum => 'Cambia forum';

  @override
  String get explore => 'Esplora';

  @override
  String get tags => 'Tag';

  @override
  String get community => 'Comunità';

  @override
  String get users => 'Utenti';

  @override
  String get groups => 'Gruppi';

  @override
  String get invites => 'Inviti';

  @override
  String get account => 'Account';

  @override
  String get drafts => 'Bozze';

  @override
  String get termsOfService => 'Termini di servizio';

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String signedInAs(String username) {
    return 'Accesso effettuato come $username';
  }

  @override
  String get notSignedIn => 'Non hai effettuato l’accesso';

  @override
  String get deviceWillNotShowAlertsUntilAllowedInSettings =>
      'Il dispositivo non mostrerà avvisi finché non consenti le notifiche nelle Impostazioni.';

  @override
  String get openSettings => 'Apri impostazioni';

  @override
  String get notificationsOnThisDevice => 'Notifiche su questo dispositivo';

  @override
  String get notificationsGrantOnSubtitle =>
      'Risposte, menzioni e messaggi di questo forum vengono recapitati qui.';

  @override
  String get notificationsGrantOffSubtitle =>
      'Approva una volta sul forum per ricevere qui risposte, menzioni e messaggi.';

  @override
  String get turnOn => 'Attiva';

  @override
  String get couldNotTurnOffNotifications =>
      'Impossibile disattivare le notifiche. Riprova più tardi.';
}
