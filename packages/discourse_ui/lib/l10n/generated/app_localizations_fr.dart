// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Forum App';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get usernameLabel => 'Nom d\'utilisateur';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get signInWithPasskey => 'Sign in with Passkey';

  @override
  String get usePasskey => 'Use Passkey';

  @override
  String get passkeyContinuePrompt => 'Use your passkey to continue';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get pleaseEnterUsername => 'Veuillez entrer votre nom d\'utilisateur';

  @override
  String get pleaseEnterPassword => 'Veuillez entrer votre mot de passe';

  @override
  String credentialsSentToDomain(String domain) {
    return 'Votre nom d\'utilisateur et mot de passe seront envoyés à $domain';
  }

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ? ';

  @override
  String get logIn => 'Se connecter';

  @override
  String get continueButton => 'Continuer';

  @override
  String get registrationNotAvailable => 'Inscription non disponible';

  @override
  String get registrationNotAvailableMessage =>
      'L\'inscription n\'est actuellement pas disponible. Le forum peut être fermé ou l\'inscription peut être désactivée.';

  @override
  String get webRegistrationRequired => 'Inscription web requise';

  @override
  String get webRegistrationRequiredMessage =>
      'Ce forum nécessite une inscription via le navigateur web. Veuillez cliquer sur le bouton ci-dessous pour ouvrir la page d\'inscription.';

  @override
  String get openRegistrationPage => 'Ouvrir la page d\'inscription';

  @override
  String get loadingAdditionalFields =>
      'Chargement des champs supplémentaires...';

  @override
  String get pleaseSelectDateOfBirth =>
      'Veuillez sélectionner votre date de naissance';

  @override
  String get pleaseEnterLocation => 'Veuillez entrer votre localisation';

  @override
  String get pleaseIndicateEmailPreference =>
      'Veuillez indiquer votre préférence d\'e-mail';

  @override
  String get pleaseFillAllRequiredFields =>
      'Veuillez remplir tous les champs obligatoires';

  @override
  String get pleaseAcceptTermsOfService =>
      'Veuillez accepter les Conditions d\'utilisation';

  @override
  String get pleaseAcceptPrivacyPolicy =>
      'Veuillez accepter la Politique de confidentialité';

  @override
  String get registrationError => 'Erreur d\'inscription';

  @override
  String get registrationFailed =>
      'L\'inscription a échoué. Veuillez vérifier vos informations.';

  @override
  String get registrationFailedTryAgain =>
      'L\'inscription a échoué. Veuillez réessayer.';

  @override
  String get registrationInfo => 'Informations d\'inscription';

  @override
  String get openWebsite => 'Ouvrir le site web';

  @override
  String couldNotOpenForumWebsite(String url) {
    return 'Impossible d\'ouvrir le site web du forum. Veuillez essayer de visiter : $url';
  }

  @override
  String get registrationSuccessfulEmailConfirm =>
      'Inscription réussie ! Veuillez vérifier votre e-mail pour confirmer votre compte avant de vous connecter.';

  @override
  String get registrationSuccessfulPendingApproval =>
      'Inscription réussie ! Votre compte est en attente d\'approbation. Vous serez notifié lorsque votre compte sera approuvé.';

  @override
  String get registrationSuccessfulAutoLogin =>
      'Inscription réussie ! Vous avez été automatiquement connecté.';

  @override
  String get welcome => 'Bienvenue !';

  @override
  String get registrationSuccessful => 'Inscription réussie';

  @override
  String get pleaseLoginWithNewAccount =>
      'Veuillez vous connecter avec votre nouveau compte.';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get usernameOrEmailLabel => 'Nom d\'utilisateur ou e-mail';

  @override
  String get pleaseEnterUsernameOrEmail =>
      'Veuillez entrer votre nom d\'utilisateur ou e-mail';

  @override
  String get sendResetLink => 'Envoyer le lien de réinitialisation';

  @override
  String get resetLinkSent => 'Lien de réinitialisation envoyé';

  @override
  String get passwordResetInstructionsSent =>
      'Les instructions pour réinitialiser votre mot de passe ont été envoyées à votre adresse e-mail enregistrée.';

  @override
  String get resetFailed => 'Échec de la réinitialisation';

  @override
  String get unableToSendResetLink =>
      'Impossible d\'envoyer le lien de réinitialisation. Veuillez réessayer.';

  @override
  String get errorSendingResetLink =>
      'Une erreur s\'est produite lors de l\'envoi du lien de réinitialisation. Veuillez vérifier votre connexion et réessayer.';

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
  String get getHelp => 'Obtenir de l\'aide';

  @override
  String get somethingWentWrong => 'Quelque chose s\'est mal passé';

  @override
  String get unexpectedErrorOccurred =>
      'Une erreur inattendue s\'est produite. Veuillez réessayer.';

  @override
  String get noInternetConnection => 'Pas de connexion Internet';

  @override
  String get checkInternetConnection =>
      'Veuillez vérifier votre connexion Internet et réessayer.';

  @override
  String get authenticationRequired => 'Authentification requise';

  @override
  String get pleaseLoginToContinue => 'Veuillez vous connecter pour continuer.';

  @override
  String get forumError => 'Erreur du forum';

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
  String get noUnreadTopics => 'Aucun sujet non lu';

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
  String get noSubscribedTopics => 'Aucun sujet abonné';

  @override
  String get noSubscribedTopicsMessage =>
      'Vous ne vous êtes abonné à aucun sujet. Appuyez sur le bouton étoile sur un sujet pour vous abonner et recevoir des notifications pour les nouvelles mises à jour.';

  @override
  String get signInToViewSubscribedTopics =>
      'Connectez-vous pour voir les sujets abonnés';

  @override
  String get youNeedToBeSignedInToViewSubscribedTopics =>
      'Vous devez être connecté pour voir vos sujets abonnés';

  @override
  String get noParticipatedTopics => 'Aucun sujet participé';

  @override
  String get topicsYouParticipatedIn =>
      'Les sujets auxquels vous avez participé seront affichés ici.';

  @override
  String get signInToViewParticipatedTopics =>
      'Connectez-vous pour voir les sujets participés';

  @override
  String get youNeedToBeSignedInToViewParticipatedTopics =>
      'Vous devez être connecté pour voir les sujets auxquels vous avez participé';

  @override
  String get latest => 'Récent';

  @override
  String get unread => 'Non lu';

  @override
  String get subscribed => 'Abonné';

  @override
  String get participated => 'Participé';

  @override
  String get connectionTimedOut =>
      'Délai de connexion expiré. Le site peut être hors ligne ou inaccessible.';

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
  String get newMessage => 'Nouveau message';

  @override
  String get appSettings => 'Paramètres de l\'application';

  @override
  String get searchSites => 'Rechercher des sites';

  @override
  String get language => 'Langue';

  @override
  String get systemDefault => 'Par défaut du système';

  @override
  String get followSystemLanguage => 'Suivre la langue du système';

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
  String get unsubscribe => 'Se désabonner';

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
  String get reportUser => 'Signaler l\'utilisateur';

  @override
  String get pleaseSelectReasonForReportingUser =>
      'Veuillez sélectionner une raison pour signaler cet utilisateur.';

  @override
  String get spamOrAdvertising => 'Spam ou publicité';

  @override
  String get harassmentOrBullying => 'Harcèlement ou intimidation';

  @override
  String get inappropriateContent => 'Contenu inapproprié';

  @override
  String get impersonationOrFakeAccount =>
      'Usurpation d\'identité ou compte faux';

  @override
  String get otherPleaseSpecify => 'Autre (veuillez préciser)';

  @override
  String get pleaseSpecifyReason => 'Veuillez préciser la raison';

  @override
  String get enterReasonForReportingUser =>
      'Entrez la raison de signalement de cet utilisateur';

  @override
  String get pleaseSelectReason => 'Veuillez sélectionner une raison';

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
  String get leaveConversation => 'Quitter la conversation';

  @override
  String get reportConversation => 'Signaler la conversation';

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
  String get myForums => 'Mes Forums';

  @override
  String get recentlyVisited => 'Récemment Visités';

  @override
  String get explore => 'Explorer';

  @override
  String get forumCopilot => 'Forum Copilot';

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
  String get failedToSaveMessage => 'Échec de l\'enregistrement du message';

  @override
  String get failedToSaveConversation =>
      'Échec de l\'enregistrement de la conversation';

  @override
  String get failedToSaveSetting => 'Échec de l\'enregistrement du paramètre';

  @override
  String get failedToSavePost => 'Échec de l\'enregistrement du message';

  @override
  String errorLoadingSites(String error) {
    return 'Erreur lors du chargement des sites : $error';
  }

  @override
  String connectingTo(String domainName) {
    return 'Connexion à $domainName...';
  }

  @override
  String get members => 'Membres';

  @override
  String get allMembers => 'Tous les Membres';

  @override
  String get online => 'En Ligne';

  @override
  String get noMembersFound => 'Aucun membre trouvé';

  @override
  String get searchForMembers => 'Rechercher des membres';

  @override
  String get enterUsernameToFindMembers =>
      'Entrez un nom d\'utilisateur pour trouver des membres du forum';

  @override
  String get noMembersOnline => 'Aucun membre n\'est actuellement en ligne';

  @override
  String get enterUsernameToSearch =>
      'Entrez le nom d\'utilisateur pour rechercher...';

  @override
  String get lookupMembers => 'Rechercher des Membres';

  @override
  String get addMembers => 'Ajouter des Membres';

  @override
  String get membersAddedSuccessfully => 'Membres ajoutés avec succès';

  @override
  String errorAddingMembers(String error) {
    return 'Erreur lors de l\'ajout de membres : $error';
  }

  @override
  String get failedToLoadOnlineUsers =>
      'Échec du chargement des utilisateurs en ligne';

  @override
  String get noUsersOnline => 'Aucun utilisateur en ligne';

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
  String get areYouSureYouWantToDeleteThisMessage =>
      'Êtes-vous sûr de vouloir supprimer ce message ?';

  @override
  String failedToDeleteMessage(String error) {
    return 'Échec de la suppression du message : $error';
  }

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
  String failedToThankPost(String error) {
    return 'Échec du remerciement du message : $error';
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
  String errorLoadingMoreMessages(String error) {
    return 'Erreur lors du chargement de plus de messages : $error';
  }

  @override
  String get inviteMessageOptional => 'Message d\'Invitation (optionnel)';

  @override
  String get iWouldLikeToAddYouToThisConversation =>
      'J\'aimerais vous ajouter à cette conversation.';

  @override
  String get searchFailed => 'Recherche échouée';

  @override
  String get trySearchingWithDifferentUsername =>
      'Essayez de rechercher avec un nom d\'utilisateur différent';

  @override
  String get noSitesFound => 'Aucun site trouvé.';

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
  String get welcomeBack => 'Bon retour !';

  @override
  String get signInToAccessYourProfile =>
      'Connectez-vous pour accéder à votre profil et gérer votre compte';

  @override
  String get enterYourUsername => 'Entrez votre nom d\'utilisateur';

  @override
  String get enterYourPassword => 'Entrez votre mot de passe';

  @override
  String get dontHaveAnAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get enterKeywordsToSearchTopics =>
      'Entrez des mots-clés pour rechercher des sujets...';

  @override
  String get pleaseFillInAllRequiredFields =>
      'Veuillez remplir tous les champs obligatoires';

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
  String get enterKeywordsOrDomainToFindForums =>
      'Entrez des mots-clés ou un domaine pour trouver des forums';

  @override
  String get enterKeywordsOrDomainNamesToFindForums =>
      'Entrez des mots-clés ou des noms de domaine pour trouver des forums';

  @override
  String get appearance => 'Apparence';

  @override
  String get followSystemTheme => 'Suivre le thème du système';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String version(String version, String buildNumber) {
    return 'version $version ($buildNumber)';
  }

  @override
  String get forumSettings => 'Paramètres du forum';

  @override
  String get noSettingsAvailable => 'Aucun paramètre disponible';

  @override
  String get settingsCategoriesWillAppearHere =>
      'Les catégories de paramètres apparaîtront ici lorsqu\'elles seront disponibles.';

  @override
  String get unableToLoadProfile => 'Impossible de charger le profil';

  @override
  String get banned => 'BANNI';

  @override
  String get reportSubmittedSuccessfully => 'Rapport soumis avec succès';

  @override
  String get failedToSubmitReport => 'Échec de la soumission du rapport';

  @override
  String get searchForForums => 'Rechercher des forums';

  @override
  String get searchForums => 'Rechercher des Forums';

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
  String errorLoadingMessage(String error) {
    return 'Erreur lors du chargement du message: $error';
  }

  @override
  String get messageNotFound => 'Message introuvable';

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
  String get alignLeft => 'Aligner à gauche';

  @override
  String get alignCenter => 'Aligner au centre';

  @override
  String get alignRight => 'Aligner à droite';

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
  String get loggingIn => 'Connexion en cours...';

  @override
  String get submittingReport => 'Envoi du rapport...';

  @override
  String get banningUser => 'Bannissement de l\'utilisateur...';

  @override
  String get unbanningUser => 'Débannissement de l\'utilisateur...';

  @override
  String get cleaningSpam => 'Nettoyage du spam...';

  @override
  String get enterSubject => 'Entrez le sujet';

  @override
  String get typeYourMessageHere => 'Tapez votre message ici';

  @override
  String get writeYourMessage => 'Écrivez votre message...';

  @override
  String get writeYourReply => 'Écrivez votre réponse...';

  @override
  String get messageSentSuccessfully => 'Message envoyé avec succès';

  @override
  String get replySentSuccessfully => 'Réponse envoyée avec succès';

  @override
  String get conversationCreatedSuccessfully =>
      'Conversation créée avec succès';

  @override
  String get conversationMarkedAsUnread => 'Conversation marquée comme non lue';

  @override
  String get messageMarkedAsUnread => 'Message marqué comme non lu';

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
  String failedToUploadFile(String error) {
    return 'Échec du téléchargement du fichier : $error';
  }

  @override
  String failedToUploadImage(String error) {
    return 'Échec du téléchargement de l\'image : $error';
  }

  @override
  String failedToSendMessage(String error) {
    return 'Échec de l\'envoi du message : $error';
  }

  @override
  String failedToSendReply(String error) {
    return 'Échec de l\'envoi de la réponse : $error';
  }

  @override
  String failedToMarkAsUnread(String error) {
    return 'Échec du marquage du message comme non lu : $error';
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
  String get replyAll => 'Répondre à tous';

  @override
  String get forward => 'Transférer';

  @override
  String get noForumsFound => 'Aucun forum trouvé.';

  @override
  String get pleaseLoginToAccessContent =>
      'Veuillez vous connecter pour accéder à ce contenu et interagir avec les publications.';

  @override
  String get searchUsers => 'Rechercher des utilisateurs...';

  @override
  String get writeYourTitle => 'Écrivez votre titre...';

  @override
  String get writeYourContent => 'Écrivez votre contenu...';

  @override
  String get selectAnOption => 'Sélectionnez une option';

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
  String get unfollow => 'Ne plus suivre';

  @override
  String get follow => 'Suivre';

  @override
  String get goToForums => 'Aller aux Forums';

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
  String get privateMessagesNotAvailable => 'Messages privés non disponibles';

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
  String get optimizeImage => 'Optimiser l\'image';

  @override
  String get optimizeAndUpload => 'Optimiser et télécharger';

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
  String get enterANumber => 'Entrez un nombre';

  @override
  String get failedToNavigateToForum => 'Échec de la navigation vers le forum';

  @override
  String failedToNavigateToForumName(String forumName) {
    return 'Échec de la navigation vers $forumName';
  }

  @override
  String forumNotFound(String forumName) {
    return 'Forum introuvable : $forumName';
  }

  @override
  String forumNotFoundById(String forumId) {
    return 'Forum introuvable : $forumId';
  }

  @override
  String couldNotOpenLink(String error) {
    return 'Impossible d\'ouvrir le lien : $error';
  }

  @override
  String get likePost => 'Aimer le message';

  @override
  String get unlikePost => 'Ne plus aimer';

  @override
  String get thankPost => 'Remercier le message';

  @override
  String get showLikes => 'Afficher les j\'aime';

  @override
  String get showThanks => 'Afficher les remerciements';

  @override
  String get quotePost => 'Citer le message';

  @override
  String get translate => 'Traduire';

  @override
  String get showOriginal => 'Afficher l\'original';

  @override
  String get translating => 'Traduction en cours...';

  @override
  String get translated => 'Traduit';

  @override
  String get translatedContent => 'Contenu traduit';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get translateTo => 'Traduire vers :';

  @override
  String get deviceLanguage => 'Langue de l\'appareil';

  @override
  String get noPostsToTranslate => 'Aucun message à traduire';

  @override
  String get translationFailed => 'Échec de la traduction';

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
  String get loginInfo => 'Login Info';

  @override
  String get loginFailed => 'Login Failed';

  @override
  String get additionalInformation => 'Additional Information';

  @override
  String dateOfBirth(Object marker) {
    return 'Date of Birth$marker';
  }

  @override
  String minimumAgeYears(Object minimumAge) {
    return 'Minimum age: $minimumAge years';
  }

  @override
  String locationLabel(Object marker) {
    return 'Location$marker';
  }

  @override
  String get receiveSiteMailings => 'Receive site mailings';

  @override
  String get moveToCategory => 'Move to category';

  @override
  String get undeleteTopic => 'Undelete Topic';

  @override
  String get undeleteTopicConfirmation =>
      'Are you sure you want to undelete this topic? It will be visible to other users again.';

  @override
  String get send => 'Send';

  @override
  String get changeEmailExplanation =>
      'We’ll send a confirmation link to your new email. The change takes effect when you click it.';

  @override
  String get changeEmailSecurityNote =>
      'For added security, Discourse may require you to confirm via the link in the email. Check your spam folder if you don’t see it.';

  @override
  String get newDirectMessage => 'New direct message';

  @override
  String get noMessagesYetSayHi => 'No messages yet — say hi.';

  @override
  String get edited => 'edited';

  @override
  String get imageExceedsUploadLimits =>
      'This image exceeds the upload limits and needs to be optimized:';

  @override
  String get optimizationsToBeApplied => 'Optimizations to be applied:';

  @override
  String reductionPercent(Object percent) {
    return 'Reduction: $percent%';
  }

  @override
  String get editProfileManagedOnWebNote =>
      'Display name, email, password, and other account settings are managed under Account → Manage account on web. Your avatar can be changed by tapping the camera badge on your photo.';

  @override
  String get approvedButRelayUnreachable =>
      'Approved, but we could not reach ForumCopilot to finish setting up. Try again later from Settings.';

  @override
  String get notificationsAreTurnedOffForThisApp =>
      'Notifications are turned off for this app';

  @override
  String forumWillAskToApproveNotifications(Object forumName) {
    return 'Next, $forumName will ask you to approve “Notifications”.';
  }

  @override
  String get approveNotificationsExplanation =>
      'Approving lets us check your notifications for you and send them to this device. This permission cannot post, reply, or read your messages.';

  @override
  String get forumOwnerPushNote =>
      'If this forum’s owner sets up notifications for the app, this step won’t be needed.';

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
  String get protected => 'Protected';

  @override
  String get solution => 'Solution';

  @override
  String get deleted => 'DELETED';

  @override
  String get pleaseLoginToViewUserProfiles =>
      'Please login to view user profiles.';

  @override
  String get announcement => 'Announcement';

  @override
  String get solved => 'Solved';

  @override
  String get hot => 'Hot';

  @override
  String get pinned => 'Pinned';

  @override
  String get subscribedLabel => 'Subscribed';

  @override
  String get locked => 'Locked';

  @override
  String get poll => 'Poll';

  @override
  String errorLoadingContent(Object error) {
    return 'Error loading content: $error';
  }

  @override
  String get noPermissionToViewSubforum =>
      'You do not have permission to view topics in this subforum.';

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
  String get topicDeletedBanner =>
      'This topic is deleted and hidden from other users';

  @override
  String get topicClosedBanner =>
      'This topic is closed and no longer accepting replies';

  @override
  String get topicPinnedBanner =>
      'This topic is pinned to the top of the forum';

  @override
  String get youAreSubscribedToThisTopic => 'You are subscribed to this topic';

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
  String get editConversation => 'Edit conversation';

  @override
  String get closeConversation => 'Close conversation';

  @override
  String get openConversation => 'Open conversation';

  @override
  String get leaveConversation2 => 'Leave conversation';

  @override
  String get reportConversation2 => 'Report conversation';

  @override
  String get closeConversation2 => 'Close Conversation';

  @override
  String get closeConversationConfirmation =>
      'Are you sure you want to close this conversation? This will prevent new replies from being posted.';

  @override
  String get close => 'Close';

  @override
  String get openConversation2 => 'Open Conversation';

  @override
  String get openConversationConfirmation =>
      'Are you sure you want to open this conversation? This will allow new replies to be posted.';

  @override
  String get open => 'Open';

  @override
  String get leaveConversation3 => 'Leave Conversation';

  @override
  String get leaveConversationConfirmation =>
      'Are you sure you want to leave this conversation? This will hide it from your inbox.';

  @override
  String errorLoadingConversation(Object error) {
    return 'Error loading conversation: $error';
  }

  @override
  String get conversationNotFound => 'Conversation not found';

  @override
  String get conversationClosedBanner =>
      'This conversation is closed and no longer accepting replies';

  @override
  String get noMessagesFound => 'No messages found';

  @override
  String get endOfConversation => 'End of conversation';

  @override
  String get jumpToMessage => 'Jump to Message';

  @override
  String get editConversation2 => 'Edit Conversation';

  @override
  String get failedToLoadMessage2 => 'Failed to load message';

  @override
  String get cannotEditThisConversation => 'Cannot edit this conversation';

  @override
  String get options => 'Options';

  @override
  String get conversationOpen => 'Conversation Open';

  @override
  String failedToCreateConversation(Object error) {
    return 'Failed to create conversation: $error';
  }

  @override
  String maximumAttachmentsAllowed(Object count) {
    return 'Maximum of $count attachment(s) allowed';
  }

  @override
  String get noImagesFoundToDisplay => 'No images found to display.';

  @override
  String get pleaseLoginToViewThisAttachment =>
      'Please login to view this attachment';

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
  String get emailSettingsSubtitle =>
      'Email frequency, like aggregation, digest schedule';

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
      'Removing your account is handled on the forum. Continue to open the site and contact the staff team — Discourse forums process deletions per their own policy.';

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
  String get unableToLoadForums => 'Unable to Load Forums';

  @override
  String get noForumsToDisplayExplanation =>
      'There are no forums to display. This might be due to permissions or the forum structure.';

  @override
  String get subscribedForums => 'Subscribed Forums';

  @override
  String get errorLoadingNotifications => 'Error loading notifications';

  @override
  String get pullDownToRefresh => 'Pull down to refresh';

  @override
  String get noNewNotificationsExplanation =>
      'You have no new notifications. Check back later for updates on topics you\'re following.';

  @override
  String noTagsMatch(Object filter) {
    return 'No tags match \"$filter\".';
  }

  @override
  String noTopicsTagged(Object tag) {
    return 'No topics tagged \"$tag\"';
  }

  @override
  String failedToBanUser2(Object error) {
    return 'Failed to ban user: $error';
  }

  @override
  String unbanUserConfirmation(Object username) {
    return 'Are you sure you want to unban $username?';
  }

  @override
  String failedToUnbanUser2(Object error) {
    return 'Failed to unban user: $error';
  }

  @override
  String get deletePostsProfilePostsAndComments =>
      'Delete posts, profile posts, and comments';

  @override
  String spamCleanConfirmation(Object username) {
    return 'Are you sure you want to spam clean $username?';
  }

  @override
  String failedToCleanSpam(Object error) {
    return 'Failed to clean spam: $error';
  }

  @override
  String get searchUser => 'Search User';

  @override
  String get tapToOpen => 'Tap to open';

  @override
  String get imageNotAvailable => 'Image not available';

  @override
  String get allForumTopicsHaveBeenMarkedAs =>
      'All forum topics have been marked as read';

  @override
  String postsCount(Object count) {
    return '$count Posts';
  }

  @override
  String get protectedForum => 'Protected Forum';

  @override
  String isPasswordProtected(Object forumName) {
    return '$forumName is password protected.';
  }

  @override
  String get enter => 'Enter';

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
  String get failedToPickFile => 'Failed to pick file';

  @override
  String onlyNMoreAttachmentsAllowed(
      Object remainingSlots, Object remainingSlots2) {
    return 'Only $remainingSlots more attachment(s) allowed. Processing first $remainingSlots2 image(s).';
  }

  @override
  String get attachmentLimitReachedSkippingRemainingImages =>
      'Attachment limit reached. Skipping remaining images.';

  @override
  String failedToUploadImagePleaseTryAgain(Object fileName) {
    return '$fileName: Failed to upload image. Please try again.';
  }

  @override
  String failedToUploadImage2(Object errorMessage, Object fileName) {
    return '$fileName: Failed to upload image: $errorMessage';
  }

  @override
  String get failedToPickImage => 'Failed to pick image';

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
  String get pleaseWaitForTheThreadToLoad =>
      'Please wait for the thread to load';

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
  String failedToSubmitReport2(Object error) {
    return 'Failed to submit report: $error';
  }

  @override
  String get editHistoryNotAvailable =>
      'Edit history is not available for this post';

  @override
  String get noPermissionToUploadAvatar =>
      'You do not have permission to upload avatars';

  @override
  String get avatarUploadedSuccessfully => 'Avatar uploaded successfully';

  @override
  String failedToPickImage2(Object error) {
    return 'Failed to pick image: $error';
  }

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
  String signOutWarning(Object siteName) {
    return 'You will be signed out of $siteName. You can sign back in any time.';
  }

  @override
  String get suggestedTopics => 'Suggested Topics';

  @override
  String get newLabel => 'NEW';

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
}
