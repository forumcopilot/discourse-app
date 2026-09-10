// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get loginTitle => 'Connexion';

  @override
  String get usePasskey => 'Use Passkey';

  @override
  String get passkeyContinuePrompt => 'Use your passkey to continue';

  @override
  String get continueButton => 'Continuer';

  @override
  String get errorTitle => 'Erreur';

  @override
  String get okButton => 'OK';

  @override
  String get retryButton => 'Réessayer';

  @override
  String get copyToClipboard => 'Copier dans le presse-papiers';

  @override
  String get copied => 'Copié';

  @override
  String get errorMessageCopiedToClipboard =>
      'Message d\'erreur copié dans le presse-papiers';

  @override
  String get dismiss => 'Ignorer';

  @override
  String get cancel => 'Annuler';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get anErrorOccurred => 'Une erreur s\'est produite';

  @override
  String get accountPendingApproval =>
      'Votre compte est en attente d\'approbation. Vous pouvez parcourir le forum mais ne pouvez pas publier jusqu\'à ce qu\'un modérateur approuve votre compte.';

  @override
  String get checkEmailToConfirm =>
      'Veuillez vérifier votre e-mail pour confirmer votre compte. Cliquez sur le lien de confirmation dans l\'e-mail que nous vous avons envoyé.';

  @override
  String get checkNewEmailToConfirm =>
      'Veuillez vérifier votre nouvelle adresse e-mail pour confirmer le changement. Votre ancien e-mail restera actif jusqu\'à ce que vous confirmiez le nouveau.';

  @override
  String get emailAddressInvalid =>
      'Votre adresse e-mail semble invalide ou rejette les e-mails. Veuillez mettre à jour votre adresse e-mail dans les paramètres du compte.';

  @override
  String get accountDisabled =>
      'Votre compte a été désactivé. Veuillez contacter un administrateur pour obtenir de l\'aide.';

  @override
  String get accountRegistrationRejected =>
      'L\'inscription de votre compte a été rejetée. Veuillez contacter un administrateur pour plus d\'informations.';

  @override
  String get welcomeToForumCopilot => 'Bienvenue sur Forum Copilot !';

  @override
  String get successfullyLoggedOut => 'Vous avez été déconnecté avec succès';

  @override
  String get accountStatusRequiresAttention =>
      'Le statut de votre compte nécessite une attention. Veuillez contacter un administrateur si vous avez des questions.';

  @override
  String get updateEmail => 'Mettre à jour l\'e-mail';

  @override
  String get resend => 'Renvoyer';

  @override
  String get noLatestTopics => 'Aucun sujet récent';

  @override
  String get noRecentTopicsToDisplay =>
      'Il n\'y a pas de sujets récents à afficher. Revenez plus tard pour de nouvelles discussions.';

  @override
  String get signInToViewLatestTopics =>
      'Connectez-vous pour voir les sujets récents';

  @override
  String get youNeedToBeSignedInToViewLatestTopics =>
      'Vous devez être connecté pour voir les sujets récents';

  @override
  String get thereAreNoUnreadTopics =>
      'Il n\'y a pas de sujets non lus. Revenez plus tard pour de nouvelles discussions.';

  @override
  String get youAreAllCaughtUp => 'Vous êtes à jour !';

  @override
  String get signInToViewUnreadTopics =>
      'Connectez-vous pour voir les sujets non lus';

  @override
  String get youNeedToBeSignedInToViewUnreadTopics =>
      'Vous devez être connecté pour voir vos sujets non lus';

  @override
  String get latest => 'Récent';

  @override
  String get unread => 'Non lu';

  @override
  String get failedToConnectToSite =>
      'Échec de la connexion au site. Le site peut être hors ligne ou inaccessible.';

  @override
  String get connectionFailed => 'Échec de la connexion';

  @override
  String failedToConnectToSiteName(String siteName) {
    return 'Échec de la connexion à $siteName';
  }

  @override
  String get loading => 'Chargement...';

  @override
  String get newConversation => 'Nouvelle conversation';

  @override
  String get language => 'Langue';

  @override
  String get all => 'Tout';

  @override
  String get topicsOnly => 'Sujets uniquement';

  @override
  String get titlesOnly => 'Titres uniquement';

  @override
  String failedToShareTopic(String error) {
    return 'Échec du partage du sujet : $error';
  }

  @override
  String get pleaseLoginToSubscribe =>
      'Veuillez vous connecter pour null ce fil';

  @override
  String get subscribe => 'S\'abonner';

  @override
  String get failedToSubscribeToThread => 'Échec de null du fil';

  @override
  String get youCannotReplyToThisThread =>
      'Vous ne pouvez pas répondre à ce fil';

  @override
  String get pleaseWaitForThreadToLoad =>
      'Veuillez attendre le chargement du fil';

  @override
  String get softDelete => 'Suppression douce';

  @override
  String get postCanBeRestoredLater =>
      'Le message peut être restauré plus tard';

  @override
  String get hardDelete => 'Suppression définitive';

  @override
  String get postWillBePermanentlyDeleted =>
      'Le message sera définitivement supprimé';

  @override
  String get reasonForDeletion => 'Raison de la suppression';

  @override
  String get enterReasonForDeletingPost =>
      'Entrez la raison de la suppression de ce message';

  @override
  String get pleaseEnterReasonForDeletion =>
      'Veuillez entrer une raison pour la suppression';

  @override
  String get reportPost => 'Signaler le message';

  @override
  String get pleaseProvideReasonForReporting =>
      'Veuillez fournir une raison pour signaler ce message.';

  @override
  String get reason => 'Raison';

  @override
  String get enterReasonForReportingPost =>
      'Entrez la raison de signalement de ce message';

  @override
  String get pleaseEnterReason => 'Veuillez entrer une raison';

  @override
  String get submitReport => 'Soumettre le rapport';

  @override
  String get selectedActions => 'Actions sélectionnées :';

  @override
  String get thisActionCannotBeUndone =>
      'Cette action ne peut pas être annulée.';

  @override
  String get participantsLabel => 'Participants';

  @override
  String usernameHasBeenInvited(String username) {
    return '$username a été invité à la conversation';
  }

  @override
  String errorInvitingUser(String error) {
    return 'Erreur lors de l\'invitation de l\'utilisateur : $error';
  }

  @override
  String get newTopic => 'Nouveau sujet';

  @override
  String get markRead => 'Marquer comme lu';

  @override
  String get spamOrAdvertising => 'Spam ou publicité';

  @override
  String get otherPleaseSpecify => 'Autre (veuillez préciser)';

  @override
  String get pleaseSpecifyReason => 'Veuillez préciser la raison';

  @override
  String get banUser => 'Bannir l\'utilisateur';

  @override
  String get unbanUser => 'Débannir l\'utilisateur';

  @override
  String pleaseSelectReasonForBanningUser(String username) {
    return 'Veuillez sélectionner une raison pour bannir $username';
  }

  @override
  String get violationOfCommunityGuidelines =>
      'Violation des directives de la communauté';

  @override
  String get harassmentOrAbusiveBehavior =>
      'Harcèlement ou comportement abusif';

  @override
  String get postingInappropriateContent =>
      'Publication de contenu inapproprié';

  @override
  String get accountCompromiseOrSecurityIssue =>
      'Compromission du compte ou problème de sécurité';

  @override
  String get enterReasonForBanningUser =>
      'Entrez la raison de bannissement de cet utilisateur';

  @override
  String get banUntil => 'Bannir jusqu\'au';

  @override
  String get selectDate => 'Sélectionner la date';

  @override
  String get moreOptions => 'Plus d\'options';

  @override
  String get topicClosed => 'Sujet fermé';

  @override
  String get topicOpened => 'Sujet ouvert';

  @override
  String get topicStickied => 'Sujet épinglé';

  @override
  String get topicUnstickied => 'Sujet désépinglé';

  @override
  String cannotEditMessage(String error) {
    return 'Impossible d\'éditer ce message : $error';
  }

  @override
  String get confirmSpamClean => 'Confirmer le nettoyage du spam';

  @override
  String get handleThreads => 'Gérer les fils';

  @override
  String get deleteMessages => 'Supprimer les messages';

  @override
  String get deleteConversations => 'Supprimer les conversations';

  @override
  String get noConversations => 'Aucune conversation';

  @override
  String get noConversationsMessage =>
      'Vous n\'avez pas encore de conversations. Démarrez une nouvelle conversation pour commencer à envoyer des messages.';

  @override
  String get imageSavedToGallery => 'Image enregistrée dans la galerie !';

  @override
  String failedToSaveImage(String error) {
    return 'Échec de l\'enregistrement de l\'image : $error';
  }

  @override
  String get userProfile => 'Profil Utilisateur';

  @override
  String get deletePost => 'Supprimer le Message';

  @override
  String get loginRequired => 'Connexion Requise';

  @override
  String get spamCleaner => 'Nettoyeur de spam';

  @override
  String get sendMessage => 'Envoyer un message';

  @override
  String get memberSince => 'Membre Depuis';

  @override
  String get lastActivity => 'Dernière Activité';

  @override
  String get likesReceived => 'J\'aime Reçus';

  @override
  String get likesGiven => 'J\'aime Donnés';

  @override
  String get showMore => 'Afficher plus';

  @override
  String get cleanSpam => 'Nettoyer le spam';

  @override
  String get failedToSaveConversation =>
      'Échec de l\'enregistrement de la conversation';

  @override
  String get members => 'Membres';

  @override
  String membersCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString Membres';
  }

  @override
  String get noSubject => 'Sans objet';

  @override
  String get search => 'Rechercher';

  @override
  String get logout => 'Déconnexion';

  @override
  String get areYouSureYouWantToLogout =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get register => 'S\'inscrire';

  @override
  String get signIn => 'Se connecter';

  @override
  String get markForumRead => 'Marquer le Forum comme Lu';

  @override
  String get notificationTest => 'Test de Notification';

  @override
  String get forum => 'Forum';

  @override
  String get profile => 'Profil';

  @override
  String get messages => 'Messages';

  @override
  String get add => 'Ajouter';

  @override
  String get retry => 'Réessayer';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteMessage => 'Supprimer le Message';

  @override
  String get deletingPost => 'Suppression du message...';

  @override
  String failedToUnlikePost(String error) {
    return 'Échec du retrait du j\'aime du message : $error';
  }

  @override
  String failedToLikePost(String error) {
    return 'Échec du j\'aime du message : $error';
  }

  @override
  String get signInToViewMessages => 'Connectez-vous pour voir les messages';

  @override
  String get youNeedToBeSignedInToViewConversations =>
      'Vous devez être connecté pour voir vos conversations.';

  @override
  String errorLoadingConversations(String error) {
    return 'Erreur lors du chargement des conversations : $error';
  }

  @override
  String failedToLeaveConversation(String error) {
    return 'Échec de la sortie de la conversation : $error';
  }

  @override
  String errorLoadingMoreConversations(String error) {
    return 'Erreur lors du chargement de plus de conversations : $error';
  }

  @override
  String get searchFailed => 'Recherche échouée';

  @override
  String get userInformationNotAvailable =>
      'Informations utilisateur non disponibles';

  @override
  String get birthday => 'Anniversaire';

  @override
  String get posts => 'Messages';

  @override
  String get following => 'Abonnements';

  @override
  String get followers => 'Abonnés';

  @override
  String get about => 'À propos';

  @override
  String get location => 'Localisation';

  @override
  String get website => 'Site web';

  @override
  String get next => 'Suivant';

  @override
  String get permanent => 'Permanent';

  @override
  String get temporary => 'Temporaire';

  @override
  String setBanDurationFor(String username) {
    return 'Définir la durée du bannissement pour $username';
  }

  @override
  String get pleaseSelectEndDateForTemporaryBan =>
      'Veuillez sélectionner une date de fin pour le bannissement temporaire';

  @override
  String get back => 'Retour';

  @override
  String get unban => 'Débannir';

  @override
  String get confirm => 'Confirmer';

  @override
  String spamClean(String username) {
    return 'Nettoyer le Spam de $username';
  }

  @override
  String get selectActionsToPerform => 'Sélectionnez les actions à effectuer :';

  @override
  String get moveOrDeleteThreadsBasedOnAdminSettings =>
      'Déplacer ou supprimer les fils selon les paramètres de l\'administrateur';

  @override
  String get messageUpdatedSuccessfully => 'Message mis à jour avec succès';

  @override
  String error(String error) {
    return 'Erreur : $error';
  }

  @override
  String failedToRemoveAttachment(String error) {
    return 'Échec de la suppression de la pièce jointe : $error';
  }

  @override
  String failedToLoadMessage(String error) {
    return 'Échec du chargement du message : $error';
  }

  @override
  String get editMessage => 'Modifier le Message';

  @override
  String get removeAttachment => 'Supprimer la Pièce Jointe';

  @override
  String get areYouSureYouWantToRemoveThisAttachment =>
      'Êtes-vous sûr de vouloir supprimer cette pièce jointe ?';

  @override
  String get none => 'Aucun';

  @override
  String get attachFile => 'Joindre un Fichier';

  @override
  String get uploadImage => 'Télécharger une Image';

  @override
  String get formatting => 'Formatage';

  @override
  String get bold => 'Gras';

  @override
  String get italic => 'Italique';

  @override
  String get underline => 'Souligné';

  @override
  String get strikethrough => 'Barré';

  @override
  String get link => 'Lien';

  @override
  String get image => 'Image';

  @override
  String get video => 'Vidéo';

  @override
  String get quote => 'Citation';

  @override
  String get code => 'Code';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get bulletList => 'Liste à Puces';

  @override
  String get numberedList => 'Liste Numérotée';

  @override
  String get listItem => 'Élément de Liste';

  @override
  String participants(int count) {
    return 'Participants ($count)';
  }

  @override
  String get markAsUnread => 'Marquer comme non lu';

  @override
  String get invite => 'Inviter';

  @override
  String get enterKeywordsToSearchTopics =>
      'Entrez des mots-clés pour rechercher des sujets...';

  @override
  String get undelete => 'Restaurer';

  @override
  String get refresh => 'Actualiser';

  @override
  String get share => 'Partager';

  @override
  String get viewOnWeb => 'Voir sur le Web';

  @override
  String get unlock => 'Déverrouiller';

  @override
  String get lock => 'Verrouiller';

  @override
  String get stick => 'Épingler';

  @override
  String get unstick => 'Désépingler';

  @override
  String get reply => 'Répondre';

  @override
  String get vote => 'Voter';

  @override
  String votesCount(int count) {
    return '$count votes';
  }

  @override
  String get pollClosed => 'Sondage fermé';

  @override
  String pollEndsOn(String date) {
    return 'Se termine le $date';
  }

  @override
  String get voteToSeeResults => 'Votez pour voir les résultats';

  @override
  String get viewFullPoll => 'Voir le sondage';

  @override
  String pollOptionsCount(int count) {
    return '$count options';
  }

  @override
  String get reactedBy => 'Réagi par';

  @override
  String get enterKeywordsToFindTopicsAndPosts =>
      'Entrez des mots-clés pour trouver des sujets et des messages';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String version(String version, String buildNumber) {
    return 'version $version ($buildNumber)';
  }

  @override
  String get unableToLoadProfile => 'Impossible de charger le profil';

  @override
  String get banned => 'BANNI';

  @override
  String get reportSubmittedSuccessfully => 'Rapport soumis avec succès';

  @override
  String get deleteTopic => 'Supprimer le sujet';

  @override
  String get topicCanBeRestoredLater => 'Le sujet peut être restauré plus tard';

  @override
  String get topicWillBePermanentlyDeleted =>
      'Le sujet sera supprimé définitivement';

  @override
  String get enterReasonForDeletingTopic =>
      'Entrez la raison de la suppression de ce sujet';

  @override
  String get pleaseSelectEndDate => 'Veuillez sélectionner une date de fin';

  @override
  String get userBannedSuccessfully => 'Utilisateur banni avec succès';

  @override
  String get failedToBanUser => 'Échec du bannissement de l\'utilisateur';

  @override
  String get userUnbannedSuccessfully => 'Utilisateur débanni avec succès';

  @override
  String get failedToUnbanUser => 'Échec du débannissement de l\'utilisateur';

  @override
  String get spamCleanUser => 'Nettoyer le spam de l\'utilisateur';

  @override
  String get deletePrivateConversations =>
      'Supprimer les conversations privées';

  @override
  String get banTheUserAccount => 'Bannir le compte utilisateur';

  @override
  String get handledThreads => 'Sujets traités';

  @override
  String get deletedMessages => 'Messages supprimés';

  @override
  String get deletedConversations => 'Conversations supprimées';

  @override
  String get bannedUser => 'Utilisateur banni';

  @override
  String successfullyCleanedSpam(String username, String actions) {
    return 'Spam nettoyé avec succès pour $username. Actions: $actions';
  }

  @override
  String get home => 'Accueil';

  @override
  String get notifications => 'Notifications';

  @override
  String get forums => 'Forums';

  @override
  String get markAllForumsAsRead => 'Marquer tous les forums comme lus ?';

  @override
  String get markAllForumsAsReadMessage =>
      'Cela marquera tous les forums et sujets comme lus. Cette action ne peut pas être annulée.';

  @override
  String get markAsRead => 'Marquer comme lu';

  @override
  String get content => 'Contenu';

  @override
  String get insertImage => 'Insérer une image';

  @override
  String get howWouldYouLikeToInsertImage =>
      'Comment souhaitez-vous insérer cette image ?';

  @override
  String get thumbnail => 'Miniature';

  @override
  String get fullSize => 'Taille réelle';

  @override
  String get pleaseEnterTitle => 'Veuillez entrer un titre';

  @override
  String get pleaseEnterContent => 'Veuillez entrer du contenu';

  @override
  String get uploading => 'Téléchargement...';

  @override
  String get uploaded => 'Téléchargé';

  @override
  String get mentionUser => 'Mentionner un utilisateur';

  @override
  String get submittingReport => 'Envoi du rapport...';

  @override
  String get banningUser => 'Bannissement de l\'utilisateur...';

  @override
  String get unbanningUser => 'Débannissement de l\'utilisateur...';

  @override
  String get cleaningSpam => 'Nettoyage du spam...';

  @override
  String get writeYourMessage => 'Écrivez votre message...';

  @override
  String get writeYourReply => 'Écrivez votre réponse...';

  @override
  String get conversationCreatedSuccessfully =>
      'Conversation créée avec succès';

  @override
  String get conversationMarkedAsUnread => 'Conversation marquée comme non lue';

  @override
  String get conversationClosed => 'Conversation fermée';

  @override
  String get conversationOpened => 'Conversation ouverte';

  @override
  String get pleaseLoginToLikeMessages =>
      'Veuillez vous connecter pour aimer les messages';

  @override
  String get loadEarlierMessages => 'Charger les messages précédents';

  @override
  String failedToLoadQuote(String error) {
    return 'Échec du chargement de la citation : \n$error';
  }

  @override
  String failedToSendReply(String error) {
    return 'Échec de l\'envoi de la réponse : $error';
  }

  @override
  String failedToMarkConversationAsUnread(String error) {
    return 'Échec du marquage de la conversation comme non lue : $error';
  }

  @override
  String failedToCloseConversation(String error) {
    return 'Échec de la fermeture de la conversation : $error';
  }

  @override
  String failedToOpenConversation(String error) {
    return 'Échec de l\'ouverture de la conversation : $error';
  }

  @override
  String failedToJumpToMessage(String error) {
    return 'Échec du saut au message : $error';
  }

  @override
  String get goToTop => 'Aller en haut';

  @override
  String get goToBottom => 'Aller en bas';

  @override
  String get pleaseLoginToAccessContent =>
      'Veuillez vous connecter pour accéder à ce contenu et interagir avec les publications.';

  @override
  String get searchUsers => 'Rechercher des utilisateurs...';

  @override
  String get enterConversationTitle => 'Entrez le titre de la conversation';

  @override
  String enterCode(int count) {
    return 'Entrez le code à $count chiffres';
  }

  @override
  String get edit => 'Modifier';

  @override
  String get report => 'Signaler';

  @override
  String get remove => 'Supprimer';

  @override
  String get subject => 'Sujet';

  @override
  String get message => 'Message';

  @override
  String get titleCannotBeEmpty => 'Le titre ne peut pas être vide';

  @override
  String get conversationUpdatedSuccessfully =>
      'Conversation mise à jour avec succès';

  @override
  String get goBack => 'Retour';

  @override
  String failedToLoadPost(String error) {
    return 'Échec du chargement de la publication : \n$error';
  }

  @override
  String failedToLikeOrUnlikeMessage(String action, String error) {
    return 'Échec du $action message : $error';
  }

  @override
  String get like => 'aimer';

  @override
  String get unlike => 'ne plus aimer';

  @override
  String downloading(String filename) {
    return 'Téléchargement de $filename...';
  }

  @override
  String openingShareSheet(String filename) {
    return 'Ouverture de la feuille de partage pour $filename';
  }

  @override
  String errorDownloading(String filename, String error) {
    return 'Erreur lors du téléchargement de $filename : $error';
  }

  @override
  String get failedToNavigateToForum => 'Échec de la navigation vers le forum';

  @override
  String forumNotFoundById(String forumId) {
    return 'Forum introuvable : $forumId';
  }

  @override
  String couldNotOpenLink(String error) {
    return 'Impossible d\'ouvrir le lien : $error';
  }

  @override
  String get translating => 'Traduction en cours...';

  @override
  String get translated => 'Traduit';

  @override
  String get translatedContent => 'Contenu traduit';

  @override
  String get twoFactorAuthentication => 'Authentification à deux facteurs';

  @override
  String get authenticationCodeLabel => 'Code d\'authentification';

  @override
  String get pleaseEnterYourAuthenticationCode =>
      'Veuillez saisir votre code d\'authentification';

  @override
  String codeMustBeDigits(int count) {
    return 'Le code doit contenir $count chiffres';
  }

  @override
  String get codeMustContainOnlyNumbers =>
      'Le code doit contenir uniquement des chiffres';

  @override
  String get verifyButton => 'Vérifier';

  @override
  String get attachments => 'Pièces jointes';

  @override
  String get replyOptions => 'Options de reponse';

  @override
  String get replyWithQuote => 'Repondre avec citation';

  @override
  String fileSavedToDownloads(String filename) {
    return 'Fichier enregistré dans Téléchargements : $filename';
  }

  @override
  String fileSavedToDocuments(String filename) {
    return 'Fichier enregistré dans Documents : $filename';
  }

  @override
  String topicLastReplyBy(String username, String time) {
    return '$username a répondu $time';
  }

  @override
  String inReplyToUser(String username) {
    return 'en réponse à $username';
  }

  @override
  String inReplyToPost(int number) {
    return 'en réponse au message n°$number';
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
  String get profileViews => 'Vues';

  @override
  String get badges => 'Badges';

  @override
  String get chatWithUser => 'Discussion';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count réponses',
      one: '1 réponse',
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
  String get lastSeen => 'Vu';

  @override
  String get chat => 'Discussion';

  @override
  String comingSoon(String label) {
    return '$label — bientôt disponible';
  }

  @override
  String moreBadges(Object count) {
    return '+$count de plus';
  }

  @override
  String get allNotificationsMarkedAsRead =>
      'Toutes les notifications marquées comme lues';

  @override
  String get apply => 'Appliquer';

  @override
  String get bookmarks => 'Signets';

  @override
  String reviewableBy(String username) {
    return 'Par $username';
  }

  @override
  String get changeEmail => 'Changer l’adresse e-mail';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get checkingStatus => 'Vérification de l’état…';

  @override
  String get clearReminder => 'Supprimer le rappel';

  @override
  String get copy => 'Copier';

  @override
  String get copyLink => 'Copier le lien';

  @override
  String couldNotEnableNotifications(String error) {
    return 'Impossible d’activer les notifications : $error';
  }

  @override
  String get couldNotFindBookmark => 'Signet introuvable';

  @override
  String couldNotOpenEmail(String email) {
    return 'Impossible d’ouvrir l’e-mail : $email';
  }

  @override
  String couldNotStartSignIn(String error) {
    return 'Impossible de démarrer la connexion : $error';
  }

  @override
  String get customDateAndTime => 'Date et heure personnalisées';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteMessageQuestion => 'Supprimer le message ?';

  @override
  String get discard => 'Abandonner';

  @override
  String get discardDraftQuestion => 'Abandonner le brouillon ?';

  @override
  String get doNotDisturb => 'Ne pas déranger';

  @override
  String get editHistory => 'Historique des modifications';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get editReminder => 'Modifier le rappel';

  @override
  String emailCopiedToClipboard(String email) {
    return 'E-mail copié dans le presse-papiers : $email';
  }

  @override
  String get pushEnabledForThisLogin => 'Activées pour cette connexion';

  @override
  String get failedToLoadMoreTopics =>
      'Impossible de charger plus de sujets. Faites défiler pour réessayer.';

  @override
  String get failedToUpdateNotificationLevel =>
      'Impossible de modifier le niveau de notification';

  @override
  String get firstPostsOnly => 'Premiers messages uniquement';

  @override
  String get ignoredUsers => 'Utilisateurs ignorés';

  @override
  String get inTwoHours => 'Dans deux heures';

  @override
  String get inviteByEmail => 'Inviter par e-mail';

  @override
  String get inviteLinkCopied => 'Lien d’invitation copié';

  @override
  String inviteSentTo(String email) {
    return 'Invitation envoyée à $email';
  }

  @override
  String get leave => 'Quitter';

  @override
  String get leaveGroup => 'Quitter le groupe';

  @override
  String get leaveGroupQuestion => 'Quitter le groupe ?';

  @override
  String get linkCopied => 'Lien copié';

  @override
  String get loadMore => 'Charger plus';

  @override
  String get manageAccountOnWeb => 'Gérer le compte sur le web';

  @override
  String get merge => 'Fusionner';

  @override
  String get mergeIntoTopic => 'Fusionner dans un sujet';

  @override
  String get newInviteLink => 'Nouveau lien d’invitation';

  @override
  String get nextWeek => 'La semaine prochaine';

  @override
  String get pushNotAvailableInThisBuild => 'Non disponible dans cette version';

  @override
  String get notNow => 'Pas maintenant';

  @override
  String tagNotificationLevelUpdated(String tag) {
    return 'Niveau de notification de « $tag » mis à jour';
  }

  @override
  String doNotDisturbOnUntil(String until) {
    return 'Activé jusqu’à $until';
  }

  @override
  String get pleaseLogInToBookmark => 'Connectez-vous pour ajouter un signet';

  @override
  String get pleaseLogInToFollowUsers =>
      'Connectez-vous pour suivre des utilisateurs';

  @override
  String get pleaseLogInToMarkAnswers =>
      'Connectez-vous pour marquer les réponses';

  @override
  String get pleaseLogInToReact => 'Connectez-vous pour réagir';

  @override
  String get pleaseLogInToVote => 'Connectez-vous pour voter';

  @override
  String get pushNotifications => 'Notifications push';

  @override
  String get relevance => 'Pertinence';

  @override
  String get reminderTimeMustBeInFuture =>
      'L’heure du rappel doit être dans le futur';

  @override
  String get removeBookmark => 'Supprimer le signet';

  @override
  String get removeVote => 'Retirer le vote';

  @override
  String get renameTopic => 'Renommer le sujet';

  @override
  String reportedBy(String username) {
    return 'Signalé par $username';
  }

  @override
  String get requestToJoin => 'Demander à rejoindre';

  @override
  String requestToJoinGroup(String group) {
    return 'Demander à rejoindre $group';
  }

  @override
  String get reset => 'Réinitialiser';

  @override
  String get resizeAndUpload => 'Redimensionner et envoyer';

  @override
  String get retryConnection => 'Réessayer la connexion';

  @override
  String get reviewQueue => 'File de modération';

  @override
  String get revoke => 'Révoquer';

  @override
  String get revokeInviteQuestion => 'Révoquer l’invitation ?';

  @override
  String get save => 'Enregistrer';

  @override
  String get sendInvite => 'Envoyer l’invitation';

  @override
  String get sendRequest => 'Envoyer la demande';

  @override
  String get settings => 'Paramètres';

  @override
  String get showVoters => 'Afficher les votants';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get signOutQuestion => 'Se déconnecter ?';

  @override
  String get signInCancelledNoPayload =>
      'Connexion annulée — aucune réponse reçue';

  @override
  String signInFailed(String error) {
    return 'Échec de la connexion : $error';
  }

  @override
  String get startChat => 'Démarrer la discussion';

  @override
  String stoppedIgnoringUser(String username) {
    return 'Vous n’ignorez plus @$username';
  }

  @override
  String get submit => 'Envoyer';

  @override
  String get discardDraftWarning =>
      'Le brouillon enregistré sera définitivement supprimé.';

  @override
  String get deleteChatMessageWarning =>
      'Le message sera supprimé pour tout le monde.';

  @override
  String get titleOnly => 'Titre uniquement';

  @override
  String get tomorrow => 'Demain';

  @override
  String get turnOff => 'Désactiver';

  @override
  String get turnOnNotifications => 'Activer les notifications';

  @override
  String get whisper => 'Chuchotement';

  @override
  String likeAgainInSeconds(Object seconds) {
    return 'Vous pourrez aimer ce message de nouveau dans ${seconds}s';
  }

  @override
  String get loginInfo => 'Informations de connexion';

  @override
  String get loginFailed => 'Échec de la connexion';

  @override
  String get moveToCategory => 'Déplacer vers une catégorie';

  @override
  String get undeleteTopic => 'Restaurer le sujet';

  @override
  String get undeleteTopicConfirmation =>
      'Voulez-vous vraiment restaurer ce sujet ? Il sera de nouveau visible par les autres utilisateurs.';

  @override
  String get send => 'Envoyer';

  @override
  String get changeEmailExplanation =>
      'Nous enverrons un lien de confirmation à votre nouvelle adresse. Le changement prend effet lorsque vous cliquez dessus.';

  @override
  String get changeEmailSecurityNote =>
      'Pour plus de sécurité, Discourse peut demander une confirmation via le lien de l’e-mail. Vérifiez vos spams si vous ne le voyez pas.';

  @override
  String get newDirectMessage => 'Nouveau message direct';

  @override
  String get noMessagesYetSayHi => 'Pas encore de messages — dites bonjour.';

  @override
  String get edited => 'modifié';

  @override
  String get editProfileManagedOnWebNote =>
      'Le nom affiché, l’e-mail, le mot de passe et les autres paramètres du compte se gèrent dans Compte → Gérer le compte sur le web. Votre avatar se change en touchant l’icône appareil photo sur votre photo.';

  @override
  String get approvedButRelayUnreachable =>
      'Approuvé, mais le serveur de notifications est injoignable pour terminer la configuration. Réessayez plus tard depuis les Réglages.';

  @override
  String get notificationsAreTurnedOffForThisApp =>
      'Les notifications sont désactivées pour cette application';

  @override
  String forumWillAskToApproveNotifications(Object forumName) {
    return 'Ensuite, $forumName vous demandera d’approuver « Notifications ».';
  }

  @override
  String get approveNotificationsExplanation =>
      'En approuvant, vous nous permettez de consulter vos notifications et de les envoyer sur cet appareil. Cette autorisation ne permet ni de publier, ni de répondre, ni de lire vos messages.';

  @override
  String get forumOwnerPushNote =>
      'Si le propriétaire de ce forum configure les notifications pour l’application, cette étape ne sera plus nécessaire.';

  @override
  String get pleaseLoginToCreateANewTopic =>
      'Connectez-vous pour créer un sujet';

  @override
  String get pleaseLoginToSubscribeToForums =>
      'Connectez-vous pour vous abonner aux forums';

  @override
  String leaveGroupWarning(Object group) {
    return 'Vous ne serez plus membre de $group. Vous pourrez rejoindre le groupe à tout moment.';
  }

  @override
  String get groupMembersPrivate =>
      'La liste des membres de ce groupe est privée.';

  @override
  String get unignore => 'Ne plus ignorer';

  @override
  String get inviteLinkCreated => 'Lien d’invitation créé';

  @override
  String expiresOn(Object date) {
    return 'Expire le $date';
  }

  @override
  String get protected => 'Protégé';

  @override
  String get solution => 'Solution';

  @override
  String get deleted => 'SUPPRIMÉ';

  @override
  String get pleaseLoginToViewUserProfiles =>
      'Connectez-vous pour voir les profils.';

  @override
  String get announcement => 'Annonce';

  @override
  String get solved => 'Résolu';

  @override
  String get hot => 'Populaire';

  @override
  String get pinned => 'Épinglé';

  @override
  String get subscribedLabel => 'Abonné';

  @override
  String get locked => 'Verrouillé';

  @override
  String get poll => 'Sondage';

  @override
  String errorLoadingContent(Object error) {
    return 'Erreur de chargement du contenu : $error';
  }

  @override
  String get noPermissionToViewSubforum =>
      'Vous n’avez pas la permission de voir les sujets de ce sous-forum.';

  @override
  String get noDiscussionsYet => 'Pas encore de discussions.';

  @override
  String get jumpToPost => 'Aller au message';

  @override
  String get jump => 'Aller';

  @override
  String get endOfTheDiscussion => 'Fin de la discussion';

  @override
  String get reviewQueueStaffOnly =>
      'Seuls le personnel et les modérateurs peuvent voir la file de modération.';

  @override
  String get nothingToReview => 'Rien à modérer';

  @override
  String refreshFailed(Object error) {
    return 'Échec de l’actualisation : $error';
  }

  @override
  String get topicDeletedBanner =>
      'Ce sujet est supprimé et masqué aux autres utilisateurs';

  @override
  String get topicClosedBanner =>
      'Ce sujet est fermé et n’accepte plus de réponses';

  @override
  String get topicPinnedBanner => 'Ce sujet est épinglé en haut du forum';

  @override
  String get youAreSubscribedToThisTopic => 'Vous êtes abonné à ce sujet';

  @override
  String get refreshing => 'Actualisation...';

  @override
  String get title => 'Titre';

  @override
  String editedAt(Object time) {
    return 'Modifié $time';
  }

  @override
  String editReason(Object reason) {
    return 'Raison : $reason';
  }

  @override
  String get thisDiffIsTooLargeToDisplay =>
      'Ce diff est trop volumineux pour être affiché.';

  @override
  String get noContentChangesInThisRevision =>
      'Aucune modification de contenu dans cette révision.';

  @override
  String revisionOf(Object currentVersion, Object versionCount) {
    return 'Révision $currentVersion sur $versionCount';
  }

  @override
  String get editConversation => 'Modifier la conversation';

  @override
  String get closeConversation => 'Fermer la conversation';

  @override
  String get openConversation => 'Ouvrir la conversation';

  @override
  String get leaveConversation2 => 'Quitter la conversation';

  @override
  String get reportConversation2 => 'Signaler la conversation';

  @override
  String get closeConversation2 => 'Fermer la conversation';

  @override
  String get closeConversationConfirmation =>
      'Voulez-vous vraiment fermer cette conversation ? Aucune nouvelle réponse ne pourra être publiée.';

  @override
  String get close => 'Fermer';

  @override
  String get openConversation2 => 'Ouvrir la conversation';

  @override
  String get openConversationConfirmation =>
      'Voulez-vous vraiment ouvrir cette conversation ? De nouvelles réponses pourront être publiées.';

  @override
  String get open => 'Ouvrir';

  @override
  String get leaveConversation3 => 'Quitter la conversation';

  @override
  String get leaveConversationConfirmation =>
      'Voulez-vous vraiment quitter cette conversation ? Elle sera masquée de votre boîte de réception.';

  @override
  String errorLoadingConversation(Object error) {
    return 'Erreur de chargement de la conversation : $error';
  }

  @override
  String get conversationNotFound => 'Conversation introuvable';

  @override
  String get conversationClosedBanner =>
      'Cette conversation est fermée et n’accepte plus de réponses';

  @override
  String get noMessagesFound => 'Aucun message trouvé';

  @override
  String get endOfConversation => 'Fin de la conversation';

  @override
  String get jumpToMessage => 'Aller au message';

  @override
  String get editConversation2 => 'Modifier la conversation';

  @override
  String get failedToLoadMessage2 => 'Impossible de charger le message';

  @override
  String get cannotEditThisConversation =>
      'Impossible de modifier cette conversation';

  @override
  String get options => 'Options';

  @override
  String get conversationOpen => 'Conversation ouverte';

  @override
  String failedToCreateConversation(Object error) {
    return 'Impossible de créer la conversation : $error';
  }

  @override
  String maximumAttachmentsAllowed(Object count) {
    return 'Maximum de $count pièce(s) jointe(s)';
  }

  @override
  String get noImagesFoundToDisplay => 'Aucune image à afficher.';

  @override
  String get pleaseLoginToViewThisAttachment =>
      'Connectez-vous pour voir cette pièce jointe';

  @override
  String get searchForTopics => 'Rechercher des sujets';

  @override
  String get noTopicsFound => 'Aucun sujet trouvé';

  @override
  String get trySearchingWithDifferentKeywords => 'Essayez d’autres mots-clés';

  @override
  String get noPostsFound => 'Aucun message trouvé';

  @override
  String get perTopicNotificationLevelsNote =>
      'Les niveaux de notification par catégorie et par sujet se règlent directement depuis ces écrans — touchez l’icône cloche d’un sujet ou d’une catégorie.';

  @override
  String get pushNotActiveForThisLogin =>
      'Inactives pour cette connexion — déconnectez-vous puis reconnectez-vous pour autoriser les notifications push';

  @override
  String get pauseNotificationsFor => 'Suspendre les notifications pendant…';

  @override
  String get doNotDisturbExplanation =>
      'Suspendez les notifications un moment — Discourse les retient jusqu’à la fin de la période';

  @override
  String get emailSettingsSubtitle =>
      'Fréquence des e-mails, regroupement des j’aime, planning des résumés';

  @override
  String get manageAccountSubtitle =>
      'Profil, e-mail, mot de passe, sécurité, paramètres avancés';

  @override
  String get changePasswordSubtitle =>
      'Envoie un e-mail de réinitialisation du mot de passe à votre adresse actuelle';

  @override
  String get ignoredUsersSubtitle =>
      'Voir et gérer les utilisateurs dont les messages vous sont masqués';

  @override
  String get deleteAccountExplanation =>
      'La suppression de votre compte se fait sur le forum. Continuez pour ouvrir le site et contacter l’équipe — les forums Discourse traitent les suppressions selon leur propre politique.';

  @override
  String get verificationEmailSent =>
      'E-mail de vérification envoyé — cliquez sur le lien pour confirmer votre nouvelle adresse.';

  @override
  String get passwordResetExplanation =>
      'Nous vous enverrons un lien de réinitialisation. Cliquez dessus pour choisir un nouveau mot de passe — le changement se fait sur le forum, pas dans cette application.';

  @override
  String get sendResetEmail => 'Envoyer l’e-mail de réinitialisation';

  @override
  String get deleteAccountDialogBody =>
      'Votre compte est géré par le forum. Contactez directement l’équipe du forum pour demander la suppression. « Continuer » ouvrira le forum dans votre navigateur pour utiliser son propre contact / message à l’équipe.';

  @override
  String get initializingForum => 'Initialisation du forum…';

  @override
  String get unableToLoadForums => 'Impossible de charger les forums';

  @override
  String get noForumsToDisplayExplanation =>
      'Aucun forum à afficher. Cela peut venir des permissions ou de la structure du forum.';

  @override
  String get subscribedForums => 'Forums suivis';

  @override
  String get errorLoadingNotifications =>
      'Erreur de chargement des notifications';

  @override
  String get pullDownToRefresh => 'Tirez vers le bas pour actualiser';

  @override
  String get noNewNotificationsExplanation =>
      'Aucune nouvelle notification. Revenez plus tard pour les nouveautés des sujets que vous suivez.';

  @override
  String noTagsMatch(Object filter) {
    return 'Aucune étiquette ne correspond à « $filter ».';
  }

  @override
  String noTopicsTagged(Object tag) {
    return 'Aucun sujet avec l’étiquette « $tag »';
  }

  @override
  String failedToBanUser2(Object error) {
    return 'Impossible de bannir l’utilisateur : $error';
  }

  @override
  String unbanUserConfirmation(Object username) {
    return 'Voulez-vous vraiment lever le bannissement de $username ?';
  }

  @override
  String failedToUnbanUser2(Object error) {
    return 'Impossible de lever le bannissement : $error';
  }

  @override
  String get deletePostsProfilePostsAndComments =>
      'Supprimer les messages, publications de profil et commentaires';

  @override
  String spamCleanConfirmation(Object username) {
    return 'Voulez-vous vraiment nettoyer le spam de $username ?';
  }

  @override
  String failedToCleanSpam(Object error) {
    return 'Échec du nettoyage du spam : $error';
  }

  @override
  String get searchUser => 'Rechercher un utilisateur';

  @override
  String get tapToOpen => 'Touchez pour ouvrir';

  @override
  String get imageNotAvailable => 'Image indisponible';

  @override
  String get allForumTopicsHaveBeenMarkedAs =>
      'Tous les sujets du forum ont été marqués comme lus';

  @override
  String postsCount(Object count) {
    return '$count messages';
  }

  @override
  String get permissionDeniedToSaveImage =>
      'Permission refusée pour enregistrer l’image';

  @override
  String get postNotFound => 'Message introuvable.';

  @override
  String get failedToUploadFilePleaseTryAgain =>
      'Échec de l’envoi du fichier. Veuillez réessayer.';

  @override
  String failedToUploadFile2(Object errorMessage) {
    return 'Échec de l’envoi du fichier : $errorMessage';
  }

  @override
  String get failedToPickFile => 'Impossible de sélectionner le fichier';

  @override
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return 'Seulement $remainingSlots pièce(s) jointe(s) supplémentaire(s) autorisée(s). Traitement des $remainingSlots2 première(s) image(s).';
  }

  @override
  String get attachmentLimitReachedSkippingRemainingImages =>
      'Limite de pièces jointes atteinte. Les images restantes sont ignorées.';

  @override
  String failedToUploadImagePleaseTryAgain(Object fileName) {
    return '$fileName : échec de l’envoi de l’image. Veuillez réessayer.';
  }

  @override
  String failedToUploadImage2(Object errorMessage, Object fileName) {
    return '$fileName : échec de l’envoi de l’image : $errorMessage';
  }

  @override
  String get failedToPickImage => 'Impossible de sélectionner l’image';

  @override
  String failedToRemoveAttachment2(Object error) {
    return 'Impossible de supprimer la pièce jointe : $error';
  }

  @override
  String sentFromMobileApp(Object siteName) {
    return 'Envoyé depuis l’application mobile $siteName';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      'Veuillez attendre la fin de l’envoi des pièces jointes';

  @override
  String get imageIsTooLargeToUpload =>
      'L’image est trop volumineuse pour être envoyée';

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName fait $fileBytes. Ce forum autorise jusqu’à $maxBytes.';
  }

  @override
  String get resizeToFitExplanation =>
      'Elle peut être réduite juste assez pour tenir, en conservant son format et autant de détails que la limite le permet.';

  @override
  String get failedToPostReplyPleaseTryAgain =>
      'Échec de la publication de la réponse. Veuillez réessayer.';

  @override
  String get pleaseWaitForTheThreadToLoad =>
      'Veuillez attendre le chargement du sujet';

  @override
  String get failedToUpdatePostPleaseTryAgain =>
      'Échec de la mise à jour du message. Veuillez réessayer.';

  @override
  String get postDeletedSuccessfully => 'Message supprimé';

  @override
  String failedToDeletePost(Object error) {
    return 'Échec de la suppression du message : $error';
  }

  @override
  String failedToSubmitReport2(Object error) {
    return 'Échec de l’envoi du signalement : $error';
  }

  @override
  String get editHistoryNotAvailable =>
      'L’historique des modifications n’est pas disponible pour ce message';

  @override
  String get noPermissionToUploadAvatar =>
      'Vous n’avez pas la permission d’envoyer un avatar';

  @override
  String get avatarUploadedSuccessfully => 'Avatar envoyé';

  @override
  String failedToPickImage2(Object error) {
    return 'Impossible de sélectionner l’image : $error';
  }

  @override
  String get react => 'Réagir';

  @override
  String get reactionsAreNotEnabledOnThisForum =>
      'Les réactions ne sont pas activées sur ce forum.';

  @override
  String get noReactionsYet => 'Pas encore de réactions';

  @override
  String get searchFilters => 'Filtres de recherche';

  @override
  String signOutWarning(Object siteName) {
    return 'Vous serez déconnecté de $siteName. Vous pourrez vous reconnecter à tout moment.';
  }

  @override
  String get suggestedTopics => 'Sujets suggérés';

  @override
  String get newLabel => 'NOUVEAU';

  @override
  String get voteRemoved => 'Vote retiré';

  @override
  String get voters => 'Votants';

  @override
  String get noVotesYet => 'Pas encore de votes.';

  @override
  String get trustLevels => 'Niveaux de confiance';

  @override
  String get trustLevelsExplanation =>
      'Les membres gagnent en confiance en lisant et en participant. Chaque niveau débloque de nouvelles possibilités.';

  @override
  String get activity => 'Activité';

  @override
  String get dontUpload => 'Ne pas envoyer';

  @override
  String get dontAskAgainAlwaysResize =>
      'Ne plus demander — toujours redimensionner';

  @override
  String get couldNotLoadCategories => 'Impossible de charger les catégories.';

  @override
  String get switchForum => 'Changer de forum';

  @override
  String get explore => 'Explorer';

  @override
  String get tags => 'Étiquettes';

  @override
  String get community => 'Communauté';

  @override
  String get users => 'Utilisateurs';

  @override
  String get groups => 'Groupes';

  @override
  String get invites => 'Invitations';

  @override
  String get account => 'Compte';

  @override
  String get drafts => 'Brouillons';

  @override
  String get termsOfService => 'Conditions d’utilisation';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String signedInAs(String username) {
    return 'Connecté en tant que $username';
  }

  @override
  String get notSignedIn => 'Non connecté';

  @override
  String get deviceWillNotShowAlertsUntilAllowedInSettings =>
      'Votre appareil n\'affichera aucune alerte tant que vous n\'autorisez pas les notifications dans les Réglages.';

  @override
  String get openSettings => 'Ouvrir les réglages';

  @override
  String get notificationsOnThisDevice => 'Notifications sur cet appareil';

  @override
  String get notificationsGrantOnSubtitle =>
      'Les réponses, mentions et messages de ce forum sont livrés ici.';

  @override
  String get notificationsGrantOffSubtitle =>
      'Approuvez une fois sur le forum pour recevoir ici ses réponses, mentions et messages.';

  @override
  String get turnOn => 'Activer';

  @override
  String get couldNotTurnOffNotifications =>
      'Impossible de désactiver les notifications. Réessayez plus tard.';
}
