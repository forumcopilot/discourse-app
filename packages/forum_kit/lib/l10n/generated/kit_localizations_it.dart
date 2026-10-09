// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'kit_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class KitLocalizationsIt extends KitLocalizations {
  KitLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get discardFailedCloseQuestion =>
      'Chiudere comunque? Una bozza salvata in precedenza resta in Bozze.';

  @override
  String get keepEditing => 'Continua a scrivere';

  @override
  String get closeAnyway => 'Chiudi comunque';

  @override
  String get okButton => 'OK';

  @override
  String get copied => 'Copiato';

  @override
  String get cancel => 'Annulla';

  @override
  String get tryAgain => 'Riprova';

  @override
  String get latest => 'Recenti';

  @override
  String get language => 'Lingua';

  @override
  String get all => 'Tutti';

  @override
  String get reason => 'Motivo';

  @override
  String get pleaseSpecifyReason => 'Specifica il motivo';

  @override
  String get selectDate => 'Seleziona data';

  @override
  String get search => 'Cerca';

  @override
  String get messages => 'Messaggi';

  @override
  String get add => 'Aggiungi';

  @override
  String get delete => 'Elimina';

  @override
  String get temporary => 'Temporaneo';

  @override
  String error(String error) {
    return 'Errore: $error';
  }

  @override
  String get none => 'Nessuno';

  @override
  String get italic => 'Corsivo';

  @override
  String get link => 'Collegamento';

  @override
  String get image => 'Immagine';

  @override
  String get quote => 'Citazione';

  @override
  String get code => 'Codice';

  @override
  String participants(int count) {
    return 'Partecipanti ($count)';
  }

  @override
  String get refresh => 'Aggiorna';

  @override
  String get share => 'Condividi';

  @override
  String get reply => 'Rispondi';

  @override
  String get dark => 'Scuro';

  @override
  String get notifications => 'Notifiche';

  @override
  String get edit => 'Modifica';

  @override
  String get remove => 'Rimuovi';

  @override
  String get message => 'Messaggio';

  @override
  String couldNotOpenLink(String error) {
    return 'Impossibile aprire il link: $error';
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
  String get apply => 'Applica';

  @override
  String get bookmarks => 'Segnalibri';

  @override
  String get copy => 'Copia';

  @override
  String get discard => 'Scarta';

  @override
  String get firstPostsOnly => 'Solo primi post';

  @override
  String get relevance => 'Rilevanza';

  @override
  String get reset => 'Reimposta';

  @override
  String get titleOnly => 'Solo titolo';

  @override
  String get solved => 'Risolto';

  @override
  String get open => 'Apri';

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
  String get postNeedsApprovalTitle => 'Messaggio Da Approvare';

  @override
  String get postNeedsApprovalBody =>
      'Abbiamo ricevuto il tuo messaggio ma prima che appaia deve essere approvato da un moderatore. Attendi.';

  @override
  String get tapToOpen => 'Tocca per aprire';

  @override
  String get imageNotAvailable => 'Immagine non disponibile';

  @override
  String get searchFilters => 'Filtri di ricerca';

  @override
  String get tags => 'Tag';

  @override
  String get discardPostQuestion => 'Vuoi eliminare il tuo messaggio?';

  @override
  String get discardChangesQuestion => 'Vuoi annullare le modifiche?';

  @override
  String get discardChanges => 'Annulla modifiche';

  @override
  String get saveDraft => 'Salva bozza';

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
  String get day => 'Giorno';

  @override
  String get month => 'Mese';

  @override
  String get chooseEmoji => 'Scegli emoji';

  @override
  String get searchEmoji => 'Cerca emoji';

  @override
  String get suspendUser => 'Sospendi Utente';

  @override
  String get suspendUntil => 'Sospendi utente fino a';

  @override
  String get suspendForever => 'Sospendi definitivamente';

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
  String get pleaseSelectSuspensionEndDate =>
      'Scegli quando termina la sospensione';

  @override
  String get dismissAllNotifications => 'Ignora tutti';

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
  String get postLikeAction => 'Metti \"Mi piace\" al messaggio';

  @override
  String get postUnlikeAction => 'Rimuovi il \"Mi piace\"';

  @override
  String get somethingWentWrongTryAgain => 'Qualcosa è andato storto. Riprova.';
}
