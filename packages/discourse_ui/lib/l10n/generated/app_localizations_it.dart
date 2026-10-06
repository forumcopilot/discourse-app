// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get accountSessionChanged =>
      'La tua sessione è cambiata. Riapri questa schermata per continuare.';

  @override
  String get draftSessionChanged =>
      'La tua sessione è cambiata. Copia il testo prima di riaprire l’editor per lavorare sulle bozze.';

  @override
  String get discardFailedCloseQuestion =>
      'Chiudere comunque? Una bozza salvata in precedenza resta in Bozze.';

  @override
  String get keepEditing => 'Continua a scrivere';

  @override
  String get closeAnyway => 'Chiudi comunque';

  @override
  String get uploadSessionChanged =>
      'La tua sessione è cambiata durante il caricamento. Riapri questa schermata prima di riprovare.';

  @override
  String get submissionUnconfirmed =>
      'Non è stato possibile confermare l’invio. Il testo è stato conservato. Controlla il forum prima di riprovare.';

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
  String get newConversation => 'Nuovo messaggio';

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
  String get youCannotReplyToThisThread =>
      'Non puoi rispondere a questo argomento';

  @override
  String get pleaseWaitForThreadToLoad => 'Attendi che l\'argomento si carichi';

  @override
  String get reason => 'Motivo';

  @override
  String get participantsLabel => 'Partecipanti';

  @override
  String usernameHasBeenInvited(String username) {
    return '$username è stato invitato al messaggio';
  }

  @override
  String errorInvitingUser(String error) {
    return 'Errore nell\'invitare l\'utente: $error';
  }

  @override
  String get newTopic => 'Nuovo argomento';

  @override
  String get pleaseSpecifyReason => 'Specifica il motivo';

  @override
  String get selectDate => 'Seleziona data';

  @override
  String get moreOptions => 'Altre opzioni';

  @override
  String get topicClosed => 'Argomento chiuso';

  @override
  String get topicOpened => 'Argomento aperto';

  @override
  String get noConversations => 'Non hai messaggi';

  @override
  String get noConversationsMessage =>
      'Non hai ancora messaggi. Scrivi un nuovo messaggio per iniziare.';

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
  String get sendMessage => 'Messaggio';

  @override
  String get likesReceived => 'Mi Piace Ricevuti';

  @override
  String get showMore => 'Mostra di più';

  @override
  String get failedToSaveConversation => 'Impossibile salvare il messaggio';

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
  String get signIn => 'Accedi';

  @override
  String get notificationTest => 'Test Notifiche';

  @override
  String get forum => 'Categoria';

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
      'Devi accedere per vedere i tuoi messaggi.';

  @override
  String failedToLeaveConversation(String error) {
    return 'Impossibile abbandonare il messaggio: $error';
  }

  @override
  String errorLoadingMoreConversations(String error) {
    return 'Errore durante il caricamento di altri messaggi: $error';
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
  String get temporary => 'Temporaneo';

  @override
  String get back => 'Indietro';

  @override
  String get confirm => 'Conferma';

  @override
  String error(String error) {
    return 'Errore: $error';
  }

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
  String get markAsUnread => 'Contrassegna come non letto';

  @override
  String get invite => 'Invita';

  @override
  String get enterKeywordsToSearchTopics =>
      'Inserisci parole chiave per cercare argomenti...';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get share => 'Condividi';

  @override
  String get viewOnWeb => 'Visualizza sul Web';

  @override
  String get reply => 'Rispondi';

  @override
  String get vote => 'Vota';

  @override
  String votesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voti',
      one: '$count voto',
    );
    return '$_temp0';
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
  String get appearance => 'Aspetto';

  @override
  String get appearanceSystem => 'Sistema';

  @override
  String version(String version, String buildNumber) {
    return 'versione $version ($buildNumber)';
  }

  @override
  String get unableToLoadProfile => 'Impossibile caricare il profilo';

  @override
  String get banned => 'BANNITO';

  @override
  String get deleteTopic => 'Cancella Argomento';

  @override
  String get home => 'Home';

  @override
  String get notifications => 'Notifiche';

  @override
  String get notificationsTab => 'Avvisi';

  @override
  String get forums => 'Categorie';

  @override
  String get content => 'Contenuto';

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
  String get writeYourMessage => 'Scrivi il tuo messaggio...';

  @override
  String get writeYourReply => 'Scrivi la tua risposta...';

  @override
  String get conversationMarkedAsUnread =>
      'Messaggio contrassegnato come non letto';

  @override
  String get conversationClosed => 'Messaggio chiuso';

  @override
  String get conversationOpened => 'Messaggio aperto';

  @override
  String failedToLoadQuote(String error) {
    return 'Errore nel caricamento della citazione: \n$error';
  }

  @override
  String failedToMarkConversationAsUnread(String error) {
    return 'Impossibile contrassegnare il messaggio come non letto: $error';
  }

  @override
  String failedToCloseConversation(String error) {
    return 'Impossibile chiudere il messaggio: $error';
  }

  @override
  String failedToOpenConversation(String error) {
    return 'Impossibile aprire il messaggio: $error';
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
  String get enterConversationTitle => 'Inserisci il titolo del messaggio';

  @override
  String enterCode(int count) {
    return 'Inserisci codice a $count cifre';
  }

  @override
  String get edit => 'Modifica';

  @override
  String get remove => 'Rimuovi';

  @override
  String get subject => 'Oggetto';

  @override
  String get message => 'Messaggio';

  @override
  String get titleCannotBeEmpty => 'Il titolo non può essere vuoto';

  @override
  String get conversationUpdatedSuccessfully => 'Messaggio aggiornato';

  @override
  String get goBack => 'Indietro';

  @override
  String get like => 'mettere mi piace a';

  @override
  String get download => 'Scarica';

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
  String get badges => 'Distintivi';

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
  String get chat => 'Chat';

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
  String get checkConnectionAndRetry =>
      'Controlla la connessione a Internet e riprova.';

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
  String get undeleteTopic => 'Ripristina Argomento';

  @override
  String get send => 'Invia';

  @override
  String get changeEmailExplanation =>
      'Invieremo un link di conferma alla tua nuova e-mail. La modifica avrà effetto quando lo aprirai.';

  @override
  String get changeEmailSecurityNote =>
      'Per maggiore sicurezza, Discourse potrebbe chiederti di confermare tramite il link nell’e-mail. Controlla la cartella spam se non la vedi.';

  @override
  String get noMessagesYetSayHi => 'Nessun messaggio ancora — saluta.';

  @override
  String get edited => 'modificato';

  @override
  String get approvedButRelayUnreachable =>
      'Approvato, ma non è stato possibile raggiungere il server delle notifiche per completare la configurazione. Riprova più tardi dalle Impostazioni.';

  @override
  String get notificationsAreTurnedOffForThisApp =>
      'Le notifiche sono disattivate per questa app';

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
  String get solution => 'Soluzione';

  @override
  String get deleted => 'ELIMINATO';

  @override
  String get pleaseLoginToViewUserProfiles =>
      'Accedi per vedere i profili utente.';

  @override
  String get solved => 'Risolto';

  @override
  String get hot => 'Popolare';

  @override
  String get pinned => 'In evidenza';

  @override
  String get locked => 'Bloccato';

  @override
  String get poll => 'Sondaggio';

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
  String get editConversation => 'Modifica titolo';

  @override
  String get closeConversation => 'Chiudi messaggio';

  @override
  String get openConversation => 'Apri messaggio';

  @override
  String get leaveConversation2 => 'Abbandona messaggio';

  @override
  String get closeConversation2 => 'Chiudi messaggio';

  @override
  String get closeConversationConfirmation =>
      'Chiudere questo messaggio? Non accetterà più nuove risposte.';

  @override
  String get close => 'Chiudi';

  @override
  String get openConversation2 => 'Apri messaggio';

  @override
  String get openConversationConfirmation =>
      'Aprire questo messaggio? Accetterà di nuovo nuove risposte.';

  @override
  String get open => 'Apri';

  @override
  String get leaveConversation3 => 'Abbandona messaggio';

  @override
  String get leaveConversationConfirmation =>
      'Vuoi davvero rimuoverti da questo messaggio? Non potrai più vederlo né rispondere.';

  @override
  String get editConversation2 => 'Modifica titolo';

  @override
  String get failedToLoadMessage2 => 'Impossibile caricare il messaggio';

  @override
  String get cannotEditThisConversation =>
      'Non puoi modificare questo messaggio';

  @override
  String get options => 'Opzioni';

  @override
  String get conversationOpen => 'Aperto alle risposte';

  @override
  String get messageTitleHint => 'In breve, di cosa tratta questa discussione?';

  @override
  String get messageOpenForReplies => 'Accetta nuove risposte';

  @override
  String get messageClosedForReplies => 'Chiuso: nessuna nuova risposta';

  @override
  String get messageSentWithoutId =>
      'Il messaggio è stato inviato, ma il forum non l\'ha restituito. Controlla i tuoi messaggi.';

  @override
  String get messageCouldNotBeSent => 'Impossibile inviare il messaggio.';

  @override
  String get messageIdMissing =>
      'Impossibile aprire questo messaggio: manca l\'ID.';

  @override
  String get pleaseAddARecipient => 'Aggiungi almeno un destinatario';

  @override
  String get archiveMessage => 'Archivia';

  @override
  String get moveToInbox => 'Sposta in posta in arrivo';

  @override
  String get messageInbox => 'In arrivo';

  @override
  String get messageArchive => 'Archiviati';

  @override
  String get messageListUnread => 'Non letti';

  @override
  String get messageListNew => 'Nuovo';

  @override
  String get messageListSent => 'Inviati';

  @override
  String removeFromMessageConfirm(String name) {
    return 'Vuoi davvero rimuovere $name da questo messaggio?';
  }

  @override
  String uploadingFilename(String filename) {
    return 'Caricamento: $filename…';
  }

  @override
  String get messageArchived => 'Messaggio archiviato';

  @override
  String get messageMovedToInbox => 'Spostato in posta in arrivo';

  @override
  String failedToArchiveMessage(Object error) {
    return 'Impossibile archiviare il messaggio: $error';
  }

  @override
  String failedToMoveMessageToInbox(Object error) {
    return 'Impossibile spostare il messaggio in posta in arrivo: $error';
  }

  @override
  String get noArchivedMessages => 'Non hai messaggi archiviati';

  @override
  String get noArchivedMessagesHint =>
      'Archivia un messaggio dal suo menu ⋮ per conservarlo qui.';

  @override
  String groupHasBeenInvited(String group) {
    return '$group è stato invitato al messaggio';
  }

  @override
  String participantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partecipanti',
      one: '1 partecipante',
    );
    return '$_temp0';
  }

  @override
  String get chatChannels => 'Canali';

  @override
  String get chatDms => 'DM';

  @override
  String get chatNoChannels => 'Non hai ancora aderito a nessun canale!';

  @override
  String get chatNoDms => 'Non hai ancora aderito a nessun messaggio diretto!';

  @override
  String get chatNoDmsCta => 'Iniziare una conversazione';

  @override
  String chatPlaceholderChannel(String channel) {
    return 'Chatta in $channel';
  }

  @override
  String chatPlaceholderUsers(String names) {
    return 'Chatta con $names';
  }

  @override
  String get chatPlaceholderSelf => 'Scrivi qualche annotazione';

  @override
  String get chatPlaceholderArchived =>
      'Il canale è archiviato, non puoi inviare nuovi messaggi in questo momento.';

  @override
  String get chatPlaceholderClosed =>
      'Il canale è chiuso, non puoi inviare nuovi messaggi in questo momento.';

  @override
  String get chatPlaceholderReadOnly =>
      'Il canale è in sola lettura, non è possibile inviare nuovi messaggi in questo momento.';

  @override
  String get chatPlaceholderSilenced =>
      'In questo momento non puoi inviare messaggi.';

  @override
  String get chatDeleteConfirm => 'Intendi davvero eliminare questo messaggio?';

  @override
  String get chatStartNewDm => 'Nuovo DM';

  @override
  String get chatCreatePersonal => 'Crea una chat personale';

  @override
  String get chatCreateGroup => 'Crea chat di gruppo';

  @override
  String get chatCannotCreate =>
      'Spiacenti, non puoi inviare messaggi diretti.';

  @override
  String get chatDisabledUser => 'ha disabilitato la chat';

  @override
  String get chatSearchPlaceholder => '@qualcuno';

  @override
  String get chatAddMorePlaceholder => '...aggiungi altri membri';

  @override
  String chatUserNotFound(String name) {
    return '@$name non trovato';
  }

  @override
  String get chatCouldNotStartDm => 'Impossibile avviare la chat.';

  @override
  String get chatSignInTitle => 'Accedi per usare la chat';

  @override
  String get chatSignInMessage =>
      'Devi accedere per vedere i canali di chat e unirti a essi.';

  @override
  String get chatDirectMessage => 'Messaggio diretto';

  @override
  String get chatNotAvailable => 'La chat non è disponibile su questo forum.';

  @override
  String get chatAttachFile => 'Allega un file';

  @override
  String get chatRemoveUpload => 'Rimuovi file';

  @override
  String get takePhoto => 'Scatta una foto';

  @override
  String get postNeedsApprovalTitle => 'Messaggio Da Approvare';

  @override
  String get postNeedsApprovalBody =>
      'Abbiamo ricevuto il tuo messaggio ma prima che appaia deve essere approvato da un moderatore. Attendi.';

  @override
  String maximumAttachmentsAllowed(Object count) {
    return 'Massimo $count allegati consentiti';
  }

  @override
  String get noImagesFoundToDisplay => 'Nessuna immagine da mostrare.';

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
      'Elimina il tuo account e i tuoi messaggi, se il forum lo consente. Altrimenti lo staff può rimuoverlo per te.';

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
  String get errorLoadingNotifications =>
      'Errore nel caricamento delle notifiche';

  @override
  String get noNewNotificationsExplanation =>
      'Riceverai una notifica in questo pannello sulle attività che ti riguardano direttamente, quali risposte ai tuoi argomenti e messaggi. quando qualcuno ti @menziona o ti cita e risponde agli argomenti che stai osservando. Le notifiche verranno inviate anche alla tua e-mail quando non hai effettuato l\'accesso per un po\' di tempo.';

  @override
  String noTagsMatch(Object filter) {
    return 'Nessun tag corrisponde a \"$filter\".';
  }

  @override
  String noTopicsTagged(Object tag) {
    return 'Nessun argomento con il tag \"$tag\"';
  }

  @override
  String get searchUser => 'Cerca utente';

  @override
  String get tapToOpen => 'Tocca per aprire';

  @override
  String get imageNotAvailable => 'Immagine non disponibile';

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
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return 'Solo altri $remainingSlots allegati consentiti. Verranno elaborate le prime $remainingSlots2 immagini.';
  }

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
  String get failedToUpdatePostPleaseTryAgain =>
      'Aggiornamento del post non riuscito. Riprova.';

  @override
  String get postDeletedSuccessfully => 'Post eliminato';

  @override
  String failedToDeletePost(Object error) {
    return 'Eliminazione del post non riuscita: $error';
  }

  @override
  String get editHistoryNotAvailable =>
      'La cronologia delle modifiche non è disponibile per questo post';

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
  String get suggestedTopics => 'Argomenti suggeriti';

  @override
  String get suggestedMessages => 'Messaggi Suggeriti';

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
  String get notSignedIn => 'Non hai effettuato l’accesso';

  @override
  String get deviceWillNotShowAlertsUntilAllowedInSettings =>
      'Il dispositivo non mostrerà avvisi finché non consenti le notifiche nelle Impostazioni.';

  @override
  String get openSettings => 'Apri impostazioni';

  @override
  String get notificationsThisDeviceSection => 'Su questo dispositivo';

  @override
  String notificationsThisDeviceCaption(Object forumName) {
    return 'Push da $forumName solo su questo dispositivo. Gli altri tuoi dispositivi e il web non cambiano.';
  }

  @override
  String notificationsAccountSection(Object forumName) {
    return 'Il tuo account su $forumName';
  }

  @override
  String get notificationsAccountCaption =>
      'Valgono ovunque: sul web, via email e su tutti i tuoi dispositivi.';

  @override
  String pushOnThisDeviceSubtitle(Object forumName) {
    return 'Attive: le nuove notifiche di $forumName arrivano su questo dispositivo.';
  }

  @override
  String pushOffThisDeviceSubtitle(Object forumName) {
    return 'Disattivate su questo dispositivo. Per attivarle, approvi una volta su $forumName.';
  }

  @override
  String get stopPushOnThisDevice => 'Interrompi push su questo dispositivo';

  @override
  String stopPushTitle(Object forumName) {
    return 'Interrompere il push di $forumName su questo dispositivo?';
  }

  @override
  String get stopPushOnlyThisDevice =>
      'Si ferma solo questo dispositivo. Gli altri tuoi dispositivi mantengono il loro.';

  @override
  String get stopPushNothingElseChanges =>
      'Le tue notifiche restano visibili nell’app e sul web, e le email del forum non cambiano.';

  @override
  String stopPushPermissionDeleted(Object forumName) {
    return 'Il permesso che hai dato su $forumName viene eliminato. Per riattivare il push dovrai approvarlo di nuovo lì.';
  }

  @override
  String get stopPushQuietHint =>
      'Vuoi solo un po’ di silenzio? Disattiva qui sopra i tipi che non ti servono, oppure usa Non disturbare nel tuo profilo.';

  @override
  String get stopPush => 'Interrompi push';

  @override
  String get turnOn => 'Attiva';

  @override
  String get couldNotTurnOffNotifications =>
      'Impossibile interrompere il push. Riprova più tardi.';

  @override
  String actionCodeTopicCreated(String when) {
    return 'Ha creato questo argomento $when';
  }

  @override
  String actionCodePublicTopic(String when) {
    return 'Ha reso questo argomento pubblico il $when';
  }

  @override
  String actionCodeOpenTopic(String when) {
    return 'Ha convertito questo contenuto in un argomento il $when';
  }

  @override
  String actionCodePrivateTopic(String when) {
    return 'Ha reso questo argomento un messaggio personale il $when';
  }

  @override
  String actionCodeSplitTopic(String when) {
    return 'Ha separato questo argomento il $when';
  }

  @override
  String actionCodeInvitedUser(String who, String when) {
    return 'Ha invitato $who $when';
  }

  @override
  String actionCodeInvitedGroup(String who, String when) {
    return 'Ha invitato $who $when';
  }

  @override
  String actionCodeUserLeft(String who, String when) {
    return '$who ha rimosso se stesso da questo messaggio $when';
  }

  @override
  String actionCodeRemovedUser(String who, String when) {
    return 'Ha rimosso $who $when';
  }

  @override
  String actionCodeRemovedGroup(String who, String when) {
    return 'Ha rimosso $who $when';
  }

  @override
  String actionCodeAutobumped(String when) {
    return 'Riproposto automaticamente $when';
  }

  @override
  String actionCodeTagsChanged(String when) {
    return 'Etichette aggiornate il giorno $when';
  }

  @override
  String actionCodeCategoryChanged(String when) {
    return 'Categoria aggiornata il giorno $when';
  }

  @override
  String get actionCodeForwarded => 'Ha inoltrato l\'e-mail sopra';

  @override
  String actionCodeAutoclosedEnabled(String when) {
    return 'Chiuso $when';
  }

  @override
  String actionCodeAutoclosedDisabled(String when) {
    return 'Aperto $when';
  }

  @override
  String actionCodeClosedEnabled(String when) {
    return 'Chiuso $when';
  }

  @override
  String actionCodeClosedDisabled(String when) {
    return 'Aperto $when';
  }

  @override
  String actionCodeArchivedEnabled(String when) {
    return 'Archiviato $when';
  }

  @override
  String actionCodeArchivedDisabled(String when) {
    return 'Archiviazione annullata $when';
  }

  @override
  String actionCodePinnedEnabled(String when) {
    return 'Appuntato $when';
  }

  @override
  String actionCodePinnedDisabled(String when) {
    return 'Sbloccato $when';
  }

  @override
  String actionCodePinnedGloballyEnabled(String when) {
    return 'Appuntato globalmente $when';
  }

  @override
  String actionCodePinnedGloballyDisabled(String when) {
    return 'Sbloccato $when';
  }

  @override
  String actionCodeVisibleEnabled(String when) {
    return 'Visibile in elenco $when';
  }

  @override
  String actionCodeVisibleDisabled(String when) {
    return 'Non visibile in elenco $when';
  }

  @override
  String actionCodeBannerEnabled(String when) {
    return 'Lo ha reso un banner il $when. Apparirà in cima a ogni pagina finché non verrà chiuso dall\'utente.';
  }

  @override
  String actionCodeBannerDisabled(String when) {
    return 'Ha rimosso questo banner il $when. Non apparirà più in cima a ogni pagina.';
  }

  @override
  String actionCodeAssigned(String who, String when) {
    return 'Assegnato a $who $when';
  }

  @override
  String actionCodeUnassigned(String who, String when) {
    return 'Assegnazione a $who $when annullata';
  }

  @override
  String actionCodeReassigned(String who, String when) {
    return 'Riassegnato a $who $when';
  }

  @override
  String localDateToday(String time) {
    return 'Oggi $time';
  }

  @override
  String localDateTomorrow(String time) {
    return 'Domani $time';
  }

  @override
  String localDateYesterday(String time) {
    return 'Ieri $time';
  }

  @override
  String get eventExpired => 'Scaduto';

  @override
  String get eventEveryDay => 'Ogni giorno';

  @override
  String get eventEveryWeekday => 'Ogni giorno feriale';

  @override
  String get eventEveryWeek => 'Ogni settimana in questo giorno feriale';

  @override
  String get eventEveryTwoWeeks =>
      'Ogni due settimane in questo giorno feriale';

  @override
  String get eventEveryFourWeeks =>
      'Ogni quattro settimane in questo giorno feriale';

  @override
  String get eventEveryMonth => 'Ogni mese in questo giorno feriale';

  @override
  String get errorNoConnection =>
      'Impossibile raggiungere il forum. Controlla la connessione e riprova.';

  @override
  String get errorTimedOut =>
      'Il forum ha impiegato troppo tempo a rispondere. Riprova.';

  @override
  String get errorPaywalled =>
      'Questo contenuto è riservato ai membri paganti del forum.';

  @override
  String get errorBlocked =>
      'Il firewall del forum ha bloccato l\'app. Riprova più tardi o apri il forum in un browser.';

  @override
  String get errorNotAllowed =>
      'Non hai accesso a questo contenuto. Accedere potrebbe aiutare.';

  @override
  String get errorNotFound => 'Questo contenuto non esiste o è stato rimosso.';

  @override
  String get errorRateLimited =>
      'Stai facendo questa operazione troppo spesso. Attendi un momento e riprova.';

  @override
  String get errorForumDown =>
      'Il forum non risponde al momento. Riprova più tardi.';

  @override
  String get deleteSpammer => 'Cancella spammer';

  @override
  String get yesDeleteSpammer => 'Sì, cancella lo spammer';

  @override
  String get deleteSpammerConfirm =>
      'Stai per cancellare i messaggi e gli argomenti di questo utente, rimuovere il suo account, bloccare le registrazioni dal suo indirizzo IP e aggiungere il suo indirizzo email a un elenco di indirizzi bloccati permanente. Sei sicuro che questo utente sia veramente uno spammer?';

  @override
  String get userWasDeleted => 'L\'utente è stato cancellato.';

  @override
  String get deleteMyAccount => 'Cancella il mio account';

  @override
  String get deleteAccountConfirm =>
      'Vuoi cancellare il tuo account in modo permanente? Questa azione non può essere annullata!';

  @override
  String get deletedYourself =>
      'Il tuo account è stato eliminato con successo.';

  @override
  String get deleteYourselfNotAllowed =>
      'Contattare un membro dello staff per richiedere l\'eliminazione del proprio account';

  @override
  String get createTopic => 'Crea Argomento';

  @override
  String get discardPostQuestion => 'Vuoi eliminare il tuo messaggio?';

  @override
  String get discardChangesQuestion => 'Vuoi annullare le modifiche?';

  @override
  String get discardChanges => 'Annulla modifiche';

  @override
  String get saveDraft => 'Salva bozza';

  @override
  String get notificationSettings => 'Impostazioni notifiche';

  @override
  String get topicIsNew => 'Nuovo argomento';

  @override
  String get noNewTopicsSinceLastVisit =>
      'Nessun nuovo argomento dall\'ultima visita.';

  @override
  String get messageIsNew => 'Nuovo messaggio';

  @override
  String topicUnreadReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count risposte non lette',
      one: '1 risposta non letta',
    );
    return '$_temp0';
  }

  @override
  String filterNewWithCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nuovi ($count)',
      one: 'Nuovo ($count)',
    );
    return '$_temp0';
  }

  @override
  String filterUnreadWithCount(int count) {
    return 'Non letti ($count)';
  }

  @override
  String categoryNewTopics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuovi',
      one: '$count nuovo',
    );
    return '$_temp0';
  }

  @override
  String categoryUnreadTopics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count non letti',
      one: '$count non letto',
    );
    return '$_temp0';
  }

  @override
  String get dismissNew => 'Ignora nuovi';

  @override
  String get dismissUnread => 'Ignora non letti';

  @override
  String get dismissNewTitle => 'Ignorare i nuovi argomenti?';

  @override
  String get dismissNewMessage => 'Non verranno più mostrati come nuovi.';

  @override
  String get dismissUnreadTitle => 'Ignorare tutti i non letti?';

  @override
  String get dismissUnreadMessage =>
      'Le loro nuove risposte verranno segnate come lette.';

  @override
  String get dismissUnreadStopTracking =>
      'Smetti di seguire questi argomenti in modo che non vengano più visualizzati come non letti per me';

  @override
  String get dismissNewAndUnread => 'Ignora nuovi e non letti';

  @override
  String dismissNewAndUnreadMessage(String category) {
    return 'Gli argomenti in $category non verranno più mostrati come nuovi o non letti.';
  }

  @override
  String get dismissedTopics => 'Ignorati';

  @override
  String topicMapViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'visualizzazioni',
      one: 'visualizzazione',
    );
    return '$_temp0';
  }

  @override
  String topicMapLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mi piace',
    );
    return '$_temp0';
  }

  @override
  String topicMapLinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'link',
    );
    return '$_temp0';
  }

  @override
  String topicMapUsers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'utenti',
      one: 'utente',
    );
    return '$_temp0';
  }

  @override
  String get markAsSolution => 'Segna come soluzione';

  @override
  String get unmarkAsSolution => 'Rimuovi come soluzione';

  @override
  String searchForumName(String forum) {
    return 'Cerca in $forum';
  }

  @override
  String countActiveThisMonth(String formatted) {
    return '$formatted attivi questo mese';
  }

  @override
  String countMembers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted membri',
      one: '$formatted membro',
    );
    return '$_temp0';
  }

  @override
  String countTopics(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted argomenti',
      one: '$formatted argomento',
    );
    return '$_temp0';
  }

  @override
  String categoryNewThisWeek(int count) {
    return '$count nuovi questa settimana';
  }

  @override
  String get categoriesView => 'Categorie';

  @override
  String get allCategories => 'Tutte le categorie';

  @override
  String get allTags => 'Tutte le etichette';

  @override
  String get myPosts => 'I miei messaggi';

  @override
  String get drawerIntroduction =>
      'Le categorie, i tag e il tuo account di questo forum sono in questo menu. Riaprilo quando vuoi con il pulsante del menu.';

  @override
  String trustLevelN(int level) {
    return 'Livello di fiducia $level';
  }

  @override
  String get filterNew => 'Nuovi';

  @override
  String get filterTop => 'Top';

  @override
  String get levelWatching => 'In osservazione';

  @override
  String get levelWatchingFirstPost => 'Osserva primo messaggio';

  @override
  String get levelTracking => 'Seguito';

  @override
  String get levelNormal => 'Normale';

  @override
  String get levelMuted => 'Silenziato';

  @override
  String get chooseCategory => 'Scegli una categoria';

  @override
  String get signInToPostAndGetNotifications =>
      'Accedi per pubblicare e ricevere notifiche';

  @override
  String forumBlocksNotificationServer(Object forumName) {
    return '$forumName blocca il nostro server delle notifiche, quindi potrebbero non arrivare. Puoi disattivarle nelle Impostazioni.';
  }

  @override
  String get relatedTopics => 'Argomenti correlati';

  @override
  String get relatedMessages => 'Messaggi correlati';

  @override
  String moreInCategory(String category) {
    return 'Altro in $category';
  }

  @override
  String get latestTopics => 'Argomenti recenti';

  @override
  String get pushGroupMessages => 'Messaggi e chat';

  @override
  String get pushGroupMessagesHint =>
      'Messaggi personali, caselle di gruppo e chat';

  @override
  String get pushGroupReplies => 'Risposte e menzioni';

  @override
  String get pushGroupRepliesHint =>
      'Risposte, menzioni, citazioni e argomenti che segui';

  @override
  String get pushGroupReactions => 'Mi piace e reazioni';

  @override
  String get pushGroupReactionsHint => 'Mi piace e reazioni ai tuoi post';

  @override
  String get pushGroupOther => 'Tutto il resto';

  @override
  String get pushGroupOtherHint =>
      'Distintivi, promemoria, risposte accettate e altro';

  @override
  String get pushChannelOther => 'Altre notifiche';

  @override
  String get couldNotChangePushSetting =>
      'Impossibile modificare questa impostazione. Riprova più tardi.';

  @override
  String neverMissAReplyOn(Object forumName) {
    return 'Non perdere nessuna risposta su $forumName';
  }

  @override
  String get notificationsPitch =>
      'Risposte, menzioni, messaggi e chat sulla schermata di blocco, di solito entro 10 minuti. Puoi scegliere quali in qualsiasi momento nelle Impostazioni.';

  @override
  String get notificationsStepAllow =>
      'Consenti le notifiche su questo telefono';

  @override
  String get notificationsStepAllowed =>
      'Le notifiche sono consentite su questo telefono';

  @override
  String notificationsStepApprove(Object forumName) {
    return 'Approva su $forumName';
  }

  @override
  String get notificationsReadOnlyNote =>
      'Sola lettura: non può pubblicare, rispondere né leggere i tuoi messaggi';

  @override
  String get notificationPreviewReply =>
      'Jane ti ha risposto: Benvenuto! Siamo felici che ci hai trovati.';

  @override
  String get notificationPreviewMessage =>
      'Sam ti ha inviato un messaggio: Vieni venerdì?';

  @override
  String get notificationPreviewNow => 'ora';

  @override
  String get notificationPreviewEarlier => '5 min fa';

  @override
  String get activityReplied => 'Ha risposto';

  @override
  String get activityStartedTopic => 'Ha aperto un argomento';

  @override
  String get activityLiked => 'Mi piace';

  @override
  String get activitySolution => 'Soluzione';

  @override
  String get activityAcceptedBy => 'accettata da';

  @override
  String get activityAwaitingApproval => 'In attesa di approvazione';

  @override
  String get activityFilterTopics => 'Argomenti';

  @override
  String get activityFilterReplies => 'Risposte';

  @override
  String get activityFilterLikes => 'Mi piace';

  @override
  String get activityFilterPending => 'In attesa';

  @override
  String get sectionToday => 'Oggi';

  @override
  String get sectionThisWeek => 'Questa settimana';

  @override
  String get sectionEarlier => 'Prima';

  @override
  String draftsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bozze in attesa',
      one: '1 bozza in attesa',
    );
    return '$_temp0';
  }

  @override
  String get resumeDrafts => 'Riprendi';

  @override
  String get myPostsEmpty => 'Ancora nessun messaggio';

  @override
  String get myPostsEmptyHint =>
      'Gli argomenti che apri e le risposte che scrivi appariranno qui.';

  @override
  String get activityEmptyTopics => 'Ancora nessun argomento';

  @override
  String get activityEmptyReplies => 'Ancora nessuna risposta';

  @override
  String get activityEmptyLikes => 'Nessun Mi piace dato';

  @override
  String get activityEmptySolved => 'Ancora nessuna soluzione';

  @override
  String get viewProfile => 'Vedi profilo';

  @override
  String get yourStuff => 'Le tue cose';

  @override
  String get accountAndPrivacy => 'Account e privacy';

  @override
  String profileStatPosts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'messaggi',
      one: 'messaggio',
    );
    return '$_temp0';
  }

  @override
  String profileStatLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mi piace',
    );
    return '$_temp0';
  }

  @override
  String profileStatDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'giorni',
      one: 'giorno',
    );
    return '$_temp0';
  }

  @override
  String get profileStatSolved => 'risolti';

  @override
  String joinForum(String forum) {
    return 'Unisciti a $forum';
  }

  @override
  String get guestBenefitPost => 'Rispondi e apri argomenti';

  @override
  String get guestBenefitNotify => 'Ricevi notifiche quando qualcuno risponde';

  @override
  String get guestBenefitSave => 'Salva messaggi e bozze';

  @override
  String get guestBenefitChat => 'Chatta e invia messaggi';

  @override
  String get createAccount => 'Crea account';

  @override
  String get aboutThisForum => 'Informazioni su questo forum';

  @override
  String get drawerMore => 'Altro';

  @override
  String get goToYourProfile => 'Vai al tuo profilo';

  @override
  String profileJoined(String date) {
    return 'Iscritto da $date';
  }

  @override
  String profileSeen(String when) {
    return 'Visto $when';
  }

  @override
  String profileLocalTime(String time) {
    return '$time ora locale';
  }

  @override
  String get profileTabSummary => 'Riepilogo';

  @override
  String get summaryTopReplies => 'Migliori risposte';

  @override
  String get summaryTopTopics => 'Migliori argomenti';

  @override
  String get summaryMostLikedBy => 'Più apprezzato da';

  @override
  String get summaryMostLiked => 'Ha apprezzato di più';

  @override
  String get summaryMostRepliedTo => 'Ha risposto di più a';

  @override
  String get summaryTopLinks => 'Link principali';

  @override
  String get summaryTopCategories => 'Categorie principali';

  @override
  String get featuredTopic => 'Argomento in evidenza';

  @override
  String get profileDetails => 'Dettagli';

  @override
  String get followUser => 'Segui';

  @override
  String get unfollowUser => 'Non seguire più';

  @override
  String get profileSuspended => 'Sospeso';

  @override
  String get searchBookmarks => 'Cerca nei segnalibri';

  @override
  String get bookmarksFilterReminders => 'Promemoria';

  @override
  String get bookmarkWholeTopic => 'Intero argomento';

  @override
  String bookmarkSaved(String when) {
    return 'salvato $when';
  }

  @override
  String bookmarkPostNumber(int number) {
    return 'messaggio #$number';
  }

  @override
  String reminderToday(String time) {
    return 'Oggi, $time';
  }

  @override
  String reminderTomorrow(String time) {
    return 'Domani, $time';
  }

  @override
  String reminderDue(String when) {
    return 'Scaduto · $when';
  }

  @override
  String get addBookmarkLabel => 'Aggiungi etichetta';

  @override
  String get editBookmarkLabel => 'Modifica etichetta';

  @override
  String get bookmarkLabelHint => 'A cosa serve?';

  @override
  String get pinBookmark => 'Fissa in alto';

  @override
  String get unpinBookmark => 'Sblocca';

  @override
  String get bookmarkRemoved => 'Segnalibro rimosso';

  @override
  String get undo => 'Annulla';

  @override
  String get bookmarksNoMatch => 'Nessun segnalibro corrisponde';

  @override
  String get addReminder => 'Aggiungi promemoria';

  @override
  String get bookmarksEmpty => 'Ancora nessun segnalibro';

  @override
  String get bookmarksEmptyHint =>
      'Aggiungi un messaggio ai segnalibri dalle sue azioni e ti aspetterà qui.';

  @override
  String get draftKindNewTopic => 'Nuovo argomento';

  @override
  String draftMessageTo(String names) {
    return 'Messaggio a $names';
  }

  @override
  String get untitledTopic => 'Argomento senza titolo';

  @override
  String get draftDiscarded => 'Bozza scartata';

  @override
  String get draftsEmpty => 'Ancora nessuna bozza';

  @override
  String get draftsEmptyHint =>
      'Le bozze si salvano mentre scrivi. Inizia una risposta o un argomento e ti aspetterà qui.';

  @override
  String get privacySection => 'Privacy';

  @override
  String get changeEmailSubtitle =>
      'Invieremo un link di verifica al nuovo indirizzo';

  @override
  String get aboutMe => 'Su di me';

  @override
  String get aboutMeHelper => 'Mostrato in cima al tuo profilo';

  @override
  String get aboutMeMarkdownHint =>
      'Markdown supportato: **grassetto**, link, :emoji:';

  @override
  String get addCover => 'Aggiungi copertina';

  @override
  String get changeCover => 'Cambia copertina';

  @override
  String get birthdayHint =>
      'Il forum lo festeggia con te. L’anno non viene salvato.';

  @override
  String get birthdayRemoved => 'Compleanno rimosso';

  @override
  String get birthdaySaved => 'Compleanno salvato';

  @override
  String get cardBackground => 'Sfondo della scheda';

  @override
  String get cardBackgroundExplanation =>
      'Dietro la tua scheda utente quando qualcuno tocca la tua foto';

  @override
  String get cardBackgroundRemoved => 'Sfondo della scheda rimosso';

  @override
  String get cardBackgroundSheetHint =>
      'Mostrato dietro la tua scheda utente. Le foto larghe rendono meglio.';

  @override
  String get changeProfilePicture => 'Cambia immagine del profilo';

  @override
  String get changeUsername => 'Cambia nome utente';

  @override
  String changeUsernameExplanation(String username) {
    return 'Le menzioni e le citazioni di @$username nei post passano al nuovo nome. I vecchi link al tuo profilo smettono di funzionare.';
  }

  @override
  String get chooseFromLibrary => 'Scegli dalla galleria';

  @override
  String get coverPhoto => 'Foto di copertina';

  @override
  String get coverPhotoSheetHint =>
      'Mostrata in cima al tuo profilo, dietro la tua immagine. Le foto larghe rendono meglio, circa 3 a 1.';

  @override
  String get coverRemoved => 'Copertina rimossa';

  @override
  String get day => 'Giorno';

  @override
  String get month => 'Mese';

  @override
  String get displayName => 'Nome visualizzato';

  @override
  String displayNameHelper(String username) {
    return 'Mostrato con i tuoi post. Il tuo nome utente resta @$username.';
  }

  @override
  String get emailPasswordInAccount => 'E-mail, password e accesso';

  @override
  String get featureATopic => 'Metti in evidenza un argomento';

  @override
  String get featureATopicHint =>
      'Fissa uno dei tuoi argomenti in cima al tuo profilo.';

  @override
  String get featuredTopicChanged => 'Argomento in evidenza cambiato';

  @override
  String get featuredTopicNone =>
      'Nessuno. Fissa uno dei tuoi argomenti sul profilo.';

  @override
  String get featuredTopicRemoved => 'Argomento in evidenza rimosso';

  @override
  String get featuredTopicRules =>
      'I messaggi e gli argomenti nelle categorie private non possono essere messi in evidenza.';

  @override
  String get fieldManagedBySignIn =>
      'Questo forum lo gestisce tramite il proprio accesso. Modificalo lì.';

  @override
  String get flair => 'Emblema';

  @override
  String flairChangedTo(String group) {
    return 'Emblema cambiato in $group';
  }

  @override
  String get flairRemoved => 'Emblema rimosso';

  @override
  String get flairSheetHint =>
      'Un piccolo emblema sulla tua immagine, da un gruppo di cui fai parte.';

  @override
  String forumPictureN(int number) {
    return 'Immagine del forum $number';
  }

  @override
  String forumQuestionNeedsAnswer(String question) {
    return '$question richiede una risposta';
  }

  @override
  String get forumQuestionRequired =>
      'Questo forum chiede a tutti di rispondere';

  @override
  String get forumQuestionSetByStaff => 'Impostato dallo staff del forum';

  @override
  String get forumQuestionsIntro =>
      'Domande di questo forum. * indica una risposta obbligatoria.';

  @override
  String get forumQuestionsNoneAnswered => 'Nessuna risposta ancora';

  @override
  String get fromThisForum => 'Da questo forum';

  @override
  String get hideMyProfile => 'Nascondi il mio profilo pubblico';

  @override
  String get hideMyProfileExplanation =>
      'Gli altri vedono solo il tuo nome, la tua immagine e i tuoi post';

  @override
  String get letterAvatar => 'Iniziale';

  @override
  String get moreAboutYou => 'Altro su di te';

  @override
  String namesAndMore(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'altri $count',
      one: '1 altro',
    );
    return '$names e $_temp0';
  }

  @override
  String get newUsername => 'Nuovo nome utente';

  @override
  String get noFlair => 'Nessun emblema';

  @override
  String noGravatarFound(String service) {
    return '$service non ha un’immagine per il tuo indirizzo e-mail';
  }

  @override
  String get noTitle => 'Nessun titolo';

  @override
  String get noTopicsMatch => 'Nessuno dei tuoi argomenti corrisponde';

  @override
  String get noTopicsToFeature => 'Non hai ancora aperto nessun argomento';

  @override
  String get notSet => 'Non impostato';

  @override
  String get orUse => 'Oppure usa';

  @override
  String get pictureManagedBySignIn =>
      'Questo forum imposta la tua immagine tramite il proprio accesso';

  @override
  String get primaryGroup => 'Gruppo principale';

  @override
  String primaryGroupChangedTo(String group) {
    return 'Gruppo principale cambiato in $group';
  }

  @override
  String get primaryGroupRemoved => 'Gruppo principale rimosso';

  @override
  String get primaryGroupSheetHint =>
      'Il tuo gruppo principale, mostrato sulla tua scheda utente.';

  @override
  String get profileLoadFailed => 'Impossibile caricare il tuo profilo';

  @override
  String get profileNowHidden => 'Il tuo profilo è nascosto';

  @override
  String get profileNowPublic => 'Il tuo profilo è pubblico';

  @override
  String get profilePicture => 'Immagine del profilo';

  @override
  String get profilePictureChanged => 'Immagine del profilo cambiata';

  @override
  String get profileSaveFailed => 'Impossibile salvare. Riprova.';

  @override
  String get profileSectionNameAndAbout => 'Nome e presentazione';

  @override
  String get profileSectionNextToName => 'Accanto al tuo nome';

  @override
  String get profileSectionOnProfile => 'Sul tuo profilo';

  @override
  String get profileSectionPrivacyAndTime => 'Privacy e orario';

  @override
  String get removeCardBackground => 'Rimuovi sfondo della scheda';

  @override
  String get removeCover => 'Rimuovi copertina';

  @override
  String get removeFeaturedTopic => 'Rimuovi argomento in evidenza';

  @override
  String get searchTimezones => 'Cerca fusi orari';

  @override
  String get searchYourTopics => 'Cerca nei tuoi argomenti';

  @override
  String get seeProfileAsOthersDo =>
      'Vedi il tuo profilo come lo vedono gli altri';

  @override
  String get timezone => 'Fuso orario';

  @override
  String timezoneChangedTo(String zone) {
    return 'Fuso orario cambiato in $zone';
  }

  @override
  String timezoneWithTime(String zone, String time) {
    return '$zone · adesso $time';
  }

  @override
  String timezonesMatchingPhone(String offset) {
    return 'Corrisponde all’orologio di questo telefono ($offset)';
  }

  @override
  String titleChangedTo(String title) {
    return 'Titolo cambiato in $title';
  }

  @override
  String get titleFromBadge => 'Distintivo';

  @override
  String titleFromBadgeEarned(String date) {
    return 'Distintivo · ottenuto il $date';
  }

  @override
  String titleFromGroup(String group) {
    return 'Gruppo $group';
  }

  @override
  String get titleGrantedByStaff => 'Assegnato dallo staff del forum';

  @override
  String get titleRemoved => 'Titolo rimosso';

  @override
  String get titleSheetHint =>
      'Mostrato dopo il tuo nome sul profilo e nei post.';

  @override
  String get username => 'Nome utente';

  @override
  String get usernameAvailable => 'Disponibile';

  @override
  String usernameChanged(String username) {
    return 'Il tuo nome utente ora è @$username';
  }

  @override
  String get usernameLockedExplanation =>
      'Questo forum permette di cambiare il nome utente solo poco dopo l’iscrizione. Un moderatore può cambiarlo per te.';

  @override
  String get yourPhoto => 'La tua foto';

  @override
  String get chooseEmoji => 'Scegli emoji';

  @override
  String get clearStatus => 'Cancella stato';

  @override
  String get clearText => 'Cancella';

  @override
  String get inOneHour => 'Tra un’ora';

  @override
  String get never => 'Mai';

  @override
  String get pauseNotifications => 'Sospendi le notifiche';

  @override
  String get pauseNotificationsUntilStatusClears =>
      'Finché il tuo stato non viene rimosso';

  @override
  String get pickATime => 'Scegli un orario';

  @override
  String get removeStatusAfter => 'Rimuovi stato';

  @override
  String get searchEmoji => 'Cerca emoji';

  @override
  String get setStatus => 'Imposta stato';

  @override
  String get setAStatus => 'Imposta uno stato';

  @override
  String get statusUpdated => 'Stato aggiornato';

  @override
  String get whatAreYouDoing => 'Cosa stai facendo?';

  @override
  String cardPosted(String when) {
    return 'Ultimo post $when';
  }

  @override
  String get change => 'Cambia';

  @override
  String get copyProfileLink => 'Copia link al profilo';

  @override
  String get ignore => 'Ignora';

  @override
  String memberOfGroup(String group) {
    return 'Membro di $group';
  }

  @override
  String get mute => 'Silenzia';

  @override
  String get unmute => 'Riattiva';

  @override
  String openProfileOf(String username) {
    return 'Apri il profilo di @$username';
  }

  @override
  String profileIsPrivate(String username) {
    return '$username tiene privato il proprio profilo.';
  }

  @override
  String showOnlyTheirPostsHere(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'i $count post',
      one: 'il post',
    );
    return 'Mostra solo $_temp0 di $name in questo argomento';
  }

  @override
  String showOnlyYourPostsHere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'i tuoi $count post',
      one: 'il tuo post',
    );
    return 'Mostra solo $_temp0 in questo argomento';
  }

  @override
  String userIgnoredFor4Months(String username) {
    return 'Ignorerai @$username per 4 mesi';
  }

  @override
  String userMuted(String username) {
    return 'Hai silenziato @$username';
  }

  @override
  String userUnmuted(String username) {
    return 'Hai riattivato @$username';
  }

  @override
  String get youParenthetical => '(tu)';

  @override
  String get topicStatusClosedHelp =>
      'Questo argomento è chiuso; non sono ammesse nuove risposte';

  @override
  String get topicStatusArchivedHelp =>
      'Questo argomento è archiviato; è bloccato e non può essere modificato';

  @override
  String get topicStatusClosedArchivedHelp =>
      'Questo argomento è chiuso e archiviato; non sono ammesse nuove risposte e non può essere modificato';

  @override
  String get topicStatusPinnedTitle => 'Appuntato';

  @override
  String get topicStatusPinnedHelp =>
      'Questo argomento è appuntato per te; verrà mostrato in cima alla sua categoria';

  @override
  String get topicStatusPinnedGloballyTitle => 'Appuntato Globalmente';

  @override
  String get topicStatusPinnedGloballyHelp =>
      'Questo argomento è appuntato globalmente; verrà mostrato sempre in cima sia agli argomenti recenti sia nella sua categoria.';

  @override
  String get topicStatusUnpinnedTitle => 'Spuntato';

  @override
  String get topicStatusUnpinnedHelp =>
      'Questo argomento è sbloccato per te; verrà visualizzato in ordine normale';

  @override
  String get topicStatusUnlistedHelp =>
      'Questo argomento è invisibile: non verrà mostrato negli elenchi argomenti ed è possibile accedervi solo tramite collegamento diretto.';

  @override
  String get topicStatusWarningHelp => 'Questo è un avvertimento ufficiale.';

  @override
  String get notificationReasonWatchingTag =>
      'Riceverai notifiche perché stai osservando un\'etichetta in questo argomento.';

  @override
  String get notificationReasonWatchingCategory =>
      'Riceverai notifiche perché stai osservando questa categoria.';

  @override
  String get notificationReasonWatchingAuto =>
      'Riceverai notifiche poiché hai iniziato ad osservare questo argomento automaticamente.';

  @override
  String get notificationReasonWatching =>
      'Riceverai notifiche perché stai osservando questo argomento.';

  @override
  String get notificationReasonWatchingCreated =>
      'Riceverai notifiche perché hai creato questo argomento.';

  @override
  String get notificationReasonTrackingCategory =>
      'Vedrai un conteggio delle nuove risposte perché stai seguendo questa categoria.';

  @override
  String get notificationReasonTrackingReplied =>
      'Vedrai un conteggio delle nuove risposte perché hai pubblicato una risposta in questo argomento.';

  @override
  String get notificationReasonTracking =>
      'Vedrai un conteggio delle nuove risposte perché stai seguendo questo argomento.';

  @override
  String get notificationReasonTrackingRead =>
      'Vedrai un conteggio delle nuove risposte perché hai letto questo argomento.';

  @override
  String get notificationReasonNormal =>
      'Riceverai notifiche se qualcuno menziona il tuo @nome o ti risponde.';

  @override
  String get notificationReasonMutedCategory =>
      'Stai ignorando tutte le notifiche di questa categoria.';

  @override
  String get notificationReasonMuted =>
      'Stai ignorando tutte le notifiche di questo argomento.';

  @override
  String get notificationLevelWatching => 'In osservazione';

  @override
  String get notificationLevelWatchingFirstPost =>
      'Osservazione Primo Messaggio';

  @override
  String get notificationLevelTracking => 'Seguito';

  @override
  String get notificationLevelNormal => 'Normale';

  @override
  String get notificationLevelMuted => 'Silenziato';

  @override
  String get topicWatchingDescription =>
      'Riceverai una notifica per ogni nuova risposta in questo argomento, e comparirà un conteggio delle nuove risposte.';

  @override
  String get topicTrackingDescription =>
      'Per questo argomento apparirà un conteggio delle nuove risposte. Riceverai una notifica se qualcuno menziona il tuo @nome o ti risponde.';

  @override
  String get topicNormalDescription =>
      'Riceverai una notifica se qualcuno menziona il tuo @nome o ti risponde.';

  @override
  String get topicMutedDescription =>
      'Non riceverai mai notifiche di alcun tipo su questo argomento, che non apparirà tra i più recenti.';

  @override
  String get messageWatchingDescription =>
      'Riceverai una notifica per ogni nuova risposta a questo messaggio, e comparirà un conteggio delle nuove risposte.';

  @override
  String get messageTrackingDescription =>
      'Per questo messaggio personale apparirà un conteggio delle nuove risposte. Riceverai una notifica se qualcuno menziona il tuo @nome o ti risponde.';

  @override
  String get messageNormalDescription =>
      'Riceverai una notifica se qualcuno menziona il tuo @nome o ti risponde.';

  @override
  String get messageMutedDescription =>
      'Non riceverai mai notifiche di alcun tipo per questo messaggio.';

  @override
  String get categoryWatchingDescription =>
      'Osserverai automaticamente tutti gli argomenti in questa categoria. Riceverai notifiche per ogni nuovo messaggio in ogni argomento, e apparirà il conteggio delle nuove risposte.';

  @override
  String get categoryWatchingFirstPostDescription =>
      'Riceverai una notifica di nuovi argomenti in questa categoria, ma non per le risposte agli argomenti.';

  @override
  String get categoryTrackingDescription =>
      'Seguirai automaticamente tutti gli argomenti in questa categoria. Riceverai una notifica se qualcuno menziona il tuo @nome o ti risponde, e apparirà un conteggio delle nuove risposte.';

  @override
  String get categoryNormalDescription =>
      'Riceverai una notifica se qualcuno menziona il tuo @nome o ti risponde.';

  @override
  String get categoryMutedDescription =>
      'Non riceverai notifiche circa i nuovi argomenti in questa categoria, inoltre essi non appariranno tra i \"Più recenti\".';

  @override
  String get tagWatchingDescription =>
      'Visualizzerai automaticamente tutti gli Argomenti con questa Etichetta. Riceverai una notifica per tutti i nuovi messaggi e Argomenti. Inoltre, accanto all\'Argomento apparirà il conteggio dei messaggi non letti e di quelli nuovi.';

  @override
  String get tagWatchingFirstPostDescription =>
      'Riceverai una notifica se saranno aperti nuovi Argomenti in questa Etichetta, ma non per le risposte agli Argomenti.';

  @override
  String get tagTrackingDescription =>
      'Seguirai automaticamente tutti gli argomenti con questa etichetta. Accanto all\'argomento apparirà un conteggio dei messaggi non letti e nuovi.';

  @override
  String get tagNormalDescription =>
      'Riceverai una notifica se qualcuno menziona il tuo @nome o risponde al tuo messaggio.';

  @override
  String get tagMutedDescription =>
      'Non riceverai alcuna notifica per nuovi Argomenti con questa Etichetta, e non compariranno nella pagina dei messaggi non letti.';

  @override
  String topicTimerAutoOpen(String timeLeft) {
    return 'Questo argomento verrà automaticamente aperto $timeLeft.';
  }

  @override
  String topicTimerAutoClose(String timeLeft) {
    return 'Questo argomento si chiuderà automaticamente $timeLeft.';
  }

  @override
  String topicTimerAutoPublish(String categoryName, String timeLeft) {
    return 'Questo argomento verrà pubblicato su #$categoryName $timeLeft.';
  }

  @override
  String topicTimerAutoCloseAfterLastPost(String duration) {
    return 'Questo Argomento si chiuderà $duration dopo l\'ultima risposta.';
  }

  @override
  String topicTimerAutoDeleteAfterLastPost(String duration) {
    return 'Questo argomento verrà cancellato $duration dopo l\'ultima risposta.';
  }

  @override
  String topicTimerAutoDelete(String timeLeft) {
    return 'Questo argomento verrà automaticamente cancellato $timeLeft.';
  }

  @override
  String topicTimerAutoBump(String timeLeft) {
    return 'Questo argomento sarà riproposto automaticamente $timeLeft.';
  }

  @override
  String topicTimerAutoDeleteReplies(String duration) {
    return 'Le risposte in questo argomento vengono automaticamente cancellate dopo $duration.';
  }

  @override
  String slowModeNotice(String duration) {
    return 'Attendi $duration tra un tuo messaggio e l\'altro in questo argomento.';
  }

  @override
  String get closeTopic => 'Chiudi Argomento';

  @override
  String get openTopic => 'Apri Argomento';

  @override
  String get pinTopic => 'Appunta Argomento';

  @override
  String get unpinTopic => 'Spunta Argomento';

  @override
  String get archiveTopic => 'Archivia Argomento';

  @override
  String get unarchiveTopic => 'Annulla archiviazione Argomento';

  @override
  String get unlistTopic => 'Nascondi argomento';

  @override
  String get listTopic => 'Metti l\'argomento in elenco';

  @override
  String get permanentlyDelete => 'Elimina definitivamente';

  @override
  String get permanentlyDeleteTopicConfirmation =>
      'Questa azione non può essere annullata. L\'argomento verrà eliminato definitivamente dal database.';

  @override
  String get deleteTopicConfirmYes => 'Sì, elimina questo argomento';

  @override
  String get deleteTopicConfirmNo => 'No, mantieni questo argomento';

  @override
  String get topicPinned => 'Argomento appuntato';

  @override
  String get topicUnpinned => 'Argomento non più appuntato';

  @override
  String get topicArchived => 'Argomento archiviato';

  @override
  String get topicUnarchived => 'Argomento non più archiviato';

  @override
  String get topicUnlisted => 'Argomento nascosto';

  @override
  String get topicListed => 'Argomento messo in elenco';

  @override
  String get topicRecovered => 'Argomento ripristinato';

  @override
  String topicActionFailed(String error) {
    return 'Impossibile aggiornare l\'argomento: $error';
  }

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuti',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ore',
      one: '1 ora',
    );
    return '$_temp0';
  }

  @override
  String durationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni',
      one: '1 giorno',
    );
    return '$_temp0';
  }

  @override
  String timeLeftMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tra $count minuti',
      one: 'tra 1 minuto',
    );
    return '$_temp0';
  }

  @override
  String timeLeftHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tra $count ore',
      one: 'tra 1 ora',
    );
    return '$_temp0';
  }

  @override
  String timeLeftDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tra $count giorni',
      one: 'tra 1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get topicStatusDeletedHelp =>
      'Questo argomento è stato eliminato ed è nascosto agli altri utenti';

  @override
  String get flagAction => 'Segnala';

  @override
  String get flagPost => 'Segnala Messaggio';

  @override
  String get signUp => 'Iscriviti';

  @override
  String get suspendUser => 'Sospendi Utente';

  @override
  String get unsuspend => 'Annulla sospensione';

  @override
  String get suspendUntil => 'Sospendi utente fino a';

  @override
  String get suspendForever => 'Sospendi definitivamente';

  @override
  String failedToSuspendUser(String error) {
    return 'Si è verificato un errore durante la sospensione di questo utente: $error';
  }

  @override
  String failedToUnsuspendUser(String error) {
    return 'Si è verificato un errore durante la riattivazione di questo utente: $error';
  }

  @override
  String get suspendReasonNotListening =>
      'Non ascoltava le raccomandazioni dello staff';

  @override
  String get suspendReasonStaffTime =>
      'Ha fatto sprecare troppo tempo allo staff';

  @override
  String get suspendReasonCombative => 'Troppo veemente';

  @override
  String get suspendReasonWrongPlace => 'Al posto sbagliato';

  @override
  String get suspendReasonNoPurpose =>
      'Azioni senza fini costruttivi se non creare disaccordo nella comunità';

  @override
  String get suspendReasonCustom => 'Personalizzato…';

  @override
  String get suspendReasonQuestion =>
      'Perché stai sospendendo l\'utente? Questo testo gli verrà mostrato tutte le volte che tenterà di accedere. Scrivi un testo breve.';

  @override
  String get closedLabel => 'Chiuso';

  @override
  String get flaggingPost => 'Segnalazione del messaggio…';

  @override
  String get pleaseSelectSuspensionEndDate =>
      'Scegli quando termina la sospensione';

  @override
  String get suspendingUser => 'Sospensione dell\'utente…';

  @override
  String get unsuspendingUser => 'Annullamento della sospensione…';

  @override
  String get userSuspended => 'Utente sospeso';

  @override
  String get userUnsuspended => 'Sospensione annullata';

  @override
  String unsuspendUserConfirmation(String username) {
    return 'Annullare la sospensione di $username? Potrà accedere di nuovo.';
  }

  @override
  String get noCategoriesToDisplay => 'Non ci sono categorie da mostrare.';

  @override
  String get noPermissionToViewCategory =>
      'Non hai il permesso di vedere gli argomenti di questa categoria.';

  @override
  String get featureTopicTitle => 'Poni argomento in primo piano';

  @override
  String get pinTopicMenu => 'Appunta Argomento...';

  @override
  String pinInCategoryUntil(String category) {
    return 'Poni questo argomento in cima alla categoria $category fino a';
  }

  @override
  String get pinGloballyUntil =>
      'Poni questo argomento in cima a tutte le liste di argomenti fino a';

  @override
  String get pinNote =>
      'Gli utenti possono spuntare gli argomenti individualmente per loro stessi.';

  @override
  String get pinUntil => 'Appunta fino a';

  @override
  String get pinDateRequired =>
      'È richiesta una data per appuntare questo argomento.';

  @override
  String get pinTopicGlobally => 'Appunta Argomento Globalmente';

  @override
  String get flagThanks =>
      'Grazie per aver contribuito alla civile convivenza della nostra community!';

  @override
  String get flagReviewProcess =>
      'Tutte le segnalazioni vengono ricevute dai moderatori e saranno esaminate il prima possibile.';

  @override
  String get flagCant =>
      'Spiacenti, al momento non puoi segnalare questo messaggio.';

  @override
  String get flagSendMessage => 'Messaggio';

  @override
  String get flagMessageForUser => 'Messaggio per l\'utente';

  @override
  String get flagMessageForModerators => 'Messaggio per i moderatori';

  @override
  String get flagPlaceholderNotifyUser =>
      'Sii dettagliato, costruttivo e sempre gentile.';

  @override
  String get flagPlaceholderNotifyModerators =>
      'Facci sapere esattamente cosa ti preoccupa, fornendo collegamenti pertinenti ed esempi ove possibile.';

  @override
  String get flagPlaceholderIllegal =>
      'Spiega dettagliatamente il motivo per cui ritieni questo contenuto illegale, fornendo anche collegamenti ed esempi pertinenti ove possibile.';

  @override
  String get flagConfirmIllegal =>
      'Le informazioni di cui sopra sono complete ed esatte.';

  @override
  String flagMessageAtLeast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'inserisci almeno $count caratteri',
      one: 'inserisci almeno $count carattere',
    );
    return '$_temp0';
  }

  @override
  String get flagMessageSent => 'Il tuo messaggio è stato inviato.';

  @override
  String get mergeTopicError =>
      'Si è verificato un errore spostando i messaggi nell\'argomento.';

  @override
  String get topicTitlePlaceholder =>
      'In breve, di cosa tratta questa discussione?';

  @override
  String get topicMoved => 'Argomento spostato';

  @override
  String get topicMerged => 'Argomento unito';

  @override
  String get mergeTopicExplanation =>
      'Tutti i messaggi di questo argomento verranno spostati nell\'argomento scelto. Non si può annullare dall\'app.';

  @override
  String get destinationTopicId => 'ID dell\'argomento di destinazione';

  @override
  String get topicAuthorUnknown => 'Sconosciuto';

  @override
  String get noHotTopics => 'Non ci sono argomenti popolari.';

  @override
  String get signInToViewNewTopics =>
      'Accedi per visualizzare i nuovi argomenti';

  @override
  String get newTopicsSignInMessage =>
      'I nuovi argomenti mostrano ciò che è stato creato dalla tua ultima visita.';

  @override
  String get topPeriodAllTime => 'Sempre';

  @override
  String get topPeriodYear => 'Anno';

  @override
  String get topPeriodQuarter => 'Trimestre';

  @override
  String get topPeriodMonth => 'Mese';

  @override
  String get topPeriodWeek => 'Settimana';

  @override
  String get topPeriodToday => 'Oggi';

  @override
  String noTopTopicsForPeriod(String period) {
    String _temp0 = intl.Intl.selectLogic(
      period,
      {
        'all': 'Nessun argomento popolare di sempre.',
        'yearly': 'Nessun argomento popolare quest\'anno.',
        'quarterly': 'Nessun argomento popolare questo trimestre.',
        'monthly': 'Nessun argomento popolare questo mese.',
        'weekly': 'Nessun argomento popolare questa settimana.',
        'daily': 'Nessun argomento popolare oggi.',
        'other': 'Non ci sono argomenti popolari.',
      },
    );
    return '$_temp0';
  }

  @override
  String get connectionTimedOutSiteUnreachable =>
      'Connessione scaduta. Il sito potrebbe essere offline o irraggiungibile.';

  @override
  String get failedToMarkNotificationsRead =>
      'Impossibile segnare le notifiche come lette';

  @override
  String get forumNameFallback => 'Forum';

  @override
  String get noForumDescription => 'Nessuna descrizione disponibile.';

  @override
  String get dismissAllNotifications => 'Ignora tutti';

  @override
  String get notificationPostIdMissing =>
      'Manca l\'ID del messaggio. Impossibile aprire il messaggio.';

  @override
  String get notificationTopicIdMissingForPost =>
      'Manca l\'ID dell\'argomento. Impossibile aprire il messaggio.';

  @override
  String get notificationTopicIdMissing =>
      'Manca l\'ID dell\'argomento. Impossibile aprire l\'argomento.';

  @override
  String get notificationUsernameMissing =>
      'Manca il nome utente. Impossibile aprire il profilo.';

  @override
  String get notificationChannelIdMissing =>
      'Manca l\'ID del canale. Impossibile aprire la chat.';

  @override
  String get notificationGroupNameMissingForInbox =>
      'Manca il nome del gruppo. Impossibile aprire la posta in arrivo.';

  @override
  String get notificationGroupNameMissing =>
      'Manca il nome del gruppo. Impossibile aprire il gruppo.';

  @override
  String get notificationNoActionUrl =>
      'Nessun URL di azione disponibile per questo tipo di notifica.';

  @override
  String get notificationBadgeUnavailable =>
      'I dettagli del distintivo non sono disponibili.';

  @override
  String get notificationBadgeLoadFailed =>
      'Impossibile caricare questo distintivo.';

  @override
  String get personalMessageTitleFallback => 'Messaggio personale';

  @override
  String get topicTitleFallback => 'Argomento';

  @override
  String get signInToViewNotifications =>
      'Accedi per visualizzare le notifiche';

  @override
  String get youNeedToBeSignedInToViewNotifications =>
      'Devi accedere per visualizzare le tue notifiche.';

  @override
  String get noUnreadNotifications => 'Nessuna notifica non letta';

  @override
  String get noNotificationsYet => 'Ancora nessuna notifica';

  @override
  String get newNotificationFallbackBody => 'Nuova notifica';

  @override
  String get unableToOpenNotification => 'Impossibile aprire la notifica';

  @override
  String get notificationMissingSiteInfo =>
      'Informazioni sul sito mancanti (site_id).';

  @override
  String get notificationInvalidSiteInfo =>
      'Informazioni sul sito non valide (site_id).';

  @override
  String get notificationMissingPostInfo =>
      'Informazioni sul messaggio mancanti (content_id).';

  @override
  String get notificationMissingMessageInfo =>
      'Informazioni sul messaggio privato mancanti (conversation_id).';

  @override
  String get notificationMissingUserInfo =>
      'Informazioni sull\'utente mancanti (sender_id).';

  @override
  String get notificationUnsupportedType => 'Tipo di notifica non supportato.';

  @override
  String get notificationForumNotFound => 'Forum non trovato per questo sito.';

  @override
  String get notificationForumOpenFailed =>
      'Impossibile inizializzare il forum.';

  @override
  String get notificationMissingTopicInfo =>
      'Informazioni sull\'argomento mancanti (topic_id).';

  @override
  String get failedToLoadTags => 'Impossibile caricare le etichette.';

  @override
  String get searchTagsHint => 'Cerca etichette…';

  @override
  String get tagsSortedByCountTooltip =>
      'Ordinate per numero di argomenti — tocca per passare ad A→Z';

  @override
  String get tagsSortedAlphabeticallyTooltip =>
      'Ordinate alfabeticamente — tocca per ordinare per popolarità';

  @override
  String get noTagsYet => 'Ancora nessuna etichetta in questo forum.';

  @override
  String get tagNotificationLevelTooltip => 'Livello di notifica';

  @override
  String get tagTopicsLoadFailed => 'Caricamento non riuscito';

  @override
  String searchFailedWithError(String error) {
    return 'Ricerca fallita: $error';
  }

  @override
  String get searchFiltersButtonTooltip => 'Filtri';

  @override
  String get searchFilterStatusSection => 'Stato';

  @override
  String get searchFilterMyActivitySection => 'La mia attività';

  @override
  String get searchFilterMatchTypeSection => 'Tipo di corrispondenza';

  @override
  String get searchTagsFilterHelper =>
      'Separate da spazi o virgole. Ogni etichetta è obbligatoria.';

  @override
  String get searchSortBy => 'Ordina per';

  @override
  String get searchStatusOpen => 'Aperto';

  @override
  String get searchStatusArchived => 'Archiviato';

  @override
  String get searchStatusNoReplies => 'Senza risposte';

  @override
  String get searchStatusPublicOnly => 'Solo pubblici';

  @override
  String get searchStatusUnsolved => 'Non risolto';

  @override
  String get searchInBookmarked => 'Nei miei segnalibri';

  @override
  String get searchInMyMessages => 'Nei miei messaggi';

  @override
  String get searchInLiked => 'Che mi piacciono';

  @override
  String get searchInPosted => 'Ho pubblicato in';

  @override
  String get searchInWatching => 'Sto osservando';

  @override
  String get searchInTracking => 'Sto seguendo';

  @override
  String get searchInSeen => 'Che ho letto';

  @override
  String get searchInUnseen => 'Che non ho letto';

  @override
  String get searchSortLatestPost => 'Ultimo messaggio';

  @override
  String get searchSortMostLiked => 'Con più \"Mi piace\"';

  @override
  String get searchSortMostViewed => 'Più visti';

  @override
  String get searchSortLatestTopic => 'Ultimo argomento';

  @override
  String get searchFieldHint => 'Cerca…';

  @override
  String get bookmarksUnavailable => 'I segnalibri non sono disponibili';

  @override
  String get failedToLoadBookmarks => 'Impossibile caricare i segnalibri';

  @override
  String get failedToRemoveBookmark => 'Impossibile rimuovere il segnalibro';

  @override
  String get failedToUpdateBookmark => 'Impossibile aggiornare il segnalibro';

  @override
  String get bookmarkWithReminder => 'Segnalibro con promemoria';

  @override
  String get noReminder => 'Nessun promemoria';

  @override
  String get failedToLoadDrafts => 'Impossibile caricare le bozze.';

  @override
  String get failedToDiscardDraft => 'Impossibile scartare la bozza';

  @override
  String draftNotDiscardedAway(String error) {
    return 'Bozza non scartata. È ancora in Bozze. $error';
  }

  @override
  String get messagesLoadFailed => 'Impossibile caricare i messaggi';

  @override
  String get moreMessagesLoadFailed => 'Impossibile caricare altri messaggi';

  @override
  String get messageUnknownUser => 'Sconosciuto';

  @override
  String get unknownErrorFallback => 'Errore sconosciuto';

  @override
  String get chatComposerDefaultHint => 'Scrivi un messaggio…';

  @override
  String chatChannelNumbered(Object id) {
    return 'canale $id';
  }

  @override
  String get chatSendFailed => 'Impossibile inviare il messaggio.';

  @override
  String get chatEditFailed => 'Impossibile modificare il messaggio.';

  @override
  String get chatDeleteFailed => 'Impossibile eliminare il messaggio.';

  @override
  String get chatReactionsUnsupported => 'Le reazioni non sono supportate qui.';

  @override
  String get chatReactionFailed => 'Impossibile aggiornare la reazione.';

  @override
  String get attachmentDefaultName => 'Allegato';

  @override
  String get fileTypeAudio => 'Audio';

  @override
  String get fileTypeText => 'Testo';

  @override
  String get fileTypeArchive => 'Archivio';

  @override
  String get fileTypeFile => 'File';

  @override
  String downloadFailedHttpStatus(String status) {
    return 'Impossibile scaricare il file: HTTP $status';
  }

  @override
  String get downloadedFileEmpty => 'Il file scaricato è vuoto';

  @override
  String downloadFileFailed(String error) {
    return 'Impossibile scaricare il file: $error';
  }

  @override
  String attachmentTypeNotAllowed(String extension, String allowed) {
    return 'Il tipo di file .$extension non è consentito. Tipi consentiti: $allowed';
  }

  @override
  String attachmentFileTooLarge(String size, String max) {
    return 'La dimensione del file ($size) supera il massimo di $max';
  }

  @override
  String get attachmentValidationFailed => 'Verifica del file non riuscita';

  @override
  String get uploadMissingReference =>
      'Caricamento riuscito, ma il server non ha restituito alcun riferimento al file.';

  @override
  String get imageFileNotFound => 'File immagine non trovato';

  @override
  String get failedToLoadVideo => 'Impossibile caricare il video';

  @override
  String get userInfoLoadFailed =>
      'Impossibile caricare le informazioni dell\'utente.';

  @override
  String userInfoLoadFailedWithError(String error) {
    return 'Impossibile caricare le informazioni dell\'utente: $error';
  }

  @override
  String get profileMenuIgnoreUser => 'Ignora utente';

  @override
  String get profileMenuUnignoreUser => 'Non ignorare più l\'utente';

  @override
  String get ignoreStateUpdateFailed =>
      'Impossibile aggiornare lo stato di utente ignorato';

  @override
  String profileNowIgnoringUser(String username) {
    return 'Stai ignorando @$username. I suoi messaggi verranno nascosti.';
  }

  @override
  String get profileIgnoreToggleFailed =>
      'Impossibile modificare l\'opzione Ignora.';

  @override
  String get profileStatsLoadFailed => 'Impossibile caricare le statistiche.';

  @override
  String get profileFollowFailed => 'Impossibile seguire';

  @override
  String get profileUnfollowFailed => 'Impossibile smettere di seguire';

  @override
  String get profileChatOpenFailed =>
      'Impossibile aprire una chat con questo utente.';

  @override
  String summaryLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mi piace',
      one: '1 mi piace',
    );
    return '$_temp0';
  }

  @override
  String summaryLinkClicks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clic',
      one: '1 click',
    );
    return '$_temp0';
  }

  @override
  String get directoryPeriodAllTime => 'Sempre';

  @override
  String get directoryPeriodYear => 'Anno';

  @override
  String get directoryPeriodQuarter => 'Trimestre';

  @override
  String get directoryPeriodMonth => 'Mese';

  @override
  String get directoryPeriodWeek => 'Settimana';

  @override
  String get directoryPeriodToday => 'Oggi';

  @override
  String get directoryOrderReceived => 'Ricevuti';

  @override
  String get directoryOrderReplies => 'Risposte';

  @override
  String get directoryOrderTopics => 'Argomenti';

  @override
  String get directoryOrderVisits => 'Visite';

  @override
  String get directoryLoadFailed => 'Impossibile caricare l\'elenco utenti.';

  @override
  String get directoryNoUsersMatch => 'Nessun utente corrisponde a quel nome.';

  @override
  String get directoryNoUsersForPeriod =>
      'Nessun utente trovato per questo periodo.';

  @override
  String get userSearchNoResults => 'Nessun utente trovato';

  @override
  String get userSearchTryDifferentUsername =>
      'Prova a cercare con un altro nome utente';

  @override
  String get userSearchPromptTitle => 'Cerca utenti';

  @override
  String get userSearchPromptHint =>
      'Inserisci un nome utente per trovare e invitare utenti';

  @override
  String get ignoredUsersUnignoreFailed => 'Impossibile smettere di ignorare.';

  @override
  String get ignoredUsersEmpty => 'Non stai ignorando nessuno.';

  @override
  String get ignoredUsersEmptyHint =>
      'Apri un profilo utente e usa «Ignora utente» nel menu per nascondere i suoi messaggi e le sue notifiche.';

  @override
  String get badgesLoadFailed => 'Impossibile caricare i distintivi.';

  @override
  String get badgesEmpty => 'Nessun distintivo in questo forum.';

  @override
  String get badgeTierGold => 'Oro';

  @override
  String get badgeTierSilver => 'Argento';

  @override
  String get badgeTierBronze => 'Bronzo';

  @override
  String badgeEarnedAgo(String time) {
    return 'Ottenuto $time';
  }

  @override
  String badgeEarnedByUsers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ottenuto da $formatted utenti',
      one: 'Ottenuto da $formatted utente',
    );
    return '$_temp0';
  }

  @override
  String get trustLevelNameNewUser => 'Nuovo utente';

  @override
  String get trustLevelNameBasic => 'Utente base';

  @override
  String get trustLevelNameMember => 'Membro';

  @override
  String get trustLevelNameRegular => 'Esperto';

  @override
  String get trustLevelNameLeader => 'Veterano';

  @override
  String get trustLevelSummary0 =>
      'Appena iscritto. Può leggere e pubblicare, con limiti su link, immagini e messaggi.';

  @override
  String get trustLevelSummary1 =>
      'Sblocca le funzioni di pubblicazione principali: immagini e allegati, più link, segnalazione dei messaggi.';

  @override
  String get trustLevelSummary2 =>
      'Può inviare inviti, ignorare utenti e modificare i propri messaggi più a lungo.';

  @override
  String get trustLevelSummary3 =>
      'Può cambiare categoria e titolo agli argomenti, creare etichette, e le sue segnalazioni di spam contano di più.';

  @override
  String get trustLevelSummary4 =>
      'Assegnato dallo staff. Può modificare qualsiasi messaggio e fissare, chiudere, dividere o unire argomenti.';

  @override
  String trustLevelRowTitle(int level, String name) {
    return 'TL$level · $name';
  }

  @override
  String get profileNoUserSpecified => 'Nessun utente specificato';

  @override
  String get userTopicsLoadFailed => 'Impossibile caricare gli argomenti';

  @override
  String get userTopicsEmpty => 'Nessun argomento creato finora.';

  @override
  String get userRecentPostsLoadFailed =>
      'Impossibile caricare i messaggi recenti';

  @override
  String get activityUnknownTopic => 'Argomento sconosciuto';

  @override
  String groupJoinedSnack(String group) {
    return 'Ti sei unito a $group';
  }

  @override
  String get groupJoinFailed => 'Impossibile unirsi al gruppo';

  @override
  String groupLeftSnack(String group) {
    return 'Hai lasciato $group';
  }

  @override
  String get groupLeaveFailed => 'Impossibile uscire dal gruppo';

  @override
  String get groupMembershipRequestHint =>
      'Perché vuoi unirti? I proprietari del gruppo lo vedranno insieme alla tua richiesta.';

  @override
  String get groupMembershipReasonRequired =>
      'Serve un motivo per richiedere di partecipare';

  @override
  String get groupMembershipRequestSent =>
      'Richiesta inviata: un proprietario del gruppo deve approvarla';

  @override
  String get groupMembershipRequestFailed =>
      'Impossibile inviare la richiesta di partecipazione';

  @override
  String get groupMemberBadge => 'Membro';

  @override
  String get groupRequestPending => 'Richiesta in attesa';

  @override
  String get groupJoining => 'Adesione…';

  @override
  String get groupJoinButton => 'Unisciti al gruppo';

  @override
  String get groupsLoadFailed => 'Impossibile caricare i gruppi.';

  @override
  String get groupBuiltIn => 'Gruppo predefinito';

  @override
  String invitesPendingWithCount(int count) {
    return 'In sospeso ($count)';
  }

  @override
  String invitesExpiredWithCount(int count) {
    return 'Scaduti ($count)';
  }

  @override
  String invitesRedeemedWithCount(int count) {
    return 'Accettati ($count)';
  }

  @override
  String get invitesLoadFailed => 'Impossibile caricare gli inviti.';

  @override
  String get inviteLinkCreateFailed => 'Impossibile creare il link di invito';

  @override
  String get inviteEmailAddressLabel => 'Indirizzo email';

  @override
  String get inviteEmailInvalid => 'Inserisci un indirizzo email valido';

  @override
  String get inviteMessageOptionalLabel => 'Messaggio (facoltativo)';

  @override
  String get inviteSendFailed => 'Impossibile inviare l\'invito';

  @override
  String get revokeInviteLinkWarning =>
      'Il link di invito smetterà di funzionare.';

  @override
  String revokeInviteEmailWarning(String email) {
    return 'L\'invito a $email smetterà di funzionare.';
  }

  @override
  String get inviteRevokeFailed => 'Impossibile revocare l\'invito';

  @override
  String get inviteNoPermission => 'Non hai l\'autorizzazione per invitare';

  @override
  String get invitesEmptyPending => 'Nessun invito in sospeso';

  @override
  String get invitesEmptyExpired => 'Nessun invito scaduto';

  @override
  String get invitesEmptyRedeemed => 'Nessun invito accettato';

  @override
  String get invitesEmptyPendingHint =>
      'Crea un link di invito per portare persone nel forum.';

  @override
  String get inviteLinkFallbackTitle => 'Link di invito';

  @override
  String inviteRedeemedOn(String date) {
    return 'Accettato il $date';
  }

  @override
  String inviteRedemptions(int count, int max) {
    return 'Accettati $count su $max';
  }

  @override
  String get inviteEmailSent => 'Email inviata';

  @override
  String get inviteEmailNotSent => 'Email non inviata';

  @override
  String inviteExpiredOn(String date) {
    return 'Scaduto il $date';
  }

  @override
  String get inviteRevokeTooltip => 'Revoca l\'invito';

  @override
  String get reviewStatusPending => 'In attesa';

  @override
  String get reviewStatusApproved => 'Approvato';

  @override
  String get reviewStatusRejected => 'Rifiutato';

  @override
  String get reviewStatusAll => 'Tutti';

  @override
  String get reviewStatusIgnored => 'Segnalazione ignorata';

  @override
  String get reviewStatusDeleted => 'Argomento o messaggio eliminato';

  @override
  String get reviewQueueUnavailable =>
      'La coda di revisione non è disponibile in questo forum.';

  @override
  String get reviewQueueLoadFailed =>
      'Impossibile caricare la coda di revisione';

  @override
  String get reviewableChangedByOther =>
      'Questo elemento è stato modificato da un altro moderatore. Aggiornamento…';

  @override
  String get reviewActionFailed => 'Impossibile eseguire l\'azione';

  @override
  String reviewActionDone(String action) {
    return '$action: fatto';
  }

  @override
  String get reviewRejectReasonHint => 'Perché viene rifiutato?';

  @override
  String get reviewTypeFlaggedPost => 'Messaggio segnalato';

  @override
  String get reviewTypeQueuedPost => 'Messaggio accodato';

  @override
  String get reviewTypeQueuedTopic => 'Argomento accodato';

  @override
  String get reviewTypeUser => 'Utente';

  @override
  String get reviewTypePost => 'Messaggio';

  @override
  String get reviewTypeChatMessage => 'Messaggio di chat segnalato';

  @override
  String get reviewModeratorAccessRequired => 'Accesso da moderatore richiesto';

  @override
  String reviewableScore(String score) {
    return 'Punteggio $score';
  }

  @override
  String get postRepliesLoadFailed => 'Impossibile caricare le risposte.';

  @override
  String get postMakeWiki => 'Rendi Wiki';

  @override
  String get postRemoveWiki => 'Rimuovi Wiki';

  @override
  String get postBookmarkRemoveFailed => 'Impossibile rimuovere il segnalibro';

  @override
  String get postBookmarkFailed =>
      'Impossibile aggiungere il messaggio ai segnalibri';

  @override
  String get postBookmarkReminderUpdateFailed =>
      'Impossibile aggiornare il promemoria';

  @override
  String get postBookmarkReminderSet => 'Promemoria impostato';

  @override
  String get postBookmarkReminderCleared => 'Promemoria cancellato';

  @override
  String get solutionMarkFailed =>
      'Impossibile segnare la risposta come soluzione';

  @override
  String get solutionUnmarkFailed =>
      'Impossibile rimuovere il segno di soluzione';

  @override
  String get postUnknownDate => 'Data sconosciuta';

  @override
  String get postBookmarkAction => 'Aggiungi un segnalibro al messaggio';

  @override
  String get reactionButtonRemoveLike =>
      'Hai messo Mi piace. Tocca per toglierlo.';

  @override
  String reactionButtonRemove(String reaction) {
    return 'La tua reazione: $reaction. Tocca per rimuoverla.';
  }

  @override
  String reactionButtonLocked(String reaction) {
    return 'La tua reazione: $reaction. Non può più essere cambiata.';
  }

  @override
  String get reactionHoldHint => 'Tieni premuto per altre reazioni';

  @override
  String reactionSummarySemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reazioni. Tocca per vedere chi ha reagito.',
      one: '1 reazione. Tocca per vedere chi ha reagito.',
    );
    return '$_temp0';
  }

  @override
  String get reactionLockedMessage =>
      'Non puoi più cambiare la tua reazione a questo messaggio.';

  @override
  String get reactionHoldTip =>
      'Suggerimento: tieni premuto il cuore per altre reazioni.';

  @override
  String reactionsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reazioni',
      one: '1 reazione',
    );
    return '$_temp0';
  }

  @override
  String get reactionsAll => 'Tutte';

  @override
  String get reactionYou => 'Tu';

  @override
  String get changeYourReaction => 'Cambia la tua reazione';

  @override
  String get reactionTapAgainToRemove =>
      'Tocca di nuovo la tua reazione per rimuoverla.';

  @override
  String reactionFilterSemantics(String reaction, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$reaction, $count persone',
      one: '$reaction, 1 persona',
    );
    return '$_temp0';
  }

  @override
  String get postLikeAction => 'Metti \"Mi piace\" al messaggio';

  @override
  String get postUnlikeAction => 'Rimuovi il \"Mi piace\"';

  @override
  String get postVoteRemoveFailed =>
      'Impossibile rimuovere il voto (tempo per annullare scaduto?)';

  @override
  String get postVoteCastFailed => 'Impossibile votare';

  @override
  String get postUpvote => 'Vota a favore';

  @override
  String get postDownvote => 'Vota contro';

  @override
  String get pollVoteFailed => 'Voto non riuscito. Riprova.';

  @override
  String get pollRemoveVoteFailed =>
      'Impossibile rimuovere il tuo voto. Riprova.';

  @override
  String get pollVotersLoadFailed => 'Impossibile caricare i votanti.';

  @override
  String get pollVotersNotVisible =>
      'I votanti di questo sondaggio non sono visibili.';

  @override
  String get pollRankedChoiceHint =>
      'Tocca le opzioni in ordine di preferenza. Le opzioni senza posizione contano come astensione.';

  @override
  String get pollRankAbstain => 'Astensione';

  @override
  String pollRank(int rank) {
    return 'Posizione $rank';
  }

  @override
  String get pollRankedChoiceWinner => 'Vincitore';

  @override
  String get pollRankedChoiceTied => 'Pareggio';

  @override
  String solutionSolvedByInPost(String name, int postNumber) {
    return 'Risolto da $name nel messaggio #$postNumber';
  }

  @override
  String solutionMarkedBy(String name) {
    return 'segnato da $name';
  }

  @override
  String reactAgainInSeconds(int seconds) {
    return 'Potrai reagire di nuovo a questo messaggio tra ${seconds}s';
  }

  @override
  String get reactionUpdateFailed => 'Impossibile aggiornare la reazione.';

  @override
  String get reactionsNotSupported =>
      'Le reazioni non sono supportate su questo forum.';

  @override
  String get reactionsLoadFailed => 'Impossibile caricare le reazioni.';

  @override
  String viewProfileOfUser(String username) {
    return 'Vedi il profilo di $username';
  }

  @override
  String get failedToSavePost => 'Impossibile salvare il messaggio';

  @override
  String failedToSavePostWithError(String error) {
    return 'Impossibile salvare il messaggio: $error';
  }

  @override
  String get failedToRemoveAttachmentCheckPermissions =>
      'Impossibile rimuovere l\'allegato. Controlla i tuoi permessi.';

  @override
  String get editPostTitle => 'Modifica Messaggio';

  @override
  String get editYourPostHint => 'Modifica il tuo messaggio...';

  @override
  String get failedToPostReply => 'Pubblicazione della risposta non riuscita';

  @override
  String failedToPostReplyWithError(String error) {
    return 'Pubblicazione della risposta non riuscita: $error';
  }

  @override
  String get failedToCreateTopic => 'Impossibile creare l\'argomento';

  @override
  String get writeYourTopicTitle => 'Scrivi il titolo del tuo argomento...';

  @override
  String get writeYourTopicContent =>
      'Scrivi il contenuto del tuo argomento...';

  @override
  String get composerTitleHint => 'Scrivi il tuo titolo...';

  @override
  String get composerContentHint => 'Scrivi il tuo contenuto...';

  @override
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit) {
    return '$fileName: troppo grande ($size) e non è stato possibile ridimensionarlo. Il limite è $limit.';
  }

  @override
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit) {
    return '$fileName ridimensionato a $size$dimensions per rientrare nel limite di $limit.';
  }

  @override
  String get composerAttachFileHint => 'Allega un file a questo messaggio';

  @override
  String get composerUploadImageHint =>
      'Carica un\'immagine in questo messaggio';

  @override
  String get composerFormattingHint => 'Apri le opzioni di formattazione';

  @override
  String get whisperStaffOnly => 'Sussurro (solo staff)';

  @override
  String get whisperOnStaffOnly => 'Sussurro attivo (solo staff)';

  @override
  String get tagInputMaxReached => 'Numero massimo di etichette raggiunto';

  @override
  String get tagInputAddTag => 'Aggiungi un\'etichetta…';

  @override
  String get tagInputAddAnother => '+ etichetta';

  @override
  String get editHistoryUnavailable =>
      'La cronologia delle modifiche non è disponibile su questo forum.';

  @override
  String get editHistoryLoadFailed =>
      'Impossibile caricare la cronologia delle modifiche.';

  @override
  String get previousRevision => 'Revisione precedente';

  @override
  String get nextRevision => 'Prossima revisione';

  @override
  String get notificationPrefsLoadFailed =>
      'Impossibile caricare le preferenze di notifica.';

  @override
  String get notificationPrefsSaveFailed =>
      'Impossibile salvare — controlla la connessione';

  @override
  String get signInToManageNotificationPrefs =>
      'Accedi per gestire le tue preferenze di notifica.';

  @override
  String get emailWhenAwayTitle => 'Email quando sei assente';

  @override
  String get emailLevelDescription =>
      'Inviami un\'e-mail quando sono citato, ricevo una risposta, o il mio @nomeutente è menzionato, oppure quando c\'è una nuova attività nelle categorie, nelle etichette o negli argomenti che osservo';

  @override
  String get notificationPrefAlways => 'Sempre';

  @override
  String get notificationPrefOnlyWhenAway => 'Solo quando non collegato';

  @override
  String get notificationPrefNever => 'Mai';

  @override
  String get emailForMessagesTitle => 'Email per i messaggi';

  @override
  String get emailMessagesLevelDescription =>
      'Inviami un\'e-mail quando mi viene inviato un messaggio personale';

  @override
  String get activitySummaryTitle => 'Riepilogo Attività';

  @override
  String get activitySummaryDescription =>
      'Quando non visito il sito, inviami un\'email riepilogativa degli argomenti e delle risposte più popolari';

  @override
  String get activitySummaryFrequencyTitle =>
      'Frequenza del riepilogo attività';

  @override
  String get activitySummaryDaily => 'Ogni giorno';

  @override
  String get activitySummaryWeekly => 'Ogni settimana';

  @override
  String get activitySummaryMonthly => 'Ogni mese';

  @override
  String get mailingListModeTitle => 'Modalità Mailing list';

  @override
  String get mailingListModeDescription =>
      'Inviami un\'email per ogni messaggio (disattiva il riepilogo attività). Sconsigliato nei forum molto trafficati.';

  @override
  String get likeNotificationFrequencyTitle =>
      'Notifica alla ricezione di \"Mi piace\"';

  @override
  String get likeNotificationFirstTimeAndDaily =>
      'La prima volta che un messaggio riceve un \"Mi piace\" e giornalmente';

  @override
  String get likeNotificationFirstTime =>
      'La prima volta che un messaggio riceve un \"Mi piace\"';

  @override
  String get whenPostingTitle => 'Quando si pubblica';

  @override
  String get whenPostingDescription =>
      'Cosa succede a un argomento a cui rispondi';

  @override
  String get whenPostingWatchTopic => 'Osserva l\'argomento';

  @override
  String get whenPostingTrackTopic => 'Traccia l\'argomento';

  @override
  String get whenPostingDoNothing => 'Non fare nulla';

  @override
  String get pauseNotificationsUntilTomorrow => 'Fino a domani';

  @override
  String get couldNotEnableDoNotDisturb =>
      'Impossibile attivare Non disturbare';

  @override
  String get doNotDisturbNotEnabledSessionChanged =>
      'Non disturbare non è stato attivato: la tua sessione è cambiata.';

  @override
  String get couldNotTurnOffDoNotDisturb =>
      'Impossibile disattivare Non disturbare';

  @override
  String get passwordResetEmailSent =>
      'Email per reimpostare la password inviata.';

  @override
  String get couldNotSendResetEmail =>
      'Impossibile inviare l\'email di reimpostazione';

  @override
  String get accountRequestFailed => 'Richiesta non riuscita.';

  @override
  String get forumUrlUnavailable => 'L\'URL del forum non è disponibile.';

  @override
  String get couldNotOpenPreferencesPage =>
      'Impossibile aprire la pagina delle preferenze.';

  @override
  String get couldNotOpenForumUrl => 'Impossibile aprire l\'URL del forum.';

  @override
  String get couldNotRequestEmailChange =>
      'Impossibile richiedere la modifica dell\'email';

  @override
  String get newEmailLabel => 'Nuova e-mail';

  @override
  String get enterAnEmailAddress => 'Inserisci un indirizzo email';

  @override
  String get emailLooksInvalid => 'Non sembra un indirizzo email';

  @override
  String get emailNoSpaces => 'Niente spazi negli indirizzi email';

  @override
  String get allowNotificationsSheetTitle => 'Consenti notifiche';

  @override
  String get notificationsGrantNoPayload =>
      'L\'autorizzazione non ha restituito alcuna risposta.';

  @override
  String get thisForumFallback => 'questo forum';

  @override
  String signInToDomain(String domain) {
    return 'Accedi a $domain';
  }

  @override
  String get loginResultTitle => 'Esito dell\'accesso';

  @override
  String get invalidAuthenticationCode => 'Codice di autenticazione non valido';

  @override
  String get tfaVerificationError =>
      'Si è verificato un errore durante la verifica. Riprova.';

  @override
  String get passwordFieldLabel => 'Password';

  @override
  String get somethingWentWrongTryAgain => 'Qualcosa è andato storto. Riprova.';

  @override
  String get unexpectedErrorTryAgain =>
      'Si è verificato un errore imprevisto. Riprova.';

  @override
  String get errorNoInternetConnection =>
      'Nessuna connessione a Internet. Controlla le impostazioni di rete.';

  @override
  String get errorRequestTimedOut => 'Richiesta scaduta. Riprova.';

  @override
  String get errorServerTryLater =>
      'Si è verificato un errore del server. Riprova più tardi.';

  @override
  String get errorInvalidCredentials => 'Nome utente o password non validi.';

  @override
  String get errorSessionExpired => 'La sessione è scaduta. Accedi di nuovo.';

  @override
  String get errorAccountSuspended =>
      'Il tuo account è stato sospeso. Contatta lo staff del forum.';

  @override
  String get errorForumNotFound => 'Forum non trovato.';

  @override
  String get errorForumAccessDenied =>
      'Non hai il permesso di accedere a questo forum.';

  @override
  String get errorForumUnavailable =>
      'Il forum non è al momento disponibile. Riprova più tardi.';

  @override
  String get errorDataNotFound => 'Dati richiesti non trovati.';

  @override
  String get errorDataCorrupted =>
      'I dati sembrano danneggiati. Aggiorna la pagina.';

  @override
  String get errorCacheLoadFailed =>
      'Impossibile caricare i dati nella cache. Riprova.';

  @override
  String errorInvalidField(String field) {
    return 'Valore non valido per $field.';
  }

  @override
  String errorFieldRequired(String field) {
    return '$field è obbligatorio.';
  }

  @override
  String errorPermissionDeniedFor(String action) {
    return 'Non hai il permesso per: $action.';
  }

  @override
  String errorFeatureNotAvailable(String feature) {
    return '$feature non è disponibile su questo forum.';
  }

  @override
  String get errorStorageFull =>
      'Lo spazio di archiviazione è pieno. Libera un po\' di spazio.';

  @override
  String get errorStorageAccessDenied =>
      'Accesso allo spazio di archiviazione negato. Controlla i permessi dell\'app.';

  @override
  String get errorNetworkTryAgain =>
      'Si è verificato un errore di rete. Riprova.';

  @override
  String get errorAuthenticationTryAgain =>
      'Autenticazione non riuscita. Riprova.';

  @override
  String get errorForumTryAgain =>
      'Si è verificato un errore del forum. Riprova.';

  @override
  String get connectionErrorTitle => 'Errore di connessione';

  @override
  String get authenticationErrorTitle => 'Errore di autenticazione';

  @override
  String get forumErrorTitle => 'Errore del forum';

  @override
  String get permissionErrorTitle => 'Errore di autorizzazione';

  @override
  String errorRemovingFromMessage(String name) {
    return 'Impossibile rimuovere $name da questo messaggio.';
  }

  @override
  String get chatNewMessage => 'Nuovo messaggio';

  @override
  String get chatStarred => 'Preferiti';

  @override
  String get chatBrowseChannels => 'Sfoglia i canali';

  @override
  String get chatFilterAll => 'Tutti';

  @override
  String get chatFilterOpen => 'Aperta';

  @override
  String get chatFilterClosed => 'Chiusi';

  @override
  String get chatFilterArchived => 'Archiviati';

  @override
  String get chatBrowseSearch => 'Cerca canale per nome';

  @override
  String get chatJoin => 'Partecipa';

  @override
  String get chatJoined => 'Partecipante';

  @override
  String get chatLeave => 'Esci';

  @override
  String chatMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membri',
      one: '$count membro',
    );
    return '$_temp0';
  }

  @override
  String get chatYesterday => 'Ieri';

  @override
  String get chatNoChannelsFound => 'Nessun canale trovato';

  @override
  String get chatCloseDm => 'Chiudi questa chat personale';

  @override
  String get chatToday => 'Oggi';

  @override
  String get chatLastVisit => 'ultima visita';

  @override
  String chatNewMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuovi messaggi',
      one: '$count nuovo messaggio',
    );
    return '$_temp0';
  }

  @override
  String get chatScrollToBottom => 'Scorri fino in fondo';

  @override
  String get chatInReplyTo => 'In risposta a';

  @override
  String get chatCopyText => 'Copia testo';

  @override
  String get chatTextCopied => 'Testo copiato negli appunti';

  @override
  String get chatBookmark => 'Aggiungi ai segnalibri';

  @override
  String get chatPinMessage => 'Fissa il messaggio';

  @override
  String get chatUnpinMessage => 'Sblocca il messaggio';

  @override
  String get chatFlag => 'Segnala';

  @override
  String get chatReactWithEmoji => 'Reagisci con delle emoji';

  @override
  String chatReplyingTo(String username) {
    return 'Rispondi a $username';
  }

  @override
  String get chatEditingMessage => 'Modifica del messaggio';

  @override
  String chatTypingOne(String username) {
    return '$username sta scrivendo';
  }

  @override
  String chatTypingTwo(String commaSeparatedUsernames, String lastUsername) {
    return '$commaSeparatedUsernames e $lastUsername stanno scrivendo';
  }

  @override
  String chatTypingMany(String commaSeparatedUsernames, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$commaSeparatedUsernames e altri $count stanno scrivendo',
      one: '$commaSeparatedUsernames e $count altro stanno scrivendo',
    );
    return '$_temp0';
  }

  @override
  String get chatOpenThread => 'Apri Discussione';

  @override
  String get chatMembers => 'Membri';

  @override
  String get chatAddMember => 'Aggiungi membro';

  @override
  String get chatFindMembers => 'Trova membri';

  @override
  String get chatRemoveMember => 'Rimuovi';

  @override
  String get chatNotifyNever => 'Mai';

  @override
  String get chatNotifyMention => 'Solo per le menzioni';

  @override
  String get chatNotifyAlways => 'Per tutte le attività';

  @override
  String get chatNotificationLevel => 'Invia notifiche push';

  @override
  String get chatMuteChannel => 'Silenzia canale';

  @override
  String get chatStarChannel => 'Aggiungi il canale ai preferiti';

  @override
  String get chatLeaveChannel => 'Lascia il canale';

  @override
  String get chatSearchTitle => 'Cerca nella chat';

  @override
  String get chatSearchNoResults => 'Nessun risultato trovato';

  @override
  String get chatMyThreads => 'I miei thread';

  @override
  String chatThreadReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count risposte',
      one: '$count risposta',
    );
    return '$_temp0';
  }

  @override
  String get chatNoThreads =>
      'Non stai partecipando a nessun thread in questo canale.';

  @override
  String get chatGroupName => 'Nome della chat di gruppo (facoltativo)';

  @override
  String chatMembersCounter(int count, int max) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count/$max membri',
      one: '$count/$max membro',
    );
    return '$_temp0';
  }

  @override
  String get chatTooManyMembers => 'Numero massimo di membri raggiunto';

  @override
  String get chatThread => 'Thread';

  @override
  String get chatChannelSettings => 'Impostazioni del canale';

  @override
  String get chatSearchMessagesHint => 'Cerca messaggi';

  @override
  String get chatMyThreadsEmpty =>
      'Ancora nessun thread. I thread a cui parteciperai appariranno qui.';

  @override
  String get chatLeaveGroupInfo =>
      'Uscendo da questa chat di gruppo, non avrai più accesso a essa e non riceverai notifiche a essa relative. Per partecipare nuovamente, dovrai ricevere nuovamente un invito da un membro della chat di gruppo.';

  @override
  String get chatPlaceholderThread => 'Chat nel thread';

  @override
  String get chatLastReply => 'ultima risposta';

  @override
  String messageListUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Non letti ($count)',
      one: 'Non letto ($count)',
    );
    return '$_temp0';
  }

  @override
  String messageListNewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nuovi ($count)',
      one: 'Nuovo ($count)',
    );
    return '$_temp0';
  }

  @override
  String get messagePersonal => 'Personali';

  @override
  String messageListIncoming(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Visualizza $count argomenti nuovi o aggiornati.',
      one: 'Visualizza $count argomento nuovo o aggiornato',
    );
    return '$_temp0';
  }

  @override
  String get chatPlaceholderGroup => 'Chatta in gruppo';

  @override
  String get notificationAccountMismatch =>
      'Questa notifica non può essere aperta con l’account attuale. Apri Notifiche per vedere gli aggiornamenti di questo account.';

  @override
  String get mediaPlay => 'Riproduci';

  @override
  String get mediaPause => 'Pausa';

  @override
  String get chatChannelStatusReadOnly => 'Sola lettura';

  @override
  String get chatChannelStatusClosed => 'Chiuso';

  @override
  String get chatChannelStatusArchived => 'Archiviato';
}
