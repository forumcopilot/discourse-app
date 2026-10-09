// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'kit_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class KitLocalizationsFr extends KitLocalizations {
  KitLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get okButton => 'OK';

  @override
  String get copied => 'Copié';

  @override
  String get cancel => 'Annuler';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get latest => 'Récent';

  @override
  String get language => 'Langue';

  @override
  String get all => 'Tout';

  @override
  String get reason => 'Raison';

  @override
  String get pleaseSpecifyReason => 'Veuillez préciser la raison';

  @override
  String get selectDate => 'Sélectionner la date';

  @override
  String get search => 'Rechercher';

  @override
  String get messages => 'Messages';

  @override
  String get add => 'Ajouter';

  @override
  String get delete => 'Supprimer';

  @override
  String get temporary => 'Temporaire';

  @override
  String error(String error) {
    return 'Erreur : $error';
  }

  @override
  String get none => 'Aucun';

  @override
  String get italic => 'Italique';

  @override
  String get link => 'Lien';

  @override
  String get image => 'Image';

  @override
  String get quote => 'Citation';

  @override
  String get code => 'Code';

  @override
  String participants(int count) {
    return 'Participants ($count)';
  }

  @override
  String get refresh => 'Actualiser';

  @override
  String get share => 'Partager';

  @override
  String get reply => 'Répondre';

  @override
  String get dark => 'Sombre';

  @override
  String get notifications => 'Notifications';

  @override
  String get edit => 'Modifier';

  @override
  String get remove => 'Supprimer';

  @override
  String get message => 'Message';

  @override
  String couldNotOpenLink(String error) {
    return 'Impossible d\'ouvrir le lien : $error';
  }

  @override
  String timeGapDaysLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours plus tard',
      one: '1 jour plus tard',
    );
    return '$_temp0';
  }

  @override
  String timeGapMonthsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mois plus tard',
      one: '1 mois plus tard',
    );
    return '$_temp0';
  }

  @override
  String timeGapYearsLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ans plus tard',
      one: '1 an plus tard',
    );
    return '$_temp0';
  }

  @override
  String get apply => 'Appliquer';

  @override
  String get bookmarks => 'Signets';

  @override
  String get copy => 'Copier';

  @override
  String get firstPostsOnly => 'Premiers messages uniquement';

  @override
  String get relevance => 'Pertinence';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get titleOnly => 'Titre uniquement';

  @override
  String get solved => 'Résolu';

  @override
  String get open => 'Ouvrir';

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
  String get postNeedsApprovalTitle => 'Ce message doit être approuvé';

  @override
  String get postNeedsApprovalBody =>
      'Votre nouveau message a bien été envoyé, mais il doit être accepté par un modérateur avant d\'apparaître publiquement. Merci de votre patience.';

  @override
  String get tapToOpen => 'Touchez pour ouvrir';

  @override
  String get imageNotAvailable => 'Image indisponible';

  @override
  String get searchFilters => 'Filtres de recherche';

  @override
  String get tags => 'Étiquettes';

  @override
  String topicMapViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vues',
      one: 'vue',
    );
    return '$_temp0';
  }

  @override
  String topicMapLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'j\'aime',
    );
    return '$_temp0';
  }

  @override
  String topicMapLinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'liens',
      one: 'lien',
    );
    return '$_temp0';
  }

  @override
  String topicMapUsers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'utilisateurs',
      one: 'utilisateur',
    );
    return '$_temp0';
  }

  @override
  String get day => 'Jour';

  @override
  String get month => 'Mois';

  @override
  String get chooseEmoji => 'Choisir un emoji';

  @override
  String get searchEmoji => 'Rechercher un emoji';

  @override
  String get suspendUser => 'Suspendre l\'utilisateur';

  @override
  String get suspendUntil => 'Suspendre l\'utilisateur jusqu\'à';

  @override
  String get suspendForever => 'Suspendre pour toujours';

  @override
  String get suspendReasonNotListening =>
      'N\'écoute pas les remarques des responsables';

  @override
  String get suspendReasonStaffTime =>
      'A fait perdre un temps excessif aux responsables';

  @override
  String get suspendReasonCombative => 'Trop belliqueux(se)';

  @override
  String get suspendReasonWrongPlace => 'Au mauvais endroit';

  @override
  String get suspendReasonNoPurpose =>
      'Aucun but constructif à ses actions autre que de créer une dissidence au sein de la communauté';

  @override
  String get suspendReasonCustom => 'Personnalisé…';

  @override
  String get suspendReasonQuestion =>
      'Pourquoi suspendez-vous cet utilisateur ? Ce texte sera affiché à l\'utilisateur quand il essaiera de se connecter. Tâchez d\'être concis(e).';

  @override
  String get closedLabel => 'Fermé';

  @override
  String get pleaseSelectSuspensionEndDate =>
      'Choisissez la fin de la suspension';

  @override
  String get dismissAllNotifications => 'Tout vu';

  @override
  String get searchFilterStatusSection => 'Statut';

  @override
  String get searchFilterMyActivitySection => 'Mon activité';

  @override
  String get searchFilterMatchTypeSection => 'Type de correspondance';

  @override
  String get searchTagsFilterHelper =>
      'Séparées par des espaces ou des virgules. Chaque étiquette est requise.';

  @override
  String get searchSortBy => 'Trier par';

  @override
  String get searchStatusOpen => 'Ouvert';

  @override
  String get searchStatusArchived => 'Archivé';

  @override
  String get searchStatusNoReplies => 'Sans réponse';

  @override
  String get searchStatusPublicOnly => 'Publics uniquement';

  @override
  String get searchStatusUnsolved => 'Non résolu';

  @override
  String get searchInBookmarked => 'Dans mes signets';

  @override
  String get searchInMyMessages => 'Dans mes messages directs';

  @override
  String get searchInLiked => 'Que j\'ai aimés';

  @override
  String get searchInPosted => 'Auxquels j\'ai participé';

  @override
  String get searchInWatching => 'Que je surveille';

  @override
  String get searchInTracking => 'Que je suis';

  @override
  String get searchInSeen => 'Que j\'ai lus';

  @override
  String get searchInUnseen => 'Que je n\'ai pas lus';

  @override
  String get searchSortLatestPost => 'Dernier message';

  @override
  String get searchSortMostLiked => 'Plus aimé';

  @override
  String get searchSortMostViewed => 'Plus vu';

  @override
  String get searchSortLatestTopic => 'Dernier sujet';

  @override
  String get searchFieldHint => 'Recherche…';

  @override
  String get postLikeAction => 'Aimer le message';

  @override
  String get postUnlikeAction => 'Annuler le « J\'aime »';
}
